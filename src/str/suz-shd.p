block-level on error undo, throw.
/*

$Revision: 190dc748139a, 1744, rls $
$Author: SSlivenko $
$Date: Mon Jan 14 12:46:21 2019 +0300 $
$Workfile: suz-shd.p $
$Archive: str/suz-shd.p $

АвтоРасчет отчетов

Автор: Кочетков Михаил Юрьевич
Дата создания: 09/14/05
Author: Michael Kochetkov
Creation date: 09/14/05

*/

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-cre-db-num as integer   no-undo .
define input  parameter p-task-type  as character no-undo .
define input  parameter p-task-num   as integer   no-undo .
define input  parameter p-db-num     as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: 190dc748139a, 1744, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 14 12:46:21 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: suz-shd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/suz-shd.p $":U .
define variable vss-description as character no-undo init "АвтоРасчет отчетов )".
{ cmp/vssrevis.i 'substitute("&1|&2",p-db-num,p-task-type)'}
{ cmp/str-glbl.i }
{ adm/auto-def.i }
&global-define tab-shift 2
{ str/auto2dia.i    }
{ ref/shd-attr.i }
{ gbl/key-rec.i }
{ gbl/getcntxt.i def }

do
on error undo, return error return-value
:
  define variable v-ind as integer   no-undo .
  run gbl/set-gbl.p
    (input  true
    ,input  g#auto-user-id
    ,input  g#auto-user-password
    ) no-error .
  if error-status :error
  then do:
    run write-to-log in this-procedure
      ( vss-workfile + {&space-char}
      + "Ошибка при инициализации переменных g#..." + {&new-line}
      + error-status :get-message(error-status :num-messages) + {&new-line}
      + return-value
      ) .
    return error return-value .
  end.

  define variable v-param-list as character no-undo .
  define variable v-rp-by-call-uniq-key-rec as character no-undo .
  define variable v-uniq-key-rec as character no-undo .
  define variable v-param-type as character no-undo .
  define variable v-dirs as character no-undo .
  define buffer buf_schedule for ub.schedule.
  define buffer lck_schedule-attr for ub.schedule-attr.

  run adm/lockshda.p (
                        input p-cre-db-num
                       ,input p-task-type
                       ,input p-task-num
                       ,input {&attr-schedule-param-list-h}
                       ,buffer lck_schedule-attr).
  if error-status :error = yes
  then do:
    run write-to-log( vss-workfile + {&space-char}
                    + "Другая сессия уже работает с этим расписанием..." + {&new-line}
                    + error-status:get-message(error-status:num-messages)
                    + return-value
                    ) .
    return . /* --->>>--- */
  end.

  find first buf_schedule no-lock where
            buf_schedule.cre-db-num = p-cre-db-num
         and buf_schedule.task-type = p-task-type
         and buf_schedule.task-num = p-task-num no-error.
  run schedule-attr-value in this-procedure
    (input  p-cre-db-num
    ,input  p-task-type
    ,input  p-task-num
    ,input  {&attr-schedule-param-list-h}
    ,output v-dirs
    ,output v-param-type
    ) .
  /*найдем call*/
  if available buf_schedule
  then do :
    run gen-key-rec in this-procedure (
                                      input  {&table_schedule}
                                    ,input (buffer buf_schedule:handle)
                                    ,output v-uniq-key-rec).
  end.
  else do :
    find last buf_schedule no-lock where
            buf_schedule.cre-db-num = p-cre-db-num
         and buf_schedule.task-type = p-task-type no-error.
    if available buf_schedule
    then do :
      run gen-key-rec in this-procedure (
                                        input  {&table_schedule}
                                      ,input (buffer buf_schedule:handle)
                                      ,output v-uniq-key-rec).
    end.
    else do :
      v-uniq-key-rec = "schedule" + {&delim-key} + string(p-cre-db-num) + {&delim-key} + p-task-type + {&delim-key} + string(p-task-num) .
    end.
  end.                              
  run get-db-num in parparentproc ( output v-cntxt-db-num).
  run rep/reprum.p
    (
      input parparentproc
    ,input this-procedure
    ,input this-procedure
    ,input {&rep-proc_rep-batchwork}
    ,input 0 /*p-profile-id*/
    ,input 22 /*p-codex-id*/
    ,input 1 /*p-ruleset-id*/
    ,input 0
    ,input v-cntxt-db-num
    ,input v-uniq-key-rec
    ,input  ( string(dynamic-next-value( "next-rep-num":U, "ubflt":U ), "9999999999") + {&delim-par} +
              string(p-task-num) + {&delim-par} +
              v-dirs )
           /*n e x  t - r e p o r t не берем - он только до 5 знаков*/
    ,input yes /*p-save*/
    ) no-error .

  /* очистка выполненных отложенных заданий */
  run trg/bt_clr.p .

end.