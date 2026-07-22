block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Передача информации об остатках в УБД

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 03/26/02

Входные параметры:
p-trn-doc = true
p-doc-code = Код складского документа

p-trn-doc = false
p-doc-code = Код переоценки

*/


define input  parameter p-trn-doc    as logical   no-undo .
define input  parameter p-doc-code   as character no-undo .
define input  parameter p-delete-doc as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Передача информации об остатках в УБД".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-trn-doc,p-doc-code,p-delete-doc)" }
{ cmp/trg-def.i  }

define buffer buf_trn-doc    for ub.trn-doc .
define buffer buf_price-doc  for ub.price-doc .
define buffer buf_clients    for ub.clients .
define buffer buf_db         for ub.db .
define buffer buf_doc-line   for ub.doc-line .
define buffer buf_prt-obj    for ub.prt-obj .
define buffer buf_price-list for ub.price-list .

define variable v-obj-type  like ub.clients.obj-type no-undo .
define variable v-obj-code  like ub.clients.obj-code no-undo .

do
on error undo, return error return-value
:
  if p-trn-doc = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "p-trn-doc" p-trn-doc skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error .
  end.

  if p-trn-doc = true
  then do:
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден складской документ" skip
        "p-trn-doc" p-trn-doc skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.

    define variable v-need-send-prt-obj-not-fact as logical   no-undo .
    define variable v-parameter-value            as character no-undo .
    define variable v-parameter-type             as character no-undo .

    assign
      v-need-send-prt-obj-not-fact = false
    .

    { gbl/conf-rd.i
      "'remorsrv':U"
      0
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      false
      v-parameter-value
      v-parameter-type
      no-error
    }
    if error-status :error
    then do:
      /* параметр может быть не задан */
    end.
    else do:
      if  v-parameter-value = 'all':u
      and g#db-num = 0
      then do:
        assign
          v-need-send-prt-obj-not-fact = true
        .
      end.
    end.

    if ( v-need-send-prt-obj-not-fact = true
         and p-delete-doc = true
       )
    or ( v-need-send-prt-obj-not-fact = true
         and buf_trn-doc.status_ = {&wayb}
         and buf_trn-doc.flag_ = true
       )
    or ( v-need-send-prt-obj-not-fact = true
         and buf_trn-doc.status_ = {&permitted}
         and buf_trn-doc.flag_ = true
       )
    or ( v-need-send-prt-obj-not-fact = true
         and buf_trn-doc.status_ = {&ready}
       )
    or ( v-need-send-prt-obj-not-fact = true
         and buf_trn-doc.status_ = {&rejected}
        )
    or (buf_trn-doc.status_ = {&fact})
    then do:
      /* надо передать информацию об количестве по признакам в УБД */
    end.
    else do:
      return .
    end.

    assign
      v-obj-type  = buf_trn-doc.obj-type
      v-obj-code  = buf_trn-doc.obj-code
    .
  end.

  if p-trn-doc = false
  then do:
    find first buf_price-doc no-lock
      where buf_price-doc.doc-num = p-doc-code
      no-error .
    if not available buf_price-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена переоценка" skip
        "p-trn-doc" p-trn-doc skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.

    if buf_price-doc.status_ <> {&act-overvalue}
    then do:
      return .
    end.

    assign
      v-obj-type  = buf_price-doc.obj-type
      v-obj-code  = buf_price-doc.obj-code
    .
  end.

  find first buf_clients no-lock
    where buf_clients.obj-type = v-obj-type
      and buf_clients.obj-code = v-obj-code
    .

  /* информация передается только при закрытии накладной по факту */

  /* информация prt-obj маршрутизируется только при закрытии документов
    в главной базе данных (ГБД)
    и только для документов из удаленной базы данных
    */
  if g#db-num = 0
  then do:
    /* Проверяем, что необходимо передавать информацию об остатках товара
      хотя бы в одну удаленную базу данных
    */
    define variable list-remote-db as character no-undo .
    assign
      list-remote-db = ""
    .

    for each buf_db no-lock
      where buf_db.remote-stock = yes
        and buf_db.db-num    <> g#db-num
        and buf_db.db-num    <> buf_clients.db-num
        and buf_db.db-num    <> 0
    on error undo, return error return-value
    :
      assign
        list-remote-db = list-remote-db
                       + (if list-remote-db <> "" then {&delim-nws} else "")
                       + string(buf_db.db-num)
      .
    end.

    if list-remote-db <> ""
    then do:
      if p-trn-doc = true
      then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = p-doc-code
        on error undo, return error
        :
          for each buf_prt-obj no-lock
            where buf_prt-obj.obj-type  = buf_doc-line.obj-type
              and buf_prt-obj.obj-code  = buf_doc-line.obj-code
              and buf_prt-obj.artic     = buf_doc-line.artic
              and buf_prt-obj.prod-type = buf_doc-line.prod-type
              and buf_prt-obj.prod-code = buf_doc-line.prod-code
          on error undo, return error
          :
            run nws/cr-route.p
              (input {&send-tbl}                 /* act-name   */
              ,input {&table_prt-obj}            /* tbl-name   */
              ,input (buffer buf_prt-obj:handle) /* tbl-handle */
              ,input list-remote-db              /* lst-db-num */
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при отправке остатков по товару в новости" skip
                "Документ" p-doc-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
          end.
        end.
      end.
      else do:
        for each buf_price-list no-lock
          where buf_price-list.doc-num    = p-doc-code
            and buf_price-list.main-price = true
        on error undo, return error
        :
          for each buf_prt-obj no-lock
            where buf_prt-obj.obj-type  = buf_price-list.obj-type
              and buf_prt-obj.obj-code  = buf_price-list.obj-code
              and buf_prt-obj.artic     = buf_price-list.artic
              and buf_prt-obj.prod-type = buf_price-list.prod-type
              and buf_prt-obj.prod-code = buf_price-list.prod-code
          on error undo, return error
          :
            run nws/cr-route.p
              (input {&send-tbl}                 /* act-name   */
              ,input {&table_prt-obj}            /* tbl-name   */
              ,input (buffer buf_prt-obj:handle) /* tbl-handle */
              ,input list-remote-db              /* lst-db-num */
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при отправке остатков по товару в новости" skip
                "Документ" p-doc-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
          end.
        end.
      end.
    end.
  end.
end.