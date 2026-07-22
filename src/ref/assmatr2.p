block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: assmatr2.p $
$Archive: ref/assmatr2.p $

Изменение статуса ассортиментной матрицы

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/24/05
*/

define input parameter p-recid as recid no-undo.
define input-output parameter p-asmt-status like ub.assortment-matrix.asmt-status no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: assmatr2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/assmatr2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса ассортиментной матрицы".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE BUFFER bf-assortment-matrix for ub.assortment-matrix.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE v-old-asmt-status like ub.assortment-matrix.asmt-status no-undo .
define variable v-db-num as integer   no-undo .


_main:
do
on error undo, return error
:
define buffer old_assortment-matrix for ub.assortment-matrix  .

{ gbl/curdbnum.i v-db-num }

FIND FIRST bf-assortment-matrix WHERE
           recid(bf-assortment-matrix) = p-recid.

    define buffer x_curr_clients for ub.clients.
      find first  x_curr_clients no-lock where
                x_curr_clients.obj-type = bf-assortment-matrix.obj-type and
                x_curr_clients.obj-code = bf-assortment-matrix.obj-code no-error.
      if available x_curr_clients then do:
        /* своя БД для удаленки*/
          if v-db-num > 0 then do:
            if x_curr_clients.db-num <>  v-db-num then do:
                message
                "На УБД нельзя добавлять/корректировать Ассортиментные матрици по Объектам других БД" skip
                    x_curr_clients.obj-type x_curr_clients.obj-code skip
                    "БД : " x_curr_clients.db-num
                    view-as alert-box error.
                undo, return error .
            end.
          end.
      end.



v-old-asmt-status = bf-assortment-matrix.asmt-status.
if p-asmt-status = ? then do:
  CASE v-old-asmt-status:
    when integer({&current-status-int}) then do:
      assign
      p-asmt-status = integer({&deleted-status-int}).
    end.
    when integer({&deleted-status-int}) then do:
      if bf-assortment-matrix.obj-type <> "" then do:
          find first old_assortment-matrix no-lock where
                      old_assortment-matrix.asmt-status = integer({&current-status-int}) and
                      old_assortment-matrix.obj-type    = bf-assortment-matrix.obj-type and
                      old_assortment-matrix.obj-code    = bf-assortment-matrix.obj-code and
                     not ( old_assortment-matrix.asmt-id   = bf-assortment-matrix.asmt-id and
                           old_assortment-matrix.db-num     = bf-assortment-matrix.db-num ) no-error .
          if not available old_assortment-matrix then
          assign
          p-asmt-status = integer({&current-status-int}).
          else do:
              message "Уже есть матрица в статусе ТЕКУЩИЙ по объекту !"
              bf-assortment-matrix.obj-type
              bf-assortment-matrix.obj-code
              view-as alert-box ERROR.
              p-asmt-status = ?.
              return error.
          end.
      end.
      else do: /* шаблон */
          assign
          p-asmt-status = integer({&current-status-int}).
      end.
    end.
  END CASE.
end.

CASE p-asmt-status:
  WHEN integer({&current-status-int}) then do:
    if integer({&current-status-int}) = bf-assortment-matrix.asmt-status  then do:
      message "Запись уже имеет статус ТЕКУЩИЙ!"
      view-as alert-box ERROR.
      p-asmt-status = ?.
      return error.
    end.
    else do:
      if v-db-num <> 0 then do:
          message
          "Восстановить матрицу можно только в ГБД"
          view-as alert-box information .
          choice = false .
      end.
      else do:
        message
        "Матрица уже удалена - восстановить?"
        view-as alert-box QUestion buttons YEs-no update choice.
      end.
    end.
  end.
  WHEN integer({&deleted-status-int}) then do:
    if integer({&deleted-status-int}) = bf-assortment-matrix.asmt-status  then do:
      message "Запись уже имеет статус УДАЛЕН!"
      view-as alert-box ERROR.
      p-asmt-status = ?.
      return error.
    end.
    else do:
      message
      "Удалить Ассортиментную матрицу?"
      view-as alert-box QUestion buttons yes-no update choice.
    end.
  end.
END CASE.
if choice = false  then do:
   release bf-assortment-matrix no-error .
   return .
end.
if choice then
assign
bf-assortment-matrix.asmt-status = p-asmt-status.
release bf-assortment-matrix no-error .
if error-status:error then do:
  message
  "Ошибка при сохранении записи Ассортиментной Матрицы" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo _main, return error .
end.
define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods  .
define buffer buf_gds-obj-prop for ub.gds-obj-prop  .

FIND FIRST bf-assortment-matrix no-lock WHERE
          recid(bf-assortment-matrix) = p-recid.

if p-asmt-status = integer({&deleted-status-int}) and
   bf-assortment-matrix.asmt-type = {&type-assmatr-obj} then do:

   choice = false .
   message
   "Изменить ИЖТ всех товаров удаленной Ассортиментной матрицы на ПУСТО ?"
   view-as alert-box QUestion buttons yes-no update choice.
   if choice then do:
      FIND FIRST bf-assortment-matrix exclusive-lock WHERE
                recid(bf-assortment-matrix) = p-recid.

      for each buf_assortment-matrix-goods exclusive-lock where
               buf_assortment-matrix-goods.asmt-id = bf-assortment-matrix.asmt-id and
               buf_assortment-matrix-goods.db-num  = bf-assortment-matrix.db-num
               :
               for each buf_gds-obj-prop exclusive-lock where
                        buf_gds-obj-prop.gds-code = buf_assortment-matrix-goods.gds-code and
                        buf_gds-obj-prop.obj-type = bf-assortment-matrix.obj-type and
                        buf_gds-obj-prop.obj-code = bf-assortment-matrix.obj-code :
                        buf_gds-obj-prop.gdop-igt = {&ass-izd-empty} .
               end.
      end.
   end.

end.

p-asmt-status = ?.
end.