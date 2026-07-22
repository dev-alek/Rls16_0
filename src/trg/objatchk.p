block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка того, что можно изменить признак объекта

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

*/

define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-action    as character no-undo .
define input parameter p-new-value as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка того, что можно изменить признак объекта".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block:
do
on error undo main-block, return error
:
  define buffer buf_clients for ub.clients .
  define buffer buf_db for ub.db .

  if p-new-value = ? then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение параметра p-new-value" skip
      "Объект" p-obj-type p-obj-code skip
      view-as alert-box error .
    undo, return error .
  end.

  case p-action :
    when "doc-prt":u then do:
      if p-new-value = false then do:
        message
          "Включенные шкалы не выключаются" skip
          "Объект" p-obj-type p-obj-code skip
          view-as alert-box information .
        undo, return error.
      end.

      if p-new-value = true then do:
        if can-find( first ub.trn-doc
          where ub.trn-doc.obj-type = p-obj-type
            and ub.trn-doc.obj-code = p-obj-code
            and ub.trn-doc.status_  <> {&fact}
        ) then do:
          message
            "На объекте имеются незакрытые документы"
            "Объект" p-obj-type p-obj-code skip
            view-as alert-box information .
          undo, return error.
        end.
      end.
    end.
    when "shift-on":u then do:
      find first buf_clients share-lock
        where buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code
        .
      find first buf_db no-lock
        where buf_db.db-num = buf_clients.db-num
        .

      if p-new-value = false then do:
        if can-find( first ub.trn-doc
          where ub.trn-doc.obj-type = p-obj-type
            and ub.trn-doc.obj-code = p-obj-code
        )
        or can-find( first ub.price-doc
          where ub.price-doc.obj-type = p-obj-type
            and ub.price-doc.obj-code = p-obj-code
        )
        or can-find( first ub.rvs-doc
          where ub.rvs-doc.obj-type = p-obj-type
            and ub.rvs-doc.obj-code = p-obj-code
        )
        or can-find( first ub.shift-obj
          where ub.shift-obj.obj-type = p-obj-type
            and ub.shift-obj.obj-code = p-obj-code
        )
        then do:
          message
            "На объекте существуют документы и/или смены" skip
            "Включенные смены нельзя выключить" skip
            "Объект" p-obj-type p-obj-code skip
            view-as alert-box information .
          undo, return error.
        end.
      end.
      else do: /* p-new-value = true */
        if p-obj-type = {&stock} then do:
          message
            "Для склада нельзя включить сменную работу" skip
            "Объект" p-obj-type p-obj-code skip
            view-as alert-box information .
          undo, return error.
        end.

        if p-obj-type = {&shop} then do:
          for each ub.cash-desk no-lock
            where ub.cash-desk.obj-code = p-obj-code
              and ub.cash-desk.db-num   = buf_db.db-num
          :
              if ub.cash-desk.pos-type <> {&cd-type-ibm}
              and ub.cash-desk.pos-type <> {&cd-type-ibm-xml}
              and ub.cash-desk.pos-type <> {&cd-type-maria} then do:
              message
                "У магазина имеются кассы с типом, отличным от IBM" skip
                "Нельзя включить сменную работу для магазина" skip
                "Объект" p-obj-type p-obj-code skip
                view-as alert-box error .
              undo, return error .
            end.
          end.
        end.

        if can-find( first ub.trn-doc
          where ub.trn-doc.obj-type = p-obj-type
            and ub.trn-doc.obj-code = p-obj-code
        ) then do:
          message
            "Нельзя включить сменную работу" skip
            "На объекте имеются складские документы" skip
            "Объект" p-obj-type p-obj-code skip
            view-as alert-box information .
          undo, return error.
        end.
        if can-find( first ub.price-doc
          where ub.price-doc.obj-type = p-obj-type
            and ub.price-doc.obj-code = p-obj-code
        ) then do:
          message
            "Нельзя включить сменную работу" skip
            "На объекте имеются документы переоценки" skip
            "Объект" p-obj-type p-obj-code skip
            view-as alert-box information .
          undo, return error.
        end.
        if can-find( first ub.rvs-doc
          where ub.rvs-doc.obj-type = p-obj-type
            and ub.rvs-doc.obj-code = p-obj-code
        ) then do:
          message
            "Нельзя включить сменную работу" skip
            "На объекте имеются документы сверки" skip
            "Объект" p-obj-type p-obj-code skip
            view-as alert-box information .
          undo, return error.
        end.
      end.

      if buf_db.db-num > 0
        and trim( buf_db.db-key ) <> "":U
        and buf_db.db-key <> ?
      then do:
          message
            substitute( "Нельзя &1 сменную работу", (if p-new-value = true then "включать" else "выключать") )  skip
            "УБД уже существует и возможно на объекте уже созданы документы" skip
            substitute( "Объект &1 &2 для БД &3", p-obj-type, p-obj-code, buf_db.db-num ) skip
            view-as alert-box information .
          undo, return error.
      end.

    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестное значение p-action" skip
        "Объект" p-obj-type p-obj-code skip
        "p-action" p-action skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end.