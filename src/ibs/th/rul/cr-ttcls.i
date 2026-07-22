/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/12/07
Author: Bakhtadze Natalya
Creation date: 03/12/07

{1} - имя класса без кавычек
{2} - имя таблицы в виде {&table_dis-host}
{3}

*/

define variable glog as logical no-undo .
define variable tt-name as character no-undo .
assign
v_ph = p-parent-handle
v_gc = p-gc-handle
lock = p-lock
wait = p-wait
temp = p-temp
.
run garbcoll_create-gc-entry in p-gc-handle (input '{1}',  input this-object) no-error.
if error-status:error then do:
  return error substitute("&1 Ошибка создания объекта {1}", vss-include-info{&vssseq}).
end.
v_bh = buffer buf_{1}:handle.
create temp-table tth.
assign
tt-name = "tt_{1}"
tth:undo = no
.
glog = yes.
assign
glog = tth:create-like({2}) no-error
.
if glog <> true then do:
  return error substitute( "&1. Ошибка при создании временной таблицы &2 (1)", vss-include-info{&vssseq}, tt-name ) .
end.
glog = yes.
assign
glog = tth:temp-table-prepare( tt-name ) no-error
.
if glog <> true then do:
  return error substitute( "&1. Ошибка при создании временной таблицы &2 (2)", vss-include-info{&vssseq}, tt-name ) .
end.

assign
v_tbh = tth:default-buffer-handle
.
assign
glog = v_tbh:buffer-create no-error
.
if glog <> true then do:
  return error substitute( "&1. Ошибка при создании буфера временной таблицы.", vss-include-info{&vssseq}).
end.


/* $Workfile$ e n d */