/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Общие процедуры для импорта/экспорта TH-DKLink

Автор: Хныкин Павел Андреевич
Дата создания: 11/20/09
Author: Pavel Khnykin
Creation date: 11/20/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop thdl-prc_stock-map-value 100000
&scop thdl-prc_firm-map-value 1000000000

procedure thdl-prc_map-obj :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define output parameter p-code      as integer   no-undo .

  define buffer buf_store   for ub.store.
  define buffer buf_shop    for ub.shop.
  define buffer buf_clients for ub.clients.

do for
  buf_store
, buf_shop
, buf_clients
on error undo, return error return-value
:
  assign
    p-code = ?
  .
  case p-obj-type
  :
    when {&shop}
    then do:
      find first buf_shop no-lock
        where buf_shop.obj-code = p-obj-code
      no-error .
      if not available buf_shop
      then do:
        return error substitute( "Не найден магазин с кодом:&1":U , p-obj-code ) . /* --->>>--- */
      end.
      assign
        p-code = buf_shop.obj-code
      .
    end.
    when {&stock}
    then do:
      find first buf_store no-lock
        where buf_store.obj-code = p-obj-code
      no-error .
      if not available buf_store
      then do:
        return error substitute( "Не найден склад с кодом:&1":U , p-obj-code ) . /* --->>>--- */
      end.
      assign
        p-code = {&thdl-prc_stock-map-value} + buf_store.obj-code
      .
    end.
    when {&prs}
    then do:
      find first buf_clients no-lock
        where buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code
      no-error .
      if not available buf_clients
      then do:
        return error substitute( "Не найден контрагент &1 &2" , p-obj-type, p-obj-code ) . /* --->>>--- */
      end.
      assign
        p-code = buf_clients.obj-code
      .
    end.
    when {&cmp}
    then do:
      find first buf_clients no-lock
        where buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code
      no-error .
      if not available buf_clients
      then do:
        return error substitute( "Не найден контрагент &1 &2" , p-obj-type, p-obj-code ) . /* --->>>--- */
      end.
      assign
        p-code = {&thdl-prc_firm-map-value} + buf_clients.obj-code
      .
    end.
    otherwise do:
      return error substitute( "Недопустимый тип контрагента:&1":U , p-obj-type ). /* --->>>--- */
    end.
  end case.

end.

end procedure. /* thdl-prc_map-obj */

procedure thdl-prc_unmap-store :
  define input  parameter p-code      as integer   no-undo .
  define output parameter p-obj-type  as character no-undo .
  define output parameter p-obj-code  as integer   no-undo .

  define buffer buf_store   for ub.store.
  define buffer buf_shop    for ub.shop.

  define variable v-code as integer   no-undo .

do for
  buf_store
, buf_shop
on error undo, return error return-value
:
  assign
    p-obj-type = ?
    p-obj-code = ?
  .
  if p-code > {&thdl-prc_stock-map-value}
  then do : /* это склад */
    assign
      v-code = p-code - {&thdl-prc_stock-map-value}
    .
    find first buf_store no-lock
      where buf_store.obj-code = v-code
    no-error .
    if not available buf_store
    then do:
      return . /* --->>>--- */
    end.
    assign
      p-obj-type = {&stock}
      p-obj-code = buf_store.obj-code
    .
  end.
  else do: /* магазин */
    find first buf_shop no-lock
      where buf_shop.obj-code = p-code
    no-error .
    if not available buf_shop
    then do:
      return . /* --->>>--- */
    end.
    assign
      p-obj-type = {&shop}
      p-obj-code = buf_shop.obj-code
    .
  end.
end.

end procedure. /* thdl-prc_unmap-store */


procedure thdl-prc_unmap-agent :
  define input  parameter p-code      as integer   no-undo .
  define output parameter p-obj-type  as character no-undo .
  define output parameter p-obj-code  as integer   no-undo .

  define variable v-code as integer   no-undo .

  define buffer buf_clients for ub.clients.

do for
  buf_clients
on error undo, return error return-value
:
  assign
    p-obj-type = ?
    p-obj-code = ?
  .
  if p-code > {&thdl-prc_firm-map-value}
  then do: /* это фирма */
    assign
      v-code = p-code - {&thdl-prc_firm-map-value}
    .
    find first buf_clients no-lock
      where buf_clients.obj-type = {&cmp}
        and buf_clients.obj-code = v-code
    no-error .
    if not available buf_clients
    then do:
      return . /* --->>>--- */
    end.
    assign
      p-obj-type = {&cmp}
      p-obj-code = buf_clients.obj-code
    .
  end.
  else do: /* это человек */
    find first buf_clients no-lock
      where buf_clients.obj-type = {&prs}
        and buf_clients.obj-code = p-code
    no-error .
    if not available buf_clients
    then do:
      return . /* --->>>--- */
    end.
    assign
      p-obj-type = {&prs}
      p-obj-code = buf_clients.obj-code
    .
  end.
end.

end procedure. /* thdl-prc_unmap-agent */

/* $Workfile$ e n d */