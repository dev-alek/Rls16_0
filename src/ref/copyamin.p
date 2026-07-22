block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: copyamin.p $
$Archive: ref/copyamin.p $

Копирование ассортиментного МИН между объектами

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/29/05
*/

define input parameter parparentproc   as   widget-handle       no-undo.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: copyamin.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/copyamin.p $":U .
define variable vss-description as character no-undo init "Копирование ассортиментного МИН между объектами".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define buffer buf_gds-obj-prop  for ub.gds-obj-prop .
define buffer curr_gds-obj-prop for ub.gds-obj-prop .
define buffer buf_assortment-matrix for ub.assortment-matrix  .
define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods  .

define temp-table temp-err no-undo  LIKE ub.rep-line
  field str as character
  field gds-code as integer
index pi is primary unique  gds-code
.
empty temp-table temp-err.
do
on error undo, return error return-value
:
  { gbl/getcntxt.i get }
 /* Проверка прав */
 define variable v-log1 as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-izt_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log1
  }
 if not v-log1 then return no-apply .

  message
    "Копирование ассортиментного МИН c текущего объекта" skip
    p-curr-obj-type
    p-curr-obj-code skip
    "Продолжить?" skip
    view-as alert-box question
    buttons yes-no
    update v-log as logical .

  if v-log <> true
  then do:
    return .
  end.

  define variable v-host-code   as integer   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .
  define variable v-user-select as logical   no-undo .

  { gbl/hostcode.i
    p-curr-obj-type
    p-curr-obj-code
    v-host-code
  }
  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-host-code
    p-curr-obj-type
    p-curr-obj-code
    v-user-select
    v-obj-type
    v-obj-code
  }
  if v-user-select <> true
  then do:
    message
      "Объект не выбран"
      view-as alert-box information .
    return .
  end.
if p-curr-obj-type = v-obj-type and
   p-curr-obj-code = v-obj-code
  then do:
    message
      "Объект не должен быть равен текущему!!!"
      view-as alert-box information .
    return .
  end.


  message
    "Копирование ассортиментного МИН c текущего объекта" skip
    p-curr-obj-type
    p-curr-obj-code skip
    "на объект"
    v-obj-type
    v-obj-code
    "Продолжить?" skip
    view-as alert-box question
    buttons yes-no
    update v-log .

  if v-log <> true
  then do:
    return .
  end.


  { gbl/hostcode.i
    v-obj-type
    v-obj-code
    v-host-code
  }
define variable  v-str as character no-undo .
v-str = "" .
run waitfram-show ("Ждите....").

define variable is-am       as logical   no-undo .
define variable asmt-id     as integer   no-undo .
define variable asmt-db-num as integer   no-undo .
is-am = false .
find first buf_assortment-matrix no-lock where
           buf_assortment-matrix.asmt-status = 0 and
           buf_assortment-matrix.obj-code = v-obj-code and
           buf_assortment-matrix.obj-type = v-obj-type
           no-error .
        if available buf_assortment-matrix then do: /* есть матрица там куда копируем */
        assign
            is-am          = true
            asmt-id        = buf_assortment-matrix.asmt-id
            asmt-db-num    = buf_assortment-matrix.db-num
        .
        end.

  /* зачистка старого мин */
  for each curr_gds-obj-prop exclusive-lock
    where curr_gds-obj-prop.obj-type = v-obj-type
      and curr_gds-obj-prop.obj-code = v-obj-code
      and curr_gds-obj-prop.gdop-assort-min = true
  on error undo, return error return-value
  :
    curr_gds-obj-prop.gdop-assort-min = false .
  end.


  for each buf_gds-obj-prop no-lock
    where buf_gds-obj-prop.obj-type =  p-curr-obj-type
      and buf_gds-obj-prop.obj-code =  p-curr-obj-code
      and buf_gds-obj-prop.gdop-assort-min = true
  on error undo, return error return-value
  :
  if is-am then do:
      find first buf_assortment-matrix-goods no-lock  where
                 buf_assortment-matrix-goods.asmg-status = 0 and
                 buf_assortment-matrix-goods.gds-code    =  buf_gds-obj-prop.gds-code and
                 buf_assortment-matrix-goods.asmt-id     =  asmt-id and
                 buf_assortment-matrix-goods.db-num      =  asmt-db-num
                 no-error .
      if not available  buf_assortment-matrix-goods then do:
          create temp-err.
          assign
            temp-err.gds-code = buf_gds-obj-prop.gds-code
        .
          { gbl/gds-cdnm.i
            buf_gds-obj-prop.gds-code
            temp-err.str
          }

         v-str = '---' .
         next.
      end.
  end.

    find first ub.gds-obj-prop exclusive-lock
      where ub.gds-obj-prop.gds-code = buf_gds-obj-prop.gds-code
        and ub.gds-obj-prop.obj-type = v-obj-type
        and ub.gds-obj-prop.obj-code = v-obj-code
      no-error .
    if available ub.gds-obj-prop then do:
          assign
            ub.gds-obj-prop.gdop-assort-min = buf_gds-obj-prop.gdop-assort-min
          .
    end.
    else do:
          create ub.gds-obj-prop no-error .
          assign
            ub.gds-obj-prop.gds-code        = buf_gds-obj-prop.gds-code
            ub.gds-obj-prop.obj-type        = v-obj-type
            ub.gds-obj-prop.obj-code        = v-obj-code
            ub.gds-obj-prop.gdop-assort-min = buf_gds-obj-prop.gdop-assort-min
            .
    end.
  end.
  run waitfram-hide.
  define variable loc-ok1 as logical   no-undo .

  if v-str <> "" then do:
     message "Не все Товары Ассортиментного МИН удалось скопировать на объект" skip
            v-obj-type skip
            v-obj-code skip
            "Они не вошли в Ассортиментную матрицу объекта." skip
            "Просмотреть товары не вошедшие в список ?"
            view-as alert-box question
            buttons yes-no
            update loc-ok1
    .
    if loc-ok1 then
        run gbl/tt-view.w
           ( input table  temp-err ) .


  end.
  run ref/gds-amin.w
    (input parParentProc
    ,input v-obj-type
    ,input v-obj-code
    ,input ?
    ) .
end.