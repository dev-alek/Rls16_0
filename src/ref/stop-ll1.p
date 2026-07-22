block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: stop-ll1.p $
$Archive: ref/stop-ll1.p $

Добавление изменение строки стоплиста по ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/22/08
Author: Bakhtadze Natalya
Creation date: 01/22/08

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter p-stop-list-code as character no-undo .
define input parameter p-d-card as character no-undo .
define input parameter p-flag as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: stop-ll1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/stop-ll1.p $":U .
define variable vss-description as character no-undo init "Добавление изменение строки стоплиста по ДК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/key-rec.i }

define variable v-mess as character no-undo .
define variable v-card-resource-id as character no-undo .
define variable v-client-resource-id as character no-undo .
define variable v-line-num as integer no-undo .
define buffer buf_stop-list for ub.stop-list.
define buffer buf_stop-list-line for ub.stop-list-line.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_clients for ub.clients.

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.

if g#db-num <> 0 then do:
  message vss-workfile vss-revision vss-description skip
          "Запрещено вызывать процедуру в УБД"
  view-as alert-box error .
  return error '':u.
end.

_main:
do for buf_stop-list-line
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_stop-list exclusive-lock where
         buf_stop-list.stop-list-code =  p-stop-list-code
     and buf_stop-list.classif-type =  {&table_dis-card}
         no-error.
  if not available buf_stop-list then do:
    assign
    v-mess = substitute("Не найден стоплист с номером &1", p-stop-list-code).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  if lookup(string(p-flag), {&stop-status-codes}) = 0 then do:
    assign
    v-mess = substitute("Неверное значение статуса строки стоплиста = &1", p-flag).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  if p-mode = {&add-def} then do:
    find first buf_Dis-card share-lock where
              buf_dis-card.d-card = p-d-card  no-error.
    if not available buf_dis-card then do:
      assign
      v-mess = substitute("Нет карты с номером &1", p-d-card).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if buf_dis-card.mask-card then do:
      assign
      v-mess = substitute("Карты-маски нельзя добавлять в стоплисты").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    find first buf_clients no-lock where
              buf_clients.obj-type = buf_Dis-card.cli-type
          and buf_clients.obj-code = buf_Dis-card.cli-code no-error .
    if not available buf_Clients then do:
      assign
      v-mess = substitute("Нет клиента-держателя ДК &1 &2&3"
                         ,p-d-card
                         ,buf_Dis-card.cli-type
                         ,buf_Dis-card.cli-code
                         ).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    run gen-key-rec in this-procedure ( input {&table_dis-card}
                                        ,input (buffer buf_dis-card:handle)
                                        ,output v-card-resource-id).
    run gen-key-rec in this-procedure ( input {&table_clients}
                                        ,input (buffer buf_clients:handle)
                                        ,output v-client-resource-id).

    find first buf_stop-list-line no-lock where
              buf_stop-list-line.stop-list-code = buf_stop-list.stop-list-code
          and buf_stop-list-line.classif-type = {&table_dis-card}
          and buf_stop-list-line.resource_id = v-card-resource-id
          no-error.
    if available buf_stop-list-line then do:
      assign
      v-mess = substitute("Такая строка стоплиста уже существует").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    find first buf_stop-list-line no-lock where
              buf_stop-list-line.stop-list-code = buf_stop-list.stop-list-code
          and buf_stop-list-line.classif-type = {&table_dis-card}
          and buf_stop-list-line.resource_id = v-client-resource-id
          and buf_stop-list-line.charkey_one = buf_Dis-card.d-card
          no-error.
    if available buf_stop-list-line then do:
      assign
      v-mess = substitute("Такая строка стоплиста уже существует").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.


&scop stop-status-code string(p-flag)
    find last buf_stop-list-line no-lock where
            buf_stop-list-line.stop-list-code = buf_stop-list.stop-list-code
        and buf_stop-list-line.classif-type = {&table_dis-card} use-index pi no-error.
    if available buf_stop-list-line then do:
      v-line-num = buf_stop-list-line.line-num.
    end.
    create buf_stop-list-line.
    assign
    buf_stop-list-line.charkey_one = p-d-card
    buf_stop-list-line.stop-list-code = buf_stop-list.stop-list-code
    buf_stop-list-line.classif-type = {&table_dis-card}
    buf_stop-list-line.key#_one = p-flag
    buf_stop-list-line.line-message = {&stop-status-name}
    buf_stop-list-line.resource_id = (if p-flag = integer({&stop-card})
                                      then v-card-resource-id
                                      else v-client-resource-id)
    buf_stop-list-line.line-num = v-line-num + 1
    .
  end.
  if p-mode = {&update} then do:
    if p-rec <> ? then do:
      find first buf_stop-list-line exclusive-lock where
              recid(buf_stop-list-line) = p-rec no-error.
    end.
    find first buf_Dis-card share-lock where
              buf_dis-card.d-card = buf_stop-list-line.charkey_one  no-error.
    if not available buf_dis-card then do:
      assign
      v-mess = substitute("Нет карты с номером &1", p-d-card).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    find first buf_clients no-lock where
              buf_clients.obj-type = buf_Dis-card.cli-type
          and buf_clients.obj-code = buf_Dis-card.cli-code no-error .
    if not available buf_Clients then do:
      assign
      v-mess = substitute("Нет клиента-держателя ДК &1 &2&3"
                         ,p-d-card
                         ,buf_Dis-card.cli-type
                         ,buf_Dis-card.cli-code
                         ).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if buf_dis-card.mask-card then do:
      assign
      v-mess = substitute("Карты-маски нельзя добавлять в стоплисты").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if buf_stop-list-line.key#_one = integer({&stop-card}) then do:
      run gen-key-rec in this-procedure ( input {&table_dis-card}
                                          ,input (buffer buf_dis-card:handle)
                                          ,output v-card-resource-id).
    end.
    else do:
      run gen-key-rec in this-procedure ( input {&table_clients}
                                          ,input (buffer buf_clients:handle)
                                          ,output v-client-resource-id).
    end.
    if available buf_stop-list-line then do:
      if buf_stop-list-line.stop-list-code <> p-stop-list-code
      or buf_stop-list-line.charkey_one <> p-d-card
      then do:
        assign
        v-mess = substitute("Нельзя менять номер стоплиста или номер карты для уже существующей строки стоплиста").
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
    if not available buf_stop-list-line then do:
      find first buf_stop-list-line exclusive-lock where
                buf_stop-list-line.stop-list-code = buf_stop-list.stop-list-code
            and buf_stop-list-line.classif-type = {&table_dis-card}
            and (buf_stop-list-line.resource_id = v-card-resource-id
                 or
                 buf_stop-list-line.resource_id = v-client-resource-id )  no-error.
     if not available buf_stop-list-line then do:
        assign
        v-mess = substitute("Не такой строки стоплиста").
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
    assign
    buf_stop-list-line.key#_one = p-flag
    buf_stop-list-line.line-message = {&stop-status-name}
    buf_stop-list-line.resource_id = ( if p-flag = integer({&stop-card})
                                       then v-card-resource-id
                                       else v-client-resource-id)
    .
  end.
  p-rec = recid(buf_stop-list-line).
  release buf_stop-list-line no-error.
  if error-status:error then do:
    assign
    v-mess = substitute("Ошибка при сохранении строки стоплиста").
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
end.

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  assign
  p-mess = substitute("Строка стоплиста: стоплист &1, карта &2&3"
                      , p-stop-list-code
                      , p-d-card
                      , {&new-line}
                      , p-mess)
  .
  CASE p-silent:
    when yes then do:
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.