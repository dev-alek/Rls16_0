/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры работы с параметрами программ, передаваемых по СПН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/21/06
Author: Bakhtadze Natalya
Creation date: 08/21/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


define {1} temp-table tt-ext-file-par no-undo like ub.ext-file-par.

procedure ext-file-par-clear-temp :

  define buffer buf_tt-ext-file-par for tt-ext-file-par .

  do
  on error undo, return error return-value
  :
    for each buf_tt-ext-file-par
    on error undo, return error
    :
      delete buf_tt-ext-file-par .
    end.
  end.

end procedure. /* ext-file-par-clear */


procedure ext-file-par-write-temp :
  define input  parameter p-db-num      as integer no-undo .
  define input  parameter p-from-db-num      as integer no-undo .
  define input  parameter p-file-num      as integer no-undo .
  define input  parameter p-param-num      as integer no-undo .
  define input  parameter p-value-type as character no-undo .
  define input  parameter p-value-name as character no-undo .
  define input  parameter p-value-char as character no-undo .
  define input  parameter p-value-date as date      no-undo .
  define input  parameter p-value-integer as integer      no-undo .
  define input  parameter p-value-decimal as decimal      no-undo .
  define input  parameter p-value-logical as logical      no-undo .

  define buffer buf_tt-ext-file-par for tt-ext-file-par .

  do
  on error undo, return error return-value
  :
    find first buf_tt-ext-file-par
      where buf_tt-ext-file-par.db-num        = p-db-num
        and buf_tt-ext-file-par.file-num      = p-file-num
        and buf_tt-ext-file-par.from-db-num   = p-from-db-num
        and buf_tt-ext-file-par.param-type    = p-value-type
        and buf_tt-ext-file-par.param-name    = p-value-name
      no-error .
    if not available buf_tt-ext-file-par then do:
      create buf_tt-ext-file-par .
      assign
        buf_tt-ext-file-par.db-num         = p-db-num
        buf_tt-ext-file-par.from-db-num    = p-from-db-num
        buf_tt-ext-file-par.file-num       = p-file-num
        buf_tt-ext-file-par.param-num      = p-param-num
        buf_tt-ext-file-par.param-type     = p-value-type
        buf_tt-ext-file-par.user-db-num    = p-db-num
              .
    end.
    CASE p-value-type:
      when {&type-char}
      or when {&datatype-uniq-key-rec}
      then do:
        assign
        buf_tt-ext-file-par.param-name = p-value-name
        buf_tt-ext-file-par.param-value = p-value-char
        .
      end.
      when {&type-date} then do:
        assign
        buf_tt-ext-file-par.param-date-name = p-value-name
        buf_tt-ext-file-par.param-date-value = p-value-date
        .
      end.
      when {&type-int} then do:
        assign
        buf_tt-ext-file-par.param-int-name = p-value-name
        buf_tt-ext-file-par.param-int-value = p-value-integer
        .
      end.
      when {&type-log} then do:
        assign
        buf_tt-ext-file-par.param-log-name = p-value-name
        buf_tt-ext-file-par.param-log-value = p-value-logical
        .
      end.
      when {&type-dec} then do:
        assign
        buf_tt-ext-file-par.param-decimal-name = p-value-name
        buf_tt-ext-file-par.param-decimal-value = p-value-decimal
        .
      end.
    END CASE.
  end.

end procedure. /* ext-file-par-write-temp */



procedure ext-file-par-write-and-send :
  define input  parameter p-db-num      as integer no-undo .
  define input  parameter p-from-db-num      as integer no-undo .
  define input  parameter p-file-num      as integer no-undo .
  define input  parameter p-param-num      as integer no-undo .
  define input  parameter p-value-type as character no-undo .
  define input  parameter p-value-name as character no-undo .
  define input  parameter p-value-char as character no-undo .
  define input  parameter p-value-date as date      no-undo .
  define input  parameter p-value-integer as integer      no-undo .
  define input  parameter p-value-decimal as decimal      no-undo .
  define input  parameter p-value-logical as logical      no-undo .
  define input  parameter p-send        as logical no-undo .
  define input  parameter p-list-db-num as character no-undo .

  define buffer buf_ext-file-par for ub.ext-file-par .

  do
  on error undo, return error return-value
  :
    find first buf_ext-file-par
      where buf_ext-file-par.db-num         = p-db-num
        and buf_ext-file-par.from-db-num    = p-from-db-num
        and buf_ext-file-par.file-num       = p-file-num
        and buf_ext-file-par.param-num      = p-param-num
      no-error .
    if not available buf_ext-file-par then do:
      create buf_ext-file-par .
      assign
        buf_ext-file-par.db-num    = p-db-num
        buf_ext-file-par.from-db-num    = p-from-db-num
        buf_ext-file-par.file-num    = p-file-num
        buf_ext-file-par.param-num    = p-param-num
        buf_ext-file-par.param-type   = p-value-type
        buf_ext-file-par.user-db-num    = p-db-num
      .
    end.
    CASE p-value-type:
      when {&type-char}
      or when ''
      or when {&datatype-uniq-key-rec}
      then do:
        assign
        buf_ext-file-par.param-name = p-value-name
        buf_ext-file-par.param-value = p-value-char
        .
        if p-value-type = ''
        and p-param-num = 0 then do:
          buf_ext-file-par.param-log-value = p-value-logical.
        end.
      end.
      when {&type-date} then do:
        assign
        buf_ext-file-par.param-date-name = p-value-name
        buf_ext-file-par.param-date-value = p-value-date
        .
      end.
      when {&type-int} then do:
        assign
        buf_ext-file-par.param-int-name = p-value-name
        buf_ext-file-par.param-int-value = p-value-integer
        .
      end.
      when {&type-dec} then do:
        assign
        buf_ext-file-par.param-decimal-name = p-value-name
        buf_ext-file-par.param-decimal-value = p-value-decimal
        .
      end.
      when {&type-log} then do:
        assign
        buf_ext-file-par.param-log-name = p-value-name
        buf_ext-file-par.param-log-value = p-value-logical
        .
      end.
    END CASE.
    if p-send then do:
      run nws/cr-route.p (
                      input {&send-tbl}
                    , input {&table_ext-file-par}
                    , input buffer buf_ext-file-par:handle
                    , input p-list-db-num) no-error.
    end.

  end.

end procedure. /* ext-file-par-write-and-send */


/* $Workfile$ e n d */