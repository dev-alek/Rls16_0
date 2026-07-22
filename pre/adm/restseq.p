block-level on error undo, throw.
define input parameter p-action    as character no-undo.
define input parameter p-seq-list  as character no-undo .
define input parameter p-first-err as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процедура проверки, восстановления Sequences".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
  define input  parameter p-db-num         like restseq.db.db-num             no-undo .
  define input  parameter p-curr-type-cdrg like restseq.code-range.range-type no-undo .
  define input  parameter p-first-code     like restseq.code-range.first-code no-undo .
  define input  parameter p-last-code      like restseq.code-range.last-code  no-undo .
  define input  parameter p-view-mess      as   logical                   no-undo .
  define output parameter v-b-code         as   integer                   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-main-bcode     like restseq.bar-code.b-code no-undo .
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
    define buffer buf_code-range   for restseq.code-range .
    define buffer buf-c_code-range for restseq.code-range .
    define buffer buf_bar-code     for restseq.bar-code .
    define buffer buf_place        for restseq.place .
    define buffer buf_goods        for restseq.goods .
    define buffer buf_units        for restseq.units .
    define buffer buf_prod-bc      for restseq.prod-bc .
    define buffer buf_dis-card     for restseq.dis-card .
    define buffer buf_dis-rule     for restseq.dis-rule .
    define buffer buf_dis-time-rule     for restseq.dis-time-rule .
    define buffer buf_firm         for restseq.firm .
    define buffer buf_person       for restseq.person .
    define buffer buf_contract     for restseq.contract .
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
    do v-ii0 = 1 to num-entries('restseq.dis-card'):
      assign
      v-table-name0 = entry(v-ii0, 'restseq.dis-card')
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
      do v-ii0 = 1 to num-entries('restseq.dis-card'):
        assign
        v-table-name0 = entry(v-ii0, 'restseq.dis-card')
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
    do v-ii1 = 1 to num-entries('restseq.contract'):
      assign
      v-table-name1 = entry(v-ii1, 'restseq.contract')
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
      do v-ii1 = 1 to num-entries('restseq.contract'):
        assign
        v-table-name1 = entry(v-ii1, 'restseq.contract')
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
    do v-ii2 = 1 to num-entries('restseq.rule-by-call'):
      assign
      v-table-name2 = entry(v-ii2, 'restseq.rule-by-call')
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
      do v-ii2 = 1 to num-entries('restseq.rule-by-call'):
        assign
        v-table-name2 = entry(v-ii2, 'restseq.rule-by-call')
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
    do v-ii3 = 1 to num-entries('restseq.fin-doc'):
      assign
      v-table-name3 = entry(v-ii3, 'restseq.fin-doc')
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
      do v-ii3 = 1 to num-entries('restseq.fin-doc'):
        assign
        v-table-name3 = entry(v-ii3, 'restseq.fin-doc')
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
    do v-ii4 = 1 to num-entries('restseq.firm'):
      assign
      v-table-name4 = entry(v-ii4, 'restseq.firm')
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
      do v-ii4 = 1 to num-entries('restseq.firm'):
        assign
        v-table-name4 = entry(v-ii4, 'restseq.firm')
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
    do v-ii5 = 1 to num-entries('restseq.person'):
      assign
      v-table-name5 = entry(v-ii5, 'restseq.person')
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
      do v-ii5 = 1 to num-entries('restseq.person'):
        assign
        v-table-name5 = entry(v-ii5, 'restseq.person')
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
    do v-ii6 = 1 to num-entries('restseq.dis-rule,restseq.dis-time-rule'):
      assign
      v-table-name6 = entry(v-ii6, 'restseq.dis-rule,restseq.dis-time-rule')
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
      do v-ii6 = 1 to num-entries('restseq.dis-rule,restseq.dis-time-rule'):
        assign
        v-table-name6 = entry(v-ii6, 'restseq.dis-rule,restseq.dis-time-rule')
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
    do v-ii7 = 1 to num-entries('restseq.bar-code,restseq.place'):
      assign
      v-table-name7 = entry(v-ii7, 'restseq.bar-code,restseq.place')
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
      do v-ii7 = 1 to num-entries('restseq.bar-code,restseq.place'):
        assign
        v-table-name7 = entry(v-ii7, 'restseq.bar-code,restseq.place')
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
  define input  parameter p-db-num         like restseq.db.db-num             no-undo .
  define input  parameter p-curr-type-cdrg like restseq.code-range.range-type no-undo .
  define output parameter p-str-u-f        as   character                 no-undo .
  define output parameter p-str-u-f-rng    as   character                 no-undo .
  do
  on error undo, return error
  :
    define buffer buf_code-range   for restseq.code-range.
    define buffer buf-c_code-range for restseq.code-range .
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
    define parameter buffer buf_prod-bc  for restseq.prod-bc .
    define input  parameter p-action           as character no-undo .
    define output parameter p-return-attribute as logical no-undo .
    def var vss-description as character no-undo init "prodbcat-01: определение параметров дополнительного бар-кода".
    define buffer buf_bar-code   for restseq.bar-code   .
    define buffer buf_units      for restseq.units      .
    define buffer buf_code-range for restseq.code-range .
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
  define input  parameter p-gds-code  like restseq.bar-code.gds-code  no-undo .
  define input  parameter p-node-code like restseq.bar-code.node-code no-undo .
  define output parameter p-b-code    like restseq.bar-code.b-code    no-undo .
  def var vss-description as character no-undo init "gdsbcode-01: определение первичного бар-кода признака".
  def var vss-proc-revision as character no-undo init "library.p gdsbcode-01" .
  define buffer buf_bar-code for restseq.bar-code .
  def var v-unit-base like restseq.goods.unit-base no-undo .
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
  define input  parameter p-gds-code  like restseq.goods.gds-code no-undo .
  define output parameter p-root-node like restseq.goods.prt-root no-undo .
  def var vss-description as character no-undo init "gdsrootnode-01: определение корневого признака товара по коду товара".
  define buffer buf_goods   for restseq.goods .
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
  define input  parameter p-prt-root  like restseq.goods.prt-root no-undo .
  define output parameter p-root-node like restseq.goods.prt-root no-undo .
  def var vss-description as character no-undo init "prt-root-to-node-code-01: определение корневого признака шкалы по коду шкалы".
  define buffer buf_gds-prt for restseq.gds-prt .
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
  define input  parameter p-gds-code  like restseq.goods.gds-code  no-undo .
  define output parameter p-unit-base like restseq.goods.unit-base no-undo .
  def var vss-description as character no-undo init "unitbase-01: определение базовой единицы измерения товара".
  define buffer buf_goods for restseq.goods .
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
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
define variable conf-par as character no-undo.
define variable par-type as character no-undo.
define variable mode-erprn as logical no-undo.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define stream LogStream .
define variable v-ld-db-name      as character no-undo .
define variable v-seq-val         as int64     no-undo .
define variable v-seq-name        as character no-undo .
define variable v-proc-name       as character no-undo .
define variable v-total-cnt       as integer   no-undo .
define variable v-total-run       as integer   no-undo .
define variable v-total-err       as integer   no-undo .
define variable v-curr-db-num     as integer no-undo.
define variable v-curr-seq-name   as character no-undo .
define variable v-curr-seq-value  as int64     no-undo .
define variable v-curr-recid      as recid     no-undo .
define variable v-new-seq-value   as int64     no-undo .
define variable v-table-name      as character no-undo .
define variable v-seq-field-name  as character no-undo .
define variable v-num-rec         as integer   no-undo .
define variable v-msg             as character no-undo .
define variable v-show-msg        as logical   no-undo .
define variable v-action          as character no-undo .
define frame seq-info
  v-curr-seq-name  format "x(25)" label "Счетчик" skip
  v-table-name     format "x(20)" label "Таблица" skip
  v-seq-field-name format "x(20)" label "Поле"    skip
  v-num-rec        label "Количество" skip
  with view-as dialog-box side-labels 1 columns three-d
  title "Проверка, восстановление счетчиков" .
function get-chk-doc-doc-code-int64 returns int64
  ( input p-db-num as integer, input p-doc-code as character ) :
  define variable v-doc-code-int64 as int64   no-undo .
  case num-entries(p-doc-code, "/") :
    when 2 then do:
      if p-db-num = 0 then return 0.
      assign
        v-doc-code-int64 = int64(entry(2, p-doc-code, "/"))
        no-error
      .
    end.
    when 1 then do:
      if p-db-num <> 0 then return 0.
      assign
        v-doc-code-int64 = int64(p-doc-code) no-error
      .
    end.
    otherwise do:
      assign
      v-doc-code-int64 = 0.
    end.
  end case.
  return v-doc-code-int64 .
end.
function get-firm-firm-code-int64 returns int64
  ( input p-curr-value      as int64,
    input p-db-num        as integer) :
  define variable v-firm-code-db as int64   no-undo .
    v-firm-code-db = p-curr-value + p-db-num *  exp( 10, 7 ) .
    return v-firm-code-db.
end.
function get-person-psn-code-int64 returns int64
  ( input p-curr-value as int64,
    input p-db-num        as integer ) :
  define variable v-psn-code-db as int64   no-undo .
    assign v-psn-code-db = p-curr-value + p-db-num *  exp( 10, 7 ).
       return v-psn-code-db.
end.
function get-layout-id-int64 returns int64
  ( input p-db-num as integer, input p-layout-id as character ) :
  define variable v-layout-id-int64 as int64   no-undo .
  case num-entries(p-layout-id, "-") :
    when 2 then do:
      if p-db-num = 0 then return 0.
      assign
        v-layout-id-int64 = int64(entry(2, p-layout-id, "-"))
        no-error
      .
    end.
    when 1 then do:
      if p-db-num <> 0 then return 0.
      assign
        v-layout-id-int64 = int64(p-layout-id) no-error
      .
    end.
    otherwise do:
      assign
      v-layout-id-int64 = 0.
    end.
  end case.
  return v-layout-id-int64 .
end.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as int64 no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  define variable v-fact-num-dec as decimal no-undo .
  do
  on error undo, return error substitute( "&1 (factord-to-fact-num). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      assign
      p-fact-num = 0.
      return.
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      v-fact-num-dec = (p-fact-order - v-fact-order-trunc ) * 10000000000
      p-fact-num = int64(v-fact-num-dec)
    .
  end.
end procedure.
procedure clear-log-file :
  do
  on error undo, return error substitute( "&1 (clear-log-file). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    output stream LogStream to "rest-seq.log" .
    output stream LogStream close .
  end.
end procedure.
procedure log-error :
  define input parameter p-err-seq-name   as character no-undo .
  define input parameter p-err-recid      as recid     no-undo .
  define input parameter p-err-curr-value as int64     no-undo .
  define input parameter p-err-new-value  as int64     no-undo .
  assign
    v-total-err = v-total-err + 1
  .
  do
  on error undo, return error substitute( "&1 (log-error). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    output stream LogStream to "rest-seq.log" append .
    put stream LogStream unformatted
      string(today, "99/99/9999") space
      string(time, "HH:MM") space
      p-action space
      p-err-seq-name space
      "recid:" space p-err-recid  space
      "curr:" space p-err-curr-value space
      "new:" space p-err-new-value
      skip
      .
    output stream LogStream close .
  end.
end procedure.
procedure check-seq-list :
  do
  on error  undo, return error substitute( "&1 (check-seq-list). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (check-seq-list). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (check-seq-list). endkey", vss-workfile )
  :
    define variable v-ret-msg         as character no-undo .
    define variable v-all-proc-list   as character no-undo .
    define variable v-ind             as integer   no-undo .
    define variable v-num-entries     as integer   no-undo .
    define variable v-proc-name       as character no-undo .
    define variable v-check-seq-name  as character no-undo .
    define variable v-list-excessive  as character no-undo .
    define variable v-list-necessary  as character no-undo .
    define variable v-list-all-av-seq as character no-undo .
    assign
      v-all-proc-list   = this-procedure :internal-entries
      v-ret-msg         = "":U
      v-list-excessive  = "":U
      v-list-necessary  = "":U
      v-num-entries     = num-entries( v-all-proc-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1 (check-seq-list do v-ind = 1). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      assign
        v-proc-name = entry( v-ind, v-all-proc-list )
      .
      if v-proc-name begins "restore-":U then do:
        assign
          v-check-seq-name  = trim( replace( v-proc-name, "restore-":U, "":U ) )
          v-list-all-av-seq = v-list-all-av-seq + (if v-list-all-av-seq = "":U then "":U else ",":U) + v-check-seq-name
        .
        find first restseq._sequence no-lock
          where restseq._sequence._seq-name = v-check-seq-name
          no-error.
        if not available restseq._sequence
          or lookup( restseq._sequence._seq-name, "next-report,s-datatype,s-petrol-code,s-sgr,s-inv,s-reserv1,s-reserv2,s-doc,s-doc-type,s-file-num,s-line-num,s-tax-rate,synch-cli-grp,synch-gds-grp,s-v-doc,s-ext-classif,s-fbr-grp,s-user-history,s-tog,s-op-hist,s-jwlr-grp,s-jewelry,s-h-route,s-h-route-dump,s-h-route-dump,synch-an-grp":U, ",":U ) > 0
        then do:
          assign
            v-list-excessive = v-list-excessive + chr(10) + v-check-seq-name
          .
        end.
      end.
    end.
    for each restseq._sequence no-lock
    on error undo, return error substitute( "&1 (check-seq-list for each restseq._sequence). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      if lookup( restseq._sequence._seq-name, v-list-all-av-seq, ",":U ) = 0
        and lookup( restseq._sequence._seq-name, "next-report,s-datatype,s-petrol-code,s-sgr,s-inv,s-reserv1,s-reserv2,s-doc,s-doc-type,s-file-num,s-line-num,s-tax-rate,synch-cli-grp,synch-gds-grp,s-v-doc,s-ext-classif,s-fbr-grp,s-user-history,s-tog,s-op-hist,s-jwlr-grp,s-jewelry,s-h-route,s-h-route-dump,s-h-route-dump,synch-an-grp":U, ",":U ) = 0
      then do:
        assign
          v-list-necessary = v-list-necessary + chr(10) + restseq._sequence._seq-name
        .
      end.
    end.
    if v-list-excessive <> "":U then do:
      assign
        v-ret-msg = v-ret-msg + substitute( "&1Лишние процедуры по обработке sequence: &2", chr(10), v-list-excessive ) + chr(10)
      .
    end.
    if v-list-necessary <> "":U then do:
      assign
        v-ret-msg = v-ret-msg + substitute( "&1Отсутствуют процедуры по обработке sequence: &2", chr(10), v-list-necessary ) + chr(10)
      .
    end.
    if v-ret-msg <> "":U then do:
      return error v-ret-msg .
    end.
    else do:
      return .
    end.
  end.
end procedure.
do
on error undo, return error substitute( "&1 (main). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
  if lookup(p-action, "check,rest,check-no-msg,rest-no-msg" ) = 0 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Запрошено неизвестное действие" skip
      "p-action" p-action skip
      view-as alert-box error .
    undo, return error .
  end.
  assign
    v-show-msg = true
  .
  if lookup(p-action, "check-no-msg,rest-no-msg":U ) > 0 then do:
    assign
      v-show-msg = false
    .
  end.
  assign
    v-action = "check":U
  .
  if lookup(p-action, "rest,rest-no-msg":U ) > 0 then do:
    assign
      v-action = "rest":U
    .
  end.
  assign
    v-ld-db-name = ldbname( "restseq":U )
  .
  run clear-log-file in this-procedure .
  assign
    v-total-cnt = 0
    v-total-err = 0
    v-total-run = 0
  .
  run check-seq-list in this-procedure
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке корректности процедуры восстановления" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    output stream LogStream to "rest-seq.log" append .
    put stream LogStream unformatted
      string(today, "99/99/9999") space string(time, "HH:MM") space
      return-value
      skip
      .
    output stream LogStream close .
    if p-first-err = true then do:
      return error .
    end.
  end.
  find first restseq.sys-ctrl no-lock
    no-error .
  if available restseq.sys-ctrl then do:
    assign
      v-curr-db-num = restseq.sys-ctrl.db-num
    .
  end.
  if v-curr-db-num = ? then do:
    undo, return error "(rest-seq.p) Не удалось определить номер текущей БД" .
  end.
  view frame seq-info .
  for each restseq._sequence no-lock
  on error undo, return error substitute( "&1 (for each restseq._sequence). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    assign
      v-seq-name  = restseq._sequence._seq-name
      v-proc-name = "restore-":U + v-seq-name
    .
    if lookup( v-seq-name, "next-report,s-datatype,s-petrol-code,s-sgr,s-inv,s-reserv1,s-reserv2,s-doc,s-doc-type,s-file-num,s-line-num,s-tax-rate,synch-cli-grp,synch-gds-grp,s-v-doc,s-ext-classif,s-fbr-grp,s-user-history,s-tog,s-op-hist,s-jwlr-grp,s-jewelry,s-h-route,s-h-route-dump,s-h-route-dump,synch-an-grp":U ) > 0 then do:
      next.
    end.
    if ( p-seq-list <> "":U
         and lookup( v-seq-name, p-seq-list ) > 0
       )
       or p-seq-list = "":U
    then do:
      assign
        v-total-cnt      = v-total-cnt + 1
        v-seq-val        = dynamic-current-value( v-seq-name, v-ld-db-name )
        v-curr-seq-value = v-seq-val
      .
      if restseq._sequence._seq-max <> ? then do:
        if v-seq-val > restseq._sequence._seq-max then do:
          assign
            v-curr-seq-value = restseq._sequence._seq-max
          .
        end.
      end.
      else do:
        if v-seq-val > 9223372036854775807 then do:
          assign
            v-curr-seq-value = 9223372036854775807
          .
        end.
      end.
      if restseq._sequence._seq-min <> ?
        and v-seq-val < restseq._sequence._seq-min
      then do:
        assign
          v-curr-seq-value = restseq._sequence._seq-min
        .
      end.
      if v-curr-seq-value <> v-seq-val then do:
        run log-error in this-procedure ~
          (input v-seq-name
          ,input ?
          ,input v-seq-val
          ,input v-curr-seq-value
          ).
        if v-action = "rest":U then do:
          assign
            dynamic-current-value( v-seq-name, v-ld-db-name ) = v-curr-seq-value
          .
        end.
        else do:
          next .
        end.
      end.
      if lookup( v-proc-name, this-procedure :internal-entries ) > 0 then do:
        assign
          v-total-run = v-total-run + 1
        .
        run value( v-proc-name ) in this-procedure
          ( input v-curr-db-num
          ) no-error .
        if error-status :error then do:
          assign
            v-msg = substitute( "Ошибка при восстановлении счетчика &1&2&3&2&4", v-seq-name, chr(10), error-status :get-message(1), return-value)
          .
          output stream LogStream to "rest-seq.log" append .
          put stream LogStream unformatted
            string(today, "99/99/9999") space string(time, "HH:MM") space
            v-msg
            skip
            .
          output stream LogStream close .
          if v-show-msg = true then do:
            message
              v-msg
              view-as alert-box error .
          end.
          if p-first-err = true then do:
            return error v-msg.
          end.
        end.
      end.
    end.
  end.
  hide frame seq-info .
  case v-action :
    when "rest":U then do:
      if v-total-err <> 0 then do:
        assign
          v-msg = substitute( "Восстановление счетчиков закончено.&1"
                              + "Просмотрено счетчиков &2.&1"
                              + "Проверено счетчиков   &3.&1"
                              + "Исправлено счетчиков  &4.&1"
                              + "Список исправленных счетчиков приведен в файле &5.&1"
                              , chr(10)
                              , v-total-cnt
                              , v-total-run
                              , v-total-err
                              , "rest-seq.log":U
                            )
        .
      end.
      else do:
        assign
          v-msg = substitute( "Восстановление счетчиков закончено.&1"
                              + "Просмотрено счетчиков &2.&1"
                              + "Проверено счетчиков   &3.&1"
                              + "Все счетчики содержали правильную информацию."
                              , chr(10)
                              , v-total-cnt
                              , v-total-run
                            )
        .
      end.
    end.
    when "check":U then do:
      if v-total-err <> 0 then do:
        assign
          v-msg = substitute( "Проверка счетчиков закончена.&1"
                              + "Просмотрено счетчиков &2.&1"
                              + "Проверено счетчиков   &3.&1"
                              + "Обнаружено ошибок     &4.&1"
                              + "Список ошибок приведен в файле &5.&1"
                              , chr(10)
                              , v-total-cnt
                              , v-total-run
                              , v-total-err
                              , "rest-seq.log":U
                            )
        .
      end.
      else do:
        assign
          v-msg = substitute( "Проверка счетчиков закончена.&1"
                              + "Просмотрено счетчиков &2.&1"
                              + "Проверено счетчиков   &3.&1"
                              + "Ошибок не обнаружено."
                              , chr(10)
                              , v-total-cnt
                              , v-total-run
                            )
        .
      end.
    end.
  end case.
  output stream LogStream to "rest-seq.log" append .
  put stream LogStream unformatted
    string(today, "99/99/9999") space string(time, "HH:MM") space
    v-msg skip
    .
  output stream LogStream close .
  if v-show-msg = true then do:
    message
      v-msg
      view-as alert-box information .
  end.
  return v-msg .
end.
procedure restore-s-trn-fact :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error substitute( "&1 (restore-s-trn-fact). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-trn-fact"   v-table-name     = "price-doc"   v-seq-field-name = "fact-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.price-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence price-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.price-doc.fact-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.price-doc)     .   end. end.
                assign   v-curr-seq-name  = "s-trn-fact"   v-table-name     = "trn-doc"   v-seq-field-name = "fact-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.trn-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence trn-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.trn-doc.fact-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.trn-doc)     .   end. end.
                assign   v-curr-seq-name  = "s-trn-fact"   v-table-name     = "c-price-doc"   v-seq-field-name = "fact-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-price-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-price-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-price-doc.fact-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-price-doc)     .   end. end.
                assign   v-curr-seq-name  = "s-trn-fact"   v-table-name     = "c-trn-doc"   v-seq-field-name = "fact-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-trn-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-trn-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-trn-doc.fact-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-trn-doc)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-trn-fact" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-chk :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error substitute( "&1 (restore-s-chk). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-chk"   v-table-name     = "chk-doc"   v-seq-field-name = "doc-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.chk-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence chk-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-chk-doc-doc-code-int64(p-curr-db-num, restseq.chk-doc.doc-code) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.chk-doc)     .   end. end.
                assign   v-curr-seq-name  = "s-chk"   v-table-name     = "c-chk-doc"   v-seq-field-name = "doc-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-chk-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-chk-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-chk-doc-doc-code-int64(p-curr-db-num, restseq.c-chk-doc.doc-code) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-chk-doc)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-chk" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-trn-doc :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error substitute( "&1 (restore-s-trn-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-trn-doc"   v-table-name     = "trn-doc"   v-seq-field-name = "doc-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.trn-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence trn-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.trn-doc.doc-code) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.trn-doc)     .   end. end.
                assign   v-curr-seq-name  = "s-trn-doc"   v-table-name     = "rvs-doc"   v-seq-field-name = "rvs-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.rvs-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence rvs-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.rvs-doc.rvs-code) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.rvs-doc)     .   end. end.
                assign   v-curr-seq-name  = "s-trn-doc"   v-table-name     = "price-doc"   v-seq-field-name = "doc-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.price-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence price-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.price-doc.doc-num) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.price-doc)     .   end. end.
                assign   v-curr-seq-name  = "s-trn-doc"   v-table-name     = "icnt-doc"   v-seq-field-name = "doc-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.icnt-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence icnt-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.icnt-doc.doc-code) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.icnt-doc)     .   end. end.
    assign   v-curr-seq-name  = "s-trn-doc"   v-table-name     = "fbr-doc"   v-seq-field-name = "doc-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.fbr-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence fbr-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.fbr-doc.doc-code) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.fbr-doc)     .   end. end.
                assign   v-curr-seq-name  = "s-trn-doc"   v-table-name     = "parts-attr"   v-seq-field-name = "in-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.parts-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence parts-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.parts-attr.in-code) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.parts-attr)     .   end. end.
                assign   v-curr-seq-name  = "s-trn-doc"   v-table-name     = "cli-gds"   v-seq-field-name = "in-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.cli-gds no-lock  on error undo, return error substitute( "&1 (validate-sequence cli-gds). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.cli-gds.in-code) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.cli-gds)     .   end. end.
                assign   v-curr-seq-name  = "s-trn-doc"   v-table-name     = "c-trn-doc"   v-seq-field-name = "doc-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-trn-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-trn-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.c-trn-doc.doc-code) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-trn-doc)     .   end. end.
                assign   v-curr-seq-name  = "s-trn-doc"   v-table-name     = "c-rvs-doc"   v-seq-field-name = "rvs-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-rvs-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-rvs-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.c-rvs-doc.rvs-code) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-rvs-doc)     .   end. end.
                assign   v-curr-seq-name  = "s-trn-doc"   v-table-name     = "c-price-doc"   v-seq-field-name = "doc-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-price-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-price-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.c-price-doc.doc-num) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-price-doc)     .   end. end.
                assign   v-curr-seq-name  = "s-trn-doc"   v-table-name     = "c-fbr-doc"   v-seq-field-name = "doc-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-fbr-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-fbr-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.c-fbr-doc.doc-code) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-fbr-doc)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-trn-doc" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-fbr-doc :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error substitute( "&1 (restore-s-fbr-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-fbr-doc"   v-table-name     = "fbr-pln"   v-seq-field-name = "doc-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.fbr-pln no-lock  on error undo, return error substitute( "&1 (validate-sequence fbr-pln). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.fbr-pln.doc-code) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.fbr-pln)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fbr-doc" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-fbr-num :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error substitute( "&1 (restore-s-fbr-num). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-fbr-num"   v-table-name     = "fbr-history"   v-seq-field-name = "hst-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.fbr-history no-lock  on error undo, return error substitute( "&1 (validate-sequence fbr-history). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.fbr-history.hst-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.fbr-history)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fbr-num" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-bank :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-bank"   v-table-name     = "rcs-retail1bank"   v-seq-field-name = "bank-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.rcs-retail1bank no-lock  on error undo, return error substitute( "&1 (validate-sequence rcs-retail1bank). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.rcs-retail1bank.bank-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.rcs-retail1bank)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-bank" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-cli-grp :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
    assign
    v-curr-seq-name  = "s-cli-grp"
    v-table-name     = "cli-grp"
    v-seq-field-name = "node-code"
    v-num-rec        = 0
    v-curr-recid     = 0
    v-new-seq-value  = 0
    .
    do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.
    find last restseq.cli-grp no-lock
      use-index pi no-error
    .
    if available restseq.cli-grp then do:
      assign
        v-curr-seq-value = restseq.cli-grp.node-code
      .
    end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-cli-grp" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-fmgb-code :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    define variable v-fm-code as   int64              no-undo .
      find restseq.code-range no-lock
        where restseq.code-range.range-type = 'fmgb':U
          and restseq.code-range.db-num     = p-curr-db-num
          and restseq.code-range.stts       = "a":U
        no-error
      .
      if not available restseq.code-range then do:
        find restseq.code-range no-lock
        where restseq.code-range.range-type = 'fmgb':U
          and restseq.code-range.db-num     = p-curr-db-num
          and restseq.code-range.stts       = "u":U
        no-error
        .
      end .
      assign
        v-curr-seq-name  = "s-fmgb-code"
        v-curr-recid     = 0
      .
      if available restseq.code-range then do:
    if mode-erprn then do:
          assign
            v-curr-seq-value = restseq.code-range.last-code
          .
          run log-error in this-procedure
    (input v-curr-seq-name
    ,input v-curr-recid
    ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )
    ,input v-curr-seq-value
    ).
      dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value .
    end.
    else do:
      assign
        v-table-name     = "firm"
        v-seq-field-name = "firm-code"
        v-num-rec        = 0
        v-new-seq-value  = 0
      .
      do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.
      if restseq.code-range.stts = "a":U then do:
        run get-max-code ( input "get-m-code":U
                          ,input restseq.code-range.db-num
                          ,input restseq.code-range.range-type
                          ,input restseq.code-range.first-code
                          ,input restseq.code-range.last-code
                          ,input FALSE
                          ,output v-fm-code
                          ).
        assign
          v-curr-seq-value = v-fm-code
        .
        if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fmgb-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
      end.
      else do:
          assign
            v-curr-seq-value = restseq.code-range.last-code
          .
          if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fmgb-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
      end.
    end.
      end .
  end.
end procedure.
procedure restore-s-pngb-code :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    define variable v-pn-code as   int64              no-undo .
    find restseq.code-range no-lock
      where restseq.code-range.range-type = 'pngb':U
        and restseq.code-range.db-num     = p-curr-db-num
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if not available restseq.code-range then do:
      find restseq.code-range no-lock
        where restseq.code-range.range-type = 'pngb':U
          and restseq.code-range.db-num     = p-curr-db-num
          and restseq.code-range.stts       = "u":U
        no-error
      .
    end.
    assign
      v-curr-seq-name  = "s-pngb-code"
      v-curr-recid     = 0
    .
      if available restseq.code-range then do:
    if mode-erprn then do:
          assign
            v-curr-seq-value = restseq.code-range.last-code
          .
          run log-error in this-procedure
    (input v-curr-seq-name
    ,input v-curr-recid
    ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )
    ,input v-curr-seq-value
    ).
      dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value .
    end.
    else do:
      assign
        v-table-name     = "person"
        v-seq-field-name = "psn-code"
        v-num-rec        = 0
        v-new-seq-value  = 0
      .
      do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.
      if restseq.code-range.stts = "a":U then do:
        run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-pn-code
                          ).
        assign
          v-curr-seq-value = v-pn-code
        .
        if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-pngb-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
      end.
      else do:
        assign
          v-curr-seq-value = restseq.code-range.last-code
        .
        if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-pngb-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
      end.
    end.
      end .
  end.
end procedure.
procedure restore-s-sclc-code :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    define variable v-b-code as   int64              no-undo .
        assign
      v-curr-seq-name  = "s-sclc-code"
      v-table-name     = "prod-bc"
      v-seq-field-name = "b-str"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .
    do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.
    find restseq.code-range no-lock
      where restseq.code-range.range-type = 'sclc':U
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-b-code
                        ).
      assign
        v-curr-seq-value = v-b-code
      .
      if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-sclc-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
    end.
  end.
end procedure.
procedure restore-s-scgb-code :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    define variable v-b-code as   int64              no-undo .
        assign
      v-curr-seq-name  = "s-scgb-code"
      v-table-name     = "prod-bc"
      v-seq-field-name = "b-str"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .
    do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.
    find restseq.code-range no-lock
      where restseq.code-range.range-type = 'scgb':U
        and restseq.code-range.db-num     = p-curr-db-num
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-b-code
                        ).
      assign
        v-curr-seq-value = v-b-code
      .
      if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-scgb-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
    end.
  end.
end procedure.
procedure restore-s-pglc-code :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    define variable v-b-code as   int64              no-undo .
        assign
      v-curr-seq-name  = "s-pglc-code"
      v-table-name     = "prod-bc"
      v-seq-field-name = "b-str"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .
    do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.
    find restseq.code-range no-lock
      where restseq.code-range.range-type = 'pglc':U
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-b-code
                        ).
      assign
        v-curr-seq-value = v-b-code
      .
      if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-pglc-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
    end.
  end.
end procedure.
procedure restore-s-pmnt-code :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-pmnt-code"   v-table-name     = "payment"   v-seq-field-name = "pmnt-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.payment no-lock  on error undo, return error substitute( "&1 (validate-sequence payment). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.payment.pmnt-code) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.payment)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-pmnt-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-gds-grp :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
    assign
    v-curr-seq-name  = "s-gds-grp"
    v-table-name     = "gds-grp"
    v-seq-field-name = "node-code"
    v-num-rec        = 0
    v-curr-recid     = 0
    v-new-seq-value  = 0
    .
    do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.
    find last restseq.gds-grp no-lock
      use-index pi no-error
    .
    if available restseq.gds-grp then do:
      assign
        v-curr-seq-value = restseq.gds-grp.node-code
      .
    end.
      if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-gds-grp" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
    assign   v-curr-seq-value = 0 .
        assign
    v-curr-seq-name  = "s-fbr-grp"
    v-table-name     = "fbr-gds-grp"
    v-seq-field-name = "node-code"
    v-num-rec        = 0
    v-curr-recid     = 0
    v-new-seq-value  = 0
    .
    do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.
    find last restseq.fbr-gds-grp no-lock use-index inodecode
      no-error
    .
    if available restseq.fbr-gds-grp then do:
      assign
        v-curr-seq-value = restseq.fbr-gds-grp.node-code
      .
    end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fbr-grp" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-gds-prt :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    if p-curr-db-num > 0 then return.
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-gds-prt"   v-table-name     = "gds-prt"   v-seq-field-name = "node-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.gds-prt no-lock  on error undo, return error substitute( "&1 (validate-sequence gds-prt). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.gds-prt.node-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.gds-prt)     .   end. end.
                assign   v-curr-seq-name  = "s-gds-prt"   v-table-name     = "gds-prt"   v-seq-field-name = "upper-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.gds-prt no-lock  on error undo, return error substitute( "&1 (validate-sequence gds-prt). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.gds-prt.upper-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.gds-prt)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-gds-prt" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-bcgb-code :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    define variable v-b-code as   int64              no-undo .
      assign
      v-curr-seq-name  = "s-bcgb-code"
      v-table-name     = "bar-code"
      v-seq-field-name = "b-code"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .
    do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.
    find restseq.code-range no-lock
      where restseq.code-range.range-type = 'bcgb':U
        and restseq.code-range.db-num     = p-curr-db-num
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-b-code
                        ).
      assign
        v-curr-seq-value = v-b-code
      .
      if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-bcgb-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
    end.
  end.
end procedure.
procedure restore-next-num-filter :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
  end.
end procedure.
procedure restore-s-user-id :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-user-id"   v-table-name     = "user-account"   v-seq-field-name = "user-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.user-account no-lock  on error undo, return error substitute( "&1 (validate-sequence user-account). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if int64(entry(1, restseq.user-account.user-id, "-") ) <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(entry(2, restseq.user-account.user-id, "-") ).   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.user-account)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-user-id" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-usr-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-usr-chip"   v-table-name     = "c-user-account"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-user-account no-lock  on error undo, return error substitute( "&1 (validate-sequence c-user-account). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-user-account.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-user-account.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-user-account)     .   end. end.
                    assign   v-curr-seq-name  = "s-usr-chip"   v-table-name     = "c-user-login"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-user-login no-lock  on error undo, return error substitute( "&1 (validate-sequence c-user-login). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-user-login.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-user-login.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-user-login)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-usr-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-user-login-action-role :
  define input parameter p-curr-db-num as integer no-undo.
  define buffer buf_global-state for ub.global-state .
  define buffer buf_global-state-attr for ub.global-state-attr .
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
   FIND FIRST buf_global-state
        exclusive-LOCK        .
FIND FIRST buf_global-state-attr
    WHERE buf_global-state-attr.gls-id = buf_global-state.gls-id
    AND buf_global-state-attr.attr-code = "action-gbl"
    EXCLUSIVE-LOCK
    NO-error
    .
  IF not AVAILABLE buf_global-state-attr or buf_global-state-attr.attr-value <> "yes"
    THEN
  DO:
  END.
  else do:
               end.
        assign   v-curr-seq-name  = "s-user-login-action-role"   v-table-name     = "user-login-action-role"   v-seq-field-name = "user-login-role-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.user-login-action-role no-lock  on error undo, return error substitute( "&1 (validate-sequence user-login-action-role). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   .   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.user-login-action-role.user-login-role-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.user-login-action-role)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-user-login-action-role" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-menu-user-call :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-menu-user-call"   v-table-name     = "menu-user-call"   v-seq-field-name = "menu-user-call-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.menu-user-call no-lock  on error undo, return error substitute( "&1 (validate-sequence menu-user-call). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.menu-user-call.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.menu-user-call.menu-user-call-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.menu-user-call)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-menu-user-call" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-user-menu-group :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-user-menu-group"   v-table-name     = "user-menu-group"   v-seq-field-name = "user-menu-group-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.user-menu-group no-lock  on error undo, return error substitute( "&1 (validate-sequence user-menu-group). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.user-menu-group.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.user-menu-group.user-menu-group-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.user-menu-group)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-user-menu-group" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-action-post :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-action-post"   v-table-name     = "action-post"   v-seq-field-name = "action-post-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.action-post no-lock  on error undo, return error substitute( "&1 (validate-sequence action-post). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.action-post.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.action-post.action-post-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.action-post)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-action-post" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-action-post-menu-group :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-action-post-menu-group"   v-table-name     = "action-post-menu-group"   v-seq-field-name = "action-post-menu-group-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.action-post-menu-group no-lock  on error undo, return error substitute( "&1 (validate-sequence action-post-menu-group). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.action-post-menu-group.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.action-post-menu-group.action-post-menu-group-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.action-post-menu-group)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-action-post-menu-group" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-action-post-role :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-action-post-role"   v-table-name     = "action-post-role"   v-seq-field-name = "action-post-role-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.action-post-role no-lock  on error undo, return error substitute( "&1 (validate-sequence action-post-role). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.action-post-role.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.action-post-role.action-post-role-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.action-post-role)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-action-post-role" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-action-role :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-action-role"   v-table-name     = "action-role"   v-seq-field-name = "action-role-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.action-role no-lock  on error undo, return error substitute( "&1 (validate-sequence action-role). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.action-role.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.action-role.action-role-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.action-role)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-action-role" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-action-role-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-action-role-chip"   v-table-name     = "c-action-role-item"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-action-role-item no-lock  on error undo, return error substitute( "&1 (validate-sequence c-action-role-item). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-action-role-item.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-action-role-item.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-action-role-item)     .   end. end.
                    assign   v-curr-seq-name  = "s-action-role-chip"   v-table-name     = "c-action-role"   v-seq-field-name = "action-role-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-action-role no-lock  on error undo, return error substitute( "&1 (validate-sequence c-action-role). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-action-role.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-action-role.action-role-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-action-role)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-action-role-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-action-role-item :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-action-role-item"   v-table-name     = "action-role-item"   v-seq-field-name = "action-role-item-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.action-role-item no-lock  on error undo, return error substitute( "&1 (validate-sequence action-role-item). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.action-role-item.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.action-role-item.action-role-item-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.action-role-item)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-action-role-item" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-alc-sale-lic :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-alc-sale-lic"   v-table-name     = "alc-sale-lic"   v-seq-field-name = "alc-sale-lic-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.alc-sale-lic no-lock  on error undo, return error substitute( "&1 (validate-sequence alc-sale-lic). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.alc-sale-lic.create-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.alc-sale-lic.alc-sale-lic-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.alc-sale-lic)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-alc-sale-lic" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-alc-supp-lic :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-alc-supp-lic"   v-table-name     = "alc-supp-lic"   v-seq-field-name = "alc-supp-lic-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.alc-supp-lic no-lock  on error undo, return error substitute( "&1 (validate-sequence alc-supp-lic). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.alc-supp-lic.create-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.alc-supp-lic.alc-supp-lic-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.alc-supp-lic)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-alc-supp-lic" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-alc-type :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-alc-type"   v-table-name     = "alc-type"   v-seq-field-name = "alc-type-inner-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.alc-type no-lock  on error undo, return error substitute( "&1 (validate-sequence alc-type). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.alc-type.create-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.alc-type.alc-type-inner-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.alc-type)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-alc-type" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-cd-events-log :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-cd-events-log"   v-table-name     = "cd-event-log"   v-seq-field-name = "trans-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.cd-event-log no-lock  on error undo, return error substitute( "&1 (validate-sequence cd-event-log). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.cd-event-log.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.cd-event-log.trans-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.cd-event-log)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-cd-events-log" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-alc-type-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-alc-type-chip"   v-table-name     = "c-alc-type"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-alc-type no-lock  on error undo, return error substitute( "&1 (validate-sequence c-alc-type). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-alc-type.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-alc-type.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-alc-type)     .   end. end.
                    assign   v-curr-seq-name  = "s-alc-type-chip"   v-table-name     = "c-alc-type-gds"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-alc-type-gds no-lock  on error undo, return error substitute( "&1 (validate-sequence c-alc-type-gds). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-alc-type-gds.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-alc-type-gds.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-alc-type-gds)     .   end. end.
                    assign   v-curr-seq-name  = "s-alc-type-chip"   v-table-name     = "c-alc-type-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-alc-type-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-alc-type-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-alc-type-attr.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-alc-type-attr.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-alc-type-attr)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-alc-type-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-alc-sale-lic-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-alc-sale-lic-chip"   v-table-name     = "c-alc-sale-lic"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-alc-sale-lic no-lock  on error undo, return error substitute( "&1 (validate-sequence c-alc-sale-lic). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-alc-sale-lic.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-alc-sale-lic.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-alc-sale-lic)     .   end. end.
                    assign   v-curr-seq-name  = "s-alc-sale-lic-chip"   v-table-name     = "c-alc-sale-lic-type"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-alc-sale-lic-type no-lock  on error undo, return error substitute( "&1 (validate-sequence c-alc-sale-lic-type). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-alc-sale-lic-type.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-alc-sale-lic-type.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-alc-sale-lic-type)     .   end. end.
                    assign   v-curr-seq-name  = "s-alc-sale-lic-chip"   v-table-name     = "c-alc-sale-lic-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-alc-sale-lic-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-alc-sale-lic-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-alc-sale-lic-attr.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-alc-sale-lic-attr.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-alc-sale-lic-attr)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-alc-sale-lic-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-alc-supp-lic-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-alc-supp-lic-chip"   v-table-name     = "c-alc-supp-lic"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-alc-supp-lic no-lock  on error undo, return error substitute( "&1 (validate-sequence c-alc-supp-lic). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-alc-supp-lic.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-alc-supp-lic.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-alc-supp-lic)     .   end. end.
                    assign   v-curr-seq-name  = "s-alc-supp-lic-chip"   v-table-name     = "c-alc-supp-lic-type"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-alc-supp-lic-type no-lock  on error undo, return error substitute( "&1 (validate-sequence c-alc-supp-lic-type). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-alc-supp-lic-type.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-alc-supp-lic-type.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-alc-supp-lic-type)     .   end. end.
                    assign   v-curr-seq-name  = "s-alc-supp-lic-chip"   v-table-name     = "c-alc-supp-lic-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-alc-supp-lic-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-alc-supp-lic-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-alc-supp-lic-attr.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-alc-supp-lic-attr.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-alc-supp-lic-attr)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-alc-supp-lic-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-btpr :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-btpr"   v-table-name     = "BatchProcess"   v-seq-field-name = "BatchProcess#"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.BatchProcess no-lock  on error undo, return error substitute( "&1 (validate-sequence BatchProcess). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.BatchProcess.BatchProcess# .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.BatchProcess)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-btpr" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-next-rep-num :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "next-rep-num"   v-table-name     = "rep"   v-seq-field-name = "rep-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.rep no-lock  on error undo, return error substitute( "&1 (validate-sequence rep). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.rep.rep-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.rep)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "next-rep-num" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-recipe :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-recipe"   v-table-name     = "recipe"   v-seq-field-name = "recipe-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.recipe no-lock  on error undo, return error substitute( "&1 (validate-sequence recipe). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.recipe.recipe-code) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.recipe)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-recipe" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-ord-doc :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-ord-doc"   v-table-name     = "ord-doc"   v-seq-field-name = "doc-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.ord-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence ord-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.ord-doc.doc-code) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.ord-doc)     .   end. end.
                assign   v-curr-seq-name  = "s-ord-doc"   v-table-name     = "c-ord-doc"   v-seq-field-name = "doc-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-ord-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-ord-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.c-ord-doc.doc-code) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-ord-doc)     .   end. end.
                assign   v-curr-seq-name  = "s-ord-doc"   v-table-name     = "ord-doc-rcv"   v-seq-field-name = "rcv-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.ord-doc-rcv no-lock  on error undo, return error substitute( "&1 (validate-sequence ord-doc-rcv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.ord-doc-rcv.rcv-code) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.ord-doc-rcv)     .   end. end.
                assign   v-curr-seq-name  = "s-ord-doc"   v-table-name     = "ord-cons"   v-seq-field-name = "cons-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.ord-cons no-lock  on error undo, return error substitute( "&1 (validate-sequence ord-cons). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.ord-cons.cons-code) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.ord-cons)     .   end. end.
                assign   v-curr-seq-name  = "s-ord-doc"   v-table-name     = "ord-chain"   v-seq-field-name = "doc-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.ord-chain no-lock  on error undo, return error substitute( "&1 (validate-sequence ord-chain). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.ord-chain.doc-code) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.ord-chain)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-ord-doc" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-ord-ch :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-ord-ch"   v-table-name     = "ord-chain"   v-seq-field-name = "rel-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.ord-chain no-lock  on error undo, return error substitute( "&1 (validate-sequence ord-chain). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.ord-chain.rel-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.ord-chain)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-ord-ch" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-ord-fact :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-ord-fact"   v-table-name     = "ord-doc"   v-seq-field-name = "fact-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.ord-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence ord-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.ord-doc.fact-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.ord-doc)     .   end. end.
                assign   v-curr-seq-name  = "s-ord-fact"   v-table-name     = "c-ord-doc"   v-seq-field-name = "fact-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-ord-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-ord-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-ord-doc.fact-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-ord-doc)     .   end. end.
                assign   v-curr-seq-name  = "s-ord-fact"   v-table-name     = "ord-doc-rcv"   v-seq-field-name = "fact-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.ord-doc-rcv no-lock  on error undo, return error substitute( "&1 (validate-sequence ord-doc-rcv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.ord-doc-rcv.fact-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.ord-doc-rcv)     .   end. end.
                assign   v-curr-seq-name  = "s-ord-fact"   v-table-name     = "ord-cons"   v-seq-field-name = "fact-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.ord-cons no-lock  on error undo, return error substitute( "&1 (validate-sequence ord-cons). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.ord-cons.fact-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.ord-cons)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-ord-fact" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-wth-doc :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-wth-doc"   v-table-name     = "wth-doc"   v-seq-field-name = "doc-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.wth-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence wth-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.wth-doc.doc-code) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.wth-doc)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-wth-doc" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-wth-fact :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-wth-fact"   v-table-name     = "wth-doc"   v-seq-field-name = "fact-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.wth-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence wth-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.wth-doc.fact-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.wth-doc)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-wth-fact" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-wth-code :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-wth-code"   v-table-name     = "wealth"   v-seq-field-name = "wth-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.wealth no-lock  on error undo, return error substitute( "&1 (validate-sequence wealth). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.wealth.wth-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.wealth)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-wth-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-par-code :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-par-code"   v-table-name     = "wth-par"   v-seq-field-name = "par-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.wth-par no-lock  on error undo, return error substitute( "&1 (validate-sequence wth-par). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.wth-par.par-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.wth-par)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-par-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-wth-ser :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-wth-ser"   v-table-name     = "wth-ser"   v-seq-field-name = "ser-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.wth-ser no-lock  on error undo, return error substitute( "&1 (validate-sequence wth-ser). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.wth-ser.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.wth-ser.ser-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.wth-ser)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-wth-ser" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-wth-place :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-wth-place"   v-table-name     = "wth-place"   v-seq-field-name = "w-p-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.wth-place no-lock  on error undo, return error substitute( "&1 (validate-sequence wth-place). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.wth-place.w-p-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.wth-place)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-wth-place" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-dcgb-code :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    define variable v-dc-code as   int64              no-undo .
        assign
      v-curr-seq-name  = "s-dcgb-code"
      v-table-name     = "dis-card"
      v-seq-field-name = "card-num"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .
    do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.
    find restseq.code-range no-lock
      where restseq.code-range.range-type = 'dcgb':U
        and restseq.code-range.db-num     = p-curr-db-num
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-dc-code
                        ).
      assign
        v-curr-seq-value = v-dc-code
      .
      if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-dcgb-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
    end.
  end.
end procedure.
procedure restore-s-corr-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-price-doc"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-price-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-price-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-price-doc.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-price-doc.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-price-doc)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-inkas"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-inkas no-lock  on error undo, return error substitute( "&1 (validate-sequence c-inkas). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-inkas.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-inkas.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-inkas)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-fbr-doc"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-fbr-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-fbr-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-fbr-doc.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-fbr-doc.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-fbr-doc)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-rvs-doc"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-rvs-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-rvs-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-rvs-doc.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-rvs-doc.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-rvs-doc)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-trn-doc"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-trn-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-trn-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-trn-doc.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-trn-doc.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-trn-doc)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-wth-doc"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-wth-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-wth-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-wth-doc.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-wth-doc.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-wth-doc)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-fin-bank"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-fin-bank no-lock  on error undo, return error substitute( "&1 (validate-sequence c-fin-bank). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-fin-bank.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-fin-bank.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-fin-bank)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-fin-schet"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-fin-schet no-lock  on error undo, return error substitute( "&1 (validate-sequence c-fin-schet). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-fin-schet.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-fin-schet.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-fin-schet)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-fin-ob"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-fin-ob no-lock  on error undo, return error substitute( "&1 (validate-sequence c-fin-ob). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-fin-ob.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-fin-ob.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-fin-ob)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-fin-doc"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-fin-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-fin-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-fin-doc.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-fin-doc.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-fin-doc)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-fin-doc-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-fin-doc-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-fin-doc-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-fin-doc-attr.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-fin-doc-attr.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-fin-doc-attr)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-group-period-validity"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-group-period-validity no-lock  on error undo, return error substitute( "&1 (validate-sequence c-group-period-validity). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-group-period-validity.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-group-period-validity.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-group-period-validity)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-tax-hist"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-tax-hist no-lock  on error undo, return error substitute( "&1 (validate-sequence c-tax-hist). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-tax-hist.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-tax-hist.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-tax-hist)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-cash-pay"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-cash-pay no-lock  on error undo, return error substitute( "&1 (validate-sequence c-cash-pay). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-cash-pay.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-cash-pay.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-cash-pay)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-condition-keeping"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-condition-keeping no-lock  on error undo, return error substitute( "&1 (validate-sequence c-condition-keeping). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-condition-keeping.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-condition-keeping.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-condition-keeping)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-deliv-type-cond-keep"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-deliv-type-cond-keep no-lock  on error undo, return error substitute( "&1 (validate-sequence c-deliv-type-cond-keep). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-deliv-type-cond-keep.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-deliv-type-cond-keep.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-deliv-type-cond-keep)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-delivery-subject"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-delivery-subject no-lock  on error undo, return error substitute( "&1 (validate-sequence c-delivery-subject). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-delivery-subject.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-delivery-subject.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-delivery-subject)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-delivery-type"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-delivery-type no-lock  on error undo, return error substitute( "&1 (validate-sequence c-delivery-type). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-delivery-type.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-delivery-type.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-delivery-type)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-delivery-type-subject"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-delivery-type-subject no-lock  on error undo, return error substitute( "&1 (validate-sequence c-delivery-type-subject). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-delivery-type-subject.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-delivery-type-subject.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-delivery-type-subject)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-var-deliv-gr-per-val"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-var-deliv-gr-per-val no-lock  on error undo, return error substitute( "&1 (validate-sequence c-var-deliv-gr-per-val). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-var-deliv-gr-per-val.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-var-deliv-gr-per-val.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-var-deliv-gr-per-val)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-variant-delivery"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-variant-delivery no-lock  on error undo, return error substitute( "&1 (validate-sequence c-variant-delivery). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-variant-delivery.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-variant-delivery.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-variant-delivery)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-ord-doc"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-ord-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-ord-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-ord-doc.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-ord-doc.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-ord-doc)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-fin-code-an-uchet"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-fin-code-an-uchet no-lock  on error undo, return error substitute( "&1 (validate-sequence c-fin-code-an-uchet). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-fin-code-an-uchet.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-fin-code-an-uchet.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-fin-code-an-uchet)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-fin-code-cel-nazn"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-fin-code-cel-nazn no-lock  on error undo, return error substitute( "&1 (validate-sequence c-fin-code-cel-nazn). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-fin-code-cel-nazn.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-fin-code-cel-nazn.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-fin-code-cel-nazn)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-fin-code-cor-acc"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-fin-code-cor-acc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-fin-code-cor-acc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-fin-code-cor-acc.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-fin-code-cor-acc.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-fin-code-cor-acc)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-ex-mark"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-ex-mark no-lock  on error undo, return error substitute( "&1 (validate-sequence c-ex-mark). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-ex-mark.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-ex-mark.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-ex-mark)     .   end. end.
                    assign   v-curr-seq-name  = "s-corr-chip"   v-table-name     = "c-contract"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-contract no-lock  on error undo, return error substitute( "&1 (validate-sequence c-contract). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-contract.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-contract.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-contract)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-corr-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-fbr-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-fbr-chip"   v-table-name     = "c-recipe"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-recipe no-lock  on error undo, return error substitute( "&1 (validate-sequence c-recipe). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-recipe.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-recipe.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-recipe)     .   end. end.
                    assign   v-curr-seq-name  = "s-fbr-chip"   v-table-name     = "c-recipe-gds"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-recipe-gds no-lock  on error undo, return error substitute( "&1 (validate-sequence c-recipe-gds). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-recipe-gds.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-recipe-gds.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-recipe-gds)     .   end. end.
                    assign   v-curr-seq-name  = "s-fbr-chip"   v-table-name     = "c-recipe-hist"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-recipe-hist no-lock  on error undo, return error substitute( "&1 (validate-sequence c-recipe-hist). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-recipe-hist.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-recipe-hist.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-recipe-hist)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fbr-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-gds-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-gds-chip"   v-table-name     = "c-gds-hist"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-gds-hist no-lock  on error undo, return error substitute( "&1 (validate-sequence c-gds-hist). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-gds-hist.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-gds-hist.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-gds-hist)     .   end. end.
                    assign   v-curr-seq-name  = "s-gds-chip"   v-table-name     = "c-table-bind"   v-seq-field-name = "chip-num-rec"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-table-bind no-lock  on error undo, return error substitute( "&1 (validate-sequence c-table-bind). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-table-bind.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-table-bind.chip-num-rec .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-table-bind)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-gds-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-cli-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-cli-chip"   v-table-name     = "c-cli-hist"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-cli-hist no-lock  on error undo, return error substitute( "&1 (validate-sequence c-cli-hist). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-cli-hist.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-cli-hist.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-cli-hist)     .   end. end.
                    assign   v-curr-seq-name  = "s-cli-chip"   v-table-name     = "c-dis-thbj-rule"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-dis-thbj-rule no-lock  on error undo, return error substitute( "&1 (validate-sequence c-dis-thbj-rule). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-dis-thbj-rule.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-dis-thbj-rule.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-dis-thbj-rule)     .   end. end.
                    assign   v-curr-seq-name  = "s-cli-chip"   v-table-name     = "c-thbj-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-thbj-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-thbj-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-thbj-attr.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-thbj-attr.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-thbj-attr)     .   end. end.
                    assign   v-curr-seq-name  = "s-cli-chip"   v-table-name     = "c-clients-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-clients-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-clients-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-clients-attr.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-clients-attr.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-clients-attr)     .   end. end.
                    assign   v-curr-seq-name  = "s-cli-chip"   v-table-name     = "c-clients"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-clients no-lock  on error undo, return error substitute( "&1 (validate-sequence c-clients). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-clients.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-clients.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-clients)     .   end. end.
                    assign   v-curr-seq-name  = "s-cli-chip"   v-table-name     = "c-firm"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-firm no-lock  on error undo, return error substitute( "&1 (validate-sequence c-firm). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-firm.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-firm.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-firm)     .   end. end.
                    assign   v-curr-seq-name  = "s-cli-chip"   v-table-name     = "c-person"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-person no-lock  on error undo, return error substitute( "&1 (validate-sequence c-person). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-person.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-person.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-person)     .   end. end.
                    assign   v-curr-seq-name  = "s-cli-chip"   v-table-name     = "c-dis-some-rule"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-dis-some-rule no-lock  on error undo, return error substitute( "&1 (validate-sequence c-dis-some-rule). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-dis-some-rule.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-dis-some-rule.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-dis-some-rule)     .   end. end.
                    assign   v-curr-seq-name  = "s-cli-chip"   v-table-name     = "c-dis-thbj-rule"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-dis-thbj-rule no-lock  on error undo, return error substitute( "&1 (validate-sequence c-dis-thbj-rule). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-dis-thbj-rule.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-dis-thbj-rule.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-dis-thbj-rule)     .   end. end.
                    assign   v-curr-seq-name  = "s-cli-chip"   v-table-name     = "c-ext-classif"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-ext-classif no-lock  on error undo, return error substitute( "&1 (validate-sequence c-ext-classif). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-ext-classif.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-ext-classif.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-ext-classif)     .   end. end.
                    assign   v-curr-seq-name  = "s-cli-chip"   v-table-name     = "c-shop"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-shop no-lock  on error undo, return error substitute( "&1 (validate-sequence c-shop). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-shop.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-shop.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-shop)     .   end. end.
                    assign   v-curr-seq-name  = "s-cli-chip"   v-table-name     = "c-staff"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-staff no-lock  on error undo, return error substitute( "&1 (validate-sequence c-staff). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-staff.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-staff.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-staff)     .   end. end.
                    assign   v-curr-seq-name  = "s-cli-chip"   v-table-name     = "c-store"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-store no-lock  on error undo, return error substitute( "&1 (validate-sequence c-store). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-store.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-store.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-store)     .   end. end.
                    assign   v-curr-seq-name  = "s-cli-chip"   v-table-name     = "c-sysconf"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-sysconf no-lock  on error undo, return error substitute( "&1 (validate-sequence c-sysconf). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-sysconf.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-sysconf.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-sysconf)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-cli-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-dc-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-dc-chip"   v-table-name     = "c-dis-card"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-dis-card no-lock  on error undo, return error substitute( "&1 (validate-sequence c-dis-card). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-dis-card.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-dis-card.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-dis-card)     .   end. end.
                    assign   v-curr-seq-name  = "s-dc-chip"   v-table-name     = "c-dis-card-property"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-dis-card-property no-lock  on error undo, return error substitute( "&1 (validate-sequence c-dis-card-property). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-dis-card-property.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-dis-card-property.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-dis-card-property)     .   end. end.
                    assign   v-curr-seq-name  = "s-dc-chip"   v-table-name     = "c-dis-dc-rule"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-dis-dc-rule no-lock  on error undo, return error substitute( "&1 (validate-sequence c-dis-dc-rule). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-dis-dc-rule.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-dis-dc-rule.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-dis-dc-rule)     .   end. end.
                    assign   v-curr-seq-name  = "s-dc-chip"   v-table-name     = "c-dis-obj"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-dis-obj no-lock  on error undo, return error substitute( "&1 (validate-sequence c-dis-obj). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-dis-obj.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-dis-obj.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-dis-obj)     .   end. end.
                    assign   v-curr-seq-name  = "s-dc-chip"   v-table-name     = "c-dis-host"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-dis-host no-lock  on error undo, return error substitute( "&1 (validate-sequence c-dis-host). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-dis-host.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-dis-host.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-dis-host)     .   end. end.
                    assign   v-curr-seq-name  = "s-dc-chip"   v-table-name     = "c-dc-hist"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-dc-hist no-lock  on error undo, return error substitute( "&1 (validate-sequence c-dc-hist). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-dc-hist.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-dc-hist.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-dc-hist)     .   end. end.
                    assign   v-curr-seq-name  = "s-dc-chip"   v-table-name     = "c-dis-card-type"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-dis-card-type no-lock  on error undo, return error substitute( "&1 (validate-sequence c-dis-card-type). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-dis-card-type.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-dis-card-type.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-dis-card-type)     .   end. end.
                    assign   v-curr-seq-name  = "s-dc-chip"   v-table-name     = "c-dis-card-type-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-dis-card-type-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-dis-card-type-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-dis-card-type-attr.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-dis-card-type-attr.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-dis-card-type-attr)     .   end. end.
                    assign   v-curr-seq-name  = "s-dc-chip"   v-table-name     = "c-dis-card-mask"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-dis-card-mask no-lock  on error undo, return error substitute( "&1 (validate-sequence c-dis-card-mask). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-dis-card-mask.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-dis-card-mask.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-dis-card-mask)     .   end. end.
                    assign   v-curr-seq-name  = "s-dc-chip"   v-table-name     = "c-dis-rule"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-dis-rule no-lock  on error undo, return error substitute( "&1 (validate-sequence c-dis-rule). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-dis-rule.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-dis-rule.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-dis-rule)     .   end. end.
                    assign   v-curr-seq-name  = "s-dc-chip"   v-table-name     = "c-dis-time-rule"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-dis-time-rule no-lock  on error undo, return error substitute( "&1 (validate-sequence c-dis-time-rule). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-dis-time-rule.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-dis-time-rule.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-dis-time-rule)     .   end. end.
                    assign   v-curr-seq-name  = "s-dc-chip"   v-table-name     = "c-dis-dct-rule"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-dis-dct-rule no-lock  on error undo, return error substitute( "&1 (validate-sequence c-dis-dct-rule). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-dis-dct-rule.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-dis-dct-rule.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-dis-dct-rule)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-dc-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-scales-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-scales-chip"   v-table-name     = "c-scales"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-scales no-lock  on error undo, return error substitute( "&1 (validate-sequence c-scales). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-scales.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-scales.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-scales)     .   end. end.
                    assign   v-curr-seq-name  = "s-scales-chip"   v-table-name     = "c-fbr-prn"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-fbr-prn no-lock  on error undo, return error substitute( "&1 (validate-sequence c-fbr-prn). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-fbr-prn.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-fbr-prn.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-fbr-prn)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-scales-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-cash-desk-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-cash-desk-chip"   v-table-name     = "c-cash-desk"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-cash-desk no-lock  on error undo, return error substitute( "&1 (validate-sequence c-cash-desk). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-cash-desk.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-cash-desk.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-cash-desk)     .   end. end.
                    assign   v-curr-seq-name  = "s-cash-desk-chip"   v-table-name     = "c-cash-desk-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-cash-desk-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-cash-desk-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-cash-desk-attr.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-cash-desk-attr.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-cash-desk-attr)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-cash-desk-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-curr-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-curr-chip"   v-table-name     = "c-currency"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-currency no-lock  on error undo, return error substitute( "&1 (validate-sequence c-currency). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-currency.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-currency.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-currency)     .   end. end.
                    assign   v-curr-seq-name  = "s-curr-chip"   v-table-name     = "c-curr-accnt"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-curr-accnt no-lock  on error undo, return error substitute( "&1 (validate-sequence c-curr-accnt). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-curr-accnt.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-curr-accnt.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-curr-accnt)     .   end. end.
                    assign   v-curr-seq-name  = "s-curr-chip"   v-table-name     = "c-curr-bank"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-curr-bank no-lock  on error undo, return error substitute( "&1 (validate-sequence c-curr-bank). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-curr-bank.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-curr-bank.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-curr-bank)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-curr-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-wth-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-wth-chip"   v-table-name     = "c-wth-hist"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-wth-hist no-lock  on error undo, return error substitute( "&1 (validate-sequence c-wth-hist). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-wth-hist.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-wth-hist.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-wth-hist)     .   end. end.
                    assign   v-curr-seq-name  = "s-wth-chip"   v-table-name     = "c-wth-place"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-wth-place no-lock  on error undo, return error substitute( "&1 (validate-sequence c-wth-place). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-wth-place.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-wth-place.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-wth-place)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-wth-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-task-num :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-task-num"   v-table-name     = "schedule"   v-seq-field-name = "task-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.schedule no-lock  on error undo, return error substitute( "&1 (validate-sequence schedule). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.schedule.cre-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.schedule.task-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.schedule)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-task-num" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-nws-hist :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-nws-hist"   v-table-name     = "nws-doc-hist"   v-seq-field-name = "ord-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.nws-doc-hist no-lock  on error undo, return error substitute( "&1 (validate-sequence nws-doc-hist). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.nws-doc-hist.ord-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.nws-doc-hist)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-nws-hist" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-fin-bank :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-fin-bank"   v-table-name     = "fin-bank"   v-seq-field-name = "code-bank"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.fin-bank no-lock  on error undo, return error substitute( "&1 (validate-sequence fin-bank). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.fin-bank.code-bank.   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.fin-bank)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fin-bank" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-fin-ob :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-fin-ob"   v-table-name     = "fin-ob"   v-seq-field-name = "doc-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.fin-ob no-lock  on error undo, return error substitute( "&1 (validate-sequence fin-ob). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.fin-ob.doc-code) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.fin-ob)     .   end. end.
                assign   v-curr-seq-name  = "s-fin-ob"   v-table-name     = "fin-ob-before"   v-seq-field-name = "before-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.fin-ob-before no-lock  on error undo, return error substitute( "&1 (validate-sequence fin-ob-before). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.fin-ob-before.before-code) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.fin-ob-before)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fin-ob" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-fin-code :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-fin-code"   v-table-name     = "fin-code-an-uchet"   v-seq-field-name = "fin-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.fin-code-an-uchet no-lock  on error undo, return error substitute( "&1 (validate-sequence fin-code-an-uchet). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.fin-code-an-uchet.fin-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.fin-code-an-uchet)     .   end. end.
                assign   v-curr-seq-name  = "s-fin-code"   v-table-name     = "fin-code-cel-nazn"   v-seq-field-name = "fin-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.fin-code-cel-nazn no-lock  on error undo, return error substitute( "&1 (validate-sequence fin-code-cel-nazn). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.fin-code-cel-nazn.fin-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.fin-code-cel-nazn)     .   end. end.
                assign   v-curr-seq-name  = "s-fin-code"   v-table-name     = "fin-code-cor-acc"   v-seq-field-name = "fin-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.fin-code-cor-acc no-lock  on error undo, return error substitute( "&1 (validate-sequence fin-code-cor-acc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.fin-code-cor-acc.fin-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.fin-code-cor-acc)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fin-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-fin-doc :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    define variable v-fd-code as   int64              no-undo .
        assign
      v-curr-seq-name  = "s-fin-doc"
      v-table-name     = "fin-doc"
      v-seq-field-name = "fin-doc-code"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .
    do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.
    find restseq.code-range no-lock
      where restseq.code-range.range-type = 'fdgb':U
        and restseq.code-range.db-num     = p-curr-db-num
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-fd-code
                        ).
      assign
        v-curr-seq-value = v-fd-code
      .
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fin-doc" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
    else do:
      find restseq.code-range no-lock
        where restseq.code-range.range-type = 'fdgb':U
          and restseq.code-range.db-num     = p-curr-db-num
          and restseq.code-range.stts       = "u":U
        no-error
      .
      if available restseq.code-range then do:
        assign
          v-curr-seq-value = restseq.code-range.last-code
        .
        if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fin-doc" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
      end.
    end.
  end.
end procedure.
procedure restore-s-fin-sttm :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-fin-sttm"   v-table-name     = "fin-statement"   v-seq-field-name = "sttm-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.fin-statement no-lock  on error undo, return error substitute( "&1 (validate-sequence fin-statement). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.fin-statement.sttm-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.fin-statement)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fin-sttm" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-fin-ob-fact :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-fin-ob-fact"   v-table-name     = "fin-ob"   v-seq-field-name = "fact-order"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.fin-ob no-lock  on error undo, return error substitute( "&1 (validate-sequence fin-ob). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   run factord-to-fact-num in this-procedure (restseq.fin-ob.fact-order, output v-new-seq-value)  .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.fin-ob)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fin-ob-fact" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-fin-doc-fact :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-fin-doc-fact"   v-table-name     = "fin-doc"   v-seq-field-name = "fact-order"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.fin-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence fin-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   run factord-to-fact-num in this-procedure (restseq.fin-doc.fact-order, output v-new-seq-value)  .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.fin-doc)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fin-doc-fact" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-fin-sttm-fact :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-fin-sttm-fact"   v-table-name     = "fin-statement"   v-seq-field-name = "fact-order"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.fin-statement no-lock  on error undo, return error substitute( "&1 (validate-sequence fin-statement). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   run factord-to-fact-num in this-procedure (restseq.fin-statement.fact-order, output v-new-seq-value)  .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.fin-statement)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fin-sttm-fact" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-ctgb-code :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    define variable v-dc-code as   int64              no-undo .
        assign
      v-curr-seq-name  = "s-ctgb-code"
      v-table-name     = "contract"
      v-seq-field-name = "contract-code"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .
    do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.
    find restseq.code-range no-lock
      where restseq.code-range.range-type = 'ctgb':U
        and restseq.code-range.db-num     = p-curr-db-num
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-dc-code
                        ).
      assign v-curr-seq-value = v-dc-code .
      if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-ctgb-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
    end.
  end.
end procedure.
procedure restore-s-chip-contract-specif :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-chip-contract-specif"   v-table-name     = "c-contract-specif"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-contract-specif no-lock  on error undo, return error substitute( "&1 (validate-sequence c-contract-specif). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-contract-specif.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-contract-specif.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-contract-specif)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-chip-contract-specif" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-sf-doc :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-sf-doc"   v-table-name     = "schet-fact-doc"   v-seq-field-name = "doc-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.schet-fact-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence schet-fact-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.schet-fact-doc.doc-code) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.schet-fact-doc)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-sf-doc" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-fin-connect :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-fin-connect"   v-table-name     = "fin-connect"   v-seq-field-name = "connect-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.fin-connect no-lock  on error undo, return error substitute( "&1 (validate-sequence fin-connect). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.fin-connect.connect-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.fin-connect)     .   end. end.
                assign   v-curr-seq-name  = "s-fin-connect"   v-table-name     = "factur-connect"   v-seq-field-name = "connect-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.factur-connect no-lock  on error undo, return error substitute( "&1 (validate-sequence factur-connect). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.factur-connect.connect-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.factur-connect)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fin-connect" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-fin-schet :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-fin-schet"   v-table-name     = "fin-schet"   v-seq-field-name = "code-schet"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.fin-schet no-lock  on error undo, return error substitute( "&1 (validate-sequence fin-schet). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.fin-schet.code-schet .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.fin-schet)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fin-schet" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-place-io :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-place-io"   v-table-name     = "place-io"   v-seq-field-name = "place-io-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.place-io no-lock  on error undo, return error substitute( "&1 (validate-sequence place-io). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.place-io.place-io-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.place-io)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-place-io" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-chip-place-io :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                        assign   v-curr-seq-name  = "s-chip-place-io"   v-table-name     = "c-place-io"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-place-io no-lock  on error undo, return error substitute( "&1 (validate-sequence c-place-io). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-place-io.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-place-io.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-place-io)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-chip-place-io" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-point-io :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-point-io"   v-table-name     = "point-io"   v-seq-field-name = "point-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.point-io no-lock  on error undo, return error substitute( "&1 (validate-sequence point-io). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.point-io.point-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.point-io)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-point-io" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-chip-point-io :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                        assign   v-curr-seq-name  = "s-chip-point-io"   v-table-name     = "c-point-io"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-point-io no-lock  on error undo, return error substitute( "&1 (validate-sequence c-point-io). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-point-io.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-point-io.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-point-io)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-chip-point-io" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-delivery :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "delivery"   v-table-name     = "group-period-validity"   v-seq-field-name = "gr-per-val-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.group-period-validity no-lock  on error undo, return error substitute( "&1 (validate-sequence group-period-validity). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.group-period-validity.gr-per-val-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.group-period-validity)     .   end. end.
                assign   v-curr-seq-name  = "delivery"   v-table-name     = "condition-keeping"   v-seq-field-name = "cond-keep-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.condition-keeping no-lock  on error undo, return error substitute( "&1 (validate-sequence condition-keeping). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.condition-keeping.cond-keep-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.condition-keeping)     .   end. end.
                assign   v-curr-seq-name  = "delivery"   v-table-name     = "delivery-type"   v-seq-field-name = "deliv-type-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.delivery-type no-lock  on error undo, return error substitute( "&1 (validate-sequence delivery-type). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.delivery-type.deliv-type-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.delivery-type)     .   end. end.
                assign   v-curr-seq-name  = "delivery"   v-table-name     = "delivery-subject"   v-seq-field-name = "deliv-subj-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.delivery-subject no-lock  on error undo, return error substitute( "&1 (validate-sequence delivery-subject). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.delivery-subject.deliv-subj-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.delivery-subject)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "delivery" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-gds-grp-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-gds-grp-chip"   v-table-name     = "c-gds-grp-hist"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-gds-grp-hist no-lock  on error undo, return error substitute( "&1 (validate-sequence c-gds-grp-hist). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-gds-grp-hist.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-gds-grp-hist.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-gds-grp-hist)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-gds-grp-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-cli-grp-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-cli-grp-chip"   v-table-name     = "c-cli-grp"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-cli-grp no-lock  on error undo, return error substitute( "&1 (validate-sequence c-cli-grp). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-cli-grp.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-cli-grp.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-cli-grp)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-cli-grp-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-drgb-code :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    define variable v-dr-code as   int64              no-undo .
        assign
      v-curr-seq-name  = "s-drgb-code"
      v-table-name     = "dis-rule"
      v-seq-field-name = "rule-num"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .
    do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.
    find restseq.code-range no-lock
      where restseq.code-range.range-type = 'drgb':U
        and restseq.code-range.db-num     = p-curr-db-num
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-dr-code
                        ).
      assign
        v-curr-seq-value = v-dr-code
      .
      if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-drgb-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
    end.
    else do:
      find restseq.code-range no-lock
        where restseq.code-range.range-type = 'drgb':U
          and restseq.code-range.db-num     = p-curr-db-num
          and restseq.code-range.stts       = "u":U
        no-error
      .
      if available restseq.code-range then do:
        assign
          v-curr-seq-value = restseq.code-range.last-code
        .
        if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-drgb-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
      end.
    end.
  end.
end procedure.
procedure restore-s-file-num-2 :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-file-num-2"   v-table-name     = "cd-grp"   v-seq-field-name = "grp-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.cd-grp no-lock  on error undo, return error substitute( "&1 (validate-sequence cd-grp). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if index(restseq.cd-grp.grp-type, 'session') = 0 then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.cd-grp.grp-code.   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.cd-grp)     .   end. end.
                assign   v-curr-seq-name  = "s-file-num-2"   v-table-name     = "cd-grp"   v-seq-field-name = "grp-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.cd-grp no-lock  on error undo, return error substitute( "&1 (validate-sequence cd-grp). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.cd-grp.grp-code.   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.cd-grp)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-file-num-2" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-ext-system :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-ext-system"   v-table-name     = "ext-system"   v-seq-field-name = "esys-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.ext-system no-lock  on error undo, return error substitute( "&1 (validate-sequence ext-system). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.ext-system.esys-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.ext-system)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-ext-system" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-asmt :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-asmt"   v-table-name     = "assortment-matrix"   v-seq-field-name = "asmt-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.assortment-matrix no-lock  on error undo, return error substitute( "&1 (validate-sequence assortment-matrix). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.assortment-matrix.asmt-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.assortment-matrix)     .   end. end.
                assign   v-curr-seq-name  = "s-asmt"   v-table-name     = "abc-analysis"   v-seq-field-name = "abc-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.abc-analysis no-lock  on error undo, return error substitute( "&1 (validate-sequence abc-analysis). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.abc-analysis.abc-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.abc-analysis)     .   end. end.
                assign   v-curr-seq-name  = "s-asmt"   v-table-name     = "xyz-analysis"   v-seq-field-name = "xyz-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.xyz-analysis no-lock  on error undo, return error substitute( "&1 (validate-sequence xyz-analysis). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.xyz-analysis.xyz-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.xyz-analysis)     .   end. end.
                assign   v-curr-seq-name  = "s-asmt"   v-table-name     = "abcxyz-analysis"   v-seq-field-name = "abcx-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.abcxyz-analysis no-lock  on error undo, return error substitute( "&1 (validate-sequence abcxyz-analysis). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.abcxyz-analysis.abcx-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.abcxyz-analysis)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-asmt" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-news-ord :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-news-ord"   v-table-name     = "route"   v-seq-field-name = "tbl-ord"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.route no-lock  on error undo, return error substitute( "&1 (validate-sequence route). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.route.tbl-ord .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.route)     .   end. end.
                    assign   v-curr-seq-name  = "s-news-ord"   v-table-name     = "esys-route"   v-seq-field-name = "esr-tbl-ord"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.esys-route no-lock  on error undo, return error substitute( "&1 (validate-sequence esys-route). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.esys-route.esr-tbl-ord .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.esys-route)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-news-ord" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-news-dord :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-news-dord"   v-table-name     = "route-dump"   v-seq-field-name = "dump-ord"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.route-dump no-lock  on error undo, return error substitute( "&1 (validate-sequence route-dump). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.route-dump.dump-ord .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.route-dump)     .   end. end.
                    assign   v-curr-seq-name  = "s-news-dord"   v-table-name     = "route"   v-seq-field-name = "dump-ord"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.route no-lock  on error undo, return error substitute( "&1 (validate-sequence route). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.route.dump-ord .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.route)     .   end. end.
                    assign   v-curr-seq-name  = "s-news-dord"   v-table-name     = "esys-route"   v-seq-field-name = "esr-dump-ord"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.esys-route no-lock  on error undo, return error substitute( "&1 (validate-sequence esys-route). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.esys-route.esr-dump-ord .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.esys-route)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-news-dord" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-fin-corr-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-fin-corr-chip"   v-table-name     = "c-fin-statement"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-fin-statement no-lock  on error undo, return error substitute( "&1 (validate-sequence c-fin-statement). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-fin-statement.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-fin-statement.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-fin-statement)     .   end. end.
                    assign   v-curr-seq-name  = "s-fin-corr-chip"   v-table-name     = "c-fin-statement-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-fin-statement-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-fin-statement-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-fin-statement-attr.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-fin-statement-attr.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-fin-statement-attr)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fin-corr-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-ref-corr-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-auto-tank"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-auto-tank no-lock  on error undo, return error substitute( "&1 (validate-sequence c-auto-tank). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-auto-tank.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-auto-tank.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-auto-tank)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-country"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-country no-lock  on error undo, return error substitute( "&1 (validate-sequence c-country). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-country.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-country.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-country)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-dis-cfg-rule"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-dis-cfg-rule no-lock  on error undo, return error substitute( "&1 (validate-sequence c-dis-cfg-rule). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-dis-cfg-rule.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-dis-cfg-rule.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-dis-cfg-rule)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-prop-head"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-prop-head no-lock  on error undo, return error substitute( "&1 (validate-sequence c-prop-head). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-prop-head.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-prop-head.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-prop-head)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-prop-ref"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-prop-ref no-lock  on error undo, return error substitute( "&1 (validate-sequence c-prop-ref). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-prop-ref.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-prop-ref.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-prop-ref)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-prop-ruleset"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-prop-ruleset no-lock  on error undo, return error substitute( "&1 (validate-sequence c-prop-ruleset). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-prop-ruleset.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-prop-ruleset.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-prop-ruleset)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-prop-script"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-prop-script no-lock  on error undo, return error substitute( "&1 (validate-sequence c-prop-script). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-prop-script.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-prop-script.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-prop-script)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-pscript-ruleset"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-pscript-ruleset no-lock  on error undo, return error substitute( "&1 (validate-sequence c-pscript-ruleset). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-pscript-ruleset.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-pscript-ruleset.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-pscript-ruleset)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-ext-classif"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-ext-classif no-lock  on error undo, return error substitute( "&1 (validate-sequence c-ext-classif). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-ext-classif.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-ext-classif.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-ext-classif)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-rule-profile"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-rule-profile no-lock  on error undo, return error substitute( "&1 (validate-sequence c-rule-profile). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-rule-profile.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-rule-profile.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-rule-profile)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-rule-process"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-rule-process no-lock  on error undo, return error substitute( "&1 (validate-sequence c-rule-process). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-rule-process.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-rule-process.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-rule-process)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-rule"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-rule no-lock  on error undo, return error substitute( "&1 (validate-sequence c-rule). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-rule.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-rule.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-rule)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-ruledict"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-ruledict no-lock  on error undo, return error substitute( "&1 (validate-sequence c-ruledict). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-ruledict.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-ruledict.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-ruledict)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-ruleset"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-ruleset no-lock  on error undo, return error substitute( "&1 (validate-sequence c-ruleset). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-ruleset.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-ruleset.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-ruleset)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-gds-prt"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-gds-prt no-lock  on error undo, return error substitute( "&1 (validate-sequence c-gds-prt). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-gds-prt.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-gds-prt.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-gds-prt)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-pay-type"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-pay-type no-lock  on error undo, return error substitute( "&1 (validate-sequence c-pay-type). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-pay-type.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-pay-type.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-pay-type)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-sum-grp"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-sum-grp no-lock  on error undo, return error substitute( "&1 (validate-sequence c-sum-grp). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-sum-grp.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-sum-grp.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-sum-grp)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-units"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-units no-lock  on error undo, return error substitute( "&1 (validate-sequence c-units). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-units.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-units.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-units)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-ext-system"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-ext-system no-lock  on error undo, return error substitute( "&1 (validate-sequence c-ext-system). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-ext-system.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-ext-system.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-ext-system)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-layout-elem"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-layout-elem no-lock  on error undo, return error substitute( "&1 (validate-sequence c-layout-elem). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-layout-elem.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-layout-elem.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-layout-elem)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-wi-mode"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-wi-mode no-lock  on error undo, return error substitute( "&1 (validate-sequence c-wi-mode). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-wi-mode.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-wi-mode.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-wi-mode)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-dis-grp-rule"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-dis-grp-rule no-lock  on error undo, return error substitute( "&1 (validate-sequence c-dis-grp-rule). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-dis-grp-rule.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-dis-grp-rule.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-dis-grp-rule)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-hist-nws-option"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-hist-nws-option no-lock  on error undo, return error substitute( "&1 (validate-sequence c-hist-nws-option). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-hist-nws-option.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-hist-nws-option.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-hist-nws-option)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-layout"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-layout no-lock  on error undo, return error substitute( "&1 (validate-sequence c-layout). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-layout.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-layout.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-layout)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-profile-by-profile"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-profile-by-profile no-lock  on error undo, return error substitute( "&1 (validate-sequence c-profile-by-profile). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-profile-by-profile.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-profile-by-profile.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-profile-by-profile)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-rp-by-call"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-rp-by-call no-lock  on error undo, return error substitute( "&1 (validate-sequence c-rp-by-call). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-rp-by-call.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-rp-by-call.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-rp-by-call)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-rp-rule-param"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-rp-rule-param no-lock  on error undo, return error substitute( "&1 (validate-sequence c-rp-rule-param). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-rp-rule-param.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-rp-rule-param.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-rp-rule-param)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-rule-by-call"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-rule-by-call no-lock  on error undo, return error substitute( "&1 (validate-sequence c-rule-by-call). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-rule-by-call.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-rule-by-call.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-rule-by-call)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-rule-by-profile"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-rule-by-profile no-lock  on error undo, return error substitute( "&1 (validate-sequence c-rule-by-profile). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-rule-by-profile.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-rule-by-profile.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-rule-by-profile)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-rule-by-set"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-rule-by-set no-lock  on error undo, return error substitute( "&1 (validate-sequence c-rule-by-set). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-rule-by-set.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-rule-by-set.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-rule-by-set)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-rule-call-param"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-rule-call-param no-lock  on error undo, return error substitute( "&1 (validate-sequence c-rule-call-param). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-rule-call-param.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-rule-call-param.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-rule-call-param)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-ruledict-param"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-ruledict-param no-lock  on error undo, return error substitute( "&1 (validate-sequence c-ruledict-param). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-ruledict-param.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-ruledict-param.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-ruledict-param)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-sr-izmerenia"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-sr-izmerenia no-lock  on error undo, return error substitute( "&1 (validate-sequence c-sr-izmerenia). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-sr-izmerenia.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-sr-izmerenia.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-sr-izmerenia)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-stop-list"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-stop-list no-lock  on error undo, return error substitute( "&1 (validate-sequence c-stop-list). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-stop-list.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-stop-list.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-stop-list)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-corr-chip"   v-table-name     = "c-tare"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-tare no-lock  on error undo, return error substitute( "&1 (validate-sequence c-tare). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-tare.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-tare.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-tare)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-ref-corr-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-ref-obj-corr-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-ref-obj-corr-chip"   v-table-name     = "c-assortment-matrix"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-assortment-matrix no-lock  on error undo, return error substitute( "&1 (validate-sequence c-assortment-matrix). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-assortment-matrix.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-assortment-matrix.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-assortment-matrix)     .   end. end.
                    assign   v-curr-seq-name  = "s-ref-obj-corr-chip"   v-table-name     = "c-sum-grp-obj"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-sum-grp-obj no-lock  on error undo, return error substitute( "&1 (validate-sequence c-sum-grp-obj). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-sum-grp-obj.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-sum-grp-obj.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-sum-grp-obj)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-ref-obj-corr-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-plc-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-plc-chip"   v-table-name     = "c-plc-hist"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-plc-hist no-lock  on error undo, return error substitute( "&1 (validate-sequence c-plc-hist). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-plc-hist.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-plc-hist.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-plc-hist)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-plc-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-pmp-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-pmp-chip"   v-table-name     = "c-pmp-hist"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-pmp-hist no-lock  on error undo, return error substitute( "&1 (validate-sequence c-pmp-hist). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-pmp-hist.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-pmp-hist.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-pmp-hist)     .   end. end.
                    assign   v-curr-seq-name  = "s-pmp-chip"   v-table-name     = "c-pump-nozzle"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-pump-nozzle no-lock  on error undo, return error substitute( "&1 (validate-sequence c-pump-nozzle). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-pump-nozzle.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-pump-nozzle.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-pump-nozzle)     .   end. end.
                    assign   v-curr-seq-name  = "s-pmp-chip"   v-table-name     = "c-pump-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-pump-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-pump-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-pump-attr.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-pump-attr.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-pump-attr)     .   end. end.
                    assign   v-curr-seq-name  = "s-pmp-chip"   v-table-name     = "c-pump"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-pump no-lock  on error undo, return error substitute( "&1 (validate-sequence c-pump). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-pump.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-pump.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-pump)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-pmp-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-nzl-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-nzl-chip"   v-table-name     = "c-nzl-hist"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-nzl-hist no-lock  on error undo, return error substitute( "&1 (validate-sequence c-nzl-hist). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-nzl-hist.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-nzl-hist.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-nzl-hist)     .   end. end.
                    assign   v-curr-seq-name  = "s-nzl-chip"   v-table-name     = "c-nozzle-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-nozzle-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-nozzle-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-nozzle-attr.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-nozzle-attr.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-nozzle-attr)     .   end. end.
                    assign   v-curr-seq-name  = "s-nzl-chip"   v-table-name     = "c-nozzle"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-nozzle no-lock  on error undo, return error substitute( "&1 (validate-sequence c-nozzle). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-nozzle.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-nozzle.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-nozzle)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-nzl-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-fbr-gds-grp-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-fbr-gds-grp-chip"   v-table-name     = "c-fbr-gds-grp-hist"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-fbr-gds-grp-hist no-lock  on error undo, return error substitute( "&1 (validate-sequence c-fbr-gds-grp-hist). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-fbr-gds-grp-hist.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-fbr-gds-grp-hist.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-fbr-gds-grp-hist)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-fbr-gds-grp-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-shift-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-shift-chip"   v-table-name     = "c-sht-hist"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-sht-hist no-lock  on error undo, return error substitute( "&1 (validate-sequence c-sht-hist). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-sht-hist.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-sht-hist.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-sht-hist)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-shift-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-sert-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-sert-chip"   v-table-name     = "c-sert"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-sert no-lock  on error undo, return error substitute( "&1 (validate-sequence c-sert). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-sert.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-sert.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-sert)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-sert-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-rule-profile :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    if p-curr-db-num > 0 then do:
      return.
    end.
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-rule-profile"   v-table-name     = "rule-profile"   v-seq-field-name = "profile_id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.rule-profile no-lock  on error undo, return error substitute( "&1 (validate-sequence rule-profile). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.rule-profile.profile_id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.rule-profile)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-rule-profile" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-rule-id :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    if p-curr-db-num > 0 then do:
      return.
    end.
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-rule-id"   v-table-name     = "rule"   v-seq-field-name = "rule_id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.rule no-lock  on error undo, return error substitute( "&1 (validate-sequence rule). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.rule.rule_id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.rule)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-rule-id" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-rule-script-id :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    if p-curr-db-num > 0 then do:
      return.
    end.
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-rule-script-id"   v-table-name     = "rule-script"   v-seq-field-name = "script_id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.rule-script no-lock  on error undo, return error substitute( "&1 (validate-sequence rule-script). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.rule-script.script_id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.rule-script)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-rule-script-id" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-cagb-code :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    define variable v-ca-code as   int64              no-undo .
        assign
      v-curr-seq-name  = "s-cagb-code"
      v-table-name     = "rule-by-call"
      v-seq-field-name = "call#_id"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .
    do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.
    find restseq.code-range no-lock
      where restseq.code-range.range-type = 'cagb':U
        and restseq.code-range.db-num     = p-curr-db-num
        and restseq.code-range.stts       = "a":U
      no-error
    .
    if available restseq.code-range then do:
      run get-max-code ( input "get-m-code":U
                        ,input restseq.code-range.db-num
                        ,input restseq.code-range.range-type
                        ,input restseq.code-range.first-code
                        ,input restseq.code-range.last-code
                        ,input FALSE
                        ,output v-ca-code
                        ).
      assign
        v-curr-seq-value = v-ca-code
      .
      if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-cagb-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
    end.
    else do:
      find restseq.code-range no-lock
        where restseq.code-range.range-type = 'cagb':U
          and restseq.code-range.db-num     = p-curr-db-num
          and restseq.code-range.stts       = "u":U
        no-error
      .
      if available restseq.code-range then do:
        assign
          v-curr-seq-value = restseq.code-range.last-code
        .
        if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-cagb-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
      end.
    end.
  end.
end procedure.
procedure restore-s-hn-id :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    if p-curr-db-num > 0 then do:
      return.
    end.
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-hn-id"   v-table-name     = "hist-nws-option"   v-seq-field-name = "hn-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.hist-nws-option no-lock  on error undo, return error substitute( "&1 (validate-sequence hist-nws-option). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.hist-nws-option.hn-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.hist-nws-option)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-hn-id" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-cfg-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-cfg-chip"   v-table-name     = "c-config"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-config no-lock  on error undo, return error substitute( "&1 (validate-sequence c-config). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-config.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-config.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-config)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-cfg-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-ex-mark :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-ex-mark"   v-table-name     = "ex-mark"   v-seq-field-name = "mark-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.ex-mark no-lock  on error undo, return error substitute( "&1 (validate-sequence ex-mark). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.ex-mark.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.ex-mark.mark-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.ex-mark)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-ex-mark" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-chip-mp :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-global-state"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-global-state no-lock  on error undo, return error substitute( "&1 (validate-sequence c-global-state). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-global-state.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-global-state.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-global-state)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-global-state-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-global-state-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-global-state-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-global-state-attr.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-global-state-attr.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-global-state-attr)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-sum-group"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-sum-group no-lock  on error undo, return error substitute( "&1 (validate-sequence c-sum-group). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-sum-group.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-sum-group.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-sum-group)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-sum-in-sum-group"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-sum-in-sum-group no-lock  on error undo, return error substitute( "&1 (validate-sequence c-sum-in-sum-group). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-sum-in-sum-group.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-sum-in-sum-group.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-sum-in-sum-group)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-qnty-group"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-qnty-group no-lock  on error undo, return error substitute( "&1 (validate-sequence c-qnty-group). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-qnty-group.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-qnty-group.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-qnty-group)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-qnty-in-qnty-group"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-qnty-in-qnty-group no-lock  on error undo, return error substitute( "&1 (validate-sequence c-qnty-in-qnty-group). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-qnty-in-qnty-group.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-qnty-in-qnty-group.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-qnty-in-qnty-group)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-turnover-group"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-turnover-group no-lock  on error undo, return error substitute( "&1 (validate-sequence c-turnover-group). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-turnover-group.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-turnover-group.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-turnover-group)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-tnv-in-turnover-group"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-tnv-in-turnover-group no-lock  on error undo, return error substitute( "&1 (validate-sequence c-tnv-in-turnover-group). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-tnv-in-turnover-group.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-tnv-in-turnover-group.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-tnv-in-turnover-group)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-buyer-group"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-buyer-group no-lock  on error undo, return error substitute( "&1 (validate-sequence c-buyer-group). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-buyer-group.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-buyer-group.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-buyer-group)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-buyer-in-buyer-group"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-buyer-in-buyer-group no-lock  on error undo, return error substitute( "&1 (validate-sequence c-buyer-in-buyer-group). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-buyer-in-buyer-group.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-buyer-in-buyer-group.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-buyer-in-buyer-group)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-price-list-type"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-price-list-type no-lock  on error undo, return error substitute( "&1 (validate-sequence c-price-list-type). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-price-list-type.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-price-list-type.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-price-list-type)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-price-list-type-pay-type"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-price-list-type-pay-type no-lock  on error undo, return error substitute( "&1 (validate-sequence c-price-list-type-pay-type). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-price-list-type-pay-type.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-price-list-type-pay-type.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-price-list-type-pay-type)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-price-list-type-cassa"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-price-list-type-cassa no-lock  on error undo, return error substitute( "&1 (validate-sequence c-price-list-type-cassa). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-price-list-type-cassa.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-price-list-type-cassa.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-price-list-type-cassa)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-price-list-type-gds-grp"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-price-list-type-gds-grp no-lock  on error undo, return error substitute( "&1 (validate-sequence c-price-list-type-gds-grp). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-price-list-type-gds-grp.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-price-list-type-gds-grp.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-price-list-type-gds-grp)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-price-list-type-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-price-list-type-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-price-list-type-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-price-list-type-attr.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-price-list-type-attr.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-price-list-type-attr)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-price-list-type-cash-pay"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-price-list-type-cash-pay no-lock  on error undo, return error substitute( "&1 (validate-sequence c-price-list-type-cash-pay). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-price-list-type-cash-pay.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-price-list-type-cash-pay.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-price-list-type-cash-pay)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-price-doc-forming"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-price-doc-forming no-lock  on error undo, return error substitute( "&1 (validate-sequence c-price-doc-forming). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-price-doc-forming.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-price-doc-forming.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-price-doc-forming)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-price-doc-forming-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-price-doc-forming-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-price-doc-forming-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-price-doc-forming-attr.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-price-doc-forming-attr.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-price-doc-forming-attr)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-price-doc-forming-gds"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-price-doc-forming-gds no-lock  on error undo, return error substitute( "&1 (validate-sequence c-price-doc-forming-gds). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-price-doc-forming-gds.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-price-doc-forming-gds.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-price-doc-forming-gds)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-price-doc-forming-gds-qnty"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-price-doc-forming-gds-qnty no-lock  on error undo, return error substitute( "&1 (validate-sequence c-price-doc-forming-gds-qnty). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-price-doc-forming-gds-qnty.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-price-doc-forming-gds-qnty.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-price-doc-forming-gds-qnty)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-price-doc-forming-gds-sum"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-price-doc-forming-gds-sum no-lock  on error undo, return error substitute( "&1 (validate-sequence c-price-doc-forming-gds-sum). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-price-doc-forming-gds-sum.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-price-doc-forming-gds-sum.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-price-doc-forming-gds-sum)     .   end. end.
                    assign   v-curr-seq-name  = "s-chip-mp"   v-table-name     = "c-price-doc-forming-gds-tnv"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-price-doc-forming-gds-tnv no-lock  on error undo, return error substitute( "&1 (validate-sequence c-price-doc-forming-gds-tnv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-price-doc-forming-gds-tnv.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-price-doc-forming-gds-tnv.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-price-doc-forming-gds-tnv)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-chip-mp" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-bgr :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-bgr"   v-table-name     = "buyer-group"   v-seq-field-name = "bgr-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.buyer-group no-lock  on error undo, return error substitute( "&1 (validate-sequence buyer-group). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.buyer-group.bgr-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.buyer-group.bgr-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.buyer-group)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-bgr" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-gop :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                        assign   v-curr-seq-name  = "s-gop"   v-table-name     = "grp-obj-price"   v-seq-field-name = "gop-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.grp-obj-price no-lock  on error undo, return error substitute( "&1 (validate-sequence grp-obj-price). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.grp-obj-price.gop-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.grp-obj-price.gop-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.grp-obj-price)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-gop" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-pal :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                        assign   v-curr-seq-name  = "s-pal"   v-table-name     = "price-all"   v-seq-field-name = "pal-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.price-all no-lock  on error undo, return error substitute( "&1 (validate-sequence price-all). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.price-all.pal-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.price-all.pal-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.price-all)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-pal" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-pdf :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                        assign   v-curr-seq-name  = "s-pdf"   v-table-name     = "price-doc-forming"   v-seq-field-name = "pdf-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.price-doc-forming no-lock  on error undo, return error substitute( "&1 (validate-sequence price-doc-forming). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.price-doc-forming.pdf-db <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.price-doc-forming.pdf-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.price-doc-forming)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-pdf" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-plt :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                        assign   v-curr-seq-name  = "s-plt"   v-table-name     = "price-list-type"   v-seq-field-name = "plt-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.price-list-type no-lock  on error undo, return error substitute( "&1 (validate-sequence price-list-type). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.price-list-type.plt-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.price-list-type.plt-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.price-list-type)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-plt" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-qgr :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-qgr"   v-table-name     = "sum-group"   v-seq-field-name = "sgr-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.sum-group no-lock  on error undo, return error substitute( "&1 (validate-sequence sum-group). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.sum-group.sgr-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.sum-group.sgr-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.sum-group)     .   end. end.
                    assign   v-curr-seq-name  = "s-qgr"   v-table-name     = "qnty-group"   v-seq-field-name = "qgr-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.qnty-group no-lock  on error undo, return error substitute( "&1 (validate-sequence qnty-group). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.qnty-group.qgr-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.qnty-group.qgr-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.qnty-group)     .   end. end.
                    assign   v-curr-seq-name  = "s-qgr"   v-table-name     = "turnover-group"   v-seq-field-name = "tog-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.turnover-group no-lock  on error undo, return error substitute( "&1 (validate-sequence turnover-group). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.turnover-group.tog-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.turnover-group.tog-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.turnover-group)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-qgr" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-lk-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-lk-chip"   v-table-name     = "some-lk"   v-seq-field-name = "resource#_id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.some-lk no-lock  on error undo, return error substitute( "&1 (validate-sequence some-lk). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.some-lk.resource#_id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.some-lk)     .   end. end.
                    assign   v-curr-seq-name  = "s-lk-chip"   v-table-name     = "who-lk"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.who-lk no-lock  on error undo, return error substitute( "&1 (validate-sequence who-lk). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.who-lk.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.who-lk.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.who-lk)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-lk-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-region :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-region"   v-table-name     = "c-region"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-region no-lock  on error undo, return error substitute( "&1 (validate-sequence c-region). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-region.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-region.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-region)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-region" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-stop-list :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-stop-list"   v-table-name     = "stop-list"   v-seq-field-name = "stop-list-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.stop-list no-lock  on error undo, return error substitute( "&1 (validate-sequence stop-list). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.stop-list.stop-list-code) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.stop-list)     .   end. end.
                assign   v-curr-seq-name  = "s-stop-list"   v-table-name     = "c-stop-list"   v-seq-field-name = "stop-list-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-stop-list no-lock  on error undo, return error substitute( "&1 (validate-sequence c-stop-list). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-doc-code-int64(restseq.c-stop-list.stop-list-code) .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-stop-list)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-stop-list" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-stop-list-fact :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-stop-list-fact"   v-table-name     = "stop-list"   v-seq-field-name = "fact-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.stop-list no-lock  on error undo, return error substitute( "&1 (validate-sequence stop-list). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.stop-list.fact-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.stop-list)     .   end. end.
                assign   v-curr-seq-name  = "s-stop-list-fact"   v-table-name     = "c-stop-list"   v-seq-field-name = "fact-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-stop-list no-lock  on error undo, return error substitute( "&1 (validate-sequence c-stop-list). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-stop-list.fact-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-stop-list)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-stop-list-fact" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-casm :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-casm"   v-table-name     = "season"   v-seq-field-name = "sea-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.season no-lock  on error undo, return error substitute( "&1 (validate-sequence season). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.season.sea-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.season)     .   end. end.
                assign   v-curr-seq-name  = "s-casm"   v-table-name     = "c-season"   v-seq-field-name = "sea-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-season no-lock  on error undo, return error substitute( "&1 (validate-sequence c-season). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-season.sea-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-season)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-casm" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-trn-fo :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-trn-fo"   v-table-name     = "fin-ob-trn"   v-seq-field-name = "id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.fin-ob-trn no-lock  on error undo, return error substitute( "&1 (validate-sequence fin-ob-trn). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.fin-ob-trn.id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.fin-ob-trn)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-trn-fo" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-trn-reason :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-trn-reason"   v-table-name     = "trn-reason"   v-seq-field-name = "reason-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.trn-reason no-lock  on error undo, return error substitute( "&1 (validate-sequence trn-reason). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.trn-reason.reason-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.trn-reason)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-trn-reason" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-cd-trans :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-cd-trans"   v-table-name     = "cd-trans"   v-seq-field-name = "trans-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.cd-trans no-lock  on error undo, return error substitute( "&1 (validate-sequence cd-trans). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.cd-trans.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.cd-trans.trans-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.cd-trans)     .   end. end.
        if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-cd-trans" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-spool :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    define variable v-spool as   int64              no-undo .
      assign
      v-curr-seq-name  = "s-spool"
      v-table-name     = "spool"
      v-seq-field-name = "spool"
      v-num-rec        = 0
      v-curr-recid     = 0
      v-new-seq-value  = 0
    .
    do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.
    find first restseq._sequence no-lock
    where restseq._sequence._seq-name = v-curr-seq-name
    no-error.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) >=  restseq._sequence._seq-max then do:
      assign
        v-curr-seq-value = 1
      .
      if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-spool" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
    end.
  end.
end procedure.
procedure restore-s-blob-int64 :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-blob-int64"   v-table-name     = "blob-data"   v-seq-field-name = "int64-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.blob-data no-lock  on error undo, return error substitute( "&1 (validate-sequence blob-data). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.blob-data.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.blob-data.int64-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.blob-data)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-blob-int64" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-clob-int64 :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-clob-int64"   v-table-name     = "clob-data"   v-seq-field-name = "int64-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.clob-data no-lock  on error undo, return error substitute( "&1 (validate-sequence clob-data). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.clob-data.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.clob-data.int64-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.clob-data)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-clob-int64" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-upg-ord :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-upg-ord"   v-table-name     = "upgrade"   v-seq-field-name = "version-ord"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.upgrade no-lock  on error undo, return error substitute( "&1 (validate-sequence upgrade). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.upgrade.version-ord .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.upgrade)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-upg-ord" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-egais :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error return-value
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-egais"   v-table-name     = "c-egais-clients"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-egais-clients no-lock  on error undo, return error substitute( "&1 (validate-sequence c-egais-clients). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-egais-clients.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-egais-clients.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-egais-clients)     .   end. end.
                    assign   v-curr-seq-name  = "s-egais"   v-table-name     = "c-egais-gds"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-egais-gds no-lock  on error undo, return error substitute( "&1 (validate-sequence c-egais-gds). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-egais-gds.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-egais-gds.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-egais-gds)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-egais" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-layout-id :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error substitute( "&1 (restore-s-layout-id). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-layout-id"   v-table-name     = "layout"   v-seq-field-name = "layout-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.layout no-lock  on error undo, return error substitute( "&1 (validate-sequence layout). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if int64(restseq.layout.cr-db-num) <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-layout-id-int64(p-curr-db-num, restseq.layout.layout-id) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.layout)     .   end. end.
                    assign   v-curr-seq-name  = "s-layout-id"   v-table-name     = "c-layout"   v-seq-field-name = "layout-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-layout no-lock  on error undo, return error substitute( "&1 (validate-sequence c-layout). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if int64(restseq.c-layout.cr-db-num) <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = get-layout-id-int64(p-curr-db-num, restseq.c-layout.layout-id) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-layout)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-layout-id" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-db-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-db-chip"   v-table-name     = "c-db"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-db no-lock  on error undo, return error substitute( "&1 (validate-sequence c-db). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.c-db.corr-user-db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-db.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-db)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-db-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-sost :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-sost"   v-table-name     = "ext-file"   v-seq-field-name = "file-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.ext-file no-lock  on error undo, return error substitute( "&1 (validate-sequence ext-file). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.ext-file.from-db-num <> p-curr-db-num then next. if restseq.ext-file.file-num = 2147483647 then next.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = abs(restseq.ext-file.file-num ).   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.ext-file)     .   end. end.
        if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-sost" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-sr-izmerenia :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-sr-izmerenia"   v-table-name     = "sr-izmerenia"   v-seq-field-name = "node-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.sr-izmerenia no-lock  on error undo, return error substitute( "&1 (validate-sequence sr-izmerenia). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.sr-izmerenia.node-code) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.sr-izmerenia)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-sr-izmerenia" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-norm-loss :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                assign   v-curr-seq-name  = "s-norm-loss"   v-table-name     = "norm-loss"   v-seq-field-name = "id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.norm-loss no-lock  on error undo, return error substitute( "&1 (validate-sequence norm-loss). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.norm-loss.id) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.norm-loss)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-norm-loss" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-gds-mercury-id :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-gds-mercury-id"   v-table-name     = "gds-mercury"   v-seq-field-name = "id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.gds-mercury no-lock  on error undo, return error substitute( "&1 (validate-sequence gds-mercury). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.gds-mercury.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.gds-mercury.id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.gds-mercury)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-gds-mercury-id" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
 end procedure.
  procedure restore-s-vsd-id :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-vsd-id"   v-table-name     = "vsd"   v-seq-field-name = "id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.vsd no-lock  on error undo, return error substitute( "&1 (validate-sequence vsd). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.vsd.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.vsd.id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.vsd)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-vsd-id" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-promo-chip :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
            assign   v-curr-seq-name  = "s-promo-chip"   v-table-name     = "c-PromoAction"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-PromoAction no-lock  on error undo, return error substitute( "&1 (validate-sequence c-PromoAction). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-PromoAction.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-PromoAction)     .   end. end.
            assign   v-curr-seq-name  = "s-promo-chip"   v-table-name     = "c-PromoCriterion"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-PromoCriterion no-lock  on error undo, return error substitute( "&1 (validate-sequence c-PromoCriterion). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-PromoCriterion.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-PromoCriterion)     .   end. end.
            assign   v-curr-seq-name  = "s-promo-chip"   v-table-name     = "c-PromoGift"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-PromoGift no-lock  on error undo, return error substitute( "&1 (validate-sequence c-PromoGift). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-PromoGift.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-PromoGift)     .   end. end.
            assign   v-curr-seq-name  = "s-promo-chip"   v-table-name     = "c-PromoGoods"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-PromoGoods no-lock  on error undo, return error substitute( "&1 (validate-sequence c-PromoGoods). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-PromoGoods.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-PromoGoods)     .   end. end.
            assign   v-curr-seq-name  = "s-promo-chip"   v-table-name     = "c-PromoObject"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-PromoObject no-lock  on error undo, return error substitute( "&1 (validate-sequence c-PromoObject). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-PromoObject.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-PromoObject)     .   end. end.
            assign   v-curr-seq-name  = "s-promo-chip"   v-table-name     = "c-promo-schedule"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-promo-schedule no-lock  on error undo, return error substitute( "&1 (validate-sequence c-promo-schedule). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-promo-schedule.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-promo-schedule)     .   end. end.
            assign   v-curr-seq-name  = "s-promo-chip"   v-table-name     = "c-promo-schedule-week"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-promo-schedule-week no-lock  on error undo, return error substitute( "&1 (validate-sequence c-promo-schedule-week). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-promo-schedule-week.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-promo-schedule-week)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-promo-chip" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-promoaction-id :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
    assign   v-curr-seq-name  = "s-promoaction-id"   v-table-name     = "PromoAction"   v-seq-field-name = "id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.PromoAction no-lock  on error undo, return error substitute( "&1 (validate-sequence PromoAction). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.PromoAction.id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.PromoAction)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-promoaction-id" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-promoCriterion-id :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
    assign   v-curr-seq-name  = "s-promoCriterion-id"   v-table-name     = "PromoCriterion"   v-seq-field-name = "id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.PromoCriterion no-lock  on error undo, return error substitute( "&1 (validate-sequence PromoCriterion). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.PromoCriterion.id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.PromoCriterion)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-promoCriterion-id" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-promoGift-id :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
    assign   v-curr-seq-name  = "s-promoGift-id"   v-table-name     = "PromoGift"   v-seq-field-name = "id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.PromoGift no-lock  on error undo, return error substitute( "&1 (validate-sequence PromoGift). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.PromoGift.id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.PromoGift)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-promoGift-id" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-promoGoods-id :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
    assign   v-curr-seq-name  = "s-promoGoods-id"   v-table-name     = "PromoGoods"   v-seq-field-name = "id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.PromoGoods no-lock  on error undo, return error substitute( "&1 (validate-sequence PromoGoods). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.PromoGoods.id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.PromoGoods)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-promoGoods-id" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-promoobject-id :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
    assign   v-curr-seq-name  = "s-promoobject-id"   v-table-name     = "PromoObject"   v-seq-field-name = "id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.PromoObject no-lock  on error undo, return error substitute( "&1 (validate-sequence PromoObject). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.PromoObject.id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.PromoObject)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-promoobject-id" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-tech-prol-pwd :
    define input parameter p-curr-db-num as integer no-undo.
    do
        on error undo, return error
        :
        assign   v-curr-seq-value = 0 .
        assign   v-curr-seq-name  = "s-tech-prol-pwd"   v-table-name     = "tech-prol-pwd"   v-seq-field-name = "id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.tech-prol-pwd no-lock  on error undo, return error substitute( "&1 (validate-sequence tech-prol-pwd). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.tech-prol-pwd.id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.tech-prol-pwd)     .   end. end.
        if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-tech-prol-pwd" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
    end.
end procedure.
procedure restore-s-c-tech-prol-pwd_chip-num :
    define input parameter p-curr-db-num as integer no-undo.
    do
        on error undo, return error
        :
        assign   v-curr-seq-value = 0 .
        assign   v-curr-seq-name  = "s-c-tech-prol-pwd_chip-num"   v-table-name     = "c-tech-prol-pwd"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-tech-prol-pwd no-lock  on error undo, return error substitute( "&1 (validate-sequence c-tech-prol-pwd). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.c-tech-prol-pwd.chip-num .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-tech-prol-pwd)     .   end. end.
        if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-c-tech-prol-pwd_chip-num" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
    end.
end procedure.
procedure restore-s-promosched-id :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
            assign   v-curr-seq-name  = "s-promosched-id"   v-table-name     = "promo-schedule"   v-seq-field-name = "id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.promo-schedule no-lock  on error undo, return error substitute( "&1 (validate-sequence promo-schedule). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.promo-schedule.id) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.promo-schedule)     .   end. end.
            assign   v-curr-seq-name  = "s-promosched-id"   v-table-name     = "promo-schedule-week"   v-seq-field-name = "id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.promo-schedule-week no-lock  on error undo, return error substitute( "&1 (validate-sequence promo-schedule-week). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.promo-schedule-week.id) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.promo-schedule-week)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-promosched-id" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-c-cashbook-chip-num :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
            assign   v-curr-seq-name  = "s-c-cashbook-chip-num"   v-table-name     = "c-cashbook"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-cashbook no-lock  on error undo, return error substitute( "&1 (validate-sequence c-cashbook). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-cashbook.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-cashbook)     .   end. end.
            assign   v-curr-seq-name  = "s-c-cashbook-chip-num"   v-table-name     = "c-cashbookattr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-cashbookattr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-cashbookattr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-cashbookattr.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-cashbookattr)     .   end. end.
            assign   v-curr-seq-name  = "s-c-cashbook-chip-num"   v-table-name     = "c-cashbookrule"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-cashbookrule no-lock  on error undo, return error substitute( "&1 (validate-sequence c-cashbookrule). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-cashbookrule.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-cashbookrule)     .   end. end.
            assign   v-curr-seq-name  = "s-c-cashbook-chip-num"   v-table-name     = "c-cashbookruleattr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-cashbookruleattr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-cashbookruleattr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-cashbookruleattr.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-cashbookruleattr)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-c-cashbook-chip-num" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-cashbook-id :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
            assign   v-curr-seq-name  = "s-cashbook-id"   v-table-name     = "cashbook"   v-seq-field-name = "id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.cashbook no-lock  on error undo, return error substitute( "&1 (validate-sequence cashbook). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.cashbook.id) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.cashbook)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-cashbook-id" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-c-operserv-chip-num :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
            assign   v-curr-seq-name  = "s-c-operserv-chip-num"   v-table-name     = "c-operserv"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-operserv no-lock  on error undo, return error substitute( "&1 (validate-sequence c-operserv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-operserv.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-operserv)     .   end. end.
            assign   v-curr-seq-name  = "s-c-operserv-chip-num"   v-table-name     = "c-operservattr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-operservattr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-operservattr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-operservattr.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-operservattr)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-c-operserv-chip-num" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-c-counter-chip-num :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
            assign   v-curr-seq-name  = "s-c-counter-chip-num"   v-table-name     = "c-counter"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-counter no-lock  on error undo, return error substitute( "&1 (validate-sequence c-counter). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-counter.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-counter)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-c-counter-chip-num" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-operserv-id :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
            assign   v-curr-seq-name  = "s-operserv-id"   v-table-name     = "operserv"   v-seq-field-name = "id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.operserv no-lock  on error undo, return error substitute( "&1 (validate-sequence operserv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.operserv.id) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.operserv)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-operserv-id" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-devisPC-id :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
            assign   v-curr-seq-name  = "s-devisPC-id"   v-table-name     = "devisPC"   v-seq-field-name = "id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.devisPC no-lock  on error undo, return error substitute( "&1 (validate-sequence devisPC). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.devisPC.id) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.devisPC)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-devisPC-id" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-utd-doc-code :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-utd-doc-code"   v-table-name     = "utd"   v-seq-field-name = "doc-id"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.utd no-lock  on error undo, return error substitute( "&1 (validate-sequence utd). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.utd.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.utd.doc-id .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.utd)     .   end. end.
        if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-utd-doc-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-c-utd-chip-num :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
            assign   v-curr-seq-name  = "s-c-utd-chip-num"   v-table-name     = "c-utd"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-utd no-lock  on error undo, return error substitute( "&1 (validate-sequence c-utd). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-utd.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-utd)     .   end. end.
            assign   v-curr-seq-name  = "s-c-utd-chip-num"   v-table-name     = "c-utd-err"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-utd-err no-lock  on error undo, return error substitute( "&1 (validate-sequence c-utd-err). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-utd-err.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-utd-err)     .   end. end.
            assign   v-curr-seq-name  = "s-c-utd-chip-num"   v-table-name     = "c-utd-lines"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-utd-lines no-lock  on error undo, return error substitute( "&1 (validate-sequence c-utd-lines). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-utd-lines.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-utd-lines)     .   end. end.
            assign   v-curr-seq-name  = "s-c-utd-chip-num"   v-table-name     = "c-utd-marking-lines"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-utd-marking-lines no-lock  on error undo, return error substitute( "&1 (validate-sequence c-utd-marking-lines). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-utd-marking-lines.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-utd-marking-lines)     .   end. end.
            assign   v-curr-seq-name  = "s-c-utd-chip-num"   v-table-name     = "c-utd-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-utd-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-utd-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-utd-attr.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-utd-attr)     .   end. end.
            assign   v-curr-seq-name  = "s-c-utd-chip-num"   v-table-name     = "c-utd-err-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-utd-err-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-utd-err-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-utd-err-attr.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-utd-err-attr)     .   end. end.
            assign   v-curr-seq-name  = "s-c-utd-chip-num"   v-table-name     = "c-utd-lines-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-utd-lines-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-utd-lines-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-utd-lines-attr.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-utd-lines-attr)     .   end. end.
            assign   v-curr-seq-name  = "s-c-utd-chip-num"   v-table-name     = "c-utd-marking-lines-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-utd-marking-lines-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-utd-marking-lines-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-utd-marking-lines-attr.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-utd-marking-lines-attr)     .   end. end.
            assign   v-curr-seq-name  = "s-c-utd-chip-num"   v-table-name     = "c-utd-head"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-utd-head no-lock  on error undo, return error substitute( "&1 (validate-sequence c-utd-head). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-utd-head.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-utd-head)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-c-utd-chip-num" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-c-code :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
            assign   v-curr-seq-name  = "s-c-code"   v-table-name     = "c-Code"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-Code no-lock  on error undo, return error substitute( "&1 (validate-sequence c-Code). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-Code.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-Code)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-c-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-c-mark-chip-num :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
            assign   v-curr-seq-name  = "s-c-mark-chip-num"   v-table-name     = "c-marking"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-marking no-lock  on error undo, return error substitute( "&1 (validate-sequence c-marking). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-marking.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-marking)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-c-mark-chip-num" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-c-mark-attr-chip-num :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
            assign   v-curr-seq-name  = "s-c-mark-attr-chip-num"   v-table-name     = "c-counter"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-counter no-lock  on error undo, return error substitute( "&1 (validate-sequence c-counter). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-counter.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-counter)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-c-mark-attr-chip-num" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-order-code :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
                    assign   v-curr-seq-name  = "s-order-code"   v-table-name     = "order-doc"   v-seq-field-name = "doc-code"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.order-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence order-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):   if restseq.order-doc.db-num <> p-curr-db-num then NEXT.   assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = restseq.order-doc.doc-code .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.order-doc)     .   end. end.
        if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-order-code" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
procedure restore-s-c-order-chip-num :
  define input parameter p-curr-db-num as integer no-undo.
  do
  on error undo, return error
  :
    assign   v-curr-seq-value = 0 .
            assign   v-curr-seq-name  = "s-c-order-chip-num"   v-table-name     = "c-order-doc"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-order-doc no-lock  on error undo, return error substitute( "&1 (validate-sequence c-order-doc). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-order-doc.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-order-doc)     .   end. end.
            assign   v-curr-seq-name  = "s-c-order-chip-num"   v-table-name     = "c-order-line"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-order-line no-lock  on error undo, return error substitute( "&1 (validate-sequence c-order-line). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-order-line.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-order-line)     .   end. end.
            assign   v-curr-seq-name  = "s-c-order-chip-num"   v-table-name     = "c-order-doc-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-order-doc-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-order-doc-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-order-doc-attr.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-order-doc-attr)     .   end. end.
            assign   v-curr-seq-name  = "s-c-order-chip-num"   v-table-name     = "c-order-line-attr"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-order-line-attr no-lock  on error undo, return error substitute( "&1 (validate-sequence c-order-line-attr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-order-line-attr.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-order-line-attr)     .   end. end.
            assign   v-curr-seq-name  = "s-c-order-chip-num"   v-table-name     = "c-order-head"   v-seq-field-name = "chip-num"   v-num-rec        = 0   v-curr-recid     = 0   v-new-seq-value  = 0 . do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end. for each restseq.c-order-head no-lock  on error undo, return error substitute( "&1 (validate-sequence c-order-head). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):      assign     v-num-rec = v-num-rec + 1   .   if v-num-rec mod 10 = 0 then do:     do with frame seq-info   on error undo, return error substitute( "&1 (show-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )   :     assign       v-curr-seq-name :screen-value  = string( v-curr-seq-name, v-curr-seq-name :format)       v-table-name :screen-value     = string( v-table-name, v-table-name :format)       v-seq-field-name :screen-value = string( v-seq-field-name, v-seq-field-name :format)       v-num-rec :screen-value        = string( v-num-rec, v-num-rec :format)     .   end.   end.   assign v-new-seq-value = int64(restseq.c-order-head.chip-num) no-error .   if v-curr-seq-value < v-new-seq-value then do:     assign       v-curr-seq-value = v-new-seq-value       v-curr-recid     = recid(restseq.c-order-head)     .   end. end.
    if dynamic-current-value( v-curr-seq-name, v-ld-db-name ) < v-curr-seq-value    or (v-curr-seq-value <> 0        and dynamic-current-value( v-curr-seq-name, v-ld-db-name ) > v-curr-seq-value        ) then do:   run log-error in this-procedure     (input v-curr-seq-name     ,input v-curr-recid     ,input dynamic-current-value( v-curr-seq-name, v-ld-db-name )     ,input v-curr-seq-value     ).   if v-action = "rest":U then do:     assign       dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = v-curr-seq-value     .   end. end. else do:   if v-curr-seq-value = 0 then do:           find first restseq._sequence no-lock       where restseq._sequence._seq-name = "s-c-order-chip-num" no-error.     if available restseq._sequence then do:       if v-action = "rest":U then do:         assign           dynamic-current-value( v-curr-seq-name, v-ld-db-name ) = restseq._sequence._seq-init         .       end.     end.   end. end.
  end.
end procedure.
