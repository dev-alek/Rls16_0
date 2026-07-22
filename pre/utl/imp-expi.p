block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 826c1485520b, 1287, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Apr 10 12:02:59 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-expi.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/imp-expi.p $":U .
define variable vss-description as character no-undo init "Процедура экспорта локальных таблиц УБД".
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
define variable p-rht as logical no-undo .
define variable p-gen as logical no-undo .
define variable p-flt as logical no-undo .
define variable p-pbc as logical no-undo .
define variable p-scl as logical no-undo .
define variable p-usr as logical no-undo .
define variable p-seq as logical no-undo .
define variable p-db-key as character no-undo .
define variable p-dir-name as character no-undo .
define variable p-version as character no-undo .
define variable p-glb as logical no-undo .
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
function corr-file-name returns character (
 input p-file-name as character)
 .
DEFINE variable v-corr-file-name as character no-undo.
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE v-char-name-list as character no-undo .
assign
v-corr-file-name = p-file-name
.
do ii = 1 to length('\/:*?"<>|':U):
  assign
  v-corr-file-name = replace(
                                v-corr-file-name
                               , substr('\/:*?"<>|':U, ii, 1 )
                               , entry(ii, 'b-slash,slash,colon,star,question,d-quote,d-quote,less-t,great-t,pipe':U)
                           )
  .
end.
return v-corr-file-name.
end function.
define variable log-file-name as character no-undo init "imp-exp.log".
define variable v-view-log as logical no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-log-gap as logical no-undo .
define variable v-user-name    as character    no-undo.
define variable v-grp-name    as character    no-undo.
define variable v-arm-code    as character    no-undo.
Procedure check-iefile:
DEFINE INPUT PARAMETER p-dir-name as character no-undo.
DEFINE INPUT PARAMETER p-file-extension as character no-undo.
DEFINE INPUT PARAMETER p-mode as character no-undo.
define output parameter p-ok as logical no-undo.
define variable full_name as character no-undo.
find first ub.sys-ctrl No-LOCK No-ERROR.
if not avail ub.sys-ctrl then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Отсутствует информация в таблице sys-ctrl"
                          )
                                          ).
    return error.
end.
FIND FIRST ub.db No-LOCK WHERE
           ub.db.db-num = ub.sys-ctrl.db-num NO-ERROR.
if not avail ub.db then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Отсутствует информация в таблице db"
                          )
                                          ).
    return error.
end.
full_name = p-dir-name + "\":U + corr-file-name(string(ub.db.db-key)) + "." + p-file-extension.
if p-mode = "import":U then do:
    if search(full_name) = ? then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не найден файл данных &1", full_name
                            )
                                            ).
        p-ok = no.
        return.
    end.
    p-ok = yes.
    return.
end.
if p-mode = "export":U then do:
    if search(full_name) <> ? then do:
    message substitute("Уже имеется в выбранной директории файл с именем &1&2" +
                       "совпадающим с именем одного из файлов экспорта&2" +
                       "Перезаписывать?"
                       ,full_name
                       , chr(10))
    view-as alert-box QUESTION buttons YES-NO update p-ok.
    return.
  end.
  p-ok = yes.
  return.
end.
END PROCEDURE.
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-b-code :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter p-b-code  like ub.bar-code.b-code       no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-b-code). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-b-code). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-b-code). endkey", vss-workfile )
  :
    define buffer buf_thbj-attr     for ub.thbj-attr .
    define buffer buf_sys-ctrl   for ub.sys-ctrl .
    define buffer buf_code-range for ub.code-range .
    define variable l-code         as   integer              no-undo .
    define variable v-db-num       like ub.db.db-num         no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    if type-code = 'sslc':U
    or type-code = 'ssgb':U
    then do:
      message
        "Нельзя генерировать локальный или глобальный взвешиваемый код." skip
        "Обратитесь к администратору системы."
        view-as alert-box error .
      undo, return error (if type-code = 'sslc':U then "loc-ss-code":U else "gbl-ss-code" ) .
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    run get-next-seq( input  type-code,
                      output l-code
                    ).
    find first buf_sys-ctrl no-lock.
    if type-code = 'sclc':U
    or type-code = 'pglc':U
    then do:
      assign
        v-db-num = 0
      .
    end.
    else do:
      assign
        v-db-num = buf_sys-ctrl.db-num
      .
    end.
    find first buf_code-range no-lock
      where buf_code-range.db-num     = v-db-num
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "a"
      use-index stts
      no-error .
    if available buf_code-range
       and l-code <= buf_code-range.last-code
       and l-code >= buf_code-range.first-code then do:
      assign
        p-b-code = l-code
      .
    end.
    else do:
      if available buf_code-range
         and l-code < buf_code-range.last-code then do:
        message
          substitute( "Последовательность для создания кодов с типом &1 имеет неверное значение.", type-code ) skip
          "Обратитесь к администратору системы."
          view-as alert-box error .
        undo, return error "sequence":U .
      end.
      do transaction
      on error undo, return error
      :
        find first buf_thbj-attr exclusive-lock
          where buf_thbj-attr.upper-prop-code = 'code-range':U
            and buf_thbj-attr.prop-code = cfg-param-code
            and buf_thbj-attr.obj-type   = 'БД':U
            and buf_thbj-attr.obj-code   = v-db-num
          no-error .
        if not available buf_thbj-attr then do:
          find first buf_thbj-attr exclusive-lock
            where buf_thbj-attr.upper-prop-code = 'code-range':U
              and buf_thbj-attr.prop-code = cfg-param-code
              and buf_thbj-attr.obj-type   = ''
              and buf_thbj-attr.obj-code   = 0
            no-error .
          if not available buf_thbj-attr then do:
            if not locked buf_thbj-attr then do:
              message
                substitute( "Отсутствует параметр 'длина диапазона кодов' (&1) для БД &2.", cfg-param-code, buf_sys-ctrl.db-num ) skip
                "Обратитесь к администратору системы."
                view-as alert-box error .
            end.
            undo, return error "config":U .
          end.
        end.
        run get-next-seq( input type-code,
                          output l-code
                        ).
        find first buf_code-range
          where buf_code-range.db-num     = v-db-num
            and buf_code-range.range-type = type-code
            and buf_code-range.stts       = "a"
          use-index stts
          no-error .
        if available buf_code-range
        and l-code <= buf_code-range.last-code
        and l-code >= buf_code-range.first-code
        then do:
          assign
            p-b-code = l-code
          .
        end.
        else do:
          if available buf_code-range then do:
            assign
              buf_code-range.stts = "u"
            .
          end.
          find first buf_code-range
            where buf_code-range.db-num     = v-db-num
              and buf_code-range.range-type = type-code
              and buf_code-range.stts       = "f"
            use-index stts
            no-error .
          if not available buf_code-range then do:
            message
              substitute( "Отсутствует свободный диапазон для кодов с типом &1.", type-code ) skip
              "Обратитесь к администратору системы"
              view-as alert-box error .
            undo, return error "code-range":U .
          end.
          assign
            buf_code-range.stts           = "a"
          .
          if buf_code-range.first-code = 1 then do:
            run set-seq-cr( input type-code,
                            input buf_code-range.first-code
                          ).
            assign
              p-b-code = 1
            .
          end.
          else do:
            run set-seq-cr( input type-code,
                            input ( buf_code-range.first-code - 1 )
                          ).
            run get-next-seq( input type-code,
                              output p-b-code
                            ).
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure get-next-seq :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter next-seq  as   integer                  no-undo .
  do
  on error  undo, return error substitute( "&1 (get-next-seq). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-next-seq). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-next-seq). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          next-seq = next-value(s-bcgb-code, ub)
        .
      end.
      when 'scgb':U then do:
        assign
          next-seq = next-value(s-scgb-code, ub)
        .
      end.
      when 'sclc':U then do:
        assign
          next-seq = next-value(s-sclc-code, ub)
        .
      end.
      when 'pglc':U then do:
        assign
          next-seq = next-value(s-pglc-code, ub)
        .
      end.
      when 'dcgb':U then do:
        assign
          next-seq = next-value(s-dcgb-code, ub)
        .
      end.
      when 'ctgb':U then do:
        assign
          next-seq = next-value(s-ctgb-code, ub)
        .
      end.
      when 'drgb':U then do:
        assign
          next-seq = next-value(s-drgb-code, ub)
        .
      end.
      when 'fmgb':U then do:
        assign
          next-seq = next-value(s-fmgb-code, ub)
        .
      end.
      when 'pngb':U then do:
        assign
          next-seq = next-value(s-pngb-code, ub)
        .
      end.
      when 'cagb':U then do:
        assign
          next-seq = next-value(s-cagb-code, ub)
        .
      end.
      when 'fdgb':U then do:
        assign
          next-seq = next-value(s-fin-doc, ub)
        .
      end.
    end case.
  end.
end procedure.
procedure set-seq-cr :
  define input parameter type-code like ub.code-range.range-type no-undo .
  define input parameter set-val   like ub.code-range.first-code no-undo .
  do
  on error  undo, return error substitute( "&1 (set-seq-cr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (set-seq-cr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (set-seq-cr). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          current-value(s-bcgb-code, ub) = set-val
        .
      end.
      when 'scgb':U then do:
        assign
          current-value(s-scgb-code, ub) = set-val
        .
      end.
      when 'sclc':U then do:
        assign
          current-value(s-sclc-code, ub) = set-val
        .
      end.
      when 'pglc':U then do:
        assign
          current-value(s-pglc-code, ub) = set-val
        .
      end.
      when 'dcgb':U then do:
        assign
          current-value(s-dcgb-code, ub) = set-val
        .
      end.
      when 'ctgb':U then do:
        assign
          current-value(s-ctgb-code, ub) = set-val
        .
      end.
      when 'drgb':U then do:
        assign
          current-value(s-drgb-code, ub) = set-val
        .
      end.
      when 'fmgb':U then do:
        assign
          current-value(s-fmgb-code, ub) = set-val
        .
      end.
      when 'pngb':U then do:
        assign
          current-value(s-pngb-code, ub) = set-val
        .
      end.
      when 'cagb':U then do:
        assign
          current-value(s-cagb-code, ub) = set-val
        .
      end.
      when 'fdgb':U then do:
        assign
          current-value(s-fin-doc, ub) = set-val
        .
      end.
    end case.
  end.
end procedure.
procedure new-bcod-gen-code-range :
  do
  on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
  :
    define input parameter p-db-num  like ub.db.db-num             no-undo .
    define input parameter type-code like ub.code-range.range-type no-undo .
    define buffer buf_code-range      for ub.code-range .
    define buffer last_code-range     for ub.code-range .
    define buffer last-1_code-range   for ub.code-range .
    define buffer last-2_code-range   for ub.code-range .
    define buffer last-3_code-range   for ub.code-range .
    define buffer buf_sys-ctrl        for ub.sys-ctrl .
    define variable conf-par       as character no-undo .
    define variable par-type       as character no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    define variable v-cre-cdrg as logical   no-undo .
    define variable v-cre-str  as character no-undo .
    define variable v-cr1      as integer no-undo .
    define variable v-cr2      as integer no-undo .
    define variable v-cr3      as integer no-undo .
    define variable v-cmax     as integer no-undo .
    find first buf_sys-ctrl no-lock .
    if buf_sys-ctrl.db-num <> 0 and type-code <> 'cagb':U then do:
      undo, return error substitute("&1 &2 &3&4Диапазоны кодов можно создавать только в ГБД&4База данных &5"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    , p-db-num
                                   ).
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    for each buf_code-range
      where buf_code-range.db-num     = -1
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "f"
    by buf_code-range.first-code
    on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
    :
      assign
        buf_code-range.db-num = p-db-num
      .
      return .
    end.
    assign
      v-cre-cdrg = TRUE
    .
    case type-code:
      when 'sclc':U
      or when 'scgb':U
      or when 'pglc':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sclc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'scgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'pglc':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
        if last_code-range.last-code + 1 > 99999 then do:
          assign
            v-cre-cdrg = FALSE
          .
        end.
      end.
      when 'bcgb':U
      or when 'sslc':U
      or when 'ssgb':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sslc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'bcgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'ssgb':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
      end.
      otherwise do:
        find last last_code-range no-lock
          where last_code-range.range-type = type-code
          no-error .
      end.
    end case.
    if not available last_code-range then do:
      undo, return error substitute("&1 &2 &3&4В БД нет ни одного диапазона с типом &5&4Не была проведена инициализация диапазонов!"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    , chr(10)
                                    , type-code
                                   ) .
    end.
    define variable v-mes10 as character no-undo .
    define variable v-param-type10 as character no-undo .
    define variable v-value-character10 as INTEGER no-undo .
    define variable v-value-date10 as date no-undo .
    define variable v-value-decimal10 as decimal no-undo .
    define variable v-value-integer10 AS integer no-undo .
    define variable v-value-logical10 AS LOGICAL no-undo .
    define variable v-tth10 as handle no-undo .
    run adm/shattri.p (
        input "get":U
        ,input  'БД':U
        ,input  p-db-num
        ,input  'code-range':U
        ,input  cfg-param-code
        ,output v-value-character10
        ,output v-value-date10
        ,output v-value-decimal10
        ,output v-value-integer10
        ,output v-value-logical10
        ,output v-param-type10
        ,INPUT-OUTPUT table-handle v-tth10
        ) no-error .
    if error-status :error then do:
      delete object v-tth10.
      v-mes10 = substitute("Ошибка при получении размера диапазона собственных глобальных кодов&2&1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value ).
      undo, return error v-mes10.
    end.
    delete object v-tth10.
    if v-cre-cdrg = TRUE then do:
      create buf_code-range .
      assign
        buf_code-range.db-num     = p-db-num
        buf_code-range.range-type = type-code
        buf_code-range.stts       = "f"
        buf_code-range.first-code = last_code-range.last-code + 1
        buf_code-range.last-code  = last_code-range.last-code + integer(v-value-integer10)
        v-cre-str = "Свободный диапазон успешно создан"
      .
    end.
    else do:
      assign
        v-cre-str = "Нет возможности создать свободный диапазон." + chr(10)
                    + substitute( "Превышен предел диапазонов c типом &1", type-code )
      .
    end.
  end.
  return v-cre-str .
end procedure.
procedure gen-new-code-range-if-neces :
  define input parameter v-db-num           like ub.db.db-num             no-undo .
  define input parameter v-range-type       like ub.code-range.range-type no-undo .
  define input parameter v-cur-code         as   integer                  no-undo .
  define input parameter v-g#news           as   logical                  no-undo .
  define input parameter v-g#db-num         like ub.db.db-num             no-undo .
  define input parameter v-g#news-source-db like ub.db.db-num             no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-new-code-range-if-neces). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-new-code-range-if-neces). endkey", vss-workfile )
  :
    define variable l-code-range-exist as logical   no-undo init false .
    define variable v-db-for-send      as character no-undo .
    define buffer buf_code-range  for ub.code-range .
    define buffer buf1_code-range for ub.code-range .
    define buffer buf_db          for ub.db .
    find first buf_code-range
      where buf_code-range.range-type = v-range-type
        and buf_code-range.last-code >= v-cur-code
      use-index last-codei
      no-error .
    if
    (
       available buf_code-range
       and
      (buf_code-range.db-num = v-db-num
        and
      buf_code-range.first-code <= v-cur-code
      )
    or
      (
        v-range-type = 'drgb':U
        AND
        v-cur-code = 0
      )
   )
   then do:
      assign
        l-code-range-exist = true
      .
      if v-g#news
      and buf_code-range.stts = "f" then do:
        assign
          buf_code-range.stts = "u"
        .
      end.
    end.
    if not l-code-range-exist
       and v-g#news-source-db <> 0
    then do:
      undo, return error substitute("&1 &2 &3&4Отсутствует диапазон кодов для БД &5 Тип диапазона кодов &6 Код &7"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    ,v-db-num
                                    ,v-range-type
                                    ,v-cur-code
                                   ).
    end.
    if (not l-code-range-exist
        or ( v-cur-code >= int( (buf_code-range.first-code + buf_code-range.last-code) / 2 ) )
       )
    and ( not can-find (first buf1_code-range no-lock
                        where buf1_code-range.db-num = v-db-num
                          and buf1_code-range.range-type = v-range-type
                          and buf1_code-range.stts = "f"
                       )
        )
    then do:
      if v-g#db-num = 0 then do:
        run new-bcod-gen-code-range in this-procedure
          (input v-db-num,
           input v-range-type
          ) no-error .
        if error-status :error then do:
          undo, return error substitute("Ошибка при создании нового свободного диапазона &1 Тип диапазона кодов &2 Код &3:&4&5 &6"
                                        , substitute("&1 &2 &3", vss-workfile, vss-revision, vss-description)
                                        ,v-db-num
                                        ,v-range-type
                                        ,v-cur-code
                                        ,chr(10)
                                        ,error-status:get-message(1)
                                        ,return-value
                                       ).
        end.
      end.
      else do:
        if v-range-type = 'sclc':U
        or v-range-type = 'pglc':U
        then do:
          assign
            v-db-for-send = "":U
          .
          if v-g#db-num = 0 then do:
            for each buf_db no-lock
              where buf_db.db-num > 0
                and buf_db.db-num <> v-g#news-source-db
            on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
            :
              assign
                v-db-for-send = v-db-for-send + chr(1) + string( buf_db.db-num )
              .
            end.
            assign
              v-db-for-send = right-trim( v-db-for-send, chr(1) )
            .
          end.
          else do:
            if not v-g#news then do:
              assign
                v-db-for-send = "0":U
              .
            end.
          end.
          run nws/cr-route.p ( input 'send-cmd':U
                        ,input ("command":U + chr(1) + "create":U + chr(1) +
                               "code-range":U + chr(1) +
                               (if v-range-type = 'sclc':U
                                then string( current-value(s-sclc-code, ub))
                                else string( current-value(s-pglc-code, ub))
                                ) + chr(1) +
                                v-range-type)
                        ,input ?
                        ,input v-db-for-send
                        ) no-error .
          if error-status :error then do:
            undo, return error return-value.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure cre-loc-sc-code-range :
  define input parameter v-cur-code as integer no-undo .
define input parameter p-cdrg-type as character no-undo .
  do
  on error  undo, return error substitute( "&1 (cre-loc-sc-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (cre-loc-sc-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (cre-loc-sc-code-range). endkey", vss-workfile )
  :
    define buffer buf_code-range for ub.code-range .
    find first buf_code-range
         where buf_code-range.range-type = p-cdrg-type
           and buf_code-range.first-code >= v-cur-code
         no-error .
    if not available buf_code-range then do:
      run new-bcod-gen-code-range in this-procedure
        ( input 0,
          input p-cdrg-type
        ) no-error .
      if error-status :error then do:
        undo, return error substitute( "Ошибка при создании нового свободного диапазона локальных весовых или штучных кодов&1"
                                       + "Код &2&1&3 &4"
                                      , chr(10)
                                      , v-cur-code
                                      , error-status:get-message(1)
                                      , return-value
                                     ) .
      end.
    end.
  end.
end procedure.
procedure mark-used-if-need :
define input parameter p-cur-code as integer no-undo .
define input parameter p-range-type like ub.code-range.range-type no-undo .
define input parameter p-db-num like ub.code-range.db-num no-undo .
  do
  on error  undo, return error substitute( "&1 (mark-used-if-need). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (mark-used-if-need). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (mark-used-if-need). endkey", vss-workfile )
  :
    DEFINE VARIABLE v-db-num like ub.code-range.db-num no-undo .
    define buffer buf_code-range for ub.code-range .
    assign
    v-db-num = if p-range-type = 'sclc':U
               then 0
               else p-db-num
    .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer locK-batchprocess11 for ub.batchprocess.
run gbl/lock-prc.p
    (input 'lscc':U
    ,input 0
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input (
            ",,,Вкл/выкл лок. вес. кодов"
           )
    ,input true
    ,buffer lock-batchprocess11
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент идет процесс вкл/выкл лок. вес. кодов" skip
      view-as alert-box error .
    undo, return error .
  end.
    find first buf_code-range
         where buf_code-range.range-type = p-range-type
           and buf_code-range.first-code >= p-cur-code
           and buf_code-range.last-code <= p-cur-code
           and buf_code-range.db-num = v-db-num
         no-error .
    if not available buf_code-range then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании поиске диапазона" skip
        "База данных" p-db-num skip
        "Код" p-cur-code skip
        "Тип" p-range-type
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_code-range.stts = "f":U then do:
      assign
      buf_code-range.stts = "u":U
      .
    end.
  end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gdsoattr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
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
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
define temp-table temp-sys-ctrl  NO-UNDO LIKE ub.sys-ctrl.
define temp-table temp-config  NO-UNDO LIKE ub.config.
define temp-table temp-prod-bc no-undo LIKE ub.prod-bc.
define temp-table temp-gds-obj-attr no-undo LIKE ub.gds-obj-attr.
define temp-table temp-scales  NO-UNDO LIKE ub.scales.
define temp-table temp-scales-gds  NO-UNDO LIKE ub.scales-gds.
define temp-table temp-scales-grp  NO-UNDO LIKE ub.scales-grp.
define temp-table temp-filter  NO-UNDO LIKE ubflt.filter.
define temp-table temp-cash-desk  NO-UNDO LIKE ub.cash-desk.
define temp-table temp-curr-shop  NO-UNDO LIKE ub.curr-shop.
define temp-table temp_sequence  NO-UNDO
field seq-name like ub._sequence._seq-name
field seq-val as int64
index pi is unique primary
seq-name
.
define temp-table temp-usr-flt  NO-UNDO LIKE ubflt.usr-flt.
define temp-table temp-user-account            NO-UNDO LIKE ub.user-account.
define temp-table temp-user-login              NO-UNDO LIKE ub.user-login.
define temp-table temp-user-obj                NO-UNDO LIKE ub.user-obj.
define temp-table temp-user-host               NO-UNDO LIKE ub.user-host.
define temp-table temp-user-menu-group         NO-UNDO LIKE ub.user-menu-group.
define temp-table temp-user-login-action-role  NO-UNDO LIKE ub.user-login-action-role.
define temp-table temp-user-login-action-item  NO-UNDO LIKE ub.user-login-action-item.
define temp-table temp-action-role             NO-UNDO LIKE ub.action-role.
define temp-table temp-action-role-item        NO-UNDO LIKE ub.action-role-item.
define temp-table temp-action-item no-undo
  field grp-acta-arm-code  as character
  field grp-acta-object    as character
  field grp-acta-act       as character
  field action-item-id     as character
  field action-context     as character
  index xpk is primary unique grp-acta-arm-code grp-acta-object grp-acta-act
  index ie1 action-item-id
  index ie2 action-context
  .
define temp-table temp-userconf no-undo
   field user-name      as character
   field obj-code       as integer
   field obj-type       as character
   field ARM            as character  format "X(12)"
   field on-line        as logical
   field max-discnt     as decimal
   field quest-print    as logical
   field arm-host-code  as integer
   field userid_        as character
   field user-name_     as character
   field password_      as character
   index pu is primary unique
         user-name
.
define temp-table temp-usr-grpa no-undo
   field user-name      as character
   field arm-code       as character
   field grp-name       as character format "X(20)"
   field host-code      as integer
   index pu is primary unique
         user-name
         host-code
         arm-code
.
define temp-table temp-usr-grpo no-undo
   field user-name      as character
   field obj-type       as character
   field obj-code       as integer
   field grp-name       as character format "X(20)"
   index pu is primary unique
         user-name
         obj-type
         obj-code
.
define temp-table temp-grpa no-undo
   field grp-name       as character format "X(20)"
   field arm-code       as character
   index pu is primary unique
         arm-code
         grp-name
.
define temp-table temp-grp-acta no-undo
   field grp-name       as character format "X(20)"
   field arm-code       as character
   field object         as character format "X(15)"
   field act            as character format "X(25)"
   index pu is primary unique
         grp-name
         arm-code
         object
         act
.
define temp-table buf-sys-ctrl  NO-UNDO LIKE ub.sys-ctrl.
define temp-table buf-config  NO-UNDO LIKE ub.config.
define temp-table buf-prod-bc no-undo LIKE ub.prod-bc.
define temp-table buf-gds-obj-attr no-undo LIKE ub.gds-obj-attr.
define temp-table buf-scales  NO-UNDO LIKE ub.scales.
define temp-table buf-scales-gds  NO-UNDO LIKE ub.scales-gds.
define temp-table buf-scales-grp  NO-UNDO LIKE ub.scales-grp.
define temp-table buf-filter  NO-UNDO LIKE ubflt.filter.
define temp-table buf-cash-desk  NO-UNDO LIKE ub.cash-desk.
define temp-table buf-curr-shop  NO-UNDO LIKE ub.curr-shop.
define temp-table buf_sequence  NO-UNDO
field seq-name like ub._sequence._seq-name
field seq-val as int64
index pi is unique primary
seq-name
.
define temp-table buf-usr-flt                 NO-UNDO LIKE ubflt.usr-flt.
define temp-table buf-user-account            NO-UNDO LIKE ub.user-account.
define temp-table buf-user-login              NO-UNDO LIKE ub.user-login.
define temp-table buf-user-obj                NO-UNDO LIKE ub.user-obj.
define temp-table buf-user-host               NO-UNDO LIKE ub.user-host.
define temp-table buf-user-menu-group         NO-UNDO LIKE ub.user-menu-group.
define temp-table buf-user-login-action-role  NO-UNDO LIKE ub.user-login-action-role.
define temp-table buf-user-login-action-item  NO-UNDO LIKE ub.user-login-action-item.
define temp-table buf-action-role             NO-UNDO LIKE ub.action-role.
define temp-table buf-action-role-item        NO-UNDO LIKE ub.action-role-item.
define temp-table buf-userconf  NO-UNDO LIKE temp-userconf .
define temp-table buf-grpa      NO-UNDO LIKE temp-grpa .
define temp-table buf-usr-grpa  NO-UNDO LIKE temp-usr-grpa .
define temp-table buf-usr-grpo  NO-UNDO LIKE temp-usr-grpo .
define temp-table buf-grp-acta  NO-UNDO LIKE temp-grp-acta .
define stream Instream.
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE ss as character no-undo .
DEFINE VARIABLE current-table as character no-undo .
DEFINE VARIABLE loc-alert-box as logical no-undo .
DEFINE VARIABLE r-bar-code like ub.bar-code.b-code no-undo .
DEFINE VARIABLE v-is-global as logical no-undo .
DEFINE VARIABLE v-is-weight as logical no-undo .
DEFINE VARIABLE v-is-pgweight as logical no-undo .
DEFINE VARIABLE v-is-scaleable as logical no-undo .
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE dopi as integer no-undo .
DEFINE VARIABLE scales-unit as character no-undo .
DEFINE VARIABLE scales-max-gds like ub.scales.max-gds no-undo.
DEFINE VARIABLE scales-tot-gds like ub.scales.tot-gds no-undo.
DEFINE VARIABLE  hnum as logical no-undo init no.
DEFINE VARIABLE  b-hnum as logical no-undo init no.
DEFINE VARIABLE  conf-par as char no-undo.
DEFINE VARIABLE  par-type as char no-undo.
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE er-mes as character no-undo .
DEFINE VARIABLE v-b-code as integer no-undo .
define variable v-pbc-rid as recid no-undo .
define variable v-b-str as character no-undo .
define variable v-cdrg-type as character no-undo .
define buffer cli_units for ub.units.
define buffer buf_code-range for ub.code-range.
define buffer buf_config for ub.config.
define buffer ext_config for ub.config.
assign
p-rht = logical(entry(1, p-parameter, chr(4)))
p-gen = logical(entry(2, p-parameter, chr(4)))
p-flt = logical(entry(3, p-parameter, chr(4)))
p-pbc = logical(entry(4, p-parameter, chr(4)))
p-scl = logical(entry(5, p-parameter, chr(4)))
p-usr = logical(entry(6, p-parameter, chr(4)))
p-seq = logical(entry(7, p-parameter, chr(4)))
p-db-key = entry(8, p-parameter, chr(4))
p-dir-name  = entry(9, p-parameter, chr(4))
p-glb       = logical(entry(10, p-parameter, chr(4)))
p-version   = entry(11, p-parameter, chr(4))
no-error
.
if error-status:error then return error substitute("&1 &2", error-status:get-message(1) , return-value ).
run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", " Импорт локальных таблиц" )) .
if p-gen then do:
  run p-gen-i in this-procedure .
end.
if p-flt then do:
  run p-flt-i in this-procedure .
end.
if p-scl then do:
  run p-scl-i in this-procedure .
end.
if p-seq then do:
  run p-seq-i in this-procedure .
end.
if p-pbc then do:
  run p-pbc-i in this-procedure .
end.
if p-rht then do:
  run p-rht-i in this-procedure .
end.
if p-usr then do:
   if (not p-rht)
   and (not (p-version = "15.0")) then do:
      run p-rht-i in this-procedure .
   end.
   run p-usr-i in this-procedure .
end.
ii = 0.
if p-gen then do:
        run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Проверка группы данных ИНФОРМАЦИЯ О БД" ) ).
      _configv:
  FOR EACH temp-config:
    find first ub.config no-lock where
              ub.config.param-code = temp-config.param-code
          AND ub.config.host-code = 0
          AND ub.config.obj-type = '':U
          AND ub.config.obj-code = 0
    NO-ERROR.
    if not available ub.config then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ИНФОРМАЦИЯ О БД" + chr(10) + " НАСТРОЕЧНЫЙ ПАРАМЕТР(config)" +                                         " " + temp-config.param-code +                                         " Фирма " + string(temp-config.host-code) +                                         " тип объекта " + temp-config.obj-type +                                         " код объекта " + string(temp-config.obj-code) +                                         " не является валидным в данной конфигурации" ) )) .              delete temp-config.                   NEXT _configv.
    end.
    if lookup(ub.config.conf-type, 'к,п':U) > 0
    then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ИНФОРМАЦИЯ О БД" + chr(10) + " НАСТРОЕЧНЫЙ ПАРАМЕТР(config)" +                                         " " + temp-config.param-code +                                         " является кодированным - импорт запрещен" ) )) .              delete temp-config.                   NEXT _configv.
    end.
    FIND FIRST ext_config No-LOCK WHERE
              ext_config.param-code = temp-config.param-code AND
              ext_config.host-code = temp-config.host-code AND
              ext_config.obj-type = temp-config.obj-type AND
              ext_config.obj-code = temp-config.obj-code
    NO-ERROR.
    IF AVAILABLE ext_config then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ИНФОРМАЦИЯ О БД" + chr(10) + " Уже есть запись НАСТРОЕЧНОГО ПАРАМЕТРА(config)" +                                         " параметр " + temp-config.param-code +                                         " Фирма " + string(temp-config.host-code) +                                         " тип объекта " + temp-config.obj-type +                                         " код объекта " + string(temp-config.obj-code) ) )) .              delete temp-config.                   NEXT _configv.
    end.
    if temp-config.host-code > 0 then do:
      FIND FIRST ub.sysconf No-LOCK WHERE
                ub.sysconf.host-code = temp-config.host-code No-ERROR.
      IF NOT AVAIL ub.sysconf then do:
                    run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ИНФОРМАЦИЯ О БД" + chr(10) + " Отсутствует фирма для НАСТРОЕЧНОГО ПАРАМЕТРА(config)" +                                           " параметр " + temp-config.param-code +                                           " Фирма " + string(temp-config.host-code) +                                           " тип объекта " + temp-config.obj-type +                                           " код объекта " + string(temp-config.obj-code) ) )) .              delete temp-config.                   NEXT _configv.
      END.
    end.
    if temp-config.obj-type <> "" or temp-config.obj-code > 0 then do:
      FIND FIRST ub.clients No-LOCK WHERE
                ub.clients.obj-type = temp-config.obj-type AND
                ub.clients.obj-code = temp-config.obj-code NO-ERROR.
      IF NOT AVAIL ub.clients then do:
                    run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ИНФОРМАЦИЯ О БД" + chr(10) + " Отсутствует объект для НАСТРОЕЧНОГО ПАРАМЕТРА(config)" +                                           " параметр " + temp-config.param-code +                                           " Фирма " + string(temp-config.host-code) +                                           " тип объекта " + temp-config.obj-type +                                           " код объекта " + string(temp-config.obj-code) ) )) .              delete temp-config.                   NEXT _configv.
      END.
      IF ub.clients.db-num <> ub.db.db-num then do:
                    run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ИНФОРМАЦИЯ О БД" + chr(10) + " Объект для НАСТРОЕЧНОГО ПАРАМЕТРА(config) принадлежит другой БД" +                                           " параметр " + temp-config.param-code +                                           " Фирма " + string(temp-config.host-code) +                                           " тип объекта " + temp-config.obj-type +                                           " код объекта " + string(temp-config.obj-code) ) )) .              delete temp-config.                   NEXT _configv.
      END.
    end.
    create buf_config.
    buffer-copy ub.config to buf_config
    assign
    buf_config.host-code = temp-config.host-code
    buf_config.obj-type = temp-config.obj-type
    buf_config.obj-code = temp-config.obj-code
    buf_config.param-value = temp-config.param-value
    .
    release buf_config no-error.
    if error-status:error then do:
      er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ИНФОРМАЦИЯ О БД" + chr(10) +  " ошибка при сохранении НАСТРОЕЧНОГО ПАРАМЕТРA(config):" +                                       " параметр " + temp-config.param-code +                                       " Фирма " + string(temp-config.host-code) +                                       " тип объекта " + temp-config.obj-type +                                       " код объекта " + string(temp-config.obj-code) +                                       er-mes) )) .                NEXT _configv.
    end.
  END.
end.
if p-flt then do:
        run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Проверка группы данных ФИЛЬТРЫ" ) ).
      _filterv:
  FOR EACH temp-filter NO-LOCK:
    FIND FIRST ubflt.filter No-LOCK WHERE
              ubflt.filter.call-point = temp-filter.call-point AND
              ubflt.filter.NAIM = temp-filter.NAIM NO-ERROR.
    IF AVAILABLE ubflt.filter then do:
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ФИЛЬТРЫ" + chr(10) + " Уже есть ФИЛЬТР(filter):" +                       " название " + string(temp-filter.Naim) +                       " точка вызова " + temp-filter.call-point) )) .              delete temp-filter.                   NEXT _filterv.
    end.
    create ubflt.filter.
    buffer-copy temp-filter to ubflt.filter.
    release ubflt.filter no-error.
    if error-status:error then do:
      er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ФИЛЬТРЫ" + chr(10) + " ошибка при сохранении записи ФИЛЬТР(filter):" +                       " название " + string(temp-filter.Naim) +                       " точка вызова " + temp-filter.call-point +                       er-mes) )) .                NEXT _filterv.
    end.
  run adm/restseqr.p
    ( input "rest-no-msg":U
     ,input "next-num-filter":U
     ,input no
    ) no-error .
  if error-status :error then do:
    return error return-value .
  end.
  END.
end.
if p-pbc then do:
        run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Проверка группы данных ВЕС и ВЗВЕШ КОДЫ" ) ).
      _prod-bcv:
  FOR EACH temp-prod-bc:
    assign
    v-is-global = no
    v-is-weight = no
    v-is-pgweight = no
    v-is-scaleable = no
    .
    FIND FIRST ub.prod-bc No-LOCK WHERE
               ub.prod-bc.b-str = temp-prod-bc.b-str
          AND  ub.prod-bc.b-code = temp-prod-bc.b-code NO-ERROR.
    IF AVAILABLE ub.prod-bc then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Уже есть ДопБК(prod-bc):" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code)) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
    end.
    find first ub.prod-bc no-lock where
              ub.prod-bc.b-str = temp-prod-bc.b-str
          AND ub.prod-bc.bc-on = yes no-error.
    IF AVAILABLE ub.prod-bc then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Уже есть такой включенный ДопБК(prod-bc) на другом товаре:" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код имеющегося включенного ДопБК" + string(ub.prod-bc.b-code)) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
    end.
    find first ub.bar-code no-lock where
               ub.bar-code.b-code = temp-prod-bc.b-code no-error.
    if not avail ub.bar-code then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Не найден бар-код для ДопБК(prod-bc):" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code)) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
    end.
    FIND FIRST ub.goods no-lock where
              ub.goods.gds-code = ub.bar-code.gds-code  NO-ERROR.
    if not avail ub.bar-code then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Не найден товар по бар-коду для ДопБК(prod-bc):" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code)) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
    end.
    find first ub.units no-lock where
               ub.units.unit-name = ub.goods.unit-base no-error .
    if not avail ub.units then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Не найдена основная ед. изм товара для ДопБК(prod-bc):" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code) +                         " Товар " + ub.goods.artic + chr(32) + ub.goods.prod-type + string(ub.goods.prod-code)) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
    end.
    if LOOKUP('вес':U, ub.units.type) = 0
    and not (LOOKUP('шту':U, ub.units.type) > 0
         and can-find(first ub.code-range no-lock where
                            ub.code-range.db-num = 0
                        and ub.code-range.range-type = 'pglc':U
                        and ub.code-range.first-code <= integer(temp-prod-bc.b-str)
                        and ub.code-range.last-code >= integer(temp-prod-bc.b-str)))
    then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Товар по ДопБК(prod-bc) НЕ ((весовой или штучный) и ДопБК - код для весов):" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code) +                         " Товар " + ub.goods.artic + chr(32) + ub.goods.prod-type + string(ub.goods.prod-code) +                         " Основн. ед. изм" + ub.goods.unit-base) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
    end.
    if ub.bar-code.unit-cli = ub.goods.unit-base then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ?
  ,output r-bar-code
  ) no-error .
      if error-status:error then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Ошибка при поиске основного бар-кода товара для ДопБК(prod-bc):" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code)) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
      end.
      if r-bar-code <> ub.bar-code.b-code then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Бар-код для ДопБК(prod-bc) не является основным бар-кодом товара:" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code)) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
      end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input temp-prod-bc.b-str
  ,input  ub.bar-code.unit-cli
  ,input  ub.goods.unit-base
  ,input  'global=request':U
  ,output v-is-global
  ) no-error .
      if error-status:error then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Ошибка при проверке на локальность ДопБК(prod-bc):" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code)) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
      end.
      if v-is-global
      and not p-glb
      then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " ДопБК(prod-bc) не локальный:" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code)) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
      end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input temp-prod-bc.b-str
  ,input  ub.bar-code.unit-cli
  ,input  ub.goods.unit-base
  ,input  'weight=request':U
  ,output v-is-weight
  ) no-error .
      if error-status:error then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Ошибка при проверке весовой ли ДопБК(prod-bc):" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code)) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
      end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input temp-prod-bc.b-str
  ,input  ub.bar-code.unit-cli
  ,input  ub.goods.unit-base
  ,input  'pgweight=request':U
  ,output v-is-pgweight
  ) no-error .
      if error-status:error then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Ошибка при проверке штучный ли ДопБК для весов(prod-bc):" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code)) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
      end.
      if not v-is-weight
      and not v-is-pgweight
      then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " ДопБК(prod-bc) не код для весов:" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code)) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
      end.
      if v-is-weight then do:
      v-cdrg-type = 'sclc':U.
    end.
    else do:
        v-cdrg-type = 'pglc':U.
      end.
    end.
    else do:
      find first cli_units no-lock where
                cli_units.unit-name = ub.bar-code.unit-cli no-error .
      if not avail cli_units then do:
                    run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Не найдена ед. изм бар-кода для ДопБК(prod-bc):" +                           " ДопБК " + string(temp-prod-bc.b-str) +                           " Бар-код " + string(temp-prod-bc.b-code) +                           " Ед.изм.бар-кода "  + ub.bar-code.unit-cli) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
      end.
      if LOOKUP('дро':U, cli_units.type) = 0 then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Единица измерения бар-кода по ДопБК(prod-bc) не весовая и не дробная:" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code) +                         " Ед. изм" + ub.bar-code.unit-cli) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
      end.
      if ub.bar-code.part-code <> "":U or ub.bar-code.in-code <> "":U then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Бар-код для ДопБК(prod-bc) не является бар-кодом товара на доп.ед.изм:" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code) +                         " in-code " + ub.bar-code.in-code +                         " part-code " + ub.bar-code.part-code ) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
      end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input temp-prod-bc.b-str
  ,input  ub.bar-code.unit-cli
  ,input  ub.goods.unit-base
  ,input  'global=request':U
  ,output v-is-global
  ) no-error .
      if error-status:error then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Ошибка при проверке на локальность ДопБК(prod-bc):" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code)) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
      end.
      if v-is-global
      and p-glb = no
      then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " ДопБК(prod-bc) не локальный:" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code)) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
      end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input temp-prod-bc.b-str
  ,input  ub.bar-code.unit-cli
  ,input  ub.goods.unit-base
  ,input  'scaleable=request':U
  ,output v-is-scaleable
  ) no-error .
      if error-status:error then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Ошибка при проверке взвешиваемый ли ДопБК(prod-bc):" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code)) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
      end.
      if not v-is-scaleable then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " ДопБК(prod-bc) не весовой:" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code)) )) .              delete temp-prod-bc.                   NEXT _prod-bcv.
      end.
      v-cdrg-type = 'sslc':U.
    end.
    v-pbc-rid = ?.
    v-b-str = temp-prod-bc.b-str.
    run trg/prod-bc1.p ( input parparentproc
                        ,input yes
                        ,input no
                        ,input no
                        ,input no
                        ,input v-cdrg-type
                        ,input ""
                        ,buffer ub.goods
                        ,input ub.bar-code.b-code
                        ,input-output v-b-str
                        ,output v-pbc-rid
                        ) no-error.
    if error-status:error
    or v-pbc-rid = ?
    then do:
      er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
      er-mes = er-mes + chr(10) + return-value .
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " ошибка при сохранении записи ДопБК(prod-bc):" +                         " ДопБК " + string(temp-prod-bc.b-str) +                         " Бар-код " + string(temp-prod-bc.b-code) +                       er-mes) )) .                NEXT _prod-bcv.
    end.
  END.
  run get-max-code in this-procedure
    ( input "f-u":U
      ,input ub.sys-ctrl.db-num
      ,input 'sslc':U
      ,input ?
      ,input ?
      ,input TRUE
      ,output v-b-code
    ) no-error .
  if error-status:error then do:
    er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
        run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " ошибка при исправлении статуса диапазонов взвешиваемых кодов(prod-bc):" +                     er-mes) )) .
  end.
  run get-max-code in this-procedure
    ( input "f-u":U
      ,input ub.sys-ctrl.db-num
      ,input 'sclc':U
      ,input ?
      ,input ?
      ,input TRUE
      ,output v-b-code
    ) no-error .
  if error-status:error then do:
    er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
        run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " ошибка при исправлении статуса диапазонов локальных весовых кодов(prod-bc):" +                     er-mes) )) .
  end.
  run get-max-code in this-procedure
    ( input "f-u":U
      ,input ub.sys-ctrl.db-num
      ,input 'pglc':U
      ,input ?
      ,input ?
      ,input TRUE
      ,output v-b-code
    ) no-error .
  if error-status:error then do:
    er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
        run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " ошибка при исправлении статуса диапазонов штучных кодов для  весовых (prod-bc):" +                     er-mes) )) .
  end.
  find first buf_code-range no-lock
    where buf_code-range.db-num     = 0
      and buf_code-range.range-type = 'sclc':U
      and buf_code-range.stts       = "a":U
    no-error .
  if not available buf_code-range then do:
    er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
        run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " ошибка при установке значения sequence внутрь активного диапазонов локальных весовых кодов(prod-bc):" +                     er-mes) )) .
  end.
  else do:
    run get-max-code ( input "get-m-code":U
                      ,input buf_code-range.db-num
                      ,input buf_code-range.range-type
                      ,input buf_code-range.first-code
                      ,input buf_code-range.last-code
                      ,input TRUE
                      ,output v-b-code
                      ) no-error .
    if error-status:error then do:
      er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " ошибка при получении max кода диапазона взвешиваемых кодов(prod-bc):" +                       er-mes) )) .
    end.
    if v-b-code <= buf_code-range.last-code then do:
      current-value(s-sclc-code, ub) = v-b-code.
    end.
    else do:
      current-value(s-sclc-code, ub) = buf_code-range.last-code.
    end.
  end.
  find first buf_code-range no-lock
    where buf_code-range.db-num     = 0
      and buf_code-range.range-type = 'pglc':U
      and buf_code-range.stts       = "a":U
    no-error .
  if not available buf_code-range then do:
    er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
        run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " ошибка при установке значения sequence внутрь активного диапазонов локальных штучных кодов для весов(prod-bc):" +                     er-mes) )) .
  end.
  else do:
    run get-max-code ( input "get-m-code":U
                      ,input buf_code-range.db-num
                      ,input buf_code-range.range-type
                      ,input buf_code-range.first-code
                      ,input buf_code-range.last-code
                      ,input TRUE
                      ,output v-b-code
                      ) no-error .
    if error-status:error then do:
      er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " ошибка при получении max кода диапазона локальных штуных кодов для весов(prod-bc):" +                       er-mes) )) .
    end.
    if v-b-code <= buf_code-range.last-code then do:
      current-value(s-pglc-code, ub) = v-b-code.
    end.
    else do:
      current-value(s-pglc-code, ub) = buf_code-range.last-code.
    end.
  end.
  run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Проверка группы данных ВЕС и ВЗВЕШ КОДЫ" ) ).
      _gds-obj-attrv:
  FOR EACH temp-gds-obj-attr NO-LOCK:
    FIND FIRST ub.gds-obj-attr No-LOCK WHERE
              ub.gds-obj-attr.gds-code = temp-gds-obj-attr.gds-code
          AND ub.gds-obj-attr.obj-code = temp-gds-obj-attr.obj-code
          AND ub.gds-obj-attr.obj-type  = temp-gds-obj-attr.obj-type
          AND ub.gds-obj-attr.attr-code  = temp-gds-obj-attr.attr-code NO-ERROR.
    IF AVAILABLE ub.gds-obj-attr then do:
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Уже есть АТРИБУТ ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr):" +                       " код товара " + string(temp-gds-obj-attr.gds-code) +                       " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) +                       " весовой код " + temp-gds-obj-attr.attr-value +                       er-mes) )) .              delete temp-gds-obj-attr.                   NEXT _gds-obj-attrv.
    end.
    FIND FIRST ub.goods No-LOCK WHERE
              ub.goods.gds-code = temp-gds-obj-attr.gds-code no-error .
    IF NOT AVAILABLE ub.goods then do:
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Нет товара для АТРИБУТА ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr):" +                       " код товара " + string(temp-gds-obj-attr.gds-code) +                       " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) +                       " весовой код " + temp-gds-obj-attr.attr-value +                       er-mes) )) .              delete temp-gds-obj-attr.                   NEXT _gds-obj-attrv.
    end.
    find first ub.units no-lock where
               ub.units.unit-name = ub.goods.unit-base no-error .
    if not avail ub.units
    or (lookup('вес':U, ub.units.type) = 0
        and
        lookup('шту':U, ub.units.type) = 0)
    then do:
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Не найдена основная единица измерения для товара или товар не весовой и не штучный для АТРИБУТА ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr):" +                       " код товара " + string(temp-gds-obj-attr.gds-code) +                       " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) +                       " весовой код " + temp-gds-obj-attr.attr-value +                       er-mes) )) .              delete temp-gds-obj-attr.                   NEXT _gds-obj-attrv.
    end.
    FIND FIRST ub.clients No-LOCK WHERE
              ub.clients.obj-type = temp-gds-obj-attr.obj-type
          AND ub.clients.obj-code = temp-gds-obj-attr.obj-code no-error .
    IF NOT AVAILABLE ub.clients then do:
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Нет объекта для АТРИБУТА ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr):" +                       " код товара " + string(temp-gds-obj-attr.gds-code) +                       " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) +                       " весовой код " + temp-gds-obj-attr.attr-value +                       er-mes) )) .              delete temp-gds-obj-attr.                   NEXT _gds-obj-attrv.
    end.
    if LOOKUP(ub.clients.obj-type, 'маг':U + chr(44) + 'скл':U) = 0 then do:
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Неверный тип объекта для АТРИБУТА ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr):" +                       " код товара " + string(temp-gds-obj-attr.gds-code) +                       " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) +                       " весовой код " + temp-gds-obj-attr.attr-value +                       er-mes) )) .              delete temp-gds-obj-attr.                   NEXT _gds-obj-attrv.
    end.
    if ub.clients.db-num <> ub.db.db-num then do:
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Объект для АТРИБУТА ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr) принадлежит другой БД:" +                       " код товара " + string(temp-gds-obj-attr.gds-code) +                       " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) +                       " весовой код " + temp-gds-obj-attr.attr-value +                       er-mes) )) .              delete temp-gds-obj-attr.                   NEXT _gds-obj-attrv.
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ?
  ,output r-bar-code
  ) no-error .
    if error-status:error then do:
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Ошибка при поиске основного бар-кода товара  для АТРИБУТА ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr) принадлежит другой БД:" +                       " код товара " + string(temp-gds-obj-attr.gds-code) +                       " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) +                       " весовой код " + temp-gds-obj-attr.attr-value +                       er-mes) )) .              delete temp-gds-obj-attr.                   NEXT _gds-obj-attrv.
    end.
    find first ub.prod-bc no-lock where
               ub.prod-bc.b-str = temp-gds-obj-attr.attr-value
            AND ub.prod-bc.b-code = r-bar-code
            AND ub.prod-bc.bc-on = yes no-error .
    if not avail ub.prod-bc then do:
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " Нет соответствующего весового кода или он выключен для АТРИБУТА ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr) принадлежит другой БД:" +                       " код товара " + string(temp-gds-obj-attr.gds-code) +                       " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) +                       " весовой код " + temp-gds-obj-attr.attr-value +                       er-mes) )) .              delete temp-gds-obj-attr.                   NEXT _gds-obj-attrv.
    end.
    create ub.gds-obj-attr.
    buffer-copy temp-gds-obj-attr to ub.gds-obj-attr.
    release ub.gds-obj-attr no-error.
    if error-status:error then do:
      er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + chr(10) + " ошибка при сохранении записи АТРИБУТ ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr):" +                       " код товара " + string(temp-gds-obj-attr.gds-code) +                       " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) +                       " весовой код " + temp-gds-obj-attr.attr-value +                       er-mes) )) .                NEXT _gds-obj-attrv.
    end.
  END.
end.
if p-scl then do:
        run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Проверка группы данных ВЕСЫ" ) ).
      _scalesv:
  FOR EACH temp-scales:
    FIND FIRST ub.scales No-LOCK WHERE
               ub.scales.db-num = temp-scales.db-num  AND
               ub.scales.scales-num = temp-scales.scales-num  NO-ERROR.
    IF AVAILABLE ub.scales then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Уже есть ВЕСЫ(scales):" +                         " номер " + string(temp-scales.scales-num)) )) .              delete temp-scales.                   NEXT _scalesv.
    end.
    IF temp-scales.master > 0 then do:
      dopi = temp-scales.master.
      IF NOT (CAN-FIND(FIRST ub.scales No-LOCK WHERE
                            ub.scales.db-num = g#db-num
                        AND ub.scales.scales-num = dopi) OR
              CAN-FIND(FIRST temp-scales No-LOCK WHERE
                             temp-scales.db-num = g#db-num
                        AND temp-scales.scales-num = dopi)) then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Не найдены главные весы для подчиненных ВЕСОВ(scales):" +                         " номер " + string(temp-scales.scales-num)) )) .              delete temp-scales.                   NEXT _scalesv.
      END.
    end.
    define variable v-rid as recid no-undo .
    run ref/scales1.p (
    input-output v-rid
    ,input 'ДОБАВЛЕНИЕ':U
    ,INPUT yes
    ,input temp-scales.db-num
    ,input temp-scales.scales-num
    ,input temp-scales.address
    ,input temp-scales.master
    ,input temp-scales.max-gds
    ,input temp-scales.scales-name
    ,input temp-scales.scales-type
    ,input temp-scales.remote
    ,input temp-scales.sts
    ,input temp-scales.unit-base
    ,input temp-scales.wt-cart
    ) no-error .
    if error-status:error then do:
      er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) +  " ошибка при сохранении записи ВЕСЫ(scales):" +                                       " номер " + string(temp-scales.scales-num) +                                       er-mes) )) .                NEXT _scalesv.
    end.
  END.
      _scales-gdsv:
  FOR EACH temp-scales-gds :
    assign
    dopi = temp-scales-gds.scales-num
    scales-unit = "":U
    scales-max-gds = 0
    scales-tot-gds = 0
    .
    FIND FIRST ub.scales where
               ub.scales.db-num = g#db-num
         AND ub.scales.scales-num = dopi NO-ERROR.
    IF NOT AVAIL ub.scales then do:
      IF NOT AVAIL ub.scales then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Не найдены ВЕСЫ для ТОВАРА НА ВЕСАХ(scales-gds):" +                         " номер весов " + string(temp-scales-gds.scales-num) +                         " PLU " + string(temp-scales-gds.PLU-code)) )) .              delete temp-scales-gds.                   NEXT _scales-gdsv.
      END.
      if ub.scales.master > 0 then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " ВЕСЫ для ТОВАРА НА ВЕСАХ(scales-gds) являются подчиненными - импортировать нельзя:" +                         " номер весов " + string(temp-scales-gds.scales-num) +                         " PLU " + string(temp-scales-gds.PLU-code)) )) .              delete temp-scales-gds.                   NEXT _scales-gdsv.
      end.
    END.
    ELSE do:
      assign
      scales-unit = ub.scales.unit-base
      scales-max-gds = ub.scales.max-gds
      scales-tot-gds = ub.scales.tot-gds
      .
    END.
    FIND FIRST ub.shop No-LOCK WHERE
               ub.shop.obj-code = temp-scales-gds.obj-code  NO-ERROR.
    IF NOT AVAILABLE ub.shop then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Нет магазина для ТОВАРА НА ВЕСАХ(scales-gds)" +                         " номер весов " + string(temp-scales-gds.scales-num) +                         " PLU " + string(temp-scales-gds.PLU-code) +                         " temp-scales-gds.obj-code " + string(temp-scales-gds.obj-code)) )) .              delete temp-scales-gds.                   NEXT _scales-gdsv.
    end.
    FIND FIRST ub.clients WHERE
               ub.clients.obj-type = 'маг':U AND
               ub.clients.obj-code = temp-scales-gds.obj-code NO-LOCK NO-ERROR.
    if avail ub.clients and clients.db-num <> ub.db.db-num then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Магазин для ТОВАРОВ ДЛЯ ВЕСОВ относится к другой БД - ТОВАР НА ВЕСАХ(scales-gds):" +                         " номер весов " + string(temp-scales-gds.scales-num) +                         " PLU " + string(temp-scales-gds.PLU-code) +                         " temp-scales-gds.obj-code " + string(temp-scales-gds.obj-code) +                         " db-num " + string(ub.db.db-num)) )) .              delete temp-scales-gds.                   NEXT _scales-gdsv.
   end.
    if temp-scales-gds.plu-code > scales-max-gds then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " PLU больше Max кол-ва товаров на весах для ТОВАРА НА ВЕСАХ(scales-gds):" +                         " номер весов " + string(temp-scales-gds.scales-num) +                         " PLU " + string(temp-scales-gds.PLU-code)) )) .              delete temp-scales-gds.                   NEXT _scales-gdsv.
    END.
    FIND FIRST ub.scales-gds No-LOCK WHERE
              ub.scales-gds.db-num = temp-scales-gds.db-num AND
              ub.scales-gds.scales-num = temp-scales-gds.scales-num AND
              ub.scales-gds.PLU-code = temp-scales-gds.PLU-code NO-ERROR.
    IF AVAIL ub.scales-gds then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Уже есть ТОВАР НА ВЕСАХ(scales-gds):" +                         " номер весов " + string(temp-scales-gds.scales-num) +                         " PLU " + string(temp-scales-gds.PLU-code)) )) .              delete temp-scales-gds.                   NEXT _scales-gdsv.
    end.
    FIND FIRST ub.scales-gds No-LOCK WHERE
              ub.scales-gds.db-num = temp-scales-gds.db-num AND
              ub.scales-gds.scales-num = temp-scales-gds.scales-num AND
              ub.scales-gds.b-code = temp-scales-gds.b-code NO-ERROR.
    IF AVAILABLE ub.scales-gds then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Уже есть ТОВАР НА ВЕСАХ(scales-gds):" +                         " номер весов " + string(temp-scales-gds.scales-num) +                         " бар-код " + string(temp-scales-gds.b-code)) )) .              delete temp-scales-gds.                   NEXT _scales-gdsv.
    end.
    FIND FIRST ub.bar-code No-LOCK WHERE
               ub.bar-code.b-code = temp-scales-gds.b-code No-ERROR.
    IF NOT AVAIL ub.bar-code then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Не найден БАР-КОД для ТОВАРА НА ВЕСАХ(scales-gds):" +                         " номер весов " + string(temp-scales-gds.scales-num) +                         " бар-код " + string(temp-scales-gds.b-code)) )) .              delete temp-scales-gds.                   NEXT _scales-gdsv.
    END.
    FIND FIRST ub.goods No-LOCK WHERE
               ub.goods.gds-code = ub.bar-code.gds-code NO-ERROR.
    IF NOT AVAILABLE ub.goods then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Не найден ТОВАР для ТОВАРА НА ВЕСАХ(scales-gds):" +                         " номер весов " + string(temp-scales-gds.scales-num) +                         " бар-код " + string(temp-scales-gds.b-code)) )) .              delete temp-scales-gds.                   NEXT _scales-gdsv.
    END.
    FIND FIRST ub.units No-LOCK WHERE
               ub.units.unit-name = ub.goods.unit-base No-ERROR.
    IF NOT AVAIL ub.units then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Не найдена ЕДИНИЦА ИЗМЕРЕНИЯ для ТОВАРА НА ВЕСАХ(scales-gds):" +                         " номер весов " + string(temp-scales-gds.scales-num) +                         " бар-код " + string(temp-scales-gds.b-code)) )) .              delete temp-scales-gds.                   NEXT _scales-gdsv.
    END.
    if ub.units.unit-name <> scales-unit
    and ub.units.type = 'вес':U
    then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " ЕДИНИЦА ИЗМЕРЕНИЯ ТОВАРА НА ВЕСАХ(scales-gds):" +                         " номер весов " + string(temp-scales-gds.scales-num) +                         " бар-код " + string(temp-scales-gds.b-code) +                         " единица измерения товара " + ub.units.unit-name +                         " единица измерения весов " + scales-unit ) )) .              delete temp-scales-gds.                   NEXT _scales-gdsv.
    END.
    FIND FIRST ub.gds-prt No-LOCK WHERE
               ub.gds-prt.upper-code = ub.goods.prt-root NO-ERROR.
    IF NOT AVAIL(ub.gds-prt) then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Не найдена ШКАЛА ПРИЗНАКОВ(пустая шкала) для ТОВАРА НА ВЕСАХ(scales-gds):" +                         " номер весов " + string(temp-scales-gds.scales-num) +                         " бар-код " + string(temp-scales-gds.b-code)) )) .              delete temp-scales-gds.                   NEXT _scales-gdsv.
    END.
    if ub.bar-code.node-code <> ub.gds-prt.node-code OR
      ub.bar-code.in-code <> "":U OR
      ub.bar-code.part-code <> "":U OR
      ub.bar-code.unit-cli <> ub.goods.unit-base then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Бар-код не является главным бар-кодом товара для ТОВАРА НА ВЕСАХ(scales-gds):" +                         " номер весов " + string(temp-scales-gds.scales-num) +                         " бар-код " + string(temp-scales-gds.b-code)) )) .              delete temp-scales-gds.                   NEXT _scales-gdsv.
    END.
    run create-scales-gds in this-procedure (
                                              buffer ub.bar-code
                                             ,buffer ub.scales
                                             ,buffer ub.goods
                                             ,buffer temp-scales-gds
                                             ) no-error .
    if error-status:error then dO:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Ошибка при создании ТОВАРА НА ВЕСАХ(scales-gds):" +                         " номер весов " + string(temp-scales-gds.scales-num) +                         " бар-код " + string(temp-scales-gds.b-code) +                         return-value) )) .              delete temp-scales-gds.                   NEXT _scales-gdsv.
    end.
    FIND LAST scales-gds WHERE
               scales-gds.db-num = g#db-num
         AND scales-gds.scales-num = ub.scales.scales-num NO-LOCK use-index pi no-error .
    if available scales-gds and ub.scales.max-plu < ub.scales-gds.PLU-code then
    ub.scales.max-plu = scales-gds.PLU-code .
  END.
      _scales-grpv:
    FOR EACH temp-scales-grp:
    assign
    dopi = temp-scales-grp.scales-num
    .
    FIND FIRST ub.scales  NO-LOCK where
               ub.scales.db-num = g#db-num AND
               ub.scales.scales-num = dopi NO-ERROR.
    IF NOT AVAIL ub.scales then do:
      FIND FIRST temp-scales NO-LOCK WHERE
                 temp-scales.db-num = g#db-num
            AND temp-scales.scales-num = dopi No-ERROR.
      IF NOT AVAIL temp-scales then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Не найдены ВЕСЫ для ГРУППЫ ТОВАРОВ НА ВЕСАХ(scales-gds):" +                         " номер весов " + string(temp-scales-grp.scales-num) +                         " код группы " + string(temp-scales-grp.node-code)) )) .              delete temp-scales-grp.                   NEXT _scales-grpv.
      END.
    END.
    FIND FIRST ub.Scales-grp No-LOCK WHERE
              ub.scales-grp.db-num = temp-scales-grp.db-num AND
              ub.scales-grp.scales-num = temp-scales-grp.scales-num AND
              ub.scales-grp.node-code = temp-scales-grp.node-code NO-ERROR.
    IF  AVAILABLE ub.scales-grp then do:
                run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Уже есть ГРУППА ТОВАРА НА ВЕСАХ(scales-grp):" +                           " номер группы " + string(temp-scales-grp.node-code) +                           " номер весов " + string(temp-scales-grp.scales-num)) )) .              delete temp-scales-grp.                   NEXT _scales-grpv.
    end.
    dopi = 0.
    FIND FIRST ub.gds-grp No-LOCK WHERE
               ub.gds-grp.node-code = temp-scales-grp.node-code No-ERROR.
    if avail ub.gds-grp then dopi = ub.gds-grp.node-code.
    IF dopi = 0 or (CAN-find(FIRST ub.gds-grp NO-LOCK WHERE
                                   ub.gds-grp.upper-code = dopi)) then do:
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Не найдена ГРУППА ТОВАРОВ или нетерминальная для ГРУППЫ ТОВАРОВ НА ВЕСАХ(scales-grp):" +                       " номер группы " + string(temp-scales-grp.node-code) +                       " номер весов " + string(temp-scales-grp.scales-num)) )) .              delete temp-scales-grp.                   NEXT _scales-grpv.
    END.
    create ub.scales-grp.
    buffer-copy temp-scales-grp to ub.scales-grp.
    release ub.scales-grp no-error.
    if error-status:error then do:
      er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) +  " ошибка при сохранении записи ГРУППА ТОВАРОВ НА ВЕСАХ(scales-grp):" +                                       " номер группы " + string(temp-scales-grp.node-code) +                                       " номер весов " + string(temp-scales-grp.scales-num) +                                       er-mes) )) .                NEXT _scales-grpv.
    end.
  END.
end.
if p-rht then do:
   define buffer buf_action-item    for ub.action-item.
   CASE p-version:
      when "15.0":U then do:
                           _action-role:
         FOR EACH temp-action-role:
            FIND FIRST ub.action-role No-LOCK
                 WHERE ub.action-role.db-num           = temp-action-role.db-num
                   and ub.action-role.action-head-code = temp-action-role.action-head-code
                   and ub.action-role.action-role-code = temp-action-role.action-role-code
                 NO-ERROR
                 .
            IF AVAILABLE ub.action-role then do:
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Уже есть ГРУППА ПРАВ (action-role):"                                             + STRING(temp-action-role.db-num)                                             + STRING(temp-action-role.action-head-code)                                             + STRING(temp-action-role.action-role-code)                                             ) )) .              delete temp-action-role.                   NEXT _action-role.
            END.
            create ub.action-role.
            buffer-copy temp-action-role to ub.action-role.
            release ub.action-role No-error.
            if error-status:error then do:
               er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) +  " ошибка при сохранении записи ГРУППЫ ПРАВ (action-role):"                                             + STRING(temp-action-role.db-num)                                             + STRING(temp-action-role.action-head-code)                                             + STRING(temp-action-role.action-role-code)                                             ) )) .                NEXT _action-role.
            end.
         END.
         run adm/restseqr.p
           ( input "rest":U
           , input "s-action-role":U
           , input no
           ) no-error .
         if error-status :error then do:
           return error return-value .
         end.
                           _action-role-item:
         FOR EACH temp-action-role-item:
            FIND FIRST ub.action-role-item No-LOCK
                 WHERE ub.action-role-item.db-num           = temp-action-role-item.db-num
                   and ub.action-role-item.action-head-code = temp-action-role-item.action-head-code
                   and ub.action-role-item.action-role-code = temp-action-role-item.action-role-code
                   and ub.action-role-item.action-item-id = temp-action-role-item.action-item-id
                 NO-ERROR
                 .
            IF AVAILABLE ub.action-role-item then do:
                           run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) + " Уже есть привязка к ГРУППЕ ПРАВ (action-role-item):"                                             + STRING(temp-action-role-item.db-num)                                             + STRING(temp-action-role-item.action-head-code)                                             + STRING(temp-action-role-item.action-role-code)                                             + STRING(temp-action-role-item.action-role-item-code)                                             ) )) .              delete temp-action-role-item.                   NEXT _action-role-item.
             END.
          create ub.action-role-item.
          assign
            ub.action-role-item.action-head-code = temp-action-role-item.action-head-code
            ub.action-role-item.action-item-id   = temp-action-role-item.action-item-id
            ub.action-role-item.action-role-code = temp-action-role-item.action-role-code
            ub.action-role-item.action-role-item-code = dynamic-next-value("s-action-role-item":U, "ub":U)
            ub.action-role-item.db-num          = temp-action-role-item.db-num
            ub.action-role-item.whole-send-news = temp-action-role-item.whole-send-news
          .
          find first ub.action-item
            where ub.action-item.action-head-code = ub.action-role-item.action-head-code
            and ub.action-item.action-item-id  = ub.action-role-item.action-item-id
            no-lock
            no-error
            .
          if available ub.action-item then
          do:
            assign
              ub.action-role-item.action-item-code = ub.action-item.action-item-code
              .
          end.
          release ub.action-role-item No-error.
          if error-status:error then
          do:
            er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ВЕСЫ" + chr(10) +  " ошибка при сохранении привязки к ГРУППЕ ПРАВ (action-role-item):"                                             + STRING(temp-action-role-item.db-num)                                             + STRING(temp-action-role-item.action-head-code)                                             + STRING(temp-action-role-item.action-role-code)                                             + STRING(temp-action-role-item.action-role-item-code)                                             ) )) .                NEXT _action-role-item.
            end.
         END.
         run adm/restseqr.p
           ( input "rest":U
           , input "s-action-role-item":U
           , input no
           ) no-error .
         if error-status :error then do:
           return error return-value .
         end.
      end.
      otherwise do:
         define variable v-global-action-role-code     as integer   no-undo .
         define variable v-firm-action-role-code       as integer   no-undo .
         define variable v-object-action-role-code     as integer   no-undo .
         define variable v-action-role-code            as integer   no-undo .
         define variable v-action-role-item-code       as integer   no-undo .
         define buffer buf_action-role       for ub.action-role .
         define buffer buf_action-role-item  for ub.action-role-item .
         run p-right-i in this-procedure .
         _gpr:
         for each temp-grpa no-lock
         on error undo, return error return-value
         :
            assign
               v-global-action-role-code = 0
               v-firm-action-role-code   = 0
               v-object-action-role-code = 0
            .
            for each temp-grp-acta no-lock
               where temp-grp-acta.grp-name = temp-grpa.grp-name
               and temp-grp-acta.arm-code = temp-grpa.arm-code
            on error undo, return error return-value
            :
               find first temp-action-item
               where temp-action-item.grp-acta-arm-code = temp-grp-acta.arm-code
                  and temp-action-item.grp-acta-object   = temp-grp-acta.object
                  and temp-action-item.grp-acta-act      = temp-grp-acta.act
               no-error .
               if not available temp-action-item
               then do:
               end.
               else do:
               case temp-action-item.action-context
               :
                  when 'global':U
                  then do:
                     if v-global-action-role-code = 0
                     then do:
                        IF NOT CAN-FIND ( FIRST buf_action-role
                                          WHERE buf_action-role.db-num            = g#db-num
                                          and buf_action-role.action-head-code    = 0
                                          and buf_action-role.action-role-context = 'global':U
                                          and buf_action-role.action-role-name    = temp-grpa.arm-code + ' ':U + temp-grpa.grp-name
                                       )
                        THEN DO:
                           assign
                              v-action-role-code = dynamic-next-value("s-action-role":U, "ub":U)
                           .
                           create buf_action-role .
                           assign
                              buf_action-role.db-num              = g#db-num
                              buf_action-role.action-head-code    = 0
                              buf_action-role.action-role-code    = v-action-role-code
                              buf_action-role.action-role-context = temp-action-item.action-context
                              buf_action-role.action-role-name    = temp-grpa.arm-code + ' ':U + temp-grpa.grp-name
                           .
                           assign
                              v-global-action-role-code = v-action-role-code
                           .
                        END.
                     end.
                     IF NOT CAN-FIND ( FIRST buf_action-role-item
                                       WHERE buf_action-role-item.db-num              = g#db-num
                                         and buf_action-role-item.action-head-code    = 0
                                         and buf_action-role-item.action-role-code    = v-global-action-role-code
                                         and buf_action-role-item.action-item-id      = temp-action-item.action-item-id
                                     )
                     THEN DO:
                        assign
                           v-action-role-item-code = dynamic-next-value("s-action-role-item":U, "ub":U)
                        .
                        create buf_action-role-item .
                        assign
                           buf_action-role-item.db-num                = g#db-num
                           buf_action-role-item.action-head-code      = 0
                           buf_action-role-item.action-role-code      = v-global-action-role-code
                           buf_action-role-item.action-role-item-code = v-action-role-item-code
                           buf_action-role-item.action-item-id        = temp-action-item.action-item-id
                        .
                        find first buf_action-item
                           where buf_action-item.action-head-code = buf_action-role-item.action-head-code
                              and buf_action-item.action-item-id  = buf_action-role-item.action-item-id
                           no-lock
                           no-error
                           .
                        if available buf_action-item then do:
                           assign
                              buf_action-role-item.action-item-code = buf_action-item.action-item-code
                           .
                        end.
                     end.
                  end.
                  when 'firm':U
                  then do:
                     if v-firm-action-role-code = 0
                     then do:
                        assign
                           v-action-role-code = dynamic-next-value("s-action-role":U, "ub":U)
                        .
                        create buf_action-role .
                        assign
                           buf_action-role.db-num              = g#db-num
                           buf_action-role.action-head-code    = 0
                           buf_action-role.action-role-code    = v-action-role-code
                           buf_action-role.action-role-context = temp-action-item.action-context
                           buf_action-role.action-role-name    = temp-grpa.arm-code + ' ':U + temp-grpa.grp-name
                        .
                        assign
                           v-firm-action-role-code = v-action-role-code
                        .
                        end.
                        assign
                           v-action-role-item-code = dynamic-next-value("s-action-role-item":U, "ub":U)
                        .
                        create buf_action-role-item .
                        assign
                           buf_action-role-item.db-num                = g#db-num
                           buf_action-role-item.action-head-code      = 0
                           buf_action-role-item.action-role-code      = v-firm-action-role-code
                           buf_action-role-item.action-role-item-code = v-action-role-item-code
                           buf_action-role-item.action-item-id        = temp-action-item.action-item-id
                        .
                        find first buf_action-item
                           where buf_action-item.action-head-code = buf_action-role-item.action-head-code
                              and buf_action-item.action-item-id  = buf_action-role-item.action-item-id
                           no-lock
                           no-error
                           .
                        if available buf_action-item then do:
                           assign
                              buf_action-role-item.action-item-code = buf_action-item.action-item-code
                           .
                        end.
                  end.
                  when 'object':U
                  then do:
                     if v-object-action-role-code = 0
                     then do:
                        assign
                           v-action-role-code = dynamic-next-value("s-action-role":U, "ub":U)
                        .
                        create buf_action-role .
                        assign
                           buf_action-role.db-num              = g#db-num
                           buf_action-role.action-head-code    = 0
                           buf_action-role.action-role-code    = v-action-role-code
                           buf_action-role.action-role-context = temp-action-item.action-context
                           buf_action-role.action-role-name    = temp-grpa.arm-code + ' ':U + temp-grpa.grp-name
                        .
                        assign
                           v-object-action-role-code = v-action-role-code
                        .
                        end.
                        assign
                           v-action-role-item-code = dynamic-next-value("s-action-role-item":U, "ub":U)
                        .
                        create buf_action-role-item .
                        assign
                           buf_action-role-item.db-num                = g#db-num
                           buf_action-role-item.action-head-code      = 0
                           buf_action-role-item.action-role-code      = v-object-action-role-code
                           buf_action-role-item.action-role-item-code = v-action-role-item-code
                           buf_action-role-item.action-item-id        = temp-action-item.action-item-id
                        .
                        find first buf_action-item
                           where buf_action-item.action-head-code = buf_action-role-item.action-head-code
                              and buf_action-item.action-item-id  = buf_action-role-item.action-item-id
                           no-lock
                           no-error
                           .
                        if available buf_action-item then do:
                           assign
                              buf_action-role-item.action-item-code = buf_action-item.action-item-code
                           .
                        end.
                  end.
                  otherwise do:
                  end.
               end.
               end.
            end.
         end.
      end.
   END CASE.
end.
if p-usr then do:
   define buffer buf__user          for ub._user.
   define buffer buf_user-account   for ub.user-account.
   define buffer buf_menu-group     for ub.menu-group.
   define buffer buf_clients        for ub.clients.
   define buffer buf_user-login     for ub.user-login.
   define buffer buf_user-context-history    for ubflt.user-context-history.
   define buffer buf_user-login-action-role  for ub.user-login-action-role.
   define buffer buf_user-menu-group      for ub.user-menu-group.
   define buffer buf_user-host      for ub.user-host.
   define buffer buf_user-obj       for ub.user-obj.
        run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Проверка группы данных ПОЛЬЗОВАТЕЛИ" ) ).
   define variable v-ok                          as logical   no-undo .
   define variable v-user-id                     as character no-undo .
   define variable v-user-login                  as character no-undo .
   define variable v-last-name                   as character no-undo .
   define variable v-user-password-encoded       as character no-undo .
   define variable v-cntxt-menu-group-id         as character no-undo .
   define variable v-cntxt-level                 as character no-undo .
   define variable v-cntxt-host-code-obj         as integer   no-undo .
   define variable v-cntxt-obj-type              as character no-undo .
   define variable v-cntxt-obj-code              as integer   no-undo .
   define variable v-arm-code-list               as character no-undo .
   define variable v-arm-code-lookup-index       as integer   no-undo .
   define variable v-menu-group-id-list          as character no-undo .
   define variable v-menu-group-id               as character no-undo .
   define variable v-user-login-role-code        as integer   no-undo .
   define variable v-obj-name                    as character no-undo .
   define variable v-user-menu-group-code        as integer   no-undo .
   CASE p-version:
      when "15.0" then do:
                           _user-account:
         FOR EACH temp-user-account:
            FIND FIRST ub.user-account No-LOCK
                 WHERE ub.user-account.user-id = temp-user-account.user-id
                 NO-ERROR
                 .
            IF AVAILABLE ub.user-account then do:
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) + " Уже есть ПОЛЬЗОВАТЕЛЬ(user-account):" + temp-user-account.user-id) )) .              delete temp-user-account.                   NEXT _user-account.
            END.
            create ub.user-account.
            buffer-copy temp-user-account to ub.user-account.
            release ub.user-account No-error.
            if error-status:error then do:
               er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) +  " ошибка при сохранении записи ПОЛЬЗОВАТЕЛЯ(user-account): " + temp-user-account.user-id + " " + er-mes) )) .                NEXT _user-account.
            end.
         END.
         run adm/restseqr.p
           ( input "rest":U
           , input "s-user-id":U
           , input no
           ) no-error .
         if error-status :error then do:
           return error return-value .
         end.
                           _user-login:
         FOR EACH temp-user-login:
            FIND FIRST ub.user-login No-LOCK
                 WHERE ub.user-login.user-id = temp-user-login.user-id
                   AND ub.user-login.db-num  = temp-user-login.db-num
                 NO-ERROR
                 .
            IF AVAILABLE ub.user-login then do:
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) + " Уже есть логин ПОЛЬЗОВАТЕЛЯ(user-login): "                                             + temp-user-login.user-id                                             + "БД:" + string(temp-user-login.db-num)                                             ) )) .              delete temp-user-login.                   NEXT _user-login.
            END.
            FIND FIRST ub.user-account No-LOCK
                 WHERE ub.user-account.user-id = temp-user-login.user-id
                 NO-ERROR
                 .
            IF NOT AVAILABLE ub.user-account then do:
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) + " Не найден ПОЛЬЗОВАТЕЛЬ(user-account):" + temp-user-login.user-id) )) .              delete temp-user-login.                   NEXT _user-login.
            END.
            create ub.user-login.
            buffer-copy temp-user-login to ub.user-login.
            release ub.user-login No-error.
            if error-status:error then do:
               er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) +  " ошибка при сохранении догина ПОЛЬЗОВАТЕЛЯ(user-login): " + temp-user-login.user-id + "БД:" + string(temp-user-login.db-num) + " " + er-mes) )) .                NEXT _user-login.
            end.
         END.
                           _user-obj:
         FOR EACH temp-user-obj:
            FIND FIRST ub.user-obj No-LOCK
                 WHERE ub.user-obj.user-id  = temp-user-obj.user-id
                   AND ub.user-obj.db-num   = temp-user-obj.db-num
                   AND ub.user-obj.obj-type = temp-user-obj.obj-type
                   AND ub.user-obj.obj-code = temp-user-obj.obj-code
                 NO-ERROR
                 .
            IF AVAILABLE ub.user-obj then do:
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) + " Уже есть объект ПОЛЬЗОВАТЕЛЯ(user-obj): "                                             + temp-user-obj.user-id                                             + "БД:" + string(temp-user-obj.db-num) + " "                                             + temp-user-obj.obj-type + ","                                             + STRING(temp-user-obj.obj-code)                                                   ) )) .              delete temp-user-obj.                   NEXT _user-obj.
            END.
            FIND FIRST ub.user-login No-LOCK
                 WHERE ub.user-login.user-id = temp-user-obj.user-id
                   AND ub.user-login.db-num  = temp-user-obj.db-num
                 NO-ERROR
                 .
            IF NOT AVAILABLE ub.user-login then do:
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) + " Не найден логин ПОЛЬЗОВАТЕЛЬ(user-obj):" + temp-user-obj.user-id + "БД:" + string(temp-user-obj.db-num)) )) .              delete temp-user-obj.                   NEXT _user-obj.
            END.
            if not can-find(first ub.clients no-lock where
                                  ub.clients.obj-type = temp-user-obj.obj-type
                              and ub.clients.obj-code = temp-user-obj.obj-code) then do:
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) + " Не найден объект ПОЛЬЗОВАТЕЛЬ(user-obj):" + temp-user-obj.user-id + "БД:" + string(temp-user-obj.db-num)) )) .              delete temp-user-obj.                   NEXT _user-obj.
            end.
            create ub.user-obj.
            buffer-copy temp-user-obj to ub.user-obj.
            release ub.user-obj No-error.
            if error-status:error then do:
               er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) +  " ошибка при сохранении объекта ПОЛЬЗОВАТЕЛЯ(user-obj): "                                            + temp-user-obj.user-id                                             + "БД:" + string(temp-user-obj.db-num) + " "                                             + temp-user-obj.obj-type + ","                                             + STRING(temp-user-obj.obj-code)                                                   ) )) .                NEXT _user-obj.
            end.
         END.
                           _user-host:
         FOR EACH temp-user-host:
            FIND FIRST ub.user-host No-LOCK
                 WHERE ub.user-host.user-id  = temp-user-host.user-id
                   AND ub.user-host.db-num   = temp-user-host.db-num
                   AND ub.user-host.host-code = temp-user-host.host-code
                 NO-ERROR
                 .
            IF AVAILABLE ub.user-host then do:
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) + " Уже есть фирма ПОЛЬЗОВАТЕЛЯ(user-host): "                                             + temp-user-host.user-id                                             + "БД:" + string(temp-user-host.db-num) + " "                                             + STRING(temp-user-host.host-code)                                                   ) )) .              delete temp-user-host.                   NEXT _user-host.
            END.
            FIND FIRST ub.user-login No-LOCK
                 WHERE ub.user-login.user-id = temp-user-host.user-id
                   AND ub.user-login.db-num  = temp-user-host.db-num
                 NO-ERROR
                 .
            IF NOT AVAILABLE ub.user-login then do:
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) + " Не найден логин ПОЛЬЗОВАТЕЛЬ(user-host):" + temp-user-host.user-id + "БД:" + string(temp-user-host.db-num)) )) .              delete temp-user-host.                   NEXT _user-host.
            END.
            if not can-find(first ub.sysconf no-lock where
                                  ub.sysconf.host-code = temp-user-host.host-code
                              ) then do:
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) + " Не найдена фирма ПОЛЬЗОВАТЕЛЬ(user-host):" + temp-user-obj.user-id + "БД:" + string(temp-user-obj.db-num)) )) .              delete temp-user-host.                   NEXT _user-host.
            end.
            create ub.user-host.
            buffer-copy temp-user-host to ub.user-host.
            release ub.user-host No-error.
            if error-status:error then do:
               er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) +  " ошибка при сохранении фирмы ПОЛЬЗОВАТЕЛЯ(user-host): "                                             + temp-user-host.user-id                                             + "БД:" + string(temp-user-host.db-num) + " "                                             + STRING(temp-user-host.host-code)                                                   + " " + er-mes) )) .                NEXT _user-host.
            end.
         END.
                           _user-menu-group:
         FOR EACH temp-user-menu-group:
            FIND FIRST ub.user-menu-group No-LOCK
                 WHERE ub.user-menu-group.user-id  = temp-user-menu-group.user-id
                   AND ub.user-menu-group.db-num   = temp-user-menu-group.db-num
                   AND ub.user-menu-group.user-menu-group-code = temp-user-menu-group.user-menu-group-code
                 NO-ERROR
                 .
            IF AVAILABLE ub.user-menu-group then do:
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) + " Уже есть группа меню ПОЛЬЗОВАТЕЛЯ(user-menu-group): "                                             + temp-user-menu-group.user-id                                             + "БД:" + string(temp-user-menu-group.db-num) + " "                                             + STRING(temp-user-menu-group.user-menu-group-code)                                                   ) )) .              delete temp-user-menu-group.                   NEXT _user-menu-group.
            END.
            FIND FIRST ub.user-login No-LOCK
                 WHERE ub.user-login.user-id = temp-user-menu-group.user-id
                   AND ub.user-login.db-num  = temp-user-menu-group.db-num
                 NO-ERROR
                 .
            IF NOT AVAILABLE ub.user-login then do:
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) + " Не найден логин ПОЛЬЗОВАТЕЛЬ(user-menu-group):" + temp-user-menu-group.user-id + "БД:" + string(temp-user-menu-group.db-num)) )) .              delete temp-user-menu-group.                   NEXT _user-menu-group.
            END.
            if not can-find(first ub.sysconf no-lock where
                                  ub.sysconf.host-code = temp-user-menu-group.host-code
                              ) then do:
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) + " Не найдена фирма ПОЛЬЗОВАТЕЛЬ(user-menu-group):" + temp-user-menu-group.user-id + "БД:" + string(temp-user-menu-group.db-num)) )) .              delete temp-user-menu-group.                   NEXT _user-menu-group.
            end.
            if not can-find(first ub.clients no-lock where
                                  ub.clients.obj-type = temp-user-menu-group.obj-type
                              and ub.clients.obj-code = temp-user-menu-group.obj-code) then do:
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) + " Не найден объект ПОЛЬЗОВАТЕЛЬ(user-menu-group):" + temp-user-menu-group.user-id + "БД:" + string(temp-user-menu-group.db-num)) )) .              delete temp-user-menu-group.                   NEXT _user-menu-group.
            end.
            create ub.user-menu-group.
            buffer-copy temp-user-menu-group to ub.user-menu-group.
            release ub.user-menu-group No-error.
            if error-status:error then do:
               er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) +  " ошибка при сохранении группы меню ПОЛЬЗОВАТЕЛЯ(user-menu-group): "                                             + temp-user-menu-group.user-id                                             + "БД:" + string(temp-user-menu-group.db-num) + " "                                             + STRING(temp-user-menu-group.user-menu-group-code)                                                   + " " + er-mes) )) .                NEXT _user-menu-group.
            end.
         END.
                           _user-login-action-role:
         FOR EACH temp-user-login-action-role:
            FIND FIRST ub.user-login-action-role No-LOCK
                 WHERE
                   ub.user-login-action-role.db-num   = temp-user-login-action-role.db-num
                   AND ub.user-login-action-role.user-login-role-code = temp-user-login-action-role.user-login-role-code
                   AND ub.user-login-action-role.action-head-code   =   temp-user-login-action-role.action-head-code
                 NO-ERROR
                 .
            IF AVAILABLE ub.user-login-action-role then do:
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) + " Уже есть группа прав ПОЛЬЗОВАТЕЛЯ(user-login-action-role): "                                             + temp-user-login-action-role.user-id                                             + "БД:" + string(temp-user-login-action-role.db-num) + " "                                             + STRING(temp-user-login-action-role.user-login-role-code)                                                   ) )) .              delete temp-user-login-action-role.                   NEXT _user-login-action-role.
            END.
            FIND FIRST ub.user-login No-LOCK
                 WHERE ub.user-login.user-id = temp-user-login-action-role.user-id
                   AND ub.user-login.db-num  = temp-user-login-action-role.db-num
                 NO-ERROR
                 .
            IF NOT AVAILABLE ub.user-login then do:
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) + " Не найден логин ПОЛЬЗОВАТЕЛЬ(user-login):" + temp-user-login-action-role.user-id + "БД:" + string(temp-user-login-action-role.db-num)) )) .              delete temp-user-login-action-role.                   NEXT _user-login-action-role.
            END.
            create ub.user-login-action-role.
            buffer-copy temp-user-login-action-role to ub.user-login-action-role.
            release ub.user-login-action-role no-error.
            if error-status:error then do:
               er-mes = "".       do jj = 1 to error-status:num-messages:         er-mes = er-mes + chr(10) + error-status:get-message(JJ).       end.
                              run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных ПОЛЬЗОВАТЕЛИ" + chr(10) +  " ошибка при сохранении группы прав ПОЛЬЗОВАТЕЛЯ(user-login-action-role): "                                             + temp-user-login-action-role.user-id                                             + "БД:" + string(temp-user-login-action-role.db-num) + " "                                             + STRING(temp-user-login-action-role.user-login-role-code)                                             + " " + er-mes ) )) .                NEXT _user-login-action-role.
            end.
         END.
         run adm/restseqr.p
           ( input "rest":U
           , input "s-user-login-action-role":U
           , input no
           ) no-error .
         if error-status :error then do:
           return error return-value .
         end.
      end.
      otherwise do:
         if "rus" = "rus":U
         then do:
            assign
               v-arm-code-list = 'офи':U
               + chr(44) + 'скл':U
               + chr(44) + 'маг':U
               + chr(44) + 'рес':U
               + chr(44) + 'фин':U
               + chr(44) + 'бгх':U
               + chr(44) + 'бух':U
               + chr(44) + 'осн':U
               + chr(44) + 'адм':U
               v-obj-name      = 'объ':U
               .
         end.
         else do:
            assign
               v-arm-code-list = 'off':U
               + chr(44) + 'str':U
               + chr(44) + 'shp':U
               + chr(44) + 'res':U
               + chr(44) + 'fin':U
               + chr(44) + 'eac':U
               + chr(44) + 'acc':U
               + chr(44) + 'fas':U
               + chr(44) + 'adm':U
               v-obj-name      = 'object':U
            .
         end.
         assign
            v-menu-group-id-list = 'off,str,shp,res,fin,bge,buh,fas,adm':U
         .
                           _userconf:
         FOR EACH temp-userconf:
            find first buf__user
               where buf__user._userid = temp-userconf.user-name
               no-error .
            if available buf__user
            then do:
               assign
               v-user-login            = buf__user._userid
               v-last-name             = buf__user._user-name
               v-user-password-encoded = buf__user._password
               .
            end.
            else do:
               assign
               v-user-login            = temp-userconf.userid_
               v-last-name             = temp-userconf.user-name_
               v-user-password-encoded = temp-userconf.password_
               .
            end.
            assign
               v-user-id = substitute('&1-&2':U
                                    ,g#db-num
                                    ,dynamic-next-value("s-user-id":U, "ub":U)
                                    )
            .
            create buf_user-account .
            assign
               buf_user-account.user-id               = v-user-id
               buf_user-account.status_               = 0
               buf_user-account.first-name            = '':U
               buf_user-account.second-name           = '':U
               buf_user-account.last-name             = v-last-name
               buf_user-account.company               = '':U
               buf_user-account.department            = '':U
               buf_user-account.e-mail                = '':U
               buf_user-account.internal-phone-number = '':U
               buf_user-account.mobile-phone-number   = '':U
               buf_user-account.phone-number          = '':U
               buf_user-account.position              = '':U
               buf_user-account.PS                    = '':U
               buf_user-account.room                  = '':U
               buf_user-account.parent-user-id        = '':U
               buf_user-account.check-parent          = false
            .
            assign
               v-cntxt-menu-group-id        = '':U
               v-cntxt-level                = 'global':U
               v-cntxt-host-code-obj        = ?
               v-cntxt-obj-type             = '':U
               v-cntxt-obj-code             = ?
            .
            assign
               v-arm-code-lookup-index = lookup(temp-userconf.ARM, v-arm-code-list)
            .
            if v-arm-code-lookup-index > 0
            then do:
               assign
               v-menu-group-id = entry(v-arm-code-lookup-index
                                       ,v-menu-group-id-list
                                       ,chr(44)
                                       )
               .
               find first buf_menu-group
                    where buf_menu-group.menu-code     = 0
                      and buf_menu-group.menu-group-id = v-menu-group-id
                    no-lock
                    no-error
                    .
               if available buf_menu-group
               then do:
               assign
                  v-cntxt-menu-group-id = buf_menu-group.menu-group-id
               .
               end.
            end.
            find first buf_clients
                 where buf_clients.obj-type = temp-userconf.obj-type
                   and buf_clients.obj-code = temp-userconf.obj-code
                 no-lock
                 no-error
                 .
            if available buf_clients
            then do:
               assign
               v-cntxt-level         = 'object':U
               v-cntxt-host-code-obj = buf_clients.host-code
               v-cntxt-obj-type      = buf_clients.obj-type
               v-cntxt-obj-code      = buf_clients.obj-code
               .
            end.
            else do:
               find first buf_clients
                    where buf_clients.obj-type = 'орг':U
                      and buf_clients.obj-code = temp-userconf.arm-host-code
                    no-lock
                    no-error
                    .
               if available buf_clients
               then do:
               assign
                  v-cntxt-level         = 'firm':U
                  v-cntxt-host-code-obj = buf_clients.host-code
                  v-cntxt-obj-type      = buf_clients.obj-type
                  v-cntxt-obj-code      = buf_clients.obj-code
               .
               end.
            end.
            IF NOT CAN-FIND (FIRST ub.user-login
                             where ub.user-login.db-num  = g#db-num
                               and ub.user-login.user-id = v-user-id  )
            then do:
               IF CAN-FIND (FIRST ub.user-login
                            where ub.user-login.db-num  = g#db-num
                              and ub.user-login.user-login = v-user-login)
               THEN DO:
                  message
                     "В системе уже есть пользователь с логином" v-user-login
                     skip
                  view-as alert-box information.
               END.
               ELSE DO:
                  create ub.user-login .
                  assign
                     ub.user-login.db-num                     = g#db-num
                     ub.user-login.user-id                    = v-user-id
                     ub.user-login.last-login-computer-name   = '':U
                     ub.user-login.last-login-computer-userid = '':U
                     ub.user-login.last-login-mjd             = 0.0
                     ub.user-login.last-login-process-id      = 0
                     ub.user-login.login-error-count          = 0
                     ub.user-login.max-discnt                 = temp-userconf.max-discnt
                     ub.user-login.quest-print                = temp-userconf.quest-print
                     ub.user-login.status_                    = 0
                     ub.user-login.user-administrator         = (if v-user-login = 'адм':U
                                                                  then true
                                                                  else false
                                                               )
                     ub.user-login.user-login                 = v-user-login
                     ub.user-login.user-password-encoded      = v-user-password-encoded
                  .
               END.
            end.
            create buf_user-context-history .
            assign
               buf_user-context-history.db-num                  = g#db-num
               buf_user-context-history.user-id                 = v-user-id
               buf_user-context-history.user-context-history-id = 1
               buf_user-context-history.cntxt-menu-code         = 0
               buf_user-context-history.cntxt-menu-group-id     = v-cntxt-menu-group-id
               buf_user-context-history.cntxt-level             = v-cntxt-level
               buf_user-context-history.cntxt-host-code         = v-cntxt-host-code-obj
               buf_user-context-history.cntxt-obj-type          = v-cntxt-obj-type
               buf_user-context-history.cntxt-obj-code          = v-cntxt-obj-code
               buf_user-context-history.cntxt-change-mjd        = 0
            .
         END.
         _user-login:
         for each buf_user-login no-lock
         on error undo, return error return-value
         :
            _usr-grpa:
            for each  temp-usr-grpa no-lock
                where temp-usr-grpa.user-name = buf_user-login.user-login
            on error undo, return error return-value
            :
               IF lookup( temp-usr-grpa.arm-code, v-arm-code-list) > 0 then do:
               assign
                  v-menu-group-id = entry( lookup( temp-usr-grpa.arm-code, v-arm-code-list), v-menu-group-id-list)
               .
               end.
               else do:
                  next _usr-grpa.
               end.
               FIND FIRST buf_menu-group
                    where buf_menu-group.menu-code     = 0
                      AND buf_menu-group.menu-group-id = v-menu-group-id
                    no-lock
                    no-error
                    .
               IF NOT AVAILABLE buf_menu-group
               THEN DO:
                  next _usr-grpa.
               END.
               find first buf_user-menu-group
               where buf_user-menu-group.db-num          = g#db-num
                  and buf_user-menu-group.user-id         = buf_user-login.user-id
                  and buf_user-menu-group.menu-code       = 0
                  and buf_user-menu-group.menu-group-code = buf_menu-group.menu-group-code
                  and buf_user-menu-group.menu-group-context = 'firm':U
                  and buf_user-menu-group.host-code       = temp-usr-grpa.host-code
                  and buf_user-menu-group.obj-type        = "":U
                  and buf_user-menu-group.obj-code        = 0
                  and buf_user-menu-group.menu-group-id   = v-menu-group-id
               no-error .
               if not available buf_user-menu-group then do:
                  ASSIGN
                     v-user-menu-group-code = next-value(s-user-menu-group, ub)
                  .
                  create buf_user-menu-group.
                  assign
                     buf_user-menu-group.db-num        = g#db-num
                     buf_user-menu-group.user-id       = buf_user-login.user-id
                     buf_user-menu-group.menu-code     = 0
                     buf_user-menu-group.menu-group-code = buf_menu-group.menu-group-code
                     buf_user-menu-group.menu-group-id = v-menu-group-id
                     buf_user-menu-group.menu-group-context       = 'firm':U
                     buf_user-menu-group.user-menu-group-code      = v-user-menu-group-code
                     buf_user-menu-group.host-code     = temp-usr-grpa.host-code
                     buf_user-menu-group.obj-type      = "":U
                     buf_user-menu-group.obj-code      = 0
                  .
                  for each temp-usr-grpo no-lock
                     where temp-usr-grpo.user-name = buf_user-login.user-login
                  on error undo, return error return-value
                  :
                     find first buf_clients no-lock
                        where buf_clients.obj-type   = temp-usr-grpo.obj-type
                           and buf_clients.obj-code  = temp-usr-grpo.obj-code
                           and buf_clients.host-code = temp-usr-grpa.host-code
                        no-error .
                     find first buf_user-menu-group
                        where buf_user-menu-group.db-num          = g#db-num
                           and buf_user-menu-group.user-id         = buf_user-login.user-id
                           and buf_user-menu-group.menu-code       = 0
                           and buf_user-menu-group.menu-group-code = buf_menu-group.menu-group-code
                           and buf_user-menu-group.menu-group-context = 'object':U
                           and buf_user-menu-group.host-code       = temp-usr-grpa.host-code
                           and buf_user-menu-group.obj-type        = temp-usr-grpo.obj-type
                           and buf_user-menu-group.obj-code        = temp-usr-grpo.obj-code
                           and buf_user-menu-group.menu-group-id   = v-menu-group-id
                        no-error .
                     if  available buf_clients
                     and not available buf_user-menu-group
                     then DO:
                        ASSIGN
                           v-user-menu-group-code = next-value(s-user-menu-group, ub)
                        .
                        create buf_user-menu-group.
                        assign
                           buf_user-menu-group.db-num        = g#db-num
                           buf_user-menu-group.user-id       = buf_user-login.user-id
                           buf_user-menu-group.menu-code     = 0
                           buf_user-menu-group.menu-group-id = v-menu-group-id
                           buf_user-menu-group.menu-group-code = buf_menu-group.menu-group-code
                           buf_user-menu-group.menu-group-context       = 'object':U
                           buf_user-menu-group.user-menu-group-code     = v-user-menu-group-code
                           buf_user-menu-group.host-code     = buf_clients.host-code
                           buf_user-menu-group.obj-type      = buf_clients.obj-type
                           buf_user-menu-group.obj-code      = buf_clients.obj-code
                        .
                     end.
                  END.
               end.
               find first buf_user-host
               where buf_user-host.db-num    = g#db-num
                  and buf_user-host.user-id   = buf_user-login.user-id
                  and buf_user-host.host-code = temp-usr-grpa.host-code
               no-error .
               if not available buf_user-host
               then do:
                  find first buf_clients no-lock
                     where buf_clients.obj-type = 'орг':U
                        and buf_clients.obj-code = temp-usr-grpa.host-code
                     no-error .
                  if not available buf_clients
                  then do:
                     next _usr-grpa.
                  end.
                  else DO:
                     create buf_user-host .
                     assign
                        buf_user-host.db-num    = g#db-num
                        buf_user-host.user-id   = buf_user-login.user-id
                        buf_user-host.host-code = temp-usr-grpa.host-code
                     .
                  end.
               end.
            end.
            _usr-grpo:
            for each temp-usr-grpo no-lock
               where temp-usr-grpo.user-name = buf_user-login.user-login
            on error undo, return error return-value
            :
               find first buf_user-obj
               where buf_user-obj.db-num    = g#db-num
                  and buf_user-obj.user-id   = buf_user-login.user-id
                  and buf_user-obj.obj-type  = temp-usr-grpo.obj-type
                  and buf_user-obj.obj-code  = temp-usr-grpo.obj-code
               no-error .
               if not available buf_user-obj
               then do:
               find first buf_clients no-lock
                  where buf_clients.obj-type = temp-usr-grpo.obj-type
                     and buf_clients.obj-code = temp-usr-grpo.obj-code
                  no-error .
               if not available buf_clients
               then do:
                  next _usr-grpo.
               end.
               else do:
                     create buf_user-obj .
                     assign
                        buf_user-obj.db-num    = g#db-num
                        buf_user-obj.user-id   = buf_user-login.user-id
                        buf_user-obj.obj-type  = temp-usr-grpo.obj-type
                        buf_user-obj.obj-code  = temp-usr-grpo.obj-code
                        buf_user-obj.host-code = buf_clients.host-code
                     .
                     find first buf_user-host
                        where buf_user-host.db-num    = g#db-num
                           and buf_user-host.user-id   = buf_user-login.user-id
                           and buf_user-host.host-code = buf_clients.host-code
                     no-error .
                     if not available buf_user-host
                     then do:
                        find first buf_clients no-lock
                           where buf_clients.obj-type = 'орг':U
                              and buf_clients.obj-code = buf_user-obj.host-code
                           no-error .
                        if not available buf_clients
                        then do:
                           next _usr-grpo.
                        end.
                        ELSE DO:
                        create buf_user-host .
                           assign
                              buf_user-host.db-num    = g#db-num
                              buf_user-host.user-id   = buf_user-login.user-id
                              buf_user-host.host-code = buf_user-obj.host-code
                           .
                        end.
                     end.
               end.
               end.
            end.
         end.
                           _temp-grpa:
         for each temp-grpa no-lock
         on error undo, return error return-value
         :
            FIND FIRST buf_action-role
                 WHERE buf_action-role.db-num              = g#db-num
                   and buf_action-role.action-head-code    = 0
                   and buf_action-role.action-role-name    = temp-grpa.arm-code + ' ':U + temp-grpa.grp-name
                 no-lock
                 no-error
                 .
            IF NOT AVAILABLE buf_action-role then do:
               next _temp-grpa.
            end.
            assign
               v-object-action-role-code = 0
               v-global-action-role-code = 0
               v-firm-action-role-code   = 0
            .
            case buf_action-role.action-role-context:
               when 'object':U then do:
                  assign
                     v-object-action-role-code = buf_action-role.action-role-code
                  .
               end.
               when 'firm':U then do:
                  assign
                     v-firm-action-role-code = buf_action-role.action-role-code
                  .
               end.
               when 'global':U then do:
                  assign
                     v-global-action-role-code = buf_action-role.action-role-code
                  .
               end.
               otherwise DO:
                  next _temp-grpa.
               end.
             end case.
            if temp-grpa.arm-code = v-obj-name
            then do:
               _temp-grpo:
               for each temp-usr-grpo
                   no-lock
                   where temp-usr-grpo.grp-name = temp-grpa.grp-name
               on error undo, return error return-value
               :
                  find first buf_user-login
                       where buf_user-login.db-num     = g#db-num
                         and buf_user-login.user-login = temp-usr-grpo.user-name
                       no-lock
                       no-error
                       .
                  if not available buf_user-login
                  then do:
                                                next _temp-grpo.
                  end.
                  else do:
                     find first buf_clients
                          where buf_clients.obj-type = temp-usr-grpo.obj-type
                            and buf_clients.obj-code = temp-usr-grpo.obj-code
                          no-lock
                          no-error
                          .
                     if not available buf_clients
                     then do:
                                                next _temp-grpo.
                     end.
                     else do:
                        if v-global-action-role-code <> 0
                        then do:
                           assign
                              v-user-login-role-code = NEXT-VALUE(s-user-login-action-role, ub)
                           .
                           create buf_user-login-action-role .
                           assign
                              buf_user-login-action-role.db-num               = g#db-num
                              buf_user-login-action-role.action-head-code     = 0
                              buf_user-login-action-role.user-login-role-code = v-user-login-role-code
                              buf_user-login-action-role.user-id              = buf_user-login.user-id
                              buf_user-login-action-role.action-role-code     = v-global-action-role-code
                              buf_user-login-action-role.action-role-context  = 'global':U
                              buf_user-login-action-role.host-code            = 0
                              buf_user-login-action-role.obj-type             = '':U
                              buf_user-login-action-role.obj-code             = 0
                              buf_user-login-action-role.gds-grp-code         = ?
                              buf_user-login-action-role.gds-code             = ?
                              buf_user-login-action-role.cli-grp-code         = ?
                           .
                        end.
                        if v-firm-action-role-code <> 0
                        then do:
                        assign
                          v-user-login-role-code = dynamic-next-value("s-user-login-action-role":U, "ub":U)
                        .
                        create buf_user-login-action-role .
                        assign
                           buf_user-login-action-role.db-num               = g#db-num
                           buf_user-login-action-role.action-head-code     = 0
                           buf_user-login-action-role.user-login-role-code = v-user-login-role-code
                           buf_user-login-action-role.user-id              = buf_user-login.user-id
                           buf_user-login-action-role.action-role-code     = v-firm-action-role-code
                           buf_user-login-action-role.action-role-context  = 'firm':U
                           buf_user-login-action-role.host-code            = buf_clients.host-code
                           buf_user-login-action-role.obj-type             = '':U
                           buf_user-login-action-role.obj-code             = 0
                           buf_user-login-action-role.gds-grp-code         = ?
                           buf_user-login-action-role.gds-code             = ?
                           buf_user-login-action-role.cli-grp-code         = ?
                        .
                        end.
                        if v-object-action-role-code <> 0
                        then do:
                        assign
                          v-user-login-role-code = dynamic-next-value("s-user-login-action-role":U, "ub":U)
                        .
                        create buf_user-login-action-role .
                        assign
                           buf_user-login-action-role.db-num               = g#db-num
                           buf_user-login-action-role.action-head-code     = 0
                           buf_user-login-action-role.user-login-role-code = v-user-login-role-code
                           buf_user-login-action-role.user-id              = buf_user-login.user-id
                           buf_user-login-action-role.action-role-code     = v-object-action-role-code
                           buf_user-login-action-role.action-role-context  = 'object':U
                           buf_user-login-action-role.host-code            = buf_clients.host-code
                           buf_user-login-action-role.obj-type             = buf_clients.obj-type
                           buf_user-login-action-role.obj-code             = buf_clients.obj-code
                           buf_user-login-action-role.gds-grp-code         = ?
                           buf_user-login-action-role.gds-code             = ?
                           buf_user-login-action-role.cli-grp-code         = ?
                        .
                        end.
                     end.
                  end.
               end.
            end.
            else do:
               _temp-usr-grpa:
               for each  temp-usr-grpa
                   where temp-usr-grpa.grp-name = temp-grpa.grp-name
                     and temp-usr-grpa.arm-code = temp-grpa.arm-code
                   no-lock
               on error undo, return error return-value
               :
                  find first buf_user-login
                       where buf_user-login.db-num     = g#db-num
                         and buf_user-login.user-login = temp-usr-grpa.user-name
                       no-lock
                       no-error .
                  if not available buf_user-login
                  then do:
                                                next _temp-usr-grpa.
                  end.
                  else do:
                     find first buf_clients no-lock
                        where buf_clients.obj-type = 'орг':U
                        and buf_clients.obj-code = temp-usr-grpa.host-code
                        no-error .
                     if not available buf_clients
                     then do:
                     end.
                     else do:
                        if v-global-action-role-code <> 0
                        then do:
                        assign
                          v-user-login-role-code = dynamic-next-value("s-user-login-action-role":U, "ub":U)
                        .
                        create buf_user-login-action-role .
                        assign
                           buf_user-login-action-role.db-num               = g#db-num
                           buf_user-login-action-role.action-head-code     = 0
                           buf_user-login-action-role.user-login-role-code = v-user-login-role-code
                           buf_user-login-action-role.user-id              = buf_user-login.user-id
                           buf_user-login-action-role.action-role-code     = v-global-action-role-code
                           buf_user-login-action-role.action-role-context  = 'global':U
                           buf_user-login-action-role.host-code            = 0
                           buf_user-login-action-role.obj-type             = '':U
                           buf_user-login-action-role.obj-code             = 0
                           buf_user-login-action-role.gds-grp-code         = ?
                           buf_user-login-action-role.gds-code             = ?
                           buf_user-login-action-role.cli-grp-code         = ?
                        .
                        end.
                        if v-firm-action-role-code <> 0
                        then do:
                        assign
                          v-user-login-role-code = dynamic-next-value("s-user-login-action-role":U, "ub":U)
                        .
                        create buf_user-login-action-role .
                        assign
                           buf_user-login-action-role.db-num               = g#db-num
                           buf_user-login-action-role.action-head-code     = 0
                           buf_user-login-action-role.user-login-role-code = v-user-login-role-code
                           buf_user-login-action-role.user-id              = buf_user-login.user-id
                           buf_user-login-action-role.action-role-code     = v-firm-action-role-code
                           buf_user-login-action-role.action-role-context  = 'firm':U
                           buf_user-login-action-role.host-code            = buf_clients.obj-code
                           buf_user-login-action-role.obj-type             = '':U
                           buf_user-login-action-role.obj-code             = 0
                           buf_user-login-action-role.gds-grp-code         = ?
                           buf_user-login-action-role.gds-code             = ?
                           buf_user-login-action-role.cli-grp-code         = ?
                        .
                        end.
                     end.
                  end.
               end.
            end.
         end.
      end.
   end case.
   _usr-flt:
   FOR EACH temp-usr-flt:
   END.
end.
if p-seq then do:
        run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Проверка группы данных СЧЕТЧИКИ" ) ).
      _sequencev:
  FOR EACH temp_sequence NO-LOCK:
    FIND FIRST ub._sequence No-LOCK WHERE
              ub._sequence._seq-name = temp_sequence.seq-name NO-ERROR.
    IF NOT AVAILABLE ubflt.filter then do:
            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Проверка группы данных СЧЕТЧИКИ" + chr(10) + " В БД нет СЧЕТЧИКА(sequence):" +                       " название " + string(temp_sequence.seq-name)) )) .              delete temp_sequence.                   NEXT _sequencev.
    end.
    if dynamic-current-value( temp_sequence.seq-name, "ub":U ) < temp_sequence.seq-val then do:
      assign
        dynamic-current-value( temp_sequence.seq-name, "ub":U ) = temp_sequence.seq-val
      .
    end.
  END.
end.
session:system-alert-boxes = loc-alert-box.
procedure p-gen-i :
  do
  on error undo, return error
  :
  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Импорт группы данных ИНФОРМАЦИЯ O БД" + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + "gen":U) )) .
  run check-iefile in this-procedure(input p-dir-name,                                      input "gen":U,                                      input "import":U,                                      output loc#log).
  ii = 0.
  if loc#log then do:
    run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Импорт группы данных ИНФОРМАЦИЯ O БД" ) ).
    input stream Instream from value(p-dir-name + "\":U + p-db-key + ".":U + "gen":U).
    _gen:
    REPEAT:
      import stream Instream unformatted ss.
      CASE ss:
        when "config":U then do:
          current-table = ss.
          case current-table:
            when "config":U then do:
              ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
              create buf-config.
              CASE p-version:
                when "12.3" then do:
                  import stream Instream buf-config.conf-type                                 v-log-gap                                            buf-config.host-code                                 buf-config.obj-code                                 buf-config.obj-type                                 buf-config.param-code                                 buf-config.param-encoded                                 buf-config.param-type                                 buf-config.param-value no-error.
                end.
                when "14.1" then do:
                  import stream Instream v-arm-code                                 buf-config.conf-type                                 v-grp-name                                 buf-config.host-code                                 buf-config.obj-code                                 buf-config.obj-type                                 buf-config.param-code                                 buf-config.param-encoded                                 buf-config.param-type                                 buf-config.param-value                                 v-user-name no-error.
                end.
                otherwise do:
                  import stream Instream buf-config.conf-type                                 buf-config.host-code                                 buf-config.obj-code                                 buf-config.obj-type                                 buf-config.param-code                                 buf-config.param-encoded                                 buf-config.param-type                                 buf-config.param-value no-error.
                end.
              END CASE.
                            if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ИНФОРМАЦИЯ O БД, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _gen.                   end.
                            IF CAN-FIND(FIRST temp-config No-LOCK WHERE
                                temp-config.param-code = buf-config.param-code AND
                                temp-config.host-code = buf-config.host-code AND
                                temp-config.obj-type = buf-config.obj-type AND
                                temp-config.obj-code = buf-config.obj-code
                                 )
                                then do:
                                    run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ИНФОРМАЦИЯ O БД, СТРОКА " + string(ii) + chr(10)) + " Уже есть запись НАСТРОЕЧНОГО ПАРАМЕТРА(config)" +                                   " параметр " + buf-config.param-code +                                   " Фирма " + string(buf-config.host-code) +                                   " тип объекта " + buf-config.obj-type +                                   " код объекта " + string(buf-config.obj-code) ) )) .              delete buf-config.                   NEXT _gen.
              end.
              if lookup( buf-config.conf-type, 'к,п':U ) > 0 then do:
                                    run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ИНФОРМАЦИЯ O БД, СТРОКА " + string(ii) + chr(10)) + " НАСТРОЕЧНОГО ПАРАМЕТРА(config) является кодированным" +                                   " параметр " + buf-config.param-code +                                   " Фирма " + string(buf-config.host-code) +                                   " тип объекта " + buf-config.obj-type +                                   " код объекта " + string(buf-config.obj-code) ) )) .              delete buf-config.                   NEXT _gen.
              end.
              create temp-config.
              buffer-copy buf-config to temp-config.
              delete buf-config.
            end.
          end CASE.
        end.
        otherwise do:
        end.
      END CASE.
    END.
    input stream InStream close.
  end.
  end.
end procedure.
procedure p-flt-i :
  do
  on error undo, return error
  :
  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Импорт группы данных ФИЛЬТРЫ" + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + "flt":U) )) .
  run check-iefile in this-procedure(input p-dir-name,                                      input "flt":U,                                      input "import":U,                                      output loc#log).
  ii = 0.
  if loc#log then do:
    run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Импорт группы данных ФИЛЬТРЫ" ) ).
    input stream Instream from value(p-dir-name + "\":U + p-db-key + ".":U + "flt":U).
    _flt:
    REPEAT:
      import stream Instream unformatted ss.
      CASE ss:
        when "filter":U then do:
          current-table = ss.
          case current-table:
            when "filter":U then do:
              ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
              create buf-filter.
              import stream Instream buf-Filter.Fields-sort-rus                                 buf-Filter.Fields-sort                                 buf-Filter.Flds                                 buf-Filter.Naim                                 buf-Filter.Num-flt                                 buf-Filter.Tbl                                 buf-Filter.Where-ysl-rus                                 buf-Filter.Where-ysl                                 buf-Filter.call-point                                 buf-Filter.lst-cend no-error.
                            if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ФИЛЬТРЫ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _flt.                   end.
                            assign
              buf-filter.where-ysl = replace(buf-filter.where-ysl, chr(1), chr(4))
              buf-filter.where-ysl-rus = replace(buf-filter.where-ysl-rus, chr(1), chr(4))
              buf-filter.fields-sort-rus = replace(buf-filter.fields-sort-rus, chr(1), chr(4))
              buf-filter.fields-sort = replace(buf-filter.fields-sort, chr(1), chr(4))
              buf-filter.call-point = replace(buf-filter.call-point, chr(1), chr(4))
              .
              IF CAN-FIND(FIRST temp-filter No-LOCK WHERE
                                temp-filter.call-point = buf-filter.call-point AND
                                temp-filter.NAIM = buf-filter.NAIM
                                )
                                then do:
                                    run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ФИЛЬТРЫ, СТРОКА " + string(ii) + chr(10)) + " Уже есть ФИЛЬТР(filter):" +                                  " название " + string(buf-filter.Naim) +                                  " точка вызова " + buf-filter.call-point) )) .              delete buf-filter.                   NEXT _flt.
              end.
              create temp-filter.
              buffer-copy buf-filter to temp-filter.
              delete buf-filter.
            end.
          end CASE.
        end.
        otherwise do:
        end.
      END CASE.
    END.
    input stream InStream close.
  end.
  end.
end procedure.
procedure p-pbc-i :
  do
  on error undo, return error
  :
  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Импорт группы данных ВЕС и ВЗВЕШ КОДЫ" + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + "pbc":U) )) .
  run check-iefile in this-procedure(input p-dir-name,                                      input "pbc":U,                                      input "import":U,                                      output loc#log).
  ii = 0.
  if loc#log then do:
    run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Импорт группы данных ВЕС и ВЗВЕШ КОДЫ" ) ).
    input stream Instream from value(p-dir-name + "\":U + p-db-key + ".":U + "pbc":U).
    _pbc:
    REPEAT:
      import stream Instream unformatted ss.
      CASE ss:
        when "prod-bc":U then do:
          current-table = ss.
          case current-table:
            when "prod-bc":U then do:
              ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
              create buf-prod-bc.
              import stream Instream buf-prod-bc.b-code                                 buf-prod-bc.b-str                                 buf-prod-bc.bc-on no-error.
                            if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ВЕС и ВЗВЕШ КОДЫ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _pbc.                   end.
                            IF CAN-FIND(FIRST temp-prod-bc No-LOCK WHERE
                                temp-prod-bc.b-str = buf-prod-bc.b-str
                            AND temp-prod-bc.b-code = buf-prod-bc.b-code )
                                then do:
                                    run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ВЕС и ВЗВЕШ КОДЫ, СТРОКА " + string(ii) + chr(10)) + " Уже есть ДопБК(prod-bc):" +                                  " ДопБК " + string(buf-prod-bc.b-str) +                                  " Бар-код " + string(buf-prod-bc.b-code)) )) .              delete buf-prod-bc.                   NEXT _pbc.
              end.
              create temp-prod-bc.
              buffer-copy buf-prod-bc to temp-prod-bc.
              delete buf-prod-bc.
            end.
            when "gds-obj-attr":U then do:
              ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
              create ub.gds-obj-attr.
              import stream Instream buf-gds-obj-attr.gds-code                                 buf-gds-obj-attr.obj-type                                 buf-gds-obj-attr.obj-code                                 buf-gds-obj-attr.attr-code                                 buf-gds-obj-attr.attr-value no-error.
                            if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ВЕС и ВЗВЕШ КОДЫ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _pbc.                   end.
                            IF CAN-FIND(FIRST temp-gds-obj-attr No-LOCK WHERE
                                temp-gds-obj-attr.gds-code = buf-gds-obj-attr.gds-code
                            AND temp-gds-obj-attr.obj-type = buf-gds-obj-attr.obj-type
                            AND temp-gds-obj-attr.obj-code = buf-gds-obj-attr.obj-code
                            AND temp-gds-obj-attr.attr-code = buf-gds-obj-attr.attr-code )
                                then do:
                                    run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ВЕС и ВЗВЕШ КОДЫ, СТРОКА " + string(ii) + chr(10)) + " Уже есть атрибут товара ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr):" +                                  " Код товара " + string(buf-gds-obj-attr.gds-code) +                                  " Объект " + gds-obj-attr.obj-type + string(buf-gds-obj-attr.obj-code) +                                  " Весовой код " + string(buf-gds-obj-attr.attr-value) ) )) .              delete buf-gds-obj-attr.                   NEXT _pbc.
              end.
              create temp-gds-obj-attr.
              buffer-copy buf-gds-obj-attr to temp-gds-obj-attr.
              delete buf-gds-obj-attr.
            end.
          end CASE.
        end.
        otherwise do:
        end.
      END CASE.
    END.
    input stream InStream close.
  end.
  end.
end procedure.
procedure p-scl-i :
  do
  on error undo, return error
  :
  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Импорт группы данных ВЕСЫ" + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + "scl":U) )) .
  run check-iefile in this-procedure(input p-dir-name,                                      input "scl":U,                                      input "import":U,                                      output loc#log).
  ii = 0.
  if loc#log then do:
    run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Импорт группы данных ВЕСЫ" ) ).
    input stream Instream from value(p-dir-name + "\":U + p-db-key + ".":U + "scl":U).
    _scl:
    REPEAT:
      import stream Instream unformatted ss.
      CASE ss:
        when "scales":U or when "scales-gds":U or when "scales-grp":U then do:
          current-table = ss.
          case current-table:
            when "scales":U then do:
              ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
              create buf-scales.
              CASE p-version:
                when "12.3" then do:
                  import stream Instream buf-scales.address                                 buf-scales.master                                 buf-scales.max-gds                                 buf-scales.max-plu                                 buf-scales.scales-name                                 buf-scales.scales-num                                 buf-scales.scales-type                                 buf-scales.to-send                                 buf-scales.tot-gds                                 buf-scales.unit-base                                 buf-scales.wt-cart no-error.
                end.
                when "14.1" then do:
                  import stream Instream buf-scales.address                                 buf-scales.master                                 buf-scales.max-gds                                 buf-scales.max-plu                                 buf-scales.scales-name                                 buf-scales.scales-num                                 buf-scales.scales-type                                 buf-scales.to-send                                 buf-scales.tot-gds                                 buf-scales.unit-base                                 buf-scales.wt-cart                                  buf-scales.remote no-error.
                end.
                when "15.0" then do:
                  import stream Instream buf-scales.address                                 buf-scales.db-num                                 buf-scales.master                                 buf-scales.max-gds                                 buf-scales.max-plu                                 buf-scales.scales-name                                 buf-scales.scales-num                                 buf-scales.scales-type                                 buf-scales.to-send                                 buf-scales.tot-gds                                 buf-scales.unit-base                                 buf-scales.wt-cart                                  buf-scales.remote no-error.
                end.
              END CASE.
                            if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ВЕСЫ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _scl.                   end.
                            IF CAN-FIND(FIRST temp-scales No-LOCK WHERE
                                temp-scales.db-num = buf-scales.db-num AND
                                temp-scales.scales-num = buf-scales.scales-num )
                                then do:
                                    run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ВЕСЫ, СТРОКА " + string(ii) + chr(10)) + " Уже есть ВЕСЫ(scales):" +                                  " номер " + string(buf-scales.scales-num)) )) .              delete buf-scales.                   NEXT _scl.
              end.
              create temp-scales.
              buffer-copy buf-scales to temp-scales.
              assign
              temp-scales.db-num = (if p-version < "15.0"
                                    then g#db-num
                                    else temp-scales.db-num)
              .
              delete buf-scales.
            end.
            when "scales-gds":U then do:
              ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
              create buf-scales-gds.
              CASE p-version:
                when "15.0" then do:
                   import stream Instream buf-scales-gds.PLU-code                                 buf-scales-gds.b-code                                 buf-scales-gds.db-num                                 buf-scales-gds.deadline                                 buf-scales-gds.obj-code                                 buf-scales-gds.obj-type                                 buf-scales-gds.scales-num                                 buf-scales-gds.to-del                                 buf-scales-gds.to-send                                 buf-scales-gds.wt-cart                                 buf-scales-gds.deaddate                                 buf-scales-gds.deadflag                                 buf-scales-gds.deadtime no-error.
                end.
                otherwise do:
                  import stream Instream buf-scales-gds.PLU-code                                 buf-scales-gds.b-code                                 buf-scales-gds.deadline                                 buf-scales-gds.obj-code                                 buf-scales-gds.obj-type                                 buf-scales-gds.scales-num                                 buf-scales-gds.to-del                                 buf-scales-gds.to-send                                 buf-scales-gds.wt-cart no-error.
                end.
              END CASE.
                            if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ВЕСЫ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _scl.                   end.
                            IF CAN-FIND(FIRST temp-scales-gds No-LOCK WHERE
                                temp-scales-gds.db-num = buf-scales-gds.db-num AND
                                temp-scales-gds.scales-num = buf-scales-gds.scales-num AND
                                temp-scales-gds.PLU-code = buf-scales-gds.PLU-code)
                                then do:
                                    run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ВЕСЫ, СТРОКА " + string(ii) + chr(10)) + " Уже есть ТОВАР НА ВЕСАХ(scales-gds):" +                                  " номер весов " + string(buf-scales-gds.scales-num) +                                  " PLU " + string(buf-scales-gds.PLU-code)) )) .              delete buf-scales-gds.                   NEXT _scl.
              end.
              IF CAN-FIND(FIRST temp-scales-gds No-LOCK WHERE
                                temp-scales-gds.db-num = buf-scales-gds.db-num AND
                                temp-scales-gds.scales-num = buf-scales-gds.scales-num AND
                                temp-scales-gds.b-code = buf-scales-gds.b-code)
                                then do:
                                    run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ВЕСЫ, СТРОКА " + string(ii) + chr(10)) + " Уже есть ТОВАР НА ВЕСАХ(scales-gds):" +                                  " номер весов " + string(buf-scales-gds.scales-num) +                                  " бар-код " + string(buf-scales-gds.b-code)) )) .              delete buf-scales-gds.                   NEXT _scl.
              end.
              create temp-scales-gds.
              buffer-copy buf-scales-gds to temp-scales-gds
              assign
              temp-scales-gds.db-num = (if p-version < "15.0"
                                    then g#db-num
                                    else temp-scales-gds.db-num)
              .
              delete buf-scales-gds.
            end.
            when "scales-grp":U then do:
              ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
              create buf-scales-grp.
              import stream Instream buf-scales-grp.node-code                                 buf-scales-grp.scales-num no-error.
                            if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ВЕСЫ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _scl.                   end.
                            IF CAN-FIND(FIRST temp-scales-grp No-LOCK WHERE
                                temp-scales-grp.db-num = buf-scales-grp.db-num AND
                                temp-scales-grp.scales-num = buf-scales-grp.scales-num AND
                                temp-scales-grp.node-code = buf-scales-grp.node-code)
                                then do:
                                    run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ВЕСЫ, СТРОКА " + string(ii) + chr(10)) + " Уже есть ГРУППА ТОВАРА НА ВЕСАХ(scales-grp):" +                                  " номер группы " + string(buf-scales-grp.node-code) +                                  " номер весов " + string(buf-scales-grp.scales-num)) )) .              delete buf-scales-grp.                   NEXT _scl.
              end.
              create temp-scales-grp.
              buffer-copy buf-scales-grp to temp-scales-grp.
              assign temp-scales-grp.db-num = g#db-num.
              delete buf-scales-grp.
            end.
          end CASE.
        end.
        otherwise do:
        end.
      END CASE.
    END.
    input stream InStream close.
  end.
  end.
end procedure.
procedure p-seq-i :
  do
  on error undo, return error
  :
  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Импорт группы данных СЧЕТЧИКИ" + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + "seq":U) )) .
  run check-iefile in this-procedure(input p-dir-name,                                      input "seq":U,                                      input "import":U,                                      output loc#log).
  ii = 0.
  if loc#log then do:
    run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Импорт группы данных СЧЕТЧИКИ" ) ).
    input stream Instream from value(p-dir-name + "\":U + p-db-key + ".":U + "seq":U).
    _seq:
    REPEAT:
      import stream Instream unformatted ss.
      CASE ss:
        when "_sequence":U then do:
          current-table = ss.
          case current-table:
            when "sequence":U then do:
              ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
              create buf_sequence.
              import stream Instream  no-error.
                            if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных СЧЕТЧИКИ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _seq.                   end.
                            if LOOKUP(buf_sequence.seq-name, 'next-report,s-doc,s-doc-type,s-file-num,':U +                                 's-line-num,s-petrol-code,s-reserve2':U +                                 ',s-spool,s-task-num,s-tax-rate,synch-cli-grp,synch-gds-grp' ) = 0 then next _seq.
              IF CAN-FIND(FIRST temp_sequence No-LOCK WHERE
                                temp_sequence.seq-name = buf_sequence.seq-name
                                )
                                then do:
                                    run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных СЧЕТЧИКИ, СТРОКА " + string(ii) + chr(10)) + " Уже есть СЧЕТЧИК(sequence):" +                                  " название " + string(buf_sequence.seq-name)) )) .              delete buf_sequence.                   NEXT _seq.
              end.
              create temp_sequence.
              buffer-copy buf_sequence to temp_sequence.
              delete buf_sequence.
            end.
          end CASE.
        end.
        otherwise do:
        end.
      END CASE.
    END.
    input stream InStream close.
  end.
  end.
end procedure.
procedure p-rht-i :
define variable v-curr-seek as integer no-undo .
  do
  on error undo, return error
  :
   run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Импорт группы данных ПРАВА" + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + "rht":U) )) .
   run check-iefile in this-procedure(input p-dir-name,                                      input "rht":U,                                      input "import":U,                                      output loc#log).
   ii = 0.
   if loc#log then do:
      run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Импорт группы данных ПРАВА" ) ).
      input stream Instream from value(p-dir-name + "\":U + p-db-key + ".":U + "rht":U).
      CASE p-version:
         when "15.0" then do:
               _rht:
               REPEAT:
                  import stream Instream unformatted ss.
                  ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                  CASE ss:
                  when "action-role":U or
                  when "action-role-item":U
                  then do:
                     current-table = ss.
                     case current-table:
                        when "action-role":U then do:
                           ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                           create buf-action-role.
                           v-curr-seek = seek(instream).
                           import stream Instream buf-action-role.db-num                                  buf-action-role.action-head-code                                  buf-action-role.action-role-code                                  buf-action-role.action-role-context                                  buf-action-role.action-role-name                                  buf-action-role.action-role-description                                  buf-action-role.whole-send-news no-error.
                                                      if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ПРАВА, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _rht.                   end.
                                                      if buf-action-role.db-num <> g#db-num then do:
                                                            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ПРАВА, СТРОКА " + string(ii) + chr(10)) + "  ИГНОРИРУЕМ РОЛЬ(action-role) ЧУЖОЙ БД: "                                                           + STRING(buf-action-role.db-num) + " "                                                           + STRING(buf-action-role.action-head-code) + " "                                                           + STRING(buf-action-role.action-role-code)                                                           ) )) .              delete buf-action-role.                   NEXT _rht.
                           end.
                           IF CAN-FIND(FIRST temp-action-role No-LOCK
                                       WHERE temp-action-role.db-num    = buf-action-role.db-num
                                         and temp-action-role.action-head-code = buf-action-role.action-head-code
                                         and temp-action-role.action-role-code = buf-action-role.action-role-code
                                       )
                                             then do:
                                                                  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ПРАВА, СТРОКА " + string(ii) + chr(10)) + " Уже есть РОЛЬ(action-role): "                                                               + STRING(buf-action-role.db-num) + " "                                                               + STRING(buf-action-role.action-head-code) + " "                                                               + STRING(buf-action-role.action-role-code)                                                               ) )) .              delete buf-action-role.                   NEXT _rht.
                           end.
                           create temp-action-role.
                           buffer-copy
                           buf-action-role to temp-action-role.
                           delete buf-action-role.
                        end.
                        when "action-role-item":U then do:
                           ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                           create buf-action-role-item.
                           v-curr-seek = seek(instream).
                           import stream Instream buf-action-role-item.db-num                                  buf-action-role-item.action-head-code                                  buf-action-role-item.action-role-code                                  buf-action-role-item.action-role-item-code                                  buf-action-role-item.action-item-code                                  buf-action-role-item.action-item-id                                  buf-action-role-item.whole-send-news no-error.
                                                      if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ПРАВА, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _rht.                   end.
                                                      if buf-action-role-item.db-num <> g#db-num then do:
                                                            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ПРАВА, СТРОКА " + string(ii) + chr(10)) + " ИГНОРИРУЕМ РОЛЬ(action-role-item) ДЛЯ ЧУЖОЙ БД: "                                                           + STRING(buf-action-role-item.db-num) + " "                                                           + STRING(buf-action-role-item.action-head-code) + " "                                                           + STRING(buf-action-role-item.action-role-code) + " "                                                           + STRING(buf-action-role-item.action-role-item-code)                                                           ) )) .              delete buf-action-role-item.                   NEXT _rht.
                           end.
                           IF CAN-FIND(FIRST temp-action-role-item No-LOCK
                                       WHERE temp-action-role-item.db-num                = buf-action-role-item.db-num
                                         and temp-action-role-item.action-head-code      = buf-action-role-item.action-head-code
                                         and temp-action-role-item.action-role-code      = buf-action-role-item.action-role-code
                                         and temp-action-role-item.action-role-item-code = buf-action-role-item.action-role-item-code
                                       )
                                             then do:
                                                                  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ПРАВА, СТРОКА " + string(ii) + chr(10)) + " Уже есть РОЛЬ(action-role-item): "                                                               + STRING(buf-action-role-item.db-num) + " "                                                               + STRING(buf-action-role-item.action-head-code) + " "                                                               + STRING(buf-action-role-item.action-role-code) + " "                                                               + STRING(buf-action-role-item.action-role-item-code)                                                               ) )) .              delete buf-action-role-item.                   NEXT _rht.
                           end.
                           create temp-action-role-item.
                           buffer-copy
                           buf-action-role-item to temp-action-role-item.
                           delete buf-action-role-item.
                        end.
                     end CASE.
                  end.
                  otherwise do:
                  end.
                  END CASE.
               END.
         end.
         otherwise do:
            _rht:
            REPEAT:
               import stream Instream unformatted ss.
               CASE ss:
               when "grpa":U or when "grp-acta":U then do:
                  current-table = ss.
                  case current-table:
                     when "grpa":U then do:
                     ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                     create buf-grpa.
                     import stream Instream buf-grpa.arm-code                                 buf-grpa.grp-name no-error.
                                          if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ПРАВА, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _rht.                   end.
                                          IF CAN-FIND(FIRST temp-grpa NO-LOCK WHERE
                                       temp-grpa.grp-name = buf-grpa.grp-name AND
                                       temp-grpa.arm-code = buf-grpa.arm-code) then do:
                                                   run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ПРАВА, СТРОКА " + string(ii) + chr(10)) + " Уже есть ГРУППЫ ПРАВ(grpa):" +                                           " группа " + buf-grpa.grp-name +                                           " АРМ " + buf-grpa.arm-code) )) .              delete buf-grpa.                   NEXT _rht.
                     END.
                     create temp-grpa.
                     buffer-copy buf-grpa to temp-grpa.
                     delete buf-grpa.
                     end.
                     when "grp-acta":U then do:
                     ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                     create buf-grp-acta.
                     import stream Instream buf-grp-acta.act                                 buf-grp-acta.arm-code                                 buf-grp-acta.grp-name                                 buf-grp-acta.object no-error.
                                          if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ПРАВА, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _rht.                   end.
                                          IF CAN-FIND(FIRST temp-grp-acta NO-LOCK WHERE
                                       temp-grp-acta.grp-name = buf-grp-acta.grp-name AND
                                       temp-grp-acta.arm-code = buf-grp-acta.arm-code AND
                                       temp-grp-acta.object = buf-grp-acta.object AND
                                       temp-grp-acta.act = buf-grp-acta.act) then do:
                                                   run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт группы данных ПРАВА, СТРОКА " + string(ii) + chr(10)) + " Уже есть ПРАВА ДЛЯ ГРУППЫ(grp-acta):" +                                           " АРМ " + buf-grp-acta.arm-code +                                           " группа " + buf-grp-acta.grp-name +                                           " объект " + buf-grp-acta.object +                                           " действие " + buf-grp-acta.act) )) .              delete buf-grp-acta.                   NEXT _rht.
                     END.
                     create temp-grp-acta.
                     buffer-copy buf-grp-acta to temp-grp-acta.
                     delete buf-grp-acta.
                     end.
                  end CASE.
               end.
               otherwise do:
               end.
               END CASE.
            END.
            end.
      END CASE.
      input stream InStream close.
     end.
     else do:
         return error.
     end.
  end.
end procedure.
procedure p-usr-i :
define variable v-curr-seek as integer no-undo .
  do
  on error undo, return error
  :
   run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Импорт группы данных ПОЛЬЗОВАТЕЛИ" + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + "usr":U) )) .
   run check-iefile in this-procedure(input p-dir-name,                                      input "usr":U,                                      input "import":U,                                      output loc#log).
   ii = 0.
   if loc#log then do:
      run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Импорт группы данных ПОЛЬЗОВАТЕЛИ" ) ).
      input stream Instream from value(p-dir-name + "\":U + p-db-key + ".":U + "usr":U).
      CASE p-version:
         when "15.0" then do:
               _usr:
               REPEAT:
                  import stream Instream unformatted ss.
                  ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                  CASE ss:
                  when "user-account":U or
                  when "user-login":U or
                  when "user-obj":U or
                  when "user-host":U or
                  when "user-menu-group":U or
                  when "user-login-action-role":U or
                  when "action-role":U or
                  when "action-role-item":U or
                  when "usr-flt":U
                  then do:
                     current-table = ss.
                     case current-table:
                        when "user-account":U then do:
                           ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                           create buf-user-account.
                           v-curr-seek = seek(instream).
                           import stream Instream buf-user-account.user-id                                  buf-user-account.status_                                  buf-user-account.first-name                                  buf-user-account.second-name                                  buf-user-account.last-name                                  buf-user-account.company                                  buf-user-account.department                                  buf-user-account.e-mail                                  buf-user-account.internal-phone-number                                  buf-user-account.mobile-phone-number                                  buf-user-account.phone-number                                  buf-user-account.position                                  buf-user-account.PS                                  buf-user-account.room                                  buf-user-account.parent-user-id                                  buf-user-account.check-parent                                  buf-user-account.nik no-error.
                                                      if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _usr.                   end.
                                                      IF CAN-FIND(FIRST temp-user-account No-LOCK WHERE
                                             temp-user-account.user-id = buf-user-account.user-id) then do:
                                                                  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + " Уже есть ПОЛЬЗОВАТЕЛЬ(user-account): " + buf-user-account.user-id) )) .              delete buf-user-account.                   NEXT _usr.
                           end.
                           create temp-user-account.
                           buffer-copy
                           buf-user-account to temp-user-account.
                           delete buf-user-account.
                        end.
                        when "user-login":U then do:
                           ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                           create buf-user-login.
                           v-curr-seek = seek(instream).
                           import stream Instream buf-user-login.db-num                                  buf-user-login.user-id                                  buf-user-login.user-login                                  buf-user-login.user-administrator                                  buf-user-login.max-discnt                                  buf-user-login.quest-print                                  buf-user-login.status_ no-error.
                                                      if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _usr.                   end.
                                                      if buf-user-login.db-num <> g#db-num then do:
                                                            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + " ИГНОРИРУЕМ ПОЛЬЗОВАТЕЛЯ(user-login) ЧУЖОЙ БД: " + buf-user-login.user-id) )) .              delete buf-user-login.                   NEXT _usr.
                           end.
                           IF CAN-FIND(FIRST temp-user-login No-LOCK
                                       WHERE temp-user-login.user-id = buf-user-login.user-id
                                         and temp-user-login.db-num  = buf-user-login.db-num
                                       )
                                             then do:
                                                                  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + " Уже есть ПОЛЬЗОВАТЕЛЬ(user-login): " + buf-user-login.user-id) )) .              delete buf-user-login.                   NEXT _usr.
                           end.
                           create temp-user-login.
                           buffer-copy
                           buf-user-login to temp-user-login.
                           delete buf-user-login.
                        end.
                        when "user-obj":U then do:
                           ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                           create buf-user-obj.
                           v-curr-seek = seek(instream).
                           import stream Instream buf-user-obj.db-num                                  buf-user-obj.user-id                                  buf-user-obj.obj-type                                  buf-user-obj.obj-code                                  buf-user-obj.host-code no-error.
                                                      if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _usr.                   end.
                                                      if buf-user-obj.db-num <> g#db-num then do:
                                                            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + " ИГНОРИРЕУМ ПОЛЬЗОВАТЕЛЯ(user-obj) ЧУЖОЙ БД: " + buf-user-obj.user-id) )) .              delete buf-user-obj.                   NEXT _usr.
                           end.
                           IF CAN-FIND(FIRST temp-user-obj No-LOCK
                                       WHERE temp-user-obj.user-id  = buf-user-obj.user-id
                                         and temp-user-obj.db-num   = buf-user-obj.db-num
                                         and temp-user-obj.obj-type = buf-user-obj.obj-type
                                         and temp-user-obj.obj-code = buf-user-obj.obj-code
                                       )
                                             then do:
                                                                  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + " Уже есть ПОЛЬЗОВАТЕЛЬ(user-obj): " + buf-user-obj.user-id) )) .              delete buf-user-obj.                   NEXT _usr.
                           end.
                           create temp-user-obj.
                           buffer-copy
                           buf-user-obj to temp-user-obj.
                           delete buf-user-obj.
                        end.
                        when "user-host":U then do:
                           ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                           create buf-user-host.
                           v-curr-seek = seek(instream).
                           import stream Instream buf-user-host.db-num                                  buf-user-host.user-id                                  buf-user-host.host-code no-error.
                                                      if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _usr.                   end.
                                                      if buf-user-host.db-num <> g#db-num then do:
                                                            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + " ИГНОРИРУЕМ ПОЛЬЗОВАТЕЛЯ(user-host) ЧУЖОЙ БД: " + buf-user-host.user-id) )) .              delete buf-user-host.                   NEXT _usr.
                           end.
                           IF CAN-FIND(FIRST temp-user-host No-LOCK
                                       WHERE temp-user-host.user-id   = buf-user-host.user-id
                                         and temp-user-host.db-num    = buf-user-host.db-num
                                         and temp-user-host.host-code = buf-user-host.host-code
                                       )
                                             then do:
                                                                  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + " Уже есть ПОЛЬЗОВАТЕЛЬ(user-host): " + buf-user-host.user-id) )) .              delete buf-user-host.                   NEXT _usr.
                           end.
                           create temp-user-host.
                           buffer-copy
                           buf-user-host to temp-user-host.
                           delete buf-user-host.
                        end.
                        when "user-login-action-role":U then do:
                           ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                           create buf-user-login-action-role.
                           v-curr-seek = seek(instream).
                           import stream Instream buf-user-login-action-role.db-num                                  buf-user-login-action-role.action-head-code                                  buf-user-login-action-role.user-login-role-code                                  buf-user-login-action-role.user-id                                  buf-user-login-action-role.action-role-code                                  buf-user-login-action-role.action-role-context                                  buf-user-login-action-role.host-code                                  buf-user-login-action-role.obj-type                                  buf-user-login-action-role.obj-code                                  buf-user-login-action-role.gds-grp-code                                  buf-user-login-action-role.gds-code                                  buf-user-login-action-role.cli-grp-code no-error.
                                                      if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _usr.                   end.
                                                      if buf-user-login-action-role.db-num <> g#db-num then do:
                                                            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + " ИГНОРИРЕМ ПОЛЬЗОВАТЕЛЯ(user-login-action-role) ЧУЖОЙ БД: " + STRING(buf-user-login-action-role.user-login-role-code)) )) .              delete buf-user-login-action-role.                   NEXT _usr.
                           end.
                           IF CAN-FIND(FIRST temp-user-login-action-role No-LOCK
                                       WHERE temp-user-login-action-role.db-num               = buf-user-login-action-role.db-num
                                         and temp-user-login-action-role.action-head-code     = buf-user-login-action-role.action-head-code
                                         and temp-user-login-action-role.user-login-role-code = buf-user-login-action-role.user-login-role-code
                                       )
                                             then do:
                                                                  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + " Уже есть ПОЛЬЗОВАТЕЛЬ(user-login-action-role): " + STRING(buf-user-login-action-role.user-login-role-code)) )) .              delete buf-user-login-action-role.                   NEXT _usr.
                           end.
                           create temp-user-login-action-role.
                           buffer-copy
                           buf-user-login-action-role to temp-user-login-action-role.
                           delete buf-user-login-action-role.
                        end.
                        when "user-menu-group":U then do:
                           ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                           create buf-user-menu-group.
                           v-curr-seek = seek(instream).
                           import stream Instream buf-user-menu-group.db-num                                  buf-user-menu-group.user-id                                  buf-user-menu-group.user-menu-group-code                                  buf-user-menu-group.menu-code                                  buf-user-menu-group.menu-group-code                                  buf-user-menu-group.menu-group-id                                  buf-user-menu-group.menu-group-context                                  buf-user-menu-group.host-code                                  buf-user-menu-group.obj-type                                  buf-user-menu-group.obj-code no-error.
                                                      if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _usr.                   end.
                                                      if buf-user-menu-group.db-num <> g#db-num then do:
                                                            run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + " ИГНОРИРЕУМ ПОЛЬЗОВАТЕЛЯ(user-menu-group) ЧУЖОЙ БД: " + STRING(buf-user-menu-group.user-menu-group-code)) )) .              delete buf-user-menu-group.                   NEXT _usr.
                           end.
                           IF CAN-FIND(FIRST temp-user-menu-group No-LOCK
                                       WHERE temp-user-menu-group.db-num               = buf-user-menu-group.db-num
                                         and temp-user-menu-group.user-id              = buf-user-menu-group.user-id
                                         and temp-user-menu-group.user-menu-group-code = buf-user-menu-group.user-menu-group-code
                                       )
                                             then do:
                                                                  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + " Уже есть ПОЛЬЗОВАТЕЛЬ(user-menu-group): " + STRING(buf-user-menu-group.user-menu-group-code)) )) .              delete buf-user-menu-group.                   NEXT _usr.
                           end.
                           create temp-user-menu-group.
                           buffer-copy
                           buf-user-menu-group to temp-user-menu-group.
                           delete buf-user-menu-group.
                        end.
                        when "usr-flt":U then do:
                           ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                           create buf-usr-flt.
                           import stream Instream buf-usr-flt.Naim                                 buf-usr-flt.call-point                                 buf-usr-flt.user-name no-error.
                                                      if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _usr.                   end.
                                                      assign
                           buf-usr-flt.call-point = replace(buf-usr-flt.call-point, chr(1), chr(4))
                           .
                           IF CAN-FIND(FIrst temp-usr-flt NO-LOCK WHERE
                                             temp-usr-flt.user-name = buf-usr-flt.user-name AND
                                             temp-usr-flt.call-point = buf-usr-flt.call-point) then do:
                                                                  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + " Уже есть ФИЛЬТР ДЛЯ ПОЛЬЗОВАТЕЛЯ(usr-flt):" +                                                 " имя пользователя " + buf-usr-flt.user-name +                                                 " точка вызова фильтра " + buf-usr-flt.call-point) )) .              delete buf-usr-flt.                   NEXT _usr.
                           end.
                           create temp-usr-flt.
                           buffer-copy buf-usr-flt to temp-usr-flt.
                           delete buf-usr-flt.
                        end.
                     end CASE.
                  end.
                  otherwise do:
                  end.
                  END CASE.
               END.
         end.
         otherwise do:
               _usr:
               REPEAT:
                  import stream Instream unformatted ss.
                  ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                  CASE ss:
                  when "userconf":U or
                  when "usr-flt":U or
                  when "usr-grpa":U or
                  when "usr-grpo":U
                  then do:
                     current-table = ss.
                     case current-table:
                        when "userconf":U then do:
                           ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                           create buf-userconf.
                           v-curr-seek = seek(instream).
                           import stream Instream buf-userconf.ARM                                 buf-userconf.max-discnt                                 buf-userconf.obj-code                                 buf-userconf.obj-type                                 buf-userconf.on-line                                 buf-userconf.user-name                                 buf-userconf.arm-host-code                                 buf-userconf.userid_                                 buf-userconf.user-name_                                 buf-userconf.password_ no-error.
                           if error-status:error then do:
                              seek stream instream to v-curr-seek.
                              import stream Instream buf-userconf.ARM                                 buf-userconf.max-discnt                                 buf-userconf.obj-code                                 buf-userconf.obj-type                                 buf-userconf.on-line                                 buf-userconf.user-name                                 buf-userconf.userid_                                 buf-userconf.user-name_                                 buf-userconf.password_ no-error.
                           end.
                                                      if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _usr.                   end.
                                                      IF CAN-FIND(FIRST temp-userconf No-LOCK WHERE
                                             temp-userconf.user-name = buf-userconf.user-name) then do:
                                                                  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + " Уже есть ПОЛЬЗОВАТЕЛЬ(userconf):" +                                                 " имя " + buf-userconf.user-name) )) .              delete buf-userconf.                   NEXT _usr.
                           end.
                           create temp-userconf.
                           buffer-copy
                           buf-userconf to temp-userconf.
                           delete buf-userconf.
                        end.
                        when "usr-flt":U then do:
                           ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                           create buf-usr-flt.
                           import stream Instream buf-usr-flt.Naim                                 buf-usr-flt.call-point                                 buf-usr-flt.user-name no-error.
                                                      if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _usr.                   end.
                                                      assign
                           buf-usr-flt.call-point = replace(buf-usr-flt.call-point, chr(1), chr(4))
                           .
                           IF CAN-FIND(FIrst temp-usr-flt NO-LOCK WHERE
                                             temp-usr-flt.user-name = buf-usr-flt.user-name AND
                                             temp-usr-flt.call-point = buf-usr-flt.call-point) then do:
                                                                  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + " Уже есть ФИЛЬТР ДЛЯ ПОЛЬЗОВАТЕЛЯ(usr-flt):" +                                                 " имя пользователя " + buf-usr-flt.user-name +                                                 " точка вызова фильтра " + buf-usr-flt.call-point) )) .              delete buf-usr-flt.                   NEXT _usr.
                           end.
                           create temp-usr-flt.
                           buffer-copy buf-usr-flt to temp-usr-flt.
                           delete buf-usr-flt.
                        end.
                        when "usr-grpa":U then do:
                           ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                           create buf-usr-grpa.
                           import stream Instream buf-usr-grpa.arm-code                                 buf-usr-grpa.grp-name                                 buf-usr-grpa.host-code                                 buf-usr-grpa.user-name no-error.
                                                      if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _usr.                   end.
                                                      IF CAN-FIND(FIRST temp-usr-grpa NO-LOCK WHERE
                                             temp-usr-grpa.user-name = buf-usr-grpa.user-name AND
                                             temp-usr-grpa.host-code = buf-usr-grpa.host-code AND
                                             temp-usr-grpa.arm-code = buf-usr-grpa.arm-code) then do:
                                                               run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + " Уже есть ПРАВА В АРМЕ ДЛЯ ПОЛЬЗОВАТЕЛЯ(usr-grpa):" +                                                 " имя пользователя " + buf-usr-grpa.user-name +                                                 " фирма " + string(buf-usr-grpa.host-code) +                                                 " АРМ " + buf-usr-grpa.arm-code) )) .              delete buf-usr-grpa.                   NEXT _usr.
                           END.
                           create temp-usr-grpa.
                           buffer-copy buf-usr-grpa to temp-usr-grpa.
                           delete buf-usr-grpa.
                        end.
                        when "usr-grpo":U then do:
                           ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
                           create buf-usr-grpo.
                           import stream Instream buf-usr-grpo.grp-name                                 buf-usr-grpo.obj-code                                 buf-usr-grpo.obj-type                                 buf-usr-grpo.user-name no-error.
                                                      if error-status:error then do:                       run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + error-status:get-message(error-status:num-messages)) )) .                       NEXT _usr.                   end.
                                                      IF CAN-FIND(FIRST temp-usr-grpo NO-LOCK WHERE
                                             temp-usr-grpo.user-name = buf-usr-grpo.user-name AND
                                             temp-usr-grpo.obj-type = buf-usr-grpo.obj-type AND
                                             temp-usr-grpo.obj-code = buf-usr-grpo.obj-code) then do:
                                                               run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", (("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + chr(10)) + " Уже есть ПРАВА НА ОБЪЕКТЕ ДЛЯ ПОЛЬЗОВАТЕЛЯ(usr-grpo):" +                                                 " имя пользователя " + buf-usr-grpo.user-name +                                                 " тип объекта " + buf-usr-grpo.obj-type +                                                 " код объекта " + string(buf-usr-grpo.obj-code)) )) .              delete buf-usr-grpo.                   NEXT _usr.
                           END.
                           create temp-usr-grpo.
                           buffer-copy buf-usr-grpo to temp-usr-grpo.
                           delete buf-usr-grpo.
                        end.
                     end CASE.
                  end.
                  otherwise do:
                  end.
                  END CASE.
               END.
            end.
      END CASE.
      input stream InStream close.
     end.
  end.
end procedure.
procedure create-scales-gds :
define parameter buffer bc for ub.bar-code.
define parameter buffer sc for ub.scales.
define parameter buffer goods for ub.goods.
define parameter buffer ltemp-scales-gds  for temp-scales-gds.
define variable ii as integer no-undo.
def buffer for-pbc for ub.prod-bc.
define variable sc-code like ub.bar-code.b-code no-undo .
define variable v-found as logical no-undo .
define variable v-on as logical no-undo .
define variable v-b-str like ub.prod-bc.b-str no-undo .
define variable f-sc-code as integer no-undo .
define buffer dubl_prod-bc for ub.prod-bc.
define buffer buf_units for ub.units.
  do
  on error undo, return error
  :
    if sc.tot-gds + 1 > sc.max-gds then do:
      undo, return error ("Превышено максимальное количество товаров на весах" + chr(32) + string(sc.scales-num)).
    end.
    find first buf_units no-lock where buf_units.unit-name = goods.unit-base.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-rid18 as recid no-undo .
v-found = no.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer locK-batchprocess19 for ub.batchprocess.
run gbl/lock-prc.p
    (input 'lscc':U
    ,input 0
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input (
            ",,,Вкл/выкл лок. вес. кодов"
           )
    ,input true
    ,buffer lock-batchprocess19
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент идет процесс вкл/выкл лок. вес. кодов" skip
      view-as alert-box error .
    undo, return error .
  end.
if lookup('вес':U, buf_units.type) > 0 then do:
  run trg/isvescod.p ( input bc.b-code
                      ,input yes
                      ,input no
                      ,input yes
                      ,input ""
                      ,output v-found
                      ,output v-on
                      ,output v-b-str) no-error.
end.
else do:
  run trg/ispgwcod.p (input bc.b-code
                    ,input yes
                    ,input no
                    ,input yes
                    ,input ""
                    ,output v-found
                    ,output v-on
                    ,output v-b-str ) no-error.
end.
if error-status:error then do:
  return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
end.
if v-found and v-on = no then do:
  find first ub.prod-bc exclusive-lock where
             ub.prod-bc.b-code = bc.b-code
        AND  ub.prod-bc.b-str = v-b-str no-error no-wait.
  if not avail prod-bc then do:
    assign
    v-found = no
    .
  end.
  else do:
    if prod-bc.bc-on = no then do:
      run trg/bc-upd.p (
                               input parparentproc
                ,input bc.b-code
                ,input  ub.prod-bc.b-str
                ,input yes
                ,input yes
                ,input no
                ,input ?
                ,input ?
                ) no-error.
      if error-status:error then do:
        assign
        v-found = no
        .
      end.
    end.
  end.
end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  ltemp-scales-gds.obj-type
  ,input  ltemp-scales-gds.obj-code
  ,input  goods.artic
  ,input  goods.prod-type
  ,input  goods.prod-code
  ,buffer ub.gds-obj
  ) no-error .
release ub.gds-obj.
if lookup('вес':U, buf_units.type) = 0
or v-found = yes
then do:
  define variable v-exist18 as logical no-undo .
  run gdsoattr-exist in this-procedure (
                                        input goods.gds-code
                                       ,input ltemp-scales-gds.obj-type
                                       ,input ltemp-scales-gds.obj-code
                                       ,input 'scales-code':U
                                       ,output v-exist18
                                      ) .
  if not v-exist18 then do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run sclcdattr in g#library
  (input  goods.gds-code
  ,input  ltemp-scales-gds.obj-type
  ,input  ltemp-scales-gds.obj-code
  ,input  v-b-str
  ,input  no
  ) no-error .
end.
if error-status:error then do:
  return error '':U.
end.
end.
if not v-found
and lookup('вес':U, buf_units.type) > 0
then do:
  v-rid18 = ?.
  run trg/prod-bc1.p ( input parparentproc
                      ,input yes
                      ,input ?
                      ,input ?
                      ,input no
                      ,input 'sclc':U
                      ,input ""
                      ,buffer goods
                      ,input bc.b-code
                      ,input-output v-b-str
                      ,output v-rid18
                      ) no-error.
  if error-status:error
  or v-rid18 = ? then do:
    return error substitute("Ошибка при сохранении ДопБК для весов&2&1&2&3", error-status:get-message(1) , chr(10), return-value ).
  end.
  find first prod-bc exclusive-lock where
            recid(prod-bc) = v-rid18.
end.
    _main:
    DO ON ERROR undo, return error on stop undo, return error:
      create ub.scales-gds.
      assign
      sc.tot-gds  = sc.tot-gds + 1
      ub.scales-gds.db-num    = g#db-num
      ub.scales-gds.obj-type  = ltemp-scales-gds.obj-type
      ub.scales-gds.obj-code = ltemp-scales-gds.obj-code
      ub.scales-gds.b-code = ltemp-scales-gds.b-code
      ub.scales-gds.scales-num = ltemp-scales-gds.scales-num
      ub.scales-gds.to-send = TRUE
      sc.to-send = TRUE
      ub.scales-gds.to-del = FALSE
      ub.scales-gds.deadline = ltemp-scales-gds.deadline
      ub.scales-gds.wt-cart = ltemp-scales-gds.wt-cart
      ub.scales-gds.plu-code = ltemp-scales-gds.plu-code
      .
    END.
  end.
end procedure.
procedure add-right :
  define input parameter p-grp-acta-arm-code  as character no-undo .
  define input parameter p-grp-acta-object    as character no-undo .
  define input parameter p-grp-acta-act       as character no-undo .
  define input parameter p-action-item-id     as character no-undo .
  define input parameter p-action-context     as character no-undo .
  define buffer buf_temp-action-item for temp-action-item .
  do transaction
  on error undo, return error return-value
  :
      create buf_temp-action-item .
      assign
        buf_temp-action-item.grp-acta-arm-code  = p-grp-acta-arm-code
        buf_temp-action-item.grp-acta-object    = p-grp-acta-object
        buf_temp-action-item.grp-acta-act       = p-grp-acta-act
        buf_temp-action-item.action-item-id     = p-action-item-id
        buf_temp-action-item.action-context     = p-action-context
      .
  end.
end procedure.
procedure p-right-i :
do
on error undo, return error
:
  if "rus" = "rus":U
  then do:
    run fill-right-rus in this-procedure .
  end.
  else do:
    run fill-right-eng in this-procedure .
  end.
end.
end procedure.
procedure fill-right-rus :
  do
  on error undo, return error return-value
  :
    run add-right in this-procedure ("маг", "отчеты",                                              "печать",                                         "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("общ", "edi_код_GLN",                                         "ИЗМЕНЕНИЕ",                                      "actn_rh-attr-gln_update",                            "global") .
    run add-right in this-procedure ("общ", "edi_работа_по_EDI",                                   "ИЗМЕНЕНИЕ",                                      "actn_rh-attr-edi_update",                            "global") .
    run add-right in this-procedure ("общ", "openxml-subsystem",                                   "ДОБАВЛЕНИЕ",                                     "actn_openxml-subsystem_add-def",                     "object") .
    run add-right in this-procedure ("общ", "openxml-subsystem",                                   "ИЗМЕНЕНИЕ",                                      "actn_openxml-subsystem_update",                      "object") .
    run add-right in this-procedure ("общ", "openxml-subsystem",                                   "ПРОСМОТР",                                       "actn_openxml-subsystem_lookup",                      "object") .
    run add-right in this-procedure ("общ", "openxml-subsystem",                                   "вкл./выкл.",                                     "actn_openxml-subsystem_on-off",                      "object") .
    run add-right in this-procedure ("общ", "openxml-subsystem",                                   "удаление",                                       "actn_openxml-subsystem_deletion",                    "object") .
    run add-right in this-procedure ("общ", "аналитика",                                           "архив",                                          "actn_analitic_archive",                              "firm") .
    run add-right in this-procedure ("общ", "артикул_и_производитель",                             "ИЗМЕНЕНИЕ",                                      "actn_ren-art_update",                                "global") .
    run add-right in this-procedure ("общ", "архив",                                               "ПРОСМОТР",                                       "actn_archive_lookup",                                "object") .
    run add-right in this-procedure ("общ", "архив-межфирм",                                       "ИЗМЕНЕНИЕ",                                      "actn_archive-hold_update",                           "firm") .
    run add-right in this-procedure ("общ", "архив-переоценка",                                    "ИЗМЕНЕНИЕ",                                      "actn_archive-prc_update",                            "object") .
    run add-right in this-procedure ("общ", "архив-поставщик",                                     "ИЗМЕНЕНИЕ",                                      "actn_archive-ahsp_update",                           "object") .
    run add-right in this-procedure ("общ", "архив-приобретение",                                  "ИЗМЕНЕНИЕ",                                      "actn_archive-aht_update",                            "object") .
    run add-right in this-procedure ("общ", "архив-товар",                                         "ИЗМЕНЕНИЕ",                                      "actn_archive-arh_update",                            "object") .
    run add-right in this-procedure ("общ", "банки_и_счета",                                       "ДОБАВЛЕНИЕ",                                     "actn_fin-bank-accounts_add-def",                     "firm") .
    run add-right in this-procedure ("общ", "банки_и_счета",                                       "ИЗМЕНЕНИЕ",                                      "actn_fin-bank-accounts_update",                      "firm") .
    run add-right in this-procedure ("общ", "банки_и_счета",                                       "КОПИРОВАНИЕ",                                    "actn_fin-bank-accounts_add-copy",                    "firm") .
    run add-right in this-procedure ("общ", "банки_и_счета",                                       "удаление",                                       "actn_fin-bank-accounts_deletion",                    "firm") .
    run add-right in this-procedure ("общ", "буг_сервис",                                          "генер-пров",                                     "actn_acc-service_trans-generation",                  "firm") .
    run add-right in this-procedure ("общ", "буг_сервис",                                          "убр-накл-из-списка",                             "actn_acc-service_waybill-clear-list",                "firm") .
    run add-right in this-procedure ("общ", "весы",                                                "удаление",                                       "actn_scales_deletion",                               "global") .
    run add-right in this-procedure ("общ", "весы/группы-товаров",                                 "добавление,удаление",                            "actn_scales-goods-groups_adding-deletion",           "global") .
    run add-right in this-procedure ("общ", "виды-налогов",                                        "ИЗМЕНЕНИЕ",                                      "actn_tax-kinds_update",                              "global") .
    run add-right in this-procedure ("общ", "вывод-накладных-в-файл",                              "печать",                                         "actn_waybills-to-file_print",                        "firm") .
    run add-right in this-procedure ("общ", "группы-товаров-на-кассах",                            "ДОБАВЛЕНИЕ",                                     "actn_group-goods-cash-desk_add-def",                 "object") .
    run add-right in this-procedure ("общ", "группы-товаров-на-кассах",                            "ИЗМЕНЕНИЕ",                                      "actn_group-goods-cash-desk_update",                  "object") .
    run add-right in this-procedure ("общ", "дата-объекта",                                        "ИЗМЕНЕНИЕ",                                      "actn_obj-date-change_update",                        "firm") .
    run add-right in this-procedure ("общ", "документы",                                           "все",                                            "actn_documents_all",                                 "global") .
    run add-right in this-procedure ("общ", "документы",                                           "экспорт",                                        "actn_documents_export",                              "firm") .
    run add-right in this-procedure ("общ", "доп-БК",                                              "scgb",                                           "actn_alt-barcode_gbl-sc-code",                       "global") .
    run add-right in this-procedure ("общ", "доп-БК",                                              "sclc",                                           "actn_alt-barcode_loc-sc-code",                       "global") .
    run add-right in this-procedure ("общ", "доп-БК",                                              "sslc",                                           "actn_alt-barcode_loc-ss-code",                       "global") .
    run add-right in this-procedure ("общ", "доп-БК",                                              "включение",                                      "actn_alt-barcode_turn-on",                           "global") .
    run add-right in this-procedure ("общ", "доп-БК",                                              "подготовка",                                     "actn_alt-barcode_preparation",                       "global") .
    run add-right in this-procedure ("общ", "доставка-хранение",                                   "работа",                                         "actn_delivery-storage_work",                         "global") .
    run add-right in this-procedure ("общ", "ед.измерения",                                        "ИЗМЕНЕНИЕ",                                      "actn_unit_update",                                   "global") .
    run add-right in this-procedure ("общ", "заказ",                                               "ПРОСМОТР",                                       "actn_pmnt-ord-doc_lookup",                           "object") .
    run add-right in this-procedure ("общ", "заказ",                                               "отправка",                                       "actn_pmnt-ord-doc_sending",                          "global") .
    run add-right in this-procedure ("общ", "значения-ставок-налогов",                             "ИЗМЕНЕНИЕ",                                      "actn_tax-rate-values_update",                        "object") .
    run add-right in this-procedure ("общ", "итоги-по-дисконтным-картам",                          "печать",                                         "actn_discount-cards-totals_print",                   "firm") .
    run add-right in this-procedure ("общ", "кассиры",                                             "статистика-по-кассирам",                         "actn_cashiers_stat-on-cashiers",                     "firm") .
    run add-right in this-procedure ("общ", "коды-ставок-налогов",                                 "ИЗМЕНЕНИЕ",                                      "actn_tax-rates_update",                              "firm") .
    run add-right in this-procedure ("общ", "курс-ММВБ",                                           "ИЗМЕНЕНИЕ",                                      "actn_micex-rate_update",                             "global") .
    run add-right in this-procedure ("общ", "курс-ЦБ",                                             "ИЗМЕНЕНИЕ",                                      "actn_cb-rate_update",                                "global") .
    run add-right in this-procedure ("общ", "курс-магазин",                                        "ИЗМЕНЕНИЕ",                                      "actn_shop-rate_update",                              "object") .
    run add-right in this-procedure ("общ", "назначение-прав",                                     "ИЗМЕНЕНИЕ",                                      "actn_rights_update",                                 "global") .
    run add-right in this-procedure ("общ", "обнов-рекв-фин-док",                                  "ИЗМЕНЕНИЕ",                                      "actn_updfind_update",                                "firm") .
    run add-right in this-procedure ("общ", "отчет-по-продажам-постоянным-клиентам",               "печать",                                         "actn_permanent-client-sale_print",                   "firm") .
    run add-right in this-procedure ("общ", "отчет-по-реализации",                                 "печать",                                         "actn_sale-report_print",                             "firm") .
    run add-right in this-procedure ("общ", "отчеты-по-док-там,-продажные-цены",                   "печать",                                         "actn_document-reports-sale_print",                   "firm") .
    run add-right in this-procedure ("общ", "отчеты-по-док-там,-учетные-цены",                     "печать",                                         "actn_document-reports-cost_print",                   "firm") .
    run add-right in this-procedure ("общ", "партии",                                              "все",                                            "actn_parts_all",                                     "firm") .
    run add-right in this-procedure ("общ", "партии",                                              "порождение",                                     "actn_parts_createneg",                               "object") .
    run add-right in this-procedure ("общ", "переоценка,-учетные-цены",                            "печать",                                         "actn_overvalue-cast_print",                          "firm") .
    run add-right in this-procedure ("общ", "платежные документы",                                 "ДОБАВЛЕНИЕ",                                     "actn_bgh-paydocs_add-def",                           "firm") .
    run add-right in this-procedure ("общ", "платежные документы",                                 "ИЗМЕНЕНИЕ",                                      "actn_bgh-paydocs_update",                            "firm") .
    run add-right in this-procedure ("общ", "платежные документы",                                 "ПРОСМОТР",                                       "actn_bgh-paydocs_lookup",                            "firm") .
    run add-right in this-procedure ("общ", "платежные документы",                                 "печать",                                         "actn_bgh-paydocs_print",                             "firm") .
    run add-right in this-procedure ("общ", "платежные документы",                                 "удаление",                                       "actn_bgh-paydocs_deletion",                          "firm") .
    run add-right in this-procedure ("общ", "помесячная-выручка-по-магазинам",                     "печать",                                         "actn_proceeds-monthly_print",                        "firm") .
    run add-right in this-procedure ("общ", "помесячные-обороты-по-производителям",                "печать",                                         "actn_prod-monthly_print",                            "firm") .
    run add-right in this-procedure ("общ", "помесячный-оборот-по-производителю-и-классификатору", "печать",                                         "actn_prod-classifier-monthly_print",                 "firm") .
    run add-right in this-procedure ("общ", "поставка",                                            "ПРОСМОТР",                                       "actn_ord-rcv_lookup",                                "object") .
    run add-right in this-procedure ("общ", "прайс-лист",                                          "печать",                                         "actn_price-list_print",                              "firm") .
    run add-right in this-procedure ("общ", "прайс-лист,вывод-в-файл",                             "печать",                                         "actn_price-list-to-file_print",                      "firm") .
    run add-right in this-procedure ("общ", "при",                                                 "коррекция_закрытых",                             "actn_income_update-closed",                          "object") .
    run add-right in this-procedure ("общ", "при",                                                 "коррекция_сроки_годности",                       "actn_income_update-last-date",                       "object") .
    run add-right in this-procedure ("общ", "примечание-(факт)",                                   "печать",                                         "actn_ps-fact_print",                                 "firm") .
    run add-right in this-procedure ("общ", "принтер кухни",                                       "работа",                                         "actn_fbr-prn_work",                                  "global") .
    run add-right in this-procedure ("общ", "расчет-налогов",                                      "печать",                                         "actn_tax-settlement_print",                          "firm") .
    run add-right in this-procedure ("общ", "реквизиты-клиента",                                   "ввод,изменение",                                 "actn_client-requisite_add-upd",                      "firm") .
    run add-right in this-procedure ("общ", "рт-котроль-цены",                                     "работа",                                         "actn_rt-check-price_work",                           "object") .
    run add-right in this-procedure ("общ", "рт-приемка-товара",                                   "<закрытие документа на факт>",                   "actn_rt-edit-doc_close-fact",                        "object") .
    run add-right in this-procedure ("общ", "рт-приемка-товара",                                   "<закрытие документа>",                           "actn_rt-edit-doc_close-doc",                         "object") .
    run add-right in this-procedure ("общ", "рт-приемка-товара",                                   "ДОБАВЛЕНИЕ",                                     "actn_rt-edit-doc_add-def",                           "object") .
    run add-right in this-procedure ("общ", "рт-приемка-товара",                                   "работа",                                         "actn_rt-edit-doc_work",                              "object") .
    run add-right in this-procedure ("общ", "скидка",                                              "работа",                                         "actn_discount_work",                                 "object") .
    run add-right in this-procedure ("общ", "соб-БК",                                              "подготовка",                                     "actn_main-barcode_preparation",                      "global") .
    run add-right in this-procedure ("общ", "соб-БК",                                              "удаление",                                       "actn_main-barcode_deletion",                         "global") .
    run add-right in this-procedure ("общ", "списки-из-справочников",                              "печать",                                         "actn_reference-lists_print",                         "firm") .
    run add-right in this-procedure ("общ", "список-платежей",                                     "ПРОСМОТР",                                       "actn_payments-reference_lookup",                     "firm") .
    run add-right in this-procedure ("общ", "спр-к_рецептов",                                      "ввод,удал,изм",                                  "actn_recipe-reference_input-deletion-updating",      "object") .
    run add-right in this-procedure ("общ", "спр-к_рецептов",                                      "общ",                                            "actn_recipe-reference_conjoint",                     "object") .
    run add-right in this-procedure ("общ", "справочник",                                          "ИЗМЕНЕНИЕ",                                      "actn_reference_update",                              "global") .
    run add-right in this-procedure ("общ", "справочник",                                          "архив",                                          "actn_reference_archive",                             "firm") .
    run add-right in this-procedure ("общ", "справочник",                                          "изм_группы",                                     "actn_reference_upd-group",                           "global") .
    run add-right in this-procedure ("общ", "справочник",                                          "изм_налогов_на_товар",                           "actn_reference_upd-gds-tax",                         "global") .
    run add-right in this-procedure ("общ", "справочник",                                          "исходная-наценка",                               "actn_reference_calc-increase",                       "global") .
    run add-right in this-procedure ("общ", "справочник",                                          "печать",                                         "actn_reference_print",                               "firm") .
    run add-right in this-procedure ("общ", "справочник",                                          "удаление",                                       "actn_reference_deletion",                            "global") .
    run add-right in this-procedure ("общ", "справочник-акцизные-марки",                           "ИЗМЕНЕНИЕ",                                      "actn_exmark-reference_update",                       "global") .
    run add-right in this-procedure ("общ", "справочник-дис",                                      "ввод,удал,изм",                                  "actn_referense-dis_input-deletion-updating",         "firm") .
    run add-right in this-procedure ("общ", "справочник-кли",                                      "ИЗМЕНЕНИЕ",                                      "actn_client-reference_update",                       "global") .
    run add-right in this-procedure ("общ", "справочник-кли",                                      "ПРОСМОТР",                                       "actn_client-reference_lookup",                       "global") .
    run add-right in this-procedure ("общ", "справочник-кли",                                      "ввод,удал",                                      "actn_client-reference_add-del",                      "global") .
    run add-right in this-procedure ("общ", "справочник-кли-чел",                                  "ввод,удал",                                      "actn_client-reference-prs_add-del",                  "global") .
    run add-right in this-procedure ("общ", "справочник-типов-дис",                                "ввод,удал,изм",                                  "actn_reference-dc-type_input-deletion-updating",     "global") .
    run add-right in this-procedure ("общ", "справочник-топливо",                                  "ИЗМЕНЕНИЕ",                                      "actn_reference-petrolium_update",                    "global") .
    run add-right in this-procedure ("общ", "справочник-услуги",                                   "ИЗМЕНЕНИЕ",                                      "actn_reference-services_update",                     "global") .
    run add-right in this-procedure ("общ", "справочник-услуги",                                   "удаление",                                       "actn_reference-services_deletion",                   "global") .
    run add-right in this-procedure ("общ", "справочник_касс",                                     "ввод,удал,изм",                                  "actn_cashdesk-reference_input-deletion-updating",    "object") .
    run add-right in this-procedure ("общ", "справочник_касс",                                     "вкл./выкл.",                                     "actn_cashdesk-reference_on-off",                     "object") .
    run add-right in this-procedure ("общ", "справочники",                                         "экспорт",                                        "actn_references_export",                             "object") .
    run add-right in this-procedure ("общ", "счет-фактура",                                        "ДОБАВЛЕНИЕ",                                     "actn_invoice_add-def",                               "object") .
    run add-right in this-procedure ("общ", "счет-фактура",                                        "удаление",                                       "actn_invoice_deletion",                              "object") .
    run add-right in this-procedure ("общ", "счета-фактуры",                                       "ДОБАВЛЕНИЕ",                                     "actn_schet-fact-doc_add-def",                        "firm") .
    run add-right in this-procedure ("общ", "счета-фактуры",                                       "ИЗМЕНЕНИЕ",                                      "actn_schet-fact-doc_update",                         "firm") .
    run add-right in this-procedure ("общ", "счета-фактуры",                                       "ПРОСМОТР",                                       "actn_schet-fact-doc_lookup",                         "firm") .
    run add-right in this-procedure ("общ", "счета-фактуры",                                       "закрыть",                                        "actn_schet-fact-doc_close",                          "firm") .
    run add-right in this-procedure ("общ", "счета-фактуры",                                       "открыть",                                        "actn_schet-fact-doc_open",                           "firm") .
    run add-right in this-procedure ("общ", "счета-фактуры",                                       "удаление",                                       "actn_schet-fact-doc_deletion",                       "firm") .
    run add-right in this-procedure ("общ", "счета-фактуры",                                       "экспорт",                                        "actn_schet-fact-doc_export",                         "firm") .
    run add-right in this-procedure ("общ", "удал_документы",                                      "все",                                            "actn_c-documents_all",                               "object") .
    run add-right in this-procedure ("общ", "фин_договор",                                         "ПРОСМОТР",                                       "actn_fin-contract_lookup",                           "firm") .
    run add-right in this-procedure ("общ", "чеки",                                                "удаление",                                       "actn_receipts_deletion",                             "object") .
    run add-right in this-procedure ("общ", "чеки-МЦ",                                             "ИЗМЕНЕНИЕ",                                      "actn_wth-receipts_update",                           "object") .
    run add-right in this-procedure ("общ", "чеки-МЦ",                                             "ПРОСМОТР",                                       "actn_wth-receipts_lookup",                           "object") .
    run add-right in this-procedure ("общ", "чеки-МЦ",                                             "удаление",                                       "actn_wth-receipts_deletion",                         "object") .
    run add-right in this-procedure ("общ", "чеки-и-выручка",                                      "печать",                                         "actn_cur-obj-proceeds_print",                        "firm") .
    run add-right in this-procedure ("объ", "hold_возврат",                                        "удаление документа закрытого на факт",           "actn_hold-return_del-fact",                          "object") .
    run add-right in this-procedure ("объ", "hold_при",                                            "удаление документа закрытого на факт",           "actn_hold-income_del-fact",                          "object") .
    run add-right in this-procedure ("объ", "hold_рас",                                            "подготовка",                                     "actn_hold-expense_preparation",                      "object") .
    run add-right in this-procedure ("объ", "hold_рас",                                            "удаление документа закрытого на факт",           "actn_hold-expense_del-fact",                         "object") .
    run add-right in this-procedure ("объ", "Документ перемещения МЦ",                             "ДОБАВЛЕНИЕ",                                     "actn_wth-doc_add-def",                               "object") .
    run add-right in this-procedure ("объ", "Документ перемещения МЦ",                             "ИЗМЕНЕНИЕ",                                      "actn_wth-doc_update",                                "object") .
    run add-right in this-procedure ("объ", "Документ перемещения МЦ",                             "ПРОСМОТР",                                       "actn_wth-doc_lookup",                                "object") .
    run add-right in this-procedure ("объ", "Документ перемещения МЦ",                             "печать",                                         "actn_wth-doc_print",                                 "object") .
    run add-right in this-procedure ("объ", "Документ перемещения МЦ",                             "удаление документа закрытого на факт",           "actn_wth-doc_del-fact",                              "object") .
    run add-right in this-procedure ("объ", "Документ перемещения МЦ",                             "удаление",                                       "actn_wth-doc_deletion",                              "object") .
    run add-right in this-procedure ("объ", "Объект-Объект",                                       "ДОБАВЛЕНИЕ",                                     "actn_o-o_add-def",                                   "object") .
    run add-right in this-procedure ("объ", "Объект-Объект",                                       "ИЗМЕНЕНИЕ",                                      "actn_o-o_update",                                    "object") .
    run add-right in this-procedure ("объ", "Объект-Объект",                                       "удаление",                                       "actn_o-o_deletion",                                  "object") .
    run add-right in this-procedure ("объ", "архив",                                               "учет",                                           "actn_archive_cost",                                  "object") .
    run add-right in this-procedure ("объ", "весовой-код-на-объекте",                              "ИЗМЕНЕНИЕ",                                      "actn_object-weight-code_update",                     "object") .
    run add-right in this-procedure ("объ", "весы",                                                "ИЗМЕНЕНИЕ",                                      "actn_scales_update",                                 "global") .
    run add-right in this-procedure ("объ", "весы",                                                "отправка",                                       "actn_scales_sending",                                "global") .
    run add-right in this-procedure ("объ", "возврат",                                             "reserv",                                         "actn_return_rsrv-dtl-action-reserv",                 "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "ПРОСМОТР",                                       "actn_return_lookup",                                 "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "добавление документа задним числом",             "actn_return_add-back-date",                          "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "добавление топлива в документ задним числом",    "actn_return_add-ptrl-back-date",                     "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "открытие",                                       "actn_return_opening",                                "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "отмена-разр",                                    "actn_return_perm-cancellation",                      "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "печать",                                         "actn_return_print",                                  "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "подготовка",                                     "actn_return_preparation",                            "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "подготовка-по-собств-фирме",                     "actn_return_prepownfirmhold",                        "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "разрешение",                                     "actn_return_permission",                             "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "удаление документа закрытого на факт",           "actn_return_del-fact",                               "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "удаление документа по топливу в прошлых сменах", "actn_return_del-ptrl-prev-shft",                     "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "факт",                                           "actn_return_fact",                                   "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "цена",                                           "actn_return_price",                                  "object") .
    run add-right in this-procedure ("объ", "дата_на_объекте",                                     "ИЗМЕНЕНИЕ",                                      "actn_object-date_update",                            "object") .
    run add-right in this-procedure ("объ", "заказ",                                               "ДОБАВЛЕНИЕ",                                     "actn_pmnt-ord-doc_add-def",                          "object") .
    run add-right in this-procedure ("объ", "заказ",                                               "ИЗМЕНЕНИЕ",                                      "actn_pmnt-ord-doc_update",                           "object") .
    run add-right in this-procedure ("объ", "заказ",                                               "ПРОСМОТР",                                       "actn_pmnt-ord-doc_lookup",                           "object") .
    run add-right in this-procedure ("объ", "заказ",                                               "удаление",                                       "actn_pmnt-ord-doc_deletion",                         "object") .
    run add-right in this-procedure ("объ", "значения-ставок-налогов",                             "ИЗМЕНЕНИЕ",                                      "actn_tax-rate-values_update",                        "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "ПРОСМОТР",                                       "actn_inventory_lookup",                              "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "открытие",                                       "actn_inventory_opening",                             "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "печать",                                         "actn_inventory_print",                               "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "подготовка",                                     "actn_inventory_preparation",                         "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "разрешение",                                     "actn_inventory_permission",                          "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "редакт-факт",                                    "actn_inventory_fact-edit",                           "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "резервы",                                        "actn_inventory_reserves",                            "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "удаление документа закрытого на факт",           "actn_inventory_del-fact",                            "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "факт",                                           "actn_inventory_fact",                                "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "добавление задним числом",                       "actn_inventory_add-back-date",                       "object") .
    run add-right in this-procedure ("объ", "инв-сч-трк",                                          "ПРОСМОТР",                                       "actn_icnt-doc_lookup",                               "object") .
    run add-right in this-procedure ("объ", "инв-сч-трк",                                          "изм-эл-сч",                                      "actn_icnt-doc_upd-el-cnt",                           "object") .
    run add-right in this-procedure ("объ", "инв-сч-трк",                                          "печать",                                         "actn_icnt-doc_print",                                "object") .
    run add-right in this-procedure ("объ", "инв-сч-трк",                                          "подготовка",                                     "actn_icnt-doc_preparation",                          "object") .
    run add-right in this-procedure ("объ", "инв-сч-трк",                                          "удаление",                                       "actn_icnt-doc_deletion",                             "object") .
    run add-right in this-procedure ("объ", "инв-сч-трк",                                          "факт",                                           "actn_icnt-doc_fact",                                 "object") .
    run add-right in this-procedure ("объ", "карты-клиента",                                       "ввод-платежа",                                   "actn_client-cards_payment-input",                    "object") .
    run add-right in this-procedure ("объ", "карты-клиента",                                       "удаление-платежа",                               "actn_client-cards_payment-deletion",                 "object") .
    run add-right in this-procedure ("объ", "касса/группы товаров",                                "ИЗМЕНЕНИЕ",                                      "actn_cashdesk-goods-groups_update",                  "object") .
    run add-right in this-procedure ("объ", "касса/кассиры",                                       "ИЗМЕНЕНИЕ",                                      "actn_cashdesk-cashiers_update",                      "object") .
    run add-right in this-procedure ("объ", "касса/категории_и_ставки_налогов",                    "ДОБАВЛЕНИЕ",                                     "actn_cashdesk-taxn_add-def",                         "object") .
    run add-right in this-procedure ("объ", "касса/категории_и_ставки_налогов",                    "удаление",                                       "actn_cashdesk-taxn_deletion",                        "object") .
    run add-right in this-procedure ("объ", "касса/клиенты",                                       "ДОБАВЛЕНИЕ",                                     "actn_cashdesk-clients_add-def",                      "object") .
    run add-right in this-procedure ("объ", "касса/клиенты",                                       "удаление",                                       "actn_cashdesk-clients_deletion",                     "object") .
    run add-right in this-procedure ("объ", "касса/курсы",                                         "ИЗМЕНЕНИЕ",                                      "actn_cashdesk-rates_update",                         "object") .
    run add-right in this-procedure ("объ", "касса/налоги_на_товар",                               "ДОБАВЛЕНИЕ",                                     "actn_cashdesk-taxg_add-def",                         "object") .
    run add-right in this-procedure ("объ", "касса/налоги_на_товар",                               "удаление",                                       "actn_cashdesk-taxg_deletion",                        "object") .
    run add-right in this-procedure ("объ", "касса/платежи",                                       "ДОБАВЛЕНИЕ",                                     "actn_cashdesk-payments_add-def",                     "object") .
    run add-right in this-procedure ("объ", "касса/платежи",                                       "удаление",                                       "actn_cashdesk-payments_deletion",                    "object") .
    run add-right in this-procedure ("объ", "касса/продавцы",                                      "ИЗМЕНЕНИЕ",                                      "actn_cashdesk-sellers_update",                       "object") .
    run add-right in this-procedure ("объ", "касса/скидки_на_итог",                                "ДОБАВЛЕНИЕ",                                     "actn_cashdesk-discnt-total_add-def",                 "object") .
    run add-right in this-procedure ("объ", "касса/скидки_на_итог",                                "удаление",                                       "actn_cashdesk-discnt-total_deletion",                "object") .
    run add-right in this-procedure ("объ", "касса/товары",                                        "ДОБАВЛЕНИЕ",                                     "actn_cashdesk-goods_add-def",                        "object") .
    run add-right in this-procedure ("объ", "касса/товары",                                        "удаление",                                       "actn_cashdesk-goods_deletion",                       "object") .
    run add-right in this-procedure ("объ", "контроль",                                            "ПРОСМОТР",                                       "actn_rvs-control_lookup",                            "object") .
    run add-right in this-procedure ("объ", "контроль",                                            "изменение-сверки",                               "actn_rvs-control_upd-revision",                      "object") .
    run add-right in this-procedure ("объ", "контроль",                                            "печать",                                         "actn_rvs-control_print",                             "object") .
    run add-right in this-procedure ("объ", "контроль",                                            "создание-сверки",                                "actn_rvs-control_cr-revision",                       "object") .
    run add-right in this-procedure ("объ", "контроль",                                            "удаление документа закрытого на факт",           "actn_rvs-control_del-fact",                          "object") .
    run add-right in this-procedure ("объ", "контроль",                                            "удаление",                                       "actn_rvs-control_deletion",                          "object") .
    run add-right in this-procedure ("объ", "контроль",                                            "факт",                                           "actn_rvs-control_fact",                              "object") .
    run add-right in this-procedure ("объ", "куц",                                                 "подготовка",                                     "actn_corr-acc-pr-view_preparation",                  "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "отчет_benet1",                                   "actn_reports_report-benet1",                         "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "отчет_benet2",                                   "actn_reports_report-benet2",                         "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "отчет_benet3",                                   "actn_reports_report-benet3",                         "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "отчет_benet4",                                   "actn_reports_report-benet4",                         "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "отчет_benet5",                                   "actn_reports_report-benet5",                         "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "отчет_g-ben-dt",                                 "actn_reports_report-benet6",                         "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "продажные_цены",                                 "actn_reports_lookup-crsa",                           "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "учетные_цены",                                   "actn_reports_lookup-cost",                           "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "цены_документа",                                 "actn_reports_lookup-sale",                           "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "цены_посредника",                                "actn_reports_lookup-medi",                           "object") .
    run add-right in this-procedure ("объ", "партии",                                              "разбиение-слияние",                              "actn_parts_split-fuse",                              "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "ИЗМЕНЕНИЕ",                                      "actn_overvalue_update",                              "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "ПРОСМОТР",                                       "actn_overvalue_lookup",                              "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "приказ",                                         "actn_overvalue_order",                               "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "печать",                                         "actn_overvalue_print",                               "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "подготовка",                                     "actn_overvalue_preparation",                         "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "признаки",                                       "actn_overvalue_properties",                          "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "разрешение",                                     "actn_overvalue_permission",                          "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "скидка",                                         "actn_overvalue_discount",                            "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "факт",                                           "actn_overvalue_fact",                                "object") .
    run add-right in this-procedure ("объ", "по_док",                                              "ПРОСМОТР",                                       "actn_rvs-on-doc_lookup",                             "object") .
    run add-right in this-procedure ("объ", "по_док",                                              "изменение-сверки",                               "actn_rvs-on-doc_upd-revision",                       "object") .
    run add-right in this-procedure ("объ", "по_док",                                              "печать",                                         "actn_rvs-on-doc_print",                              "object") .
    run add-right in this-procedure ("объ", "по_док",                                              "создание-сверки",                                "actn_rvs-on-doc_cr-revision",                        "object") .
    run add-right in this-procedure ("объ", "по_док",                                              "удаление",                                       "actn_rvs-on-doc_deletion",                           "object") .
    run add-right in this-procedure ("объ", "по_док",                                              "факт",                                           "actn_rvs-on-doc_fact",                               "object") .
    run add-right in this-procedure ("объ", "поставка",                                            "ДОБАВЛЕНИЕ",                                     "actn_ord-rcv_add-def",                               "object") .
    run add-right in this-procedure ("объ", "поставка",                                            "ИЗМЕНЕНИЕ",                                      "actn_ord-rcv_update",                                "object") .
    run add-right in this-procedure ("объ", "поставка",                                            "ПРОСМОТР",                                       "actn_ord-rcv_lookup",                                "object") .
    run add-right in this-procedure ("объ", "поставка",                                            "накладная",                                      "actn_ord-rcv_h-wbill",                               "object") .
    run add-right in this-procedure ("объ", "поставка",                                            "удаление",                                       "actn_ord-rcv_deletion",                              "object") .
    run add-right in this-procedure ("объ", "при",                                                 "import",                                         "actn_income_import",                                 "object") .
    run add-right in this-procedure ("объ", "при",                                                 "ПРОСМОТР",                                       "actn_income_lookup",                                 "object") .
    run add-right in this-procedure ("объ", "при",                                                 "добавление документа задним числом",             "actn_income_add-back-date",                          "object") .
    run add-right in this-procedure ("объ", "при",                                                 "добавление топлива в документ задним числом",    "actn_income_add-ptrl-back-date",                     "object") .
    run add-right in this-procedure ("объ", "при",                                                 "открытие",                                       "actn_income_opening",                                "object") .
    run add-right in this-procedure ("объ", "при",                                                 "открытие-запроса",                               "actn_income_opening-inquiry",                        "object") .
    run add-right in this-procedure ("объ", "при",                                                 "печать",                                         "actn_income_print",                                  "object") .
    run add-right in this-procedure ("объ", "при",                                                 "подготовка",                                     "actn_income_preparation",                            "object") .
    run add-right in this-procedure ("объ", "при",                                                 "подготовка-по-собств-фирме",                     "actn_income_prepownfirmhold",                        "object") .
    run add-right in this-procedure ("объ", "при",                                                 "удаление документа закрытого на факт",           "actn_income_del-fact",                               "object") .
    run add-right in this-procedure ("объ", "при",                                                 "удаление документа по топливу в прошлых сменах", "actn_income_del-ptrl-prev-shft",                     "object") .
    run add-right in this-procedure ("объ", "при",                                                 "факт",                                           "actn_income_fact",                                   "object") .
    run add-right in this-procedure ("объ", "принтер кухни/товары",                                "работа",                                         "actn_fbr-prn-goods_work",                            "object") .
    run add-right in this-procedure ("объ", "продажа",                                             "ПРОСМОТР",                                       "actn_sale_lookup",                                   "object") .
    run add-right in this-procedure ("объ", "продажа",                                             "удаление продажи закрытой на факт",              "actn_sale_del-sale-fact",                            "object") .
    run add-right in this-procedure ("объ", "продажа",                                             "факт",                                           "actn_sale_fact",                                     "object") .
    run add-right in this-procedure ("объ", "производство",                                        "ПРОСМОТР",                                       "actn_manufacturing_lookup",                          "object") .
    run add-right in this-procedure ("объ", "производство",                                        "альтернатива",                                   "actn_manufacturing_alternative",                     "object") .
    run add-right in this-procedure ("объ", "производство",                                        "комплектация",                                   "actn_manufacturing_gathering",                       "object") .
    run add-right in this-procedure ("объ", "производство",                                        "печать",                                         "actn_manufacturing_print",                           "object") .
    run add-right in this-procedure ("объ", "производство",                                        "подготовка",                                     "actn_manufacturing_preparation",                     "object") .
    run add-right in this-procedure ("объ", "производство",                                        "прод.ц.ингр",                                    "actn_manufacturing_price-sale-ingr",                 "object") .
    run add-right in this-procedure ("объ", "производство",                                        "прод.ц.сост",                                    "actn_manufacturing_price-sale-comp",                 "object") .
    run add-right in this-procedure ("объ", "производство",                                        "производство",                                   "actn_manufacturing_manufacturing",                   "object") .
    run add-right in this-procedure ("объ", "производство",                                        "разделка",                                       "actn_manufacturing_dressing",                        "object") .
    run add-right in this-procedure ("объ", "производство",                                        "свободно",                                       "actn_manufacturing_free",                            "object") .
    run add-right in this-procedure ("объ", "производство",                                        "свободно,ИЗМЕНЕНИЕ",                             "actn_manufacturing_free-update",                     "object") .
    run add-right in this-procedure ("объ", "производство",                                        "удаление производства закрытого на факт",        "actn_manufacturing_del-manuf-fact",                  "object") .
    run add-right in this-procedure ("объ", "производство",                                        "факт",                                           "actn_manufacturing_fact",                            "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "reserv",                                         "actn_expense_rsrv-dtl-action-reserv",                "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "ПРОСМОТР",                                       "actn_expense_lookup",                                "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "добавление документа задним числом",             "actn_expense_add-back-date",                         "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "добавление топлива в документ задним числом",    "actn_expense_add-ptrl-back-date",                    "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "отгрузка",                                       "actn_expense_shipping",                              "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "открытие",                                       "actn_expense_opening",                               "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "отмена-разр",                                    "actn_expense_perm-cancellation",                     "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "печать",                                         "actn_expense_print",                                 "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "подготовка",                                     "actn_expense_preparation",                           "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "подготовка-по-собств-фирме",                     "actn_expense_prepownfirmhold",                       "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "право на закрытие расхода ниже учетной цен",     "actn_expense_chkslpr",                               "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "разрешение",                                     "actn_expense_permission",                            "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "удаление документа закрытого на факт",           "actn_expense_del-fact",                              "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "удаление документа по топливу в прошлых сменах", "actn_expense_del-ptrl-prev-shft",                    "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "факт",                                           "actn_expense_fact",                                  "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "цена",                                           "actn_expense_price",                                 "object") .
    run add-right in this-procedure ("объ", "расход внутренний",                                   "удаление документа закрытого на факт",           "actn_tdedt-ras-perem_del-fact",                      "object") .
    run add-right in this-procedure ("объ", "смена",                                               "ПРОСМОТР",                                       "actn_rvs-shift_lookup",                              "object") .
    run add-right in this-procedure ("объ", "смена",                                               "изменение-сверки",                               "actn_rvs-shift_upd-revision",                        "object") .
    run add-right in this-procedure ("объ", "смена",                                               "печать",                                         "actn_rvs-shift_print",                               "object") .
    run add-right in this-procedure ("объ", "смена",                                               "режим-менеджера",                                "actn_shift_super",                                   "object") .
    run add-right in this-procedure ("объ", "смена",                                               "создание-сверки",                                "actn_rvs-shift_cr-revision",                         "object") .
    run add-right in this-procedure ("объ", "смена",                                               "удаление",                                       "actn_rvs-shift_deletion",                            "object") .
    run add-right in this-procedure ("объ", "смена",                                               "факт",                                           "actn_rvs-shift_fact",                                "object") .
    run add-right in this-procedure ("объ", "смена",                                               "штатный-режим",                                  "actn_shift_regular",                                 "object") .
    run add-right in this-procedure ("объ", "создание-чека",                                       "ввод",                                           "actn_receipt_input",                                 "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "reserv",                                         "actn_write-off_rsrv-dtl-action-reserv",              "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "ПРОСМОТР",                                       "actn_write-off_lookup",                              "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "добавление документа задним числом",             "actn_write-off_add-back-date",                       "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "добавление топлива в документ задним числом",    "actn_write-off_add-ptrl-back-date",                  "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "отгрузка",                                       "actn_write-off_shipping",                            "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "открытие",                                       "actn_write-off_opening",                             "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "отмена-разр",                                    "actn_write-off_perm-cancellation",                   "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "печать",                                         "actn_write-off_print",                               "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "подготовка",                                     "actn_write-off_preparation",                         "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "разрешение",                                     "actn_write-off_permission",                          "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "удаление документа закрытого на факт",           "actn_write-off_del-fact",                            "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "удаление документа по топливу в прошлых сменах", "actn_write-off_del-ptrl-prev-shft",                  "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "факт",                                           "actn_write-off_fact",                                "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "цена",                                           "actn_write-off_price",                               "object") .
    run add-right in this-procedure ("объ", "справочник мест отгрузки\приемки",                    "ДОБАВЛЕНИЕ",                                     "actn_place-io-reference_add-def",                    "object") .
    run add-right in this-procedure ("объ", "справочник мест отгрузки\приемки",                    "ИЗМЕНЕНИЕ",                                      "actn_place-io-reference_update",                     "object") .
    run add-right in this-procedure ("объ", "справочник мест отгрузки\приемки",                    "удаление",                                       "actn_place-io-reference_deletion",                   "object") .
    run add-right in this-procedure ("объ", "справочник пунктов отгрузки\доставки",                "ДОБАВЛЕНИЕ",                                     "actn_point-io-reference_add-def",                    "global") .
    run add-right in this-procedure ("объ", "справочник пунктов отгрузки\доставки",                "ИЗМЕНЕНИЕ",                                      "actn_point-io-reference_update",                     "global") .
    run add-right in this-procedure ("объ", "справочник пунктов отгрузки\доставки",                "удаление",                                       "actn_point-io-reference_deletion",                   "global") .
    run add-right in this-procedure ("объ", "справочник-ТРК",                                      "работа",                                         "actn_pump-reference_work",                           "object") .
    run add-right in this-procedure ("объ", "справочник-места-хранения-МЦ",                        "работа",                                         "actn_wth-place-reference_work",                      "object") .
    run add-right in this-procedure ("объ", "справочник-складские-места",                          "работа",                                         "actn_place-reference_work",                          "global") .
    run add-right in this-procedure ("объ", "справочник_касс",                                     "ИЗМЕНЕНИЕ",                                      "actn_cashdesk-reference_update",                     "object") .
    run add-right in this-procedure ("объ", "срок",                                                "запросы",                                        "actn_period_inquires",                               "object") .
    run add-right in this-procedure ("объ", "срок",                                                "резервы",                                        "actn_period_reserves",                               "object") .
    run add-right in this-procedure ("объ", "статус-скл_места-трк_товар",                          "работа",                                         "actn_plgdspm-sts_work",                              "object") .
    run add-right in this-procedure ("объ", "счет-фактура",                                        "ИЗМЕНЕНИЕ общ счет-фактура ИЗМЕНЕНИЕ",           "actn_invoice_update",                                "object") .
    run add-right in this-procedure ("объ", "счет-фактура",                                        "ПРОСМОТР общ счет-фактура ПРОСМОТР",             "actn_invoice_lookup",                                "object") .
    run add-right in this-procedure ("объ", "счет-фактура",                                        "печать общ счет-фактура печать",                 "actn_invoice_print",                                 "object") .
    run add-right in this-procedure ("объ", "счет-фактура",                                        "подготовка",                                     "actn_invoice_preparation",                           "object") .
    run add-right in this-procedure ("объ", "чек-МЦ",                                              "ввод",                                           "actn_wth-receipt_input",                             "object") .
    run add-right in this-procedure ("осн", "вариант операций ОС",                                 "ДОБАВЛЕНИЕ",                                     "actn_os-oper-var_add-def",                           "firm") .
    run add-right in this-procedure ("осн", "вариант операций ОС",                                 "ИЗМЕНЕНИЕ",                                      "actn_os-oper-var_update",                            "firm") .
    run add-right in this-procedure ("осн", "вариант операций ОС",                                 "удаление",                                       "actn_os-oper-var_deletion",                          "firm") .
    run add-right in this-procedure ("осн", "вид деятельности",                                    "ДОБАВЛЕНИЕ",                                     "actn_os-act-kind_add-def",                           "firm") .
    run add-right in this-procedure ("осн", "вид деятельности",                                    "ИЗМЕНЕНИЕ",                                      "actn_os-act-kind_update",                            "firm") .
    run add-right in this-procedure ("осн", "вид деятельности",                                    "удаление",                                       "actn_os-act-kind_deletion",                          "firm") .
    run add-right in this-procedure ("осн", "группа налогового учета",                             "ДОБАВЛЕНИЕ",                                     "actn_os-group-tax_add-def",                          "firm") .
    run add-right in this-procedure ("осн", "группа налогового учета",                             "ИЗМЕНЕНИЕ",                                      "actn_os-group-tax_update",                           "firm") .
    run add-right in this-procedure ("осн", "группа налогового учета",                             "удаление",                                       "actn_os-group-tax_deletion",                         "firm") .
    run add-right in this-procedure ("осн", "группы-ОС",                                           "ДОБАВЛЕНИЕ",                                     "actn_fixed-assets-groups_add-def",                   "firm") .
    run add-right in this-procedure ("осн", "группы-ОС",                                           "ИЗМЕНЕНИЕ",                                      "actn_fixed-assets-groups_update",                    "firm") .
    run add-right in this-procedure ("осн", "группы-ОС",                                           "удаление",                                       "actn_fixed-assets-groups_deletion",                  "firm") .
    run add-right in this-procedure ("осн", "карточки-МБП",                                        "ДОБАВЛЕНИЕ",                                     "actn_supplies-cards_add-def",                        "firm") .
    run add-right in this-procedure ("осн", "карточки-МБП",                                        "ИЗМЕНЕНИЕ",                                      "actn_supplies-cards_update",                         "firm") .
    run add-right in this-procedure ("осн", "карточки-МБП",                                        "ликв/вост",                                      "actn_supplies-cards_disposition-reconstruction",     "firm") .
    run add-right in this-procedure ("осн", "карточки-МБП",                                        "модернизация",                                   "actn_supplies-cards_modernization",                  "firm") .
    run add-right in this-procedure ("осн", "карточки-МБП",                                        "перемещение",                                    "actn_supplies-cards_displacement",                   "firm") .
    run add-right in this-procedure ("осн", "карточки-МБП",                                        "удаление",                                       "actn_supplies-cards_deletion",                       "firm") .
    run add-right in this-procedure ("осн", "карточки-Материалов",                                 "ДОБАВЛЕНИЕ",                                     "actn_row-cards_add-def",                             "firm") .
    run add-right in this-procedure ("осн", "карточки-Материалов",                                 "ИЗМЕНЕНИЕ",                                      "actn_row-cards_update",                              "firm") .
    run add-right in this-procedure ("осн", "карточки-Материалов",                                 "ликв/вост",                                      "actn_row-cards_disposition-reconstruction",          "firm") .
    run add-right in this-procedure ("осн", "карточки-Материалов",                                 "перемещение",                                    "actn_row-cards_displacement",                        "firm") .
    run add-right in this-procedure ("осн", "карточки-Материалов",                                 "удаление",                                       "actn_row-cards_deletion",                            "firm") .
    run add-right in this-procedure ("осн", "карточки-ОС",                                         "ДОБАВЛЕНИЕ",                                     "actn_fixed-assets-cards_add-def",                    "firm") .
    run add-right in this-procedure ("осн", "карточки-ОС",                                         "ИЗМЕНЕНИЕ",                                      "actn_fixed-assets-cards_update",                     "firm") .
    run add-right in this-procedure ("осн", "карточки-ОС",                                         "ликв/вост",                                      "actn_fixed-assets-cards_disposition-reconstruction", "firm") .
    run add-right in this-procedure ("осн", "карточки-ОС",                                         "модернизация",                                   "actn_fixed-assets-cards_modernization",              "firm") .
    run add-right in this-procedure ("осн", "карточки-ОС",                                         "перемещение",                                    "actn_fixed-assets-cards_displacement",               "firm") .
    run add-right in this-procedure ("осн", "карточки-ОС",                                         "переоценка",                                     "actn_fixed-assets-cards_overvalue",                  "firm") .
    run add-right in this-procedure ("осн", "карточки-ОС",                                         "печать-карточки",                                "actn_fixed-assets-cards_card-print",                 "firm") .
    run add-right in this-procedure ("осн", "карточки-ОС",                                         "удаление",                                       "actn_fixed-assets-cards_deletion",                   "firm") .
    run add-right in this-procedure ("осн", "нормы-амортизации",                                   "ДОБАВЛЕНИЕ",                                     "actn_depreciation-rate_add-def",                     "firm") .
    run add-right in this-procedure ("осн", "нормы-амортизации",                                   "ИЗМЕНЕНИЕ",                                      "actn_depreciation-rate_update",                      "firm") .
    run add-right in this-procedure ("осн", "нормы-амортизации",                                   "удаление",                                       "actn_depreciation-rate_deletion",                    "firm") .
    run add-right in this-procedure ("осн", "отчеты",                                              "печать",                                         "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("осн", "первичный документ ОС",                               "ДОБАВЛЕНИЕ",                                     "actn_os-src-docs_add-def",                           "firm") .
    run add-right in this-procedure ("осн", "первичный документ ОС",                               "ИЗМЕНЕНИЕ",                                      "actn_os-src-docs_update",                            "firm") .
    run add-right in this-procedure ("осн", "первичный документ ОС",                               "удаление",                                       "actn_os-src-docs_deletion",                          "firm") .
    run add-right in this-procedure ("осн", "печатная форма ОС",                                   "ДОБАВЛЕНИЕ",                                     "actn_os-frm-docs_add-def",                           "firm") .
    run add-right in this-procedure ("осн", "печатная форма ОС",                                   "ИЗМЕНЕНИЕ",                                      "actn_os-frm-docs_update",                            "firm") .
    run add-right in this-procedure ("осн", "печатная форма ОС",                                   "удаление",                                       "actn_os-frm-docs_deletion",                          "firm") .
    run add-right in this-procedure ("осн", "тип операций ОС",                                     "ДОБАВЛЕНИЕ",                                     "actn_os-oper-type_add-def",                          "firm") .
    run add-right in this-procedure ("осн", "тип операций ОС",                                     "ИЗМЕНЕНИЕ",                                      "actn_os-oper-type_update",                           "firm") .
    run add-right in this-procedure ("осн", "тип операций ОС",                                     "удаление",                                       "actn_os-oper-type_deletion",                         "firm") .
    run add-right in this-procedure ("офи", "МЦ",                                                  "работа",                                         "actn_wealth_work",                                   "global") .
    run add-right in this-procedure ("офи", "группа-клиентов",                                     "скидка",                                         "actn_clients-group_discount",                        "global") .
    run add-right in this-procedure ("офи", "книга-покупок",                                       "печать",                                         "actn_purchase-book_print",                           "firm") .
    run add-right in this-procedure ("офи", "книга-продаж",                                        "печать",                                         "actn_sales-book_print",                              "firm") .
    run add-right in this-procedure ("офи", "оплаты",                                              "ИЗМЕНЕНИЕ",                                      "actn_payments_update",                               "global") .
    run add-right in this-procedure ("офи", "отчеты",                                              "печать",                                         "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("офи", "платежи-ожидаемые",                                   "работа",                                         "actn_payments-expected_work",                        "firm") .
    run add-right in this-procedure ("офи", "справочник",                                          "изменение-групп",                                "actn_reference_groups-edit",                         "global") .
    run add-right in this-procedure ("офи", "справочник-валют",                                    "работа",                                         "actn_currency-reference_work",                       "global") .
    run add-right in this-procedure ("офи", "справочник-стран",                                    "работа",                                         "actn_country-reference_work",                        "global") .
    run add-right in this-procedure ("офи", "типы-платежей",                                       "ввод,удал,изм",                                  "actn_payments-types_input-deletion-updating",        "global") .
    run add-right in this-procedure ("офи", "фин_обязательства",                                   "ПРОСМОТР",                                       "actn_fin-liability_lookup",                          "firm") .
    run add-right in this-procedure ("офи", "шкалы",                                               "ИЗМЕНЕНИЕ",                                      "actn_scale_update",                                  "global") .
    run add-right in this-procedure ("рес", "касса/ресторан",                                      "работа",                                         "actn_cashdesk-restaurant_work",                      "firm") .
    run add-right in this-procedure ("рес", "отчеты",                                              "печать",                                         "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("рес", "рес_автопроизводство",                                "работа",                                         "actn_res-autofbr_work",                              "firm") .
    run add-right in this-procedure ("рес", "рес_печать",                                          "печать",                                         "actn_res-print_print",                               "firm") .
    run add-right in this-procedure ("рес", "рес_план-меню",                                       "ИЗМЕНЕНИЕ",                                      "actn_res-pln-menu_update",                           "firm") .
    run add-right in this-procedure ("рес", "рес_план-меню",                                       "ПРОСМОТР",                                       "actn_res-pln-menu_lookup",                           "firm") .
    run add-right in this-procedure ("рес", "рес_справочник",                                      "ИЗМЕНЕНИЕ",                                      "actn_res-reference_update",                          "firm") .
    run add-right in this-procedure ("рес", "рес_справочник",                                      "ПРОСМОТР",                                       "actn_res-reference_lookup",                          "firm") .
    run add-right in this-procedure ("скл", "отчеты",                                              "печать",                                         "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("скл", "печать-в-набор",                                      "печать",                                         "actn_composition-print_print",                       "firm") .
    run add-right in this-procedure ("скл", "печать-в-набор,-повторно",                            "печать",                                         "actn_composition-reprint_print",                     "firm") .
    run add-right in this-procedure ("фин", "апп",                                                 "<закрытие документа на факт>",                   "actn_income-payoff_close-fact",                      "firm") .
    run add-right in this-procedure ("фин", "апп",                                                 "<закрытие документа>",                           "actn_income-payoff_close-doc",                       "firm") .
    run add-right in this-procedure ("фин", "апп",                                                 "<открытие документа>",                           "actn_income-payoff_open-doc",                        "firm") .
    run add-right in this-procedure ("фин", "апр",                                                 "<закрытие документа на факт>",                   "actn_expense-payoff_close-fact",                     "firm") .
    run add-right in this-procedure ("фин", "апр",                                                 "<закрытие документа>",                           "actn_expense-payoff_close-doc",                      "firm") .
    run add-right in this-procedure ("фин", "апр",                                                 "<открытие документа>",                           "actn_expense-payoff_open-doc",                       "firm") .
    run add-right in this-procedure ("фин", "отчеты",                                              "печать",                                         "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("фин", "пко",                                                 "<закрытие документа на факт>",                   "actn_income-cash_close-fact",                        "firm") .
    run add-right in this-procedure ("фин", "пко",                                                 "<закрытие документа>",                           "actn_income-cash_close-doc",                         "firm") .
    run add-right in this-procedure ("фин", "пко",                                                 "<открытие документа>",                           "actn_income-cash_open-doc",                          "firm") .
    run add-right in this-procedure ("фин", "платежи",                                             "ДОБАВЛЕНИЕ",                                     "actn_fin-doc_add-def",                               "firm") .
    run add-right in this-procedure ("фин", "платежи",                                             "ИЗМЕНЕНИЕ",                                      "actn_fin-doc_update",                                "firm") .
    run add-right in this-procedure ("фин", "платежи",                                             "ПРОСМОТР",                                       "actn_fin-doc_lookup",                                "firm") .
    run add-right in this-procedure ("фин", "платежи",                                             "удаление",                                       "actn_fin-doc_deletion",                              "firm") .
    run add-right in this-procedure ("фин", "ппп",                                                 "<закрытие документа на факт>",                   "actn_income-cashless_close-fact",                    "firm") .
    run add-right in this-procedure ("фин", "ппп",                                                 "<закрытие документа>",                           "actn_income-cashless_close-doc",                     "firm") .
    run add-right in this-procedure ("фин", "ппп",                                                 "<отказ от документа>",                           "actn_income-cashless_reject-doc",                    "firm") .
    run add-right in this-procedure ("фин", "ппп",                                                 "<открытие документа>",                           "actn_income-cashless_open-doc",                      "firm") .
    run add-right in this-procedure ("фин", "рко",                                                 "<закрытие документа на факт>",                   "actn_expense-cash_close-fact",                       "firm") .
    run add-right in this-procedure ("фин", "рко",                                                 "<закрытие документа>",                           "actn_expense-cash_close-doc",                        "firm") .
    run add-right in this-procedure ("фин", "рко",                                                 "<открытие документа>",                           "actn_expense-cash_open-doc",                         "firm") .
    run add-right in this-procedure ("фин", "рпп",                                                 "<закрытие документа на факт>",                   "actn_expense-cashless_close-fact",                   "firm") .
    run add-right in this-procedure ("фин", "рпп",                                                 "<закрытие документа>",                           "actn_expense-cashless_close-doc",                    "firm") .
    run add-right in this-procedure ("фин", "рпп",                                                 "<отказ от документа>",                           "actn_expense-cashless_reject-doc",                   "firm") .
    run add-right in this-procedure ("фин", "рпп",                                                 "<открытие документа>",                           "actn_expense-cashless_open-doc",                     "firm") .
    run add-right in this-procedure ("фин", "фин_договор",                                         "ДОБАВЛЕНИЕ",                                     "actn_fin-contract_add-def",                          "firm") .
    run add-right in this-procedure ("фин", "фин_договор",                                         "ИЗМЕНЕНИЕ",                                      "actn_fin-contract_update",                           "firm") .
    run add-right in this-procedure ("фин", "фин_договор",                                         "модернизация",                                   "actn_fin-contract_modernization",                    "firm") .
    run add-right in this-procedure ("фин", "фин_договор",                                         "удаление",                                       "actn_fin-contract_deletion",                         "firm") .
    run add-right in this-procedure ("фин", "фин_договор",                                         "экспорт",                                        "actn_fin-contract_export",                           "firm") .
    run add-right in this-procedure ("фин", "фин_обязательства",                                   "<закрытие документа на факт>",                   "actn_fin-liability_close-fact",                      "firm") .
    run add-right in this-procedure ("фин", "фин_обязательства",                                   "ДОБАВЛЕНИЕ",                                     "actn_fin-liability_add-def",                         "firm") .
    run add-right in this-procedure ("фин", "фин_обязательства",                                   "ИЗМЕНЕНИЕ",                                      "actn_fin-liability_update",                          "firm") .
    run add-right in this-procedure ("фин", "фин_обязательства",                                   "ПРОСМОТР",                                       "actn_fin-liability_lookup",                          "firm") .
    run add-right in this-procedure ("фин", "фин_обязательства",                                   "печать",                                         "actn_fin-liability_print",                           "firm") .
    run add-right in this-procedure ("фин", "фин_обязательства",                                   "удаление",                                       "actn_fin-liability_deletion",                        "firm") .
    run add-right in this-procedure ("фин", "фин_обязательства",                                   "экспорт",                                        "actn_fin-liability_export",                          "firm") .
    run add-right in this-procedure ("фин", "фин_справочник",                                      "ДОБАВЛЕНИЕ",                                     "actn_fin-reference_add-def",                         "firm") .
    run add-right in this-procedure ("фин", "фин_справочник",                                      "ИЗМЕНЕНИЕ",                                      "actn_fin-reference_update",                          "firm") .
    run add-right in this-procedure ("фин", "фин_справочник",                                      "ПРОСМОТР",                                       "actn_fin-reference_lookup",                          "firm") .
    run add-right in this-procedure ("фин", "фин_справочник",                                      "печать",                                         "actn_fin-reference_print",                           "firm") .
    run add-right in this-procedure ("фин", "фин_справочник",                                      "удаление",                                       "actn_fin-reference_deletion",                        "firm") .
    run add-right in this-procedure ("фин", "фин_справочник",                                      "экспорт",                                        "actn_fin-reference_export",                          "firm") .
  end.
end procedure.
procedure fill-right-eng :
  do
  on error undo, return error return-value
  :
    run add-right in this-procedure ("acc",    "account-function",         "balance",                                 "actn_acc-functions_balance",                         "firm") .
    run add-right in this-procedure ("acc",    "account-function",         "close",                                   "actn_acc-functions_close",                           "firm") .
    run add-right in this-procedure ("acc",    "account-function",         "main-book",                               "actn_acc-functions_main-book",                       "firm") .
    run add-right in this-procedure ("acc",    "account-function",         "multibalance",                            "actn_acc-functions_multibalance",                    "firm") .
    run add-right in this-procedure ("acc",    "account-function",         "open",                                    "actn_acc-functions_open",                            "firm") .
    run add-right in this-procedure ("acc",    "account-function",         "waybill-without-trans",                   "actn_acc-functions_transless-waybill",               "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "add-acc-item",                            "actn_acc-options_add-acc-item",                      "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "delete-acc-item",                         "actn_acc-options_del-acc-item",                      "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "external-transaction",                    "actn_acc-options_external-auto-transaction",         "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "form-add",                                "actn_acc-options_form-add",                          "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "form-delete",                             "actn_acc-options_form-del",                          "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "form-update",                             "actn_acc-options_form-upd",                          "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "oper-sum-add",                            "actn_acc-options_oper-sum-add",                      "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "oper-sum-delete",                         "actn_acc-options_oper-sum-del",                      "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "oper-sum-update",                         "actn_acc-options_oper-sum-upd",                      "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "typical-oper-add",                        "actn_acc-options_typical-oper-add",                  "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "typical-oper-delete",                     "actn_acc-options_typical-oper-del",                  "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "typical-oper-update",                     "actn_acc-options_typical-oper-upd",                  "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "update-acc-item",                         "actn_acc-options_upd-acc-item",                      "firm") .
    run add-right in this-procedure ("acc",    "account-service",          "utilities",                               "actn_acc-service_utilities",                         "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "add-acc-item",                            "actn_analitic_add-acc-item",                         "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "add-node",                                "actn_analitic_add-nodes",                            "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "cash-book",                               "actn_analitic_cash-book",                            "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "delete-acc-item",                         "actn_analitic_del-acc-item",                         "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "delete-archive",                          "actn_analitic_del-archive",                          "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "delete-node",                             "actn_analitic_del-nodes",                            "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "function",                                "actn_analitic_functions",                            "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "jobber-turn",                             "actn_analitic_jobber-turn",                          "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "jobber-turn-base-curr",                   "actn_analitic_jobber-turn-base-curr",                "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "jobber-turn-roubles",                     "actn_analitic_jobber-turn-roubles",                  "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "print",                                   "actn_analitic_print",                                "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "update-acc-item",                         "actn_analitic_upd-acc-item",                         "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "update-node",                             "actn_analitic_upd-nodes",                            "firm") .
    run add-right in this-procedure ("acc",    "purchase-book",            "print",                                   "actn_purchase-book_print",                           "firm") .
    run add-right in this-procedure ("acc",    "report",                   "print",                                   "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("acc",    "sale-book",                "print",                                   "actn_sales-book_print",                              "firm") .
    run add-right in this-procedure ("acc",    "transaction",              "LOOKUP",                                  "actn_transactions_lookup",                           "firm") .
    run add-right in this-procedure ("acc",    "transaction",              "base-curr-amount",                        "actn_transactions_base-curr-amount",                 "firm") .
    run add-right in this-procedure ("acc",    "transaction",              "print",                                   "actn_transactions_print",                            "firm") .
    run add-right in this-procedure ("acc",    "transaction",              "update-complete-transaction",             "actn_transactions_upd-comlete-trans",                "firm") .
    run add-right in this-procedure ("acc",    "transaction",              "update-group",                            "actn_transactions_upd-group",                        "firm") .
    run add-right in this-procedure ("acc",    "transaction",              "update-status",                           "actn_transactions_upd-status",                       "firm") .
    run add-right in this-procedure ("acc",    "transaction",              "work",                                    "actn_transactions_work",                             "firm") .
    run add-right in this-procedure ("cmm",    "CB-rate",                  "UPDATE",                                  "actn_cb-rate_update",                                "global") .
    run add-right in this-procedure ("cmm",    "GLN",                      "UPDATE",                                  "actn_rh-attr-gln_update",                            "global") .
    run add-right in this-procedure ("cmm",    "MICEX-rate",               "UPDATE",                                  "actn_micex-rate_update",                             "global") .
    run add-right in this-procedure ("cmm",    "POS-reference",            "on-off",                                  "actn_cashdesk-reference_on-off",                     "object") .
    run add-right in this-procedure ("cmm",    "POS-reference",            "preparation",                             "actn_cashdesk-reference_input-deletion-updating",    "object") .
    run add-right in this-procedure ("cmm",    "PS-fact",                  "print",                                   "actn_ps-fact_print",                                 "firm") .
    run add-right in this-procedure ("cmm",    "Parts",                    "CreateNeg",                               "actn_parts_createneg",                               "object") .
    run add-right in this-procedure ("cmm",    "Parts",                    "all",                                     "actn_parts_all",                                     "firm") .
    run add-right in this-procedure ("cmm",    "account-service",          "transaction-generation",                  "actn_acc-service_trans-generation",                  "firm") .
    run add-right in this-procedure ("cmm",    "account-service",          "waybill-clear-list",                      "actn_acc-service_waybill-clear-list",                "firm") .
    run add-right in this-procedure ("cmm",    "acp",                      "update-closed",                           "actn_income_update-closed",                          "object") .
    run add-right in this-procedure ("cmm",    "acp",                      "update-last-date",                        "actn_income_update-last-date",                       "object") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "preparation",                             "actn_alt-barcode_preparation",                       "global") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "scgb",                                    "actn_alt-barcode_gbl-sc-code",                       "global") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "sclc",                                    "actn_alt-barcode_loc-sc-code",                       "global") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "ssgb",                                    "actn_alt-barcode_gbl-ss-code",                       "global") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "sslc",                                    "actn_alt-barcode_loc-ss-code",                       "global") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "turn-on",                                 "actn_alt-barcode_turn-on",                           "global") .
    run add-right in this-procedure ("cmm",    "analitic",                 "archive",                                 "actn_analitic_archive",                              "firm") .
    run add-right in this-procedure ("cmm",    "archive",                  "LOOKUP",                                  "actn_archive_lookup",                                "object") .
    run add-right in this-procedure ("cmm",    "archive-ahsp",             "UPDATE",                                  "actn_archive-ahsp_update",                           "object") .
    run add-right in this-procedure ("cmm",    "archive-aht",              "UPDATE",                                  "actn_archive-aht_update",                            "object") .
    run add-right in this-procedure ("cmm",    "archive-arh",              "UPDATE",                                  "actn_archive-arh_update",                            "object") .
    run add-right in this-procedure ("cmm",    "archive-multyfirm",        "UPDATE",                                  "actn_archive-hold_update",                           "firm") .
    run add-right in this-procedure ("cmm",    "archive-prc",              "UPDATE",                                  "actn_archive-prc_update",                            "object") .
    run add-right in this-procedure ("cmm",    "cashier",                  "stat-on-cashiers",                        "actn_cashiers_stat-on-cashiers",                     "firm") .
    run add-right in this-procedure ("cmm",    "client-reference",         "LOOKUP",                                  "actn_client-reference_lookup",                       "global") .
    run add-right in this-procedure ("cmm",    "client-reference",         "UPDATE",                                  "actn_client-reference_update",                       "global") .
    run add-right in this-procedure ("cmm",    "client-reference",         "add-del",                                 "actn_client-reference_add-del",                      "global") .
    run add-right in this-procedure ("cmm",    "client-reference-prs",     "add-del",                                 "actn_client-reference-prs_add-del",                  "global") .
    run add-right in this-procedure ("cmm",    "client-requisite",         "add-upd",                                 "actn_client-requisite_add-upd",                      "firm") .
    run add-right in this-procedure ("cmm",    "del_document",             "all",                                     "actn_c-documents_all",                               "object") .
    run add-right in this-procedure ("cmm",    "delivery-storage",         "work",                                    "actn_delivery-storage_work",                         "global") .
    run add-right in this-procedure ("cmm",    "discount",                 "work",                                    "actn_discount_work",                                 "object") .
    run add-right in this-procedure ("cmm",    "discount-cards-totals",    "print",                                   "actn_discount-cards-totals_print",                   "firm") .
    run add-right in this-procedure ("cmm",    "document",                 "all",                                     "actn_documents_all",                                 "global") .
    run add-right in this-procedure ("cmm",    "document",                 "export",                                  "actn_documents_export",                              "firm") .
    run add-right in this-procedure ("cmm",    "document-reports-cost",    "print",                                   "actn_document-reports-cost_print",                   "firm") .
    run add-right in this-procedure ("cmm",    "document-reports-sale",    "print",                                   "actn_document-reports-sale_print",                   "firm") .
    run add-right in this-procedure ("cmm",    "edi",                      "UPDATE",                                  "actn_rh-attr-edi_update",                            "global") .
    run add-right in this-procedure ("cmm",    "exmark-reference",         "UPDATE",                                  "actn_exmark-reference_update",                       "global") .
    run add-right in this-procedure ("cmm",    "fin-bank-accounts",        "COPY",                                    "actn_fin-bank-accounts_add-copy",                    "firm") .
    run add-right in this-procedure ("cmm",    "fin-bank-accounts",        "CREATE",                                  "actn_fin-bank-accounts_add-def",                     "firm") .
    run add-right in this-procedure ("cmm",    "fin-bank-accounts",        "UPDATE",                                  "actn_fin-bank-accounts_update",                      "firm") .
    run add-right in this-procedure ("cmm",    "fin-bank-accounts",        "deletion",                                "actn_fin-bank-accounts_deletion",                    "firm") .
    run add-right in this-procedure ("cmm",    "fin-contract",             "LOOKUP",                                  "actn_fin-contract_lookup",                           "firm") .
    run add-right in this-procedure ("cmm",    "group-goods-cash-desk",    "CREATE",                                  "actn_group-goods-cash-desk_add-def",                 "object") .
    run add-right in this-procedure ("cmm",    "group-goods-cash-desk",    "UPDATE",                                  "actn_group-goods-cash-desk_update",                  "object") .
    run add-right in this-procedure ("cmm",    "invoice",                  "CREATE",                                  "actn_invoice_add-def",                               "object") .
    run add-right in this-procedure ("cmm",    "invoice",                  "LOOKUP",                                  "actn_invoice_lookup",                                "object") .
    run add-right in this-procedure ("cmm",    "invoice",                  "UPDATE",                                  "actn_invoice_update",                                "object") .
    run add-right in this-procedure ("cmm",    "invoice",                  "deletion",                                "actn_invoice_deletion",                              "object") .
    run add-right in this-procedure ("cmm",    "invoice",                  "print",                                   "actn_invoice_print",                                 "object") .
    run add-right in this-procedure ("cmm",    "kitchen",                  "work",                                    "actn_fbr-prn_work",                                  "global") .
    run add-right in this-procedure ("cmm",    "main-barcode",             "deletion",                                "actn_main-barcode_deletion",                         "global") .
    run add-right in this-procedure ("cmm",    "main-barcode",             "preparation",                             "actn_main-barcode_preparation",                      "global") .
    run add-right in this-procedure ("cmm",    "obj-date",                 "UPDATE",                                  "actn_obj-date-change_update",                        "firm") .
    run add-right in this-procedure ("cmm",    "only-edi",                 "UPDATE",                                  "actn_rh-attr-only-edi_update",                       "global") .
    run add-right in this-procedure ("cmm",    "openxml-subsystem",        "CREATE",                                  "actn_openxml-subsystem_add-def",                     "object") .
    run add-right in this-procedure ("cmm",    "openxml-subsystem",        "LOOKUP",                                  "actn_openxml-subsystem_lookup",                      "object") .
    run add-right in this-procedure ("cmm",    "openxml-subsystem",        "UPDATE",                                  "actn_openxml-subsystem_update",                      "object") .
    run add-right in this-procedure ("cmm",    "openxml-subsystem",        "deletion",                                "actn_openxml-subsystem_deletion",                    "object") .
    run add-right in this-procedure ("cmm",    "openxml-subsystem",        "on-off",                                  "actn_openxml-subsystem_on-off",                      "object") .
    run add-right in this-procedure ("cmm",    "order",                    "POS/send",                                "actn_pmnt-ord-doc_sending",                          "global") .
    run add-right in this-procedure ("cmm",    "overvalue-cast",           "print",                                   "actn_overvalue-cast_print",                          "firm") .
    run add-right in this-procedure ("cmm",    "pay docs",                 "CREATE",                                  "actn_bgh-paydocs_add-def",                           "firm") .
    run add-right in this-procedure ("cmm",    "pay docs",                 "LOOKUP",                                  "actn_bgh-paydocs_lookup",                            "firm") .
    run add-right in this-procedure ("cmm",    "pay docs",                 "UPDATE",                                  "actn_bgh-paydocs_update",                            "firm") .
    run add-right in this-procedure ("cmm",    "pay docs",                 "deletion",                                "actn_bgh-paydocs_deletion",                          "firm") .
    run add-right in this-procedure ("cmm",    "pay docs",                 "print",                                   "actn_bgh-paydocs_print",                             "firm") .
    run add-right in this-procedure ("cmm",    "payments-reference",       "LOOKUP",                                  "actn_payments-reference_lookup",                     "firm") .
    run add-right in this-procedure ("cmm",    "permanent-client-sale",    "print",                                   "actn_permanent-client-sale_print",                   "firm") .
    run add-right in this-procedure ("cmm",    "price-list",               "print",                                   "actn_price-list_print",                              "firm") .
    run add-right in this-procedure ("cmm",    "price-list-to-file",       "print",                                   "actn_price-list-to-file_print",                      "firm") .
    run add-right in this-procedure ("cmm",    "proceeds-monthly",         "print",                                   "actn_proceeds-monthly_print",                        "firm") .
    run add-right in this-procedure ("cmm",    "prod-classifier-monthly",  "print",                                   "actn_prod-classifier-monthly_print",                 "firm") .
    run add-right in this-procedure ("cmm",    "prod-monthly",             "print",                                   "actn_prod-monthly_print",                            "firm") .
    run add-right in this-procedure ("cmm",    "receipt",                  "deletion",                                "actn_receipts_deletion",                             "object") .
    run add-right in this-procedure ("cmm",    "receipts-and-revenue",     "print",                                   "actn_cur-obj-proceeds_print",                        "firm") .
    run add-right in this-procedure ("cmm",    "recipe-reference",         "cmm",                                     "actn_recipe-reference_conjoint",                     "object") .
    run add-right in this-procedure ("cmm",    "recipe-reference",         "preparation",                             "actn_recipe-reference_input-deletion-updating",      "object") .
    run add-right in this-procedure ("cmm",    "reference",                "UPDATE",                                  "actn_reference_update",                              "global") .
    run add-right in this-procedure ("cmm",    "reference",                "archive",                                 "actn_reference_archive",                             "firm") .
    run add-right in this-procedure ("cmm",    "reference",                "deletion",                                "actn_reference_deletion",                            "global") .
    run add-right in this-procedure ("cmm",    "reference",                "export",                                  "actn_references_export",                             "object") .
    run add-right in this-procedure ("cmm",    "reference",                "price-calc-param",                        "actn_reference_calc-increase",                       "global") .
    run add-right in this-procedure ("cmm",    "reference",                "print",                                   "actn_reference_print",                               "firm") .
    run add-right in this-procedure ("cmm",    "reference",                "update-goods-tax",                        "actn_reference_upd-gds-tax",                         "global") .
    run add-right in this-procedure ("cmm",    "reference",                "update-group",                            "actn_reference_upd-group",                           "global") .
    run add-right in this-procedure ("cmm",    "reference-dc-type",        "preparation",                             "actn_reference-dc-type_input-deletion-updating",     "global") .
    run add-right in this-procedure ("cmm",    "reference-list",           "print",                                   "actn_reference-lists_print",                         "firm") .
    run add-right in this-procedure ("cmm",    "reference-petrolium",      "UPDATE",                                  "actn_reference-petrolium_update",                    "global") .
    run add-right in this-procedure ("cmm",    "reference-services",       "UPDATE",                                  "actn_reference-services_update",                     "global") .
    run add-right in this-procedure ("cmm",    "reference-services",       "deletion",                                "actn_reference-services_deletion",                   "global") .
    run add-right in this-procedure ("cmm",    "refernse-dis",             "preparation",                             "actn_referense-dis_input-deletion-updating",         "firm") .
    run add-right in this-procedure ("cmm",    "ren-art",                  "UPDATE",                                  "actn_ren-art_update",                                "global") .
    run add-right in this-procedure ("cmm",    "right-assignment",         "UPDATE",                                  "actn_rights_update",                                 "global") .
    run add-right in this-procedure ("cmm",    "rt-check-price",           "work",                                    "actn_rt-check-price_work",                           "object") .
    run add-right in this-procedure ("cmm",    "rt-edit-doc",              "<close document fact>",                   "actn_rt-edit-doc_close-fact",                        "object") .
    run add-right in this-procedure ("cmm",    "rt-edit-doc",              "<close document>",                        "actn_rt-edit-doc_close-doc",                         "object") .
    run add-right in this-procedure ("cmm",    "rt-edit-doc",              "CREATE",                                  "actn_rt-edit-doc_add-def",                           "object") .
    run add-right in this-procedure ("cmm",    "rt-edit-doc",              "work",                                    "actn_rt-edit-doc_work",                              "object") .
    run add-right in this-procedure ("cmm",    "sale-report",              "print",                                   "actn_sale-report_print",                             "firm") .
    run add-right in this-procedure ("cmm",    "scales",                   "deletion",                                "actn_scales_deletion",                               "global") .
    run add-right in this-procedure ("cmm",    "scales/goods-group",       "add-delete",                              "actn_scales-goods-groups_adding-deletion",           "global") .
    run add-right in this-procedure ("cmm",    "schet-fact-doc",           "CREATE",                                  "actn_schet-fact-doc_add-def",                        "firm") .
    run add-right in this-procedure ("cmm",    "schet-fact-doc",           "LOOKUP",                                  "actn_schet-fact-doc_lookup",                         "firm") .
    run add-right in this-procedure ("cmm",    "schet-fact-doc",           "UPDATE",                                  "actn_schet-fact-doc_update",                         "firm") .
    run add-right in this-procedure ("cmm",    "schet-fact-doc",           "close",                                   "actn_schet-fact-doc_close",                          "firm") .
    run add-right in this-procedure ("cmm",    "schet-fact-doc",           "deletion",                                "actn_schet-fact-doc_deletion",                       "firm") .
    run add-right in this-procedure ("cmm",    "schet-fact-doc",           "export",                                  "actn_schet-fact-doc_export",                         "firm") .
    run add-right in this-procedure ("cmm",    "schet-fact-doc",           "open",                                    "actn_schet-fact-doc_open",                           "firm") .
    run add-right in this-procedure ("cmm",    "send-trn-edi",             "UPDATE",                                  "actn_rh-attr-send-trn-edi_update",                   "global") .
    run add-right in this-procedure ("cmm",    "shop-rate",                "UPDATE",                                  "actn_shop-rate_update",                              "object") .
    run add-right in this-procedure ("cmm",    "tax-kinds",                "UPDATE",                                  "actn_tax-kinds_update",                              "global") .
    run add-right in this-procedure ("cmm",    "tax-rate-codes",           "UPDATE",                                  "actn_tax-rates_update",                              "firm") .
    run add-right in this-procedure ("cmm",    "tax-rate-values",          "UPDATE",                                  "actn_tax-rate-values_update",                        "object") .
    run add-right in this-procedure ("cmm",    "tax-settlement",           "print",                                   "actn_tax-settlement_print",                          "firm") .
    run add-right in this-procedure ("cmm",    "unit",                     "UPDATE",                                  "actn_unit_update",                                   "global") .
    run add-right in this-procedure ("cmm",    "updfind",                  "UPDATE",                                  "actn_updfind_update",                                "firm") .
    run add-right in this-procedure ("cmm",    "waybills-to-file",         "print",                                   "actn_waybills-to-file_print",                        "firm") .
    run add-right in this-procedure ("cmm",    "wth-receipt",              "LOOKUP",                                  "actn_wth-receipts_lookup",                           "object") .
    run add-right in this-procedure ("cmm",    "wth-receipt",              "UPDATE",                                  "actn_wth-receipts_update",                           "object") .
    run add-right in this-procedure ("cmm",    "wth-receipt",              "deletion",                                "actn_wth-receipts_deletion",                         "object") .
    run add-right in this-procedure ("fas",    "assets kind of activity",  "CREATE",                                  "actn_os-act-kind_add-def",                           "firm") .
    run add-right in this-procedure ("fas",    "assets kind of activity",  "UPDATE",                                  "actn_os-act-kind_update",                            "firm") .
    run add-right in this-procedure ("fas",    "assets kind of activity",  "deletion",                                "actn_os-act-kind_deletion",                          "firm") .
    run add-right in this-procedure ("fas",    "assets operation type",    "CREATE",                                  "actn_os-oper-type_add-def",                          "firm") .
    run add-right in this-procedure ("fas",    "assets operation type",    "UPDATE",                                  "actn_os-oper-type_update",                           "firm") .
    run add-right in this-procedure ("fas",    "assets operation type",    "deletion",                                "actn_os-oper-type_deletion",                         "firm") .
    run add-right in this-procedure ("fas",    "assets operation variant", "CREATE",                                  "actn_os-oper-var_add-def",                           "firm") .
    run add-right in this-procedure ("fas",    "assets operation variant", "UPDATE",                                  "actn_os-oper-var_update",                            "firm") .
    run add-right in this-procedure ("fas",    "assets operation variant", "deletion",                                "actn_os-oper-var_deletion",                          "firm") .
    run add-right in this-procedure ("fas",    "assets print form",        "CREATE",                                  "actn_os-frm-docs_add-def",                           "firm") .
    run add-right in this-procedure ("fas",    "assets print form",        "UPDATE",                                  "actn_os-frm-docs_update",                            "firm") .
    run add-right in this-procedure ("fas",    "assets print form",        "deletion",                                "actn_os-frm-docs_deletion",                          "firm") .
    run add-right in this-procedure ("fas",    "assets source documents",  "CREATE",                                  "actn_os-src-docs_add-def",                           "firm") .
    run add-right in this-procedure ("fas",    "assets source documents",  "UPDATE",                                  "actn_os-src-docs_update",                            "firm") .
    run add-right in this-procedure ("fas",    "assets source documents",  "deletion",                                "actn_os-src-docs_deletion",                          "firm") .
    run add-right in this-procedure ("fas",    "assets tax group",         "CREATE",                                  "actn_os-group-tax_add-def",                          "firm") .
    run add-right in this-procedure ("fas",    "assets tax group",         "UPDATE",                                  "actn_os-group-tax_update",                           "firm") .
    run add-right in this-procedure ("fas",    "assets tax group",         "deletion",                                "actn_os-group-tax_deletion",                         "firm") .
    run add-right in this-procedure ("fas",    "depreciation-rate",        "CREATE",                                  "actn_depreciation-rate_add-def",                     "firm") .
    run add-right in this-procedure ("fas",    "depreciation-rate",        "UPDATE",                                  "actn_depreciation-rate_update",                      "firm") .
    run add-right in this-procedure ("fas",    "depreciation-rate",        "deletion",                                "actn_depreciation-rate_deletion",                    "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-card",        "CREATE",                                  "actn_fixed-assets-cards_add-def",                    "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-card",        "UPDATE",                                  "actn_fixed-assets-cards_update",                     "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-card",        "card-print",                              "actn_fixed-assets-cards_card-print",                 "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-card",        "deletion",                                "actn_fixed-assets-cards_deletion",                   "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-card",        "displacement",                            "actn_fixed-assets-cards_displacement",               "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-card",        "disposition-reconstruction",              "actn_fixed-assets-cards_disposition-reconstruction", "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-card",        "modernization",                           "actn_fixed-assets-cards_modernization",              "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-card",        "overvalue",                               "actn_fixed-assets-cards_overvalue",                  "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-group",       "CREATE",                                  "actn_fixed-assets-groups_add-def",                   "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-group",       "UPDATE",                                  "actn_fixed-assets-groups_update",                    "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-group",       "deletion",                                "actn_fixed-assets-groups_deletion",                  "firm") .
    run add-right in this-procedure ("fas",    "report",                   "print",                                   "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("fas",    "row-cards",                "CREATE",                                  "actn_row-cards_add-def",                             "firm") .
    run add-right in this-procedure ("fas",    "row-cards",                "UPDATE",                                  "actn_row-cards_update",                              "firm") .
    run add-right in this-procedure ("fas",    "row-cards",                "deletion",                                "actn_row-cards_deletion",                            "firm") .
    run add-right in this-procedure ("fas",    "row-cards",                "displacement",                            "actn_row-cards_displacement",                        "firm") .
    run add-right in this-procedure ("fas",    "row-cards",                "disposition-reconstruction",              "actn_row-cards_disposition-reconstruction",          "firm") .
    run add-right in this-procedure ("fas",    "supplies-cards",           "CREATE",                                  "actn_supplies-cards_add-def",                        "firm") .
    run add-right in this-procedure ("fas",    "supplies-cards",           "UPDATE",                                  "actn_supplies-cards_update",                         "firm") .
    run add-right in this-procedure ("fas",    "supplies-cards",           "deletion",                                "actn_supplies-cards_deletion",                       "firm") .
    run add-right in this-procedure ("fas",    "supplies-cards",           "displacement",                            "actn_supplies-cards_displacement",                   "firm") .
    run add-right in this-procedure ("fas",    "supplies-cards",           "disposition-reconstruction",              "actn_supplies-cards_disposition-reconstruction",     "firm") .
    run add-right in this-procedure ("fas",    "supplies-cards",           "modernization",                           "actn_supplies-cards_modernization",                  "firm") .
    run add-right in this-procedure ("fin",    "ec",                       "<close document fact>",                   "actn_expense-cash_close-fact",                       "firm") .
    run add-right in this-procedure ("fin",    "ec",                       "<close document>",                        "actn_expense-cash_close-doc",                        "firm") .
    run add-right in this-procedure ("fin",    "ec",                       "<open document>",                         "actn_expense-cash_open-doc",                         "firm") .
    run add-right in this-procedure ("fin",    "ei",                       "<close document fact>",                   "actn_expense-cashless_close-fact",                   "firm") .
    run add-right in this-procedure ("fin",    "ei",                       "<close document>",                        "actn_expense-cashless_close-doc",                    "firm") .
    run add-right in this-procedure ("fin",    "ei",                       "<open document>",                         "actn_expense-cashless_open-doc",                     "firm") .
    run add-right in this-procedure ("fin",    "ei",                       "<reject document>",                       "actn_expense-cashless_reject-doc",                   "firm") .
    run add-right in this-procedure ("fin",    "eo",                       "<close document fact>",                   "actn_expense-payoff_close-fact",                     "firm") .
    run add-right in this-procedure ("fin",    "eo",                       "<close document>",                        "actn_expense-payoff_close-doc",                      "firm") .
    run add-right in this-procedure ("fin",    "eo",                       "<open document>",                         "actn_expense-payoff_open-doc",                       "firm") .
    run add-right in this-procedure ("fin",    "fin-contract",             "CREATE",                                  "actn_fin-contract_add-def",                          "firm") .
    run add-right in this-procedure ("fin",    "fin-contract",             "UPDATE",                                  "actn_fin-contract_update",                           "firm") .
    run add-right in this-procedure ("fin",    "fin-contract",             "deletion",                                "actn_fin-contract_deletion",                         "firm") .
    run add-right in this-procedure ("fin",    "fin-contract",             "export",                                  "actn_fin-contract_export",                           "firm") .
    run add-right in this-procedure ("fin",    "fin-contract",             "modernization",                           "actn_fin-contract_modernization",                    "firm") .
    run add-right in this-procedure ("fin",    "fin-doc",                  "CREATE",                                  "actn_fin-doc_add-def",                               "firm") .
    run add-right in this-procedure ("fin",    "fin-doc",                  "LOOKUP",                                  "actn_fin-doc_lookup",                                "firm") .
    run add-right in this-procedure ("fin",    "fin-doc",                  "UPDATE",                                  "actn_fin-doc_update",                                "firm") .
    run add-right in this-procedure ("fin",    "fin-doc",                  "deletion",                                "actn_fin-doc_deletion",                              "firm") .
    run add-right in this-procedure ("fin",    "fin-liability",            "<close document fact>",                   "actn_fin-liability_close-fact",                      "firm") .
    run add-right in this-procedure ("fin",    "fin-liability",            "CREATE",                                  "actn_fin-liability_add-def",                         "firm") .
    run add-right in this-procedure ("fin",    "fin-liability",            "LOOKUP",                                  "actn_fin-liability_lookup",                          "firm") .
    run add-right in this-procedure ("fin",    "fin-liability",            "UPDATE",                                  "actn_fin-liability_update",                          "firm") .
    run add-right in this-procedure ("fin",    "fin-liability",            "deletion",                                "actn_fin-liability_deletion",                        "firm") .
    run add-right in this-procedure ("fin",    "fin-liability",            "export",                                  "actn_fin-liability_export",                          "firm") .
    run add-right in this-procedure ("fin",    "fin-liability",            "print",                                   "actn_fin-liability_print",                           "firm") .
    run add-right in this-procedure ("fin",    "fin-reference",            "CREATE",                                  "actn_fin-reference_add-def",                         "firm") .
    run add-right in this-procedure ("fin",    "fin-reference",            "LOOKUP",                                  "actn_fin-reference_lookup",                          "firm") .
    run add-right in this-procedure ("fin",    "fin-reference",            "UPDATE",                                  "actn_fin-reference_update",                          "firm") .
    run add-right in this-procedure ("fin",    "fin-reference",            "deletion",                                "actn_fin-reference_deletion",                        "firm") .
    run add-right in this-procedure ("fin",    "fin-reference",            "export",                                  "actn_fin-reference_export",                          "firm") .
    run add-right in this-procedure ("fin",    "fin-reference",            "print",                                   "actn_fin-reference_print",                           "firm") .
    run add-right in this-procedure ("fin",    "ic",                       "<close document fact>",                   "actn_income-cash_close-fact",                        "firm") .
    run add-right in this-procedure ("fin",    "ic",                       "<close document>",                        "actn_income-cash_close-doc",                         "firm") .
    run add-right in this-procedure ("fin",    "ic",                       "<open document>",                         "actn_income-cash_open-doc",                          "firm") .
    run add-right in this-procedure ("fin",    "ii",                       "<close document fact>",                   "actn_income-cashless_close-fact",                    "firm") .
    run add-right in this-procedure ("fin",    "ii",                       "<close document>",                        "actn_income-cashless_close-doc",                     "firm") .
    run add-right in this-procedure ("fin",    "ii",                       "<open document>",                         "actn_income-cashless_open-doc",                      "firm") .
    run add-right in this-procedure ("fin",    "ii",                       "<reject document>",                       "actn_income-cashless_reject-doc",                    "firm") .
    run add-right in this-procedure ("fin",    "io",                       "<close document fact>",                   "actn_income-payoff_close-fact",                      "firm") .
    run add-right in this-procedure ("fin",    "io",                       "<close document>",                        "actn_income-payoff_close-doc",                       "firm") .
    run add-right in this-procedure ("fin",    "io",                       "<open document>",                         "actn_income-payoff_open-doc",                        "firm") .
    run add-right in this-procedure ("fin",    "report",                   "print",                                   "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("object", "Object-Object",            "CREATE",                                  "actn_o-o_add-def",                                   "object") .
    run add-right in this-procedure ("object", "Object-Object",            "UPDATE",                                  "actn_o-o_update",                                    "object") .
    run add-right in this-procedure ("object", "Object-Object",            "deletion",                                "actn_o-o_deletion",                                  "object") .
    run add-right in this-procedure ("object", "POS-reference",            "UPDATE",                                  "actn_cashdesk-reference_update",                     "object") .
    run add-right in this-procedure ("object", "POS/cashier",              "UPDATE",                                  "actn_cashdesk-cashiers_update",                      "object") .
    run add-right in this-procedure ("object", "POS/client",               "CREATE",                                  "actn_cashdesk-clients_add-def",                      "object") .
    run add-right in this-procedure ("object", "POS/client",               "deletion",                                "actn_cashdesk-clients_deletion",                     "object") .
    run add-right in this-procedure ("object", "POS/curr-rate",            "UPDATE",                                  "actn_cashdesk-rates_update",                         "object") .
    run add-right in this-procedure ("object", "POS/goods",                "CREATE",                                  "actn_cashdesk-goods_add-def",                        "object") .
    run add-right in this-procedure ("object", "POS/goods",                "deletion",                                "actn_cashdesk-goods_deletion",                       "object") .
    run add-right in this-procedure ("object", "POS/goods-group",          "UPDATE",                                  "actn_cashdesk-goods-groups_update",                  "object") .
    run add-right in this-procedure ("object", "POS/payment",              "CREATE",                                  "actn_cashdesk-payments_add-def",                     "object") .
    run add-right in this-procedure ("object", "POS/payment",              "deletion",                                "actn_cashdesk-payments_deletion",                    "object") .
    run add-right in this-procedure ("object", "POS/seller",               "UPDATE",                                  "actn_cashdesk-sellers_update",                       "object") .
    run add-right in this-procedure ("object", "POS/taxes-goods",          "CREATE",                                  "actn_cashdesk-taxg_add-def",                         "object") .
    run add-right in this-procedure ("object", "POS/taxes-goods",          "deletion",                                "actn_cashdesk-taxg_deletion",                        "object") .
    run add-right in this-procedure ("object", "POS/taxes-value",          "CREATE",                                  "actn_cashdesk-taxn_add-def",                         "object") .
    run add-right in this-procedure ("object", "POS/taxes-value",          "deletion",                                "actn_cashdesk-taxn_deletion",                        "object") .
    run add-right in this-procedure ("object", "POS/total-discount",       "CREATE",                                  "actn_cashdesk-discnt-total_add-def",                 "object") .
    run add-right in this-procedure ("object", "POS/total-discount",       "deletion",                                "actn_cashdesk-discnt-total_deletion",                "object") .
    run add-right in this-procedure ("object", "Parts",                    "split-fuse",                              "actn_parts_split-fuse",                              "object") .
    run add-right in this-procedure ("object", "acp",                      "LOOKUP",                                  "actn_income_lookup",                                 "object") .
    run add-right in this-procedure ("object", "acp",                      "add document back date",                  "actn_income_add-back-date",                          "object") .
    run add-right in this-procedure ("object", "acp",                      "add petrol in document back date",        "actn_income_add-ptrl-back-date",                     "object") .
    run add-right in this-procedure ("object", "acp",                      "delete document in status fact",          "actn_income_del-fact",                               "object") .
    run add-right in this-procedure ("object", "acp",                      "delete document on petrol in prev shift", "actn_income_del-ptrl-prev-shft",                     "object") .
    run add-right in this-procedure ("object", "acp",                      "fact",                                    "actn_income_fact",                                   "object") .
    run add-right in this-procedure ("object", "acp",                      "import",                                  "actn_income_import",                                 "object") .
    run add-right in this-procedure ("object", "acp",                      "open",                                    "actn_income_opening",                                "object") .
    run add-right in this-procedure ("object", "acp",                      "open-inquiry",                            "actn_income_opening-inquiry",                        "object") .
    run add-right in this-procedure ("object", "acp",                      "preparation",                             "actn_income_preparation",                            "object") .
    run add-right in this-procedure ("object", "acp",                      "prepownfirmhold",                         "actn_income_prepownfirmhold",                        "object") .
    run add-right in this-procedure ("object", "acp",                      "print",                                   "actn_income_print",                                  "object") .
    run add-right in this-procedure ("object", "on_doc",                   "LOOKUP",                                  "actn_rvs-on-doc_lookup",                             "object") .
    run add-right in this-procedure ("object", "on_doc",                   "cr-revision",                             "actn_rvs-on-doc_cr-revision",                        "object") .
    run add-right in this-procedure ("object", "on_doc",                   "deletion",                                "actn_rvs-on-doc_deletion",                           "object") .
    run add-right in this-procedure ("object", "on_doc",                   "fact",                                    "actn_rvs-on-doc_fact",                               "object") .
    run add-right in this-procedure ("object", "on_doc",                   "print",                                   "actn_rvs-on-doc_print",                              "object") .
    run add-right in this-procedure ("object", "on_doc",                   "upd-revision",                            "actn_rvs-on-doc_upd-revision",                       "object") .
    run add-right in this-procedure ("object", "archive",                  "cost",                                    "actn_archive_cost",                                  "object") .
    run add-right in this-procedure ("object", "cap",                      "preparation",                             "actn_corr-acc-pr-view_preparation",                  "object") .
    run add-right in this-procedure ("object", "client-card",              "payment-deletion",                        "actn_client-cards_payment-deletion",                 "object") .
    run add-right in this-procedure ("object", "client-card",              "payment-input",                           "actn_client-cards_payment-input",                    "object") .
    run add-right in this-procedure ("object", "control",                  "LOOKUP",                                  "actn_rvs-control_lookup",                            "object") .
    run add-right in this-procedure ("object", "control",                  "cr-revision",                             "actn_rvs-control_cr-revision",                       "object") .
    run add-right in this-procedure ("object", "control",                  "delete document in status fact",          "actn_rvs-control_del-fact",                          "object") .
    run add-right in this-procedure ("object", "control",                  "deletion",                                "actn_rvs-control_deletion",                          "object") .
    run add-right in this-procedure ("object", "control",                  "fact",                                    "actn_rvs-control_fact",                              "object") .
    run add-right in this-procedure ("object", "control",                  "print",                                   "actn_rvs-control_print",                             "object") .
    run add-right in this-procedure ("object", "control",                  "upd-revision",                            "actn_rvs-control_upd-revision",                      "object") .
    run add-right in this-procedure ("object", "cre-receipt",              "input",                                   "actn_receipt_input",                                 "object") .
    run add-right in this-procedure ("object", "exp",                      "LOOKUP",                                  "actn_expense_lookup",                                "object") .
    run add-right in this-procedure ("object", "exp",                      "add document back date",                  "actn_expense_add-back-date",                         "object") .
    run add-right in this-procedure ("object", "exp",                      "add petrol in document back date",        "actn_expense_add-ptrl-back-date",                    "object") .
    run add-right in this-procedure ("object", "exp",                      "close expense less acc-price",            "actn_expense_chkslpr",                               "object") .
    run add-right in this-procedure ("object", "exp",                      "delete document in status fact",          "actn_expense_del-fact",                              "object") .
    run add-right in this-procedure ("object", "exp",                      "delete document on petrol in prev shift", "actn_expense_del-ptrl-prev-shft",                    "object") .
    run add-right in this-procedure ("object", "exp",                      "fact",                                    "actn_expense_fact",                                  "object") .
    run add-right in this-procedure ("object", "exp",                      "open",                                    "actn_expense_opening",                               "object") .
    run add-right in this-procedure ("object", "exp",                      "perm-cancellation",                       "actn_expense_perm-cancellation",                     "object") .
    run add-right in this-procedure ("object", "exp",                      "permission",                              "actn_expense_permission",                            "object") .
    run add-right in this-procedure ("object", "exp",                      "preparation",                             "actn_expense_preparation",                           "object") .
    run add-right in this-procedure ("object", "exp",                      "prepownfirmhold",                         "actn_expense_prepownfirmhold",                       "object") .
    run add-right in this-procedure ("object", "exp",                      "price",                                   "actn_expense_price",                                 "object") .
    run add-right in this-procedure ("object", "exp",                      "print",                                   "actn_expense_print",                                 "object") .
    run add-right in this-procedure ("object", "exp",                      "reserv",                                  "actn_expense_rsrv-dtl-action-reserv",                "object") .
    run add-right in this-procedure ("object", "exp",                      "shipping",                                "actn_expense_shipping",                              "object") .
    run add-right in this-procedure ("object", "expense internal",         "delete document in status fact",          "actn_tdedt-ras-perem_del-fact",                      "object") .
    run add-right in this-procedure ("object", "hold_acp",                 "delete document in status fact",          "actn_hold-income_del-fact",                          "object") .
    run add-right in this-procedure ("object", "hold_exp",                 "delete document in status fact",          "actn_hold-expense_del-fact",                         "object") .
    run add-right in this-procedure ("object", "hold_exp",                 "preparation",                             "actn_hold-expense_preparation",                      "object") .
    run add-right in this-procedure ("object", "hold_ret",                 "delete document in status fact",          "actn_hold-return_del-fact",                          "object") .
    run add-right in this-procedure ("object", "inv",                      "LOOKUP",                                  "actn_inventory_lookup",                              "object") .
    run add-right in this-procedure ("object", "inv",                      "delete document in status fact",          "actn_inventory_del-fact",                            "object") .
    run add-right in this-procedure ("object", "inv",                      "fact",                                    "actn_inventory_fact",                                "object") .
    run add-right in this-procedure ("object", "inv",                      "fact-edit",                               "actn_inventory_fact-edit",                           "object") .
    run add-right in this-procedure ("object", "inv",                      "open",                                    "actn_inventory_opening",                             "object") .
    run add-right in this-procedure ("object", "inv",                      "permission",                              "actn_inventory_permission",                          "object") .
    run add-right in this-procedure ("object", "inv",                      "preparation",                             "actn_inventory_preparation",                         "object") .
    run add-right in this-procedure ("object", "inv",                      "print",                                   "actn_inventory_print",                               "object") .
    run add-right in this-procedure ("object", "inv",                      "reserve",                                 "actn_inventory_reserves",                            "object") .
    run add-right in this-procedure ("object", "inv-cnt-pump",             "LOOKUP",                                  "actn_icnt-doc_lookup",                               "object") .
    run add-right in this-procedure ("object", "inv-cnt-pump",             "deletion",                                "actn_icnt-doc_deletion",                             "object") .
    run add-right in this-procedure ("object", "inv-cnt-pump",             "fact",                                    "actn_icnt-doc_fact",                                 "object") .
    run add-right in this-procedure ("object", "inv-cnt-pump",             "preparation",                             "actn_icnt-doc_preparation",                          "object") .
    run add-right in this-procedure ("object", "inv-cnt-pump",             "print",                                   "actn_icnt-doc_print",                                "object") .
    run add-right in this-procedure ("object", "inv-cnt-pump",             "upd-el-cnt",                              "actn_icnt-doc_upd-el-cnt",                           "object") .
    run add-right in this-procedure ("object", "invoice",                  "LOOKUP",                                  "actn_invoice_lookup",                                "object") .
    run add-right in this-procedure ("object", "invoice",                  "UPDATE",                                  "actn_invoice_update",                                "object") .
    run add-right in this-procedure ("object", "invoice",                  "preparation",                             "actn_invoice_preparation",                           "object") .
    run add-right in this-procedure ("object", "invoice",                  "print",                                   "actn_invoice_print",                                 "object") .
    run add-right in this-procedure ("object", "kitchen",                  "work",                                    "actn_fbr-prn-goods_work",                            "object") .
    run add-right in this-procedure ("object", "manufacturing",            "LOOKUP",                                  "actn_manufacturing_lookup",                          "object") .
    run add-right in this-procedure ("object", "manufacturing",            "alternative",                             "actn_manufacturing_alternative",                     "object") .
    run add-right in this-procedure ("object", "manufacturing",            "delete manufactured close in fact",       "actn_manufacturing_del-manuf-fact",                  "object") .
    run add-right in this-procedure ("object", "manufacturing",            "dressing",                                "actn_manufacturing_dressing",                        "object") .
    run add-right in this-procedure ("object", "manufacturing",            "fact",                                    "actn_manufacturing_fact",                            "object") .
    run add-right in this-procedure ("object", "manufacturing",            "free",                                    "actn_manufacturing_free",                            "object") .
    run add-right in this-procedure ("object", "manufacturing",            "free,UPDATE",                             "actn_manufacturing_free-update",                     "object") .
    run add-right in this-procedure ("object", "manufacturing",            "gathering",                               "actn_manufacturing_gathering",                       "object") .
    run add-right in this-procedure ("object", "manufacturing",            "manufacturing",                           "actn_manufacturing_manufacturing",                   "object") .
    run add-right in this-procedure ("object", "manufacturing",            "preparation",                             "actn_manufacturing_preparation",                     "object") .
    run add-right in this-procedure ("object", "manufacturing",            "price-sale-comp",                         "actn_manufacturing_price-sale-comp",                 "object") .
    run add-right in this-procedure ("object", "manufacturing",            "price-sale-ingr",                         "actn_manufacturing_price-sale-ingr",                 "object") .
    run add-right in this-procedure ("object", "manufacturing",            "print",                                   "actn_manufacturing_print",                           "object") .
    run add-right in this-procedure ("object", "object-date",              "UPDATE",                                  "actn_object-date_update",                            "object") .
    run add-right in this-procedure ("object", "off",                      "LOOKUP",                                  "actn_write-off_lookup",                              "object") .
    run add-right in this-procedure ("object", "off",                      "add document back date",                  "actn_write-off_add-back-date",                       "object") .
    run add-right in this-procedure ("object", "off",                      "add petrol in document back date",        "actn_write-off_add-ptrl-back-date",                  "object") .
    run add-right in this-procedure ("object", "off",                      "delete document in status fact",          "actn_write-off_del-fact",                            "object") .
    run add-right in this-procedure ("object", "off",                      "delete document on petrol in prev shift", "actn_write-off_del-ptrl-prev-shft",                  "object") .
    run add-right in this-procedure ("object", "off",                      "fact",                                    "actn_write-off_fact",                                "object") .
    run add-right in this-procedure ("object", "off",                      "open",                                    "actn_write-off_opening",                             "object") .
    run add-right in this-procedure ("object", "off",                      "perm-cancellation",                       "actn_write-off_perm-cancellation",                   "object") .
    run add-right in this-procedure ("object", "off",                      "permission",                              "actn_write-off_permission",                          "object") .
    run add-right in this-procedure ("object", "off",                      "preparation",                             "actn_write-off_preparation",                         "object") .
    run add-right in this-procedure ("object", "off",                      "price",                                   "actn_write-off_price",                               "object") .
    run add-right in this-procedure ("object", "off",                      "print",                                   "actn_write-off_print",                               "object") .
    run add-right in this-procedure ("object", "off",                      "reserv",                                  "actn_write-off_rsrv-dtl-action-reserv",              "object") .
    run add-right in this-procedure ("object", "off",                      "shipping",                                "actn_write-off_shipping",                            "object") .
    run add-right in this-procedure ("object", "order",                    "CREATE",                                  "actn_pmnt-ord-doc_add-def",                          "object") .
    run add-right in this-procedure ("object", "order",                    "LOOKUP cmm order LOOKUP",                 "actn_pmnt-ord-doc_lookup",                           "object") .
    run add-right in this-procedure ("object", "order",                    "UPDATE",                                  "actn_pmnt-ord-doc_update",                           "object") .
    run add-right in this-procedure ("object", "order",                    "deletion",                                "actn_pmnt-ord-doc_deletion",                         "object") .
    run add-right in this-procedure ("object", "overvalue",                "LOOKUP",                                  "actn_overvalue_lookup",                              "object") .
    run add-right in this-procedure ("object", "overvalue",                "UPDATE",                                  "actn_overvalue_update",                              "object") .
    run add-right in this-procedure ("object", "overvalue",                "discount",                                "actn_overvalue_discount",                            "object") .
    run add-right in this-procedure ("object", "overvalue",                "fact",                                    "actn_overvalue_fact",                                "object") .
    run add-right in this-procedure ("object", "overvalue",                "order",                                   "actn_overvalue_order",                               "object") .
    run add-right in this-procedure ("object", "overvalue",                "permission",                              "actn_overvalue_permission",                          "object") .
    run add-right in this-procedure ("object", "overvalue",                "preparation",                             "actn_overvalue_preparation",                         "object") .
    run add-right in this-procedure ("object", "overvalue",                "print",                                   "actn_overvalue_print",                               "object") .
    run add-right in this-procedure ("object", "overvalue",                "properties",                              "actn_overvalue_properties",                          "object") .
    run add-right in this-procedure ("object", "period",                   "inquiry",                                 "actn_period_inquires",                               "object") .
    run add-right in this-procedure ("object", "period",                   "reserve",                                 "actn_period_reserves",                               "object") .
    run add-right in this-procedure ("object", "place-io-reference",       "CREATE",                                  "actn_place-io-reference_add-def",                    "object") .
    run add-right in this-procedure ("object", "place-io-reference",       "UPDATE",                                  "actn_place-io-reference_update",                     "object") .
    run add-right in this-procedure ("object", "place-io-reference",       "deletion",                                "actn_place-io-reference_deletion",                   "object") .
    run add-right in this-procedure ("object", "place-reference",          "work",                                    "actn_place-reference_work",                          "global") .
    run add-right in this-procedure ("object", "plgdspm-sts",              "work",                                    "actn_plgdspm-sts_work",                              "object") .
    run add-right in this-procedure ("object", "point-io-reference",       "CREATE",                                  "actn_point-io-reference_add-def",                    "global") .
    run add-right in this-procedure ("object", "point-io-reference",       "UPDATE",                                  "actn_point-io-reference_update",                     "global") .
    run add-right in this-procedure ("object", "point-io-reference",       "deletion",                                "actn_point-io-reference_deletion",                   "global") .
    run add-right in this-procedure ("object", "pump-reference",           "work",                                    "actn_pump-reference_work",                           "object") .
    run add-right in this-procedure ("object", "reciev",                   "CREATE",                                  "actn_ord-rcv_add-def",                               "object") .
    run add-right in this-procedure ("object", "reciev",                   "LOOKUP cmm reciev LOOKUP",                "actn_ord-rcv_lookup",                                "object") .
    run add-right in this-procedure ("object", "reciev",                   "UPDATE",                                  "actn_ord-rcv_update",                                "object") .
    run add-right in this-procedure ("object", "reciev",                   "deletion",                                "actn_ord-rcv_deletion",                              "object") .
    run add-right in this-procedure ("object", "reciev",                   "waybill",                                 "actn_ord-rcv_h-wbill",                               "object") .
    run add-right in this-procedure ("object", "report",                   "lookup-price-cost",                       "actn_reports_lookup-cost",                           "object") .
    run add-right in this-procedure ("object", "report",                   "lookup-price-crsa",                       "actn_reports_lookup-crsa",                           "object") .
    run add-right in this-procedure ("object", "report",                   "lookup-price-mediatr",                    "actn_reports_lookup-medi",                           "object") .
    run add-right in this-procedure ("object", "report",                   "lookup-price-sale",                       "actn_reports_lookup-sale",                           "object") .
    run add-right in this-procedure ("object", "report",                   "report-benet1",                           "actn_reports_report-benet1",                         "object") .
    run add-right in this-procedure ("object", "report",                   "report-benet2",                           "actn_reports_report-benet2",                         "object") .
    run add-right in this-procedure ("object", "report",                   "report-benet3",                           "actn_reports_report-benet3",                         "object") .
    run add-right in this-procedure ("object", "report",                   "report-benet4",                           "actn_reports_report-benet4",                         "object") .
    run add-right in this-procedure ("object", "report",                   "report-benet5",                           "actn_reports_report-benet5",                         "object") .
    run add-right in this-procedure ("object", "report",                   "report-benet6",                           "actn_reports_report-benet6",                         "object") .
    run add-right in this-procedure ("object", "ret",                      "LOOKUP",                                  "actn_return_lookup",                                 "object") .
    run add-right in this-procedure ("object", "ret",                      "add document back date",                  "actn_return_add-back-date",                          "object") .
    run add-right in this-procedure ("object", "ret",                      "add petrol in document back date",        "actn_return_add-ptrl-back-date",                     "object") .
    run add-right in this-procedure ("object", "ret",                      "delete document in status fact",          "actn_return_del-fact",                               "object") .
    run add-right in this-procedure ("object", "ret",                      "delete document on petrol in prev shift", "actn_return_del-ptrl-prev-shft",                     "object") .
    run add-right in this-procedure ("object", "ret",                      "fact",                                    "actn_return_fact",                                   "object") .
    run add-right in this-procedure ("object", "ret",                      "open",                                    "actn_return_opening",                                "object") .
    run add-right in this-procedure ("object", "ret",                      "perm-cancellation",                       "actn_return_perm-cancellation",                      "object") .
    run add-right in this-procedure ("object", "ret",                      "permission",                              "actn_return_permission",                             "object") .
    run add-right in this-procedure ("object", "ret",                      "preparation",                             "actn_return_preparation",                            "object") .
    run add-right in this-procedure ("object", "ret",                      "prepownfirmhold",                         "actn_return_prepownfirmhold",                        "object") .
    run add-right in this-procedure ("object", "ret",                      "price",                                   "actn_return_price",                                  "object") .
    run add-right in this-procedure ("object", "ret",                      "print",                                   "actn_return_print",                                  "object") .
    run add-right in this-procedure ("object", "ret",                      "reserv",                                  "actn_return_rsrv-dtl-action-reserv",                 "object") .
    run add-right in this-procedure ("object", "sale",                     "LOOKUP",                                  "actn_sale_lookup",                                   "object") .
    run add-right in this-procedure ("object", "sale",                     "delete sale in status fact",              "actn_sale_del-sale-fact",                            "object") .
    run add-right in this-procedure ("object", "sale",                     "fact",                                    "actn_sale_fact",                                     "object") .
    run add-right in this-procedure ("object", "scales",                   "POS/send",                                "actn_scales_sending",                                "global") .
    run add-right in this-procedure ("object", "scales",                   "UPDATE",                                  "actn_scales_update",                                 "global") .
    run add-right in this-procedure ("object", "shift",                    "LOOKUP",                                  "actn_rvs-shift_lookup",                              "object") .
    run add-right in this-procedure ("object", "shift",                    "cr-revision",                             "actn_rvs-shift_cr-revision",                         "object") .
    run add-right in this-procedure ("object", "shift",                    "deletion",                                "actn_rvs-shift_deletion",                            "object") .
    run add-right in this-procedure ("object", "shift",                    "fact",                                    "actn_rvs-shift_fact",                                "object") .
    run add-right in this-procedure ("object", "shift",                    "print",                                   "actn_rvs-shift_print",                               "object") .
    run add-right in this-procedure ("object", "shift",                    "regular-mode",                            "actn_shift_regular",                                 "object") .
    run add-right in this-procedure ("object", "shift",                    "supervisor",                              "actn_shift_super",                                   "object") .
    run add-right in this-procedure ("object", "shift",                    "upd-revision",                            "actn_rvs-shift_upd-revision",                        "object") .
    run add-right in this-procedure ("object", "tax-rate-values",          "UPDATE",                                  "actn_tax-rate-values_update",                        "object") .
    run add-right in this-procedure ("object", "wealth moving document",   "CREATE",                                  "actn_wth-doc_add-def",                               "object") .
    run add-right in this-procedure ("object", "wealth moving document",   "LOOKUP",                                  "actn_wth-doc_lookup",                                "object") .
    run add-right in this-procedure ("object", "wealth moving document",   "UPDATE",                                  "actn_wth-doc_update",                                "object") .
    run add-right in this-procedure ("object", "wealth moving document",   "delete document in status fact",          "actn_wth-doc_del-fact",                              "object") .
    run add-right in this-procedure ("object", "wealth moving document",   "deletion",                                "actn_wth-doc_deletion",                              "object") .
    run add-right in this-procedure ("object", "wealth moving document",   "print",                                   "actn_wth-doc_print",                                 "object") .
    run add-right in this-procedure ("object", "weight-code-on-object",    "UPDATE",                                  "actn_object-weight-code_update",                     "object") .
    run add-right in this-procedure ("object", "wth-place-reference",      "work",                                    "actn_wth-place-reference_work",                      "object") .
    run add-right in this-procedure ("object", "wth-receipt",              "input",                                   "actn_wth-receipt_input",                             "object") .
    run add-right in this-procedure ("off",    "client-group",             "discount",                                "actn_clients-group_discount",                        "global") .
    run add-right in this-procedure ("off",    "country-reference",        "work",                                    "actn_country-reference_work",                        "global") .
    run add-right in this-procedure ("off",    "currency-reference",       "work",                                    "actn_currency-reference_work",                       "global") .
    run add-right in this-procedure ("off",    "fin-liability",            "LOOKUP",                                  "actn_fin-liability_lookup",                          "firm") .
    run add-right in this-procedure ("off",    "payment",                  "UPDATE",                                  "actn_payments_update",                               "global") .
    run add-right in this-procedure ("off",    "payment-type",             "preparation",                             "actn_payments-types_input-deletion-updating",        "global") .
    run add-right in this-procedure ("off",    "payments-expected",        "work",                                    "actn_payments-expected_work",                        "firm") .
    run add-right in this-procedure ("off",    "purchase-book",            "print",                                   "actn_purchase-book_print",                           "firm") .
    run add-right in this-procedure ("off",    "reference",                "group-edit",                              "actn_reference_groups-edit",                         "global") .
    run add-right in this-procedure ("off",    "report",                   "print",                                   "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("off",    "sale-book",                "print",                                   "actn_sales-book_print",                              "firm") .
    run add-right in this-procedure ("off",    "scale",                    "UPDATE",                                  "actn_scale_update",                                  "global") .
    run add-right in this-procedure ("off",    "wealth",                   "work",                                    "actn_wealth_work",                                   "global") .
    run add-right in this-procedure ("res",    "POS/restaurant",           "work",                                    "actn_cashdesk-restaurant_work",                      "firm") .
    run add-right in this-procedure ("res",    "report",                   "print",                                   "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("res",    "res-autofbr",              "work",                                    "actn_res-autofbr_work",                              "firm") .
    run add-right in this-procedure ("res",    "res-pln-menu",             "LOOKUP",                                  "actn_res-pln-menu_lookup",                           "firm") .
    run add-right in this-procedure ("res",    "res-pln-menu",             "UPDATE",                                  "actn_res-pln-menu_update",                           "firm") .
    run add-right in this-procedure ("res",    "res-print",                "print",                                   "actn_res-print_print",                               "firm") .
    run add-right in this-procedure ("res",    "res-reference",            "LOOKUP",                                  "actn_res-reference_lookup",                          "firm") .
    run add-right in this-procedure ("res",    "res-reference",            "UPDATE",                                  "actn_res-reference_update",                          "firm") .
    run add-right in this-procedure ("shp",    "report",                   "print",                                   "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("str",    "composition-print",        "print",                                   "actn_composition-print_print",                       "firm") .
    run add-right in this-procedure ("str",    "composition-reprint",      "print",                                   "actn_composition-reprint_print",                     "firm") .
    run add-right in this-procedure ("str",    "report",                   "print",                                   "actn_reports_print",                                 "firm") .
  end.
end procedure.
