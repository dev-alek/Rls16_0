
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 4

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/08/06
Author: Bakhtadze Natalya
Creation date: 10/08/06


---------------------------&start-codex_id=4;ruleset_id=1;-----------------
Импорт данных по ДК

---------------------------&end-codex_id=4;ruleset_id=1;-----------------

*/

/*---------------------------&start-using-class&-------------------------------*/
using Ibs.Th.Rul.Dis-card_.
using Ibs.Th.Rul.Dis-tot_.
block-level on error undo, throw.

/*---------------------------&end-using-class&---------------------------------*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-is-dynamic as logical no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-doc-date as date no-undo .
define input parameter p-fact-date as date no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .
/*если вызывается персистентно то эти два параметра не играют значения*/
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .

{ str/saledcdf.i " " }
define INPUT parameter table for temp-d-card.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 4".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ cmp/dc-list.i dc-list   def "shared" }
{ cmp/dcp-list.i dcp-list def "shared" }
{ str/vchk-pay.i "SHARED" }
{ trg/new-bcod.i }
{ nws/lib-nws.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code

{ nws/temp-cmd.i "SHARED" }
{ rul/cl-hist.i "shared" }
{ rul/library-cls.i "non-class-part" }
{ gbl/key-rec.i }
{ gbl/gate-clb.i }


/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-d-card as character no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-doc-code as character no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-current-date as date no-undo .
define variable v-emitent-host-code as integer no-undo .
define variable v-type as character no-undo .
/*****************************/
define variable v-sign as integer no-undo .
define variable file-name as char.
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-end-new-line     as logical no-undo .
define variable v-last-error-message as character no-undo .
define variable v-retry-action as integer no-undo .
define variable v-retry as logical no-undo .
define variable v-last-rec-ord as integer no-undo .

{ rul/seterror.i }
define shared temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-cmd for temp-cmd.
/*это у нас объект 3*/
define buffer buf_dis-card-sale_obj for temp-d-card.
define variable vh_dis-card-sale_obj as handle no-undo .
vh_dis-card-sale_obj = buffer buf_dis-card-sale_obj:handle.
define temp-table temp-clients_ no-undo like ub.clients.
define temp-table temp-dis-card_ no-undo like ub.dis-card.


define buffer buf_cash-pay for ub.cash-pay.

define stream instream.
define variable log-file-name                as character      no-undo init "indcard.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-seek                       as int64          no-undo .

function 00040000_get-readed-line returns character ( input p-seek as int64):
define variable v-line as character no-undo .
seek stream instream to p-seek.
import stream instream unformatted v-line.
return v-line.
end function.

function 00040000_get-error-message returns character :
define variable v-ii as integer no-undo .
define variable v-mess as character no-undo .
DO v-ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
    v-mess = substitute("&1&2ош &3"
                        ,v-mess
                        ,{&new-line}
                        ,ERROR-STATUS:GET-MESSAGE(v-ii)).
END.
return v-mess.
end function.

function 00040000_after-import_f returns logical ( input p-d-card as character):
  run 00040000_after-import in this-procedure ( input p-d-card) no-error.
  run set-error in this-procedure ( input return-value ).
  return not (error-status:error).
end function.



&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~).            ~
          assign v-view-log = yes



/*---------------------------&start-rule-call-param&-------------------------------*/
 define variable p-cli-type-code as character no-undo.
 define variable p-issue-code as integer no-undo.
 define variable p-issue-date as date no-undo.
 define variable p-valid-date as date no-undo.


/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/
{ trg/discardh.i rul }
{ trg/dis-hsth.i rul }














/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run delete-procedure in this-procedure .
end.


&scop sign v-sign *

run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error .
if error-status:error
or return-value = "return" then return.

/* ------------------------- &start-def-vars& -----------------------------------*/
 define variable Card-number1 as  character no-undo .
 define variable Card1 as class Dis-card_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save)
Card1 = new Dis-card_{&constructor_1} .
 define variable d-pcnt1 as  decimal no-undo .
 define variable Line1 as  character no-undo .
 define variable Message1 as  character no-undo .
 define variable Tot-sum1 as class Dis-tot_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save)
Tot-sum1 = new Dis-tot_{&constructor_1} .


/* ------------------------- &end-def-vars& -----------------------------------*/


if not this-procedure:persistent then do:
  run proc-main in this-procedure ( input p-type
                              ,input p-emitent-host-code ) no-error .
  if error-status:error then do:
      run delete-procedure in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  run delete-procedure in this-procedure .
end.

procedure proc-main :
define input parameter p-type like ub.dis-card.type no-undo .
define input parameter p-emitent-host-code like ub.dis-card.emitent-host-code no-undo .

_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

/*надо найти настройки маршрутизации и записи истории для данного типа ДК для всех объектов*/
assign
v-emitent-host-code = p-emitent-host-code
v-type = p-type.


/* ------------------------- &start-hn-option& -----------------------------------*/





/* ------------------------- &end-hn-option -----------------------------------*/


run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт физ лиц/карт из файла &1", file-name)).


    input stream Instream from value(file-name).

    _stroka:
    REPEAT:
      v-retry = no.
      if retry then do:
        v-retry = yes.
      end.
      process events.
      run get-stop-state in p-log-handle ( output v-stop) no-error .
      if v-stop then do:
          run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input substitute("Процесс импорта прерван пользователем")).
         leave _stroka.
      end.
      if not v-retry then
      num-rec = num-rec + 1.
      if not v-retry then do:
      run get-last-rec-ord in p-cmd-proc-handle ( input p-cmd-code, output v-last-rec-ord).
      v-retry-action = 0 .
      end.
     _release:
      do on error undo, retry:
        if  retry
        or v-retry
        then do:
          v-retry-action = v-retry-action + 1.
          run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input substitute("Ошибка при импорте строки &1&2&3&2&4"
                                                                  , num-rec
                                                                  , {&new-line}
                                                                  , error-status:get-message(1)
                                                                  , return-value)).
        end.
      /* ------------------------- &count-retry-action-start& -----------------------------------*/
      /* ------------------------- &start-release-obj& -----------------------------------*/
if v-retry-action < 1 then do:
&scop release_2 release_ ( )
Card1:Dis-card_{&release_2} .
end.
if v-retry-action < 2 then do:
&scop release_2 release_ ( )
Tot-sum1:Dis-tot_{&release_2} .
end.

      /* ------------------------- &end-release-obj& -------------------------------------*/
      /* ------------------------- &count-retry-action-end& -----------------------------------*/
      end.

       v-seek = seek(instream).
       _rule:
       do transaction on error undo _rule, retry _rule:
         if retry
         or v-retry
         then do:
            run write-log-and-file in p-log-handle (
                                                    input 1
                                                  , input log-file-name
                                                  , input 1
                                                  , input substitute("&1&2&3"
                                                                    , error-status:get-message(1)
                                                                    , {&new-line}
                                                                    , return-value)).
           run undo-from-rec-ord in p-cmd-proc-handle ( input p-cmd-code, input v-last-rec-ord).
           run clear-from-rec-ord in this-procedure ( input v-last-rec-ord).
           next _stroka.
         end.
         else do:
      /* ------------------------- &start-rule& -----------------------------------*/
/* Импорт данных по ДК из сиcтемы ЛАНТАБ
 */

_1250:
do:
                                                                      /* Salience 0 rule_id 1250*/
/* define variable Card-number1 as  character no-undo .*/
                                                                      /* Salience 1 rule_id 1250*/
/* define variable d-pcnt1 as  decimal no-undo .*/
                                                                      /* Salience 2 rule_id 1250*/
/* define variable Card1 as class Dis-card_ no-undo .*/
                                                                      /* Salience 3 rule_id 1250*/
/* define variable Line1 as  character no-undo .*/
                                                                      /* Salience 4 rule_id 1250*/
/* define variable Message1 as  character no-undo .*/
                                                                      /* Salience 5 rule_id 1250*/
/* define variable Tot-sum1 as class Dis-tot_ no-undo .*/
                                                                      /* Salience 6 rule_id 1250*/
 Card-number1 = "" .
                                                                      /* Salience 7 rule_id 1250*/
 import stream INstream  DELIMITER ';'  Card-number1 d-pcnt1  no-error .
                                                                      /* salience 8 rule_id 1250*/
IF  error-status:error = true  THEN do:   
/* salience 9 in upper-rule-id 1250*/
  _1252:
  do:
                                                                      /* salience 0 rule_id 1252*/
  IF  00040000_get-readed-line( input v-seek) = ""  THEN do:   
/* salience 1 in upper-rule-id 1252*/
    _1255:
    do:
                                                                      /* Salience 0 rule_id 1255*/
     next _stroka .

    end. /*of rule 1255*/
  end. /*of rule 1255*/
                                                                      /* salience 2 rule_id 1252*/
  IF  num-rec = 1  THEN do:   
/* salience 3 in upper-rule-id 1252*/
    _1251:
    do:
                                                                      /* Salience 0 rule_id 1251*/
     Message1 = 00040000_get-error-message() + "Строка не разобрана!~nТребуемый формат строки(между полями <;>):~nномер ДК символьный - только цифры~n%скидки неотрицательный, меньше 100 или ?" .

    end. /*of rule 1251*/
  end. /*of rule 1251*/
  else do: /*rule 1254*/
/* salience 4 in upper-rule-id 1252*/
    _1254:
    do:
                                                                      /* Salience 0 rule_id 1254*/
     Message1 = 00040000_get-error-message() .

    end. /*of rule 1254*/
  end. /*of rule 1254*/
                                                                      /* Salience 5 rule_id 1252*/
   Message1 = Message1 + "~nСтрока :" + String( num-rec) .
                                                                      /* Salience 9 rule_id 1252*/
   run write-log-and-file in p-log-handle ( 
                input 1                            
              , input log-file-name                
              , input 1                            
              , input Message1).            
assign v-view-log = yes
 .
                                                                      /* Salience 10 rule_id 1252*/
   next _stroka .

  end. /*of rule 1252*/
end. /*of rule 1252*/
                                                                      /* salience 10 rule_id 1250*/
IF  Card1:find_dis-card_no-error( INPUT Card-number1) = false  THEN do:   
/* salience 12 in upper-rule-id 1250*/
  _1253:
  do:
                                                                      /* salience 0 rule_id 1253*/
  IF  Card1:create_dis-card_( INPUT v-current-obj-type, INPUT v-current-obj-code, INPUT Card-number1, INPUT v-emitent-host-code, INPUT v-type, INPUT p-cli-type-code) = false  THEN do:   
/* salience 1 in upper-rule-id 1253*/
    _1257:
    do:
                                                                      /* Salience 2 rule_id 1257*/
     run write-log-and-file in p-log-handle ( 
                input 1                            
              , input log-file-name                
              , input 1                            
              , input (v-last-error-message + {&new-line} + "Строка: " + String(num-rec))).     
assign v-view-log = yes .
                                                                      /* Salience 3 rule_id 1257*/
     undo _stroka, retry _stroka .

    end. /*of rule 1257*/
  end. /*of rule 1257*/
                                                                      /* Salience 2 rule_id 1253*/
   Card1:issue-code = p-issue-code .
                                                                      /* Salience 3 rule_id 1253*/
   Card1:issue-date = p-issue-date .
                                                                      /* Salience 4 rule_id 1253*/
   Card1:valid-date = p-valid-date .
                                                                      /* Salience 5 rule_id 1253*/
   Card1:d-pcnt = d-pcnt1 .
                                                                      /* Salience 6 rule_id 1253*/
   Tot-sum1:create_dis-tot_( INPUT Card-number1) .
                                                                      /* salience 7 rule_id 1253*/
  IF  Card1:dis-card_save( ) = false  THEN do:   
/* salience 8 in upper-rule-id 1253*/
    _1258:
    do:
                                                                      /* Salience 0 rule_id 1258*/
     run write-log-and-file in p-log-handle ( 
                input 1                            
              , input log-file-name                
              , input 1                            
              , input (v-last-error-message + {&new-line} + "Строка: " + String(num-rec))).     
assign v-view-log = yes .
                                                                      /* Salience 1 rule_id 1258*/
     undo _stroka, retry _stroka .

    end. /*of rule 1258*/
  end. /*of rule 1258*/
                                                                      /* salience 9 rule_id 1253*/
  IF  Tot-sum1:dis-tot_save( ) = false  THEN do:   
/* salience 10 in upper-rule-id 1253*/
    _1259:
    do:
                                                                      /* Salience 0 rule_id 1259*/
     run write-log-and-file in p-log-handle ( 
                input 1                            
              , input log-file-name                
              , input 1                            
              , input (v-last-error-message + {&new-line} + "Строка: " + String(num-rec))).     
assign v-view-log = yes .
                                                                      /* Salience 1 rule_id 1259*/
     undo _stroka, retry _stroka .

    end. /*of rule 1259*/
  end. /*of rule 1259*/

  end. /*of rule 1253*/
end. /*of rule 1253*/

end. /*of rule 1250*/


      /* ------------------------- &end-rule -------------------------------------*/
        end.
      end.
      v-retry-action = 0 .
     _release:
      do on error undo, retry:
        if  retry
        or v-retry
        then do:
          v-retry-action = v-retry-action + 1.
          run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input substitute("&1&2&3"
                                                                  , error-status:get-message(1)
                                                                  , {&new-line}
                                                                  , v-last-error-message )).
        end.
      /* ------------------------- &count-retry-action-start& -----------------------------------*/
      /* ------------------------- &start-release-obj& -----------------------------------*/
if v-retry-action < 1 then do:
&scop release_2 release_ ( )
Card1:Dis-card_{&release_2} .
end.
if v-retry-action < 2 then do:
&scop release_2 release_ ( )
Tot-sum1:Dis-tot_{&release_2} .
end.

      /* ------------------------- &end-release-obj& -------------------------------------*/
      /* ------------------------- &count-retry-action-end& -----------------------------------*/
      end.
      if v-retry-action = 0 then do:
        num-rec-ok = num-rec-ok + 1.
      end.
      run write-counter in p-log-handle ( input substitute("Обработано строк: &1, из них удачно: &2", num-rec, num-rec-ok)).
      process events.
      run get-stop-state in p-log-handle ( output v-stop) no-error .
      if v-stop then do:
          run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input substitute("Процесс импорта прерван пользователем")).
         leave _stroka.
      end.
      if num-rec modulo 100 = 0 then do:
        run write-log-and-file in p-log-handle (
                                                input 1
                                              , input log-file-name
                                              , input 1
                                              , input substitute("Записи &1-&2: сохранение/пересылка в СПН...", num-rec - 100, num-rec)).
        find first buf_temp-cmd use-index pi.
        run after-command in p-parent-handle (buffer buf_temp-cmd) no-error.
        if error-status:error then do:
          &scop my-message substitute("Ошибка при сохранении/пересылке по СПН:&1&2&1&3" ~
                                      , ~{&new-line~} ~
                                      , error-status:get-message(1) ~
                                      , return-value )
         {&display-message}.
          undo _main, return error .
        end.
        run before-command in p-parent-handle (buffer buf_temp-cmd) no-error.
        if error-status:error then do:
          &scop my-message substitute("Ошибка при инициации сохранения/пересылки пакета по СПН:&1&2&1&3" ~
                                      , ~{&new-line~} ~
                                      , error-status:get-message(1) ~
                                      , return-value )
         {&display-message}.
        end.
        find first buf_temp-cmd use-index pi.
        p-cmd-code = buf_temp-cmd.cmd-code.
      end.
    end. /*repeat*/
    if not v-stop then do:
      num-rec = num-rec - 1.
    end.
    input stream instream close.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
                                          , input substitute("Записи &1-&2: сохранение/пересылка в СПН..."
                                          , (num-rec - num-rec modulo 100 + 1), num-rec)).
    find first buf_temp-cmd use-index pi.
    run after-command in p-parent-handle (buffer buf_temp-cmd) no-error.
    if error-status:error then do:
      &scop my-message substitute("Ошибка при сохранении/пересылке по СПН:&1&2&1&3" ~
                                  , ~{&new-line~} ~
                                  , error-status:get-message(1) ~
                                  , return-value )
      {&display-message}.
      undo _main, return error .
    end.
    run before-command in p-parent-handle (buffer buf_temp-cmd) no-error.
    if error-status:error then do:
      &scop my-message substitute("Ошибка при инициации сохранения/пересылки пакета по СПН:&1&2&1&3" ~
                                  , ~{&new-line~} ~
                                  , error-status:get-message(1) ~
                                  , return-value )
      {&display-message}.
    end.
    find first buf_temp-cmd use-index pi.
    p-cmd-code = buf_temp-cmd.cmd-code.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Обработано строк: &1, из них удачно: &2", num-rec, num-rec-ok)).
  end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for tt0-rule-call-param.

  do
  on error undo, return error
  :

/*---------------------------&start-process-rule-call-param&-------------------------------*/
 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-cli-type-code"
 no-error.
if available buf_rule-call-param then do:
assign p-cli-type-code = buf_rule-call-param.param-value-character.
end.

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-issue-code"
 no-error.
if available buf_rule-call-param then do:
assign p-issue-code = buf_rule-call-param.param-value-integer.
end.

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-issue-date"
 no-error.
if available buf_rule-call-param then do:
assign p-issue-date = buf_rule-call-param.param-value-date.
end.

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-valid-date"
 no-error.
if available buf_rule-call-param then do:
assign p-valid-date = buf_rule-call-param.param-value-date.
end.



/*---------------------------&end-process-rule-call-param&-------------------------------*/
    case p-ruleset-id:
      when 1 then do:
        for each buf_cash-pay no-lock where
               buf_cash-pay.curr-code = 0
        by buf_cash-pay.cdpay-code:
           if buf_cash-pay.is-cash then do:
             leave.
           end.
        end.
        if not available buf_cash-pay then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Не найдено ни одного типа кассового платежа с валютой &1 и свойством <НАЛИЧНЫЕ>,&2" +
                                 "к которому можно привязать импортируемые суммы покупок по ДК"
                                 , 0
                                 , {&new-line}
                                 )).
          assign
          v-view-log = yes.
          {&view-log}.
          return error.
        end.
        assign
        v-sign = 1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-doc-code = p-doc-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        v-current-date = p-doc-date
        file-name  = p-process-file-name
        .
        if NOT g#db-num = 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Импорт клиентов и их дисконтных карт возможен только в ГБД")).
          assign
          v-view-log = yes.
          {&view-log}.
          return "return".
        end.

        run gbl/filename.p (
                        input  file-name
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Не найден файл для импорта физ.лиц/ДК &1", file-name)).
          assign
          v-view-log = yes.
          {&view-log}.
          return "return".
        end.
        assign
        file-name = v-full-path.
        run gbl/filnline.p (
                      input file-name
                      ,output v-end-new-line).
        if v-end-new-line = no then do:
          /*добавим перевод каретки*/
          output stream Instream to value(file-name) append.
          put stream instream unformatted skip(1).
          output stream Instream close.
        end.
      end.
    end case.
  end. /*doe*/

end procedure. /* load-ruleset-context */

procedure 00040000_set-vpay-chk  :
define input parameter p-bh as handle no-undo .
define buffer buf_vchk-pay for vchk-pay.
find first buf_vchk-pay no-lock where
          buf_vchk-pay.d-card = p-bh:buffer-field("d-card"):buffer-value
      and buf_vchk-pay.pay-code = buf_cash-pay.cdpay-code
      and buf_vchk-pay.curr-code = 0
      and buf_vchk-pay.doc-date = v-current-date
      and buf_vchk-pay.cre-pay = no
      and buf_vchk-pay.exch-rate = p-bh:buffer-field("pay-tot-rubl"):buffer-value / p-bh:buffer-field("pay-tot-base"):buffer-value
      and buf_vchk-pay.base-rate = p-bh:buffer-field("pay-tot-rubl"):buffer-value / p-bh:buffer-field("pay-tot-base"):buffer-value
      no-error .
 if not available buf_vchk-pay then do:
   create buf_vchk-pay.
   assign
   buf_vchk-pay.d-card = p-bh:buffer-field("d-card"):buffer-value
   buf_vchk-pay.pay-code = buf_cash-pay.cdpay-code
   buf_vchk-pay.curr-code = 0
   buf_vchk-pay.doc-date = v-current-date
   buf_vchk-pay.cre-pay = no
   buf_vchk-pay.exch-rate = p-bh:buffer-field("pay-tot-rubl"):buffer-value / p-bh:buffer-field("pay-tot-base"):buffer-value
   buf_vchk-pay.base-rate = p-bh:buffer-field("pay-tot-rubl"):buffer-value / p-bh:buffer-field("pay-tot-base"):buffer-value
   .
 end.
 assign
 buf_vchk-pay.tot-sum = buf_vchk-pay.tot-sum + p-bh:buffer-field("pay-tot-rubl"):buffer-value
 buf_vchk-pay.tot-base = buf_vchk-pay.tot-base + p-bh:buffer-field("pay-tot-base"):buffer-value
 buf_vchk-pay.tot-rubl = buf_vchk-pay.tot-rubl + p-bh:buffer-field("pay-tot-rubl"):buffer-value
 .
end procedure.

procedure create_clients_:
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define buffer buf_temp-clients_ for temp-clients_.
find first buf_temp-clients_ where
          buf_temp-clients_.obj-type = p-obj-type
     and  buf_temp-clients_.obj-code = p-obj-code no-error .
if not available buf_temp-clients_ then do:
  create buf_temp-clients_.
  assign
  buf_temp-clients_.obj-type = p-obj-type
  buf_temp-clients_.obj-code = p-obj-code
  .
end.
end procedure.

procedure create_dis-card_:
define input parameter p-d-card as character no-undo .
define buffer buf_temp-dis-card_ for temp-dis-card_.
find first buf_temp-dis-card_ where
          buf_temp-dis-card_.d-card = p-d-card no-error .
if not available buf_temp-dis-card_ then do:
  create buf_temp-dis-card_.
  assign
  buf_temp-dis-card_.d-card = p-d-card
  .
end.
end procedure.

procedure can-find_clients_  :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define output parameter p-find as logical no-undo .
find first temp-clients_ where
                     temp-clients_.obj-type = p-obj-type
                 and temp-clients_.obj-code = p-obj-code no-error.
p-find = available temp-clients_.
end procedure.

procedure can-find_dis-card_  :
define input parameter p-d-card as character no-undo .
define output parameter p-find as logical no-undo .
find first temp-dis-card_ where
                     temp-dis-card_.d-card = p-d-card no-error.
p-find = available temp-dis-card_.
end procedure.

procedure delete-procedure :

  do
  on error undo, return error
  :
      for each temp-clients_:
        delete temp-clients_.
      end.
      for each temp-dis-card_:
        delete temp-dis-card_.
      end.
      run garbcoll_clear in this-procedure .

  end.

end procedure. /* delete-procedure */

{ str/saledcdf.i " " import-temp-d-card }

procedure 00040000_after-import :
define input  parameter p-d-card as character no-undo .
define variable v-ii as integer   no-undo .
define variable v-jj as integer   no-undo .
define variable v-codex-id as integer   no-undo .
define variable v-ruleset-id as integer   no-undo .
define variable v-ai-ruleset-id-list as character no-undo extent 4.
define variable v-ai-codex-id-list as character no-undo .
define variable v-proc-name as character no-undo .
define buffer buf_temp-d-card for temp-d-card.
define buffer buf_Dis-card for ub.dis-card.
define buffer buf_import-temp-d-card for import-temp-d-card.
define buffer buf_rule-by-call for ub.rule-by-call.

  main-block:
  do
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :

      assign
      v-ai-codex-id-list = (if g#db-num = 0
                         then "1,2"
                         else '':U)
      v-ai-ruleset-id-list[1] = string(5)
      v-ai-ruleset-id-list[2] = "6,5"
      v-ai-ruleset-id-list[3] = ''
      .

      find first buf_temp-d-card where
               buf_temp-d-card.d-card = p-d-card no-error.
      if not available buf_temp-d-card then do:
        find first buf_Dis-card exclusive-lock where
                  buf_dis-card.d-card = p-d-card no-error.
        if not available  buf_dis-card then do:
          undo main-block, return error substitute("ДК &1 не найдена").
        end.
      end.
      create buf_import-temp-d-card.
      if available buf_temp-d-card then do:
        buffer-copy buf_temp-d-card to buf_import-temp-d-card.
      end.
      else do:
        buffer-copy buf_dis-card to buf_import-temp-d-card
        assign
        buf_import-temp-d-card.obj-type = p-obj-type
        buf_import-temp-d-card.obj-code = p-obj-code
        buf_import-temp-d-card.host-code = p-host-code
        .
      end.
      release buf_temp-d-card.
      _codex:
      do v-jj = 1 to num-entries(v-ai-codex-id-list):
        if entry(v-jj, v-ai-codex-id-list) = '':U then next _codex.
        v-codex-id = integer(entry(v-jj, v-ai-codex-id-list)).
        do v-ii = 1 to num-entries(v-ai-ruleset-id-list[v-jj]):
           if entry(v-ii, v-ai-ruleset-id-list[v-jj]) = '':U then next.
           v-ruleset-id = integer(entry(v-ii, v-ai-ruleset-id-list[v-jj])).
          _rule-by-call:
          for each buf_rule-by-call no-lock where
                    buf_rule-by-call.call_id = p-call-id
              and buf_rule-by-call.can-calc = yes
              and buf_rule-by-call.codex_id = v-codex-id
              and buf_rule-by-call.ruleset_id = v-ruleset-id
          by buf_rule-by-call.call_Id
          by buf_rule-by-call.codex_id
          by buf_rule-by-call.ruleset_id
          by buf_rule-by-call.order_id
          on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
          on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ) :
            if not (buf_rule-by-call.profile_id = p-profile-id
                    or
                    buf_rule-by-call.profile_id = 1
                    )
            then next _rule-by-call.
            v-proc-name = "rul/" + string(buf_rule-by-call.rule_id, '999999999') + '.p'.
            run value(v-proc-name)  (
                                                           input parparentproc
                                                          ,input p-parent-handle
                                                          ,input p-log-handle
                                                          ,input p-cont-handle
                                                          ,input v-codex-id
                                                          ,input v-ruleset-id
                                                          ,input p-call-id
                                                          ,input buf_rule-by-call.order_id
                                                          ,input buf_rule-by-call.rule_id
                                                          ,input buf_rule-by-call.profile
                                                          ,input buf_rule-by-call.is_dynamic
                                                          ,input p-doc-type
                                                          ,input buf_import-temp-d-card.host-code
                                                          ,input buf_import-temp-d-card.obj-type
                                                          ,input buf_import-temp-d-card.obj-code
                                                          ,input p-doc-code
                                                          ,input p-process-file-name
                                                          ,input p-doc-date
                                                          ,input p-fact-date
                                                          ,input p-save
                                                          ,input v-curr-r-b
                                                          ,input p-cmd-proc-handle
                                                          ,input p-cmd-code
                                                          ,input p-type
                                                          ,input p-emitent-host-code
                                                          ,input table import-temp-d-card
                                                          ) no-error .
        if error-status:error then do:
          undo main-block, return error substitute("Ошибка при выполнении правила &1 ( профайл &2) для ДК &3&4&5&4&6"
                                                   ,buf_rule-by-call.rule_id
                                                   ,buf_rule-by-call.profile_id
                                                   ,p-d-card
                                                   ,{&new-line}
                                                   ,error-status:get-message(1)
                                                   ,return-value ).
        end.
      end. /*for each buf_rule-by-call no-lock where*/
    end. /*do v-ii = 1 to num-entries(v-ai-ruleset-id-list[v-jj]):*/
  end. /*do v-jj = 1 to num-entries(v-ai-codex-id-list):*/
  find first buf_import-temp-d-card where buf_import-temp-d-card.d-card = p-d-card.
  delete buf_import-temp-d-card.
end.
end procedure.


