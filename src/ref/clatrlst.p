block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: clatrlst.p $
$Archive: ref/clatrlst.p $

Пакетное изменение по списку атрибутов клиента

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/28/05
Author: Bakhtadze Natalya
Creation date: 12/28/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input parameter parhost-code like ub.sysconf.host-code no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
define input parameter pardelete-OK as logical no-undo .
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clatrlst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/clatrlst.p $":U .
define variable vss-description as character no-undo init "Пакетное изменение по списку атрибутов клиента".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

{ gbl/clntattr.i }
{ cmp/cli-list.i cli-list def shared }
{ gbl/cur-time.i }

define variable parhost-code like ub.sysconf.host-code no-undo .
define variable parobj-type like ub.clients.obj-type no-undo .
define variable parobj-code like ub.clients.obj-code no-undo .
define variable pardelete-ok as logical no-undo .
DEFINE VARIABLE var-object as character no-undo init {&table_clients-attr}.
{ cmp/bitoper.i }
{ cmp/tempattr.i "SHARED" var-object }


define variable v-no-ask as logical no-undo .
define variable v-view-log as logical no-undo .
define variable log-file-name                as character      no-undo init "clatrlst.txt".
define variable v-stop                       as logical        no-undo .
define variable v-choice as integer no-undo .
DEFINE VARIABLE num-rec as integer no-undo .
DEFINE VARIABLE num-rec-ok as integer no-undo .
define variable v-mes as character no-undo .


&scoped-define  cliattr-type-get-error assign ~
v-mes = substitute("клиент &1&2: ошибка при определении названия и типа атрибута клиента&3:&4&5 &6&4"  + ~
                   "Обратитесь к администратору системы"  ~
                   , cli-list.obj-type ~
                   , cli-list.obj-code  ~
                   , temp-attr.attr-code ~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).

&scoped-define  cliattr-value-get-error assign ~
v-mes = substitute("клиент &1&2: ошибка при определении значения атрибута клиента &3:&4&5 &6&4"  + ~
                   "Обратитесь к администратору системы"  ~
                   , cli-list.obj-type ~
                   , cli-list.obj-code  ~
                   , temp-attr.attr-code ~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).

&scoped-define  cliattr-write-error assign ~
v-mes = substitute("клиент &1&2: ошибка при записи атрибута клиента &3:&4&5 &6&4"  + ~
                   "Обратитесь к администратору системы"  ~
                   , cli-list.obj-type ~
                   , cli-list.obj-code  ~
                   , temp-attr.attr-value ~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).

&scoped-define  cliattr-delete-error assign ~
v-mes = substitute("клиент &1&2: ошибка при удалении атрибута клиента &3:&4&5 &6&4"  + ~
                   "Обратитесь к администратору системы"  ~
                   , cli-list.obj-type ~
                   , cli-list.obj-code  ~
                   , temp-attr.attr-value ~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).

assign
parhost-code = integer(entry(1, p-parameter, {&delim-par}))
parobj-type  = entry(2, p-parameter, {&delim-par})
parobj-code = integer(entry(3, p-parameter, {&delim-par}))
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
  "'!!!При изменении атрибутов клиента по списку клиентов произошли ошибки!!!'"
  "'clatrlst.txt'" }
  return .
end.
run write-log  in p-log-handle(
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Изменение атрибутов клиентов по списку клиентов")).



_cli-list:
for each cli-list No-LOCK ,
    first ub.clients No-LOCK WHERE
          ub.clients.obj-type = cli-list.obj-type AND
          ub.clients.obj-code = cli-list.obj-code
  ON ERROR undo, NEXT:
    num-rec = num-rec + 1.
    run do-changes in this-procedure (
                                       input ub.clients.obj-type
                                      ,input ub.clients.obj-code) no-error .

    if error-status:error then do:
      assign
      v-view-log = yes.
      run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input return-value
                                          ).
       if v-no-ask  then do:
        run gbl/d-askw.w (
                      input "Изменение атрибутов клиентов по списку"
                      ,input substitute("клиент &1&2 - не удалось провести изменение атрибутов клиента"
                                      , cli-list.obj-type
                                      , cli-list.obj-code
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
       end. /*if-v-no-ask*/
    end. /*if error-status:error */
    else do:
      num-rec-ok = num-rec-ok + 1.
      if pardelete-ok then delete cli-list.
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
      leave _cli-list.
    end.
END.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пакетное изменение атрибутов по списку клиентов завершено: из &1 клиентов списка успешно изменено &2", num-rec, num-rec-ok )).
.
{ str/cdviewlg.i
"'!!!При изменении атрибутов клиентов по списку клиентов произошли ошибки!!!'"
"'clatrlst.txt'" }

procedure do-changes :
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE var-deleted as logical no-undo .

    _main:
  do
  on error undo, return error
  :
    for each temp-attr no-lock
        on error undo _main, return error:
      CASE temp-attr.action:
        when yes then do:
          run clntattr-write in this-procedure(
                                                input parobj-type,
                                                input parobj-code,
                                                input temp-attr.attr-code,
                                                input temp-attr.attr-value
                                                    )  no-error.
          IF ERROR-STATUS:ERROR THEN DO:
              {&cliattr-write-error}
              undo _main,   return error v-mes.
          END.
        end.
        when no then do:
          var-deleted = no.
          run clntattr-delete in this-procedure(
                                                input parobj-type,
                                                input parobj-code,
                                                input temp-attr.attr-code,
                                                output var-deleted
                                                    )  no-error.
          IF ERROR-STATUS:ERROR THEN DO:
              {&cliattr-delete-error}
              undo _main, return error v-mes.
          END.
        end.
      END CASE.
    end. /*for each temp-attr*/
  end.

end procedure. /* do-changes */