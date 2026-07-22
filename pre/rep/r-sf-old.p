block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id           as recid                no-undo.
define input parameter invers           as logical              no-undo.
define input parameter p-mode           as character            no-undo.
define input parameter p-round          as character            no-undo.
define input parameter p-no-slt         as logical              no-undo .
define input parameter p-reverse        as logical              no-undo .
do
on error undo, return error
:
define variable vss-revision    as character no-undo initial "$Revision: c93cbc1375c4, 1081, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Oct 12 16:32:18 2017 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-sf-old.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-sf-old.p $":U .
define variable vss-description as character no-undo initial "Печать счета-фактуры.":U .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function breakstr returns character ( input        for-name    as character,
                                      input        line-length as integer,
                                      input-output line1       as character,
                                      input-output line2       as character ) :
  define variable ii as integer no-undo.
  if length( for-name ) > line-length then do:
    assign ii    = 1
           line1 = "":u
           line2 = "":u.
    if length( entry( ii, for-name , " ":u ) ) > line-length then do:
      assign line1 =       substring( for-name, 1, line-length     )
             line2 = trim( substring( for-name,    line-length + 1 ) ).
    end.                                                     else do:
      do while length( line1 + entry( ii, for-name, " ":u ) ) < ( line-length + 1 ) :
        assign line1 = line1 + entry( ii, for-name, " ":u ) + " ":u
               ii    = ii    + 1.
        if length( entry( ii, for-name, " ":u ) ) > line-length then do:
          assign line1 = line1 + substring( for-name, length( line1 ), line-length - length( line1 ) + 1 ).
        end.
      end.
      assign line2 = trim( substring( for-name, length( line1 ) ) ).
    end.
  end.                                else do:
    assign line1 = for-name
           line2 = "":u.
  end.
  return ( line1 ).
end function.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
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
function cross-list returns logical (
  input parfirst-stream  as character,
  input parsecond-stream as character,
  input pardelim         as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  define variable vari            as integer no-undo .
  define variable varresult-cross as logical no-undo .
  assign
    varresult-cross = no
  .
  def var v-num-parfirst-stream as integer no-undo .
  assign
    v-num-parfirst-stream = num-entries(parfirst-stream, pardelim)
  .
  do vari = 1 to v-num-parfirst-stream
  :
    if lookup(entry(vari, parfirst-stream, pardelim)
             ,parsecond-stream
             ,pardelim
             ) > 0 then do:
      assign
        varresult-cross = yes
      .
      leave.
    end.
  end.
  return varresult-cross .
end function.
function hvrdtax return logical (input parrecid as recid):
define variable varresult as logical no-undo.
run hvrdtax-proc (input parrecid, output varresult).
return varresult.
end function.
procedure hvrdtax-proc:
define input  parameter parrecid  as recid   no-undo.
define output parameter parresult as logical no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_units for ub.units.
define buffer rt_tax   for ub.tax.
find first rt_tax   where rt_tax.tax-code    = integer('3':U) no-lock no-error.
find first bf_goods where recid(bf_goods)    = parrecid              no-lock.
find first bf_units where bf_units.unit-name = bf_goods.unit-base    no-lock.
if available rt_tax and
    can-find(first ub.tax-units No-LOCK WHERE
                   ub.tax-units.tax-code = rt_tax.tax-code AND
                   LOOKUP(ub.tax-units.type, bf_units.type) > 0) then assign parresult = yes.
                                                    else assign parresult = no.
end procedure.
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    def var v-tax-name      as char                         no-undo.
    def var v-tax-price     as decimal      init 0          no-undo.
    def var v-tax           as decimal      init 0          no-undo.
    def var v-tot-tax       as decimal      init 0          no-undo.
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-fmtcli-name          as character    no-undo.
define variable v-fmtcli-engl-name     as character    no-undo.
define variable v-fmtcli-addres        as character    no-undo.
define variable v-fmtcli-post-addres   as character    no-undo.
define variable v-fmtcli-full-addres   as character    no-undo.
define variable v-fmtcli-phone         as character    no-undo.
define variable v-fmtcli-inn           as character    no-undo.
define variable v-fmtcli-kpp           as character    no-undo.
define variable v-fmtcli-okpo          as character    no-undo.
define variable v-fmtcli-country       as character    no-undo.
define variable v-fmtcli-city          as character    no-undo.
define variable v-fmtcli-index         as character    no-undo.
define variable v-fmtcli-schet-exists  as logical      no-undo.
define variable v-fmtcli-bank-exists   as logical      no-undo.
define variable v-fmtcli-bank-r-schet  as character    no-undo.
define variable v-fmtcli-bank-c-schet  as character    no-undo.
define variable v-fmtcli-bank-bik      as character    no-undo.
define variable v-fmtcli-bank-name     as character    no-undo.
define variable v-fmtcli-bank-addres   as character    no-undo.
define variable v-fmtcli-bank-city     as character    no-undo.
procedure fmtcli-get-bank :
define input parameter p-host-code      as integer          no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-curr-code      as integer          no-undo.
    define buffer buf_fin-schet     for ub.fin-schet.
    define buffer buf_fin-bank      for ub.fin-bank.
do
for buf_fin-schet
  , buf_fin-bank
on error undo, return error
:
    assign
        v-fmtcli-schet-exists       = no
        v-fmtcli-bank-exists        = no
        v-fmtcli-bank-r-schet       = "":U
        v-fmtcli-bank-c-schet       = "":U
        v-fmtcli-bank-bik           = "":U
        v-fmtcli-bank-name          = "":U
        v-fmtcli-bank-addres        = "":U
        v-fmtcli-bank-city          = "":U
    .
    search-for-schet:
    for each buf_fin-schet no-lock
       where buf_fin-schet.host-code = p-host-code
         and buf_fin-schet.cli-type  = p-obj-type
         and buf_fin-schet.cli-code  = p-obj-code
         and buf_fin-schet.curr-code = p-curr-code
    on error undo, return error
    :
        if buf_fin-schet.status_   = 'удал':U
        then do:
        end.
        else do:
            assign
                v-fmtcli-schet-exists   = yes
                v-fmtcli-bank-r-schet   = trim( buf_fin-schet.r-schet )
                v-fmtcli-bank-c-schet   = trim( buf_fin-schet.c-schet )
            .
            find first buf_fin-bank no-lock
                 where buf_fin-bank.host-code = p-host-code
                   and buf_fin-bank.code-bank = buf_fin-schet.code-bank
            no-error.
            if available buf_fin-bank
            then do:
                assign
                    v-fmtcli-bank-exists      = yes
                    v-fmtcli-bank-bik         = trim( buf_fin-bank.bik )
                    v-fmtcli-bank-name        = trim( buf_fin-bank.bank-name )
                    v-fmtcli-bank-addres      = trim(buf_fin-bank.addres)
                    v-fmtcli-bank-city      = trim(buf_fin-bank.bank-city)
                .
            end.
            else do:
                assign
                    v-fmtcli-bank-exists    = no
                    v-fmtcli-bank-bik       = "":U
                    v-fmtcli-bank-name      = "":U
                    v-fmtcli-bank-addres    = "":U
                    v-fmtcli-bank-city      = "":U
                .
            end.
            leave search-for-schet.
        end.
    end.
end.
end procedure.
procedure fmtcli-get-client :
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
    define variable v-temp-fmtcli-address      as character     no-undo.
    define variable v-num-country-city    as integer      no-undo.
    define buffer buf_clients   for ub.clients.
    define buffer buf_firm      for ub.firm.
    define buffer buf_store     for ub.store.
    define buffer buf_shop      for ub.shop.
    define buffer buf_person    for ub.person.
do
for buf_clients
  , buf_firm
  , buf_store
  , buf_shop
  , buf_person
on error undo, return error
:
    assign
        v-fmtcli-name           = "":U
        v-fmtcli-addres         = "":U
        v-fmtcli-post-addres    = "":U
        v-fmtcli-full-addres    = "":U
        v-fmtcli-phone          = "":U
        v-fmtcli-inn            = "":U
        v-fmtcli-kpp            = "":U
        v-fmtcli-okpo           = "":U
        v-fmtcli-city           = "":U
        v-fmtcli-index          = "":U
        v-fmtcli-country        = "":U
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    .
    assign
        v-fmtcli-name = buf_clients.obj-name
    .
    case buf_clients.obj-type:
       when 'орг':U
       then do:
            find first buf_firm no-lock
                 where buf_firm.firm-code = buf_clients.obj-code
                 no-error
            .
            if available buf_firm
            then do:
                assign
                    v-num-country-city = num-entries( buf_firm.city )
                    v-fmtcli-engl-name = buf_firm.engl-name
                .
                if v-num-country-city > 0
                then do:
                    assign
                        v-fmtcli-country    = trim( entry( 1, buf_firm.city ) )
                    .
                end.
                if v-num-country-city > 1
                then do:
                    assign
                        v-fmtcli-city       = trim( entry( 2, buf_firm.city ) )
                    .
                end.
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-country
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-city
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input IF buf_firm.ind = 0 THEN "" ELSE string( buf_firm.ind )
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input v-fmtcli-country
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input v-fmtcli-city
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input string( buf_firm.ind )
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input substring( buf_firm.addres1, 1, 50 )
                    , input buf_firm.addres2
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-temp-fmtcli-address
                    , input substring( buf_firm.addres1, 51, 50 )
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-temp-fmtcli-address
                    , input substring( buf_firm.addres1, 101, 50 )
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                assign
                    v-fmtcli-addres = v-temp-fmtcli-address
                .
                if buf_firm.addres1 <> ?
                then do:
                    run fmtcli-concatenate-strings in this-procedure (
                          input v-fmtcli-full-addres
                        , input v-fmtcli-addres
                        , input ", ":U
                        , input 0
                        , output v-fmtcli-full-addres
                    ).
                end.
                run fmtcli-concatenate-strings in this-procedure (
                      input substring( buf_firm.post-addr1, 1, 50 )
                    , input buf_firm.post-addr2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input substring( buf_firm.post-addr1, 51, 50 )
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input substring( buf_firm.post-addr1, 101, 50 )
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                assign
                    v-fmtcli-phone         = buf_firm.phone
                    v-fmtcli-inn           = buf_firm.inn
                    v-fmtcli-kpp           = buf_firm.kpp
                    v-fmtcli-okpo          = buf_firm.okpo
                    v-fmtcli-index         = string( buf_firm.ind )
                .
            end.
       end.
       when 'маг':U
       then do:
            find first buf_shop no-lock
                 where buf_shop.obj-code = buf_clients.obj-code
            .
            if available buf_shop
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input buf_shop.addres1
                    , input buf_shop.addres2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-addres
                ).
                assign
                    v-fmtcli-full-addres = v-fmtcli-addres
                    v-fmtcli-post-addres = v-fmtcli-addres
                    v-fmtcli-phone       = buf_shop.phone
                    v-fmtcli-inn         = "":U
                    v-fmtcli-kpp         = "":U
                    v-fmtcli-okpo        = "":U
                    v-fmtcli-city        = "":U
                    v-fmtcli-index       = "":U
                .
            end.
       end.
       when 'скл':U
       then do:
            find first buf_store no-lock
                 where buf_store.obj-code = buf_clients.obj-code
            .
            if available buf_store
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input buf_store.addres1
                    , input buf_store.addres2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-addres
                ).
                assign
                    v-fmtcli-full-addres = v-fmtcli-addres
                    v-fmtcli-phone       = buf_store.phone
                    v-fmtcli-inn         = "":U
                    v-fmtcli-kpp         = "":U
                    v-fmtcli-okpo        = "":U
                    v-fmtcli-city        = "":U
                    v-fmtcli-index       = "":U
                .
            end.
       end.
       when 'чел':U
       then do:
            find first buf_person no-lock
                 where buf_person.psn-code = buf_clients.obj-code
            .
            if available buf_person
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input ( if buf_person.ind = 0 or buf_person.ind = ?
                              then "":U
                              else string( buf_person.ind, "999999")
                              )
                    , input buf_person.city
                    , input ", ":U
                    , input 0
                    , output v-fmtcli-full-addres
                ).
                assign
                    v-fmtcli-addres = buf_person.address
                .
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-addres
                    , input ", ":U
                    , input 0
                    , output v-fmtcli-full-addres
                ).
                assign
                    v-fmtcli-phone     = buf_person.phone1
                    v-fmtcli-inn       = buf_person.inn
                    v-fmtcli-kpp       = buf_person.kpp
                    v-fmtcli-okpo      = buf_person.okpo
                    v-fmtcli-city      = buf_person.city
                    v-fmtcli-index     = string( buf_person.ind )
                .
            end.
       end.
    end case.
end.
end procedure.
procedure fmtcli-concatenate-strings :
define input parameter p-string-1       as character        no-undo.
define input parameter p-string-2       as character        no-undo.
define input parameter p-delimiter      as character        no-undo.
define input parameter p-length         as integer          no-undo.
define output parameter p-out-string    as character        no-undo.
do
on error undo, return error
:
    assign
        p-out-string = ( if p-string-1 = ?
                         then "":U
                         else trim( p-string-1 ) )
    .
    assign
        p-out-string = p-out-string
                     + ( if p-out-string = "":U
                         or length( p-out-string ) = p-length
                         or p-string-2 = ?
                         or trim( p-string-2 ) = "":U
                         then "":U
                         else p-delimiter )
                     + ( if p-string-2 = ?
                         or trim( p-string-2 ) = "":U
                         then "":U
                         else trim( p-string-2 ) )
    .
end.
end procedure.
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-torgconf-ext-doc-type as character    no-undo.
define variable v-torgconf-outdate   as logical  init no    no-undo.
define variable v-torgconf-outnum    as logical  init no    no-undo.
define variable v-torgconf-outprim   as logical  init no    no-undo.
define variable v-torgconf-outdisc   as logical  init no    no-undo.
define variable v-torgconf-outsubs   as logical  init no    no-undo.
define variable v-torgconf-outrecv   as logical  init no    no-undo.
define variable v-torgconf-outegrp   as logical  init no    no-undo.
define variable v-torgconf-outt12    as logical  init no    no-undo.
define variable v-torgconf-outappr   as logical  init no    no-undo.
define variable v-torgconf-outrubl   as logical  init no    no-undo.
define variable v-torgconf-outhold   as logical  init no    no-undo.
define variable v-torgconf-outobj    as logical  init no    no-undo.
define variable v-torgconf-outexlst  as logical  init no    no-undo.
define variable v-torgconf-outexpas  as character  init no    no-undo.
define variable v-torgconf-outprncd  as logical  init no    no-undo.
define variable v-torgconf-outares   as logical  init no    no-undo.
define variable v-torgconf-outsend   as logical  init no    no-undo.
define variable v-torgconf-outasend  as logical  init no    no-undo.
define variable v-torgconf-outprops  as logical  init no    no-undo.
define variable v-torgconf-outogr    as character no-undo.
define variable v-torgconf-outR      as character no-undo.
define variable v-torgconf-outB      as character no-undo.
define variable v-torgconf-outC      as character no-undo.
define variable v-torgconf-outssdoc  as character init "":U no-undo.
define variable v-torgconf-self-host-code           as integer      no-undo.
define variable v-torgconf-self-host-type           as character    INITIAL 'орг':U  no-undo.
define variable v-torgconf-self-host-name           as character    no-undo.
define variable v-torgconf-self-host-engl-name           as character    no-undo.
define variable v-torgconf-self-host-addres         as character    no-undo.
define variable v-torgconf-self-host-post-addres    as character    no-undo.
define variable v-torgconf-self-host-phone          as character    no-undo.
define variable v-torgconf-self-host-inn            as character    no-undo.
define variable v-torgconf-self-host-kpp            as character    no-undo.
define variable v-torgconf-self-host-okpo           as character    no-undo.
define variable v-torgconf-self-host-egrip-date     as character    no-undo.
define variable v-torgconf-self-host-egrip-num      as character    no-undo.
define variable v-torgconf-sup-host-code            as integer      no-undo.
define variable v-torgconf-sup-host-type            as character  INITIAL 'орг':U  no-undo.
define variable v-torgconf-sup-host-name            as character    no-undo.
define variable v-torgconf-sup-host-engl-name            as character    no-undo.
define variable v-torgconf-sup-host-addres          as character    no-undo.
define variable v-torgconf-sup-host-post-addres     as character    no-undo.
define variable v-torgconf-sup-host-phone           as character    no-undo.
define variable v-torgconf-sup-host-inn             as character    no-undo.
define variable v-torgconf-sup-host-kpp             as character    no-undo.
define variable v-torgconf-sup-host-okpo            as character    no-undo.
define variable v-torgconf-sup-host-egrip-date      as character    no-undo.
define variable v-torgconf-sup-host-egrip-num       as character    no-undo.
define variable v-torgconf-temp-post-addres         as character    no-undo.
define variable v-torgconf-self-obj-type            as character    no-undo.
define variable v-torgconf-self-obj-code            as integer      no-undo.
define variable v-torgconf-self-obj-name            as character    no-undo.
define variable v-torgconf-self-obj-engl-name            as character    no-undo.
define variable v-torgconf-self-obj-addres          as character    no-undo.
define variable v-torgconf-self-obj-phone           as character    no-undo.
define variable v-torgconf-self-obj-inn             as character    no-undo.
define variable v-torgconf-self-obj-okpo            as character    no-undo.
define variable v-torgconf-sup-obj-type             as character    no-undo.
define variable v-torgconf-sup-obj-code             as integer      no-undo.
define variable v-torgconf-sup-obj-name             as character    no-undo.
define variable v-torgconf-sup-obj-engl-name             as character    no-undo.
define variable v-torgconf-sup-obj-addres           as character    no-undo.
define variable v-torgconf-sup-obj-phone            as character    no-undo.
define variable v-torgconf-sup-obj-inn              as character    no-undo.
define variable v-torgconf-sup-obj-okpo             as character    no-undo.
define variable v-torgconf-self-schet-exists        as logical      no-undo.
define variable v-torgconf-self-bank-exists         as logical      no-undo.
define variable v-torgconf-self-bank-r-schet        as character    no-undo.
define variable v-torgconf-self-bank-c-schet        as character    no-undo.
define variable v-torgconf-self-bank-bik            as character    no-undo.
define variable v-torgconf-self-bank-name           as character    no-undo.
define variable v-torgconf-self-bank-addres         as character    no-undo.
define variable v-torgconf-self-bank-city           as character    no-undo.
define variable v-torgconf-sup-schet-exists         as logical      no-undo.
define variable v-torgconf-sup-bank-exists          as logical      no-undo.
define variable v-torgconf-sup-bank-r-schet         as character    no-undo.
define variable v-torgconf-sup-bank-c-schet         as character    no-undo.
define variable v-torgconf-sup-bank-bik             as character    no-undo.
define variable v-torgconf-sup-bank-name            as character    no-undo.
define variable v-torgconf-sup-bank-addres          as character    no-undo.
define variable v-torgconf-sup-bank-city            as character    no-undo.
define variable v-torgconf-cli-type             as character    no-undo.
define variable v-torgconf-cli-code             as integer      no-undo.
define variable v-torgconf-cli-name             as character    no-undo.
define variable v-torgconf-cli-engl-name        as character    no-undo.
define variable v-torgconf-cli-addres           as character    no-undo.
define variable v-torgconf-cli-post-addres      as character    no-undo.
define variable v-torgconf-cli-phone            as character    no-undo.
define variable v-torgconf-cli-inn              as character    no-undo.
define variable v-torgconf-cli-kpp              as character    no-undo.
define variable v-torgconf-cli-okpo             as character    no-undo.
define variable v-torgconf-ship-type             as character    no-undo.
define variable v-torgconf-ship-code             as integer      no-undo.
define variable v-torgconf-ship-name             as character    no-undo.
define variable v-torgconf-ship-engl-name        as character    no-undo.
define variable v-torgconf-ship-addres           as character    no-undo.
define variable v-torgconf-ship-post-addres      as character    no-undo.
define variable v-torgconf-ship-phone            as character    no-undo.
define variable v-torgconf-ship-inn              as character    no-undo.
define variable v-torgconf-ship-kpp              as character    no-undo.
define variable v-torgconf-ship-okpo             as character    no-undo.
define variable v-torgconf-cli-schet-exists     as logical      no-undo.
define variable v-torgconf-cli-bank-exists      as logical      no-undo.
define variable v-torgconf-cli-bank-r-schet     as character    no-undo.
define variable v-torgconf-cli-bank-c-schet     as character    no-undo.
define variable v-torgconf-cli-bank-bik         as character    no-undo.
define variable v-torgconf-cli-bank-name        as character    no-undo.
define variable v-torgconf-cli-bank-addres      as character    no-undo.
define variable v-torgconf-cli-bank-city        as character    no-undo.
define variable v-torgconf-ship-schet-exists     as logical      no-undo.
define variable v-torgconf-ship-bank-exists      as logical      no-undo.
define variable v-torgconf-ship-bank-r-schet     as character    no-undo.
define variable v-torgconf-ship-bank-c-schet     as character    no-undo.
define variable v-torgconf-ship-bank-bik         as character    no-undo.
define variable v-torgconf-ship-bank-name        as character    no-undo.
define variable v-torgconf-ship-bank-addres      as character    no-undo.
define variable v-torgconf-ship-bank-city        as character    no-undo.
define variable v-torgconf-doc-code             as character    no-undo.
define variable v-torgconf-doc-date             as character    no-undo.
define variable v-torgconf-client-from          as character    no-undo.
define variable v-torgconf-organization         as character    no-undo.
define variable v-torgconf-organization-code    as character    no-undo.
define variable v-torgconf-organization-type    as character    no-undo.
define variable v-torgconf-okpo                 as character    no-undo.
define variable v-torgconf-cargo-to-name        as character    no-undo.
define variable v-torgconf-cargo-to-okpo        as character    no-undo.
define variable v-torgconf-cargo-to-addres      as character    no-undo.
define variable v-torgconf-cargo-to-value       as character    no-undo.
define variable v-torgconf-torg12-cargo-label   as character    no-undo.
define variable v-torgconf-torg12-cargo-string  as character    no-undo.
define variable v-torgconf-torg12-cargo-value   as character    no-undo.
define variable v-torgconf-torg12-cargo-okpo    as character    no-undo.
define variable v-torgconf-torg12-cargo-code    as character    no-undo.
define variable v-torgconf-torg12-cargo-type    as character    no-undo.
define variable v-torgconf-cargo-from-name      as character    no-undo.
define variable v-torgconf-cargo-from-okpo      as character    no-undo.
define variable v-torgconf-cargo-from-addres    as character    no-undo.
define variable v-torgconf-cargo-from-label     as character    no-undo.
define variable v-torgconf-cargo-from-value     as character    no-undo.
define variable v-torgconf-cargo-from-sf-value  as character    no-undo.
define variable v-torgconf-cargo-from-string    as character    no-undo.
define variable v-torgconf-supplier             as character    no-undo.
define variable v-torgconf-suppi                as character    no-undo.
define variable v-torgconf-saler                as character    no-undo.
define variable v-torgconf-sal                  as character    no-undo.
define variable v-torgconf-consignee            as character    no-undo.
define variable v-torgconf-cons                 as character    no-undo.
define variable v-torgconf-supplier-okpo        as character    no-undo.
define variable v-torgconf-saler-okpo           as character    no-undo.
define variable v-torgconf-consignee-okpo       as character    no-undo.
define variable v-torgconf-supplier-code        as character    no-undo.
define variable v-torgconf-saler-code           as character    no-undo.
define variable v-torgconf-consignee-code       as character    no-undo.
define variable v-torgconf-supplier-type        as character    no-undo.
define variable v-torgconf-saler-type           as character    no-undo.
define variable v-torgconf-consignee-type       as character    no-undo.
define variable v-torgconf-supplier-name        as character    no-undo.
define variable v-torgconf-supplier-engl-name   as character    no-undo.
define variable v-torgconf-saler-name           as character    no-undo.
define variable v-torgconf-consignee-name       as character    no-undo.
define variable v-torgconf-supplier-addr        as character    no-undo.
define variable v-torgconf-saler-addr           as character    no-undo.
define variable v-torgconf-consignee-addr       as character    no-undo.
define variable v-torgconf-supplier-inn         as character    no-undo.
define variable v-torgconf-saler-inn            as character    no-undo.
define variable v-torgconf-consignee-inn        as character    no-undo.
define variable v-torgconf-supplier-kpp         as character    no-undo.
define variable v-torgconf-saler-kpp            as character    no-undo.
define variable v-torgconf-consignee-kpp        as character    no-undo.
define variable v-torgconf-plat-rasch-doc       as character    no-undo.
define variable v-torgconf-main-boss            as character    no-undo.
define variable v-torgconf-main-buh             as character    no-undo.
define variable v-torgconf-reason               as character    no-undo.
define variable v-torgconf-sf-buyer-name        as character    no-undo.
define variable v-torgconf-sf-buyer-code        as character    no-undo.
define variable v-torgconf-sf-buyer-type        as character    no-undo.
define variable v-torgconf-sf-buyer-addr        as character    no-undo.
define variable v-torgconf-wth-cargo-to         as character    no-undo.
define variable p-torgconf-date-warrant         as date      no-undo.
define variable p-torgconf-N-warrant            as character no-undo.
define variable p-torgconf-accept-fname         as character no-undo.
define variable p-torgconf-accept-position      as character no-undo.
define variable p-torgconf-t_pass-fname         as character no-undo.
define variable p-torgconf-t_pass-position      as character no-undo.
define variable p-torgconf-nfindoc              as character no-undo.
define variable p-torgconf-ndovwho              as character no-undo.
define variable p-torgconf-ddog                 as date      no-undo.
define variable p-torgconf-ndog                 as character no-undo.
define variable v-torgconf-vdoc-code            as character no-undo.
define variable v-doc-code-attr                 as character no-undo.
define variable v-torgconf-doc-date-attr        as character no-undo.
define variable v-torgconf-vdoc-date            as character no-undo.
define variable v-torgconf-main-boss-post       as character no-undo.
define variable v-torgconf-ogr-name             as character no-undo.
define variable v-torgconf-ogr-post             as character no-undo.
define variable v-name                          as character    no-undo.
define variable v-form-name    as character    no-undo.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure wthcattr-sprcli :
define input parameter parparentproc  as widget-handle no-undo.
define input parameter p-mode  as character no-undo.
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  DEFINE VARIABLE v-value as character no-undo .
  define variable v-cli-type as character no-undo .
  define variable v-cli-code as integer no-undo .
  define buffer buf_clients   for ub.clients.
  define variable v_rid as character no-undo.
  define variable ref-rec as recid no-undo .
  do
  on error undo, return error
  :
      v-value = p-value.
   if p-value <> '':U then do:
    assign
    v-cli-type = substring(p-value, 1, 3)
    v-cli-code = integer(substring(p-value, 4))
    no-error.
    if error-status:error then do:
      assign
      v-cli-type = '':U
      v-cli-code = 0
      .
    end.
   end.
   FIND FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = v-cli-type AND
            buf_clients.obj-code = v-cli-code  NO-ERROR.
   IF available(buf_clients) then do:
    run ref/cli-all.w (
                input parparentproc
               ,input if p-mode = 'ИЗМЕНЕНИЕ':U then "b-sel":U else "":U
               ,input v-cli-type
               ,input 'все':U
               ,input 'все':U
               ,input RECID( buf_clients )
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  ELSE if p-mode = 'ИЗМЕНЕНИЕ':U then DO:
    run ref/cli-all.w (
                 input parparentproc
                ,INPUT "b-sel":U
               ,input  v-cli-type
               ,input 'все':U
               ,input 'текущие':U
               ,input ?
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  else do:
    message
    if p-value = "":U then 'Атрибут не задан!'
    else substitute('Не найден клиент &1',p-value)
    view-as alert-box warning.
  end.
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST buf_clients NO-LOCK WHERE
               RECID( buf_clients ) = ref-rec NO-ERROR.
    IF AVAIL buf_clients THEN DO:
      v-value = buf_clients.obj-type + string(buf_clients.obj-code, ">>>>>>>>9").
    end.
  end.
  if v-value <> p-value then do:
    p-value = v-value.
    p-setted = yes.
  end.
  end.
end procedure.
  define new global shared variable g#wthcalib as handle no-undo.
procedure torgconf-read :
do
on error undo, return error
:
    define input parameter p-form-name  as character    no-undo.
    define input parameter p-host-code  as integer      no-undo.
    define input parameter p-obj-type   as character    no-undo.
    define input parameter p-obj-code   as integer      no-undo.
    define variable v-outdate   as character     no-undo.
    define variable v-outares   as character     no-undo.
    define variable v-outsend   as character     no-undo.
    define variable v-outasend  as character     no-undo.
    define variable v-outprops  as character     no-undo.
    define variable v-outnum    as character     no-undo.
    define variable v-outprim   as character     no-undo.
    define variable v-outdisc   as character     no-undo.
    define variable v-outsubs   as character     no-undo.
    define variable v-outrecv   as character     no-undo.
    define variable v-outegrp   as character     no-undo.
    define variable v-outt12    as character     no-undo.
    define variable v-outappr   as character     no-undo.
    define variable v-outrubl   as character     no-undo.
    define variable v-outhold   as character     no-undo.
    define variable v-outobj    as character     no-undo.
    define variable v-outexlst  as character     no-undo.
    define variable v-outprncd  as character     no-undo.
    define variable v-par-type  as character     no-undo.
    define variable v-outogr    as character     no-undo.
    define variable v-outR      as character     no-undo.
    define variable v-outB      as character     no-undo.
    define variable v-outC      as character     no-undo.
    assign
        v-torgconf-outdate  = no
        v-torgconf-outnum   = no
        v-torgconf-outprim  = no
        v-torgconf-outdisc  = no
        v-torgconf-outsubs  = no
        v-torgconf-outrecv  = no
        v-torgconf-outegrp  = no
        v-torgconf-outt12   = no
        v-torgconf-outappr  = no
        v-torgconf-outrubl  = no
        v-torgconf-outhold  = no
        v-torgconf-outobj   = no
        v-torgconf-outexlst = no
        v-torgconf-outexpas = "":U
        v-torgconf-outprncd = yes
        v-torgconf-outares  = no
        v-torgconf-outsend  = no
        v-torgconf-outasend  = no
        v-torgconf-outprops  = no
        v-form-name          = p-form-name
    .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'prt-glob':U
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
    if thbjattr_thbj-attr.prop-code = 'outprncd':U then v-outprncd =  string(thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'outrecv':U  then v-outrecv  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outprops':U then v-outprops =  thbjattr_thbj-attr.property-value-character .
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input p-obj-type
  ,input p-obj-code
  ,input 'prt-obj':U
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
    if thbjattr_thbj-attr.prop-code = 'outdate':U  then v-outdate  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outares':U  then v-outares  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outnum':U   then v-outnum   =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outprim':U  then v-outprim  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outdisc':U  then v-outdisc  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outsubs':U  then v-outsubs  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outegrp':U  then v-outegrp  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outt12':U   then v-outt12   =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outappr':U  then v-outappr  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outrubl':U  then v-outrubl  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outhold':U  then v-outhold  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outobj':U   then v-outobj   =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outsend':U  then v-outsend  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outasend':U then v-outasend =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outogr':U   then v-torgconf-outogr   =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outR':U     then v-torgconf-outR     =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outB':U     then v-torgconf-outB     =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outssdoc':U then v-torgconf-outssdoc =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outC':U     then v-torgconf-outC     =  thbjattr_thbj-attr.property-value-character .
end.
    run gbl/conf-rd.p ("outexpas", "":U, "":U, 0, "":U, "":U, "":U, no, output v-torgconf-outexpas, output v-par-type) no-error.
    if error-status :error
    then do:
        assign
            v-torgconf-outexpas = "":U
        .
    end.
    assign
        v-torgconf-outprncd = ( v-outprncd = "yes":U )
    .
    if p-form-name <> ""
    and p-form-name <> ?
    then do:
        run gbl/conf-rd.p ("outexlst" , p-host-code, p-obj-type, p-obj-code, "", "", "", no, output v-outexlst , output v-par-type) no-error.
        if error-status :error
        then do:
            assign
                v-outexlst           = ""
            .
        end.
        if lookup( p-form-name, v-outdate ) <> 0
        then do:
            assign
                v-torgconf-outdate  = yes
            .
        end.
        if lookup( p-form-name, v-outares ) <> 0
        then do:
            assign
                v-torgconf-outares  = yes
            .
        end.
        if lookup( p-form-name, v-outnum  ) <> 0
        then do:
            assign
                v-torgconf-outnum   = yes
            .
        end.
        if lookup( p-form-name, v-outprim ) <> 0
        then do:
            assign
                v-torgconf-outprim  = yes
            .
        end.
        if lookup( p-form-name, v-outdisc ) <> 0
        then do:
            assign
                v-torgconf-outdisc  = yes
            .
        end.
        if lookup( p-form-name, v-outsubs ) <> 0
        then do:
            assign
                v-torgconf-outsubs  = yes
            .
        end.
        if lookup( p-form-name, v-outrecv ) <> 0
        then do:
            assign
                v-torgconf-outrecv  = yes
            .
        end.
        if lookup( p-form-name, v-outegrp ) <> 0
        then do:
            assign
                v-torgconf-outegrp  = yes
            .
        end.
        if lookup( p-form-name, v-outt12  ) <> 0
        then do:
            assign
                v-torgconf-outt12   = yes
            .
        end.
        if lookup( p-form-name, v-outappr  ) <> 0
        then do:
            assign
                v-torgconf-outappr   = yes
            .
        end.
        if lookup( p-form-name, v-outrubl  ) <> 0
        then do:
            assign
                v-torgconf-outrubl   = yes
            .
        end.
        if lookup( p-form-name, v-outhold  ) <> 0
        then do:
            assign
                v-torgconf-outhold   = yes
            .
        end.
        if lookup( p-form-name, v-outobj   ) <> 0
        then do:
            assign
                v-torgconf-outobj    = yes
            .
        end.
        if lookup( p-form-name, v-outsend   ) <> 0
        then do:
            assign
                v-torgconf-outsend    = yes
            .
        end.
        if lookup( p-form-name, v-outasend   ) <> 0
        then do:
            assign
                v-torgconf-outasend    = yes
            .
        end.
        if lookup( p-form-name, v-outprops   ) <> 0
        then do:
            assign
                v-torgconf-outprops    = yes
            .
        end.
        if lookup( p-form-name, v-outexlst ) <> 0
        then do:
            assign
                v-torgconf-outexlst  = yes
            .
        end.
     assign
      v-name = p-form-name.
end.
end.
end procedure.
procedure torgconf-get-self-param :
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-curr-code          as integer          no-undo.
    define variable v-host-code    as integer      no-undo.
    define variable v-par-type     as character    no-undo.
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message(1))
:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    if v-torgconf-outhold = yes
    then do:
        run torgconf-get-holdfirm-code in this-procedure (
              input p-obj-type
            , input p-obj-code
            , output v-torgconf-self-host-code
        ).
        if v-torgconf-self-host-code = 0
        then do:
            return error.
        end.
    end.
    else do:
        assign
            v-torgconf-self-host-code = v-host-code
        .
    end.
    if v-torgconf-self-host-code = 0
    then do:
        assign
            v-torgconf-self-host-name           = "":U
            v-torgconf-self-host-addres         = "":U
            v-torgconf-self-host-post-addres    = "":U
            v-torgconf-self-host-phone          = "":U
            v-torgconf-self-host-inn            = "":U
            v-torgconf-self-host-kpp            = "":U
            v-torgconf-self-host-okpo           = "":U
            v-torgconf-self-host-egrip-date     = "":U
            v-torgconf-self-host-egrip-num      = "":U
        .
    end.
    else do:
        run fmtcli-get-client in this-procedure (
              input 'орг':U
            , input v-torgconf-self-host-code
        ).
        assign
            v-torgconf-self-host-name        = v-fmtcli-name
            v-torgconf-self-host-engl-name   = v-fmtcli-engl-name
            v-torgconf-self-host-addres      = v-fmtcli-full-addres
            v-torgconf-self-host-post-addres = v-fmtcli-post-addres
            v-torgconf-self-host-phone       = v-fmtcli-phone
            v-torgconf-self-host-inn         = v-fmtcli-inn
            v-torgconf-self-host-kpp         = v-fmtcli-kpp
            v-torgconf-self-host-okpo        = v-fmtcli-okpo
        .
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-self-host-code
            , input 'egrip-date':U
            , output v-torgconf-self-host-egrip-date
            , output v-par-type
        ).
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-self-host-code
            , input 'egrip-num':U
            , output v-torgconf-self-host-egrip-num
            , output v-par-type
        ).
        run fmtcli-get-bank in this-procedure (
              input v-host-code
            , input 'орг':U
            , input v-torgconf-self-host-code
            , input p-curr-code
        ).
    end.
    assign
        v-torgconf-self-schet-exists = v-fmtcli-schet-exists
        v-torgconf-self-bank-exists  = v-fmtcli-bank-exists
        v-torgconf-self-bank-r-schet = v-fmtcli-bank-r-schet
        v-torgconf-self-bank-c-schet = v-fmtcli-bank-c-schet
        v-torgconf-self-bank-bik     = v-fmtcli-bank-bik
        v-torgconf-self-bank-name    = v-fmtcli-bank-name
        v-torgconf-self-bank-addres  = v-fmtcli-bank-addres
        v-torgconf-self-bank-city    = v-fmtcli-bank-city
    .
    assign
        v-torgconf-self-obj-type = p-obj-type
        v-torgconf-self-obj-code = p-obj-code
    .
    run fmtcli-get-client in this-procedure (
          input p-obj-type
        , input p-obj-code
    ).
    assign
        v-torgconf-self-obj-name       = v-fmtcli-name
        v-torgconf-self-obj-engl-name  = v-fmtcli-engl-name
        v-torgconf-self-obj-addres     = v-fmtcli-full-addres
        v-torgconf-temp-post-addres    = v-fmtcli-post-addres
        v-torgconf-self-obj-phone      = v-fmtcli-phone
        v-torgconf-self-obj-inn        = v-fmtcli-inn
        v-torgconf-self-obj-okpo       = v-fmtcli-okpo
    .
end.
end procedure.
procedure torgconf-get-recepient-param :
define input parameter torgconfdoc-code   as character                  no-undo.
define output parameter v-code-rec        as integer                    no-undo .
define output parameter v-type-rec        as character                  no-undo initial 'C':U.
define output parameter v-codefirm-rec    as integer                    no-undo .
define output parameter v-curcode-rec     as integer                    no-undo .
     define variable  v-recipient-code  as character                  no-undo .
     define variable  v-recipient       like ub.doc-attr.attr-value   no-undo.
     define variable  v-trdcattr-type   as character                  no-undo initial 'C':U.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input torgconfdoc-code ,
                        input 'Recipient':U ,
                       output v-recipient-code ,
                       output v-trdcattr-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " torgconfdoc-code skip
      "Атрибут: " 'Recipient':U skip
      "Значение: " v-recipient skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
  assign
    v-recipient  = v-recipient-code
    v-type-rec = substring(v-recipient-code,1,3)
    v-code-rec  = int(substring(v-recipient-code,4,15))
    no-error
  .
  if v-type-rec = ? then v-type-rec = "" .
  if v-code-rec  = ? then v-code-rec  =  0 .
  end procedure.
procedure torgconf-get-wthrecepient-param :
define input parameter torgconfdoc-code   as character                  no-undo.
define output parameter v-code-rec        as integer                    no-undo .
define output parameter v-type-rec        as character                  no-undo initial 'C':U.
define output parameter v-codefirm-rec    as integer                    no-undo .
define output parameter v-curcode-rec     as integer                    no-undo .
     define variable  v-recipient-code  as character                  no-undo .
     define variable  v-recipient       like ub.doc-attr.attr-value   no-undo.
     define variable  v-trdcattr-type   as character                  no-undo initial 'C':U.
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input torgconfdoc-code ,
                        input 'wthconsignee':U ,
                       output v-recipient-code ,
                       output v-trdcattr-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " torgconfdoc-code skip
      "Атрибут: " 'wthconsignee':U skip
      "Значение: " v-recipient skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
  assign
    v-recipient  = v-recipient-code
    v-type-rec = substring(v-recipient-code,1,3)
    v-code-rec  = int(substring(v-recipient-code,4,15))
    no-error
  .
  if v-type-rec = ? then v-type-rec = "" .
  if v-code-rec  = ? then v-code-rec  =  0 .
  end procedure.
procedure torgconf-get-warrant:
define input parameter p-torgconfdoc-code           as character                  no-undo.
    define variable p-torgconf-date-type            as character no-undo.
    define variable p-torgconf-N-type               as character no-undo.
    define variable p-torgconf-accept-n-type        as character no-undo.
    define variable p-torgconf-accept-p-type        as character no-undo.
    define variable p-torgconf-nfindoc-type         as character no-undo.
    define variable p-torgconf-ndovwho-type         as character no-undo.
    define variable p-torgconf-ndog-type            as character no-undo.
    define variable p-torgconf-dfindoc-type         as date      no-undo.
    define variable p-torgconf-ddog-type            as date      no-undo.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 'ddov':U ,
                       output p-torgconf-date-warrant ,
                       output p-torgconf-date-type ) no-error .
     if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 'ddov':U skip
      "Значение: " p-torgconf-date-warrant skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 'ndov':U ,
                       output p-torgconf-N-warrant ,
                       output p-torgconf-N-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 'ndov':U skip
      "Значение: " p-torgconf-N-warrant skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 't_accept-fname':U ,
                       output p-torgconf-accept-fname ,
                       output p-torgconf-accept-n-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 't_accept-fname':U skip
      "Значение: " p-torgconf-accept-fname skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 't_accept-position':U ,
                       output p-torgconf-accept-position ,
                       output p-torgconf-accept-p-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 't_accept-position':U skip
      "Значение: " p-torgconf-accept-position skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 't_pass-fname':U ,
                       output p-torgconf-t_pass-fname ,
                       output p-torgconf-accept-n-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 't_pass-fname':U skip
      "Значение: " p-torgconf-t_pass-fname skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 't_pass-position':U ,
                       output p-torgconf-t_pass-position ,
                       output p-torgconf-accept-p-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 't_pass-position':U skip
      "Значение: " p-torgconf-t_pass-position skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 'ndovwho':U ,
                       output p-torgconf-ndovwho ,
                       output p-torgconf-ndovwho-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 'ndovwho':U skip
      "Значение: " p-torgconf-ndovwho skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
  end procedure.
procedure torgconf-get-warrant-wth:
define input parameter p-torgconfdoc-code           as character                  no-undo.
    define variable p-torgconf-ndovwho-type         as character no-undo.
    define variable p-torgconf-accept-n-type        as character no-undo.
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input p-torgconfdoc-code ,
                        input 'wthproxy':U ,
                       output p-torgconf-ndovwho ,
                       output p-torgconf-ndovwho-type ) no-error .
      if error-status :error then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при вызове процедуры tdat-val":U skip
         "Документ: " p-torgconfdoc-code skip
         "Атрибут: " 'wthproxy':U skip
         "Значение: " p-torgconf-ndovwho skip
         trim( error-status :get-message (1) ) skip
         return-value skip
         view-as alert-box error.
      undo, return error return-value.
      end.
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input p-torgconfdoc-code ,
                        input 'wthreceiver':U ,
                       output p-torgconf-accept-fname ,
                       output p-torgconf-accept-n-type ) no-error .
      if error-status :error then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при вызове процедуры tdat-val":U skip
         "Документ: " p-torgconfdoc-code skip
         "Атрибут: " 't_accept-fname':U skip
         "Значение: " p-torgconf-accept-fname skip
         trim( error-status :get-message (1) ) skip
         return-value skip
         view-as alert-box error.
      undo, return error return-value.
      end.
  end procedure.
procedure torgconf-get-sup-param :
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-curr-code          as integer          no-undo.
    define variable v-host-code    as integer      no-undo.
    define variable v-par-type     as character    no-undo.
do
on error undo, return error
:
    assign
       v-torgconf-sup-host-code = v-host-code
    .
    if v-torgconf-sup-host-code = 0
    then do:
        assign
            v-torgconf-sup-host-name           = "":U
            v-torgconf-sup-host-addres         = "":U
            v-torgconf-sup-host-post-addres    = "":U
            v-torgconf-sup-host-phone          = "":U
            v-torgconf-sup-host-inn            = "":U
            v-torgconf-sup-host-kpp            = "":U
            v-torgconf-sup-host-okpo           = "":U
            v-torgconf-sup-host-egrip-date     = "":U
            v-torgconf-sup-host-egrip-num      = "":U
        .
    end.
    else do:
        run fmtcli-get-client in this-procedure (
              input 'орг':U
            , input v-torgconf-sup-host-code
        ).
        assign
            v-torgconf-sup-host-name        = v-fmtcli-name
            v-torgconf-sup-host-engl-name   = v-fmtcli-engl-name
            v-torgconf-sup-host-addres      = v-fmtcli-full-addres
            v-torgconf-sup-host-post-addres = v-fmtcli-post-addres
            v-torgconf-sup-host-phone       = v-fmtcli-phone
            v-torgconf-sup-host-inn         = v-fmtcli-inn
            v-torgconf-sup-host-kpp         = v-fmtcli-kpp
            v-torgconf-sup-host-okpo        = v-fmtcli-okpo
        .
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-sup-host-code
            , input 'egrip-date':U
            , output v-torgconf-sup-host-egrip-date
            , output v-par-type
        ).
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-sup-host-code
            , input 'egrip-num':U
            , output v-torgconf-sup-host-egrip-num
            , output v-par-type
        ).
        run fmtcli-get-bank in this-procedure (
              input v-host-code
            , input 'орг':U
            , input v-torgconf-sup-host-code
            , input p-curr-code
        ).
    end.
    assign
        v-torgconf-sup-schet-exists = v-fmtcli-schet-exists
        v-torgconf-sup-bank-exists  = v-fmtcli-bank-exists
        v-torgconf-sup-bank-r-schet = v-fmtcli-bank-r-schet
        v-torgconf-sup-bank-c-schet = v-fmtcli-bank-c-schet
        v-torgconf-sup-bank-bik     = v-fmtcli-bank-bik
        v-torgconf-sup-bank-name    = v-fmtcli-bank-name
        v-torgconf-sup-bank-addres  = v-fmtcli-bank-addres
        v-torgconf-sup-bank-city    = v-fmtcli-bank-city
    .
    assign
        v-torgconf-sup-obj-type = p-obj-type
        v-torgconf-sup-obj-code = p-obj-code
    .
    if trim(p-obj-type) <> ""
    and p-obj-code <> 0
    then do:
    run fmtcli-get-client in this-procedure (
          input p-obj-type
        , input p-obj-code
    ).
    assign
        v-torgconf-sup-obj-name        = v-fmtcli-name
        v-torgconf-sup-obj-engl-name   = v-fmtcli-engl-name
        v-torgconf-sup-obj-addres      = v-fmtcli-full-addres
        v-torgconf-temp-post-addres    = v-fmtcli-post-addres
        v-torgconf-sup-obj-phone       = v-fmtcli-phone
        v-torgconf-sup-obj-inn         = v-fmtcli-inn
        v-torgconf-sup-obj-okpo        = v-fmtcli-okpo
    .
   end.
   end.
end procedure.
procedure torgconf-get-cli-param :
define input parameter p-host-obj-code      as integer          no-undo.
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-curr-code          as integer          no-undo.
    define variable v-host-code    as integer      no-undo.
do
on error undo, return error
:
    assign
        v-torgconf-cli-type = p-obj-type
        v-torgconf-cli-code = p-obj-code
    .
    run fmtcli-get-client in this-procedure (
          input p-obj-type
        , input p-obj-code
    ).
    assign
        v-torgconf-cli-name         = trim( v-fmtcli-name          )
        v-torgconf-cli-engl-name    = trim( v-fmtcli-engl-name          )
        v-torgconf-cli-addres       = trim( v-fmtcli-full-addres   )
        v-torgconf-cli-post-addres  = trim( v-fmtcli-post-addres   )
        v-torgconf-cli-phone        = trim( v-fmtcli-phone         )
        v-torgconf-cli-inn          = trim( v-fmtcli-inn           )
        v-torgconf-cli-kpp          = trim( v-fmtcli-kpp           )
        v-torgconf-cli-okpo         = trim( v-fmtcli-okpo          )
    .
   run fmtcli-get-bank in this-procedure (
          input p-host-obj-code
        , input p-obj-type
        , input p-obj-code
        , input p-curr-code
    ).
    assign
        v-torgconf-cli-schet-exists = v-fmtcli-schet-exists
        v-torgconf-cli-bank-exists  = v-fmtcli-bank-exists
        v-torgconf-cli-bank-r-schet = v-fmtcli-bank-r-schet
        v-torgconf-cli-bank-c-schet = v-fmtcli-bank-c-schet
        v-torgconf-cli-bank-bik     = v-fmtcli-bank-bik
        v-torgconf-cli-bank-name    = v-fmtcli-bank-name
        v-torgconf-cli-bank-addres  = v-fmtcli-bank-addres
        v-torgconf-cli-bank-city    = v-fmtcli-bank-city
    .
end.
end procedure.
procedure torgconf-get-ship-param :
define input parameter p-host-obj-code      as integer          no-undo.
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-curr-code          as integer          no-undo.
    define variable v-host-code    as integer      no-undo.
do
on error undo, return error
:
    assign
        v-torgconf-ship-type = p-obj-type
        v-torgconf-ship-code = p-obj-code
    .
    if trim(p-obj-type) = ""
    and p-obj-code = 0
    then do:
    assign
        v-torgconf-ship-name         = "":U
        v-torgconf-ship-addres       = "":U
        v-torgconf-ship-post-addres  = "":U
        v-torgconf-ship-phone        = "":U
        v-torgconf-ship-inn          = "":U
        v-torgconf-ship-kpp          = "":U
        v-torgconf-ship-okpo         = "":U
    .
    end.
    else do:
    run fmtcli-get-client in this-procedure (
          input p-obj-type
        , input p-obj-code
    ).
    assign
        v-torgconf-ship-name         = trim( v-fmtcli-name          )
        v-torgconf-ship-engl-name    = trim( v-fmtcli-engl-name          )
        v-torgconf-ship-addres       = trim( v-fmtcli-full-addres   )
        v-torgconf-ship-post-addres  = trim( v-fmtcli-post-addres   )
        v-torgconf-ship-phone        = trim( v-fmtcli-phone         )
        v-torgconf-ship-inn          = trim( v-fmtcli-inn           )
        v-torgconf-ship-kpp          = trim( v-fmtcli-kpp           )
        v-torgconf-ship-okpo         = trim( v-fmtcli-okpo          )
    .
    end.
        run fmtcli-get-bank in this-procedure (
          input p-host-obj-code
        , input p-obj-type
        , input p-obj-code
        , input p-curr-code
    ).
    assign
        v-torgconf-ship-schet-exists = v-fmtcli-schet-exists
        v-torgconf-ship-bank-exists  = v-fmtcli-bank-exists
        v-torgconf-ship-bank-r-schet = v-fmtcli-bank-r-schet
        v-torgconf-ship-bank-c-schet = v-fmtcli-bank-c-schet
        v-torgconf-ship-bank-bik     = v-fmtcli-bank-bik
        v-torgconf-ship-bank-name    = v-fmtcli-bank-name
        v-torgconf-ship-bank-addres  = v-fmtcli-bank-addres
        v-torgconf-ship-bank-city    = v-fmtcli-bank-city
    .
end.
end procedure.
procedure torgconf-get-holdfirm-code :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define output parameter p-firm-code as integer          no-undo.
    define variable v-firm-code-str     as character    no-undo.
    define variable v-par-type          as character    no-undo.
    define buffer buf_clients       for ub.clients.
do
for buf_clients
on error undo, return error
:
    run gbl/clntat-v.p (
          input p-obj-type
        , input p-obj-code
        , input 'holdfirm-code':U
        , output v-firm-code-str
        , output v-par-type
    ).
    assign
        p-firm-code = integer( v-firm-code-str )
    no-error.
    if error-status :error
    then do:
        message
            "Неверно задан код фирмы для печати накладных."
        view-as alert-box warning.
        assign
            p-firm-code = 0
        .
    end.
    else do:
        find first buf_clients no-lock
             where buf_clients.obj-type = 'орг':U
               and buf_clients.obj-code = p-firm-code
        no-error.
        if not available buf_clients
        then do:
            message
                "Включен параметр 'Список печатных форм, для которых должна быть задана фирма для печати накладных' (outhold)" skip
                "Не найдена фирма по заданному коду фирмы для печати накладных."
            view-as alert-box warning.
            assign
                p-firm-code = 0
            .
        end.
    end.
end.
end procedure.
procedure torgconf-get-post-head:
define input  parameter p-obj-type             as character        no-undo.
define input  parameter p-obj-code             as integer          no-undo.
define output parameter p-torgconf-post-head   as character        no-undo.
   define variable v-host-code         as integer      no-undo.
   define buffer buf_sysconf     for ub.sysconf.
     assign
      p-torgconf-post-head  = ""
     .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
   find first buf_sysconf no-lock
   where buf_sysconf.host-code = v-host-code
   no-error.
   if available buf_sysconf
   then do:
      assign
         p-torgconf-post-head = buf_sysconf.head-position
      .
   end.
end procedure.
procedure torgconf-get-storekeeper:
define input  parameter p-wrkr                   as integer          no-undo.
define output parameter p-torgconf-wrkr-name     as character        no-undo.
define output parameter p-torgconf-post          as character        no-undo.
   define buffer buf_sysconf     for ub.sysconf.
   define buffer buf_person      for ub.person.
   define buffer buf_shop        for ub.shop .
   define buffer buf_store       for ub.store .
   if v-torgconf-outC = "no_print"
   then do:
      assign p-torgconf-post = ""
             p-torgconf-wrkr-name = ""
             .
   end.
   if v-torgconf-outC = "clad_doc"
   then do:
      run rep/get-psn.p
            (input  p-wrkr
            ,output p-torgconf-wrkr-name
            ) .
      find first buf_person no-lock
      where buf_person.psn-code = p-wrkr
      no-error.
      if available buf_person
      then do:
        p-torgconf-post = buf_person.position.
      end.
      if p-torgconf-post = "?":U then p-torgconf-post = "".
      if p-torgconf-wrkr-name = "?":U then p-torgconf-wrkr-name = "".
   end.
   if v-torgconf-outC = "clad_obj"
   then do:
      CASE v-torgconf-self-obj-type:
      WHEN 'маг':U
      THEN DO:
         find first buf_shop no-lock
         where buf_shop.obj-code = v-torgconf-self-obj-code
         .
         assign
            p-torgconf-wrkr-name = buf_shop.store-man
            p-torgconf-post = ""
         .
         if p-torgconf-wrkr-name = "?":U then p-torgconf-wrkr-name = "".
      END.
      WHEN 'скл':U
      THEN DO:
         find first buf_store no-lock
         where buf_store.obj-code = v-torgconf-self-obj-code
         .
         assign
            p-torgconf-wrkr-name = buf_store.store-man
            p-torgconf-post = ""
         .
         if p-torgconf-wrkr-name = "?":U then p-torgconf-wrkr-name = "".
      END.
      OTHERWISE DO:
         assign
            p-torgconf-post = "":U
            p-torgconf-wrkr-name = "":U
         .
      END.
      END CASE.
   end.
 end procedure.
procedure torgconf-get-form-header :
define input parameter p-for-inverse    as logical          no-undo.
define input parameter p-doc-code       as character        no-undo.
define input parameter p-print-doc      as logical          no-undo.
define input parameter p-doc-date       as date             no-undo.
define input parameter p-fact-date      as date             no-undo.
define input parameter p-doc-type       as character        no-undo.
define input parameter p-status_        as character        no-undo.
define input parameter p-reverse        as logical          no-undo.
define input parameter p-sf-par         as logical          no-undo.
    define variable v-attr-type         as character    no-undo.
    define variable v-doc-code-standard as logical      no-undo.
    define variable v-doc-date-standard as logical      no-undo.
    define variable v-par-consignee-addres  as character    no-undo.
    define variable v-host-code         as integer      no-undo.
    define variable v-dcode-attr        as character    no-undo.
    define variable v-ddate-attr        as character    no-undo.
    define variable v-doc-date          as character    no-undo.
    define variable v-doc-code          as character    no-undo.
    define variable v-par-type          as character    no-undo.
    define variable v-attr              as character    no-undo.
    define buffer buf_firm          for ub.firm .
    define buffer buf_clients       for ub.clients .
    define buffer buf_sysconf       for ub.sysconf .
    define buffer buf_shop          for ub.shop .
    define buffer buf_store         for ub.store .
    define buffer buf_person        for ub.person .
    define buffer buf_trn-doc       for ub.trn-doc .
    define buffer buf_wth-doc       for ub.wth-doc .
    do
for buf_firm
  , buf_clients
  , buf_sysconf
  , buf_shop
  , buf_trn-doc
  , buf_person
  , buf_wth-doc
on error undo, return error
:
    if p-doc-type = 'при':U
    or p-doc-type = 'возврат':U
    then do:
        assign
            v-torgconf-supplier         = substitute( "&1&2&3&4&5", v-torgconf-cli-name, ( if v-torgconf-cli-addres = "":U then "":U else ", " ),
                                          v-torgconf-cli-addres, ( if v-torgconf-cli-phone = "":U then "":U else ", " ), v-torgconf-cli-phone )
            v-torgconf-suppi            = substitute( "&1&2&3&4&5", v-torgconf-cli-name, ( if v-torgconf-cli-addres = "":U then "":U else ", " ),
                                          v-torgconf-cli-addres, ( if v-torgconf-cli-phone = "":U then "":U else ", " ), v-torgconf-cli-phone )
            v-torgconf-saler            = substitute( "&1&2&3&4&5", v-torgconf-self-host-name, ( if v-torgconf-self-host-addres = "":U then "":U else ", " ),
                                          v-torgconf-self-host-addres, ( if v-torgconf-self-host-phone = "":U then "":U else ", " ),v-torgconf-self-host-phone )
            v-torgconf-consignee        = substitute( "&1&2&3&4&5", v-torgconf-sup-host-name, ( if v-torgconf-sup-host-addres = "":U then "":U else ", " ),
                                          v-torgconf-sup-host-addres, ( if v-torgconf-sup-host-phone = "":U then "":U else ", " ), v-torgconf-sup-host-phone  )
            v-torgconf-supplier-okpo    = v-torgconf-cli-okpo
            v-torgconf-saler-okpo       = v-torgconf-self-host-okpo
            v-torgconf-consignee-okpo   = v-torgconf-sup-host-okpo
            v-torgconf-supplier-code    = substitute( "&1", v-torgconf-cli-code         )
            v-torgconf-supplier-type    = v-torgconf-cli-type
            v-torgconf-saler-code       = substitute( "&1", v-torgconf-self-host-code   )
            v-torgconf-saler-type       = v-torgconf-self-host-type
            v-torgconf-consignee-code   = substitute( "&1", v-torgconf-sup-host-code   )
            v-torgconf-consignee-type   = v-torgconf-sup-host-type
            v-torgconf-supplier-name    = substitute( "&1", v-torgconf-cli-name         )
            v-torgconf-saler-name       = substitute( "&1", v-torgconf-self-host-name   )
            v-torgconf-consignee-name   = substitute( "&1", v-torgconf-sup-host-name   )
            v-torgconf-supplier-addr    = substitute( "&1", v-torgconf-cli-addres       )
            v-torgconf-saler-addr       = substitute( "&1", v-torgconf-self-host-addres )
            v-torgconf-consignee-addr   = substitute( "&1", v-torgconf-sup-host-addres )
            v-torgconf-supplier-inn     = substitute( "&1", v-torgconf-cli-inn          )
            v-torgconf-supplier-engl-name     = substitute( "&1", v-torgconf-cli-engl-name          )
            v-torgconf-saler-inn        = substitute( "&1", v-torgconf-self-host-inn    )
            v-torgconf-consignee-inn    = substitute( "&1", v-torgconf-sup-host-inn    )
            v-torgconf-supplier-kpp     = substitute( "&1", v-torgconf-cli-kpp          )
            v-torgconf-saler-kpp        = substitute( "&1", v-torgconf-self-host-kpp    )
            v-torgconf-consignee-kpp    = substitute( "&1", v-torgconf-sup-host-kpp    )
        .
        if v-torgconf-cli-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-supplier = v-torgconf-supplier
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-cli-bank-r-schet
                                , v-torgconf-cli-bank-c-schet
                                )
                v-torgconf-suppi = v-torgconf-supplier
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-cli-bank-r-schet
                                , v-torgconf-cli-bank-c-schet
                                )
            .
            if v-torgconf-cli-bank-exists = yes
            then do:
                assign
                    v-torgconf-supplier = v-torgconf-supplier
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-cli-bank-bik
                                    , v-torgconf-cli-bank-name
                                    ,(if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                    )
                   v-torgconf-suppi = v-torgconf-supplier
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-cli-bank-bik
                                    , v-torgconf-cli-bank-name
                                    ,(if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                    )
                .
            end.
        end.
        if v-torgconf-self-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-saler = v-torgconf-saler
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-self-bank-r-schet
                                , v-torgconf-self-bank-c-schet
                                )
            .
            if v-torgconf-self-bank-exists = yes
            then do:
                assign
                    v-torgconf-saler = v-torgconf-saler
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-self-bank-bik
                                    , v-torgconf-self-bank-name
                                    , v-torgconf-self-bank-addres
                                    )
                .
            end.
        end.
        if v-torgconf-sup-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-consignee = v-torgconf-consignee
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-sup-bank-r-schet
                                , v-torgconf-sup-bank-c-schet
                                )
            .
          if v-torgconf-sup-bank-exists = yes
           then do:
             assign
                v-torgconf-consignee = v-torgconf-consignee
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-sup-bank-bik
                                    , v-torgconf-sup-bank-name
                                    , v-torgconf-sup-bank-addres
                                    )
                .
            end.
        end.
   if v-torgconf-outares = yes  AND v-form-name  = "torg12":U
   then do:
       assign
         v-torgconf-supplier = substitute(  "&1&2&3 &4 &5&6"
                                                , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-cli-inn, v-torgconf-cli-kpp) ELSE "":U
                                                , v-torgconf-cli-name
                                                , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-cli-code )
                                                      else "":U )
                                                , v-torgconf-cli-post-addres
                                                , v-torgconf-cli-phone
                                                , ( if v-torgconf-cli-bank-r-schet <> "":U
                                                    AND v-form-name                  = "torg12":U
                                                      then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                            , v-torgconf-cli-bank-r-schet
                                                            , v-torgconf-cli-bank-c-schet
                                                            , v-torgconf-cli-bank-bik
                                                            , v-torgconf-cli-bank-name
                                                            , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )     )
                                                      else "":U )
                                             )
      .
   end.
    v-torgconf-suppi = substitute(  "&1&2&3 &4 &5&6"
                                     , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-cli-inn, v-torgconf-cli-kpp) ELSE "":U
                                     , v-torgconf-cli-name
                                     , ( if v-torgconf-outprncd = yes
                                         then substitute( " (&1)", v-torgconf-cli-code )
                                         else "":U )
                                     , v-torgconf-cli-addres
                                     , v-torgconf-cli-phone
                                     , ( if v-torgconf-cli-bank-r-schet <> "":U
                                         AND v-form-name                  = "torg12":U
                                         then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-cli-bank-r-schet
                                                        , v-torgconf-cli-bank-c-schet
                                                        , v-torgconf-cli-bank-bik
                                                        , v-torgconf-cli-bank-name
                                                        , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) ))
                                                else "":U )
                                     ).
    end.
    else do:
    v-torgconf-suppi = substitute(  "&1&2&3 &4 &5&6"
                                     , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                     , v-torgconf-self-host-name
                                     , ( if v-torgconf-outprncd = yes
                                         then substitute( " (&1)", v-torgconf-self-host-code )
                                         else "":U )
                                     , v-torgconf-self-host-addres
                                     , v-torgconf-self-host-phone
                                     , ( if v-torgconf-self-bank-r-schet <> "":U
                                         AND v-form-name                  = "torg12":U
                                         then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-self-bank-r-schet
                                                        , v-torgconf-self-bank-c-schet
                                                        , v-torgconf-self-bank-bik
                                                        , v-torgconf-self-bank-name
                                                        , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                else "":U )
                                        ).
      if v-torgconf-outares = yes
      and p-reverse = no
      then do:
         assign
            v-par-consignee-addres = v-torgconf-ship-post-addres
         .
      end.
      if v-torgconf-outares = no
      and p-reverse = no
      then do:
         assign
            v-par-consignee-addres = v-torgconf-ship-addres
         .
      end.
      if p-reverse = yes
      then do:
          assign
            v-par-consignee-addres = v-torgconf-ship-addres
          .
      end.
        assign
            v-torgconf-supplier         = substitute( "&1&2&3&4&5", v-torgconf-self-host-name, ( if v-torgconf-self-host-addres = "":U then "":U else ", " ), v-torgconf-self-host-addres,
                                          ( if v-torgconf-self-host-phone = "":U then "":U else ", " ), v-torgconf-self-host-phone )
            v-torgconf-saler            = substitute( "&1&2&3&4&5", v-torgconf-cli-name      , ( if v-torgconf-cli-addres       = "":U then "":U else ", " ), v-torgconf-cli-addres,
                                          ( if v-torgconf-cli-phone       = "":U then "":U else ", " ), v-torgconf-cli-phone )
            v-torgconf-consignee        = substitute( "&1&2&3&4&5", v-torgconf-ship-name      , ( if v-par-consignee-addres   = "":U then "":U else ", " ), v-par-consignee-addres,
                                           ( if v-torgconf-ship-phone   = "":U then "":U else ", " ), v-torgconf-ship-phone)
            v-torgconf-supplier-okpo    = v-torgconf-self-host-okpo
            v-torgconf-saler-okpo       = v-torgconf-cli-okpo
            v-torgconf-consignee-okpo   = v-torgconf-ship-okpo
            v-torgconf-supplier-code    = substitute( "&1", v-torgconf-self-host-code   )
            v-torgconf-supplier-code    = v-torgconf-self-host-type
            v-torgconf-saler-code       = substitute( "&1", v-torgconf-cli-code         )
            v-torgconf-saler-type       = v-torgconf-cli-type
            v-torgconf-consignee-code   = substitute( "&1", v-torgconf-ship-code         )
            v-torgconf-consignee-type   = v-torgconf-ship-type
            v-torgconf-supplier-name    = substitute( "&1", v-torgconf-self-host-name   )
            v-torgconf-saler-name       = substitute( "&1", v-torgconf-cli-name         )
            v-torgconf-consignee-name   = substitute( "&1", v-torgconf-ship-name         )
            v-torgconf-supplier-addr    = substitute( "&1", v-torgconf-self-host-addres )
            v-torgconf-saler-addr       = substitute( "&1", v-torgconf-cli-addres       )
            v-torgconf-consignee-addr   = substitute( "&1", v-par-consignee-addres                )
            v-torgconf-supplier-inn     = substitute( "&1", v-torgconf-self-host-inn    )
            v-torgconf-supplier-engl-name     = substitute( "&1", v-torgconf-self-host-engl-name    )
            v-torgconf-saler-inn        = substitute( "&1", v-torgconf-cli-inn          )
            v-torgconf-consignee-inn    = substitute( "&1", v-torgconf-ship-inn          )
            v-torgconf-supplier-kpp     = substitute( "&1", v-torgconf-self-host-kpp    )
            v-torgconf-saler-kpp        = substitute( "&1", v-torgconf-cli-kpp          )
            v-torgconf-consignee-kpp    = substitute( "&1", v-torgconf-ship-kpp          )
            v-torgconf-sf-buyer-name    = v-torgconf-consignee-name
            v-torgconf-sf-buyer-code    = v-torgconf-consignee-code
            v-torgconf-sf-buyer-type    = v-torgconf-consignee-type
            v-torgconf-sf-buyer-addr    = v-torgconf-consignee-addr
        .
        if v-torgconf-self-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-supplier = v-torgconf-supplier
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-self-bank-r-schet
                                , v-torgconf-self-bank-c-schet
                                )
            .
            if v-torgconf-self-bank-exists = yes
            then do:
                assign
                    v-torgconf-supplier = v-torgconf-supplier
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-self-bank-bik
                                    , v-torgconf-self-bank-name
                                    , v-torgconf-self-bank-addres
                                    )
                .
            end.
        end.
        if v-torgconf-cli-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-saler = v-torgconf-saler
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-cli-bank-r-schet
                                , v-torgconf-cli-bank-c-schet
                                )
            .
            if v-torgconf-cli-bank-exists = yes
            then do:
                assign
                    v-torgconf-saler = v-torgconf-saler
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-cli-bank-bik
                                    , v-torgconf-cli-bank-name
                                    , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                    )
                .
            end.
        end.
        if v-torgconf-ship-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-consignee = v-torgconf-consignee
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-ship-bank-r-schet
                                , v-torgconf-ship-bank-c-schet
                                )
            .
            if v-torgconf-ship-bank-exists = yes
            then do:
                assign
                    v-torgconf-consignee = v-torgconf-consignee
                        + substitute( " БИК &1 в &2  &3"
                                    , v-torgconf-ship-bank-bik
                                    , v-torgconf-ship-bank-name
                                    , (if v-torgconf-ship-bank-city = "":U then "":U else ( "г. " + v-torgconf-ship-bank-city) )
                                    )
                .
            end.
        end.
   if p-reverse = yes
      then do:
       if  v-torgconf-outares = yes then v-torgconf-saler = substitute( "&1&2&3", v-torgconf-cli-name      , ( if v-torgconf-cli-post-addres       = "":U then "":U else ", " ), v-torgconf-cli-post-addres       )
         .
       else v-torgconf-saler = substitute( "&1&2&3", v-torgconf-cli-name      , ( if v-torgconf-cli-addres       = "":U then "":U else ", " ), v-torgconf-cli-addres       ) .
              if v-torgconf-cli-schet-exists = yes
              AND v-form-name                  = "torg12":U
                  then do:
                        assign
                           v-torgconf-saler = v-torgconf-saler
                              + substitute( ", р/с &1 к/с &2"
                                          , v-torgconf-cli-bank-r-schet
                                          , v-torgconf-cli-bank-c-schet
                                          )
            .
            if v-torgconf-cli-bank-exists = yes
            AND v-form-name                  = "torg12":U
               then do:
                  assign
                     v-torgconf-saler = v-torgconf-saler
                           + substitute( " БИК &1 в &2  &3"
                                       , v-torgconf-cli-bank-bik
                                       , v-torgconf-cli-bank-name
                                       , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                       )
                  .
            end.
        end.
        v-torgconf-saler-name = v-torgconf-cli-name .
        v-torgconf-saler-okpo = v-torgconf-cli-okpo.
   end.
    if trim(v-torgconf-consignee) = ""
    and v-torgconf-outares = yes
    and p-reverse = no
    then do:
      assign
      v-torgconf-consignee = substitute( "&1&2&3", v-torgconf-cli-name      , ( if v-torgconf-cli-post-addres       = "":U then "":U else ", " ), v-torgconf-cli-post-addres)
      .
         if v-torgconf-cli-schet-exists = yes
         AND v-form-name                  = "torg12":U
            then do:
                  assign
                     v-torgconf-consignee = v-torgconf-consignee
                        + substitute( ", р/с &1 к/с &2"
                                    , v-torgconf-cli-bank-r-schet
                                    , v-torgconf-cli-bank-c-schet
                                    )
                  .
                  if v-torgconf-cli-bank-exists = yes
                  then do:
                     assign
                        v-torgconf-consignee = v-torgconf-consignee
                              + substitute( " БИК &1 в &2 &3"
                                          , v-torgconf-cli-bank-bik
                                          , v-torgconf-cli-bank-name
                                          , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                          )
                     .
                  end.
            end.
    end.
    if trim(v-torgconf-consignee) = ""
    and v-torgconf-outares = no
    and p-reverse = no
    then do:
    assign
      v-torgconf-consignee = substitute( "&1&2&3", v-torgconf-cli-name      , ( if v-torgconf-cli-addres       = "":U then "":U else ", " ), v-torgconf-cli-addres)
      .
         if v-torgconf-cli-schet-exists = yes
         AND v-form-name                  = "torg12":U
            then do:
                  assign
                     v-torgconf-consignee = v-torgconf-consignee
                        + substitute( ", р/с &1 к/с &2"
                                    , v-torgconf-cli-bank-r-schet
                                    , v-torgconf-cli-bank-c-schet
                                    )
                  .
                  if v-torgconf-cli-bank-exists = yes
                  then do:
                     assign
                        v-torgconf-consignee = v-torgconf-consignee
                              + substitute( " БИК &1 в &2 &3"
                                          , v-torgconf-cli-bank-bik
                                          , v-torgconf-cli-bank-name
                                          , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                          )
                     .
                  end.
            end.
    end.
    if trim(v-torgconf-consignee) = ""
    and    p-reverse = yes
    then do:
      assign
      v-torgconf-consignee = substitute( "&1&2&3", v-torgconf-cli-name      , ( if v-torgconf-cli-addres       = "":U then "":U else ", " ), v-torgconf-cli-addres)
      v-torgconf-sf-buyer-name    = v-torgconf-cli-name
      v-torgconf-sf-buyer-code    = string(v-torgconf-cli-code)
      v-torgconf-sf-buyer-type    = v-torgconf-cli-type
      v-torgconf-sf-buyer-addr    = v-torgconf-cli-addres
      .
         if v-torgconf-cli-schet-exists = yes
         AND v-form-name                  = "torg12":U
            then do:
                  assign
                     v-torgconf-consignee = v-torgconf-consignee
                        + substitute( ", р/с &1 к/с &2"
                                    , v-torgconf-cli-bank-r-schet
                                    , v-torgconf-cli-bank-c-schet
                                    )
                  .
                  if v-torgconf-cli-bank-exists = yes
                  then do:
                     assign
                        v-torgconf-consignee = v-torgconf-consignee
                              + substitute( " БИК &1 в &2 &3"
                                          , v-torgconf-cli-bank-bik
                                          , v-torgconf-cli-bank-name
                                          , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                          )
                     .
                  end.
            end.
    end.
   end.
    if p-for-inverse = yes
    or p-doc-type = 'при':U
    or p-doc-type = 'возврат':U
    then do:
        assign
            v-torgconf-cargo-from-name      = v-torgconf-cli-name
            v-torgconf-cargo-from-okpo      = v-torgconf-cli-okpo
            v-torgconf-cargo-from-addres    = v-torgconf-cli-addres
            v-torgconf-cargo-to-name        = v-torgconf-self-host-name
            v-torgconf-cargo-to-okpo        = v-torgconf-self-host-okpo
            v-torgconf-cargo-to-addres      = v-torgconf-self-host-post-addres
        .
        if v-torgconf-outares then v-torgconf-cargo-from-addres    = v-torgconf-cli-post-addres  .
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-self-host-code
            , input 'cargo-to':U
            , output v-torgconf-cargo-to-value
            , output v-attr-type
        ).
        run gbl/clntat-v.p (
              input v-torgconf-cli-type
            , input v-torgconf-cli-code
            , input 'cargo-from':U
            , output v-torgconf-cargo-from-value
            , output v-attr-type
        ).
        assign
            v-torgconf-cargo-from-sf-value = v-torgconf-cargo-from-value
        .
        if v-torgconf-cargo-to-value = "":U
        then do:
            if v-torgconf-ext-doc-type = 'pz':U
            OR v-torgconf-outobj = TRUE
            then do:
                assign
                    v-torgconf-cargo-to-value   = substitute( "&1&2 &3 &4"
                                                    , v-torgconf-self-host-name
                                                    , ( if v-torgconf-outprncd = yes
                                                    then substitute( " (&1)", v-torgconf-self-host-code )
                                                    else "":U )
                                                    , v-torgconf-self-obj-addres
                                                    , v-torgconf-self-obj-phone
                                                    )
                .
            end.
            else if v-torgconf-outasend = yes then do:
                assign
                    v-torgconf-cargo-to-value   = substitute( "&1&2 &3 &4"
                                                    , v-torgconf-self-host-name
                                                    , ( if v-torgconf-outprncd = yes
                                                    then substitute( " (&1)", v-torgconf-self-host-code )
                                                    else "":U )
                                                    , v-torgconf-self-host-post-addres
                                                    , v-torgconf-self-host-phone
                                                    )
                .
            end.
            else do:
                assign
                    v-torgconf-cargo-to-value   = substitute( "&1&2 &3 &4"
                                                    , v-torgconf-self-host-name
                                                    , ( if v-torgconf-outprncd = yes
                                                    then substitute( " (&1)", v-torgconf-self-host-code )
                                                    else "":U )
                                                    , v-torgconf-self-host-addres
                                                    , v-torgconf-self-host-phone
                                                    )
                .
            end.
        end.
        if v-torgconf-cargo-from-value = "":U
        then do:
            assign
                v-torgconf-cargo-from-value = substitute( "&1&2 &3 &4"
                                                , v-torgconf-cli-name
                                                , ( if v-torgconf-outprncd = yes
                                                  then substitute( " (&1)", v-torgconf-cli-code )
                                                  else "":U )
                                                , v-torgconf-cargo-from-addres
                                                , v-torgconf-cli-phone
                                                )
            .
        end.
        if v-torgconf-cargo-from-sf-value = "":U
        then do:
            assign
                v-torgconf-cargo-from-sf-value  = v-torgconf-cargo-from-name
                                                    + "  ":U
                                                    + v-torgconf-cargo-from-addres
            .
        end.
    end.
    else do:
        if v-torgconf-outsend then do:
        assign
            v-torgconf-cargo-from-name      = v-torgconf-self-obj-name
            v-torgconf-cargo-from-addres    = v-torgconf-self-obj-addres
        .
        end.
        else if v-torgconf-outobj then assign
            v-torgconf-cargo-from-name      = v-torgconf-self-host-name
            v-torgconf-cargo-from-addres    = v-torgconf-self-obj-addres
        .
        else if v-torgconf-outasend then assign
            v-torgconf-cargo-from-name      = v-torgconf-self-host-name
            v-torgconf-cargo-from-addres    = v-torgconf-self-host-post-addres
        .
        else  assign
            v-torgconf-cargo-from-name      = v-torgconf-self-host-name
            v-torgconf-cargo-from-addres    = v-torgconf-self-host-addres
        .
        assign
            v-torgconf-cargo-from-okpo      = v-torgconf-self-host-okpo
            v-torgconf-cargo-to-name        = v-torgconf-cli-name
            v-torgconf-cargo-to-okpo        = v-torgconf-cli-okpo
            v-torgconf-cargo-to-addres      = v-torgconf-cli-post-addres
        .
        run gbl/clntat-v.p (
              input v-torgconf-cli-type
            , input v-torgconf-cli-code
            , input 'cargo-to':U
            , output v-torgconf-cargo-to-value
            , output v-attr-type
        ).
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-self-host-code
            , input 'cargo-from':U
            , output v-torgconf-cargo-from-value
            , output v-attr-type
        ).
        assign
            v-torgconf-cargo-from-sf-value = v-torgconf-cargo-from-value
        .
        if v-torgconf-cargo-to-value = "":U
        then do:
            assign
                v-torgconf-cargo-to-value   = substitute( "&1&2 &3 &4"
                                                    , v-torgconf-cli-name
                                                    , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-cli-code )
                                                      else "":U )
                                                    , v-torgconf-cli-post-addres
                                                    , v-torgconf-cli-phone
                                                    )
            .
        end.
        if v-torgconf-cargo-from-value = "":U
        then do:
            assign
                v-torgconf-cargo-from-value = substitute( "&1&2 &3 &4"
                                                    , v-torgconf-self-host-name
                                                    , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-self-host-code )
                                                      else "":U )
                                                    , v-torgconf-self-host-post-addres
                                                    , v-torgconf-self-host-phone
                                                    )
            .
        end.
        if v-torgconf-cargo-from-sf-value = "":U
        then do:
            assign
                v-torgconf-cargo-from-sf-value  = v-torgconf-cargo-from-name
                                                    + "  ":U
                                                    +  v-torgconf-cargo-from-addres
            .
        end.
    end.
    if lookup( v-torgconf-ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u ) <> 0
    then do:
        assign
            v-torgconf-wth-cargo-to = "":U
        .
        run gbl/wthat-v.p (
              input p-doc-code
            , input 'wthconsignee':U
            , output v-torgconf-wth-cargo-to
            , output v-attr-type
        ).
        assign
            v-torgconf-wth-cargo-to = trim( v-torgconf-wth-cargo-to )
        .
        if v-torgconf-wth-cargo-to <> "":U
        then do:
            run fmtcli-get-client in this-procedure (
                  input substring( v-torgconf-wth-cargo-to, 1, 3  )
                , input integer( trim( substring( v-torgconf-wth-cargo-to, 4 ) ) )
            ).
            assign
                v-torgconf-cargo-to-value = substitute( "&1&2 &3 &4"
                                                    , v-fmtcli-name
                                                    , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", trim( substring( v-torgconf-wth-cargo-to, 4 ) ) )
                                                      else "":U )
                                                    , v-fmtcli-full-addres
                                                    , v-fmtcli-phone
                                                    )
            .
        end.
    end.
    if ( p-doc-type = 'при':U
    or p-doc-type = 'возврат':U )
    then do:
      if v-torgconf-outares = yes
      THEN DO:
         assign
            v-torgconf-torg12-cargo-value   = v-torgconf-supplier
            v-torgconf-torg12-cargo-code    = v-torgconf-supplier-code
            v-torgconf-torg12-cargo-type    = v-torgconf-supplier-type
            v-torgconf-torg12-cargo-type    = v-torgconf-supplier-okpo
         .
      END.
      ELSE DO:
         case v-form-name:
         WHEN "torg12":U
         THEN DO:
            assign
               v-torgconf-torg12-cargo-value   = SUBSTITUTE( "&1 ИНН &2 КПП &3"
                                                            , v-torgconf-supplier
                                                            , v-torgconf-supplier-inn
                                                            , v-torgconf-supplier-kpp
                                                            )
               v-torgconf-torg12-cargo-code    = v-torgconf-supplier-code
               v-torgconf-torg12-cargo-type    = v-torgconf-supplier-type
            .
         END.
         END CASE.
      END.
    end.
    else do:
      IF v-form-name = "torg12":U
      THEN DO:
         assign
            v-torgconf-torg12-cargo-value   = SUBSTITUTE( "&1 ИНН &2 КПП &3"
                                                         , v-torgconf-consignee
                                                         , v-torgconf-consignee-inn
                                                         , v-torgconf-consignee-kpp
                                                         )
            v-torgconf-torg12-cargo-code    = v-torgconf-consignee-code
            v-torgconf-torg12-cargo-type    = v-torgconf-consignee-type
            v-torgconf-torg12-cargo-okpo    = v-torgconf-consignee-okpo
         .
      END.
      ELSE DO:
         assign
            v-torgconf-torg12-cargo-value   = v-torgconf-consignee
            v-torgconf-torg12-cargo-code    = v-torgconf-consignee-code
            v-torgconf-torg12-cargo-type    = v-torgconf-consignee-type
         .
      END.
    end.
   assign
         v-torgconf-cons = v-torgconf-consignee
         v-torgconf-sal  = v-torgconf-saler
   .
   if p-reverse = yes
      then do:
              assign                v-torgconf-torg12-cargo-value   = SUBSTITUTE( "&1 ИНН &2 КПП &3"
                                                         , v-torgconf-saler
                                                         , v-torgconf-saler-inn
                                                         , v-torgconf-saler-kpp
                                                         )
            v-torgconf-torg12-cargo-code    = v-torgconf-saler-code
            v-torgconf-torg12-cargo-type    = v-torgconf-saler-type
            v-torgconf-torg12-cargo-okpo    = v-torgconf-saler-okpo
            v-torgconf-saler      = v-torgconf-cons
            v-torgconf-consignee  = v-torgconf-sal
            v-torgconf-saler-name = v-torgconf-sf-buyer-name
            v-torgconf-saler-code = v-torgconf-sf-buyer-code
            v-torgconf-saler-type = v-torgconf-sf-buyer-type
            v-torgconf-saler-addr = v-torgconf-sf-buyer-addr
            v-torgconf-saler-okpo = v-torgconf-consignee-okpo
            v-torgconf-saler-inn = v-torgconf-consignee-inn
            v-torgconf-saler-kpp = v-torgconf-consignee-kpp
      .
      end.
   if ( p-doc-type = 'при':U
   or p-doc-type = 'возврат':U )
   and not p-for-inverse
   and v-torgconf-ext-doc-type <> 're':U
   and v-torgconf-ext-doc-type <> 'pz':U
      then do:
         assign
            v-torgconf-torg12-cargo-label   = "Грузоотправитель"
            v-torgconf-torg12-cargo-okpo    = v-torgconf-cargo-from-okpo
            v-torgconf-torg12-cargo-string  = v-torgconf-torg12-cargo-label + ": ":U + v-torgconf-torg12-cargo-value
         .
      end.
      else do:
         assign
            v-torgconf-torg12-cargo-label   = "Грузополучатель"
            v-torgconf-torg12-cargo-string  = v-torgconf-torg12-cargo-label + ": ":U + v-torgconf-torg12-cargo-value
         .
      end.
    if v-torgconf-ext-doc-type = 're':U
    or v-torgconf-ext-doc-type = 'pz':U
    then do:
      assign
         v-torgconf-organization = v-torgconf-supplier
         v-torgconf-organization-code = v-torgconf-supplier-code
         v-torgconf-organization-type = v-torgconf-supplier-type
      .
    end.
    else do:
        if p-for-inverse = yes
        then do:
            assign
                v-torgconf-organization-code = substitute( "&1", v-torgconf-cli-code)
                v-torgconf-organization-type = v-torgconf-cli-type
                v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                            , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-cli-inn, v-torgconf-cli-kpp) ELSE "":U
                                            , v-torgconf-cli-name
                                            , ( if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-cli-code )
                                                else "":U )
                                            , v-torgconf-cli-addres
                                            , v-torgconf-cli-phone
                                            , ( if v-torgconf-cli-bank-r-schet <> "":U
                                              AND v-form-name                  = "torg12":U
                                                then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-cli-bank-r-schet
                                                        , v-torgconf-cli-bank-c-schet
                                                        , v-torgconf-cli-bank-bik
                                                        , v-torgconf-cli-bank-name
                                                        , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )     )
                                                else "":U )
                                        )
                v-torgconf-okpo         = v-torgconf-cli-okpo
            .
        end.
        else do:
            assign
                v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
                v-torgconf-organization-type = v-torgconf-self-host-type
                v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                            , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                            , v-torgconf-self-host-name
                                            , ( if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-self-host-code )
                                                else "":U )
                                            , v-torgconf-self-host-addres
                                            , v-torgconf-self-host-phone
                                            , ( if v-torgconf-self-bank-r-schet <> "":U
                                                AND v-form-name                  = "torg12":U
                                                then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-self-bank-r-schet
                                                        , v-torgconf-self-bank-c-schet
                                                        , v-torgconf-self-bank-bik
                                                        , v-torgconf-self-bank-name
                                                        , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                else "":U )
                                        )
                v-torgconf-okpo         = v-torgconf-self-host-okpo
            .
        end.
    end.
    assign
        v-torgconf-client-from = ( if p-doc-type = 'при':U
                                   or v-torgconf-ext-doc-type = 're':U
                                   or v-torgconf-ext-doc-type = 'pz':U
                                   then " ":U
                                   else substitute( "&1&2"
                                            , v-torgconf-self-obj-name
                                            , ( if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-self-obj-code  )
                                                else "":U ) ) )
    .
if   v-torgconf-outsend = no
and (  p-doc-type = 'при':U
    or p-doc-type = 'возврат':U
    )
and (  v-torgconf-ext-doc-type <> 're':U
    or v-torgconf-ext-doc-type <> 'pz':U
    )
then do:
   if v-torgconf-outobj = yes
   then do:
       assign
         v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
         v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                                , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                                , v-torgconf-self-host-name
                                                , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-self-host-code )
                                                      else "":U )
                                                , v-torgconf-self-obj-addres
                                                , v-torgconf-self-obj-phone
                                                , ( if v-torgconf-self-bank-r-schet <> "":U
                                                  AND v-form-name                  = "torg12":U
                                                      then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                            , v-torgconf-self-bank-r-schet
                                                            , v-torgconf-self-bank-c-schet
                                                            , v-torgconf-self-bank-bik
                                                            , v-torgconf-self-bank-name
                                                            , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                      else "":U )
                                             )
      .
   end.
   else do:
      if v-torgconf-outasend = no
      then do:
      assign
         v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
         v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                                , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                                , v-torgconf-self-host-name
                                                , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-self-host-code )
                                                      else "":U )
                                                , v-torgconf-self-host-addres
                                                , v-torgconf-self-host-phone
                                                , ( if v-torgconf-self-bank-r-schet <> "":U
                                                    AND v-form-name                  = "torg12":U
                                                      then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                            , v-torgconf-self-bank-r-schet
                                                            , v-torgconf-self-bank-c-schet
                                                            , v-torgconf-self-bank-bik
                                                            , v-torgconf-self-bank-name
                                                            , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                      else "":U )
                                             )
      .
      end.
      else do:
      assign
         v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
         v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                                , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                                , v-torgconf-self-host-name
                                                , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-self-host-code )
                                                      else "":U )
                                                , v-torgconf-self-host-post-addres
                                                , v-torgconf-self-host-phone
                                                , ( if v-torgconf-self-bank-r-schet <> "":U
                                                    AND v-form-name                  = "torg12":U
                                                      then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                            , v-torgconf-self-bank-r-schet
                                                            , v-torgconf-self-bank-c-schet
                                                            , v-torgconf-self-bank-bik
                                                            , v-torgconf-self-bank-name
                                                            , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                      else "":U )
                                             )
      .
      end.
   end.
end.
if  v-torgconf-outsend = yes
and (  p-doc-type = 'при':U
    or p-doc-type = 'возврат':U
    )
and ( v-torgconf-ext-doc-type <> 're':U
    or v-torgconf-ext-doc-type <> 'pz':U
    )
then do:
      assign
      v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
      v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                             , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                             , v-torgconf-self-obj-name
                                             , ( if v-torgconf-outprncd = yes
                                                   then substitute( " (&1)", v-torgconf-self-obj-code )
                                                   else "":U )
                                             , v-torgconf-self-obj-addres
                                             , v-torgconf-self-obj-phone
                                             , ( if v-torgconf-self-bank-r-schet <> "":U
                                                   AND v-form-name                  = "torg12":U
                                                   then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                         , v-torgconf-self-bank-r-schet
                                                         , v-torgconf-self-bank-c-schet
                                                         , v-torgconf-self-bank-bik
                                                         , v-torgconf-self-bank-name
                                                         , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                   else "":U )
                                          )
      .
end.
   if( p-doc-type <> 'при':U
   or  p-doc-type <> 'возврат':U )
   and v-torgconf-outsend  = no
   and v-torgconf-outasend = yes
   and v-torgconf-outobj   = no
   then do:
       assign
         v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
         v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                                , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                                , v-torgconf-self-host-name
                                                , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-self-host-code )
                                                      else "":U )
                                                , v-torgconf-self-host-post-addres
                                                , v-torgconf-self-host-phone
                                                , ( if v-torgconf-self-bank-r-schet <> "":U
                                                    AND v-form-name                  = "torg12":U
                                                      then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                            , v-torgconf-self-bank-r-schet
                                                            , v-torgconf-self-bank-c-schet
                                                            , v-torgconf-self-bank-bik
                                                            , v-torgconf-self-bank-name
                                                            , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                      else "":U )
                                             )
      .
   end.
   if ( not ( ( p-doc-type = 'при':U
             or p-doc-type = 'возврат':U )
               ))
    and v-torgconf-outsend = yes
    then do:
      assign
          v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
          v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                            , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                            , v-torgconf-self-obj-name
                                            , ( if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-self-host-code )
                                                else "":U )
                                            , v-torgconf-self-obj-addres
                                            , v-torgconf-self-obj-phone
                                            , ( if v-torgconf-self-bank-r-schet <> "":U
                                                AND v-form-name                  = "torg12":U
                                                then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-self-bank-r-schet
                                                        , v-torgconf-self-bank-c-schet
                                                        , v-torgconf-self-bank-bik
                                                        , v-torgconf-self-bank-name
                                                        , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                else "":U )
                                        )
          v-torgconf-client-from = ""
      .
    end.
    if ( not ( ( p-doc-type = 'при':U
             or p-doc-type = 'возврат':U )
     ))
    and v-torgconf-outsend = no
    and v-torgconf-outobj  = yes
    then do:
        assign
          v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
          v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                            , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                            , v-torgconf-self-host-name
                                            , ( if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-self-host-code )
                                                else "":U )
                                            , v-torgconf-self-obj-addres
                                            , v-torgconf-self-obj-phone
                                            , ( if v-torgconf-self-bank-r-schet <> "":U
                                                AND v-form-name                  = "torg12":U
                                                then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-self-bank-r-schet
                                                        , v-torgconf-self-bank-c-schet
                                                        , v-torgconf-self-bank-bik
                                                        , v-torgconf-self-bank-name
                                                        , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                else "":U )
                                        )
        .
    end.
    if v-torgconf-outnum = yes
    then do:
        assign
            v-torgconf-doc-code = "          "
        .
    end.
    else do:
        if lookup( v-torgconf-ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u ) <> 0
        then do:
            run gbl/wthat-v.p (
                  input p-doc-code
                , input 'wthnsf':U
                , output v-torgconf-doc-code
                , output v-attr-type
            ).
            assign
                v-doc-code-standard = ( trim( v-torgconf-doc-code ) = "":U )
            .
        end.
        else do:
            assign
                v-doc-code-standard = yes
            .
        end.
        if v-doc-code-standard = yes
        then do:
            run gbl/trdcat-v.p (
                input p-doc-code
                , input 'print-num':U
                , output v-torgconf-doc-code
                , output v-attr-type
            ).
            if v-torgconf-doc-code = "":U
            then do:
                if p-for-inverse = yes
                then do:
                    if p-doc-type = 'при':U
                    then do:
                        assign
                            v-torgconf-doc-code = entry( 1, p-doc-code, "=":U )
                        no-error.
                    end.
                    else do:
                        assign
                            v-torgconf-doc-code = entry( 1, p-doc-code, "-":U )
                        no-error.
                    end.
                    define variable v-doc-code-integer    as integer      no-undo.
                    assign
                        v-doc-code-integer = integer( v-torgconf-doc-code )
                    no-error.
                    if error-status :error
                    then do:
                        assign
                            v-doc-code-integer = 0
                        .
                    end.
                    if v-torgconf-doc-code = ""
                    then do:
                        assign v-torgconf-doc-code = substr( p-doc-code, 1, 2 )
                                            + string( month( p-doc-date ),  "99" )
                                            + string( day( p-doc-date ),    "99" )
                        .
                    end.
                    else do:
                        assign v-torgconf-doc-code = string( month( p-doc-date ), ">9" )
                                            + trim( string( day( p-doc-date ), ">9" ) )
                                            + string( v-doc-code-integer )
                        .
                    end.
                end.
                else do:
                    assign
                        v-torgconf-doc-code = p-doc-code
                    .
                end.
            end.
        end.
    end.
    if v-torgconf-outnum = yes
    then do:
        assign
            v-torgconf-vdoc-code = " "
        .
    end.
    else do:
      assign
         v-torgconf-vdoc-code = p-doc-code
      .
      if p-doc-type = 'при':U
      then do:
         run gbl/trdcat-v.p (
                    input p-doc-code
                  , input 'nids':U
                  , output v-doc-code-attr
                  , output v-attr-type
               ).
      end.
      if  p-doc-type =  'рас':U
      or  p-doc-type =  'возврат':U
      then do:
         run gbl/trdcat-v.p (
                    input p-doc-code
                  , input 'print-num':U
                  , output v-doc-code-attr
                  , output v-attr-type
               ).
      end.
      if trim(v-doc-code-attr) <> ""
      then do:
         assign
            v-torgconf-vdoc-code = v-doc-code-attr
         .
      end.
    end.
    if v-torgconf-outdate = yes
    then do:
        assign
         v-torgconf-doc-date =  "          "
         v-torgconf-vdoc-date = "          "
        .
    end.
    else do:
        if lookup( v-torgconf-ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u ) <> 0
        then do:
            run gbl/wthat-v.p (
                  input p-doc-code
                , input 'wthdsf':U
                , output v-torgconf-doc-date
                , output v-attr-type
            ).
            assign
                v-doc-date-standard = ( trim( v-torgconf-doc-date ) = "":U )
            .
        end.
        else do:
            assign
                v-doc-date-standard = yes
            .
        end.
        if v-doc-date-standard = yes
        then do:
            assign v-torgconf-doc-date =  ( if p-status_ <> 'факт':U
                                            or p-print-doc = yes
                                            then string( p-doc-date, "99/99/9999" )
                                            else string( p-fact-date, "99/99/9999" )
                                        )
            .
        end.
        assign v-torgconf-vdoc-date = ( if p-status_ <> 'факт':U
                                          then string( p-doc-date, "99/99/9999" )
                                          else string( p-fact-date, "99/99/9999" )
                                      )
        .
        if p-doc-type = 'при':U
           then do:
              run gbl/trdcat-v.p (
                  input p-doc-code
                , input 'dids':U
                , output v-torgconf-doc-date-attr
                , output v-attr-type
             ).
           end.
        if trim(v-torgconf-doc-date-attr) <> ""
        then do:
            assign v-torgconf-vdoc-date = v-torgconf-doc-date-attr
            .
        end.
    end.
   if  v-name <> 'wthtrg12'
   and v-name <> 'wthfct'
   and v-name <> 'wthm11'
   then do:
    run gbl/trdcat-v.p (
                  input p-doc-code
                , input 'NFinDoc':U
                , output v-dcode-attr
                , output v-par-type
            ) no-error.
    if error-status :error
    then do:
        assign v-dcode-attr = "".
    end.
    run gbl/trdcat-v.p (
                  input p-doc-code
                , input 'DFinDoc':U
                , output v-ddate-attr
                , output v-par-type
            ) no-error.
    if error-status :error
    then do:
        assign v-ddate-attr = "".
    end.
   end.
   else do:
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input p-doc-code ,
                        input 'wthpaydoc':U ,
                       output v-attr ,
                       output v-attr-type )  .
   end.
    case v-torgconf-outssdoc
    :
     when "nacl":U
     then do:
         if  v-name <> 'wthtrg12'
         and v-name <> 'wthfct'
         and v-name <> 'wthm11'
         then do:
            assign
               v-torgconf-plat-rasch-doc   = substitute( "&1 от &2 &3"
                                                , if trim(v-dcode-attr) = "" then v-torgconf-doc-code else v-dcode-attr
                                                , if trim(v-ddate-attr) = "" then v-torgconf-doc-date else v-ddate-attr
                                                , ( if p-status_ <> 'факт':U
                                                   then string( "(" + caps( p-status_ ) + ")" )
                                                   else "":U )
                                             )
            .
         end.
         else do:
         if trim(v-attr) = ""
         then do:
            assign
               v-torgconf-plat-rasch-doc   = substitute( "&1 от &2 &3",
                                                        v-torgconf-doc-code,
                                                        v-torgconf-doc-date,
                                                         ( if p-status_ <> 'факт':U then string( "(" + caps( p-status_ ) + ")" ) else "":U )
                                                        )
            .
         end.
         else do:
            assign
               v-torgconf-plat-rasch-doc = v-attr.
         end.
         end.
     end.
     otherwise do:
         if  v-name <> 'wthtrg12'
         and v-name <> 'wthfct'
         and v-name <> 'wthm11'
         then do:
            IF v-dcode-attr <> "":U
            OR v-ddate-attr <> "":U
            THEN
            assign
               v-torgconf-plat-rasch-doc   = substitute( "&1 от &2"
                                                   , if trim(v-dcode-attr) = "" then "" else v-dcode-attr
                                                   , if trim(v-ddate-attr) = "" then "" else v-ddate-attr
                                                )
            .
         end.
         else do:
            assign
               v-torgconf-plat-rasch-doc   = substitute( "&1", if trim(v-attr) = "" then "" else v-attr)
            .
         end.
     end.
    end case.
   if v-torgconf-outB = "no_print"
   then do:
      assign v-torgconf-main-buh = "".
   end.
   if v-torgconf-outB = "glbuh_firm"
   then do:
         if v-torgconf-self-host-code = 0
         then do:
         end.
         else do:
            find first buf_sysconf no-lock
               where buf_sysconf.host-code = v-torgconf-self-host-code
            .
            assign
               v-torgconf-main-buh  = buf_sysconf.snr-accnt
            .
         end.
   end.
   if v-torgconf-outB = "buh_obj"
   then do:
      CASE v-torgconf-self-obj-type:
      WHEN 'маг':U
      THEN DO:
         find first buf_shop no-lock
         where buf_shop.obj-code = v-torgconf-self-obj-code
         .
         assign
            v-torgconf-main-buh  = entry(1,buf_shop.acct,"|")
         .
      END.
      WHEN 'скл':U
      THEN DO:
         find first buf_store no-lock
         where buf_store.obj-code = v-torgconf-self-obj-code
         .
         assign
            v-torgconf-main-buh  = buf_store.store-man
         .
      END.
      OTHERWISE DO:
         assign
            v-torgconf-main-buh  = "":U
         .
      END.
      END CASE.
   end.
   if v-torgconf-outR = "no_print"
      then do:
         assign
            v-torgconf-main-boss = ""
            v-torgconf-main-boss-post = ""
         .
      end.
   if v-torgconf-outR = "ruk_firm"
      then do:
         find first buf_sysconf no-lock
         where buf_sysconf.host-code = v-torgconf-self-host-code
         no-error.
         if available buf_sysconf
         then do:
            assign
               v-torgconf-main-boss-post = buf_sysconf.head-position
            .
         end.
         find first buf_clients no-lock
         where buf_clients.obj-type = 'орг':U
         and buf_clients.obj-code = v-torgconf-self-host-code
         .
         find first buf_firm no-lock
         where buf_firm.firm-code = buf_clients.obj-code
         no-error.
         if available buf_firm
         then do:
            assign
               v-torgconf-main-boss = buf_firm.director
            .
         end.
      end.
   if v-torgconf-outR = "dir_obj"
      then do:
         CASE v-torgconf-self-obj-type:
         WHEN 'маг':U
         THEN DO:
            find first buf_shop no-lock
            where buf_shop.obj-code = v-torgconf-self-obj-code
            .
            assign
               v-torgconf-main-boss = buf_shop.director
               v-torgconf-main-boss-post = "Директор"
            .
         END.
         WHEN 'скл':U
         THEN DO:
            find first buf_store no-lock
            where buf_store.obj-code = v-torgconf-self-obj-code
            .
            assign
               v-torgconf-main-boss = buf_store.store-boss
               v-torgconf-main-boss-post = "Директор"
            .
         END.
         OTHERWISE DO:
            assign
               v-torgconf-main-boss       = "":U
               v-torgconf-main-boss-post  = "":U
            .
         END.
         END CASE.
      end.
   if  v-name <> 'wthtrg12':U
   and v-name <> 'wthfct':U
   and v-name <> 'wthm11':U
   then do:
    find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error.
    if available buf_trn-doc
      then do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-host-code
  )  .
      end.
    if v-torgconf-outogr = "no_print"
      then do:
         assign
            v-torgconf-ogr-name = ""
            v-torgconf-ogr-post = ""
         .
      end.
   if v-torgconf-outogr  = "ruk_firm"
         then do:
         find first buf_sysconf no-lock
         where buf_sysconf.host-code = v-host-code
         no-error.
         if available buf_sysconf
         then do:
            assign
               v-torgconf-ogr-post = buf_sysconf.head-position
            .
         end.
         find first buf_clients no-lock
             where buf_clients.obj-type = 'орг':U
             and buf_clients.obj-code = v-host-code
         .
         find first buf_firm no-lock
             where buf_firm.firm-code = buf_clients.obj-code
         .
         assign
             v-torgconf-ogr-name = buf_firm.director
         .
      end.
      if v-torgconf-outogr = "dir_obj"
         then do:
         find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
         no-error.
            CASE buf_trn-doc.obj-type:
            WHEN 'маг':U
            THEN DO:
               find first buf_shop no-lock
               where buf_shop.obj-code = buf_trn-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_shop.director
                  v-torgconf-ogr-post = "Директор"
               .
            END.
            WHEN 'скл':U
            THEN DO:
               find first buf_store no-lock
               where buf_store.obj-code = buf_trn-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_store.store-boss
                  v-torgconf-ogr-post = "Директор"
               .
            END.
            OTHERWISE DO:
               assign
                  v-torgconf-ogr-name = "":U
                  v-torgconf-ogr-post = "":U
               .
            END.
            END CASE.
         end.
   if v-torgconf-outogr = "manag_doc"
      then do:
         find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
         no-error.
         if available buf_trn-doc
         then do:
            run rep/get-psn.p
            (input buf_trn-doc.boss
            ,output v-torgconf-ogr-name
            ) .
         end.
         find first buf_person no-lock
         where buf_person.psn-code = buf_trn-doc.boss
         no-error.
         if available buf_person
         then do:
            v-torgconf-ogr-post = buf_person.position.
         end.
         if v-torgconf-ogr-name = "?":U then v-torgconf-ogr-name = "".
         if v-torgconf-ogr-post = ? then  v-torgconf-ogr-post = "".
      end.
   end.
   else do:
   find first buf_wth-doc no-lock
      where buf_wth-doc.doc-code = p-doc-code
      no-error.
      if available buf_wth-doc
         then do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_wth-doc.obj-type
  ,input  buf_wth-doc.obj-code
  ,output v-host-code
  )  .
         end.
      if v-torgconf-outogr = "no_print"
         then do:
            assign
               v-torgconf-ogr-name = ""
               v-torgconf-ogr-post = ""
            .
         end.
      if v-torgconf-outogr  = "ruk_firm"
            then do:
            find first buf_sysconf no-lock
            where buf_sysconf.host-code = v-host-code
            no-error.
            if available buf_sysconf
            then do:
               assign
                  v-torgconf-ogr-post = buf_sysconf.head-position
               .
            end.
            find first buf_clients no-lock
               where buf_clients.obj-type = 'орг':U
               and buf_clients.obj-code = v-host-code
            .
            find first buf_firm no-lock
               where buf_firm.firm-code = buf_clients.obj-code
            .
            assign
               v-torgconf-ogr-name = buf_firm.director
            .
         end.
         if v-torgconf-outogr = "dir_obj"
            then do:
            find first buf_wth-doc no-lock
            where buf_wth-doc.doc-code = p-doc-code
            no-error.
               find first buf_shop no-lock
               where buf_shop.obj-code = buf_wth-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_shop.director
                  v-torgconf-ogr-post = "Директор"
               .
            end.
      if v-torgconf-outogr = "manag_doc"
         then do:
            find first buf_wth-doc no-lock
            where buf_wth-doc.doc-code = p-doc-code
            no-error.
            if available buf_wth-doc
            then do:
               run rep/get-psn.p
               (input buf_wth-doc.deliver
               ,output v-torgconf-ogr-name
               ) .
            end.
            find first buf_person no-lock
            where buf_person.psn-code = buf_wth-doc.deliver
            no-error.
            if available buf_person
            then do:
               v-torgconf-ogr-post = buf_person.position.
            end.
            if v-torgconf-ogr-name = "?":U then v-torgconf-ogr-name = "".
            if v-torgconf-ogr-post = ? then  v-torgconf-ogr-post = "".
         end.
   end.
end.
end procedure.
procedure torgconf-get-outogr-param:
    define input parameter p-form-name  as character    no-undo.
    define input parameter p-host-code  as integer      no-undo.
    define input parameter p-obj-type   as character    no-undo.
    define input parameter p-obj-code   as integer      no-undo.
    define input parameter p-doc-code   as character      no-undo.
    define buffer buf_firm          for ub.firm .
    define buffer buf_clients       for ub.clients .
    define buffer buf_sysconf       for ub.sysconf .
    define buffer buf_shop          for ub.shop .
    define buffer buf_store         for ub.store .
    define buffer buf_person        for ub.person .
    define buffer buf_trn-doc       for ub.trn-doc .
    define buffer buf_wth-doc       for ub.wth-doc .
   if  p-form-name <> 'wthtrg12':U
   and p-form-name <> 'wthfct':U
   and p-form-name <> 'wthm11':U
   then do:
    find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error.
    if v-torgconf-outogr = "no_print"
      then do:
         assign
            v-torgconf-ogr-name = ""
            v-torgconf-ogr-post = ""
         .
      end.
   if v-torgconf-outogr  = "ruk_firm"
         then do:
         find first buf_sysconf no-lock
         where buf_sysconf.host-code = p-host-code
         no-error.
         if available buf_sysconf
         then do:
            assign
               v-torgconf-ogr-post = buf_sysconf.head-position
            .
         end.
         find first buf_clients no-lock
             where buf_clients.obj-type = 'орг':U
             and buf_clients.obj-code = p-host-code
         .
         find first buf_firm no-lock
             where buf_firm.firm-code = buf_clients.obj-code
         .
         assign
             v-torgconf-ogr-name = buf_firm.director
         .
      end.
      if v-torgconf-outogr = "dir_obj"
         then do:
         find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
         no-error.
            CASE buf_trn-doc.obj-type:
            WHEN 'маг':U
            THEN DO:
               find first buf_shop no-lock
               where buf_shop.obj-code = buf_trn-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_shop.director
                  v-torgconf-ogr-post = "Директор"
               .
            END.
            WHEN 'скл':U
            THEN DO:
               find first buf_store no-lock
               where buf_store.obj-code = buf_trn-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_store.store-boss
                  v-torgconf-ogr-post = "Директор"
               .
            END.
            OTHERWISE DO:
               assign
                  v-torgconf-ogr-name = "":U
                  v-torgconf-ogr-post = "":U
               .
            END.
            END CASE.
         end.
   if v-torgconf-outogr = "manag_doc"
      then do:
         find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
         no-error.
         if available buf_trn-doc
         then do:
            run rep/get-psn.p
            (input buf_trn-doc.boss
            ,output v-torgconf-ogr-name
            ) .
         end.
         find first buf_person no-lock
         where buf_person.psn-code = buf_trn-doc.boss
         no-error.
         if available buf_person
         then do:
            v-torgconf-ogr-post = buf_person.position.
         end.
         if v-torgconf-ogr-name = "?":U then v-torgconf-ogr-name = "".
         if v-torgconf-ogr-post = ? then  v-torgconf-ogr-post = "".
      end.
   end.
   else do:
   find first buf_wth-doc no-lock
      where buf_wth-doc.doc-code = p-doc-code
      no-error.
      if v-torgconf-outogr = "no_print"
         then do:
            assign
               v-torgconf-ogr-name = ""
               v-torgconf-ogr-post = ""
            .
         end.
      if v-torgconf-outogr  = "ruk_firm"
            then do:
            find first buf_sysconf no-lock
            where buf_sysconf.host-code = p-host-code
            no-error.
            if available buf_sysconf
            then do:
               assign
                  v-torgconf-ogr-post = buf_sysconf.head-position
               .
            end.
            find first buf_clients no-lock
               where buf_clients.obj-type = 'орг':U
               and buf_clients.obj-code = p-host-code
            .
            find first buf_firm no-lock
               where buf_firm.firm-code = buf_clients.obj-code
            .
            assign
               v-torgconf-ogr-name = buf_firm.director
            .
         end.
         if v-torgconf-outogr = "dir_obj"
            then do:
            find first buf_wth-doc no-lock
            where buf_wth-doc.doc-code = p-doc-code
            no-error.
               find first buf_shop no-lock
               where buf_shop.obj-code = buf_wth-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_shop.director
                  v-torgconf-ogr-post = "Директор"
               .
            end.
      if v-torgconf-outogr = "manag_doc"
         then do:
            find first buf_wth-doc no-lock
            where buf_wth-doc.doc-code = p-doc-code
            no-error.
            if available buf_wth-doc
            then do:
               run rep/get-psn.p
               (input buf_wth-doc.deliver
               ,output v-torgconf-ogr-name
               ) .
            end.
            find first buf_person no-lock
            where buf_person.psn-code = buf_wth-doc.deliver
            no-error.
            if available buf_person
            then do:
               v-torgconf-ogr-post = buf_person.position.
            end.
            if v-torgconf-ogr-name = "?":U then v-torgconf-ogr-name = "".
            if v-torgconf-ogr-post = ? then  v-torgconf-ogr-post = "".
         end.
   end.
end.
procedure torgconf-get-reason  :
define input parameter  p-doc-code       as character        no-undo.
define input parameter  p-reason-code    as integer          no-undo .
define input parameter  p-doc-type       as character        no-undo.
    if p-reason-code > 0
    then do:
        define buffer buf_trn-reason for ub.trn-reason.
        find first buf_trn-reason no-lock where buf_trn-reason.reason-code = p-reason-code no-error .
        if available buf_trn-reason then assign v-torgconf-reason =  buf_trn-reason.reason-name .
    end.
    else do:
        if p-doc-type = 'при':U
        then  do:
            define variable v-attr-type     as character    no-undo.
            define variable v-attr-value    as character    no-undo.
            run gbl/trdcat-v.p (input p-doc-code,input 'nids':U,output v-attr-value,output v-attr-type) .
            assign v-torgconf-reason = v-attr-value .
            run gbl/trdcat-v.p (input p-doc-code,input 'dids':U,output v-attr-value,output v-attr-type) .
            assign v-torgconf-reason = v-torgconf-reason + " от " + v-attr-value .
        end.
    end.
end procedure.
define variable vss-include-info16 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_p-fmt_string-part no-undo
    field str-key       as integer
    field string-part   as character
    index pi is primary unique
        str-key
.
define variable v-p-fmt-16-str-key    as integer      no-undo.
FUNCTION center-field RETURNS INTEGER (INPUT iStartPix AS INTEGER, iEndPix AS INTEGER,
                                  iInput AS INTEGER).
  def var v-start-print as integer no-undo .
  if (iStartPix < 0) or (iEndPix < iStartPix) then return 0.
  assign
    v-start-print = INTEGER(iStartPix + ((iEndPix - iStartPix) / 2) - (iInput / 2))
  .
  RETURN v-start-print .
END FUNCTION.
FUNCTION right-field RETURNS INTEGER ( iEndPix AS INTEGER,
                                  iInput AS INTEGER).
  def var v-start-print as integer no-undo .
  assign
    v-start-print = INTEGER(iEndPix - 1 - iInput)
  .
  if v-start-print < 0 then return 0.
  RETURN v-start-print .
END FUNCTION.
function p-fmt-align-string returns character (
      p-in-string      as character
    , p-page-width     as integer
    , p-align-type     as character
).
    define variable v-string-length     as integer      no-undo.
    define variable v-out-string        as character    no-undo.
    assign
        v-string-length = length( trim( p-in-string ) )
    .
    if v-string-length >= p-page-width
    then do:
        assign
            v-out-string = trim( p-in-string )
        .
    end.
    else do:
        case p-align-type
        :
            when 'left':U
            then do:
                assign
                    v-out-string = trim( p-in-string )
                .
            end.
            when 'right':U
            then do:
                assign
                    v-out-string = fill( " ":U, p-page-width - v-string-length ) + trim( p-in-string )
                .
            end.
            when 'center':U
            then do:
                assign
                    v-out-string = fill( " ":U, integer( ( p-page-width - v-string-length ) / 2 ) ) + trim( p-in-string )
                .
            end.
        end case.
    end.
    return v-out-string .
end function.
procedure p-fmt-split-string :
define input parameter p-source-string  as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
define output parameter p-string-1      as character        no-undo.
define output parameter p-string-2      as character        no-undo.
do
on error undo, return error
:
    define variable v-space-pos    as integer      no-undo.
    if length( p-source-string ) <= p-split-length
    then do:
        assign
            p-string-1 = p-source-string
        .
    end.
    else do:
        assign
            v-space-pos = r-index( p-source-string, " ":U, p-split-length )
        .
        if v-space-pos = 0
        then do:
            assign
                v-space-pos = index( p-source-string, " ":U )
            .
        end.
        if v-space-pos = 0
        then do:
            assign
                p-string-1 = substring( p-source-string, 1, p-split-length )
                p-string-2 = trim( substring( p-source-string, p-split-length, p-split-length ) )
            .
        end.
        else do:
            assign
                p-string-1 = substring( p-source-string, 1, v-space-pos )
                p-string-2 = trim( substring( p-source-string, v-space-pos ) )
            .
        end.
    end.
end.
end procedure.
procedure p-fmt-round :
define input parameter p-qnty               as decimal          no-undo.
define input parameter p-price-no-VAT       as decimal          no-undo.
define input parameter p-VAT                as decimal          no-undo.
define input parameter p-SLT                as decimal          no-undo.
define input parameter p-road-tax           as decimal          no-undo.
define output parameter p-new-price-no-VAT  as decimal          no-undo.
define output parameter p-new-VAT           as decimal          no-undo.
define output parameter p-new-SLT           as decimal          no-undo.
define output parameter p-new-sum-VAT       as decimal          no-undo.
define output parameter p-new-sum-SLT       as decimal          no-undo.
define output parameter p-new-sum-road-tax  as decimal          no-undo.
define output parameter p-new-sum-no-VAT    as decimal          no-undo.
define output parameter p-new-sum-full      as decimal          no-undo.
    define variable v-vat-pc    as decimal      no-undo.
    define variable v-slt-pc    as decimal      no-undo.
do
on error undo, return error
:
    if p-price-no-VAT = 0
    then do:
        assign
            p-new-price-no-VAT = 0.0
            p-new-VAT          = ?
            p-new-SLT          = ?
            p-new-sum-VAT      = 0.0
            p-new-sum-SLT      = 0.0
            p-new-sum-no-VAT   = 0.0
            p-new-sum-road-tax = 0.0
            p-new-sum-full     = 0.0
        .
    end.
    else do:
        assign
            v-vat-pc            = p-VAT / p-price-no-VAT
            v-slt-pc            = p-SLT / ( p-price-no-VAT + p-VAT )
            p-new-price-no-VAT  = round( p-price-no-VAT, 2 )
            p-new-VAT           = round( p-new-price-no-VAT * v-vat-pc, 2 )
            p-new-SLT           = round( ( p-new-price-no-VAT + p-new-VAT ) * v-slt-pc, 2 )
            p-new-sum-VAT       = round( p-new-VAT          * p-qnty, 2 )
            p-new-sum-SLT       = round( ( p-new-price-no-VAT + p-new-VAT ) * p-qnty * v-slt-pc, 2 )
            p-new-sum-no-VAT    = round( p-new-price-no-VAT * p-qnty, 2 )
            p-new-sum-road-tax  = round( p-road-tax * p-qnty, 2 )
            p-new-sum-full      = round( ( p-new-price-no-VAT + p-new-VAT + p-new-SLT + p-road-tax ) * p-qnty, 2 )
        .
    end.
end.
end procedure.
procedure p-fmt-split :
define input parameter p-in-string      as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
    define variable v-start-pos     as integer      no-undo.
    define variable v-end-pos       as integer      no-undo.
    define buffer buf_temp_p-fmt_string-part        for temp_p-fmt_string-part.
do
for buf_temp_p-fmt_string-part
on error undo, return error
:
    empty temp-table buf_temp_p-fmt_string-part.
    if p-split-length < 1
    then do:
        undo, return error substitute( "p-fmt-split: Строка не может быть разбита на &1 частей", p-split-length ).
    end.
    assign
        p-in-string                 = trim( p-in-string )
        v-p-fmt-16-str-key   = 0
        v-start-pos                 = 1
        v-end-pos                   = length( p-in-string )
    .
    run p-fmt-get-string-range in this-procedure (
          input p-in-string
        , input p-split-length
        , input v-start-pos
        , output v-start-pos
        , output v-end-pos
    ).
    do while v-end-pos <> 0
    :
        create buf_temp_p-fmt_string-part.
        assign
            v-p-fmt-16-str-key = v-p-fmt-16-str-key + 1
        .
        assign
            buf_temp_p-fmt_string-part.str-key      = v-p-fmt-16-str-key
            buf_temp_p-fmt_string-part.string-part  = substring( p-in-string, v-start-pos, v-end-pos - v-start-pos )
        .
        assign
            v-start-pos = v-end-pos + 1
        .
        run p-fmt-get-string-range in this-procedure (
              input p-in-string
            , input p-split-length
            , input v-start-pos
            , output v-start-pos
            , output v-end-pos
        ).
    end.
end.
end procedure.
procedure p-fmt-get-string-range :
define input parameter p-in-string      as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
define input parameter p-old-start-pos  as integer          no-undo.
define output parameter p-start-pos     as integer          no-undo.
define output parameter p-end-pos       as integer          no-undo.
    define variable v-init-string    as character    no-undo.
    define variable v-temp-char      as character    no-undo.
    define variable v-temp-pos       as integer      no-undo.
    define variable v-counter        as integer      no-undo.
do
on error undo, return error
:
    assign
        p-start-pos   = p-old-start-pos
        v-init-string = substring( p-in-string, p-start-pos )
    no-error.
    if error-status :error
    or trim( v-init-string ) = "":U
    then do:
        assign
            p-end-pos = 0
        .
        undo, return .
    end.
    assign
        v-temp-char   = substring( v-init-string, 1, 1 )
    .
    do
    while trim( v-temp-char ) = "":U
    :
        assign
            p-start-pos     = p-start-pos + 1
            v-init-string   = substring( p-in-string, p-start-pos )
            v-temp-char     = substring( v-init-string, 1, 1 )
        .
    end.
    assign
        v-temp-pos  = p-split-length
        v-temp-char = substring( v-init-string, v-temp-pos, 1 )
        v-counter   = 0
    .
    search-word-end:
    do
    while trim( v-temp-char ) <> "":U
    :
        assign
            v-counter   = v-counter + 1
        .
        if v-counter > 20
        then do:
            assign
                v-temp-pos  = p-split-length
            .
            leave search-word-end.
        end.
        assign
            v-temp-pos  = v-temp-pos - 1
            v-temp-char = substring( v-init-string, v-temp-pos, 1 )
        .
    end.
    assign
        p-end-pos = p-start-pos + v-temp-pos - 1
    .
end.
end procedure.
def var vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
def var vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-param no-undo   field param-code     as character   field param-sub-code as character   field param-value    as character   index xpk is primary unique param-code param-sub-code   .
procedure paramls-clear :
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.
end procedure.
procedure paramls-write :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.
end procedure.
procedure paramls-read :
  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.
end procedure.
procedure paramls-append :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.
end procedure.
define variable vss-include-info19 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
    field data-key     as character
    field xl-line-id   as integer
    field Name         as character
    field EI           as character
    field qnty         as character
    field price        as character
    field SumNoVAT     as character
    field SumActciz    as character
    field VATpc        as character
    field VATsum       as character
    field sum          as character
    field country      as character
    field GTD          as character
    index pi is primary unique xl-line-id
.
define variable v-facturxl-current-data-row     as integer      no-undo.
define variable v-facturxl-cell-file-name       as character    no-undo.
define variable v-facturxl-data-file-name       as character    no-undo.
procedure facturxl-init :
    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-facturxl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-facturxl-data-file-name
    ).
    output stream excel-line to value( v-facturxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-facturxl-cell-file-name
    ).
    output stream excel-cell to value( v-facturxl-cell-file-name ).
    if printrubl
    then do:
        run facturxl-write-cell-data in this-procedure (
              input "valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run facturxl-write-cell-data in this-procedure (
              input "valutCode":U
            , input "1":U
        ).
    end.
    run facturxl-write-cell-data in this-procedure (
          input "columnList":U
        , input "Name,EI,qnty,price,SumNoVAT,SumActciz,VATpc,VATsum,sum,country,GTD":U
    ).
    run facturxl-write-cell-data in this-procedure (
          input "columnType":U
        , input "S,S,D,C,C,S,D,C,C,S,S":U
    ).
    run facturxl-write-cell-data in this-procedure (
          input "columnAmount":U
        , input "11":U
    ).
    run facturxl-write-cell-data in this-procedure (
          input "subtotalList":U
        , input "SumNoVAT,VATsum,sum":U
    ).
    run facturxl-write-cell-data in this-procedure (
          input "subtotalType":U
        , input "S,S,S":U
    ).
    run facturxl-write-cell-data in this-procedure (
          input "subtotalAmount":U
        , input "3":U
    ).
end.
end procedure.
procedure facturxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/sf_97old.xlt":U.
        export "exe/t_97.bas":U.
        export v-facturxl-cell-file-name.
        export v-facturxl-data-file-name.
    output close.
end.
end procedure.
procedure facturxl-close-10 :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/sf_97-10.xlt":U.
        export "exe/t_97.bas":U.
        export v-facturxl-cell-file-name.
        export v-facturxl-data-file-name.
    output close.
end.
end procedure.
procedure facturxl-close-vat-itog :
do
on error undo, return error return-value
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/sf_97vat.xlt":U.
        export "exe/t_97.bas":U.
        export v-facturxl-cell-file-name.
        export v-facturxl-data-file-name.
    output close.
end.
end procedure.
procedure facturxl-write-cell-data :
define input parameter p-data-key   as character        no-undo.
define input parameter p-data-value as character        no-undo.
    define buffer buf_temp_cell-data     for temp_cell-data.
do
for buf_temp_cell-data
on error undo, return error
:
    find first buf_temp_cell-data
         where buf_temp_cell-data.data-key = p-data-key
    no-error.
    if not available buf_temp_cell-data
    then do:
        create buf_temp_cell-data.
        assign
            buf_temp_cell-data.data-key = p-data-key
        .
    end.
    assign
        buf_temp_cell-data.data-value = p-data-value
    .
    put stream excel-cell unformatted
                        buf_temp_cell-data.data-key
        chr(9)   buf_temp_cell-data.data-value
        chr(10)
    .
end.
end procedure.
procedure facturxl-write-line-data :
define input parameter p-Name          as character        no-undo.
define input parameter p-UAES          as character        no-undo.
define input parameter p-EI            as character        no-undo.
define input parameter p-qnty          as character        no-undo.
define input parameter p-price         as character        no-undo.
define input parameter p-SumNoVAT      as character        no-undo.
define input parameter p-SumActciz     as character        no-undo.
define input parameter p-VATpc         as character        no-undo.
define input parameter p-VATsum        as character        no-undo.
define input parameter p-sum           as character        no-undo.
define input parameter p-country       as character        no-undo.
define input parameter p-GTD           as character        no-undo.
    define buffer buf_temp_line-data        for temp_line-data.
do
for buf_temp_line-data
on error undo, return error
:
    for each buf_temp_line-data
    :
        delete buf_temp_line-data.
    end.
    create buf_temp_line-data.
    assign
        v-facturxl-current-data-row = v-facturxl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = "LD":U
        buf_temp_line-data.xl-line-id   = v-facturxl-current-data-row
        buf_temp_line-data.Name         = p-Name
        buf_temp_line-data.EI           = p-EI
        buf_temp_line-data.qnty         = p-qnty
        buf_temp_line-data.price        = p-price
        buf_temp_line-data.SumNoVAT     = p-SumNoVAT
        buf_temp_line-data.SumActciz    = p-SumActciz
        buf_temp_line-data.VATpc        = p-VATpc
        buf_temp_line-data.VATsum       = p-VATsum
        buf_temp_line-data.sum          = p-sum
        buf_temp_line-data.country      = p-country
        buf_temp_line-data.GTD          = p-GTD
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        chr(9)   buf_temp_line-data.Name
        chr(9)   buf_temp_line-data.EI
        chr(9)   buf_temp_line-data.qnty
        chr(9)   buf_temp_line-data.price
        chr(9)   buf_temp_line-data.SumNoVAT
        chr(9)   buf_temp_line-data.SumActciz
        chr(9)   buf_temp_line-data.VATpc
        chr(9)   buf_temp_line-data.VATsum
        chr(9)   buf_temp_line-data.sum
        chr(9)   buf_temp_line-data.country
        chr(9)   buf_temp_line-data.GTD
        chr(10)
    .
end.
end procedure.
procedure facturxl-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.
    define variable v-template-file-name    as character    no-undo.
    define variable v-vb-file-name          as character    no-undo.
    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/sf_97.xlt" )
        v-vb-file-name          = search( "exe/t_97.bas")
    .
    if v-template-file-name = ?
    or v-template-file-name = "":U
    then do:
        message
            "Ошибка имени файла шаблона."
        view-as alert-box error.
    end.
    if v-vb-file-name = ?
    or v-vb-file-name = "":U
    then do:
        message
            "Ошибка имени файла кода обработки."
        view-as alert-box error.
    end.
    run paramls-write in this-procedure (
          input "template":U
        , input "template-file-name":U
        , input v-template-file-name
    ).
    run paramls-write in this-procedure (
          input "template":U
        , input "vb-file-name":U
        , input v-vb-file-name
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-header-filename":U
        , input p-header-filename
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-filename":U
        , input p-data-filename
    ).
    run gbl/macroxlt.p (
        input-output table buf_temp-param
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка создания файла Excel."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
end procedure.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define stream Out-stream .
define shared variable PrintScale   as logical              no-undo.
define shared variable CostPrice    as logical              no-undo.
define variable v-must-print-scale      as logical              no-undo.
define variable tdoc-prt                as logical              no-undo.
define variable p-sf-par                as logical              no-undo.
define variable PrevPage                as integer   initial 0  no-undo.
define variable str                     as character            no-undo.
define variable gds-str                 as character            no-undo.
define variable gds-str1                as character            no-undo.
define variable gds-str2                as character            no-undo.
define variable rootnode_code           as integer              no-undo.
define variable v-lines-counter         as integer              no-undo.
define variable v-node-code             like ub.gds-prt.upper-code no-undo.
define variable v-qnty                  as decimal              no-undo.
define variable v-price                 as decimal              no-undo.
define variable v-price-no-VAT          as decimal              no-undo.
define variable v-sum                   as decimal              no-undo.
define variable v-sum-no-VAT            as decimal              no-undo.
define variable v-sum-actciz            as decimal              no-undo.
define variable v-VAT                   as decimal              no-undo.
define variable v-SLT                   as decimal              no-undo.
define variable v-vat-pc                as decimal              no-undo.
define variable v-slt-pc                as decimal              no-undo.
define variable v-parts-price           as decimal              no-undo.
define variable v-parts-price-no-VAT    as decimal              no-undo.
define variable v-parts-sum             as decimal              no-undo.
define variable v-parts-sum-no-VAT      as decimal              no-undo.
define variable v-parts-sum-actciz      as decimal              no-undo.
define variable v-parts-VAT             as decimal              no-undo.
define variable v-parts-SLT             as decimal              no-undo.
define variable v-tot-sum               as decimal              no-undo.
define variable v-tot-VAT               as decimal              no-undo.
define variable v-tot-SLT               as decimal              no-undo.
define variable v-tot-sum-no-VAT        as decimal              no-undo.
define variable v-prt-qnty              as decimal              no-undo.
define variable v-prt-VAT               as decimal              no-undo.
define variable v-prt-SLT               as decimal              no-undo.
define variable v-prt-sum-no-VAT        as decimal              no-undo.
define variable v-prt-sum               as decimal              no-undo.
define variable v-tot-prt-qnty          as decimal              no-undo.
define variable v-tot-prt-VAT           as decimal              no-undo.
define variable v-tot-prt-SLT           as decimal              no-undo.
define variable v-tot-prt-sum-no-VAT    as decimal              no-undo.
define variable v-tot-prt-sum           as decimal              no-undo.
define variable sym1  as character initial ":" no-undo.
define variable sym2  as character initial ":" no-undo.
define variable sym3  as character initial ":" no-undo.
define variable sym4  as character initial ":" no-undo.
define variable sym5  as character initial ":" no-undo.
define variable sym6  as character initial ":" no-undo.
define variable sym7  as character initial ":" no-undo.
define variable sym8  as character initial ":" no-undo.
define variable sym9  as character initial ":" no-undo.
define variable sym10 as character initial ":" no-undo.
define variable sym11 as character initial ":" no-undo.
define variable sym12 as character initial ":" no-undo.
define variable sym13 as character initial ":" no-undo.
define variable v-prt-name       as character            no-undo.
define variable v-country        as character            no-undo.
define variable v-GTD            as character            no-undo.
define variable v-single-line    as character            no-undo.
define variable v-propis         as character            no-undo.
define variable v-propis-cop     as character            no-undo.
define variable t-addres         as character            no-undo.
define variable t-phone          as character            no-undo.
define variable t-inn            as character            no-undo.
define variable t-num            as character            no-undo.
define variable v-print-doc      as character            no-undo.
define variable v-par-type       as character            no-undo.
define variable v-curr-abbr      as character            no-undo.
define variable v-void-decimal   as decimal              no-undo.
define variable v-sum-VAT        as decimal              no-undo.
define variable v-sum-SLT        as decimal              no-undo.
define variable v-sum-tax        as decimal              no-undo.
define variable v-host-code     as integer              no-undo.
define variable v-curr-code     as integer              no-undo.
define variable v-r-factur-is-vozvrat-vnesh  as logical      no-undo.
define variable tmp-var         as character             no-undo.
define variable FullGdsName     as logical               no-undo.
define variable  v-trdcattr-type            as character                 no-undo .
define variable  v-code-rec                 as integer                   no-undo .
define variable  v-type-rec                 as character                 no-undo .
define variable  v-recipient-code           as character                 no-undo .
define variable  v-codefirm-rec             as character                 no-undo .
define variable  v-curcode-rec              as integer                   no-undo .
define variable  v-out-name                 as character                 no-undo .
define variable v-outhdobj      as logical  init no    no-undo .
define variable v-outhdobj-str  as character no-undo .
define variable v-cli-type      as character no-undo .
define variable v-cli-code      as integer   no-undo .
define variable v-is-hold-doc   as logical   no-undo .
define buffer buf_trn-doc               for ub.trn-doc.
define buffer buf_our_clients           for ub.clients.
define buffer buf_clients               for ub.clients.
define buffer buf_firm                  for ub.firm.
define buffer buf_sysconf               for ub.sysconf.
define buffer buf_country               for ub.country.
define buffer buf_parts-attr            for ub.parts-attr.
define frame factur
        sym1               column-label ":!:!:!:" format "X(1)" space(0)
        ub.goods.gds-name  column-label "Наименование товара (описание выполненных работ, ! оказанных услуг), имущественного права ! ":C54 format "X(54)" space(0)
        sym2               column-label ":!:!:!:" format "X(1)" space(0)
        ub.goods.unit-base column-label "Ед.!изм.! " format "X(4)" space(0)
        sym3               column-label ":!:!:!:" format "X(1)" space(0)
        v-qnty             column-label "Количество! ! " format ">>>>>>9.<<<" space(0)
        sym4               column-label ":!:!:!:" format "X(1)" space(0)
        v-price-no-VAT     column-label "Цена (тариф)!за ед.изм.! ":C12 format "->>>>>>>9.99" space(0)
        sym5               column-label ":!:!:!:" format "X(1)" space(0)
        v-sum-no-VAT       column-label "Стоимость товаров!(работ, услуг),!имуществ. прав!всего без налога":C17 format "->>>>>>>>>>>>9.99" space(0)
        sym6               column-label ":!:!:!:" format "X(1)" space(0)
        v-sum-actciz       column-label "в т.ч.!акциз! ":C9 format ">>>>>9.99" space(0)
        sym7               column-label ":!:!:!:" format "X(1)" space(0)
        ub.doc-line.Vat-pc column-label "Ставка!налога":C6 format ">9.9<%" space(0)
        sym8               column-label ":!:!:!:" format "X(1)" space(0)
        v-VAT              column-label "Сумма!налога! ":C12 format "->>>>>>>9.99" space(0)
        sym9               column-label ":!:!:!:" format "X(1)" space(0)
        v-sum              column-label "Ст-ть товаров!(работ, услуг),!имуществ. прав!с учетом налога":c15 format "->>>>>>>>>>9.99" space(0)
        sym11              column-label ":!:!:!:" format "X(1)" space(0)
        v-country          column-label "Страна!происхождения! ":C15 format "X(15)" space(0)
        sym12              column-label ":!:!:!:" format "X(1)" space(0)
        v-GTD              column-label "Номер таможенной!декларации! ":C31 format "X(31)" space(0)
        sym13              column-label ":!:!:!:" format "X(1)" space(0)
header
        ( if PAGE-NUMBER( Out-stream ) > 1
          then string( "Документ N: " + v-torgconf-doc-code + " от " + v-torgconf-doc-date )
          else "":U )                                                       at 40 format "X(50)"
        string( "Страница " + string( PAGE-NUMBER( Out-stream ), ">>9" ) )  at 180 format "X(13)" skip
        v-single-line format "X(198)" at 1
with width 235 down stream-io.
if session :set-wait-state( "compiler" ) then.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in p-mainmenu-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in p-mainmenu-handle
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
find first buf_trn-doc no-lock
     where recid( buf_trn-doc ) = rec_id
.
if buf_trn-doc.ext-doc-type = 're':U
then do:
    assign
        v-r-factur-is-vozvrat-vnesh = yes
    .
end.
else do:
    assign
        v-r-factur-is-vozvrat-vnesh = no
    .
end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-host-code
  )  .
if printRubl = yes
then do:
    assign
        v-curr-code = 0
    .
end.
else do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-curr-code
  )  .
end.
run torgconf-read in this-procedure (
      input "factur"
    , input v-host-code
    , input buf_trn-doc.obj-type
    , input buf_trn-doc.obj-code
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров печати формы."
    skip "Форма будет напечатана с параметрами по умолчанию."
    skip return-value
    skip trim( error-status :get-message( 1 ) )
         trim( error-status :get-message( 2 ) )
         trim( error-status :get-message( 3 ) )
    view-as alert-box error.
end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold-doc
  )  .
if  v-is-hold-doc then do:
  run gbl/conf-rd.p ("outhdobj" , v-host-code, buf_trn-doc.obj-type, buf_trn-doc.obj-code, "", "", "", no, output v-outhdobj-str , output v-par-type) no-error.
  if error-status :error
  then do:
    assign
      v-outhdobj-str = ""
    .
  end.
  if lookup( "factur", v-outhdobj-str ) <> 0
  then do:
    assign
      v-outhdobj = yes
    .
  end.
end.
  assign
    v-cli-type = buf_trn-doc.cli-type
    v-cli-code = buf_trn-doc.cli-code
  .
run torgconf-get-recepient-param (
    input buf_trn-doc.doc-code
  , output v-code-rec
  , output v-type-rec
  , output v-codefirm-rec
  , output v-curcode-rec
    ).
if v-code-rec = 0 and
   v-outhdobj = yes and
   v-is-hold-doc = yes
then do:
  assign
    v-type-rec = buf_trn-doc.hold-obj-type
    v-code-rec = buf_trn-doc.hold-obj-code
  .
end.
run torgconf-get-sup-param in this-procedure (
      input v-type-rec
    , input v-code-rec
    , input v-curcode-rec
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров объекта документа."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box warning.
end.
run torgconf-get-ship-param in this-procedure (
      input buf_trn-doc.host-code
    , input v-type-rec
    , input v-code-rec
    , input v-curcode-rec
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров объекта клиента документа."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box warning.
end.
run torgconf-get-self-param in this-procedure (
      input buf_trn-doc.obj-type
    , input buf_trn-doc.obj-code
    , input v-curr-code
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров объекта документа."
    skip return-value
    skip trim( error-status :get-message( 1 ) )
         trim( error-status :get-message( 2 ) )
         trim( error-status :get-message( 3 ) )
    view-as alert-box warning.
end.
run torgconf-get-cli-param in this-procedure (
      input buf_trn-doc.host-code
    , input v-cli-type
    , input v-cli-code
    , input v-curr-code
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров объекта клиента документа."
    skip return-value
    skip trim( error-status :get-message( 1 ) )
         trim( error-status :get-message( 2 ) )
         trim( error-status :get-message( 3 ) )
    view-as alert-box warning.
end.
assign
    v-single-line   = fill("-", 198)
    v-lines-counter = 1
.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_trn-doc.obj-type
  ,input buf_trn-doc.obj-code
  ,input 'prt-obj':U
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
    if thbjattr_thbj-attr.prop-code = 'FGdsNinD' then tmp-var =  string(thbjattr_thbj-attr.property-value-logical) .
end.
assign
    FullGdsName = ( tmp-var = "yes" )
.
output stream Out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
run facturxl-init in this-procedure .
run print-header in this-procedure (
      input buf_trn-doc.doc-code
    , output v-curr-abbr
).
form header
    v-single-line format "X(198)" at 1 skip
    "Продолжение - на следующей странице" at 30 skip
    with frame Bottomframe width 235 page-bottom no-labels no-box .
view stream Out-stream frame Bottomframe .
form with frame factur .
for each ub.doc-line no-lock
   where ub.doc-line.doc-code = buf_trn-doc.doc-code
break by ub.doc-line.artic
:
    run print-line in this-procedure .
end.
run print-footer in this-procedure .
run facturxl-close in this-procedure .
hide stream Out-stream frame Bottomframe .
output stream Out-stream close.
if session :set-wait-state( "" ) then.
def var Log-Res as logical no-undo .
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_waybills-to-file_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  no
    ,output Log-Res
    )  .
end.
if Log-Res
then do:
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 8 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
end.
else do:
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 0 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
end.
end.
procedure print-more:
do
on error undo, return error
:
    define variable v-start-string as character no-undo.
    define variable v-add-string as character no-undo.
    assign
        v-start-string = gds-str2
    .
    do while trim(v-start-string) <> "" :
        assign gds-str = v-start-string.
        v-add-string = breakstr(gds-str, 54, input-output v-add-string, input-output v-start-string).
        display stream Out-stream
            sym1 fill(" ",17) + v-add-string @ ub.goods.gds-name
            sym2 sym3 sym4 sym5 sym6 sym7 sym8
            sym9  sym11 sym12 sym13
            with frame factur .
        down stream Out-stream 1 with frame factur .
    end.
end.
end procedure.
procedure print-line :
do
on error undo, return error
:
define variable v-print-parts     as logical    init no       no-undo.
    find first ub.goods no-lock
         where ub.goods.prod-type = ub.doc-line.prod-type
           and ub.goods.prod-code = ub.doc-line.prod-code
           and ub.goods.artic = ub.doc-line.artic
    .
    find first ub.country no-lock
         where ub.country.alpha1 = ub.goods.alpha1
    no-error.
    if lookup( "zum", p-mode ) <> 0
    then do:
        assign
            v-country = ub.goods.engl-name
        .
    end.
    else do:
        if available ub.country
        then do:
            assign
                v-country = ub.country.short-name
            .
        end.
        else do:
            assign
                v-country = ""
            .
        end.
    end.
    assign
        gds-str  = ''
        gds-str1 = ''
        gds-str2 = ''
    .
    find first ub.Units no-lock
         where ub.units.unit-name = ub.goods.unit-base
    .
    if (units.type = "дро,2ед"  or  ub.units.type = "дро,доп" )
    then do:
        assign
            str =  string(ub.goods.artic,"x(16)") +  " "  + string(ub.goods.Sort,"x(5)") + " " + trim(ub.goods.gds-name)
                                                                                 + " " + trim(ub.goods.PS)
        .
    end.
    else do:
        assign
            str = string(ub.goods.artic,"x(16)") +  " "  + trim(ub.goods.gds-name)
        .
    end.
    assign
        Gds-str1 = breakstr(str, 54, input-output gds-str1, input-output gds-str2)
    .
    do while trim(gds-str2) <> "" :
        assign
            gds-str = gds-str2
            gds-str1 = breakstr(gds-str, 54, input-output gds-str1, input-output gds-str2)
        .
    end.
    assign
        gds-str1 = breakstr(str, 54, input-output gds-str1, input-output gds-str2).
    .
    find first ub.gds-prt no-lock
         where ub.gds-prt.upper-code = ub.doc-line.prt-root
    .
    assign
        rootnode_code = ub.gds-prt.node-code
    .
    if ( ub.gds-prt.node-name <> '_Пустая шкала':U )
    then do:
        assign
            v-tot-prt-qnty          = 0
            v-tot-prt-VAT           = 0
            v-tot-prt-SLT           = 0
            v-tot-prt-sum-no-VAT    = 0
            v-tot-prt-sum           = 0
            v-must-print-scale      = PrintScale
        .
        if v-must-print-scale = yes
        then do:
          define variable is-printed as logical initial no no-undo .
          for each ub.parts no-lock
             where ub.parts.out-code  = ub.doc-line.doc-code
               and ub.parts.obj-type  = ub.doc-line.obj-type
               and ub.parts.obj-code  = ub.doc-line.obj-code
               and ub.parts.artic     = ub.doc-line.artic
               and ub.parts.prod-type = ub.doc-line.prod-type
               and ub.parts.prod-code = ub.doc-line.prod-code
          :
            assign v-GTD = ub.parts.cst-code.
            if available ub.country
            and ub.country.alpha1 = "RU":U
            then do:
                assign
                    v-GTD       = "-":U
                    v-country   = "-":U
                .
            end.
            find first buf_parts-attr no-lock
              where buf_parts-attr.in-code   = ub.parts.in-code
                and buf_parts-attr.gds-code  = ub.goods.gds-code
                and buf_parts-attr.part-code = ub.parts.part-code
            no-error .
            if available buf_parts-attr
              and buf_parts-attr.country-code <> 0
              then do:
                  find first buf_country
                  where buf_country.num-code = buf_parts-attr.country-code
                  no-error.
                  if available buf_country
                  and buf_country.num-code <> ub.country.num-code
                  and buf_country.short-name <> ""
                  then do :
                       assign
                          v-country = buf_country.short-name
                        .
                       if buf_country.alpha1 = "RU":U
                       then do :
                          assign
                            v-country = "-":U
                            v-GTD     = "-":U
                          .
                       end .
                  end.
            end.
            if is-printed = no then do:
              assign is-printed = yes .
              display stream Out-stream sym1 gds-str1 @ ub.goods.gds-name sym2 v-country sym3 v-GTD
                                        sym4 sym5 sym6 sym7 sym8 sym9  sym11 sym12 sym13 with frame factur .
              down stream Out-stream 1 with frame factur .
                run facturxl-write-line-data in this-procedure (
                      input gds-str1
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input v-country
                    , input v-GTD
                ).
            end.
            else do:
              if v-GTD <> "" then do:
                display stream Out-stream sym1 sym2  sym3 v-GTD sym4 sym5 sym6 sym7 sym8 sym9  sym11 sym12 sym13 with frame factur .
                down stream Out-stream 1 with frame factur .
                run facturxl-write-line-data in this-procedure (
                      input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input "":U
                    , input v-GTD
                ).
              end.
            end.
          end.
          if is-printed = no then do:
            display stream Out-stream sym1 gds-str1 @ ub.goods.gds-name sym2 v-country sym3 sym4 sym5 sym6 sym7 sym8 sym9  sym11 sym12 sym13 with frame factur .
            down stream Out-stream 1 with frame factur .
            run facturxl-write-line-data in this-procedure (
                  input string( ub.goods.artic, "X(16)" ) + " " + ub.goods.gds-name
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input v-country
                , input "":U
            ).
            if FullGdsName
            and gds-str1 <> "":U then do :
               run print-more in this-procedure.
            end.
          end.
        end.
        for each ub.gds-dtl no-lock
           where ub.gds-dtl.prod-type  = ub.doc-line.prod-type
             and ub.gds-dtl.prod-code  = ub.doc-line.prod-code
             and ub.gds-dtl.artic      = ub.doc-line.artic
             and ub.gds-dtl.doc-code   = ub.doc-line.doc-code
        :
            find first ub.gds-prt no-lock
                 where ub.gds-prt.node-code = ub.gds-dtl.prt-code
            .
            if CostPrice = yes
            then do:
assign
  price-rubl-with-tax-loc = ub.doc-line.price-rubl
  price-base-with-tax-loc = ub.doc-line.price-base
.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = ub.doc-line.artic     and
                                     in-vatp-goods.prod-type = ub.doc-line.prod-type and
                                     in-vatp-goods.prod-code = ub.doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = ub.doc-line.road-tax
          road-tax-rubl-loc = ub.doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = ub.doc-line.road-tax
          road-tax-base-loc = ub.doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if ub.doc-line.transport-base = ? then 0 else ub.doc-line.transport-base)
        transport-rubl-loc = (if ub.doc-line.transport-rubl = ? then 0 else ub.doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if ub.doc-line.other-base     = ? then 0 else ub.doc-line.other-base)
        other-rubl-loc     = (if ub.doc-line.other-rubl     = ? then 0 else ub.doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if ub.doc-line.vat-pc         = ? then 0 else ub.doc-line.vat-pc)
        slt-pc-loc         = (if ub.doc-line.slt-pc         = ? then 0 else ub.doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = ub.doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = ub.doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = ub.doc-line.obj-code  and
                                      in-vatp-parts.artic     = ub.doc-line.artic     and
                                      in-vatp-parts.prod-type = ub.doc-line.prod-type and
                                      in-vatp-parts.prod-code = ub.doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if ub.doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / ub.doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if ub.doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / ub.doc-line.fact-qnty  else 0
        transport-base-loc  = if ub.doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / ub.doc-line.fact-qnty  else 0
        transport-rubl-loc  = if ub.doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / ub.doc-line.fact-qnty  else 0
        other-base-loc      = if ub.doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / ub.doc-line.fact-qnty  else 0
        other-rubl-loc      = if ub.doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / ub.doc-line.fact-qnty  else 0
                                        vat-base-loc        = if ub.doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / ub.doc-line.fact-qnty   else 0
        slt-base-loc        = if ub.doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / ub.doc-line.fact-qnty   else 0
                vat-rubl-loc        = if ub.doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / ub.doc-line.fact-qnty   else 0
        slt-rubl-loc        = if ub.doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / ub.doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
                assign
                    v-VAT       = ( if PrintRubl then vat-rubl-loc      else vat-base-loc )
                    v-SLT       = ( if PrintRubl then slt-rubl-loc      else slt-base-loc )
                .
                if v-VAT = ?        then assign v-VAT       = 0.
                if v-SLT = ?        then assign v-SLT       = 0.
                assign
                    v-price-no-VAT   = ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc ) - v-VAT - v-SLT
                    v-prt-qnty       = ub.gds-dtl.fact-qnty
                .
                if v-r-factur-is-vozvrat-vnesh = yes
                then do:
                    assign
                        v-price-no-VAT = v-price-no-VAT -
                                        ( if PrintRubl
                                            then ( transport-rubl-loc + other-rubl-loc )
                                            else ( transport-base-loc + other-base-loc ) )
                    .
                end.
                if p-round = 'round':U
                then do:
                    run p-fmt-round in this-procedure (
                          input v-prt-qnty
                        , input v-price-no-VAT
                        , input v-VAT
                        , input v-SLT
                        , input 0
                        , output v-price-no-VAT
                        , output v-VAT
                        , output v-SLT
                        , output v-prt-VAT
                        , output v-prt-SLT
                        , output v-void-decimal
                        , output v-prt-sum-no-VAT
                        , output v-void-decimal
                    ).
                end.
                else do:
                    assign
                        v-prt-VAT       =  v-VAT            * v-prt-qnty
                        v-prt-SLT        = v-SLT            * v-prt-qnty
                        v-prt-sum-no-VAT = v-price-no-VAT   * v-prt-qnty
                    .
                end.
                assign
                    v-price          = v-price-no-VAT + v-VAT
                    v-prt-sum        = v-prt-sum-no-VAT + v-prt-VAT
                .
                assign
                    v-tot-prt-qnty          = v-tot-prt-qnty        + v-prt-qnty
                    v-tot-prt-VAT           = v-tot-prt-VAT         + v-prt-VAT
                    v-tot-prt-SLT           = v-tot-prt-SLT         + v-prt-SLT
                    v-tot-prt-sum-no-VAT    = v-tot-prt-sum-no-VAT  + v-prt-sum-no-VAT
                    v-tot-prt-sum           = v-tot-prt-sum         + v-prt-sum
                .
            end.
            else do:
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
find first out-vatp_goods where out-vatp_goods.artic     = ub.doc-line.artic     and
                                   out-vatp_goods.prod-type = ub.doc-line.prod-type and
                                   out-vatp_goods.prod-code = ub.doc-line.prod-code no-lock.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  ub.doc-line.artic
  ,input  ub.doc-line.prod-type
  ,input  ub.doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
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
    "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if ub.doc-line.road-tax = ? then 0 else ub.doc-line.road-tax * 1)
    excise-base-sale      =  (if ub.doc-line.excise   = ? then 0 else ub.doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if ub.doc-line.road-tax = ? then 0 else ub.doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if ub.doc-line.excise   = ? then 0 else ub.doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if ub.doc-line.road-tax = ? then 0 else ub.doc-line.road-tax * 1)
    excise-rubl-sale      = (if ub.doc-line.excise   = ? then 0 else ub.doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if ub.doc-line.road-tax = ? then 0 else ub.doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if ub.doc-line.excise   = ? then 0 else ub.doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
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
       and out-vatp_doc-line.artic      = ub.doc-line.artic
       and out-vatp_doc-line.prod-type  = ub.doc-line.prod-type
       and out-vatp_doc-line.prod-code  = ub.doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = ub.doc-line.artic
                               and out-vatp_parts.prod-type  = ub.doc-line.prod-type
                               and out-vatp_parts.prod-code  = ub.doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc)
  discnt-base-sale            = ub.gds-dtl.discnt-base
  price-base-with-tax-sale    = (ub.gds-dtl.price-base - ub.gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc)
  discnt-rubl-sale            = ub.gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = ub.gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = ub.gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((ub.gds-dtl.price-base - ub.gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * ub.doc-line.cons-vat-pc / (100 + ub.doc-line.cons-vat-pc) * ub.gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((ub.gds-dtl.price-base - ub.gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc) * ub.gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * ub.doc-line.cons-vat-pc / (100 + ub.doc-line.cons-vat-pc) * ub.gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc) * ub.gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((ub.gds-dtl.price-base - ub.gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * ub.doc-line.cons-vat-pc / (100 + ub.doc-line.cons-vat-pc) * ub.gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((ub.gds-dtl.price-base - ub.gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - varprice-base-cons) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc) * ub.gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * ub.doc-line.cons-vat-pc / (100 + ub.doc-line.cons-vat-pc) * ub.gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - varprice-rubl-cons) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc) * ub.gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
                assign
                    v-VAT = ( if PrintRubl then vat-rubl-buyer else vat-base-buyer )
                    v-SLT = ( if PrintRubl then slt-rubl-sale else slt-base-sale )
                .
                if v-VAT = ? then assign v-VAT = 0.
                if v-SLT = ? then assign v-SLT = 0.
                assign
                    v-price-no-VAT   = ( if PrintRubl then price-rubl-with-tax-sale else price-base-with-tax-sale ) - v-VAT - v-SLT
                    v-prt-qnty       = ub.gds-dtl.fact-qnty
                .
                if p-round = 'round':U
                then do:
                    run p-fmt-round in this-procedure (
                          input v-prt-qnty
                        , input v-price-no-VAT
                        , input v-VAT
                        , input v-SLT
                        , input 0
                        , output v-price-no-VAT
                        , output v-VAT
                        , output v-SLT
                        , output v-prt-VAT
                        , output v-prt-SLT
                        , output v-void-decimal
                        , output v-prt-sum-no-VAT
                        , output v-void-decimal
                    ).
                end.
                else do:
                    assign
                        v-prt-VAT        = v-VAT          * v-prt-qnty
                        v-prt-SLT        = v-SLT          * v-prt-qnty
                        v-prt-sum-no-VAT = v-price-no-VAT * v-prt-qnty
                    .
                end.
                assign
                    v-price          = v-price-no-VAT + v-VAT
                    v-prt-sum        = v-prt-sum-no-VAT + v-prt-VAT
                .
                assign
                    v-tot-prt-qnty          = v-tot-prt-qnty        + v-prt-qnty
                    v-tot-prt-VAT           = v-tot-prt-VAT         + v-prt-VAT
                    v-tot-prt-SLT           = v-tot-prt-SLT         + v-prt-SLT
                    v-tot-prt-sum-no-VAT    = v-tot-prt-sum-no-VAT  + v-prt-sum-no-VAT
                    v-tot-prt-sum           = v-tot-prt-sum         + v-prt-sum
                .
            end.
            if v-must-print-scale
            then do:
                find first ub.bar-code no-lock
                     where ub.bar-code.gds-code    = ub.goods.gds-code
                       and ub.bar-code.unit-cli    = ub.goods.unit-base
                       and ub.bar-code.node-code   = ub.gds-dtl.prt-code
                       and ub.bar-code.part-code   = ""
                       and ub.bar-code.in-code     = ""
                .
                assign
                    v-prt-name = ""
                .
                do while available ub.gds-prt:
                    if available ub.gds-prt
                    then do:
                        assign
                            v-prt-name     = "\" + string( ub.gds-prt.node-name, "X(10)" ) + v-prt-name
                            v-node-code   = ub.gds-prt.upper-code
                        .
                    end.
                    find first ub.gds-prt no-lock
                         where ub.gds-prt.node-code = v-node-code
                           and ub.gds-prt.root <> yes
                    no-error.
                end.
                display stream out-stream
                        sym1 v-prt-name @ ub.goods.gds-name
                        sym2 ub.goods.unit-base
                        sym3 v-prt-qnty @ v-qnty
                        sym4 v-price-no-VAT
                        sym5 v-prt-sum-no-VAT @ v-sum-no-VAT
                        sym6 "   ---" format "x(6)" @ v-sum-actciz
                        sym7 ub.doc-line.Vat-pc
                        sym8 v-prt-VAT when v-prt-qnty <> 0 @ v-VAT
                        sym9 v-prt-sum @ v-sum
                        sym11 sym12 sym13
                        with frame factur .
                v-lines-counter = v-lines-counter + 1 .
                down stream out-stream 1 with frame factur .
                run facturxl-write-line-data in this-procedure (
                      input v-prt-name
                    , input "":U
                    , input ub.goods.unit-base
                    , input string( v-prt-qnty )
                    , input string( v-price-no-VAT )
                    , input string( v-prt-sum-no-VAT )
                    , input "   ---":U
                    , input string( ub.doc-line.Vat-pc )
                    , input string( v-prt-VAT )
                    , input string( v-prt-sum )
                    , input "":U
                    , input "":U
                ).
            end.
        end.
        assign
            v-qnty          = v-tot-prt-qnty
            v-VAT           = v-tot-prt-VAT
            v-SLT           = v-tot-prt-SLT
            v-sum-no-VAT    = v-tot-prt-sum-no-VAT
            v-sum           = v-tot-prt-sum
        .
        if not v-must-print-scale
        then do:
            assign v-price-no-VAT = v-sum-no-VAT / v-qnty.
            find first ub.bar-code no-lock
                    where ub.bar-code.gds-code = ub.goods.gds-code
                    and ub.bar-code.unit-cli = ub.goods.unit-base
                    and ub.bar-code.node-code = rootnode_code
                    and ub.bar-code.part-code = ""
                    and ub.bar-code.in-code = ""
            .
            for each ub.parts no-lock
                where ub.parts.out-code = ub.doc-line.doc-code
                    and ub.parts.obj-type = ub.doc-line.obj-type
                    and ub.parts.obj-code = ub.doc-line.obj-code
                    and ub.parts.artic = ub.doc-line.artic
                    and ub.parts.prod-type = ub.doc-line.prod-type
                    and ub.parts.prod-code = ub.doc-line.prod-code
            :
                    assign v-GTD = ub.parts.cst-code.
                    if available ub.country
                    and ub.country.alpha1 = "RU":U
                    then do:
                        assign
                            v-GTD       = "-":U
                            v-country   = "-":U
                        .
                    end.
                    find first buf_parts-attr no-lock
                      where buf_parts-attr.in-code   = ub.parts.in-code
                        and buf_parts-attr.gds-code  = ub.goods.gds-code
                        and buf_parts-attr.part-code = ub.parts.part-code
                    no-error .
                    if available buf_parts-attr
                      and buf_parts-attr.country-code <> 0
                      then do:
                          find first buf_country
                          where buf_country.num-code = buf_parts-attr.country-code
                          no-error.
                          if available buf_country
                          and buf_country.num-code <> ub.country.num-code
                          and buf_country.short-name <> ""
                          then do :
                              assign
                                  v-country = buf_country.short-name
                                .
                              if buf_country.alpha1 = "RU":U
                              then do :
                                  assign
                                    v-country = "-":U
                                    v-GTD     = "-":U
                                  .
                              end .
                          end.
                    end.
                    display stream Out-stream
                            sym1 string(ub.goods.artic,"X(16)") + " " + ub.goods.gds-name @ ub.goods.gds-name
                            sym2 ub.goods.unit-base
                            sym3 ub.parts.fact-qnty @ v-qnty
                            sym4 v-price-no-VAT
                            sym5 (if v-qnty <> 0 then v-sum-no-VAT * ub.parts.fact-qnty / v-qnty else 0 ) @ v-sum-no-VAT
                            sym6 "   ---" format "x(6)" @ v-sum-actciz
                            sym7 ub.doc-line.Vat-pc
                            sym8 v-VAT * ub.parts.fact-qnty / v-qnty when v-qnty <> 0 @ v-VAT
                            sym9 (if v-qnty <> 0 then v-sum * ub.parts.fact-qnty / v-qnty else 0 ) @ v-sum
                            sym11 v-country
                            sym12 v-GTD
                            sym13
                            with frame factur .
                    down stream Out-stream 1 with frame factur .
                    run facturxl-write-line-data in this-procedure (
                          input string( ub.goods.artic, "X(16)" ) + " " + ub.goods.gds-name
                        , input "":U
                        , input ub.goods.unit-base
                        , input string( ub.parts.fact-qnty )
                        , input string( v-price-no-VAT )
                        , input (if v-qnty <> 0 then v-sum-no-VAT * ub.parts.fact-qnty / v-qnty else 0 )
                        , input "   ---":U
                        , input string( ub.doc-line.Vat-pc )
                        , input ( if v-qnty = 0 then "":U else string( v-VAT * ub.parts.fact-qnty / v-qnty ) )
                        , input string( if v-qnty <> 0 then v-sum * ub.parts.fact-qnty / v-qnty else 0 )
                        , input v-country
                        , input v-GTD
                    ).
                    if FullGdsName
                    and goods.gds-name <> "":U then do :
                      run print-more in this-procedure.
                    end.
                    v-lines-counter = v-lines-counter + 1 .
            end.
        end.
    end.
    else do:
        find first ub.bar-code no-lock
                where ub.bar-code.gds-code = ub.goods.gds-code
                and ub.bar-code.unit-cli = ub.goods.unit-base
                and ub.bar-code.node-code = rootnode_code
                and ub.bar-code.part-code = ""
                and ub.bar-code.in-code = ""
        .
        if CostPrice = yes
        then do:
            assign v-qnty = ub.doc-line.doc-qnty.
assign
  price-rubl-with-tax-loc = ub.doc-line.price-rubl
  price-base-with-tax-loc = ub.doc-line.price-base
.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = ub.doc-line.artic     and
                                     in-vatp-goods.prod-type = ub.doc-line.prod-type and
                                     in-vatp-goods.prod-code = ub.doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = ub.doc-line.road-tax
          road-tax-rubl-loc = ub.doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = ub.doc-line.road-tax
          road-tax-base-loc = ub.doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if ub.doc-line.transport-base = ? then 0 else ub.doc-line.transport-base)
        transport-rubl-loc = (if ub.doc-line.transport-rubl = ? then 0 else ub.doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if ub.doc-line.other-base     = ? then 0 else ub.doc-line.other-base)
        other-rubl-loc     = (if ub.doc-line.other-rubl     = ? then 0 else ub.doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if ub.doc-line.vat-pc         = ? then 0 else ub.doc-line.vat-pc)
        slt-pc-loc         = (if ub.doc-line.slt-pc         = ? then 0 else ub.doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = ub.doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = ub.doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = ub.doc-line.obj-code  and
                                      in-vatp-parts.artic     = ub.doc-line.artic     and
                                      in-vatp-parts.prod-type = ub.doc-line.prod-type and
                                      in-vatp-parts.prod-code = ub.doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if ub.doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / ub.doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if ub.doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / ub.doc-line.fact-qnty  else 0
        transport-base-loc  = if ub.doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / ub.doc-line.fact-qnty  else 0
        transport-rubl-loc  = if ub.doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / ub.doc-line.fact-qnty  else 0
        other-base-loc      = if ub.doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / ub.doc-line.fact-qnty  else 0
        other-rubl-loc      = if ub.doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / ub.doc-line.fact-qnty  else 0
                                        vat-base-loc        = if ub.doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / ub.doc-line.fact-qnty   else 0
        slt-base-loc        = if ub.doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / ub.doc-line.fact-qnty   else 0
                vat-rubl-loc        = if ub.doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / ub.doc-line.fact-qnty   else 0
        slt-rubl-loc        = if ub.doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / ub.doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
            assign
                v-VAT       = ( if PrintRubl then vat-rubl-loc      else vat-base-loc )
                v-SLT       = ( if PrintRubl then slt-rubl-loc      else slt-base-loc )
                v-tax-price = ( if PrintRubl then road-tax-rubl-loc else road-tax-base-loc )
            .
            if v-VAT = ?        then assign v-VAT       = 0.
            if v-SLT = ?        then assign v-SLT       = 0.
            if v-tax-price = ?  then assign v-tax-price = 0.
            assign
                    v-price-no-VAT = ( if PrintRubl
                                        then price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - road-tax-rubl-loc
                                        else price-base-with-tax-loc - vat-base-loc - slt-base-loc - road-tax-base-loc)
            .
            if v-r-factur-is-vozvrat-vnesh = yes
            then do:
                assign
                    v-price-no-VAT = v-price-no-VAT
                                    - ( if PrintRubl
                                        then ( transport-rubl-loc + other-rubl-loc )
                                        else ( transport-base-loc + other-base-loc ) )
                .
            end.
        end.
        else do:
            find first ub.gds-dtl no-lock
                 where ub.gds-dtl.doc-code = ub.doc-line.doc-code
                   and ub.gds-dtl.prod-type = ub.doc-line.prod-type
                   and ub.gds-dtl.prod-code = ub.doc-line.prod-code
                   and ub.gds-dtl.artic = ub.doc-line.artic
                   and ub.gds-dtl.prt-code = rootnode_code
            .
            assign
                v-qnty = ub.gds-dtl.fact-qnty
            .
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
find first out-vatp_goods where out-vatp_goods.artic     = ub.doc-line.artic     and
                                   out-vatp_goods.prod-type = ub.doc-line.prod-type and
                                   out-vatp_goods.prod-code = ub.doc-line.prod-code no-lock.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  ub.doc-line.artic
  ,input  ub.doc-line.prod-type
  ,input  ub.doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
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
    "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if ub.doc-line.road-tax = ? then 0 else ub.doc-line.road-tax * 1)
    excise-base-sale      =  (if ub.doc-line.excise   = ? then 0 else ub.doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if ub.doc-line.road-tax = ? then 0 else ub.doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if ub.doc-line.excise   = ? then 0 else ub.doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if ub.doc-line.road-tax = ? then 0 else ub.doc-line.road-tax * 1)
    excise-rubl-sale      = (if ub.doc-line.excise   = ? then 0 else ub.doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if ub.doc-line.road-tax = ? then 0 else ub.doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if ub.doc-line.excise   = ? then 0 else ub.doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
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
       and out-vatp_doc-line.artic      = ub.doc-line.artic
       and out-vatp_doc-line.prod-type  = ub.doc-line.prod-type
       and out-vatp_doc-line.prod-code  = ub.doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = ub.doc-line.artic
                               and out-vatp_parts.prod-type  = ub.doc-line.prod-type
                               and out-vatp_parts.prod-code  = ub.doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc)
  discnt-base-sale            = ub.gds-dtl.discnt-base
  price-base-with-tax-sale    = (ub.gds-dtl.price-base - ub.gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc)
  discnt-rubl-sale            = ub.gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = ub.gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = ub.gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((ub.gds-dtl.price-base - ub.gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * ub.doc-line.cons-vat-pc / (100 + ub.doc-line.cons-vat-pc) * ub.gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((ub.gds-dtl.price-base - ub.gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc) * ub.gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * ub.doc-line.cons-vat-pc / (100 + ub.doc-line.cons-vat-pc) * ub.gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc) * ub.gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((ub.gds-dtl.price-base - ub.gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * ub.doc-line.cons-vat-pc / (100 + ub.doc-line.cons-vat-pc) * ub.gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((ub.gds-dtl.price-base - ub.gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-base - ub.gds-dtl.discnt-base                - road-tax-base-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - varprice-base-cons) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc) * ub.gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * ub.doc-line.cons-vat-pc / (100 + ub.doc-line.cons-vat-pc) * ub.gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl                - road-tax-rubl-sale) * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc) - varprice-rubl-cons) * ub.doc-line.vat-pc / (100 + ub.doc-line.vat-pc) * ub.gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
            assign
                v-VAT       = ( if PrintRubl then vat-rubl-buyer        else vat-base-buyer )
                v-SLT       = ( if PrintRubl then slt-rubl-sale         else slt-base-sale )
                v-tax-price = ( if PrintRubl then road-tax-rubl-sale    else road-tax-base-sale )
            .
            if v-VAT = ?        then assign v-VAT       = 0.
            if v-SLT = ?        then assign v-SLT       = 0.
            if v-tax-price = ?  then assign v-tax-price = 0.
            assign
                v-price-no-VAT = ( if PrintRubl
                                   then price-rubl-with-tax-sale
                                   else price-base-with-tax-sale ) - v-VAT - v-SLT - v-tax-price
            .
        end.
        if p-round = 'round':U
        then do:
                run p-fmt-round in this-procedure (
                      input v-qnty
                    , input v-price-no-VAT
                    , input v-VAT
                    , input v-SLT
                    , input v-tax-price
                    , output v-price-no-VAT
                    , output v-void-decimal
                    , output v-void-decimal
                    , output v-VAT
                    , output v-SLT
                    , output v-tax
                    , output v-sum-no-VAT
                    , output v-void-decimal
                ).
        end.
        else do:
            assign
                v-VAT           = v-VAT * v-qnty
                v-SLT           = v-SLT * v-qnty
                v-sum-no-VAT    = v-price-no-VAT * v-qnty
                v-tax           = v-tax-price * v-qnty
            .
        end.
        assign
            v-sum           = v-sum-no-VAT + v-VAT
        .
        if ub.goods.gds-type = 'у':U
        or PrintScale
        then do:
            display stream Out-stream
                sym1 gds-str1 @ ub.goods.gds-name
                sym2 ( if invers then ub.doc-line.unit-cli else ub.goods.unit-base ) @ ub.goods.unit-base
                sym3 v-qnty
                sym4 v-price-no-VAT
                sym5 v-sum-no-VAT
                sym6 "   ---" format "x(6)" @ v-sum-actciz
                sym7 ub.doc-line.Vat-pc
                sym8 v-VAT
                sym9 v-sum
                sym11 v-country
                sym12
                sym13
            with frame factur .
            down stream Out-stream 1 with frame factur .
            run facturxl-write-line-data in this-procedure (
                  input string( ub.goods.artic, "X(16)" ) + " " + ub.goods.gds-name
                , input "":U
                , input ( if invers then ub.doc-line.unit-cli else ub.goods.unit-base )
                , input string( v-qnty          )
                , input string( v-price-no-VAT  )
                , input string( v-sum-no-VAT    )
                , input "   ---":U
                , input string( ub.doc-line.Vat-pc  )
                , input string( v-VAT            )
                , input string( v-sum            )
                , input v-country
                , input "":U
            ).
            if FullGdsName
            and gds-str1 <> "":U then do :
               run print-more in this-procedure.
            end.
            assign v-lines-counter = v-lines-counter + 1.
        end.
        else do:
            define variable v-first-parts   as logical     no-undo.
            assign
                v-first-parts = yes
            .
            for each ub.parts no-lock
               where ub.parts.out-code  = ub.doc-line.doc-code
                 and ub.parts.obj-type  = ub.doc-line.obj-type
                 and ub.parts.obj-code  = ub.doc-line.obj-code
                 and ub.parts.artic     = ub.doc-line.artic
                 and ub.parts.prod-type = ub.doc-line.prod-type
                 and ub.parts.prod-code = ub.doc-line.prod-code
            :
                assign
                    v-GTD       = ub.parts.cst-code
                    v-prt-qnty  = ub.parts.fact-qnty
                .
                if available ub.country
                and ub.country.alpha1 = "RU":U
                then do:
                    assign
                        v-GTD       = "-":U
                        v-country   = "-":U
                    .
                end.
                find first buf_parts-attr no-lock
                  where buf_parts-attr.in-code   = ub.parts.in-code
                    and buf_parts-attr.gds-code  = ub.goods.gds-code
                    and buf_parts-attr.part-code = ub.parts.part-code
                no-error .
                if available buf_parts-attr
                  and buf_parts-attr.country-code <> 0
                  then do:
                      find first buf_country
                      where buf_country.num-code = buf_parts-attr.country-code
                      no-error.
                      if available buf_country
                      and buf_country.num-code <> ub.country.num-code
                      and buf_country.short-name <> ""
                      then do :
                          assign
                              v-country = buf_country.short-name
                            .
                          if buf_country.alpha1 = "RU":U
                          then do :
                              assign
                                v-country = "-":U
                                v-GTD     = "-":U
                              .
                          end .
                      end.
                end.
                if CostPrice = yes
                then do:
assign
  price-rubl-with-tax-loc = ub.parts.price-rubl
  price-base-with-tax-loc = ub.parts.price-base
.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if ub.parts.out-code = 'free-zone':U     or
     ub.parts.out-code = 'out-zone':U   or
     ub.parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = ub.parts.out-code
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
   price-cli-with-tax-loc = ub.parts.price-cli
   cli-base-rate          = ub.parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if ub.parts.road-tax-base  = ? then 0 else ub.parts.road-tax-base)
           road-tax-rubl-loc  = (if ub.parts.road-tax-rubl  = ? then 0 else ub.parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if ub.parts.transport-base = ? then 0 else ub.parts.transport-base)
          transport-rubl-loc = (if ub.parts.transport-rubl = ? then 0 else ub.parts.transport-rubl)
          other-base-loc     = (if ub.parts.other-base     = ? then 0 else ub.parts.other-base)
          other-rubl-loc     = (if ub.parts.other-rubl     = ? then 0 else ub.parts.other-rubl)
          vat-pc-loc         = (if ub.parts.vat-pc         = ? then 0 else ub.parts.vat-pc)
          slt-pc-loc         = (if ub.parts.slt-pc         = ? then 0 else ub.parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (ub.parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if ub.parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if ub.parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / ub.parts.price-cli .
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
                        v-parts-VAT       = ( if PrintRubl then vat-rubl-loc      else vat-base-loc )
                        v-parts-SLT       = ( if PrintRubl then slt-rubl-loc      else slt-base-loc )
                        v-tax-price       = ( if PrintRubl then road-tax-rubl-loc else road-tax-base-loc )
                    .
                    if v-parts-VAT = ?  then assign v-parts-VAT = 0.
                    if v-parts-SLT = ?  then assign v-parts-SLT = 0.
                    if v-tax-price = ?  then assign v-tax-price = 0.
                    assign
                        v-parts-price-no-VAT    =
                                          ( if PrintRubl
                                          then price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - road-tax-rubl-loc
                                          else price-base-with-tax-loc - vat-base-loc - slt-base-loc - road-tax-base-loc )
                        v-parts-sum             =
                                          ( if PrintRubl
                                          then price-rubl-with-tax-loc
                                          else price-base-with-tax-loc ) * v-prt-qnty
                    .
                    if v-r-factur-is-vozvrat-vnesh = yes
                    then do:
                        assign
                            v-parts-price-no-VAT = v-parts-price-no-VAT
                                            - ( if PrintRubl
                                                then ( transport-rubl-loc + other-rubl-loc )
                                                else ( transport-base-loc + other-base-loc ) )
                            v-parts-sum          = v-parts-sum
                                            - ( ( if PrintRubl
                                                  then ( transport-rubl-loc + other-rubl-loc )
                                                  else ( transport-base-loc + other-base-loc ) ) * v-prt-qnty )
                        .
                    end.
                    if p-round = 'round':U
                    then do:
                        if v-first-parts = yes
                        then do:
                            assign
                                v-first-parts   = no
                                v-sum-no-VAT    = 0
                                v-VAT           = 0
                                v-SLT           = 0
                                v-tax           = 0
                                v-sum           = 0
                            .
                        end.
                        run p-fmt-round in this-procedure (
                              input v-prt-qnty
                            , input v-parts-price-no-VAT
                            , input v-parts-VAT
                            , input v-parts-SLT
                            , input v-tax-price
                            , output v-parts-price-no-VAT
                            , output v-parts-VAT
                            , output v-parts-SLT
                            , output v-sum-VAT
                            , output v-sum-SLT
                            , output v-sum-tax
                            , output v-parts-sum-no-VAT
                            , output v-parts-sum
                        ).
                        assign
                            v-sum-no-VAT    = v-sum-no-VAT  + v-parts-sum-no-VAT
                            v-VAT           = v-VAT         + v-sum-VAT
                            v-SLT           = v-SLT         + v-sum-SLT
                            v-tax           = v-tax         + v-sum-tax
                            v-sum           = v-sum         + v-parts-sum
                        .
                    end.
                    display stream Out-stream
                        sym1 gds-str1                                                           @ ub.goods.gds-name
                        sym2 ( if invers then ub.doc-line.unit-cli else ub.goods.unit-base )          @ ub.goods.unit-base
                        sym3 v-prt-qnty                                                         @ v-qnty
                        sym4 v-parts-price-no-VAT                                               @ v-price-no-VAT
                        sym5 v-parts-price-no-VAT * v-prt-qnty                                  @ v-sum-no-VAT
                        sym6 "   ---" format "x(6)"                                             @ v-sum-actciz
                        sym7 ub.doc-line.Vat-pc
                        sym8 v-parts-VAT * v-prt-qnty  when v-qnty <> 0                         @ v-VAT
                        sym9 v-parts-sum                                                        @ v-sum
                        sym11 v-country
                        sym12 v-GTD
                        sym13
                    with frame factur .
                    down stream Out-stream 1
                    with frame factur .
                    run facturxl-write-line-data in this-procedure (
                          input string( ub.goods.artic, "X(16)" ) + " " + ub.goods.gds-name
                        , input "":U
                        , input ( if invers then ub.doc-line.unit-cli else ub.goods.unit-base )
                        , input string( v-prt-qnty                        )
                        , input string( v-parts-price-no-VAT              )
                        , input string( v-parts-price-no-VAT * v-prt-qnty )
                        , input "   ---":U
                        , input string( ub.doc-line.Vat-pc          )
                        , input ( if v-qnty = 0 then "":U else string( v-parts-VAT * v-prt-qnty ) )
                        , input string( v-parts-sum              )
                        , input v-country
                        , input v-GTD
                    ).
                end.
                else do:
                    display stream Out-stream
                        sym1 gds-str1                                                           @ ub.goods.gds-name
                        sym2 ( if invers then ub.doc-line.unit-cli else ub.goods.unit-base )       @ ub.goods.unit-base
                        sym3 v-prt-qnty                                                         @ v-qnty
                        sym4 v-price-no-VAT
                        sym5 v-price-no-VAT * v-prt-qnty                                        @ v-sum-no-VAT
                        sym6 "   ---" format "x(6)"                                             @ v-sum-actciz
                        sym7 ub.doc-line.Vat-pc
                        sym8 v-VAT / v-qnty * v-prt-qnty when v-qnty <> 0                       @ v-VAT
                        sym9  ( v-price-no-VAT + v-VAT / v-qnty ) * v-prt-qnty when v-qnty <> 0 @ v-sum
                        sym11 v-country
                        sym12 v-GTD
                        sym13
                    with frame factur .
                    down stream Out-stream 1
                    with frame factur .
                    run facturxl-write-line-data in this-procedure (
                          input string( ub.goods.artic, "X(16)" ) + " " + ub.goods.gds-name
                        , input "":U
                        , input ( if invers then ub.doc-line.unit-cli else ub.goods.unit-base )
                        , input string( v-prt-qnty                        )
                        , input string( v-price-no-VAT              )
                        , input string( v-price-no-VAT * v-prt-qnty )
                        , input "   ---":U
                        , input string( ub.doc-line.Vat-pc          )
                        , input ( if v-qnty = 0 then "":U else string( v-VAT / v-qnty * v-prt-qnty ) )
                        , input ( if v-qnty = 0 then "":U else string( ( v-price-no-VAT + v-VAT / v-qnty ) * v-prt-qnty ) )
                        , input v-country
                        , input v-GTD
                    ).
                end.
                if FullGdsName
                and gds-str1 <> "":U then do :
                   run print-more in this-procedure.
                end.
define variable vss-include-info38 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        if hvrdtax (recid(goods))
        then do:
                    run tax-name (  input 'rdt':U
                                , output v-tax-name
                                ).
                    display stream out-stream
                        fill(" ", 19) + v-tax-name @ goods.gds-name
                        v-prt-qnty                                                   @ v-qnty
                            ( if PrintRubl then parts.road-tax-rubl else parts.road-tax-base )
                                                                                    @ v-price-no-VAT
                            ( if PrintRubl then parts.road-tax-rubl * v-prt-qnty
                                           else parts.road-tax-base * v-prt-qnty )
                                                                                    @ v-sum-no-VAT
                        "   ---" format "x(6)"                                      @ v-sum-actciz
                        0                                                           @ v-VAT
                            ( if PrintRubl then parts.road-tax-rubl * v-prt-qnty
                                           else parts.road-tax-base * v-prt-qnty )
                                                                                    @ v-sum
                        sym1 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym11 sym13
                    with frame factur.
                    down stream out-stream 1
                    with frame factur.
                run facturxl-write-line-data in this-procedure (
                      input fill(" ", 19) + v-tax-name
                    , input "  -  ":U
                    , input "":U
                    , input "":U
                    , input string( v-prt-qnty )
                    , input
                                ( if PrintRubl then parts.road-tax-rubl else parts.road-tax-base )
                    , input
                            ( if PrintRubl then parts.road-tax-rubl * v-prt-qnty
                                           else parts.road-tax-base * v-prt-qnty )
                    , input "   ---":U
                    , input "":U
                    , input "0":U
                    , input
                            ( if PrintRubl then parts.road-tax-rubl * v-prt-qnty
                                           else parts.road-tax-base * v-prt-qnty )
                    , input "":U
                    , input "":U
                    , input "":U
                ).
                    assign
                        v-lines-counter = v-lines-counter   + 1
                    .
        end.
        else do:
            if v-tax-price <> 0
            then do:
                message
                  "Значение третьего налога (стеклопосуда) в документе отлично от нуля для товара " + goods.artic
                  + ", хотя для этого товара система не позволяет задать третий налог. Возможны ошибки в накладной"
                view-as alert-box error.
            end.
        end.
                assign v-lines-counter = v-lines-counter + 1.
            end.
        end.
    end.
    assign
        v-tot-sum-no-VAT    = v-tot-sum-no-VAT  + v-sum-no-VAT  + v-tax
        v-tot-VAT           = v-tot-VAT         + v-VAT
        v-tot-SLT           = v-tot-SLT         + v-SLT
        v-tot-tax           = v-tot-tax         + v-tax
        v-tot-sum           = v-tot-sum         + v-sum         + v-tax
    .
end.
end procedure.
procedure print-header :
define input parameter p-doc-code           as character    no-undo.
define output parameter p-curr-abbr         as character    no-undo.
    define variable v-print-doc      as character           no-undo.
    define variable v-par-type       as character           no-undo.
    define variable t-num            as character           no-undo.
    define variable v-obj-prt-on     as logical             no-undo.
    define variable t-inn            as character           no-undo.
    define variable v-plat-rasch-doc as character    no-undo.
    define variable v-curr-name      as character           no-undo.
    define variable v-base-name      as character           no-undo.
    define variable v-base-abbr      as character           no-undo.
    define variable v-rubl-name      as character           no-undo.
    define variable t-currency       as character           no-undo.
    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_currency      for ub.currency.
do
for buf_trn-doc
  , buf_currency
on error undo, return error
:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
    .
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_trn-doc.obj-type
  ,input buf_trn-doc.obj-code
  ,input 'prt-firm':U
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
    if thbjattr_thbj-attr.prop-code = 'factur01' then v-print-doc =  string(thbjattr_thbj-attr.property-value-logical) .
end.
    assign
      p-sf-par = no
    .
    run torgconf-get-form-header in this-procedure (
          input Invers
        , input buf_trn-doc.doc-code
        , input ( v-print-doc = "yes" )
        , input buf_trn-doc.doc-date
        , input buf_trn-doc.fact-date
        , input buf_trn-doc.doc-type
        , input buf_trn-doc.status_
        , input p-reverse
        , input p-sf-par
    ).
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,input  'doc-prt=request'
  ,output v-obj-prt-on
  )  .
    if v-obj-prt-on = no
    or invers
    then do:
        assign
            PrintScale = no
        .
    end.
    find first buf_currency no-lock
         where buf_currency.curr-code = buf_trn-doc.exch-code
    .
    assign
        p-curr-abbr = buf_currency.curr-abbr
        v-curr-name = buf_currency.curr-name
    .
    define variable v-base-code as integer   no-undo .
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output v-base-code
  )  .
    find first buf_currency no-lock
         where buf_currency.curr-code = v-base-code
    .
    assign
        v-base-name = buf_currency.curr-name
        v-base-abbr = buf_currency.curr-abbr
    .
    find first buf_currency no-lock
         where buf_currency.curr-code = 0
    .
    assign
        v-rubl-name = buf_currency.curr-name
    .
    assign
        t-num = substitute( "&1         от &2 &3"
                        , v-torgconf-doc-code
                        , v-torgconf-doc-date
                        , ( if buf_trn-doc.status_ <> 'факт':U
                            then string( "(" + caps( buf_trn-doc.status_ ) + ")" )
                            else "":U )
                )
    .
    assign
        t-inn = substitute( "&1&2&3", v-torgconf-supplier-inn, ( if ((v-torgconf-supplier-kpp = "":U) AND (v-torgconf-supplier-inn = "":U)) then "":U else "/":U ), v-torgconf-supplier-kpp )
    .
    if v-torgconf-outappr = yes
    then do:
      put stream Out-stream
         space(108) "                                                                           Приложение № 1" skip
         space(108) "               к Правилам ведения журналов учета полученных и выставленных счетов-фактур," skip
         space(108) "               книг покупок и книг продаж при расчетах по налогу на добавленную стоимость" skip
         space(108) "                              (в ред. Постановлений Правительства РФ от 15.03.2001 № 189," skip
         space(108) "       от 27.07.2002 № 575, от 16.02.2004 № 84, от 11.05.2006 № 283, от 26.05.2009 № 451)" skip
      .
    END.
    put stream Out-stream
        space(25) string( "СЧЕТ-ФАКТУРА N" + ( if p-round = 'round':U then ":" else " " ) + t-num ) format "X(190)"
        skip(1) space(5) string( "Продавец" + ( if p-round = 'round':U then ":" else " " ) + fill( " ", 31 ) + v-torgconf-supplier-name + IF v-torgconf-supplier-engl-name = "":U THEN "":U ELSE SUBSTITUTE(" (&1)", v-torgconf-supplier-engl-name )) format "X(190)"
        skip    space(5) string( "Адрес"    + ( if p-round = 'round':U then ":" else " " ) + fill( " ", 34 ) + v-torgconf-supplier-addr ) format "X(190)"
        skip    space(5) string( "Идентификационный номер продавца (ИНН/КПП)" + ( if p-round = 'round':U then ":" else " " ) + t-inn ) format "X(190)"
        .
   if LOOKUP( "serv", p-mode ) <> 0 then v-out-name = '---------------------'  .
   else if
   buf_trn-doc.doc-type <> 'при':U
   and ( not invers )
   and buf_trn-doc.office = no
   and v-torgconf-outobj = no
   and v-torgconf-outasend = no
   and v-torgconf-outsend = no
   then v-out-name = "Он же".
   else
   v-out-name =  v-torgconf-cargo-from-sf-value.
   run facturxl-write-cell-data in this-procedure (
        input "h_cargoFrom":U
      , input v-out-name
   ).
   if LENGTH(v-out-name) > 145
      then do:
         put stream Out-stream
            skip    space(5) string( "Грузоотправитель и его адрес"
                                 + ( if p-round = 'round':U then ":" else " " )
                                 + fill( " ", 11 )
                                 + ( if buf_trn-doc.office = yes
                                       then "---"
                                       else SUBSTRING(v-out-name,1,145))) format "X(190)"
            skip    space(45) SUBSTRING(v-out-name,146) format "X(145)" skip
         .
      end.
      else do:
         put stream Out-stream
            skip    space(5) string( "Грузоотправитель и его адрес"
                                    + ( if p-round = 'round':U then ":" else " " )
                                    + fill( " ", 11 )
                                    + ( if buf_trn-doc.office = yes
                                          then "---"
                                          else v-out-name)) format "X(190)" skip
         .
      end.
    run facturxl-write-cell-data in this-procedure (
          input "h_docCode":U
        , input v-torgconf-doc-code
    ).
    run facturxl-write-cell-data in this-procedure (
          input "h_docDate":U
        , input v-torgconf-doc-date
    ).
    run facturxl-write-cell-data in this-procedure (
          input "h_supplier":U
        , input v-torgconf-supplier-name + IF v-torgconf-supplier-engl-name = "":U THEN "":U ELSE SUBSTITUTE(" (&1)", v-torgconf-supplier-engl-name )
    ).
    run facturxl-write-cell-data in this-procedure (
          input "h_supplierAddr":U
        , input v-torgconf-supplier-addr
    ).
    run facturxl-write-cell-data in this-procedure (
          input "h_supplierINN":U
        , input t-inn
    ).
    assign
        t-inn = substitute( "&1&2&3", v-torgconf-saler-inn, ( if v-torgconf-saler-kpp = "":U then "":U else "/":U ), v-torgconf-saler-kpp )
    .
    if lookup( "GreenL", p-mode ) <> 0
    then do:
        assign
            v-plat-rasch-doc    = "":U
        .
    end.
    else do:
        assign
            v-plat-rasch-doc    = " N ":U + ( if p-round = 'round':U then ": ":U else " ":U ) + fill( " ", 6 ) + v-torgconf-plat-rasch-doc
        .
    end.
         if LOOKUP( "serv", p-mode ) <> 0 then v-out-name = '---------------------'  .
         else if     buf_trn-doc.doc-type <> 'при':U
            and buf_trn-doc.doc-type <> 'возврат':U
         then v-out-name =  v-torgconf-consignee.
         else v-out-name =  v-torgconf-cargo-to-value .
         run facturxl-write-cell-data in this-procedure (
               input "h_cargoTo":U
             , input v-out-name
         ).
        if LENGTH(v-out-name) > 145
         then do:
            put stream Out-stream
               space(5) string( "Грузополучатель и его адрес" + ( if p-round = 'round':U then ": " else " " ) + fill( " ", 12 ) + SUBSTRING(v-out-name,1,145))   format "X(190)"
               skip space(45) SUBSTRING(v-out-name, 146) format "X(145)"
            .
         end.
         else do:
            put stream Out-stream
               space(5) string( "Грузополучатель и его адрес" + ( if p-round = 'round':U then ": " else " " ) + fill( " ", 12 ) + v-out-name)   format "X(190)"
            .
         end.
        put stream Out-stream
        skip    space(5) string( "К платежно-расчетному документу" + v-plat-rasch-doc ) format "X(190)"
        skip(1) space(5) string( "Покупатель" + ( if p-round = 'round':U then ":" else " " ) + fill( " ", 29 ) + v-torgconf-saler-name +
                                                if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-saler-code )
                                                else "":U  ) format "X(190)"
        skip    space(5) string( "Адрес" + ( if p-round = 'round':U then ":" else " " ) + fill( " ", 34 ) + v-torgconf-saler-addr ) format "X(190)"
        skip    space(5) string( "Идентификационный номер покупателя (ИНН/КПП)" + ( if p-round = 'round':U then ": " else " " ) + t-inn ) format "X(190)"
        skip    space(5) "Дополнение (условия оплаты по договору (контракту), способ отправления и т.п." format "X(190)"
        skip    space(5) string( fill( "_", 130 ) ) format "X(130)"
        skip
    .
    run facturxl-write-cell-data in this-procedure (
          input "h_platDoc":U
        , input v-torgconf-plat-rasch-doc
    ).
    run facturxl-write-cell-data in this-procedure (
          input "h_saler":U
        , input v-torgconf-saler-name + if v-torgconf-outprncd = yes
                                        then substitute( " (&1)", v-torgconf-saler-code )
                                        else "":U
    ).
    run facturxl-write-cell-data in this-procedure (
          input "h_salerAddr":U
        , input v-torgconf-saler-addr
    ).
    run facturxl-write-cell-data in this-procedure (
          input "h_salerINN":U
        , input t-inn
    ).
    assign
        t-currency = ( trim( ( if invers and buf_trn-doc.doc-type <> 'при':U then v-curr-name else ( if PrintRubl then v-rubl-name else v-base-name  ) ) ) + "." )
    .
    run facturxl-write-cell-data in this-procedure (
          input "h_currency":U
        , input t-currency
    ).
    if buf_trn-doc.ext-doc-type = 'ep':U
    then do:
        put stream Out-stream
            space(10) "Возврат товара поставщику." format "X(120)" skip
        .
    end.
    if v-torgconf-outrubl = no
    then do:
        put stream Out-stream
            space(10)
                string( "Валюта : " +
                trim( ( if invers and buf_trn-doc.doc-type <> 'при':U then v-curr-name else ( if PrintRubl then v-rubl-name else v-base-name  ) ) ) + "." ) format "X(120)"
        .
    end.
    if v-torgconf-outprim = no
    then do:
        put stream Out-stream
            skip space(10)
            ( if not( buf_trn-doc.PS begins "@" )
            then string( "Примечание : " + substr( buf_trn-doc.PS, 1, 120 ) )
            else ""
            ) format "X(120)"
        .
    end.
    put stream Out-stream
        skip
    .
end.
end procedure.
procedure print-footer :
define variable v-base-code as integer     no-undo .
define variable v-base-abbr as character   no-undo .
define buffer buf_currency      for ub.currency.
do
on error undo, return error
:
    put stream Out-stream
        v-single-line format "X(198)"
    .
    if line-counter( Out-stream ) + 10 > page-size( Out-stream )
    then do:
        page stream Out-stream.
    end.
    run facturxl-write-cell-data in this-procedure (
          input "it_SumNoVAT":U
        , input string( v-tot-sum-no-VAT )
    ).
    run facturxl-write-cell-data in this-procedure (
          input "it_VATsum":U
        , input string( v-tot-VAT )
    ).
    run facturxl-write-cell-data in this-procedure (
          input "it_sum":U
        , input string( v-tot-sum )
    ).
    display stream Out-stream
        "Всего" @ ub.goods.gds-name
        v-tot-sum-no-VAT  @ v-sum-no-VAT
        v-tot-VAT         @ v-VAT
        v-tot-sum         @ v-sum
    with frame factur .
    down stream Out-stream 2 with frame factur .
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output v-base-code
  )  .
    find first buf_currency no-lock
         where buf_currency.curr-code = v-base-code
    .
    assign
        v-base-abbr = buf_currency.curr-abbr
    .
    if abs( v-tot-SLT ) >= 0.005
    or ( not invers and abs( buf_trn-doc.discnt-rubl ) >= 0.005 )
    then do:
        put stream Out-stream
            space(5) "Итого по документу: "
            trim( string( v-tot-sum, "->,>>>,>>>,>>>,>>>,>>9.99" ) )
            + " ("
            + trim( ( if invers and buf_trn-doc.doc-type <> 'при':U then v-curr-abbr else ( if PrintRubl then "РУБ" else v-base-abbr ) ) )
            + ")"
                                                                        format "X(120)"     at 40
        .
        if v-tot-SLT <> 0 and p-no-slt = false
        then do:
            put stream Out-stream
                skip space(10) "Налог с продаж: "
                        trim( string( v-tot-SLT, "->>>,>>9.99" ) )
                        + " ("
                        + trim( ( if PrintRubl then "РУБ" else v-base-abbr ) )
                        + ")"
                                                                        format "X(150)"     at 40
            .
        end.
        if buf_trn-doc.discnt-rubl <> 0
        and not invers
        and v-torgconf-outdisc = no
        then do:
            put stream Out-stream
                skip space(14) "Скидка:"
                        trim( string( ( if PrintRubl
                                        then buf_trn-doc.discnt-rubl
                                        else buf_trn-doc.tot-calc ), "->>>,>>>,>>>,>>9.99" ) )
                        + " ("
                        + trim( ( if PrintRubl then "РУБ" else v-base-abbr ) )
                        + ")"
                                                                        format "X(150)"     at 40
            .
        end.
    end.
    if v-tot-tax <> 0
    then do:
        put stream Out-stream
            skip space(10)  v-tax-name + ": "                                   format "X(20)"
                trim( string( v-tot-tax, "->>>,>>>,>>>,>>9.99" ) )
                + " ("
                + trim( ( if invers and buf_trn-doc.doc-type <> 'при':U then v-curr-abbr else ( if PrintRubl then "РУБ" else v-base-abbr ) ) )
                + ")"
                                                                        format "X(150)"     at 40
        .
    end.
    put stream Out-stream
        skip space(5) "Итого к оплате: "
                        string( trim( string( v-tot-sum + v-tot-SLT, "->,>>>,>>>,>>>,>>>,>>9.99" ) )
                        + " ("
                        + trim( ( if invers and buf_trn-doc.doc-type <> 'при':U then v-curr-abbr else ( if PrintRubl then "РУБ" else v-base-abbr ) ) )
                        + ")" )
                                                                        format "X(150)"     at 40
    .
    if PrintRubl
    and v-torgconf-outprops = yes
    then do:
        run rep/wp-rub.p (
            input v-tot-sum + v-tot-SLT
            , output v-propis
            , output v-propis-cop
        ).
        put stream out-stream
            skip space(25) v-propis
                                                                            format "X(150)"  at 40
            skip(1)
        .
        run facturxl-write-cell-data in this-procedure (
              input "h_summ_prop":U
            , input v-propis
        ).
    end.
    if v-torgconf-outsubs = no
    then do:
        run facturxl-write-cell-data in this-procedure (
              input "f_bossName":U
            , input v-torgconf-main-boss
        ).
        run facturxl-write-cell-data in this-procedure (
              input "f_buhName":U
            , input v-torgconf-main-buh
        ).
    end.
    if v-torgconf-outsubs = no
    and trim(v-torgconf-main-boss) = "":U
    or v-torgconf-outsubs = yes
      then do:
            v-torgconf-main-boss = fill( "_", 36 ).
      end.
    if v-torgconf-outsubs = no
    and trim(v-torgconf-main-buh) = "":U
    or v-torgconf-outsubs = yes
      then do:
         v-torgconf-main-buh = fill( "_", 36 ).
      end.
        put stream Out-stream
            skip(2) space(10) "Руководитель организации   " format "X(28)" fill( "_", 26 ) format "X(26)" "    /" v-torgconf-main-boss format "X(36)" "/"
            "      Главный бухгалтер   " format "X(25)"fill( "_", 26 ) format "X(26)" "    /" v-torgconf-main-buh format "X(36)" "/"
            skip space(45) "(подпись)" space(30) "(Ф.И.О)"  space(47) "(подпись)" space(30) "(Ф.И.О)"
        .
    if v-torgconf-outegrp = no
    then do :
      if trim(v-torgconf-self-host-name) = "":U
      then do:
          v-torgconf-self-host-name = fill("_", 42).
      end.
      if v-torgconf-self-host-egrip-date <> "":U
       or v-torgconf-self-host-egrip-num  <> "":U
       then do:
          put stream Out-stream
              skip (1) space(10) substitute( "Индивидуальный предприниматель   &1  / &2 / ЕГРИП N &3 от &4 ", fill( "_", 26 ) , string(v-torgconf-self-host-name, "x(42)") , v-torgconf-self-host-egrip-num, v-torgconf-self-host-egrip-date ) format "X(174)"
              skip     space(51) "(подпись)"  space(29) "(Ф.И.О)" space(22) "(реквизиты свидетельства о государственной"
              skip     space(119) substitute( "регистрации индивидуального предпринимателя)" ) format "X(90)"
              skip
          .
          run facturxl-write-cell-data in this-procedure (
                input "f_ownerName":U
              , input v-torgconf-self-host-name
          ).
          run facturxl-write-cell-data in this-procedure (
              input "f_ownerReg":U
            , input substitute ("N &1 от &2 ", v-torgconf-self-host-egrip-num, v-torgconf-self-host-egrip-date )
          ).
      end.
      else do :
          put stream Out-stream
              skip (1) space(10) substitute( "Индивидуальный предприниматель   &1  / &2 /  &3  ", fill( "_", 26 ) , fill("_", 42) , fill( "_", 50 ) ) format "X(174)"
              skip     space(51) "(подпись)"  space(29) "(Ф.И.О)" space(22) "(реквизиты свидетельства о государственной"
              skip     space(119) substitute( "регистрации индивидуального предпринимателя)" ) format "X(90)"
              skip
          .
      end.
    end.
    put stream Out-stream  skip "Примечание. Первый экземпляр - покупателю, второй экземпляр - продавцу"   format "X(90)"
    .
end.
end procedure.
