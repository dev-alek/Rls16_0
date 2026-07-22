/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сканирует все объекты и фирмы, помещает их во временные таблицы.

Автор: Суслов Алексей Юрьевич
Дата создания: 12/25/07
Author: Alexey Suslov
Creation date: 12/25/07

Удобно в случаях, когда необходимо отобрать все объекты, относящиеся к определенной фирме

Пример использования:

{ gbl/temphsts.i }
run init-temphost .

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {&share-options} temp-table temp-host no-undo
  field host-code like ub.store.host-code

  index xpk host-code
.

define {&share-options} temp-table temp-obj no-undo
  field obj-type  like ub.clients.obj-type
  field obj-code  like ub.clients.obj-code
  field host-code like ub.store.host-code
  field db-num    like ub.clients.db-num

  index xpk  obj-type obj-code
  index xie1 host-code
  index xie2 db-num host-code
.

procedure init-temphost:

  define buffer buf_store   for ub.store .
  define buffer buf_shop    for ub.shop .
  define buffer buf_clients for ub.clients .
  define buffer buf_db for ub.db .

  define buffer buf_temp-host for temp-host .
  define buffer buf_temp-obj for temp-obj .

  do
  on error undo, return error return-value
  :
    for each buf_store
    on error undo, return error
    :
      find first buf_clients no-lock
        where buf_clients.obj-type = {&stock}
          and buf_clients.obj-code = buf_store.obj-code
        no-error .
      if not available buf_clients
      then do:
        message
          "Ошибка при поиске клиента" skip
          "Клиент" {&stock} buf_store.obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      if buf_clients.stts <> 0 then next.
      find first buf_temp-host
        where buf_temp-host.host-code = buf_store.host-code
        no-error .
      if not available buf_temp-host
      then do:
        create buf_temp-host .
        assign
          buf_temp-host.host-code = buf_store.host-code
        .
      end.


      create buf_temp-obj .
      assign
        buf_temp-obj.obj-type  = {&stock}
        buf_temp-obj.obj-code  = buf_store.obj-code
        buf_temp-obj.host-code = buf_store.host-code
        buf_temp-obj.db-num    = buf_clients.db-num
      .
    end.

    for each buf_shop
    on error undo, return error
    :
      find first buf_clients no-lock
        where buf_clients.obj-type = {&shop}
          and buf_clients.obj-code = buf_shop.obj-code
        no-error .
      if not available buf_clients then do:
        message
          "Ошибка при поиске клиента" skip
          "Клиент" {&shop} buf_shop.obj-code skip
          view-as alert-box error .
        undo, return error .
      end.

      if buf_clients.stts <> 0 then next.
      find first buf_temp-host
        where buf_temp-host.host-code = buf_shop.host-code
        no-error .

      if not available buf_temp-host
      then do:
        create buf_temp-host .
        assign
          buf_temp-host.host-code = buf_shop.host-code
        .
      end.
      create buf_temp-obj .
      assign
        buf_temp-obj.obj-type  = {&shop}
        buf_temp-obj.obj-code  = buf_shop.obj-code
        buf_temp-obj.host-code = buf_shop.host-code
        buf_temp-obj.db-num    = buf_clients.db-num
      .
    end.
  end.
end.

/* $File: temphost.i $ e n d */