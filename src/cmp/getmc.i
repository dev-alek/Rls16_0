/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

обработка диапазонов кодов

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/02
Author: Dmitry Ukhanov
Creation date: 03/22/02

*/
/*
  {1} - таблица в которой используется код полученый из диапазона
  {2} - поле куда записан код
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-ii{&vssseq} as integer   no-undo .
define variable v-table-name{&vssseq} as character no-undo .
define variable v-field-name{&vssseq} as character no-undo .
define variable buf_h{&vssseq} as handle no-undo .
define variable q_h{&vssseq} as handle no-undo .
define variable v-avail{&vssseq} as integer   no-undo .
define variable v-code-mess{&vssseq} as character no-undo .
define variable glog{&vssseq} as logical   no-undo .
define variable v-code_{&vssseq} as integer   no-undo .

case p-action :
  when "get-m-code":U then do:
    do v-ii{&vssseq} = 1 to num-entries({1}):
      assign
      v-table-name{&vssseq} = entry(v-ii{&vssseq}, {1})
      v-field-name{&vssseq} = entry(v-ii{&vssseq}, {2})
      .

      create buffer buf_h{&vssseq} for table v-table-name{&vssseq}.
      create query q_h{&vssseq}.
      q_h{&vssseq}:SET-BUFFERS(buf_h{&vssseq}).
      q_h{&vssseq}:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name{&vssseq}
                        ,v-field-name{&vssseq}
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h{&vssseq}:QUERY-OPEN.
      REPEAT while  q_h{&vssseq}:get-next().
        assign
          v-code_{&vssseq} = buf_h{&vssseq}:buffer-field(v-field-name{&vssseq}):buffer-value
        .
        leave . /* --->>>--- */
      END.
      q_h{&vssseq}:QUERY-CLOSE().
      delete object q_h{&vssseq}.
      delete object buf_h{&vssseq}.
      v-b-code = max(v-code_{&vssseq}, v-b-code).
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
      v-avail{&vssseq} = 0.
      do v-ii{&vssseq} = 1 to num-entries({1}):
        assign
        v-table-name{&vssseq} = entry(v-ii{&vssseq}, {1})
        v-field-name{&vssseq} = entry(v-ii{&vssseq}, {2})
        .
        create buffer buf_h{&vssseq} for table v-table-name{&vssseq}.
        glog{&vssseq} = buf_h{&vssseq}:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name{&vssseq}
                                , v-field-name{&vssseq}
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .

        if buf_h{&vssseq}:available then do:
          assign
          v-avail{&vssseq} = v-avail{&vssseq} + 1
          .
          if v-avail{&vssseq} = 1 then do:
            v-code-mess{&vssseq} = string(buf_h{&vssseq}:buffer-field(v-field-name{&vssseq}):buffer-value)
            .
          end.
        end.
        delete object buf_h{&vssseq}.
     end. /*do v-ii{&vssseq} = 1 to num-entries({1}):*/
     if v-avail{&vssseq} > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , {&new-line}
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess{&vssseq}
                                          )
/*          v-ret-msg          = v-ret-msg + v-msg*/
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
      if v-avail{&vssseq} = 0
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
                                            , {&new-line}
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
/*          v-ret-msg          = v-ret-msg + v-msg*/
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
  end. /*when "f-u":U then do:*/
end case.

/* $Workfile$ end */