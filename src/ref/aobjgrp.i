/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Метод формирования списка объектов в статусе ТЕК по всем группы .

Автор: Чернова Светлана Александровна
Дата создания: 12/20/05
Author: Svetlana Chernova
Creation date: 12/20/05

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
{ cmp/str-glbl.i }

define temp-table x_obj-grp-obj-price no-undo like ub.obj-grp-obj-price .
procedure metod-gop-obj-all :
define input  parameter p-curr-db-num as integer   no-undo . /**/
  do
  on error undo, return error return-value
  :
 empty temp-table x_obj-group .
 empty temp-table x_obj-grp-obj-price .
 define buffer buf_grp-obj-price for ub.grp-obj-price  .

 for each buf_grp-obj-price no-lock where
          buf_grp-obj-price.stts = 0 :
      run metod-gop-obj in this-procedure (
          input  p-curr-db-num ,
          input  buf_grp-obj-price.gop-id       ,
          input  buf_grp-obj-price.gop-db-num   ).
          for each x_obj-group :
             create x_obj-grp-obj-price.
             buffer-copy buf_grp-obj-price to x_obj-grp-obj-price
             assign
                x_obj-grp-obj-price.obj-type = x_obj-group.obj-type
                x_obj-grp-obj-price.obj-code = x_obj-group.obj-code
             .
          end.
 end.
  end.

end procedure. /* metod-gop-obj-all */