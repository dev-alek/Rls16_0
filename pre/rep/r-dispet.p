block-level on error undo, throw.
define input parameter parParentProc   as handle    no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-call-handle as handle no-undo .
define input parameter p-rebh as handle no-undo .
define input parameter p-rdbh                   as handle                  no-undo .
define input parameter p-report-id as character no-undo .
define input parameter p-xsd-file as character no-undo .
define input parameter p-log-file-name as character no-undo .
define input parameter p-batch        as integer  no-undo .
define input parameter p-codex-id               as integer no-undo .
define input parameter p-ruleset-id             as integer no-undo .
define input parameter p-time as integer          no-undo.
define input parameter p-date         as date   no-undo .
define input parameter p-cli-list     as character        no-undo.
define input parameter p-excel         as logical          no-undo .
define input parameter p-xml           as logical          no-undo .
define input parameter p-dir-excel          as character no-undo .
define input parameter p-dir-xml          as character no-undo .
define output parameter p-dataseth as handle no-undo .
define output parameter p-xmlh as handle no-undo.
define variable vss-revision    as character no-undo init "$Revision: 63c9a434965b, 3578, rls $":U .
define variable vss-author      as character no-undo init "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo init "$Date: 2023/12/14 13:36:13 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-dispet.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-dispet.p $":U .
define variable vss-description as character no-undo init "Отчет диспетчера".
define variable g#report-num  as integer      no-undo .
define variable v-sort-list    as character    no-undo.
define variable v-sort-type    as character    no-undo.
define variable v-sort         as logical      no-undo.
define variable v-sort-MAX     as integer      no-undo.
define variable v-sort-code    as integer      no-undo.
define variable v-message    as character    no-undo.
define variable v-err-mess as character no-undo .
define variable v-start-datetime as datetime no-undo .
define buffer buf_rvs-line-attr for ub.rvs-line-attr .
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
define variable vss-include-info0 as character format "X(65)" no-undo
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-disp-xl-current-data-row AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-disp-xl-cell-file-name   AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-disp-xl-data-file-name   AS CHARACTER NO-UNDO.
DEFINE STREAM excel-line.
DEFINE STREAM excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
    field data-key      as character
    field xl-line-id    as integer
    field obj-number      as character
    field obj-address     as character
    field obj-phone       as character
    field gds-name        as character
    field loc1            as character
    field max-qnty        as character
    field add-qnty        as character
    field sale-qnty-7     as character
    field curr-qnty       as character
    field level-water     as character
    field volume-water    as character
    field doc-qnty       as character
    field curr-date       as character
    field curr-time       as character
    field sale-qnty-1     as character
    index pi is primary unique
        xl-line-id
.
PROCEDURE disp-xl-init :
DO
ON ERROR UNDO, RETURN ERROR
:
   ASSIGN
      v-disp-xl-current-data-row = 0
   .
   run gbl/_tmpfile.p (
         INPUT "xd"
      , INPUT ".txt"
      , OUTPUT v-disp-xl-data-file-name
   ).
   OUTPUT STREAM excel-line TO value( v-disp-xl-data-file-name ).
   run gbl/_tmpfile.p (
         INPUT "xc"
      , INPUT ".txt"
      , OUTPUT v-disp-xl-cell-file-name
   ).
   OUTPUT STREAM excel-cell TO value( v-disp-xl-cell-file-name ).
   run disp-xl-write-cell-data in this-procedure (
         input "valutCode":U
      , input "1":U
   ).
   RUN disp-xl-write-cell-data IN THIS-PROCEDURE (
         INPUT "columnList":U
      , INPUT "obj_number,obj_address,obj_phone,gds_name,loc1,max_qnty,add_qnty,sale_qnty_7,curr_qnty,doc_qnty,level_water,volume_water,curr_date,curr_time,sale_qnty_1":U
   ).
   RUN disp-xl-write-cell-data IN THIS-PROCEDURE (
         INPUT "columnType":U
      , INPUT "S,S,S,S,S,S,S,S,S,S,S,S,S,S,S":U
   ).
   RUN disp-xl-write-cell-data IN THIS-PROCEDURE (
         INPUT "columnAmount":U
      , INPUT "15":U
   ).
END.
END PROCEDURE.
PROCEDURE disp-xl-close :
DO
ON ERROR UNDO, RETURN ERROR
:
    OUTPUT STREAM excel-line CLOSE.
    OUTPUT STREAM excel-cell CLOSE.
    OUTPUT TO value( STRING( SESSION:temp-directory + "$" + STRING( g#report-num ) ) + ".txl" )  .
        EXPORT "exe/rep-disp.xlt":U.
        EXPORT "exe/t_97.bas":U.
        EXPORT v-disp-xl-cell-file-name.
        EXPORT v-disp-xl-data-file-name.
    OUTPUT CLOSE.
END.
END PROCEDURE.
PROCEDURE disp-xl-write-cell-data :
DEFINE INPUT PARAMETER p-data-key   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-data-value AS CHARACTER NO-UNDO.
define buffer buf_temp_cell-data     for temp_cell-data.
DO
ON ERROR UNDO, RETURN ERROR
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
PROCEDURE disp-xl-write-line-data :
DEFINE INPUT PARAMETER p-obj-number  AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-address AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-phone   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-gds-name    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-loc1        AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-max-qnty    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-add-qnty    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-sale-qnty-7 AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-curr-qnty   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-level-water AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-volume-water AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-doc-qnty    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-curr-date   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-curr-time   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-sale-qnty-1 AS CHARACTER NO-UNDO.
define buffer buf_temp_line-data        for temp_line-data.
DO
ON ERROR UNDO, RETURN ERROR
:
    for each buf_temp_line-data
    :
        delete buf_temp_line-data.
    end.
    create buf_temp_line-data.
    assign
        v-disp-xl-current-data-row = v-disp-xl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key   = "LD":U
        buf_temp_line-data.xl-line-id = v-disp-xl-current-data-row
        buf_temp_line-data.obj-number    = p-obj-number
        buf_temp_line-data.obj-address   = p-obj-address
        buf_temp_line-data.obj-phone     = p-obj-phone
        buf_temp_line-data.gds-name      = p-gds-name
        buf_temp_line-data.loc1          = p-loc1
        buf_temp_line-data.max-qnty      = p-max-qnty
        buf_temp_line-data.add-qnty      = p-add-qnty
        buf_temp_line-data.sale-qnty-7   = p-sale-qnty-7
        buf_temp_line-data.curr-qnty     = p-curr-qnty
        buf_temp_line-data.level-water   = p-level-water
        buf_temp_line-data.volume-water  = p-volume-water
        buf_temp_line-data.curr-date     = p-curr-date
        buf_temp_line-data.curr-time     = p-curr-time
        buf_temp_line-data.sale-qnty-1   = p-sale-qnty-1
    .
    PUT STREAM excel-line UNFORMATTED
                        buf_temp_line-data.data-key
        chr(9)   p-obj-number
        chr(9)   p-obj-address
        chr(9)   p-obj-phone
        chr(9)   p-gds-name
        chr(9)   p-loc1
        chr(9)   p-max-qnty
        chr(9)   p-add-qnty
        chr(9)   p-sale-qnty-7
        chr(9)   p-curr-qnty
        chr(9)   p-doc-qnty
        chr(9)   p-level-water
        chr(9)   p-volume-water
        chr(9)   p-curr-date
        chr(9)   p-curr-time
        chr(9)   p-sale-qnty-1
        chr(10)
    .
END.
END PROCEDURE.
PROCEDURE disp-xl-run-excel :
DEFINE INPUT PARAMETER p-header-filename    AS CHARACTER        NO-UNDO.
DEFINE INPUT PARAMETER p-data-filename      AS CHARACTER        NO-UNDO.
DEFINE VARIABLE v-template-file-name    AS CHARACTER    NO-UNDO.
DEFINE VARIABLE v-vb-file-name          AS CHARACTER    NO-UNDO.
DEFINE BUFFER buf_temp-param FOR temp-param .
DO
FOR buf_temp-param
ON ERROR UNDO, RETURN ERROR
:
    CREATE buf_temp-param.
    ASSIGN
        v-template-file-name    = SEARCH( "exe/rep-disp.xlt" )
        v-vb-file-name          = SEARCH( "exe/t_97.bas")
    .
    IF v-template-file-name = ?
    OR v-template-file-name = "":U
    THEN DO:
        MESSAGE
            "Ошибка имени файла шаблона."
        VIEW-AS ALERT-BOX ERROR.
    END.
    IF v-vb-file-name = ?
    OR v-vb-file-name = "":U
    THEN DO:
        MESSAGE
            "Ошибка имени файла кода обработки."
        VIEW-AS ALERT-BOX ERROR.
    END.
    RUN paramls-write IN THIS-PROCEDURE (
          INPUT "template":U
        , INPUT "template-file-name":U
        , INPUT v-template-file-name
    ).
    RUN paramls-write IN THIS-PROCEDURE (
          INPUT "template":U
        , INPUT "vb-file-name":U
        , INPUT v-vb-file-name
    ).
    RUN PARAMLS-WRITE IN THIS-PROCEDURE (
          INPUT "data":U
        , INPUT "data-header-filename":U
        , INPUT p-header-filename
    ).
    RUN paramls-write IN THIS-PROCEDURE (
          INPUT "data":U
        , INPUT "data-filename":U
        , INPUT p-data-filename
    ).
    run gbl/macroxlt.p (
        INPUT-OUTPUT table buf_temp-param
    ) NO-ERROR.
    IF ERROR-STATUS :ERROR
    THEN DO:
        MESSAGE
                 vss-workfile vss-revision vss-description
            SKIP(1)
            SKIP "Ошибка создания файла Excel."
            SKIP RETURN-VALUE
            SKIP TRIM(ERROR-STATUS :GET-MESSAGE(1))
                 TRIM(ERROR-STATUS :GET-MESSAGE(2))
                 TRIM(ERROR-STATUS :GET-MESSAGE(3))
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR .
    END.
END.
END PROCEDURE.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
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
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
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
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable tempcxml_v-num_ as integer no-undo .
define  temp-table temp-xml-tables no-undo
field order as integer
field tbl-name as character
field tbl-handle_ as handle
field table-handle_ as handle
field uniq-gate-rec as character
field gate-name as character
field gate-handle_ as handle
field is-parent as logical
index pi is unique primary
uniq-gate-rec
tbl-name
index iorder
order
index gr
uniq-gate-rec
index gh
gate-handle_
index iparent
is-parent
.
define  temp-table temp-xml-records no-undo
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
uniq-key-rec
.
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info11 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info11, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info11, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info11, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info11, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info11 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info11, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info11 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info11, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info11, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info11, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info11, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info11, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info11, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info11 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info11 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info11, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info11, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info11, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info11 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info11 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info11, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info11, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
procedure get-gate-file-name :
define input parameter p-gate-rec as character no-undo .
define output  parameter p-gate-file-name as character no-undo .
define buffer buf_clob-data for ub.clob-data.
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
run gen-row-keyr in this-procedure ( input p-gate-rec
                                    ,input ?
                                    ,input "ub"
                                    ,input ?
                                    ,input no-lock
                                    ,output v-tbl-row
                                    ,output v-tbl-name) no-error.
if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                        ,vss-include-info9
                                                        ,p-gate-rec).
find first buf_clob-data no-lock where
          rowid(buf_clob-data) = v-tbl-row no-error.
if not available buf_clob-data then do:
  if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                          ,vss-include-info9
                                                          ,p-gate-rec).
end.
p-gate-file-name = buf_clob-data.file-name.
end procedure.
procedure get-gate-rec :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info9, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info9 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info9 )
:
    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = 'gate':U
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).
    end.
    run gen-key-rec in this-procedure ( input 'clob-data':U
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).
end.
end procedure.
procedure get-gate-by-name :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define variable v-db-num as integer no-undo .
define variable v-int64-id as int64 no-undo .
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info9, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info9 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info9 )
:
    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = 'gate':U
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).
    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 из БД:&2&3", p-gate-name, chr(10), error-status:get-message(1) ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    run gen-key-rec in this-procedure ( input 'clob-data':U
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
      end.
    end.
end.
end procedure.
procedure get-gate-by-rec :
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define input-output parameter p-longchar  as longchar no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info9, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info9 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info9 )
:
  run gen-row-keyr in this-procedure (
                                        input  p-gate-rec
                                        ,input  ?
                                        ,input  "ub"
                                        ,input  ?
                                        ,input  NO-LOCK
                                        ,output v-rowid
                                        ,output v-tbl-name   ) no-error.
    find first buf_clob-data no-lock where
              rowid(buf_clob-data) = v-rowid  no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB  &1"
                                      , p-gate-rec
                                      ).
    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    define variable v-esm as character no-undo .
    v-esm = error-status:get-message(1) .
    if p-longchar <> ? then do:
      p-longchar = v-longchar.
    end.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 (&2) из БД&3&4"
                                   , p-gate-rec
                                   , p-gate-rec
                                   , v-esm
                                   ).
    end.
    p-dsh:private-data = buf_clob-data.file-name_ + chr(4) + p-gate-rec.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
end.
end procedure.
procedure get-gate-by-file :
define input  parameter p-schema-file-name as character no-undo .
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info9, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info9 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info9 )
:
    COPY-LOB
    FROM  FILE p-schema-file-name
    TO  OBJECT v-longchar
    no-convert
    NO-ERROR .
    if error-status :error then do:
        undo, return error substitute("Не удалось считать файл схемы &1 в память&2&3"
                                  , p-schema-file-name
                              , chr(10)
                              , error-status:get-message(1) ).
    end.
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, p-schema-file-name, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "longchar"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = ''.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему из файла &1&2&3"
                                   , p-schema-file-name
                                   ,chr(10)
                                   , error-status:get-message(1)
                                   ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1" and  uniq-gate-rec = "&2" '
                                   ,p-dsh:get-buffer-handle(v-ii):name
                                   ,p-gate-rec
                                   )) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):table
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
end.
end procedure.
procedure gate-clear :
define input  parameter p-dsh as handle no-undo .
define input  parameter p-xmlh as handle no-undo .
define variable v-dsh as handle no-undo .
define variable v-th as handle no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-dsh) then do:
      delete object p-dsh.
      v-dsh = p-dsh.
      p-dsh = ?.
    end.
    repeat while true:
      p-xmlh:find-first( substitute( " where gate-handle_ = &1 ", v-dsh)
                         , share-lock) no-error.
      if p-xmlh:available then do:
        assign
        v-th = p-xmlh:buffer-field("table-handle_"):buffer-value.
        if valid-handle(p-xmlh:buffer-field("table-handle_"))
        and valid-handle(v-th)
        and v-th:dynamic = yes
        then do:
          delete object p-xmlh:buffer-field("table-handle_"):buffer-value.
          p-xmlh:buffer-field("table-handle_"):buffer-value = ?.
        end.
        p-xmlh:buffer-delete().
      end.
      else do:
        leave.
      end.
    end.
    if p-xmlh:dynamic = yes
    and valid-handle(p-xmlh)
    then do:
      delete object p-xmlh:table-handle.
      p-xmlh = ?.
    end.
    v-dsh = ?.
  end.
end procedure.
procedure all-gates-clear :
define parameter buffer buf_temp-xml-tables for temp-xml-tables.
do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
      if first-of(buf_temp-xml-tables.uniq-gate-rec) then do:
        delete object buf_temp-xml-tables.gate-handle_.
        buf_temp-xml-tables.gate-handle_ = ?.
      end.
      if valid-handle(buf_temp-xml-tables.table-handle_)
      and buf_temp-xml-tables.table-handle_:dynamic = no
      then do:
        delete object buf_temp-xml-tables.table-handle_.
        buf_temp-xml-tables.table-handle_ = ?.
      end.
      delete buf_temp-xml-tables.
  end.
end.
end procedure.
procedure fix-schemalocation :
define input-output  parameter p-longchar as longchar no-undo .
DEFINE VARIABLE hdoc AS HANDLE.
DEFINE VARIABLE hroot AS HANDLE.
DEFINE VARIABLE hnode-child AS HANDLE.
DEFINE VARIABLE hnode-attr AS HANDLE.
define variable v-jj as integer   no-undo .
define variable ok as logical   no-undo .
define variable v-path1                    as character                no-undo .
DEFINE VARIABLE v-full-path1               as character                no-undo .
DEFINE VARIABLE v-file-name1               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext1        as character                no-undo .
DEFINE VARIABLE v-file-name-ext1           as character                no-undo .
define variable v-schema-location          as character                no-undo .
do
on error undo, return error return-value
:
  CREATE X-DOCUMENT hdoc.
  CREATE X-noderef hroot.
  CREATE X-noderef hnode-child.
  CREATE X-noderef hnode-attr.
  hdoc:load("longchar", p-longchar, no) no-error.
  iF ERROR-STATUS:GET-MESSAGE(1) <> '' THEN message ERROR-STATUS:GET-MESSAGE(1) view-as alert-box .
  hdoc:get-document-element(hroot).
  _repeat:
  REPEAT v-jj = 1 TO hroot:NUM-CHILDREN:
    ok = hroot:GET-CHILD(hNode-Child, v-jj).
    if not ok then next.
    if hNode-Child:local-name = "include"
    then do:
      ok = hNode-Child:GET-ATTRIBUTE-NODE( hnode-attr, "schemaLocation" ).
        v-schema-location = hnode-attr:node-value.
        run gbl/filename.p (
                        input "exe/" + hnode-attr:node-value
                      ,output v-full-path1
                      ,output v-path1
                      ,output v-file-name1
                      ,output v-file-name-no-ext1
                      ,output v-file-name-ext1
                      ) no-error .
        if error-status :error then do:
          delete object hnode-attr.
          delete object hnode-child.
          delete object hroot.
          delete object hdoc.
          undo, return error substitute("Не удалось определить расположение схемы &1", v-schema-location).
        end.
      ok = hNode-Child:sET-ATTRIBUTE(  "schemaLocation", v-full-path1 ).
      leave  _repeat.
    end.
  END.
  hdoc:save("longchar", p-longchar).
  delete object hnode-attr.
  delete object hnode-child.
  delete object hroot.
  delete object hdoc.
end.
end procedure.
procedure gate-clb_fill-xml-tables :
define input parameter p-dsh as handle no-undo .
define input-output parameter p-xmlh as handle no-undo .
define variable v-ii as integer no-undo .
  do
  on error undo, return error
  :
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = entry(2, p-dsh:private-data, chr(4))
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
  end.
end procedure.
procedure all-gates-empty :
define buffer buf_temp-xml-tables for temp-xml-tables.
do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    if valid-handle(buf_temp-xml-tables.tbl-handle_) then do:
      buf_temp-xml-tables.tbl-handle_:empty-temp-table().
    end.
  end.
end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define stream temp-stream.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prnexldl_clear:
define input parameter p-txl-file-name as character no-undo .
define variable v-template-file-name as character no-undo .
define variable v-vb-file-name as character no-undo .
define variable v-data-header-filename as character no-undo .
define variable v-data-filename as character no-undo .
if search( p-txl-file-name ) <> ? then do:
  input stream temp-stream from value( p-txl-file-name ).
  repeat
  :
      import stream temp-stream v-template-file-name   .
      import stream temp-stream v-vb-file-name         .
      import stream temp-stream v-data-header-filename .
      os-delete value(v-data-header-filename).
      import stream temp-stream v-data-filename        .
      os-delete value(v-data-filename).
  end.
  input stream temp-stream close.
  os-delete value( p-txl-file-name ).
end.
end procedure .
define stream reprumpr_in.
procedure reprumpr_print-xlt :
define input parameter p-dir-name as character no-undo .
define input parameter p-subdir-name as character no-undo .
define input parameter p-custom-name as character no-undo .
define input parameter p-disable-option as integer no-undo .
define input parameter p-font-number as integer no-undo .
define buffer buf_temp-param for temp-param .
define variable v-report-num            as integer no-undo .
define variable v-filename              as character    no-undo .
define variable v-obj-dir               as character    no-undo .
define variable v-report-filename       as character    no-undo .
define variable v-home-dir-filename     as character    no-undo .
define variable v-error-num             as integer      no-undo .
define variable v-template-file-name    as character    no-undo .
define variable v-vb-file-name          as character    no-undo .
define variable v-data-header-filename  as character    no-undo .
define variable v-data-filename         as character    no-undo .
define variable v-excel-file-name       as character    no-undo .
define variable v-err-message           as character    no-undo .
define variable v-os-err-str            as character    no-undo .
define variable v-report-dir            as character    no-undo .
do for buf_temp-param
on error undo, return error return-value
:
assign
  v-report-dir  = trim( replace( p-dir-name, '/' , '\' ) , '\' )
.
  assign
  v-report-num = g#report-num
  v-obj-dir           = v-report-dir + chr(47) +
                        (if p-subdir-name <> '' then (p-subdir-name + chr(47)) else '')
  v-filename          = string( session:temp-directory ) + "rpt" + string( v-report-num )
  v-excel-file-name   = string( session:temp-directory ) + "rpt" + string( v-report-num ) + ".xls"
  v-home-dir-filename = v-obj-dir +  p-custom-name
  .
  os-delete value( v-filename + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( v-report-num ) + ".txl" )
    value( v-filename + ".txl" )
  .
  assign
    v-filename = search( v-filename + ".txl" )
  .
  if v-filename = "" or v-filename = ?
  then do:
    assign
      v-err-message = v-err-message + substitute( "Не найден файл &1 для формирования Excel-файла по объекту p-custom-name"
                                                , string( session:temp-directory ) + "rpt" + string( v-report-num )
                                                )
    .
    return error v-err-message.
  end.
  input stream reprumpr_in from value( v-filename ).
  import stream reprumpr_in v-template-file-name   no-error .
  import stream reprumpr_in v-vb-file-name         no-error .
  import stream reprumpr_in v-data-header-filename no-error .
  import stream reprumpr_in v-data-filename        no-error .
  input stream reprumpr_in close.
  if search( v-template-file-name ) = ?
  then do:
    assign
      v-err-message = v-err-message + substitute( "Не найден шаблон Excel для вывода данных.&2Указан файл шаблона:&1&2&2"
                                                , v-template-file-name
                                                , chr(10)
                                                )
    .
    return error v-err-message.
  end.
  if search( v-vb-file-name ) = ?
  then do:
    assign
      v-err-message = v-err-message + substitute( "Не найден текст программы заполнения шаблона Excel.&3Файл шаблона:&1&3Указан файл программы:&2&3&3"
                                                , v-template-file-name
                                                , v-vb-file-name
                                                , chr(10)
                                                )
    .
    return error v-err-message.
  end.
  if v-data-header-filename <> "":U
  and search( v-data-header-filename ) = ?
  then do:
    assign
      v-err-message = v-err-message + substitute( "Не найден файл шапки.&3Файл шаблона:&1&3Указан файл шапки:&2&3&3"
                                                , v-template-file-name
                                                , v-data-header-filename
                                                , chr(10)
                                                )
    .
    return error v-err-message.
  end.
  if v-data-filename <> "":U
  and search( v-data-filename )   = ?
  then do:
    assign
      v-err-message = v-err-message + substitute( "Не найден файл строк данных.&3Файл шаблона:&1&3Указан файл строк данных:&2&3&3"
                                                , v-template-file-name
                                                , v-data-filename
                                                , chr(10)
                                                )
    .
    return error v-err-message.
  end.
  create buf_temp-param.
  assign
    v-template-file-name = search( v-template-file-name )
    file-info :file-name = v-template-file-name
    v-template-file-name = file-info :full-pathname
    v-vb-file-name       = search( v-vb-file-name )
    file-info :file-name = v-vb-file-name
    v-vb-file-name       = file-info :full-pathname
  .
  if v-template-file-name = ? or v-template-file-name = "":U
  then do:
    RETURN error substitute("Не найден шаблон &1", v-template-file-name).
  end.
  run paramls-write in this-procedure ( input "template":U
                                      , input "template-file-name":U
                                      , input v-template-file-name
                                      ).
  run paramls-write in this-procedure ( input "template":U
                                      , input "vb-file-name":U
                                      , input v-vb-file-name
                                      ).
  run paramls-write in this-procedure ( input "data":U
                                      , input "data-header-filename":U
                                      , input v-data-header-filename
                                      ).
  run paramls-write in this-procedure ( input "data":U
                                      , input "data-filename":U
                                      , input v-data-filename
                                      ).
  run paramls-write in this-procedure ( input "saveas":U
                                      , input "excel-file-name":U
                                      , input v-excel-file-name
                                      ).
  run paramls-write in this-procedure ( input "file":U
                                      , input "file-no-open":U
                                      , input "yes":U
                                      ).
  run gbl/macroxlt.p ( input-output table buf_temp-param ) no-error.
  if error-status :error
  then do:
    assign
      v-err-message = v-err-message + substitute( "&1&2&3&4Ошибка создания файла Excel.&4&5&4&6&4&7&4&8&4&4"
                                                , vss-workfile
                                                , vss-revision
                                                , vss-description
                                                , chr(10)
                                                , return-value
                                                , trim(error-status :get-message(1))
                                                , trim(error-status :get-message(2))
                                                , trim(error-status :get-message(3))
                                                )
    .
    return error v-err-message.
  end.
  run prnexldl_clear in this-procedure ( input v-filename) no-error.
  if error-status :error
  then do:
    assign
      v-err-message = v-err-message + substitute( "Ошибка удаления файла &1: &2 &3&3"
                                                , v-filename
                                                , return-value
                                                , chr(10)
                                                )
    .
    return error v-err-message.
  end.
  run gbl/dir-cre.p ( input v-obj-dir ) no-error  .
  if error-status :error
  then do:
    assign
      v-err-message = v-err-message + substitute( "Ошибка создания директории &1: &2&4&3&4&4"
                                                , v-filename
                                                , return-value
                                                , trim(error-status :get-message(1))
                                                , chr(10)
                                                )
    .
  end.
  run gbl/del-file.p ( input v-home-dir-filename ) no-error .
  if error-status :error
  then do:
    assign
      v-err-message = v-err-message + substitute( "Ошибка удаления файла &1: &2 &3&3"
                                                , v-home-dir-filename
                                                , return-value
                                                , chr(10)
                                                )
    .
    return error v-err-message.
  end.
  run gbl/ren-file.p ( input v-excel-file-name
                  , input v-home-dir-filename
                  ) no-error .
  if error-status :error
  then do:
    assign
      v-err-message = v-err-message + substitute( "Ошибка перемещения файла &1 -> &2: &3&4&4"
                                                , v-excel-file-name
                                                , v-home-dir-filename
                                                , return-value
                                                , chr(10)
                                                )
    .
    return error v-err-message.
  end.
  run cb_fill-report-destination in p-parent-handle (  input p-rdbh
                                                ,input p-report-id
                                                ,input 'excel':U
                                                ,input v-home-dir-filename
                                                ,input string(p-disable-option) + chr(4) + string(p-font-number)
                                                ).
end.
end procedure.
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table report-headert no-undo
field datetimeStart as datetime
field datetimeEnd as datetime
field report-name as character
field report-label as character
field report-id as character
field report-db-num as integer
field task-num as integer
index pi is unique primary
report-id
.
define  temp-table report-parameterst no-undo
field report-id as character
field parameter-name as character
field parameter-label as character
field parameter-value-type as character
field parameter-value as character
field parameter-index as integer
field parameter-des as character
index pi is unique primary
report-id
parameter-name
parameter-index
.
define  temp-table report-errorst no-undo
field report-id as character
field ErrNum as integer
field ErrCode as integer
field ErrSeverity as integer
field ErrMessage as character
index pi is unique primary
report-id
ErrNum.
define  temp-table report-destinationt no-undo
field report-id as character
field destination-id as character
field destination as character
field destination-details as character
index pi is unique primary
report-id
destination-id.
define temp-table obj-list no-undo
field obj-type as character
field obj-code as integer
field obj-name as character
field db-num as integer
field obj-address as character
field obj-phone as character
field obj-number as integer
index pi is unique primary
obj-type
obj-code
.
define temp-table tt-place no-undo
field obj-type as character
field obj-code as integer
field obj-number as integer
field gds-code as integer
field gds-name as character
field loc1 as character
field max-qnty as decimal
field add-qnty as decimal
field min-qnty as decimal
field current-sale  as decimal
field income as decimal
field sale-qnty-7 as decimal
field curr-qnty as decimal
field doc-qnty as decimal
field sale-qnty-1 as decimal
field curr-date as date
field curr-time-str as character
field level-water as decimal
field volume-water  as decimal
field obj-name           as character
field obj-address        as character
field obj-phone          as character
field sort-code          as integer
field pl-code            as integer
field found-in-rvs       as logical
field is-meas            as logical
field curr-time          as integer
index pu as primary unique
      obj-type
      obj-code
      sort-code
      gds-code
      pl-code
index i-print
      obj-number
      sort-code
      gds-code
      pl-code
INDEX rvs
      obj-type
      obj-code
      found-in-rvs
.
define dataset dispet-1
for obj-list, tt-place, report-headert, report-parameterst, report-errorst
data-relation r1 for obj-list, tt-place
relation-fields (obj-type, obj-type, obj-code, obj-code) nested
data-relation rh1 for report-headert, report-parameterst
relation-fields (report-id, report-id) nested
data-relation rh2 for report-headert, report-errorst
relation-fields (report-id, report-id) nested
.
DEFINE VARIABLE sym1  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym2  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym3  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym4  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym5  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym6  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym7  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym8  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym9  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym10 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym16 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym17 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym11 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym12 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym13 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym14 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym15 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
define variable v-obj-name-list    as character    no-undo.
define variable v-i    as integer      no-undo.
define variable v-obj-list    as character    no-undo.
define variable v-rep-list    as character    no-undo.
define variable v-write-err as logical no-undo .
DEFINE STREAM out-stream.
FUNCTION number-from-string RETURNS INTEGER
  ( input p-name as character, input p-code as integer )  FORWARD.
FUNCTION get-report-file-name returns character
   ( input p-date as date, input p-time as integer) FORWARD.
define buffer buf_clients     for ub.clients .
do
on error  undo , return error return-value
on endkey undo , return error return-value
on stop   undo , return error return-value
   :
  ASSIGN
  v-rep-list = "Dispet"
  .
  if p-report-id = "50/2034" then do:
    p-rebh = buffer report-errorst:handle.
  end.
  if valid-handle(p-parent-handle)
  and lookup("cb_write-report-error", p-parent-handle:internal-entries) > 0
  and valid-handle(p-rebh)
  and p-xml = yes
  then do:
    v-write-err = yes.
  end.
define variable v-account as integer init 0 no-undo .
define variable v-account-lavel as character no-undo .
define variable v-button-stop as logical no-undo .
define variable v-kol-spice as integer no-undo .
define variable v-kol-spice2 as integer no-undo .
define variable v-kol-spice3 as integer no-undo .
DEFINE VARIABLE StopProcessing AS LOGICAL NO-UNDO.
DEFINE BUTTON StopBtn AUTO-END-KEY
     LABEL "Стоп"
     SIZE 10 BY 1.
DEFINE VARIABLE RecordsDone AS INTEGER FORMAT ">,>>>,>>>,>>9":U INITIAL 0
     LABEL "Обработано записей"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE RecordsString AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString2 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString3 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.13 BY 4.46.
DEFINE FRAME InfoFrame
     StopBtn AT ROW 4.25 COL 21.75
     RecordsString AT ROW 1.21 COL 2 NO-LABEL
     RecordsString2 AT ROW 1.96 COL 2 NO-LABEL
     RecordsString3 AT ROW 2.58 COL 2 NO-LABEL
     RecordsDone AT ROW 3.42 COL 24.88 COLON-ALIGNED
     RECT-1 AT ROW 1 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Процесс"
         DEFAULT-BUTTON StopBtn CANCEL-BUTTON StopBtn.
define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame InfoFrame:handle.
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameRepError").
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  if mFrameView
  then do:
    ASSIGN
       FRAME InfoFrame:HIDDEN                           = TRUE
       StopBtn:sensitive IN FRAME InfoFrame             = TRUE.
  end.
ON CHOOSE OF StopBtn IN FRAME InfoFrame
DO:
  IF not StopProcessing THEN
    Message "Вы действительно хотите прервать" SKIP
            "процесс проверки?" view-as alert-box QUESTION BUTTONS yes-no
              UPDATE StopProcessing.
  IF StopProcessing THEN do:
     if mFrameView
     then do:
        HIDE FRAME InfoFrame.
     end.
  End.
END.
assign v-account = ( if integer( 10 ) = 0 then 100 else integer( 10 ) ).
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("ON mFrameView=" + string(mFrameView), "frameRepError").
  end.
  if not session:batch-mode then
  do:
    VIEW FRAME InfoFrame.
    mFrameView = true.
  end.
   v-button-stop = false .
      if mFrameView
      then do:
      if v-button-stop then view STOPBTN in frame InfoFrame.
                       else Hide STOPBTN in frame InfoFrame.
      end.
  define variable v-param-type as character no-undo .
  define variable v-value-date as date no-undo .
  define variable v-value-decimal as decimal no-undo .
  define variable v-value-integer as INTEGER no-undo .
  define variable v-value-logical AS LOGICAL no-undo .
  define variable v-tth as handle no-undo .
  run adm/shattri.p (
      input "get":U
      ,input  ''
      ,input  0
      ,input  'report-glob':U
      ,input  'rep-sort':U
                    , output v-sort-list
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
                    ) no-error.
  if error-status:error
  or v-sort-list = "":U
  then do:
    delete object v-tth.
        if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input "Не заполнен параметр  в секции Настройки для ОТЧЕТОВ - Сортировка топлива в отчетах по октановому числу").    end.    else do:       run write-to-log in p-log-handle ( input "Не заполнен параметр  в секции Настройки для ОТЧЕТОВ - Сортировка топлива в отчетах по октановому числу").    end.
    if p-xml
    and v-write-err
    then do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
                                                    ,input p-report-id
                                                    ,input ?
                                                    ,input '3':U
                                                    ,input "Не заполнен параметр  в секции Настройки для ОТЧЕТОВ - Сортировка топлива в отчетах по октановому числу").
    end.
    RETURN ERROR.
  end.
  else do:
    assign
    v-sort     = true
    v-sort-max = NUM-ENTRIES(v-sort-list) + 10
    .
  end.
  delete object v-tth.
  DO v-i = 1 TO NUM-ENTRIES(p-cli-list):
    FIND FIRST buf_clients
        WHERE RECID(buf_clients) = integer(entry(v-i , p-cli-list))
        NO-LOCK
        NO-ERROR
    .
    CREATE obj-list.
    Buffer-copy buf_clients TO obj-list.
  END.
  IF  NOT CAN-FIND( FIRST obj-list) THEN DO:
        if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input "Не выбрано ни одного объекта").    end.    else do:       run write-to-log in p-log-handle ( input "Не выбрано ни одного объекта").    end.
    if p-xml
    and v-write-err
    then do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
                                                    ,input p-report-id
                                                    ,input ?
                                                    ,input '3':U
                                                    ,input "Не выбрано ни одного объекта").
    end.
    RETURN ERROR.
  END.
  run fill-data in this-procedure .
if session :set-wait-state( "compiler" ) then.
  run get-report-num in parParentProc ( output g#report-num).
  IF p-batch = integer('0':U) THEN DO:
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
  END.
  if p-excel
  or p-batch = integer('0':U)
  then do:
    RUN disp-xl-init IN THIS-PROCEDURE.
    RUN print-header IN THIS-PROCEDURE .
    run print-body in this-procedure .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
    RUN disp-xl-close IN THIS-PROCEDURE .
  end.
  IF p-batch  > 0 THEN DO:
    IF p-excel THEN DO:
      RUN reprumpr_print-xlt (  input p-dir-excel
                               ,input ""
                               ,input get-report-file-name( p-date, p-time) + ".xls"
                               ,input 8
                               ,input 7
                             ) no-error.
      if error-status:error then do:
            if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input v-message).    end.    else do:       run write-to-log in p-log-handle ( input v-message).    end.
      end.
    END.
    IF  p-xml THEN DO:
      RUN print-xml IN THIS-PROCEDURE.
    END.
  END.
  ELSE DO:
    output stream out-stream close.
    define variable v-user-action   as character no-undo .
    define variable v-printed       as logical   no-undo .
    define variable ReportFontNum   as integer no-undo .
    os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
    os-rename
      value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
      value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
    .
    run gbl/prnfilen.w
        ( input  ""
        , input  8
        , input  string(session :temp-directory) + "rpt" + string( g#report-num )
        , input  ReportFontNum
        , output v-user-action
        , output v-printed
        ) .
    os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
  END.
  empty temp-table tt-place.
if session :set-wait-state( "" ) then.
end.
procedure fill-data :
define buffer buf_place       for ub.place .
define buffer buf_rvs-doc     for ub.rvs-doc .
define buffer buf_rvs-line    for ub.rvs-line .
define buffer buf_pl-gds      for ub.pl-gds .
define buffer buf_goods       for ub.goods .
define buffer buf_prod-bc     for ub.prod-bc .
define buffer buf_bar-code    for ub.bar-code .
define buffer buf_doc-line-attr     for ub.doc-line-attr .
define buffer buf_tt-place    for tt-place .
define buffer buf_obj-list    for obj-list.
define variable v-not-first-obj    as logical      no-undo.
define variable v-gds-name    as character    no-undo.
define variable v-gds-code    as integer      no-undo.
define variable v-attr-value    as character no-undo .
define variable v-attr-type     as character no-undo .
define variable v-number      as INTEGER    no-undo.
define variable v-cntxt-db-num    as INTEGER       no-undo .
define variable v-fact-order      as decimal       no-undo .
define variable v-res as logical no-undo.
define variable v-value as character no-undo.
define variable v-min-qnty as decimal no-undo .
define variable v-income   as decimal no-undo .
define variable v-current-sale  as decimal no-undo .
do
on error undo, return error
:
  run get-db-num in parparentproc ( output v-cntxt-db-num).
  _obj:
  FOR EACH buf_obj-list NO-LOCK:
    IF  v-not-first-obj
    AND v-cntxt-db-num <> 0
    and p-batch = integer('0':U)
    THEN DO:
            if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input "на УБД для отчета допустим только текущий объект").    end.    else do:       run write-to-log in p-log-handle ( input "на УБД для отчета допустим только текущий объект").    end.
      leave _obj.
    end.
    RUN fmtcli-get-client IN THIS-PROCEDURE ( INPUT  buf_obj-list.obj-type
                                            , INPUT  buf_obj-list.obj-code
                                            ) .
    ASSIGN
    v-obj-list = v-obj-list + SUBSTITUTE("&1 &2", buf_obj-list.obj-type, buf_obj-list.obj-code) + ","
    .
    find last buf_rvs-doc
        where buf_rvs-doc.obj-type  = buf_obj-list.obj-type
          and buf_rvs-doc.obj-code  = buf_obj-list.obj-code
          and buf_rvs-doc.status_   = 'факт':U
          and ((buf_rvs-doc.doc-date < p-date)
          OR  (buf_rvs-doc.doc-date = p-date
          AND buf_rvs-doc.fact-time < p-time))
          use-index stat-fact
        no-lock
        no-error
        .
    IF NOT AVAILABLE buf_rvs-doc THEN DO:
             if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input Substitute ( "На объекте &1 &2 нет закрытых сверок"                                   , buf_obj-list.obj-code                                   , buf_obj-list.obj-type                                   )).    end.    else do:       run write-to-log in p-log-handle ( input Substitute ( "На объекте &1 &2 нет закрытых сверок"                                   , buf_obj-list.obj-code                                   , buf_obj-list.obj-type                                   )).    end.
      if p-xml
      and v-write-err
      then do:
        run cb_write-report-error in p-parent-handle ( input p-rebh
                                                      ,input p-report-id
                                                      ,input ?
                                                      ,input '3':U
                                                      ,input Substitute ( "На объекте &1 &2 нет закрытых сверок"                                   , buf_obj-list.obj-code                                   , buf_obj-list.obj-type                                   )).
      end.
      next _obj.
    END.
    assign
    v-fact-order    = buf_rvs-doc.fact-order
    v-obj-name-list = IF v-obj-name-list = "":U
                      THEN buf_obj-list.obj-name
                      else SUBSTITUTE ( "&1, &2"
                                      , v-obj-name-list
                                      , buf_obj-list.obj-name
                                      )
    .
    FOR EACH  buf_place
        WHERE buf_place.obj-type = buf_obj-list.obj-type
          and buf_place.obj-code = buf_obj-list.obj-code
          and buf_place.status_ <> 'удал':U
        no-lock :
        assign
          v-min-qnty = 0
          v-income = 0
          v-current-sale = 0
        .
        run placelib_get-attr(
              "dead-balance",
              buf_place.obj-code,
              buf_place.obj-type,
              buf_place.pl-code,
              output v-value,
              output v-res
          ).
          if v-res then do:
              v-min-qnty = decimal(v-value).
          end.
          for first buf_rvs-line-attr no-LOCK where buf_rvs-line-attr.attr-code = "income"
                                 and buf_rvs-line-attr.rvs-code = buf_rvs-doc.rvs-code
                                 and buf_rvs-line-attr.obj-code = buf_place.obj-code
                                 and buf_rvs-line-attr.obj-type = buf_place.obj-type
                                 and buf_rvs-line-attr.pl-code = buf_place.pl-code
                                 and buf_rvs-line-attr.rvs-code = buf_rvs-doc.rvs-code:
            v-income = DECIMAL (buf_rvs-line-attr.attr-value) .
          end.
          for first buf_rvs-line-attr no-LOCK where buf_rvs-line-attr.attr-code = "current-sale"
                                 and buf_rvs-line-attr.rvs-code = buf_rvs-doc.rvs-code
                                 and buf_rvs-line-attr.obj-code = buf_place.obj-code
                                 and buf_rvs-line-attr.obj-type = buf_place.obj-type
                                 and buf_rvs-line-attr.pl-code = buf_place.pl-code
                                 and buf_rvs-line-attr.rvs-code = buf_rvs-doc.rvs-code:
            v-current-sale = DECIMAL (buf_rvs-line-attr.attr-value) .
          end.
      assign
      v-sort-code = v-sort-max
      v-gds-code  = 0
      v-gds-name  = "":U
      .
      assign
      .
      create buf_tt-place.
      assign
      buf_tt-place.obj-type = buf_place.obj-type
      buf_tt-place.obj-code = buf_place.obj-code
      buf_tt-place.pl-code  = buf_place.pl-code
      buf_tt-place.loc1     = buf_place.loc1
      buf_tt-place.max-qnty = buf_place.max-qnty
      buf_tt-place.add-qnty = buf_place.add-qnty
      buf_tt-place.min-qnty = v-min-qnty
      buf_tt-place.current-sale = v-current-sale
      buf_tt-place.income = v-income
      buf_tt-place.is-meas    = buf_place.is-meas
      buf_tt-place.obj-number = buf_place.obj-code
      buf_tt-place.obj-name = buf_obj-list.obj-name
      buf_tt-place.obj-address = ( if v-fmtcli-index <> '':U then ( v-fmtcli-index ) else '':U )
                                + ( if v-fmtcli-full-addres <> '':U then ( v-fmtcli-full-addres ) else '':U )
      buf_tt-place.obj-phone   = ( if v-fmtcli-phone <> '':U then v-fmtcli-phone else '':U )
      buf_obj-list.obj-number  = (if   buf_obj-list.obj-number <> buf_tt-place.obj-number
                              then buf_tt-place.obj-number
                              else  buf_obj-list.obj-number)
      buf_obj-list.obj-address = (if  buf_obj-list.obj-address <> buf_tt-place.obj-address
                              then buf_tt-place.obj-address
                              else  buf_obj-list.obj-address)
      buf_obj-list.obj-phone   = (if  buf_obj-list.obj-phone <> buf_tt-place.obj-phone
                              then buf_tt-place.obj-phone
                              else  buf_obj-list.obj-phone)
      .
      IF available buf_rvs-doc then do:
        find first buf_rvs-line
              where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                and buf_rvs-line.obj-type = buf_place.obj-type
                and buf_rvs-line.obj-code = buf_place.obj-code
                and buf_rvs-line.pl-code  = buf_place.pl-code
            no-lock
            no-error
            .
        if available buf_rvs-line then do:
          find  first buf_goods
                where buf_goods.gds-code = buf_rvs-line.gds-code
                no-lock
                no-error
                        .
          IF AVAILABLE buf_goods then do:
            assign
              v-gds-code = buf_goods.gds-code
              v-gds-name = buf_goods.gds-name
            .
            IF LOOKUP(string(buf_goods.gds-code) , v-sort-list) <> 0 then do:
              assign
                v-sort-code = LOOKUP(string(buf_goods.gds-code) , v-sort-list)
              .
            end.
            else do:
              assign
                v-sort-code = v-sort-max
              .
            end.
          end.
          else do:
            assign
            v-gds-code = buf_rvs-line.gds-code
            v-gds-name = SUBSTITUTE("Нет товара &1", buf_rvs-line.gds-code)
            .
          end.
          assign
          buf_tt-place.found-in-rvs  = TRUE
          buf_tt-place.curr-qnty     = buf_rvs-line.state-measure-qnty
          buf_tt-place.level-water   = buf_rvs-line.state-level-water
          buf_tt-place.volume-water  = buf_rvs-line.state-brutto-qnty - buf_rvs-line.state-measure-qnty
          buf_tt-place.curr-date     = buf_rvs-doc.fact-date
          buf_tt-place.curr-time     = buf_rvs-doc.fact-time
          buf_tt-place.curr-time-str = STRING(buf_rvs-doc.fact-time, "HH:MM:SS") + ".000"
          buf_tt-place.gds-code      = v-gds-code
          buf_tt-place.gds-name      = v-gds-name
          buf_tt-place.sort-code     = v-sort-code
          .
          find first buf_doc-line-attr
                where buf_doc-line-attr.doc-code   = buf_rvs-doc.rvs-code
                  and buf_doc-line-attr.gds-code   = buf_goods.gds-code
                  and buf_doc-line-attr.attr-code  = SUBSTITUTE("rvs-&1",buf_place.pl-code)
              no-lock
              no-error
              .
          if available buf_doc-line-attr then do:
            assign
            buf_tt-place.doc-qnty     = DECIMAL(ENTRY(1, buf_doc-line-attr.attr-value, chr(4)))
            .
          END.
        end.
      end.
    END.
    IF CAN-FIND (FIRST buf_tt-place
                  WHERE buf_tt-place.obj-type = buf_obj-list.obj-type
                    AND buf_tt-place.obj-code = buf_obj-list.obj-code
                    AND buf_tt-place.found-in-rvs = FALSE)
    THEN DO:
      run get-prev-rvs ( input v-fact-order
                        , input buf_obj-list.obj-type
                        , input buf_obj-list.obj-code
                          ) .
    END.
    FOR EACH buf_tt-place
          where  buf_tt-place.obj-type = buf_obj-list.obj-type
            and buf_tt-place.obj-code = buf_obj-list.obj-code
            and buf_tt-place.found-in-rvs = FALSE
          :
      DELETE buf_tt-place.
    END.
    run fill-sale IN THIS-PROCEDURE
                    ( input buf_obj-list.obj-type
                    , input buf_obj-list.obj-code
                    , input (p-date - 1)
                    , INput YES
                    ).
    run fill-sale IN THIS-PROCEDURE
                    ( input buf_obj-list.obj-type
                    , input buf_obj-list.obj-code
                    , input (p-date - 7)
                    , INput NO
                    ).
    release buf_rvs-doc.
    assign
    v-not-first-obj = TRUE
    .
  END.
  FOR EACH buf_tt-place :
    assign
    v-attr-value = ?
    v-attr-type  = ?
    .
    run gds-attr-value in this-procedure
        ( input  buf_tt-place.gds-code
        , input  'ptrl-without-rvs':U
        , output v-attr-value
        , output v-attr-type
        ) .
    if lookup(v-attr-value, 'true,yes':u) > 0
    then do:
      delete buf_tt-place.
    end.
  end.
end.
end procedure.
procedure fill-sale :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-sale-date  as date             no-undo.
define input parameter p-day        as logical          no-undo.
define variable v-prev-gds-code    as integer      no-undo.
define buffer buf_chk-gds     for ub.chk-gds .
define buffer buf_chk-doc     for ub.chk-doc .
define buffer buf_tt-place    for tt-place .
define buffer buf_bar-code    for ub.bar-code .
define buffer buf_inkas       for ub.inkas .
do
on error undo, return error
:
   for each  buf_chk-doc
      where  buf_chk-doc.obj-type = p-obj-type
         and buf_chk-doc.obj-code = p-obj-code
         and buf_chk-doc.chk-date = p-sale-date
         and (buf_chk-doc.chk-type = INTEGER('1':U)
          OR  buf_chk-doc.chk-type = INTEGER('6':U))
         and buf_chk-doc.out-code <> ?
         no-lock
         ,
        first buf_inkas
        where buf_inkas.inkas-code = buf_chk-doc.out-code
          and buf_inkas.status_    = 'факт':U
      no-lock
      :
      ASSIGN
         v-prev-gds-code = 0
      .
      _place:
      FOR EACH  buf_tt-place
      where buf_tt-place.obj-type = p-obj-type
        and buf_tt-place.obj-code = p-obj-code
      :
         FIND FIRST buf_bar-code
               where buf_bar-code.gds-code = buf_tt-place.gds-code
            NO-LOCK
            .
         FOR each buf_chk-gds
         where buf_chk-gds.doc-code = buf_chk-doc.doc-code
            and buf_chk-gds.b-code = buf_bar-code.b-code
            and buf_chk-gds.loc1 = buf_tt-place.loc1
         no-lock
         :
            IF p-day then do:
               assign
                  buf_tt-place.sale-qnty-1 = buf_tt-place.sale-qnty-1 + buf_chk-gds.doc-qnty
               .
            end.
            else do:
               assign
                  buf_tt-place.sale-qnty-7 = buf_tt-place.sale-qnty-7 + buf_chk-gds.doc-qnty
               .
            end.
         end.
         ASSIGN
            v-prev-gds-code = buf_tt-place.gds-code
         .
      END.
   end.
end.
end procedure.
procedure print-header :
do
on error undo, return error
:
   IF p-batch = integer('0':U)
   THEN DO:
   put stream out-stream
      "ОТЧЕТ ДИСПЕТЧЕРА" at 25 skip(1)
      "АЗС: " v-obj-name-list FORMAT "x(212)"skip
         "Дата отчета:" p-date " время отчета:" STRING(p-time, "HH:MM:SS") skip(1)
"+--------------------+----------------------------------+---------------+---------------+--------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+--------+--------+-----------+"       skip
"|                    |                                  |               |               |        |           |           |           |           |           |           |           |        |        |           |"       skip
"|        АЗС         |              Адрес               |    телефон    |     Марка     | № ре-  |   Объем   |  Трубо-   | Ожидаемая | Фактиче-  | Уровень   |   Объем   | Остаток   |  Дата  | Время  |реализация |"       skip
"|                    |                                  |               |     н/пр      | зерву- |           |  провод   | реализация| ский      | воды, см  |  воды, л  | по чекам  |  изме- | изме-  |( прошлые  |"       skip
"|                    |                                  |               |               | ара    |           |           |           | остаток   |           |           | и док-ам  |  рения | рения  |   сутки ) |"       skip
"|                    |                                  |               |               |        |           |           |           |           |           |           |           |        |        |           |"       skip
"+--------------------+----------------------------------+---------------+---------------+--------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+--------+--------+-----------+"       skip
   .
   END.
   run disp-xl-write-cell-data in this-procedure ( input "h_obj_name_list":U,  input v-obj-name-list ).
   run disp-xl-write-cell-data in this-procedure ( input "h_date":U,           input p-date ) .
   run disp-xl-write-cell-data in this-procedure ( input "h_time":U,           input STRING( p-time, "HH:MM:SS" ) ) .
end.
end procedure.
procedure print-body :
define buffer buf_tt-place    for tt-place .
define variable v-line    as character    no-undo.
  define frame f-first
    sym1                       no-label format "X(1)"       space(0)
    buf_tt-place.obj-name      no-label format "X(20)"      space(0)
    sym2                       no-label format "X(1)"       space(0)
    buf_tt-place.obj-address   no-label format "X(34)"      space(0)
    sym3                       no-label format "X(1)"       space(0)
    buf_tt-place.obj-phone     no-label format "X(15)"      space(0)
    sym4                       no-label format "X(1)"       space(0)
    buf_tt-place.gds-name      no-label format "x(15)"      space(0)
    sym5                       no-label format "X(1)"       space(0)
    buf_tt-place.loc1          no-label format "X(8)"       space(0)
    sym6                       no-label format "X(1)"       space(0)
    buf_tt-place.max-qnty      no-label format "->>>,>>9.99" space(0)
    sym7                       no-label format "X(1)"       space(0)
    buf_tt-place.add-qnty      no-label format "->>>,>>9.99" space(0)
    sym8                       no-label format "X(1)"       space(0)
    buf_tt-place.sale-qnty-7   no-label format "->>>,>>9.99" space(0)
    sym9                       no-label format "X(1)"       space(0)
    buf_tt-place.curr-qnty     no-label format "->>>,>>9.99" space(0)
    sym16                      no-label format "X(1)"       space(0)
    buf_tt-place.level-water   no-label format "->>>,>>9.99" space(0)
    sym17                      no-label format "X(1)"       space(0)
    buf_tt-place.volume-water  no-label format "->>>,>>9.99" space(0)
    sym10                      no-label format "X(1)"       space(0)
    buf_tt-place.doc-qnty      no-label format "->>>,>>9.99" space(0)
    sym15                      no-label format "X(1)"       space(0)
    buf_tt-place.curr-date     no-label format "99/99/99"   space(0)
    sym12                      no-label format "X(1)"       space(0)
    buf_tt-place.curr-time-str no-label format "X(8)"       space(0)
    sym13                      no-label format "X(1)"       space(0)
    buf_tt-place.sale-qnty-1   no-label format "->>>,>>9.99" space(0)
    sym14                      no-label format "X(1)"       space(0)
    skip
  with width 212 down stream-io no-labels no-box.
do
on error undo, return error
:
   assign
      v-line        = fill( "-" , 212 )
   .
   FOR EACH buf_tt-place
   :
      IF buf_tt-place.sort-code >= v-sort-max
      OR buf_tt-place.sort-code <= 0
      THEN DO:
         DELETE buf_tt-place.
      END.
   end.
   FOR EACH buf_tt-place
       BREAK BY buf_tt-place.obj-number
             BY buf_tt-place.sort-code
             BY buf_tt-place.gds-code
   :
      IF FIRST-OF (buf_tt-place.obj-number)
      then do:
         IF p-batch = integer('0':U)
         THEN DO:
         DISPLAY STREAM out-stream
               buf_tt-place.obj-name
               buf_tt-place.obj-address
               buf_tt-place.obj-phone
               buf_tt-place.gds-name
               buf_tt-place.loc1
               buf_tt-place.max-qnty
               buf_tt-place.add-qnty
               buf_tt-place.sale-qnty-7
               buf_tt-place.curr-qnty
               buf_tt-place.level-water
               buf_tt-place.volume-water
               buf_tt-place.doc-qnty
               buf_tt-place.curr-date
               buf_tt-place.curr-time-str
               buf_tt-place.sale-qnty-1
                  sym1  sym2  sym3
               sym4  sym5  sym6
               sym7  sym8  sym9
                  sym16 sym17
                  sym10 sym12
               sym13 sym14 sym15
         with frame f-first.
         down stream out-stream with frame f-first
         .
         END.
         run disp-xl-write-line-data IN THIS-PROCEDURE
                     ( INPUT buf_tt-place.obj-name
                     , INPUT buf_tt-place.obj-address
                     , INPUT buf_tt-place.obj-phone
                     , INPUT buf_tt-place.gds-name
                     , INPUT buf_tt-place.loc1
                     , INPUT buf_tt-place.max-qnty
                     , INPUT buf_tt-place.add-qnty
                     , INPUT buf_tt-place.sale-qnty-7
                     , INPUT buf_tt-place.curr-qnty
                     , INPUT buf_tt-place.level-water
                     , INPUT buf_tt-place.volume-water
                     , INPUT buf_tt-place.doc-qnty
                     , INPUT buf_tt-place.curr-date
                     , INPUT buf_tt-place.curr-time-str
                     , INPUT buf_tt-place.sale-qnty-1
                     ) .
      end.
      ELSE DO:
         IF FIRST-OF (buf_tt-place.gds-code)
         then do:
            IF p-batch = integer('0':U)
            THEN DO:
            DISPLAY STREAM out-stream
                  "":U @ buf_tt-place.obj-name
                  "":U @ buf_tt-place.obj-address
                  "":U @ buf_tt-place.obj-phone
                  buf_tt-place.gds-name
                  buf_tt-place.loc1
                  buf_tt-place.max-qnty
                  buf_tt-place.add-qnty
                  buf_tt-place.sale-qnty-7
                  buf_tt-place.curr-qnty
                  buf_tt-place.level-water
                  buf_tt-place.volume-water
                  buf_tt-place.doc-qnty
                  buf_tt-place.curr-date
                  buf_tt-place.curr-time-str
                  buf_tt-place.sale-qnty-1
                     sym1  sym2  sym3
                  sym4  sym5  sym6
                  sym7  sym8  sym9
                     sym16 sym17
                     sym10 sym12 sym15
                  sym13 sym14
            with frame f-first.
            down stream out-stream with frame f-first
            .
            END.
            run disp-xl-write-line-data IN THIS-PROCEDURE
                        ( INPUT "":U
                        , INPUT "":U
                        , INPUT "":U
                        , INPUT buf_tt-place.gds-name
                        , INPUT buf_tt-place.loc1
                        , INPUT buf_tt-place.max-qnty
                        , INPUT buf_tt-place.add-qnty
                        , INPUT buf_tt-place.sale-qnty-7
                        , INPUT buf_tt-place.curr-qnty
                        , INPUT buf_tt-place.level-water
                        , INPUT buf_tt-place.volume-water
                        , INPUT buf_tt-place.doc-qnty
                        , INPUT buf_tt-place.curr-date
                        , INPUT buf_tt-place.curr-time-str
                        , INPUT buf_tt-place.sale-qnty-1
                        ) .
         end.
         else do:
            IF p-batch = integer('0':U)
            THEN DO:
            DISPLAY STREAM out-stream
                  "":U @ buf_tt-place.obj-name
                  buf_tt-place.gds-name
                  buf_tt-place.loc1
                  buf_tt-place.max-qnty
                  buf_tt-place.add-qnty
                  "":U @ buf_tt-place.sale-qnty-7
                  buf_tt-place.curr-qnty
                  buf_tt-place.level-water
                  buf_tt-place.volume-water
                  buf_tt-place.curr-date
                  buf_tt-place.curr-time-str
                  "":U @ buf_tt-place.sale-qnty-1
                     sym1
                  sym4  sym5  sym6
                  sym7  sym8  sym9
                     sym16 sym17 sym10 sym12
                  sym13 sym14
            with frame f-first.
            down stream out-stream with frame f-first
            .
            END.
            run disp-xl-write-line-data IN THIS-PROCEDURE
                        ( INPUT "":U
                        , INPUT "":U
                        , INPUT "":U
                        , INPUT buf_tt-place.gds-name
                        , INPUT buf_tt-place.loc1
                        , INPUT buf_tt-place.max-qnty
                        , INPUT buf_tt-place.add-qnty
                        , INPUT "":U
                        , INPUT buf_tt-place.curr-qnty
                        , INPUT buf_tt-place.level-water
                        , INPUT buf_tt-place.volume-water
                        , INPUT buf_tt-place.doc-qnty
                        , INPUT buf_tt-place.curr-date
                        , INPUT buf_tt-place.curr-time-str
                        , INPUT "":U
                        ) .
         end.
      END.
      IF LAST-OF (buf_tt-place.obj-number)
      AND p-batch = integer('0':U)
      then do:
         put stream out-stream
            v-line   FORMAT "x(212)"
         .
      end.
   end.
end.
end procedure.
procedure get-prev-rvs :
define input parameter p-fact-order as decimal          no-undo.
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define buffer buf_tt-place FOR tt-place.
define variable v-fact-order    as decimal      no-undo.
define variable v-gds-name    as character    no-undo.
define variable v-gds-code    as integer      no-undo.
define buffer buf_rvs-doc  for ub.rvs-doc .
define buffer buf_rvs-line for ub.rvs-line .
define buffer buf_goods    for ub.goods .
define buffer buf_prod-bc     for ub.prod-bc .
define buffer buf_bar-code    for ub.bar-code .
define buffer buf_doc-line-attr     for ub.doc-line-attr .
do
on error undo, return error
:
   assign
      v-fact-order = p-fact-order
   .
   do while CAN-FIND (FIRST buf_tt-place
                      WHERE buf_tt-place.obj-type = p-obj-type
                        AND buf_tt-place.obj-code = p-obj-code
                        AND buf_tt-place.found-in-rvs = FALSE
                        ) :
      FIND LAST buf_rvs-doc
         where buf_rvs-doc.obj-type = p-obj-type
         and buf_rvs-doc.obj-code   = p-obj-code
         and buf_rvs-doc.status_    = 'факт':U
         and buf_rvs-doc.fact-order < v-fact-order
         no-lock
         no-error
         .
      IF available buf_rvs-doc then do:
         FOR EACH buf_tt-place
            WHERE buf_tt-place.obj-type = p-obj-type
              AND buf_tt-place.obj-code = p-obj-code
              AND buf_tt-place.found-in-rvs = FALSE
            NO-LOCK
            ,
            first  buf_rvs-line
            where  buf_rvs-line.rvs-code  = buf_rvs-doc.rvs-code
               and buf_rvs-line.obj-type = buf_tt-place.obj-type
               and buf_rvs-line.obj-code = buf_tt-place.obj-code
               and buf_rvs-line.pl-code  = buf_tt-place.pl-code
            no-lock
            :
               find  first buf_goods
                     where buf_goods.gds-code = buf_rvs-line.gds-code
                     no-lock
                     no-error
                     .
               assign
                  v-sort-code = v-sort-max
                  v-gds-code  = 0
                  v-gds-name  = "":U
               .
               IF AVAILABLE buf_goods then do:
                  assign
                     v-gds-code = buf_goods.gds-code
                     v-gds-name = buf_goods.gds-name
                  .
                  IF LOOKUP(string(buf_goods.gds-code) , v-sort-list) <> 0 then do:
                    assign
                        v-sort-code = LOOKUP(string(buf_goods.gds-code) , v-sort-list)
                    .
                  end.
                  else do:
                    assign
                        v-sort-code = v-sort-max
                    .
                  end.
                  IF AVAILABLE buf_prod-bc THEN dO:
                  end.
               end.
               else do:
                  assign
                     v-gds-code = buf_rvs-line.gds-code
                     v-gds-name = SUBSTITUTE("Нет товара &1", buf_rvs-line.gds-code)
                  .
               end.
               assign
                  buf_tt-place.found-in-rvs  = TRUE
                  buf_tt-place.curr-qnty     = buf_rvs-line.state-measure-qnty
                  buf_tt-place.level-water   = buf_rvs-line.state-level-water
                  buf_tt-place.volume-water  = buf_rvs-line.state-brutto-qnty - buf_rvs-line.state-measure-qnty
                  buf_tt-place.curr-date     = buf_rvs-doc.fact-date
                  buf_tt-place.curr-time     = buf_rvs-doc.fact-time
                  buf_tt-place.curr-time-str = STRING(buf_rvs-doc.fact-time, "HH:MM:SS") + ".000"
                  buf_tt-place.gds-code      = v-gds-code
                  buf_tt-place.gds-name      = v-gds-name
                  buf_tt-place.sort-code     = v-sort-code
               .
               find first buf_doc-line-attr
                  where buf_doc-line-attr.doc-code   = buf_rvs-doc.rvs-code
                     and buf_doc-line-attr.gds-code   = buf_goods.gds-code
                     and buf_doc-line-attr.attr-code  = SUBSTITUTE("rvs-&1",buf_rvs-line.pl-code)
                  no-lock
                  no-error
                  .
               if available buf_doc-line-attr then do:
                     assign
                        buf_tt-place.doc-qnty     = DECIMAL(ENTRY(1, buf_doc-line-attr.attr-value, chr(4)))
                     .
               END.
         end.
      end.
      ELSE DO:
         RETURN.
      END.
      assign
         v-fact-order = buf_rvs-doc.fact-order
      .
   end.
end.
end procedure.
procedure get-next-rvs :
define parameter buffer buf_tt-place FOR tt-place.
define input parameter p-fact-order as decimal          no-undo.
define buffer buf_rvs-doc     for ub.rvs-doc .
define buffer buf_rvs-line    for ub.rvs-line .
do
on error undo, return error
:
   FOR EACH buf_rvs-doc
      where buf_rvs-doc.obj-type = buf_tt-place.obj-type
      and buf_rvs-doc.obj-code   = buf_tt-place.obj-code
      and buf_rvs-doc.status_    = 'факт':U
      and buf_rvs-doc.fact-order > p-fact-order
      no-lock
   :
      find first buf_rvs-line
            where buf_rvs-line.rvs-code  = buf_rvs-doc.rvs-code
               and buf_rvs-line.obj-type = buf_tt-place.obj-type
               and buf_rvs-line.obj-code = buf_tt-place.obj-code
               and buf_rvs-line.pl-code  = buf_tt-place.pl-code
               and buf_rvs-line.gds-code = buf_tt-place.gds-code
            no-lock
            no-error
            .
      if available buf_rvs-line then do:
         assign
            buf_tt-place.found-in-rvs  = TRUE
            buf_tt-place.curr-qnty     = buf_rvs-line.state-measure-qnty
            buf_tt-place.level-water   = buf_rvs-line.state-level-water
            buf_tt-place.volume-water  = buf_rvs-line.state-brutto-qnty - buf_rvs-line.state-measure-qnty
            buf_tt-place.curr-date     = buf_rvs-doc.fact-date
            buf_tt-place.curr-time     = buf_rvs-doc.fact-time
            buf_tt-place.curr-time-str = STRING(buf_rvs-doc.fact-time, "HH:MM:SS") + ".000"
         .
      end.
   end.
end.
end procedure.
FUNCTION number-from-string RETURNS INTEGER
  ( input p-name as character
  , input p-code as integer
  ) :
define variable v-temp-number as character    no-undo.
define variable v-temp-char   as character    no-undo.
define variable v-count       as integer      no-undo.
define variable v-found       as logical      no-undo.
_find:
DO v-count = 1 to LENGTH(p-name):
  assign
      v-temp-char = substring( p-name, v-count, 1)
  .
  IF LOOKUP(v-temp-char, "0,1,2,3,4,5,6,7,8,9") > 0 THEN DO:
      ASSIGN
        v-temp-number = v-temp-number + v-temp-char
        v-found = TRUE
      .
  END.
  ELSE DO:
      IF v-found
      THEN LEAVE _find .
  END.
END.
IF v-temp-number <> ""
THEN RETURN INTEGER(v-temp-number) .
ELSE RETURN p-code + 1000000 .
END FUNCTION.
function get-report-file-name returns character ( input p-date as date
                                          ,input p-time as integer):
DEFINE VARIABLE v-hour     AS INTEGER.
DEFINE VARIABLE v-minute   AS INTEGER.
DEFINE VARIABLE v-sec      AS INTEGER.
DEFINE VARIABLE v-timeleft AS INTEGER.
v-sec = p-time MOD 60.
v-timeleft = (p-time - v-sec) / 60.
v-minute = v-timeleft MOD 60.
v-hour = (v-timeleft - v-minute) / 60.
return SUBSTITUTE("&1_&2-&3", STRING(p-date, "99-99-9999") , STRING(v-hour, "99"), STRING(v-minute, "99")).
end function.
procedure print-xml :
define variable v-gate-rec as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-dataseth as handle no-undo .
define variable v-xmlh as handle no-undo .
define buffer buf_temp-xml-tables for temp-xml-tables.
v-xmlh = buffer buf_temp-xml-tables:handle.
if p-report-id  = "52/2039" then do:
  run get-gate-rec in this-procedure ( input p-xsd-file
                                      ,output v-gate-rec) no-error.
  if error-status:error then do:
    undo, return error substitute("Не найдено описание xsd-схемы &1 в БД", p-xsd-file).
  end.
  v-longchar = ?.
  run get-gate-by-rec in this-procedure ( input v-gate-rec
                                        ,output v-dataseth
                                        ,input-output v-xmlh
                                        ,input-output v-longchar
                                        ) no-error.
  if error-status:error then do:
        if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("Ошибка при создании структуры маршрутизируемых данных согласно гейту:&1&2&3&2&4"                               , v-gate-rec                               , chr(10)                               , error-status:get-message(1)                               , return-value )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("Ошибка при создании структуры маршрутизируемых данных согласно гейту:&1&2&3&2&4"                               , v-gate-rec                               , chr(10)                               , error-status:get-message(1)                               , return-value )).    end.
    delete object v-dataseth no-error.
    undo, return error '':U.
  end.
end.
else do:
  define variable v-xsd-file as character no-undo .
  v-xsd-file = search(p-xsd-file).
  run get-gate-by-file in this-procedure ( input v-xsd-file
                                          ,input ''
                                          ,output v-dataseth
                                          ,input-output v-xmlh
                                          ) no-error.
  if error-status:error then do:
        if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("Ошибка при создании структуры маршрутизируемых данных согласно схеме:&1&2&3&2&4"                               , v-gate-rec                               , chr(10)                               , error-status:get-message(1)                               , return-value )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("Ошибка при создании структуры маршрутизируемых данных согласно схеме:&1&2&3&2&4"                               , v-gate-rec                               , chr(10)                               , error-status:get-message(1)                               , return-value )).    end.
    delete object v-dataseth no-error.
    undo, return error '':U.
  end.
  run cb_fill-report-header in p-parent-handle ( input buffer report-headert:handle
                                                ,input p-report-id
                                                ,input "dispet"
                                                ,input "Отчет диспетчера"
                                                ,input v-start-datetime
                                                ,input cur-time-datetime()
                                                ).
  run cb_fill-report-parameters in p-parent-handle ( input buffer report-parameterst:handle
                                                    ,input p-report-id
                                                    ).
  run cb_write-report-parameter in p-parent-handle (
                                                      input (buffer report-parameterst:handle)
                                                     ,input p-report-id
                                                     ,input "p-data-datetime"
                                                     ,input "Дата-время"
                                                     ,input 'character':U
                                                     ,input substitute("&1 &2.000"
                                                                      , string(p-date, "99/99/9999")
                                                                      , string(p-time, "hh:mm:ss"))
                                                     ,input ?
                                                     ,input 0.0
                                                     ,input 0
                                                     ,input no
                                                     ,input 0
                                                     ,input 'Дата-время актуальность данных отчета'
                                                     ).
end.
_xml-tables:
for each buf_temp-xml-tables:
  case buf_temp-xml-tables.tbl-name:
    when "Dispet" then do:
      buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                      buffer obj-list:handle
                                                    , yes
                                                    , no
                                                    , yes
                                                    ) no-error.
    end.
    when "dispetRow" then do:
      buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                      buffer tt-place:handle
                                                    , yes
                                                    , no
                                                    , yes
                                                    ) no-error.
    end.
    when "report-header" then do:
      if p-report-id  <> "52/2039" then do:
        buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                        buffer report-headert:handle
                                                      , yes
                                                      , no
                                                      , yes
                                                      ) no-error.
      end.
    end.
    when "report-parameters" then do:
      if p-report-id  <> "52/2039" then do:
        buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                        buffer report-parameterst:handle
                                                      , yes
                                                      , no
                                                      , yes
                                                      ) no-error.
      end.
    end.
    when "report-errors" then do:
      if p-report-id  <> "52/2039" then do:
        buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                        buffer report-errorst:handle
                                                      , yes
                                                      , no
                                                      , yes
                                                      ) no-error.
      end.
    end.
    otherwise do:
      next _xml-tables.
    end.
  end case.
  if error-status:error then do:
    if v-write-err then do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
                                                    ,input p-report-id
                                                    ,input ?
                                                    ,input '4':U
                                                    ,input substitute("Ошибка при сохранении в XML отчета диспетчера - таблица &1&2&3&2&4"
                                                                      , buf_temp-xml-tables.tbl-name
                                                                      , chr(10)
                                                                      , error-status:get-message(1)
                                                                      , return-value
                                                                      )).
    end.
  end.
end.
if p-report-id  = "52/2039" then do:
  p-dataseth = v-dataseth.
  p-xmlh = v-xmlh.
end.
else do:
  v-dataseth:write-xml("FILE"
                    , (p-dir-xml +  get-report-file-name( p-date, p-time) + ".xml")
                    , yes
                    , "windows-1251"
                    , ?
                    , no
                    , no ) no-error.
  if error-status:error then do:
        if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("Ошибка при записи данных в файл согласно схеме:&1&2&3&2&4"                               , p-xsd-file                               , chr(10)                               , error-status:get-message(1)                               , return-value )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("Ошибка при записи данных в файл согласно схеме:&1&2&3&2&4"                               , p-xsd-file                               , chr(10)                               , error-status:get-message(1)                               , return-value )).    end.
    delete object v-dataseth no-error.
    undo, return error '':U.
  end.
  run gate-clear in this-procedure ( input v-dataseth
                                   ,input v-xmlh) no-error.
end.
end procedure.
