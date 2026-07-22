/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание атрибутов с объектами-исключениями из ДНЦ

Автор: Чернова Светлана Александровна
Дата создания: 04/24/09
Author: Svetlana Chernova
Creation date: 04/24/09


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ ref/xobjgrp.i  }  /* список объектов  */
{ str/pdf-attr.i }
procedure make-attr-objexcl :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .

define buffer buf_x_obj-group for x_obj-group  .

  do
  on error undo, return error return-value
  :
      for each  buf_x_obj-group no-lock where not (
                buf_x_obj-group.obj-code = p-obj-code and
                buf_x_obj-group.obj-type = p-obj-type  ) :
      run ins-pdf-attr-objdel (
          p-pdf-id ,
          p-pdf-db-num ,
          p-plt-id     ,
          p-plt-db-num ,
          buf_x_obj-group.obj-type ,
          buf_x_obj-group.obj-code
          ) .
       end.
  end.

end procedure. /* make-attr-objexcl */