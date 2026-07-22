block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.fin-ob .
define variable  vss-revision    as character no-undo init "$Revision$":U .
define variable  vss-author      as character no-undo init "$Author$":U .
define variable  vss-date        as character no-undo init "$Date$":U .
define variable  vss-workfile    as character no-undo init "$Workfile$":U .
define variable  vss-archive     as character no-undo init "$Archive$":U .
define variable  vss-description as character no-undo init "Триггер на yдаление финансового обязательства ".
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
      p-vss-parameters = substitute('&1|&2', ub.fin-ob.doc-code, ub.fin-ob.host-code)
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
main-block :
do transaction
on error undo main-block, return error
:
define buffer other_fin-ob        for ub.fin-ob.
define buffer other_fin-ob-before for ub.fin-ob-before.
define buffer other_fin-ob-trn    for ub.fin-ob-trn.
define buffer buf_c-fin-ob        for ub.c-fin-ob.
define variable v-trn-code as character no-undo .
define variable v-fin-ob as character no-undo .
define variable v-col-fin-ob as integer no-undo .
define variable v-type-pay-orig  as character no-undo .
define variable v-type-pay       as character no-undo .
define variable v-pay as character no-undo .
define variable v-ok as logical no-undo .
define variable v-not-flag as logical no-undo .
define variable v-galki as logical no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
find first contract no-lock where  contract.contract-code = fin-ob.contract-code no-error .
v-ok = true .
v-not-flag = true .
if available contract then do:
    if lookup ( contract.usl-opl , 'По факту поставки,Отсрочка платежа (по поставке)' ) > 0
      then
        assign
          v-type-pay-orig = "по поставке"
          v-pay = 'По факту поставки,Отсрочка платежа (по поставке)'
        .
      else
        assign
            v-type-pay-orig = "по реализации"
            v-pay = 'По факту реализации,По реализации части приход. накладной,Отсрочка платежа (по реализации)'
        .
end.
for each fin-ob-trn no-lock where fin-ob-trn.doc-code  = fin-ob.doc-code
    on error undo, return error :
    v-trn-code = fin-ob-trn.trn-doc-code.
    v-fin-ob =  "" .
    v-col-fin-ob =  0 .
    if v-trn-code <> "" then do:
        for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code  = v-trn-code and
                                                other_fin-ob-trn.doc-code      <> fin-ob.doc-code ,
            first other_fin-ob no-lock where other_fin-ob.doc-code  = other_fin-ob-trn.doc-code ,
              first contract   no-lock where contract.contract-code = other_fin-ob.contract-code and
                                             lookup( contract.usl-opl , v-pay ) > 0
            on error undo, return error :
            v-fin-ob = v-fin-ob + " ФО " + string(other_fin-ob-trn.doc-code) + "," .
            v-col-fin-ob = v-col-fin-ob + 1.
        end.
    end.
    if v-pay = 'По факту реализации,По реализации части приход. накладной,Отсрочка платежа (по реализации)' then do:
        if v-trn-code <> "" then do:
        for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code  = v-trn-code and
                                                other_fin-ob-trn.doc-code      <> fin-ob.doc-code ,
            first other_fin-ob-before no-lock where other_fin-ob-before.before-code  = other_fin-ob-trn.doc-code ,
              first contract   no-lock where contract.contract-code = other_fin-ob-before.contract-code and
                                             lookup( contract.usl-opl , v-pay ) > 0
            on error undo, return error :
            v-fin-ob = v-fin-ob + "  ПФО " + string(other_fin-ob-trn.doc-code).
            v-col-fin-ob = v-col-fin-ob + 1.
        end.
       end.
    end.
    if v-col-fin-ob > 0 then
    message "Финансовое обязательство было создано по накладной  " v-trn-code skip
             "Тип оплаты : " v-type-pay-orig skip
             "По этой же накладной было одновременно создано еще : " v-col-fin-ob   skip
             "Вн. номера : " v-fin-ob                                     skip
             "По накладной ФО и ПФО автоматически генерируются один раз "  skip
             "   по одному типу оплаты (поставке или реализации)       "  skip
             " "                                                          skip  skip
             "( ДА  - удалить финансовое обязательство " fin-ob.doc-code " , "  skip
             "      без возможности повторной автоматической генерации по накладной "  skip
             " НЕТ - не удалять ) "
             view-as alert-box question
             buttons yes-no
             title "Вопрос"
             update v-ok
             .
end.
v-not-flag  = v-ok.
if v-ok = false then   UNDO , RETURN ERROR.
find first fin-connect NO-LOCK
  where fin-connect.host-code = fin-ob.host-code
    and fin-connect.fin-ob-code = fin-ob.doc-code
no-error .
if available fin-connect then do:
  MESSAGE
    "Нельзя удалять связанные фин. обязательства! Сначала удалите связь с платежем."
   VIEW-AS ALERT-BOX ERROR TITLE "Удаление невозможно!" .
   UNDO , RETURN ERROR.
end.
for each fin-ob-tax  exclusive-lock  where
    fin-ob-tax.doc-code  = fin-ob.doc-code  and
    fin-ob-tax.host-code = fin-ob.host-code
    on error undo main-block, return error
    :
       delete  fin-ob-tax.
end.
for each fin-ob-trn no-lock where
    fin-ob-trn.doc-code  = fin-ob.doc-code  and
    fin-ob-trn.host-code = fin-ob.host-code
    on error undo main-block, return error
    :
    for each trn-doc  exclusive-lock   where
       trn-doc.doc-code = fin-ob-trn.trn-doc-code
        on error undo main-block, return error  :
        v-galki = true .
            for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code =  fin-ob-trn.trn-doc-code and
                                                    other_fin-ob-trn.doc-code     <>  fin-ob-trn.doc-code ,
                first other_fin-ob no-lock where other_fin-ob.doc-code  = other_fin-ob-trn.doc-code ,
                  first contract   no-lock where contract.contract-code = other_fin-ob.contract-code and
                                                lookup( contract.usl-opl , v-pay ) > 0
                  on error undo, return error :
                  v-galki = false .
            end.
            for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code =  fin-ob-trn.trn-doc-code and
                                                    other_fin-ob-trn.doc-code     <>  fin-ob-trn.doc-code ,
                first other_fin-ob-before no-lock where other_fin-ob-before.before-code  = other_fin-ob-trn.doc-code ,
                  first contract   no-lock where contract.contract-code = other_fin-ob-before.contract-code and
                                                lookup( contract.usl-opl , v-pay ) > 0
                  on error undo, return error :
                  v-galki = false .
            end.
              if v-galki = true  then do:
                  if v-pay = 'По факту реализации,По реализации части приход. накладной,Отсрочка платежа (по реализации)' then do:
                      assign
                          trn-doc.cr-expfo    = false
                          trn-doc.expfo-date  = 01/01/1990
                      no-error .
                  end.
                  else do:
                      assign
                          trn-doc.cr-incfo    = false
                          trn-doc.incfo-date  = 01/01/1990
                      no-error .
                  end.
                  if trn-doc.cr-expfo = false and
                     trn-doc.cr-incfo = false then do:
                    assign
                      trn-doc.cr-incorexpfo = false.
                  end.
                    if error-status :error then
                    message vss-workfile vss-revision vss-description skip
                        "Ошибка корректировки накладной" skip
                        error-status :get-message(1)
                        view-as alert-box information .
              end.
    end.
    for each c-trn-doc  exclusive-lock   where
       c-trn-doc.doc-code = fin-ob-trn.trn-doc-code
        on error undo main-block, return error  :
        v-galki = true .
            for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code =  fin-ob-trn.trn-doc-code and
                                                    other_fin-ob-trn.doc-code     <>  fin-ob-trn.doc-code ,
                first other_fin-ob no-lock where other_fin-ob.doc-code  = other_fin-ob-trn.doc-code ,
                  first contract   no-lock where contract.contract-code = other_fin-ob.contract-code and
                                                lookup( contract.usl-opl , v-pay ) > 0
                  on error undo, return error :
                  v-galki = false .
            end.
            for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code =  fin-ob-trn.trn-doc-code and
                                                    other_fin-ob-trn.doc-code     <>  fin-ob-trn.doc-code ,
                first other_fin-ob-before no-lock where other_fin-ob-before.before-code  = other_fin-ob-trn.doc-code ,
                  first contract   no-lock where contract.contract-code = other_fin-ob-before.contract-code and
                                                lookup( contract.usl-opl , v-pay ) > 0
                  on error undo, return error :
                  v-galki = false .
            end.
              if v-galki = true  then do:
                  if v-pay = 'По факту реализации,По реализации части приход. накладной,Отсрочка платежа (по реализации)' then do:
                      assign
                          c-trn-doc.cr-expfo    = false
                          c-trn-doc.expfo-date  = 01/01/1990
                      no-error .
                  end.
                  else do:
                      assign
                          c-trn-doc.cr-incfo    = false
                          c-trn-doc.incfo-date  = 01/01/1990
                      no-error .
                  end.
                  if c-trn-doc.cr-expfo = false and
                     c-trn-doc.cr-incfo = false then do:
                    assign
                      c-trn-doc.cr-incorexpfo = false.
                  end.
                    if error-status :error then
                    message vss-workfile vss-revision vss-description skip
                        "Ошибка корректировки накладной" skip
                        error-status :get-message(1)
                        view-as alert-box information .
              end.
    end.
end.
for each fin-ob-trn  exclusive-lock  where
    fin-ob-trn.doc-code  = fin-ob.doc-code  and
    fin-ob-trn.host-code = fin-ob.host-code
    on error undo main-block, return error
    :
       delete  fin-ob-trn.
end.
for each fin-gds-part  exclusive-lock  where
    fin-gds-part.fin-ob-code  = fin-ob.doc-code  and
    fin-gds-part.host-code = fin-ob.host-code
    on error undo main-block, return error
    :
       delete  fin-gds-part.
end.
for each fin-ob-before  exclusive-lock  where
    fin-ob-before.doc-code  = fin-ob.doc-code  and
    fin-ob-before.host-code = fin-ob.host-code
    on error undo main-block, return error
    :
       assign
         fin-ob-before.status_= 'новый':U
         fin-ob-before.doc-code = ""       .
end.
    if fin-ob.status_ = 'факт':U then
      run str/calc-bal.p (input "finob", input no, input fin-ob.doc-type, input fin-ob.host-code, input fin-ob.contract-code, input fin-ob.sum-contract, input fin-ob.sum-rubl, input fin-ob.sum-base) .
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fin-ob.
    buffer-copy fin-ob to buf_c-fin-ob
    assign
    buf_c-fin-ob.chip-num           = next-value (s-corr-chip, ub)
    buf_c-fin-ob.corr-time          = v-time
    buf_c-fin-ob.corr-user-db-num   = g#db-num
    buf_c-fin-ob.corr-user-name     = g#userid
    buf_c-fin-ob.corr-date          = v-date
    buf_c-fin-ob.is-doc-del         = true
    .
    if fin-ob.status_ = 'факт':U then  buf_c-fin-ob.is-del  = true .
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'delete':U
        , input 'fin-ob':U
        , input ( buffer ub.fin-ob:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                            , chr(10)
                            , vss-workfile
                            , return-value
                            , error-status :get-message ( 1 ) ).
    end.
    end.
end.
