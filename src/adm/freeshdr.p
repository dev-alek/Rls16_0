block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: freeshdr.p $
$Archive: adm/freeshdr.p $

Процедура вызова произвольной задачи выполняющейся по расписанию

Автор: Бахтадзе Наталья Викторовна
Дата создания: 14/11/05
Author: Bakhtadze Natalya
Creation date: 14/11/05

*/

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-cre-db-num  as integer   no-undo .
define input parameter p-task-type   as character no-undo .
define input parameter p-task-num    as integer   no-undo .
define input parameter p-db-num      as integer      no-undo . /* БД по объктам которой необходимо принять информацию */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: freeshdr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/freeshdr.p $":U .
define variable vss-description as character no-undo init "Процедура вызова произвольной задачи выполняющейся по расписанию".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ adm/auto-def.i }
{ cmp/library.i }
{ ref/shd-attr.i }
{ str/auto2dia.i }
{ bge/bge-xml.i }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-free-id as character no-undo .
define variable v-free-task-name as character no-undo .
define variable v-run-prog-name as character no-undo .
define variable v-enable-concurrent-0 as logical no-undo .
define variable v-enable-concurrent-db as logical no-undo .
define variable v-is-rum as logical no-undo .
define variable v-conf-par as character no-undo .
define variable v-par-val as character no-undo .
define variable v-par-type as character no-undo .
define variable v-mes as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define buffer buf_schedule-attr for ub.schedule-attr.
define buffer buf_schedule for ub.schedule.
define buffer lock-batchprocess for ub.batchprocess.


do
on error undo, return error substitute("&1 &2 &3&4&5&4"
                                      ,vss-workfile
                                      ,vss-revision
                                      ,vss-description
                                      ,{&new-line}
                                      ,error-status:get-message(1) )
:

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

  define buffer lck_schedule-attr for ub.schedule-attr.

  run schedule-attr-get-free-id  in this-procedure (
                                                      input p-cre-db-num
                                                    ,input p-task-type
                                                    ,input p-task-num
                                                    ,output v-free-id) no-error .
  if error-status:error then do:
    assign
    v-mes = substitute("&1 &2 &3&4Невозможно получить название  произвольного задания по строке расписания&4" +
                                  "Неверный атрибут расписания <Идентификатор произвольной задачи>&4" +
                                  "№ расписания &5"
                                  , vss-workfile
                                  , vss-revision
                                  , vss-description
                                  , {&new-line}
                                  , p-task-num
                                  ).

    run write-to-log in this-procedure ( v-mes ).
    undo, return error.
  end.

  run schedule-attr-get-free-props  in this-procedure (input v-free-id, output v-value).
  assign
  v-free-task-name = entry(buffer temp-schedule-free:buffer-field("free-task-name"):POSITION - 2, v-value, {&delim-par} )
  v-run-prog-name = entry(buffer temp-schedule-free:buffer-field("proc-run-name"):POSITION - 2, v-value, {&delim-par} )
  v-conf-par = entry(buffer temp-schedule-free:buffer-field("conf-param"):POSITION - 2, v-value, {&delim-par} )
  v-enable-concurrent-0 = (entry(buffer temp-schedule-free:buffer-field("enable-concurrent-0"):POSITION - 2, v-value, {&delim-par} ) = "yes")
  v-enable-concurrent-db = (entry(buffer temp-schedule-free:buffer-field("enable-concurrent-db"):POSITION - 2, v-value, {&delim-par} ) = "yes")
  no-error .
  if error-status:error then do:
    v-mes = substitute("&1 &2 &3&4Невозможно получить название  произвольного задания по строке расписания&4" +
                                  "Неверно заданы параметры  задания в файле shd-free.d&4&6&4" +
                                  "№ расписания &5"
                                  , vss-workfile
                                  , vss-revision
                                  , vss-description
                                  , {&new-line}
                                  , p-task-num
                                  , error-status:get-message(1)
                                  ).
    run write-to-log in this-procedure ( v-mes ).
    undo, return error.
  end.
  run schedule-attr-is-rum-free-id in this-procedure ( input v-free-id
                                                      ,output v-is-rum) no-error.
  if v-conf-par <> '':U then do:
    { gbl/conf-rd.i
      v-conf-par
      "''"
      "''"
      0
      "''"
      "''"
      "''"
      yes
      v-par-val
      v-par-type
      no-error }
    if error-status:error
    or v-par-type <> "L":U
    then do:
      v-mes = substitute("Невозможно запустить произвольное задания по строке расписания&1" +
                                    "Требуемый конфигурационный параметр &2 не включен&1" +
                                    "№ расписания &3"
                                    , {&new-line}
                                    , v-conf-par
                                    , p-task-num
                                    ).
      run write-to-log in this-procedure ( v-mes ).
      undo, return error.
    end.
  end.
  if not v-enable-concurrent-0 then do:
    run gbl/lock-prc.p
        (input {&lock-prc-schd-free}
        ,input 0
        ,input 0
        ,input 0
        ,input v-free-id
        ,input ""
        ,input ""
        ,input (
                v-free-task-name
              )
        ,input no
        ,buffer lock-batchprocess
        ) no-error .
    if error-status:error then do:
      ASSIGN
      V-MES = return-value .
      run write-to-log in this-procedure ( v-mes ).
      undo, return error.
    end.
  end.
  if not v-enable-concurrent-db then do:
    run gbl/lock-prc.p
        (input {&lock-prc-schd-free}
        ,input 0
        ,input 0
        ,input 0
        ,input v-free-id
        ,input string(p-db-num)
        ,input ""
        ,input (
                v-free-task-name + {&space-char} + string(p-db-num)
              )
        ,input no
        ,buffer lock-batchprocess
        ) no-error .
    if error-status:error then do:
      ASSIGN
      V-MES = return-value .
      run write-to-log in this-procedure ( v-mes ).
      undo, return error.
    end.
  end.
  if v-is-rum then do:
    /*найдем call*/
    find first buf_schedule no-lock where
              buf_schedule.cre-db-num = p-cre-db-num
          and buf_schedule.task-type = p-task-type
          and buf_schedule.task-num = p-task-num no-error.
    run gen-key-rec in this-procedure (
                                      input  {&table_schedule}
                                    ,input (buffer buf_schedule:handle)
                                    ,output v-uniq-key-rec).
    run get-db-num in parparentproc ( output v-cntxt-db-num).
        
    case entry(1, v-free-id, "_"):
      when {&ord} then do:
    run str/ordrum.p
      (
        input parparentproc
      ,input this-procedure
      ,input this-procedure
      ,input {&ord-proc_ord-batchwork}
      ,input 0 /*p-profile-id*/
      ,input 23 /*p-codex-id*/
      ,input 1 /*p-ruleset-id*/
      ,input 0
      ,input v-cntxt-db-num
      ,input v-uniq-key-rec
      ,input  ( string(dynamic-next-value( "next-rep-num":U, "ubflt":U ), "9999999999") + {&delim-par} +
                string(p-task-num) )
            /*n e x  t - r e p o r t не берем - он только до 5 знаков*/
      ,input yes /*p-save*/
      ) no-error .
      end.
      when {&table_goods} then do:
        run str/goodsrum.p
          (
            input parparentproc
          ,input this-procedure
          ,input this-procedure
          ,input {&goods-proc_goods-batchwork}
          ,input 0 /*p-profile-id*/
          ,input 11 /*p-codex-id*/
          ,input 10 /*p-ruleset-id*/
          ,input v-cntxt-db-num
          ,input v-uniq-key-rec
          ,input  ( string(dynamic-next-value( "next-rep-num":U, "ubflt":U ), "9999999999") + {&delim-par} +
                    string(p-task-num) )
                /*n e x  t - r e p o r t не берем - он только до 5 знаков*/
          ,input yes /*p-save*/
          ) no-error .
      end.
    end case.
  end.
  else do:
  run value(v-run-prog-name)(
                              input parparentproc
                            , input this-procedure:handle
                            , input this-procedure:handle
                            , input p-cre-db-num
                            , input p-task-type
                            , input p-task-num
                            , input p-db-num         ) no-error .
  end.
  if error-status :error then do:
    ASSIGN
    V-MES = substitute("!!!Ошибка при выполнении задания:&1&2&1&3&1&6&1№ расписания &4, для БД &5"
                      ,{&new-line}
                      , error-status:get-message(1)
                      , return-value
                      , p-task-num
                      , string(p-db-num)
                      , v-free-task-name ).
    run write-to-log in this-procedure ( v-mes ).
    undo, return error.
  end.
  if return-value <> '':U then do:
    run write-to-log in this-procedure ( return-value ).
  end.
end. /*doe*/