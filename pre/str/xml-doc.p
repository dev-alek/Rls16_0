block-level on error undo, throw.
define input parameter pardoc-code    like ub.trn-doc.doc-code no-undo.
define input parameter paroutput-file as   character           no-undo.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: xml-doc.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/xml-doc.p $":U .
define variable vss-description as character no-undo initial "Выгрузка документа в формате xml":U .
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function xml-doc_replacespecsymbols returns char (input sinput as char).
  assign
    sinput = replace(sinput, '&', "&#038;")
    sinput = replace(sinput, '"', "&#034;")
    sinput = replace(sinput, '<', "&#060;")
    sinput = replace(sinput, '>', "&#062;")
    sinput = replace(sinput, chr(10), "&#010;")
  .
  return sinput.
end function.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info1 as character format "X(65)" no-undo
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable varr-b   as character no-undo.
define variable vartype  as character no-undo.
define variable varshift as character no-undo.
define variable varfile-name as character no-undo.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-trn-doc no-undo
field DocCode                like ub.trn-doc.doc-code
field ExtDocType             like ub.trn-doc.ext-doc-type
field ExtDocTypeName         as   character
field DocType                like ub.trn-doc.doc-type
field Internal               like ub.trn-doc.internal
field Sts                    like ub.trn-doc.status_
field Flag                   like ub.trn-doc.flag_
field DocDate                like ub.trn-doc.doc-date
field ContractId             like ub.trn-doc.contract-code
field ContractNum            like ub.contract.contract-prn-code
field ContractDate           like ub.contract.contract-date
field SupplCrcCode           like ub.trn-doc.exch-code
field SupplCrcAbbr           like ub.currency.curr-abbr
field SupplCrcName           like ub.currency.curr-name
field SupplCrcDate           like ub.trn-doc.exch-date
field SupplCrcRate           like ub.trn-doc.exch-rate
field SupplCrcScale          like ub.trn-doc.exch-scale
field BaseCrcRate            like ub.trn-doc.base-rate
field BaseCrcScale           like ub.trn-doc.base-scale
field CliType                like ub.trn-doc.cli-type
field CliCode                like ub.trn-doc.cli-code
field CliName                like ub.trn-doc.cli-name
field PostIndex              like ub.firm.ind
field City                   like ub.firm.city
field Address                like ub.firm.addres1
field AddressAdd             like ub.firm.addres2
field PostAddress            like ub.firm.post-addr1
field PostAddressAdd         like ub.firm.post-addr2
field EMail                  like ub.firm.e-mail
field Fax                    like ub.firm.fax
field Phone                  like ub.firm.phone
field PhoneNote              like ub.firm.phone1-note
field Inn                    like ub.firm.inn
field KPP                    like ub.firm.kpp
field OKPO                   like ub.firm.okpo
field OKONH                  like ub.firm.okonh
field ContactPerson          like ub.firm.contact-psn
field Director               like ub.firm.director
field EnglName               like ub.firm.engl-name
field GenAccnt               like ub.firm.gen-acct
field Telex                  like ub.firm.telex
field Name                   like ub.person.name1
field Patronymic             like ub.person.name2
field PassNum                like ub.person.passp-num
field PassSer                like ub.person.passp-ser
field GivenBy                like ub.person.given-by
field Position               like ub.person.position
field PostBox                like ub.person.post-box
field BankNameRubl           as   character
field BankCodeRubl           as   character
field BankAccRubl            as   character
field AddressBankRubl        as   character
field AddressAddBankRubl     as   character
field PBankAccRubl           as   character
field BankNameBase           as   character
field BankCodeBase           as   character
field BankAccBase            as   character
field AddressBankBase        as   character
field AddressAddBankBase     as   character
field PBankAccBase           as   character
field ObjType                like ub.trn-doc.obj-type
field ObjCode                like ub.trn-doc.obj-code
field ObjName                like ub.clients.obj-name
field OutCode                like ub.trn-doc.out-code
field ShipNum                like ub.trn-doc.ship-num
field ShipDate               like ub.trn-doc.ship-date
field OrdNum                 like ub.trn-doc.ord-num
field Office                 like ub.trn-doc.office
field FactDate               like ub.trn-doc.fact-date
field FactNum                like ub.trn-doc.fact-num
field FactOrder              like ub.trn-doc.fact-order
field FactQnty               like ub.trn-doc.fact-qnty
field DocQnty                like ub.trn-doc.doc-qnty
field BefQnty                like ub.trn-doc.doc-qnty
field CalcSum                as   character
field SumCheckFactSuppl      like ub.trn-doc.tot-cli
field SumFactBaseAcc         like ub.trn-doc.fact-base
field SumFactRublAcc         like ub.trn-doc.fact-rubl
field SumFactSuppl           like ub.trn-doc.tot-calc
field SumBefBaseAcc          like ub.trn-doc.tot-calc
field DscFactBaseDoc         like ub.trn-doc.tot-calc
field VatType                like ub.trn-doc.vat-type
field VatFactBaseAcc         like ub.trn-doc.vat-base
field VatFactBaseDoc         like ub.trn-doc.vat-base
field VatFactRublAcc         like ub.trn-doc.vat-rubl
field VatFactRublDoc         like ub.trn-doc.vat-rubl
field SltType                like ub.trn-doc.slt-type
field SltFactBaseAcc         like ub.trn-doc.slt-base
field SltFactBaseDoc         like ub.trn-doc.slt-base
field SltFactRublAcc         like ub.trn-doc.slt-rubl
field SltFactRublDoc         like ub.trn-doc.slt-rubl
field SumDocBaseAcc          like ub.trn-doc.fact-base
field SumDocBaseDoc          like ub.trn-doc.tot-doc
field SumDocRublAcc          like ub.trn-doc.fact-base
field SumDocRublDoc          like ub.trn-doc.tot-rubl
field SumFactBaseDoc         like ub.trn-doc.tot-fact
field SumFactRublDoc         like ub.trn-doc.tot-sale
field DscFactRublDoc         like ub.trn-doc.discnt-rubl
field SumBefRublAcc          like ub.trn-doc.discnt-rubl
field OvervalueFactSaleacc   like ub.trn-doc.tot-ov
field OvervalueFactSaledoc   like ub.trn-doc.tot-ov
field TaxThreeFactSaleAcc        like ub.trn-doc.road-tax
field ExciseFactSaleAcc      like ub.trn-doc.excise
field TransportExpSuppl      like ub.trn-doc.tot-transp
field OtherExpSuppl          like ub.trn-doc.tot-other
field ExtraQnty              like ub.trn-doc-sum.fact-qnty
field ExtraSupplQnty         like ub.trn-doc-sum.fact-qnty
field ExtraFactBaseAcc       like ub.trn-doc-sum.cost-sum-base
field ExtraFactRublAcc       like ub.trn-doc-sum.cost-sum-rubl
field ExtraFactSale          like ub.trn-doc-sum.sale-sum-base
field MissQnty               like ub.trn-doc-sum.fact-qnty
field MissCliQnty            like ub.trn-doc-sum.fact-qnty
field MissFactBaseAcc        like ub.trn-doc-sum.cost-sum-base
field MissFactRublAcc        like ub.trn-doc-sum.cost-sum-rubl
field MissFactSale           like ub.trn-doc-sum.sale-sum-base
field WastageFactSale        like ub.trn-doc-sum.sale-sum-base
field BefSupplQnty           like ub.trn-doc-sum.fact-qnty
field AftSupplQnty           like ub.trn-doc-sum.fact-qnty
field Wrkr                   as   character
field Agnt                   as   character
field Boss                   as   character
field InvNum                 like ub.trn-doc.inv-num
field PayCode                like ub.trn-doc.pay-code
field DiscntType             like ub.trn-doc.discnt-type
field DiscntPc               like ub.trn-doc.discnt-pc
field Creid                  like ub.trn-doc.creid
field PrintRubl              like ub.trn-doc.print-rubl
field PS                     like ub.trn-doc.PS
field Ov                     like ub.trn-doc.ov
field HostCode               like ub.trn-doc.host-code
field HostName               like ub.clients.obj-name
field BgeDate                like ub.trn-doc.bge-date
field TotLines               like ub.trn-doc.tot-lines
field CstCode                like ub.trn-doc.cst-code
field FactTime               like ub.trn-doc.fact-time
field ShiftName              like ub.trn-doc.shift-name
field ShiftNum               like ub.trn-doc.shift-num
field ShiftDate              like ub.trn-doc.shift-date
field RetSupp                like ub.trn-doc.ret-supp
field SupplQnty              like ub.trn-doc.cli-qnty
field SctDate                like ub.trn-doc.scf-date
field AccDate                like ub.trn-doc.acc-date
field BankRublIsHave         as   logical
field BankBaseIsHave         as   logical
field ExpenseOwn             as   decimal
field RsrvDate               like ub.trn-doc.rsrv-date
field RsrvTerm               as   integer
field ReasonCode             as   integer
index pi is unique primary DocCode
.
define temp-table tt-trn-doc-add no-undo
field DocCode                like ub.trn-doc.doc-code
field AcctObj                like ub.shop.acct
field AddressObj             like ub.shop.addres1
field AddressAddObj          like ub.shop.addres2
field DirectorObj            like ub.shop.director
field GoodsManObj            like ub.shop.goods-man
field PhoneObj               like ub.shop.phone
field StoreBossObj           like ub.shop.store-boss
field StoreManObj            like ub.shop.store-man
field PostIndexOwn           like ub.firm.ind
field CityOwn                like ub.firm.city
field AddressOwn             like ub.firm.addres1
field AddressAddOwn          like ub.firm.addres2
field PostAddressOwn         like ub.firm.post-addr1
field PostAddressAddOwn      like ub.firm.post-addr2
field EMailOwn               like ub.firm.e-mail
field FaxOwn                 like ub.firm.fax
field PhoneOwn               like ub.firm.phone
field PhoneNoteOwn           like ub.firm.phone1-note
field InnOwn                 like ub.firm.inn
field KPPOwn                 like ub.firm.kpp
field OKPOOwn                like ub.firm.okpo
field OKONHOwn               like ub.firm.okonh
field ContactPersonOwn       like ub.firm.contact-psn
field DirectorOwn            like ub.firm.director
field EnglNameOwn            like ub.firm.engl-name
field GenAccntOwn            like ub.sysconf.snr-accnt
field TelexOwn               like ub.firm.telex
field BankNameRublOwn        as character
field BankCodeRublOwn        as character
field BankAccRublOwn         as character
field AddressBankRublOwn     as character
field AddressAddBankRublOwn  as character
field PBankAccRublOwn        as character
field BankNameBaseOwn        as character
field BankCodeBaseOwn        as character
field BankAccBaseOwn         as character
field AddressBankBaseOwn     as character
field AddressAddBankBaseOwn  as character
field PBankAccBaseOwn        as character
field KOPFOwn                like ub.sysconf.kopf
field SOEIOwn                like ub.sysconf.soei
field BranchOwn              like ub.sysconf.branch
field PropertyOwn            like ub.sysconf.property
field OwnBankRublIsHave      as   logical
field OwnBankBaseIsHave      as   logical
index pi is unique primary DocCode
.
define temp-table tt-doc-line no-undo
field DocCode            like ub.doc-line.doc-code
field Artic              like ub.doc-line.artic
field ProdType           like ub.doc-line.prod-type
field ProdCode           like ub.doc-line.prod-code
field GdsCode            like ub.goods.gds-code
field ProdName           like ub.clients.obj-name
field GdsName            like ub.goods.gds-name
field EnglName           like ub.goods.engl-name
field LabelName          like ub.goods.label-name
field GrpCode            like ub.gds-grp.node-code
field GrpFullName        as   character
field GrpName            like ub.gds-grp.node-name
field UnitBase           like ub.goods.unit-base
field ObjType            like ub.doc-line.obj-type
field ObjCode            like ub.doc-line.obj-code
field ObjName            like ub.clients.obj-name
field ExtDocType         like ub.doc-line.ext-doc-type
field FactOrder          like ub.doc-line.fact-order
field Sts                like ub.doc-line.status_
field SupplQnty          like ub.doc-line.cli-qnty
field SupplRate          like ub.doc-line.cli-base-rate
field DocQnty            like ub.doc-line.doc-qnty
field FactQnty           like ub.doc-line.fact-qnty
field BeforeKgQnty       like ub.inv-line.wast-cli-qnty
field FactKgQnty         like ub.inv-line.wast-cli-qnty
field AfterKgQnty        like ub.inv-line.wast-cli-qnty
field PriceAvrgRubl      like ub.doc-line.price-rubl
field PriceAvrgBase      like ub.doc-line.price-base
field PriceAvrgSuppl     like ub.doc-line.price-cli
field UnitSuppl          like ub.doc-line.unit-cli
field VatPcAcc           like ub.doc-line.vat-pc
field VatPcDoc           like ub.doc-line.vat-pc
field PrtOk              like ub.doc-line.prt-ok
field PrtRoot            like ub.doc-line.prt-root
field SltPcAcc           like ub.doc-line.slt-pc
field SltPcDoc           like ub.doc-line.slt-pc
field LineNum            like ub.doc-line.line-num
field WtBrutto           like ub.doc-line.wt-brutto
field NumPlace           like ub.doc-line.num-place
field TaxThreeSupplSale  like ub.doc-line.road-tax
field TaxThreeDocSale    like ub.doc-line.road-tax
field ExciseDocSale      like ub.doc-line.excise
field Density            like ub.doc-line.fact-density
field Temperature        like ub.doc-line.temperature
field TransportBase      like ub.doc-line.transport-base
field TransportRubl      like ub.doc-line.transport-rubl
field OtherBase          like ub.doc-line.other-base
field OtherRubl          like ub.doc-line.other-rubl
field BeforeQnty         like ub.doc-line-sum.fact-qnty
field BeforeBaseAcc      like ub.doc-line-sum.cost-sum-base
field BeforeRublAcc      like ub.doc-line-sum.cost-sum-rubl
field BeforeSale         like ub.doc-line-sum.sale-sum-base
field AfterQnty          like ub.doc-line.doc-qnty
field AfterBaseAcc       like ub.doc-line-sum.cost-sum-base
field AfterRublAcc       like ub.doc-line-sum.cost-sum-rubl
field AfterSale          like ub.doc-line-sum.sale-sum-base
field ExtraQnty          like ub.doc-line-sum.fact-qnty
field ExtraBaseAcc       like ub.doc-line-sum.cost-sum-base
field ExtraRublAcc       like ub.doc-line-sum.cost-sum-rubl
field ExtraSale          like ub.doc-line-sum.sale-sum-base
field MissQnty           like ub.doc-line-sum.fact-qnty
field MissBaseAcc        like ub.doc-line-sum.cost-sum-base
field MissRublAcc        like ub.doc-line-sum.cost-sum-rubl
field MissSale           like ub.doc-line-sum.sale-sum-base
field WastageSale        like ub.doc-line-sum.sale-sum-base
field BeforeCliQnty      like ub.doc-line-sum.fact-qnty
field AfterCliQnty       like ub.doc-line-sum.fact-qnty
field ExtraCliQnty       like ub.doc-line-sum.fact-qnty
field MissCliQnty        like ub.doc-line-sum.fact-qnty
field SumSignBaseAcc               like ub.ot-line.sum-base
field SumSignRublAcc               like ub.ot-line.sum-rubl
field SumSignVatBaseAcc            like ub.ot-line.vat-base
field SumSignVatRublAcc            like ub.ot-line.vat-rubl
field SumSignSltBaseAcc            like ub.ot-line.slt-base
field SumSignSltRublAcc            like ub.ot-line.slt-rubl
field SumSignTaxThreeBaseAcc           like ub.ot-line.road-tax-base
field SumSignTaxThreeRublAcc           like ub.ot-line.road-tax-rubl
field SumSignTransportBaseAcc      like ub.ot-line.transport-base
field SumSignTransportRublAcc      like ub.ot-line.transport-rubl
field SumSignOtherBaseAcc          like ub.ot-line.other-base
field SumSignOtherRublAcc          like ub.ot-line.other-rubl
field SumSignExciseBaseAcc         like ub.ot-line.excise-base
field SumSignExciseRublAcc         like ub.ot-line.excise-rubl
field SumSignBaseDoc               like ub.ot-line.sum-base
field SumSignRublDoc               like ub.ot-line.sum-rubl
field SumSignVatBaseDoc            like ub.ot-line.vat-base
field SumSignVatRublDoc            like ub.ot-line.vat-rubl
field SumSignSltBaseDoc            like ub.ot-line.slt-base
field SumSignSltRublDoc            like ub.ot-line.slt-rubl
field SumSignTaxThreeBaseDoc           like ub.ot-line.road-tax-base
field SumSignTaxThreeRublDoc           like ub.ot-line.road-tax-rubl
field SumSignTransportBaseDoc      like ub.ot-line.transport-base
field SumSignTransportRublDoc      like ub.ot-line.transport-rubl
field SumSignOtherBaseDoc          like ub.ot-line.other-base
field SumSignOtherRublDoc          like ub.ot-line.other-rubl
field SumSignExciseBaseDoc         like ub.ot-line.excise-base
field SumSignExciseRublDoc         like ub.ot-line.excise-rubl
field CarNum                       like ub.doc-line-attr.attr-value
field CarVol                       like ub.doc-line-attr.attr-value
field Tests                        like ub.doc-line-attr.attr-value
field AutoentObjType               like ub.doc-line-attr.attr-value
field AutoentObjCode               like ub.doc-line-attr.attr-value
field ItemPour                     like ub.doc-line-attr.attr-value
field TimePour                     like ub.doc-line-attr.attr-value
field TankVol                      like ub.doc-line-attr.attr-value
field TankTemp                     like ub.doc-line-attr.attr-value
field TankWater                    like ub.doc-line-attr.attr-value
field TankDensity                  like ub.doc-line-attr.attr-value
field TankWeight                   like ub.doc-line-attr.attr-value
field TimeIncome                   like ub.doc-line-attr.attr-value
index pi is unique primary DocCode Artic ProdType ProdCode
index LineNum LineNum
.
define temp-table tt-barcode no-undo
field DocCode as character
field GdsCode as integer
field BarCode as character
index pi
DocCode
GdsCode
BarCode
.
define temp-table tt-gds-dtl no-undo
field DocCode            like ub.gds-dtl.doc-code
field ExtDocType         like ub.trn-doc.ext-doc-type
field Artic              like ub.gds-dtl.artic
field ProdType           like ub.gds-dtl.prod-type
field ProdCode           like ub.gds-dtl.prod-code
field GdsCode            like ub.goods.gds-code
field BarCodeUnitBase    like ub.bar-code.b-code
field ProdName           like ub.clients.obj-name
field GdsName            like ub.goods.gds-name
field PrtCode            like ub.gds-dtl.prt-code
field FullPrtName        like ub.gds-prt.f-name
field ObjType            like ub.gds-dtl.obj-type
field ObjCode            like ub.gds-dtl.obj-code
field ObjName            like ub.clients.obj-name
field FactQnty           like ub.gds-dtl.fact-qnty
field AfterQnty          like ub.gds-dtl.fact-qnty
field DocQnty            like ub.gds-dtl.doc-qnty
field PriceRublDoc       like ub.gds-dtl.price-rubl
field PriceBaseDoc       like ub.gds-dtl.price-base
field DiscntRublDoc      like ub.gds-dtl.discnt-rubl
field DiscntBaseDoc      like ub.gds-dtl.discnt-base
field DiscntType         like ub.gds-dtl.discnt-type
field DiscntPc           like ub.gds-dtl.discnt-pc
field PriceBaseSale      like ub.gds-dtl.cur-base
field Ov                 like ub.gds-dtl.ov
index pi is unique primary DocCode Artic ProdType ProdCode PrtCode
.
define temp-table tt-parts no-undo
field ObjType                like ub.parts.obj-type
field ObjCode                like ub.parts.obj-code
field ObjName                like ub.clients.obj-name
field ContractId             like ub.trn-doc.contract-code
field ContractNum            like ub.contract.contract-prn-code
field ContractDate           like ub.contract.contract-date
field Artic                  like ub.parts.artic
field ProdType               like ub.parts.prod-type
field ProdCode               like ub.parts.prod-code
field GdsCode                like ub.goods.gds-code
field ProdName               like ub.clients.obj-name
field GdsName                like ub.goods.gds-name
field InCode                 like ub.parts.in-code
field OutCode                like ub.parts.out-code
field ExtDocType             like ub.trn-doc.ext-doc-type
field CountryAlphaOne        like ub.goods.alpha1
field CountryAlphaTwo        like ub.country.alpha2
field CountryNumCode         like ub.country.num-code
field CountryLongName        like ub.country.long-name
field CountryShortName       like ub.country.long-name
field PartCode               like ub.parts.part-code
field Sign                   as   integer
field DocQnty                like ub.parts.qnty
field PriceBaseAcc           like ub.parts.price-base
field PriceRublAcc           like ub.parts.price-rubl
field FactDate               like ub.parts.fact-date
field FactNum                like ub.parts.fact-num
field Sts                    like ub.parts.status_
field VatPcAcc               like ub.parts.VAT-pc
field Ps                     like ub.parts.PS
field PayCode                like ub.parts.pay-code
field FactQnty               like ub.parts.fact-qnty
field SupplType              like ub.parts.supp-type
field SupplCode              like ub.parts.supp-code
field SupplName              like ub.clients.obj-name
field RsrvFree               like ub.parts.rsrv-free
field DocType                like ub.parts.doc-type
field SupplQnty              like ub.parts.cli-qnty
field PlCode                 like ub.parts.pl-code
field VatType                like ub.parts.VAT-type
field SupplCrcCode           like ub.parts.exch-code
field SupplCrcAbbr           like ub.currency.curr-abbr
field SupplCrcName           like ub.currency.curr-name
field PriceSuppl             like ub.parts.price-cli
field SupplRate              like ub.parts.cli-base-rate
field SltPcAcc               like ub.parts.SLT-pc
field HostCode               like ub.parts.host-code
field IsSupp                 like ub.parts.is-supp
field RealQnty               like ub.parts.real-qnty
field SltType                like ub.parts.SLT-type
field CstCode                like ub.parts.cst-code
field LastDate               like ub.parts.last-date
field TaxThreeBaseAcc        like ub.parts.road-tax-base
field TaxThreeRublAcc        like ub.parts.road-tax-rubl
field TransportBaseAcc       like ub.parts.transport-base
field TransportRublAcc       like ub.parts.transport-rubl
field OtherBaseAcc           like ub.parts.other-base
field OtherRublAcc           like ub.parts.other-rubl
field VatBaseAcc             like ub.doc-line.price-base
field VatRublAcc             like ub.doc-line.price-rubl
field SltBaseAcc             like ub.doc-line.price-base
field SltRublAcc             like ub.doc-line.price-rubl
index pi is primary unique
ObjType
ObjCode
Artic
ProdType
ProdCode
InCode
OutCode
PartCode
.
define temp-table tt-attr no-undo
field DocCode                 like ub.trn-doc.doc-code
field attr-code               like ub.doc-attr.attr-code
field attr-value              like ub.doc-attr.attr-value
field attr-type               as character
index pi is unique primary DocCode attr-code
.
define variable v-own-rubl-fmtcli-schet-exists  as logical   no-undo.
define variable v-own-rubl-fmtcli-bank-r-schet  as character no-undo.
define variable v-own-rubl-fmtcli-bank-c-schet  as character no-undo.
define variable v-own-rubl-fmtcli-bank-bik      as character no-undo.
define variable v-own-rubl-fmtcli-bank-name     as character no-undo.
define variable v-own-rubl-fmtcli-bank-addres   as character no-undo.
define variable v-own-base-fmtcli-schet-exists  as logical   no-undo.
define variable v-own-base-fmtcli-bank-r-schet  as character no-undo.
define variable v-own-base-fmtcli-bank-c-schet  as character no-undo.
define variable v-own-base-fmtcli-bank-bik      as character no-undo.
define variable v-own-base-fmtcli-bank-name     as character no-undo.
define variable v-own-base-fmtcli-bank-addres   as character no-undo.
define variable v-cli-rubl-fmtcli-schet-exists  as logical   no-undo.
define variable v-cli-rubl-fmtcli-bank-r-schet  as character no-undo.
define variable v-cli-rubl-fmtcli-bank-c-schet  as character no-undo.
define variable v-cli-rubl-fmtcli-bank-bik      as character no-undo.
define variable v-cli-rubl-fmtcli-bank-name     as character no-undo.
define variable v-cli-rubl-fmtcli-bank-addres   as character no-undo.
define variable v-cli-base-fmtcli-schet-exists  as logical   no-undo.
define variable v-cli-base-fmtcli-bank-r-schet  as character no-undo.
define variable v-cli-base-fmtcli-bank-c-schet  as character no-undo.
define variable v-cli-base-fmtcli-bank-bik      as character no-undo.
define variable v-cli-base-fmtcli-bank-name     as character no-undo.
define variable v-cli-base-fmtcli-bank-addres   as character no-undo.
define variable v-before-qnty                   as decimal   no-undo.
define variable v-fact-qnty                     as decimal   no-undo.
define variable v-abs-fact-qnty                 as decimal   no-undo.
define variable v-after-qnty                    as decimal   no-undo.
define variable v-sort as integer   no-undo .
procedure xml-doc_clear-doc :
  define buffer bf_tt-trn-doc     for tt-trn-doc .
  define buffer bf_tt-trn-doc-add for tt-trn-doc-add.
  do
  on error undo, return error return-value
  :
    for each bf_tt-trn-doc
    on error undo, return error return-value
    :
      delete bf_tt-trn-doc .
    end.
    for each bf_tt-trn-doc-add
    on error undo, return error return-value
    :
      delete bf_tt-trn-doc-add .
    end.
  end.
end procedure.
procedure xml-doc_clear-line :
  define buffer bf_tt-doc-line for tt-doc-line.
  define buffer bf_tt-barcode for tt-barcode.
  do
  on error undo, return error return-value
  :
    for each bf_tt-doc-line
    on error undo, return error return-value
    :
      delete bf_tt-doc-line .
    end.
    for each bf_tt-barcode
    on error undo, return error return-value
    :
      delete bf_tt-barcode .
    end.
  end.
end procedure.
procedure xml-doc_clear-dtl :
  define buffer bf_tt-gds-dtl  for tt-gds-dtl.
  do
  on error undo, return error return-value
  :
    for each bf_tt-gds-dtl
    on error undo, return error return-value
    :
      delete bf_tt-gds-dtl .
    end.
  end.
end procedure.
procedure xml-doc_clear-parts :
  define buffer bf_tt-parts    for tt-parts.
  do
  on error undo, return error return-value
  :
    for each bf_tt-parts
    on error undo, return error return-value
    :
      delete bf_tt-parts.
    end.
  end.
end procedure.
procedure xml-doc_clear-attr :
  define buffer bf_tt-attr    for tt-attr.
  do
  on error undo, return error return-value
  :
    for each bf_tt-attr
    on error undo, return error return-value
    :
      delete bf_tt-attr.
    end.
  end.
end procedure.
procedure xml-doc_create-doc :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_tt-trn-doc          for tt-trn-doc.
define buffer bf_tt-trn-doc-add      for tt-trn-doc-add.
define buffer bf_trn-doc             for ub.trn-doc.
define buffer bf-ext_trn-doc-sum     for ub.trn-doc-sum.
define buffer bf-ext-cli_trn-doc-sum for ub.trn-doc-sum.
define buffer bf-mis_trn-doc-sum     for ub.trn-doc-sum.
define buffer bf-mis-cli_trn-doc-sum for ub.trn-doc-sum.
define buffer bf-wst_trn-doc-sum     for ub.trn-doc-sum.
define buffer bf-bef-cli_trn-doc-sum for ub.trn-doc-sum.
define buffer bf-aft-cli_trn-doc-sum for ub.trn-doc-sum.
define buffer bf-host_clients        for ub.clients.
define buffer bf-obj_clients         for ub.clients.
define buffer bf_currency            for ub.currency.
define buffer bf_firm                for ub.firm.
define buffer bf_person              for ub.person.
define buffer bf_shop                for ub.shop.
define buffer bf_store               for ub.store.
define buffer bf-own_firm            for ub.firm.
define buffer bf_sysconf             for ub.sysconf.
define buffer bf-contract            for ub.contract.
define buffer bf-wrkr_clients        for ub.clients.
define buffer bf-agnt_clients        for ub.clients.
define buffer bf-boss_clients        for ub.clients.
define variable par-type as character no-undo.
define variable varvalue as character no-undo.
define variable vartype  as character no-undo.
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
if error-status:error then do:
  return error substitute ("Не найден документ с номером &1.", pardoc-code).
end.
find first bf-obj_clients where bf-obj_clients.obj-type = bf_trn-doc.obj-type and
                                bf-obj_clients.obj-code = bf_trn-doc.obj-code no-lock.
find first bf-host_clients where bf-host_clients.obj-type = 'орг':U               and
                                 bf-host_clients.obj-code = bf_trn-doc.host-code no-lock.
find first bf-wrkr_clients where bf-wrkr_clients.obj-type = 'чел':U and
                                 bf-wrkr_clients.obj-code = bf_trn-doc.wrkr no-lock no-error.
find first bf-agnt_clients where bf-agnt_clients.obj-type = 'чел':U and
                                 bf-agnt_clients.obj-code = bf_trn-doc.agnt no-lock no-error.
find first bf-boss_clients where bf-boss_clients.obj-type = 'чел':U and
                                 bf-boss_clients.obj-code = bf_trn-doc.boss no-lock no-error.
if bf_trn-doc.ext-doc-type = 'ie':U then do:
  find first bf_currency where bf_currency.curr-code = bf_trn-doc.exch-code no-lock.
end.
if bf_trn-doc.obj-type = 'маг':U then do:
  find first bf_shop where bf_shop.obj-code = bf_trn-doc.obj-code no-lock.
end.
else do:
  find first bf_store where bf_store.obj-code = bf_trn-doc.obj-code no-lock.
end.
find first bf-own_firm where bf-own_firm.firm-code = bf_trn-doc.host-code no-lock.
find first bf_sysconf  where bf_sysconf.host-code  = bf_trn-doc.host-code no-lock.
run fmtcli-get-bank in this-procedure
 (input bf_sysconf.host-code,
  input 'орг':U,
  input bf_sysconf.host-code,
  input 0).
if v-fmtcli-schet-exists then do:
  assign
    v-own-rubl-fmtcli-schet-exists  = yes
    v-own-rubl-fmtcli-bank-r-schet  = v-fmtcli-bank-r-schet
    v-own-rubl-fmtcli-bank-c-schet  = v-fmtcli-bank-c-schet
    v-own-rubl-fmtcli-bank-bik      = v-fmtcli-bank-bik
    v-own-rubl-fmtcli-bank-name     = v-fmtcli-bank-name
    v-own-rubl-fmtcli-bank-addres   = v-fmtcli-bank-addres
  .
end.
else do:
  assign
    v-own-rubl-fmtcli-schet-exists  = no.
end.
if bf_sysconf.base-code <> 0 then do:
  run fmtcli-get-bank in this-procedure
   (input bf_sysconf.host-code,
    input 'орг':U,
    input bf_sysconf.host-code,
    input bf_sysconf.base-code).
  if v-fmtcli-schet-exists then do:
    assign
      v-own-base-fmtcli-schet-exists  = yes
      v-own-base-fmtcli-bank-r-schet  = v-fmtcli-bank-r-schet
      v-own-base-fmtcli-bank-c-schet  = v-fmtcli-bank-c-schet
      v-own-base-fmtcli-bank-bik      = v-fmtcli-bank-bik
      v-own-base-fmtcli-bank-name     = v-fmtcli-bank-name
      v-own-base-fmtcli-bank-addres   = v-fmtcli-bank-addres
    .
  end.
  else do:
    assign
      v-own-base-fmtcli-schet-exists  = no.
  end.
end.
else do:
  assign
    v-own-base-fmtcli-schet-exists = no.
end.
find first bf-contract no-lock where bf-contract.contract-code = bf_trn-doc.contract-code and
                                     bf-contract.host-code     = bf_trn-doc.host-code no-error .
create bf_tt-trn-doc.
create bf_tt-trn-doc-add.
assign
  bf_tt-trn-doc.DocCode                = bf_trn-doc.doc-code
  bf_tt-trn-doc.ExtDocType             = bf_trn-doc.ext-doc-type
  bf_tt-trn-doc.ExtDocTypeName         = entry (lookup (bf_trn-doc.ext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U)
  bf_tt-trn-doc.DocType                = bf_trn-doc.doc-type
  bf_tt-trn-doc.Internal               = bf_trn-doc.internal
  bf_tt-trn-doc.Sts                    = bf_trn-doc.status_
  bf_tt-trn-doc.Flag                   = bf_trn-doc.flag_
  bf_tt-trn-doc.DocDate                = bf_trn-doc.doc-date
  bf_tt-trn-doc.ContractId             = (if bf_trn-doc.ext-doc-type = 'ie':U or bf_trn-doc.ext-doc-type = 'ap':U then bf_trn-doc.contract-code else 0)
  bf_tt-trn-doc.BaseCrcRate            = bf_trn-doc.base-rate
  bf_tt-trn-doc.BaseCrcScale           = bf_trn-doc.base-scale
  bf_tt-trn-doc.CliType                = bf_trn-doc.cli-type
  bf_tt-trn-doc.CliCode                = bf_trn-doc.cli-code
  bf_tt-trn-doc.CliName                = bf_trn-doc.cli-name
  bf_tt-trn-doc.ObjType                = bf_trn-doc.obj-type
  bf_tt-trn-doc.ObjCode                = bf_trn-doc.obj-code
  bf_tt-trn-doc.ObjName                = bf-obj_clients.obj-name
  bf_tt-trn-doc.ShipNum                = bf_trn-doc.ship-num
  bf_tt-trn-doc.ShipDate               = bf_trn-doc.ship-date
  bf_tt-trn-doc.OrdNum                 = bf_trn-doc.ord-num
  bf_tt-trn-doc.Office                 = bf_trn-doc.office
  bf_tt-trn-doc.FactDate               = bf_trn-doc.fact-date
  bf_tt-trn-doc.FactNum                = bf_trn-doc.fact-num
  bf_tt-trn-doc.FactOrder              = bf_trn-doc.fact-order
  bf_tt-trn-doc.FactQnty               = bf_trn-doc.fact-qnty
  bf_tt-trn-doc.SumFactBaseAcc         = bf_trn-doc.fact-base
  bf_tt-trn-doc.SumFactRublAcc         = bf_trn-doc.fact-rubl
  bf_tt-trn-doc.VatType                = bf_trn-doc.vat-type
  bf_tt-trn-doc.SltType                = bf_trn-doc.slt-type
  bf_tt-trn-doc.Wrkr                   = (if available bf-wrkr_clients then bf-wrkr_clients.obj-name else "":u)
  bf_tt-trn-doc.Agnt                   = (if available bf-agnt_clients then bf-agnt_clients.obj-name else "":u)
  bf_tt-trn-doc.Boss                   = (if available bf-boss_clients then bf-boss_clients.obj-name else "":u)
  bf_tt-trn-doc.PayCode                = bf_trn-doc.pay-code
  bf_tt-trn-doc.Creid                  = bf_trn-doc.creid
  bf_tt-trn-doc.PrintRubl              = bf_trn-doc.print-rubl
  bf_tt-trn-doc.PS                     = bf_trn-doc.PS
  bf_tt-trn-doc.Ov                     = bf_trn-doc.ov
  bf_tt-trn-doc.HostCode               = bf_trn-doc.host-code
  bf_tt-trn-doc.HostName               = bf-host_clients.obj-name
  bf_tt-trn-doc-add.PostIndexOwn       = bf-own_firm.ind
  bf_tt-trn-doc-add.CityOwn            = bf-own_firm.city
  bf_tt-trn-doc-add.AddressOwn         = bf-own_firm.addres1
  bf_tt-trn-doc-add.AddressAddOwn      = bf-own_firm.addres2
  bf_tt-trn-doc-add.PostAddressOwn     = bf-own_firm.post-addr1
  bf_tt-trn-doc-add.PostAddressAddOwn  = bf-own_firm.post-addr2
  bf_tt-trn-doc-add.EMailOwn           = bf-own_firm.e-mail
  bf_tt-trn-doc-add.FaxOwn             = bf-own_firm.fax
  bf_tt-trn-doc-add.PhoneOwn           = bf-own_firm.phone
  bf_tt-trn-doc-add.InnOwn             = bf-own_firm.inn
  bf_tt-trn-doc-add.KPPOwn             = bf-own_firm.kpp
  bf_tt-trn-doc-add.OKPOOwn            = bf-own_firm.okpo
  bf_tt-trn-doc-add.OKONHOwn           = bf-own_firm.okonh
  bf_tt-trn-doc-add.PhoneNoteOwn       = bf-own_firm.phone1-note
  bf_tt-trn-doc-add.ContactPersonOwn   = bf-own_firm.contact-psn
  bf_tt-trn-doc-add.DirectorOwn        = bf-own_firm.director
  bf_tt-trn-doc-add.EnglNameOwn        = bf-own_firm.engl-name
  bf_tt-trn-doc-add.GenAccntOwn        = bf_sysconf.snr-accnt
  bf_tt-trn-doc-add.TelexOwn           = bf-own_firm.telex
.
if available bf-contract then do:
   assign
     bf_tt-trn-doc.ContractNum            = bf-contract.contract-prn-code
     bf_tt-trn-doc.ContractDate           = bf-contract.contract-date
   .
end.
else do:
   assign
     bf_tt-trn-doc.ContractNum            = ""
     bf_tt-trn-doc.ContractDate           = ?
   .
end.
if v-own-rubl-fmtcli-schet-exists then do:
  assign
    bf_tt-trn-doc-add.OwnBankRublIsHave      = yes
    bf_tt-trn-doc-add.BankNameRublOwn        = v-own-rubl-fmtcli-bank-name
    bf_tt-trn-doc-add.BankCodeRublOwn        = v-own-rubl-fmtcli-bank-bik
    bf_tt-trn-doc-add.BankAccRublOwn         = v-own-rubl-fmtcli-bank-r-schet
    bf_tt-trn-doc-add.AddressBankRublOwn     = v-own-rubl-fmtcli-bank-addres
    bf_tt-trn-doc-add.AddressAddBankRublOwn  = "":u
    bf_tt-trn-doc-add.PBankAccRublOwn        = v-own-rubl-fmtcli-bank-c-schet
  .
end.
else do:
  assign
    bf_tt-trn-doc-add.OwnBankRublIsHave = no.
end.
if v-own-base-fmtcli-schet-exists then do:
  assign
    bf_tt-trn-doc-add.OwnBankBaseIsHave      = yes
    bf_tt-trn-doc-add.BankNameBaseOwn        = v-own-base-fmtcli-bank-name
    bf_tt-trn-doc-add.BankCodeBaseOwn        = v-own-base-fmtcli-bank-bik
    bf_tt-trn-doc-add.BankAccBaseOwn         = v-own-base-fmtcli-bank-r-schet
    bf_tt-trn-doc-add.AddressBankBaseOwn     = v-own-base-fmtcli-bank-addres
    bf_tt-trn-doc-add.AddressAddBankBaseOwn  = "":u
    bf_tt-trn-doc-add.PBankAccBaseOwn        = v-own-base-fmtcli-bank-c-schet
  .
end.
else do:
  assign
    bf_tt-trn-doc-add.OwnBankBaseIsHave = no.
end
.
assign
  bf_tt-trn-doc-add.KOPFOwn     = bf_sysconf.kopf
  bf_tt-trn-doc-add.SOEIOwn     = bf_sysconf.soei
  bf_tt-trn-doc-add.BranchOwn   = bf_sysconf.branch
  bf_tt-trn-doc-add.PropertyOwn = bf_sysconf.property
.
assign
  bf_tt-trn-doc.TotLines               = bf_trn-doc.tot-lines
  bf_tt-trn-doc.FactTime               = bf_trn-doc.fact-time
  bf_tt-trn-doc.RetSupp                = bf_trn-doc.ret-supp
  bf_tt-trn-doc.RsrvDate               = bf_trn-doc.rsrv-date
  bf_tt-trn-doc.RsrvTerm               = bf_trn-doc.rsrv-date - bf_trn-doc.doc-date
  bf_tt-trn-doc.ReasonCode             = bf_trn-doc.reason-code
   .
if bf_trn-doc.cli-type = 'орг':U then do:
  find first bf_firm where bf_firm.firm-code = bf_trn-doc.cli-code no-lock no-error.
  if not available bf_firm then do:
    return error substitute ("Не найдена фирма-контрагент с кодом &1.", bf_trn-doc.cli-code).
  end.
end.
else do:
  if bf_trn-doc.cli-type = 'маг':U  or
     bf_trn-doc.cli-type = 'скл':U then do:
    find first bf_firm where bf_firm.firm-code = bf_trn-doc.host-code no-lock no-error.
    if not available bf_firm then do:
      return error substitute ("Не найдена фирма-контрагент с кодом &1.", bf_trn-doc.cli-code).
    end.
  end.
  else do:
    find first bf_person where bf_person.psn-code = bf_trn-doc.cli-code no-lock no-error.
    if not available bf_person then do:
      return error substitute ("Не найдено физ. лицо-контрагент с кодом &1.", bf_trn-doc.cli-code).
    end.
  end.
end.
run fmtcli-get-bank in this-procedure
 (input bf_sysconf.host-code,
  input bf_trn-doc.cli-type,
  input bf_trn-doc.cli-code,
  input 0).
if v-fmtcli-schet-exists then do:
  assign
    v-cli-rubl-fmtcli-schet-exists  = yes
    v-cli-rubl-fmtcli-bank-r-schet  = v-fmtcli-bank-r-schet
    v-cli-rubl-fmtcli-bank-c-schet  = v-fmtcli-bank-c-schet
    v-cli-rubl-fmtcli-bank-bik      = v-fmtcli-bank-bik
    v-cli-rubl-fmtcli-bank-name     = v-fmtcli-bank-name
    v-cli-rubl-fmtcli-bank-addres   = v-fmtcli-bank-addres
  .
end.
else do:
  assign
    v-cli-rubl-fmtcli-schet-exists  = no.
end.
if bf_sysconf.base-code <> 0 then do:
  run fmtcli-get-bank in this-procedure
   (input bf_sysconf.host-code,
    input bf_trn-doc.cli-type,
    input bf_trn-doc.cli-code,
    input bf_sysconf.base-code).
  if v-fmtcli-schet-exists then do:
    assign
      v-cli-base-fmtcli-schet-exists  = yes
      v-cli-base-fmtcli-bank-r-schet  = v-fmtcli-bank-r-schet
      v-cli-base-fmtcli-bank-c-schet  = v-fmtcli-bank-c-schet
      v-cli-base-fmtcli-bank-bik      = v-fmtcli-bank-bik
      v-cli-base-fmtcli-bank-name     = v-fmtcli-bank-name
      v-cli-base-fmtcli-bank-addres   = v-fmtcli-bank-addres
    .
  end.
  else do:
    assign
      v-cli-base-fmtcli-schet-exists  = no.
  end.
end.
else do:
  assign
    v-cli-base-fmtcli-schet-exists = no.
end.
assign
  bf_tt-trn-doc.PostIndex = (if bf_trn-doc.cli-type = 'орг':U or bf_trn-doc.cli-type = 'маг':U or bf_trn-doc.cli-type = 'скл':U then bf_firm.ind     else bf_person.ind)
  bf_tt-trn-doc.City      = (if bf_trn-doc.cli-type = 'орг':U or bf_trn-doc.cli-type = 'маг':U or bf_trn-doc.cli-type = 'скл':U then bf_firm.city    else bf_person.city)
  bf_tt-trn-doc.Address   = (if bf_trn-doc.cli-type = 'орг':U or bf_trn-doc.cli-type = 'маг':U or bf_trn-doc.cli-type = 'скл':U then bf_firm.addres1 else bf_person.address)
  .
if bf_trn-doc.cli-type = 'орг':U or bf_trn-doc.cli-type = 'маг':U or bf_trn-doc.cli-type = 'скл':U then do:
  assign
    bf_tt-trn-doc.AddressAdd     = bf_firm.addres2
    bf_tt-trn-doc.PostAddress    = bf_firm.post-addr1
    bf_tt-trn-doc.PostAddressAdd = bf_firm.post-addr2
  .
end.
assign
  bf_tt-trn-doc.EMail     = (if bf_trn-doc.cli-type = 'орг':U or bf_trn-doc.cli-type = 'маг':U or bf_trn-doc.cli-type = 'скл':U then bf_firm.e-mail      else bf_person.e-mail)
  bf_tt-trn-doc.Fax       = (if bf_trn-doc.cli-type = 'орг':U or bf_trn-doc.cli-type = 'маг':U or bf_trn-doc.cli-type = 'скл':U then bf_firm.fax         else bf_person.fax)
  bf_tt-trn-doc.Phone     = (if bf_trn-doc.cli-type = 'орг':U or bf_trn-doc.cli-type = 'маг':U or bf_trn-doc.cli-type = 'скл':U then bf_firm.phone       else bf_person.phone1)
  bf_tt-trn-doc.PhoneNote = (if bf_trn-doc.cli-type = 'орг':U or bf_trn-doc.cli-type = 'маг':U or bf_trn-doc.cli-type = 'скл':U then bf_firm.phone1-note else bf_person.phone1-note)
  bf_tt-trn-doc.Inn       = (if bf_trn-doc.cli-type = 'орг':U or bf_trn-doc.cli-type = 'маг':U or bf_trn-doc.cli-type = 'скл':U then bf_firm.inn         else bf_person.inn)
  bf_tt-trn-doc.KPP       = (if bf_trn-doc.cli-type = 'орг':U or bf_trn-doc.cli-type = 'маг':U or bf_trn-doc.cli-type = 'скл':U then bf_firm.kpp         else bf_person.kpp)
  bf_tt-trn-doc.OKPO      = (if bf_trn-doc.cli-type = 'орг':U or bf_trn-doc.cli-type = 'маг':U or bf_trn-doc.cli-type = 'скл':U then bf_firm.okpo        else bf_person.okpo)
  bf_tt-trn-doc.OKONH     = (if bf_trn-doc.cli-type = 'орг':U or bf_trn-doc.cli-type = 'маг':U or bf_trn-doc.cli-type = 'скл':U then bf_firm.okonh       else bf_person.okonh)
.
if bf_trn-doc.cli-type = 'орг':U or bf_trn-doc.cli-type = 'маг':U or bf_trn-doc.cli-type = 'скл':U then do:
  assign
    bf_tt-trn-doc.ContactPerson = bf_firm.contact-psn
    bf_tt-trn-doc.Director      = bf_firm.director
    bf_tt-trn-doc.EnglName      = bf_firm.engl-name
    bf_tt-trn-doc.GenAccnt      = bf_firm.gen-acct
    bf_tt-trn-doc.Telex         = bf_firm.telex
    .
end.
else do:
  assign
    bf_tt-trn-doc.Name       = bf_person.name1
    bf_tt-trn-doc.Patronymic = bf_person.name2
    bf_tt-trn-doc.PassNum    = bf_person.passp-num
    bf_tt-trn-doc.PassSer    = bf_person.passp-ser
    bf_tt-trn-doc.GivenBy    = bf_person.given-by
    bf_tt-trn-doc.Position   = bf_person.position
    bf_tt-trn-doc.PostBox    = bf_person.post-box
  .
end.
if v-cli-rubl-fmtcli-schet-exists then do:
  assign
    bf_tt-trn-doc.BankRublIsHave      = yes
    bf_tt-trn-doc.BankNameRubl        = v-cli-rubl-fmtcli-bank-name
    bf_tt-trn-doc.BankCodeRubl        = v-cli-rubl-fmtcli-bank-bik
    bf_tt-trn-doc.BankAccRubl         = v-cli-rubl-fmtcli-bank-r-schet
    bf_tt-trn-doc.AddressBankRubl     = v-cli-rubl-fmtcli-bank-addres
    bf_tt-trn-doc.AddressAddBankRubl  = "":u
    bf_tt-trn-doc.PBankAccRubl        = v-cli-rubl-fmtcli-bank-c-schet
   .
end.
else do:
  assign
    bf_tt-trn-doc.BankRublIsHave      = no.
end.
if v-cli-base-fmtcli-schet-exists then do:
  assign
    bf_tt-trn-doc.BankBaseIsHave       = yes
    bf_tt-trn-doc.BankNameBase         = v-cli-base-fmtcli-bank-name
    bf_tt-trn-doc.BankCodeBase         = v-cli-base-fmtcli-bank-bik
    bf_tt-trn-doc.BankAccBase          = v-cli-base-fmtcli-bank-r-schet
    bf_tt-trn-doc.AddressBankBase      = v-cli-base-fmtcli-bank-addres
    bf_tt-trn-doc.AddressAddBankBase   = "":u
    bf_tt-trn-doc.PBankAccBase         = v-cli-base-fmtcli-bank-c-schet
  .
end.
else do:
  assign
    bf_tt-trn-doc.BankBaseIsHave      = no.
end.
  assign
    bf_tt-trn-doc.BgeDate = bf_trn-doc.bge-date
    bf_tt-trn-doc.SctDate = bf_trn-doc.scf-date
    bf_tt-trn-doc.AccDate = bf_trn-doc.acc-date
    bf_tt-trn-doc.InvNum  = bf_trn-doc.inv-num    .
if varshift = "yes" then do:
  assign
    bf_tt-trn-doc.ShiftNum  = bf_trn-doc.shift-num
    bf_tt-trn-doc.ShiftName = bf_trn-doc.shift-name
    bf_tt-trn-doc.ShiftDate = bf_trn-doc.shift-date .
end.
if bf_trn-doc.ext-doc-type = 'ie':U then do:
  assign
    bf_tt-trn-doc.SupplCrcCode         = bf_trn-doc.exch-code
    bf_tt-trn-doc.SupplCrcAbbr         = bf_currency.curr-abbr
    bf_tt-trn-doc.SupplCrcName         = bf_currency.curr-name
    bf_tt-trn-doc.SupplCrcDate         = bf_trn-doc.exch-date
    bf_tt-trn-doc.SupplCrcRate         = bf_trn-doc.exch-rate
    bf_tt-trn-doc.SupplCrcScale        = bf_trn-doc.exch-scale
    bf_tt-trn-doc.SumCheckFactSuppl    = bf_trn-doc.tot-cli
    bf_tt-trn-doc.SumFactSuppl         = bf_trn-doc.tot-calc
    bf_tt-trn-doc.VatFactBaseAcc       = bf_trn-doc.vat-base
    bf_tt-trn-doc.VatFactRublAcc       = bf_trn-doc.vat-rubl
    bf_tt-trn-doc.SltFactBaseAcc       = bf_trn-doc.slt-base
    bf_tt-trn-doc.SltFactRublAcc       = bf_trn-doc.slt-rubl
    bf_tt-trn-doc.SumDocBaseAcc        = bf_trn-doc.fact-base
    bf_tt-trn-doc.SumDocRublAcc        = bf_trn-doc.fact-base
    bf_tt-trn-doc.OvervalueFactSaleacc = bf_trn-doc.tot-ov
    bf_tt-trn-doc.TaxThreeFactSaleAcc      = bf_trn-doc.road-tax
    bf_tt-trn-doc.ExciseFactSaleAcc    = bf_trn-doc.excise
    bf_tt-trn-doc.TransportExpSuppl    = bf_trn-doc.tot-transp
    bf_tt-trn-doc.OtherExpSuppl        = bf_trn-doc.tot-other
    bf_tt-trn-doc.SupplQnty            = bf_trn-doc.cli-qnty
    bf_tt-trn-doc.CstCode              = bf_trn-doc.cst-code   .
end.
else do:
  assign
    bf_tt-trn-doc.VatFactBaseDoc        = bf_trn-doc.vat-base
    bf_tt-trn-doc.VatFactRublDoc        = bf_trn-doc.vat-rubl
    bf_tt-trn-doc.SltFactBaseDoc        = bf_trn-doc.slt-base
    bf_tt-trn-doc.SltFactRublDoc        = bf_trn-doc.slt-rubl
    bf_tt-trn-doc.SumDocBaseDoc         = bf_trn-doc.tot-doc
    bf_tt-trn-doc.SumDocRublDoc         = bf_trn-doc.tot-rubl
    bf_tt-trn-doc.OvervalueFactSaledoc  = bf_trn-doc.tot-ov    .
end.
if bf_trn-doc.out-code <> ? and
   bf_trn-doc.out-code <> "" then do:
  assign
     bf_tt-trn-doc.OutCode = bf_trn-doc.out-code.
end.
if bf_trn-doc.ext-doc-type = 'vt':U      or
   bf_trn-doc.ext-doc-type = 'vp':U         or
   bf_trn-doc.ext-doc-type = 'ap':U   or
   bf_trn-doc.ext-doc-type = 'mp':U or
   bf_trn-doc.ext-doc-type = 'pc':U   then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'addsum':U ,
                       output varvalue ,
                       output vartype ) no-error .
  if error-status:error then do:
    return error substitute ("Ошибка при вызове процедуры tdat-val &1 &2.", return-value, error-status:get-message(1)).
  end.
  if lookup ('ext':U, varvalue) <> 0 then do:
    find first bf-ext_trn-doc-sum where bf-ext_trn-doc-sum.doc-code = bf_trn-doc.doc-code and
                                        bf-ext_trn-doc-sum.sum-type = 'ext':U    no-lock.
    if not available bf-ext_trn-doc-sum then do:
      return error substitute ("Не найдена сумма с типом &1 по документу &2.", 'ext':U, bf-ext_trn-doc-sum.doc-code).
    end.
  end.
  if lookup ('extc':U, varvalue) <> 0 then do:
    find first bf-ext-cli_trn-doc-sum where bf-ext-cli_trn-doc-sum.doc-code = bf_trn-doc.doc-code  and
                                            bf-ext-cli_trn-doc-sum.sum-type = 'extc':U no-lock.
    if not available bf-ext-cli_trn-doc-sum then do:
      return error substitute ("Не найдена сумма с типом &1 по документу &2.", 'extc':U, bf-ext-cli_trn-doc-sum.doc-code).
    end.
  end.
  if lookup ('mis':U, varvalue) <> 0 then do:
    find first bf-mis_trn-doc-sum where bf-mis_trn-doc-sum.doc-code = bf_trn-doc.doc-code and
                                        bf-mis_trn-doc-sum.sum-type = 'mis':U     no-lock.
    if not available bf-mis_trn-doc-sum then do:
      return error substitute ("Не найдена сумма с типом &1 по документу &2.", 'mis':U, bf-mis_trn-doc-sum.doc-code).
    end.
  end.
  if lookup ('misc':U, varvalue) <> 0 then do:
    find first bf-mis-cli_trn-doc-sum where bf-mis-cli_trn-doc-sum.doc-code = bf_trn-doc.doc-code and
                                            bf-mis-cli_trn-doc-sum.sum-type = 'misc':U no-lock.
    if not available bf-mis-cli_trn-doc-sum then do:
      return error substitute ("Не найдена сумма с типом &1 по документу &2.", 'misc':U, bf-mis-cli_trn-doc-sum.doc-code).
    end.
  end.
  if lookup ('wst':U, varvalue) <> 0 then do:
    find first bf-wst_trn-doc-sum where bf-wst_trn-doc-sum.doc-code = bf_trn-doc.doc-code and
                                        bf-wst_trn-doc-sum.sum-type = 'wst':U  no-lock.
    if not available bf-wst_trn-doc-sum then do:
      return error substitute ("Не найдена сумма с типом &1 по документу &2.", 'wst':U, bf-wst_trn-doc-sum.doc-code).
    end.
  end.
  if lookup ('bcd':U, varvalue) <> 0 then do:
    find first bf-bef-cli_trn-doc-sum where bf-bef-cli_trn-doc-sum.doc-code = bf_trn-doc.doc-code   and
                                            bf-bef-cli_trn-doc-sum.sum-type = 'bcd':U no-lock.
    if not available bf-bef-cli_trn-doc-sum then do:
      return error substitute ("Не найдена сумма с типом &1 по документу &2.", 'bcd':U, bf-bef-cli_trn-doc-sum.doc-code).
    end.
  end.
  if lookup ('acd':U, varvalue) <> 0 then do:
    find first bf-aft-cli_trn-doc-sum where bf-aft-cli_trn-doc-sum.doc-code = bf_trn-doc.doc-code  and
                                            bf-aft-cli_trn-doc-sum.sum-type = 'acd':U no-lock.
    if not available bf-aft-cli_trn-doc-sum then do:
      return error substitute ("Не найдена сумма с типом &1 по документу &2.", 'acd':U, bf-aft-cli_trn-doc-sum.doc-code).
    end.
  end.
  assign
    bf_tt-trn-doc.BefQnty                = bf_trn-doc.doc-qnty
    bf_tt-trn-doc.CalcSum                = varvalue
    bf_tt-trn-doc.SumBefBaseAcc          = bf_trn-doc.tot-calc
    bf_tt-trn-doc.SumBefRublAcc          = bf_trn-doc.discnt-rubl
    bf_tt-trn-doc.ExtraQnty              = (if available bf-ext_trn-doc-sum     then bf-ext_trn-doc-sum.fact-qnty         else ?)
    bf_tt-trn-doc.ExtraSupplQnty         = (if available bf-ext-cli_trn-doc-sum then bf-ext-cli_trn-doc-sum.fact-qnty     else ?)
    bf_tt-trn-doc.ExtraFactBaseAcc       = (if available bf-ext_trn-doc-sum     then bf-ext_trn-doc-sum.cost-sum-base     else ?)
    bf_tt-trn-doc.ExtraFactRublAcc       = (if available bf-ext_trn-doc-sum     then bf-ext_trn-doc-sum.cost-sum-rubl     else ?)
    bf_tt-trn-doc.ExtraFactSale          = (if available bf-ext_trn-doc-sum     then (if varr-b = "base" then bf-ext_trn-doc-sum.sale-sum-base else bf-ext_trn-doc-sum.sale-sum-rubl) else ?)
    bf_tt-trn-doc.MissQnty               = (if available bf-mis_trn-doc-sum     then bf-mis_trn-doc-sum.fact-qnty         else ?)
    bf_tt-trn-doc.MissCliQnty            = (if available bf-mis-cli_trn-doc-sum then bf-mis-cli_trn-doc-sum.fact-qnty     else ?)
    bf_tt-trn-doc.MissFactBaseAcc        = (if available bf-mis_trn-doc-sum     then bf-mis_trn-doc-sum.cost-sum-base     else ?)
    bf_tt-trn-doc.MissFactRublAcc        = (if available bf-mis_trn-doc-sum     then bf-mis_trn-doc-sum.cost-sum-rubl     else ?)
    bf_tt-trn-doc.MissFactSale           = (if available bf-mis_trn-doc-sum     then (if varr-b = "base" then bf-mis_trn-doc-sum.sale-sum-base else bf-mis_trn-doc-sum.sale-sum-rubl) else ?)
    bf_tt-trn-doc.WastageFactSale        = (if available bf-wst_trn-doc-sum     then (if varr-b = "base" then bf-wst_trn-doc-sum.sale-sum-base else bf-wst_trn-doc-sum.sale-sum-rubl) else ?)
    bf_tt-trn-doc.BefSupplQnty           = (if available bf-bef-cli_trn-doc-sum then bf-bef-cli_trn-doc-sum.fact-qnty     else ?)
    bf_tt-trn-doc.AftSupplQnty           = (if available bf-aft-cli_trn-doc-sum then bf-aft-cli_trn-doc-sum.fact-qnty     else ?)
    .
end.
else do:
  assign
    bf_tt-trn-doc.DocQnty = bf_trn-doc.doc-qnty.
end.
if bf_trn-doc.ext-doc-type <> 'ie':U and
   bf_trn-doc.ext-doc-type <> 'vt':U and
   bf_trn-doc.ext-doc-type <> 'vp':U         and
   bf_trn-doc.ext-doc-type <> 'ap':U   and
   bf_trn-doc.ext-doc-type <> 'mp':U and
   bf_trn-doc.ext-doc-type <> 'pc':U   then do:
   assign
     bf_tt-trn-doc.DscFactBaseDoc = bf_trn-doc.tot-calc
     bf_tt-trn-doc.SumFactBaseDoc = bf_trn-doc.tot-fact
     bf_tt-trn-doc.SumFactRublDoc = bf_trn-doc.tot-sale
     bf_tt-trn-doc.DscFactRublDoc = bf_trn-doc.discnt-rubl
     bf_tt-trn-doc.DiscntType     = bf_trn-doc.discnt-type
     bf_tt-trn-doc.DiscntPc       = bf_trn-doc.discnt-pc   .
end.
assign
 bf_tt-trn-doc-add.DocCode       = bf_trn-doc.doc-code
 bf_tt-trn-doc-add.AddressObj    = (if bf_trn-doc.obj-type = 'маг':U then bf_shop.addres1 else bf_store.addres1)
 bf_tt-trn-doc-add.AddressAddObj = (if bf_trn-doc.obj-type = 'маг':U then bf_shop.addres2 else bf_store.addres2)
.
if bf_trn-doc.obj-type = 'маг':U then do:
  assign
    bf_tt-trn-doc-add.AcctObj     = entry(1,bf_shop.acct,"|")
    bf_tt-trn-doc-add.DirectorObj = bf_shop.director
    bf_tt-trn-doc-add.GoodsManObj = bf_shop.goods-man
  .
end.
assign
  bf_tt-trn-doc-add.PhoneObj     = (if bf_trn-doc.obj-type = 'маг':U then bf_shop.phone      else bf_store.phone)
  bf_tt-trn-doc-add.StoreBossObj = (if bf_trn-doc.obj-type = 'маг':U then bf_shop.store-boss else bf_store.store-boss)
  bf_tt-trn-doc-add.StoreManObj  = (if bf_trn-doc.obj-type = 'маг':U then bf_shop.store-man  else bf_store.store-man)
.
end.
if bf_trn-doc.ext-doc-type = 'ie':U then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'expense_own':U ,
                       output varvalue ,
                       output vartype ) no-error .
  if error-status:error then do:
    return error substitute ("Ошибка при вызове процедуры tdat-val &1 &2.", return-value, error-status:get-message(1)).
  end.
  assign
    bf_tt-trn-doc.ExpenseOwn = decimal(varvalue).
end.
end procedure.
procedure xml-doc_create-line :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_tt-doc-line          for tt-doc-line.
define buffer bf_doc-line             for ub.doc-line.
define buffer bf-ext_doc-line-sum     for ub.doc-line-sum.
define buffer bf-ext-cli_doc-line-sum for ub.doc-line-sum.
define buffer bf-mis_doc-line-sum     for ub.doc-line-sum.
define buffer bf-mis-cli_doc-line-sum for ub.doc-line-sum.
define buffer bf-wst_doc-line-sum     for ub.doc-line-sum.
define buffer bf-bef-cli_doc-line-sum for ub.doc-line-sum.
define buffer bf-aft-cli_doc-line-sum for ub.doc-line-sum.
define buffer bf-bef_doc-line-sum     for ub.doc-line-sum.
define buffer bf-aft_doc-line-sum     for ub.doc-line-sum.
define buffer bf_doc-line-attr        for ub.doc-line-attr.
define buffer bf_goods                for ub.goods.
define buffer bf-obj_clients          for ub.clients.
define buffer bf-prod_clients         for ub.clients.
define buffer bf_trn-doc              for ub.trn-doc.
define buffer bf_gds-grp              for ub.gds-grp.
define variable varis-petrol     as   logical               no-undo.
define variable varis-pieces     as   logical               no-undo.
define variable custvalue        as   character             no-undo.
define variable custtype         as   character             no-undo.
define variable varfact-qnty     like ub.doc-line.fact-qnty no-undo.
define variable varvat-pc        like ub.doc-line.vat-pc    no-undo.
define variable varslt-pc        like ub.doc-line.slt-pc    no-undo.
define variable varvalue         as   character             no-undo.
define variable vartype          as   character             no-undo.
define variable varfull-grp-name as   character             no-undo.
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
if error-status:error then do:
  return error substitute ("Не найден документ с номером &1.", pardoc-code).
end.
run gbl/conf-rd.p ("is-custm" , "", "", 0, "", "", "", no, output custvalue, output custtype) no-error.
for each bf_doc-line where bf_doc-line.doc-code = pardoc-code no-lock on error undo, return error return-value :
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock no-error.
  if not available bf_goods then do:
    return error substitute ("Не найден товар: &1 &2 &3.", bf_doc-line.artic, bf_doc-line.prod-type, bf_doc-line.prod-code).
  end.
  find first bf_gds-grp where bf_gds-grp.node-code = bf_goods.grp-code no-lock no-error.
  if not available bf_gds-grp then do:
    return error substitute ("Не найден группа товаров с кодом &1 для товара: &2 &3 &4.", bf_goods.grp-code, bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
  end.
  run grplib-get-full-name in this-procedure (input bf_gds-grp.node-code, output varfull-grp-name).
  find first bf-prod_clients where bf-prod_clients.obj-type = bf_doc-line.prod-type and
                                   bf-prod_clients.obj-code = bf_doc-line.prod-code no-lock.
  find first bf-obj_clients  where bf-obj_clients.obj-type = bf_doc-line.obj-type and
                                   bf-obj_clients.obj-code = bf_doc-line.obj-code no-lock.
  if bf_trn-doc.ext-doc-type = 'vt':U              or
     bf_trn-doc.ext-doc-type = 'vp':U         or
     bf_trn-doc.ext-doc-type = 'ap':U   or
     bf_trn-doc.ext-doc-type = 'mp':U or
     bf_trn-doc.ext-doc-type = 'pc':U
  then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'addsum':U ,
                       output varvalue ,
                       output vartype ) no-error .
    if error-status:error then do:
      return error substitute ("Ошибка при вызове процедуры tdat-val &1 &2.", return-value, error-status:get-message(1)).
    end.
    if lookup ('ext':U, varvalue) <> 0 then do:
      find first bf-ext_doc-line-sum where bf-ext_doc-line-sum.doc-code = bf_trn-doc.doc-code and
                                           bf-ext_doc-line-sum.gds-code = bf_goods.gds-code   and
                                           bf-ext_doc-line-sum.sum-type = 'ext':U    no-lock no-error.
    end.
    if lookup ('extc':U, varvalue) <> 0 then do:
      find first bf-ext-cli_doc-line-sum where bf-ext-cli_doc-line-sum.doc-code = bf_trn-doc.doc-code  and
                                               bf-ext-cli_doc-line-sum.gds-code = bf_goods.gds-code    and
                                               bf-ext-cli_doc-line-sum.sum-type = 'extc':U no-lock no-error.
    end.
    if lookup ('mis':U, varvalue) <> 0 then do:
      find first bf-mis_doc-line-sum where bf-mis_doc-line-sum.doc-code = bf_trn-doc.doc-code and
                                           bf-mis_doc-line-sum.gds-code = bf_goods.gds-code   and
                                           bf-mis_doc-line-sum.sum-type = 'mis':U     no-lock no-error.
    end.
    if lookup ('misc':U, varvalue) <> 0 then do:
      find first bf-mis-cli_doc-line-sum where bf-mis-cli_doc-line-sum.doc-code = bf_trn-doc.doc-code and
                                               bf-mis-cli_doc-line-sum.gds-code = bf_goods.gds-code   and
                                               bf-mis-cli_doc-line-sum.sum-type = 'misc':U no-lock no-error.
    end.
    if lookup ('wst':U, varvalue) <> 0 then do:
      find first bf-wst_doc-line-sum where bf-wst_doc-line-sum.doc-code = bf_trn-doc.doc-code and
                                           bf-wst_doc-line-sum.gds-code = bf_goods.gds-code   and
                                           bf-wst_doc-line-sum.sum-type = 'wst':U  no-lock no-error.
      if not available bf-wst_doc-line-sum then do:
        return error substitute ("Не найдена сумма с типом &1 по документу &2 товар &3 &4 &5 &6.", 'wst':U, bf-wst_doc-line-sum.doc-code, bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name).
      end.
    end.
    if lookup ('bd':U, varvalue) <> 0 then do:
      find first bf-bef_doc-line-sum where bf-bef_doc-line-sum.doc-code = bf_trn-doc.doc-code and
                                           bf-bef_doc-line-sum.gds-code = bf_goods.gds-code   and
                                           bf-bef_doc-line-sum.sum-type = 'bd':U   no-lock no-error.
      if not available bf-bef_doc-line-sum then do:
        return error substitute ("Не найдена сумма с типом &1 по документу &2 товар &3 &4 &5 &6.", 'bd':U, bf-bef_doc-line-sum.doc-code, bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name).
      end.
    end.
    if lookup ('ad':U, varvalue) <> 0 then do:
      find first bf-aft_doc-line-sum where bf-aft_doc-line-sum.doc-code = bf_trn-doc.doc-code  and
                                           bf-aft_doc-line-sum.gds-code = bf_goods.gds-code    and
                                           bf-aft_doc-line-sum.sum-type = 'ad':U no-lock no-error.
      if not available bf-aft_doc-line-sum then do:
        return error substitute ("Не найдена сумма с типом &1 по документу &2 товар &3 &4 &5 &6.", 'ad':U, bf-aft_doc-line-sum.doc-code, bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name).
      end.
    end.
    if lookup ('bcd':U, varvalue) <> 0 then do:
      find first bf-bef-cli_doc-line-sum where bf-bef-cli_doc-line-sum.doc-code = bf_trn-doc.doc-code   and
                                               bf-bef-cli_doc-line-sum.gds-code = bf_goods.gds-code     and
                                               bf-bef-cli_doc-line-sum.sum-type = 'bcd':U no-lock no-error.
      if not available bf-bef-cli_doc-line-sum then do:
        return error substitute ("Не найдена сумма с типом &1 по документу &2 товар &3 &4 &5 &6.", 'bcd':U, bf-bef-cli_doc-line-sum.doc-code, bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name).
      end.
    end.
    if lookup ('acd':U, varvalue) <> 0 then do:
      find first bf-aft-cli_doc-line-sum where bf-aft-cli_doc-line-sum.doc-code = bf_trn-doc.doc-code  and
                                               bf-aft-cli_doc-line-sum.gds-code = bf_goods.gds-code    and
                                               bf-aft-cli_doc-line-sum.sum-type = 'acd':U no-lock no-error.
      if not available bf-aft-cli_doc-line-sum then do:
        return error substitute ("Не найдена сумма с типом &1 по документу &2 товар &3 &4 &5 &6.", 'acd':U, bf-aft-cli_doc-line-sum.doc-code, bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name).
      end.
    end.
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf_goods.artic
  ,  input bf_goods.prod-type
  ,  input bf_goods.prod-code
  , output varis-petrol
  , output varis-pieces
  ) no-error.
  if error-status:error then do:
    return error return-value.
  end.
  create bf_tt-doc-line.
  assign
    bf_tt-doc-line.DocCode            = bf_doc-line.doc-code
    bf_tt-doc-line.Artic              = bf_doc-line.artic
    bf_tt-doc-line.ProdType           = bf_doc-line.prod-type
    bf_tt-doc-line.ProdCode           = bf_doc-line.prod-code
    bf_tt-doc-line.GdsCode            = bf_goods.gds-code
    bf_tt-doc-line.ProdName           = bf-prod_clients.obj-name
    bf_tt-doc-line.GdsName            = bf_goods.gds-name
    bf_tt-doc-line.EnglName           = trim(bf_goods.engl-name)
    bf_tt-doc-line.LabelName          = trim(bf_goods.label-name)
    bf_tt-doc-line.GrpCode            = bf_gds-grp.node-code
    bf_tt-doc-line.GrpFullName        = varfull-grp-name
    bf_tt-doc-line.GrpName            = bf_gds-grp.node-name
    bf_tt-doc-line.UnitBase           = bf_goods.unit-base
    bf_tt-doc-line.ObjType            = bf_doc-line.obj-type
    bf_tt-doc-line.ObjCode            = bf_doc-line.obj-code
    bf_tt-doc-line.ObjName            = bf-obj_clients.obj-name
    bf_tt-doc-line.ExtDocType         = bf_doc-line.ext-doc-type
    bf_tt-doc-line.FactOrder          = bf_doc-line.fact-order
    bf_tt-doc-line.Sts                = bf_doc-line.status_
    bf_tt-doc-line.FactQnty           = bf_doc-line.fact-qnty
    bf_tt-doc-line.PriceAvrgRubl      = bf_doc-line.price-rubl
    bf_tt-doc-line.PriceAvrgBase      = bf_doc-line.price-base
    bf_tt-doc-line.PrtOk              = bf_doc-line.prt-ok
    bf_tt-doc-line.PrtRoot            = bf_doc-line.prt-root             .
    run r-cost in this-procedure (input  bf_doc-line.doc-code,
                                  input  bf_doc-line.artic,
                                  input  bf_doc-line.prod-type,
                                  input  bf_doc-line.prod-code,
                                  output varfact-qnty,
                                  output varvat-pc,
                                  output varslt-pc,
                                  output bf_tt-doc-line.SumSignBaseAcc,
                                  output bf_tt-doc-line.SumSignRublAcc,
                                  output bf_tt-doc-line.SumSignVatBaseAcc,
                                  output bf_tt-doc-line.SumSignVatRublAcc,
                                  output bf_tt-doc-line.SumSignSltBaseAcc,
                                  output bf_tt-doc-line.SumSignSltRublAcc,
                                  output bf_tt-doc-line.SumSignTaxThreeBaseAcc,
                                  output bf_tt-doc-line.SumSignTaxThreeRublAcc,
                                  output bf_tt-doc-line.SumSignTransportBaseAcc,
                                  output bf_tt-doc-line.SumSignTransportRublAcc,
                                  output bf_tt-doc-line.SumSignOtherBaseAcc,
                                  output bf_tt-doc-line.SumSignOtherRublAcc,
                                  output bf_tt-doc-line.SumSignExciseBaseAcc,
                                  output bf_tt-doc-line.SumSignExciseRublAcc) no-error.
    if error-status:error then do:
      return error return-value.
    end.
    run r-sale in this-procedure (input  bf_doc-line.doc-code,
                                  input  bf_doc-line.artic,
                                  input  bf_doc-line.prod-type,
                                  input  bf_doc-line.prod-code,
                                  output varfact-qnty,
                                  output varvat-pc,
                                  output varslt-pc,
                                  output bf_tt-doc-line.SumSignBaseDoc,
                                  output bf_tt-doc-line.SumSignRublDoc,
                                  output bf_tt-doc-line.SumSignVatBaseDoc,
                                  output bf_tt-doc-line.SumSignVatRublDoc,
                                  output bf_tt-doc-line.SumSignSltBaseDoc,
                                  output bf_tt-doc-line.SumSignSltRublDoc,
                                  output bf_tt-doc-line.SumSignTaxThreeBaseDoc,
                                  output bf_tt-doc-line.SumSignTaxThreeRublDoc,
                                  output bf_tt-doc-line.SumSignTransportBaseDoc,
                                  output bf_tt-doc-line.SumSignTransportRublDoc,
                                  output bf_tt-doc-line.SumSignOtherBaseDoc,
                                  output bf_tt-doc-line.SumSignOtherRublDoc,
                                  output bf_tt-doc-line.SumSignExciseBaseDoc,
                                  output bf_tt-doc-line.SumSignExciseRublDoc)  no-error.
    if error-status:error then do:
      return error return-value.
    end.
    if bf_trn-doc.ext-doc-type = 'ie':U then do:
      assign
        bf_tt-doc-line.SupplQnty          = bf_doc-line.cli-qnty
        bf_tt-doc-line.SupplRate          = bf_doc-line.cli-base-rate
        bf_tt-doc-line.PriceAvrgSuppl     = bf_doc-line.price-cli
        bf_tt-doc-line.UnitSuppl          = bf_doc-line.unit-cli
        bf_tt-doc-line.VatPcAcc           = bf_doc-line.vat-pc
        bf_tt-doc-line.SltPcAcc           = bf_doc-line.slt-pc
        bf_tt-doc-line.LineNum            = bf_doc-line.line-num
        bf_tt-doc-line.TaxThreeSupplSale  = bf_doc-line.road-tax
        bf_tt-doc-line.TransportBase      = bf_doc-line.transport-base
        bf_tt-doc-line.TransportRubl      = bf_doc-line.transport-rubl
        bf_tt-doc-line.OtherBase          = bf_doc-line.other-base
        bf_tt-doc-line.OtherRubl          = bf_doc-line.other-rubl .
    end.
    else do:
      assign
        bf_tt-doc-line.SltPcDoc           = bf_doc-line.slt-pc
        bf_tt-doc-line.VatPcDoc           = bf_doc-line.vat-pc
        bf_tt-doc-line.TaxThreeDocSale        = bf_doc-line.road-tax
        bf_tt-doc-line.ExciseDocSale      = bf_doc-line.excise .
    end.
    if bf_trn-doc.ext-doc-type <> 'vt':U              or
       bf_trn-doc.ext-doc-type <> 'vp':U         or
       bf_trn-doc.ext-doc-type <> 'ap':U   or
       bf_trn-doc.ext-doc-type <> 'mp':U or
       bf_trn-doc.ext-doc-type <> 'pc':U   then do:
      assign
        bf_tt-doc-line.DocQnty = bf_doc-line.doc-qnty.
    end.
    if custvalue = "yes" then do:
      assign
        bf_tt-doc-line.WtBrutto = bf_doc-line.wt-brutto
        bf_tt-doc-line.NumPlace = bf_doc-line.num-place .
    end.
    if varis-petrol and
       not varis-pieces then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_getwtqty in g#lib-trn3 (  input bf_doc-line.doc-code ,
                        input bf_doc-line.artic ,
                        input bf_doc-line.prod-type ,
                        input bf_doc-line.prod-code ,
                       output v-before-qnty ,
                       output v-after-qnty ,
                       output v-fact-qnty ,
                       output v-abs-fact-qnty ) no-error.
      assign
        bf_tt-doc-line.Density      = bf_doc-line.fact-density
        bf_tt-doc-line.Temperature  = bf_doc-line.temperature
        bf_tt-doc-line.BeforeKgQnty = v-before-qnty
        bf_tt-doc-line.FactKgQnty   = v-fact-qnty
        bf_tt-doc-line.AfterKgQnty  = v-after-qnty
      .
    end.
    if bf_trn-doc.ext-doc-type = 'vt':U          or
       bf_trn-doc.ext-doc-type = 'vp':U     or
       bf_trn-doc.ext-doc-type = 'ap':U   or
       bf_trn-doc.ext-doc-type = 'mp':U or
       bf_trn-doc.ext-doc-type = 'pc':U   then do:
      assign
        bf_tt-doc-line.BeforeQnty         = (if available bf-bef_doc-line-sum then bf-bef_doc-line-sum.fact-qnty else ?)
        bf_tt-doc-line.BeforeBaseAcc      = (if available bf-bef_doc-line-sum then bf-bef_doc-line-sum.cost-sum-base else ?)
        bf_tt-doc-line.BeforeRublAcc      = (if available bf-bef_doc-line-sum then bf-bef_doc-line-sum.cost-sum-rubl else ?)
        bf_tt-doc-line.BeforeSale         = (if available bf-bef_doc-line-sum then (if varr-b = "base" then bf-bef_doc-line-sum.sale-sum-base else bf-bef_doc-line-sum.sale-sum-rubl) else ?)
        bf_tt-doc-line.AfterQnty          = bf_doc-line.doc-qnty
        bf_tt-doc-line.AfterBaseAcc       = (if available bf-aft_doc-line-sum then bf-aft_doc-line-sum.cost-sum-base else ?)
        bf_tt-doc-line.AfterRublAcc       = (if available bf-aft_doc-line-sum then bf-aft_doc-line-sum.cost-sum-rubl else ?)
        bf_tt-doc-line.AfterSale          = (if available bf-aft_doc-line-sum then (if varr-b = "base" then bf-aft_doc-line-sum.sale-sum-base else bf-aft_doc-line-sum.sale-sum-rubl) else ?)
        bf_tt-doc-line.ExtraQnty          = (if available bf-ext_doc-line-sum     then bf-ext_doc-line-sum.fact-qnty         else ?)
        bf_tt-doc-line.ExtraCliQnty       = (if available bf-ext-cli_doc-line-sum then bf-ext-cli_doc-line-sum.fact-qnty     else ?)
        bf_tt-doc-line.ExtraBaseAcc       = (if available bf-ext_doc-line-sum     then bf-ext_doc-line-sum.cost-sum-base     else ?)
        bf_tt-doc-line.ExtraRublAcc       = (if available bf-ext_doc-line-sum     then bf-ext_doc-line-sum.cost-sum-rubl     else ?)
        bf_tt-doc-line.ExtraSale          = (if available bf-ext_doc-line-sum     then (if varr-b = "base" then bf-ext_doc-line-sum.sale-sum-base else bf-ext_doc-line-sum.sale-sum-rubl) else ?)
        bf_tt-doc-line.MissQnty           = (if available bf-mis_doc-line-sum     then bf-mis_doc-line-sum.fact-qnty         else ?)
        bf_tt-doc-line.MissCliQnty        = (if available bf-mis-cli_doc-line-sum then bf-mis-cli_doc-line-sum.fact-qnty     else ?)
        bf_tt-doc-line.MissBaseAcc        = (if available bf-mis_doc-line-sum     then bf-mis_doc-line-sum.cost-sum-base     else ?)
        bf_tt-doc-line.MissRublAcc        = (if available bf-mis_doc-line-sum     then bf-mis_doc-line-sum.cost-sum-rubl     else ?)
        bf_tt-doc-line.MissSale           = (if available bf-mis_doc-line-sum     then (if varr-b = "base" then bf-mis_doc-line-sum.sale-sum-base else bf-mis_doc-line-sum.sale-sum-rubl) else ?)
        bf_tt-doc-line.WastageSale        = (if available bf-wst_doc-line-sum     then (if varr-b = "base" then bf-wst_doc-line-sum.sale-sum-base else bf-wst_doc-line-sum.sale-sum-rubl) else ?)
        bf_tt-doc-line.BeforeCliQnty      = (if available bf-bef-cli_doc-line-sum then bf-bef-cli_doc-line-sum.fact-qnty     else ?)
        bf_tt-doc-line.AfterCliQnty       = (if available bf-aft-cli_doc-line-sum then bf-aft-cli_doc-line-sum.fact-qnty     else ?)
        .
    end.
    if varis-petrol     and
       not varis-pieces and
       bf_trn-doc.ext-doc-type = 'ie':U  then do:
                        find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = bf_doc-line.doc-code and                                                         bf_doc-line-attr.gds-code  = bf_goods.gds-code    and                                                         bf_doc-line-attr.attr-code = "car-num"     no-lock no-error.                       if available bf_doc-line-attr then do:                         assign                                                                                bf_tt-doc-line.CarNum = bf_doc-line-attr.attr-value.                       end.
                  find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = bf_doc-line.doc-code and                                                         bf_doc-line-attr.gds-code  = bf_goods.gds-code    and                                                         bf_doc-line-attr.attr-code = "car-vol"     no-lock no-error.                       if available bf_doc-line-attr then do:                         assign                                                                                bf_tt-doc-line.CarVol = bf_doc-line-attr.attr-value.                       end.
                  find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = bf_doc-line.doc-code and                                                         bf_doc-line-attr.gds-code  = bf_goods.gds-code    and                                                         bf_doc-line-attr.attr-code = "tests"     no-lock no-error.                       if available bf_doc-line-attr then do:                         assign                                                                                bf_tt-doc-line.Tests = bf_doc-line-attr.attr-value.                       end.
                  find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = bf_doc-line.doc-code and                                                         bf_doc-line-attr.gds-code  = bf_goods.gds-code    and                                                         bf_doc-line-attr.attr-code = "autoentobj-type"     no-lock no-error.                       if available bf_doc-line-attr then do:                         assign                                                                                bf_tt-doc-line.AutoentObjType = bf_doc-line-attr.attr-value.                       end.
                  find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = bf_doc-line.doc-code and                                                         bf_doc-line-attr.gds-code  = bf_goods.gds-code    and                                                         bf_doc-line-attr.attr-code = "autoentobj-code"     no-lock no-error.                       if available bf_doc-line-attr then do:                         assign                                                                                bf_tt-doc-line.AutoentObjCode = bf_doc-line-attr.attr-value.                       end.
                  find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = bf_doc-line.doc-code and                                                         bf_doc-line-attr.gds-code  = bf_goods.gds-code    and                                                         bf_doc-line-attr.attr-code = "item-pour"     no-lock no-error.                       if available bf_doc-line-attr then do:                         assign                                                                                bf_tt-doc-line.ItemPour = bf_doc-line-attr.attr-value.                       end.
                  find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = bf_doc-line.doc-code and                                                         bf_doc-line-attr.gds-code  = bf_goods.gds-code    and                                                         bf_doc-line-attr.attr-code = "time-pour"     no-lock no-error.                       if available bf_doc-line-attr then do:                         assign                                                                                bf_tt-doc-line.TimePour = bf_doc-line-attr.attr-value.                       end.
                  find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = bf_doc-line.doc-code and                                                         bf_doc-line-attr.gds-code  = bf_goods.gds-code    and                                                         bf_doc-line-attr.attr-code = "tank-vol"     no-lock no-error.                       if available bf_doc-line-attr then do:                         assign                                                                                bf_tt-doc-line.TankVol = bf_doc-line-attr.attr-value.                       end.
                  find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = bf_doc-line.doc-code and                                                         bf_doc-line-attr.gds-code  = bf_goods.gds-code    and                                                         bf_doc-line-attr.attr-code = "tank-temp"     no-lock no-error.                       if available bf_doc-line-attr then do:                         assign                                                                                bf_tt-doc-line.TankTemp = bf_doc-line-attr.attr-value.                       end.
                  find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = bf_doc-line.doc-code and                                                         bf_doc-line-attr.gds-code  = bf_goods.gds-code    and                                                         bf_doc-line-attr.attr-code = "tank-water"     no-lock no-error.                       if available bf_doc-line-attr then do:                         assign                                                                                bf_tt-doc-line.TankWater = bf_doc-line-attr.attr-value.                       end.
                  find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = bf_doc-line.doc-code and                                                         bf_doc-line-attr.gds-code  = bf_goods.gds-code    and                                                         bf_doc-line-attr.attr-code = "tank-density"     no-lock no-error.                       if available bf_doc-line-attr then do:                         assign                                                                                bf_tt-doc-line.TankDensity = bf_doc-line-attr.attr-value.                       end.
                  find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = bf_doc-line.doc-code and                                                         bf_doc-line-attr.gds-code  = bf_goods.gds-code    and                                                         bf_doc-line-attr.attr-code = "tank-weight"     no-lock no-error.                       if available bf_doc-line-attr then do:                         assign                                                                                bf_tt-doc-line.TankWeight = bf_doc-line-attr.attr-value.                       end.
                  find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = bf_doc-line.doc-code and                                                         bf_doc-line-attr.gds-code  = bf_goods.gds-code    and                                                         bf_doc-line-attr.attr-code = "time-income"     no-lock no-error.                       if available bf_doc-line-attr then do:                         assign                                                                                bf_tt-doc-line.TimeIncome = bf_doc-line-attr.attr-value.                       end.
    end.
end.
end.
end procedure.
procedure xml-doc_create-barcode :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_tt-barcode for tt-barcode.
define buffer bf_doc-line   for ub.doc-line.
define buffer bf_goods      for ub.goods.
define buffer bf_trn-doc    for ub.trn-doc.
define buffer buf_bar-code  for ub.bar-code  .
define buffer buf_prod-bc   for ub.prod-bc  .
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
if error-status:error then do:
  return error substitute ("Не найден документ с номером &1.", pardoc-code).
end.
for each bf_doc-line where bf_doc-line.doc-code = pardoc-code no-lock on error undo, return error return-value :
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock no-error.
  if not available bf_goods then do:
    return error substitute ("Не найден товар: &1 &2 &3.", bf_doc-line.artic, bf_doc-line.prod-type, bf_doc-line.prod-code).
  end.
  for each buf_bar-code no-lock where
           buf_bar-code.gds-code = bf_goods.gds-code and
           buf_bar-code.unit-cli = bf_goods.unit-base :
            for each buf_prod-bc no-lock where
                     buf_prod-bc.b-code = buf_bar-code.b-code :
                      find first bf_tt-barcode where
                              bf_tt-barcode.doccode = pardoc-code and
                              bf_tt-barcode.barcode = buf_prod-bc.b-str and
                              bf_tt-barcode.gdscode = bf_goods.gds-code no-error .
                      if not available bf_tt-barcode then do:
                          create bf_tt-barcode.
                          assign
                            bf_tt-barcode.doccode = pardoc-code
                            bf_tt-barcode.barcode  = buf_prod-bc.b-str
                            bf_tt-barcode.gdscode = bf_goods.gds-code
                          .
                      end.
            end.
  end.
end.
end.
end procedure.
procedure xml-doc_create-dtl :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_tt-gds-dtl    for tt-gds-dtl.
define buffer bf_gds-dtl       for ub.gds-dtl.
define buffer bf_goods         for ub.goods.
define buffer bf-obj_clients   for ub.clients.
define buffer bf-prod_clients  for ub.clients.
define buffer bf_gds-prt       for ub.gds-prt.
define buffer bf_trn-doc       for ub.trn-doc.
define variable varb-code like ub.bar-code.b-code no-undo.
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
if error-status:error then do:
  return error substitute ("Не найден документ с номером &1.", pardoc-code).
end.
for each bf_gds-dtl where bf_gds-dtl.doc-code = pardoc-code no-lock
                          on error undo, return error return-value :
  find first bf_goods where bf_goods.artic     = bf_gds-dtl.artic     and
                            bf_goods.prod-type = bf_gds-dtl.prod-type and
                            bf_goods.prod-code = bf_gds-dtl.prod-code no-lock no-error.
  if error-status:error then do:
    return error substitute ("Не найдент товар: &1 &2 &3.", bf_gds-dtl.artic, bf_gds-dtl.prod-type, bf_gds-dtl.prod-code).
  end.
  find first bf-prod_clients where bf-prod_clients.obj-type = bf_gds-dtl.prod-type and
                                   bf-prod_clients.obj-code = bf_gds-dtl.prod-code no-lock.
  find first bf-obj_clients  where bf-obj_clients.obj-type = bf_gds-dtl.obj-type and
                                   bf-obj_clients.obj-code = bf_gds-dtl.obj-code no-lock.
  find first bf_gds-prt where bf_gds-prt.node-code = bf_gds-dtl.prt-code no-lock.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  bf_gds-prt.node-code
  ,output varb-code
  ) no-error .
  create bf_tt-gds-dtl.
  assign
    bf_tt-gds-dtl.DocCode            = bf_gds-dtl.doc-code
    bf_tt-gds-dtl.ExtDocType         = bf_trn-doc.ext-doc-type
    bf_tt-gds-dtl.Artic              = bf_gds-dtl.artic
    bf_tt-gds-dtl.ProdType           = bf_gds-dtl.prod-type
    bf_tt-gds-dtl.ProdCode           = bf_gds-dtl.prod-code
    bf_tt-gds-dtl.GdsCode            = bf_goods.gds-code
    bf_tt-gds-dtl.ProdName           = bf-prod_clients.obj-name
    bf_tt-gds-dtl.GdsName            = bf_goods.gds-name
    bf_tt-gds-dtl.PrtCode            = bf_gds-dtl.prt-code
    bf_tt-gds-dtl.BarCodeUnitBase    = varb-code
    bf_tt-gds-dtl.FullPrtName        = bf_gds-prt.f-name
    bf_tt-gds-dtl.ObjType            = bf_gds-dtl.obj-type
    bf_tt-gds-dtl.ObjCode            = bf_gds-dtl.obj-code
    bf_tt-gds-dtl.ObjName            = bf-obj_clients.obj-name
    bf_tt-gds-dtl.FactQnty           = bf_gds-dtl.fact-qnty
    bf_tt-gds-dtl.DocQnty            = bf_gds-dtl.doc-qnty
    bf_tt-gds-dtl.PriceRublDoc       = bf_gds-dtl.price-rubl
    bf_tt-gds-dtl.PriceBaseDoc       = bf_gds-dtl.price-base
    bf_tt-gds-dtl.DiscntRublDoc      = bf_gds-dtl.discnt-rubl
    bf_tt-gds-dtl.DiscntBaseDoc      = bf_gds-dtl.discnt-base
    bf_tt-gds-dtl.DiscntType         = bf_gds-dtl.discnt-type
    bf_tt-gds-dtl.DiscntPc           = bf_gds-dtl.discnt-pc
    bf_tt-gds-dtl.PriceBaseSale      = bf_gds-dtl.cur-base
    bf_tt-gds-dtl.Ov                 = bf_gds-dtl.ov                .
  if bf_trn-doc.ext-doc-type = 'vt':U or
     bf_trn-doc.ext-doc-type = 'vp':U         or
     bf_trn-doc.ext-doc-type = 'ap':U   or
     bf_trn-doc.ext-doc-type = 'mp':U or
     bf_trn-doc.ext-doc-type = 'pc':U   then do:
    assign
      bf_tt-gds-dtl.AfterQnty = bf_gds-dtl.fact-qnty.
  end.
end.
end.
end procedure.
procedure xml-doc_create-parts :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_tt-parts      for tt-parts.
define buffer bf_parts         for ub.parts.
define buffer bf_trn-doc       for ub.trn-doc.
define buffer bf-obj_clients   for ub.clients.
define buffer bf-prod_clients  for ub.clients.
define buffer bf-suppl_clients for ub.clients.
define buffer bf_goods         for ub.goods.
define buffer bf_country       for ub.country.
define buffer bf_currency      for ub.currency.
define buffer bf-contract       for ub.contract.
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
do on error undo, return error return-value :
  find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
  if error-status:error then do:
    return error substitute ("Не найден документ с номером &1.", pardoc-code).
  end.
  find first bf-obj_clients where bf-obj_clients.obj-type = bf_trn-doc.obj-type and
                                  bf-obj_clients.obj-code = bf_trn-doc.obj-code no-lock.
  for each bf_parts where bf_parts.out-code = pardoc-code no-lock on error undo, return error return-value :
    find first bf_goods where bf_goods.artic     = bf_parts.artic     and
                              bf_goods.prod-type = bf_parts.prod-type and
                              bf_goods.prod-code = bf_parts.prod-code no-lock no-error.
    if not available bf_goods then do:
      return error substitute ("Не найден товар &1 &2 &3.", bf_parts.artic, bf_parts.prod-type, bf_parts.prod-code).
    end.
    find first bf_country where bf_country.alpha1 = bf_goods.alpha1 no-lock no-error.
    find first bf-suppl_clients where bf-suppl_clients.obj-type = bf_parts.supp-type and
                                      bf-suppl_clients.obj-code = bf_parts.supp-code no-lock.
    find first bf-prod_clients where bf-prod_clients.obj-type = bf_parts.prod-type and
                                     bf-prod_clients.obj-code = bf_parts.prod-code no-lock.
    find first bf-contract no-lock where bf-contract.contract-code = bf_parts.contract-code and
                                         bf-contract.host-code     = bf_parts.host-code no-error .
    create bf_tt-parts.
    assign
      bf_tt-parts.ObjType            = bf_parts.obj-type
      bf_tt-parts.ObjCode            = bf_parts.obj-code
      bf_tt-parts.ObjName            = bf-obj_clients.obj-name
      bf_tt-parts.Artic              = bf_parts.artic
      bf_tt-parts.ProdType           = bf_parts.prod-type
      bf_tt-parts.ProdCode           = bf_parts.prod-code
      bf_tt-parts.GdsCode            = bf_goods.gds-code
      bf_tt-parts.ProdName           = bf-prod_clients.obj-name
      bf_tt-parts.GdsName            = bf_goods.gds-name
      bf_tt-parts.InCode             = bf_parts.in-code
      bf_tt-parts.OutCode            = bf_parts.out-code
      bf_tt-parts.ExtDocType         = bf_trn-doc.ext-doc-type
      bf_tt-parts.CountryAlphaOne    = (if available bf_country then bf_country.alpha1     else "":U)
      bf_tt-parts.CountryAlphaTwo    = (if available bf_country then bf_country.alpha2     else "":U)
      bf_tt-parts.CountryNumCode     = (if available bf_country then bf_country.num-code   else ?)
      bf_tt-parts.CountryLongName    = (if available bf_country then bf_country.long-name  else "XX неизвестна")
      bf_tt-parts.CountryShortName   = (if available bf_country then bf_country.short-name else "XX неизвестна")
      bf_tt-parts.PartCode           = bf_parts.part-code
      bf_tt-parts.Sign               = (if bf_parts.doc-type = 'при':U or bf_parts.doc-type = 'возврат':U or bf_parts.doc-type = 'инв':U then 1 else -1)
      bf_tt-parts.DocQnty            = bf_parts.qnty
      bf_tt-parts.PriceBaseAcc       = bf_parts.price-base
      bf_tt-parts.PriceRublAcc       = bf_parts.price-rubl
      bf_tt-parts.FactDate           = bf_parts.fact-date
      bf_tt-parts.FactNum            = bf_parts.fact-num
      bf_tt-parts.Sts                = bf_parts.status_
      bf_tt-parts.VatPcAcc           = bf_parts.VAT-pc
      bf_tt-parts.Ps                 = bf_parts.PS
      bf_tt-parts.PayCode            = bf_parts.pay-code
      bf_tt-parts.FactQnty           = bf_parts.fact-qnty
      bf_tt-parts.SupplType          = bf_parts.supp-type
      bf_tt-parts.SupplCode          = bf_parts.supp-code
      bf_tt-parts.SupplName          = bf-suppl_clients.obj-name
      bf_tt-parts.RsrvFree           = bf_parts.rsrv-free
      bf_tt-parts.DocType            = bf_parts.doc-type
      bf_tt-parts.PlCode             = bf_parts.pl-code
      bf_tt-parts.VatType            = bf_parts.VAT-type
      bf_tt-parts.SupplCrcCode       = bf_parts.exch-code
      bf_tt-parts.PriceSuppl         = bf_parts.price-cli
      bf_tt-parts.SupplRate          = bf_parts.cli-base-rate
      bf_tt-parts.SltPcAcc           = bf_parts.SLT-pc
      bf_tt-parts.HostCode           = bf_parts.host-code
      bf_tt-parts.IsSupp             = bf_parts.is-supp
      bf_tt-parts.RealQnty           = bf_parts.real-qnty
      bf_tt-parts.SltType            = bf_parts.SLT-type
      bf_tt-parts.CstCode            = bf_parts.cst-code
      bf_tt-parts.LastDate           = bf_parts.last-date
      bf_tt-parts.TaxThreeBaseAcc        = bf_parts.road-tax-base
      bf_tt-parts.TaxThreeRublAcc        = bf_parts.road-tax-rubl
      bf_tt-parts.TransportBaseAcc   = bf_parts.transport-base
      bf_tt-parts.TransportRublAcc   = bf_parts.transport-rubl
      bf_tt-parts.OtherBaseAcc       = bf_parts.other-base
      bf_tt-parts.OtherRublAcc       = bf_parts.other-rubl
      bf_tt-parts.ContractId         = bf_parts.contract-code
    .
if available bf-contract then do:
   assign
     bf_tt-parts.ContractNum            = bf-contract.contract-prn-code
     bf_tt-parts.ContractDate           = bf-contract.contract-date
   .
end.
else do:
   assign
     bf_tt-parts.ContractNum            = ""
     bf_tt-parts.ContractDate           = ?
   .
end.
assign
  price-rubl-with-tax-loc = bf_parts.price-rubl
  price-base-with-tax-loc = bf_parts.price-base
.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if bf_parts.out-code = 'free-zone':U     or
     bf_parts.out-code = 'out-zone':U   or
     bf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = bf_parts.out-code
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
   price-cli-with-tax-loc = bf_parts.price-cli
   cli-base-rate          = bf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if bf_parts.road-tax-base  = ? then 0 else bf_parts.road-tax-base)
           road-tax-rubl-loc  = (if bf_parts.road-tax-rubl  = ? then 0 else bf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if bf_parts.transport-base = ? then 0 else bf_parts.transport-base)
          transport-rubl-loc = (if bf_parts.transport-rubl = ? then 0 else bf_parts.transport-rubl)
          other-base-loc     = (if bf_parts.other-base     = ? then 0 else bf_parts.other-base)
          other-rubl-loc     = (if bf_parts.other-rubl     = ? then 0 else bf_parts.other-rubl)
          vat-pc-loc         = (if bf_parts.vat-pc         = ? then 0 else bf_parts.vat-pc)
          slt-pc-loc         = (if bf_parts.slt-pc         = ? then 0 else bf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (bf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if bf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if bf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / bf_parts.price-cli .
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
      bf_tt-parts.VatBaseAcc = vat-base-loc
      bf_tt-parts.VatRublAcc = vat-rubl-loc
      bf_tt-parts.SltBaseAcc = slt-base-loc
      bf_tt-parts.SltRublAcc = slt-rubl-loc .
    if bf_trn-doc.ext-doc-type = 'ie':U then do:
      find first bf_currency where bf_currency.curr-code = bf_parts.exch-code no-lock.
      assign
        bf_tt-parts.SupplQnty    = bf_parts.cli-qnty
        bf_tt-parts.SupplCrcAbbr = bf_currency.curr-abbr
        bf_tt-parts.SupplCrcName = bf_currency.curr-name .
    end.
  end.
end.
end procedure.
procedure xml-doc_create-attr :
define input parameter pardoc-code like ub.doc-attr.doc-code no-undo.
define buffer bf_tt-attr       for tt-attr.
define buffer bf_attr          for ub.doc-attr.
define buffer bf_trn-doc       for ub.trn-doc.
define variable v-type           as character no-undo .
define variable v-format         as character no-undo .
define variable v-fillin_width   as integer   no-undo .
define variable v-fillin_height  as integer   no-undo .
define variable v-label          as character no-undo .
define variable v-user-can-edit  as logical   no-undo .
define variable v-output-display as logical   no-undo .
define variable v-other          as character no-undo .
define variable v-proc-attr       as character no-undo .
define variable v-full-screen-val as character no-undo .
do on error undo, return error return-value :
  find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
  if error-status:error then do:
    return error substitute ("Не найден документ с номером &1.", pardoc-code).
  end.
  for each bf_attr where bf_attr.doc-code = pardoc-code no-lock on error undo, return error return-value :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input bf_attr.attr-code ,
                       output v-type ,
                       output v-format ,
                       output v-fillin_width ,
                       output v-fillin_height ,
                       output v-label ,
                       output v-user-can-edit ,
                       output v-output-display ,
                       output v-other  ,
                       output v-proc-attr ,
                       output v-full-screen-val ,
                       output v-sort
                       )  .
    if v-output-display = false then next .
    create bf_tt-attr.
    assign
      bf_tt-attr.DocCode             = bf_attr.doc-code
      bf_tt-attr.attr-code           = bf_attr.attr-code
      bf_tt-attr.attr-value          = bf_attr.attr-value
      bf_tt-attr.attr-type           = v-type
     .
  end.
end.
end procedure.
procedure xml-doc_export-doc :
  define input  parameter p-handle-callback as handle    no-undo .
  define input  parameter p-proc-name       as character no-undo .
  define buffer bf_tt-trn-doc     for tt-trn-doc .
  define buffer bf_tt-trn-doc-add for tt-trn-doc-add.
  define variable par-type as character no-undo.
  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-prefix = "    "
      v-suffix = chr(10)
    .
    for each bf_tt-trn-doc
    on error undo, return error return-value
    :
      find first bf_tt-trn-doc-add where bf_tt-trn-doc-add.DocCode = bf_tt-trn-doc.DocCode.
      run value(p-proc-name) in p-handle-callback
        (input '  <trn-doc>' + chr(10)
        ) .
                  run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DocCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.DocCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExtDocType', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ExtDocType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExtDocTypeName', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ExtDocTypeName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DocType', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.DocType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Internal', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Internal))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Sts', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Sts))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Flag', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Flag))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DocDate', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.DocDate, '99.99.9999':U))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ContractId', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ContractId))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ContractNum', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ContractNum))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ContractDate', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ContractDate, '99.99.9999':U))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BaseCrcRate', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.BaseCrcRate))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BaseCrcScale', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.BaseCrcScale))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'CliType', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.CliType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'CliCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.CliCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'CliName', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.CliName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PostIndex', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.PostIndex))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'City', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.City))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Address', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Address))) + v-suffix ) .
      if bf_tt-trn-doc.CliType = 'орг':U then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AddressAdd', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.AddressAdd))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PostAddress', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.PostAddress))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PostAddressAdd', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.PostAddressAdd))) + v-suffix ) .
      end.
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'EMail', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.EMail))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Fax', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Fax))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Phone', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Phone))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PhoneNote', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.PhoneNote))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Inn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Inn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'KPP', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.KPP))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'OKPO', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.OKPO))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'OKONH', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.OKONH))) + v-suffix ) .
      if bf_tt-trn-doc.CliType = 'орг':U then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ContactPerson', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ContactPerson))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Director', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Director))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'EnglName', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.EnglName))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'GenAccnt', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.GenAccnt))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Telex', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Telex))) + v-suffix ) .
      end.
      else do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Name', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Name))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Patronymic', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Patronymic))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PassNum', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.PassNum))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PassSer', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.PassSer))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'GivenBy', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.GivenBy))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Position', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Position))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PostBox', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.PostBox))) + v-suffix ) .
      end.
      if bf_tt-trn-doc.BankRublIsHave = yes then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BankNameRubl', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.BankNameRubl))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BankCodeRubl', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.BankCodeRubl))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BankAccRubl', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.BankAccRubl))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AddressBankRubl', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.AddressBankRubl))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AddressAddBankRubl', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.AddressAddBankRubl))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PBankAccRubl', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.PBankAccRubl))) + v-suffix ) .
      end.
      if bf_tt-trn-doc.BankBaseIsHave = yes then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BankNameBase', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.BankNameBase))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BankCodeBase', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.BankCodeBase))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BankAccBase', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.BankAccBase))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AddressBankBase', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.AddressBankBase))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AddressAddBankBase', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.AddressAddBankBase))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PBankAccBase', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.PBankAccBase))) + v-suffix ) .
      end.
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ObjType', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ObjType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ObjCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ObjCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ObjName', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ObjName))) + v-suffix ) .
                  run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AddressObj', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.AddressObj))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AddressAddObj', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.AddressAddObj))) + v-suffix ) .
      if bf_tt-trn-doc.ObjType = 'маг':U then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AcctObj', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.AcctObj))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DirectorObj', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.DirectorObj))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'GoodsManObj', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.GoodsManObj))) + v-suffix ) .
      end.
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PhoneObj', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.PhoneObj))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'StoreBossObj', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.StoreBossObj))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'StoreManObj', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.StoreManObj))) + v-suffix ) .
                  run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ShipNum', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ShipNum))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ShipDate', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ShipDate, '99.99.9999':U))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'OrdNum', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.OrdNum))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Office', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Office))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'FactDate', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.FactDate, '99.99.9999':U))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'FactNum', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.FactNum))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'FactOrder', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.FactOrder))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'FactQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.FactQnty))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumFactBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SumFactBaseAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumFactRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SumFactRublAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'VatType', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.VatType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SltType', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SltType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Wrkr', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Wrkr))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Agnt', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Agnt))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Boss', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Boss))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PayCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.PayCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Creid', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Creid))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PrintRubl', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.PrintRubl))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PS', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.PS))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Ov', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.Ov))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'HostCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.HostCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'HostName', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.HostName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'RsrvDate', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.RsrvDate, '99.99.9999':U))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'RsrvTerm', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.RsrvTerm))) + v-suffix ) .
                  run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PostIndexOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.PostIndexOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'CityOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.CityOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AddressOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.AddressOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AddressAddOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.AddressAddOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PostAddressOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.PostAddressOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PostAddressAddOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.PostAddressAddOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'EMailOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.EMailOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'FaxOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.FaxOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PhoneOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.PhoneOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PhoneNoteOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.PhoneNoteOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'InnOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.InnOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'KPPOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.KPPOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'OKPOOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.OKPOOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'OKONHOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.OKONHOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ContactPersonOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.ContactPersonOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DirectorOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.DirectorOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'EnglNameOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.EnglNameOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'GenAccntOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.GenAccntOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TelexOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.TelexOwn))) + v-suffix ) .
      if bf_tt-trn-doc-add.OwnBankRublIsHave = yes then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BankNameRublOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.BankNameRublOwn))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BankCodeRublOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.BankCodeRublOwn))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BankAccRublOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.BankAccRublOwn))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AddressBankRublOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.AddressBankRublOwn))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AddressAddBankRublOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.AddressAddBankRublOwn))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PBankAccRublOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.PBankAccRublOwn))) + v-suffix ) .
      end.
      if bf_tt-trn-doc-add.OwnBankBaseIsHave = yes then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BankNameBaseOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.BankNameBaseOwn))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BankCodeBaseOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.BankCodeBaseOwn))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BankAccBaseOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.BankAccBaseOwn))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AddressBankBaseOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.AddressBankBaseOwn))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AddressAddBankBaseOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.AddressAddBankBaseOwn))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PBankAccBaseOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.PBankAccBaseOwn))) + v-suffix ) .
      end.
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'KOPFOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.KOPFOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SOEIOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.SOEIOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BranchOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.BranchOwn))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PropertyOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc-add.PropertyOwn))) + v-suffix ) .
                  run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TotLines', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.TotLines))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'FactTime', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.FactTime))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'RetSupp', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.RetSupp))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BgeDate', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.BgeDate, '99.99.9999':U))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SctDate', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SctDate, '99.99.9999':U))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AccDate', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.AccDate, '99.99.9999':U))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'InvNum', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.InvNum))) + v-suffix ) .
      if varshift = "yes" then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ShiftNum', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ShiftNum))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ShiftDate', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ShiftDate, '99.99.9999':U))) + v-suffix ) .
      end.
      if bf_tt-trn-doc.ExtDocType = 'ie':U then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SupplCrcCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SupplCrcCode))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SupplCrcAbbr', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SupplCrcAbbr))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SupplCrcName', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SupplCrcName))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SupplCrcDate', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SupplCrcDate, '99.99.9999':U))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SupplCrcRate', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SupplCrcRate))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SupplCrcScale', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SupplCrcScale))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumCheckFactSuppl', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SumCheckFactSuppl))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumFactSuppl', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SumFactSuppl))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'VatFactBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.VatFactBaseAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'VatFactRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.VatFactRublAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SltFactBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SltFactBaseAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SltFactRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SltFactRublAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumDocBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SumDocBaseAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumDocRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SumDocRublAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'OvervalueFactSaleacc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.OvervalueFactSaleacc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TaxThreeFactSaleAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.TaxThreeFactSaleAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExciseFactSaleAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ExciseFactSaleAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TransportExpSuppl', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.TransportExpSuppl))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'OtherExpSuppl', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.OtherExpSuppl))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SupplQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SupplQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'CstCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.CstCode))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExpenseOwn', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ExpenseOwn))) + v-suffix ) .
      end.
      else do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'VatFactBaseDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.VatFactBaseDoc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'VatFactRublDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.VatFactRublDoc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SltFactBaseDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SltFactBaseDoc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SltFactRublDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SltFactRublDoc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumDocBaseDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SumDocBaseDoc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumDocRublDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SumDocRublDoc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'OvervalueFactSaledoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.OvervalueFactSaledoc))) + v-suffix ) .
      end.
      if bf_tt-trn-doc.OutCode <> ? and
         bf_tt-trn-doc.OutCode <> "" then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'OutCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.OutCode))) + v-suffix ) .
      end.
      if bf_tt-trn-doc.ExtDocType = 'vt':U              OR
         bf_tt-trn-doc.extdoctype = 'vp':U         or
         bf_tt-trn-doc.extdoctype = 'ap':U   or
         bf_tt-trn-doc.extdoctype = 'mp':U or
         bf_tt-trn-doc.extdoctype = 'pc':U   then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BefQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.BefQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumBefBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SumBefBaseAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumBefRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SumBefRublAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExtraQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ExtraQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExtraSupplQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ExtraSupplQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExtraFactBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ExtraFactBaseAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExtraFactRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ExtraFactRublAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExtraFactSale', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ExtraFactSale))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'MissQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.MissQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'MissCliQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.MissCliQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'MissFactBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.MissFactBaseAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'MissFactRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.MissFactRublAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'MissFactSale', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.MissFactSale))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'WastageFactSale', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.WastageFactSale))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BefSupplQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.BefSupplQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AftSupplQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.AftSupplQnty))) + v-suffix ) .
      end.
      else do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DocQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.DocQnty))) + v-suffix ) .
      end.
      if bf_tt-trn-doc.ExtDocType  <> 'ie':U and
         bf_tt-trn-doc.ExtDocType  <> 'vt':U       and
         bf_tt-trn-doc.extdoctype <> 'vp':U         and
         bf_tt-trn-doc.extdoctype <> 'ap':U   and
         bf_tt-trn-doc.extdoctype <> 'mp':U and
         bf_tt-trn-doc.extdoctype <> 'pc':U   then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DscFactBaseDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.DscFactBaseDoc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumFactBaseDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SumFactBaseDoc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumFactRublDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.SumFactRublDoc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DscFactRublDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.DscFactRublDoc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DiscntType', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.DiscntType))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DiscntPc', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.DiscntPc))) + v-suffix ) .
      end.
                  run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ReasonCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-trn-doc.ReasonCode))) + v-suffix ) .
      run value(p-proc-name) in p-handle-callback
        (input '  </trn-doc>' + chr(10)
        ) .
    end.
  end.
end procedure.
procedure xml-doc_export-line :
  define input  parameter p-handle-callback as handle    no-undo .
  define input  parameter p-proc-name       as character no-undo .
  define buffer bf_tt-doc-line for tt-doc-line .
  define buffer bf_goods       for ub.goods.
  define variable varis-petrol as logical   no-undo.
  define variable varis-pieces as logical   no-undo.
  define variable custvalue    as character no-undo.
  define variable custtype     as character no-undo.
  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-prefix = "    "
      v-suffix = chr(10)
    .
    run gbl/conf-rd.p ("is-custm" , "", "", 0, "", "", "", no, output custvalue, output custtype) no-error.
    for each bf_tt-doc-line on error undo, return error return-value :
      find first bf_goods where bf_goods.artic     = bf_tt-doc-line.artic    and
                                bf_goods.prod-type = bf_tt-doc-line.ProdType and
                                bf_goods.prod-code = bf_tt-doc-line.ProdCode no-lock.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf_goods.artic
  ,  input bf_goods.prod-type
  ,  input bf_goods.prod-code
  , output varis-petrol
  , output varis-pieces
  ) no-error.
      if error-status:error then do:
        return error return-value.
      end.
      run value(p-proc-name) in p-handle-callback
        (input '  <doc-line>' + chr(10)
        ) .
                  run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DocCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.DocCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Artic', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.Artic))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ProdType', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.ProdType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ProdCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.ProdCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'GdsCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.GdsCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ProdName', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.ProdName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'GdsName', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.GdsName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'EnglName', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.EnglName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'LabelName', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.LabelName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'GrpCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.GrpCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'GrpFullName', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.GrpFullName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'GrpName', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.GrpName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'UnitBase', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.UnitBase))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ObjType', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.ObjType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ObjCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.ObjCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ObjName', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.ObjName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExtDocType', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.ExtDocType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'FactOrder', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.FactOrder))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Sts', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.Sts))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'FactQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.FactQnty))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PriceAvrgRubl', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.PriceAvrgRubl))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PriceAvrgBase', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.PriceAvrgBase))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PrtOk', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.PrtOk))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PrtRoot', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.PrtRoot))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignBaseAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignRublAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignVatBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignVatBaseAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignVatRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignVatRublAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignSltBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignSltBaseAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignSltRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignSltRublAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignTaxThreeBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignTaxThreeBaseAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignTaxThreeRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignTaxThreeRublAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignTransportBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignTransportBaseAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignTransportRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignTransportRublAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignOtherBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignOtherBaseAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignOtherRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignOtherRublAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignExciseBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignExciseBaseAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignExciseRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignExciseRublAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignBaseDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignBaseDoc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignRublDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignRublDoc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignVatBaseDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignVatBaseDoc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignVatRublDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignVatRublDoc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignSltBaseDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignSltBaseDoc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignSltRublDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignSltRublDoc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignTaxThreeBaseDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignTaxThreeBaseDoc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignTaxThreeRublDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignTaxThreeRublDoc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignTransportBaseDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignTransportBaseDoc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignTransportRublDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignTransportRublDoc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignOtherBaseDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignOtherBaseDoc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignOtherRublDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignOtherRublDoc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignExciseBaseDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignExciseBaseDoc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SumSignExciseRublDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SumSignExciseRublDoc))) + v-suffix ) .
      if bf_tt-doc-line.ExtDocType = 'ie':U then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SupplQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SupplQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SupplRate', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SupplRate))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PriceAvrgSuppl', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.PriceAvrgSuppl))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'UnitSuppl', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.UnitSuppl))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'VatPcAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.VatPcAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SltPcAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SltPcAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'LineNum', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.LineNum))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TaxThreeSupplSale', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.TaxThreeSupplSale))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TransportBase', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.TransportBase))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TransportRubl', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.TransportRubl))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'OtherBase', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.OtherBase))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'OtherRubl', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.OtherRubl))) + v-suffix ) .
      end.
      else do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SltPcDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.SltPcDoc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'VatPcDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.VatPcDoc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TaxThreeDocSale', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.TaxThreeDocSale))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExciseDocSale', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.ExciseDocSale))) + v-suffix ) .
      end.
      if bf_tt-doc-line.ExtDocType   <> 'vt':U and
         bf_tt-doc-line.extdoctype <> 'vp':U         and
         bf_tt-doc-line.extdoctype <> 'ap':U   and
         bf_tt-doc-line.extdoctype <> 'mp':U and
         bf_tt-doc-line.extdoctype <> 'pc':U
      then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DocQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.DocQnty))) + v-suffix ) .
      end.
      if custvalue = "yes" then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'WtBrutto', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.WtBrutto))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'NumPlace', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.NumPlace))) + v-suffix ) .
      end.
      if varis-petrol and
         not varis-pieces then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Density', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.Density))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Temperature', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.Temperature))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BeforeKgQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.BeforeKgQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'FactKgQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.FactKgQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AfterKgQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.AfterKgQnty))) + v-suffix ) .
      end.
      if bf_tt-doc-line.ExtDocType = 'vt':U or
         bf_tt-doc-line.extdoctype = 'vp':U         or
         bf_tt-doc-line.extdoctype = 'ap':U   or
         bf_tt-doc-line.extdoctype = 'mp':U or
         bf_tt-doc-line.extdoctype = 'pc':U
      then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BeforeQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.BeforeQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BeforeBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.BeforeBaseAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BeforeRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.BeforeRublAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BeforeSale', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.BeforeSale))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AfterQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.AfterQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AfterBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.AfterBaseAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AfterRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.AfterRublAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AfterSale', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.AfterSale))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExtraQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.ExtraQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExtraBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.ExtraBaseAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExtraRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.ExtraRublAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExtraSale', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.ExtraSale))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'MissQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.MissQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'MissBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.MissBaseAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'MissRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.MissRublAcc))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'MissSale', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.MissSale))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'WastageSale', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.WastageSale))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BeforeCliQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.BeforeCliQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AfterCliQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.AfterCliQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExtraCliQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.ExtraCliQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'MissCliQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.MissCliQnty))) + v-suffix ) .
      end.
      if varis-petrol     and
         not varis-pieces and
         bf_tt-doc-line.ExtDocType = 'ie':U  then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'CarNum', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.CarNum))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'CarVol', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.CarVol))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Tests', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.Tests))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AutoentObjType', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.AutoentObjType))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AutoentObjCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.AutoentObjCode))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ItemPour', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.ItemPour))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TimePour', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.TimePour))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TankVol', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.TankVol))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TankTemp', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.TankTemp))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TankWater', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.TankWater))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TankDensity', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.TankDensity))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TankWeight', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.TankWeight))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TimeIncome', xml-doc_ReplaceSpecSymbols(string(bf_tt-doc-line.TimeIncome))) + v-suffix ) .
      end.
      run value(p-proc-name) in p-handle-callback
          (input '  </doc-line>' + chr(10)
          ) .
    end.
  end.
end procedure.
procedure xml-doc_export-barcode :
  define input  parameter p-handle-callback as handle    no-undo .
  define input  parameter p-proc-name       as character no-undo .
  define buffer bf_tt-barcode for tt-barcode .
  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-prefix = "    "
      v-suffix = chr(10)
    .
    for each bf_tt-barcode on error undo, return error return-value :
      run value(p-proc-name) in p-handle-callback
          (input '   <barcodedop>' + chr(10)
          ) .
                  run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DocCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-barcode.DocCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'GdsCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-barcode.GdsCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BarCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-barcode.BarCode))) + v-suffix ) .
      run value(p-proc-name) in p-handle-callback
          (input '   </barcodedop>' + chr(10)
          ) .
    end.
  end.
end procedure.
procedure xml-doc_export-dtl :
  define input  parameter p-handle-callback as handle    no-undo .
  define input  parameter p-proc-name       as character no-undo .
  define buffer bf_tt-gds-dtl for tt-gds-dtl .
  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-prefix = "    "
      v-suffix = chr(10)
    .
    for each bf_tt-gds-dtl on error undo, return error return-value :
      run value(p-proc-name) in p-handle-callback
          (input '  <gds-dtl>' + chr(10)
          ) .
                  run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DocCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.DocCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExtDocType', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.ExtDocType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Artic', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.Artic))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ProdType', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.ProdType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ProdCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.ProdCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'GdsCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.GdsCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ProdName', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.ProdName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'GdsName', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.GdsName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PrtCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.PrtCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'BarCodeUnitBase', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.BarCodeUnitBase))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'FullPrtName', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.FullPrtName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ObjType', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.ObjType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ObjCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.ObjCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ObjName', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.ObjName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'FactQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.FactQnty))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DocQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.DocQnty))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PriceRublDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.PriceRublDoc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PriceBaseDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.PriceBaseDoc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DiscntRublDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.DiscntRublDoc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DiscntBaseDoc', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.DiscntBaseDoc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DiscntType', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.DiscntType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DiscntPc', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.DiscntPc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PriceBaseSale', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.PriceBaseSale))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Ov', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.Ov))) + v-suffix ) .
      if bf_tt-gds-dtl.ExtDocType = 'vt':U or
         bf_tt-gds-dtl.extdoctype = 'vp':U         or
         bf_tt-gds-dtl.extdoctype = 'ap':U   or
         bf_tt-gds-dtl.extdoctype = 'mp':U or
         bf_tt-gds-dtl.extdoctype = 'pc':U
           then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'AfterQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-gds-dtl.AfterQnty))) + v-suffix ) .
      end.
      run value(p-proc-name) in p-handle-callback
          (input '  </gds-dtl>' + chr(10)
          ) .
    end.
  end.
end procedure.
procedure xml-doc_export-parts :
  define input  parameter p-handle-callback as handle    no-undo .
  define input  parameter p-proc-name       as character no-undo .
  define buffer bf_tt-parts for tt-parts .
  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-prefix = "    "
      v-suffix = chr(10)
    .
    for each bf_tt-parts on error undo, return error return-value :
      run value(p-proc-name) in p-handle-callback
          (input '  <parts>' + chr(10)
          ) .
                  run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ObjType', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.ObjType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ObjCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.ObjCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ObjName', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.ObjName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ContractId', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.ContractId))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ContractNum', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.ContractNum))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ContractDate', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.ContractDate, '99/99/9999':U))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Artic', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.Artic))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ProdType', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.ProdType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ProdCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.ProdCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'GdsCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.GdsCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ProdName', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.ProdName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'GdsName', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.GdsName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'InCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.InCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'OutCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.OutCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'ExtDocType', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.ExtDocType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'CountryAlphaOne', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.CountryAlphaOne))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'CountryAlphaTwo', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.CountryAlphaTwo))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'CountryNumCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.CountryNumCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'CountryLongName', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.CountryLongName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'CountryShortName', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.CountryShortName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PartCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.PartCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Sign', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.Sign))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DocQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.DocQnty))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PriceBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.PriceBaseAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PriceRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.PriceRublAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'FactDate', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.FactDate, '99/99/9999':U))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'FactNum', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.FactNum))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Sts', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.Sts))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'VatPcAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.VatPcAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'Ps', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.Ps))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PayCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.PayCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'FactQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.FactQnty))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SupplType', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.SupplType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SupplCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.SupplCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SupplName', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.SupplName))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'RsrvFree', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.RsrvFree))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DocType', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.DocType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PlCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.PlCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'VatType', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.VatType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SupplCrcCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.SupplCrcCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'PriceSuppl', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.PriceSuppl))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SupplRate', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.SupplRate))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SltPcAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.SltPcAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'HostCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.HostCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'IsSupp', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.IsSupp))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'RealQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.RealQnty))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SltType', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.SltType))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'CstCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.CstCode))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'LastDate', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.LastDate, '99/99/9999':U))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TaxThreeBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.TaxThreeBaseAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TaxThreeRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.TaxThreeRublAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TransportBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.TransportBaseAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'TransportRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.TransportRublAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'OtherBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.OtherBaseAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'OtherRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.OtherRublAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'VatBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.VatBaseAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'VatRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.VatRublAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SltBaseAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.SltBaseAcc))) + v-suffix ) .
            run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SltRublAcc', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.SltRublAcc))) + v-suffix ) .
      if bf_tt-parts.ExtDocType = 'ie':U then do:
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SupplQnty', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.SupplQnty))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SupplCrcAbbr', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.SupplCrcAbbr))) + v-suffix ) .
                run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'SupplCrcName', xml-doc_ReplaceSpecSymbols(string(bf_tt-parts.SupplCrcName))) + v-suffix ) .
      end.
      run value(p-proc-name) in p-handle-callback
          (input '  </parts>' + chr(10)
          ) .
    end.
  end.
end procedure.
procedure xml-doc_export-attr :
  define input  parameter p-handle-callback as handle    no-undo .
  define input  parameter p-proc-name       as character no-undo .
  define buffer bf_tt-attr for tt-attr .
      define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-prefix = "    "
      v-suffix = chr(10)
    .
    find first bf_tt-attr no-error .
      if available bf_tt-attr then do:
        run value(p-proc-name) in p-handle-callback
            (input '  <doc-attr>' + chr(10)
            ) .
                        run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', 'DocCode', xml-doc_ReplaceSpecSymbols(string(bf_tt-attr.DocCode))) + v-suffix ) .
        for each bf_tt-attr on error undo, return error return-value :
        if lookup(substring(bf_tt-attr.attr-code,1,1) ,"0,1,2,3,4,5,6,7,8,9") > 0 then bf_tt-attr.attr-code = "F" + bf_tt-attr.attr-code.
                    run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', bf_tt-attr.attr-code , xml-doc_ReplaceSpecSymbols(string(bf_tt-attr.attr-value))) + v-suffix ) .
        end.
        run value(p-proc-name) in p-handle-callback
            (input '  </doc-attr>' + chr(10)
            ) .
    end.
  end.
end procedure.
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure r-cost :
  define input  parameter v-doc-code       like ub.doc-line.doc-code          no-undo .
  define input  parameter v-artic          like ub.doc-line.artic             no-undo .
  define input  parameter v-prod-type      like ub.doc-line.prod-type         no-undo .
  define input  parameter v-prod-code      like ub.doc-line.prod-code         no-undo .
  define output parameter v-fact-qnty      like ub.ot-line.fact-qnty       no-undo .
  define output parameter v-vat-pc         like ub.doc-line.vat-pc         no-undo .
  define output parameter v-slt-pc         like ub.doc-line.slt-pc         no-undo .
  define output parameter v-sum-base       like ub.ot-line.sum-base        no-undo .
  define output parameter v-sum-rubl       like ub.ot-line.sum-rubl        no-undo .
  define output parameter v-vat-base       like ub.ot-line.vat-base        no-undo .
  define output parameter v-vat-rubl       like ub.ot-line.vat-rubl        no-undo .
  define output parameter v-slt-base       like ub.ot-line.slt-base        no-undo .
  define output parameter v-slt-rubl       like ub.ot-line.slt-rubl        no-undo .
  define output parameter v-road-tax-base  like ub.ot-line.road-tax-base   no-undo .
  define output parameter v-road-tax-rubl  like ub.ot-line.road-tax-rubl   no-undo .
  define output parameter v-transport-base like ub.ot-line.transport-base  no-undo .
  define output parameter v-transport-rubl like ub.ot-line.transport-rubl  no-undo .
  define output parameter v-other-base     like ub.ot-line.other-base      no-undo .
  define output parameter v-other-rubl     like ub.ot-line.other-rubl      no-undo .
  define output parameter v-excise-base    like ub.ot-line.excise-base     no-undo .
  define output parameter v-excise-rubl    like ub.ot-line.excise-rubl     no-undo .
  do
  on error undo, return error
  :
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
    def var v-parts-fact-qnty as decimal   no-undo .
    define buffer buf_parts    for ub.parts    .
    define buffer buf_goods    for ub.goods    .
    define buffer buf_trn-doc  for ub.trn-doc  .
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = v-doc-code
        and buf_doc-line.artic     = v-artic
        and buf_doc-line.prod-type = v-prod-type
        and buf_doc-line.prod-code = v-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info6 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа"  skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = v-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info6 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info6 skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_goods.gds-type = 'т':U then do:
          for each buf_parts no-lock
            where buf_parts.out-code  = buf_trn-doc.doc-code
              and buf_parts.obj-type  = buf_trn-doc.obj-type
              and buf_parts.obj-code  = buf_trn-doc.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
          on error undo, return error
          :
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
              v-parts-fact-qnty  = (if buf_trn-doc.doc-type = 'при':U
                                    or buf_trn-doc.doc-type = 'возврат':U
                                    or buf_trn-doc.doc-type = 'инв':U
                                    then buf_parts.fact-qnty
                                    else - buf_parts.fact-qnty
                                   )
            .
            assign
              v-fact-qnty           = v-fact-qnty      + v-parts-fact-qnty
              v-sum-base            = v-sum-base       +  ( price-base-with-tax-loc * v-parts-fact-qnty )
              v-sum-rubl            = v-sum-rubl       +  ( price-rubl-with-tax-loc * v-parts-fact-qnty )
              v-vat-base            = v-vat-base       +  ( vat-base-loc            * v-parts-fact-qnty )
              v-vat-rubl            = v-vat-rubl       +  ( vat-rubl-loc            * v-parts-fact-qnty )
              v-slt-base            = v-slt-base       +  ( slt-base-loc            * v-parts-fact-qnty )
              v-slt-rubl            = v-slt-rubl       +  ( slt-rubl-loc            * v-parts-fact-qnty )
              v-road-tax-base       = v-road-tax-base  +  ( road-tax-base-loc       * v-parts-fact-qnty )
              v-road-tax-rubl       = v-road-tax-rubl  +  ( road-tax-rubl-loc       * v-parts-fact-qnty )
              v-excise-base         =   0
              v-excise-rubl         =   0
              v-transport-base      = v-transport-base +   (transport-base-loc      * v-parts-fact-qnty )
              v-transport-rubl      = v-transport-rubl +   (transport-rubl-loc      * v-parts-fact-qnty )
              v-other-base          = v-other-base     +   (other-base-loc          * v-parts-fact-qnty )
              v-other-rubl          = v-other-rubl     +   (other-rubl-loc          * v-parts-fact-qnty )
            .
        end.
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
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
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
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
            v-vat-pc              = vat-pc-loc
            v-slt-pc              = slt-pc-loc
        .
    end.
    else do:
          assign
            v-parts-fact-qnty           = (if buf_trn-doc.doc-type = 'при':U
                                      or buf_trn-doc.doc-type = 'возврат':U
                                      or buf_trn-doc.doc-type = 'инв':U
                                      then buf_doc-line.fact-qnty
                                      else - buf_doc-line.fact-qnty
                                    )
          .
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
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
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
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
            v-fact-qnty           = v-fact-qnty      + v-parts-fact-qnty
            v-vat-pc              = vat-pc-loc
            v-slt-pc              = slt-pc-loc
            v-sum-base            = v-sum-base       + (price-base-with-tax-loc * v-parts-fact-qnty)
            v-sum-rubl            = v-sum-rubl       + (price-rubl-with-tax-loc * v-parts-fact-qnty)
            v-vat-base            = v-vat-base       + (vat-base-loc            * v-parts-fact-qnty)
            v-vat-rubl            = v-vat-rubl       + (vat-rubl-loc            * v-parts-fact-qnty)
            v-slt-base            = v-slt-base       + (slt-base-loc            * v-parts-fact-qnty)
            v-slt-rubl            = v-slt-rubl       + (slt-rubl-loc            * v-parts-fact-qnty)
            v-road-tax-base       =  0
            v-road-tax-rubl       =  0
            v-excise-base         =  0
            v-excise-rubl         =  0
            v-transport-base      =  0
            v-transport-rubl      =  0
            v-other-base          =  0
            v-other-rubl          =  0
          .
    end.
  end.
end procedure.
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure r-sale :
  define input parameter  p-doc-code          like ub.doc-line.doc-code          no-undo .
  define input parameter  p-artic             like ub.doc-line.artic             no-undo .
  define input parameter  p-prod-type         like ub.doc-line.prod-type         no-undo .
  define input parameter  p-prod-code         like ub.doc-line.prod-code         no-undo .
  define output parameter p-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
  define output parameter p-vat-pc            like ub.doc-line.vat-pc         no-undo .
  define output parameter p-slt-pc            like ub.doc-line.slt-pc         no-undo .
  define output parameter p-sum-base          like ub.ot-line.sum-base        no-undo .
  define output parameter p-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
  define output parameter p-vat-base          like ub.ot-line.vat-base        no-undo .
  define output parameter p-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
  define output parameter p-slt-base          like ub.ot-line.slt-base        no-undo .
  define output parameter p-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
  define output parameter p-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
  define output parameter p-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
  define output parameter p-transport-base    like ub.ot-line.transport-base  no-undo .
  define output parameter p-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
  define output parameter p-other-base        like ub.ot-line.other-base      no-undo .
  define output parameter p-other-rubl        like ub.ot-line.other-rubl      no-undo .
  define output parameter p-excise-base       like ub.ot-line.excise-base     no-undo .
  define output parameter p-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
  define variable vss-description as character no-undo initial "r-sale-01: обработка продажных цен товара".
  do
  on error undo, return error
  :
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
    define variable v-gds-dtl-fact-qnty as decimal no-undo .
    define buffer buf_gds-dtl  for ub.gds-dtl .
    define buffer buf_goods    for ub.goods .
    define buffer buf_trn-doc  for ub.trn-doc .
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info11 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info11 skip
        "Не найден документ" skip
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
            ASSIGN
                p-fact-qnty           = p-fact-qnty     + v-gds-dtl-fact-qnty
                p-sum-base            = p-sum-base      + price-base-with-tax-sale  * v-gds-dtl-fact-qnty
                p-sum-rubl            = p-sum-rubl      + price-rubl-with-tax-sale  * v-gds-dtl-fact-qnty
                p-vat-base            = p-vat-base      + vat-base-sale             * v-gds-dtl-fact-qnty
                p-vat-rubl            = p-vat-rubl      + vat-rubl-sale             * v-gds-dtl-fact-qnty
                p-slt-base            = p-slt-base      + slt-base-sale             * v-gds-dtl-fact-qnty
                p-slt-rubl            = p-slt-rubl      + slt-rubl-sale             * v-gds-dtl-fact-qnty
                p-road-tax-base       = p-road-tax-base + road-tax-base-sale        * v-gds-dtl-fact-qnty
                p-road-tax-rubl       = p-road-tax-rubl + road-tax-rubl-sale        * v-gds-dtl-fact-qnty
                p-excise-base         = p-excise-base   + excise-base-sale          * v-gds-dtl-fact-qnty
                p-excise-rubl         = p-excise-rubl   + excise-rubl-sale          * v-gds-dtl-fact-qnty
                p-other-base          = p-other-base    + discnt-base-sale          * v-gds-dtl-fact-qnty
                p-other-rubl          = p-other-rubl    + discnt-rubl-sale          * v-gds-dtl-fact-qnty
            .
        end.
    end.
    assign
        p-transport-base      = 0
        p-transport-rubl      = 0
        p-vat-pc              = buf_doc-line.vat-pc
        p-slt-pc              = buf_doc-line.slt-pc
    .
  end.
  if p-fact-qnty      = ?
  or p-vat-pc         = ?
  or p-slt-pc         = ?
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
      vss-include-info11 skip
      "Получены неопределенные значения" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "fact-qnty     " p-fact-qnty      skip
      "vat-pc        " p-vat-pc         skip
      "slt-pc        " p-slt-pc         skip
      "sum-base      " p-sum-base       skip
      "sum-rubl      " p-sum-rubl       skip
      "vat-base      " p-vat-base       skip
      "vat-rubl      " p-vat-rubl       skip
      "slt-base      " p-slt-base       skip
      "slt-rubl      " p-slt-rubl       skip
      "road-tax-base " p-road-tax-base  skip
      "road-tax-rubl " p-road-tax-rubl  skip
      "transport-base" p-transport-base skip
      "transport-rubl" p-transport-rubl skip
      "other-base    " p-other-base     skip
      "other-rubl    " p-other-rubl     skip
      "excise-base   " p-excise-base    skip
      "excise-rubl   " p-excise-rubl    skip
      view-as alert-box error .
    undo, return error .
  end.
end procedure.
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
define variable vss-include-info15 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_grplib_grp no-undo
    field sel           as character
    field nabor         as character
    field full-name     as character
    field print-code    as character
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field calc-method   as character
    field round-method  as character
    field increase-pc   as decimal
    field min-marg      as character
    field max-marg      as character
    field cli-type      as character
    field cli-code      as integer
    field notcorr      as character
    field name          as character
    field level         as integer
    field mark          as character
    index pi is primary unique sort-name
    index fn full-name
    index nc is unique node-code
    index sl sel
    index uc upper-code
.
define temp-table temp_grplib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    index pi is primary unique sort-name
    index fn full-name
    index lv level
    index it is-terminal
.
define temp-table temp_found-result-nodelist no-undo
    field node-code     as recid
    field processed     as logical
    field sort-name     as character
    field full-name     as character
    index pi is primary unique node-code
    index ps processed
.
define variable v-grplib-not-fill-extra-info        as logical      no-undo.
define variable v-grplib-no-warning-grp-amount      as logical      no-undo.
define variable v-grplib-grp-amount-for-load        as integer      no-undo.
procedure grplib-get-parameters :
define input parameter p-store-type     as character        no-undo.
define input parameter p-store-code     as integer          no-undo.
do
on error undo, return error
:
    assign
        v-grplib-not-fill-extra-info = no
    .
end.
end procedure.
procedure grplib-get-sort-name :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_gds-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
define variable vss-include-info16 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
procedure grplib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = 0
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_gds-grp.node-code
        .
    end.
end.
end procedure.
procedure grplib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
define output parameter p-found       as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run grplib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "grplib-expand-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_grplib_found-grp
    :
        delete temp_grplib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-name  = entry( v-counter, p-search-name, chr(2) )
            no-error .
            if not available buf_gds-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + ( if v-full-name = "" then "" else chr(47) )        + buf_gds-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_gds-grp.node-name
                    v-upper-code = buf_gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name = v-full-name + chr(47)
                        temp_grplib_found-grp.sort-name = v-sort-name
                        temp_grplib_found-grp.node-code = v-upper-code
                        temp_grplib_found-grp.level     = v-counter
                    .
                end.
            end.
        end.
        else do:
            for each buf_gds-grp no-lock
               where buf_gds-grp.upper-code = v-upper-code
                 and buf_gds-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    p-found = yes
                .
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else chr(47) )
                                                        + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_gds-grp.node-name
                    temp_grplib_found-grp.node-code = buf_gds-grp.node-code
                    temp_grplib_found-grp.level     = v-level
                .
            end.
            if p-found = no
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_grplib_found-grp
                :
                    delete temp_grplib_found-grp.
                end.
                assign
                    p-found = no
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define buffer buf_gds-grp           for ub.gds-grp.
    create temp_found-result-nodelist.
    assign
        temp_found-result-nodelist.node-code = p-start-node-code
        temp_found-result-nodelist.processed = no
    .
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-full-name
    ).
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-sort-name
    ).
    process-nodes:
    do while yes
    :
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.node-code = p-start-node-code
        .
        assign
            temp_found-result-nodelist.processed = yes
        .
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run grplib-is-terminal in this-procedure (
                  input buf_gds-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                    temp_grplib_found-grp.is-terminal = yes
                .
            end.
            else do:
                create temp_found-result-nodelist.
                assign
                    temp_found-result-nodelist.node-code = buf_gds-grp.node-code
                    temp_found-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_found-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_found-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_gds-grp.node-name + chr(47)
                        temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_gds-grp.node-name + chr(2)
                        temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                        temp_grplib_found-grp.is-terminal = no
                    .
                end.
            end.
        end.
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.processed = no
        no-error.
        if not available temp_found-result-nodelist
        then do:
            leave process-nodes.
        end.
        else do:
            assign
                p-start-node-code = temp_found-result-nodelist.node-code
                v-start-full-name = temp_found-result-nodelist.full-name
                v-start-sort-name = temp_found-result-nodelist.sort-name
            .
        end.
    end.
end.
end procedure.
procedure grplib-expand-name :
define input parameter p-start-name as character        no-undo.
define output parameter p-end-name  as character        no-undo.
    define variable v-is-terminal   as logical      no-undo.
    define variable v-found         as character    no-undo.
    define buffer buf_temp_grplib_found-grp     for temp_grplib_found-grp.
do
for buf_temp_grplib_found-grp
on error undo, return error
:
    run grplib-find-grp-by-full-name in this-procedure (
          input p-start-name
        , input no
        , output v-found
    ) no-error.
    run grplib-get-max-substring in this-procedure (
                input length( p-start-name )
              , output p-end-name
    ) no-error .
    if error-status :error
    then do:
        assign
            p-end-name = ""
        .
    end.
    else do:
        find first temp_grplib_found-grp
            where temp_grplib_found-grp.full-name = p-end-name
        no-error.
        if available temp_grplib_found-grp
        then do:
            find first buf_temp_grplib_found-grp
                where buf_temp_grplib_found-grp.full-name begins p-end-name
                and recid( buf_temp_grplib_found-grp ) <> recid( temp_grplib_found-grp )
            no-error.
            if not available buf_temp_grplib_found-grp
            then do:
                run grplib-is-terminal in this-procedure (
                    input temp_grplib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-max-substring :
do
on error undo, return error
:
define input parameter p-min-substring-length   as integer      no-undo.
define output parameter p-substring             as character    no-undo.
        define variable v-char-counter  as integer           no-undo.
        define variable v-current-char  as character         no-undo.
        define variable v-names-counter  as integer           no-undo.
        define variable v-base-string   as character         no-undo.
        assign
            v-char-counter  = p-min-substring-length
        .
        find first temp_grplib_found-grp no-error.
        if not available temp_grplib_found-grp
        then do:
            undo, return error "grplib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string  = temp_grplib_found-grp.full-name
                v-char-counter = 0
            .
            counter-block:
            do while yes
            on error undo, return error "grplib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_grplib_found-grp
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_grplib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
                    then do:
                        leave counter-block.
                    end.
                end.
                if v-names-counter = 1
                then do:
                    assign
                        p-substring = v-base-string
                    .
                    return.
                end.
            end.
            assign
                p-substring = substring( v-base-string, 1, v-char-counter - 1 )
            .
        end.
end.
end procedure.
procedure grplib-is-terminal :
do
on error undo, return error "Ошибка процедуры grplib-is-terminal"
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = p-node-code
    no-error .
    if not available buf_gds-grp
    then do:
        assign
            p-is-terminal = yes
        .
    end.
    else do:
        assign
            p-is-terminal = no
        .
    end.
end.
end procedure.
procedure grplib-have-goods :
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-have-goods   as logical      no-undo.
    define buffer buf_goods         for ub.goods.
    find first buf_goods no-lock
         where buf_goods.grp-code = p-node-code
    no-error .
    if available buf_goods
    then do:
        assign
            p-have-goods = yes
        .
    end.
    else do:
        assign
            p-have-goods = no
        .
    end.
end.
end procedure.
procedure grplib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    search-grp:
    for each buf_gds-grp no-lock
        where buf_gds-grp.node-code > p-start-code
    :
        if index( buf_gds-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_gds-grp.node-code
                v-found      = yes
            .
            run grplib-get-full-name in this-procedure (
                  input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
            end.
            leave search-grp.
        end.
    end.
    if v-found = yes
    then do:
    end.
    else do:
        assign
            p-full-name  = ""
            p-found-code = 0
        .
    end.
end.
end procedure.
procedure grplib-analyze-grp-name :
do
on error undo, return error
:
define input parameter p-grp-name       as character            no-undo.
define input parameter p-upper-code     as integer              no-undo.
define output parameter p-error-message as character init ""    no-undo.
    define variable v-char-list     as character    no-undo.
    define variable v-char-counter  as integer      no-undo.
    define variable v-full-name     as character    no-undo.
    if p-grp-name = "" then do:
        assign
            p-error-message = "Название группы не может быть пустым.".
        .
    end.
    else do:
        assign
            v-char-list = "47,92,58,63,34,60,62,171,187,183"
        .
        do v-char-counter = 1 to num-entries( v-char-list )
        :
            if index( p-grp-name, chr( integer( entry( v-char-counter, v-char-list ) ) ) ) <> 0
            then do:
                assign
                    p-error-message = 'Название группы не может содержать символы /\:*?"<>|«»·'
                .
                return.
            end.
        end.
        if p-upper-code > 0
        then do:
            run grplib-get-full-name in this-procedure (
                  input p-upper-code
                , output v-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
            end.
            if length( v-full-name ) + 1 + length( p-grp-name ) > 350
            then do:
                assign
                    p-error-message = 'Полное название группы не может содержать более 350 символов.'
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-lvl-num :
define input parameter p-node-code  as integer      no-undo.
define output parameter p-lvl-num   as integer      no-undo.
    define variable v-full-name    as character    no-undo.
do
on error undo, return error
:
    run grplib-get-full-name in this-procedure (
          input p-node-code
        , output v-full-name
    ).
    assign
        p-lvl-num = num-entries( v-full-name, chr(47) ) - 1
    .
    if p-lvl-num = -1
    then do:
        assign
            p-lvl-num = 0
        .
    end.
end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer bf_clients for ub.clients.
define buffer bf_trn-doc for ub.trn-doc.
define buffer bf_shop    for ub.shop.
define buffer bf_store   for ub.store.
define stream trn-out.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock.
find first bf_clients where bf_clients.obj-type = bf_trn-doc.obj-type and
                            bf_clients.obj-code = bf_trn-doc.obj-code no-lock.
if bf_clients.obj-type = 'маг':U then do:
  find first bf_shop where bf_shop.obj-code = bf_clients.obj-code no-lock.
  assign
    varshift = string(bf_shop.shift-on).
end.
else do:
  find first bf_store where bf_store.obj-code = bf_clients.obj-code no-lock.
  assign
    varshift = string(bf_store.shift-on).
end.
assign
varfile-name = str-encode( input replace(pardoc-code , "*", "$")
                          ,input ''
                          ,input '\/:*?"<>|':U
                          )
.
run xml-doc_clear-doc in this-procedure no-error.
if error-status :error then do:
  return error substitute( "Ошибка при очистке временной таблицы заголовка документа &1 &2.", error-status :get-message( 1 ), return-value ).
end.
run xml-doc_clear-line in this-procedure no-error.
if error-status :error then do:
  return error substitute( "Ошибка при очистке временной таблицы линий документа &1 &2.", error-status :get-message( 1 ), return-value ).
end.
run xml-doc_clear-dtl in this-procedure no-error.
if error-status :error then do:
  return error substitute( "Ошибка при очистке временной таблицы признаков документа &1 &2.", error-status :get-message( 1 ), return-value ).
end.
run xml-doc_clear-parts in this-procedure no-error.
if error-status :error then do:
  return error substitute( "Ошибка при очистке временной таблицы партий документа &1 &2.", error-status :get-message( 1 ), return-value ).
end.
run xml-doc_clear-attr in this-procedure no-error.
if error-status :error then do:
  return error substitute( "Ошибка при очистке временной таблицы атрибутов документа &1 &2.", error-status :get-message( 1 ), return-value ).
end.
run xml-doc_create-doc in this-procedure (input pardoc-code) no-error.
if error-status :error then do:
  return error substitute( "Ошибка при создании временной таблицы заголовка документа &1 &2.", error-status :get-message( 1 ), return-value ).
end.
run xml-doc_create-line in this-procedure (input pardoc-code) no-error.
if error-status :error then do:
  return error substitute( "Ошибка при создании временной таблицы линий документа &1 &2.", error-status :get-message( 1 ), return-value ).
end.
run xml-doc_create-barcode in this-procedure (input pardoc-code) no-error.
if error-status:error then do:
  return error substitute ("Ошибка при создании временной таблицы линий дополнительных бар-кодов &1 &2.", error-status:get-message(1), return-value).
end.
run xml-doc_create-dtl in this-procedure (input pardoc-code) no-error.
if error-status :error then do:
  return error substitute( "Ошибка при создании временной таблицы признаков документа &1 &2.", error-status :get-message( 1 ), return-value ).
end.
run xml-doc_create-parts in this-procedure (input pardoc-code) no-error.
if error-status :error then do:
  return error substitute( "Ошибка при создании временной таблицы партий документа &1" + chr(10) + "&2", error-status :get-message( 1 ), return-value ).
end.
run xml-doc_create-attr in this-procedure (input pardoc-code) no-error.
if error-status :error then do:
  return error substitute( "Ошибка при создании временной таблицы атрибутов документа &1" + chr(10) + "&2", error-status :get-message( 1 ), return-value ).
end.
if paroutput-file = ?  or
   paroutput-file = "" then do:
   output stream trn-out to value ("./" + varfile-name + ".tmp").
   run write-string in this-procedure
     (input '<?xml version="1.0" encoding="windows-1251"?>':u + chr(10) + '<root>':u + chr(10)
     ).
end.
else do:
  output stream trn-out to value(paroutput-file) append.
end.
run xml-doc_export-doc in this-procedure (input this-procedure,
                                          input "write-string") no-error.
if error-status :error then do:
  return error "Ошибка при экспорте заголовка документа".
end.
run xml-doc_export-line in this-procedure (input this-procedure,
                                           input "write-string") no-error.
if error-status :error then do:
  return error "Ошибка при экспорте линии документа".
end.
run xml-doc_export-barcode in this-procedure (input this-procedure,
                                           input "write-string") no-error.
if error-status:error then do:
  return error "Ошибка при экспорте линии доп.бк.".
end.
run xml-doc_export-dtl in this-procedure (input this-procedure,
                                          input "write-string") no-error.
if error-status :error then do:
  return error "Ошибка при экспорте признаков документа".
end.
run xml-doc_export-parts in this-procedure (input this-procedure,
                                            input "write-string") no-error.
if error-status :error then do:
  return error "Ошибка при экспорте партий документа".
end.
run xml-doc_export-attr in this-procedure (input this-procedure,
                                            input "write-string") no-error.
if error-status :error then do:
  return error "Ошибка при экспорте атрибутов документа".
end.
if paroutput-file = ?  or
   paroutput-file = "" then do:
   run write-string in this-procedure
     (input '</root>':u + chr(10)).
end.
output stream trn-out close.
if paroutput-file = ?  or
   paroutput-file = "" then do:
   if search ("./" + varfile-name + ".xml") <> ? then do:
     os-delete value ("./" + varfile-name + ".xml").
   end.
   os-copy value ("./" + varfile-name + ".tmp") value ("./" + varfile-name + ".xml").
   os-delete value ("./" + varfile-name + ".tmp").
end.
procedure write-string :
 define input parameter parstring as character no-undo.
 put stream trn-out unformatted parstring.
end.
