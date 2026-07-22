block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Пересылка объектов системы КМ-ру IBM-пускальник".
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
define NEW SHARED temp-table cash-obj no-undo
field km-objcode  as integer
field km-objname as character
field km-objtype as integer
field on-addr like ub.cash-desk.addr-path
field off-addr like ub.cash-desk.addr-path
field shop-nums as character
field obj-lock as integer
field firm-name as character
field jur-address as character
field post-address as character
field INN as character
field KPP as character
index pi is unique primary
km-objtype km-objcode km-objname
.
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable  p-db-num like ub.db.db-num no-undo .
define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .
define variable action     as character no-undo .
define variable log-file-name as character no-undo init "send-cd.txt".
define variable v-view-log as logical no-undo .
define variable callpoint as character no-undo.
define variable glog as logical no-undo .
define buffer buf_shop for ub.shop.
define buffer buf_clients for ub.clients.
define buffer buf_cash-desk for ub.cash-desk.
define buffer bfcdm_cash-desk for ub.cash-desk.
assign
p-db-num = integer(entry(1, p-parameter, chr(4)))
p-obj-code = integer(entry(2, p-parameter, chr(4)))
action     = entry(3, p-parameter, chr(4))
no-error
.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3"
                         , p-parameter
                         , chr(10)
                         , error-status:get-message(1)
                         )).
  v-view-log = yes.
  undo, return error .
end .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
assign
callpoint = action.
action = if action = "R" then "U" else action.
for each cash-obj:
    delete cash-obj.
end.
FIND FIRST ub.cash-desk NO-LOCK WHERE
           ub.cash-desk.db-num = g#db-num
       AND ub.cash-desk.pos-type = 'IBM-XML':U
       AND ub.cash-desk.autonomy = integer('2':U)  No-error.
IF not avail(ub.cash-desk) then do:
  if callpoint <> "R" then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!&1 объектов БД реализуется только для кассового менеджера IBM"
                              , (if action = "U" then "Передача" else "Удаление")
                            )
                                            ).
     return.
  end.
end.
if callpoint = "R"
then do:
  glog = yes.
end.
else do:
  define variable v-host-code as integer   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-reference_update':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
end.
if NOT glog then return .
glog = yes.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("&1 магазина &2: пересылка всех имеющихся в БД объектов"
                      , (if action = "U" then "Пересылка на кассы" else "Удаление с касс" )
                      , p-obj-code)
    ).
run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Подготовка данных")
                                      ).
  find first cash-obj where
           cash-obj.km-objtype = 0
       AND  cash-obj.km-objcode = g#db-num
       AND cash-obj.km-objname = "БД" + string(g#db-num)
         no-error .
  if not available cash-obj then do:
    create cash-obj.
    assign
    cash-obj.km-objcode = g#db-num
    cash-obj.km-objtype = 0
    cash-obj.km-objname = "БД" + string(g#db-num)
    cash-obj.on-addr    = "":U
    cash-obj.off-addr   = "":U
    cash-obj.shop-nums  = "":U
    cash-obj.obj-lock   = 0
    .
    for each bfcdm_cash-desk no-lock where
            bfcdm_cash-desk.db-num = g#db-num
      AND  bfcdm_cash-desk.pos-type = 'IBM-XML':U
      AND  bfcdm_cash-desk.autonomy = integer('2':U)
      :
        assign
        cash-obj.shop-nums = cash-obj.shop-nums
                            + (if cash-obj.shop-nums = "":u then "":U else chr(44))
                            + string(bfcdm_cash-desk.obj-code)
        .
    end.
  end.
  find first cash-obj where
           cash-obj.km-objtype = 2
       AND  cash-obj.km-objcode = 0
       AND cash-obj.km-objname = "КМ"
         no-error .
  if not available cash-obj then do:
    create cash-obj.
    assign
    cash-obj.km-objcode = 0
    cash-obj.km-objtype = 2
    cash-obj.km-objname = "КМ"
    cash-obj.on-addr    = "":U
    cash-obj.off-addr   = "":U
    cash-obj.shop-nums  = "":U
    cash-obj.obj-lock   = 0
    .
   for each bfcdm_cash-desk no-lock where
            bfcdm_cash-desk.db-num = g#db-num
      AND  bfcdm_cash-desk.pos-type = 'IBM-XML':U
      AND  bfcdm_cash-desk.autonomy = integer('2':U)
      :
        assign
        cash-obj.shop-nums = cash-obj.shop-nums
                            + (if cash-obj.shop-nums = "":u then "":U else chr(44))
                            + string(bfcdm_cash-desk.obj-code)
        .
   end.
 end.
_for:
for each buf_clients no-lock where
          buf_clients.db-num = g#db-num
      AND buf_clients.obj-type = 'маг':U:
  find first buf_shop no-lock where
              buf_shop.obj-code = buf_clients.obj-code no-error .
  if not available buf_shop then next _for.
  FIND FIRST cash-desk NO-LOCK WHERE
           cash-desk.db-num = g#db-num
       AND cash-desk.pos-type = 'IBM-XML':U
       AND cash-desk.autonomy = integer('1':U)
       AND cash-desk.is-del   = no
       AND cash-desk.obj-code  = buf_clients.obj-code
       No-error.
  if not available cash-desk then next _for.
  find first cash-obj where
           cash-obj.km-objtype = 1
       AND  cash-obj.km-objcode = buf_clients.obj-code no-error .
  if not available cash-obj then do:
    run fmtcli-get-client in this-procedure
                                  (
                                   input 'орг':U
                                  ,input buf_clients.host-code
                                  ).
    create cash-obj.
    assign
    cash-obj.km-objcode = buf_clients.obj-code
    cash-obj.km-objtype = 1
    cash-obj.km-objname = buf_clients.obj-type + string(buf_clients.obj-code)
    cash-obj.on-addr    = "":U
    cash-obj.off-addr   = "":U
    cash-obj.shop-nums  = string(buf_clients.obj-code)
    cash-obj.obj-lock   = buf_clients.stts
    cash-obj.firm-name  = v-fmtcli-name
    cash-obj.jur-address = v-fmtcli-addres
    cash-obj.post-address = v-fmtcli-post-addres
    cash-obj.INN         = v-fmtcli-INN
    cash-obj.KPP         = v-fmtcli-KPP
    .
  end.
  for each buf_cash-desk no-lock where
              buf_cash-desk.db-num = g#db-num
          AND buf_cash-desk.obj-code = buf_shop.obj-code
          AND buf_cash-desk.pos-type = 'IBM-XML':U:
    if buf_cash-desk.autonomy = integer('0':U) then next.
    if buf_cash-desk.autonomy = integer('2':U) then next.
    find first cash-obj where
            cash-obj.km-objtype = (if buf_cash-desk.autonomy = integer('2':U) then 2 else 3)
        AND  cash-obj.km-objcode = buf_cash-desk.cash-num no-error .
    if not available cash-obj then do:
      create cash-obj.
      assign
      cash-obj.km-objcode = buf_cash-desk.cash-num
      cash-obj.km-objtype = (if buf_cash-desk.autonomy = integer('2':U) then 2 else 3)
      cash-obj.km-objname = (if buf_cash-desk.autonomy = integer('2':U)
                             then "КМ"
                             else ("маг" + string(buf_cash-desk.obj-code) + "_касса" + string(buf_cash-desk.cash-num))
                             )
      cash-obj.on-addr    = (if buf_cash-desk.autonomy = integer('2':U)
                            then buf_cash-desk.addr-path
                            else (entry(1, buf_cash-desk.addr-path, chr(4))
                                  + "://":U
                                  + entry(2, buf_cash-desk.addr-path, chr(4))
                                 )
                            )
      cash-obj.off-addr   = (if buf_cash-desk.autonomy = integer('2':U)
                            then buf_cash-desk.addr-path
                            else (entry(1, buf_cash-desk.addr-path, chr(4))
                                  + "://":U
                                  + entry(2, buf_cash-desk.addr-path, chr(4))
                                 )
                            )
      cash-obj.shop-nums  = if buf_cash-desk.autonomy = integer('1':U)
                            then  string(buf_cash-desk.obj-code)
                            else "":U
      cash-obj.obj-lock   = if ((action = "U":U or callpoint = "R":U) and buf_cash-desk.cash-on )
                            then 0
                            else 1
      .
      if buf_cash-desk.autonomy = integer('2':U) then do:
        for each bfcdm_cash-desk no-lock where
                bfcdm_cash-desk.db-num = g#db-num
          AND  bfcdm_cash-desk.pos-type = 'IBM-XML':U
          AND  bfcdm_cash-desk.autonomy = integer('2':U)
          AND  bfcdm_cash-desk.cash-on = yes
          :
           assign
           cash-obj.shop-nums = cash-obj.shop-nums
                                + (if cash-obj.shop-nums = "":u then "":U else chr(44))
                                + string(bfcdm_cash-desk.obj-code)
           .
        end.
      end.
    end.
  end.
end.
if can-find(first cash-obj ) then do:
  run str/send-obj.p (
                    input parparentproc
                  ,input this-procedure
                  ,input p-log-handle
                  ,input (string(g#db-num) + chr(4) +
                          string(p-obj-code) + chr(4) +
                          action)) no-error.
  if not error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("&1 маг&2 &3"
                            , (if action = "U"
                              then "Передача объектов БД на кассы"
                              else "Удаление объектов БД с касс")
                            , p-obj-code
                            , (if action = "U"
                              then "проведена"
                              else "проведено")
                            )
                                        ).
  end.
  else do:
    assign
    v-view-log = yes
    .
  end.
end.
else do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Не найдено информации по объектам БД для передачи на кассы маг&1")
                            , p-obj-code
                                        ).
end.
  finally :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При отсылке информации на кассы произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action7   as character no-undo .
  define variable v-printed7       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При отсылке информации на кассы произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + log-file-name)
    ,input  7
    ,output v-user-action7
    ,output v-printed7
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&1", chr(10))
    ).
    define variable v-save-file-name as character no-undo .
    v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
    OS-APPEND value(log-file-name) value(v-save-file-name).
    OS-DELETE value(log-file-name).
  end finally .
