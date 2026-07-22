/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура обеспечения уникальности имен одноуровневых узлов классификатора

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

*/
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/waitfram.i }

define variable tot-grp as integer no-undo.
define variable upd-grp as integer no-undo.
define variable v-curr-db-num like ub.db.db-num no-undo .
define variable glog as logical no-undo .

{ gbl/curdbnum.i v-curr-db-num }
if v-curr-db-num <> 0 then do:
   message "Можно запускать только в центральной базе" view-as alert-box.
   return.
end.
glog = no.
message
"Проверка и обеспечение уникальности имен одноуровневых узлов классификатора путем подстановки точек." skip (2)
"Работает при больших классификаторов ОЧЕНЬ долго." skip (2)
"Продолжать ?" view-as alert-box question buttons OK-Cancel update glog.
if not glog then return.

run waitfram-show in this-procedure ("ЖДИТЕ. Обеспечение уникальности классификатора ...").
run uniq-grp (0, 0).
run waitfram-hide in this-procedure .



PROCEDURE uniq-grp.
def input param c like ub.{1}.upper-code.
def input param ln like ub.{1}.lvl-num.
def buffer b-{1} for ub.{1}.

for each b-{1} where b-{1}.upper-code = c:
  find first ub.{1} where ub.{1}.upper-code = c and
                                ub.{1}.node-name begins b-{1}.node-name
                                and recid(ub.{1}) <> recid(b-{1})
                                no-lock no-error.
  if available ub.{1} then
    assign
      b-{1}.node-name = b-{1}.node-name + "."
      upd-grp = upd-grp + 1.
  run uniq-grp (b-{1}.node-code, ln + 1).
  tot-grp = tot-grp + 1.
  if tot-grp modulo 10 = 0 then
  run waitfram-show in this-procedure ("Уникальность кл-ра ...  Просмотрено: " + string (tot-grp) + "  Исправлено: " + string (upd-grp)).
end.
END PROCEDURE.

/* $Workfile$ e n d */