/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр карточки товара

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
1 - имя 1-го (единственного) browse - обязательный
2 - имя внутренней процедуры с одним output-параметром - recid( goods )
3 - Имя переменной mainmenu-handle

*/

&if "{3}" = "" &then
  &scop mainmenu-handle parparentproc
&else
  &scop mainmenu-handle ~{3~}
&endif

define variable v-f2gds-goods-recid    as recid        no-undo.

run {2} (
    output v-f2gds-goods-recid
).
if v-f2gds-goods-recid = ?
then do:
    return no-apply.
end.
else do:
    run ref/gds-form.w (
          input {&mainmenu-handle}
        , input {&lookup}
        , input ?
        , input ?
        , input ? /*p-call-handle*/
        , input-output v-f2gds-goods-recid
    ).
  apply "entry" to {1} in frame {&frame-name}.
  return no-apply.
end.
/* $Workfile$ e n d */