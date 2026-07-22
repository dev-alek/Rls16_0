block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ddcr-lst.p $
$Archive: ref/ddcr-lst.p $

Пакетное изменение по списку скидок на отдельные ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/11/06
Author: Bakhtadze Natalya
Creation date: 12/11/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter pardelete-OK as logical no-undo .
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ddcr-lst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/ddcr-lst.p $":U .
define variable vss-description as character no-undo init "Пакетное изменение по списку скидок на отдельные ДК".
{ cmp/vssrevis.i }
{ gbl/getcntxt.i def }
{ cmp/trg-def.i }
{ cmp/library.i }
{ ref/disdcrul.i }
{ cmp/dc-list.i dc-list def shared }


define variable p-host-code like ub.clients.host-code no-undo .
define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .
define variable pardelete-ok as logical no-undo .
DEFINE VARIABLE var-object as character no-undo init {&table_dis-dc-rule}.
{ cmp/bitoper.i }
{ ref/temp-dsc.i "SHARED" var-object }


define variable v-no-ask as logical no-undo .
define variable v-view-log as logical no-undo .
define variable log-file-name                as character      no-undo init "ddcr-lst.txt".
define variable v-stop                       as logical        no-undo .

define variable v-choice as integer no-undo .
DEFINE VARIABLE num-rec as integer no-undo .
DEFINE VARIABLE num-rec-ok as integer no-undo .
define variable v-mes as character no-undo .

&scoped-define cd-type-code temp-disc.pos-type
&scoped-define dis-dc-rule-code temp-disc.discnt-role

&scoped-define  disdcrul-value-get-error assign ~
v-mes = substitute("ДК &1, фирма &2 &3&4, POS &5, Тип скидки &6: ошибка при определении значения скидки ДК&7&8&7&9"   ~
                   , dc-list.d-card ~
                   , p-host-code  ~
                   , p-obj-type   ~
                   , p-obj-code   ~
                   , ~{&cd-type-name~} ~
                   , ~{&dis-dc-rule-name~} ~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).
&scoped-define  disdcrul-write-error assign ~
v-mes = substitute("ДК &1, фирма &2 объект &3&4, POS &5, Тип скидки &6: ошибка при записи скидки:&7&8&7&9"  ~
                   , dc-list.d-card ~
                   , p-host-code ~
                   , p-obj-type   ~
                   , p-obj-code   ~
                   , ~{&cd-type-name~} ~
                   , ~{&dis-dc-rule-name~} ~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).

&scoped-define  disdcrul-delete-error assign ~
v-mes = substitute("ДК &1, фирма &2 объект &3&4, POS &5, Тип скидки &6: ошибка при удалении скидки:&7&8&7&9" ~
                   , dc-list.d-card ~
                   , p-host-code ~
                   , p-obj-type  ~
                   , p-obj-code   ~
                   , temp-disc.pos-type ~
                   , ~{&dis-dc-rule-name~} ~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).

assign
p-host-code = integer(entry(1, p-parameter, {&delim-par}))
p-obj-type  = entry(2, p-parameter, {&delim-par})
p-obj-code = integer(entry(3, p-parameter, {&delim-par}))
pardelete-ok = logical(entry(4, p-parameter, {&delim-par}))
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
  "'!!!При изменении скидок по отдельным ДК по списку произошли ошибки!!!'"
  "'ddcr-lst.txt'" }
  return .
end.
run write-log  in p-log-handle(
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Изменение скидок товара на объекте &1&2 по списку товаров", p-obj-type, p-obj-code)).


_dc-list:
for each dc-list
  ON ERROR undo, NEXT:
    num-rec = num-rec + 1.
    run do-changes in this-procedure (
                                       input dc-list.d-card
                                      ,input p-host-code
                                      ,input p-obj-type
                                      ,input p-obj-code) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input return-value
                                          ).
      assign
      v-view-log = yes.
      if v-no-ask  then do:
        run gbl/d-askw.w (
                      input "Изменение скидок товара на отдельные ДК по списку"
                      ,input substitute("ДК &1 Фирма &2 объект &3&4 - не удалось провести изменение скидок на ДК"
                                      , dc-list.d-card
                                      , p-host-code
                                      , p-obj-type
                                      , p-obj-code
                                      )
                      ,input "|"
                      ,input ("Продолжить|" +
                            "Продолжить и больше не запрашивать подтверждения на продолжение|" +
                            "Прекратить")
                      ,input "||"
                      ,input 1
                      ,input 3
                      ,output v-choice).
        if v-choice = 3 then do:
          leave.
        end.
        if v-choice = 2 then do:
          assign
          v-no-ask = yes.
        end.
      end.
    end. /*if error-status:error */
    else do:
      num-rec-ok = num-rec-ok + 1.
      if pardelete-ok then delete dc-list.
    end.
    run show-counter in p-log-handle .
    run write-counter in p-log-handle (substitute("Обработано &1 из них успешно &2"
                                                , num-rec
                                                , num-rec-ok
                                                )) no-error.

    run get-stop-state in p-log-handle (
        output v-stop
    ).
    if v-stop then do:
      leave _dc-list.
    end.

END.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пакетное изменение скидок по списку ДК завершено: из &1 ДК списка успешно изменено &2", num-rec, num-rec-ok )).
.
{ str/cdviewlg.i
"'!!!При изменении скидок на отдельные ДК по списку ДК произошли ошибки!!!'"
"'ddcr-lst.txt'" }


procedure do-changes :
define input parameter pard-card like ub.dis-dc-rule.d-card no-undo .
define input parameter p-host-code like ub.clients.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE var-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-correct as logical no-undo .
define variable v-error-code as character no-undo .
define variable v-rule-num as integer no-undo .
define buffer buf_dis-dc-rule for ub.dis-dc-rule.

    _main:
  do
  on error undo, return error
  :
    _temp-disc:
    for each temp-disc no-lock
        on error undo _main, return error:

      CASE temp-disc.action:
        when yes then do:
          run disdcrul-write in this-procedure(
                                                 input pard-card
                                                ,input p-host-code
                                                ,input p-obj-type
                                                ,input p-obj-code
                                                ,input temp-disc.pos-type
                                                ,input temp-disc.discnt-role
                                                ,input temp-disc.templ-rl-root
                                                ,input temp-disc.time-templ-rl-root
                                                ,input temp-disc.rule-num
                                                ,input temp-disc.nonunique
                                                    )  no-error.


          if error-status:error then do:
            {&disdcrul-write-error}
            undo _main, return error v-mes.
          end.
        end. /*when yes*/
        when no then do:
          var-deleted = no.
          find first buf_dis-dc-rule no-lock where
                    buf_dis-dc-rule.obj-type = temp-disc.obj-type
                and buf_dis-dc-rule.obj-code = temp-disc.obj-code
                and buf_dis-dc-rule.host-code = temp-disc.host-code
                and buf_dis-dc-rule.d-card = pard-card
                and buf_dis-dc-rule.pos-type = temp-disc.pos-type
                and buf_dis-dc-rule.discnt-role = temp-disc.discnt-role
                and  buf_dis-dc-rule.nonunique = temp-disc.nonunique   no-error.
          if available buf_dis-dc-rule
          and buf_dis-dc-rule.time-templ-rl-root = temp-disc.time-templ-rl-root
          and buf_dis-dc-rule.rule-num = temp-disc.rule-num
          then do:
            v-rule-num = buf_dis-dc-rule.rule-num.
            find current buf_dis-dc-rule exclusive-lock no-wait no-error.
            if not available buf_dis-dc-rule then do:
&scoped-define cd-type-code temp-disc.pos-type
              undo _main, return error substitute( "Товар &1 фирма &2 объект &3&4 POS &5 тип скидки &6, правило &7&8" +
                                                   "занята запись скидки"
                                                   , pard-card
                                                   , p-host-code
                                                   , p-obj-type
                                                   , p-obj-code
                                                   , {&cd-type-name}
                                                   , {&dis-dc-rule-name}
                                                   , v-rule-num
                                                   , {&new-line}
                                                   ).

            end.
            delete buf_dis-dc-rule no-error.
            if error-status:error then do:
              {&disdcrul-delete-error}
              undo _main, return error v-mes.
            end.
          end.
        end.
      END CASE.
    end. /*for each temp-disc*/
  end.

end procedure. /* do-changes */