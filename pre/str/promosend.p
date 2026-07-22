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
define variable vss-description as character no-undo init "Толкач пересылки промоакций на кассу".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable p-pos-type    as character no-undo .
define variable p-obj-type    like ub.clients.obj-type no-undo .
define variable p-obj-code    like ub.clients.obj-code no-undo .
define variable action        as char      no-undo .
define variable recid-list    as character no-undo .
define var      choice        as integer   no-undo.
define var      rid-list      as char      no-undo.
define variable glog          as logical   no-undo .
define variable log-file-name as character no-undo init "send-cd.txt":U .
define variable v-view-log as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable vSubs as class ibs.th.ref.promo.promoactionsubs no-undo .
assign
   p-pos-type = entry(1, p-parameter, chr(4))
   p-obj-type = entry(2, p-parameter, chr(4))
   p-obj-code = integer(entry(3, p-parameter, chr(4)))
   action     = entry(4, p-parameter, chr(4))
   recid-list = entry(5, p-parameter, chr(4))
no-error .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
CASE p-pos-type:
  when 'IBM-XML':U
  then do:
    FIND FIRST ub.cash-desk NO-LOCK WHERE
              ub.cash-desk.db-num = g#db-num AND
              ub.cash-desk.pos-type = 'IBM-XML':U
              No-error.
    IF not avail(ub.cash-desk) then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!&1 промоакции реализуются только для POS &2"
                                , (if action = "U" then "Передача" else "Удаление")
                                , 'IBM-XML':U
                              )
                                              ).
      return.
    end.
    if action = "U"
    then do:
    end.
    else do:
    end.
  end.
END CASE.
if recid-list = "" then do:
run gbl/d-askw.w (input "Выбор промоакций для пересылки",
            input ( (if action = "U"
                      then "Переслать на кассу"
                      else "Удалить из кассы" ) + chr(10) +
                              "информацию о промоакциях"
                              ),
            input "|",
            input "Все|Выборочно|Отказ от пересылки",
            input "||",
            input 1,
            input 3,
            output choice).
CASE choice:
   when 1 then
      do:
      end.
   when 2 then
      do:
    run ref/promo.p (input parparentproc,yes,output vSubs) no-error.
    if not valid-object (vSubs) then return.
      end.
   when 3 then
      do:
         return.
      end.
END CASE.
end.
else do:
define variable v-promo-stor as class ibs.th.gbl.storage.promoactionstorage no-undo .
def var ii as integer no-undo .
v-promo-stor = new ibs.th.gbl.storage.promoactionstorage().
do ii = 0 to num-entries(recid-list,chr(44)):
for each ub.PromoAction no-lock where recid(ub.PromoAction) = integer(entry(ii,recid-list,chr(44))):
   v-promo-stor:getpromoactionsubs(input-output vSubs,ub.PromoAction.db-num,ub.PromoAction.id, p-obj-code).
end.
end.
end.
CASE p-pos-type:
  when  'IBM-XML':U
  then do:
    run str/send-promo.p (
                    input parparentproc
                   ,input p-parent-handle
                   ,input p-log-handle
                   ,input p-obj-code
                   ,input action
                   ,input (if not valid-object (vSubs) and recid-list = ""
                           then 0
                           else 1)
                  , input vSubs
                  , input log-file-name
                  , input-output v-view-log
                  ) no-error .
  end.
end CASE.
  finally :
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
