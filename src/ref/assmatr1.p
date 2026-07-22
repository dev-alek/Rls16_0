block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: assmatr1.p $
$Archive: ref/assmatr1.p $

Сохранение изменений в карточке Заголовка АМ

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/23/05
*/

define input-output parameter p-doc-rec  as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-asmt-id   like ub.assortment-matrix.asmt-id   no-undo .
define input parameter p-asmt-name like ub.assortment-matrix.asmt-name no-undo .
define input parameter p-des       like ub.assortment-matrix.asmt-des  no-undo .
define input parameter p-type      like ub.assortment-matrix.asmt-type no-undo .
define input parameter p-obj-type  like ub.assortment-matrix.obj-type  no-undo .
define input parameter p-obj-code  like ub.assortment-matrix.obj-code  no-undo .
define input parameter p-rel       as logical   no-undo .
define input parameter p-rootshablon as character no-undo .


def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: assmatr1.p $":U .
def var vss-archive     as character no-undo init "$Archive: ref/assmatr1.p $":U .
def var vss-description as character no-undo init "Сохранение изменений в карточке Заголовка АМ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/assmatat.i }

define variable v-db-num like ub.db.db-num no-undo .
define variable v-db-num-obj like ub.db.db-num no-undo .

define stream LogStream.

if p-mode <> {&add-def} AND p-mode <> {&update} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.

{ gbl/curdbnum.i v-db-num }

if p-asmt-name = "":U then do:
  run err-mess ("Название ассортиментной матрицы не может быть пустым").
  return error "asmt-name":U.
end.

_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:

define variable v-date as date no-undo .
define variable v-time as integer no-undo .

if p-type = {&type-assmatr-obj} then do:
    if p-obj-type = "" and p-obj-code = 0 then do:
        message "Не заполнено значение Объекта !"
                 view-as alert-box error.
        undo, return error .
    end.

    define buffer x_curr_clients for ub.clients.
      find first  x_curr_clients no-lock where
                x_curr_clients.obj-type = p-obj-type and
                x_curr_clients.obj-code = p-obj-code no-error.
      if not available x_curr_clients then do:
      message
      "Неверное значение для поиска Объекта"
          p-obj-type
          p-obj-code
          view-as alert-box error.
      undo, return error .
      end.

    /* своя БД для удаленки*/
       if v-db-num > 0 then do:
        if x_curr_clients.db-num <>  v-db-num then do:
            message
            "На УБД нельзя добавлять/корректировать Ассортиментные матрици по Объектам других БД" skip
                p-obj-type p-obj-code skip
                "БД : " x_curr_clients.db-num
                view-as alert-box error.
            undo, return error .
        end.
       end.

end.

run cur-time in this-procedure(output v-date, output v-time).

  if p-mode = {&add-def} then do:

  /*проверка по объекту */
    if p-type = {&type-assmatr-obj} then do:
    /* уникальность*/
    define buffer obj_matrix for ub.assortment-matrix.
    find first obj_matrix no-lock where
               obj_matrix.asmt-type = {&type-assmatr-obj} and
               obj_matrix.asmt-status  = 0 and
               obj_matrix.obj-type  = p-obj-type and
               obj_matrix.obj-code  = p-obj-code no-error .
     if available obj_matrix then do:
      message
         "Уже существует текущая Ассортиментная матрица для Объекта" skip
          p-obj-type  p-obj-code skip
          "Название: " obj_matrix.asmt-name skip
          view-as alert-box error.
      undo, return error .
     end.
    end.

    create ub.assortment-matrix.
    assign
    ub.assortment-matrix.asmt-id = next-value(s-asmt, {&db-name_schema})
    ub.assortment-matrix.asmt-date-create    = v-date
    ub.assortment-matrix.asmt-time-create    = v-time
    ub.assortment-matrix.asmt-db-num-create  = g#db-num
    ub.assortment-matrix.asmt-db-num-update  = g#db-num
    ub.assortment-matrix.asmt-who-create     = g#userid
    ub.assortment-matrix.db-num              = g#db-num
.

    p-doc-rec = recid(ub.assortment-matrix)
    .
  end.
  else do:
    FIND FIRST ub.assortment-matrix where
              recid(ub.assortment-matrix) = p-doc-rec No-ERROR.
    if not available ub.assortment-matrix then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись АМ - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.assortment-matrix.asmt-id <> p-asmt-id
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "внутренний код" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
  end.
  assign
    ub.assortment-matrix.asmt-name     = p-asmt-name
    ub.assortment-matrix.asmt-des      = p-des
    ub.assortment-matrix.asmt-type     = p-type
    ub.assortment-matrix.asmt-status   =  (if p-mode = {&add-def}
        then 0
        else ub.assortment-matrix.asmt-status )
    ub.assortment-matrix.obj-type = if p-type = {&type-assmatr-shablon} then "" else p-obj-type
    ub.assortment-matrix.obj-code = if p-type = {&type-assmatr-shablon} then 0  else p-obj-code
  .

define variable v-exist as logical   no-undo .
define variable v-delete as logical   no-undo .

  if p-rel = false  then do:
      run assmatat-delete (
        input ub.assortment-matrix.asmt-id
       ,input ub.assortment-matrix.db-num
       ,input {&assmatat-RootShablon}
       ,output v-delete
       ) no-error .
       if error-status :error then message
         vss-workfile vss-revision vss-description skip
         error-status :get-message(1) skip
         return-value skip
         "55"
         view-as alert-box error
       .
  end.
  else do:
    run assmatat-write (
       input ub.assortment-matrix.asmt-id
      ,input ub.assortment-matrix.db-num
      ,input {&assmatat-RootShablon}
      ,input p-rootshablon
      ) no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "66"
        view-as alert-box error
      .
  end.
end. /*doe*/



PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
      message
      p-mess
      view-as alert-box error .
END PROCEDURE.