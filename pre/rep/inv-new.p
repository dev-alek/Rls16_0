block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-trn-doc-recid      as recid            no-undo.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: inv-new.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/inv-new.p $":U .
define variable vss-description as character no-undo initial "Новая форма для инвентаризации.":U .
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
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_p-fmt_string-part no-undo
    field str-key       as integer
    field string-part   as character
    index pi is primary unique
        str-key
.
define variable v-p-fmt-1-str-key    as integer      no-undo.
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
        v-p-fmt-1-str-key   = 0
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
            v-p-fmt-1-str-key = v-p-fmt-1-str-key + 1
        .
        assign
            buf_temp_p-fmt_string-part.str-key      = v-p-fmt-1-str-key
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
define variable vss-include-info2 as character format "X(65)" no-undo
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
    define stream out-stream.
    define variable v-inv-new-line-counter  as integer      no-undo.
    define variable v-single-line           as character    no-undo.
    define variable v-today                 as date         no-undo.
    define variable v-time                  as integer      no-undo.
    define variable v-print-rubl            as logical      no-undo.
    define variable v-page-after-sum        as decimal      no-undo.
    define variable v-page-before-sum       as decimal      no-undo.
    define variable v-page-surplus-sum      as decimal      no-undo.
    define variable v-page-lack-sum         as decimal      no-undo.
    define variable v-doc-after-sum         as decimal      no-undo.
    define variable v-doc-before-sum        as decimal      no-undo.
    define variable v-doc-surplus-sum       as decimal      no-undo.
    define variable v-doc-lack-sum          as decimal      no-undo.
    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.
do
on error undo, return error
:
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    find first buf_trn-doc no-lock
         where recid( buf_trn-doc ) = p-trn-doc-recid
    no-error.
    if not available buf_trn-doc
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Неверно выбран документ."
        view-as alert-box error.
        undo, return error .
    end.
    if buf_trn-doc.ext-doc-type <> 'vt':U
    then do:
        message
                "Ошибка выбора документа."
            skip(1)
            skip "Форма предназначена только для печати"
            skip "документов инвентаризации."
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-single-line  = fill( "-", 230 )
        v-inv-new-line-counter = 0
        v-print-rubl   = ( if PrintRubl = yes then yes else no )
    .
if session :set-wait-state( "compiler" ) then.
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(230) .
    run fmtcli-get-client in this-procedure (
          input buf_trn-doc.obj-type
        , input buf_trn-doc.obj-code
    ).
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    put stream Out-Stream
        skip space(5)
            substitute( "Объект: (&1 &2) &3"
                        , buf_trn-doc.obj-type
                        , buf_trn-doc.obj-code
                        , v-fmtcli-name      )              format "X(193)"
        skip(1) space(5)
            substitute( "Дата печати: &1"
                        , string( v-today, "99/99/9999" ) ) format "X(23)"
            "Инвентаризация"                                   at 5 + 23 + 60
    .
    run print-header in this-procedure (
        input yes
    ).
    for each buf_doc-line no-lock
       where buf_doc-line.doc-code = buf_trn-doc.doc-code
    by buf_doc-line.artic
    on error undo, return error
    :
        assign
            v-inv-new-line-counter  = v-inv-new-line-counter    + 1
        .
        run print-line in this-procedure (
              input buf_doc-line.doc-code
            , input buf_doc-line.artic
            , input buf_doc-line.prod-type
            , input buf_doc-line.prod-code
            , input v-print-rubl
        ).
    end.
    run print-footer in this-procedure (
        input v-print-rubl
    ).
    output stream Out-Stream close.
if session :set-wait-state( "" ) then.
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
procedure print-header :
define input parameter p-first  as logical      no-undo.
do
on error undo, return error
:
    if line-counter( Out-stream ) = 0
    or p-first = yes
    then do:
        put stream Out-Stream
            skip string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) format "X(13)"   at right-field( 198, 13)
        .
        put stream Out-Stream
            skip
                v-single-line           format "X(194)"    at 5
            skip
                "|"                                     at 5
                "N"                                     at center-field( 5, 10, 1 )
                "|"                                     at 10
                "Код"                                   at center-field( 10, 20, 3 )
                "|"                                     at 20
                "Артикул"                               at center-field( 20, 37, 7 )
                "|"                                     at 37
                "Наименование товара"                   at 37 + 2
                "|"                                     at 70
                "Ед."                                   at center-field( 70, 75, 3 )
                "|"                                     at 75
                "Учетный"                               at center-field( 75, 87, 7 )
                "|"                                     at 87
                "Продажная"                             at center-field( 87, 98, 9 )
                "|"                                     at 98
                "Сумма по ТН"                           at center-field( 98, 114, 11 )
                "|"                                     at 114
                "Количество"                            at center-field( 114, 126, 10 )
                "|"                                     at 126
                "Сумма"                                 at center-field( 126, 142, 5 )
                "|"                                     at 142
                "Излишки"                               at center-field( 142, 154, 7 )
                "|"                                     at 154
                "Сумма"                                 at center-field( 154, 170, 5 )
                "|"                                     at 170
                "Недостача"                             at center-field( 170, 182, 9 )
                "|"                                     at 182
                "Сумма"                                 at center-field( 182, 198, 5 )
                "|"                                     at 198
            skip
                "|"                                     at 5
                "п/п"                                   at center-field( 5, 10, 3 )
                "|"                                     at 10
                "|"                                     at 20
                "|"                                     at 37
                "|"                                     at 70
                "изм."                                  at center-field( 70, 75, 4 )
                "|"                                     at 75
                "остаток"                               at center-field( 75, 87, 7 )
                "|"                                     at 87
                "цена"                                  at center-field( 87, 98, 4 )
                "|"                                     at 98
                "|"                                     at 114
                "по факту"                              at center-field( 114, 126, 8 )
                "|"                                     at 126
                "по факту"                              at center-field( 126, 142, 8 )
                "|"                                     at 142
                "|"                                     at 154
                "излишков"                              at center-field( 154, 170, 8 )
                "|"                                     at 170
                "|"                                     at 182
                "недостачи"                             at center-field( 182, 198, 9 )
                "|"                                     at 198
            skip
                "|"                                     at 5
                v-single-line                           format "X(192)"
                "|"
        .
    end.
end.
end procedure.
procedure print-line :
define input parameter p-doc-code   as character        no-undo.
define input parameter p-artic      as character        no-undo.
define input parameter p-prod-type  as character        no-undo.
define input parameter p-prod-code  as integer          no-undo.
define input parameter p-print-rubl as logical          no-undo.
    define variable v-price-sale            as decimal      no-undo.
    define variable v-before-qnty           as decimal      no-undo.
    define variable v-before-sum            as decimal      no-undo.
    define variable v-before-sum-rubl       as decimal      no-undo.
    define variable v-before-sum-base       as decimal      no-undo.
    define variable v-after-qnty            as decimal      no-undo.
    define variable v-after-sum             as decimal      no-undo.
    define variable v-after-sum-rubl        as decimal      no-undo.
    define variable v-after-sum-base        as decimal      no-undo.
    define variable v-surplus-qnty          as decimal      no-undo.
    define variable v-surplus-sum           as decimal      no-undo.
    define variable v-lack-qnty             as decimal      no-undo.
    define variable v-lack-sum              as decimal      no-undo.
    define buffer buf_doc-line      for doc-line.
    define buffer buf_goods         for goods.
do
on error undo, return error
:
    find first buf_goods no-lock
         where buf_goods.artic      = p-artic
           and buf_goods.prod-type  = p-prod-type
           and buf_goods.prod-code  = p-prod-code
    .
    find first buf_doc-line no-lock
         where buf_doc-line.doc-code  = p-doc-code
           and buf_doc-line.artic     = buf_goods.artic
           and buf_doc-line.prod-type = buf_goods.prod-type
           and buf_doc-line.prod-code = buf_goods.prod-code
    .
    run print-header in this-procedure (
        input no
    ).
    run get-before-and-after-inv-qnty in this-procedure (
          input p-doc-code
        , input buf_goods.gds-code
        , output v-before-qnty
        , output v-before-sum-rubl
        , output v-before-sum-base
        , output v-after-qnty
        , output v-after-sum-rubl
        , output v-after-sum-base
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка вычисления сумм до и после инвентаризации."
            skip(1)
            skip "Документ:" p-doc-code
            skip "Товар:" buf_goods.artic buf_goods.gds-name
            skip(1)
            skip "Строка товара в форме может содержать неверные данные."
        view-as alert-box warning.
        assign
            v-price-sale  = 0
            v-before-qnty = 0
            v-before-sum  = 0
            v-after-qnty  = 0
            v-after-sum   = 0
        .
    end.
    if p-print-rubl
    then do:
        assign
            v-before-sum = v-before-sum-rubl
            v-after-sum  = v-after-sum-rubl
            v-price-sale = v-before-sum-rubl / v-before-qnty
        .
    end.
    else do:
        assign
            v-before-sum = v-before-sum-base
            v-after-sum  = v-after-sum-base
            v-price-sale = v-before-sum-base / v-before-qnty
        .
    end.
    assign
        v-surplus-qnty  = 0
        v-surplus-sum   = 0
        v-lack-qnty     = 0
        v-lack-sum      = 0
    .
    if v-before-qnty < v-after-qnty
    then do:
        assign
            v-surplus-qnty = v-after-qnty - v-before-qnty
            v-surplus-sum  = v-after-sum  - v-before-sum
        .
    end.
    if v-before-qnty > v-after-qnty
    then do:
        assign
            v-lack-qnty = v-before-qnty - v-after-qnty
            v-lack-sum  = v-before-sum  - v-after-sum
        .
    end.
    put stream out-stream
        skip
            "|"                                         at 5
            v-inv-new-line-counter  format ">>>9"
            "|"                                         at 10
            buf_goods.gds-code      format "999999999"
            "|"                                         at 20
            p-artic                 format "X(16)"
            "|"                                         at 37
            buf_goods.gds-name      format "X(32)"
            "|"                                         at 70
            buf_goods.unit-base     format "X(4)"
            "|"                                         at 75
            v-before-qnty           format "->>>,>>9.99"
            "|"                                         at 87
            v-price-sale            format ">>>,>>9.99"
            "|"                                         at 98
            v-before-sum            format "->>>,>>>,>>9.99"
            "|"                                         at 114
            v-after-qnty            format "->>>,>>9.99"
            "|"                                         at 126
            v-after-sum             format "->>>,>>>,>>9.99"
            "|"                                         at 142
            v-surplus-qnty          format "->>>,>>9.99"
            "|"                                         at 154
            v-surplus-sum           format "->>>,>>>,>>9.99"
            "|"                                         at 170
            v-lack-qnty             format "->>>,>>9.99"
            "|"                                         at 182
            v-lack-sum              format "->>>,>>>,>>9.99"
            "|"                                         at 198
    .
    assign
        v-page-after-sum        = v-page-after-sum      + v-after-sum
        v-page-before-sum       = v-page-before-sum     + v-before-sum
        v-page-surplus-sum      = v-page-surplus-sum    + v-surplus-sum
        v-page-lack-sum         = v-page-lack-sum       + v-lack-sum
    .
    if line-counter( Out-stream ) + 2 > page-size( Out-stream )
    then do:
        run print-end-of-page in this-procedure (
            input yes
        ).
    end.
end.
end procedure.
procedure print-footer :
do
on error undo, return error
:
define input parameter p-print-rubl as logical      no-undo.
    define variable v-all-sum-cost as decimal       no-undo.
    run print-end-of-page in this-procedure (
        input no
    ).
    if line-counter( Out-stream ) + 10 > page-size( Out-stream )
    then do:
        page stream out-stream.
    end.
    put stream Out-Stream
        skip (1)
            "Всего по документу:   "                        at 5
            v-doc-before-sum            format "->>>,>>>,>>9.99"  at 98 + 1
            v-doc-after-sum             format "->>>,>>>,>>9.99"  at 126 + 1
            v-doc-surplus-sum           format "->>>,>>>,>>9.99"  at 154 + 1
            v-doc-lack-sum              format "->>>,>>>,>>9.99"  at 182 + 1
    .
    put stream Out-Stream
        skip (2)
            "Гл. Бухгалтер:_______________________________________________________________ "                       at 5
        skip (1)
            "Начальник розничной сети:____________________________________________________ "                       at 5
    .
end.
end procedure.
procedure print-end-of-page :
do
on error undo, return error
:
define input parameter p-print-continue-line    as logical      no-undo.
    put stream Out-Stream
        skip
            v-single-line           format "X(194)"     at 5
        skip
            "Итого: "                                       at 37
            v-page-before-sum       format "->>>,>>>,>>9.99"      at 98 + 1
            v-page-after-sum        format "->>>,>>>,>>9.99"      at 126 + 1
            v-page-surplus-sum      format "->>>,>>>,>>9.99"      at 154 + 1
            v-page-lack-sum         format "->>>,>>>,>>9.99"      at 182 + 1
    .
    if p-print-continue-line = yes
    then do:
        put stream Out-Stream
            skip
                v-single-line           format "X(194)"    at 5
            skip
                "Продолжение - на следующей странице"               at 30
        .
    end.
    assign
        v-doc-after-sum     = v-doc-after-sum     + v-page-after-sum
        v-doc-before-sum    = v-doc-before-sum    + v-page-before-sum
        v-doc-surplus-sum   = v-doc-surplus-sum   + v-page-surplus-sum
        v-doc-lack-sum      = v-doc-lack-sum      + v-page-lack-sum
    .
    assign
        v-page-after-sum   = 0
        v-page-before-sum  = 0
        v-page-surplus-sum = 0
        v-page-lack-sum    = 0
    .
end.
end procedure.
procedure get-before-and-after-inv-qnty :
define input parameter p-doc-code           as character        no-undo.
define input parameter p-gds-code           as integer          no-undo.
define output parameter p-before-qnty       as decimal          no-undo.
define output parameter p-before-sum-rubl   as decimal          no-undo.
define output parameter p-before-sum-base   as decimal          no-undo.
define output parameter p-after-qnty        as decimal          no-undo.
define output parameter p-after-sum-rubl    as decimal          no-undo.
define output parameter p-after-sum-base    as decimal          no-undo.
    define variable v-attr-value    as character     no-undo.
    define variable v-attr-type     as character     no-undo.
    define buffer buf_trn-doc-sum       for trn-doc-sum.
    define buffer buf_doc-line-sum      for doc-line-sum.
do
on error undo, return error
:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'addsum':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
    if lookup( 'bd':U, v-attr-value ) <> 0
    then do:
        find first buf_doc-line-sum no-lock
             where buf_doc-line-sum.doc-code = p-doc-code
               and buf_doc-line-sum.gds-code = p-gds-code
               and buf_doc-line-sum.sum-type = 'bd':U
        no-error.
        if available buf_doc-line-sum
        then do:
            assign
                p-before-qnty       = buf_doc-line-sum.fact-qnty
                p-before-sum-rubl   = buf_doc-line-sum.crsa-sum-rubl
                p-before-sum-base   = buf_doc-line-sum.crsa-sum-base
            .
        end.
        else do:
            message
                skip "Не найдена запись trn-doc-sum"
                skip(1)
                skip "Номер документа:" p-doc-code
                skip "Код товара:" p-gds-code
            view-as alert-box error.
            undo, return error .
        end.
    end.
    if lookup( 'ad':U, v-attr-value ) <> 0
    then do:
        find first buf_doc-line-sum no-lock
             where buf_doc-line-sum.doc-code = p-doc-code
               and buf_doc-line-sum.gds-code = p-gds-code
               and buf_doc-line-sum.sum-type = 'ad':U
        no-error.
        if available buf_doc-line-sum
        then do:
            assign
                p-after-qnty       = buf_doc-line-sum.fact-qnty
                p-after-sum-rubl   = buf_doc-line-sum.crsa-sum-rubl
                p-after-sum-base   = buf_doc-line-sum.crsa-sum-base
            .
        end.
        else do:
            message
                skip "Не найдена запись trn-doc-sum"
                skip(1)
                skip "Номер документа:" p-doc-code
                skip "Код товара:" p-gds-code
            view-as alert-box error.
            undo, return error .
        end.
    end.
end.
end procedure.
