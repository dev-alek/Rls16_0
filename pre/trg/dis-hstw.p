block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.dis-host OLD oldb .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись итогов по диcконтной карте  на фирме".
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
      p-vss-parameters = substitute('&1|&2':u,ub.dis-host.d-card,ub.dis-host.dt-code,ub.dis-host.host-code)
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable for-saldo-rubl as decimal no-undo.
define variable for-saldo-base as decimal no-undo.
define variable l-is-updated-saldo as logical no-undo .
define temp-table tt-dis-host no-undo like ub.dis-host.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status:get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if g#db-num = 0 then do:
    define variable v-curr-r-b as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    if ub.dis-host.host-code > 0
    and ub.dis-host.dt-code = 0
    then do:
      buffer-compare oldb to ub.dis-host
      case-sensitive
      save result in l-is-updated-saldo.
      if l-is-updated-saldo <> yes then do:
        assign
          for-saldo-rubl = ub.dis-host.pay-tot-rubl - (ub.dis-host.gds-tot-rubl - ub.dis-host.gds-dis-rubl )
          for-saldo-base = ub.dis-host.pay-tot-base - (ub.dis-host.gds-tot-base - ub.dis-host.gds-dis-base )
        .
        find first ub.dis-card
          where ub.dis-card.d-card = ub.dis-host.d-card
          no-error .
        if not available ub.dis-card then do:
          undo main-block, return error substitute( "&1. &2&3&4Не найдена дисконтная карта с номером &5"
                                                   , vss-workfile
                                                   , vss-revision
                                                   , vss-description
                                                   , chr(10)
                                                   , ub.dis-host.d-card).
        end.
        if (
            (v-curr-r-b = 'base':U and (for-saldo-base) < ( -0.001))
            OR
            (v-curr-r-b = 'rubl':U and (for-saldo-rubl) < ( -0.001))
            )
        and (not ub.dis-card.credit-card
            or ub.dis-card.emitent-host-code = 0
            )
        then do:
          if ub.dis-card.emitent-host-code = 0
          then do:
            undo main-block, return error substitute( "&1. &2&3&4Не может быть отрицательного сальдо на глобальной дисконтной карте &5"
                                                    , vss-workfile
                                                    , vss-revision
                                                    , vss-description
                                                    , chr(10)
                                                    , ub.dis-host.d-card).
          end.
        end.
        assign
        ub.dis-card.saldo-rubl = for-saldo-rubl
        ub.dis-card.saldo-base = for-saldo-base
        .
      end.
    end.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input 'update':U
        , input 'dis-host':U
        , input ( buffer ub.dis-host:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.
