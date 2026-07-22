block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: csh-lst.p $
$Archive: ref/csh-lst.p $

Пакетное изменение по списку скидок кассовых платежей по объекту

Автор: Мазуров Виталий Александрович
Дата создания: 08/03/11
Author: Mazurov Vitaly
Creation date: 08/03/11

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input parameter p-rid-list as char no-undo .
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: csh-lst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/csh-lst.p $":U .
define variable vss-description as character no-undo init "Пакетное изменение по списку скидок кассовых платежей по объекту".

DEFINE TEMP-TABLE temp-cpdisc NO-UNDO LIKE ub.dis-cp-rule
       field rule-label as character.

{ cmp/vssrevis.i }
{ gbl/getcntxt.i def }
{ cmp/trg-def.i }
{ cmp/library.i }
{ ref/discprul.i interface parparentproc }

DEFINE VARIABLE var-object as character no-undo init {&table_dis-cp-rule}.
{ cmp/bitoper.i }
{ ref/temp-dsc.i "SHARED" var-object }

define variable p-rid-list  as character              no-undo .

define variable v-no-ask      as logical   no-undo .
define variable v-view-log    as logical   no-undo .
define variable log-file-name as character no-undo init "csh-lst.txt".
define variable v-stop        as logical   no-undo .

define variable v-choice      as integer   no-undo .
define variable v-i           as integer   no-undo .
define variable v-err-cnt     as integer   no-undo init 0 .
define variable v-deleted     as logical   no-undo .
DEFINE VARIABLE num-rec       as integer no-undo .
DEFINE VARIABLE num-rec-ok    as integer no-undo .

define variable v-cdpay-code like ub.dis-cp-rule.cdpay-code no-undo .
define variable v-curr-code  like ub.dis-cp-rule.curr-code  no-undo .
define variable v-obj-name   as character no-undo .
define variable v-rule-num   as integer   no-undo .
define variable v-nonunique  as character no-undo .

def buffer buf_cash-pay    for ub.cash-pay .
def buffer buf_dis-cp-rule for ub.dis-cp-rule .

&scoped-define cd-type-code     temp-disc.pos-type
&scoped-define dis-cp-rule-code temp-disc.discnt-role

/*Получим и разберем параметры*/
assign
p-rid-list = p-parameter
no-error
.
if error-status:error then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
  { str/cdviewlg.i
  "'!!!При изменении скидок кассовых платежей на объекте по списку кассовых платежей произошли ошибки!!!'"
  "'csh-lst.txt'" }
  return.
end.
run write-log  in p-log-handle( input 0, "&DLine").

/*run gbl/inidebug.p .*/

/*Перебираем список платежей*/
_rid-list:
do v-i = 1 to num-entries(p-rid-list) :
    /*Получим код и валюту*/
    find first buf_cash-pay no-lock
    where recid(buf_cash-pay) = int( entry( v-i, p-rid-list ) ) no-error .
    if not avail buf_cash-pay then do:
       v-err-cnt = v-err-cnt + 1.
       run write-log-and-file in p-log-handle (
           input 1
         , input log-file-name
         , input 1
         , input substitute("Некорректный recid кассового платежа: &1", entry( v-i, p-rid-list ) ) ).
       next _rid-list.
    end.
    assign
      v-cdpay-code = buf_cash-pay.cdpay-code
      v-curr-code  = buf_cash-pay.curr-code
      v-obj-name   = buf_cash-pay.obj-name
    .
    /*Привязываем/удаляем скидки по платежу по объекту*/
    _main:
    do
    on error undo, return error
    :
        _temp-disc:
        for each temp-disc no-lock break by temp-disc.obj-code
            on error undo _main, return error:

            if first-of (temp-disc.obj-code) then do:
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute("Изменение скидок платежа &3 на объекте &1&2 по списку кассовых платежей", temp-disc.obj-type, temp-disc.obj-code, v-obj-name)).
            end.
            assign
               v-nonunique = temp-disc.nonunique
               v-rule-num  = temp-disc.rule-num
            .
            CASE temp-disc.action:
            /*******Добавление платежей*******/
            when yes then do:
                run discpru-write in this-procedure (
                                         input v-cdpay-code
                                        ,input v-curr-code
                                        ,input temp-disc.host-code
                                        ,input temp-disc.obj-type
                                        ,input temp-disc.obj-code
                                        ,input temp-disc.pos-type
                                        ,input temp-disc.discnt-role
                                        ,input temp-disc.templ-rl-root
                                        ,input temp-disc.time-templ-rl-root
                                        ,input v-rule-num
                                        ,input v-nonunique
                                      ) no-error .
                if error-status:error then do:
                    assign
                      num-rec = num-rec + 1
                      v-err-cnt = v-err-cnt + 1
                    .
                    run write-log-and-file in p-log-handle (
                         input 1
                       , input log-file-name
                       , input 1
                       , input substitute("Не удалось привязать скидку по платежу &7 на объекте &1&2: &3&4&5&6&4&8"
                                        , temp-disc.obj-type
                                        , temp-disc.obj-code
                                        , entry( v-i, p-rid-list )
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        , v-obj-name
                                        , temp-disc.label_   /*тут может быть строка ошибки обработки*/
                                         ) ).
                    next _temp-disc .
                end.
                else do:
                    assign
                      num-rec = num-rec + 1
                      num-rec-ok = num-rec-ok + 1
                    .
                end.
                /*Показываем процесс обработки*/
                run show-counter in p-log-handle .
                run write-counter in p-log-handle (substitute("Обработано изменений &1 из них успешно &2"
                                                            , num-rec
                                                            , num-rec-ok
                                                            )) no-error.
                run get-stop-state in p-log-handle ( output v-stop ).
                if v-stop then do:
                  leave _rid-list.
                end.

            end. /*when yes*/
            when no then do:
                /*******Удаление платежей*******/
                run discpru-delete_m in this-procedure (
                                         input v-cdpay-code
                                        ,input v-curr-code
                                        ,input temp-disc.host-code
                                        ,input temp-disc.obj-type
                                        ,input temp-disc.obj-code
                                        ,input temp-disc.pos-type
                                        ,input temp-disc.discnt-role
                                        ,input v-nonunique
                                        ,input temp-disc.rule-num
                                        ,output v-deleted
                                      ) no-error .
                if error-status:error or not v-deleted then do:
                    assign
                      num-rec = num-rec + 1
                      v-err-cnt = v-err-cnt + 1
                    .
                    run write-log-and-file in p-log-handle (
                         input 1
                       , input log-file-name
                       , input 1
                       , input substitute("Не удалось удалить скидку по платежу &7 на объекте &1&2: &3&4&5&6&4&8"
                                        , temp-disc.obj-type
                                        , temp-disc.obj-code
                                        , entry( v-i, p-rid-list )
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        , v-obj-name
                                        , temp-disc.label_  /*тут может быть строка ошибки обработки*/
                                         ) ).
                    next _temp-disc .
                end.
                else do:
                    assign
                      num-rec = num-rec + 1
                      num-rec-ok = num-rec-ok + 1
                    .
                end.
                /*Показываем процесс обработки*/
                run show-counter in p-log-handle .
                run write-counter in p-log-handle (substitute("Обработано изменений &1 из них успешно &2"
                                                            , num-rec
                                                            , num-rec-ok
                                                            )) no-error.
                run get-stop-state in p-log-handle ( output v-stop ).
                if v-stop then do:
                  leave _rid-list.
                end.

            end. /*when no*/
            END CASE.
        end. /*for each temp-disc*/
    end. /*do _main*/


end. /*do p-rid-list*/

run write-log-and-file in p-log-handle (
    input 1
  , input log-file-name
  , input 1
  , input substitute("Пакетное изменение скидок по списку завершено: из &1 успешно изменено &2", num-rec, num-rec-ok )).
.

/*if v-err-cnt > 0 then do:
  assign
  v-view-log = yes.
  { str/cdviewlg.i
  "'!!!При изменении скидок кассовых платежей на объекте по списку кассовых платежей произошли ошибки!!!'"
  "'csh-lst.txt'" }
  return.
end.*/

/*Удаление скидок на платежи*/
procedure discpru-delete_m :
define input parameter p-cdpay-code     like ub.dis-cp-rule.cdpay-code  no-undo .
define input parameter p-curr-code      like ub.dis-cp-rule.curr-code  no-undo .
define input parameter p-host-code      like ub.dis-cp-rule.host-code   no-undo .
define input parameter p-obj-type       like ub.dis-cp-rule.obj-type   no-undo .
define input parameter p-obj-code       like ub.dis-cp-rule.obj-code   no-undo .
define input parameter p-pos-type       like ub.dis-cp-rule.pos-type   no-undo .
define input parameter p-discnt-role    like ub.dis-cp-rule.discnt-role no-undo .
define input parameter p-nonunique      like ub.dis-cp-rule.nonunique   no-undo .
define input parameter p-rule-num       like ub.dis-cp-rule.rule-num   no-undo .
define output parameter p-deleted       as logical no-undo .
define variable v-rule-label as character no-undo .
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
DO
on error undo, return error
:
/*Если указано конкретное правило*/
if not ( p-rule-num = ? or p-rule-num = 0 ) then do:
    find first buf_dis-cp-rule exclusive-lock
    where buf_dis-cp-rule.rule-num = p-rule-num no-error.
    if not available buf_dis-cp-rule then do:
      return '':U.
    end.
    delete buf_dis-cp-rule no-error.
    if error-status:error then do:
      run discpru-name in this-procedure
        (input  buf_dis-cp-rule.templ-rl-root        /* p-templ-rl-root           */
        ,output v-rule-label          /* p-label          */
        ) no-error .
    &scop cd-type-code p-pos-type
      undo, return error substitute("Ошибка при удалении скидки по типу касс. платежа:&1" +
                                   "скидка &2 (POS &3) на фирме &4 &5&6 для платежа&1&7&1&8"
                                    ,{&new-line}
                                    ,v-rule-label
                                    ,p-pos-type
                                    ,p-host-code
                                    ,p-obj-type
                                    ,p-obj-code
                                    ,error-status:get-message(1)
                                    ,return-value ).
    end.
end.
/*Все такие*/
else do:
    find first buf_dis-cp-rule no-lock
    where buf_dis-cp-rule.cdpay-code  = p-cdpay-code
      and buf_dis-cp-rule.curr-code   = p-curr-code
      and buf_dis-cp-rule.obj-type    = p-obj-type
      and buf_dis-cp-rule.host-code   = p-host-code
      and buf_dis-cp-rule.obj-code    = p-obj-code
      and buf_dis-cp-rule.pos-type    = p-pos-type
      and buf_dis-cp-rule.discnt-role = p-discnt-role
      and buf_dis-cp-rule.nonunique   = p-nonunique no-error.
    if not available buf_dis-cp-rule then do:
      return '':U.
    end.

    for each buf_dis-cp-rule exclusive-lock
    where buf_dis-cp-rule.cdpay-code  = p-cdpay-code
      and buf_dis-cp-rule.curr-code   = p-curr-code
      and buf_dis-cp-rule.obj-type    = p-obj-type
      and buf_dis-cp-rule.host-code   = p-host-code
      and buf_dis-cp-rule.obj-code    = p-obj-code
      and buf_dis-cp-rule.pos-type    = p-pos-type
      and buf_dis-cp-rule.discnt-role = p-discnt-role
      and buf_dis-cp-rule.nonunique   = p-nonunique
    :
        delete buf_dis-cp-rule no-error.
        if error-status:error then do:
            run discpru-name in this-procedure (
                 input  buf_dis-cp-rule.templ-rl-root        /* p-templ-rl-root           */
                ,output v-rule-label                         /* p-label          */
            ) no-error .
            &scop cd-type-code p-pos-type
            undo, return error substitute("Ошибка при удалении скидки по типу касс. платежа:&1" +
                                          "скидка &2 (POS &3) на фирме &4 &5&6 для платежа&1&7&1&8"
                                          ,{&new-line}
                                          ,v-rule-label
                                          ,p-pos-type
                                          ,p-host-code
                                          ,p-obj-type
                                          ,p-obj-code
                                          ,error-status:get-message(1)
                                          ,return-value ).
        end.
    end. /*for each buf_dis-cp-rule*/
end.
p-deleted = yes.
return '':U.
END. /*doe*/
end procedure.
