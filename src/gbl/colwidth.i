/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для считывания и сохранения ширины колонок в базе данных

Автор: Перваков Михаил Сергеевич
Дата создания: 09/07/06
Author: Mikhail Pervakov
Creation date: 09/07/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&global-define include_colwidth ok

define variable v-colwidth-db-num          as integer   no-undo .
define variable v-colwidth-user-id         as character no-undo .
define variable v-colwidth-program-name    as character no-undo .
define variable v-colwidth-width-01        as decimal   no-undo .
define variable v-colwidth-width-02        as decimal   no-undo .
define variable v-colwidth-width-03        as decimal   no-undo .
define variable v-colwidth-width-04        as decimal   no-undo .
define variable v-colwidth-width-05        as decimal   no-undo .
define variable v-colwidth-width-06        as decimal   no-undo .
define variable v-colwidth-width-07        as decimal   no-undo .
define variable v-colwidth-width-08        as decimal   no-undo .
define variable v-colwidth-width-09        as decimal   no-undo .
define variable v-colwidth-width-10        as decimal   no-undo .
define variable v-colwidth-width-11        as decimal   no-undo .
define variable v-colwidth-width-12        as decimal   no-undo .
define variable v-colwidth-width-13        as decimal   no-undo .
define variable v-colwidth-width-14        as decimal   no-undo .
define variable v-colwidth-width-15        as decimal   no-undo .
define variable v-colwidth-width-16        as decimal   no-undo .
define variable v-colwidth-width-17        as decimal   no-undo .
define variable v-colwidth-width-18        as decimal   no-undo .
define variable v-colwidth-width-19        as decimal   no-undo .
define variable v-colwidth-width-20        as decimal   no-undo .
define variable v-colwidth-width-01-shadow as decimal   no-undo .
define variable v-colwidth-width-02-shadow as decimal   no-undo .
define variable v-colwidth-width-03-shadow as decimal   no-undo .
define variable v-colwidth-width-04-shadow as decimal   no-undo .
define variable v-colwidth-width-05-shadow as decimal   no-undo .
define variable v-colwidth-width-06-shadow as decimal   no-undo .
define variable v-colwidth-width-07-shadow as decimal   no-undo .
define variable v-colwidth-width-08-shadow as decimal   no-undo .
define variable v-colwidth-width-09-shadow as decimal   no-undo .
define variable v-colwidth-width-10-shadow as decimal   no-undo .
define variable v-colwidth-width-11-shadow as decimal   no-undo .
define variable v-colwidth-width-12-shadow as decimal   no-undo .
define variable v-colwidth-width-13-shadow as decimal   no-undo .
define variable v-colwidth-width-14-shadow as decimal   no-undo .
define variable v-colwidth-width-15-shadow as decimal   no-undo .
define variable v-colwidth-width-16-shadow as decimal   no-undo .
define variable v-colwidth-width-17-shadow as decimal   no-undo .
define variable v-colwidth-width-18-shadow as decimal   no-undo .
define variable v-colwidth-width-19-shadow as decimal   no-undo .
define variable v-colwidth-width-20-shadow as decimal   no-undo .

procedure colwidth-read :

  define input  parameter p-db-num       as integer   no-undo .
  define input  parameter p-user-id      as character no-undo .
  define input  parameter p-program-name as character no-undo .
  define output parameter p-data-exist   as logical   no-undo .

  define buffer buf_rpt-option for ubflt.rpt-option .

  do
  on error undo, return error return-value
  :
    assign
      v-colwidth-db-num       = p-db-num
      v-colwidth-user-id      = p-user-id
      v-colwidth-program-name = p-program-name
    .

    find first buf_rpt-option no-lock
      where buf_rpt-option.rpt-name    = p-program-name
        and buf_rpt-option.rpt-code    = {&rpt-code_column-width}
        and buf_rpt-option.user-db-num = p-db-num
        and buf_rpt-option.user-id     = p-user-id
      no-error .
    if available buf_rpt-option
    then do:
      assign
        p-data-exist        = true
        v-colwidth-width-01 = buf_rpt-option.param-decimal-01-value
        v-colwidth-width-02 = buf_rpt-option.param-decimal-02-value
        v-colwidth-width-03 = buf_rpt-option.param-decimal-03-value
        v-colwidth-width-04 = buf_rpt-option.param-decimal-04-value
        v-colwidth-width-05 = buf_rpt-option.param-decimal-05-value
        v-colwidth-width-06 = buf_rpt-option.param-decimal-06-value
        v-colwidth-width-07 = buf_rpt-option.param-decimal-07-value
        v-colwidth-width-08 = buf_rpt-option.param-decimal-08-value
        v-colwidth-width-09 = buf_rpt-option.param-decimal-09-value
        v-colwidth-width-10 = buf_rpt-option.param-decimal-10-value
        v-colwidth-width-11 = buf_rpt-option.param-decimal-11-value
        v-colwidth-width-12 = buf_rpt-option.param-decimal-12-value
        v-colwidth-width-13 = buf_rpt-option.param-decimal-13-value
        v-colwidth-width-14 = buf_rpt-option.param-decimal-14-value
        v-colwidth-width-15 = buf_rpt-option.param-decimal-15-value
        v-colwidth-width-16 = buf_rpt-option.param-decimal-16-value
        v-colwidth-width-17 = buf_rpt-option.param-decimal-17-value
        v-colwidth-width-18 = buf_rpt-option.param-decimal-18-value
        v-colwidth-width-19 = buf_rpt-option.param-decimal-19-value
        v-colwidth-width-20 = buf_rpt-option.param-decimal-20-value
      .
    end.
    else do:
      assign
        p-data-exist        = false
        v-colwidth-width-01 = 0
        v-colwidth-width-02 = 0
        v-colwidth-width-03 = 0
        v-colwidth-width-04 = 0
        v-colwidth-width-05 = 0
        v-colwidth-width-06 = 0
        v-colwidth-width-07 = 0
        v-colwidth-width-08 = 0
        v-colwidth-width-09 = 0
        v-colwidth-width-10 = 0
        v-colwidth-width-11 = 0
        v-colwidth-width-12 = 0
        v-colwidth-width-13 = 0
        v-colwidth-width-14 = 0
        v-colwidth-width-15 = 0
        v-colwidth-width-16 = 0
        v-colwidth-width-17 = 0
        v-colwidth-width-18 = 0
        v-colwidth-width-19 = 0
        v-colwidth-width-20 = 0
      .
    end.
    assign
      v-colwidth-width-01-shadow = v-colwidth-width-01
      v-colwidth-width-02-shadow = v-colwidth-width-02
      v-colwidth-width-03-shadow = v-colwidth-width-03
      v-colwidth-width-04-shadow = v-colwidth-width-04
      v-colwidth-width-05-shadow = v-colwidth-width-05
      v-colwidth-width-06-shadow = v-colwidth-width-06
      v-colwidth-width-07-shadow = v-colwidth-width-07
      v-colwidth-width-08-shadow = v-colwidth-width-08
      v-colwidth-width-09-shadow = v-colwidth-width-09
      v-colwidth-width-10-shadow = v-colwidth-width-10
      v-colwidth-width-11-shadow = v-colwidth-width-11
      v-colwidth-width-12-shadow = v-colwidth-width-12
      v-colwidth-width-13-shadow = v-colwidth-width-13
      v-colwidth-width-14-shadow = v-colwidth-width-14
      v-colwidth-width-15-shadow = v-colwidth-width-15
      v-colwidth-width-16-shadow = v-colwidth-width-16
      v-colwidth-width-17-shadow = v-colwidth-width-17
      v-colwidth-width-18-shadow = v-colwidth-width-18
      v-colwidth-width-19-shadow = v-colwidth-width-19
      v-colwidth-width-20-shadow = v-colwidth-width-20
    .
  end.

end procedure. /* colwidth-read */


procedure colwidth-write :

  define buffer buf_rpt-option for ubflt.rpt-option .

  do
  on error undo, return error return-value
  :
    if v-colwidth-width-01-shadow <> v-colwidth-width-01
    or v-colwidth-width-02-shadow <> v-colwidth-width-02
    or v-colwidth-width-03-shadow <> v-colwidth-width-03
    or v-colwidth-width-04-shadow <> v-colwidth-width-04
    or v-colwidth-width-05-shadow <> v-colwidth-width-05
    or v-colwidth-width-06-shadow <> v-colwidth-width-06
    or v-colwidth-width-07-shadow <> v-colwidth-width-07
    or v-colwidth-width-08-shadow <> v-colwidth-width-08
    or v-colwidth-width-09-shadow <> v-colwidth-width-09
    or v-colwidth-width-10-shadow <> v-colwidth-width-10
    or v-colwidth-width-11-shadow <> v-colwidth-width-11
    or v-colwidth-width-12-shadow <> v-colwidth-width-12
    or v-colwidth-width-13-shadow <> v-colwidth-width-13
    or v-colwidth-width-14-shadow <> v-colwidth-width-14
    or v-colwidth-width-15-shadow <> v-colwidth-width-15
    or v-colwidth-width-16-shadow <> v-colwidth-width-16
    or v-colwidth-width-17-shadow <> v-colwidth-width-17
    or v-colwidth-width-18-shadow <> v-colwidth-width-18
    or v-colwidth-width-19-shadow <> v-colwidth-width-19
    or v-colwidth-width-20-shadow <> v-colwidth-width-20
    then do:
      do transaction
      on error undo, return error return-value
      :
        find first buf_rpt-option exclusive-lock
          where buf_rpt-option.rpt-name    = v-colwidth-program-name
            and buf_rpt-option.rpt-code    = {&rpt-code_column-width}
            and buf_rpt-option.user-db-num = v-colwidth-db-num
            and buf_rpt-option.user-id     = v-colwidth-user-id
          no-error .
        if not available buf_rpt-option
        then do:
          create buf_rpt-option .
          assign
            buf_rpt-option.rpt-name    = v-colwidth-program-name
            buf_rpt-option.rpt-code    = {&rpt-code_column-width}
            buf_rpt-option.user-db-num = v-colwidth-db-num
            buf_rpt-option.user-id     = v-colwidth-user-id
          .
        end.
        assign
          buf_rpt-option.param-decimal-01-value = v-colwidth-width-01
          buf_rpt-option.param-decimal-02-value = v-colwidth-width-02
          buf_rpt-option.param-decimal-03-value = v-colwidth-width-03
          buf_rpt-option.param-decimal-04-value = v-colwidth-width-04
          buf_rpt-option.param-decimal-05-value = v-colwidth-width-05
          buf_rpt-option.param-decimal-06-value = v-colwidth-width-06
          buf_rpt-option.param-decimal-07-value = v-colwidth-width-07
          buf_rpt-option.param-decimal-08-value = v-colwidth-width-08
          buf_rpt-option.param-decimal-09-value = v-colwidth-width-09
          buf_rpt-option.param-decimal-10-value = v-colwidth-width-10
          buf_rpt-option.param-decimal-11-value = v-colwidth-width-11
          buf_rpt-option.param-decimal-12-value = v-colwidth-width-12
          buf_rpt-option.param-decimal-13-value = v-colwidth-width-13
          buf_rpt-option.param-decimal-14-value = v-colwidth-width-14
          buf_rpt-option.param-decimal-15-value = v-colwidth-width-15
          buf_rpt-option.param-decimal-16-value = v-colwidth-width-16
          buf_rpt-option.param-decimal-17-value = v-colwidth-width-17
          buf_rpt-option.param-decimal-18-value = v-colwidth-width-18
          buf_rpt-option.param-decimal-19-value = v-colwidth-width-19
          buf_rpt-option.param-decimal-20-value = v-colwidth-width-20
        .
      end.
      assign
        v-colwidth-width-01-shadow = v-colwidth-width-01
        v-colwidth-width-02-shadow = v-colwidth-width-02
        v-colwidth-width-03-shadow = v-colwidth-width-03
        v-colwidth-width-04-shadow = v-colwidth-width-04
        v-colwidth-width-05-shadow = v-colwidth-width-05
        v-colwidth-width-06-shadow = v-colwidth-width-06
        v-colwidth-width-07-shadow = v-colwidth-width-07
        v-colwidth-width-08-shadow = v-colwidth-width-08
        v-colwidth-width-09-shadow = v-colwidth-width-09
        v-colwidth-width-10-shadow = v-colwidth-width-10
        v-colwidth-width-11-shadow = v-colwidth-width-11
        v-colwidth-width-12-shadow = v-colwidth-width-12
        v-colwidth-width-13-shadow = v-colwidth-width-13
        v-colwidth-width-14-shadow = v-colwidth-width-14
        v-colwidth-width-15-shadow = v-colwidth-width-15
        v-colwidth-width-16-shadow = v-colwidth-width-16
        v-colwidth-width-17-shadow = v-colwidth-width-17
        v-colwidth-width-18-shadow = v-colwidth-width-18
        v-colwidth-width-19-shadow = v-colwidth-width-19
        v-colwidth-width-20-shadow = v-colwidth-width-20
      .
    end.
  end.

end procedure. /* colwidth-write */


/* $Workfile$ e n d */