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
using Ibs.Th.Rul.Clients_.
using Ibs.Th.Rul.Dis-card-sale_obj.
using Ibs.Th.Rul.Dis-card-type_.
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
 define variable p-dis-tot-obj-code as integer no-undo.
 define variable p-issue-code as integer no-undo.
 define variable p-issue-date as date no-undo.
 define variable p-valid-date as date no-undo.
 define variable p-cli-grp-code as integer no-undo.
 define variable p-lim-cr as decimal no-undo.
 define variable p-category as integer no-undo.


/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/
{ trg/clientsh.i rul }

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
 define variable Cli-code1 as  integer no-undo .
 define variable Cli-first-name1 as  character no-undo .
 define variable Cli-grp-code1 as  integer no-undo .
 define variable Cli-last-name1 as  character no-undo .
 define variable Cli-patronymic-name1 as  character no-undo .
 define variable Cli-phone1 as  character no-undo .
 define variable Cli-type1 as  character no-undo .
 define variable Client1 as class Clients_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save, input "discards")
Client1 = new Clients_{&constructor_1} .
 define variable D-pcnt1 as  decimal no-undo .
 define variable Dc-type1 as  character no-undo .
 define variable Dis-card-type1 as class Dis-card-type_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save)
Dis-card-type1 = new Dis-card-type_{&constructor_1} .
 define variable Emitent-host-code1 as  integer no-undo .
 define variable Import-sum-obj1 as class Dis-card-sale_obj no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input vh_dis-card-sale_obj, input p-codex-id, input p-ruleset-id)
Import-sum-obj1 = new Dis-card-sale_obj{&constructor_1} .
 define variable Issue-code1 as  integer no-undo .
 define variable Issue-date1 as  date no-undo .
 define variable Lim-cr1 as  decimal no-undo .
 define variable Message1 as  character no-undo .
 define variable Netto-sum-base1 as  decimal no-undo .
 define variable Netto-sum-rubl1 as  decimal no-undo .
 define variable Num-chk1 as  integer no-undo .
 define variable Shop-code1 as  integer no-undo .
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
Client1:Clients_{&release_2} .
end.
if v-retry-action < 2 then do:
&scop release_2 release_ ( )
Card1:Dis-card_{&release_2} .
end.
if v-retry-action < 3 then do:
&scop release_2 release_ ( )
Dis-card-type1:Dis-card-type_{&release_2} .
end.
if v-retry-action < 4 then do:
&scop release_2 release_ ( )
Import-sum-obj1:Dis-card-sale_obj{&release_2} .
end.
if v-retry-action < 5 then do:
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
/* Стандартный импорт ДК в IBS TH
 */

_1260:
do:
                                                                      /* Salience 0 rule_id 1260*/
/* define variable Cli-type1 as  character no-undo .*/
                                                                      /* Salience 1 rule_id 1260*/
/* define variable Cli-code1 as  integer no-undo .*/
                                                                      /* Salience 2 rule_id 1260*/
/* define variable Cli-last-name1 as  character no-undo .*/
                                                                      /* Salience 3 rule_id 1260*/
/* define variable Cli-first-name1 as  character no-undo .*/
                                                                      /* Salience 4 rule_id 1260*/
/* define variable Cli-patronymic-name1 as  character no-undo .*/
                                                                      /* Salience 5 rule_id 1260*/
/* define variable Cli-phone1 as  character no-undo .*/
                                                                      /* Salience 6 rule_id 1260*/
/* define variable Cli-grp-code1 as  integer no-undo .*/
                                                                      /* Salience 7 rule_id 1260*/
/* define variable Card-number1 as  character no-undo .*/
                                                                      /* Salience 8 rule_id 1260*/
/* define variable D-pcnt1 as  decimal no-undo .*/
                                                                      /* Salience 9 rule_id 1260*/
/* define variable Num-chk1 as  integer no-undo .*/
                                                                      /* Salience 10 rule_id 1260*/
/* define variable Netto-sum-base1 as  decimal no-undo .*/
                                                                      /* Salience 11 rule_id 1260*/
/* define variable Netto-sum-rubl1 as  decimal no-undo .*/
                                                                      /* Salience 12 rule_id 1260*/
/* define variable Shop-code1 as  integer no-undo .*/
                                                                      /* Salience 13 rule_id 1260*/
/* define variable Issue-code1 as  integer no-undo .*/
                                                                      /* Salience 14 rule_id 1260*/
/* define variable Issue-date1 as  date no-undo .*/
                                                                      /* Salience 15 rule_id 1260*/
/* define variable Dc-type1 as  character no-undo .*/
                                                                      /* Salience 16 rule_id 1260*/
/* define variable Emitent-host-code1 as  integer no-undo .*/
                                                                      /* Salience 17 rule_id 1260*/
/* define variable Lim-cr1 as  decimal no-undo .*/
                                                                      /* Salience 18 rule_id 1260*/
/* define variable Message1 as  character no-undo .*/
                                                                      /* Salience 19 rule_id 1260*/
/* define variable Client1 as class Clients_ no-undo .*/
                                                                      /* Salience 20 rule_id 1260*/
/* define variable Card1 as class Dis-card_ no-undo .*/
                                                                      /* Salience 21 rule_id 1260*/
/* define variable Dis-card-type1 as class Dis-card-type_ no-undo .*/
                                                                      /* Salience 22 rule_id 1260*/
/* define variable Import-sum-obj1 as class Dis-card-sale_obj no-undo .*/
                                                                      /* Salience 23 rule_id 1260*/
/* define variable Tot-sum1 as class Dis-tot_ no-undo .*/
                                                                      /* Salience 24 rule_id 1260*/
 Card-number1 = "" .
                                                                      /* Salience 25 rule_id 1260*/
 import stream INstream  DELIMITER ' '  Cli-type1 Cli-code1 Cli-last-name1 Cli-first-name1 Cli-patronymic-name1 Cli-phone1 Cli-grp-code1 Card-number1 D-pcnt1 Num-chk1 Netto-sum-base1 Netto-sum-rubl1 Shop-code1 Issue-code1 Issue-date1 Dc-type1 Lim-cr1  no-error .
                                                                      /* salience 26 rule_id 1260*/
IF  error-status:error = true  THEN do:
/* salience 27 in upper-rule-id 1260*/
  _1287:
  do:
                                                                      /* salience 0 rule_id 1287*/
  IF  00040000_get-readed-line( input v-seek) = ""  THEN do:
/* salience 1 in upper-rule-id 1287*/
    _1286:
    do:
                                                                      /* Salience 0 rule_id 1286*/
     next _stroka .

    end. /*of rule 1286*/
  end. /*of rule 1286*/
                                                                      /* salience 2 rule_id 1287*/
  IF  num-rec = 1  THEN do:
/* salience 3 in upper-rule-id 1287*/
    _1298:
    do:
                                                                      /* Salience 0 rule_id 1298*/
     Message1 = 00040000_get-error-message() + "Строчка не разобрана!~nТребуемый формат строки(между полями пробелы - символьные поля закавычены):~nтип клиента или ?~nкод клиента или ?~nфамилия клиента или ?~nимя клиента или ?~nотчество клиента или ?~nтелефон клиента или ?~nкод группы клиентов или ?~nномер дисконтной карты - символьный - только цифры~nпроцент скидки - неотрицательный меньше 100 или ?~nчисло чеков клиента или ?~nсумма покупок в базовой валюте или ?~nномер магазина на который будут начислены итоги по дисконтной карте или ?~nномер магазина выдавшего дисконтную карту или ?~nдата выдачи дисконтной карты или ?~nтип карты или ?~nлимит кредита или ?" .

    end. /*of rule 1298*/
  end. /*of rule 1298*/
  else do: /*rule 1297*/
/* salience 4 in upper-rule-id 1287*/
    _1297:
    do:
                                                                      /* Salience 0 rule_id 1297*/
     Message1 = 00040000_get-error-message() .

    end. /*of rule 1297*/
  end. /*of rule 1297*/
                                                                      /* Salience 5 rule_id 1287*/
   Message1 = Message1 + "~nСтрока :" + String( num-rec) .
                                                                      /* Salience 6 rule_id 1287*/
   run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input Message1).
assign v-view-log = yes
 .
                                                                      /* Salience 7 rule_id 1287*/
   next _stroka .

  end. /*of rule 1287*/
end. /*of rule 1287*/
                                                                      /* salience 28 rule_id 1260*/
IF  Card1:find_dis-card_no-error( INPUT Card-number1) = false  THEN do:
/* salience 29 in upper-rule-id 1260*/
  _1264:
  do:
                                                                      /* salience 0 rule_id 1264*/
  IF  (Cli-type1 = ?) OR (Cli-code1 = ?) OR Cli-type1 = "?"  THEN do:
/* salience 1 in upper-rule-id 1264*/
    _1270:
    do:
                                                                      /* salience 0 rule_id 1270*/
    IF  (Cli-type1 = ?) OR Cli-type1 = "?"  THEN do:
/* salience 1 in upper-rule-id 1270*/
      _1271:
      do:
                                                                      /* Salience 0 rule_id 1271*/
       Cli-type1 = {&prs} .

      end. /*of rule 1271*/
    end. /*of rule 1271*/
                                                                      /* salience 2 rule_id 1270*/
    IF  (Cli-code1 = ?)  THEN do:
/* salience 3 in upper-rule-id 1270*/
      _1294:
      do:
                                                                      /* Salience 0 rule_id 1294*/
       Cli-code1 = 0 .

      end. /*of rule 1294*/
    end. /*of rule 1294*/
                                                                      /* salience 4 rule_id 1270*/
    IF  (Cli-grp-code1 = ?)  THEN do:
/* salience 5 in upper-rule-id 1270*/
      _1269:
      do:
                                                                      /* Salience 0 rule_id 1269*/
       Cli-grp-code1 = p-cli-grp-code .

      end. /*of rule 1269*/
    end. /*of rule 1269*/
                                                                      /* salience 6 rule_id 1270*/
    IF  Client1:create_clients_( INPUT Cli-type1, INPUT Cli-code1, INPUT Cli-last-name1, INPUT Cli-grp-code1) = false  THEN do:
/* salience 7 in upper-rule-id 1270*/
      _1302:
      do:
                                                                      /* Salience 0 rule_id 1302*/
       run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + {&new-line} + "Строка: " + String(num-rec))).
assign v-view-log = yes .
                                                                      /* Salience 1 rule_id 1302*/
       undo _stroka, retry _stroka .

      end. /*of rule 1302*/
    end. /*of rule 1302*/
                                                                      /* salience 9 rule_id 1270*/
    IF  Cli-type1 = {&prs}  THEN do:
/* salience 10 in upper-rule-id 1270*/
      _1285:
      do:
                                                                      /* salience 0 rule_id 1285*/
      IF  (Cli-first-name1 <> ?)  THEN do:
/* salience 1 in upper-rule-id 1285*/
        _1293:
        do:
                                                                      /* Salience 0 rule_id 1293*/
         Client1:name1 = Cli-first-name1 .

        end. /*of rule 1293*/
      end. /*of rule 1293*/
                                                                      /* salience 2 rule_id 1285*/
      IF  (Cli-patronymic-name1 <> ?)  THEN do:
/* salience 3 in upper-rule-id 1285*/
        _1284:
        do:
                                                                      /* Salience 0 rule_id 1284*/
         Client1:name2 = Cli-patronymic-name1 .

        end. /*of rule 1284*/
      end. /*of rule 1284*/

      end. /*of rule 1285*/
    end. /*of rule 1285*/
                                                                      /* salience 11 rule_id 1270*/
    IF  (Cli-phone1 <> ?)  THEN do:
/* salience 12 in upper-rule-id 1270*/
      _1288:
      do:
                                                                      /* Salience 0 rule_id 1288*/
       Client1:phone = Cli-phone1 .

      end. /*of rule 1288*/
    end. /*of rule 1288*/

    end. /*of rule 1270*/
  end. /*of rule 1270*/
  else do: /*rule 1289*/
/* salience 2 in upper-rule-id 1264*/
    _1289:
    do:
                                                                      /* salience 0 rule_id 1289*/
    IF  Client1:find_clients_no-error( INPUT Cli-type1, INPUT Cli-code1) = false  THEN do:
/* salience 1 in upper-rule-id 1289*/
      _1292:
      do:
                                                                      /* Salience 0 rule_id 1292*/
       Message1 = "Не найден клиент-держатель карты:" + Cli-type1 + String( Cli-code1) .
                                                                      /* Salience 1 rule_id 1292*/
       Message1 = Message1 + "~nСтрока :" + String( num-rec) .
                                                                      /* Salience 2 rule_id 1292*/
       run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input Message1).
assign v-view-log = yes
 .
                                                                      /* Salience 3 rule_id 1292*/
       undo _stroka, retry _stroka .

      end. /*of rule 1292*/
    end. /*of rule 1292*/

    end. /*of rule 1289*/
  end. /*of rule 1289*/
                                                                      /* salience 3 rule_id 1264*/
  IF  (Dc-type1 = ?) OR Dc-type1 = "?"  THEN do:
/* salience 4 in upper-rule-id 1264*/
    _1265:
    do:
                                                                      /* Salience 0 rule_id 1265*/
     Dc-type1 = v-type .

    end. /*of rule 1265*/
  end. /*of rule 1265*/
                                                                      /* Salience 5 rule_id 1264*/
   Emitent-host-code1 = v-emitent-host-code .
                                                                      /* salience 6 rule_id 1264*/
  IF  Card1:create_dis-card_( INPUT v-current-obj-type, INPUT v-current-obj-code, INPUT Card-number1, INPUT Emitent-host-code1, INPUT Dc-type1, INPUT ( Cli-type1 + String( Cli-code1) )) = false  THEN do:
/* salience 7 in upper-rule-id 1264*/
    _1274:
    do:
                                                                      /* Salience 2 rule_id 1274*/
     run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + {&new-line} + "Строка: " + String(num-rec))).
assign v-view-log = yes .
                                                                      /* Salience 3 rule_id 1274*/
     undo _stroka, retry _stroka .

    end. /*of rule 1274*/
  end. /*of rule 1274*/
                                                                      /* salience 8 rule_id 1264*/
  IF  (Issue-code1 = ?)  THEN do:
/* salience 9 in upper-rule-id 1264*/
    _1273:
    do:
                                                                      /* Salience 0 rule_id 1273*/
     Issue-code1 = p-issue-code .

    end. /*of rule 1273*/
  end. /*of rule 1273*/
                                                                      /* Salience 10 rule_id 1264*/
   Card1:issue-code = Issue-code1 .
                                                                      /* salience 11 rule_id 1264*/
  IF  ( Issue-date1 = ? )  THEN do:
/* salience 12 in upper-rule-id 1264*/
    _1263:
    do:
                                                                      /* Salience 0 rule_id 1263*/
     Issue-date1 = p-issue-date .

    end. /*of rule 1263*/
  end. /*of rule 1263*/
                                                                      /* Salience 13 rule_id 1264*/
   Card1:issue-date = Issue-date1 .
                                                                      /* salience 14 rule_id 1264*/
  IF  (Lim-cr1 = ? )  THEN do:
/* salience 15 in upper-rule-id 1264*/
    _1301:
    do:
                                                                      /* Salience 0 rule_id 1301*/
     Lim-cr1 = p-lim-cr .

    end. /*of rule 1301*/
  end. /*of rule 1301*/
                                                                      /* Salience 16 rule_id 1264*/
   Card1:lim-kr = Lim-cr1 .
                                                                      /* Salience 17 rule_id 1264*/
   Card1:category = p-category .
                                                                      /* Salience 18 rule_id 1264*/
   Card1:valid-date = p-valid-date .

   Card1:valid-from = Issue-date1 .

                                                                                                                                         /* Salience 19 rule_id 1264*/
   Dis-card-type1:find_dis-card-type_( INPUT Emitent-host-code1, INPUT Dc-type1) .
                                                                      /* salience 20 rule_id 1264*/
  IF  (D-pcnt1 = ? )  THEN do:
/* salience 21 in upper-rule-id 1264*/
    _1291:
    do:
                                                                      /* salience 0 rule_id 1291*/
    IF  ( Dis-card-type1:dflt-d-pcnt-method = integer({&dc-d-pcnt-good}) ) OR ( Dis-card-type1:dflt-d-pcnt-method = integer({&dc-d-pcnt-both}) )  THEN do:
/* salience 1 in upper-rule-id 1291*/
      _1290:
      do:
                                                                      /* Salience 0 rule_id 1290*/
       D-pcnt1 = Dis-card-type1:dflt-pcnt# .

      end. /*of rule 1290*/
    end. /*of rule 1290*/
                                                                      /* salience 2 rule_id 1291*/
    IF  ( Dis-card-type1:dflt-d-pcnt-method = integer({&dc-d-pcnt-cash}) ) OR ( Dis-card-type1:dflt-d-pcnt-method = integer({&dc-d-pcnt-both}) )  THEN do:
/* salience 3 in upper-rule-id 1291*/
      _1300:
      do:
                                                                      /* Salience 0 rule_id 1300*/
       D-pcnt1 = Dis-card-type1:dflt-cash-pcnt# .

      end. /*of rule 1300*/
    end. /*of rule 1300*/

    end. /*of rule 1291*/
  end. /*of rule 1291*/
                                                                      /* salience 22 rule_id 1264*/
  IF  ( Dis-card-type1:dflt-d-pcnt-method = integer({&dc-d-pcnt-good}) ) OR ( Dis-card-type1:dflt-d-pcnt-method = integer({&dc-d-pcnt-both}) )  THEN do:
/* salience 23 in upper-rule-id 1264*/
    _1266:
    do:
                                                                      /* Salience 0 rule_id 1266*/
     Card1:d-pcnt = D-pcnt1 .

    end. /*of rule 1266*/
  end. /*of rule 1266*/
  else do: /*rule 1296*/
/* salience 24 in upper-rule-id 1264*/
    _1296:
    do:
                                                                      /* Salience 0 rule_id 1296*/
     Card1:d-pcnt = 0 .

    end. /*of rule 1296*/
  end. /*of rule 1296*/
                                                                      /* salience 25 rule_id 1264*/
  IF  ( Dis-card-type1:dflt-d-pcnt-method = integer({&dc-d-pcnt-cash}) ) OR ( Dis-card-type1:dflt-d-pcnt-method = integer({&dc-d-pcnt-both}) )  THEN do:
/* salience 26 in upper-rule-id 1264*/
    _1299:
    do:
                                                                      /* Salience 0 rule_id 1299*/
     Card1:cash-d-pcnt = D-pcnt1 .

    end. /*of rule 1299*/
  end. /*of rule 1299*/
  else do: /*rule 1272*/
/* salience 27 in upper-rule-id 1264*/
    _1272:
    do:
                                                                      /* Salience 0 rule_id 1272*/
     Card1:cash-d-pcnt = 0 .

    end. /*of rule 1272*/
  end. /*of rule 1272*/
                                                                      /* Salience 28 rule_id 1264*/
   Card1:d-pcnt-method = Dis-card-type1:dflt-d-pcnt-method .
                                                                      /* Salience 29 rule_id 1264*/
   Card1:credit-card = Dis-card-type1:dflt-credit-card .
                                                                      /* Salience 30 rule_id 1264*/
   Card1:debet-card = Dis-card-type1:dflt-debet-card .
                                                                      /* Salience 31 rule_id 1264*/
   Card1:staff-card = Dis-card-type1:dflt-staff-card .
                                                                      /* salience 32 rule_id 1264*/
  IF  (Shop-code1 = ?)  THEN do:
/* salience 33 in upper-rule-id 1264*/
    _1295:
    do:
                                                                      /* Salience 0 rule_id 1295*/
     Shop-code1 = p-dis-tot-obj-code .

    end. /*of rule 1295*/
  end. /*of rule 1295*/
                                                                      /* salience 34 rule_id 1264*/
  IF  ( Netto-sum-base1 <> ?) OR ( Netto-sum-rubl1 <> ?)  THEN do:
/* salience 35 in upper-rule-id 1264*/
    _1268:
    do:
                                                                      /* salience 0 rule_id 1268*/
    IF  Import-sum-obj1:create_dis-card-sale_obj( INPUT Card-number1, INPUT {&shop}, INPUT Shop-code1, INPUT v-current-doc-code, INPUT Issue-date1) = false  THEN do:
/* salience 1 in upper-rule-id 1268*/
      _1267:
      do:
                                                                      /* Salience 0 rule_id 1267*/
       run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + {&new-line} + "Строка: " + String(num-rec))).
assign v-view-log = yes .
                                                                      /* Salience 1 rule_id 1267*/
       undo _stroka, retry _stroka .

      end. /*of rule 1267*/
    end. /*of rule 1267*/
                                                                      /* Salience 2 rule_id 1268*/
     Import-sum-obj1:pay-tot-base = Netto-sum-base1 .
                                                                      /* Salience 3 rule_id 1268*/
     Import-sum-obj1:pay-tot-rubl = Netto-sum-rubl1 .
                                                                      /* Salience 4 rule_id 1268*/
     Import-sum-obj1:gds-tot-base = Netto-sum-base1 .
                                                                      /* Salience 5 rule_id 1268*/
     Import-sum-obj1:gds-tot-rubl = Netto-sum-rubl1 .
                                                                      /* Salience 6 rule_id 1268*/
     Import-sum-obj1:num-chk = Num-chk1 .
                                                                      /* Salience 7 rule_id 1268*/
     Import-sum-obj1:type = Dc-type1 .
                                                                      /* Salience 8 rule_id 1268*/
     Import-sum-obj1:emitent-host-code = Emitent-host-code1 .

    end. /*of rule 1268*/
  end. /*of rule 1268*/
                                                                      /* salience 36 rule_id 1264*/
  IF  Tot-sum1:find_dis-tot_( INPUT Card-number1) = false  THEN do:
/* salience 37 in upper-rule-id 1264*/
    _1283:
    do:
                                                                      /* Salience 0 rule_id 1283*/
     Tot-sum1:create_dis-tot_( INPUT Card-number1) .

    end. /*of rule 1283*/
  end. /*of rule 1283*/
                                                                      /* salience 38 rule_id 1264*/
  IF  Client1:clients_save( ) = false  THEN do:
/* salience 39 in upper-rule-id 1264*/
    _1277:
    do:
                                                                      /* Salience 0 rule_id 1277*/
     run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + {&new-line} + "Строка: " + String(num-rec))).
assign v-view-log = yes .
                                                                      /* Salience 1 rule_id 1277*/
     undo _stroka, retry _stroka .

    end. /*of rule 1277*/
  end. /*of rule 1277*/
                                                                      /* Salience 40 rule_id 1264*/
   Card1:cli-code = Client1:obj-code .
                                                                      /* Salience 41 rule_id 1264*/
   Import-sum-obj1:cli-type = Card1:cli-type .
                                                                      /* Salience 42 rule_id 1264*/
   Import-sum-obj1:cli-code = Card1:cli-code .
                                                                      /* salience 43 rule_id 1264*/
  IF  Card1:dis-card_save( ) = false  THEN do:
/* salience 44 in upper-rule-id 1264*/
    _1278:
    do:
                                                                      /* Salience 0 rule_id 1278*/
     run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + {&new-line} + "Строка: " + String(num-rec))).
assign v-view-log = yes .
                                                                      /* Salience 1 rule_id 1278*/
     undo _stroka, retry _stroka .

    end. /*of rule 1278*/
  end. /*of rule 1278*/
                                                                      /* salience 45 rule_id 1264*/
  IF  Tot-sum1:dis-tot_save( ) = false  THEN do:
/* salience 46 in upper-rule-id 1264*/
    _1279:
    do:
                                                                      /* Salience 0 rule_id 1279*/
     run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + {&new-line} + "Строка: " + String(num-rec))).
assign v-view-log = yes .
                                                                      /* Salience 1 rule_id 1279*/
     undo _stroka, retry _stroka .

    end. /*of rule 1279*/
  end. /*of rule 1279*/
                                                                      /* salience 47 rule_id 1264*/
  IF  (( Netto-sum-base1 <> ?) OR ( Netto-sum-rubl1 <> ?)) and Import-sum-obj1:dis-card-sale_objsave( ) = false  THEN do:
/* salience 48 in upper-rule-id 1264*/
    _1280:
    do:
                                                                      /* Salience 0 rule_id 1280*/
     run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + {&new-line} + "Строка: " + String(num-rec))).
assign v-view-log = yes .
                                                                      /* Salience 1 rule_id 1280*/
     undo _stroka, retry _stroka .

    end. /*of rule 1280*/
  end. /*of rule 1280*/
                                                                      /* salience 49 rule_id 1264*/
  IF  00040000_after-import_f( input Card-number1) = false  THEN do:
/* salience 50 in upper-rule-id 1264*/
    _1936:
    do:
                                                                      /* Salience 0 rule_id 1936*/
     run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + {&new-line} + "Строка: " + String(num-rec))).
assign v-view-log = yes .
                                                                      /* Salience 1 rule_id 1936*/
     undo _stroka, retry _stroka .

    end. /*of rule 1936*/
  end. /*of rule 1936*/

  end. /*of rule 1264*/
end. /*of rule 1264*/
else do: /*rule 1276*/
/* salience 30 in upper-rule-id 1260*/
  _1276:
  do:
                                                                      /* salience 0 rule_id 1276*/
  IF  (Shop-code1 = ?)  THEN do:
/* salience 1 in upper-rule-id 1276*/
    _1282:
    do:
                                                                      /* Salience 0 rule_id 1282*/
     Shop-code1 = p-dis-tot-obj-code .

    end. /*of rule 1282*/
  end. /*of rule 1282*/
                                                                      /* Salience 2 rule_id 1276*/
   Cli-type1 = Card1:cli-type .
                                                                      /* Salience 3 rule_id 1276*/
   Cli-code1 = Card1:cli-code .
                                                                      /* Salience 4 rule_id 1276*/
   Emitent-host-code1 = Card1:emitent-host-code .
                                                                      /* Salience 5 rule_id 1276*/
   Dc-type1 = Card1:type .
                                                                      /* salience 6 rule_id 1276*/
  IF  ( Netto-sum-base1 <> ?) OR ( Netto-sum-rubl1 <> ?)  THEN do:
/* salience 7 in upper-rule-id 1276*/
    _1262:
    do:
                                                                      /* salience 0 rule_id 1262*/
    IF  Import-sum-obj1:find_dis-card-sale_obj_no-error( INPUT Card-number1) = false  THEN do:
/* salience 1 in upper-rule-id 1262*/
      _1261:
      do:
                                                                      /* Salience 0 rule_id 1261*/
       Message1 = "Нельзя импортировать итоги по уже имеющейся ДК" .
                                                                      /* Salience 1 rule_id 1261*/
       Message1 = Message1 + "~nСтрока :" + String( num-rec) .
                                                                      /* Salience 2 rule_id 1261*/
       run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input Message1).
assign v-view-log = yes
 .
                                                                      /* Salience 3 rule_id 1261*/
       undo _stroka, retry _stroka .

      end. /*of rule 1261*/
    end. /*of rule 1261*/
                                                                      /* salience 2 rule_id 1262*/
    IF  Import-sum-obj1:create_dis-card-sale_obj( INPUT Card-number1, INPUT {&shop}, INPUT Shop-code1, INPUT v-current-doc-code, INPUT Issue-date1) = false  THEN do:
/* salience 3 in upper-rule-id 1262*/
      _1275:
      do:
                                                                      /* Salience 0 rule_id 1275*/
       run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + {&new-line} + "Строка: " + String(num-rec))).
assign v-view-log = yes .
                                                                      /* Salience 1 rule_id 1275*/
       undo _stroka, retry _stroka .

      end. /*of rule 1275*/
    end. /*of rule 1275*/
                                                                      /* Salience 4 rule_id 1262*/
     Import-sum-obj1:pay-tot-base = Netto-sum-base1 .
                                                                      /* Salience 5 rule_id 1262*/
     Import-sum-obj1:pay-tot-rubl = Netto-sum-rubl1 .
                                                                      /* Salience 6 rule_id 1262*/
     Import-sum-obj1:gds-tot-base = Netto-sum-base1 .
                                                                      /* Salience 7 rule_id 1262*/
     Import-sum-obj1:gds-tot-rubl = Netto-sum-rubl1 .
                                                                      /* Salience 8 rule_id 1262*/
     Import-sum-obj1:num-chk = Num-chk1 .
                                                                      /* Salience 9 rule_id 1262*/
     Import-sum-obj1:type = Dc-type1 .
                                                                      /* Salience 10 rule_id 1262*/
     Import-sum-obj1:emitent-host-code = Emitent-host-code1 .
                                                                      /* Salience 11 rule_id 1262*/
     Import-sum-obj1:cli-type = Cli-type1 .
                                                                      /* Salience 12 rule_id 1262*/
     Import-sum-obj1:cli-code = Cli-code1 .
                                                                      /* salience 14 rule_id 1262*/
    IF  Import-sum-obj1:dis-card-sale_objsave( ) = false  THEN do:
/* salience 15 in upper-rule-id 1262*/
      _1281:
      do:
                                                                      /* Salience 0 rule_id 1281*/
       run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + {&new-line} + "Строка: " + String(num-rec))).
assign v-view-log = yes .
                                                                      /* Salience 1 rule_id 1281*/
       undo _stroka, retry _stroka .

      end. /*of rule 1281*/
    end. /*of rule 1281*/
                                                                      /* salience 16 rule_id 1262*/
    IF  00040000_after-import_f( input Card-number1) = false  THEN do:
/* salience 17 in upper-rule-id 1262*/
      _1937:
      do:
                                                                      /* Salience 0 rule_id 1937*/
       run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input (v-last-error-message + {&new-line} + "Строка: " + String(num-rec))).
assign v-view-log = yes .
                                                                      /* Salience 1 rule_id 1937*/
       undo _stroka, retry _stroka .

      end. /*of rule 1937*/
    end. /*of rule 1937*/

    end. /*of rule 1262*/
  end. /*of rule 1262*/

  end. /*of rule 1276*/
end. /*of rule 1276*/

end. /*of rule 1260*/


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
Client1:Clients_{&release_2} .
end.
if v-retry-action < 2 then do:
&scop release_2 release_ ( )
Card1:Dis-card_{&release_2} .
end.
if v-retry-action < 3 then do:
&scop release_2 release_ ( )
Dis-card-type1:Dis-card-type_{&release_2} .
end.
if v-retry-action < 4 then do:
&scop release_2 release_ ( )
Import-sum-obj1:Dis-card-sale_obj{&release_2} .
end.
if v-retry-action < 5 then do:
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
and buf_rule-call-param.param-name = "p-dis-tot-obj-code"
 no-error.
if available buf_rule-call-param then do:
assign p-dis-tot-obj-code = buf_rule-call-param.param-value-integer.
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

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-cli-grp-code"
 no-error.
if available buf_rule-call-param then do:
assign p-cli-grp-code = buf_rule-call-param.param-value-integer.
end.

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-lim-cr"
 no-error.
if available buf_rule-call-param then do:
assign p-lim-cr = buf_rule-call-param.param-value-decimal.
end.

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-category"
 no-error.
if available buf_rule-call-param then do:
assign p-category = buf_rule-call-param.param-value-integer.
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

