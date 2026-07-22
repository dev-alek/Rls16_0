block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-atrlst.p $
$Archive: ref/g-atrlst.p $

Пакетное изменение по списку глобальных атрибутов товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/18/06
Author: Bakhtadze Natalya
Creation date: 01/18/06

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
define variable vss-workfile    as character no-undo init "$Workfile: g-atrlst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/g-atrlst.p $":U .
define variable vss-description as character no-undo init "Пакетное изменение по списку глобальных атрибутов товара".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ ref/gds-attr.i interface parparentproc }
{ cmp/gds-list.i gds-list def shared }
{ gbl/getcntxt.i def }



define variable parhost-code like ub.sysconf.host-code no-undo .
define variable parobj-type like ub.clients.obj-type no-undo .
define variable parobj-code like ub.clients.obj-code no-undo .
define variable pardelete-ok as logical no-undo .
DEFINE VARIABLE var-object as character no-undo init {&table_goods-attr}.
{ cmp/bitoper.i }
{ cmp/tempattr.i "SHARED" var-object }


define variable v-no-ask as logical no-undo .
define variable v-view-log as logical no-undo .
define variable log-file-name                as character      no-undo init "g-atrlst.txt".
define variable v-stop                       as logical        no-undo .

define variable v-choice as integer no-undo .
DEFINE VARIABLE num-rec as integer no-undo .
DEFINE VARIABLE num-rec-ok as integer no-undo .
define variable v-mes as character no-undo .
define variable v-ok as logical no-undo .


&scoped-define  gds-attr-type-get-error assign ~
v-mes = substitute("товар с кодом &1: ошибка при определении названия и типа глобального атрибута товара &2&3:&4 &5&3"  + ~
                   "Обратитесь к администратору системы"  ~
                   , gds-list.gds-code ~
                   , temp-attr.attr-code ~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).

&scoped-define  gds-attr-value-get-error assign ~
v-mes = substitute("товар с кодом &1: ошибка при определении значения глобального атрибута товара &2&3:&4 &5&3"  + ~
                   "Обратитесь к администратору системы"  ~
                   , gds-list.gds-code ~
                   , temp-attr.attr-code ~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).
&scoped-define  gds-attr-write-error assign ~
v-mes = substitute("товар с кодом &1: ошибка при записи глобального атрибута товара &2&3:&4 &5&3"  + ~
                   "Обратитесь к администратору системы"  ~
                   , gds-list.gds-code ~
                   , temp-attr.attr-value ~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).
&scoped-define  gds-attr-delete-error assign ~
v-mes = substitute("товар с кодом &1: ошибка при удалении глобального атрибута товара &2&3:&4 &5&3"  + ~
                   "Обратитесь к администратору системы"  ~
                   , gds-list.gds-code ~
                   , temp-attr.attr-value ~
                   , ~{&new-line~}     ~
                   , error-status:get-message(1) ~
                   , return-value ).

&scoped-define  gds-attr-check-error assign ~
v-mes = substitute("товар с кодом &1: ошибка при проверке корректности задаваемого значения глобального атрибута товара &2&3:&4 &4&3"  + ~
                   "Обратитесь к администратору системы"  ~
                   , gds-list.gds-code ~
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
  "'!!!При изменении глобальных атрибутов товара по списку товаров произошли ошибки!!!'"
  "'g-atrlst.txt'" }
  return .
end.
run write-log  in p-log-handle(
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Изменение глобальных атрибутов товара по списку товаров")).


_gds-list:
for each gds-list
/*
   , first gds-obj No-LOCK WHERE
          gds-obj.gds-code = gds-list.gds-code AND
          gds-obj.obj-type = parobj-type AND
          gds-obj.obj-code = parobj-code*/
  ON ERROR undo, NEXT:
    num-rec = num-rec + 1.
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
                                        ) no-error .
    end.
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
                      input "Изменение глобальных атрибутов товара  по списку товаров"
                      ,input substitute("Товар с кодом &1 - не удалось провести изменение атрибутов товара на объекте"
                                      , gds-list.gds-code
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
      if pardelete-ok then delete gds-list.
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
      leave _gds-list.
    end.

END.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пакетное изменение глобальных атрибутов по списку товаров завершено: из &1 товаров списка успешно изменено &2", num-rec, num-rec-ok )).
.
{ str/cdviewlg.i
"'!!!При изменении атрибутов товара на объекте по списку товаров произошли ошибки!!!'"
"'g-atrlst.txt'" }


procedure do-changes :
define input parameter pargds-code like ub.goods.gds-code no-undo .

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE var-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-correct as logical no-undo .
define variable v-error-code as character no-undo .
define variable jj as integer no-undo .

    _main:
  do
  on error undo, return error
  :
    _temp-attr:
    for each temp-attr no-lock
        on error undo _main, return error:

      do jj = 1 to num-entries(temp-attr.other-inf, {&slash-char}):
        if entry(1, entry(jj, temp-attr.other-inf, {&slash-char}), "=":U) = "check-ext":U then do:
          assign
          v-check = string(entry(2, entry(jj, temp-attr.other-inf, {&slash-char}), "=":U))
          .
        end.
      end.
      if v-check <> "":U then do:
        assign
        v-correct = no
        v-error-code = "":U.
        run value(v-check)(
                          input pargds-code
                          ,input attr-value
                          ,input (if temp-attr.action = yes then {&update} else {&deletion})
                          ,output v-correct
                          ,output v-error-code) no-error.
        if error-status:error
        or not v-correct  then do:
          {&gds-attr-check-error}
          undo _main, return error v-mes.
        end.
      end.  /*if v-check <> "":U then do:*/
      CASE temp-attr.action:
        when yes then do:
          run gds-attr-write in this-procedure(
                                                input pargds-code,
                                                input temp-attr.attr-code,
                                                input temp-attr.attr-value
                                                    )  no-error.
           if error-status:error  then do:
             {&gds-attr-write-error}
             undo _main, return error v-mes.
           end.
        end. /*when yes*/
        when no then do:
          var-deleted = no.
          run gds-attr-delete in this-procedure(
                                                input pargds-code,
                                                input temp-attr.attr-code,
                                                output var-deleted
                                                    )  no-error.
           if error-status:error  then do:
             {&gds-attr-delete-error}
             undo _main, return error v-mes.
           end.
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