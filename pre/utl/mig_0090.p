block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mig_0090.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mig_0090.p $":U .
define variable vss-description as character no-undo init "Модификация тфблиц раздела Диапазоны".
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
define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character no-undo .
define input parameter p-db-num         as integer   no-undo .
define input parameter p-cli-code       as integer   no-undo .
define input parameter log-file-name   as character  no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define stream getmc-stream .
procedure get-max-code :
  define input  parameter p-action         as   character                 no-undo .
  define input  parameter p-db-num         like ub.db.db-num             no-undo .
  define input  parameter p-curr-type-cdrg like ub.code-range.range-type no-undo .
  define input  parameter p-first-code     like ub.code-range.first-code no-undo .
  define input  parameter p-last-code      like ub.code-range.last-code  no-undo .
  define input  parameter p-view-mess      as   logical                   no-undo .
  define output parameter v-b-code         as   integer                   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-main-bcode     like ub.bar-code.b-code no-undo .
    define variable l-prod-bc-global as   logical             no-undo .
    define variable l-prod-bc-weight as   logical             no-undo .
    define variable l-prod-bc-pgweight as   logical             no-undo .
    define variable rec-cnt          as   integer             no-undo .
    define variable str-u-f          as   character           no-undo .
    define variable str-u-f-rng      as   character           no-undo .
    define variable ind              as   integer             no-undo .
    define variable v-msg              as   character           no-undo initial "":U.
    define variable v-ret-msg          as   character           no-undo initial "":U.
    define frame get-max-code-inf
      rec-cnt label "Просмотрено"
      with view-as dialog-box side-labels row 11 centered
      title "..........................................." three-d
    .
    define buffer buf_code-range   for ub.code-range .
    define buffer buf-c_code-range for ub.code-range .
    define buffer buf_bar-code     for ub.bar-code .
    define buffer buf_place        for ub.place .
    define buffer buf_goods        for ub.goods .
    define buffer buf_units        for ub.units .
    define buffer buf_prod-bc      for ub.prod-bc .
    define buffer buf_dis-card     for ub.dis-card .
    define buffer buf_dis-rule     for ub.dis-rule .
    define buffer buf_dis-time-rule     for ub.dis-time-rule .
    define buffer buf_firm         for ub.firm .
    define buffer buf_person       for ub.person .
    define buffer buf_contract     for ub.contract .
    if p-curr-type-cdrg = 'sslc':U
    or p-curr-type-cdrg = 'ssgb':U
    then do:
      assign
        v-b-code = ?
      .
      return.
    end.
    if p-curr-type-cdrg = 'sclc':U
    or p-curr-type-cdrg = 'pglc':U
      or p-curr-type-cdrg = 'sslc':U
    then do:
      assign
        p-db-num = 0
      .
    end.
    case p-action :
      when "get-m-code":U then do:
        assign
          v-b-code = p-first-code
        .
      end.
      when "f-u":U then do:
        assign
          v-b-code = 0
        .
      end.
    end case.
    case p-curr-type-cdrg :
      when 'dcgb':U then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii2 as integer   no-undo .
define variable v-table-name2 as character no-undo .
define variable v-field-name2 as character no-undo .
define variable buf_h2 as handle no-undo .
define variable q_h2 as handle no-undo .
define variable v-avail2 as integer   no-undo .
define variable v-code-mess2 as character no-undo .
define variable glog2 as logical   no-undo .
define variable v-code_2 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii2 = 1 to num-entries('ub.dis-card'):
      assign
      v-table-name2 = entry(v-ii2, 'ub.dis-card')
      v-field-name2 = entry(v-ii2, 'card-num')
      .
      create buffer buf_h2 for table v-table-name2.
      create query q_h2.
      q_h2:SET-BUFFERS(buf_h2).
      q_h2:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name2
                        ,v-field-name2
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h2:QUERY-OPEN.
      REPEAT while  q_h2:get-next().
        assign
          v-code_2 = buf_h2:buffer-field(v-field-name2):buffer-value
        .
        leave .
      END.
      q_h2:QUERY-CLOSE().
      delete object q_h2.
      delete object buf_h2.
      v-b-code = max(v-code_2, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail2 = 0.
      do v-ii2 = 1 to num-entries('ub.dis-card'):
        assign
        v-table-name2 = entry(v-ii2, 'ub.dis-card')
        v-field-name2 = entry(v-ii2, 'card-num')
        .
        create buffer buf_h2 for table v-table-name2.
        glog2 = buf_h2:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name2
                                , v-field-name2
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h2:available then do:
          assign
          v-avail2 = v-avail2 + 1
          .
          if v-avail2 = 1 then do:
            v-code-mess2 = string(buf_h2:buffer-field(v-field-name2):buffer-value)
            .
          end.
        end.
        delete object buf_h2.
     end.
     if v-avail2 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess2
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail2 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'ctgb':U then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii3 as integer   no-undo .
define variable v-table-name3 as character no-undo .
define variable v-field-name3 as character no-undo .
define variable buf_h3 as handle no-undo .
define variable q_h3 as handle no-undo .
define variable v-avail3 as integer   no-undo .
define variable v-code-mess3 as character no-undo .
define variable glog3 as logical   no-undo .
define variable v-code_3 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii3 = 1 to num-entries('ub.contract'):
      assign
      v-table-name3 = entry(v-ii3, 'ub.contract')
      v-field-name3 = entry(v-ii3, 'contract-code')
      .
      create buffer buf_h3 for table v-table-name3.
      create query q_h3.
      q_h3:SET-BUFFERS(buf_h3).
      q_h3:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name3
                        ,v-field-name3
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h3:QUERY-OPEN.
      REPEAT while  q_h3:get-next().
        assign
          v-code_3 = buf_h3:buffer-field(v-field-name3):buffer-value
        .
        leave .
      END.
      q_h3:QUERY-CLOSE().
      delete object q_h3.
      delete object buf_h3.
      v-b-code = max(v-code_3, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail3 = 0.
      do v-ii3 = 1 to num-entries('ub.contract'):
        assign
        v-table-name3 = entry(v-ii3, 'ub.contract')
        v-field-name3 = entry(v-ii3, 'contract-code')
        .
        create buffer buf_h3 for table v-table-name3.
        glog3 = buf_h3:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name3
                                , v-field-name3
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h3:available then do:
          assign
          v-avail3 = v-avail3 + 1
          .
          if v-avail3 = 1 then do:
            v-code-mess3 = string(buf_h3:buffer-field(v-field-name3):buffer-value)
            .
          end.
        end.
        delete object buf_h3.
     end.
     if v-avail3 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess3
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail3 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'cagb':U then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii4 as integer   no-undo .
define variable v-table-name4 as character no-undo .
define variable v-field-name4 as character no-undo .
define variable buf_h4 as handle no-undo .
define variable q_h4 as handle no-undo .
define variable v-avail4 as integer   no-undo .
define variable v-code-mess4 as character no-undo .
define variable glog4 as logical   no-undo .
define variable v-code_4 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii4 = 1 to num-entries('ub.rule-by-call'):
      assign
      v-table-name4 = entry(v-ii4, 'ub.rule-by-call')
      v-field-name4 = entry(v-ii4, 'call#_id')
      .
      create buffer buf_h4 for table v-table-name4.
      create query q_h4.
      q_h4:SET-BUFFERS(buf_h4).
      q_h4:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name4
                        ,v-field-name4
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h4:QUERY-OPEN.
      REPEAT while  q_h4:get-next().
        assign
          v-code_4 = buf_h4:buffer-field(v-field-name4):buffer-value
        .
        leave .
      END.
      q_h4:QUERY-CLOSE().
      delete object q_h4.
      delete object buf_h4.
      v-b-code = max(v-code_4, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail4 = 0.
      do v-ii4 = 1 to num-entries('ub.rule-by-call'):
        assign
        v-table-name4 = entry(v-ii4, 'ub.rule-by-call')
        v-field-name4 = entry(v-ii4, 'call#_id')
        .
        create buffer buf_h4 for table v-table-name4.
        glog4 = buf_h4:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name4
                                , v-field-name4
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h4:available then do:
          assign
          v-avail4 = v-avail4 + 1
          .
          if v-avail4 = 1 then do:
            v-code-mess4 = string(buf_h4:buffer-field(v-field-name4):buffer-value)
            .
          end.
        end.
        delete object buf_h4.
     end.
     if v-avail4 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess4
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail4 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'fdgb':U then do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii5 as integer   no-undo .
define variable v-table-name5 as character no-undo .
define variable v-field-name5 as character no-undo .
define variable buf_h5 as handle no-undo .
define variable q_h5 as handle no-undo .
define variable v-avail5 as integer   no-undo .
define variable v-code-mess5 as character no-undo .
define variable glog5 as logical   no-undo .
define variable v-code_5 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii5 = 1 to num-entries('ub.fin-doc'):
      assign
      v-table-name5 = entry(v-ii5, 'ub.fin-doc')
      v-field-name5 = entry(v-ii5, 'fin-doc-code')
      .
      create buffer buf_h5 for table v-table-name5.
      create query q_h5.
      q_h5:SET-BUFFERS(buf_h5).
      q_h5:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name5
                        ,v-field-name5
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h5:QUERY-OPEN.
      REPEAT while  q_h5:get-next().
        assign
          v-code_5 = buf_h5:buffer-field(v-field-name5):buffer-value
        .
        leave .
      END.
      q_h5:QUERY-CLOSE().
      delete object q_h5.
      delete object buf_h5.
      v-b-code = max(v-code_5, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail5 = 0.
      do v-ii5 = 1 to num-entries('ub.fin-doc'):
        assign
        v-table-name5 = entry(v-ii5, 'ub.fin-doc')
        v-field-name5 = entry(v-ii5, 'fin-doc-code')
        .
        create buffer buf_h5 for table v-table-name5.
        glog5 = buf_h5:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name5
                                , v-field-name5
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h5:available then do:
          assign
          v-avail5 = v-avail5 + 1
          .
          if v-avail5 = 1 then do:
            v-code-mess5 = string(buf_h5:buffer-field(v-field-name5):buffer-value)
            .
          end.
        end.
        delete object buf_h5.
     end.
     if v-avail5 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess5
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail5 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'fmgb':U then do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii6 as integer   no-undo .
define variable v-table-name6 as character no-undo .
define variable v-field-name6 as character no-undo .
define variable buf_h6 as handle no-undo .
define variable q_h6 as handle no-undo .
define variable v-avail6 as integer   no-undo .
define variable v-code-mess6 as character no-undo .
define variable glog6 as logical   no-undo .
define variable v-code_6 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii6 = 1 to num-entries('ub.firm'):
      assign
      v-table-name6 = entry(v-ii6, 'ub.firm')
      v-field-name6 = entry(v-ii6, 'firm-code')
      .
      create buffer buf_h6 for table v-table-name6.
      create query q_h6.
      q_h6:SET-BUFFERS(buf_h6).
      q_h6:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name6
                        ,v-field-name6
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h6:QUERY-OPEN.
      REPEAT while  q_h6:get-next().
        assign
          v-code_6 = buf_h6:buffer-field(v-field-name6):buffer-value
        .
        leave .
      END.
      q_h6:QUERY-CLOSE().
      delete object q_h6.
      delete object buf_h6.
      v-b-code = max(v-code_6, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail6 = 0.
      do v-ii6 = 1 to num-entries('ub.firm'):
        assign
        v-table-name6 = entry(v-ii6, 'ub.firm')
        v-field-name6 = entry(v-ii6, 'firm-code')
        .
        create buffer buf_h6 for table v-table-name6.
        glog6 = buf_h6:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name6
                                , v-field-name6
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h6:available then do:
          assign
          v-avail6 = v-avail6 + 1
          .
          if v-avail6 = 1 then do:
            v-code-mess6 = string(buf_h6:buffer-field(v-field-name6):buffer-value)
            .
          end.
        end.
        delete object buf_h6.
     end.
     if v-avail6 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess6
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail6 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'pngb':U then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii7 as integer   no-undo .
define variable v-table-name7 as character no-undo .
define variable v-field-name7 as character no-undo .
define variable buf_h7 as handle no-undo .
define variable q_h7 as handle no-undo .
define variable v-avail7 as integer   no-undo .
define variable v-code-mess7 as character no-undo .
define variable glog7 as logical   no-undo .
define variable v-code_7 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii7 = 1 to num-entries('ub.person'):
      assign
      v-table-name7 = entry(v-ii7, 'ub.person')
      v-field-name7 = entry(v-ii7, 'psn-code')
      .
      create buffer buf_h7 for table v-table-name7.
      create query q_h7.
      q_h7:SET-BUFFERS(buf_h7).
      q_h7:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name7
                        ,v-field-name7
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h7:QUERY-OPEN.
      REPEAT while  q_h7:get-next().
        assign
          v-code_7 = buf_h7:buffer-field(v-field-name7):buffer-value
        .
        leave .
      END.
      q_h7:QUERY-CLOSE().
      delete object q_h7.
      delete object buf_h7.
      v-b-code = max(v-code_7, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail7 = 0.
      do v-ii7 = 1 to num-entries('ub.person'):
        assign
        v-table-name7 = entry(v-ii7, 'ub.person')
        v-field-name7 = entry(v-ii7, 'psn-code')
        .
        create buffer buf_h7 for table v-table-name7.
        glog7 = buf_h7:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name7
                                , v-field-name7
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h7:available then do:
          assign
          v-avail7 = v-avail7 + 1
          .
          if v-avail7 = 1 then do:
            v-code-mess7 = string(buf_h7:buffer-field(v-field-name7):buffer-value)
            .
          end.
        end.
        delete object buf_h7.
     end.
     if v-avail7 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess7
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail7 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'drgb':U then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii8 as integer   no-undo .
define variable v-table-name8 as character no-undo .
define variable v-field-name8 as character no-undo .
define variable buf_h8 as handle no-undo .
define variable q_h8 as handle no-undo .
define variable v-avail8 as integer   no-undo .
define variable v-code-mess8 as character no-undo .
define variable glog8 as logical   no-undo .
define variable v-code_8 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii8 = 1 to num-entries('ub.dis-rule,ub.dis-time-rule'):
      assign
      v-table-name8 = entry(v-ii8, 'ub.dis-rule,ub.dis-time-rule')
      v-field-name8 = entry(v-ii8, 'rule-num,time-rule-num')
      .
      create buffer buf_h8 for table v-table-name8.
      create query q_h8.
      q_h8:SET-BUFFERS(buf_h8).
      q_h8:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name8
                        ,v-field-name8
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h8:QUERY-OPEN.
      REPEAT while  q_h8:get-next().
        assign
          v-code_8 = buf_h8:buffer-field(v-field-name8):buffer-value
        .
        leave .
      END.
      q_h8:QUERY-CLOSE().
      delete object q_h8.
      delete object buf_h8.
      v-b-code = max(v-code_8, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail8 = 0.
      do v-ii8 = 1 to num-entries('ub.dis-rule,ub.dis-time-rule'):
        assign
        v-table-name8 = entry(v-ii8, 'ub.dis-rule,ub.dis-time-rule')
        v-field-name8 = entry(v-ii8, 'rule-num,time-rule-num')
        .
        create buffer buf_h8 for table v-table-name8.
        glog8 = buf_h8:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name8
                                , v-field-name8
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h8:available then do:
          assign
          v-avail8 = v-avail8 + 1
          .
          if v-avail8 = 1 then do:
            v-code-mess8 = string(buf_h8:buffer-field(v-field-name8):buffer-value)
            .
          end.
        end.
        delete object buf_h8.
     end.
     if v-avail8 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess8
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail8 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'bcgb':U then do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii9 as integer   no-undo .
define variable v-table-name9 as character no-undo .
define variable v-field-name9 as character no-undo .
define variable buf_h9 as handle no-undo .
define variable q_h9 as handle no-undo .
define variable v-avail9 as integer   no-undo .
define variable v-code-mess9 as character no-undo .
define variable glog9 as logical   no-undo .
define variable v-code_9 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii9 = 1 to num-entries('ub.bar-code,ub.place'):
      assign
      v-table-name9 = entry(v-ii9, 'ub.bar-code,ub.place')
      v-field-name9 = entry(v-ii9, 'b-code,pl-code')
      .
      create buffer buf_h9 for table v-table-name9.
      create query q_h9.
      q_h9:SET-BUFFERS(buf_h9).
      q_h9:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name9
                        ,v-field-name9
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h9:QUERY-OPEN.
      REPEAT while  q_h9:get-next().
        assign
          v-code_9 = buf_h9:buffer-field(v-field-name9):buffer-value
        .
        leave .
      END.
      q_h9:QUERY-CLOSE().
      delete object q_h9.
      delete object buf_h9.
      v-b-code = max(v-code_9, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail9 = 0.
      do v-ii9 = 1 to num-entries('ub.bar-code,ub.place'):
        assign
        v-table-name9 = entry(v-ii9, 'ub.bar-code,ub.place')
        v-field-name9 = entry(v-ii9, 'b-code,pl-code')
        .
        create buffer buf_h9 for table v-table-name9.
        glog9 = buf_h9:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name9
                                , v-field-name9
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h9:available then do:
          assign
          v-avail9 = v-avail9 + 1
          .
          if v-avail9 = 1 then do:
            v-code-mess9 = string(buf_h9:buffer-field(v-field-name9):buffer-value)
            .
          end.
        end.
        delete object buf_h9.
     end.
     if v-avail9 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess9
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail9 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'scgb':U
      or when 'sclc':U
      then do:
        case p-action :
          when "get-m-code":U then do:
            assign
              frame get-max-code-inf :title = "Поиск максимального значения кода"
            .
          end.
          when "f-u":U then do:
            assign
              frame get-max-code-inf :title = "Корректировка статуса code-range"
            .
            run mark-all-used-as-free in this-procedure (
                                       input  p-db-num
                                      ,input  p-curr-type-cdrg
                                      ,output str-u-f
                                      ,output str-u-f-rng
                                    ).
          end.
        end case.
        view frame get-max-code-inf.
        assign
          rec-cnt = 0
        .
        display
          rec-cnt
          with frame get-max-code-inf
        .
        for each buf_units no-lock
            where lookup('вес':U, buf_units.type) > 0
        on error undo, return error
        :
          for each buf_goods no-lock
            where buf_goods.unit-base = buf_units.unit-name
          on error undo, return error
          :
            assign
              rec-cnt = rec-cnt + 1
            .
            if ( rec-cnt modulo 10 ) = 0 then do:
              display
                rec-cnt
                with frame get-max-code-inf
              .
            end.
            run mc_gdsbcode in this-procedure (
                             input  buf_goods.gds-code
                            ,input  ?
                            ,output v-main-bcode
                          ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при поиске корневого бар-кода" skip
                "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            for each buf_prod-bc no-lock
                where buf_prod-bc.b-code = v-main-bcode
            on error undo, return error
            :
              if p-curr-type-cdrg = 'sclc':U
                and buf_prod-bc.bc-on = FALSE
              then do:
                next.
              end.
              run mc_prodbcat in this-procedure (
                               buffer buf_prod-bc
                              ,input  'global=request':u
                              ,output l-prod-bc-global
                            ) no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
                  "Основной бар-код" buf_prod-bc.b-code skip
                  "Дополнительный бар-код" buf_prod-bc.b-str skip
                  "Действие global=request" skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
              run mc_prodbcat in this-procedure (
                               buffer buf_prod-bc
                              ,input  'weight=request':u
                              ,output l-prod-bc-weight
                            ) no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
                  "Основной бар-код" buf_prod-bc.b-code skip
                  "Дополнительный бар-код" buf_prod-bc.b-str skip
                  "Действие weight=request" skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
              if l-prod-bc-weight
                and ( ( l-prod-bc-global
                        and p-curr-type-cdrg = 'scgb':U
                      )
                      or
                      ( not l-prod-bc-global
                        and p-curr-type-cdrg = 'sclc':U
                      )
                    )
              then do:
                case p-action :
                  when "get-m-code":U then do:
                    if integer( buf_prod-bc.b-str ) >= p-first-code
                      and integer( buf_prod-bc.b-str ) <= p-last-code
                      and integer( buf_prod-bc.b-str ) > v-b-code
                    then do:
                      assign
                        v-b-code = integer( buf_prod-bc.b-str )
                      .
                    end.
                  end.
                  when "f-u":U then do:
                    for each buf_code-range
                      where buf_code-range.db-num     = p-db-num
                        and buf_code-range.range-type = p-curr-type-cdrg
                        and buf_code-range.stts       = "f":U
                        and buf_code-range.first-code <= integer( buf_prod-bc.b-str )
                        and buf_code-range.last-code  >= integer( buf_prod-bc.b-str )
                    on error undo, return error
                    :
                      assign
                        buf_code-range.stts = "u":U
                      .
                      if lookup( string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code ), str-u-f-rng ) <> 0 then do:
                        assign
                          str-u-f-rng = diff-list( str-u-f-rng
                                                  ,string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code )
                                                  ,",":U
                                                  )
                        .
                      end.
                      if lookup( buf_code-range.range-type + chr(3) + string( buf_code-range.first-code ), str-u-f ) = 0 then do:
                        assign
                          v-b-code = v-b-code + 1
                          v-msg     = substitute( "Диапазон кодов с &2 по &3&1"
                                                  + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                                  , chr(10)
                                                  , buf_code-range.first-code
                                                  , buf_code-range.last-code
                                                  , buf_prod-bc.b-str
                                                )
                          v-ret-msg = v-ret-msg + v-msg
                        .
                        if p-view-mess = true then do:
                          message
                            v-msg
                            view-as alert-box information.
                        end.
                      end.
                    end.
                  end.
                end case.
              end.
            end.
          end.
        end.
        if p-action = "f-u":U then do:
          do ind = 1 to num-entries( str-u-f-rng ):
            assign
              v-b-code  = v-b-code + 1
              v-msg     = substitute( "Диапазон кодов &2&1"
                                      + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                      , chr(10)
                                      , entry( ind, str-u-f-rng )
                                    )
              v-ret-msg = v-ret-msg + chr(10) + v-msg
            .
            if p-view-mess = true then do:
              message
                v-msg
                view-as alert-box information.
            end.
          end.
        end.
        hide frame get-max-code-inf no-pause .
      end.
      when 'pglc':U
      then do:
        case p-action :
          when "get-m-code":U then do:
            assign
              frame get-max-code-inf :title = "Поиск максимального значения кода"
            .
          end.
          when "f-u":U then do:
            assign
              frame get-max-code-inf :title = "Корректировка статуса code-range"
            .
            run mark-all-used-as-free in this-procedure (
                                       input  p-db-num
                                      ,input  p-curr-type-cdrg
                                      ,output str-u-f
                                      ,output str-u-f-rng
                                    ).
          end.
        end case.
        view frame get-max-code-inf.
        assign
          rec-cnt = 0
        .
        display
          rec-cnt
          with frame get-max-code-inf
        .
        for each buf_prod-bc no-lock where
                buf_prod-bc.b-str >= "00100"
            and buf_prod-bc.b-str <= "99999"
            and buf_prod-bc.bc-on-type = 'pglc':U
            and length(buf_prod-bc.b-str) = 5
        on error undo, return error
        :
            assign
              rec-cnt = rec-cnt + 1
            .
            if ( rec-cnt modulo 10 ) = 0 then do:
              display
                rec-cnt
                with frame get-max-code-inf
              .
            end.
            if p-curr-type-cdrg = 'pglc':U
              and buf_prod-bc.bc-on = FALSE
            then do:
              next.
            end.
            run mc_prodbcat in this-procedure (
                              buffer buf_prod-bc
                            ,input  'pgweight=request':u
                            ,output l-prod-bc-pgweight
                          ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
                "Основной бар-код" buf_prod-bc.b-code skip
                "Дополнительный бар-код" buf_prod-bc.b-str skip
                "Действие weight=request" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            if l-prod-bc-pgweight
            and p-curr-type-cdrg = 'pglc':U
            then do:
              case p-action :
                when "get-m-code":U then do:
                  if integer( buf_prod-bc.b-str ) >= p-first-code
                    and integer( buf_prod-bc.b-str ) <= p-last-code
                    and integer( buf_prod-bc.b-str ) > v-b-code
                  then do:
                    assign
                      v-b-code = integer( buf_prod-bc.b-str )
                    .
                  end.
                end.
                when "f-u":U then do:
                  for each buf_code-range
                    where buf_code-range.db-num     = p-db-num
                      and buf_code-range.range-type = p-curr-type-cdrg
                      and buf_code-range.stts       = "f":U
                      and buf_code-range.first-code <= integer( buf_prod-bc.b-str )
                      and buf_code-range.last-code  >= integer( buf_prod-bc.b-str )
                  on error undo, return error
                  :
                  assign
                  buf_code-range.stts = "u":U
                    .
                  if lookup( string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code ), str-u-f-rng ) <> 0 then do:
                      assign
                        str-u-f-rng = diff-list( str-u-f-rng
                                                ,string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code )
                                                ,",":U
                                                )
                      .
                  end.
                  if lookup( buf_code-range.range-type + chr(3) + string( buf_code-range.first-code ), str-u-f ) = 0 then do:
                      assign
                        v-b-code = v-b-code + 1
                        v-msg     = substitute( "Диапазон кодов с &2 по &3&1"
                                                + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                                , chr(10)
                                                , buf_code-range.first-code
                                                , buf_code-range.last-code
                                                , buf_prod-bc.b-str
                                              )
                        v-ret-msg = v-ret-msg + v-msg
                      .
                    if p-view-mess = true then do:
                      message
                        v-msg
                        view-as alert-box information.
                    end.
                  end.
                end.
              end.
            end case.
          end.
        end.
        if p-action = "f-u":U then do:
          do ind = 1 to num-entries( str-u-f-rng ):
            assign
              v-b-code = v-b-code + 1
              v-msg     = substitute( "Диапазон кодов &2&1"
                                      + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                      , chr(10)
                                      , entry( ind, str-u-f-rng )
                                    )
              v-ret-msg = v-ret-msg + chr(10) + v-msg
            .
            if p-view-mess = true then do:
              message
                v-msg
                view-as alert-box information.
            end.
          end.
        end.
        hide frame get-max-code-inf no-pause .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "get-max-code" skip
          "Непредусмотрена обработка диапазона кодов " p-curr-type-cdrg
          view-as alert-box error.
        return error.
      end.
    end case.
  end.
  return v-ret-msg.
end procedure.
procedure mark-all-used-as-free :
  define input  parameter p-db-num         like ub.db.db-num             no-undo .
  define input  parameter p-curr-type-cdrg like ub.code-range.range-type no-undo .
  define output parameter p-str-u-f        as   character                 no-undo .
  define output parameter p-str-u-f-rng    as   character                 no-undo .
  do
  on error undo, return error
  :
    define buffer buf_code-range   for ub.code-range.
    define buffer buf-c_code-range for ub.code-range .
    assign
      p-str-u-f     = "":U
      p-str-u-f-rng = "":U
    .
    for each buf_code-range share-lock
        where buf_code-range.db-num     = p-db-num
          and buf_code-range.range-type = p-curr-type-cdrg
          and buf_code-range.stts       = "u":U
    on error undo, return error
    :
      find first buf-c_code-range exclusive-lock
        where rowid( buf-c_code-range ) = rowid( buf_code-range )
      .
      assign
        buf-c_code-range.stts = "c":U
      .
      release buf-c_code-range .
      assign
        buf_code-range.stts = "f":U
        p-str-u-f     = p-str-u-f + ",":U + buf_code-range.range-type + chr(3) + string( buf_code-range.first-code )
        p-str-u-f-rng = p-str-u-f-rng + ",":U + string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code )
      .
    end.
    assign
      p-str-u-f     = substring( p-str-u-f, 2, length( p-str-u-f ) - 1 )
      p-str-u-f-rng = substring( p-str-u-f-rng, 2, length( p-str-u-f-rng ) - 1 )
    .
  end.
end procedure.
procedure mc_prodbcat :
  do
  on error undo, return error
  :
    define parameter buffer buf_prod-bc  for ub.prod-bc .
    define input  parameter p-action           as character no-undo .
    define output parameter p-return-attribute as logical no-undo .
    def var vss-description as character no-undo init "prodbcat-01: определение параметров дополнительного бар-кода".
    define buffer buf_bar-code   for ub.bar-code   .
    define buffer buf_units      for ub.units      .
    define buffer buf_code-range for ub.code-range .
    define variable p-code-int as integer no-undo .
    define variable v-cdrg-type as character no-undo .
    if not available buf_prod-bc then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задан дополнительный бар-код" skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_bar-code no-lock
      where buf_bar-code.b-code = buf_prod-bc.b-code
      no-error .
    if not available buf_bar-code then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильная ссылка на основной бар-код" skip
        "Основной бар-код" buf_prod-bc.b-code skip
        "Дополнительный бар-код" buf_prod-bc.b-str skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_units no-lock
      where buf_units.unit-name = buf_bar-code.unit-cli
      no-error .
    if not available buf_units then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена единица измерения основного бар-кода" skip
        "Основной бар-код" buf_bar-code.b-code skip
        "Единица измерения" buf_bar-code.unit-cli skip
        view-as alert-box error .
      undo, return error .
    end.
    def var ind                    as integer   no-undo .
    def var v-num-entries-p-action as integer   no-undo .
    def var v-action               as character no-undo .
    assign
      v-num-entries-p-action = num-entries(p-action)
    .
    assign
      p-return-attribute = true
    .
    _ind:
    do ind = 1 to v-num-entries-p-action
    :
     if ind > 1 and p-return-attribute = false then return.
      assign
        v-action = entry(ind, p-action)
      .
      case v-action :
        when "global=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = ''
          or buf_prod-bc.bc-on-type = 'scgb':U
          or buf_prod-bc.bc-on-type = 'ssgb':U) then do:
            assign
              p-return-attribute = false
            .
          end.
        end.
        when "weight=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = 'sclc':U
          or buf_prod-bc.bc-on-type = 'scgb':U) then do:
            assign
              p-return-attribute = false.
          end.
        end.
        when "pgweight=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = 'pglc':U) then do:
            assign
              p-return-attribute = false.
          end.
        end.
        when "petrolium=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = 'ptlc':U) then do:
            assign
              p-return-attribute = false.
          end.
        end.
        when "scaleable=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = 'sslc':U
          or buf_prod-bc.bc-on-type = 'ssgb':U) then do:
            assign
              p-return-attribute = false.
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестное значение параметра v-action " skip
            "v-action" v-action skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error .
        end.
      end case.
    end.
  end.
end procedure.
procedure mc_gdsbcode :
  define input  parameter p-gds-code  like ub.bar-code.gds-code  no-undo .
  define input  parameter p-node-code like ub.bar-code.node-code no-undo .
  define output parameter p-b-code    like ub.bar-code.b-code    no-undo .
  def var vss-description as character no-undo init "gdsbcode-01: определение первичного бар-кода признака".
  def var vss-proc-revision as character no-undo init "library.p gdsbcode-01" .
  define buffer buf_bar-code for ub.bar-code .
  def var v-unit-base like ub.goods.unit-base no-undo .
  do
  on error undo, return error
  :
    if p-node-code = ? then do:
      run mc_gdsrootnode in this-procedure (
         input  p-gds-code
        ,output p-node-code
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого признака товара" skip
          "Код товара" p-gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    run mc_unitbase in this-procedure (
       input  p-gds-code
      ,output v-unit-base
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка определения базовой единицы измерения товара" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_bar-code no-lock
      where buf_bar-code.gds-code  = p-gds-code
        and buf_bar-code.node-code = p-node-code
        and buf_bar-code.part-code = ""
        and buf_bar-code.in-code   = ""
        and buf_bar-code.unit-cli  = v-unit-base
      no-error .
    if not available buf_bar-code then do:
      undo, return error vss-proc-revision + ":" + chr(10)
        + "Не найден первичный бар-кода признака " + chr(10)
        + "Код товара " + string(p-gds-code) + chr(10)
        + "Код признака " + string(p-node-code) + chr(10)
        + "Базовая единица измерения " + string(v-unit-base) + chr(10)
        .
    end.
    assign
      p-b-code = buf_bar-code.b-code
    .
  end.
end procedure.
procedure mc_gdsrootnode :
  define input  parameter p-gds-code  like ub.goods.gds-code no-undo .
  define output parameter p-root-node like ub.goods.prt-root no-undo .
  def var vss-description as character no-undo init "gdsrootnode-01: определение корневого признака товара по коду товара".
  define buffer buf_goods   for ub.goods .
  do
  on error undo, return error
  :
    find first buf_goods no-lock
      where buf_goods.gds-code  = p-gds-code
      no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    run mc_prt-root-to-node-code in this-procedure (
       input  buf_goods.prt-root
      ,output p-root-node
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры prt-root-to-node-code" skip
        "Товар" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "Указатель на корень шкалы" buf_goods.prt-root skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure mc_prt-root-to-node-code :
  define input  parameter p-prt-root  like ub.goods.prt-root no-undo .
  define output parameter p-root-node like ub.goods.prt-root no-undo .
  def var vss-description as character no-undo init "prt-root-to-node-code-01: определение корневого признака шкалы по коду шкалы".
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error
  :
    find buf_gds-prt no-lock
      where buf_gds-prt.upper-code = p-prt-root
      no-error .
    if not available buf_gds-prt then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден корень шкалы" skip
        "Указатель на корень шкалы" p-prt-root skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-root-node = buf_gds-prt.node-code
    .
  end.
end procedure.
procedure mc_unitbase :
  define input  parameter p-gds-code  like ub.goods.gds-code  no-undo .
  define output parameter p-unit-base like ub.goods.unit-base no-undo .
  def var vss-description as character no-undo init "unitbase-01: определение базовой единицы измерения товара".
  define buffer buf_goods for ub.goods .
  do
  on error undo, return error
  :
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-unit-base = buf_goods.unit-base
    .
  end.
end procedure.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Диапазоны") ).
on write  of ub.code-range      override do: end .
on delete of ub.code-range      override do: end .
  do
  on error undo, return error return-value
  :
  for each ub.code-range exclusive-lock :
      if ub.code-range.stts = 'a':U and ub.code-range.db-num <> p-db-num  then ub.code-range.stts = 'u':U .
      if ub.code-range.db-num > 0 then ub.code-range.db-num = 0 .
  end.
define variable v-b-code as integer   no-undo .
define variable v-curr-type-cdrg as character no-undo .
define variable i as integer   no-undo .
define variable vrv as character no-undo .
  v-curr-type-cdrg =
        'ssgb':U + "," +
        'ctgb':U + "," +
        'dcgb':U + "," +
        'fmgb':U + "," +
        'pngb':U + "," +
        'drgb':U + "," +
        'bcgb':U + "," +
        'scgb':U .
  do i = 1 to num-entries(v-curr-type-cdrg) :
    run get-max-code in this-procedure
      ( input "f-u":U
        ,input 0
        ,input entry (i , v-curr-type-cdrg )
        ,input ?
        ,input ?
        ,input false
        ,output v-b-code
      ) no-error .
      vrv =  return-value .
      if vrv <> "" then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input vrv  ).
     end.
  end.
  end.
