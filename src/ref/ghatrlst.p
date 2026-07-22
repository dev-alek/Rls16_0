block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ghatrlst.p $
$Archive: ref/ghatrlst.p $

Пакетное изменение по списку атрибутов товара на фирме

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

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
define variable vss-workfile    as character no-undo init "$Workfile: ghatrlst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/ghatrlst.p $":U .
define variable vss-description as character no-undo init "Пакетное изменение по списку атрибутов товара на фирме".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

{ cmp/gds-list.i gds-list def shared }
{ ref/gdshattr.i }
{ gbl/getcntxt.i def }


define variable parhost-code like ub.sysconf.host-code no-undo .
define variable parobj-type like ub.clients.obj-type no-undo .
define variable parobj-code like ub.clients.obj-code no-undo .
define variable pardelete-ok as logical no-undo .
DEFINE VARIABLE var-object as character no-undo init {&table_gds-host-attr}.
{ cmp/bitoper.i }
{ cmp/tempattr.i "SHARED" var-object }
{ cmp/obj-list.i }

define variable v-no-ask as logical no-undo .
define variable v-view-log as logical no-undo .
define variable log-file-name                as character      no-undo init "ghatrlst.txt".
define variable v-stop                       as logical        no-undo .
define variable v-choice as integer no-undo .
DEFINE VARIABLE num-rec as integer no-undo .
DEFINE VARIABLE num-rec-ok as integer no-undo .
DEFINE VARIABLE num-rec-all as integer no-undo .
DEFINE VARIABLE num-rec-ok-all as integer no-undo .
define variable v-ok as logical no-undo .


define variable v-mes as character no-undo .


&scoped-define  gdshattr-type-get-error assign ~
v-mes = substitute("товар с кодом &1, фирма &2: ошибка при определении названия и типа атрибута товара на фирме &3&4:&5 &6&4"  + ~
                   "Обратитесь к администратору системы"  ~
                   , gds-list.gds-code ~
                   , parhost-code         ~
                   , temp-attr.attr-code ~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).

&scoped-define  gdshattr-value-get-error assign ~
v-mes = substitute("товар с кодом &1, фирма &2: ошибка при определении значения атрибута товара на фирме &3&4:&5 &6&4"  + ~
                   "Обратитесь к администратору системы"  ~
                   , gds-list.gds-code ~
                   , parhost-code         ~
                   , temp-attr.attr-code ~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).

&scoped-define  gdshattr-write-error assign ~
v-mes = substitute("товар с кодом &1, фирма &2: ошибка при записи атрибута товара на фирме &3&4:&5 &6&4"  + ~
                   "Обратитесь к администратору системы"  ~
                   , gds-list.gds-code ~
                   , parhost-code         ~
                   , temp-attr.attr-value ~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).

&scoped-define  gdshattr-delete-error assign ~
v-mes = substitute("товар с кодом &1, фирма &2: ошибка при удалении атрибута товара на фирме &3&4:&5 &6&4"  + ~
                   "Обратитесь к администратору системы"  ~
                   , gds-list.gds-code ~
                   , parhost-code         ~
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
  "'!!!При изменении атрибутов товара на фирме по списку товаров произошли ошибки!!!'"
  "'ghatrlst.txt'" }
  return .
end.
for each obj-list
break
by obj-list.obj-type
by obj-list.obj-code
:
assign
parhost-code = obj-list.obj-code
  .


run write-log  in p-log-handle(
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Изменение атрибутов товара на фирме &1 по списку товаров", parhost-code)).

assign
num-rec = 0
num-rec-ok = 0
.

_gds-list:
for each gds-list No-LOCK
  ON ERROR undo, NEXT:
    num-rec = num-rec + 1.
    num-rec-all = num-rec-all + 1.
    v-ok = false.
    run check-actg in this-procedure (
                                       input gds-list.grp-code
                                      ,input gds-list.gds-code
                                      ,input parobj-code
                                      ,input parobj-type
                                      ,output v-ok )  no-error .

    if v-ok = true then do :
    run do-changes in this-procedure (
                                       input gds-list.gds-code
                                      ,input parhost-code
                                      ,input parobj-type
                                      ,input parobj-code
                                      ) no-error .

    end.
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
                      input "Изменение атрибутов товара на фирме по списку товаров"
                      ,input substitute("Товар с кодом &1 фирма &2 - не удалось провести изменение атрибутов товара на фирме"
                                      , gds-list.gds-code
                                      , parhost-code
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
      num-rec-ok-all = num-rec-ok-all + 1.
      if pardelete-ok and last(obj-list.obj-type) and last(obj-list.obj-code) then do:
        delete gds-list.
      end.
    end.

    run show-counter in p-log-handle .
    run write-counter in p-log-handle (substitute("Обработано по фирме &3 &1 из них успешно &2"
                                                , num-rec
                                                , num-rec-ok
                                                , parhost-code
                                                )) no-error.

    run get-stop-state in p-log-handle (
        output v-stop
    ).
    if v-stop then do:
      leave _gds-list.
    end.
END.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пакетное изменение атрибутов по фирме &3: из &1 товаров успешно изменено &2"
                      , num-rec
                      , num-rec-ok
                      , parhost-code
                      )).

end.
run write-log  in p-log-handle(
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пакетное изменение атрибутов по списку товаров завершено:&3 из &1 успешно изменено &2"
                       , num-rec-all
                       , num-rec-ok-all
                       , {&new-line})).
.
{ str/cdviewlg.i
"'!!!При изменении атрибутов товара на фирме по списку товаров произошли ошибки!!!'"
"'ghatrlst.txt'" }

procedure do-changes :
define input parameter pargds-code like ub.gds-obj.gds-code no-undo .
define input parameter parhost-code like ub.sysconf.host-code no-undo .
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
          run gdshattr-write in this-procedure(
                                                input pargds-code,
                                                input parobj-type,
                                                input parobj-code,
                                                input temp-attr.attr-code,
                                                input temp-attr.attr-value
                                                    )  no-error.
          IF ERROR-STATUS:ERROR THEN DO:
              {&gdshattr-write-error}
              undo _main, return error v-mes.
          END.
        end.
        when no then do:
          var-deleted = no.
          run gdshattr-delete in this-procedure(
                                                input pargds-code,
                                                input parobj-type,
                                                input parobj-code,
                                                input temp-attr.attr-code,
                                                output var-deleted
                                                    )  no-error.
          IF ERROR-STATUS:ERROR THEN DO:
              {&gdshattr-delete-error}
              undo _main, return error v-mes.
          END.
        end.
      END CASE.
    end. /*for each temp-attr*/
  end.

end procedure. /* do-changes */

procedure check-actg :

define input parameter p-grp-code as integer no-undo.
define input parameter p-gds-code as integer no-undo.
define input parameter p-obj-code as integer no-undo.
define input parameter p-obj-type as character no-undo.
define output parameter p-ok as logical no-undo.

define variable glog as logical no-undo.

do
on error undo, return error
:
    { gbl/getcntxt.i get }
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reference_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    p-grp-code
    0
    false
    glog
    }
    if glog then do:
      assign
        p-ok = true.
    end.
    else do :
      find first gds-grp no-lock
           where gds-grp.node-code = p-grp-code no-error.
      v-mes = substitute("товар с кодом &1, &2&3: У вас отсутствует глобальное право на изменение товара в привязке к группе товаров &4"
                   , p-gds-code
                   , p-obj-type
                   , p-obj-code
                   , (string(gds-grp.node-code) + " " + gds-grp.node-name)
                    ).
      undo,return error v-mes.
    end.
end.

end procedure.   /*check-actg*/