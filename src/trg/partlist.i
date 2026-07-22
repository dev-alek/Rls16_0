/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список партий для резервировани

Автор: Чернова Светлана Александровна
Дата создания: 02/14/07
Author: Svetlana Chernova
Creation date: 02/14/07

create: Перваков Михаил Сергеевич
Дата создания: 11/24/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ Список партий для резервирования".

define variable v-partlist-use       as logical   no-undo .
define variable v-partlist-total-num as integer   no-undo .

define temp-table temp-part-list no-undo
  field ord-num   as integer
  field in-code   as character
  field part-code as character
  field qnty      as decimal

  index xpk is primary unique ord-num
  index ie1 in-code part-code
  .

procedure partlist_clear :

  define buffer buf_temp-part-list for temp-part-list .

  do
  on error undo, return error return-value
  :
    assign
      v-partlist-total-num = 0
    .
    for each buf_temp-part-list
    on error undo, return error return-value
    :
      delete buf_temp-part-list .
    end.
  end.

end procedure. /* partlist_clear */

procedure partlist_use-set :

  define input  parameter p-use as logical   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-partlist-use = p-use
    .
  end.

end procedure. /* partlist_set-use */

procedure partlist_use-get :

  define output parameter p-use as logical   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-use = v-partlist-use
    .
  end.

end procedure. /* partlist_use-get */

procedure partlist_append_part :

  define input  parameter p-in-code   as character no-undo .
  define input  parameter p-part-code as character no-undo .
  define input  parameter p-qnty      as decimal   no-undo .

  define buffer buf_temp-part-list for temp-part-list .

  do
  on error undo, return error return-value
  :
    assign
      v-partlist-total-num = v-partlist-total-num + 1
    .
    create buf_temp-part-list .
    assign
      buf_temp-part-list.ord-num   = v-partlist-total-num
      buf_temp-part-list.in-code   = p-in-code
      buf_temp-part-list.part-code = p-part-code
      buf_temp-part-list.qnty      = p-qnty
    .
  end.

end procedure. /* partlist_append_part */

procedure partlist_get-total-num :

  define output parameter p-total-num as integer   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-total-num = v-partlist-total-num
    .
  end.

end procedure. /* partlist_get-total-num */

procedure partlist_get-part-qnty :

  define input  parameter p-ord-num   as integer   no-undo .
  define output parameter p-in-code   as character no-undo .
  define output parameter p-part-code as character no-undo .
  define output parameter p-qnty      as decimal   no-undo .

  define buffer buf_temp-part-list for temp-part-list .

  do
  on error undo, return error return-value
  :
    find first buf_temp-part-list
      where buf_temp-part-list.ord-num = p-ord-num
      no-error .
    if not available buf_temp-part-list
    then do:
      undo, return error substitute("Не найдена партия с номером &1. Текущее количество партий &2"
                                   ,p-ord-num
                                   ,v-partlist-total-num
                                   )
        .
    end.
    assign
      p-in-code   = buf_temp-part-list.in-code
      p-part-code = buf_temp-part-list.part-code
      p-qnty      = buf_temp-part-list.qnty
    .
  end.

end procedure. /* partlist_get-part-qnty */

procedure partlist_check-part-qnty :

  define input  parameter p-in-code    as character no-undo .
  define input  parameter p-part-code  as character no-undo .
  define output parameter p-part-qnty  as decimal   no-undo .

  define buffer buf_temp-part-list for temp-part-list .

  do
  on error undo, return error return-value
  :
    find first buf_temp-part-list
      where buf_temp-part-list.in-code   = p-in-code
        and buf_temp-part-list.part-code = p-part-code
      no-error .
    if available buf_temp-part-list
    then do:
      assign
        p-part-qnty = buf_temp-part-list.qnty
      .
    end.
    else do:
      assign
        p-part-qnty = 0
      .
    end.
  end.

end procedure. /* partlist_check-part-qnty */


/* $Workfile$ e n d */