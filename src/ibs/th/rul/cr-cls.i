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
assign
v_pp = parparentproc
v_lh = p-log-handle
v_ph = p-parent-handle
v_gc = p-gc-handle
v_cnt = p-cont-handle
lock = p-lock
wait = p-wait
temp = p-temp
.
run garbcoll_create-gc-entry in p-gc-handle (input '{1}',  input this-object) no-error.
if error-status:error then do:
  return error substitute("&1 Ошибка создания объекта {1}", vss-include-info{&vssseq}).
end.
/*считаем что у нас в режиме temp НЕ МОГУТ БЫТЬ ПРАВИЛА, которым потребу.тся исходные данные из контейнера временных таблиц*/
v_bh = buffer buf_{1}:handle.
v_tbh = buffer buft_{1}:handle.


/* $Workfile$ e n d */