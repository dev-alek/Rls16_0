block-level on error undo, throw.
define input parameter p-db-num      like ub.db.db-num     no-undo .
define input parameter p-db-key      like ub.db.db-key     no-undo .
define input parameter p-db-key-enc  like ub.db.db-key-enc no-undo .
define input parameter p-type-unload as   character        no-undo .
define input parameter p-unload-history as logical         no-undo .
define variable vss-revision    as character no-undo initial "$Revision: f29df1d5f130, 3104, rls $":U .
define variable vss-author      as character no-undo initial "$Author: DRuban $":U .
define variable vss-date        as character no-undo initial "$Date: Вт авг 09 09:15:01 2022 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: rest-rdb.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: adm/rest-rdb.p $":U .
define variable vss-description as character no-undo initial "Добавление и восстановление УБД".
define variable mode-erprn as logical no-undo.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
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
  define input  parameter p-db-num         like dst.db.db-num             no-undo .
  define input  parameter p-curr-type-cdrg like dst.code-range.range-type no-undo .
  define input  parameter p-first-code     like dst.code-range.first-code no-undo .
  define input  parameter p-last-code      like dst.code-range.last-code  no-undo .
  define input  parameter p-view-mess      as   logical                   no-undo .
  define output parameter v-b-code         as   integer                   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-main-bcode     like dst.bar-code.b-code no-undo .
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
    define buffer buf_code-range   for dst.code-range .
    define buffer buf-c_code-range for dst.code-range .
    define buffer buf_bar-code     for dst.bar-code .
    define buffer buf_place        for dst.place .
    define buffer buf_goods        for dst.goods .
    define buffer buf_units        for dst.units .
    define buffer buf_prod-bc      for dst.prod-bc .
    define buffer buf_dis-card     for dst.dis-card .
    define buffer buf_dis-rule     for dst.dis-rule .
    define buffer buf_dis-time-rule     for dst.dis-time-rule .
    define buffer buf_firm         for dst.firm .
    define buffer buf_person       for dst.person .
    define buffer buf_contract     for dst.contract .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii0 as integer   no-undo .
define variable v-table-name0 as character no-undo .
define variable v-field-name0 as character no-undo .
define variable buf_h0 as handle no-undo .
define variable q_h0 as handle no-undo .
define variable v-avail0 as integer   no-undo .
define variable v-code-mess0 as character no-undo .
define variable glog0 as logical   no-undo .
define variable v-code_0 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii0 = 1 to num-entries('dst.dis-card'):
      assign
      v-table-name0 = entry(v-ii0, 'dst.dis-card')
      v-field-name0 = entry(v-ii0, 'card-num')
      .
      create buffer buf_h0 for table v-table-name0.
      create query q_h0.
      q_h0:SET-BUFFERS(buf_h0).
      q_h0:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name0
                        ,v-field-name0
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h0:QUERY-OPEN.
      REPEAT while  q_h0:get-next().
        assign
          v-code_0 = buf_h0:buffer-field(v-field-name0):buffer-value
        .
        leave .
      END.
      q_h0:QUERY-CLOSE().
      delete object q_h0.
      delete object buf_h0.
      v-b-code = max(v-code_0, v-b-code).
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
      v-avail0 = 0.
      do v-ii0 = 1 to num-entries('dst.dis-card'):
        assign
        v-table-name0 = entry(v-ii0, 'dst.dis-card')
        v-field-name0 = entry(v-ii0, 'card-num')
        .
        create buffer buf_h0 for table v-table-name0.
        glog0 = buf_h0:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name0
                                , v-field-name0
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h0:available then do:
          assign
          v-avail0 = v-avail0 + 1
          .
          if v-avail0 = 1 then do:
            v-code-mess0 = string(buf_h0:buffer-field(v-field-name0):buffer-value)
            .
          end.
        end.
        delete object buf_h0.
     end.
     if v-avail0 > 0
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
                                            , v-code-mess0
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
      if v-avail0 = 0
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii1 as integer   no-undo .
define variable v-table-name1 as character no-undo .
define variable v-field-name1 as character no-undo .
define variable buf_h1 as handle no-undo .
define variable q_h1 as handle no-undo .
define variable v-avail1 as integer   no-undo .
define variable v-code-mess1 as character no-undo .
define variable glog1 as logical   no-undo .
define variable v-code_1 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii1 = 1 to num-entries('dst.contract'):
      assign
      v-table-name1 = entry(v-ii1, 'dst.contract')
      v-field-name1 = entry(v-ii1, 'contract-code')
      .
      create buffer buf_h1 for table v-table-name1.
      create query q_h1.
      q_h1:SET-BUFFERS(buf_h1).
      q_h1:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name1
                        ,v-field-name1
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h1:QUERY-OPEN.
      REPEAT while  q_h1:get-next().
        assign
          v-code_1 = buf_h1:buffer-field(v-field-name1):buffer-value
        .
        leave .
      END.
      q_h1:QUERY-CLOSE().
      delete object q_h1.
      delete object buf_h1.
      v-b-code = max(v-code_1, v-b-code).
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
      v-avail1 = 0.
      do v-ii1 = 1 to num-entries('dst.contract'):
        assign
        v-table-name1 = entry(v-ii1, 'dst.contract')
        v-field-name1 = entry(v-ii1, 'contract-code')
        .
        create buffer buf_h1 for table v-table-name1.
        glog1 = buf_h1:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name1
                                , v-field-name1
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h1:available then do:
          assign
          v-avail1 = v-avail1 + 1
          .
          if v-avail1 = 1 then do:
            v-code-mess1 = string(buf_h1:buffer-field(v-field-name1):buffer-value)
            .
          end.
        end.
        delete object buf_h1.
     end.
     if v-avail1 > 0
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
                                            , v-code-mess1
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
      if v-avail1 = 0
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
    do v-ii2 = 1 to num-entries('dst.rule-by-call'):
      assign
      v-table-name2 = entry(v-ii2, 'dst.rule-by-call')
      v-field-name2 = entry(v-ii2, 'call#_id')
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
      do v-ii2 = 1 to num-entries('dst.rule-by-call'):
        assign
        v-table-name2 = entry(v-ii2, 'dst.rule-by-call')
        v-field-name2 = entry(v-ii2, 'call#_id')
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
      when 'fdgb':U then do:
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
    do v-ii3 = 1 to num-entries('dst.fin-doc'):
      assign
      v-table-name3 = entry(v-ii3, 'dst.fin-doc')
      v-field-name3 = entry(v-ii3, 'fin-doc-code')
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
      do v-ii3 = 1 to num-entries('dst.fin-doc'):
        assign
        v-table-name3 = entry(v-ii3, 'dst.fin-doc')
        v-field-name3 = entry(v-ii3, 'fin-doc-code')
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
      when 'fmgb':U then do:
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
    do v-ii4 = 1 to num-entries('dst.firm'):
      assign
      v-table-name4 = entry(v-ii4, 'dst.firm')
      v-field-name4 = entry(v-ii4, 'firm-code')
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
      do v-ii4 = 1 to num-entries('dst.firm'):
        assign
        v-table-name4 = entry(v-ii4, 'dst.firm')
        v-field-name4 = entry(v-ii4, 'firm-code')
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
      when 'pngb':U then do:
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
    do v-ii5 = 1 to num-entries('dst.person'):
      assign
      v-table-name5 = entry(v-ii5, 'dst.person')
      v-field-name5 = entry(v-ii5, 'psn-code')
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
      do v-ii5 = 1 to num-entries('dst.person'):
        assign
        v-table-name5 = entry(v-ii5, 'dst.person')
        v-field-name5 = entry(v-ii5, 'psn-code')
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
      when 'drgb':U then do:
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
    do v-ii6 = 1 to num-entries('dst.dis-rule,dst.dis-time-rule'):
      assign
      v-table-name6 = entry(v-ii6, 'dst.dis-rule,dst.dis-time-rule')
      v-field-name6 = entry(v-ii6, 'rule-num,time-rule-num')
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
      do v-ii6 = 1 to num-entries('dst.dis-rule,dst.dis-time-rule'):
        assign
        v-table-name6 = entry(v-ii6, 'dst.dis-rule,dst.dis-time-rule')
        v-field-name6 = entry(v-ii6, 'rule-num,time-rule-num')
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
      when 'bcgb':U then do:
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
    do v-ii7 = 1 to num-entries('dst.bar-code,dst.place'):
      assign
      v-table-name7 = entry(v-ii7, 'dst.bar-code,dst.place')
      v-field-name7 = entry(v-ii7, 'b-code,pl-code')
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
      do v-ii7 = 1 to num-entries('dst.bar-code,dst.place'):
        assign
        v-table-name7 = entry(v-ii7, 'dst.bar-code,dst.place')
        v-field-name7 = entry(v-ii7, 'b-code,pl-code')
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
  define input  parameter p-db-num         like dst.db.db-num             no-undo .
  define input  parameter p-curr-type-cdrg like dst.code-range.range-type no-undo .
  define output parameter p-str-u-f        as   character                 no-undo .
  define output parameter p-str-u-f-rng    as   character                 no-undo .
  do
  on error undo, return error
  :
    define buffer buf_code-range   for dst.code-range.
    define buffer buf-c_code-range for dst.code-range .
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
    define parameter buffer buf_prod-bc  for dst.prod-bc .
    define input  parameter p-action           as character no-undo .
    define output parameter p-return-attribute as logical no-undo .
    def var vss-description as character no-undo init "prodbcat-01: определение параметров дополнительного бар-кода".
    define buffer buf_bar-code   for dst.bar-code   .
    define buffer buf_units      for dst.units      .
    define buffer buf_code-range for dst.code-range .
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
  define input  parameter p-gds-code  like dst.bar-code.gds-code  no-undo .
  define input  parameter p-node-code like dst.bar-code.node-code no-undo .
  define output parameter p-b-code    like dst.bar-code.b-code    no-undo .
  def var vss-description as character no-undo init "gdsbcode-01: определение первичного бар-кода признака".
  def var vss-proc-revision as character no-undo init "library.p gdsbcode-01" .
  define buffer buf_bar-code for dst.bar-code .
  def var v-unit-base like dst.goods.unit-base no-undo .
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
  define input  parameter p-gds-code  like dst.goods.gds-code no-undo .
  define output parameter p-root-node like dst.goods.prt-root no-undo .
  def var vss-description as character no-undo init "gdsrootnode-01: определение корневого признака товара по коду товара".
  define buffer buf_goods   for dst.goods .
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
  define input  parameter p-prt-root  like dst.goods.prt-root no-undo .
  define output parameter p-root-node like dst.goods.prt-root no-undo .
  def var vss-description as character no-undo init "prt-root-to-node-code-01: определение корневого признака шкалы по коду шкалы".
  define buffer buf_gds-prt for dst.gds-prt .
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
  define input  parameter p-gds-code  like dst.goods.gds-code  no-undo .
  define output parameter p-unit-base like dst.goods.unit-base no-undo .
  def var vss-description as character no-undo init "unitbase-01: определение базовой единицы измерения товара".
  define buffer buf_goods for dst.goods .
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cd-attr-code :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  define output parameter p-prop-list      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-code in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ,output p-prop-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-tooltip :
  define input  parameter p-ucode   as character no-undo .
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-tooltip in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-value :
  define input  parameter p-db-num    like ub.cash-desk-attr.db-num        no-undo .
  define input  parameter p-obj-code  like ub.cash-desk-attr.obj-code      no-undo .
  define input  parameter p-pos-type  like ub.cash-desk-attr.pos-type      no-undo .
  define input  parameter p-cash-num  like ub.cash-desk-attr.cash-num      no-undo .
  define input  parameter p-ucode     like ub.cash-desk-attr.upper-attr-code      no-undo .
  define input  parameter p-code      like ub.cash-desk-attr.attr-code      no-undo .
  define output parameter p-character like ub.cash-desk-attr.attr-value-character    no-undo .
  define output parameter p-date      like ub.cash-desk-attr.attr-value-date         no-undo .
  define output parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal      no-undo .
  define output parameter p-integer   like ub.cash-desk-attr.attr-value-integer      no-undo .
  define output parameter p-logical   like ub.cash-desk-attr.attr-value-logical      no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-character
      ,output p-date
      ,output p-decimal
      ,output p-integer
      ,output p-logical
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-write :
  define input parameter p-db-num    like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code  like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type  like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num  like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code      like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-character like ub.cash-desk-attr.attr-value-character no-undo .
  define input parameter p-date      like ub.cash-desk-attr.attr-value-date      no-undo .
  define input parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal   no-undo .
  define input parameter p-integer   like ub.cash-desk-attr.attr-value-integer   no-undo .
  define input parameter p-logical   like ub.cash-desk-attr.attr-value-logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-write in g#attr-lib
      (input p-db-num
      ,input p-obj-code
      ,input p-pos-type
      ,input p-cash-num
      ,input p-ucode
      ,input p-code
      ,input p-character
      ,input p-date
      ,input p-decimal
      ,input p-integer
      ,input p-logical
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-exist :
  define input  parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input  parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input  parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-delete :
  define input parameter  p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter  p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter  p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter  p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter  p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter  p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-news :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  define output parameter p-from-gbd       as logical   no-undo .
  define output parameter p-from-ubd       as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-news in g#attr-lib
      (
       input  p-ucode
      ,input  p-code
      ,output p-news
      ,output p-from-gbd
      ,output p-from-ubd
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-hist :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-hist           as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-hist in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-hist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-parse-date-time returns date
(input  p-string as character
,output p-time   as integer
):
  define variable v-return-value as date      no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-parse-date-time-proc in g#attr-lib
    (input  p-string
    ,output p-time
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run last-check-date-time in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-cd-datetostring returns character
(input  p-date as date
):
  define variable v-return-value as character no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-cd-datetostring-proc in g#attr-lib
    (input  p-date
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr-last-report-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-report-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-maria in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-periodic-tasks :
define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-periodic-tasks in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr_get-attr-int returns integer
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as integer   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-int-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-int-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
function cd-attr_get-attr-log returns logical
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as logical   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-log-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-log-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr_check-marketer :
  define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-value as character no-undo .
  define input parameter p-mode  as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_check-marketer in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
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
procedure cd-attr-manual-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-manual-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-batch-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-batch-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-send-param :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-send-param     as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-send-param in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-send-param
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure db-attr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-code in g#attr-lib
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
procedure db-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-tooltip in g#attr-lib
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
procedure db-attr-value :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-value in g#attr-lib
      (input  p-db-num
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
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-write in g#attr-lib
      (input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input  parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input  parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
def var vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure progs-name :
  define input  parameter p-action-code         as character no-undo .
  define output parameter p-main-prog-name      as character no-undo .
  define output parameter p-list-db-proc-name   as character no-undo .
  define output parameter p-commit-proc-name    as character no-undo .
  define output parameter p-execution-proc-name as character no-undo .
  define output parameter p-recover-proc-name   as character no-undo .
  define output parameter p-after-proc-name     as character no-undo .
  do
  on error undo, return error
  :
    case p-action-code :
            when 'crush_code-range':U then do:     assign       p-main-prog-name      = 'trg/code-rgt.p':U       p-list-db-proc-name   = 'utl/cdrg-dbl.p':U       p-commit-proc-name    = 'comm-crush-cdrg':U       p-execution-proc-name = 'exec-crush-cdrg':U       p-recover-proc-name   = 'rcvr-crush-cdrg':U       p-after-proc-name     = '':U     .   end.
            when 'delete_code-range':U then do:     assign       p-main-prog-name      = 'trg/code-rgt.p':U       p-list-db-proc-name   = 'utl/cdrg-dbl.p':U       p-commit-proc-name    = 'comm-del-cdrg':U       p-execution-proc-name = 'exec-del-cdrg':U       p-recover-proc-name   = 'rcvr-del-cdrg':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-prt-bar-code':U then do:     assign       p-main-prog-name      = 'trg/bar-codt.p':U       p-list-db-proc-name   = 'str/barcddb.p':U       p-commit-proc-name    = 'block-del-prt-bar-code':U       p-execution-proc-name = 'delete-prt-bar-code':U       p-recover-proc-name   = 'undo-delete-prt-bar-code':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-part-bar-code':U then do:     assign       p-main-prog-name      = 'trg/bar-codt.p':U       p-list-db-proc-name   = 'str/barcddb.p':U       p-commit-proc-name    = 'block-del-part-bar-code':U       p-execution-proc-name = 'delete-part-bar-code':U       p-recover-proc-name   = 'undo-delete-part-bar-code':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-ucli-bar-code':U then do:     assign       p-main-prog-name      = 'trg/bar-codt.p':U       p-list-db-proc-name   = 'str/barcddb.p':U       p-commit-proc-name    = 'block-del-ucli-bar-code':U       p-execution-proc-name = 'delete-ucli-bar-code':U       p-recover-proc-name   = 'undo-delete-ucli-bar-code':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-dis-card':U then do:     assign       p-main-prog-name      = 'trg/discardt.p':U       p-list-db-proc-name   = 'trg/discardb.p':U       p-commit-proc-name    = 'block-del-dis-card':U       p-execution-proc-name = 'delete-dis-card':U       p-recover-proc-name   = 'undo-delete-dis-card':U       p-after-proc-name     = '':U     .   end.
            when 'chown-dis-card':U then do:     assign       p-main-prog-name      = 'trg/discardt.p':U       p-list-db-proc-name   = 'trg/discardb.p':U       p-commit-proc-name    = 'block-chown-dis-card':U       p-execution-proc-name = 'chown-dis-card':U       p-recover-proc-name   = 'undo-chown-dis-card':U       p-after-proc-name     = 'after-chown-dis-card':U     .   end.
            when 'delete_nu-dis-rule':U then do:     assign       p-main-prog-name      = 'trg/dis-rult.p':U       p-list-db-proc-name   = 'trg/disruldb.p':U       p-commit-proc-name    = 'block-del-dis-rule':U       p-execution-proc-name = 'delete-dis-rule':U       p-recover-proc-name   = 'undo-delete-dis-rule':U       p-after-proc-name     = '':U     .   end.
            when 'ren-art':U then do:     assign       p-main-prog-name      = 'trg/goodst.p':U       p-list-db-proc-name   = 'utl/renartcd.p':U       p-commit-proc-name    = 'comm-ren-art':U       p-execution-proc-name = 'exec-ren-art':U       p-recover-proc-name   = 'rcvr-ren-art':U       p-after-proc-name     = 'after-ren-art':U     .   end.
            when 'delete_nu-clob-data':U then do:     assign       p-main-prog-name      = 'trg/clobdatt.p':U       p-list-db-proc-name   = 'trg/clbdatdb.p':U       p-commit-proc-name    = 'block-del-clob-data':U       p-execution-proc-name = 'delete-clob-data':U       p-recover-proc-name   = 'undo-delete-clob-data':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-layout':U then do:     assign       p-main-prog-name      = 'trg/layoutt.p':U       p-list-db-proc-name   = 'trg/layoutdb.p':U       p-commit-proc-name    = 'block-del-layout':U       p-execution-proc-name = 'delete-layout':U       p-recover-proc-name   = 'undo-delete-layout':U       p-after-proc-name     = '':U     .   end.
            otherwise do:
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info16, p-action-code ).
      end.
    end case.
  end.
  return.
end procedure.
procedure progs-title :
  define input  parameter p-action-code         as character no-undo .
  define output parameter p-action-title      as character no-undo .
  do
  on error undo, return error
  :
    case p-action-code :
            when 'crush_code-range':U then do:     assign       p-action-title        = "Разбиение диапазона кодов (code-range)"     .   end.
            when 'delete_code-range':U then do:     assign       p-action-title        = "Удаление диапазона кодов (code-range)"     .   end.
            when 'delete_nu-prt-bar-code':U then do:     assign       p-action-title        = "Удаление неисп. бар-кода признака"     .   end.
            when 'delete_nu-part-bar-code':U then do:     assign       p-action-title        = "Удаление неисп. бар-кода партиии"     .   end.
            when 'delete_nu-ucli-bar-code':U then do:     assign       p-action-title        = "Удаление неисп.бар-кода на доп ед.изм."     .   end.
            when 'delete_nu-dis-card':U then do:     assign       p-action-title        = "Удаление неиспользуемой ДК"     .   end.
            when 'chown-dis-card':U then do:     assign       p-action-title        = "Смена владельца ДК"     .   end.
            when 'delete_nu-dis-rule':U then do:     assign       p-action-title        = "Удаление правила скидки по фирме и глобального правила скидки"     .   end.
            when 'ren-art':U then do:     assign       p-action-title        = "Изм. артикула и(или) произв. товара"     .   end.
            when 'delete_nu-clob-data':U then do:     assign       p-action-title        = "Удаление неиспользуемой clob-data"     .   end.
            when 'delete_nu-layout':U then do:     assign       p-action-title        = "Удаление РАСКЛАДКИ"     .   end.
            otherwise do:
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info16, p-action-code ).
      end.
    end case.
  end.
  return.
end procedure.
FUNCTION progs-title-function returns character(
   input  p-action-code         as character):
define variable p-action-title      as character no-undo .
  do
  on error undo, return error
  :
    case p-action-code :
            when 'crush_code-range':U then do:     assign       p-action-title        = "Разбиение диапазона кодов (code-range)"     .   end.
            when 'delete_code-range':U then do:     assign       p-action-title        = "Удаление диапазона кодов (code-range)"     .   end.
            when 'delete_nu-prt-bar-code':U then do:     assign       p-action-title        = "Удаление неисп. бар-кода признака"     .   end.
            when 'delete_nu-part-bar-code':U then do:     assign       p-action-title        = "Удаление неисп. бар-кода партиии"     .   end.
            when 'delete_nu-ucli-bar-code':U then do:     assign       p-action-title        = "Удаление неисп.бар-кода на доп ед.изм."     .   end.
            when 'delete_nu-dis-card':U then do:     assign       p-action-title        = "Удаление неиспользуемой ДК"     .   end.
            when 'chown-dis-card':U then do:     assign       p-action-title        = "Смена владельца ДК"     .   end.
            when 'delete_nu-dis-rule':U then do:     assign       p-action-title        = "Удаление правила скидки по фирме и глобального правила скидки"     .   end.
            when 'ren-art':U then do:     assign       p-action-title        = "Изм. артикула и(или) произв. товара"     .   end.
            when 'delete_nu-clob-data':U then do:     assign       p-action-title        = "Удаление неиспользуемой clob-data"     .   end.
            when 'delete_nu-layout':U then do:     assign       p-action-title        = "Удаление РАСКЛАДКИ"     .   end.
            otherwise do:
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info16, p-action-code ).
      end.
    end case.
  end.
  return p-action-title.
end FUNCTION.
procedure get-row-keyr-string :
 define input  parameter p-key-rec  as character no-undo.
 define output parameter p-tbl-title as character no-undo.
 define output parameter p-rec-string  as character no-undo.
  do
  on error undo, return error
  :
    define variable v-full-tbl-name as character no-undo .
    define variable bh_tbl-name     as handle    no-undo .
    define variable fh              as handle    no-undo .
    define variable v-ok            as logical   no-undo .
    define variable v-field-num     as integer   no-undo .
    define variable v-count-fld     as integer   no-undo .
    define variable v-tbl-name as character no-undo.
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (get-row-keyr-string). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info16 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = "ub.":U + v-tbl-name
      v-field-num     = num-entries( p-key-rec, chr(3) ) - 1
      p-rec-string         = "":U
      v-count-fld     = 0
    .
    find ub._file
      where ub._file._file-name = v-tbl-name
      no-error.
    if not available ub._file then do:
      return error substitute( "&1. Таблица &2 отсутствует в БД", vss-include-info16, v-tbl-name ).
    end.
    assign
    p-tbl-title = ub._file._file-label
    .
    find ub._index
      where recid( ub._index  ) = ub._file._prime-index
      no-error.
    if not available ub._index
      or LC( ub._index._index-name ) = "default":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info16, v-tbl-name ).
    end.
    block_where :
    for each ub._index-field of ub._index  ,
        each ub._field of _index-field
        break by _index-seq
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      if p-rec-string = "":U then do:
        assign
          p-rec-string = "":U
        .
      end.
      else do:
        assign
          p-rec-string = p-rec-string + chr(32) + chr(44)
        .
      end.
      assign
        p-rec-string = p-rec-string + (if p-rec-string = "":u then "":U else chr(32)) + substitute( "&1 = &2":U, ub._field._label, entry( v-count-fld + 1 , p-key-rec, chr(3) ) )
      .
    end.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info16, v-tbl-name ).
    end.
  end.
  return.
end procedure.
FUNCTION uniq-key-rec-string-f returns character(
   input  p-uniq-key-rec         as character):
define variable v-tbl-title as character no-undo .
define variable v-rec-string as character no-undo .
  do
  on error undo, return error
  :
    run get-row-keyr-string in this-procedure (
                                              input p-uniq-key-rec
                                              ,output v-tbl-title
                                              ,output v-rec-string).
    assign
    v-rec-string = (if v-tbl-title <> ? and
                    v-tbl-title <> "":U
                    then (v-tbl-title + ":")
                   else "":U) + chr(32) + v-rec-string
    .
  end.
  return v-rec-string.
end FUNCTION.
procedure create_db-rec_route :
  define input parameter p1-uniq-key-rec as character no-undo .
  define input parameter p1-action       as character no-undo .
  define input parameter p1-operation    as character no-undo .
  define input parameter p1-send-db-list as character no-undo .
  define input parameter p1-db-init      as integer   no-undo .
  define input parameter p1-parameters   as character no-undo .
  define input parameter p1-answer-code  as integer   no-undo .
  define input parameter p1-answer-msg   as character no-undo .
  do
  on error undo, return error
  :
    define variable v-command     as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-curr-db     as integer   no-undo .
    define variable v-db-for-send as character no-undo .
    define variable v-db-num      as integer   no-undo .
    define variable v-db-num-char as character no-undo .
    define buffer buf_sys-ctrl    for ub.sys-ctrl .
    find first buf_sys-ctrl no-lock .
    assign
      v-curr-db     = buf_sys-ctrl.db-num
      v-db-for-send = "":U
    .
    if v-curr-db = 0 then do:
      if p1-answer-code >= 0 then do:
        if v-curr-db <> p1-db-init then do:
          assign
            v-db-for-send = string( p1-db-init )
          .
        end.
      end.
      else do:
        assign
          v-num-entries = num-entries( p1-send-db-list, chr(44) )
        .
        do v-ind = 1 to v-num-entries:
          assign
            v-db-num-char = entry( v-ind, p1-send-db-list, chr(44) )
            v-db-num      = integer( v-db-num-char )
          .
          if v-db-num <> v-curr-db
            and v-db-num <> p1-db-init
          then do:
            if v-db-for-send = "":U then do:
              assign
                v-db-for-send = v-db-num-char
              .
            end.
            else do:
              assign
                v-db-for-send =  v-db-for-send + chr(1) + v-db-num-char
              .
            end.
          end.
        end.
      end.
    end.
    else do:
      assign
        v-db-for-send = "0":U
      .
    end.
    if v-db-for-send <> "":U then do:
      assign
        v-command = "command":U + chr(1)
                    + "two-commit":U + chr(1)
                    + p1-action + chr(1)
                    + p1-operation + chr(1)
                    + p1-uniq-key-rec + chr(1)
                    + string( p1-db-init ) + chr(1)
                    + p1-parameters + chr(1)
                    + string( p1-answer-code ) + chr(1)
                    + p1-answer-msg
      .
      run nws/cr-route.p ( input 'send-cmd':U
                    ,input v-command
                    ,input ?
                    ,input v-db-for-send
                    ) no-error .
      if error-status :error then do:
        return error return-value.
      end.
    end.
  end.
  return.
end procedure.
procedure create_msg_route :
  define input parameter p2-send-db-list as character no-undo .
  define input parameter p2-msg          as character no-undo .
  do
  on error undo, return error
  :
    define variable v-msg-command as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-curr-db     as integer   no-undo .
    define variable v-db-for-send as character no-undo .
    define variable v-db-num      as integer   no-undo .
    define variable v-db-num-char as character no-undo .
    define buffer buf_sys-ctrl    for ub.sys-ctrl .
    find first buf_sys-ctrl no-lock .
    assign
      v-curr-db     = buf_sys-ctrl.db-num
      v-db-for-send = "":U
    .
    if v-curr-db = 0 then do:
      assign
        v-num-entries = num-entries( p2-send-db-list, chr(44) )
      .
      do v-ind = 1 to v-num-entries:
        assign
          v-db-num-char = entry( v-ind, p2-send-db-list, chr(44) )
          v-db-num      = integer( v-db-num-char )
        .
        if v-db-num <> v-curr-db then do:
          if v-db-for-send = "":U then do:
            assign
              v-db-for-send = v-db-num-char
            .
          end.
          else do:
            assign
              v-db-for-send =  v-db-for-send + chr(1) + v-db-num-char
            .
          end.
        end.
      end.
    end.
    else do:
      assign
        v-db-for-send = "0":U
      .
    end.
    if v-db-for-send <> "":U then do:
      assign
        v-msg-command = "command":U + chr(1)
                        + "message-to-log":U + chr(1)
                        + p2-msg
      .
      run nws/cr-route.p ( input 'send-cmd':U
                    ,input v-msg-command
                    ,input ?
                    ,input v-db-for-send
                    ) no-error .
      if error-status :error then do:
        return error substitute( "&1&2&3"
                                  , return-value
                                  , chr(10)
                                  , error-status :get-message(1)
                                ).
      end.
    end.
  end.
  return.
end procedure.
function get-send-db-list returns character
  ( input p-curr-db     as integer
   ,input p-all-db-list as character
  )
:
  define variable v-send-db-list as character no-undo .
  if p-curr-db = 0 then do:
    assign
      v-send-db-list = p-all-db-list
    .
  end.
  else do:
    assign
      v-send-db-list = string(p-curr-db)
    .
  end.
  return v-send-db-list .
end function .
define temp-table temp_db-rec-attr no-undo like ub.db-rec-attr
  field db-list as character
.
procedure fill-two-commit-command :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-main-prog-name      as character no-undo .
    define variable v-list-db-proc-name   as character no-undo .
    define variable v-commit-proc-name    as character no-undo .
    define variable v-execution-proc-name as character no-undo .
    define variable v-recover-proc-name   as character no-undo .
    define variable v-after-proc-name     as character no-undo .
    define buffer buf_db-rec-attr for ub.db-rec-attr .
    for each buf_db-rec-attr exclusive-lock
      break by buf_db-rec-attr.db-num
    on error undo, return error return-value
    :
      find first temp_db-rec-attr
        where temp_db-rec-attr.uniq-key-rec = buf_db-rec-attr.uniq-key-rec
          and temp_db-rec-attr.attr-code    = buf_db-rec-attr.attr-code
        no-error.
      if not available temp_db-rec-attr then do:
        create temp_db-rec-attr.
        buffer-copy buf_db-rec-attr to temp_db-rec-attr
          assign
            temp_db-rec-attr.db-list = string( buf_db-rec-attr.db-num )
        .
        run progs-name in this-procedure
          ( input buf_db-rec-attr.attr-code
           ,output v-main-prog-name
           ,output v-list-db-proc-name
           ,output v-commit-proc-name
           ,output v-execution-proc-name
           ,output v-recover-proc-name
           ,output v-after-proc-name
          ) no-error .
        if error-status :error then do:
          return error substitute( "&1. Ошибка при определении имен процедур. &2", vss-workfile, return-value ).
        end.
        run value( v-list-db-proc-name )
          ( input buf_db-rec-attr.attr-code
           ,input buf_db-rec-attr.uniq-key-rec
           ,output temp_db-rec-attr.db-list
          ) no-error .
        if error-status :error then do:
          return error substitute( "&1. Ошибка при определении списка БД. &2", vss-workfile, return-value ).
        end.
      end.
      if temp_db-rec-attr.db-num <> 0 then do:
        if buf_db-rec-attr.db-num = 0 then do:
          assign
            temp_db-rec-attr.db-num = buf_db-rec-attr.db-num
          .
        end.
        else do:
          assign
            temp_db-rec-attr.db-num = ?
          .
        end.
      end.
    end.
    return.
  end.
end procedure.
define variable attach-list as character no-undo initial '~
abc-analysis-attr~
,abc-analysis-doc~
,abc-analysis-gds-obj~
,abc-analysis-gds-obj-attr~
,abc-analysis-goods~
,abc-analysis-goods-attr~
,abc-analysis-grp~
,abc-analysis-obj~
,abc-analysis-period~
,abc-analysis-prod~
,abcxyz-analysis-attr~
,abcxyz-analysis-goods~
,abcxyz-analysis-goods-attr~
,add-line~
,add-trn~
,add-trn-attr~
,arh-trn-doc-contract~
,c-buyer-in-buyer-group~
,c-buyer-group~
,c-pl-gds-obj~
,c-sht-hist~
,cd-doc-line~
,c-cd-doc-line~
,chk-discnt~
,chk-discnt-attr~
,c-chk-discnt~
,chk-doc~
,chk-doc-attr~
,c-chk-doc-attr~
,chk-gds~
,chk-gds-attr~
,marking-chk~
,c-marking-chk~
,c-marking-attr~
,c-chk-gds~
,chk-pay~
,chk-gds-attr~
,chk-pay-attr~
,c-chk-pay~
,contract-line~
,contract-specif-attr~
,c-contract-line~
,db-grp-obj-price~
,c-db-grp-obj-price~
,doc-abc-def-doc~
,doc-abc-def-obj~
,c-doc-attr~
,doc-fbr-gds~
,c-doc-fbr-gds~
,doc-line~
,c-doc-line~
,doc-line-attr~
,c-doc-line-attr~
,doc-line-sum~
,c-doc-line-sum~
,doc-pl~
,c-doc-pl~
,doc-pl-pump~
,c-doc-pl-pump~
,doc-prts~
,c-doc-prts~
,doc-xyz-def-doc~
,doc-xyz-def-obj~
,esys-route-dump~
,factur-connect-line~
,fbr-line~
,c-fbr-line~
,fbr-pln-line~
,c-fbr-pln-line~
,c-fin-code-an-uchet~
,c-fin-code-cel-nazn~
,c-fin-code-cor-acc~
,fin-doc-attr~
,c-fin-doc-attr~
,fin-doc-tax~
,c-fin-doc-tax~
,fin-gds-part~
,c-fin-gds-part~
,fin-ob-attr~
,c-fin-ob-attr~
,fin-ob-tax~
,c-fin-ob-tax~
,fin-ob-tax-before~
,fin-ob-trn~
,fin-statement-attr~
,c-fin-statement-attr~
,fin-statement-line~
,c-fin-statement-line~
,gds-dtl~
,c-gds-dtl~
,c-global-state~
,global-state-attr~
,c-global-state-attr~
,host-grp-obj-price~
,c-host-grp-obj-price~
,icnt-line~
,inkas-pay~
,c-inkas-pay~
,inkas-pay-desk~
,c-inkas-pay-desk~
,inkas-pay-wth~
,c-inkas-pay-wth~
,inv-doc~
,inv-line~
,c-inv-line~
,layout-elem-rule~
,obj-grp-obj-price~
,c-obj-grp-obj-price~
,ord-cons-attr~
,ord-cons-line-attr~
,ord-doc-attr~
,c-ord-doc-attr~
,ord-dtl~
,c-ord-dtl~
,ord-dtl-cons~
,ord-dtl-rcv~
,ord-gds-cons~
,ord-line~
,c-ord-line~
,ord-line-attr~
,c-ord-line-attr~
,ord-line-rcv~
,ord-rcv-attr~
,ord-rcv-line-attr~
,c-parts~
,c-parts-attr~
,parts-root~
,c-parts-root~
,esys-pck-keys~
,c-price-doc-forming~
,price-doc-forming-attr~
,c-price-doc-forming-attr~
,price-doc-forming-gds~
,c-price-doc-forming-gds~
,price-doc-forming-gdsattr~
,c-price-doc-forming-gdsattr~
,price-doc-forming-gds-qnty~
,c-price-doc-forming-gds-qnty~
,price-doc-forming-gds-sum~
,c-price-doc-forming-gds-sum~
,price-doc-forming-gds-tnv~
,c-price-doc-forming-gds-tnv~
,price-list~
,c-price-list~
,price-list-attr~
,c-price-list-attr~
,price-list-type-attr~
,c-price-list-type-attr~
,price-list-type-cash-pay~
,c-price-list-type-cash-pay~
,price-list-type-cassa~
,c-price-list-type-cassa~
,price-list-type-gds-grp~
,c-price-list-type-gds-grp~
,price-list-type-pay-type~
,c-price-list-type-pay-type~
,c-qnty-group~
,qnty-in-qnty-group~
,c-qnty-in-qnty-group~
,rang-abc-def-obj~
,rang-xyz-def-obj~
,rule-i-script~
,rule-script~
,rule-trans-memo~
,rvs-line~
,rvs-line-attr~
,c-rvs-line~
,rvs-line-pump~
,c-rvs-line-pump~
,rvs-pump~
,sale-doc~
,c-sale-doc~
,schet-fact-line~
,c-schet-fact-line~
,shift-cash~
,c-shift-obj~
,shift-staff~
,c-shift-staff~
,shift-attr~
,c-shift-attr~
,stop-list-line~
,c-sum-group~
,sum-in-sum-group~
,c-sum-in-sum-group~
,c-turnover-group~
,tnv-in-turnover-group~
,c-tnv-in-turnover-group~
,trn-doc-sum~
,c-trn-doc-sum~
,c-trn-reason~
,trn-reason-host~
,c-trn-reason-host~
,trn-reason-obj~
,c-trn-reason-obj~
,trn-rsn-attr~
,c-trn-rsn-attr~
,turnover-buyer~
,turnover-buyer-attr~
,turnover-buyer-gds~
,turnover-buyer-gds-attr~
,wi-mode~
,wth-dtl~
,c-wth-dtl~
,wth-line~
,c-wth-line~
,wth-parts~
,c-wth-parts~
,xyz-analysis-attr~
,xyz-analysis-doc~
,xyz-analysis-gds-obj~
,xyz-analysis-gds-obj-attr~
,xyz-analysis-goods~
,xyz-analysis-goods-attr~
,xyz-analysis-obj~
,xyz-analysis-period~
,utd-lines~
,utd-marking-lines~
,utd-err~
,utd-attr~
,utd-lines-attr~
,utd-marking-lines-attr~
,utd-err-attr~
,marking~
,marking-lines~
,order-doc~
,order-line~
,reportShift~
,shift-param~
,susp-chk~
':U .
define variable news-list as character no-undo initial '~
abc-analysis~
,abcxyz-analysis~
,add-doc~
,action-post~
,action-post-host~
,action-post-menu-group~
,action-post-obj~
,action-post-role~
,action-post-user-login~
,action-role~
,c-action-role~
,action-role-item~
,c-action-role-item~
,action-role-item-gds~
,action-role-item-gds-grp~
,alc-sale-lic~
,c-alc-sale-lic~
,alc-sale-lic-attr~
,c-alc-sale-lic-attr~
,alc-sale-lic-type~
,c-alc-sale-lic-type~
,alc-supp-lic~
,c-alc-supp-lic~
,alc-supp-lic-attr~
,c-alc-supp-lic-attr~
,alc-supp-lic-type~
,c-alc-supp-lic-type~
,alc-type~
,c-alc-type~
,alc-type-attr~
,c-alc-type-attr~
,alc-type-gds~
,c-alc-type-gds~
,arh-fin-doc-an~
,arh-fin-doc-an-nal~
,arh-fin-doc-c-schet-tax-nal~
,arh-fin-doc-contr-schet~
,arh-fin-doc-contr-schet-nal~
,arh-fin-doc-contr-schet-tax~
,arh-fin-doc-schet~
,arh-fin-doc-schet-nal~
,arh-fin-doc-schet-tax~
,arh-fin-doc-schet-tax-nal~
,arh-fin-doc-contr-schet-obj~
,arh-fin-doc-contr-s-nal-obj~
,arh-fin-doc-contr-s-tax-obj~
,arh-fin-doc-c-s-tax-nal-obj~
,arh-fin-doc-schet-obj~
,arh-fin-doc-schet-nal-obj~
,arh-fin-ob-contr~
,attr-prop~
,auto-tank~
,c-auto-tank~
,auto-tank-meas~
,auto-tank-attr~
,auto-section~
,c-auto-section~
,auto-section-attr~
,c-auto-section-attr~
,auto-section-table~
,c-auto-section-table~
,bar-code~
,c-bar-code~
,bar-code-attr~
,c-bar-code-attr~
,bar-code-obj-attr~
,c-bar-code-obj-attr~
,blob-bind~
,buyer-group~
,buyer-in-buyer-group~
,c-cli-hist~
,c-dc-hist~
,c-fbr-gds-grp-hist~
,c-gds-grp-hist~
,c-gds-hist~
,c-nzl-hist~
,c-plc-hist~
,c-pmp-hist~
,c-recipe-hist~
,c-table-bind~
,c-tax-hist~
,c-usr-hist~
,c-wth-hist~
,cash-desk~
,c-cash-desk~
,cash-desk-attr~
,c-cash-desk-attr~
,cash-pay~
,c-cash-pay~
,cash-pay-attr~
,c-cash-pay-attr~
,cd-clu~
,c-cd-clu~
,cd-dlu~
,c-cd-dlu~
,cd-doc~
,c-cd-doc~
,cd-events~
,cd-events-attr~
,cd-event-log~
,cd-event-log-attr~
,cd-grp~
,c-cd-grp~
,cd-plu~
,c-cd-plu~
,c-chk-doc~
,cd-trans~
,cd-video-link~
,cd-video-link-attr~
,cli-art~
,cli-gds~
,cli-grp~
,c-cli-grp~
,clients~
,c-clients~
,clients-attr~
,c-clients-attr~
,clob-bind~
,code-range~
,condition-keeping~
,c-condition-keeping~
,config~
,c-config~
,contract~
,c-contract~
,contract-attr~
,contract-specif~
,c-contract-specif~
,country~
,c-country~
,criterion-analysis~
,cshr-month~
,curr-accnt~
,c-curr-accnt~
,curr-bank~
,c-curr-bank~
,curr-shop~
,currency~
,custom-labels~
,datatype-exp~
,datatype-exp-attr~
,datatype-imp~
,datatype-imp-attr~
,datatype-table~
,datatype-table-exp~
,datatype-table-field~
,datatype-table-field-exp~
,datatype-table-field-imp~
,datatype-table-imp~
,db~
,c-db~
,db-attr~
,db-info~
,db-status~
,deliv-type-cond-keep~
,c-deliv-type-cond-keep~
,delivery-subject~
,c-delivery-subject~
,delivery-type~
,c-delivery-type~
,delivery-type-subject~
,c-delivery-type-subject~
,dis-card~
,c-dis-card~
,dis-card-long~
,c-dis-card-long~
,dis-card-mask~
,c-dis-card-mask~
,dis-card-mask-attr~
,c-dis-card-mask-attr~
,dis-card-property~
,c-dis-card-property~
,dis-card-type~
,c-dis-card-type~
,dis-card-type-attr~
,c-dis-card-type-attr~
,dis-cfg-rule~
,c-dis-cfg-rule~
,dis-cp-rule~
,c-dis-cp-rule~
,dis-dc-rule~
,c-dis-dc-rule~
,dis-dct-rule~
,c-dis-dct-rule~
,dis-gds-rule~
,c-dis-gds-rule~
,dis-gds-rule-attr~
,dis-grp-rule~
,c-dis-grp-rule~
,dis-host~
,c-dis-host~
,dis-obj~
,c-dis-obj~
,dis-rule~
,c-dis-rule~
,dis-some-rule~
,c-dis-some-rule~
,dis-thbj-rule~
,c-dis-thbj-rule~
,dis-time-rule~
,c-dis-time-rule~
,doc-abc-def~
,doc-attr~
,doc-xyz-def~
,drt-prop~
,c-drt-prop~
,edi-status~
,esys-all-attr~
,esys-datatype-exp~
,c-esys-datatype-exp~
,esys-datatype-imp~
,c-esys-datatype-imp~
,esys-pck-rcvd~
,esys-pck-rcvd-err~
,esys-pck-sent~
,esys-route~
,ex-mark~
,c-ex-mark~
,ext-artic~
,c-ext-artic~
,ext-artic-attr~
,c-ext-artic-attr~
,ext-classif~
,c-ext-classif~
,ext-file~
,ext-file-line~
,ext-file-par~
,ext-system~
,c-ext-system~
,ext-system-attr~
,factur-connect~
,fbr-doc~
,c-fbr-doc~
,fbr-gds-grp~
,c-fbr-gds-grp~
,fbr-gds-grp-attr~
,c-fbr-gds-grp-attr~
,fbr-gds-obj~
,c-fbr-gds-obj~
,fbr-history~
,fbr-pln~
,c-fbr-pln~
,fbr-prn~
,c-fbr-prn~
,fbr-prn-gds~
,c-fbr-prn-gds~
,fbr-prn-grp~
,c-fbr-prn-grp~
,fbr-recipe~
,fbr-recipe-gds~
,fin-bank~
,c-fin-bank~
,fin-code-an-uchet~
,fin-code-cel-nazn~
,fin-code-cor-acc~
,fin-connect~
,fin-doc~
,c-fin-doc~
,fin-ob~
,c-fin-ob~
,fin-ob-before~
,fin-schet~
,c-fin-schet~
,fin-statement~
,c-fin-statement~
,firm~
,c-firm~
,gds-grp~
,c-gds-grp~
,gds-grp-attr~
,c-gds-grp-attr~
,gds-grp-obj~
,c-gds-grp-obj~
,gds-host-attr~
,c-gds-host-attr~
,gds-obj~
,gds-obj-attr~
,c-gds-obj-attr~
,gds-obj-prop~
,c-gds-obj-prop~
,gds-obj-prop-attr~
,assortment-matrix~
,assortment-matrix-attr~
,c-assortment-matrix~
,assortment-matrix-goods~
,c-assortment-matrix-goods~
,gds-prt~
,c-gds-prt~
,gds-season~
,c-gds-season~
,gds-add-charges~
,c-gds-add-charges~
,gds-grp-obj-attr~
,c-gds-obj-ref~
,global-state~
,goods~
,c-goods~
,goods-attr~
,c-goods-attr~
,group-period-validity~
,c-group-period-validity~
,grp-obj-price~
,c-grp-obj-price~
,hist-nws-option~
,c-hist-nws-option~
,icnt-doc~
,inkas~
,c-inkas~
,layout~
,c-layout~
,layout-elem~
,layout-elem-rule~
,c-layout-elem-rule~
,lvl-name~
,menu-user~
,menu-user-call~
,marking~
,marking-lines~
,nozzle~
,c-nozzle~
,nozzle-attr~
,c-nozzle-attr~
,nws-doc-hist~
,nws-outline~
,obj-date~
,ord-cons~
,ord-doc~
,c-ord-doc~
,ord-doc-rcv~
,ord-chain~
,parts~
,parts-attr~
,pay-type~
,c-pay-type~
,pck-rcvd~
,pck-sent~
,person~
,c-person~
,pl-gds~
,c-pl-gds~
,pl-gds-attr~
,c-pl-gds-attr~
,pl-gds-pump~
,c-pl-gds-pump~
,pl-level~
,pl-level-imp~
,c-pl-level~
,pl-level-mm~
,pl-level-mm-imp~
,pl-pump~
,c-pl-pump~
,pl-pump-nozzle~
,c-pl-pump-nozzle~
,place~
,c-place~
,place-attr~
,c-place-attr~
,place-imp~
,place-imp-attr~
,place-io~
,c-place-io~
,point-io~
,c-point-io~
,point-place-rel~
,c-point-place-rel~
,point-point-rel~
,c-point-point-rel~
,price-all~
,price-doc~
,c-price-doc~
,price-doc-forming~
,c-price-doc-forming~
,price-list-type~
,c-price-list-type~
,prod-bc~
,c-prod-bc~
,prod-bc-db~
,profile-by-profile~
,c-profile-by-profile~
,prop-head~
,c-prop-head~
,prop-map~
,prop-ref~
,c-prop-ref~
,prop-ref-call~
,prop-ruleset~
,prop-script~
,prt-obj~
,pscript-ruleset~
,pump~
,c-pump~
,pump-attr~
,c-pump-attr~
,pump-nozzle~
,c-pump-nozzle~
,qnty-group~
,rang-abc-def~
,rang-xyz-def~
,recipe~
,c-recipe~
,recipe-develop~
,c-recipe-develop~
,recipe-gds~
,c-recipe-gds~
,regions~
,c-regions~
,norm-loss~
,c-norm-loss~
,rp-by-call~
,c-rp-by-call~
,rp-rule-param~
,rpt-option~
,rule~
,rule-by-call~
,c-rule-by-call~
,rule-by-profile~
,rule-by-set~
,rule-call-param~
,c-rule-call-param~
,rule-profile~
,rule-process~
,ruledict~
,c-ruledict~
,ruledict-param~
,ruleset~
,rvs-doc~
,c-rvs-doc~
,s-coeff~
,c-s-coeff~
,scales~
,c-scales~
,scales-attr~
,c-scales-attr~
,scales-gds~
,c-scales-gds~
,scales-grp~
,c-scales-grp~
,schedule~
,schedule-attr~
,schet-fact-doc~
,c-schet-fact-doc~
,season~
,c-season~
,sert~
,c-sert~
,sert-join~
,shift-obj~
,c-shift-obj~
,shift-period~
,shop~
,c-shop~
,some-lk~
,sr-izmerenia~
,c-sr-izmerenia~
,sr-izmerenia-attr~
,c-sr-izmerenia-attr~
,staff~
,c-staff~
,stop-list~
,store~
,c-store~
,sum-group~
,sum-grp~
,c-sum-grp~
,sum-grp-obj~
,c-sum-grp-obj~
,sysconf~
,c-sysconf~
,tare~
,c-tare~
,tax~
,c-tax~
,tax-rate~
,c-tax-rate~
,tax-rate-gds~
,tax-rate-gds-grp~
,c-tax-rate-gds-grp~
,tax-rate-value~
,tax-units~
,c-tax-units~
,thbj-attr~
,c-thbj-attr~
,trn-doc~
,c-trn-doc~
,trn-reason~
,turnover-buyer-main~
,turnover-group~
,units~
,c-units~
,upgrade~
,user-account~
,c-user-account~
,user-context-history~
,user-host~
,user-login~
,c-user-login~
,user-login-action-item~
,user-login-action-role~
,user-login-attr~
,user-menu-group~
,user-obj~
,user-window-attr~
,var-deliv-gr-per-val~
,c-var-deliv-gr-per-val~
,variant-delivery~
,c-variant-delivery~
,varianty-delivery-gds-obj~
,c-varianty-delivery-gds-obj~
,wealth~
,c-wealth~
,who-lk~
,wth-doc~
,c-wth-doc~
,wth-doc-attr
,wth-gds~
,c-wth-gds~
,wth-ser~
,c-wth-ser~
,wth-par~
,c-wth-par~
,wth-place~
,c-wth-place~
,xyz-analysis~
,c-user-log~
,egais-clients~
,c-egais-clients~
,egais-gds~
,c-egais-gds~
,c-vsd~
,c-gds-mercury
,vsd~
,vsd-attr~
,c-gds-mercury~
,gds-mercury~
,gds-mercury-attr~
,units-attr~
,c-promo-schedule~
,c-promo-schedule-week~
,c-PromoAction~
,c-PromoAttr~
,c-PromoCriterion~
,c-PromoGift~
,c-PromoGoods~
,c-PromoObject~
,promo-schedule~
,promo-schedule-week~
,PromoAction~
,PromoAttr~
,PromoCriterion~
,PromoGift~
,PromoGoods~
,PromoObject~
,tech-prol-pwd~
,c-tech-prol-pwd~
,c-CashBook~
,c-CashBookAttr~
,c-CashBookRule~
,c-CashBookRuleAttr~
,c-OperServ~
,c-operServAttr~
,CashBook~
,CashBookAttr~
,CashBookRule~
,CashBookRuleAttr~
,OperServ~
,OperServAttr~
,c-counter~
,counter~
,c-cashbook-head~
,c-goods-attr-any~
,c-promo-head~
,code~
,c-code~
,devisPc~
,devisPc-attr~
,utd~
,c-utd-head~
,c-utd~
,c-utd-head~
,c-utd-lines~
,c-utd-marking-lines~
,c-utd-err~
,c-utd-attr~
,c-utd-lines-attr~
,c-utd-marking-lines-attr~
,c-utd-err-attr~
,marking-attr
,Xattr~
,xGroupObj~
,xstatus~
,c-contract-specif-attr~
,tran-fuel~
,chk-slip-head~
,chk-slip-string~
,c-marking
,order-doc~
,order-line~
,order-doc-attr~
,order-line-attr~
,c-order-head~
,c-order-doc~
,c-order-line~
,c-order-doc-attr~
,c-order-line-attr~
,reportShift~
,shift-param~
,susp-chk~
':U .
define variable oth-list1 as character no-undo .
define variable oth-list2 as character no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table hst-bush no-undo
field table-name as character
field bush-head as character
field where-phrase as character
field if-phrase as character
field is-main as logical
field joined-buffers as character
index pi is unique primary
table-name
bush-head
index imain is-main
.
define temp-table hst-bind no-undo
field src-table-name as character
field rec-table-name as character
field where-phrase as character
field if-phrase as character
index pi is unique primary
src-table-name
rec-table-name
.
define variable hst-bush_bush-head as character no-undo extent 15 init
[
    'c-gds-hist':U
  , 'c-cli-hist':U
  , 'c-dc-hist':U
  , 'c-tax-hist':U
  , 'c-gds-grp-hist':U
  , 'c-wth-hist':U
  , 'c-fbr-gds-grp-hist':U
  , 'c-plc-hist':U
  , 'c-pmp-hist':U
  , 'c-nzl-hist':U
  , 'c-sht-hist':U
  , 'c-recipe-hist':U
  , 'c-usr-hist':U
  , 'c-table-bind':U
]
 .
define variable hst-psevdo-bush_bush-head as character no-undo extent 15 init
[
  'c-auto-tank':U
,'c-cash-desk':U
,'c-cash-pay':U
,'c-dis-card-type':U
,'c-fbr-prn':U
,'c-prop-head':U
,'c-ruledict':U
,'c-scales':U
,'c-sert':U
 ]
 .
define variable hst-bush_bush-contain as character no-undo .
define variable hst-bush_bush-main as character no-undo .
define variable hst-bush_bush-join as character no-undo .
if p-unload-history then do:
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name =  'c-goods':U
hst-bush.is-main    = yes
hst-bush.where-phrase    = " true ~
, first ub.c-gds-hist no-lock where ub.c-gds-hist.gds-code = ub.c-goods.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-goods.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-goods.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-gds-obj-attr':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist  no-lock where ub.c-gds-hist.gds-code = ub.c-gds-obj-attr.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-gds-obj-attr.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-gds-obj-attr.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-bar-code-obj-attr':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist  no-lock where ub.c-gds-hist.gds-code = ub.c-bar-code-obj-attr.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-bar-code-obj-attr.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-bar-code-obj-attr.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-gds-host-attr':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-gds-host-attr.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-gds-host-attr.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-gds-host-attr.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-goods-attr':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-goods-attr.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-goods-attr.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-goods-attr.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-fbr-gds-obj':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-fbr-gds-obj.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-fbr-gds-obj.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-fbr-gds-obj.chip-num ~
" .
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-s-coeff':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-s-coeff.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-s-coeff.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-s-coeff.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-prod-bc':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.b-code = ub.c-prod-bc.b-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-prod-bc.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-prod-bc.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-bar-code':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-bar-code.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-bar-code.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-bar-code.chip-num ~
and ub.c-gds-hist.subject <> 'prod-bc':U ~
" .
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-bar-code-attr':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-bar-code-attr.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-bar-code-attr.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-bar-code-attr.chip-num ~
" .
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-varianty-delivery-gds-obj':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-varianty-delivery-gds-obj.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-varianty-delivery-gds-obj.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-varianty-delivery-gds-obj.chip-num ~
" .
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-gds-season':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-gds-season.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-gds-season.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-gds-season.chip-num ~
" .
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'tax-rate-gds':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
,each ub.c-gds-hist outer-join no-lock  where ub.c-gds-hist.gds-code = ub.tax-rate-gds.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.tax-rate-gds.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.tax-rate-gds.chip-num ~
" .
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-assortment-matrix-goods':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-assortment-matrix-goods.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-assortment-matrix-goods.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-assortment-matrix-goods.chip-num ~
" .
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-gds-obj-prop':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-gds-obj-prop.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-gds-obj-prop.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-gds-obj-prop.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-pl-gds':U
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = 'c-plc-hist':U ~
and ub.c-table-bind.tbl-name-rec = 'c-gds-hist':U ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-gds.corr-user-db-num  ~
and ub.c-table-bind.chip-num-src = ub.c-pl-gds.chip-num, ~
first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-pl-gds.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
" .
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-pl-gds-attr':U
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = 'c-plc-hist':U ~
and ub.c-table-bind.tbl-name-rec = 'c-gds-hist':U ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-gds-attr.corr-user-db-num  ~
and ub.c-table-bind.chip-num-src = ub.c-pl-gds-attr.chip-num, ~
first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-pl-gds-attr.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
" .
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-pl-gds-pump':U
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = 'c-plc-hist':U ~
and ub.c-table-bind.tbl-name-rec = 'c-gds-hist':U ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-gds-pump.corr-user-db-num ~
and ub.c-table-bind.chip-num-src = ub.c-pl-gds-pump.chip-num  ~
,first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-pl-gds-pump.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
" .
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-dis-gds-rule':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-dis-gds-rule.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-dis-gds-rule.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-dis-gds-rule.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-ext-artic':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-ext-artic.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-ext-artic.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-ext-artic.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-sert':U
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = 'c-sert':U ~
and ub.c-table-bind.tbl-name-rec = 'c-gds-hist':U ~
and ub.c-table-bind.corr-user-db-num = ub.c-sert.corr-user-db-num ~
and ub.c-table-bind.chip-num-src = ub.c-sert.chip-num  ~
,first ub.c-gds-hist no-lock  where ub.c-gds-hist.b-code = ub.c-sert.b-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
" .
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-recipe':U
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = 'c-recipe':U ~
and ub.c-table-bind.tbl-name-rec = 'c-gds-hist':U ~
and ub.c-table-bind.corr-user-db-num = ub.c-recipe.corr-user-db-num  ~
and ub.c-table-bind.chip-num-src = ub.c-recipe.chip-num, ~
first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-recipe.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
" .
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-hist':U
hst-bush.table-name = 'c-recipe-gds':U
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = 'c-recipe-gds':U  ~
and ub.c-table-bind.tbl-name-rec = 'c-gds-hist':U ~
and ub.c-table-bind.corr-user-db-num = ub.c-recipe-gds.corr-user-db-num  ~
and ub.c-table-bind.chip-num-src = ub.c-recipe-gds.chip-num, ~
first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-recipe-gds.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-cli-hist':U
hst-bush.table-name = 'c-clients':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = ub.c-clients.obj-type ~
and ub.c-cli-hist.obj-code  = ub.c-clients.obj-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-clients.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-clients.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-cli-hist':U
hst-bush.table-name = 'c-clients-attr':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = ub.c-clients-attr.obj-type ~
and ub.c-cli-hist.obj-code  = ub.c-clients-attr.obj-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-clients-attr.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-clients-attr.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-cli-hist':U
hst-bush.table-name = 'c-sysconf':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock where ub.c-cli-hist.obj-type  = 'орг':U ~
and ub.c-cli-hist.obj-code  = ub.c-sysconf.host-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-sysconf.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-sysconf.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-cli-hist':U
hst-bush.table-name = 'c-person':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = 'чел':U ~
and ub.c-cli-hist.obj-code  = ub.c-person.psn-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-person.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-person.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-cli-hist':U
hst-bush.table-name = 'c-firm':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = 'орг':U ~
and ub.c-cli-hist.obj-code  = ub.c-firm.firm-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-firm.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-firm.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-cli-hist':U
hst-bush.table-name = 'c-shop':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = 'маг':U ~
and ub.c-cli-hist.obj-code  = ub.c-shop.obj-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-shop.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-shop.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-cli-hist':U
hst-bush.table-name = 'c-store':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = 'скл':U ~
and ub.c-cli-hist.obj-code  = ub.c-store.obj-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-store.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-store.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-cli-hist':U
hst-bush.table-name = 'c-staff':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = 'чел':U ~
and ub.c-cli-hist.obj-code  = ub.c-staff.psn-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-staff.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-staff.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-cli-hist':U
hst-bush.table-name = 'c-dis-thbj-rule':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = ub.c-dis-thbj-rule.obj-type ~
and ub.c-cli-hist.obj-code  = ub.c-dis-thbj-rule.obj-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-dis-thbj-rule.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-dis-thbj-rule.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-cli-hist':U
hst-bush.table-name = 'c-thbj-attr':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = ub.c-thbj-attr.obj-type ~
and ub.c-cli-hist.obj-code  = ub.c-thbj-attr.obj-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-thbj-attr.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-thbj-attr.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-dc-hist':U
hst-bush.table-name = 'c-dis-card':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-dc-hist no-lock  where ub.c-dc-hist.d-card  = ub.c-dis-card.d-card ~
and ub.c-dc-hist.corr-user-db-num = ub.c-dis-card.corr-user-db-num ~
and ub.c-dc-hist.chip-num = ub.c-dis-card.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-dc-hist':U
hst-bush.table-name = 'c-dis-obj':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-dc-hist no-lock  where ub.c-dc-hist.d-card  = ub.c-dis-obj.d-card ~
and ub.c-dc-hist.corr-user-db-num = ub.c-dis-obj.corr-user-db-num ~
and ub.c-dc-hist.chip-num = ub.c-dis-obj.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-dc-hist':U
hst-bush.table-name = 'c-dis-host':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-dc-hist no-lock  where ub.c-dc-hist.d-card  = ub.c-dis-host.d-card ~
and ub.c-dc-hist.corr-user-db-num = ub.c-dis-host.corr-user-db-num ~
and ub.c-dc-hist.chip-num = ub.c-dis-host.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-dc-hist':U
hst-bush.table-name = 'c-dis-card-property':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-dc-hist no-lock  where ub.c-dc-hist.d-card  = ub.c-dis-card-property.d-card ~
and ub.c-dc-hist.corr-user-db-num = ub.c-dis-card-property.corr-user-db-num ~
and ub.c-dc-hist.chip-num = ub.c-dis-card-property.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-dc-hist':U
hst-bush.table-name = 'c-dis-dc-rule':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-dc-hist no-lock  where ub.c-dc-hist.d-card  = ub.c-dis-dc-rule.d-card ~
and ub.c-dc-hist.corr-user-db-num = ub.c-dis-dc-rule.corr-user-db-num ~
and ub.c-dc-hist.chip-num = ub.c-dis-dc-rule.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-tax-hist':U
hst-bush.table-name = 'c-tax':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-tax-hist no-lock  where ub.c-tax-hist.tax-code  = ub.c-tax.tax-code ~
and ub.c-tax-hist.corr-user-db-num = ub.c-tax.corr-user-db-num ~
and ub.c-tax-hist.chip-num = ub.c-tax.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-tax-hist':U
hst-bush.table-name = 'c-tax-rate':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-tax-hist no-lock  where ub.c-tax-hist.tax-code  = ub.c-tax-rate.tax-code ~
and ub.c-tax-hist.corr-user-db-num = ub.c-tax-rate.corr-user-db-num ~
and ub.c-tax-hist.chip-num = ub.c-tax-rate.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-tax-hist':U
hst-bush.table-name = 'tax-rate-value':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, each ub.c-tax-hist no-lock outer-join where ub.c-tax-hist.tax-code  = ub.tax-rate-value.tax-code ~
and ub.c-tax-hist.rate-code  = ub.tax-rate-value.rate-code ~
and ub.c-tax-hist.corr-user-db-num = ub.tax-rate-value.corr-user-db-num ~
and ub.c-tax-hist.chip-num = ub.tax-rate-value.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-tax-hist':U
hst-bush.table-name = 'c-tax-units':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-tax-hist no-lock  where ub.c-tax-hist.tax-code  = ub.c-tax-units.tax-code ~
and ub.c-tax-hist.corr-user-db-num = ub.c-tax-units.corr-user-db-num ~
and ub.c-tax-hist.chip-num = ub.c-tax-units.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-grp-hist':U
hst-bush.table-name = 'c-gds-grp':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-grp-hist no-lock  where ub.c-gds-grp-hist.node-code  = ub.c-gds-grp.node-code ~
and ub.c-gds-grp-hist.corr-user-db-num = ub.c-gds-grp.corr-user-db-num ~
and ub.c-gds-grp-hist.chip-num = ub.c-gds-grp.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-grp-hist':U
hst-bush.table-name = 'c-gds-grp-attr':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-grp-hist no-lock  where ub.c-gds-grp-hist.node-code  = ub.c-gds-grp-attr.node-code ~
and ub.c-gds-grp-hist.corr-user-db-num = ub.c-gds-grp-attr.corr-user-db-num ~
and ub.c-gds-grp-hist.chip-num = ub.c-gds-grp-attr.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-grp-hist':U
hst-bush.table-name = 'c-gds-grp-obj':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-grp-hist no-lock  where ub.c-gds-grp-hist.node-code  = ub.c-gds-grp-obj.node-code ~
and ub.c-gds-grp-hist.corr-user-db-num = ub.c-gds-grp-obj.corr-user-db-num ~
and ub.c-gds-grp-hist.chip-num = ub.c-gds-grp-obj.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-grp-hist':U
hst-bush.table-name = 'c-tax-rate-gds-grp':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-grp-hist no-lock  where ub.c-gds-grp-hist.node-code  = ub.c-tax-rate-gds-grp.node-code ~
and ub.c-gds-grp-hist.corr-user-db-num = ub.c-tax-rate-gds-grp.corr-user-db-num ~
and ub.c-gds-grp-hist.chip-num = ub.c-tax-rate-gds-grp.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-gds-grp-hist':U
hst-bush.table-name = 'c-dis-grp-rule':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
 ub.c-dis-grp-rule.classif-type = 'gds-grp':U, first ub.c-gds-grp-hist no-lock  where ub.c-gds-grp-hist.node-code  = ub.c-dis-grp-rule.node-code ~
and ub.c-gds-grp-hist.corr-user-db-num = ub.c-tax-rate-gds-grp.corr-user-db-num ~
and ub.c-gds-grp-hist.chip-num = ub.c-tax-rate-gds-grp.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-wth-hist':U
hst-bush.table-name = 'c-wealth':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-wth-hist no-lock  where ub.c-wth-hist.wth-code  = ub.c-wealth.wth-code ~
and ub.c-wth-hist.corr-user-db-num = ub.c-wealth.corr-user-db-num ~
and ub.c-wth-hist.chip-num = ub.c-wealth.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-wth-hist':U
hst-bush.table-name = 'c-wth-par':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-wth-hist no-lock  where ub.c-wth-hist.wth-code  = ub.c-wth-par.wth-code ~
and ub.c-wth-hist.corr-user-db-num = ub.c-wth-par.corr-user-db-num ~
and ub.c-wth-hist.chip-num = ub.c-wth-par.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-fbr-gds-grp-hist':U
hst-bush.table-name = 'c-fbr-gds-grp':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-fbr-gds-grp-hist no-lock  where ub.c-fbr-gds-grp-hist.obj-type  = ub.c-fbr-gds-grp.obj-type ~
and ub.c-fbr-gds-grp-hist.obj-code  = ub.c-fbr-gds-grp.obj-code ~
and ub.c-fbr-gds-grp-hist.node-code  = ub.c-fbr-gds-grp.node-code ~
and ub.c-fbr-gds-grp-hist.corr-user-db-num = ub.c-fbr-gds-grp.corr-user-db-num ~
and ub.c-fbr-gds-grp-hist.chip-num = ub.c-fbr-gds-grp.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-fbr-gds-grp-hist':U
hst-bush.table-name = 'c-fbr-gds-grp-attr':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-fbr-gds-grp-hist no-lock  where ub.c-fbr-gds-grp-hist.obj-type  = ub.c-fbr-gds-grp-attr.obj-type ~
and ub.c-fbr-gds-grp-hist.obj-code  = ub.c-fbr-gds-grp-attr.obj-code ~
and ub.c-fbr-gds-grp-hist.node-code  = ub.c-fbr-gds-grp-attr.node-code ~
and ub.c-fbr-gds-grp-hist.corr-user-db-num = ub.c-fbr-gds-grp-attr.corr-user-db-num ~
and ub.c-fbr-gds-grp-hist.chip-num = ub.c-fbr-gds-grp-attr.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-plc-hist':U
hst-bush.table-name = 'c-place':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock  where ub.c-plc-hist.obj-type  = ub.c-place.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-place.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-place.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-place.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-place.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-plc-hist':U
hst-bush.table-name = 'c-pl-level':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock  where ub.c-plc-hist.obj-type  = ub.c-place.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-level.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-level.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-level.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-level.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-plc-hist':U
hst-bush.table-name = 'c-pl-gds':U
hst-bush.is-main    =  yes
hst-bush.joined-buffers =  "c-table-bind,c-gds-hist"
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock  where ub.c-plc-hist.obj-type  = ub.c-pl-gds.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-gds.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-gds.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-gds.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-gds.chip-num ~
,first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = 'c-plc-hist':U ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-gds.corr-user-db-num  ~
and ub.c-table-bind.chip-num-src = ub.c-pl-gds.chip-num, ~
first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-pl-gds.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-plc-hist':U
hst-bush.table-name = 'c-pl-gds-pump':U
hst-bush.is-main    =  yes
hst-bush.joined-buffers =  "c-table-bind,c-gds-hist,buf_c-table-bind,c-pmp-hist"
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock  where ub.c-plc-hist.obj-type  = ub.c-pl-gds-pump.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-gds-pump.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-gds-pump.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-gds-pump.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-gds-pump.chip-num ~
,first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = 'c-plc-hist':U ~
and ub.c-table-bind.tbl-name-rec = 'c-gds-hist':U ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-gds-pump.corr-user-db-num ~
and ub.c-table-bind.chip-num-src = ub.c-pl-gds-pump.chip-num ~
,first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-pl-gds-pump.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num  ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec  ~
,first buf_c-table-bind no-lock  where buf_c-table-bind.tbl-name-src = 'c-plc-hist':U ~
and buf_c-table-bind.tbl-name-rec = 'c-pmp-hist':U ~
and buf_c-table-bind.corr-user-db-num = ub.c-pl-gds-pump.corr-user-db-num  ~
and buf_c-table-bind.chip-num-src = ub.c-pl-gds-pump.chip-num ~
,first ub.c-pmp-hist no-lock  where ub.c-pmp-hist.obj-type = ub.c-pl-gds-pump.obj-type  ~
and ub.c-pmp-hist.obj-code = ub.c-pl-gds-pump.obj-code ~
and ub.c-pmp-hist.pump-code = ub.c-pl-gds-pump.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = buf_c-table-bind.corr-user-db-num  ~
and ub.c-pmp-hist.chip-num = buf_c-table-bind.chip-num-rec ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-plc-hist':U
hst-bush.table-name = 'c-pl-pump':U
hst-bush.is-main    =  yes
hst-bush.joined-buffers =  "c-table-bind,c-pmp-hist"
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock  where ub.c-plc-hist.obj-type  = ub.c-pl-pump.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-pump.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-pump.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-pump.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-pump.chip-num ~
,first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = 'c-plc-hist':U ~
and ub.c-table-bind.tbl-name-rec = 'c-pmp-hist':U ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-pump.corr-user-db-num ~
and ub.c-table-bind.chip-num-src = ub.c-pl-pump.chip-num ~
,first ub.c-pmp-hist no-lock  where ub.c-pmp-hist.obj-type = ub.c-pl-pump.obj-type ~
and ub.c-pmp-hist.obj-code = ub.c-pl-pump.obj-code ~
and ub.c-pmp-hist.pump-code = ub.c-pl-pump.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = ub.c-table-bind.chip-num-rec ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-plc-hist':U
hst-bush.table-name = 'c-pl-pump-nozzle':U
hst-bush.is-main    =  yes
hst-bush.joined-buffers =  "c-table-bind,c-pmp-hist,buf_c-table-bind,c-nzl-hist"
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock  where ub.c-plc-hist.obj-type  = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-pump-nozzle.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-pump-nozzle.chip-num  ~
,first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = 'c-plc-hist':U ~
and ub.c-table-bind.tbl-name-rec = 'c-pmp-hist':U ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num  ~
and ub.c-table-bind.chip-num-src = ub.c-pl-pump-nozzle.chip-num ~
,first ub.c-pmp-hist no-lock  where ub.c-pmp-hist.obj-type = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-pmp-hist.obj-code = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-pmp-hist.pump-code = ub.c-pl-pump-nozzle.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num  ~
and ub.c-pmp-hist.chip-num = ub.c-table-bind.chip-num-rec ~
,first buf_c-table-bind no-lock  where buf_c-table-bind.tbl-name-src = 'c-plc-hist':U ~
and buf_c-table-bind.tbl-name-rec = 'c-nzl-hist':U ~
and buf_c-table-bind.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num  ~
and buf_c-table-bind.chip-num-src = ub.c-pl-pump-nozzle.chip-num ~
,first ub.c-nzl-hist no-lock  where ub.c-nzl-hist.obj-type = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-nzl-hist.obj-code = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-nzl-hist.nozzle-code = ub.c-pl-pump-nozzle.nozzle-code ~
and ub.c-nzl-hist.corr-user-db-num = buf_c-table-bind.corr-user-db-num  ~
and ub.c-nzl-hist.chip-num = buf_c-table-bind.chip-num-rec ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-plc-hist':U
hst-bush.table-name = 'c-place-attr':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock  where ub.c-plc-hist.obj-type  = ub.c-place-attr.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-place-attr.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-place-attr.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-place-attr.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-place-attr.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-plc-hist':U
hst-bush.table-name = 'c-pl-gds-attr':U
hst-bush.is-main    =  yes
hst-bush.joined-buffers = "c-table-bind,c-gds-hist"
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock  where ub.c-plc-hist.obj-type  = ub.c-pl-gds-attr.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-gds-attr.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-gds-attr.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-gds-attr.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-gds-attr.chip-num ~
,first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = 'c-plc-hist':U ~
and ub.c-table-bind.tbl-name-rec = 'c-gds-hist':U ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-gds-attr.corr-user-db-num  ~
and ub.c-table-bind.chip-num-src = ub.c-pl-gds-attr.chip-num, ~
first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-pl-gds-attr.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
" .
create hst-bush.
assign
hst-bush.bush-head    = 'c-pmp-hist':U
hst-bush.table-name = 'c-pump':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-pmp-hist no-lock  where ub.c-pmp-hist.obj-type  = ub.c-pump.obj-type ~
and ub.c-pmp-hist.obj-code  = ub.c-pump.obj-code ~
and ub.c-pmp-hist.pump-code  = ub.c-pump.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-pump.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = ub.c-pump.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-pmp-hist':U
hst-bush.table-name = 'c-pump-nozzle':U
hst-bush.is-main    =  yes
hst-bush.joined-buffers =  "c-table-bind,c-nzl-hist"
hst-bush.where-phrase = " true ~
, first ub.c-pmp-hist no-lock  where ub.c-pmp-hist.obj-type  = ub.c-pump-nozzle.obj-type  ~
and ub.c-pmp-hist.obj-code  = ub.c-pump-nozzle.obj-code ~
and ub.c-pmp-hist.pump-code  = ub.c-pump-nozzle.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-pump-nozzle.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = ub.c-pump-nozzle.chip-num ~
,first ub.c-table-bind no-lock where ub.c-table-bind.tbl-name-src = 'c-pmp-hist':U ~
and ub.c-table-bind.corr-user-db-num     = ub.c-pump-nozzle.corr-user-db-num ~
and ub.c-table-bind.chip-num-src     = ub.c-pump-nozzle.chip-num ~
,first ub.c-nzl-hist no-lock where ub.c-nzl-hist.nozzle-code = ub.c-pump-nozzle.nozzle-code ~
and ub.c-nzl-hist.obj-type = ub.c-pump-nozzle.obj-type ~
and ub.c-nzl-hist.obj-code = ub.c-pump-nozzle.obj-code ~
and ub.c-nzl-hist.corr-user-db-num = ub.c-pump-nozzle.corr-user-db-num ~
and ub.c-nzl-hist.chip-num = ub.c-table-bind.chip-num-rec ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-pmp-hist':U
hst-bush.table-name = 'c-pl-gds-pump':U
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock where ub.c-plc-hist.obj-type  = ub.c-pl-gds-pump.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-gds-pump.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-gds-pump.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-gds-pump.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-gds-pump.chip-num ~
,first ub.c-table-bind no-lock where ub.c-table-bind.tbl-name-src = 'c-plc-hist':U ~
and ub.c-table-bind.tbl-name-rec = 'c-gds-hist':U ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-gds-pump.corr-user-db-num and ~
and ub.c-table-bind.chip-num-src = ub.c-pl-gds-pump.chip-num, ~
first ub.c-gds-hist no-lock where ub.c-gds-hist.gds-code = ub.c-pl-gds-pump.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
,first buf_c-table-bind no-lock where ub.c-table-bind.tbl-name-src = 'c-plc-hist':U ~
and buf_c-table-bind.tbl-name-rec = 'c-pmp-hist':U ~
and buf_c-table-bind.corr-user-db-num = ub.c-pl-gds-pump.corr-user-db-num and ~
and buf_c-table-bind.chip-num-src = ub.c-pl-gds-pump.chip-num, ~
,first ub.c-pmp-hist no-lock where ub.c-pmp-hist.obj-type = ub.c-pl-gds-pump.obj-type ~
and ub.c-pmp-hist.obj-code = ub.c-pl-gds-pump.obj-code ~
and ub.c-pmp-hist.pump-code = ub.c-pl-gds-pump.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = buf_c-table-bind.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = buf_c-table-bind.chip-num-rec ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-pmp-hist':U
hst-bush.table-name = 'c-pl-pump':U
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock where ub.c-plc-hist.obj-type  = ub.c-pl-pump.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-pump.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-pump.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-pump.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-pump.chip-num ~
,first ub.c-table-bind no-lock where ub.c-table-bind.tbl-name-src = 'c-plc-hist':U ~
and ub.c-table-bind.tbl-name-rec = 'c-pmp-hist':U ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-pump.corr-user-db-num ~
and ub.c-table-bind.chip-num-src = ub.c-pl-pump.chip-num ~
,first ub.c-pmp-hist no-lock where ub.c-pmp-hist.obj-type = ub.c-pl-pump.obj-type ~
and ub.c-pmp-hist.obj-code = ub.c-pl-pump.obj-code ~
and ub.c-pmp-hist.pump-code = ub.c-pl-pump.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = ub.c-table-bind.chip-num-rec ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-pmp-hist':U
hst-bush.table-name = 'c-pl-pump-nozzle':U
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock where ub.c-plc-hist.obj-type  = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-pump-nozzle.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-pump-nozzle.chip-num ~
,first ub.c-table-bind no-lock where ub.c-table-bind.tbl-name-src = 'c-plc-hist':U ~
and ub.c-table-bind.tbl-name-rec = 'c-pmp-hist':U ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num and ~
and ub.c-table-bind.chip-num-src = ub.c-pl-pump-nozzle.chip-num, ~
,first ub.c-pmp-hist no-lock where ub.c-pmp-hist.obj-type = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-pmp-hist.obj-code = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-pmp-hist.pump-code = ub.c-pl-pump-nozzle.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = ub.c-table-bind.chip-num-rec ~
,first buf_c-table-bind no-lock where ub.c-table-bind.tbl-name-src = 'c-plc-hist':U ~
and buf_c-table-bind.tbl-name-rec = 'c-nzl-hist':U ~
and buf_c-table-bind.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num and ~
and buf_c-table-bind.chip-num-src = ub.c-pl-pump-nozzle.chip-num, ~
,first ub.c-nzl-hist no-lock where ub.c-nzl-hist.obj-type = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-nzl-hist.obj-code = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-nzl-hist.nozzle-code = ub.c-pl-pump-nozzle.nozzle-code ~
and ub.c-nzl-hist.corr-user-db-num = buf_c-table-bind.corr-user-db-num ~
and ub.c-nzl-hist.chip-num = buf_c-table-bind.chip-num-rec ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-pmp-hist':U
hst-bush.table-name = 'c-pump-attr':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-pmp-hist no-lock where ub.c-pmp-hist.obj-type  = ub.c-pump-attr.obj-type ~
and ub.c-pmp-hist.obj-code  = ub.c-pump-attr.obj-code ~
and ub.c-pmp-hist.pump-code  = ub.c-pump-attr.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-pump-attr.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = ub.c-pump-attr.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-nzl-hist':U
hst-bush.table-name = 'c-nozzle':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-nzl-hist no-lock where ub.c-nzl-hist.obj-type  = ub.c-nozzle.obj-type ~
and ub.c-nzl-hist.obj-code  = ub.c-nozzle.obj-code ~
and ub.c-nzl-hist.nozzle-code  = ub.c-nozzle.nozzle-code ~
and ub.c-nzl-hist.corr-user-db-num = ub.c-nozzle.corr-user-db-num ~
and ub.c-nzl-hist.chip-num = ub.c-nozzle.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-nzl-hist':U
hst-bush.table-name = 'c-pump-nozzle':U
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-pmp-hist no-lock where ub.c-pmp-hist.obj-type  = ub.c-pump.obj-type ~
and ub.c-pmp-hist.obj-code  = ub.c-pump.obj-code ~
and ub.c-pmp-hist.pump-code  = ub.c-pump.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-pump.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = ub.c-pump.chip-num ~
,first ub.c-table-bind no-lock where ub.c-table-bind.tbl-name-src = 'c-pmp-hist':U ~
and ub.c-table-bind.corr-user-db-num     = ub.c-pump-nozzle.corr-user-db-num ~
and ub.c-table-bind.chip-num-src     = ub.c-pump-nozzle.chip-num ~
,first ub.c-nzl-hist no-lock where ub.c-nzl-hist.nozzle-code = ub.c-pump-nozzle.nozzle-code ~
and ub.c-nzl-hist.obj-type = ub.c-pump-nozzle.obj-type ~
and ub.c-nzl-hist.obj-code = ub.c-pump-nozzle.obj-code ~
and ub.c-nzl-hist.corr-user-db-num = ub.c-pump-nozzle.corr-user-db-num ~
and ub.c-nzl-hist.chip-num = ub.c-table-bind.chip-num-rec ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-nzl-hist':U
hst-bush.table-name = 'c-pl-pump-nozzle':U
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock where ub.c-plc-hist.obj-type  = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-pump-nozzle.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-pump-nozzle.chip-num ~
,first ub.c-table-bind no-lock where ub.c-table-bind.tbl-name-src = 'c-plc-hist':U ~
and ub.c-table-bind.tbl-name-rec = 'c-pmp-hist':U ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num and ~
and ub.c-table-bind.chip-num-src = ub.c-pl-pump-nozzle.chip-num, ~
,first ub.c-pmp-hist no-lock where ub.c-pmp-hist.obj-type = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-pmp-hist.obj-code = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-pmp-hist.pump-code = ub.c-pl-pump-nozzle.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = ub.c-table-bind.chip-num-rec ~
,first buf_c-table-bind no-lock where ub.c-table-bind.tbl-name-src = 'c-plc-hist':U ~
and buf_c-table-bind.tbl-name-rec = 'c-nzl-hist':U ~
and buf_c-table-bind.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num and ~
and buf_c-table-bind.chip-num-src = ub.c-pl-pump-nozzle.chip-num, ~
,first ub.c-nzl-hist no-lock where ub.c-nzl-hist.obj-type = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-nzl-hist.obj-code = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-nzl-hist.nozzle-code = ub.c-pl-pump-nozzle.nozzle-code ~
and ub.c-nzl-hist.corr-user-db-num = buf_c-table-bind.corr-user-db-num ~
and ub.c-nzl-hist.chip-num = buf_c-table-bind.chip-num-rec ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-nzl-hist':U
hst-bush.table-name = 'c-nozzle-attr':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-nzl-hist no-lock where ub.c-nzl-hist.obj-type  = ub.c-nozzle-attr.obj-type ~
and ub.c-nzl-hist.obj-code  = ub.c-nozzle-attr.obj-code ~
and ub.c-nzl-hist.nozzle-code  = ub.c-nozzle-attr.nozzle-code ~
and ub.c-nzl-hist.corr-user-db-num = ub.c-nozzle-attr.corr-user-db-num ~
and ub.c-nzl-hist.chip-num = ub.c-nozzle-attr.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-sht-hist':U
hst-bush.table-name = 'c-shift-obj':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-sht-hist no-lock where ub.c-sht-hist.obj-type  = ub.c-shift-obj.obj-type ~
and ub.c-sht-hist.obj-code  = ub.c-shift-obj.obj-code ~
and ub.c-sht-hist.shift-date  = ub.c-shift-obj.shift-date ~
and ub.c-sht-hist.shift-num  = ub.c-shift-obj.shift-num ~
and ub.c-sht-hist.corr-user-db-num = ub.c-shift-obj.corr-user-db-num ~
and ub.c-sht-hist.chip-num = ub.c-shift-obj.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-sht-hist':U
hst-bush.table-name = 'c-shift-staff':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-sht-hist no-lock where ub.c-sht-hist.obj-type  = ub.c-shift-staff.obj-type ~
and ub.c-sht-hist.obj-code  = ub.c-shift-staff.obj-code ~
and ub.c-sht-hist.shift-date  = ub.c-shift-staff.shift-date ~
and ub.c-sht-hist.shift-num  = ub.c-shift-staff.shift-num ~
and ub.c-sht-hist.corr-user-db-num = ub.c-shift-staff.corr-user-db-num ~
and ub.c-sht-hist.chip-num = ub.c-shift-staff.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-recipe-hist':U
hst-bush.table-name = 'c-recipe':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-recipe-hist no-lock where ub.c-recipe-hist.corr-user-db-num = ub.c-recipe.corr-user-db-num ~
and ub.c-recipe-hist.chip-num = ub.c-recipe.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-recipe-hist':U
hst-bush.table-name = 'c-recipe-gds':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-recipe-hist no-lock where ub.c-recipe-hist.corr-user-db-num = ub.c-recipe-gds.corr-user-db-num ~
and ub.c-recipe-hist.chip-num = ub.c-recipe-gds.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-usr-hist':U
hst-bush.table-name = 'c-user-account':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-usr-hist no-lock where ub.c-usr-hist.user-id = ub.c-user-account.user-id ~
and ub.c-usr-hist.corr-user-db-num = ub.c-user-account.corr-user-db-num ~
and ub.c-usr-hist.chip-num = ub.c-user-account.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-usr-hist':U
hst-bush.table-name = 'c-user-login':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-usr-hist no-lock where ub.c-usr-hist.user-id = ub.c-user-login.user-id ~
and ub.c-usr-hist.corr-user-db-num = ub.c-user-login.corr-user-db-num ~
and ub.c-usr-hist.chip-num = ub.c-user-login.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-auto-tank':U
hst-bush.table-name = 'c-auto-tank':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
ub.c-auto-tank.subject = 'auto-tank':U ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-cash-desk':U
hst-bush.table-name = 'c-cash-desk':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
ub.c-cash-desk.subject = 'cash-desk':U ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-cash-desk':U
hst-bush.table-name = 'c-cash-desk-attr':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cash-desk no-lock where ub.c-cash-desk.db-num = ub.c-cash-desk-attr.db-num ~
and  ub.c-cash-desk.obj-code = ub.c-cash-desk-attr.obj-code  ~
and  ub.c-cash-desk.pos-type = ub.c-cash-desk-attr.pos-type  ~
and  ub.c-cash-desk.cash-num = ub.c-cash-desk-attr.cash-num  ~
and  ub.c-cash-desk.corr-user-db-num = ub.c-cash-desk-attr.corr-user-db-num ~
and ub.c-cash-desk.chip-num = ub.c-cash-desk-attr.chip-num  ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-cash-pay':U
hst-bush.table-name = 'c-cash-pay':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
ub.c-cash-pay.subject = 'cash-pay':U ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-cash-pay':U
hst-bush.table-name = 'c-cash-pay-attr':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cash-pay no-lock where ub.c-cash-pay.cdpay-code = ub.c-cash-pay-attr.cdpay-code ~
and  ub.c-cash-pay.curr-code = ub.c-cash-pay-attr.curr-code  ~
and  ub.c-cash-pay.corr-user-db-num = ub.c-cash-pay-attr.corr-user-db-num ~
and ub.c-cash-pay.chip-num = ub.c-cash-pay-attr.chip-num  ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-cash-pay':U
hst-bush.table-name = 'c-dis-cp-rule':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cash-pay no-lock where ub.c-cash-pay.cdpay-code = ub.c-dis-cp-rule.cdpay-code ~
and  ub.c-cash-pay.curr-code = ub.c-dis-cp-rule.curr-code  ~
and  ub.c-cash-pay.corr-user-db-num = ub.c-dis-cp-rule.corr-user-db-num ~
and ub.c-cash-pay.chip-num = ub.c-dis-cp-rule.chip-num  ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-dis-card-type':U
hst-bush.table-name = 'c-dis-card-type':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
ub.c-dis-card-type.subject = 'dis-card-type':U ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-dis-card-type':U
hst-bush.table-name = 'c-dis-card-type-attr':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-dis-card-type no-lock where ub.c-dis-card-type.emitent-host-code = ub.c-dis-card-type-attr.emitent-host-code ~
and  ub.c-dis-card-type.type = ub.c-dis-card-type-attr.type  ~
and  ub.c-dis-card-type.host-code = ub.c-dis-card-type-attr.host-code  ~
and  ub.c-dis-card-type.obj-type = ub.c-dis-card-type-attr.obj-type  ~
and  ub.c-dis-card-type.obj-code = ub.c-dis-card-type-attr.obj-code  ~
and  ub.c-dis-card-type.corr-user-db-num = ub.c-dis-card-type-attr.corr-user-db-num ~
and ub.c-dis-card-type.chip-num = ub.c-dis-card-type-attr.chip-num  ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-dis-card-type':U
hst-bush.table-name = 'c-dis-card-mask':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-dis-card-type no-lock where ub.c-dis-card-type.subject = 'dis-card-mask':U ~
and  ub.c-dis-card-type.corr-user-db-num = ub.c-dis-card-mask.corr-user-db-num ~
and ub.c-dis-card-type.chip-num = ub.c-dis-card-mask.chip-num  ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-dis-card-type':U
hst-bush.table-name = 'c-rp-by-call':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ub.c-rp-by-call.call_id begins ('dis-card-type':U + chr(3)) ~
, first ub.c-dis-card-type no-lock where ub.c-dis-card-type.subject = 'rp-by-call':U ~
and  ub.c-dis-card-type.corr-user-db-num = ub.c-rp-by-call.corr-user-db-num ~
and ub.c-dis-card-type.chip-num = ub.c-rp-by-call.chip-num  ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-dis-card-type':U
hst-bush.table-name = 'c-rule-by-call':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ub.c-rule-by-call.call_id begins ('dis-card-type':U  + chr(3)) ~
, first ub.c-dis-card-type no-lock where ub.c-dis-card-type.subject = 'rule-by-call':U ~
and  ub.c-dis-card-type.corr-user-db-num = ub.c-rule-by-call.corr-user-db-num ~
and ub.c-dis-card-type.chip-num = ub.c-rule-by-call.chip-num  ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-dis-card-type':U
hst-bush.table-name = 'c-rule-call-param':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ub.c-rule-call-param.call_id begins ('dis-card-type':U  + chr(3)) ~
, first ub.c-dis-card-type no-lock where ub.c-dis-card-type.subject = 'rule-call-param':U ~
and  ub.c-dis-card-type.corr-user-db-num = ub.c-rule-call-param.corr-user-db-num ~
and ub.c-dis-card-type.chip-num = ub.c-rule-call-param.chip-num  ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-dis-card-type':U
hst-bush.table-name = 'c-dis-dct-rule':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-dis-card-type no-lock where ub.c-dis-card-type.subject = 'dis-dct-rule':U ~
and  ub.c-dis-card-type.corr-user-db-num = ub.c-dis-dct-rule.corr-user-db-num ~
and ub.c-dis-card-type.chip-num = ub.c-dis-dct-rule.chip-num  ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-dis-card-type':U
hst-bush.table-name = 'c-hist-nws-option':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ub.c-hist-nws-option.subject-group = 'c-dc-hist':U ~
, first ub.ctable-bind no-lock where ub.c-table-bind.corr-user-db-num = ub.c-dis-card-type.corr-user-db-num ~
AND ub.c-table-bind.tbl-name-rec     = ~{&table_c-dis-card-type~}  ~
AND ub.c-table-bind.chip-num-rec     = uB.c-dis-card-type.chip-num ~
,first UB.c-hist-nws-option no-lock where ~
    UB.c-hist-nws-option.subject-group = ~{&table_c-dc-hist~}  ~
AND ub.c-hist-nws-option.charkey_one = ub.c-dis-card-type.type ~
AND ub.c-hist-nws-option.host-code = ub.c-dis-card-type.emitent-host-code ~
AND ub.c-hist-nws-option.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
AND ub.c-hist-nws-option.chip-num = ub.c-table-bind.chip-num-src  ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-fbr-prn':U
hst-bush.table-name = 'c-fbr-prn':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
  ub.c-fbr-prn.subject = 'fbr-prn':U ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-fbr-prn':U
hst-bush.table-name = 'c-fbr-prn-gds':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-fbr-prn no-lock where ub.c-fbr-prn.subject = 'fbr-prn-gds':U ~
and  ub.c-fbr-prn.corr-user-db-num = ub.c-fbr-prn-gds.corr-user-db-num ~
and ub.c-fbr-prn.chip-num = ub.c-fbr-prn-gds.chip-num  ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-fbr-prn':U
hst-bush.table-name = 'c-fbr-prn-grp':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-fbr-prn no-lock where ub.c-fbr-prn.subject = 'fbr-prn-grp':U ~
and  ub.c-fbr-prn.corr-user-db-num = ub.c-fbr-prn-grp.corr-user-db-num ~
and ub.c-fbr-prn.chip-num = ub.c-fbr-prn-grp.chip-num  ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-prop-head':U
hst-bush.table-name = 'c-prop-ref':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-prop-head no-lock where ub.c-prop-head.subject = 'prop-ref':U ~
and  ub.c-prop-head.corr-user-db-num = ub.c-prop-ref.corr-user-db-num ~
and ub.c-prop-head.chip-num = ub.c-prop-ref.chip-num  ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-scales':U
hst-bush.table-name = 'c-scales':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
  ub.c-scales.subject = 'c-scales':U ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-scales':U
hst-bush.table-name = 'c-scales-attr':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-scales no-lock where ub.c-scales.subject = 'scales-attr':U ~
and  ub.c-scales.corr-user-db-num = ub.c-scales-attr.corr-user-db-num ~
and ub.c-scales.chip-num = ub.c-scales-attr.chip-num  ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-scales':U
hst-bush.table-name = 'c-scales-gds':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-scales no-lock where ub.c-scales.subject = 'scales-gds':U ~
and  ub.c-scales.corr-user-db-num = ub.c-scales-gds.corr-user-db-num ~
and ub.c-scales.chip-num = ub.c-scales-gds.chip-num  ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-scales':U
hst-bush.table-name = 'c-scales-grp':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
,first ub.c-scales no-lock where ub.c-scales.subject = 'scales-grp':U ~
and  ub.c-scales.corr-user-db-num = ub.c-scales-grp.corr-user-db-num ~
and ub.c-scales.chip-num = ub.c-scales-grp.chip-num  ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-sert':U
hst-bush.table-name = 'c-sert':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
  ub.c-sert.subject = 'c-sert':U ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-ruledict':U
hst-bush.table-name = 'c-ruledict':U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
 ub.c-ruledict.subject = 'ruledict':U ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-sum-grp':U
hst-bush.table-name = 'c-dis-grp-rule':U + "_1":U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
 c-dis-grp-rule_1.classif-type = 'sum-grp':U, first ub.c-sum-grp no-lock  where ub.c-sum-grp.grp-code = c-dis-grp-rule_1.node-code ~
and ub.c-sum-grp.corr-user-db-num = c-dis-grp-rule_1.corr-user-db-num ~
and ub.c-sum-grp.chip-num = c-dis-grp-rule_1.chip-num ~
".
create hst-bush.
assign
hst-bush.bush-head    = 'c-sum-grp-obj':U
hst-bush.table-name = 'c-dis-grp-rule':U + "_2":U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
 c-dis-grp-rule_2.classif-type = 'sum-grp-obj':U, first ub.c-sum-grp-obj no-lock  where ub.c-sum-grp-obj.grp-code = c-dis-grp-rule_2.node-code ~
and ub.c-sum-grp-obj.obj-type = c-dis-grp-rule_2.obj-type ~
and ub.c-sum-grp-obj.obj-code = c-dis-grp-rule_2.obj-code ~
and ub.c-sum-grp-obj.corr-user-db-num = c-dis-grp-rule_2.corr-user-db-num ~
and ub.c-sum-grp-obj.chip-num = c-dis-grp-rule_2.chip-num ~
".
end.
define variable hst-bush_bind-list as character no-undo init
"~
-~
,-~
,-~
,-~
,-~
,-~
,-~
,-~
,-~
,-~
,-~
"
.
define temp-table rrdb-option no-undo
field first-table-name as character
field second-table-name as character
field third-table-name as character
field fourth-table-name as character
field fifth-table-name as character
field sixth-table-name as character
field first-table-export as logical init yes
field second-table-export as logical init yes
field third-table-export as logical init yes
field fourth-table-export as logical init yes
field fifth-table-export as logical init yes
field sixth-table-export as logical init yes
field if-buffer-num as integer init 1
field where-phrase as character
field if-phrase as character
field dump-point as character
field subject-group as character
field obj-fields as character
field des as character
field id as integer
index pi is unique primary
id
index isubject subject-group
index ipoint dump-point
.
define variable rest-rdb_id                as integer   no-undo .
define variable table-ref as character no-undo .
define variable table-ref-where as character no-undo .
define variable table-ref-if-cond as character no-undo .
define variable table-obj as character no-undo .
define variable table-obj-where as character no-undo .
define variable table-obj-if-cond as character no-undo .
define variable table-host-obj as character no-undo .
define variable table-host-obj-where as character no-undo .
define variable table-host-obj-if-cond as character no-undo .
define variable table-xobj as character no-undo .
define variable table-xobj-where as character no-undo .
define variable table-xobj-if-cond as character no-undo .
define variable table-xobj-fields   as character no-undo .
define variable table-firm-db       as character no-undo .
define variable table-firm-db-no    as character no-undo .
define variable table-firm-db-where as character no-undo .
define variable table-firm-db-if-cond as character no-undo .
define variable table-db       as character no-undo .
define variable table-db-where as character no-undo .
define variable table-db-if-cond as character no-undo .
define variable table-erprn as character no-undo .
assign table-ref = '~
assortment-matrix~
,assortment-matrix-goods~
,alc-type~
,c-alc-type~
,alc-type-attr~
,c-alc-type-attr~
,alc-type-gds~
,c-alc-type-gds~
,alc-type-gds-attr~
,alc-sale-lic~
,c-alc-sale-lic~
,alc-sale-lic-attr~
,c-alc-sale-lic-attr~
,alc-sale-lic-type~
,c-alc-sale-lic-type~
,alc-sale-lic-type-attr~
,alc-supp-lic~
,c-alc-supp-lic~
,alc-supp-lic-attr~
,c-alc-supp-lic-attr~
,alc-supp-lic-type~
,c-alc-supp-lic-type~
,alc-supp-lic-type-attr~
,arh-wth-cli~
,arh-wth-cli-doc~
,arh-wth-cli-tot~
,attr-prop~
,auto-tank~
,auto-section~
,auto-section-table~
,bar-code-attr~
,c-bar-code-attr~
,c-auto-tank~
,c-auto-section~
,c-auto-section-table~
,auto-tank-meas~
,buyer-group~
,c-buyer-group~
,buyer-in-buyer-group~
,c-buyer-in-buyer-group~
,cash-pay~
,c-cash-pay~
,cash-pay-attr~
,c-cash-pay-attr~
,cd-events~
,cd-events-attr~
,cd-video-link~
,cd-video-link-attr~
,cli-grp~
,c-cli-grp~
,clients~
,code-range~
,condition-keeping~
,c-condition-keeping~
,contract~
,contract-line~
,contract-specif~
,contract-specif-attr~
,country~
,c-country~
,criterion-analysis~
,curr-accnt~
,c-curr-accnt~
,curr-bank~
,c-curr-bank~
,currency~
,c-currency~
,custom-labels~
,db~
,db-attr~
,db-grp-obj-price~
,deliv-type-cond-keep~
,c-deliv-type-cond-keep~
,delivery-subject~
,c-delivery-subject~
,delivery-type~
,c-delivery-type~
,delivery-type-subject~
,c-delivery-type-subject~
,dis-card-mask~
,dis-card-mask-attr~
,dis-card-type~
,dis-card-type-attr~
,dis-dct-rule~
,dis-cfg-rule~
,c-dis-cfg-rule~
,dis-time-rule~
,drt-prop~
,c-drt-prop~
,ex-mark~
,c-ex-mark~
,ext-artic~
,c-ext-artic~
,ext-artic-attr~
,c-ext-artic-attr~
,ext-classif~
,c-ext-classif~
,fin-bank~
,fin-schet~
,firm~
,gds-add-charges~
,gds-add-charges-attr~
,gds-grp~
,c-gds-grp~
,gds-grp-attr~
,gds-grp-obj~
,c-gds-grp-obj~
,gds-host-attr~
,gds-prt~
,c-gds-prt~
,gds-obj-prop~
,global-state~
,c-global-state~
,global-state-attr~
,c-global-state-attr~
,goods~
,goods-attr~
,group-period-validity~
,c-group-period-validity~
,grp-obj-price~
,host-grp-obj-price~
,layout~
,layout-elem~
,layout-elem-attr~
,layout-elem-rule~
,lvl-name~
,obj-grp-obj-price~
,pay-type~
,c-pay-type~
,person~
,place-io~
,c-place-io~
,point-io~
,c-point-io~
,point-place-rel~
,c-point-place-rel~
,point-point-rel~
,c-point-point-rel~
,profile-by-profile~
,c-profile-by-profile~
,prop-head~
,prop-map~
,prop-ref~
,prop-ref-call~
,prop-ruleset~
,prop-script~
,pscript-ruleset~
,qnty-group~
,c-qnty-group~
,qnty-in-qnty-group~
,c-qnty-in-qnty-group~
,recipe~
,recipe-gds~
,regions~
,c-regions~
,rp-by-call~
,rp-rule-param~
,c-rp-by-call~
,rule~
,rule-by-call~
,rule-by-profile~
,rule-by-set~
,rule-call-param~
,rule-i-script~
,rule-profile~
,rule-process~
,rule-script~
,rule-trans-memo~
,ruledict~
,ruledict-param~
,ruleset~
,s-coeff~
,schedule~
,schedule-attr~
,sert~
,c-sert~
,sert-join~
,shop~
,stop-list~
,c-stop-list~
,stop-list-line~
,c-stop-list-line~
,store~
,sum-group~
,c-sum-group~
,sum-grp~
,c-sum-grp~
,sum-in-sum-group~
,c-sum-in-sum-group~
,sysconf~
,tare~
,c-tare~
,tax~
,c-tax~
,tax-rate~
,tax-rate-attr~
,c-tax-rate~
,tax-rate-gds~
,tax-rate-gds-grp~
,tax-rate-value~
,tax-units~
,c-tax-units~
,thbj-attr~
,c-thbj-attr~
,tnv-in-turnover-group~
,c-tnv-in-turnover-group~
,trn-reason~
,c-trn-reason~
,trn-reason-host~
,c-trn-reason-host~
,trn-reason-obj~
,c-trn-reason-obj~
,turnover-buyer~
,turnover-buyer-gds~
,turnover-buyer-main~
,turnover-group~
,c-turnover-group~
,units~
,c-units~
,upgrade~
,user-account~
,var-deliv-gr-per-val~
,c-var-deliv-gr-per-val~
,variant-delivery~
,c-variant-delivery~
,wealth~
,c-wealth~
,wi-mode~
,wi-mode-attr~
,wth-gds~
,c-wth-gds~
,wth-par~
,c-wth-par~
,wth-ser~
,c-wth-ser~
,wth-parts~
,code~
':U
table-ref-where = fill(chr(4), num-entries(table-ref) - 1 )
table-ref =  table-ref + '~
,dis-rule~
,dis-gds-rule~
,dis-grp-rule_1~
,c-dis-grp-rule_1~
,dis-grp-rule_2~
,c-dis-grp-rule_2~
,dis-thbj-rule~
,c-dis-thbj-rule~
,dis-cp-rule~
,c-dis-cp-rule
,fbr-gds-grp~
,c-fbr-gds-grp~
,fbr-gds-grp-attr~
,c-fbr-gds-grp-attr~
,c-sert~
,staff~
,clob-bind~
,clob-bind_1~
,c-ruledict~
,c-layout~
,c-layout-elem-rule~
,bar-code-obj-attr~
,c-bar-code-obj-attr~
,c-prop-head~
,c-utd-head~
,c-utd~
,c-utd-attr~
,c-Utd-err~
,c-Utd-lines~
,c-Utd-marking-lines~
,c-Utd-err-attr~
,c-Utd-lines-attr~
,c-Utd-marking-lines-attr~
':U
table-ref-where = table-ref-where + chr(4) + " ub.dis-rule.host-code = 0 and ub.dis-rule.obj-type = '' and ub.dis-rule.obj-code = 0 "
table-ref-where = table-ref-where + chr(4) + " ub.dis-gds-rule.obj-type = '' and ub.dis-gds-rule.obj-code = 0 "
table-ref-where = table-ref-where + chr(4) + " dis-grp-rule_1.classif-type = 'gds-grp':U and dis-grp-rule_1.obj-type = '' and dis-grp-rule_1.obj-code = 0 "
table-ref-where = table-ref-where + chr(4) + " c-dis-grp-rule_1.classif-type = 'gds-grp':U and c-dis-grp-rule_1.obj-type = '' and c-dis-grp-rule_1.obj-code = 0 "
table-ref-where = table-ref-where + chr(4) + " dis-grp-rule_2.classif-type = 'sum-grp':U and dis-grp-rule_2.obj-type = '' and dis-grp-rule_2.obj-code = 0 "
table-ref-where = table-ref-where + chr(4) + " c-dis-grp-rule_2.classif-type = 'sum-grp':U and c-dis-grp-rule_2.obj-type = '' and c-dis-grp-rule_2.obj-code = 0 "
table-ref-where = table-ref-where + chr(4) + " (ub.dis-thbj-rule.obj-type = '' and ub.dis-thbj-rule.obj-code = 0) or ub.dis-thbj-rule.host-code = 0 "
table-ref-where = table-ref-where + chr(4) + " (ub.c-dis-thbj-rule.obj-type = '' and ub.c-dis-thbj-rule.obj-code = 0) or ub.c-dis-thbj-rule.host-code = 0 "
table-ref-where = table-ref-where + chr(4) + " (ub.dis-cp-rule.obj-type = '' and ub.dis-cp-rule.obj-code = 0) or ub.dis-cp-rule.host-code = 0 "
table-ref-where = table-ref-where + chr(4) + " (ub.c-dis-cp-rule.obj-type = '' and ub.c-dis-cp-rule.obj-code = 0) or ub.c-dis-cp-rule.host-code = 0 "
table-ref-where = table-ref-where + chr(4) + " ub.fbr-gds-grp.obj-type = '' and ub.fbr-gds-grp.obj-code = 0 and ub.fbr-gds-grp.upper-code > 0"
table-ref-where = table-ref-where + chr(4) + " ub.c-fbr-gds-grp.obj-type = '' and ub.c-fbr-gds-grp.obj-code = 0 "
table-ref-where = table-ref-where + chr(4) + " ub.fbr-gds-grp-attr.obj-type = '' and ub.fbr-gds-grp-attr.obj-code = 0 "
table-ref-where = table-ref-where + chr(4) + " ub.c-fbr-gds-grp-attr.obj-type = '' and ub.c-fbr-gds-grp-attr.obj-code = 0 "
table-ref-where = table-ref-where + chr(4) + "ub.c-sert.b-code = 0"
table-ref-where = table-ref-where + chr(4) + "ub.staff.db-num = - 1"
table-ref-where = table-ref-where + chr(4) + "ub.clob-bind.resource-type = 'gate':U"
table-ref-where = table-ref-where + chr(4) + "clob-bind_1.resource-type = 'ref':U"
table-ref-where = table-ref-where + chr(4) + substitute("ub.c-ruledict.entry-id = 0 and (ub.c-ruledict.corr-user-db-num = &1 or ub.c-ruledict.corr-user-db-num = 0)", p-db-num)
table-ref-where = table-ref-where + chr(4) + substitute("ub.c-layout.corr-user-db-num = &1", p-db-num)
table-ref-where = table-ref-where + chr(4) + substitute("ub.c-layout-elem-rule.corr-user-db-num = &1", p-db-num)
table-ref-where = table-ref-where + chr(4) + substitute("ub.bar-code-obj-attr.obj-type = '' and ub.bar-code-obj-attr.obj-code = 0")
table-ref-where = table-ref-where + chr(4) + substitute("ub.c-bar-code-obj-attr.obj-type = '' and ub.c-bar-code-obj-attr.obj-code = 0")
table-ref-where = table-ref-where + chr(4) + substitute("ub.c-prop-head.subject > 'prop-ref':U or ub.c-prop-head.subject < 'prop-ref':U")
table-ref-where = table-ref-where + chr(4) + substitute("ub.c-utd-head.corr-user-db-num = &1 ", p-db-num)
table-ref-where = table-ref-where + chr(4) + substitute("ub.c-utd.corr-user-db-num = &1 ", p-db-num)
table-ref-where = table-ref-where + chr(4) + substitute("ub.c-utd-attr.corr-user-db-num = &1 ", p-db-num)
table-ref-where = table-ref-where + chr(4) + substitute("ub.c-utd-err.corr-user-db-num = &1 ", p-db-num)
table-ref-where = table-ref-where + chr(4) + substitute("ub.c-utd-lines.corr-user-db-num = &1 ", p-db-num)
table-ref-where = table-ref-where + chr(4) + substitute("ub.c-utd-marking-lines.corr-user-db-num = &1 ", p-db-num)
table-ref-where = table-ref-where + chr(4) + substitute("ub.c-utd-err-attr.corr-user-db-num = &1 ", p-db-num)
table-ref-where = table-ref-where + chr(4) + substitute("ub.c-utd-lines-attr.corr-user-db-num = &1 ", p-db-num)
table-ref-where = table-ref-where + chr(4) + substitute("ub.c-utd-marking-lines-attr.corr-user-db-num = &1 ", p-db-num)
table-ref-if-cond = fill(chr(4), num-entries(table-ref) - 1)
.
assign
table-ref = table-ref + "~
,c-bar-code~
,c-bar-code-attr~
,c-clients~
,c-clients-attr~
,c-dis-card-mask~
,c-dis-card-type~
,c-dis-card-type-attr~
,c-dis-time-rule~
,c-dis-dct-rule~
,c-dis-rule~
,c-firm~
,c-gds-host-attr~
,c-goods~
,c-goods-attr~
,c-person~
,c-prod-bc~
,c-prop-ref~
,c-recipe~
,c-recipe-gds~
,c-rule-by-call~
,c-shop~
,c-store~
,c-staff~
,c-sysconf~
":U
table-ref-where   = table-ref-where +
                    fill(chr(4), num-entries(table-ref)  - num-entries(table-ref-where, chr(4)))
table-ref-if-cond = table-ref-if-cond
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple-and-global"
                  + chr(4) + "if-simple-and-global"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-simple"
                  + chr(4) + "if-db-num-1"
                  + chr(4) + "if-simple"
.
assign
table-obj = '~
bar-code-obj-attr~
,c-bar-code-obj-attr~
,cd-clu~
,c-cd-clu~
,cd-dlu~
,c-cd-dlu~
,cd-doc~
,c-cd-doc~
,cd-doc-line~
,c-cd-doc-line~
,cd-grp~
,c-cd-grp~
,cd-plu~
,c-cd-plu~
,cd-trans~
,curr-shop~
,dis-cp-rule~
,c-dis-cp-rule~
,dis-gds-rule~
,c-dis-gds-rule~
,dis-rule~
,c-dis-rule~
,dis-thbj-rule~
,c-dis-thbj-rule~
,fbr-gds-grp~
,c-fbr-gds-grp~
,fbr-gds-grp-attr~
,c-fbr-gds-grp-attr~
,fbr-gds-obj~
,c-fbr-gds-obj~
,gds-obj~
,gds-obj-attr~
,c-gds-obj-attr~
,c-gds-obj-ref~
,nozzle~
,c-nozzle~
,nozzle-attr~
,c-nozzle-attr~
,obj-date~
,pl-gds~
,c-pl-gds~
,pl-gds-pump~
,c-pl-gds-pump~
,pl-pump~
,c-pl-pump~
,pl-pump-nozzle~
,c-pl-pump-nozzle~
,place~
,c-place~
,pump~
,c-pump~
,pump-nozzle~
,c-pump-nozzle~
,scales-gds~
,c-scales-gds~
,shift-cash~
,shift-obj~
,c-shift-obj~
,shift-staff~
,c-shift-staff~
,sum-grp-obj~
,c-sum-grp-obj~
,dis-grp-rule_3~
,c-dis-grp-rule_3~
,varianty-delivery-gds-obj~
,c-varianty-delivery-gds-obj~
,wth-obj~
,wth-place~
,wth-pobj~
':U
table-obj-where = fill(chr(4), num-entries(table-obj) - 1 )
table-obj-if-cond = fill(chr(4), num-entries(table-obj) - 1)
.
assign
table-host-obj = '~
arh-fin-doc-contr-schet-obj~
,arh-fin-doc-contr-s-nal-obj~
,arh-fin-doc-contr-s-tax-obj~
,arh-fin-doc-c-s-tax-nal-obj~
,arh-fin-doc-schet-obj~
,arh-fin-doc-schet-nal-obj~
':U
table-host-obj-where = fill(chr(4), num-entries(table-host-obj) - 1 )
table-host-obj-if-cond = fill(chr(4), num-entries(table-host-obj) - 1)
.
assign
table-Xobj        = '':U
table-Xobj-fields = '':U
table-Xobj-where  = fill( chr(4), num-entries( table-Xobj ) - 1 )
table-Xobj-if-cond  = fill( chr(4), num-entries( table-Xobj ) - 1 )
.
assign
table-firm-db = '~
arh-fin-doc-an~
,arh-fin-doc-an-nal~
,arh-fin-doc-c-schet-tax-nal~
,arh-fin-doc-contr-schet~
,arh-fin-doc-contr-schet-nal~
,arh-fin-doc-contr-schet-tax~
,arh-fin-doc-schet~
,arh-fin-doc-schet-nal~
,arh-fin-doc-schet-tax~
,arh-fin-doc-schet-tax-nal~
,arh-fin-ob-contr~
,c-contract~
,c-contract-specif~
,factur-connect~
,factur-connect-line~
,c-fin-bank~
,fin-code-an-uchet~
,fin-code-cel-nazn~
,fin-code-cor-acc~
,fin-connect~
,fin-doc~
,c-fin-doc~
,fin-doc-attr~
,c-fin-doc-attr~
,fin-doc-tax~
,c-fin-doc-tax~
,c-fin-schet~
,fin-statement~
,c-fin-statement~
,fin-statement-attr~
,c-fin-statement-attr~
,fin-statement-line~
,c-fin-statement-line~
,schet-fact-doc~
,c-schet-fact-doc~
,schet-fact-line~
,c-schet-fact-line~
':U
table-firm-db-where = fill(chr(4), num-entries(table-firm-db) - 1)
table-firm-db-if-cond = fill(chr(4), num-entries(table-firm-db) - 1)
table-firm-db-no = "~
fin-doc~
,c-fin-doc~
,fin-doc-attr~
,c-fin-doc-attr~
,fin-doc-tax~
,c-fin-doc-tax~
,fin-statement~
,c-fin-statement~
,fin-statement-attr~
,c-fin-statement-attr~
,fin-statement-line~
,c-fin-statement-line~
":U
.
assign
table-db       = '
action-post~
,action-post-host~
,action-post-menu-group~
,action-post-obj~
,action-post-role~
,action-post-user-login~
,action-role~
,action-role-item~
,action-role-item-gds~
,action-role-item-gds-grp~
,cash-desk~
,c-cash-desk~
,cash-desk-attr~
,c-cash-desk-attr~
,cd-event-log~
,cd-event-log-attr~
,config~
,fbr-prn~
,c-fbr-prn~
,fbr-prn-gds~
,c-fbr-prn-gds~
,fbr-prn-grp~
,c-fbr-prn-grp~
,menu-user~
,scales~
,c-scales~
,scales-attr~
,c-scales-attr~
,scales-grp~
,c-scales-grp~
,staff~
,c-staff~
,user-context-history~
,user-host~
,user-login~
,user-login-action-item~
,user-login-action-role~
,user-login-attr~
,user-menu-group~
,user-obj~
':U
table-db-where = fill(chr(4), num-entries(table-db) - 1)
table-db-if-cond = fill(chr(4), num-entries(table-db) - 1)
.
assign table-erprn    = '
goods~
,goods-attr~
,gds-host-attr~
,gds-obj-prop~
,recipe~
,recipe-gds~
,dis-gds-rule~
,c-dis-gds-rule~
,gds-obj~
,gds-obj-attr~
,c-gds-obj-attr~
,c-gds-obj-ref~
,code-range~
,contract~
,contract-line~
,contract-specif~
':U.
procedure prepare-tables :
define input parameter p-table-list as character no-undo .
define input parameter p-where-list as character no-undo .
define input parameter p-if-cond as character no-undo .
define input parameter p-obj-fields as character no-undo .
define input parameter p-dump-point as character no-undo .
define input parameter p-unload-history as logical no-undo .
define variable v-ii    as integer no-undo .
define variable v-count as integer   no-undo .
define buffer buf_rrdb-option for rrdb-option.
define buffer buf_hst-bush for hst-bush.
do
on error undo, return error
:
  assign
    v-count = num-entries(p-table-list)
  .
  if v-count <> num-entries(p-where-list, chr(4)) then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Список таблиц (первая таблица списка &1) не соответствует списку условий (where-list)", entry(1, p-table-list) ) skip
      view-as alert-box error .
    return error.
  end.
  if v-count <> num-entries(p-if-cond, chr(4)) then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Список таблиц (первая таблица списка &1) не соответствует списку условий (if-cond)", entry(1, p-table-list) ) skip
      view-as alert-box error .
    return error.
  end.
  if v-count <> num-entries(p-obj-fields, chr(4))
    and trim(p-obj-fields) <> '':U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Список таблиц (первая таблица списка &1) не соответствует списку условий (obj-fields)", entry(1, p-table-list) ) skip
      view-as alert-box error .
    return error.
  end.
  _v-ii:
  do v-ii = 1 to v-count
  :
    if p-unload-history = no
    and entry(v-ii, p-table-list) begins "c-" then next _v-ii.
    if mode-erprn and  lookup(entry(v-ii, p-table-list),table-erprn) > 0 then next _v-ii.
    create buf_rrdb-option.
    assign
    buf_rrdb-option.first-table-name = entry(v-ii, p-table-list)
    buf_rrdb-option.where-phrase     = entry(v-ii, p-where-list, chr(4))
    buf_rrdb-option.if-phrase        = entry(v-ii, p-if-cond,  chr(4))
    buf_rrdb-option.obj-fields       = (if trim(p-obj-fields) = '':U
                                        then '':U
                                        else entry(v-ii, p-obj-fields, chr(4))
                                        )
    buf_rrdb-option.dump-point       = p-dump-point
    buf_rrdb-option.subject-group    = '':U
    buf_rrdb-option.id = rest-rdb_id + 1
    rest-rdb_id = rest-rdb_id + 1
    .
    CASE p-dump-point:
      when "obj" then do:
        if buf_rrdb-option.where-phrase = '':U
        then do:
          buf_rrdb-option.where-phrase =  substitute(' (&1.obj-type = "&&1" and &1.obj-code = &&2) '
                                                      ,buf_rrdb-option.first-table-name
                                                     )
          .
        end.
        else do:
          buf_rrdb-option.where-phrase =  substitute('(&1) and (&2.obj-type = "&&1" and &2.obj-code = &&2 ) '
                                                    ,buf_rrdb-option.where-phrase
                                                    ,buf_rrdb-option.first-table-name
                                                     )
          .
        end.
      end.
      when "host-obj" then do:
        if buf_rrdb-option.where-phrase = '':U
        then do:
          buf_rrdb-option.where-phrase =  substitute(' (&1.host-code = &&3 and &1.obj-type = "&&1" and &1.obj-code = &&2) '
                                                      ,buf_rrdb-option.first-table-name
                                                     )
          .
        end.
        else do:
          buf_rrdb-option.where-phrase =  substitute('(&1) and (&2.host-code = &&3 and &2.obj-type = "&&1" and &2.obj-code = &&2 ) '
                                                    ,buf_rrdb-option.where-phrase
                                                    ,buf_rrdb-option.first-table-name
                                                     )
          .
        end.
      end.
      when "db" then do:
        if buf_rrdb-option.where-phrase = '':U
        then do:
          buf_rrdb-option.where-phrase =  substitute(" (&1.db-num = &2) "
                                                      ,buf_rrdb-option.first-table-name
                                                      ,p-db-num
                                                     )
          .
        end.
        else do:
          buf_rrdb-option.where-phrase =  substitute("(&1) and (&2.db-num = &3) "
                                                    ,buf_rrdb-option.where-phrase
                                                    ,buf_rrdb-option.first-table-name
                                                    ,p-db-num
                                                     )
          .
        end.
      end.
      when "firm-db" then do:
        if buf_rrdb-option.where-phrase = '':U
        then do:
          buf_rrdb-option.where-phrase =  substitute(" (&1.host-code = &&1) "
                                                      ,buf_rrdb-option.first-table-name
                                                     )
          .
        end.
        else do:
          buf_rrdb-option.where-phrase =  substitute("(&1) and (&2.host-code = &&1) "
                                                    ,buf_rrdb-option.where-phrase
                                                    ,buf_rrdb-option.first-table-name
                                                     )
          .
        end.
      end.
      when "Xobj" then do:
        if buf_rrdb-option.where-phrase = '':U
        then do:
          buf_rrdb-option.where-phrase =  substitute(' (&1.&2 = "&&1" and &1.&3 = &&2) '
                                                      ,buf_rrdb-option.first-table-name
                                                      , entry(1, buf_rrdb-option.obj-fields, chr(32))
                                                      , entry(2, buf_rrdb-option.obj-fields, chr(32))
                                                     )
          .
        end.
        else do:
          buf_rrdb-option.where-phrase =  substitute(' (&1) and (&2.&3 = "&&1" and &2.&4 = &&2) '
                                                      ,buf_rrdb-option.where-phrase
                                                      ,buf_rrdb-option.first-table-name
                                                      ,entry(1, buf_rrdb-option.obj-fields, chr(32))
                                                      ,entry(2, buf_rrdb-option.obj-fields, chr(32))
                                                     )
          .
        end.
      end.
    END CASE.
    if buf_rrdb-option.first-table-name begins "c-":U
    or lookup(buf_rrdb-option.first-table-name, 'tax-rate-gds':U + chr(44) +
                                                'tax-rate-value':U + chr(44) +
                                                'auto-tank-meas':U) > 0
    then do:
      find first buf_hst-bush where
                buf_hst-bush.table-name = buf_rrdb-option.first-table-name
            and buf_hst-bush.is-main = yes            no-error .
      if available buf_hst-bush then do:
        if buf_rrdb-option.first-table-name <> buf_hst-bush.bush-head then do:
          assign
          buf_rrdb-option.second-table-name = buf_hst-bush.bush-head
          .
          if buf_hst-bush.joined-buffers <> '':U then do:
            if num-entries(buf_hst-bush.joined-buffers) >= 1 then do:
                assign
                buf_rrdb-option.third-table-name = entry(1, buf_hst-bush.joined-buffers)
                .
            end.
            if num-entries(buf_hst-bush.joined-buffers) >= 2 then do:
                assign
                buf_rrdb-option.fourth-table-name = entry(2, buf_hst-bush.joined-buffers)
                .
            end.
            if num-entries(buf_hst-bush.joined-buffers) >= 3 then do:
                assign
                buf_rrdb-option.fifth-table-name = entry(3, buf_hst-bush.joined-buffers)
                .
            end.
            if num-entries(buf_hst-bush.joined-buffers) >= 4 then do:
                assign
                buf_rrdb-option.sixth-table-name = entry(4, buf_hst-bush.joined-buffers)
                .
            end.
          end.
        end.
        assign
        buf_rrdb-option.where-phrase = substitute("&1 &2"
                                                  ,(if buf_rrdb-option.where-phrase <> '':U
                                                   then substitute("(&1) and "
                                                                   ,buf_rrdb-option.where-phrase )
                                                   else '':U)
                                                  ,buf_hst-bush.where-phrase)
        .
      end.
    end.
  end.
end.
end procedure.
procedure prepare-dc :
define input parameter p-db-num as integer no-undo .
define input parameter p-unload-history as logical no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf0_hist-nws-option for ub.hist-nws-option.
define buffer buf_rrdb-option for rrdb-option.
define buffer buf_dis-obj for ub.dis-obj.
define buffer buf_dis-host for ub.dis-host.
define buffer buf_clients for ub.clients.
do
on error undo, return error
:
  for each buf_Dis-card-type no-lock:
    if buf_dis-card-type.host-code > 0
    or buf_dis-card-type.obj-code > 0 then next.
    create buf_rrdb-option.
    assign
    buf_rrdb-option.first-table-name = 'dis-card':U
    buf_rrdb-option.second-table-name = ''
    buf_rrdb-option.where-phrase = substitute(' ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2" '
                                          , buf_dis-card-type.emitent-host-code
                                          , buf_dis-card-type.type)
    buf_rrdb-option.if-phrase = ''
    buf_rrdb-option.dump-point = "ref"
    buf_rrdb-option.subject-group = "dc"
    buf_rrdb-option.id = rest-rdb_id + 1
    buf_rrdb-option.des = substitute("dis-card: type = &1", buf_dis-card-type.type)
    rest-rdb_id = rest-rdb_id + 1
    .
    create buf_rrdb-option.
    assign
    buf_rrdb-option.first-table-name = 'dis-card':U
    buf_rrdb-option.first-table-export = no
    buf_rrdb-option.second-table-name = 'dis-card-long':U
    buf_rrdb-option.where-phrase = substitute(' ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", ' +
                                          'each ub.dis-card-long no-lock where ub.dis-card-long.d-card = ub.dis-card.d-card '
                                          , buf_dis-card-type.emitent-host-code
                                          , buf_dis-card-type.type)
    buf_rrdb-option.if-phrase = ''
    buf_rrdb-option.dump-point = "ref"
    buf_rrdb-option.subject-group = "dc"
    buf_rrdb-option.id = rest-rdb_id + 1
    buf_rrdb-option.des = substitute("dis-card-long: type = &1", buf_dis-card-type.type)
    rest-rdb_id = rest-rdb_id + 1
    .
    create buf_rrdb-option.
    assign
    buf_rrdb-option.first-table-name = 'dis-card':U
    buf_rrdb-option.first-table-export = no
    buf_rrdb-option.second-table-name = 'dis-card-property':U
    buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", ' +
                                          'each ub.dis-card-property no-lock where ub.dis-card-property.d-card = ub.dis-card.d-card and ' +
                                          'ub.dis-card-property.obj-type = "&3"'
                                          , buf_dis-card-type.emitent-host-code
                                          , buf_dis-card-type.type
                                          , '':U
                                          )
    buf_rrdb-option.if-phrase = ''
    buf_rrdb-option.dump-point = "ref"
    buf_rrdb-option.subject-group = "dc"
    buf_rrdb-option.id = rest-rdb_id + 1
    buf_rrdb-option.des = substitute("dis-card-property: type = &1", buf_dis-card-type.type)
    rest-rdb_id = rest-rdb_id + 1
    .
    create buf_rrdb-option.
    assign
    buf_rrdb-option.first-table-name = 'dis-card':U
    buf_rrdb-option.first-table-export = no
    buf_rrdb-option.second-table-name = 'dis-dc-rule':U
    buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                          'each ub.dis-dc-rule no-lock where ub.dis-dc-rule.d-card = ub.dis-card.d-card and ' +
                                          'ub.dis-dc-rule.obj-type = "&3"'
                                          , buf_dis-card-type.emitent-host-code
                                          , buf_dis-card-type.type
                                          , '':U)
    buf_rrdb-option.if-phrase = ''
    buf_rrdb-option.dump-point = "ref"
    buf_rrdb-option.subject-group = "dc"
    buf_rrdb-option.id = rest-rdb_id + 1
    buf_rrdb-option.des = substitute("dis-dc-rule: type = &1", buf_dis-card-type.type)
    rest-rdb_id = rest-rdb_id + 1
    .
    for each buf_prop-head where
            buf_prop-head.general contains 'dis-card-type':U:
      if buf_prop-head.storage-place-host = 'dis-host':U
      then do:
        find first buf0_hist-nws-option where
                  buf0_hist-nws-option.table-name = 'dis-host':U
              and buf0_hist-nws-option.db-num = 0
              and buf0_hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
              and buf0_hist-nws-option.charkey_one = buf_Dis-card-type.type
              and buf0_hist-nws-option.charkey_two = '':U
              and buf0_hist-nws-option.charkey_three = '':U
              and buf0_hist-nws-option.key#_one = buf_prop-head.dtm-code
              and buf0_hist-nws-option.key#_two = 0
              and buf0_hist-nws-option.key#_three = 0
              and buf0_hist-nws-option.obj-type = ''
              and buf0_hist-nws-option.obj-code = 0
              no-error .
      if NOT available buf0_hist-nws-option
      or (available buf0_hist-nws-option
          and
               (buf0_hist-nws-option.smart-nws = integer('-1':U)
                or buf0_hist-nws-option.smart-nws = integer('-10':U))
          )
      then do:
        for each buf_prop-ref no-lock where
                buf_prop-ref.dtm-code = buf_prop-head.dtm-code:
          create buf_rrdb-option.
          assign
          buf_rrdb-option.first-table-name = 'dis-card':U
          buf_rrdb-option.first-table-export = no
          buf_rrdb-option.second-table-name = 'dis-host':U
          buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                              'each ub.dis-host no-lock where ub.dis-host.d-card = ub.dis-card.d-card and ' +
                                              'ub.dis-host.dt-code = &3'
                                                , buf_dis-card-type.emitent-host-code
                                                , buf_dis-card-type.type
                                                , buf_prop-ref.dt-code
                                                )
          buf_rrdb-option.if-phrase = ''
          buf_rrdb-option.dump-point = "ref"
          buf_rrdb-option.subject-group = "dc"
          buf_rrdb-option.id = rest-rdb_id + 1
          buf_rrdb-option.des = substitute("dis-host: type = &1 dtm-code = &2 dt-code = &3"
                                          , buf_dis-card-type.type
                                          ,buf_prop-head.dtm-code
                                          ,buf_prop-ref.dt-code
                                          )
          rest-rdb_id = rest-rdb_id + 1
          .
          if p-unload-history then do:
            if not available buf0_hist-nws-option
            or buf0_hist-nws-option.get-hist-from-nws  >= 0
            or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
            create buf_rrdb-option.
            assign
            buf_rrdb-option.first-table-name = 'dis-card':U
            buf_rrdb-option.first-table-export = no
            buf_rrdb-option.second-table-name = 'c-dis-host':U
            buf_rrdb-option.third-table-name = 'c-dc-hist':U
            buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                'each ub.c-dis-host no-lock where ub.c-dis-host.d-card = ub.dis-card.d-card and ' +
                                                'ub.c-dis-host.dt-code = &3, ' +
                                                'first ub.c-dc-hist no-lock where ' +
                                                'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                'ub.c-dc-hist.corr-user-db-num = ub.c-dis-host.corr-user-db-num and ' +
                                                'ub.c-dc-hist.chip-num = ub.c-dis-host.chip-num '
                                                  , buf_dis-card-type.emitent-host-code
                                                  , buf_dis-card-type.type
                                                    , buf_prop-ref.dt-code
                                                  )
            buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                      or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                    then '':U
                                    else "if-self")
            buf_rrdb-option.if-buffer-num = 2
            buf_rrdb-option.dump-point = "ref"
            buf_rrdb-option.subject-group = "dc"
            buf_rrdb-option.id = rest-rdb_id + 1
            buf_rrdb-option.des = substitute("c-dis-host: type = &1 dtm-code = &2 dt-code = &3"
                                            , buf_dis-card-type.type
                                            ,buf_prop-head.dtm-code
                                            ,buf_prop-ref.dt-code
                                            )
            rest-rdb_id = rest-rdb_id + 1
            .
          end.
          end.
        end.
      end.
      if available buf0_hist-nws-option
      and (buf0_hist-nws-option.smart-nws = integer('0':U)
      or buf0_hist-nws-option.smart-nws = integer('10':U)) then do:
        for each buf_prop-ref no-lock where
                buf_prop-ref.dtm-code = buf_prop-head.dtm-code:
          find first buf_dis-host no-lock where
                      buf_Dis-host.dt-code = buf_prop-ref.dt-code no-error .
          if available buf_dis-host
          then do:
            if buf_prop-ref.dt-code > 0 then do:
            create buf_rrdb-option.
            assign
            buf_rrdb-option.first-table-name = 'dis-card':U
            buf_rrdb-option.first-table-export = no
            buf_rrdb-option.second-table-name = 'dis-host':U
            buf_rrdb-option.third-table-name = 'clients':U
            buf_rrdb-option.third-table-export = no
            buf_rrdb-option.fourth-table-name = 'dis-obj':U
            buf_rrdb-option.fourth-table-export = no
            buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                'each ub.dis-host no-lock where ub.dis-host.d-card = ub.dis-card.d-card and ' +
                                                'ub.dis-host.dt-code = &3, '  +
                                                'first ub.clients no-lock where ub.clients.db-num = &4 and ' +
                                                '(ub.dis-host.host-code = 0 or ub.clients.host-code = ub.dis-host.host-code), ' +
                                                'first ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                                'ub.dis-obj.obj-type = ub.clients.obj-type and ub.dis-obj.obj-code = ub.clients.obj-code '
                                                , buf_dis-card-type.emitent-host-code
                                                , buf_dis-card-type.type
                                                , buf_prop-ref.dt-code
                                                , p-db-num
                                                )
            buf_rrdb-option.if-phrase = ''
            buf_rrdb-option.dump-point = "ref"
            buf_rrdb-option.subject-group = "dc"
            buf_rrdb-option.id = rest-rdb_id + 1
            buf_rrdb-option.des = substitute("dis-host: type = &1 dtm-code = &2 dt-code = &3"
                                            , buf_dis-card-type.type
                                            ,buf_prop-head.dtm-code
                                            ,buf_prop-ref.dt-code
                                            )
            rest-rdb_id = rest-rdb_id + 1
            .
            if p-unload-history then do:
              if not available buf0_hist-nws-option
              or buf0_hist-nws-option.get-hist-from-nws  >= 0
              or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
                create buf_rrdb-option.
                assign
                buf_rrdb-option.first-table-name = 'dis-card':U
                buf_rrdb-option.first-table-export = no
                buf_rrdb-option.second-table-name = 'c-dis-host':U
                buf_rrdb-option.third-table-name = 'c-dc-hist':U
                buf_rrdb-option.fourth-table-name = 'clients':U
                buf_rrdb-option.fourth-table-export = no
                buf_rrdb-option.fifth-table-name = 'dis-obj':U
                buf_rrdb-option.fifth-table-export = no
                buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                    'each ub.c-dis-host no-lock where ub.c-dis-host.d-card = ub.dis-card.d-card and ' +
                                                    'ub.c-dis-host.dt-code = &3, ' +
                                                    'first ub.c-dc-hist no-lock where ' +
                                                    'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                    'ub.c-dc-hist.corr-user-db-num = ub.c-dis-host.corr-user-db-num and ' +
                                                    'ub.c-dc-hist.chip-num = ub.c-dis-host.chip-num, ' +
                                                    'first ub.clients no-lock where ub.clients.db-num = &4 and ' +
                                                    '(ub.c-dis-host.host-code = 0 or ub.clients.host-code = ub.c-dis-host.host-code), ' +
                                                    'first ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                                    'ub.dis-obj.obj-type = ub.clients.obj-type and ub.dis-obj.obj-code = ub.clients.obj-code '
                                                    , buf_dis-card-type.emitent-host-code
                                                    , buf_dis-card-type.type
                                                    , buf_prop-ref.dt-code
                                                    , p-db-num
                                                    )
                buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                            or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                        then '':U
                                        else "if-self")
                buf_rrdb-option.if-buffer-num = 2
                buf_rrdb-option.dump-point = "ref"
                buf_rrdb-option.subject-group = "dc"
                buf_rrdb-option.id = rest-rdb_id + 1
                buf_rrdb-option.des = substitute("c-dis-host: type = &1 dtm-code = &2 dt-code = &3"
                                                , buf_dis-card-type.type
                                                ,buf_prop-head.dtm-code
                                                ,buf_prop-ref.dt-code
                                                )
                rest-rdb_id = rest-rdb_id + 1
                .
                end.
              end.
            end.
            else do:
              create buf_rrdb-option.
              assign
              buf_rrdb-option.first-table-name = 'dis-card':U
              buf_rrdb-option.first-table-export = no
              buf_rrdb-option.second-table-name = 'dis-host':U
              buf_rrdb-option.third-table-name = 'clients':U
              buf_rrdb-option.third-table-export = no
              buf_rrdb-option.fourth-table-name = 'dis-obj':U
              buf_rrdb-option.fourth-table-export = no
              buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                  'each ub.dis-host no-lock where ub.dis-host.d-card = ub.dis-card.d-card and ' +
                                                  'ub.dis-host.dt-code = &3 and ub.dis-host.host-code > 0, '  +
                                                  'first ub.clients no-lock where ub.clients.db-num = &4 and ' +
                                                  '(ub.dis-host.host-code = 0 or ub.clients.host-code = ub.dis-host.host-code), ' +
                                                  'first ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                                  'ub.dis-obj.obj-type = ub.clients.obj-type and ub.dis-obj.obj-code = ub.clients.obj-code '
                                                  , buf_dis-card-type.emitent-host-code
                                                  , buf_dis-card-type.type
                                                  , buf_prop-ref.dt-code
                                                  , p-db-num
                                                  )
              buf_rrdb-option.if-phrase = ''
              buf_rrdb-option.dump-point = "ref"
              buf_rrdb-option.subject-group = "dc"
              buf_rrdb-option.id = rest-rdb_id + 1
              buf_rrdb-option.des = substitute("dis-host: type = &1 dtm-code = &2 dt-code = &3"
                                              , buf_dis-card-type.type
                                              ,buf_prop-head.dtm-code
                                              ,buf_prop-ref.dt-code
                                              )
              rest-rdb_id = rest-rdb_id + 1
              .
              if p-unload-history then do:
                if not available buf0_hist-nws-option
                or buf0_hist-nws-option.get-hist-from-nws  >= 0
                or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
                  create buf_rrdb-option.
                  assign
                  buf_rrdb-option.first-table-name = 'dis-card':U
                  buf_rrdb-option.first-table-export = no
                  buf_rrdb-option.second-table-name = 'c-dis-host':U
                  buf_rrdb-option.third-table-name = 'c-dc-hist':U
                  buf_rrdb-option.fourth-table-name = 'clients':U
                  buf_rrdb-option.fourth-table-export = no
                  buf_rrdb-option.fifth-table-name = 'dis-obj':U
                  buf_rrdb-option.fifth-table-export = no
                  buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                      'each ub.c-dis-host no-lock where ub.c-dis-host.d-card = ub.dis-card.d-card and ' +
                                                      'ub.c-dis-host.dt-code = &3, ' +
                                                      'first ub.c-dc-hist no-lock where ' +
                                                      'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                      'ub.c-dc-hist.corr-user-db-num = ub.c-dis-host.corr-user-db-num and ' +
                                                      'ub.c-dc-hist.chip-num = ub.c-dis-host.chip-num, ' +
                                                      'first ub.clients no-lock where ub.clients.db-num = &4 and ' +
                                                      '(ub.c-dis-host.host-code = 0 or ub.clients.host-code = ub.c-dis-host.host-code), ' +
                                                      'first ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                                      'ub.dis-obj.obj-type = ub.clients.obj-type and ub.dis-obj.obj-code = ub.clients.obj-code '
                                                      , buf_dis-card-type.emitent-host-code
                                                      , buf_dis-card-type.type
                                                      , buf_prop-ref.dt-code
                                                      , p-db-num
                                                      )
                  buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                            or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                          then '':U
                                          else "if-self")
                  buf_rrdb-option.if-buffer-num = 2
                  buf_rrdb-option.dump-point = "ref"
                  buf_rrdb-option.subject-group = "dc"
                  buf_rrdb-option.id = rest-rdb_id + 1
                  buf_rrdb-option.des = substitute("c-dis-host: type = &1 dtm-code = &2 dt-code = &3"
                                                  , buf_dis-card-type.type
                                                  ,buf_prop-head.dtm-code
                                                  ,buf_prop-ref.dt-code
                                                  )
                  rest-rdb_id = rest-rdb_id + 1
                  .
                end.
              end.
            end.
          end.
        end.
      end.
      if available buf0_hist-nws-option
      and buf0_hist-nws-option.smart-nws >= 0 then do:
        for each buf_prop-ref no-lock where
                buf_prop-ref.dtm-code = buf_prop-head.dtm-code
            and buf_prop-ref.dt-code = 0
                :
          create buf_rrdb-option.
          assign
          buf_rrdb-option.first-table-name = 'dis-card':U
          buf_rrdb-option.first-table-export = no
          buf_rrdb-option.second-table-name = 'dis-host':U
          buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                              'each ub.dis-host no-lock where ub.dis-host.d-card = ub.dis-card.d-card and ' +
                                              'ub.dis-host.dt-code = &3 and ' +
                                              'ub.dis-host.host-code = 0 '
                                                , buf_dis-card-type.emitent-host-code
                                                , buf_dis-card-type.type
                                                , buf_prop-ref.dt-code
                                                )
          buf_rrdb-option.if-phrase = ''
          buf_rrdb-option.dump-point = "ref"
          buf_rrdb-option.subject-group = "dc"
          buf_rrdb-option.id = rest-rdb_id + 1
          buf_rrdb-option.des = substitute("dis-host: type = &1 dtm-code = &2 dt-code = &3"
                                          , buf_dis-card-type.type
                                          ,buf_prop-head.dtm-code
                                          ,buf_prop-ref.dt-code
                                          )
          rest-rdb_id = rest-rdb_id + 1
          .
          if p-unload-history then do:
            if (not available buf0_hist-nws-option
            or buf0_hist-nws-option.get-hist-from-nws  >= 0
            or buf0_hist-nws-option.nws-to-hist  >= 0)
            and (available buf0_hist-nws-option
            and buf0_hist-nws-option.smart-nws <> integer('1':U))
            then do:
                create buf_rrdb-option.
                assign
                buf_rrdb-option.first-table-name = 'dis-card':U
                buf_rrdb-option.first-table-export = no
                buf_rrdb-option.second-table-name = 'c-dis-host':U
                buf_rrdb-option.third-table-name = 'c-dc-hist':U
                buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                    'each ub.c-dis-host no-lock where ub.c-dis-host.d-card = ub.dis-card.d-card and ' +
                                                    'ub.c-dis-host.dt-code = &3 and ' +
                                                    'ub.c-dis-host.host-code = 0,' +
                                                    'first ub.c-dc-hist no-lock where ' +
                                                    'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                    'ub.c-dc-hist.corr-user-db-num = ub.c-dis-host.corr-user-db-num and ' +
                                                    'ub.c-dc-hist.chip-num = ub.c-dis-host.chip-num '
                                                    , buf_dis-card-type.emitent-host-code
                                                    , buf_dis-card-type.type
                                                    , buf_prop-ref.dt-code
                                                    )
                buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                          or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                        then '':U
                                        else "if-self")
                buf_rrdb-option.if-buffer-num = 2
                buf_rrdb-option.dump-point = "ref"
                buf_rrdb-option.subject-group = "dc"
                buf_rrdb-option.id = rest-rdb_id + 1
                buf_rrdb-option.des = substitute("c-dis-host: type = &1 dtm-code = &2 dt-code = &3"
                                                , buf_dis-card-type.type
                                                ,buf_prop-head.dtm-code
                                                ,buf_prop-ref.dt-code
                                                )
                rest-rdb_id = rest-rdb_id + 1
                .
              end.
            end.
          end.
        end.
      end.
      if buf_prop-head.storage-place-obj = 'dis-obj':U
      then do:
        find first buf0_hist-nws-option where
                  buf0_hist-nws-option.table-name = 'dis-obj':U
              and buf0_hist-nws-option.db-num = 0
              and buf0_hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
              and buf0_hist-nws-option.charkey_one = buf_Dis-card-type.type
              and buf0_hist-nws-option.charkey_two = '':U
              and buf0_hist-nws-option.charkey_three = '':U
              and buf0_hist-nws-option.key#_one = buf_prop-head.dtm-code
              and buf0_hist-nws-option.key#_two = 0
              and buf0_hist-nws-option.key#_three = 0
              and buf0_hist-nws-option.obj-type = ''
              and buf0_hist-nws-option.obj-code = 0
              no-error .
        if NOT available buf0_hist-nws-option
        or (available buf0_hist-nws-option
            and
                (buf0_hist-nws-option.smart-nws = integer('-1':U)
                  or buf0_hist-nws-option.smart-nws = integer('-10':U))
            )
        then do:
          for each buf_prop-ref no-lock where
                  buf_prop-ref.dtm-code = buf_prop-head.dtm-code:
            create buf_rrdb-option.
            assign
            buf_rrdb-option.first-table-name = 'dis-card':U
            buf_rrdb-option.first-table-export = no
            buf_rrdb-option.second-table-name = 'dis-obj':U
            buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                'each ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                                'ub.dis-obj.dt-code = &3'
                                                  , buf_dis-card-type.emitent-host-code
                                                  , buf_dis-card-type.type
                                                  , buf_prop-ref.dt-code
                                                  )
            buf_rrdb-option.if-phrase = ''
            buf_rrdb-option.dump-point = "ref"
            buf_rrdb-option.subject-group = "dc"
            buf_rrdb-option.id = rest-rdb_id + 1
            buf_rrdb-option.des = substitute("dis-obj: type = &1 dtm-code = &2 dt-code = &3"
                                            , buf_dis-card-type.type
                                            ,buf_prop-head.dtm-code
                                            ,buf_prop-ref.dt-code
                                            )
            rest-rdb_id = rest-rdb_id + 1
            .
            if p-unload-history then do:
              if not available buf0_hist-nws-option
              or buf0_hist-nws-option.get-hist-from-nws  >= 0
              or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
                create buf_rrdb-option.
                assign
                buf_rrdb-option.first-table-name = 'dis-card':U
                buf_rrdb-option.first-table-export = no
                buf_rrdb-option.second-table-name = 'c-dis-obj':U
                buf_rrdb-option.third-table-name = 'c-dc-hist':U
                buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                    'each ub.c-dis-obj no-lock where ub.c-dis-obj.d-card = ub.dis-card.d-card and ' +
                                                    'ub.c-dis-obj.dt-code = &3, ' +
                                                    'first ub.c-dc-hist no-lock where ' +
                                                    'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                    'ub.c-dc-hist.corr-user-db-num = ub.c-dis-obj.corr-user-db-num and ' +
                                                    'ub.c-dc-hist.chip-num = ub.c-dis-obj.chip-num '
                                                      , buf_dis-card-type.emitent-host-code
                                                      , buf_dis-card-type.type
                                                      , buf_prop-ref.dt-code
                                                      )
                buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                          or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                        then '':U
                                        else "if-self")
                buf_rrdb-option.if-buffer-num = 2
                buf_rrdb-option.dump-point = "ref"
                buf_rrdb-option.subject-group = "dc"
                buf_rrdb-option.id = rest-rdb_id + 1
                buf_rrdb-option.des = substitute("c-dis-obj: type = &1 dtm-code = &2 dt-code = &3"
                                                , buf_dis-card-type.type
                                                ,buf_prop-head.dtm-code
                                                ,buf_prop-ref.dt-code
                                                )
                rest-rdb_id = rest-rdb_id + 1
                .
              end.
            end.
          end.
        end.
        if available buf0_hist-nws-option
        and (buf0_hist-nws-option.smart-nws = integer('0':U)
             or
             buf0_hist-nws-option.smart-nws = integer('10':U)
            ) then do:
          for each buf_prop-ref no-lock where
                  buf_prop-ref.dtm-code = buf_prop-head.dtm-code:
            find first buf_dis-obj no-lock where
                    buf_dis-obj.dt-code = buf_prop-ref.dt-code no-error.
            if available buf_dis-obj then do:
              create buf_rrdb-option.
              assign
              buf_rrdb-option.first-table-name = 'dis-card':U
              buf_rrdb-option.first-table-export = no
              buf_rrdb-option.second-table-name = 'dis-obj':U
              buf_rrdb-option.third-table-name = 'clients':U
              buf_rrdb-option.third-table-export = no
              buf_rrdb-option.fourth-table-name = substitute("buf_&1", 'dis-obj':U)
              buf_rrdb-option.fourth-table-export = no
              buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                  'each ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                                  'ub.dis-obj.dt-code = &3,' +
                                                  'first ub.clients no-lock where ub.clients.db-num = &4, ' +
                                                  'first buf_dis-obj no-lock where buf_dis-obj.d-card = ub.dis-card.d-card and ' +
                                                  'buf_dis-obj.obj-type = ub.clients.obj-type and buf_dis-obj.obj-code = ub.clients.obj-code '
                                                  , buf_dis-card-type.emitent-host-code
                                                  , buf_dis-card-type.type
                                                  , buf_prop-ref.dt-code
                                                  ,p-db-num
                                                    )
              buf_rrdb-option.if-phrase = ''
              buf_rrdb-option.dump-point = "ref"
              buf_rrdb-option.subject-group = "dc"
              buf_rrdb-option.id = rest-rdb_id + 1
              buf_rrdb-option.des = substitute("dis-obj: type = &1 dtm-code = &2 dt-code = &3"
                                              , buf_dis-card-type.type
                                              ,buf_prop-head.dtm-code
                                              ,buf_prop-ref.dt-code
                                              )
              rest-rdb_id = rest-rdb_id + 1
              .
              if p-unload-history then do:
                if not available buf0_hist-nws-option
                or buf0_hist-nws-option.get-hist-from-nws  >= 0
                or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
                  create buf_rrdb-option.
                  assign
                  buf_rrdb-option.first-table-name = 'dis-card':U
                  buf_rrdb-option.first-table-export = no
                  buf_rrdb-option.second-table-name = 'c-dis-obj':U
                  buf_rrdb-option.third-table-name = 'c-dc-hist':U
                  buf_rrdb-option.fourth-table-name = 'clients':U
                  buf_rrdb-option.fourth-table-export = no
                  buf_rrdb-option.fifth-table-name = substitute("buf_&1", 'dis-obj':U)
                  buf_rrdb-option.fifth-table-export = no
                  buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                      'each ub.c-dis-obj no-lock where ub.c-dis-obj.d-card = ub.dis-card.d-card and ' +
                                                      'ub.c-dis-obj.dt-code = &3, ' +
                                                      'first ub.c-dc-hist no-lock where ' +
                                                      'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                      'ub.c-dc-hist.corr-user-db-num = ub.c-dis-obj.corr-user-db-num and ' +
                                                      'ub.c-dc-hist.chip-num = ub.c-dis-obj.chip-num, ' +
                                                      'first ub.clients no-lock where ub.clients.db-num = &4, ' +
                                                      'first buf_dis-obj no-lock where buf_dis-obj.d-card = ub.dis-card.d-card and ' +
                                                      'buf_dis-obj.obj-type = ub.clients.obj-type and buf_dis-obj.obj-code = ub.clients.obj-code '
                                                      , buf_dis-card-type.emitent-host-code
                                                      , buf_dis-card-type.type
                                                      , buf_prop-ref.dt-code
                                                      , p-db-num
                                                      )
                  buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                          or (buf0_hist-nws-option.hist-to-nws  >= 0
                                          and buf0_hist-nws-option.get-hist-from-nws  >= 0)
                                          then '':U
                                          else "if-self")
                  buf_rrdb-option.if-buffer-num = 2
                  buf_rrdb-option.dump-point = "ref"
                  buf_rrdb-option.subject-group = "dc"
                  buf_rrdb-option.id = rest-rdb_id + 1
                  buf_rrdb-option.des = substitute("c-dis-obj: type = &1 dtm-code = &2 dt-code = &3"
                                                  , buf_dis-card-type.type
                                                  ,buf_prop-head.dtm-code
                                                  ,buf_prop-ref.dt-code
                                                  )
                  rest-rdb_id = rest-rdb_id + 1
                  .
                end.
              end.
            end.
          end.
        end.
        if available buf0_hist-nws-option
        and buf0_hist-nws-option.smart-nws = integer('1':U)
        then do:
          for each buf_prop-ref no-lock where
                  buf_prop-ref.dtm-code = buf_prop-head.dtm-code:
          for each buf_clients no-lock where
              buf_clients.db-num = p-db-num,
            first buf_dis-obj no-lock where
                      buf_Dis-obj.dt-code = buf_prop-ref.dt-code
                and  buf_Dis-obj.obj-type = buf_clients.obj-type
                and  buf_Dis-obj.obj-code = buf_clients.obj-code:
            leave.
          end.
          if available buf_dis-obj then do:
              create buf_rrdb-option.
              assign
              buf_rrdb-option.first-table-name = 'dis-card':U
              buf_rrdb-option.first-table-export = no
              buf_rrdb-option.second-table-name = 'dis-obj':U
              buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                  'each ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                                  'ub.dis-obj.dt-code = &3 and ' +
                                                  'ub.dis-obj.obj-type = "&&1" and ' +
                                                  'ub.dis-obj.obj-code = &&2 '
                                                    , buf_dis-card-type.emitent-host-code
                                                    , buf_dis-card-type.type
                                                    , buf_prop-ref.dt-code
                                                    )
              buf_rrdb-option.if-phrase = ''
              buf_rrdb-option.dump-point = "obj"
              buf_rrdb-option.subject-group = "dc"
              buf_rrdb-option.id = rest-rdb_id + 1
              buf_rrdb-option.des = substitute("dis-obj: type = &1 dtm-code = &2 dt-code = &3"
                                              , buf_dis-card-type.type
                                              ,buf_prop-head.dtm-code
                                              ,buf_prop-ref.dt-code
                                              )
              rest-rdb_id = rest-rdb_id + 1
              .
              if p-unload-history then do:
                if not available buf0_hist-nws-option
                or buf0_hist-nws-option.get-hist-from-nws  >= 0
                or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
                  create buf_rrdb-option.
                  assign
                  buf_rrdb-option.first-table-name = 'dis-card':U
                  buf_rrdb-option.first-table-export = no
                  buf_rrdb-option.second-table-name = 'c-dis-obj':U
                  buf_rrdb-option.third-table-name = 'c-dc-hist':U
                  buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                      'each ub.c-dis-obj no-lock where ub.c-dis-obj.d-card = ub.dis-card.d-card and ' +
                                                      'ub.c-dis-obj.dt-code = &3 and ' +
                                                      'ub.c-dis-obj.obj-type = "&&1" and ' +
                                                      'ub.c-dis-obj.obj-code = &&2, ' +
                                                      'first ub.c-dc-hist no-lock where ' +
                                                      'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                      'ub.c-dc-hist.corr-user-db-num = ub.c-dis-obj.corr-user-db-num and ' +
                                                      'ub.c-dc-hist.chip-num = ub.c-dis-obj.chip-num '
                                                      , buf_dis-card-type.emitent-host-code
                                                      , buf_dis-card-type.type
                                                      , buf_prop-ref.dt-code
                                                      )
                  buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                            or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                          then '':U
                                          else "if-self")
                  buf_rrdb-option.if-buffer-num = 2
                  buf_rrdb-option.dump-point = "obj"
                  buf_rrdb-option.subject-group = "dc"
                  buf_rrdb-option.id = rest-rdb_id + 1
                  buf_rrdb-option.des = substitute("c-dis-obj: type = &1 dtm-code = &2 dt-code = &3"
                                                  , buf_dis-card-type.type
                                                  ,buf_prop-head.dtm-code
                                                  ,buf_prop-ref.dt-code
                                                  )
                  rest-rdb_id = rest-rdb_id + 1
                  .
                end.
              end.
            end.
          end.
        end.
      end.
      if buf_prop-head.storage-place-obj = 'dis-card-property':U then do:
        find first buf0_hist-nws-option where
                  buf0_hist-nws-option.table-name = 'dis-card-property':U
              and buf0_hist-nws-option.db-num = 0
              and buf0_hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
              and buf0_hist-nws-option.charkey_one = buf_Dis-card-type.type
              and buf0_hist-nws-option.charkey_two = '':U
              and buf0_hist-nws-option.charkey_three = '':U
              and buf0_hist-nws-option.key#_one = buf_prop-head.dtm-code
              and buf0_hist-nws-option.key#_two = 0
              and buf0_hist-nws-option.key#_three = 0
              and buf0_hist-nws-option.obj-type = ''
              and buf0_hist-nws-option.obj-code = 0
              no-error .
         if not available buf0_hist-nws-option
         or (available buf0_hist-nws-option
             and
              (buf0_hist-nws-option.smart-nws = integer('-1':U)
               or
               buf0_hist-nws-option.smart-nws = integer('-10':U)
               )
             )
         then do:
          create buf_rrdb-option.
          assign
          buf_rrdb-option.first-table-name = 'dis-card':U
          buf_rrdb-option.first-table-export = no
          buf_rrdb-option.second-table-name = 'dis-card-property':U
          buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                              'each ub.dis-card-property where ub.dis-card-property.d-card = ub.dis-card.d-card and ' +
                                              'ub.dis-card-property.dtm-code = &3'
                                                , buf_dis-card-type.emitent-host-code
                                                , buf_dis-card-type.type
                                                , buf_prop-head.dtm-code
                                                )
          buf_rrdb-option.if-phrase = ''
          buf_rrdb-option.dump-point = "ref"
          buf_rrdb-option.subject-group = "dc"
          buf_rrdb-option.id = rest-rdb_id + 1
          buf_rrdb-option.des = substitute("dis-card-property: type = &1 dtm-code = &2"
                                          , buf_dis-card-type.type
                                          ,buf_prop-head.dtm-code
                                          )
          rest-rdb_id = rest-rdb_id + 1
          .
          if p-unload-history then do:
            if not available buf0_hist-nws-option
            or buf0_hist-nws-option.get-hist-from-nws  >= 0
            or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
              create buf_rrdb-option.
              assign
              buf_rrdb-option.first-table-name = 'dis-card':U
              buf_rrdb-option.first-table-export = no
              buf_rrdb-option.second-table-name = 'c-dis-card-property':U
              buf_rrdb-option.third-table-name = 'c-dc-hist':U
              buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                  'each ub.c-dis-card-property where ub.c-dis-card-property.d-card = ub.dis-card.d-card and ' +
                                                  'ub.c-dis-card-property.dtm-code = &3,  ' +
                                                  'first ub.c-dc-hist no-lock where ' +
                                                  'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                  'ub.c-dc-hist.corr-user-db-num = ub.c-dis-card-property.corr-user-db-num and ' +
                                                  'ub.c-dc-hist.chip-num = ub.c-dis-card-property.chip-num '
                                                    , buf_dis-card-type.emitent-host-code
                                                    , buf_dis-card-type.type
                                                    , buf_prop-head.dtm-code
                                                    )
              buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                        or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                      then '':U
                                      else "if-self")
              buf_rrdb-option.if-buffer-num = 2
              buf_rrdb-option.dump-point = "ref"
              buf_rrdb-option.subject-group = "dc"
              buf_rrdb-option.id = rest-rdb_id + 1
              buf_rrdb-option.des = substitute("c-dis-card-property: type = &1 dtm-code = &2"
                                              , buf_dis-card-type.type
                                              ,buf_prop-head.dtm-code
                                              )
              rest-rdb_id = rest-rdb_id + 1
              .
            end.
           end.
         end.
         if available buf0_hist-nws-option
         and
         (buf0_hist-nws-option.smart-nws = integer('0':U)
          or
          buf0_hist-nws-option.smart-nws = integer('10':U)
          )
         then do:
          create buf_rrdb-option.
          assign
          buf_rrdb-option.first-table-name = 'dis-card':U
          buf_rrdb-option.first-table-export = no
          buf_rrdb-option.second-table-name = 'dis-card-property':U
          buf_rrdb-option.third-table-name = 'clients':U
          buf_rrdb-option.third-table-export = no
          buf_rrdb-option.fourth-table-name = 'dis-obj':U
          buf_rrdb-option.fourth-table-export = no
          buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                              'each ub.dis-card-property where ub.dis-card-property.d-card = ub.dis-card.d-card and ' +
                                              'ub.dis-card-property.dtm-code = &3,' +
                                              'first ub.clients no-lock where ub.clients.db-num = &4, ' +
                                              'first ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                              'ub.dis-obj.obj-type = ub.clients.obj-type and ub.dis-obj.obj-code = ub.clients.obj-code '
                                              , buf_dis-card-type.emitent-host-code
                                              , buf_dis-card-type.type
                                              , buf_prop-head.dtm-code
                                              , p-db-num
                                                )
          buf_rrdb-option.if-phrase = ''
          buf_rrdb-option.dump-point = "ref"
          buf_rrdb-option.subject-group = "dc"
          buf_rrdb-option.id = rest-rdb_id + 1
          buf_rrdb-option.des = substitute("dis-card-property: type = &1 dtm-code = &2"
                                          , buf_dis-card-type.type
                                          ,buf_prop-head.dtm-code
                                          )
          rest-rdb_id = rest-rdb_id + 1
          .
          if p-unload-history then do:
            if not available buf0_hist-nws-option
            or buf0_hist-nws-option.get-hist-from-nws  >= 0
            or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
              create buf_rrdb-option.
              assign
              buf_rrdb-option.first-table-name = 'dis-card':U
              buf_rrdb-option.first-table-export = no
              buf_rrdb-option.second-table-name = 'c-dis-card-property':U
              buf_rrdb-option.third-table-name = 'c-dc-hist':U
              buf_rrdb-option.fourth-table-name = 'clients':U
              buf_rrdb-option.fourth-table-export = no
              buf_rrdb-option.fifth-table-name = 'dis-obj':U
              buf_rrdb-option.fifth-table-export = no
              buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                  'each ub.c-dis-card-property where ub.c-dis-card-property.d-card = ub.dis-card.d-card and ' +
                                                  'ub.c-dis-card-property.dtm-code = &3,  ' +
                                                  'first ub.c-dc-hist no-lock where ' +
                                                  'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                  'ub.c-dc-hist.corr-user-db-num = ub.c-dis-card-property.corr-user-db-num and ' +
                                                  'ub.c-dc-hist.chip-num = ub.c-dis-card-property.chip-num, ' +
                                                  'first ub.clients no-lock where ub.clients.db-num = &4, ' +
                                                  'first ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                                  'ub.dis-obj.obj-type = ub.clients.obj-type and ub.dis-obj.obj-code = ub.clients.obj-code '
                                                  , buf_dis-card-type.emitent-host-code
                                                  , buf_dis-card-type.type
                                                  , buf_prop-head.dtm-code
                                                  , p-db-num
                                                    )
              buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                        or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                      then '':U
                                      else "if-self")
              buf_rrdb-option.if-buffer-num = 2
              buf_rrdb-option.dump-point = "ref"
              buf_rrdb-option.subject-group = "dc"
              buf_rrdb-option.id = rest-rdb_id + 1
              buf_rrdb-option.des = substitute("c-dis-card-property: type = &1 dtm-code = &2"
                                              , buf_dis-card-type.type
                                              ,buf_prop-head.dtm-code
                                              )
              rest-rdb_id = rest-rdb_id + 1
              .
            end.
           end.
         end.
         if available buf0_hist-nws-option
         and buf0_hist-nws-option.smart-nws = integer('1':U) then do:
          create buf_rrdb-option.
          assign
          buf_rrdb-option.first-table-name = 'dis-card':U
          buf_rrdb-option.first-table-export = no
          buf_rrdb-option.second-table-name = 'dis-card-property':U
          buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                              'each ub.dis-card-property where ub.dis-card-property.d-card = ub.dis-card.d-card and ' +
                                              'ub.dis-card-property.dtm-code = &3 and ' +
                                              'ub.dis-card-property.obj-type = "&&1" and ' +
                                              'ub.dis-card-property.obj-code = &&2 '
                                                , buf_dis-card-type.emitent-host-code
                                                , buf_dis-card-type.type
                                                , buf_prop-head.dtm-code
                                                )
          buf_rrdb-option.if-phrase = ''
          buf_rrdb-option.dump-point = "obj"
          buf_rrdb-option.subject-group = "dc"
          buf_rrdb-option.id = rest-rdb_id + 1
          buf_rrdb-option.des = substitute("dis-card-property: type = &1 dtm-code = &2"
                                          , buf_dis-card-type.type
                                          ,buf_prop-head.dtm-code
                                          )
          rest-rdb_id = rest-rdb_id + 1
          .
          if p-unload-history then do:
            if not available buf0_hist-nws-option
            or buf0_hist-nws-option.get-hist-from-nws  >= 0
            or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
              create buf_rrdb-option.
              assign
              buf_rrdb-option.first-table-name = 'dis-card':U
              buf_rrdb-option.first-table-export = no
              buf_rrdb-option.second-table-name = 'c-dis-card-property':U
              buf_rrdb-option.third-table-name = 'c-dc-hist':U
              buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                  'each ub.c-dis-card-property where ub.c-dis-card-property.d-card = ub.dis-card.d-card and ' +
                                                  'ub.c-dis-card-property.dtm-code = &3 and ' +
                                                  'ub.c-dis-card-property.obj-type = "&&1" and ' +
                                                  'ub.c-dis-card-property.obj-code = &&2, ' +
                                                  'first ub.c-dc-hist no-lock where ' +
                                                  'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                  'ub.c-dc-hist.corr-user-db-num = ub.c-dis-card-property.corr-user-db-num and ' +
                                                  'ub.c-dc-hist.chip-num = ub.c-dis-card-property.chip-num '
                                                    , buf_dis-card-type.emitent-host-code
                                                    , buf_dis-card-type.type
                                                    , buf_prop-head.dtm-code
                                                    )
              buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                        or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                      then '':U
                                      else "if-self")
              buf_rrdb-option.if-buffer-num = 2
              buf_rrdb-option.dump-point = "obj"
              buf_rrdb-option.subject-group = "dc"
              buf_rrdb-option.id = rest-rdb_id + 1
              buf_rrdb-option.des = substitute("c-dis-card-property: type = &1 dtm-code = &2"
                                              , buf_dis-card-type.type
                                              ,buf_prop-head.dtm-code
                                              )
              rest-rdb_id = rest-rdb_id + 1
              .
            end.
           end.
         end.
      end.
      if buf_prop-head.storage-place-obj = 'dis-card':U then do:
        find first buf0_hist-nws-option where
                  buf0_hist-nws-option.table-name = 'dis-card':U
              and buf0_hist-nws-option.db-num = 0
              and buf0_hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
              and buf0_hist-nws-option.charkey_one = buf_Dis-card-type.type
              and buf0_hist-nws-option.charkey_two = '':U
              and buf0_hist-nws-option.charkey_three = '':U
              and buf0_hist-nws-option.key#_one = buf_prop-head.dtm-code
              and buf0_hist-nws-option.key#_two = 0
              and buf0_hist-nws-option.key#_three = 0
              and buf0_hist-nws-option.obj-type = ''
              and buf0_hist-nws-option.obj-code = 0
              no-error .
          if p-unload-history then do:
            if not available buf0_hist-nws-option
            or buf0_hist-nws-option.get-hist-from-nws  >= 0
            or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
              create buf_rrdb-option.
              assign
              buf_rrdb-option.first-table-name = 'dis-card':U
              buf_rrdb-option.first-table-export = no
              buf_rrdb-option.second-table-name = 'c-dis-card':U
              buf_rrdb-option.third-table-name = 'c-dc-hist':U
              buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                  'each ub.c-dis-card where ub.c-dis-card.d-card = ub.dis-card.d-card,' +
                                                  'first ub.c-dc-hist no-lock where ' +
                                                  'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                  'ub.c-dc-hist.corr-user-db-num = ub.c-dis-card.corr-user-db-num and ' +
                                                  'ub.c-dc-hist.chip-num = ub.c-dis-card.chip-num '
                                                    , buf_dis-card-type.emitent-host-code
                                                    , buf_dis-card-type.type
                                                    )
              buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                        or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                      then '':U
                                      else "if-self")
              buf_rrdb-option.if-buffer-num = 2
              buf_rrdb-option.dump-point = "ref"
              buf_rrdb-option.subject-group = "dc"
              buf_rrdb-option.id = rest-rdb_id + 1
              buf_rrdb-option.des = substitute("c-dis-card: type = &1"
                                              , buf_dis-card-type.type
                                              )
              rest-rdb_id = rest-rdb_id + 1
              .
          end.
        end.
      end.
    end.
    find first buf0_hist-nws-option where
              buf0_hist-nws-option.table-name = 'dis-dc-rule':U
          and buf0_hist-nws-option.db-num = p-db-num
          and buf0_hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
          and buf0_hist-nws-option.charkey_one = buf_Dis-card-type.type
          and buf0_hist-nws-option.charkey_two = '':U
          and buf0_hist-nws-option.charkey_three = '':U
          and buf0_hist-nws-option.key#_one = 0
          and buf0_hist-nws-option.key#_two = 0
          and buf0_hist-nws-option.key#_three = 0
          and buf0_hist-nws-option.obj-type = ''
          and buf0_hist-nws-option.obj-code = 0
          no-error .
    if not available buf0_hist-nws-option
    or (available buf0_hist-nws-option
        and
        (buf0_hist-nws-option.smart-nws = integer('-1':U)
         or
         buf0_hist-nws-option.smart-nws = integer('-10':U)
        )
       ) then do:
      create buf_rrdb-option.
      assign
      buf_rrdb-option.first-table-name = 'dis-card':U
      buf_rrdb-option.first-table-export = no
      buf_rrdb-option.second-table-name = 'dis-dc-rule':U
      buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                          'each ub.dis-dc-rule where ub.dis-dc-rule.d-card = ub.dis-card.d-card and ub.dis-dc-rule.obj-type > "&3"'
                                            , buf_dis-card-type.emitent-host-code
                                            , buf_dis-card-type.type
                                            , ''
                                            )
      buf_rrdb-option.if-phrase = ''
      buf_rrdb-option.dump-point = "ref"
      buf_rrdb-option.subject-group = "dc"
      buf_rrdb-option.id = rest-rdb_id + 1
      buf_rrdb-option.des = substitute("dis-dc-rule: type = &1"
                                      , buf_dis-card-type.type
                                      )
      rest-rdb_id = rest-rdb_id + 1
      .
      if p-unload-history then do:
        if not available buf0_hist-nws-option
        or buf0_hist-nws-option.get-hist-from-nws  >= 0
        or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
          create buf_rrdb-option.
          assign
          buf_rrdb-option.first-table-name = 'dis-card':U
          buf_rrdb-option.first-table-export = no
          buf_rrdb-option.second-table-name = 'c-dis-dc-rule':U
          buf_rrdb-option.third-table-name = 'c-dc-hist':U
          buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                              'each ub.c-dis-dc-rule where ub.c-dis-dc-rule.d-card = ub.dis-card.d-card and ub.c-dis-dc-rule.obj-type > "&3", ' +
                                              'first ub.c-dc-hist no-lock where ' +
                                              'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                              'ub.c-dc-hist.corr-user-db-num = ub.c-dis-dc-rule.corr-user-db-num and ' +
                                              'ub.c-dc-hist.chip-num = ub.c-dis-dc-rule.chip-num '
                                                , buf_dis-card-type.emitent-host-code
                                                , buf_dis-card-type.type
                                                , ''
                                                )
          buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                    or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                  then '':U
                                  else "if-self")
          buf_rrdb-option.if-buffer-num = 2
          buf_rrdb-option.dump-point = "ref"
          buf_rrdb-option.subject-group = "dc"
          buf_rrdb-option.id = rest-rdb_id + 1
          buf_rrdb-option.des = substitute("c-dis-dc-rule: type = &1"
                                          , buf_dis-card-type.type
                                          )
          rest-rdb_id = rest-rdb_id + 1
          .
        end.
      end.
    end.
    if available buf0_hist-nws-option
    and
        (buf0_hist-nws-option.smart-nws = integer('0':U)
         or
         buf0_hist-nws-option.smart-nws = integer('10':U)
        )
     then do:
      create buf_rrdb-option.
      assign
      buf_rrdb-option.first-table-name = 'dis-card':U
      buf_rrdb-option.first-table-export = no
      buf_rrdb-option.second-table-name = 'dis-dc-rule':U
      buf_rrdb-option.third-table-name = 'clients':U
      buf_rrdb-option.third-table-export = no
      buf_rrdb-option.fourth-table-name = 'dis-obj':U
      buf_rrdb-option.fourth-table-export = no
      buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                          'each ub.dis-dc-rule where ub.dis-dc-rule.d-card = ub.dis-card.d-card, ' +
                                          'first ub.clients no-lock where ub.clients.db-num = &43  and ub.clients.obj-type = ub.dis-dc-rule.obj-type and ub.clients.obj-code = ub.dis-dc-rule.obj-code, ' +
                                          'first ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                          'ub.dis-obj.obj-type = ub.clients.obj-type and ub.dis-obj.obj-code = ub.clients.obj-code '
                                          , buf_dis-card-type.emitent-host-code
                                          , buf_dis-card-type.type
                                          , p-db-num
                                            )
      buf_rrdb-option.if-phrase = ''
      buf_rrdb-option.dump-point = "ref"
      buf_rrdb-option.subject-group = "dc"
      buf_rrdb-option.id = rest-rdb_id + 1
      buf_rrdb-option.des = substitute("dis-dc-rule: type = &1"
                                      , buf_dis-card-type.type
                                      )
      rest-rdb_id = rest-rdb_id + 1
      .
      if p-unload-history then do:
        if not available buf0_hist-nws-option
        or buf0_hist-nws-option.get-hist-from-nws  >= 0
        or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
          create buf_rrdb-option.
          assign
          buf_rrdb-option.first-table-name = 'dis-card':U
          buf_rrdb-option.first-table-export = no
          buf_rrdb-option.second-table-name = 'c-dis-dc-rule':U
          buf_rrdb-option.third-table-name = 'c-dc-hist':U
          buf_rrdb-option.fourth-table-name = 'clients':U
          buf_rrdb-option.fourth-table-export = no
          buf_rrdb-option.fifth-table-name = 'dis-obj':U
          buf_rrdb-option.fifth-table-export = no
          buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                              'each ub.c-dis-dc-rule where ub.c-dis-dc-rule.d-card = ub.dis-card.d-card, ' +
                                              'first ub.c-dc-hist no-lock where ' +
                                              'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                              'ub.c-dc-hist.corr-user-db-num = ub.c-dis-dc-rule.corr-user-db-num and ' +
                                              'ub.c-dc-hist.chip-num = ub.c-dis-dc-rule.chip-num, ' +
                                              'first ub.clients no-lock where ub.clients.db-num = &3 and ub.clients.obj-type = ub.c-dis-dc-rule.obj-type and ub.clients.obj-code = ub.c-dis-dc-rule.obj-code , ' +
                                              'first ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                              'ub.dis-obj.obj-type = ub.clients.obj-type and ub.dis-obj.obj-code = ub.clients.obj-code '
                                                , buf_dis-card-type.emitent-host-code
                                                , buf_dis-card-type.type
                                                , p-db-num
                                                )
          buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                    or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                  then '':U
                                  else "if-self")
          buf_rrdb-option.if-buffer-num = 2
          buf_rrdb-option.dump-point = "ref"
          buf_rrdb-option.subject-group = "dc"
          buf_rrdb-option.id = rest-rdb_id + 1
          buf_rrdb-option.des = substitute("c-dis-dc-rule: type = &1"
                                          , buf_dis-card-type.type
                                          )
          rest-rdb_id = rest-rdb_id + 1
          .
        end.
      end.
    end.
    if available buf0_hist-nws-option
    and buf0_hist-nws-option.smart-nws = integer('1':U) then do:
      create buf_rrdb-option.
      assign
      buf_rrdb-option.first-table-name = 'dis-card':U
      buf_rrdb-option.first-table-export = no
      buf_rrdb-option.second-table-name = 'dis-dc-rule':U
      buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                          'each ub.dis-dc-rule where ub.dis-dc-rule.d-card = ub.dis-card.d-card and ' +
                                          'ub.dis-dc-rule.obj-type = "&&1" and ' +
                                          'ub.dis-dc-rule.obj-code = &&2'
                                            , buf_dis-card-type.emitent-host-code
                                            , buf_dis-card-type.type
                                            )
      buf_rrdb-option.if-phrase = ''
      buf_rrdb-option.dump-point = "obj"
      buf_rrdb-option.subject-group = "dc"
      buf_rrdb-option.id = rest-rdb_id + 1
      buf_rrdb-option.des = substitute("dis-dc-rule: type = &1"
                                      , buf_dis-card-type.type
                                      )
      rest-rdb_id = rest-rdb_id + 1
      .
      if p-unload-history then do:
        if not available buf0_hist-nws-option
        or buf0_hist-nws-option.get-hist-from-nws  >= 0
        or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
          create buf_rrdb-option.
          assign
          buf_rrdb-option.first-table-name = 'dis-card':U
          buf_rrdb-option.first-table-export = no
          buf_rrdb-option.second-table-name = 'c-dis-dc-rule':U
          buf_rrdb-option.third-table-name = 'c-dc-hist':U
          buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                              'each ub.c-dis-dc-rule where ub.c-dis-dc-rule.d-card = ub.dis-card.d-card and ' +
                                              'ub.c-dis-dc-rule.obj-type = "&&1" and ' +
                                              'ub.c-dis-dc-rule.obj-code = &&2, ' +
                                              'first ub.c-dc-hist no-lock where ' +
                                              'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                              'ub.c-dc-hist.corr-user-db-num = ub.c-dis-dc-rule.corr-user-db-num and ' +
                                              'ub.c-dc-hist.chip-num = ub.c-dis-dc-rule.chip-num '
                                                , buf_dis-card-type.emitent-host-code
                                                , buf_dis-card-type.type
                                                )
          buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                    or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                  then '':U
                                  else "if-self")
          buf_rrdb-option.if-buffer-num = 2
          buf_rrdb-option.dump-point = "obj"
          buf_rrdb-option.subject-group = "dc"
          buf_rrdb-option.id = rest-rdb_id + 1
          buf_rrdb-option.des = substitute("c-dis-dc-rule: type = &1"
                                          , buf_dis-card-type.type
                                          )
          rest-rdb_id = rest-rdb_id + 1
          .
        end.
      end.
    end.
    find first buf0_hist-nws-option where
            buf0_hist-nws-option.table-name = 'dis-card-long':U
        and buf0_hist-nws-option.db-num = p-db-num
        and buf0_hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
        and buf0_hist-nws-option.charkey_one = buf_Dis-card-type.type
        and buf0_hist-nws-option.charkey_two = '':U
        and buf0_hist-nws-option.charkey_three = '':U
        and buf0_hist-nws-option.key#_one = 0
        and buf0_hist-nws-option.key#_two = 0
        and buf0_hist-nws-option.key#_three = 0
        and buf0_hist-nws-option.obj-type = ''
        and buf0_hist-nws-option.obj-code = 0
        no-error .
    if p-unload-history then do:
      if not available buf0_hist-nws-option
      or buf0_hist-nws-option.get-hist-from-nws  >= 0
      or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
        create buf_rrdb-option.
        assign
        buf_rrdb-option.first-table-name = 'dis-card':U
        buf_rrdb-option.first-table-export = no
        buf_rrdb-option.second-table-name = 'c-dis-card-long':U
        buf_rrdb-option.third-table-name = 'c-dc-hist':U
        buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                            'each ub.c-dis-card-long where ub.c-dis-card-long.d-card = ub.dis-card.d-card, ' +
                                            'first ub.c-dc-hist no-lock where ' +
                                            'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                            'ub.c-dc-hist.corr-user-db-num = ub.c-dis-card-long.corr-user-db-num and ' +
                                            'ub.c-dc-hist.chip-num = ub.c-dis-card-long.chip-num '
                                              , buf_dis-card-type.emitent-host-code
                                              , buf_dis-card-type.type
                                              )
        buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                  or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                then '':U
                                else "if-self")
        buf_rrdb-option.if-buffer-num = 2
        buf_rrdb-option.dump-point = "ref"
        buf_rrdb-option.subject-group = "dc"
        buf_rrdb-option.id = rest-rdb_id + 1
        buf_rrdb-option.des = substitute("c-dis-card-long: type = &1"
                                        , buf_dis-card-type.type
                                        )
        rest-rdb_id = rest-rdb_id + 1
        .
      end.
    end.
  end.
end.
end procedure.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define buffer buf_rrdb-option for rrdb-option.
define variable conf-par as character no-undo.
define variable ser-wth-conf-par as logical no-undo.
define variable par-type as character no-undo.
define variable fin-doc-par as integer no-undo.
define variable v-on-gbl as logical no-undo.
define variable v-multi as logical no-undo initial no .
define temp-table temp-cash-desk no-undo
  field last-date like ub.chk-doc.chk-date
  field last-time like ub.chk-doc.chk-time
  field cash-num  like ub.cash-desk.cash-num
  index pi        is   unique primary cash-num.
  define variable ind1                as integer   no-undo .
  define variable ind2                as integer   no-undo .
  define variable host                as integer   no-undo .
  define variable tot-cli-count       as integer   no-undo.
  define variable v-cli-count         as integer   no-undo.
  define variable tot-firm-db-count   as integer   no-undo.
  define variable firm-db-count       as integer   no-undo.
  define variable v-log               as logical   no-undo.
  define variable v-obj-is-active     as logical   no-undo.
  define variable v-proceeded-host    as character no-undo.
  define variable v-ok   as logical   no-undo .
  define variable v-lock as logical   no-undo .
  define variable v-msg  as character no-undo .
  define variable v-today       as date      no-undo.
  define variable v-time        as integer   no-undo.
  define variable v-hn          as logical   no-undo.
  define variable v-command   as character no-undo .
  define variable v-new-route as logical   no-undo .
  define variable v-subject as character no-undo .
  define variable bh as handle    no-undo .
  define buffer buf_pck-sent for ub.pck-sent .
  define buffer buf_pck-rcvd for ub.pck-rcvd .
  define temp-table tt-host-list no-undo
    field host-code like ub.store.host-code
    index pi        is   unique primary host-code
  .
  define variable l-prod-bc-global as logical no-undo .
  define            variable fl        as character no-undo format "x(14)":U .
  define new shared variable count-str as character no-undo initial "":U .
  define new shared frame ddd
    count-str label "":U      format "X(50)":U
    fl        label "Таблица" format "X(50)":U
    ind1      label "Записей"
  with view-as dialog-box side-labels 1 columns three-d title "Перекачка данных".
  define stream slog .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-erpRN'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  NO
  ,output conf-par
  ,output par-type
  ) no-error .
    IF not error-status:error and conf-par = "yes":U then mode-erprn = yes.
    else mode-erprn = no.
function get-hist-nws-option returns logical (  input p-db-num as integer
                                               ,input p-tbl-name as character ):
define buffer buf_hist-nws-option for ub.hist-nws-option.
define buffer buf0_hist-nws-option for ub.hist-nws-option.
find first buf_hist-nws-option no-lock where
          buf_hist-nws-option.table-name = p-tbl-name
      and buf_Hist-nws-option.db-num = p-db-num
      and buf_Hist-nws-option.host-code = 0
      and buf_Hist-nws-option.obj-type = '':U
      and buf_Hist-nws-option.obj-code = 0
      and buf_Hist-nws-option.charkey_one = '':U
      and buf_Hist-nws-option.charkey_two = '':U
      and buf_Hist-nws-option.charkey_three = '':U
      and buf_Hist-nws-option.key#_one = 0
      and buf_Hist-nws-option.key#_two = 0
      and buf_Hist-nws-option.key#_three = 0  no-error .
find first buf0_hist-nws-option no-lock where
          buf0_hist-nws-option.table-name = p-tbl-name
      and buf0_Hist-nws-option.db-num = 0
      and buf0_Hist-nws-option.host-code = 0
      and buf0_Hist-nws-option.obj-type = '':U
      and buf0_Hist-nws-option.obj-code = 0
      and buf0_Hist-nws-option.charkey_one = '':U
      and buf0_Hist-nws-option.charkey_two = '':U
      and buf0_Hist-nws-option.charkey_three = '':U
      and buf0_Hist-nws-option.key#_one = 0
      and buf0_Hist-nws-option.key#_two = 0
      and buf0_Hist-nws-option.key#_three = 0  no-error .
if
(not available buf_hist-nws-option
or buf_hist-nws-option.get-hist-from-nws >= 0 )
and
(not available buf0_hist-nws-option
or buf0_hist-nws-option.hist-to-nws >= 0 )
then do:
  return yes.
end.
return no.
end function.
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  if num-entries(p-type-unload, chr(4)) = 2
  then do :
    v-multi = logical(entry(2, p-type-unload, chr(4))) no-error.
    p-type-unload = entry(1, p-type-unload, chr(4)) .
  end.
  if transaction = true
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Активна транзакция" skip
      "Выгрузка невозможна" skip
      view-as alert-box error .
    undo, return error "Активна транзакция" .
  end.
  if p-type-unload <> 'unload-copy':U
  and not v-multi
  then do:
    message
      "Выгрузка УБД." skip
      "Все данные, не пришедшие в ГБД будут потеряны." skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-log .
    if not v-log then do:
      return "not-create":U .
    end.
  end.
  view frame ddd.
  assign
    ind1 = 0
    fl = "start":U
    count-str = substitute( "Выгрузка УБД &1", p-db-num )
  .
  do with frame ddd
  :
    assign
      count-str :screen-value   = string( count-str, count-str :format)
      fl :screen-value          = string( fl, fl :format)
      ind1 :screen-value        = string( ind1, ind1 :format)
    .
  end.
  output stream slog to rest-rdb.txt append .
  export stream slog "start-rest":U cur-time-string() .
  output stream slog close .
  output stream slog to rest-rdb.txt append .
  export stream slog "disable triggers of dst":U cur-time-string() .
  output stream slog close .
  for each dst._file no-lock
    where dst._file._hidden = false
  on error  undo, return error substitute( "&1 (disable-load-triggers-dst). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (disable-load-triggers-dst). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (disable-load-triggers-dst). endkey", vss-workfile )
  :
    create buffer bh for table substitute( "dst.&1", dst._file._file-name ) .
    bh:disable-load-triggers(true) .
    delete object bh .
  end.
  if p-type-unload = 'unload-copy':U then do:
    output stream slog to rest-rdb.txt append .
    export stream slog "disable triggers of src":U cur-time-string() .
    output stream slog close .
    for each src._file no-lock
      where src._file._hidden = false
    on error  undo, return error substitute( "&1 (disable-load-triggers-src). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (disable-load-triggers-src). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (disable-load-triggers-src). endkey", vss-workfile )
    :
      create buffer bh for table substitute( "src.&1", src._file._file-name ) .
      bh:disable-load-triggers(true) .
      delete object bh .
    end.
  end.
  run db-attr-write in this-procedure
    ( input p-db-num
     ,input 'unload-after-cut':U
     ,input "yes"
    ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при записи значения атрибута 'выгрузка после обрезания' для БД &1", p-db-num ) skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
  end.
  output stream slog to rest-rdb.txt append .
  export stream slog "lock-news":U cur-time-string() .
  output stream slog close .
  assign
    v-lock = false
  .
define variable vss-include-info20 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_lock-route in g#lib-nws
  ( input  'lockfull'
  , input  p-db-num
  , input  0
  , input  substitute( 'Выгрузка УБД &1', p-db-num )
  , output v-msg
  , output v-lock
  , output v-ok
  ) no-error .
  if error-status :error
    or v-lock = false
    or v-ok   = false
  then do:
    message
      vss-workfile vss-revision vss-description skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
  end.
  find first ub.db no-lock
    where ub.db.db-num = p-db-num
    .
  do transaction
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define buffer buf_upgrade for ub.upgrade .
    find last buf_upgrade exclusive-lock
      where buf_upgrade.db-num = 0
      no-error .
    if available buf_upgrade then do:
      disable triggers for load of ub.upgrade.
      for each ub.upgrade exclusive-lock
        where ub.upgrade.db-num = p-db-num
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        delete ub.upgrade .
      end.
      create ub.upgrade .
      assign
        ub.upgrade.db-num      = p-db-num
        ub.upgrade.version-num = buf_upgrade.version-num
        ub.upgrade.version-ord = 1
        ub.upgrade.step-num    = buf_upgrade.step-num
        ub.upgrade.err-msgs    = "":U
        ub.upgrade.err-code    = 0
        ub.upgrade.complete    = TRUE
        ub.upgrade.UpgDate     = today
        ub.upgrade.UpgTimeInt  = time
        ub.upgrade.UpgTime     = string( time, "HH:MM:SS" )
       .
      if p-type-unload = 'unload-copy':U then do:
        for each src.upgrade exclusive-lock
          where src.upgrade.db-num = p-db-num
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          delete src.upgrade .
        end.
        create src.upgrade .
        assign
          src.upgrade.db-num      = ub.upgrade.db-num
          src.upgrade.version-num = ub.upgrade.version-num
          src.upgrade.version-ord = ub.upgrade.version-ord
          src.upgrade.step-num    = ub.upgrade.step-num
          src.upgrade.err-msgs    = ub.upgrade.err-msgs
          src.upgrade.err-code    = ub.upgrade.err-code
          src.upgrade.complete    = ub.upgrade.complete
          src.upgrade.UpgDate     = ub.upgrade.UpgDate
          src.upgrade.UpgTimeInt  = ub.upgrade.UpgTimeInt
          src.upgrade.UpgTime     = ub.upgrade.UpgTime
        .
      end.
    end.
  end.
  do transaction
  on error  undo, return error substitute( "&1 (transaction1). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (transaction1). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (transaction1). endkey", vss-workfile )
  :
    if not can-find (first src.db-status no-lock
      where src.db-status.db-num = p-db-num)
    then do:
      if not can-find (first ub.db-status no-lock
        where ub.db-status.db-num = p-db-num)
      then do:
        disable triggers for load of ub.db-status.
        create ub.db-status .
        assign
          ub.db-status.db-num = p-db-num
        .
      end.
      if p-type-unload = 'unload-copy':U then do:
        for each ub.db-status no-lock
          where ub.db-status.db-num = p-db-num
        on error  undo, return error substitute( "&1 (db-status). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo, return error substitute( "&1 (db-status). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (db-status). endkey", vss-workfile )
        :
          create src.db-status .
          buffer-copy ub.db-status to src.db-status .
        end.
      end.
    end.
    assign
      ind1 = 0
      fl = "code-range":U
      count-str = substitute( "Создание диапазонов кодов" )
    .
    do with frame ddd
    :
      assign
        count-str :screen-value   = string( count-str, count-str :format)
        fl :screen-value          = string( fl, fl :format)
        ind1 :screen-value        = string( ind1, ind1 :format)
      .
    end.
    if not mode-erprn then do:
        if not can-find (first src.code-range no-lock
          where src.code-range.db-num = p-db-num
            and src.code-range.range-type = 'bcgb':U)
        then do:
          if not can-find (first ub.code-range no-lock
            where ub.code-range.db-num = p-db-num
              and ub.code-range.range-type = 'bcgb':U)
          then do:
            disable triggers for load of ub.code-range.
            run new-bcod-gen-code-range in this-procedure
              ( input p-db-num
                ,input 'bcgb':U
              ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании нового свободного диапазона" skip
                "База данных" p-db-num skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
            end.
          end.
          if p-type-unload = 'unload-copy':U then do:
            for each ub.code-range no-lock
              where ub.code-range.db-num = p-db-num
                and ub.code-range.range-type = 'bcgb':U
            on error  undo, return error substitute( "&1 (code-range1). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (code-range1). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (code-range1). endkey", vss-workfile )
            :
              create src.code-range .
              buffer-copy ub.code-range to src.code-range .
            end.
          end.
        end.
        if not can-find (first src.code-range no-lock
          where src.code-range.db-num = p-db-num
            and src.code-range.range-type = 'ctgb':U)
        then do:
          if not can-find (first ub.code-range no-lock
            where ub.code-range.db-num = p-db-num
              and ub.code-range.range-type = 'ctgb':U)
          then do:
            disable triggers for load of ub.code-range.
            run new-bcod-gen-code-range in this-procedure
              ( input p-db-num
                ,input 'ctgb':U
              ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании нового свободного диапазона" skip
                "База данных" p-db-num skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
            end.
          end.
          if p-type-unload = 'unload-copy':U then do:
            for each ub.code-range no-lock
              where ub.code-range.db-num = p-db-num
                and ub.code-range.range-type = 'ctgb':U
            on error  undo, return error substitute( "&1 (code-range2). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (code-range2). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (code-range2). endkey", vss-workfile )
            :
              create src.code-range .
              buffer-copy ub.code-range to src.code-range .
            end.
          end.
        end.
        if not can-find (first src.code-range no-lock
          where src.code-range.db-num = p-db-num
            and src.code-range.range-type = 'drgb':U)
        then do:
          if not can-find (first ub.code-range no-lock
            where ub.code-range.db-num = p-db-num
              and ub.code-range.range-type = 'drgb':U)
          then do:
            disable triggers for load of ub.code-range.
            run new-bcod-gen-code-range in this-procedure
              ( input p-db-num
                ,input 'drgb':U
              ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании нового свободного диапазона" skip
                "База данных" p-db-num skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
            end.
          end.
          if p-type-unload = 'unload-copy':U then do:
            for each ub.code-range no-lock
              where ub.code-range.db-num = p-db-num
                and ub.code-range.range-type = 'drgb':U
            on error  undo, return error substitute( "&1 (code-range3). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (code-range3). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (code-range3). endkey", vss-workfile )
            :
              create src.code-range .
              buffer-copy ub.code-range to src.code-range .
            end.
          end.
          if not can-find (first src.code-range no-lock
            where src.code-range.db-num = p-db-num
              and src.code-range.range-type = 'fmgb':U)
          then do:
            if not can-find (first ub.code-range no-lock
              where ub.code-range.db-num = p-db-num
                and ub.code-range.range-type = 'fmgb':U)
            then do:
              disable triggers for load of ub.code-range.
              run new-bcod-gen-code-range in this-procedure
                ( input p-db-num
                  ,input 'fmgb':U
                ) no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при создании нового свободного диапазона" skip
                  "База данных" p-db-num skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
              end.
            end.
          end.
          if p-type-unload = 'unload-copy':U then do:
            for each ub.code-range no-lock
              where ub.code-range.db-num = p-db-num
                and ub.code-range.range-type = 'fmgb':U
            on error  undo, return error substitute( "&1 (code-range3). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (code-range3). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (code-range3). endkey", vss-workfile )
            :
              create src.code-range .
              buffer-copy ub.code-range to src.code-range .
            end.
          end.
          if not can-find (first src.code-range no-lock
            where src.code-range.db-num = p-db-num
              and src.code-range.range-type = 'pngb':U)
          then do:
            if not can-find (first ub.code-range no-lock
              where ub.code-range.db-num = p-db-num
                and ub.code-range.range-type = 'pngb':U)
            then do:
              disable triggers for load of ub.code-range.
              run new-bcod-gen-code-range in this-procedure
                ( input p-db-num
                  ,input 'pngb':U
                ) no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при создании нового свободного диапазона" skip
                  "База данных" p-db-num skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
              end.
            end.
          end.
          if p-type-unload = 'unload-copy':U then do:
            for each ub.code-range no-lock
              where ub.code-range.db-num = p-db-num
                and ub.code-range.range-type = 'pngb':U
            on error  undo, return error substitute( "&1 (code-range3). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (code-range3). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (code-range3). endkey", vss-workfile )
            :
              create src.code-range .
              buffer-copy ub.code-range to src.code-range .
            end.
          end.
      end.
     end.
     else do:
                create dst.code-range.
        assign
          dst.code-range.range-type = 'bcgb':U
          dst.code-range.PS         = "FOR ERP"
          dst.code-range.beg-date   = today
          dst.code-range.first-code = 1
          dst.code-range.last-code  = 1000000000 - 1
          dst.code-range.db-num     = p-db-num
          dst.code-range.stts       = "u":U
        .
        create dst.code-range.
        assign
          dst.code-range.range-type = 'bcgb':U
          dst.code-range.PS         = "FOR ERP"
          dst.code-range.beg-date   = today
          dst.code-range.first-code = 1000000000
          dst.code-range.last-code  = 1000000000 * 2
          dst.code-range.db-num = p-db-num
          dst.code-range.stts = "a":U
        .
        create dst.code-range.
        assign
          dst.code-range.range-type = 'fmgb':U
          dst.code-range.PS         = "FOR ERP"
          dst.code-range.beg-date   = today
          dst.code-range.first-code = 1
          dst.code-range.last-code  = 999999999
          dst.code-range.db-num = p-db-num
          dst.code-range.stts = "a":U
        .
        create dst.code-range.
        assign
          dst.code-range.range-type = 'pngb':U
          dst.code-range.PS         = "FOR ERP"
          dst.code-range.beg-date   = today
          dst.code-range.first-code = 1
          dst.code-range.last-code  = 999999999
          dst.code-range.db-num = p-db-num
          dst.code-range.stts = "a":U
        .
        create dst.code-range.
        assign
          dst.code-range.range-type = 'fdgb':U
          dst.code-range.PS         = "FOR ERP"
          dst.code-range.beg-date   = today
          dst.code-range.first-code = 1
          dst.code-range.last-code  = 999999999
          dst.code-range.db-num = p-db-num
          dst.code-range.stts = "a":U
        .
        create dst.code-range.
        assign
          dst.code-range.range-type = 'ctgb':U
          dst.code-range.PS         = "FOR ERP"
          dst.code-range.beg-date   = today
          dst.code-range.first-code = 1
          dst.code-range.last-code  = 999999999
          dst.code-range.db-num = p-db-num
          dst.code-range.stts = "a":U
        .
        create dst.code-range.
        assign
          dst.code-range.range-type = 'drgb':U
          dst.code-range.PS         = "FOR ERP"
          dst.code-range.beg-date   = today
          dst.code-range.first-code = 1
          dst.code-range.last-code  = 999999999
          dst.code-range.db-num = p-db-num
          dst.code-range.stts = "a":U
        .
        for each src.code-range where src.code-range.db-num = 0 and
            (src.code-range.range-type = 'sclc':U or
            src.code-range.range-type =  'sslc':U or
            src.code-range.range-type =  'pglc':U):
                create dst.code-range.
                buffer-copy src.code-range to dst.code-range .
        end.
        for each src.code-range where src.code-range.db-num = p-db-num and
            src.code-range.range-type =  'cagb':U :
                create dst.code-range.
                buffer-copy src.code-range to dst.code-range .
        end.
     end.
  end.
  output stream slog to rest-rdb.txt append .
  export stream slog "hist-nws-option":U cur-time-string() .
  output stream slog close .
  assign
    ind1 = 0
    fl = "hist-nws-option":U
    count-str = substitute( "Создание опции истории и маршрутизации" )
  .
  do with frame ddd
  :
    assign
      count-str :screen-value   = string( count-str, count-str :format)
      fl :screen-value          = string( fl, fl :format)
      ind1 :screen-value        = string( ind1, ind1 :format)
    .
  end.
  for each src.hist-nws-option no-lock
    where src.hist-nws-option.db-num = 0
  on error  undo, return error substitute( "&1 (hist-nws-option1). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (hist-nws-option1). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (hist-nws-option1). endkey", vss-workfile )
  :
    create dst.hist-nws-option .
    buffer-copy src.hist-nws-option to dst.hist-nws-option .
  end.
  for each src.hist-nws-option no-lock
    where src.hist-nws-option.db-num = p-db-num
  on error  undo, return error substitute( "&1 (hist-nws-option2). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (hist-nws-option2). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (hist-nws-option2). endkey", vss-workfile )
  :
    find first dst.hist-nws-option where
              dst.hist-nws-option.db-num = src.hist-nws-option.db-num
           and dst.hist-nws-option.hn-id = src.hist-nws-option.hn-id no-error.
    if not available dst.hist-nws-option then do:
      create dst.hist-nws-option .
      buffer-copy src.hist-nws-option to dst.hist-nws-option .
    end.
    else do:
      if dst.hist-nws-option.table-name <> src.hist-nws-option.table-name
      or dst.hist-nws-option.subject-group <> src.hist-nws-option.subject-group
      or dst.hist-nws-option.option-descr <> src.hist-nws-option.option-descr
      or dst.hist-nws-option.charkey_one <> src.hist-nws-option.charkey_one
      or dst.hist-nws-option.key#_one <> src.hist-nws-option.key#_one then do:
         buffer-copy src.hist-nws-option to dst.hist-nws-option .
      end.
    end.
  end.
  if ub.db.remote-stock = true then do:
    assign
      table-ref       = table-ref + ",prt-obj,db-status":U
      table-ref-where = table-ref-where + fill( chr(4), 2 )
      table-ref-if-cond  = table-ref-if-cond   + fill( chr(4), 2 )
    .
  end.
  else do:
    assign
      table-obj          = table-obj         + ",prt-obj":U
      table-obj-where    = table-obj-where   + chr(4)
      table-obj-if-cond  = table-obj-if-cond + fill( chr(4), 1 )
    .
  end.
  if ub.db.unload-arch = true then do:
    assign
      table-obj = table-obj + ",ot-line,ot-tot,stk-line,stk-tot,ot-supp-line,ot-supp-tot,stk-supp-line,stk-supp-tot":U
      table-obj-where = table-obj-where + fill(chr(4), 8)
      table-obj-if-cond = table-obj-if-cond + fill(chr(4), 8)
    .
  end.
  if ub.db.unload-aht = true then do:
    assign
      table-obj = table-obj + ",aht-ot-line,aht-ot-tot,aht-stk-line,aht-stk-tot,aht-stk,aht-doc":U
      table-obj-where = table-obj-where + fill(chr(4), 6)
      table-obj-if-cond = table-obj-if-cond + fill(chr(4), 6)
    .
  end.
  run prepare-tables in this-procedure ( input table-ref
                                        ,input table-ref-where
                                        ,input table-ref-if-cond
                                        ,input '':U
                                        ,input "ref"
                                        ,input p-unload-history
                                        ).
  run prepare-tables in this-procedure ( input table-obj
                                        ,input table-obj-where
                                        ,input table-obj-if-cond
                                        ,input '':U
                                        ,input "obj"
                                        ,input p-unload-history
                                        ).
  run prepare-tables in this-procedure ( input table-host-obj
                                        ,input table-host-obj-where
                                        ,input table-host-obj-if-cond
                                        ,input '':U
                                        ,input "host-obj"
                                        ,input p-unload-history
                                        ).
  run prepare-tables in this-procedure ( input table-xobj
                                        ,input table-xobj-where
                                        ,input table-xobj-if-cond
                                        ,input table-xobj-fields
                                        ,input "xobj"
                                        ,input p-unload-history
                                        ).
  run prepare-tables in this-procedure ( input table-firm-db
                                        ,input table-firm-db-where
                                        ,input table-firm-db-if-cond
                                        ,input '':U
                                        ,input "firm-db"
                                        ,input p-unload-history
                                        ).
  run prepare-tables in this-procedure ( input table-db
                                        ,input table-db-where
                                        ,input table-db-if-cond
                                        ,input '':U
                                        ,input "db"
                                        ,input p-unload-history
                                        ).
  run prepare-dc in this-procedure ( input p-db-num
                                    ,input p-unload-history
                                    ).
  output stream slog to rest-rdb.txt append .
  export stream slog "clear-tables":U cur-time-string() .
  output stream slog close .
  for each dst.sys-ctrl exclusive-lock
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  :
    delete dst.sys-ctrl .
  end.
  for each dst.gds-grp exclusive-lock
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  :
    delete dst.gds-grp .
  end.
  for each dst.cli-grp exclusive-lock
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  :
    delete dst.cli-grp .
  end.
  for each dst.gds-prt exclusive-lock
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  :
    delete dst.gds-prt .
  end.
  for each dst.db exclusive-lock
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  :
    delete dst.db .
  end.
  do with frame ddd
  on error  undo, return error substitute( "&1 (frame ddd). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (frame ddd). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (frame ddd). endkey", vss-workfile )
  :
    output stream slog to rest-rdb.txt append .
    export stream slog "route":U cur-time-string() .
    output stream slog close .
    assign
      ind1 = 0
      fl = "route":U
      count-str = "Удаление маршрутизации"
      v-new-route = false
    .
    if p-type-unload = 'unload-copy':U then do:
      on delete of src.route      override do: end.
      on delete of src.route-dump override do: end.
    end.
    for each ub.route exclusive-lock
       where ub.route.db-num    = p-db-num
       by ub.route.tbl-ord
    on error  undo, return error substitute( "&1 (ub.route). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (ub.route). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (ub.route). endkey", vss-workfile )
    :
      if ub.route.name-rec = "begins_unload_from_copy":U then do:
        assign
          v-new-route = true
        .
      end.
      assign
        ind1 = ind1 + 1
      .
      do with frame ddd
      :
        assign
          count-str :screen-value   = string( count-str, count-str :format)
          fl :screen-value          = string( fl, fl :format)
          ind1 :screen-value        = string( ind1, ind1 :format)
        .
      end.
      if p-type-unload = 'unload-copy':U
        and v-new-route = false
      then do:
        for each src.route exclusive-lock
          where src.route.db-num    = ub.route.db-num
            and src.route.tbl-ord   = ub.route.tbl-ord
        on error  undo, return error substitute( "&1 (src.route). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo, return error substitute( "&1 (src.route). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (src.route). endkey", vss-workfile )
        :
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_route           for src.route .
define buffer buf_route-dump      for src.route-dump .
define buffer buf_route-dump-link for src.route-dump-link .
define buffer buf_sys-ctrl        for src.sys-ctrl .
disable triggers for load of src.route-dump .
find first buf_sys-ctrl no-lock.
if buf_sys-ctrl.db-num = 0 then do:
  find first buf_route no-lock
    where buf_route.dump-ord = src.route.dump-ord
      and buf_route.db-num   > src.route.db-num
    no-error
  .
  if not available buf_route then do:
    find first buf_route no-lock
      where buf_route.dump-ord = src.route.dump-ord
        and buf_route.db-num   < src.route.db-num
      no-error
    .
  end.
end.
if buf_sys-ctrl.db-num <> 0
  or not available buf_route
then do:
  for each buf_route-dump-link
    where buf_route-dump-link.dump-ord = src.route.dump-ord
  on error undo, return error
  :
    delete buf_route-dump-link.
  end.
  for each buf_route-dump
    where buf_route-dump.dump-ord = src.route.dump-ord
  on error undo, return error
  :
    delete buf_route-dump.
  end.
end.
          delete src.route .
        end.
      end.
      delete ub.route .
    end.
    output stream slog to rest-rdb.txt append .
    export stream slog "pck-sent" cur-time-string() .
    output stream slog close .
    assign
      ind1 = 0
      fl = "pck-sent":U
      count-str = "":U
    .
    if p-type-unload <> 'unload-copy':U then do:
      find last ub.pck-sent share-lock
        where ub.pck-sent.db-num   = p-db-num
          and ub.pck-sent.pack-num > 0
        use-index pi
        no-error
      .
      if available ub.pck-sent then do:
        find first buf_pck-sent share-lock
          where buf_pck-sent.db-num = p-db-num
            and buf_pck-sent.pack-num = 0
          no-error .
        if available buf_pck-sent then do:
          do transaction
          on error  undo, return error substitute( "&1 (transaction_pck-sent). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
          on stop   undo, return error substitute( "&1 (transaction_pck-sent). stop", vss-workfile )
          on endkey undo, return error substitute( "&1 (transaction_pck-sent). endkey", vss-workfile )
          :
            for each ub.pck-sent-attr exclusive-lock
              where ub.pck-sent-attr.db-num   = buf_pck-sent.db-num
                and ub.pck-sent-attr.pack-num = buf_pck-sent.pack-num
            on error  undo, return error substitute( "&1 (pck-sent-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (pck-sent-attr). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (pck-sent-attr). endkey", vss-workfile )
            :
              delete ub.pck-sent-attr .
            end.
            delete buf_pck-sent .
            for each ub.pck-sent-attr exclusive-lock
              where ub.pck-sent-attr.db-num   = ub.pck-sent.db-num
                and ub.pck-sent-attr.pack-num = ub.pck-sent.pack-num
            on error  undo, return error substitute( "&1 (pck-sent-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (pck-sent-attr). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (pck-sent-attr). endkey", vss-workfile )
            :
              assign
                ub.pck-sent-attr.pack-num = 0
              .
            end.
            assign
              ub.pck-sent.pack-num = 0
            .
          end.
          for each ub.pck-sent exclusive-lock
            where ub.pck-sent.db-num   = p-db-num
              and ub.pck-sent.pack-num > 0
          on error  undo, return error substitute( "&1 (ub.pck-sent). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
          on stop   undo, return error substitute( "&1 (ub.pck-sent). stop", vss-workfile )
          on endkey undo, return error substitute( "&1 (ub.pck-sent). endkey", vss-workfile )
          :
            assign
              ind1 = ind1 + 1
            .
            do with frame ddd
            :
              assign
                count-str :screen-value   = string( count-str, count-str :format)
                fl :screen-value          = string( fl, fl :format)
                ind1 :screen-value        = string( ind1, ind1 :format)
              .
            end.
            for each ub.pck-sent-attr exclusive-lock
              where ub.pck-sent-attr.db-num   = ub.pck-sent.db-num
                and ub.pck-sent-attr.pack-num = ub.pck-sent.pack-num
            on error  undo, return error substitute( "&1 (pck-sent-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (pck-sent-attr). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (pck-sent-attr). endkey", vss-workfile )
            :
              delete ub.pck-sent-attr .
            end.
            delete ub.pck-sent .
          end.
        end.
      end.
    end.
    for each ub.pck-sent exclusive-lock
      where ub.pck-sent.db-num = p-db-num
    on error  undo, return error substitute( "&1 (ub.pck-sent). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (ub.pck-sent). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (ub.pck-sent). endkey", vss-workfile )
    :
      assign
        ind1 = ind1 + 1
      .
      do with frame ddd
      :
        assign
          count-str :screen-value   = string( count-str, count-str :format)
          fl :screen-value          = string( fl, fl :format)
          ind1 :screen-value        = string( ind1, ind1 :format)
        .
      end.
      create dst.pck-rcvd.
      buffer-copy ub.pck-sent to dst.pck-rcvd
        assign
          dst.pck-rcvd.db-num     = 0
          dst.pck-rcvd.rcvd-recs  = ub.pck-sent.total-recs
          dst.pck-rcvd.rcvd       = yes
        .
      if p-type-unload = 'unload-copy':U then do:
        find first src.pck-sent exclusive-lock
          where src.pck-sent.db-num   = ub.pck-sent.db-num
            and src.pck-sent.pack-num = ub.pck-sent.pack-num
        .
        assign
          src.pck-sent.rcvd = yes
        .
      end.
    end.
    output stream slog to rest-rdb.txt append .
    export stream slog "pck-rcvd":U cur-time-string() .
    output stream slog close .
    assign
      ind1 = 0
      fl = "pck-rcvd":U
      count-str = "":U
    .
    if p-type-unload <> 'unload-copy':U then do:
      find last ub.pck-rcvd share-lock
        where ub.pck-rcvd.db-num   = p-db-num
          and ub.pck-rcvd.pack-num > 0
        use-index pi
        no-error
      .
      if available ub.pck-rcvd then do:
        find first buf_pck-rcvd share-lock
          where buf_pck-rcvd.db-num = p-db-num
            and buf_pck-rcvd.pack-num = 0
          no-error .
        if available buf_pck-rcvd then do:
          do transaction
          on error  undo, return error substitute( "&1 (transaction_pck-rcvd). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
          on stop   undo, return error substitute( "&1 (transaction_pck-rcvd). stop", vss-workfile )
          on endkey undo, return error substitute( "&1 (transaction_pck-rcvd). endkey", vss-workfile )
          :
            for each ub.pck-rcvd-attr exclusive-lock
              where ub.pck-rcvd-attr.db-num   = buf_pck-rcvd.db-num
                and ub.pck-rcvd-attr.pack-num = buf_pck-rcvd.pack-num
            on error  undo, return error substitute( "&1 (pck-rcvd-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (pck-rcvd-attr). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (pck-rcvd-attr). endkey", vss-workfile )
            :
              delete ub.pck-rcvd-attr .
            end.
            delete buf_pck-rcvd .
            for each ub.pck-rcvd-attr exclusive-lock
              where ub.pck-rcvd-attr.db-num   = ub.pck-rcvd.db-num
                and ub.pck-rcvd-attr.pack-num = ub.pck-rcvd.pack-num
            on error  undo, return error substitute( "&1 (pck-rcvd-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (pck-rcvd-attr). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (pck-rcvd-attr). endkey", vss-workfile )
            :
              assign
                ub.pck-rcvd-attr.pack-num = 0
              .
            end.
            assign
              ub.pck-rcvd.pack-num = 0
            .
          end.
          for each ub.pck-rcvd exclusive-lock
            where ub.pck-rcvd.db-num   = p-db-num
              and ub.pck-rcvd.pack-num > 0
          on error  undo, return error substitute( "&1 (ub.pck-rcvd). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
          on stop   undo, return error substitute( "&1 (ub.pck-rcvd). stop", vss-workfile )
          on endkey undo, return error substitute( "&1 (ub.pck-rcvd). endkey", vss-workfile )
          :
            assign
              ind1 = ind1 + 1
            .
            do with frame ddd
            :
              assign
                count-str :screen-value   = string( count-str, count-str :format)
                fl :screen-value          = string( fl, fl :format)
                ind1 :screen-value        = string( ind1, ind1 :format)
      .
            end.
            for each ub.pck-rcvd-attr exclusive-lock
              where ub.pck-rcvd-attr.db-num   = ub.pck-rcvd.db-num
                and ub.pck-rcvd-attr.pack-num = ub.pck-rcvd.pack-num
            on error  undo, return error substitute( "&1 (pck-rcvd-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (pck-rcvd-attr). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (pck-rcvd-attr). endkey", vss-workfile )
            :
              delete ub.pck-rcvd-attr .
            end.
            delete ub.pck-rcvd .
          end.
        end.
      end.
    end.
    for each ub.pck-rcvd exclusive-lock
       where ub.pck-rcvd.db-num = p-db-num
    on error  undo, return error substitute( "&1 (ub.pck-rcvd). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (ub.pck-rcvd). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (ub.pck-rcvd). endkey", vss-workfile )
    :
      assign
        ind1 = ind1 + 1
      .
      do with frame ddd
      :
        assign
          count-str :screen-value   = string( count-str, count-str :format)
          fl :screen-value          = string( fl, fl :format)
          ind1 :screen-value        = string( ind1, ind1 :format)
        .
      end.
      create dst.pck-sent.
      buffer-copy ub.pck-rcvd to dst.pck-sent
        assign
          dst.pck-sent.db-num     = 0
          dst.pck-sent.rcvd       = yes
        .
      if p-type-unload = 'unload-copy':U then do:
        find first src.pck-rcvd exclusive-lock
          where src.pck-rcvd.db-num   = ub.pck-rcvd.db-num
            and src.pck-rcvd.pack-num = ub.pck-rcvd.pack-num
        .
        assign
          src.pck-rcvd.rcvd = yes
        .
      end.
    end.
    do transaction
    on error  undo, return error substitute( "&1 (sys-ctrl). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (sys-ctrl). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (sys-ctrl). endkey", vss-workfile )
    :
      output stream slog to rest-rdb.txt append .
      export stream slog "sys-ctrl":U cur-time-string() .
      output stream slog close .
      find first ub.sys-ctrl no-lock.
      find first dst.sys-ctrl no-error.
      if not available dst.sys-ctrl then do:
        create dst.sys-ctrl.
      end.
      assign
        dst.sys-ctrl.sys-date = today
        dst.sys-ctrl.db-num   = p-db-num
        dst.sys-ctrl.cut-date = ub.sys-ctrl.cut-date
        dst.sys-ctrl.sys-key  = ub.sys-ctrl.sys-key
        dst.sys-ctrl.language = ub.sys-ctrl.language
        dst.sys-ctrl.r-b      = ub.sys-ctrl.r-b
      .
    end.
define variable vss-include-info22 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run actn-gbl in g#library2
    ( output v-on-gbl
    ) no-error .
end.
    if v-on-gbl then do:
      output stream slog to rest-rdb.txt append .
      export stream slog "action-role":U cur-time-string() .
      output stream slog close .
      for each ub.action-role no-lock
        where ub.action-role.db-num = 0
      on error  undo, return error substitute( "&1 (action-role). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (action-role). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (action-role). endkey", vss-workfile )
      :
        create dst.action-role.
        buffer-copy ub.action-role to dst.action-role .
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "action-role-attr":U cur-time-string() .
      output stream slog close .
      for each ub.action-role-attr no-lock
        where ub.action-role-attr.db-num = 0
      on error  undo, return error substitute( "&1 (action-role-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (action-role-attr). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (action-role-attr). endkey", vss-workfile )
      :
        create dst.action-role-attr.
        buffer-copy ub.action-role-attr to dst.action-role-attr .
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "action-role-item":U cur-time-string() .
      output stream slog close .
      for each ub.action-role-item no-lock
        where ub.action-role-item.db-num = 0
      on error  undo, return error substitute( "&1 (action-role-item). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (action-role-item). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (action-role-item). endkey", vss-workfile )
      :
        create dst.action-role-item.
        buffer-copy ub.action-role-item to dst.action-role-item .
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "action-role-item-attr":U cur-time-string() .
      output stream slog close .
      for each ub.action-role-item-attr no-lock
        where ub.action-role-item-attr.db-num = 0
      on error  undo, return error substitute( "&1 (action-role-item-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (action-role-item-attr). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (action-role-item-attr). endkey", vss-workfile )
      :
        create dst.action-role-item-attr.
        buffer-copy ub.action-role-item-attr to dst.action-role-item-attr .
      end.
    end.
    for each buf_rrdb-option where
            buf_rrdb-option.dump-point = "ref"
            by buf_rrdb-option.dump-point by buf_rrdb-option.first-table-name
    on error  undo, return error substitute( "&1 (buf_rrdb-option.dump-point = ref). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (buf_rrdb-option.dump-point = ref). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (buf_rrdb-option.dump-point = ref). endkey", vss-workfile )
    :
      assign
      v-subject =  (if buf_rrdb-option.subject-group = "dc"
                    then buf_rrdb-option.des
                    else buf_rrdb-option.first-table-name)
      count-str = "Глобальные справочники"
      fl = v-subject
      .
      do with frame ddd
      :
        assign
          count-str :screen-value   = string( count-str, count-str :format)
          fl :screen-value          = string( fl, fl :format)
          ind1 :screen-value        = string( ind1, ind1 :format)
        .
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "table-ref-move":U v-subject cur-time-string() .
      output stream slog close .
      if buf_rrdb-option.first-table-name begins 'c-':U then do:
        assign
        v-hn = yes
        v-hn = get-hist-nws-option( input p-db-num
                                   ,input buf_rrdb-option.first-table-name)
        no-error .
      end.
      else do:
        v-hn = yes.
      end.
      if not v-hn then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "!!!SKIPPING other db  history records!!!!!" .
        output stream slog close .
      end.
      run adm/cred-tbl.p (
                         input this-procedure:handle
                        ,input p-db-num
                        ,input '':U
                        ,input 0
                        ,input 0
                        ,input count-str
                        ,input (buf_rrdb-option.first-table-name + "," +                          buf_rrdb-option.second-table-name + "," +                          buf_rrdb-option.third-table-name + "," +                          buf_rrdb-option.fourth-table-name + "," +                          buf_rrdb-option.fifth-table-name + "," +                          buf_rrdb-option.sixth-table-name)
                        ,input (string(buf_rrdb-option.first-table-export) + "," +                          string(buf_rrdb-option.second-table-export) + "," +                          string(buf_rrdb-option.third-table-export) + "," +                          string(buf_rrdb-option.fourth-table-export) + "," +                          string(buf_rrdb-option.fifth-table-export) + "," +                          string(buf_rrdb-option.sixth-table-export))
                        ,input buf_rrdb-option.where-phrase
                        ,input buf_rrdb-option.if-phrase
                        ,input buf_rrdb-option.if-buffer-num
                        ,input "ref"
                        ,input v-hn
                        ,input yes
                        ) .
      output stream slog to rest-rdb.txt append .
      export stream slog "OK ref" v-subject cur-time-string() .
      output stream slog close .
    end.
    for each buf_rrdb-option where buf_rrdb-option.dump-point = "db"
    on error  undo, return error substitute( "&1 (buf_rrdb-option.dump-point = db). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (buf_rrdb-option.dump-point = db). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (buf_rrdb-option.dump-point = db). endkey", vss-workfile )
    :
      assign
      v-subject =  (if buf_rrdb-option.subject-group = "dc"
                    then buf_rrdb-option.des
                    else buf_rrdb-option.first-table-name)
      count-str = "Справочники по БД"
      fl = v-subject
      .
      do with frame ddd
      :
        assign
          count-str :screen-value   = string( count-str, count-str :format)
          fl :screen-value          = string( fl, fl :format)
          ind1 :screen-value        = string( ind1, ind1 :format)
        .
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "table-db-move":U v-subject cur-time-string() .
      output stream slog close .
      if buf_rrdb-option.first-table-name begins 'c-':U then do:
        assign
        v-hn = yes
        v-hn = get-hist-nws-option( input p-db-num
                                    ,input buf_rrdb-option.first-table-name)
        no-error .
      end.
      else do:
        v-hn = yes.
      end.
      if not v-hn then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "!!!SKIPPING other db  history records!!!!!" .
        output stream slog close .
      end.
      run adm/cred-tbl.p (
                          input this-procedure:handle
                        ,input p-db-num
                        ,input '':U
                        ,input 0
                        ,input 0
                        ,input count-str
                        ,input (buf_rrdb-option.first-table-name + "," +                          buf_rrdb-option.second-table-name + "," +                          buf_rrdb-option.third-table-name + "," +                          buf_rrdb-option.fourth-table-name + "," +                          buf_rrdb-option.fifth-table-name + "," +                          buf_rrdb-option.sixth-table-name)
                        ,input (string(buf_rrdb-option.first-table-export) + "," +                          string(buf_rrdb-option.second-table-export) + "," +                          string(buf_rrdb-option.third-table-export) + "," +                          string(buf_rrdb-option.fourth-table-export) + "," +                          string(buf_rrdb-option.fifth-table-export) + "," +                          string(buf_rrdb-option.sixth-table-export))
                        ,input buf_rrdb-option.where-phrase
                        ,input buf_rrdb-option.if-phrase
                        ,input buf_rrdb-option.if-buffer-num
                        ,input "db"
                        ,input v-hn
                        ,input yes
                        ) .
      output stream slog to rest-rdb.txt append .
      export stream slog "OK df" v-subject cur-time-string() .
      output stream slog close .
    end.
    assign
    count-str = ""
    fl = ""
    .
    do with frame ddd
    :
      assign
        count-str :screen-value   = string( count-str, count-str :format)
        fl :screen-value          = string( fl, fl :format)
        ind1 :screen-value        = string( ind1, ind1 :format)
      .
    end.
    for each dst.user-login exclusive-lock
    on error  undo, return error substitute( "&1 (dst.user-login). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (dst.user-login). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (dst.user-login). endkey", vss-workfile )
    :
        if not can-find (first dst._user where dst._user._userid = dst.user-login.user-login no-lock) then do:
DEFINE TEMP-TABLE tempUser NO-UNDO LIKE
dst._User
.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    if dst.user-login.status_ = 0
    then do:
      find first dst.user-account
           where dst.user-account.user-id = dst.user-login.user-id
           no-lock
           no-error .
      if not available dst.user-account
      then do:
        create dst.user-account.
        assign
            dst.user-account.user-id               = dst.user-login.user-id
            dst.user-account.status_               = 0
            dst.user-account.first-name            = '':U
            dst.user-account.second-name           = '':U
            dst.user-account.last-name             = dst.user-login.user-login
            dst.user-account.nik                   = dst.user-login.user-login
            dst.user-account.company               = '':U
            dst.user-account.department            = '':U
            dst.user-account.e-mail                = '':U
            dst.user-account.internal-phone-number = '':U
            dst.user-account.mobile-phone-number   = '':U
            dst.user-account.phone-number          = '':U
            dst.user-account.position              = '':U
            dst.user-account.PS                    = '':U
            dst.user-account.room                  = '':U
            dst.user-account.parent-user-id        = '':U
            dst.user-account.check-parent          = false
        .
      end.
      else
         dst.user-login.status_ = dst.user-account.status_.
   end.
   if dst.user-login.status_ = 0
   then do:
      find first dst._user
           where dst._user._userid    = dst.user-login.user-login
           no-error
           .
      if not available dst._user then do:
         create dst._user .
         assign
            dst._user._userid    = dst.user-login.user-login
            dst._user._password  = dst.user-login.user-password-encoded
         .
      end.
      ELSE DO:
         BUFFER-COPY dst._User EXCEPT dst._User._Password dst._User._TenantId TO tempUser ASSIGN tempUser._Password = dst.user-login.user-password-encoded
         .
         DELETE dst._User.
         CREATE dst._User.
         BUFFER-COPY tempUser EXCEPT tempUser._TenantId TO _User.
      END.
      assign
        dst._user._user-name = substitute('&1 &2 &3'
                                        ,dst.user-account.last-name
                                        ,dst.user-account.first-name
                                        ,dst.user-account.second-name
                                        )
      .
      release _user.
    end.
        end.
    end.
    do transaction
    on error  undo, return error substitute( "&1 (user-login). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (user-login). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (user-login). endkey", vss-workfile )
    :
      disable triggers for load of ub.user-account.
      disable triggers for load of ub.user-login.
      disable triggers for load of src.user-account.
      disable triggers for load of src.user-login.
      find first dst.user-login exclusive-lock
        where dst.user-login.user-login = "адм"
        no-error .
      if available dst.user-login then do:
        find first dst.user-account exclusive-lock
          where dst.user-account.user-id = dst.user-login.user-id
          no-error
        .
        find first ub.user-account exclusive-lock
          where ub.user-account.user-id = dst.user-account.user-id
          no-error .
        find first ub.user-login exclusive-lock
          where ub.user-login.user-id = dst.user-login.user-id
            and ub.user-login.db-num  = dst.user-login.db-num
          no-error .
        if not available ub.user-account then do:
          create ub.user-account.
          buffer-copy dst.user-account to ub.user-account.
        end.
        if not available ub.user-login then do:
          create ub.user-login.
          buffer-copy dst.user-login to ub.user-login.
        end.
        if p-type-unload = 'unload-copy':U then do:
          find first src.user-account exclusive-lock
            where src.user-account.user-id = dst.user-account.user-id
            no-error .
          find first src.user-login exclusive-lock
            where src.user-login.user-id = dst.user-login.user-id
              and src.user-login.db-num  = dst.user-login.db-num
            no-error .
          if not available src.user-account then do:
            create src.user-account.
            buffer-copy dst.user-account to src.user-account.
          end.
          if not available src.user-login then do:
            create src.user-login.
            buffer-copy dst.user-login to src.user-login.
          end.
        end.
      end.
    end.
    run adm/restclna.p
      (input  p-db-num
      ,input  ub.db.unload-arch
      ,input  ub.db.unload-arch
      ,input  ub.db.unload-aht
      ) .
    assign
      ind1 = 0
      fl = "clob-data":U
    .
    output stream slog to rest-rdb.txt append .
    export stream slog "clob-data":U cur-time-string() .
    output stream slog close .
    define variable v-jj as integer no-undo .
    define variable v-entry as character no-undo .
    define variable lob-res-list as character no-undo .
    lob-res-list = 'gate':U + chr(44) + 'ref':U.
    do v-jj = 1 to num-entries(lob-res-list):
      v-entry = entry(v-jj, lob-res-list).
    for each dst.clob-bind no-lock
        where dst.clob-bind.resource-type = v-entry
      ,each src.clob-data no-lock
      where src.clob-data.db-num = dst.clob-bind.db-num
        and src.clob-data.int64-id = dst.clob-bind.int64-id
    on error  undo, return error substitute( "&1 (clob-data). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (clob-data). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (clob-data). endkey", vss-workfile )
    :
      if not can-find (first dst.clob-data no-lock
      where dst.clob-data.db-num = dst.clob-bind.db-num
        and dst.clob-data.int64-id = dst.clob-bind.int64-id)
      then do:
        create dst.clob-data .
        buffer-copy src.clob-data to dst.clob-data .
      end.
    end.
    end.
    lob-res-list = 'list':U + chr(44) + 'list-macro':U .
    do v-jj = 1 to num-entries(lob-res-list):
      v-entry = entry(v-jj, lob-res-list).
      for each src.clob-bind no-lock
        where src.clob-bind.resource-type = v-entry
        ,each src.clob-data no-lock
        where src.clob-data.db-num = dst.clob-bind.db-num
          and src.clob-data.int64-id = dst.clob-bind.int64-id
      on error  undo, return error substitute( "&1 (clob-data). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (clob-data). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (clob-data). endkey", vss-workfile )
      :
        if src.clob-data.is-cs = no then next.
        create dst.clob-data .
        buffer-copy src.clob-data to dst.clob-data .
        create dst.clob-bind .
        buffer-copy src.clob-bind to dst.clob-bind .
      end.
    end.
    lob-res-list = 'egais-ab':U + chr(44) + 'egais-awo':U
      + chr(44) + 'egais-ab_shop':U + chr(44) + 'egais-awo_shop':U
      + chr(44) + 'egais-wb':U + chr(44) + 'egais-ref-b':U + chr(44) + 'egais-wb-act':U + chr(44) + 'egais-ticket':U + chr(44) + 'egais-wb-ticket':U.
    do v-jj = 1 to num-entries(lob-res-list):
      v-entry = entry(v-jj, lob-res-list).
      for each src.clob-bind no-lock
        where src.clob-bind.resource-type = v-entry
        ,each src.clob-data no-lock
        where src.clob-data.db-num = dst.clob-bind.db-num
          and src.clob-data.int64-id = dst.clob-bind.int64-id
      on error  undo, return error substitute( "&1 (clob-data). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (clob-data). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (clob-data). endkey", vss-workfile )
      :
        if src.clob-data.is-cs = no then next.
        create dst.clob-data .
        buffer-copy src.clob-data to dst.clob-data .
        create dst.clob-bind .
        buffer-copy src.clob-bind to dst.clob-bind .
      end.
    end.
    output stream slog to rest-rdb.txt append .
    export stream slog "bar-code":U cur-time-string() .
    output stream slog close .
    assign
      ind1 = 0
      fl = "bar-code":U
    .
    for each ub.bar-code no-lock
    on error  undo, return error substitute( "&1 (ub.bar-code). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (ub.bar-code). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (ub.bar-code). endkey", vss-workfile )
    :
      assign
        ind1 = ind1 + 1
      .
      do with frame ddd
      :
        assign
          fl :screen-value   = string( fl, fl :format)
          ind1 :screen-value = string( ind1, ind1 :format)
        .
      end.
      create dst.bar-code.
      buffer-copy ub.bar-code to dst.bar-code.
      for each ub.prod-bc no-lock
         where ub.prod-bc.b-code = ub.bar-code.b-code
      on error  undo, return error substitute( "&1 (ub.prod-bc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (ub.prod-bc). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (ub.prod-bc). endkey", vss-workfile )
      :
        if ub.prod-bc.bc-on-type eq 'GTIN':U
        then
            l-prod-bc-global = yes.
        else do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  'global=request':u
  ,output l-prod-bc-global
  ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
            "Основной бар-код" ub.prod-bc.b-code skip
            "Дополнительный бар-код" ub.prod-bc.b-str skip
            "Действие global=request" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
        end.
        end.
        if l-prod-bc-global then do:
          create dst.prod-bc.
          buffer-copy ub.prod-bc to dst.prod-bc.
        end.
      end.
    end.
    if not mode-erprn then do:
       run cre-activ-code-range ( input p-db-num
                                 ,input 'bcgb':U
                                ) no-error.
       if error-status :error then do:
         message
           vss-workfile vss-revision vss-description skip
           "Ошибка при активизации диапазона собственных кодов товаров (бар-кодов)" skip
           error-status :get-message(1) skip
           return-value skip
           view-as alert-box error .
         undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
       end.
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input 'scgb':U
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона глобальных весовых кодов" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input 'sclc':U
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона локальных весовых кодов" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input 'pglc':U
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона локальных штучных кодов для весов" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input 'ssgb':U
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона глобальных взвешиваемых кодов" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input 'sslc':U
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона локальных взвешиваемых кодов" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input 'dcgb':U
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона кодов дисконтных карт" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input 'cagb':U
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона кодов точек привязки" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input 'ctgb':U
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона кодов договоров" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
    end.
    run cre-activ-code-range ( input p-db-num
                              ,input 'drgb':U
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона кодов правил скидок и расписаний" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
    end.
     run cre-activ-code-range ( input p-db-num
                              ,input 'fdgb':U
                             ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при активизации диапазона кодов фин документов" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
    end.
    if ub.db.remote-stock = no then do:
      output stream slog to rest-rdb.txt append .
      export stream slog "db-status" cur-time-string() .
      output stream slog close .
      for each ub.db-status no-lock
          where ub.db-status.db-num = p-db-num
      on error  undo, return error substitute( "&1 (ub.db-status). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (ub.db-status). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (ub.db-status). endkey", vss-workfile )
      :
        create dst.db-status.
        buffer-copy ub.db-status to dst.db-status.
      end.
    end.
    output stream slog to rest-rdb.txt append .
    export stream slog "ext-system":U cur-time-string() .
    output stream slog close .
    assign
      tot-cli-count = 0
    .
    run adm/restext.p (
          input this-procedure
        , input p-db-num
        , input p-unload-history
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка выгрузки внешней подсистемы для БД" p-db-num
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'ser-wth'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  NO
  ,output conf-par
  ,output par-type
  ) no-error .
    IF not error-status:error and conf-par = "yes":U then ser-wth-conf-par = yes.
    else ser-wth-conf-par = no.
    for each ub.clients no-lock
      where ub.clients.db-num = p-db-num
    on error  undo, return error substitute( "&1 (1 clients-all). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (1 clients-all). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (1 clients-all). endkey", vss-workfile )
    :
      assign
        tot-cli-count = tot-cli-count + 1
      .
    end.
    assign
      v-cli-count = 0
    .
    output stream slog to rest-rdb.txt append .
    export stream slog "start rest-season" cur-time-string() .
    output stream slog close .
    run rest-season in this-procedure
      ( input ""
       ,input ?
      )
      no-error
    .
    if error-status:error then do:
      output stream slog to rest-rdb.txt append .
      export stream slog
      "    !!!!rest-season"
      substitute( " &1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)) skip.
      output stream slog close .
      undo, return error  substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    else do:
      output stream slog to rest-rdb.txt append .
      export stream slog
      "OK rest-season"  skip.
      output stream slog close .
    end.
    output stream slog to rest-rdb.txt append .
      export stream slog "start CashBook " cur-time-string() .
      output stream slog close .
      run rest-cash-book in this-procedure
        no-error .
      if error-status :error then do:
        output stream slog to rest-rdb.txt append .
        export stream slog  error-status :get-message(1) return-value cur-time-string() .
        output stream slog close .
        return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
      end.
      else do:
         output stream slog to rest-rdb.txt append .
         export stream slog
         "OK CashBook"  skip.
         output stream slog close .
      end.
    for each ub.clients no-lock
      where ub.clients.db-num = p-db-num
    on error  undo, return error substitute( "&1 (clients-all). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (clients-all). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (clients-all). endkey", vss-workfile )
    :
      output stream slog to rest-rdb.txt append .
      export stream slog substitute("START &1&2 &3", ub.clients.obj-type, ub.clients.obj-code, cur-time-string() ).
      output stream slog close .
      assign
        v-cli-count = v-cli-count + 1
        count-str = "Обработано объектов" + chr(32) + string( v-cli-count ) + chr(32)
                    + "из" + chr(32) + string( tot-cli-count )
      .
      if ub.clients.obj-type = 'скл':U then do:
        find ub.store where ub.store.obj-code = ub.clients.obj-code no-lock.
        assign
          host = ub.store.host-code
        .
      end.
      else do:
        find ub.shop where ub.shop.obj-code = ub.clients.obj-code no-lock.
        assign
          host = ub.shop.host-code
        .
      end.
      if not can-find( first tt-host-list where tt-host-list.host-code = host no-lock ) then do:
        assign
          ind1 = 0
          fl = "cli-gds":U
        .
        for each ub.cli-gds no-lock
          where ub.cli-gds.host-code = host
        on error  undo, return error substitute( "&1 (ub.cli-gds). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo, return error substitute( "&1 (ub.cli-gds). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (ub.cli-gds). endkey", vss-workfile )
        :
          assign  ind1 = ind1 + 1.
          do with frame ddd
          :
            assign
              count-str :screen-value   = string( count-str, count-str :format)
              fl :screen-value          = string( fl, fl :format)
              ind1 :screen-value        = string( ind1, ind1 :format)
            .
          end.
          if not can-find( first dst.cli-gds no-lock
            where dst.cli-gds.cli-type  = ub.cli-gds.cli-type
              and dst.cli-gds.cli-code  = ub.cli-gds.cli-code
              and dst.cli-gds.host-code = ub.cli-gds.host-code
              and dst.cli-gds.artic     = ub.cli-gds.artic
              and dst.cli-gds.prod-type = ub.cli-gds.prod-type
              and dst.cli-gds.prod-code = ub.cli-gds.prod-code )
              then do:
            create dst.cli-gds.
            buffer-copy ub.cli-gds to dst.cli-gds.
          end.
        end.
        create tt-host-list.
        assign
          tt-host-list.host-code = host
        .
      end.
      for each buf_rrdb-option
        where buf_rrdb-option.dump-point = "obj"
      on error  undo, return error substitute( "&1 (buf_rrdb-option.dump-point = obj). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (buf_rrdb-option.dump-point = obj). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (buf_rrdb-option.dump-point = obj). endkey", vss-workfile )
      :
        assign
        v-subject =  (if buf_rrdb-option.subject-group = "dc"
                      then buf_rrdb-option.des
                      else buf_rrdb-option.first-table-name)
        count-str = "Справочники по объектам"
        fl = v-subject
        .
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        output stream slog to rest-rdb.txt append .
        export stream slog "table-obj-move" v-subject cur-time-string() .
        output stream slog close .
        if buf_rrdb-option.first-table-name begins 'c-':U then do:
          assign
          v-hn = yes
          v-hn = get-hist-nws-option( input p-db-num
                                      ,input buf_rrdb-option.first-table-name)
          no-error .
        end.
        else do:
          v-hn = yes.
        end.
        if not v-hn then do:
          output stream slog to rest-rdb.txt append .
          export stream slog "!!!SKIPPING other db  history records!!!!!" .
          output stream slog close .
        end.
        run adm/cred-tbl.p (
                           input this-procedure:handle
                          ,input p-db-num
                          ,input ub.clients.obj-type
                          ,input ub.clients.obj-code
                          ,input 0
                          ,input count-str
                          ,input (buf_rrdb-option.first-table-name + "," +                          buf_rrdb-option.second-table-name + "," +                          buf_rrdb-option.third-table-name + "," +                          buf_rrdb-option.fourth-table-name + "," +                          buf_rrdb-option.fifth-table-name + "," +                          buf_rrdb-option.sixth-table-name)
                          ,input (string(buf_rrdb-option.first-table-export) + "," +                          string(buf_rrdb-option.second-table-export) + "," +                          string(buf_rrdb-option.third-table-export) + "," +                          string(buf_rrdb-option.fourth-table-export) + "," +                          string(buf_rrdb-option.fifth-table-export) + "," +                          string(buf_rrdb-option.sixth-table-export))
                          ,input buf_rrdb-option.where-phrase
                          ,input buf_rrdb-option.if-phrase
                          ,input buf_rrdb-option.if-buffer-num
                          ,input "obj"
                          ,input v-hn
                          ,input yes
                          ) .
        output stream slog to rest-rdb.txt append .
        export stream slog "OK table-obj-move" v-subject cur-time-string() .
        output stream slog close .
      end.
      for each buf_rrdb-option
        where buf_rrdb-option.dump-point = "host-obj"
      on error  undo, return error substitute( "&1 (buf_rrdb-option.dump-point = obj). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (buf_rrdb-option.dump-point = obj). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (buf_rrdb-option.dump-point = obj). endkey", vss-workfile )
      :
        assign
        v-subject =  (if buf_rrdb-option.subject-group = "dc"
                      then buf_rrdb-option.des
                      else buf_rrdb-option.first-table-name)
        count-str = "Справочники по фирм-объектам"
        fl = v-subject
        .
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        output stream slog to rest-rdb.txt append .
        export stream slog "table-host-obj-move" v-subject cur-time-string() .
        output stream slog close .
        if buf_rrdb-option.first-table-name begins 'c-':U then do:
          assign
          v-hn = yes
          v-hn = get-hist-nws-option( input p-db-num
                                      ,input buf_rrdb-option.first-table-name)
          no-error .
        end.
        else do:
          v-hn = yes.
        end.
        if not v-hn then do:
          output stream slog to rest-rdb.txt append .
          export stream slog "!!!SKIPPING other db  history records!!!!!" .
          output stream slog close .
        end.
        run adm/cred-tbl.p (
                           input this-procedure:handle
                          ,input p-db-num
                          ,input ub.clients.obj-type
                          ,input ub.clients.obj-code
                          ,input ub.clients.host-code
                          ,input count-str
                          ,input (buf_rrdb-option.first-table-name + "," +                          buf_rrdb-option.second-table-name + "," +                          buf_rrdb-option.third-table-name + "," +                          buf_rrdb-option.fourth-table-name + "," +                          buf_rrdb-option.fifth-table-name + "," +                          buf_rrdb-option.sixth-table-name)
                          ,input (string(buf_rrdb-option.first-table-export) + "," +                          string(buf_rrdb-option.second-table-export) + "," +                          string(buf_rrdb-option.third-table-export) + "," +                          string(buf_rrdb-option.fourth-table-export) + "," +                          string(buf_rrdb-option.fifth-table-export) + "," +                          string(buf_rrdb-option.sixth-table-export))
                          ,input buf_rrdb-option.where-phrase
                          ,input buf_rrdb-option.if-phrase
                          ,input buf_rrdb-option.if-buffer-num
                          ,input "host-obj"
                          ,input v-hn
                          ,input yes
                          ) .
        output stream slog to rest-rdb.txt append .
        export stream slog "OK table-host-obj-move" v-subject cur-time-string() .
        output stream slog close .
      end.
      for each buf_rrdb-option
        where buf_rrdb-option.dump-point = "Xobj"
      on error  undo, return error substitute( "&1 (buf_rrdb-option.dump-point = Xobj). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (buf_rrdb-option.dump-point = Xobj). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (buf_rrdb-option.dump-point = Xobj). endkey", vss-workfile )
      :
        assign
        v-subject =  (if buf_rrdb-option.subject-group = "dc"
                      then buf_rrdb-option.des
                      else buf_rrdb-option.first-table-name)
        count-str = "Справочники по объектам"
        fl = v-subject
        .
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        output stream slog to rest-rdb.txt append .
        export stream slog "table-Xobj-move" v-subject cur-time-string() .
        output stream slog close .
        if buf_rrdb-option.first-table-name begins 'c-':U then do:
          assign
          v-hn = yes
          v-hn = get-hist-nws-option( input p-db-num
                                      ,input buf_rrdb-option.first-table-name)
          no-error .
        end.
        else do:
          v-hn = yes.
        end.
        if not v-hn then do:
          output stream slog to rest-rdb.txt append .
          export stream slog "!!!SKIPPING other db  history records!!!!!" .
          output stream slog close .
        end.
        run adm/cred-tbl.p (
                            input this-procedure:handle
                          ,input p-db-num
                          ,input ub.clients.obj-type
                          ,input ub.clients.obj-code
                          ,input 0
                          ,input count-str
                          ,input (buf_rrdb-option.first-table-name + "," +                          buf_rrdb-option.second-table-name + "," +                          buf_rrdb-option.third-table-name + "," +                          buf_rrdb-option.fourth-table-name + "," +                          buf_rrdb-option.fifth-table-name + "," +                          buf_rrdb-option.sixth-table-name)
                          ,input (string(buf_rrdb-option.first-table-export) + "," +                          string(buf_rrdb-option.second-table-export) + "," +                          string(buf_rrdb-option.third-table-export) + "," +                          string(buf_rrdb-option.fourth-table-export) + "," +                          string(buf_rrdb-option.fifth-table-export) + "," +                          string(buf_rrdb-option.sixth-table-export))
                          ,input buf_rrdb-option.where-phrase
                          ,input buf_rrdb-option.if-phrase
                          ,input buf_rrdb-option.if-buffer-num
                          ,input "Xobj"
                          ,input v-hn
                          ,input yes
                          ) .
        output stream slog to rest-rdb.txt append .
        export stream slog "OK Xobj" v-subject cur-time-string() .
        output stream slog close .
      end.
      if ub.clients.obj-type = 'маг':U then do:
        do transaction
        on error  undo, return error substitute( "&1 (dst.curr-shop). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo, return error substitute( "&1 (dst.curr-shop). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (dst.curr-shop). endkey", vss-workfile )
        :
          create dst.curr-shop.
          assign
            dst.curr-shop.curr-code = 0
            dst.curr-shop.exch-date = today
            dst.curr-shop.exch-rate = 1
            dst.curr-shop.exch-scale = 1
            dst.curr-shop.exch-time = time
            dst.curr-shop.obj-code = ub.clients.obj-code
            dst.curr-shop.obj-type = 'маг':U.
        end.
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-price-doc " cur-time-string() .
      output stream slog close .
      run rest-price-doc in this-procedure
        ( input ub.clients.obj-type
         ,input ub.clients.obj-code
        )  no-error.
      .
      if error-status:error then do:
        output stream slog to rest-rdb.txt append .
        export stream slog
        "    !!!!rest-price-doc"
        substitute( " &1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)) skip.
        output stream slog close .
        undo, return error  substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
      end.
      else do:
        output stream slog to rest-rdb.txt append .
        export stream slog
        "OK rest-price-doc"  skip.
        output stream slog close .
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-price-all " cur-time-string() .
      output stream slog close .
      run rest-price-all in this-procedure
        ( input ub.clients.obj-type
         ,input ub.clients.obj-code
        )  no-error.
      .
      if error-status:error then do:
        output stream slog to rest-rdb.txt append .
        export stream slog
        "    !!!!rest-price-all"
        substitute( " &1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)) skip.
        output stream slog close .
        undo, return error  substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
      end.
      else do:
        output stream slog to rest-rdb.txt append .
        export stream slog
        "OK rest-price-all"  skip.
        output stream slog close .
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start parts-free " cur-time-string() .
      output stream slog close .
      assign ind1 = 0
             fl   = "parts-free".
      for each ub.parts no-lock
        where ub.parts.obj-type = ub.clients.obj-type
          and ub.parts.obj-code = ub.clients.obj-code
          and ub.parts.out-code = 'free-zone':U
      on error  undo, return error substitute( "&1 (parts-free). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (parts-free). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (parts-free). endkey", vss-workfile )
      :
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        run process-parts in this-procedure .
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start parts-out " cur-time-string() .
      output stream slog close .
      assign ind1 = 0
             fl   = "parts-out".
      for each ub.parts no-lock
        where ub.parts.obj-type = ub.clients.obj-type
          and ub.parts.obj-code = ub.clients.obj-code
          and ub.parts.out-code = 'out-zone':U
      on error  undo, return error substitute( "&1 (parts-out). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (parts-out). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (parts-out). endkey", vss-workfile )
      :
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        run process-parts in this-procedure .
      end.
      assign ind1 = 0
             fl   = "parts-obj-attr".
      for each ub.parts-obj-attr no-lock
        where ub.parts-obj-attr.obj-type = ub.clients.obj-type
          and ub.parts-obj-attr.obj-code = ub.clients.obj-code
      on error  undo, return error substitute( "&1 (parts-obj-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (parts-obj-attr). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (parts-obj-attr). endkey", vss-workfile )
      :
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        create dst.parts-obj-attr.
        buffer-copy ub.parts-obj-attr to dst.parts-obj-attr.
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-trn-doc " cur-time-string() .
      output stream slog close .
      run rest-trn-doc in this-procedure
        ( input ub.clients.obj-type
         ,input ub.clients.obj-code
        )
        no-error
      .
      if error-status :error then do:
          output stream slog to rest-rdb.txt append .
          export stream slog  error-status :get-message(1) return-value cur-time-string() .
          output stream slog close .
          return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
      end.
      if p-unload-history then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "start rest-c-trn-doc " cur-time-string() .
        output stream slog close .
        run rest-c-trn-doc in this-procedure
          ( input ub.clients.obj-type
          ,input ub.clients.obj-code
          )
          no-error
        .
        if error-status :error then do:
            output stream slog to rest-rdb.txt append .
            export stream slog  error-status :get-message(1) return-value cur-time-string() .
            output stream slog close .
            return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
        end.
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-Utd " cur-time-string() .
      output stream slog close .
      run rest-Utd in this-procedure
        ( input ub.clients.obj-type
         ,input ub.clients.obj-code
        )
        no-error
      .
      if error-status :error then do:
          output stream slog to rest-rdb.txt append .
          export stream slog  error-status :get-message(1) return-value cur-time-string() .
          output stream slog close .
          return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-inkas " cur-time-string() .
      output stream slog close .
      run rest-inkas in this-procedure
        ( input ub.clients.obj-type
         ,input ub.clients.obj-code
        ) no-error .
      if error-status :error then do:
        return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
      end.
      if p-unload-history then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "start rest-c-inkas " cur-time-string() .
        output stream slog close .
        run rest-c-inkas in this-procedure
          ( input ub.clients.obj-type
          ,input ub.clients.obj-code
          )
        .
      end.
      if not ser-wth-conf-par then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "start rest-wth-doc " cur-time-string() .
        output stream slog close .
        run rest-wth-doc in this-procedure
          ( input ub.clients.obj-type
          ,input ub.clients.obj-code
          )
        .
        if p-unload-history then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "start rest-c-wth-doc " cur-time-string() .
        output stream slog close .
        run rest-c-wth-doc in this-procedure
          ( input ub.clients.obj-type
          ,input ub.clients.obj-code
          )
        .
        end.
      end.
        output stream slog to rest-rdb.txt append .
        export stream slog "start rest-fin-doc " cur-time-string() .
        output stream slog close .
        run rest-fin-doc in this-procedure
          ( input ub.clients.obj-type
          ,input ub.clients.obj-code
          )
        .
        if p-unload-history then do:
          output stream slog to rest-rdb.txt append .
          export stream slog "start rest-c-fin-doc " cur-time-string() .
          output stream slog close .
          run rest-c-fin-doc in this-procedure
            ( input ub.clients.obj-type
            ,input ub.clients.obj-code
            )
          .
        end.
      if ub.clients.obj-type = 'маг':U then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "start rest-chk " cur-time-string() .
        output stream slog close .
        run rest-chk in this-procedure
          ( input ub.clients.obj-type
          ,input ub.clients.obj-code
          )
        .
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-arh-wth-tot " cur-time-string() .
      output stream slog close .
      run rest-arh-wth-tot in this-procedure
          ( input ub.clients.obj-type
          ,input ub.clients.obj-code
          )
      .
      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-arh-wth-w-p " cur-time-string() .
      output stream slog close .
      run rest-arh-wth-w-p in this-procedure
          ( input ub.clients.obj-type
          ,input ub.clients.obj-code
          )
      .
      output stream slog to rest-rdb.txt append .
      export stream slog "start fbr-doc " cur-time-string() .
      output stream slog close .
      assign ind1 = 0
             fl   = "fbr-doc".
      for each ub.fbr-doc no-lock
          where ub.fbr-doc.obj-type = ub.clients.obj-type
            and ub.fbr-doc.obj-code = ub.clients.obj-code
      on error  undo, return error substitute( "&1 (fbr-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (fbr-doc). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (fbr-doc). endkey", vss-workfile )
      :
        for each ub.fbr-line no-lock
            where ub.fbr-line.doc-code = ub.fbr-doc.doc-code
        on error  undo, return error substitute( "&1 (fbr-line). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo, return error substitute( "&1 (fbr-line). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (fbr-line). endkey", vss-workfile )
        :
          create dst.fbr-line.
          buffer-copy ub.fbr-line to dst.fbr-line no-error.
        end.
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        create dst.fbr-doc.
        buffer-copy  ub.fbr-doc to dst.fbr-doc.
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start fbr-pln " cur-time-string() .
      output stream slog close .
      assign ind1 = 0
             fl   = "fbr-pln".
      for each ub.fbr-pln no-lock
          where ub.fbr-pln.obj-type = ub.clients.obj-type
            and ub.fbr-pln.obj-code = ub.clients.obj-code
      on error  undo, return error substitute( "&1 (fbr-pln). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (fbr-pln). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (fbr-pln). endkey", vss-workfile )
      :
        for each ub.fbr-pln-line no-lock
            where ub.fbr-pln-line.doc-code = ub.fbr-pln.doc-code
        on error  undo, return error substitute( "&1 (fbr-pln-line). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo, return error substitute( "&1 (fbr-pln-line). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (fbr-pln-line). endkey", vss-workfile )
        :
          create dst.fbr-pln-line.
          buffer-copy ub.fbr-pln-line to dst.fbr-pln-line no-error.
        end.
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        create dst.fbr-pln.
        buffer-copy  ub.fbr-pln to dst.fbr-pln.
      end.
      if p-unload-history then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "start c-fbr-pln " cur-time-string() .
        output stream slog close .
        assign ind1 = 0
              fl   = "c-fbr-pln".
        for each ub.c-fbr-pln no-lock
            where ub.c-fbr-pln.obj-type = ub.clients.obj-type
              and ub.c-fbr-pln.obj-code = ub.clients.obj-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          for each ub.c-fbr-pln-line no-lock
              where ub.c-fbr-pln-line.doc-code = ub.c-fbr-pln.doc-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-fbr-pln-line.
            buffer-copy ub.c-fbr-pln-line to dst.c-fbr-pln-line no-error.
          end.
          assign  ind1 = ind1 + 1.
          do with frame ddd
          :
            assign
              count-str :screen-value   = string( count-str, count-str :format)
              fl :screen-value          = string( fl, fl :format)
              ind1 :screen-value        = string( ind1, ind1 :format)
            .
          end.
          create dst.c-fbr-pln.
          buffer-copy  ub.c-fbr-pln to dst.c-fbr-pln.
        end.
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start rvs-doc " cur-time-string() .
      output stream slog close .
      assign ind1 = 0
             fl   = "rvs-doc".
      for each ub.rvs-doc no-lock
          where ub.rvs-doc.obj-type = ub.clients.obj-type
            and ub.rvs-doc.obj-code = ub.clients.obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        for each ub.rvs-line no-lock
            where ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.rvs-line.
          buffer-copy ub.rvs-line to dst.rvs-line no-error.
        end.
        for each ub.rvs-line-pump no-lock
            where ub.rvs-line-pump.rvs-code = ub.rvs-doc.rvs-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.rvs-line-pump.
          buffer-copy ub.rvs-line-pump to dst.rvs-line-pump no-error.
        end.
        for each ub.rvs-pump no-lock
            where ub.rvs-pump.rvs-code = ub.rvs-doc.rvs-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.rvs-pump.
          buffer-copy ub.rvs-pump to dst.rvs-pump no-error.
        end.
        for each ub.doc-attr no-lock
            where ub.doc-attr.doc-code = ub.rvs-doc.rvs-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.doc-attr.
          buffer-copy ub.doc-attr to dst.doc-attr no-error.
        end.
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        create dst.rvs-doc.
        buffer-copy  ub.rvs-doc to dst.rvs-doc.
      end.
      if p-unload-history then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "start c-rvs-doc " cur-time-string() .
        output stream slog close .
        assign ind1 = 0
              fl   = "c-rvs-doc".
        for each ub.c-rvs-doc no-lock
            where ub.c-rvs-doc.obj-type = ub.clients.obj-type
              and ub.c-rvs-doc.obj-code = ub.clients.obj-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          for each ub.c-rvs-line no-lock
              where ub.c-rvs-line.rvs-code         = ub.c-rvs-doc.rvs-code
                and ub.c-rvs-line.corr-user-db-num = ub.c-rvs-doc.corr-user-db-num
                and ub.c-rvs-line.chip-num         = ub.c-rvs-doc.chip-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-rvs-line.
            buffer-copy ub.c-rvs-line to dst.c-rvs-line .
          end.
          for each ub.c-rvs-line-pump no-lock
              where ub.c-rvs-line-pump.rvs-code         = ub.c-rvs-doc.rvs-code
                and ub.c-rvs-line-pump.corr-user-db-num = ub.c-rvs-doc.corr-user-db-num
                and ub.c-rvs-line-pump.chip-num         = ub.c-rvs-doc.chip-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-rvs-line-pump.
            buffer-copy ub.c-rvs-line-pump to dst.c-rvs-line-pump .
          end.
          for each ub.c-doc-attr no-lock
              where ub.c-doc-attr.doc-code         = ub.c-rvs-doc.rvs-code
                and ub.c-doc-attr.corr-user-db-num = ub.c-rvs-doc.corr-user-db-num
                and ub.c-doc-attr.chip-num         = ub.c-rvs-doc.chip-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-doc-attr.
            buffer-copy ub.c-doc-attr to dst.c-doc-attr .
          end.
          assign  ind1 = ind1 + 1.
          do with frame ddd
          :
            assign
              count-str :screen-value   = string( count-str, count-str :format)
              fl :screen-value          = string( fl, fl :format)
              ind1 :screen-value        = string( ind1, ind1 :format)
            .
          end.
          create dst.c-rvs-doc.
          buffer-copy ub.c-rvs-doc to dst.c-rvs-doc.
        end.
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start icnt-doc " cur-time-string() .
      output stream slog close .
      assign ind1 = 0
             fl   = "icnt-doc".
      for each ub.icnt-doc no-lock
          where ub.icnt-doc.obj-type = ub.clients.obj-type
            and ub.icnt-doc.obj-code = ub.clients.obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        for each ub.icnt-line no-lock
            where ub.icnt-line.doc-code = ub.icnt-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.icnt-line.
          buffer-copy ub.icnt-line to dst.icnt-line no-error.
        end.
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        create dst.icnt-doc.
        buffer-copy  ub.icnt-doc to dst.icnt-doc.
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start ord-doc " cur-time-string() .
      output stream slog close .
      assign ind1 = 0
             fl   = "ord-doc".
      for each ub.ord-doc no-lock
           where (ub.ord-doc.obj-type = ub.clients.obj-type
              and ub.ord-doc.obj-code = ub.clients.obj-code)
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
       if can-find (first dst.ord-doc no-lock
            where dst.ord-doc.doc-code = ub.ord-doc.doc-code ) then next.
        for each ub.ord-line no-lock
            where ub.ord-line.doc-code = ub.ord-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.ord-line.
          buffer-copy ub.ord-line to dst.ord-line no-error.
        end.
        for each ub.ord-dtl no-lock
            where ub.ord-dtl.doc-code = ub.ord-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.ord-dtl.
          buffer-copy ub.ord-dtl to dst.ord-dtl no-error.
        end.
        if ub.ord-doc.whole-send-news > 0 then do:
          for each ub.edi-status no-lock
            where ub.edi-status.tbl-name = 'ord-doc':U
              and  ub.edi-status.doc-code = ub.ord-doc.doc-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.edi-status.
            buffer-copy ub.edi-status to dst.edi-status no-error.
          end.
          for each ub.edi-status no-lock
            where ub.edi-status.tbl-name = 'ord-line':U
              and  ub.edi-status.doc-code begins (ub.ord-doc.doc-code + chr(4))
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.edi-status.
            buffer-copy ub.edi-status to dst.edi-status no-error.
          end.
        end.
        if not can-find( first dst.ord-cons no-lock
            where dst.ord-cons.cons-code = ub.ord-doc.cons-code )
        then do:
              for each ub.ord-cons no-lock
                  where ub.ord-cons.cons-code = ub.ord-doc.cons-code
              on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
              :
                create dst.ord-cons.
                buffer-copy ub.ord-cons to dst.ord-cons no-error.
                for each ub.ord-gds-cons no-lock
                    where ub.ord-gds-cons.cons-code = ub.ord-cons.cons-code
                on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
                :
                  create dst.ord-gds-cons.
                  buffer-copy ub.ord-gds-cons to dst.ord-gds-cons no-error.
                end.
                for each ub.ord-dtl-cons no-lock
                    where ub.ord-dtl-cons.cons-code = ub.ord-cons.cons-code
                on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
                :
                  create dst.ord-dtl-cons.
                  buffer-copy ub.ord-dtl-cons to dst.ord-dtl-cons no-error.
                end.
              end.
        end.
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        create dst.ord-doc.
        buffer-copy  ub.ord-doc to dst.ord-doc.
      end.
      for each ub.ord-doc no-lock
           where (ub.ord-doc.cli-type = ub.clients.obj-type
              and ub.ord-doc.cli-code = ub.clients.obj-code)
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
       if can-find (first dst.ord-doc no-lock
            where dst.ord-doc.doc-code = ub.ord-doc.doc-code ) then next.
        for each ub.ord-line no-lock
            where ub.ord-line.doc-code = ub.ord-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.ord-line.
          buffer-copy ub.ord-line to dst.ord-line no-error.
        end.
        for each ub.ord-dtl no-lock
            where ub.ord-dtl.doc-code = ub.ord-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.ord-dtl.
          buffer-copy ub.ord-dtl to dst.ord-dtl no-error.
        end.
        if ub.ord-doc.whole-send-news > 0 then do:
          for each ub.edi-status no-lock
            where ub.edi-status.tbl-name = 'ord-doc':U
              and  ub.edi-status.doc-code = ub.ord-doc.doc-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.edi-status.
            buffer-copy ub.edi-status to dst.edi-status no-error.
          end.
          for each ub.edi-status no-lock
            where ub.edi-status.tbl-name = 'ord-line':U
              and  ub.edi-status.doc-code begins (ub.ord-doc.doc-code + chr(4))
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.edi-status.
            buffer-copy ub.edi-status to dst.edi-status no-error.
          end.
        end.
        if not can-find( first dst.ord-cons no-lock
            where dst.ord-cons.cons-code = ub.ord-doc.cons-code )
        then do:
              for each ub.ord-cons no-lock
                  where ub.ord-cons.cons-code = ub.ord-doc.cons-code
              on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
              :
                create dst.ord-cons.
                buffer-copy ub.ord-cons to dst.ord-cons no-error.
                for each ub.ord-gds-cons no-lock
                    where ub.ord-gds-cons.cons-code = ub.ord-cons.cons-code
                on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
                :
                  create dst.ord-gds-cons.
                  buffer-copy ub.ord-gds-cons to dst.ord-gds-cons no-error.
                end.
                for each ub.ord-dtl-cons no-lock
                    where ub.ord-dtl-cons.cons-code = ub.ord-cons.cons-code
                on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
                :
                  create dst.ord-dtl-cons.
                  buffer-copy ub.ord-dtl-cons to dst.ord-dtl-cons no-error.
                end.
              end.
        end.
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        create dst.ord-doc.
        buffer-copy  ub.ord-doc to dst.ord-doc.
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start ord-doc-rcv " cur-time-string() .
      output stream slog close .
      assign ind1 = 0
             fl   = "ord-doc-rcv".
      for each ub.ord-doc-rcv no-lock
          where (ub.ord-doc-rcv.obj-type = ub.clients.obj-type
            and ub.ord-doc-rcv.obj-code = ub.clients.obj-code ) or
              ( ub.ord-doc-rcv.cli-type = ub.clients.obj-type
            and ub.ord-doc-rcv.cli-code = ub.clients.obj-code )
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
       if can-find (first dst.ord-doc-rcv no-lock
            where dst.ord-doc-rcv.doc-code = ub.ord-doc-rcv.doc-code
              and dst.ord-doc-rcv.rcv-code = ub.ord-doc-rcv.rcv-code)
              then next.
        for each ub.ord-line-rcv no-lock
            where ub.ord-line-rcv.doc-code = ub.ord-doc-rcv.doc-code
              and ub.ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.ord-line-rcv.
          buffer-copy ub.ord-line-rcv to dst.ord-line-rcv no-error.
        end.
        for each ub.ord-chain no-lock
            where ub.ord-chain.doc-code = ub.ord-doc-rcv.rcv-code
              and ub.ord-chain.doc-type = "rcv"
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.ord-chain.
          buffer-copy ub.ord-chain to dst.ord-chain no-error.
        end.
        for each ub.ord-dtl-rcv no-lock
            where ub.ord-dtl-rcv.doc-code = ub.ord-doc-rcv.doc-code
              and ub.ord-dtl-rcv.rcv-code = ub.ord-doc-rcv.rcv-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.ord-dtl-rcv.
          buffer-copy ub.ord-dtl-rcv to dst.ord-dtl-rcv no-error.
        end.
        if ub.ord-doc-rcv.whole-send-news > 0 then do:
          for each ub.edi-status no-lock
            where ub.edi-status.tbl-name = 'ord-doc-rcv':U
              and  ub.edi-status.doc-code = ub.ord-doc-rcv.rcv-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.edi-status.
            buffer-copy ub.edi-status to dst.edi-status no-error.
          end.
          for each ub.edi-status no-lock
            where ub.edi-status.tbl-name = 'ord-line-rcv':U
              and  ub.edi-status.doc-code begins (ub.ord-doc-rcv.rcv-code + chr(4))
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.edi-status.
            buffer-copy ub.edi-status to dst.edi-status no-error.
          end.
        end.
        assign  ind1 = ind1 + 1.
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        create dst.ord-doc-rcv.
        buffer-copy  ub.ord-doc-rcv to dst.ord-doc-rcv.
      end.
      if ub.db.unload-aht = true then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "start aht-time " cur-time-string() .
        output stream slog close .
        assign ind1 = 0
               fl   = "aht-time".
        for each ub.aht-time no-lock
            where ub.aht-time.obj-type = ub.clients.obj-type
              and ub.aht-time.obj-code = ub.clients.obj-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          assign  ind1 = ind1 + 1.
          do with frame ddd
          :
            assign
              count-str :screen-value   = string( count-str, count-str :format)
              fl :screen-value          = string( fl, fl :format)
              ind1 :screen-value        = string( ind1, ind1 :format)
            .
          end.
          create dst.aht-time.
          buffer-copy  ub.aht-time to dst.aht-time .
          for each ub.aht-gds no-lock
              where ub.aht-gds.aht-time-code = ub.aht-time.aht-time-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.aht-gds.
            buffer-copy ub.aht-gds to dst.aht-gds .
          end.
        end.
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start obj-date " cur-time-string() .
      output stream slog close .
      if not can-find (first dst.obj-date no-lock
           where dst.obj-date.obj-type = ub.clients.obj-type
             and dst.obj-date.obj-code = ub.clients.obj-code)
             then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  ub.clients.obj-type
  ,input  ub.clients.obj-code
  ,input  'active=request'
  ,output v-obj-is-active
  ) no-error .
        if v-obj-is-active = no
        then do:
            run create-date-on-object (
                  input ub.clients.obj-type
                , input ub.clients.obj-code
            ) no-error.
            if error-status :error
            then do:
                message
                vss-description
                skip "Ошибка создания даты на объекте."
                skip "Тип объекта:" ub.clients.obj-type
                skip "Код объекта:" ub.clients.obj-code
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
            end.
        end.
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-fin-ob " cur-time-string() .
      output stream slog close .
      run rest-fin-ob in this-procedure
        ( input ub.clients.obj-type
         ,input ub.clients.obj-code
        )
        no-error
      .
      if error-status :error then do:
          output stream slog to rest-rdb.txt append .
          export stream slog  error-status :get-message(1) return-value cur-time-string() .
          output stream slog close .
          return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-add-doc " cur-time-string() .
      output stream slog close .
      run rest-add-doc in this-procedure
        ( input ub.clients.obj-type
         ,input ub.clients.obj-code
        )
        no-error
      .
      if error-status :error then do:
          output stream slog to rest-rdb.txt append .
          export stream slog  error-status :get-message(1) return-value cur-time-string() .
          output stream slog close .
          return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-season-obj" cur-time-string() .
      output stream slog close .
      run rest-season in this-procedure
        ( input ub.clients.obj-type
         ,input ub.clients.obj-code
        )
        no-error
      .
      if error-status:error then do:
        output stream slog to rest-rdb.txt append .
        export stream slog
        "    !!!!rest-season-obj"
        substitute( " &1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)) skip.
        output stream slog close .
        undo, return error  substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
      end.
      else do:
        output stream slog to rest-rdb.txt append .
        export stream slog
        "OK rest-season-obj"  skip.
        output stream slog close .
      end.
      output stream slog to rest-rdb.txt append .
      export stream slog "start PromoAction " cur-time-string() .
      output stream slog close .
      run rest-promo-action in this-procedure
        no-error .
      if error-status :error then do:
        output stream slog to rest-rdb.txt append .
        export stream slog  error-status :get-message(1) return-value cur-time-string() .
        output stream slog close .
        return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
      end.
    end.
    if ser-wth-conf-par then do:
      output stream slog to rest-rdb.txt append .
      export stream slog "start rest-wth-doc-full " cur-time-string() .
      output stream slog close .
      run rest-wth-doc-full in this-procedure
      .
     if p-unload-history then do:
        output stream slog to rest-rdb.txt append .
        export stream slog "start rest-c-wth-doc-full " cur-time-string() .
        output stream slog close .
        run rest-c-wth-doc-full in this-procedure
        .
      end.
    end.
    output stream slog to rest-rdb.txt append .
    export stream slog "start prod-bc-db " cur-time-string() .
    output stream slog close .
    assign ind1 = 0
           fl   = "prod-bc-db".
    for each ub.prod-bc-db no-lock
        where ub.prod-bc-db.db-num = p-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign  ind1 = ind1 + 1.
      do with frame ddd
      :
        assign
          count-str :screen-value   = string( count-str, count-str :format)
          fl :screen-value          = string( fl, fl :format)
          ind1 :screen-value        = string( ind1, ind1 :format)
        .
      end.
      create dst.prod-bc-db.
      buffer-copy  ub.prod-bc-db to dst.prod-bc-db.
      create dst.prod-bc.
      buffer-copy  ub.prod-bc-db to dst.prod-bc
      assign
      dst.prod-bc.cr-db-num = ub.prod-bc-db.db-num
      .
    end.
    for each ub.sysconf no-lock
      where ub.sysconf.firm-db-num = p-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        tot-firm-db-count = tot-firm-db-count + 1
      .
    end.
    assign
      firm-db-count = 0
    .
    for each ub.sysconf no-lock
      where ub.sysconf.firm-db-num = p-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        firm-db-count = firm-db-count + 1
        count-str = "Обработано фирм, для которых главная БД фирмы =" + chr(32) + string(p-db-num) + chr(32) +
                    string( firm-db-count ) + chr(32)
                    + "из" + chr(32) + string( tot-firm-db-count )
      .
      for each buf_rrdb-option where buf_rrdb-option.dump-point = "firm-db"
      on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        assign
        v-subject =  (if buf_rrdb-option.subject-group = "dc"
                      then buf_rrdb-option.des
                      else buf_rrdb-option.first-table-name)
        count-str = "Справочники по главным БД фирм"
        fl = v-subject
        .
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        output stream slog to rest-rdb.txt append .
        export stream slog "table-firm-db-move" v-subject cur-time-string() .
        output stream slog close .
        if buf_rrdb-option.first-table-name begins 'c-':U then do:
          assign
          v-hn = yes
          v-hn = get-hist-nws-option( input p-db-num
                                      ,input buf_rrdb-option.first-table-name)
          no-error .
        end.
        else do:
          v-hn = yes.
        end.
        if not v-hn then do:
          output stream slog to rest-rdb.txt append .
          export stream slog "!!!SKIPPING other db  history records!!!!!" .
          output stream slog close .
        end.
        run adm/cred-tbl.p (
                            input this-procedure:handle
                          ,input p-db-num
                          ,input '':U
                          ,input 0
                          ,input ub.sysconf.host-code
                          ,input count-str
                          ,input (buf_rrdb-option.first-table-name + "," +                          buf_rrdb-option.second-table-name + "," +                          buf_rrdb-option.third-table-name + "," +                          buf_rrdb-option.fourth-table-name + "," +                          buf_rrdb-option.fifth-table-name + "," +                          buf_rrdb-option.sixth-table-name)
                          ,input (string(buf_rrdb-option.first-table-export) + "," +                          string(buf_rrdb-option.second-table-export) + "," +                          string(buf_rrdb-option.third-table-export) + "," +                          string(buf_rrdb-option.fourth-table-export) + "," +                          string(buf_rrdb-option.fifth-table-export) + "," +                          string(buf_rrdb-option.sixth-table-export))
                          ,input buf_rrdb-option.where-phrase
                          ,input buf_rrdb-option.if-phrase
                          ,input buf_rrdb-option.if-buffer-num
                          ,input "firm-db"
                          ,input v-hn
                          ,input yes
                          ) .
        output stream slog to rest-rdb.txt append .
        export stream slog "OK firm-db" v-subject cur-time-string() .
        output stream slog close .
      end.
    end.
    assign
    v-cli-count = 0
    .
    _cl2:
    for each ub.clients no-lock
      where ub.clients.db-num = p-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-cli-count = v-cli-count + 1
        count-str = "Обработано объектов, для которых главная БД фирмы = 0" + chr(32) + string( v-cli-count ) + chr(32)
                    + "из" + chr(32) + string( tot-cli-count )
      .
      if ub.clients.obj-type = 'скл':U then do:
        find ub.store where ub.store.obj-code = ub.clients.obj-code no-lock.
        assign
          host = ub.store.host-code
        .
      end.
      else do:
        find ub.shop where ub.shop.obj-code = ub.clients.obj-code no-lock.
        assign
          host = ub.shop.host-code
        .
      end.
      find first ub.sysconf where ub.sysconf.host-code = host no-lock.
      if ub.sysconf.firm-db-num <> 0 then NEXT _cl2.
      if LOOKUP(string(ub.sysconf.host-code), v-proceeded-host, chr(4)) > 0 then NEXT _cl2.
      for each buf_rrdb-option where buf_rrdb-option.dump-point = "firm-db"
      on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        assign
        v-subject =  (if buf_rrdb-option.subject-group = "dc"
                      then buf_rrdb-option.des
                      else buf_rrdb-option.first-table-name)
        count-str = "Справочники по главным БД фирм"
        fl = v-subject
        .
        do with frame ddd
        :
          assign
            count-str :screen-value   = string( count-str, count-str :format)
            fl :screen-value          = string( fl, fl :format)
            ind1 :screen-value        = string( ind1, ind1 :format)
          .
        end.
        if lookup(buf_rrdb-option.first-table-name, table-firm-db-no) > 0 then next.
        output stream slog to rest-rdb.txt append .
        export stream slog "table-firm-db-move" v-subject cur-time-string() .
        output stream slog close .
        if buf_rrdb-option.first-table-name begins 'c-':U then do:
          assign
          v-hn = yes
          v-hn = get-hist-nws-option( input p-db-num
                                      ,input buf_rrdb-option.first-table-name)
          no-error .
        end.
        else do:
          v-hn = yes.
        end.
        if not v-hn then do:
          output stream slog to rest-rdb.txt append .
          export stream slog "!!!SKIPPING other db  history records!!!!!" .
          output stream slog close .
        end.
        run adm/cred-tbl.p (
                            input this-procedure:handle
                          ,input p-db-num
                          ,input '':U
                          ,input 0
                          ,input ub.sysconf.host-code
                          ,input count-str
                          ,input (buf_rrdb-option.first-table-name + "," +                          buf_rrdb-option.second-table-name + "," +                          buf_rrdb-option.third-table-name + "," +                          buf_rrdb-option.fourth-table-name + "," +                          buf_rrdb-option.fifth-table-name + "," +                          buf_rrdb-option.sixth-table-name)
                          ,input (string(buf_rrdb-option.first-table-export) + "," +                          string(buf_rrdb-option.second-table-export) + "," +                          string(buf_rrdb-option.third-table-export) + "," +                          string(buf_rrdb-option.fourth-table-export) + "," +                          string(buf_rrdb-option.fifth-table-export) + "," +                          string(buf_rrdb-option.sixth-table-export))
                          ,input buf_rrdb-option.where-phrase
                          ,input buf_rrdb-option.if-phrase
                          ,input buf_rrdb-option.if-buffer-num
                          ,input "firm-db"
                          ,input v-hn
                          ,input yes
                          ) .
        output stream slog to rest-rdb.txt append .
        export stream slog "OK firm-db" v-subject cur-time-string() .
        output stream slog close .
      end.
      assign
      v-proceeded-host = v-proceeded-host + chr(4) + string(ub.sysconf.host-code)
      .
    end.
    run rest-mpl in this-procedure .
    hide frame ddd no-pause.
    output stream slog to rest-rdb.txt append .
    export stream slog "rest-sequence" cur-time-string() .
    output stream slog close .
    create alias restseq    for database value( ldbname( "dst":U ) ) .
    create alias restseqflt for database value( ldbname( "dst":U ) ) .
    run adm/restseq.p
      ( input "rest-no-msg"
       ,input "":U
       ,input yes
      ) no-error .
    if error-status :error then do:
      delete alias restseqflt.
      delete alias restseq.
      return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
    end.
    delete alias restseqflt.
    delete alias restseq.
    output stream slog to rest-rdb.txt append .
    export stream slog "stop-rest-success" cur-time-string() .
    output stream slog close .
    output stream slog to rest-rdb.txt append .
    export stream slog "two-commit-command" cur-time-string() .
    output stream slog close .
    run rest-tcc in this-procedure
      ( input p-db-num
       ,input p-type-unload
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при обработке команд two-commit" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
    end.
    output stream slog to rest-rdb.txt append .
    export stream slog "stop-two-commit-command" cur-time-string() .
    output stream slog close .
    output stream slog to rest-rdb.txt append .
    export stream slog "check-clients" cur-time-string() .
    output stream slog close .
    assign
      ind1 = 0
      fl = "":U
      count-str = "Проверка привязки объектов"
    .
    for each ub.clients share-lock
      where ub.clients.db-num = p-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        ind1 = ind1 + 1
      .
      do with frame inf
      :
        assign
          count-str :screen-value   = string( count-str, count-str :format)
          fl :screen-value          = string( fl, fl :format)
          ind1 :screen-value        = string( ind1, ind1 :format)
        .
      end.
      find first src.clients share-lock
        where src.clients.obj-type = ub.clients.obj-type
          and src.clients.obj-code = ub.clients.obj-code
        no-error .
      if not available src.clients
        or ub.clients.db-num <> src.clients.db-num
      then do:
        return error substitute( "&1. Клиенты привязаны к разным БД. Возможно была запущена утилита переноса объекта.", vss-workfile, ub.clients.obj-type, ub.clients.obj-code ).
      end.
    end.
    output stream slog to rest-rdb.txt append .
    export stream slog "stop-check-clients" cur-time-string() .
    output stream slog close .
    assign
      v-lock = true
    .
define variable vss-include-info26 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_lock-route in g#lib-nws
  ( input  'unlock'
  , input  p-db-num
  , input  0
  , input  ''
  , output v-msg
  , output v-lock
  , output v-ok
  ) no-error .
    if error-status :error
      or v-lock = true
      or v-ok   = false
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "&1", v-msg ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      return.
    end.
    output stream slog to rest-rdb.txt append .
    export stream slog "start gds-mercury " cur-time-string() .
    output stream slog close .
    for each src.gds-mercury no-lock:
      for each src.gds-mercury-attr no-lock where src.gds-mercury-attr.ID =  src.gds-mercury.ID
        and src.gds-mercury-attr.db-num = src.gds-mercury.db-num:
        create dst.gds-mercury-attr .
        buffer-copy src.gds-mercury-attr to dst.gds-mercury-attr .
      end.
      create dst.gds-mercury.
      buffer-copy src.gds-mercury to dst.gds-mercury.
    end.
    output stream slog to rest-rdb.txt append .
    export stream slog "start vsd " cur-time-string() .
    output stream slog close .
    for each src.vsd where src.vsd.db-num = p-db-num no-lock:
      for each src.vsd-attr no-lock where src.vsd-attr.ID =  src.vsd.ID
        and src.vsd-attr.db-num = src.vsd.db-num:
        create dst.vsd-attr .
        buffer-copy src.vsd-attr to dst.vsd-attr .
      end.
      create dst.vsd.
      buffer-copy src.vsd to dst.vsd.
    end.
    do transaction
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1. stop", vss-workfile )
    on endkey undo, return error substitute( "&1. endkey", vss-workfile )
    :
      disable triggers for load of ub.db.
      find ub.db exclusive-lock
        where ub.db.db-num = p-db-num
      .
      find dst.db exclusive-lock
        where dst.db.db-num = p-db-num
      .
      assign
        ub.db.db-key       = p-db-key
        ub.db.db-key-enc   = p-db-key-enc
        ub.db.stts         = 0
        dst.db.db-key      = p-db-key
        dst.db.db-key-enc  = p-db-key-enc
        dst.db.stts        = 0
      .
      if p-type-unload = 'unload-copy':U then do:
        find src.db exclusive-lock
          where src.db.db-num = p-db-num
        .
        assign
          src.db.db-key      = p-db-key
          src.db.db-key-enc  = p-db-key-enc
          src.db.stts        = 0
        .
      end.
      run cur-time in this-procedure
        ( output v-today
         ,output v-time
        ).
      assign
        v-command = "command":U + chr(1)
                    + "get-inf-dbs":U
      .
def var vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf27_db    for dst.db .
define buffer buf27_route for dst.route .
define variable v-msg#27    as character no-undo .
define variable v-lock#27   as logical   no-undo .
define variable v-ok#27     as logical   no-undo .
find first buf27_db no-lock
  where buf27_db.db-num = 0
  no-error
.
if not available buf27_db then do:
  message
    vss-include-info27 skip
    vss-workfile vss-revision vss-description skip
    substitute( "Попытка создать маршрутизацию на несуществующую БД &1", 0 ) skip
    return-value skip
    error-status :get-message ( error-status :num-messages )
    view-as alert-box error
  .
end.
if "dst":U <> "ub":U
   or ( trim( buf27_db.db-key ) <> "":U
        and buf27_db.db-key <> ?
      )
then do:
    disable triggers for load of dst.route .
  create buf27_route .
  assign
    buf27_route.last-pack    = -1
    buf27_route.name-rec     = v-command
    buf27_route.db-num       = 0
    buf27_route.uniq-key-rec = '':U
    buf27_route.num-dump     = 0
    buf27_route.tbl-ord      = dynamic-next-value( "s-news-ord":U, "dst":U )
    .
    assign
      buf27_route.dump-ord = dynamic-next-value( "s-news-dord":U, "dst":U )
    .
    assign
      buf27_route.CreDate      = v-today
    .
    assign
      buf27_route.CreTimeInt   = v-time
      buf27_route.CreTime      = string(v-time,"HH:MM:SS":U)
    .
    assign
      buf27_route.CreUserName  = 'rest-rdb':U
    .
end.
else do:
define variable vss-include-info28 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_lock-route in g#lib-nws
  ( input  'check'
  , input  0
  , input  0
  , input  ''
  , output v-msg#27
  , output v-lock#27
  , output v-ok#27
  ) no-error .
  if error-status :error
    or v-lock#27 = true
    or v-ok#27   = false
  then do:
    return error substitute( "&1. Маршрутизация записи &2.&3Ключ записи: &4&3&3"
                             ,vss-include-info27
                             ,v-command
                             ,chr(10)
                             ,'':U
                           )
                + substitute( "&1&2&2&3&2&2&4"
                              ,v-msg#27
                              ,chr(10)
                              ,return-value
                              ,error-status :get-message( error-status :num-messages )
                            ) .
  end.
end.
    end.
  end.
  if not can-find(first dst.db-attr where dst.db-attr.db-num = p-db-num and dst.db-attr.attr-code = 'ver-met':U) then
  do:
    for first dst.db-attr exclusive-lock where
              dst.db-attr.db-num = 0
          and dst.db-attr.attr-code = 'ver-met':U
    :
      dst.db-attr.db-num = p-db-num.
    end.
  end.
  disconnect dst.
  if not v-multi
  then
  message
    "Перекачка успешно завершена."
    view-as alert-box information .
  return.
end.
procedure cre-activ-code-range :
  define input parameter p-db-num     like dst.code-range.db-num     no-undo.
  define input parameter p-range-type like dst.code-range.range-type no-undo.
  do
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-b-code as integer   no-undo .
    define variable crg-cre  as logical   no-undo .
    if p-range-type = 'sclc':U
      or p-range-type = 'sslc':U
      or p-range-type = 'pglc':U
    then do:
      assign
        p-db-num = 0
      .
    end.
    if not can-find( first dst.code-range
                     where dst.code-range.db-num     = p-db-num
                       and dst.code-range.range-type = p-range-type
                     no-lock
                   )
    then do:
      if p-range-type = 'scgb':U
        or p-range-type = 'dcgb':U
        or p-range-type = 'sslc':U
        or p-range-type = 'ssgb':U
        or p-range-type = 'pglc':U
        or p-range-type = 'cagb':U
        or p-range-type = 'fdgb':U
      then do:
        return.
      end.
      else do:
        return error "Нет ни одного диапазона с типом" + chr(32) + p-range-type.
      end.
    end.
    find first dst.code-range
      where dst.code-range.db-num     = p-db-num
        and dst.code-range.range-type = p-range-type
        and dst.code-range.stts       = "a":U
      no-error .
    if available dst.code-range then do:
      assign
        dst.code-range.stts = "u":U
      .
    end.
    run get-max-code in this-procedure
      ( input "f-u":U
        ,input p-db-num
        ,input p-range-type
        ,input ?
        ,input ?
        ,input FALSE
        ,output v-b-code
      ).
    if not can-find(first dst.code-range no-lock
      where dst.code-range.db-num     = p-db-num
        and dst.code-range.range-type = p-range-type
        and dst.code-range.stts       = "a":U)
      then do:
      assign
        crg-cre = FALSE
      .
      for each dst.code-range
        where dst.code-range.db-num     = p-db-num
          and dst.code-range.range-type = p-range-type
          and dst.code-range.stts       = "u":U
      by dst.code-range.first-code descending
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        assign
          dst.code-range.stts = "a":U
          crg-cre             = TRUE
        .
        leave .
      end.
      if not crg-cre then do:
        for each dst.code-range
          where dst.code-range.db-num     = p-db-num
            and dst.code-range.range-type = p-range-type
            and dst.code-range.stts       = "f":U
        by dst.code-range.first-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          assign
            dst.code-range.stts = "a":U
          .
          leave .
        end.
      end.
    end.
  end.
end procedure.
procedure create-date-on-object :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define input parameter p-obj-type   as character    no-undo.
    define input parameter p-obj-code   as integer      no-undo.
    define variable v-last-date   as date         no-undo.
    define variable v-today       as date      no-undo.
    define variable v-time        as integer   no-undo.
    define buffer buf_obj-date      for dst.obj-date.
    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_price-doc     for ub.price-doc.
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    find last buf_trn-doc no-lock
        where buf_trn-doc.obj-type = p-obj-type
          and buf_trn-doc.obj-code = p-obj-code
          and buf_trn-doc.status_  = 'факт':U
    use-index fact-order
    no-error.
    find last buf_price-doc
        where buf_price-doc.obj-type = p-obj-type
          and buf_price-doc.obj-code = p-obj-code
          and buf_price-doc.status_  = 'акт':U
    use-index fact-order
    no-error.
    if not available buf_trn-doc
    and not available buf_price-doc
    then do:
        assign
            v-last-date = v-today
        .
    end.
    else do:
      if not available buf_price-doc then do:
        assign
          v-last-date = buf_trn-doc.fact-date
        .
      end.
      else do:
        if not available buf_trn-doc then do:
          assign
            v-last-date = buf_price-doc.fact-date
          .
        end.
        else do:
          assign
            v-last-date = ( if buf_trn-doc.fact-date > buf_price-doc.fact-date
                            then buf_trn-doc.fact-date
                            else buf_price-doc.fact-date
                          )
          .
        end.
      end.
    end.
    create buf_obj-date .
    assign
        buf_obj-date.obj-type  = p-obj-type
        buf_obj-date.obj-code  = p-obj-code
        buf_obj-date.sys-date  = v-last-date
        buf_obj-date.status_   = 'новый':U
        buf_obj-date.open-id   = "rest-rdb":U
        buf_obj-date.open-date = v-today
        buf_obj-date.open-time = v-time
    .
end.
end procedure.
procedure process-parts :
   define buffer marking-lines for ub.marking-lines.
   define buffer buf_marking-lines for dst.marking-lines.
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    create dst.parts .
    buffer-copy ub.parts to dst.parts .
    define variable v-parts-gds-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pargocod in g#library
  (input  recid(ub.parts)
  ,output v-parts-gds-code
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при поиске товара для партии" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
    end.
    for each marking-lines where marking-lines.gds-code   = v-parts-gds-code
                             and marking-lines.obj-type   = ub.parts.obj-type
                             and marking-lines.obj-code   = ub.parts.obj-code
                             and marking-lines.in-code    = ub.parts.in-code
                             and marking-lines.out-code   = ub.parts.out-code
                             and marking-lines.part-code  = ub.parts.part-code
    no-lock
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ):
       create buf_marking-lines.
       buffer-copy  marking-lines to buf_marking-lines.
       run rest-Onemark(buf_marking-lines.mark).
    end.
    find first ub.parts-supp no-lock
      where ub.parts-supp.in-code   = ub.parts.in-code
        and ub.parts-supp.artic     = ub.parts.artic
        and ub.parts-supp.prod-type = ub.parts.prod-type
        and ub.parts-supp.prod-code = ub.parts.prod-code
        and ub.parts-supp.part-code = ub.parts.part-code
      no-error .
    if available ub.parts-supp
    then do:
      if not can-find (first dst.parts-supp no-lock
        where dst.parts-supp.in-code   = ub.parts.in-code
          and dst.parts-supp.artic     = ub.parts.artic
          and dst.parts-supp.prod-type = ub.parts.prod-type
          and dst.parts-supp.prod-code = ub.parts.prod-code
          and dst.parts-supp.part-code = ub.parts.part-code)
      then do:
        create dst.parts-supp .
        buffer-copy ub.parts-supp to dst.parts-supp .
      end.
    end.
    if not can-find (first dst.parts-attr no-lock
      where dst.parts-attr.in-code   = ub.parts.in-code
        and dst.parts-attr.gds-code  = v-parts-gds-code
        and dst.parts-attr.part-code = ub.parts.part-code)
    then do:
      find first ub.parts-attr no-lock
        where ub.parts-attr.in-code   = ub.parts.in-code
          and ub.parts-attr.gds-code  = v-parts-gds-code
          and ub.parts-attr.part-code = ub.parts.part-code
        no-error .
      if available ub.parts-attr
      then do:
        create dst.parts-attr .
        buffer-copy ub.parts-attr to dst.parts-attr .
      end.
    end.
    for each ub.parts-add no-lock
      where  ub.parts-add.in-code   = ub.parts.in-code
        and  ub.parts-add.gds-code  = v-parts-gds-code
        and  ub.parts-add.part-code = ub.parts.part-code :
      if not can-find (first dst.parts-add no-lock
      where  dst.parts-add.in-code   = ub.parts.in-code
        and  dst.parts-add.gds-code  = v-parts-gds-code
        and  dst.parts-add.part-code = ub.parts.part-code
        and  dst.parts-add.add-doc-code  = ub.parts-add.add-doc-code
        and  dst.parts-add.add-gds-code  = ub.parts-add.add-gds-code
        and  dst.parts-add.cli-type      = ub.parts-add.cli-type
        and  dst.parts-add.cli-code      = ub.parts-add.cli-code
        and  dst.parts-add.host-code     = ub.parts-add.host-code
        and  dst.parts-add.contract-code = ub.parts-add.contract-code)
        then do:
          create dst.parts-add .
          buffer-copy ub.parts-add to dst.parts-add .
        end.
    end.
  end.
end procedure.
procedure process-c-parts :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    create dst.c-parts .
    buffer-copy ub.c-parts to dst.c-parts .
    define variable v-parts-gds-code as integer   no-undo .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  ub.c-parts.artic
  ,input  ub.c-parts.prod-type
  ,input  ub.c-parts.prod-code
  ,output v-parts-gds-code
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при поиске кода товара по артикулу для таблицы c-parts" skip
        "Указатель на запись c-parts" recid(ub.c-parts) skip
        "Артикул" ub.c-parts.artic ub.c-parts.prod-type ub.c-parts.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
    end.
    if not can-find (first dst.c-parts-attr no-lock
      where dst.c-parts-attr.in-code   = ub.c-parts.in-code
        and dst.c-parts-attr.gds-code  = v-parts-gds-code
        and dst.c-parts-attr.part-code = ub.c-parts.part-code)
    then do:
      find first ub.c-parts-attr no-lock
        where ub.c-parts-attr.in-code   = ub.c-parts.in-code
          and ub.c-parts-attr.gds-code  = v-parts-gds-code
          and ub.c-parts-attr.part-code = ub.c-parts.part-code
        no-error .
      if available ub.c-parts-attr
      then do:
        create dst.c-parts-attr .
        buffer-copy ub.c-parts-attr to dst.c-parts-attr .
      end.
    end.
  end.
end procedure.
procedure rest-OneMark :
   define input parameter p-mark as character no-undo .
   define buffer marking          for  ub.marking.
   define buffer buf_marking      for dst.marking.
   define buffer marking-attr     for  ub.marking-attr.
   define buffer buf_marking-attr for dst.marking-attr.
   find first buf_marking where buf_marking.mark eq p-mark
   no-lock no-error.
   if not available buf_marking
   then do:
      find first marking where marking.mark eq p-mark
      no-lock no-error.
      if available  marking
      then do on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ):
         create buf_marking.
         buffer-copy marking to buf_marking.
         if     buf_marking.obj-type eq 'маг':U
            and buf_marking.sts eq objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
         then do:
            find dst.shop where dst.shop.obj-code = buf_marking.obj-code no-lock.
            if not available ub.shop
            then
               buf_marking.sts eq objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB.
         end.
         for each marking-attr where marking-attr.mark eq buf_marking.mark
         no-lock
         on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ):
            create buf_marking-attr.
            buffer-copy marking-attr to buf_marking-attr.
         end.
      end.
   end.
end.
procedure rest-Utd :
   define input parameter p-obj-type as character no-undo .
   define input parameter p-obj-code as integer   no-undo .
   define buffer utd                         for ub.utd.
   define buffer but_utd                     for dst.utd.
   define buffer utd-attr                    for ub.utd-attr.
   define buffer but_utd-attr                for dst.utd-attr.
   define buffer Utd-err                     for ub.Utd-err.
   define buffer but_Utd-err                 for dst.Utd-err.
   define buffer Utd-lines                   for ub.Utd-lines.
   define buffer but_Utd-lines               for dst.Utd-lines.
   define buffer Utd-marking-lines           for ub.Utd-marking-lines.
   define buffer but_Utd-marking-lines       for dst.Utd-marking-lines.
   define buffer Utd-err-attr                for ub.Utd-err-attr.
   define buffer but_Utd-err-attr            for dst.Utd-err-attr.
   define buffer Utd-lines-attr              for ub.Utd-lines-attr.
   define buffer but_Utd-lines-attr          for dst.Utd-lines-attr.
   define buffer Utd-marking-lines-attr      for ub.Utd-marking-lines-attr.
   define buffer but_Utd-marking-lines-attr  for dst.Utd-marking-lines-attr.
   do
   on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
   on stop   undo, return error substitute( "&1. stop", vss-workfile )
   on endkey undo, return error substitute( "&1. endkey", vss-workfile )
   :
      assign
         ind1 = 0
         fl   = 'trn-doc':U
      .
      if transaction = true
      then do:
         message
            vss-workfile vss-revision vss-description skip
            "При выгрузке УПД активна транзакция" skip
            "Выгрузка невозможна" skip
         view-as alert-box error .
         undo, return error "При выгрузке документов активна транзакция" .
      end.
      for each utd no-lock
         where Utd.obj-type = p-obj-type
           and UTD.obj-code = p-obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
         create but_utd.
         buffer-copy utd to but_utd.
         assign  ind1 = ind1 + 1.
         display ind1 count-str fl with frame ddd view-as dialog-box.
         for each utd-attr where  Utd-attr.db-num eq   Utd.db-num
                                 and  Utd-attr.doc-id eq   Utd.doc-id
         no-lock:
            create but_Utd-attr.
            buffer-copy Utd-attr to but_Utd-attr.
         end.
         for each utd-err where  Utd-err.db-num eq   Utd.db-num
                            and  Utd-err.doc-id eq   Utd.doc-id
         no-lock:
            create but_Utd-err.
            buffer-copy Utd-err to but_Utd-err.
         end.
         for each  Utd-lines where  Utd-lines.db-num eq   Utd.db-num
                               and  Utd-lines.doc-id eq   Utd.doc-id
         no-lock:
            create but_Utd-lines.
            buffer-copy Utd-lines to but_Utd-lines.
         end.
         for each  Utd-marking-lines where  Utd-marking-lines.db-num eq   Utd.db-num
                                       and  Utd-marking-lines.doc-id eq   Utd.doc-id
         no-lock:
            create but_Utd-marking-lines.
            buffer-copy Utd-marking-lines to but_Utd-marking-lines.
            run rest-OneMark(but_Utd-marking-lines.mark).
         end.
         for each utd-err-attr where  Utd-err-attr.db-num eq   Utd.db-num
                                 and  Utd-err-attr.doc-id eq   Utd.doc-id
         no-lock:
            create but_Utd-err-attr.
            buffer-copy Utd-err-attr to but_Utd-err-attr.
         end.
         for each  Utd-lines-attr where  Utd-lines-attr.db-num eq   Utd.db-num
                                    and  Utd-lines-attr.doc-id eq   Utd.doc-id
         no-lock:
            create but_Utd-lines-attr.
            buffer-copy Utd-lines-attr to but_Utd-lines-attr.
         end.
         for each  Utd-marking-lines-attr where  Utd-marking-lines-attr.db-num eq   Utd.db-num
                                            and  Utd-marking-lines-attr.doc-id eq   Utd.doc-id
         no-lock:
            create but_Utd-marking-lines-attr.
            buffer-copy Utd-marking-lines-attr to but_Utd-marking-lines-attr.
         end.
      end.
   end.
end.
procedure rest-trn-doc :
  define input parameter p-trn_obj-type as character no-undo .
  define input parameter p-trn_obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    assign
      ind1 = 0
    .
    assign
      fl   = 'trn-doc':U
    .
    if transaction = true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "При выгрузке документов активна транзакция" skip
        "Выгрузка невозможна" skip
        view-as alert-box error .
      undo, return error "При выгрузке документов активна транзакция" .
    end.
    for each ub.trn-doc no-lock
      where ub.trn-doc.obj-type = p-trn_obj-type
        and ub.trn-doc.obj-code = p-trn_obj-code
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      if ( ub.trn-doc.status_ = 'накл':U
           and ub.trn-doc.flag_ = false
         )
         or ( ub.trn-doc.status_ = 'запрос':U
              and ub.trn-doc.flag_ = false
            )
      then do:
        next.
      end.
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      create dst.trn-doc.
      buffer-copy  ub.trn-doc to dst.trn-doc.
      find first ub.batchprocess no-lock
        where ub.batchprocess.bp_type     = 'trnhd':U
          and ub.batchprocess.bp_status   = 'N':U
          and ub.batchprocess.charkey_one = ub.trn-doc.doc-code
        no-error .
      if available ub.batchprocess
      then do:
        create dst.batchprocess .
        buffer-copy ub.batchprocess to dst.batchprocess .
      end.
      if ub.db.unload-arch = true
      then do:
        find first ub.batchprocess no-lock
          where ub.batchprocess.bp_type     = 'arh':U
            and ub.batchprocess.bp_status   = 'N':U
            and ub.batchprocess.charkey_one = ub.trn-doc.doc-code
          no-error .
        if available ub.batchprocess
        then do:
          create dst.batchprocess .
          buffer-copy ub.batchprocess to dst.batchprocess .
        end.
        find first ub.batchprocess no-lock
          where ub.batchprocess.bp_type     = 'ahsp':U
            and ub.batchprocess.bp_status   = 'N':U
            and ub.batchprocess.charkey_one = ub.trn-doc.doc-code
          no-error .
        if available ub.batchprocess
        then do:
          create dst.batchprocess .
          buffer-copy ub.batchprocess to dst.batchprocess .
        end.
      end.
      if ub.db.unload-aht = true
      then do:
        find first ub.batchprocess no-lock
          where ub.batchprocess.bp_type     = 'aht':U
            and ub.batchprocess.bp_status   = 'N':U
            and ub.batchprocess.charkey_one = ub.trn-doc.doc-code
          no-error .
        if available ub.batchprocess
        then do:
          create dst.batchprocess .
          buffer-copy ub.batchprocess to dst.batchprocess .
        end.
      end.
      for each ub.doc-line no-lock
          where ub.doc-line.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.doc-line.
        buffer-copy ub.doc-line to dst.doc-line.
      end.
      for each ub.gds-dtl no-lock
          where ub.gds-dtl.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.gds-dtl.
        buffer-copy  ub.gds-dtl to dst.gds-dtl.
      end.
      for each ub.parts no-lock
        where ub.parts.out-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        run process-parts in this-procedure no-error.
        if error-status :error then do:
          undo, return error substitute( 'rest-rdb.p: &1 &2' , return-value , error-status :get-message(1) ).
        end.
      end.
      for each ub.parts-root no-lock
        where ub.parts-root.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.parts-root.
        buffer-copy ub.parts-root to dst.parts-root.
      end.
      for each ub.inv-doc no-lock
          where ub.inv-doc.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.inv-doc.
        buffer-copy ub.inv-doc to dst.inv-doc.
      end.
      for each ub.trn-doc-sum no-lock
          where ub.trn-doc-sum.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.trn-doc-sum.
        buffer-copy ub.trn-doc-sum to dst.trn-doc-sum.
      end.
      for each ub.inv-line no-lock
          where ub.inv-line.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.inv-line.
        buffer-copy ub.inv-line to dst.inv-line.
      end.
      for each ub.doc-line-sum no-lock
          where ub.doc-line-sum.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.doc-line-sum.
        buffer-copy ub.doc-line-sum to dst.doc-line-sum.
      end.
      for each ub.doc-prts no-lock
          where ub.doc-prts.out-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.doc-prts.
        buffer-copy ub.doc-prts to dst.doc-prts.
      end.
      for each ub.doc-pl no-lock
          where ub.doc-pl.out-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.doc-pl.
        buffer-copy ub.doc-pl to dst.doc-pl.
      end.
      for each ub.doc-line-attr no-lock
          where ub.doc-line-attr.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.doc-line-attr.
        buffer-copy ub.doc-line-attr to dst.doc-line-attr.
      end.
      for each ub.doc-attr no-lock
          where ub.doc-attr.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.doc-attr.
        buffer-copy ub.doc-attr to dst.doc-attr.
      end.
      for each ub.doc-pl-pump no-lock
          where ub.doc-pl-pump.out-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.doc-pl-pump.
        buffer-copy ub.doc-pl-pump to dst.doc-pl-pump.
      end.
      for each ub.doc-fbr-gds no-lock
          where ub.doc-fbr-gds.out-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.doc-fbr-gds.
        buffer-copy ub.doc-fbr-gds to dst.doc-fbr-gds.
      end.
      for each ub.arh-trn-doc-contract no-lock
          where ub.arh-trn-doc-contract.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.arh-trn-doc-contract.
        buffer-copy ub.arh-trn-doc-contract to dst.arh-trn-doc-contract.
      end.
      if ub.trn-doc.whole-send-news > 0 then do:
        for each ub.edi-status no-lock
            where ub.edi-status.tbl-name = 'trn-doc':U
            and  ub.edi-status.doc-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.edi-status.
          buffer-copy ub.edi-status to dst.edi-status no-error.
        end.
        for each ub.edi-status no-lock
            where ub.edi-status.tbl-name = 'doc-line':U
            and  ub.edi-status.doc-code begins (ub.trn-doc.doc-code + chr(4))
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.edi-status.
          buffer-copy ub.edi-status to dst.edi-status no-error.
        end.
      end.
     if p-unload-history then do:
      for each ub.c-trn-doc no-lock
          where ub.c-trn-doc.doc-code = ub.trn-doc.doc-code
            and ub.c-trn-doc.is-del = false
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-trn-doc.
        buffer-copy ub.c-trn-doc to dst.c-trn-doc.
      end.
      for each ub.c-doc-line no-lock
          where ub.c-doc-line.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-doc-line.
        buffer-copy ub.c-doc-line to dst.c-doc-line.
      end.
      for each ub.c-gds-dtl no-lock
          where ub.c-gds-dtl.doc-code = ub.trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-gds-dtl.
        buffer-copy  ub.c-gds-dtl to dst.c-gds-dtl.
      end.
        for each ub.c-parts no-lock
          where ub.c-parts.out-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          run process-c-parts in this-procedure .
        end.
        for each ub.c-parts-root no-lock
          where ub.c-parts-root.doc-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-parts-root.
          buffer-copy ub.c-parts-root to dst.c-parts-root.
        end.
        for each ub.c-inv-line no-lock
            where ub.c-inv-line.doc-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-inv-line.
          buffer-copy ub.c-inv-line to dst.c-inv-line.
        end.
        for each ub.c-trn-doc-sum no-lock
            where ub.c-trn-doc-sum.doc-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-trn-doc-sum.
          buffer-copy ub.c-trn-doc-sum to dst.c-trn-doc-sum.
        end.
        for each ub.c-doc-line-sum no-lock
            where ub.c-doc-line-sum.doc-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-doc-line-sum.
          buffer-copy ub.c-doc-line-sum to dst.c-doc-line-sum.
        end.
        for each ub.c-doc-prts no-lock
            where ub.c-doc-prts.out-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-doc-prts.
          buffer-copy ub.c-doc-prts to dst.c-doc-prts.
        end.
        for each ub.c-doc-pl no-lock
            where ub.c-doc-pl.out-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-doc-pl.
          buffer-copy ub.c-doc-pl to dst.c-doc-pl.
        end.
        for each ub.c-doc-line-attr no-lock
            where ub.c-doc-line-attr.doc-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-doc-line-attr.
          buffer-copy ub.c-doc-line-attr to dst.c-doc-line-attr.
        end.
        for each ub.c-doc-pl-pump no-lock
            where ub.c-doc-pl-pump.out-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-doc-pl-pump.
          buffer-copy ub.c-doc-pl-pump to dst.c-doc-pl-pump.
        end.
        for each ub.c-doc-fbr-gds no-lock
            where ub.c-doc-fbr-gds.out-code = ub.trn-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-doc-fbr-gds.
          buffer-copy ub.c-doc-fbr-gds to dst.c-doc-fbr-gds.
        end.
      end.
    end.
  end.
  return.
end procedure.
procedure rest-c-trn-doc :
  define input parameter p-trn_obj-type as character no-undo .
  define input parameter p-trn_obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    assign ind1 = 0
           fl   = "c-trn-doc is-del".
    for each ub.c-trn-doc no-lock
        where ub.c-trn-doc.obj-type = p-trn_obj-type
          and ub.c-trn-doc.obj-code = p-trn_obj-code
          and ub.c-trn-doc.is-del   = true
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      create dst.c-trn-doc.
      buffer-copy ub.c-trn-doc to dst.c-trn-doc.
      for each ub.c-doc-line no-lock
          where ub.c-doc-line.doc-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-doc-line.
        buffer-copy ub.c-doc-line to dst.c-doc-line.
      end.
      for each ub.c-gds-dtl no-lock
          where ub.c-gds-dtl.doc-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-gds-dtl.
        buffer-copy  ub.c-gds-dtl to dst.c-gds-dtl.
      end.
      for each ub.c-parts no-lock
        where ub.c-parts.out-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        run process-c-parts in this-procedure .
      end.
      for each ub.c-parts-root no-lock
        where ub.c-parts-root.doc-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-parts-root.
        buffer-copy ub.c-parts-root to dst.c-parts-root.
      end.
      for each ub.c-inv-line no-lock
          where ub.c-inv-line.doc-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-inv-line.
        buffer-copy ub.c-inv-line to dst.c-inv-line.
      end.
      for each ub.c-trn-doc-sum no-lock
          where ub.c-trn-doc-sum.doc-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-trn-doc-sum.
        buffer-copy ub.c-trn-doc-sum to dst.c-trn-doc-sum.
      end.
      for each ub.c-doc-line-sum no-lock
          where ub.c-doc-line-sum.doc-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-doc-line-sum.
        buffer-copy ub.c-doc-line-sum to dst.c-doc-line-sum.
      end.
      for each ub.c-doc-prts no-lock
          where ub.c-doc-prts.out-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-doc-prts.
        buffer-copy ub.c-doc-prts to dst.c-doc-prts.
      end.
      for each ub.c-doc-pl no-lock
          where ub.c-doc-pl.out-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-doc-pl.
        buffer-copy ub.c-doc-pl to dst.c-doc-pl.
      end.
      for each ub.c-doc-line-attr no-lock
          where ub.c-doc-line-attr.doc-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-doc-line-attr.
        buffer-copy ub.c-doc-line-attr to dst.c-doc-line-attr.
      end.
      for each ub.c-doc-pl-pump no-lock
          where ub.c-doc-pl-pump.out-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-doc-pl-pump.
        buffer-copy ub.c-doc-pl-pump to dst.c-doc-pl-pump.
      end.
      for each ub.c-doc-fbr-gds no-lock
          where ub.c-doc-fbr-gds.out-code = ub.c-trn-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-doc-fbr-gds.
        buffer-copy ub.c-doc-fbr-gds to dst.c-doc-fbr-gds.
      end.
    end.
  end.
  return.
end procedure.
procedure rest-inkas :
  define input parameter p-inkas_obj-type as character no-undo .
  define input parameter p-inkas_obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (rest-inkas). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (rest-inkas). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (rest-inkas). endkey", vss-workfile )
  :
    assign ind1 = 0
           fl   = "inkas".
    for each ub.inkas no-lock
        where ub.inkas.obj-type = p-inkas_obj-type
          and ub.inkas.obj-code = p-inkas_obj-code
    on error  undo, return error substitute( "&1 (rest-inkas/inkas). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo, return error substitute( "&1 (rest-inkas/inkas). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (rest-inkas/inkas). endkey", vss-workfile )
    :
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      create dst.inkas.
      buffer-copy  ub.inkas to dst.inkas.
      for each ub.inkas-pay no-lock
          where ub.inkas-pay.inkas-code = ub.inkas.inkas-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.inkas-pay.
        buffer-copy  ub.inkas-pay to dst.inkas-pay.
      end.
      for each ub.inkas-pay-desk no-lock
          where ub.inkas-pay-desk.inkas-code = ub.inkas.inkas-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.inkas-pay-desk.
        buffer-copy  ub.inkas-pay-desk to dst.inkas-pay-desk.
      end.
      for each ub.inkas-pay-wth no-lock
          where ub.inkas-pay-wth.inkas-code = ub.inkas.inkas-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.inkas-pay-wth.
        buffer-copy  ub.inkas-pay-wth to dst.inkas-pay-wth.
      end.
      for each ub.sale-doc no-lock
          where ub.sale-doc.inkas-code = ub.inkas.inkas-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.sale-doc.
        buffer-copy  ub.sale-doc to dst.sale-doc.
      end.
      if p-unload-history then do:
        for each ub.c-sale-doc no-lock
            where ub.c-sale-doc.inkas-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-sale-doc.
          buffer-copy  ub.c-sale-doc to dst.c-sale-doc.
        end.
        for each ub.c-inkas no-lock
            where ub.c-inkas.inkas-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          if ub.c-inkas.is-del = yes then do:
            return error substitute( "К существующей продаже &1 есть история его удаления", ub.c-inkas.inkas-code ) .
          end.
          create dst.c-inkas.
          buffer-copy ub.c-inkas to dst.c-inkas.
        end.
        for each ub.c-inkas-pay no-lock
            where ub.c-inkas-pay.inkas-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-inkas-pay.
          buffer-copy ub.c-inkas-pay to dst.c-inkas-pay.
        end.
        for each ub.c-inkas-pay-desk no-lock
            where ub.c-inkas-pay-desk.inkas-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-inkas-pay-desk.
          buffer-copy  ub.c-inkas-pay-desk to dst.c-inkas-pay-desk.
        end.
        for each ub.c-inkas-pay-wth no-lock
            where ub.c-inkas-pay-wth.inkas-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-inkas-pay-wth.
          buffer-copy  ub.c-inkas-pay-wth to dst.c-inkas-pay-wth.
        end.
        for each ub.c-chk-doc no-lock
            where ub.c-chk-doc.out-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-chk-doc.
          buffer-copy  ub.c-chk-doc to dst.c-chk-doc.
        end.
        for each ub.c-chk-gds no-lock
            where ub.c-chk-gds.out-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-chk-gds.
          buffer-copy  ub.c-chk-gds to dst.c-chk-gds.
        end.
        for each ub.c-chk-pay no-lock
            where ub.c-chk-pay.out-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-chk-pay.
          buffer-copy  ub.c-chk-pay to dst.c-chk-pay.
        end.
        for each ub.c-chk-discnt no-lock
            where ub.c-chk-discnt.out-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-chk-discnt.
          buffer-copy  ub.c-chk-discnt to dst.c-chk-discnt.
        end.
        for each ub.c-chk-doc-attr no-lock
            where ub.c-chk-doc-attr.out-code = ub.inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-chk-doc-attr.
          buffer-copy  ub.c-chk-doc-attr to dst.c-chk-doc-attr.
        end.
      end.
    end.
  end.
  return.
end procedure.
procedure rest-c-inkas :
  define input parameter p-inkas_obj-type as character no-undo .
  define input parameter p-inkas_obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    assign ind1 = 0
           fl   = "c-inkas".
    for each ub.c-inkas no-lock
        where ub.c-inkas.obj-type = p-inkas_obj-type
          and ub.c-inkas.obj-code = p-inkas_obj-code
          and ub.c-inkas.is-del = yes
    break
    by
    ub.c-inkas.inkas-code
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      create dst.c-inkas.
      buffer-copy ub.c-inkas to dst.c-inkas.
      if first-of(ub.c-inkas.inkas-code) then do:
        for each ub.c-inkas-pay no-lock
            where ub.c-inkas-pay.inkas-code = ub.c-inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-inkas-pay.
          buffer-copy ub.c-inkas-pay to dst.c-inkas-pay.
        end.
        for each ub.c-inkas-pay-desk no-lock
            where ub.c-inkas-pay-desk.inkas-code = ub.c-inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-inkas-pay-desk.
          buffer-copy ub.c-inkas-pay-desk to dst.c-inkas-pay-desk.
        end.
        for each ub.c-inkas-pay-wth no-lock
            where ub.c-inkas-pay-wth.inkas-code = ub.c-inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-inkas-pay-wth.
          buffer-copy ub.c-inkas-pay-wth to dst.c-inkas-pay-wth.
        end.
        for each ub.c-sale-doc no-lock
            where ub.c-sale-doc.inkas-code = ub.c-inkas.inkas-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.c-sale-doc.
          buffer-copy  ub.c-sale-doc to dst.c-sale-doc.
        end.
      end.
    end.
  end.
  return.
end procedure.
procedure rest-wth-doc :
  define input parameter p-wth-doc_obj-type as character no-undo .
  define input parameter p-wth-doc_obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
      assign ind1 = 0
             fl   = "wth-doc".
      for each ub.wth-doc no-lock
          where ub.wth-doc.obj-type = p-wth-doc_obj-type
            and ub.wth-doc.obj-code = p-wth-doc_obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        assign  ind1 = ind1 + 1.
        display ind1 count-str fl with frame ddd view-as dialog-box.
        create dst.wth-doc.
        buffer-copy  ub.wth-doc to dst.wth-doc.
        for each ub.wth-line no-lock
            where ub.wth-line.doc-code = ub.wth-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.wth-line.
          buffer-copy ub.wth-line to dst.wth-line.
        end.
        for each ub.wth-dtl no-lock
            where ub.wth-dtl.doc-code = ub.wth-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.wth-dtl.
          buffer-copy  ub.wth-dtl to dst.wth-dtl.
        end.
        for each ub.wth-doc-attr no-lock
            where ub.wth-doc-attr.doc-code = ub.wth-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.wth-doc-attr.
          buffer-copy  ub.wth-doc-attr to dst.wth-doc-attr.
        end.
        if ub.wth-doc.auto-fill = yes then do:
          if p-unload-history then do:
            for each ub.c-chk-doc no-lock
                where ub.c-chk-doc.out-code = ub.wth-doc.doc-code
            on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
            :
              create dst.c-chk-doc.
              buffer-copy  ub.c-chk-doc to dst.c-chk-doc.
            end.
            for each ub.c-chk-pay no-lock
                where ub.c-chk-pay.out-code = ub.wth-doc.doc-code
            on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
            :
              create dst.c-chk-pay.
              buffer-copy  ub.c-chk-pay to dst.c-chk-pay.
            end.
          end.
        end.
      end.
  end.
end procedure.
procedure rest-c-wth-doc :
  define input parameter p-wthd_obj-type as character no-undo .
  define input parameter p-wthd_obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    assign ind1 = 0
           fl   = "c-wth-doc".
    for each ub.c-wth-doc no-lock
        where ub.c-wth-doc.obj-type = p-wthd_obj-type
          and ub.c-wth-doc.obj-code = p-wthd_obj-code
          and ub.c-wth-doc.is-del = yes
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      create dst.c-wth-doc.
      buffer-copy ub.c-wth-doc to dst.c-wth-doc.
      for each ub.c-wth-line no-lock
          where ub.c-wth-line.doc-code = ub.c-wth-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-wth-line.
        buffer-copy ub.c-wth-line to dst.c-wth-line.
      end.
      for each ub.c-wth-dtl no-lock
          where ub.c-wth-dtl.doc-code = ub.c-wth-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-wth-dtl.
        buffer-copy ub.c-wth-dtl to dst.c-wth-dtl.
      end.
    end.
  end.
  return.
end procedure.
procedure rest-fin-doc :
  define input parameter p-fin-doc_obj-type as character no-undo .
  define input parameter p-fin-doc_obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
      assign ind1 = 0
             fl   = "fin-doc".
      for each ub.fin-doc no-lock
          where ub.fin-doc.obj-type = p-fin-doc_obj-type
            and ub.fin-doc.obj-code = p-fin-doc_obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        assign  ind1 = ind1 + 1.
        display ind1 count-str fl with frame ddd view-as dialog-box.
        create dst.fin-doc.
        buffer-copy  ub.fin-doc to dst.fin-doc.
        for each ub.fin-doc-attr no-lock
            where ub.fin-doc-attr.host-code     = ub.fin-doc.host-code
              and ub.fin-doc-attr.fin-doc-code  = ub.fin-doc.fin-doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.fin-doc-attr.
          buffer-copy ub.fin-doc-attr to dst.fin-doc-attr.
        end.
        for each ub.fin-doc-cor-acc-lk no-lock
            where ub.fin-doc-cor-acc-lk.host-code     = ub.fin-doc.host-code
              and ub.fin-doc-cor-acc-lk.fin-doc-code  = ub.fin-doc.fin-doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.fin-doc-cor-acc-lk.
          buffer-copy ub.fin-doc-cor-acc-lk to dst.fin-doc-cor-acc-lk.
          for each ub.fin-doc-cor-acc-lk-attr no-lock
              where ub.fin-doc-cor-acc-lk-attr.fin-code = ub.fin-doc-cor-acc-lk.fin-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.fin-doc-cor-acc-lk-attr.
            buffer-copy ub.fin-doc-cor-acc-lk-attr to dst.fin-doc-cor-acc-lk-attr.
          end.
        end.
        for each ub.fin-doc-schet-lk no-lock
            where ub.fin-doc-schet-lk.host-code     = ub.fin-doc.host-code
              and ub.fin-doc-schet-lk.fin-doc-code  = ub.fin-doc.fin-doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.fin-doc-schet-lk.
          buffer-copy ub.fin-doc-schet-lk to dst.fin-doc-schet-lk.
          for each ub.fin-doc-schet-lk-attr no-lock
              where ub.fin-doc-schet-lk-attr.code-schet = ub.fin-doc-schet-lk.code-schet
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.fin-doc-schet-lk-attr.
            buffer-copy ub.fin-doc-schet-lk-attr to dst.fin-doc-schet-lk-attr.
          end.
        end.
        for each ub.fin-doc-tax no-lock
            where ub.fin-doc-tax.host-code    = ub.fin-doc.host-code
              and ub.fin-doc-tax.fin-doc-code = ub.fin-doc.fin-doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.fin-doc-tax.
          buffer-copy ub.fin-doc-tax to dst.fin-doc-tax.
          for each ub.fin-doc-tax-attr no-lock
              where ub.fin-doc-tax-attr.fin-doc-code = ub.fin-doc-tax.fin-doc-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.fin-doc-tax-attr.
            buffer-copy ub.fin-doc-tax-attr to dst.fin-doc-tax-attr.
          end.
        end.
      end.
      for each ub.fin-doc-obj no-lock
          where ub.fin-doc-obj.obj-type = p-fin-doc_obj-type
            and ub.fin-doc-obj.obj-code = p-fin-doc_obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        assign  ind1 = ind1 + 1.
        display ind1 count-str fl with frame ddd view-as dialog-box.
        create dst.fin-doc-obj.
        buffer-copy  ub.fin-doc-obj to dst.fin-doc-obj.
        for each ub.fin-doc-obj-attr no-lock
            where ub.fin-doc-obj-attr.host-code     = ub.fin-doc-obj.host-code
              and ub.fin-doc-obj-attr.fin-doc-code  = ub.fin-doc-obj.fin-doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.fin-doc-obj-attr.
          buffer-copy ub.fin-doc-obj-attr to dst.fin-doc-obj-attr.
        end.
      end.
  end.
end procedure.
procedure rest-c-fin-doc :
  define input parameter p-find_obj-type as character no-undo .
  define input parameter p-find_obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    assign ind1 = 0
           fl   = "c-fin-doc".
    for each ub.c-fin-doc no-lock
        where ub.c-fin-doc.obj-type = p-find_obj-type
          and ub.c-fin-doc.obj-code = p-find_obj-code
          and ub.c-fin-doc.is-del = yes
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      create dst.c-fin-doc.
      buffer-copy ub.c-fin-doc to dst.c-fin-doc.
      for each ub.c-fin-doc-attr no-lock
          where ub.c-fin-doc-attr.host-code     = ub.c-fin-doc.host-code
            and ub.c-fin-doc-attr.fin-doc-code  = ub.c-fin-doc.fin-doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-fin-doc-attr.
        buffer-copy ub.c-fin-doc-attr to dst.c-fin-doc-attr.
      end.
      for each ub.c-fin-doc-tax no-lock
          where ub.c-fin-doc-tax.host-code     = ub.c-fin-doc.host-code
            and ub.c-fin-doc-tax.fin-doc-code  = ub.c-fin-doc.fin-doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.c-fin-doc-tax.
        buffer-copy ub.c-fin-doc-tax to dst.c-fin-doc-tax.
      end.
    end.
  end.
end procedure.
procedure rest-wth-doc-full :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
      assign ind1 = 0
             fl   = "wth-doc".
    for each ub.wth-doc no-lock
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      if can-find(first ub.wth-parts where ub.wth-parts.out-code = ub.wth-doc.doc-code) or
      can-find(first ub.clients where ub.clients.db-num = p-db-num
                                  and ub.clients.obj-type = ub.wth-doc.obj-type
                                  and ub.clients.obj-code = ub.wth-doc.obj-code
               )
      then do:
        assign  ind1 = ind1 + 1.
        display ind1 count-str fl with frame ddd view-as dialog-box.
        create dst.wth-doc.
        buffer-copy  ub.wth-doc to dst.wth-doc.
        for each ub.wth-line no-lock
            where ub.wth-line.doc-code = ub.wth-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.wth-line.
          buffer-copy ub.wth-line to dst.wth-line.
        end.
        for each ub.wth-dtl no-lock
            where ub.wth-dtl.doc-code = ub.wth-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.wth-dtl.
          buffer-copy  ub.wth-dtl to dst.wth-dtl.
        end.
        for each ub.wth-doc-attr no-lock
            where ub.wth-doc-attr.doc-code = ub.wth-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          create dst.wth-doc-attr.
          buffer-copy  ub.wth-doc-attr to dst.wth-doc-attr.
        end.
        if ub.wth-doc.auto-fill = yes then do:
          if p-unload-history then do:
            for each ub.c-chk-doc no-lock
                where ub.c-chk-doc.out-code = ub.wth-doc.doc-code
            on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
            :
              create dst.c-chk-doc.
              buffer-copy  ub.c-chk-doc to dst.c-chk-doc.
            end.
            for each ub.c-chk-pay no-lock
                where ub.c-chk-pay.out-code = ub.wth-doc.doc-code
            on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
            :
              create dst.c-chk-pay.
              buffer-copy  ub.c-chk-pay to dst.c-chk-pay.
            end.
          end.
        end.
      end.
    end.
  end.
end.
procedure rest-c-wth-doc-full :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
      assign ind1 = 0
             fl   = "c-wth-doc".
    for each ub.c-wth-doc no-lock  where
       ub.c-wth-doc.is-del = yes
    break by
    ub.c-wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      if first-of(ub.c-wth-doc.doc-code) then do:
        if can-find(first ub.c-wth-parts where ub.c-wth-parts.out-code = ub.c-wth-doc.doc-code) or
        can-find(first ub.clients where ub.clients.db-num = p-db-num
                                    and ub.clients.obj-type = ub.c-wth-doc.obj-type
                                    and ub.clients.obj-code = ub.c-wth-doc.obj-code
                )
        then do:
          assign  ind1 = ind1 + 1.
          display ind1 count-str fl with frame ddd view-as dialog-box.
          create dst.c-wth-doc.
          buffer-copy  ub.c-wth-doc to dst.c-wth-doc.
          for each ub.c-wth-line no-lock
              where ub.c-wth-line.doc-code = ub.c-wth-doc.doc-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-wth-line.
            buffer-copy ub.c-wth-line to dst.c-wth-line.
          end.
          for each ub.c-wth-dtl no-lock
              where ub.c-wth-dtl.doc-code = ub.c-wth-doc.doc-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-wth-dtl.
            buffer-copy  ub.c-wth-dtl to dst.c-wth-dtl.
          end.
        end.
      end.
    end.
  end.
end.
procedure rest-arh-wth-tot :
  define input parameter p-wth-arh_obj-type as character no-undo .
  define input parameter p-wth-arh_obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
      assign ind1 = 0
             fl   = "arh-wth-tot".
      for each ub.arh-wth-tot no-lock
          where ub.arh-wth-tot.obj-type = p-wth-arh_obj-type
            and ub.arh-wth-tot.obj-code = p-wth-arh_obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        assign  ind1 = ind1 + 1.
        display ind1 count-str fl with frame ddd view-as dialog-box.
        create dst.arh-wth-tot.
        buffer-copy  ub.arh-wth-tot to dst.arh-wth-tot.
      end.
  end.
end procedure.
procedure rest-arh-wth-w-p :
  define input parameter p-wth-arh_obj-type as character no-undo .
  define input parameter p-wth-arh_obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
      assign ind1 = 0
             fl   = "arh-wth-w-p".
      for each ub.arh-wth-w-p no-lock
          where ub.arh-wth-w-p.obj-type = p-wth-arh_obj-type
            and ub.arh-wth-w-p.obj-code = p-wth-arh_obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        assign  ind1 = ind1 + 1.
        display ind1 count-str fl with frame ddd view-as dialog-box.
        create dst.arh-wth-w-p.
        buffer-copy  ub.arh-wth-w-p to dst.arh-wth-w-p.
      end.
  end.
end procedure.
procedure rest-price-doc :
  define input parameter p-price-doc_obj-type as character no-undo .
  define input parameter p-price-doc_obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    assign
      ind1 = 0
      fl   = 'price-doc':U
    .
    for each ub.price-doc no-lock
      where ub.price-doc.obj-type = p-price-doc_obj-type
        and ub.price-doc.obj-code = p-price-doc_obj-code
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      find first ub.batchprocess no-lock
        where ub.batchprocess.bp_type     = 'prc':U
          and ub.batchprocess.bp_status   = 'N':U
          and ub.batchprocess.charkey_one = ub.price-doc.doc-num
        no-error .
      if available ub.batchprocess
      then do:
        create dst.batchprocess .
        buffer-copy ub.batchprocess to dst.batchprocess .
      end.
      if ub.db.unload-arch = true
      then do:
        find first ub.batchprocess no-lock
          where ub.batchprocess.bp_type     = 'arh':U
            and ub.batchprocess.bp_status   = 'N':U
            and ub.batchprocess.charkey_one = ub.price-doc.doc-num
          no-error .
        if available ub.batchprocess
        then do:
          create dst.batchprocess .
          buffer-copy ub.batchprocess to dst.batchprocess .
        end.
        find first ub.batchprocess no-lock
          where ub.BatchProcess.bp_type     = 'ahsp':U
            and ub.BatchProcess.bp_status   = 'N':U
            and ub.batchprocess.charkey_one = ub.price-doc.doc-num
          no-error .
        if available ub.batchprocess
        then do:
          create dst.batchprocess .
          buffer-copy ub.batchprocess to dst.batchprocess .
        end.
      end.
      if ub.db.unload-aht = true
      then do:
        find first ub.batchprocess no-lock
          where ub.batchprocess.bp_type     = 'aht':U
            and ub.batchprocess.bp_status   = 'N':U
            and ub.batchprocess.charkey_one = ub.price-doc.doc-num
          no-error .
        if available ub.batchprocess
        then do:
          create dst.batchprocess .
          buffer-copy ub.batchprocess to dst.batchprocess .
        end.
      end.
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      for each ub.price-list no-lock
        where ub.price-list.doc-num = ub.price-doc.doc-num
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.price-list.
        buffer-copy ub.price-list to dst.price-list.
      end.
      for each ub.price-list-attr no-lock
        where ub.price-list-attr.doc-num = ub.price-doc.doc-num
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.price-list-attr.
        buffer-copy ub.price-list-attr to dst.price-list-attr.
      end.
      for each ub.parts no-lock
        where ub.parts.out-code = ub.price-doc.doc-num
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        run process-parts in this-procedure .
      end.
      create dst.price-doc.
      buffer-copy  ub.price-doc to dst.price-doc.
    end.
  end.
  return.
end procedure.
procedure rest-chk :
  define input parameter p-chk_obj-type as character no-undo .
  define input parameter p-chk_obj-code as integer   no-undo .
  define buffer buf_cash-desk for ub.caSH-DESK.
  define variable V-IS-magia as logical no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    assign ind1 = 0
           fl   = "chk-doc".
    find first buf_cash-desk no-lock where
              buf_cash-desk.obj-code = p-chk_obj-code
          AND buf_cash-desk.db-num = p-db-num
          AND buf_cash-desk.pos-type = 'MAGIA-XML':U no-error .
    if available buf_cash-desk then do:
      assign
      v-is-magia = yes
      .
    end.
    for each ub.chk-doc no-lock
        where ub.chk-doc.obj-type = p-chk_obj-type
          and ub.chk-doc.obj-code = p-chk_obj-code
        use-index chk-out
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      if v-is-magia then do:
        find first temp-cash-desk where
                temp-cash-desk.cash-num = ub.chk-doc.pay-desk no-error.
        if not available temp-cash-desk then do:
          create temp-cash-desk.
          assign
          temp-cash-desk.cash-num = ub.chk-doc.pay-desk
          temp-cash-desk.last-date = ub.chk-doc.chk-date
          temp-cash-desk.last-time = ub.chk-doc.chk-time
          .
        end.
        else do:
          assign
          temp-cash-desk.last-time     = if temp-cash-desk.last-date < ub.chk-doc.chk-date
                                          or (temp-cash-desk.last-date = ub.chk-doc.chk-date
                                              and
                                              temp-cash-desk.last-time < ub.chk-doc.chk-time)
                                          then ub.chk-doc.chk-time
                                          else temp-cash-desk.last-time
          temp-cash-desk.last-date     = (if temp-cash-desk.last-date < ub.chk-doc.chk-date
                                          then ub.chk-doc.chk-date
                                          else temp-cash-desk.last-date)
          .
        end.
      end.
      for each ub.marking-chk no-lock
          where ub.marking-chk.doc-code = ub.chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.marking-chk.
        buffer-copy  ub.marking-chk to dst.marking-chk.
      end.
      for each ub.chk-gds no-lock
          where ub.chk-gds.doc-code = ub.chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.chk-gds.
        buffer-copy  ub.chk-gds to dst.chk-gds.
      end.
      for each ub.chk-pay no-lock
          where ub.chk-pay.doc-code = ub.chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.chk-pay.
        buffer-copy  ub.chk-pay to dst.chk-pay.
      end.
      for each ub.chk-discnt no-lock
          where ub.chk-discnt.doc-code = ub.chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.chk-discnt.
        buffer-copy  ub.chk-discnt to dst.chk-discnt.
      end.
      for each ub.chk-doc-attr no-lock
          where ub.chk-doc-attr.doc-code = ub.chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create dst.chk-doc-attr.
        buffer-copy  ub.chk-doc-attr to dst.chk-doc-attr.
      end.
      create dst.chk-doc.
      buffer-copy  ub.chk-doc to dst.chk-doc.
    end.
    if v-is-magia then do:
      for each temp-cash-desk:
        find first buf_cash-desk no-lock where
                 buf_cash-desk.db-num = p-db-num
             AND buf_cash-desk.obj-code = p-chk_obj-code
             AND buf_cash-desk.pos-type = 'MAGIA-XML':U
             AND buf_cash-desk.cash-num = temp-cash-desk.cash-num no-error .
        if available buf_cash-desk then
        run cd-attr-write in this-procedure (
                                                input p-db-num
                                              ,input p-chk_obj-code
                                              ,input 'MAGIA-XML':U
                                              ,input temp-cash-desk.cash-num
                                              ,input 'MAGIA-XML_operative':U
                                              ,input 'last-check-date-time':U
                                              ,input (cd-attr-CD-DatetoString (temp-cash-desk.last-date) + chr(32)  +  string(temp-cash-desk.last-time, "HH:MM:SS":U)
                                                    )
                                              ,input ?
                                              ,input 0.0
                                              ,input 0
                                              ,input no
                                              ) no-error.
      end.
    end.
    if p-unload-history then do:
      assign ind1 = 0
            fl   = "c-chk-doc".
      for each ub.c-chk-doc no-lock
          where ub.c-chk-doc.obj-type = p-chk_obj-type
            and ub.c-chk-doc.obj-code = p-chk_obj-code
            and ub.c-chk-doc.is-del = yes
          use-index idel
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        if ub.c-chk-doc.out-code <> ? then next.
        assign  ind1 = ind1 + 1.
        display ind1 count-str fl with frame ddd view-as dialog-box.
        for each ub.c-chk-gds no-lock
            where ub.c-chk-gds.doc-code = ub.c-chk-doc.doc-code
              and ub.c-chk-gds.chip-num = ub.c-chk-doc.chip-num
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          if ub.c-chk-gds.out-code <> ? then next.
          create dst.c-chk-gds.
          buffer-copy  ub.c-chk-gds to dst.c-chk-gds.
        end.
        for each ub.c-chk-pay no-lock
            where ub.c-chk-pay.doc-code = ub.c-chk-doc.doc-code
              and ub.c-chk-pay.chip-num = ub.c-chk-doc.chip-num
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          if ub.c-chk-pay.out-code <> ? then next.
          create dst.c-chk-pay.
          buffer-copy  ub.c-chk-pay to dst.c-chk-pay.
        end.
        for each ub.c-chk-discnt no-lock
            where ub.c-chk-discnt.doc-code = ub.c-chk-doc.doc-code
              and ub.c-chk-discnt.chip-num = ub.c-chk-doc.chip-num
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          if ub.c-chk-discnt.out-code <> ? then next.
          create dst.c-chk-discnt.
          buffer-copy  ub.c-chk-discnt to dst.c-chk-discnt.
        end.
        for each ub.c-chk-doc-attr no-lock
            where ub.c-chk-doc-attr.doc-code = ub.c-chk-doc.doc-code
              and ub.c-chk-doc-attr.chip-num = ub.c-chk-doc.chip-num
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          if ub.c-chk-doc-attr.out-code <> ? then next.
          create dst.c-chk-doc-attr.
          buffer-copy  ub.c-chk-doc-attr to dst.c-chk-doc-attr.
        end.
        create dst.c-chk-doc.
        buffer-copy  ub.c-chk-doc to dst.c-chk-doc.
      end.
    end.
  end.
  return.
end procedure.
procedure rest-tcc :
  define input  parameter p-db-num      as integer   no-undo .
  define input  parameter p-type-unload as character no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define buffer buf-ub_db-rec-attr  for ub.db-rec-attr .
    define buffer buf-dst_db-rec-attr for dst.db-rec-attr .
    define buffer buf-src_db-rec-attr for src.db-rec-attr .
    define buffer buf_route       for dst.route .
    define variable v-today       as date      no-undo.
    define variable v-time        as integer   no-undo.
    define variable v-command      as character no-undo .
    define variable v-answer-code  as integer   no-undo .
    define variable v-answer-msg   as character no-undo .
    run fill-two-commit-command in this-procedure.
    find first temp_db-rec-attr
      where temp_db-rec-attr.db-num = ?
      no-error .
    if available temp_db-rec-attr then do:
      return error substitute( "Нельзя выгрузить БД!&1Есть незавершенные распределенные команды при которых выгрузка недопустима!", chr(10) ).
    end.
    run cur-time in this-procedure
      ( output v-today
       ,output v-time
      ).
    run adm\comcom.p (p-db-num).
    for each temp_db-rec-attr
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      if lookup( string( p-db-num ), temp_db-rec-attr.db-list, ",":U ) > 0 then do:
        if temp_db-rec-attr.attr-type = "execution":U
          or temp_db-rec-attr.attr-type = "recover":U
        then do:
          assign
            v-answer-code = 0
            v-answer-msg  = ""
          .
        end.
        else do:
          assign
            v-answer-code = 1
            v-answer-msg  = substitute( "Из-за выгрузки УБД &1 нельзя провести проверку.", p-db-num )
          .
          create buf-dst_db-rec-attr.
          buffer-copy temp_db-rec-attr to buf-dst_db-rec-attr
            assign
              buf-dst_db-rec-attr.db-num             = p-db-num
              buf-dst_db-rec-attr.attr-value-logical = yes
          .
        end.
        find first buf-ub_db-rec-attr no-lock
          where buf-ub_db-rec-attr.db-num       = p-db-num
            and buf-ub_db-rec-attr.uniq-key-rec = temp_db-rec-attr.uniq-key-rec
            and buf-ub_db-rec-attr.attr-code    = temp_db-rec-attr.attr-code
          no-error .
        if not available buf-ub_db-rec-attr then do:
          create buf-ub_db-rec-attr.
          buffer-copy temp_db-rec-attr to buf-ub_db-rec-attr
            assign
              buf-ub_db-rec-attr.db-num             = p-db-num
              buf-ub_db-rec-attr.attr-value-logical = yes
          .
          if p-type-unload = 'unload-copy':U then do:
            create buf-src_db-rec-attr.
            buffer-copy temp_db-rec-attr to buf-src_db-rec-attr
              assign
                buf-src_db-rec-attr.db-num             = p-db-num
                buf-src_db-rec-attr.attr-value-logical = yes
            .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure display-with-frame :
  define input parameter p-count-str      as character        no-undo.
  define input parameter p-table-name     as character        no-undo.
  define input parameter p-index          as integer          no-undo.
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
      display
          p-count-str     @ count-str
          p-table-name    @ fl
          p-index         @ ind1
      with frame ddd
      view-as dialog-box.
  end.
end procedure.
procedure rest-mpl :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    assign ind1 = 0.
           fl   = "price-list-type".
    for each ub.price-list-type no-lock
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      create dst.price-list-type.
      buffer-copy  ub.price-list-type to dst.price-list-type.
          for each ub.price-list-type-attr no-lock
             where ub.price-list-type-attr.plt-id     = ub.price-list-type.plt-id     and
                   ub.price-list-type-attr.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-list-type-attr.
            buffer-copy ub.price-list-type-attr to dst.price-list-type-attr.
          end.
          for each ub.price-list-type-cash-pay no-lock
             where ub.price-list-type-cash-pay.plt-id     = ub.price-list-type.plt-id     and
                   ub.price-list-type-cash-pay.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-list-type-cash-pay.
            buffer-copy ub.price-list-type-cash-pay to dst.price-list-type-cash-pay.
          end.
          for each ub.price-list-type-cassa no-lock
             where ub.price-list-type-cassa.plt-id     = ub.price-list-type.plt-id     and
                   ub.price-list-type-cassa.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-list-type-cassa.
            buffer-copy ub.price-list-type-cassa to dst.price-list-type-cassa.
          end.
          for each ub.price-list-type-gds-grp no-lock
             where ub.price-list-type-gds-grp.plt-id     = ub.price-list-type.plt-id     and
                   ub.price-list-type-gds-grp.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-list-type-gds-grp.
            buffer-copy ub.price-list-type-gds-grp to dst.price-list-type-gds-grp.
          end.
          for each ub.price-list-type-pay-type no-lock
             where ub.price-list-type-pay-type.plt-id     = ub.price-list-type.plt-id     and
                   ub.price-list-type-pay-type.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-list-type-pay-type.
            buffer-copy ub.price-list-type-pay-type to dst.price-list-type-pay-type.
          end.
          if p-unload-history then do:
          for each ub.c-price-list-type no-lock
             where ub.c-price-list-type.plt-id     = ub.price-list-type.plt-id     and
                   ub.c-price-list-type.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-list-type.
            buffer-copy ub.c-price-list-type to dst.c-price-list-type.
          end.
          for each ub.c-price-list-type-attr no-lock
             where ub.c-price-list-type-attr.plt-id     = ub.price-list-type.plt-id     and
                   ub.c-price-list-type-attr.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-list-type-attr.
            buffer-copy ub.c-price-list-type-attr to dst.c-price-list-type-attr.
          end.
          for each ub.c-price-list-type-cash-pay no-lock
             where ub.c-price-list-type-cash-pay.plt-id     = ub.price-list-type.plt-id     and
                   ub.c-price-list-type-cash-pay.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-list-type-cash-pay.
            buffer-copy ub.c-price-list-type-cash-pay to dst.c-price-list-type-cash-pay.
          end.
          for each ub.c-price-list-type-cassa no-lock
             where ub.c-price-list-type-cassa.plt-id     = ub.price-list-type.plt-id     and
                   ub.c-price-list-type-cassa.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-list-type-cassa.
            buffer-copy ub.c-price-list-type-cassa to dst.c-price-list-type-cassa.
          end.
          for each ub.c-price-list-type-gds-grp no-lock
             where ub.c-price-list-type-gds-grp.plt-id     = ub.price-list-type.plt-id     and
                   ub.c-price-list-type-gds-grp.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-list-type-gds-grp.
            buffer-copy ub.c-price-list-type-gds-grp to dst.c-price-list-type-gds-grp.
          end.
          for each ub.c-price-list-type-pay-type no-lock
             where ub.c-price-list-type-pay-type.plt-id     = ub.price-list-type.plt-id     and
                   ub.c-price-list-type-pay-type.plt-db-num = ub.price-list-type.plt-db-num
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-list-type-pay-type.
            buffer-copy ub.c-price-list-type-pay-type to dst.c-price-list-type-pay-type.
          end.
        end.
    end.
    assign ind1 = 0.
           fl   = "price-doc-forming".
    for each ub.price-doc-forming no-lock
        where ub.price-doc-forming.stts = integer('3':U)
          or  ub.price-doc-forming.stts = integer('4':U)
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign  ind1 = ind1 + 1.
      display ind1 count-str fl with frame ddd view-as dialog-box.
      create dst.price-doc-forming.
      buffer-copy  ub.price-doc-forming to dst.price-doc-forming.
          for each ub.price-doc-forming-attr no-lock
             where ub.price-doc-forming-attr.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.price-doc-forming-attr.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.price-doc-forming-attr.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.price-doc-forming-attr.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-doc-forming-attr.
            buffer-copy ub.price-doc-forming-attr to dst.price-doc-forming-attr.
          end.
          for each ub.price-doc-forming-gds no-lock
             where ub.price-doc-forming-gds.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.price-doc-forming-gds.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.price-doc-forming-gds.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.price-doc-forming-gds.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-doc-forming-gds.
            buffer-copy ub.price-doc-forming-gds to dst.price-doc-forming-gds.
          end.
          for each ub.price-doc-forming-gds-qnty no-lock
             where ub.price-doc-forming-gds-qnty.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.price-doc-forming-gds-qnty.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.price-doc-forming-gds-qnty.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.price-doc-forming-gds-qnty.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-doc-forming-gds-qnty.
            buffer-copy ub.price-doc-forming-gds-qnty to dst.price-doc-forming-gds-qnty.
          end.
          for each ub.price-doc-forming-gds-sum no-lock
             where ub.price-doc-forming-gds-sum.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.price-doc-forming-gds-sum.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.price-doc-forming-gds-sum.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.price-doc-forming-gds-sum.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-doc-forming-gds-sum.
            buffer-copy ub.price-doc-forming-gds-sum to dst.price-doc-forming-gds-sum.
          end.
          for each ub.price-doc-forming-gds-tnv no-lock
             where ub.price-doc-forming-gds-tnv.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.price-doc-forming-gds-tnv.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.price-doc-forming-gds-tnv.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.price-doc-forming-gds-tnv.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-doc-forming-gds-tnv.
            buffer-copy ub.price-doc-forming-gds-tnv to dst.price-doc-forming-gds-tnv.
          end.
          if p-unload-history then do:
          for each ub.c-price-doc-forming-attr no-lock
             where ub.c-price-doc-forming-attr.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.c-price-doc-forming-attr.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.c-price-doc-forming-attr.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.c-price-doc-forming-attr.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-doc-forming-attr.
            buffer-copy ub.c-price-doc-forming-attr to dst.c-price-doc-forming-attr.
          end.
          for each ub.c-price-doc-forming-gds no-lock
             where ub.c-price-doc-forming-gds.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.c-price-doc-forming-gds.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.c-price-doc-forming-gds.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.c-price-doc-forming-gds.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-doc-forming-gds.
            buffer-copy ub.c-price-doc-forming-gds to dst.c-price-doc-forming-gds.
          end.
          for each ub.c-price-doc-forming-gds-qnty no-lock
             where ub.c-price-doc-forming-gds-qnty.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.c-price-doc-forming-gds-qnty.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.c-price-doc-forming-gds-qnty.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.c-price-doc-forming-gds-qnty.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-doc-forming-gds-qnty.
            buffer-copy ub.c-price-doc-forming-gds-qnty to dst.c-price-doc-forming-gds-qnty.
          end.
          for each ub.c-price-doc-forming-gds-sum no-lock
             where ub.c-price-doc-forming-gds-sum.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.c-price-doc-forming-gds-sum.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.c-price-doc-forming-gds-sum.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.c-price-doc-forming-gds-sum.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-doc-forming-gds-sum.
            buffer-copy ub.c-price-doc-forming-gds-sum to dst.c-price-doc-forming-gds-sum.
          end.
          for each ub.c-price-doc-forming-gds-tnv no-lock
             where ub.c-price-doc-forming-gds-tnv.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.c-price-doc-forming-gds-tnv.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.c-price-doc-forming-gds-tnv.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.c-price-doc-forming-gds-tnv.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-doc-forming-gds-tnv.
            buffer-copy ub.c-price-doc-forming-gds-tnv to dst.c-price-doc-forming-gds-tnv.
          end.
          for each ub.c-price-doc-forming no-lock
             where ub.c-price-doc-forming.plt-id     = ub.price-doc-forming.plt-id     and
                   ub.c-price-doc-forming.plt-db-num = ub.price-doc-forming.plt-db-num and
                   ub.c-price-doc-forming.pdf-id     = ub.price-doc-forming.pdf-id     and
                   ub.c-price-doc-forming.pdf-db     = ub.price-doc-forming.pdf-db
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.c-price-doc-forming.
            buffer-copy ub.c-price-doc-forming to dst.c-price-doc-forming.
          end.
       end.
    end.
  end.
  return.
end procedure.
procedure rest-assort-matrix :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
  disable triggers for load of ub.assortment-matrix.
  disable triggers for load of ub.assortment-matrix-attr.
  disable triggers for load of ub.assortment-matrix-goods.
  disable triggers for dump of ub.assortment-matrix.
  disable triggers for dump of ub.assortment-matrix-attr.
  disable triggers for dump of ub.assortment-matrix-goods.
  disable triggers for load of dst.assortment-matrix.
  disable triggers for load of dst.assortment-matrix-attr.
  disable triggers for load of dst.assortment-matrix-goods.
  disable triggers for dump of dst.assortment-matrix.
  disable triggers for dump of dst.assortment-matrix-attr.
  disable triggers for dump of dst.assortment-matrix-goods.
  for each ub.assortment-matrix no-lock where
           ub.assortment-matrix.obj-type = p-obj-type and
           ub.assortment-matrix.obj-code = p-obj-code
           on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
           :
          create dst.assortment-matrix .
          buffer-copy ub.assortment-matrix to dst.assortment-matrix.
          for each ub.assortment-matrix-goods no-lock where
                  ub.assortment-matrix-goods.asmt-id = ub.assortment-matrix.asmt-id  and
                  ub.assortment-matrix-goods.db-num  = ub.assortment-matrix.db-num
                  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
                  :
                  create dst.assortment-matrix-goods .
                  buffer-copy ub.assortment-matrix-goods to dst.assortment-matrix-goods .
          end.
          for each ub.assortment-matrix-attr no-lock where
                  ub.assortment-matrix-attr.asmt-id = ub.assortment-matrix.asmt-id  and
                  ub.assortment-matrix-attr.db-num  = ub.assortment-matrix.db-num
                  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
                  :
                  create dst.assortment-matrix-attr .
                  buffer-copy ub.assortment-matrix-attr to dst.assortment-matrix-attr .
          end.
  end.
end.
end procedure.
procedure rest-season :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
  disable triggers for load of ub.season.
  disable triggers for load of ub.season-attr.
  disable triggers for load of ub.gds-season.
  disable triggers for load of ub.gds-season-attr.
  disable triggers for dump of ub.season.
  disable triggers for dump of ub.season-attr.
  disable triggers for dump of ub.gds-season.
  disable triggers for dump of ub.gds-season-attr.
  disable triggers for load of dst.season.
  disable triggers for load of dst.season-attr.
  disable triggers for load of dst.gds-season.
  disable triggers for load of dst.gds-season-attr.
  disable triggers for dump of dst.season.
  disable triggers for dump of dst.season-attr.
  disable triggers for dump of dst.gds-season.
  disable triggers for dump of dst.gds-season-attr.
  for each ub.season no-lock:
    find first ub.season-attr no-lock where ub.season-attr.sea-code =  ub.season.sea-code
      and ub.season-attr.db-num = ub.season.db-num
      and ub.season-attr.attr-code = 'sea-obj':U no-error.
    if (available ub.season-attr
        and ub.season-attr.attr-value = p-obj-type + string (p-obj-code))
        or (not available ub.season-attr and p-obj-code = ?)
    then do:
      for each ub.season-attr no-lock where ub.season-attr.sea-code = ub.season.sea-code
        and ub.season-attr.db-num = ub.season.db-num:
        create dst.season-attr .
        buffer-copy ub.season-attr to dst.season-attr .
      end.
      for each ub.gds-season no-lock where ub.gds-season.sea-code = ub.season.sea-code
        and ub.gds-season.db-num = ub.season.db-num:
        create dst.gds-season .
        buffer-copy ub.gds-season to dst.gds-season .
      end.
      for each ub.gds-season-attr no-lock where ub.gds-season-attr.sea-code = ub.season.sea-code
          and ub.gds-season-attr.db-num = ub.season.db-num:
        create dst.gds-season-attr .
        buffer-copy ub.gds-season-attr to dst.gds-season-attr .
      end.
      create dst.season.
      buffer-copy ub.season to dst.season.
    end.
  end.
end.
end procedure.
procedure rest-fin-ob :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
  for each ub.fin-ob no-lock where
           ub.fin-ob.obj-type = p-obj-type and
           ub.fin-ob.obj-code = p-obj-code and
           ub.fin-ob.doc-type = 'при':U  and
           ub.fin-ob.status_  = 'факт':U
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
          for each ub.fin-ob-tax no-lock where
                   ub.fin-ob-tax.host-code = ub.fin-ob.host-code and
                   ub.fin-ob-tax.doc-code = ub.fin-ob.doc-code
                   on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
                   :
                    create dst.fin-ob-tax.
                    buffer-copy ub.fin-ob-tax to dst.fin-ob-tax.
          end.
          for each ub.fin-ob-attr no-lock where
                   ub.fin-ob-attr.host-code = ub.fin-ob.host-code and
                   ub.fin-ob-attr.doc-code  = ub.fin-ob.doc-code
                   on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
                   :
                    create dst.fin-ob-attr.
                    buffer-copy ub.fin-ob-attr to dst.fin-ob-attr.
          end.
          for each ub.fin-ob-trn no-lock where
                   ub.fin-ob-trn.host-code = ub.fin-ob.host-code and
                   ub.fin-ob-trn.doc-code  = ub.fin-ob.doc-code
                   on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
                   :
                    create dst.fin-ob-trn.
                    buffer-copy ub.fin-ob-trn to dst.fin-ob-trn.
          end.
          for each ub.fin-gds-part no-lock where
                   ub.fin-gds-part.host-code = ub.fin-ob.host-code and
                   ub.fin-gds-part.fin-ob-code  = ub.fin-ob.doc-code
                   on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
                   :
                    create dst.fin-gds-part.
                    buffer-copy ub.fin-gds-part to dst.fin-gds-part.
          end.
        create dst.fin-ob.
        buffer-copy ub.fin-ob to dst.fin-ob.
  end.
  end.
end procedure.
procedure rest-price-all :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
  for each ub.price-all no-lock where
           ub.price-all.obj-type = p-obj-type and
           ub.price-all.obj-code = p-obj-code
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            create dst.price-all.
            buffer-copy ub.price-all to dst.price-all.
  end.
  end.
end procedure.
procedure rest-add-doc :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
  for each ub.add-doc no-lock where
           ub.add-doc.obj-type = p-obj-type and
           ub.add-doc.obj-code = p-obj-code and
           ( ub.add-doc.status_  = 'факт':U or
           ub.add-doc.status_    = 'закрыт':U )
          on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
      for each ub.add-line no-lock where
               ub.add-line.doc-code = ub.add-doc.doc-code
              on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
              :
            create dst.add-line.
            buffer-copy ub.add-line to dst.add-line.
      end.
      for each ub.add-trn no-lock where
               ub.add-trn.doc-code = ub.add-doc.doc-code
              on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
              :
            create dst.add-trn.
            buffer-copy ub.add-trn to dst.add-trn.
      end.
      create dst.add-doc.
      buffer-copy ub.add-doc to dst.add-doc.
  end.
  end.
end procedure.
procedure rest-cash-book private :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
      for each ub.CashBook no-lock
      on error  undo, return error substitute( "&1 (CashBook). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (CashBook). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (CashBook). endkey", vss-workfile )
      :
        create dst.CashBook.
        buffer-copy ub.CashBook to dst.CashBook .
      end.
      for each ub.CashBookAttr no-lock
      on error  undo, return error substitute( "&1 (CashBookAttr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (CashBookAttr). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (CashBookAttr). endkey", vss-workfile )
      :
        create dst.CashBookAttr.
        buffer-copy ub.CashBookAttr to dst.CashBookAttr .
      end.
      for each ub.CashBookRule no-lock
      on error  undo, return error substitute( "&1 (CashBookRule). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (CashBookRule). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (CashBookRule). endkey", vss-workfile )
      :
        create dst.CashBookRule.
        buffer-copy ub.CashBookRule to dst.CashBookRule .
      end.
      for each ub.CashBookRuleAttr no-lock
      on error  undo, return error substitute( "&1 (CashBookRuleAttr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (CashBookRuleAttr). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (CashBookRuleAttr). endkey", vss-workfile )
      :
          create dst.CashBookRuleAttr.
          buffer-copy ub.CashBookRuleAttr to dst.CashBookRuleAttr .
      end.
      for each ub.OperServ no-lock
      on error  undo, return error substitute( "&1 (OperServ). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (OperServ). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (OperServ). endkey", vss-workfile )
      :
        create dst.OperServ.
        buffer-copy ub.OperServ to dst.OperServ .
      end.
      for each ub.OperServAttr no-lock
      on error  undo, return error substitute( "&1 (OperServAttr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1 (OperServAttr). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (OperServAttr). endkey", vss-workfile )
      :
        create dst.OperServAttr.
        buffer-copy ub.OperServAttr to dst.OperServAttr .
      end.
  end.
end procedure.
procedure rest-promo-action private :
   do
      on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      on stop   undo, return error substitute( "&1. stop", vss-workfile )
      on endkey undo, return error substitute( "&1. endkey", vss-workfile )
      :
      for each dst.PromoAction:
         delete dst.PromoAction .
      end.
      for each dst.PromoAttr:
         delete dst.PromoAttr .
      end.
      for each dst.promo-schedule:
         delete dst.promo-schedule .
      end.
      for each dst.promo-schedule-week:
         delete dst.promo-schedule-week .
      end.
      for each dst.PromoCriterion:
         delete dst.PromoCriterion .
      end.
      for each dst.PromoGift:
         delete dst.PromoGift .
      end.
      for each dst.PromoGoods:
         delete dst.PromoGoods .
      end.
      for each dst.PromoObject:
         delete dst.PromoObject .
      end.
      for each ub.PromoAction no-lock
         where ub.PromoAction.end-date < today and ub.PromoAction.Status_ <> 2
         on error  undo, return error substitute( "&1 (PromoAction). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
         on stop   undo, return error substitute( "&1 (PromoAction). stop", vss-workfile )
         on endkey undo, return error substitute( "&1 (PromoAction). endkey", vss-workfile )
         :
         create dst.PromoAction.
         buffer-copy ub.PromoAction to dst.PromoAction .
         for each ub.PromoAttr no-lock
            where ub.PromoAttr.tablename = "PromoAction" and
            ub.PromoAttr.attr-code = "promo-message" and
            ub.PromoAction.id = int64(entry(1,ub.PromoAttr.p-key,chr(3))) and
            ub.PromoAction.db-num = integer(entry(2,ub.PromoAttr.p-key,chr(3)))
            on error  undo, return error substitute( "&1 (PromoAttr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (PromoAttr). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (PromoAttr). endkey", vss-workfile )
            :
            create dst.PromoAttr.
            buffer-copy ub.PromoAttr to dst.PromoAttr .
         end.
         for each ub.promo-schedule no-lock
            where ub.promo-schedule.db-num = ub.PromoAction.db-num and
            ub.promo-schedule.id = ub.PromoAction.promosched-id
            on error  undo, return error substitute( "&1 (promo-schedule). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (promo-schedule). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (promo-schedule). endkey", vss-workfile )
            :
            create dst.promo-schedule.
            buffer-copy ub.promo-schedule to dst.promo-schedule .
         end.
         for each ub.promo-schedule-week no-lock
            where ub.promo-schedule-week.db-num = ub.PromoAction.db-num and
            ub.promo-schedule-week.promosched-id = ub.PromoAction.promosched-id
            on error  undo, return error substitute( "&1 (promo-schedule-week). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (promo-schedule-week). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (promo-schedule-week). endkey", vss-workfile )
            :
            create dst.promo-schedule-week.
            buffer-copy ub.promo-schedule-week to dst.promo-schedule-week .
         end.
         for each ub.PromoCriterion no-lock
            where ub.PromoCriterion.db-num = ub.PromoAction.db-num and
            ub.PromoCriterion.idAction = ub.PromoAction.id
            on error  undo, return error substitute( "&1 (PromoCriterion). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (PromoCriterion). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (PromoCriterion). endkey", vss-workfile )
            :
            create dst.PromoCriterion.
            buffer-copy ub.PromoCriterion to dst.PromoCriterion .
         end.
         for each ub.PromoGift no-lock
            where ub.PromoGift.db-num = ub.PromoAction.db-num and
            ub.PromoGift.idaction = ub.PromoAction.id
            on error  undo, return error substitute( "&1 (PromoGift). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (PromoGift). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (PromoGift). endkey", vss-workfile )
            :
            create dst.PromoGift.
            buffer-copy ub.PromoGift to dst.PromoGift .
         end.
         for each ub.PromoGoods no-lock
            where ub.PromoGoods.db-num = ub.PromoAction.db-num and
            ub.PromoGoods.idAction = ub.PromoAction.id
            on error  undo, return error substitute( "&1 (PromoGoods). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (PromoGoods). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (PromoGoods). endkey", vss-workfile )
            :
            create dst.PromoGoods.
            buffer-copy ub.PromoGoods to dst.PromoGoods .
         end.
         for each ub.PromoObject no-lock
            where ub.PromoObject.db-num = ub.PromoAction.db-num and
            ub.PromoObject.idAction = ub.PromoAction.id
            on error  undo, return error substitute( "&1 (PromoObject). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            on stop   undo, return error substitute( "&1 (PromoObject). stop", vss-workfile )
            on endkey undo, return error substitute( "&1 (PromoObject). endkey", vss-workfile )
            :
            create dst.PromoObject.
            buffer-copy ub.PromoObject to dst.PromoObject .
         end.
      end.
   end.
end procedure.
