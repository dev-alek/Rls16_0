block-level on error undo, throw.
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-rec as recid no-undo .
define input  parameter p-ask as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: ordpocls.p $":u .
define variable vss-archive     as character no-undo init "$Archive: cus/ordpocls.p $":u .
define variable vss-description as character no-undo init  "Переход по графу статусов заказы покупателей" .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable g#report-num as integer   no-undo .
run get-report-num in parParentProc ( output g#report-num ).
define  buffer buf_ord-doc    for ub.ord-doc.
define  buffer t-doc-rcv      for ub.ord-doc-rcv .
define  buffer t-ord-doc-rcv  for ub.ord-doc-rcv.
define  buffer t-doc-line     for ub.ord-line.
define  buffer t-doc-line-rcv for ub.ord-line-rcv.
define  buffer t-trn-line     for ub.doc-line.
define  buffer t-trn-doc      for ub.trn-doc.
define  buffer buf_contract for ub.contract  .
define temp-table temp-obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
.
define variable v-num-chip as character no-undo .
define variable  sum-ord like ub.ord-line.qnty no-undo .
define variable  sum-rcv like ub.ord-line.qnty no-undo .
define variable  sum-trn like ub.ord-line.qnty no-undo .
define variable old-state like ub.ord-doc.status_ no-undo .
define variable old-flag like ub.ord-doc.flag_ no-undo .
define stream  errStream  .
define variable v-log as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output to-day
  )  .
 find first buf_ord-doc where recid (buf_ord-doc) = p-rec exclusive-lock no-error.
 assign
  old-state = buf_ord-doc.status_
  old-flag  = buf_ord-doc.flag_
  .
  if buf_ord-doc.ship-date = ? then do:
      if p-ask then
      Message "Не задана дата заказа ! "
      skip
      "Документ" buf_ord-doc.doc-code skip
      view-as alert-box error .
      return.
  end.
  if buf_ord-doc.transport-contract  <> 0 and buf_ord-doc.transport-contract  <> ? then do:
    find first buf_contract no-lock where
                buf_contract.host-code     =  buf_ord-doc.transport-host-code and
                buf_contract.contract-code =  buf_ord-doc.transport-contract no-error .
    if not available buf_contract then do:
        message
          "Не верно задан договор грузоперевозчика" skip
          "Грузоперевозчик: " buf_ord-doc.transport-host-code      skip
          "Договор:         " buf_ord-doc.transport-contract  skip
          view-as alert-box error
        .
        return error  .
        end.
  end.
  define variable t-date  as date      no-undo .
  define variable t-time  as integer   no-undo .
  run cur-time in this-procedure ( output  t-date , output  t-time ).
  if can-find
    ( first t-doc-line no-lock where
            t-doc-line.doc-code = buf_ord-doc.doc-code and
          ( t-doc-line.qnty  =  0 or t-doc-line.qnty  = ?)) then do:
      if p-ask then
      Message "В заказе есть строки с количеством равным 0 или ? ! "
      skip
      "Документ" buf_ord-doc.doc-code skip
      view-as alert-box error .
      return.
  end.
 case buf_ord-doc.status_ :
      when 'отказ':U then do :
        if p-ask then
        Message
          "Нельзя закрыть заказ"
          "в статусе " caps(buf_ord-doc.status_) skip
          "Документ" buf_ord-doc.doc-code view-as alert-box information.
        return.
      end.
      when 'новый':U then do :
        if buf_ord-doc.flag_ = false  then do:
              if buf_ord-doc.ship-date < t-date then do:
                  if p-ask then
                  Message "Дата заказа меньше текущей даты ! " skip
                  string(buf_ord-doc.ship-date, "99/99/9999" ) skip
                  "Сегодня" string(t-date, "99/99/9999" )
                  skip
                  "Документ" buf_ord-doc.doc-code skip
                  view-as alert-box error .
                  return.
              end.
              find first  t-doc-line where t-doc-line.doc-code  = buf_ord-doc.doc-code no-lock no-error .
              if not available t-doc-line then do:
                  if p-ask then
                  message   "Заказ"  buf_ord-doc.doc-code  "  не содержит ни одной записи ! "
                  view-as alert-box information
                  title "Внимание!!! "
                .
                  return.
               end.
              find first  t-doc-line where
                    t-doc-line.doc-code  = buf_ord-doc.doc-code and
                  ( t-doc-line.price-rubl  <= 0 or
                    t-doc-line.price-rubl   = ? )
                    no-lock no-error .
              if available t-doc-line then do:
                  if p-ask then
                  message   " Заказ"  buf_ord-doc.doc-code  "   содержит товары с неопределенной ценой (руб)! "
                            view-as alert-box information
                            title "Закрыть заказ "   .
                  return.
              end.
          define variable v_ok as logical no-undo .
          define buffer buf_clients for ub.clients .
          find first buf_clients no-lock where
                     buf_clients.obj-code = buf_ord-doc.obj-code and
                     buf_clients.obj-type = buf_ord-doc.obj-type no-error .
          if not available buf_clients then do:
                  if p-ask then
                  message   " Не правильно задан объект"  skip
                              buf_ord-doc.obj-code skip
                              buf_ord-doc.obj-type
                              view-as alert-box information
                              title "Закрыть заказ "   .
                  return.
          end.
          define buffer buf1_clients for ub.clients .
          find first buf1_clients no-lock where
                     buf1_clients.obj-code = buf_ord-doc.cli-code and
                     buf1_clients.obj-type = buf_ord-doc.cli-type no-error .
          if not available buf1_clients then do:
                  if p-ask then
                  message   " Не правильно задан контрагент"  skip
                              buf_ord-doc.cli-code skip
                              buf_ord-doc.cli-type
                              view-as alert-box information
                              title "Закрыть заказ "   .
                  return.
          end.
          assign
              buf_ord-doc.status_ = 'новый':U
              buf_ord-doc.flag_ = true
              .
              return.
        end.
            if buf_ord-doc.flag_ = true  then do:
              run cus/ord-espo.p
                  ( input parParentProc ,
                    input recid (buf_ord-doc) ,
                    output v-num-chip )
                    no-error .
              if error-status :error then
              message vss-workfile vss-revision vss-description skip
                      "Ошибка ord-espo.p " skip
                      skip
                      error-status :get-message(1) skip
                      return-value skip
                      view-as alert-box error
              .
              if buf_ord-doc.contract-code <> 0 then do:
                find first buf_contract no-lock where
                           buf_contract.contract-code = buf_ord-doc.contract-code and
                           buf_contract.host-code     = buf_ord-doc.host-code no-error .
                           if error-status :error then do:
                              if p-ask then
                                        message
                                            substitute ( "Не найден договор &1 на фирме &2" ,buf_ord-doc.contract-code , buf_ord-doc.host-code ) skip
                                            "Заказ № " buf_ord-doc.doc-code skip
                                            view-as alert-box error .
                              return error .
                           end.
                  case buf_contract.usl-opl:
                    when 'Предоплата':U then do:
                         assign
                          buf_ord-doc.need-fo  = 1
                          buf_ord-doc.need-fo2 = 0
                         .
                    end.
                    when 'Предоплата(%)':U then do:
                          assign
                            buf_ord-doc.need-fo  = 1
                            buf_ord-doc.need-fo2 = 1
                          .
                    end.
                    when 'Не определено':U then do:
                          assign
                            buf_ord-doc.need-fo  = 2
                            buf_ord-doc.need-fo2 = 0
                          .
                    end.
                    otherwise do:
                          assign
                            buf_ord-doc.need-fo  = 0
                            buf_ord-doc.need-fo2 = 0
                          .
                    end.
                  end case.
              end.
              else do:
                assign
                  buf_ord-doc.need-fo  = 0
                  buf_ord-doc.need-fo2 = 0
                .
              end.
              buf_ord-doc.out-code = v-num-chip .
              return .
            end.
        end.
        when 'поставка':U
        then do :
            for each t-ord-doc-rcv exclusive-lock
               where t-ord-doc-rcv.doc-code = buf_ord-doc.doc-code
                 and t-ord-doc-rcv.status_  = 'поставка':U
                      :
              assign
                sum-rcv = 0
                sum-trn = 0
                .
              for each t-doc-line-rcv no-lock
                 where t-doc-line-rcv.doc-code  = t-ord-doc-rcv.doc-code
                  and  t-doc-line-rcv.rcv-code  = t-ord-doc-rcv.rcv-code
                        :
                for each ub.ord-chain no-lock
                   where ub.ord-chain.doc-code     = t-doc-line-rcv.rcv-code
                     and ub.ord-chain.doc-type     = 'rcv'
                     and ub.ord-chain.rel-doc-type = 'trn'
                        :
                 find first t-trn-doc no-lock
                    where t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code
                      and t-trn-doc.status_   = 'факт':U
                      and t-trn-doc.doc-type  = 'рас':U
                      and t-trn-doc.internal  = false
                        no-error.
                      if not available  t-trn-doc then next .
                        for each t-trn-line no-lock
                           where t-trn-line.doc-code  = t-trn-doc.doc-code
                             and t-trn-line.artic     = t-doc-line-rcv.artic
                             and t-trn-line.prod-type = t-doc-line-rcv.prod-type
                             and t-trn-line.prod-code = t-doc-line-rcv.prod-code
                             :
                            assign sum-trn = sum-trn + t-trn-line.fact-qnty.
                        end.
                end.
                assign sum-rcv = sum-rcv + t-doc-line-rcv.qnty.
              end.
              if sum-trn >= sum-rcv
              and sum-rcv <> 0
              then do:
                assign
                  t-ord-doc-rcv.status_   = 'факт':U
                  t-ord-doc-rcv.fact-date = to-day
                .
              end.
            end.
            for each t-ord-doc-rcv where  t-ord-doc-rcv.doc-code     = buf_ord-doc.doc-code no-lock :
              for each ub.ord-chain no-lock where
                        ub.ord-chain.doc-code = t-ord-doc-rcv.rcv-code and
                        ub.ord-chain.doc-type = 'rcv'                  and
                        ub.ord-chain.rel-doc-type = 'trn'
                        :
                for each t-trn-doc no-lock where
                          t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code and
                          t-trn-doc.doc-type  = 'рас':U and
                          t-trn-doc.status_  <> 'факт':U  :
                  if p-ask then
                  message "Документ РН" t-trn-doc.doc-code " имеет статус " CAPS(t-trn-doc.status_)
                          "Закройте РН до статуса ФАКТ " view-as alert-box error
                          title "Закрыть заказ "
                          .
                  return.
                 end.
                 end.
            end.
              if buf_ord-doc.contract-code <> 0 then do:
                find first buf_contract no-lock where
                           buf_contract.contract-code = buf_ord-doc.contract-code and
                           buf_contract.host-code     = buf_ord-doc.host-code no-error .
                           if error-status :error then do:
                              if p-ask then
                                          message
                                            substitute ( "Не найден договор Вн№ &1 на фирме &2  Заказ№ &3 " ,buf_ord-doc.contract-code , buf_ord-doc.host-code , buf_ord-doc.doc-code )
                                            view-as alert-box error .
                              return error substitute ( "Не найден договор Вн№ &1 на фирме &2  Заказ№ &3 " ,buf_ord-doc.contract-code , buf_ord-doc.host-code , buf_ord-doc.doc-code ).
                           end.
                  case buf_contract.usl-opl:
                    when 'Предоплата':U or
                    when 'Предоплата(%)':U
                    then do:
                         if buf_ord-doc.need-fo =  1 and  buf_ord-doc.cr-fo = false then do:
                            if p-ask then
                            message substitute ("Не создано Финансовое Обязательство по договору  Вн№  &1 условие &2 ",buf_ord-doc.contract-code,caps(buf_contract.usl-opl))
                                    view-as alert-box error .
                            return error 'error,':U + substitute ("Не создано Финансовое обязательство по договору  Вн№  &1 условие &2 ",buf_ord-doc.contract-code,caps(buf_contract.usl-opl)) .
                         end.
                         if buf_ord-doc.need-fo2 <> 1 and buf_contract.usl-opl  = 'Предоплата(%)':U then buf_ord-doc.need-fo2 = 1 .
                    end.
                  end case.
              end.
         assign
           sum-ord = 0
           sum-rcv = 0
           sum-trn = 0
          .
           for each t-doc-line     where t-doc-line.doc-code     = buf_ord-doc.doc-code  no-lock :
               for each  t-doc-line-rcv where t-doc-line-rcv.doc-code = t-doc-line.doc-code and
                                         t-doc-line-rcv.artic      = t-doc-line.artic         and
                                         t-doc-line-rcv.prod-type  = t-doc-line.prod-type   and
                                         t-doc-line-rcv.prod-code  = t-doc-line.prod-code no-lock ,
                 first t-doc-rcv where t-doc-line-rcv.doc-code = t-doc-rcv.doc-code  and
                                       t-doc-line-rcv.rcv-code = t-doc-rcv.rcv-code  no-lock :
              for each ub.ord-chain no-lock where
                        ub.ord-chain.doc-code = t-doc-rcv.rcv-code and
                        ub.ord-chain.doc-type = 'rcv'                  and
                        ub.ord-chain.rel-doc-type = 'trn'
                        :
                 find first t-trn-doc no-lock where
                            t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code and
                            t-trn-doc.obj-type  = t-doc-rcv.obj-type and
                            t-trn-doc.obj-code  = t-doc-rcv.obj-code and
                            t-trn-doc.status_   = 'факт':U   and
                            t-trn-doc.doc-type  = 'рас':U  and
                            t-trn-doc.internal  = false
                            no-error .
                   if not available  t-trn-doc then next .
                        for each  t-trn-line where
                                  t-trn-line.doc-code  = t-trn-doc.doc-code          and
                                  t-trn-line.obj-code  = buf_ord-doc.obj-code        and
                                  t-trn-line.obj-type  = buf_ord-doc.obj-type        and
                                  t-trn-line.artic     = t-doc-line-rcv.artic        and
                                  t-trn-line.prod-type = t-doc-line-rcv.prod-type    and
                                  t-trn-line.prod-code = t-doc-line-rcv.prod-code    no-lock :
                            sum-trn = sum-trn + t-trn-line.fact-qnty.
                        end.
                   end.
                  sum-rcv = sum-rcv + t-doc-line-rcv.qnty.
                end.
                sum-ord = sum-ord + t-doc-line.qnty.
           end.
            if  sum-trn = 0  then do:
                  v-log = false .
                  if p-ask then
                    message "Заказ " buf_ord-doc.doc-code " не имеет внешней РН !" skip
                    "Закрыть в статус (ФАКТ-) ? " skip
                      view-as alert-box question
                      buttons yes-no
                      title "Закрыть заказ"
                      update v-log
                    .
                if not v-log then return.
                buf_ord-doc.flag_ = false .
            end.
            if  sum-ord > sum-trn then do:
                  v-log = false .
                  if p-ask then
                message  "Заказ "  buf_ord-doc.doc-code " не покрыт внешней РН полностью !" skip
                  "Закрыть в статус (ФАКТ-) ? " skip
                  "Сумма заказа               " sum-ord skip
                  "Сумма накл. перемещения    " sum-trn
                  view-as alert-box question
                  buttons yes-no
                  title "Закрыть заказ"
                  update v-log
                .
                if not v-log then return.
                buf_ord-doc.flag_ = false .
            end.
            if  sum-ord =  sum-trn then do:
                buf_ord-doc.flag_ = true  .
            end.
            if  sum-ord <  sum-trn then do:
                  v-log = false .
                  if p-ask then
                message "На  Заказ"  buf_ord-doc.doc-code " превышено количество по РН !" skip
                  "Закрыть в статус (ФАКТ+) ? " skip
                  sum-ord skip
                  sum-trn
                  view-as alert-box question
                  buttons yes-no
                  title "Закрыть заказ"
                  update v-log
                .
                if not v-log then return.
                buf_ord-doc.flag_ = true  .
            end.
            assign
              buf_ord-doc.status_ = 'факт':U
              buf_ord-doc.fact-date = to-day
              .
            for each t-ord-doc-rcv   exclusive-lock
               where t-ord-doc-rcv.doc-code = buf_ord-doc.doc-code
                 and t-ord-doc-rcv.status_  <> 'факт':U
               :
              for each ub.ord-chain no-lock where
                        ub.ord-chain.doc-code = t-ord-doc-rcv.rcv-code and
                        ub.ord-chain.doc-type = 'rcv'                  and
                        ub.ord-chain.rel-doc-type = 'trn'
                        :
                 for each t-trn-doc no-lock where
                          t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code and
                          t-trn-doc.doc-type  = 'рас':U and
                          t-trn-doc.status_   = 'факт':U  :
                        assign
                          t-ord-doc-rcv.status_   = 'факт':U
                          t-ord-doc-rcv.fact-date = to-day
                          .
                 end.
                 end.
            end.
      end.
 end case.
