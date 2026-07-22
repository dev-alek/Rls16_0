block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter Invers               as logical          no-undo.
    define stream out-stream.
    define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
    define variable vss-author      as character no-undo initial "$Author: expertek $":U .
    define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
    define variable vss-workfile    as character no-undo initial "$Workfile: torg-1.p $":U .
    define variable vss-archive     as character no-undo initial "$Archive: rep/torg-1.p $":U .
    define variable vss-description as character no-undo initial "Акт о приемке товаров":U .
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
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
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.
define variable vss-include-info15 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_sheet2_line-data no-undo
    field sheet-name        as character
    field xl-line-id        as integer
    field counter           as integer
    field Name              as character
    field gdscode           as character
    field EI                as character
    field OKEI              as character
    field price             as character
    field AmountInPlSupp    as character
    field PlaceAmountSupp   as character
    field MassSupp          as character
    field SumSupp           as character
    field AmountInPlFact    as character
    field PlaceAmountFact   as character
    field MassFact          as character
    field SumFact           as character
    field sum               as character
    field VATpc             as character
    field VATsum            as character
    field AmountInPlDelt    as character
    field PlaceAmountDelt   as character
    field MassDelt          as character
    field SumDelt           as character
    field Sertif            as character
    index pi is primary unique
        xl-line-id
.
define variable v-torg1xl-sheet2-cur-data-row   as integer      no-undo.
define variable v-torg1xl-cell-file-name            as character    no-undo.
define variable v-torg1xl-data-file-name            as character    no-undo.
procedure torg1xl-init :
do
on error undo, return error
:
    assign
        v-torg1xl-sheet2-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-torg1xl-data-file-name
    ).
    output stream excel-line to value( v-torg1xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-torg1xl-cell-file-name
    ).
    output stream excel-cell to value( v-torg1xl-cell-file-name ).
    run torg1xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input "стр1,стр2,стр3":U
    ).
    if printrubl
    then do:
        run torg1xl-write-cell-data in this-procedure (
              input "стр1_valutCode":U
            , input "0":U
        ).
        run torg1xl-write-cell-data in this-procedure (
              input "стр2_valutCode":U
            , input "0":U
        ).
        run torg1xl-write-cell-data in this-procedure (
              input "стр3_valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run torg1xl-write-cell-data in this-procedure (
              input "стр1_valutCode":U
            , input "1":U
        ).
        run torg1xl-write-cell-data in this-procedure (
              input "стр2_valutCode":U
            , input "1":U
        ).
        run torg1xl-write-cell-data in this-procedure (
              input "стр3_valutCode":U
            , input "1":U
        ).
    end.
    run torg1xl-write-cell-data in this-procedure (
          input "стр2_columnList":U
        , input "counter,Name,gdscode,EI,OKEI,price,AmountInPlSupp,PlaceAmountSupp,MassSupp,SumSupp,AmountInPlFact,PlaceAmountFact,MassFact,SumFact,sum,VATpc,VATsum,AmountInPlDelt,PlaceAmountDelt,MassDelt,SumDelt,Sertif":U
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "стр2_columnType":U
        , input "I,S,S,S,S,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,S":U
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "стр2_subtotalList":U
        , input "PlaceAmountSupp,SumSupp,PlaceAmountFact,SumFact,sum,VATsum,PlaceAmountDelt,SumDelt":U
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "стр2_subtotalType":U
        , input "D,D,D,D,D,D,D,D":U
    ).
end.
end procedure.
procedure torg1xl-sheet2-write-line-data :
define input parameter p-Name              as character        no-undo.
define input parameter p-gdscode           as character        no-undo.
define input parameter p-EI                as character        no-undo.
define input parameter p-OKEI              as character        no-undo.
define input parameter p-price             as character        no-undo.
define input parameter p-AmountInPlSupp    as character        no-undo.
define input parameter p-PlaceAmountSupp   as character        no-undo.
define input parameter p-MassSupp          as character        no-undo.
define input parameter p-SumSupp           as character        no-undo.
define input parameter p-AmountInPlFact    as character        no-undo.
define input parameter p-PlaceAmountFact   as character        no-undo.
define input parameter p-MassFact          as character        no-undo.
define input parameter p-SumFact           as character        no-undo.
define input parameter p-sum               as character        no-undo.
define input parameter p-VATpc             as character        no-undo.
define input parameter p-VATsum            as character        no-undo.
define input parameter p-AmountInPlDelt    as character        no-undo.
define input parameter p-PlaceAmountDelt   as character        no-undo.
define input parameter p-MassDelt          as character        no-undo.
define input parameter p-SumDelt           as character        no-undo.
define input parameter p-Sertif            as character        no-undo.
    define buffer buf_temp_sheet2_line-data        for temp_sheet2_line-data.
do
for buf_temp_sheet2_line-data
on error undo, return error
:
    for each buf_temp_sheet2_line-data
    :
        delete buf_temp_sheet2_line-data.
    end.
    create buf_temp_sheet2_line-data.
    assign
        v-torg1xl-sheet2-cur-data-row           = v-torg1xl-sheet2-cur-data-row + 1
        buf_temp_sheet2_line-data.sheet-name        = "стр2":U
        buf_temp_sheet2_line-data.counter           = v-torg1xl-sheet2-cur-data-row
        buf_temp_sheet2_line-data.Name              = p-Name
        buf_temp_sheet2_line-data.gdscode           = p-gdscode
        buf_temp_sheet2_line-data.EI                = p-EI
        buf_temp_sheet2_line-data.OKEI              = p-OKEI
        buf_temp_sheet2_line-data.price             = p-price
        buf_temp_sheet2_line-data.AmountInPlSupp    = p-AmountInPlSupp
        buf_temp_sheet2_line-data.PlaceAmountSupp   = p-PlaceAmountSupp
        buf_temp_sheet2_line-data.MassSupp          = p-MassSupp
        buf_temp_sheet2_line-data.SumSupp           = p-SumSupp
        buf_temp_sheet2_line-data.AmountInPlFact    = p-AmountInPlFact
        buf_temp_sheet2_line-data.PlaceAmountFact   = p-PlaceAmountFact
        buf_temp_sheet2_line-data.MassFact          = p-MassFact
        buf_temp_sheet2_line-data.SumFact           = p-SumFact
        buf_temp_sheet2_line-data.sum               = p-sum
        buf_temp_sheet2_line-data.VATpc             = p-VATpc
        buf_temp_sheet2_line-data.VATsum            = p-VATsum
        buf_temp_sheet2_line-data.AmountInPlDelt    = p-AmountInPlDelt
        buf_temp_sheet2_line-data.PlaceAmountDelt   = p-PlaceAmountDelt
        buf_temp_sheet2_line-data.MassDelt          = p-MassDelt
        buf_temp_sheet2_line-data.SumDelt           = p-SumDelt
        buf_temp_sheet2_line-data.Sertif            = p-Sertif
    .
    put stream excel-line unformatted
                        buf_temp_sheet2_line-data.sheet-name
        chr(9)   "DTA":U
        chr(9)   buf_temp_sheet2_line-data.counter
        chr(9)   buf_temp_sheet2_line-data.Name
        chr(9)   buf_temp_sheet2_line-data.gdscode
        chr(9)   buf_temp_sheet2_line-data.EI
        chr(9)   buf_temp_sheet2_line-data.OKEI
        chr(9)   buf_temp_sheet2_line-data.price
        chr(9)   buf_temp_sheet2_line-data.AmountInPlSupp
        chr(9)   buf_temp_sheet2_line-data.PlaceAmountSupp
        chr(9)   buf_temp_sheet2_line-data.MassSupp
        chr(9)   buf_temp_sheet2_line-data.SumSupp
        chr(9)   buf_temp_sheet2_line-data.AmountInPlFact
        chr(9)   buf_temp_sheet2_line-data.PlaceAmountFact
        chr(9)   buf_temp_sheet2_line-data.MassFact
        chr(9)   buf_temp_sheet2_line-data.SumFact
        chr(9)   buf_temp_sheet2_line-data.sum
        chr(9)   buf_temp_sheet2_line-data.VATpc
        chr(9)   buf_temp_sheet2_line-data.VATsum
        chr(9)   buf_temp_sheet2_line-data.AmountInPlDelt
        chr(9)   buf_temp_sheet2_line-data.PlaceAmountDelt
        chr(9)   buf_temp_sheet2_line-data.MassDelt
        chr(9)   buf_temp_sheet2_line-data.SumDelt
        chr(9)   buf_temp_sheet2_line-data.Sertif
        chr(10)
    .
end.
end procedure.
procedure torg1xl-write-cell-data :
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
procedure torg1xl-run-excel :
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
        v-template-file-name    = search( "exe/torg1.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
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
procedure torg1xl-close :
  define variable v-template-filename as character no-undo .
do
on error undo, return error
:
    if printrubl
    then do:
      assign
        v-template-filename = "exe/torg1.xlt":U
      .
    end.
    else do:
      assign
        v-template-filename = "exe/torg1_val.xlt":U
      .
    end.
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export v-template-filename.
        export "exe/t_form.bas":U.
        export v-torg1xl-cell-file-name.
        export v-torg1xl-data-file-name.
    output close.
end.
end procedure.
procedure torg1xl-sheet2-write-line-format :
define input parameter p-fmt-label       as character  no-undo.
    define buffer buf_temp_sheet2_line-data        for temp_sheet2_line-data.
do
for buf_temp_sheet2_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        "стр2":U
        chr(9)   "FMT":U
        chr(9)   p-fmt-label
        chr(10)
    .
end.
end procedure.
def var vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      vss-include-info16 skip
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
    define variable v-line-counter  as integer         no-undo.
    define variable v-val-str       as char            no-undo.
    define variable v-print-doc                 as character                no-undo.
    define variable type-par        as character    no-undo .
    define variable v-gds-name      as character    no-undo.
    define variable v-gds-code      as integer      no-undo.
    define variable v-unit-name     as character    no-undo.
    define variable v-unit-okei     as integer      no-undo.
    define variable v-bar-code      as integer      no-undo.
    define variable v-sert          as character    no-undo.
    define variable v-price         as decimal      no-undo.
    define variable v-price-NoVAT   as decimal      no-undo.
    define variable v-qnty-supp     as decimal      no-undo.
    define variable v-qnty-fact     as decimal      no-undo.
    define variable v-curr-code     as integer      no-undo.
    define variable v-host-code     as integer      no-undo.
    define variable v-sum-PlaceAmountSupp   as decimal      no-undo.
    define variable v-sum-SumSupp           as decimal      no-undo.
    define variable v-sum-PlaceAmountFact   as decimal      no-undo.
    define variable v-sum-SumFact           as decimal      no-undo.
    define variable v-sum-sum               as decimal      no-undo.
    define variable v-sum-VATsum            as decimal      no-undo.
    define variable v-sum-PlaceAmountDelt   as decimal      no-undo.
    define variable v-sum-SumDelt           as decimal      no-undo.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.
    define buffer buf_parts         for parts.
    define buffer buf_goods         for goods.
    define buffer buf_units         for units.
    define buffer buf_sert-join     for sert-join.
    define buffer buf_sert          for sert.
    define buffer buf_currency      for currency.
do
for buf_trn-doc
  , buf_doc-line
  , buf_parts
  , buf_goods
  , buf_units
  , buf_sert-join
  , buf_sert
  , buf_currency
on error undo, return error return-value
:
if session :set-wait-state( "compiler" ) then.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-curr-code
  )  .
    end.
    run torgconf-read in this-procedure (
          input "torg1":U
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
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
        view-as alert-box error.
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
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
        view-as alert-box warning.
    end.
    run torgconf-get-cli-param in this-procedure (
          input buf_trn-doc.host-code
        , input buf_trn-doc.cli-type
        , input buf_trn-doc.cli-code
        , input v-curr-code
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
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if v-print-doc <> 'yes'  then assign v-print-doc = "no"  .
    run torgconf-get-form-header in this-procedure (
          input Invers
        , input buf_trn-doc.doc-code
        , input ( v-print-doc = "yes" )
        , input buf_trn-doc.doc-date
        , input buf_trn-doc.fact-date
        , input buf_trn-doc.doc-type
        , input buf_trn-doc.status_
        , input no
        , input no
    ).
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
    put stream out-stream unformatted
          chr(10)
        + "Печатная форма предназначена только для вывода в Microsoft Excel."
        + chr(10)
    .
    output stream out-stream close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
    output close.
    run torg1xl-init in this-procedure .
    find first buf_currency no-lock
         where buf_currency.curr-code = buf_trn-doc.exch-code
    .
    assign
        v-val-str = ( if Invers
                      then buf_currency.curr-abbr
                      else ( if PrintRubl then "рублях" else "баз.вал" ) )
    .
    run torg1xl-write-cell-data in this-procedure (
          input "organization":U
        , input v-torgconf-organization
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "cliFrom":U
        , input v-torgconf-client-from
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "okpo":U
        , input v-torgconf-okpo
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "docCode":U
        , input v-torgconf-doc-code
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "docDate":U
        , input v-torgconf-doc-date
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "operationType":U
        , input ( if buf_trn-doc.doc-type = 'при':U AND NOT Invers then " приход" else " расход" )
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "cargoTo":U
        , input v-torgconf-torg12-cargo-label
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "cargoToValue":U
        , input v-torgconf-cargo-from-value
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "supplier":U
        , input v-torgconf-supplier
    ).
    assign
        v-line-counter = 0
    .
    for each buf_doc-line no-lock
       where buf_doc-line.doc-code = buf_trn-doc.doc-code
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.artic      = buf_doc-line.artic
               and buf_goods.prod-type  = buf_doc-line.prod-type
               and buf_goods.prod-code  = buf_doc-line.prod-code
        .
        find first buf_units no-lock
             where buf_units.unit-name = buf_goods.unit-base
        .
        assign
            v-gds-code  = buf_goods.gds-code
            v-gds-name  = buf_goods.gds-name
            v-unit-name = buf_units.unit-name
            v-unit-okei = buf_units.OKEI
        .
        for each tt-clcparts
        on error undo, return error
        :
            delete tt-clcparts.
        end.
        for each buf_parts no-lock
           where buf_parts.out-code   = buf_trn-doc.doc-code
             and buf_parts.obj-type   = buf_trn-doc.obj-type
             and buf_parts.obj-code   = buf_trn-doc.obj-code
             and buf_parts.prod-type  = buf_doc-line.prod-type
             and buf_parts.prod-code  = buf_doc-line.prod-code
             and buf_parts.artic      = buf_doc-line.artic
        on error undo, return error return-value
        :
            assign
                v-line-counter = v-line-counter + 1
            .
            create tt-clcparts.
            buffer-copy buf_parts to tt-clcparts.
            run clcprtsl_calc-parts in this-procedure (
                  input recid( tt-clcparts )
                , input no
                , input no
                , input 0
                , input 0
                , input 0
                , input 0
                , input 0
                , input 0
                , input 0
                , input "":U
                , input 0
                , input 0
                , input 0
                , input 0
                , input 0
                , input 0
            ).
            find first tt-allsum
                 where tt-allsum.sum-type = 'основная_сумма':U
            .
            assign
                v-price     = ( if printrubl = yes then buf_parts.price-rubl else buf_parts.price-base )
                v-qnty-supp = buf_parts.qnty
                v-qnty-fact = buf_parts.fact-qnty
            .
            assign
                v-sert = "":U
            .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-bar-code
  ) no-error .
 .
            for each buf_sert-join no-lock
               where buf_sert-join.cli-type   = buf_goods.prod-type
                 and buf_sert-join.cli-code   = buf_goods.prod-code
                 and buf_sert-join.b-code     = v-bar-code
            :
                for each buf_sert no-lock
                   where buf_sert.sert-code = buf_sert-join.sert-code
                :
                    if  buf_trn-doc.fact-date <= buf_sert.last-date
                    and buf_trn-doc.fact-date >= buf_sert.first-date
                    then do:
                        assign
                            v-sert = v-sert
                                    + ( if trim( v-sert ) = "":U
                                        then "":U
                                        else ", ":U )
                                    + string( buf_sert-join.sert-code )
                        .
                    end.
                end.
            end.
            assign
                v-price-NoVAT         = v-price - v-price * buf_parts.VAT-pc / ( 100 + buf_parts.VAT-pc )
                v-sum-PlaceAmountSupp = v-sum-PlaceAmountSupp + v-qnty-supp
                v-sum-SumSupp         = v-sum-SumSupp         + ( v-qnty-supp * v-price-NoVAT )
                v-sum-PlaceAmountFact = v-sum-PlaceAmountFact + v-qnty-fact
                v-sum-SumFact         = v-sum-SumFact         + ( v-qnty-fact * v-price-NoVAT )
                v-sum-sum             = v-sum-sum             + ( v-qnty-fact * v-price )
                v-sum-VATsum          = v-sum-VATsum          + ( buf_parts.VAT-pc / 100 * v-qnty-fact * v-price-NoVAT )
                v-sum-PlaceAmountDelt = v-sum-PlaceAmountDelt + ( v-qnty-fact - v-qnty-supp )
                v-sum-SumDelt         = v-sum-SumDelt         + ( ( v-qnty-fact - v-qnty-supp ) * v-price-NoVAT )
            .
            run torg1xl-sheet2-write-line-data in this-procedure (
                  input v-gds-name
                , input v-gds-code
                , input v-unit-name
                , input v-unit-okei
                , input v-price-NoVAT
                , input 1
                , input v-qnty-supp
                , input 0
                , input v-qnty-supp * v-price-NoVAT
                , input 1
                , input v-qnty-fact
                , input 0
                , input v-qnty-fact * v-price-NoVAT
                , input v-qnty-fact * v-price
                , input buf_parts.VAT-pc
                , input buf_parts.VAT-pc / 100 * v-qnty-fact * v-price-NoVAT
                , input 1
                , input v-qnty-fact - v-qnty-supp
                , input 0
                , input ( v-qnty-fact - v-qnty-supp ) * v-price-NoVAT
                , input v-sert
            ).
        end.
    end.
    run torg1xl-write-cell-data in this-procedure (
          input "стр2_it_PlaceAmountSupp":U
        , input v-sum-PlaceAmountSupp
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "стр2_it_SumSupp":U
        , input v-sum-SumSupp
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "стр2_it_PlaceAmountFact":U
        , input v-sum-PlaceAmountFact
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "стр2_it_SumFact":U
        , input v-sum-SumFact
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "стр2_it_sum":U
        , input v-sum-sum
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "стр2_it_VATsum":U
        , input v-sum-VATsum
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "стр2_it_PlaceAmountDelt":U
        , input v-sum-PlaceAmountDelt
    ).
    run torg1xl-write-cell-data in this-procedure (
          input "стр2_it_SumDelt":U
        , input v-sum-SumDelt
    ).
    run torg1xl-close in this-procedure .
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 4 >= 8 then 2 else 0), 0, 0,
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
if session :set-wait-state( "" ) then.
end.
