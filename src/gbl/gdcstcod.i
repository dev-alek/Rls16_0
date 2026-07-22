/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает информацию о ГТД

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/20/04

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure gdcstcod_cst-code :

  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-gds-code  as integer   no-undo .
  define input  parameter p-in-code   as character no-undo .
  define input  parameter p-part-code as character no-undo .
  define output parameter p-cst-code  as character no-undo .


  define buffer buf_goods for ub.goods .
  define buffer buf_parts for ub.parts .

  do
  on error undo, return error return-value
  :
    assign
      p-cst-code = ''
    .


    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      undo, return error substitute("Ошибка задания входных параметров. Не найден товар &1", p-gds-code) .
    end.

    if p-in-code = ?
    then do:
      undo, return error substitute("Ошибка задания входных параметров. Неизвестное значение номера накладной &1", p-in-code) .
    end.

    if p-part-code = ?
    then do:
      undo, return error substitute("Ошибка задания входных параметров. Неизвестное значение номера номера партии &1", p-part-code) .
    end.


    if p-in-code = '':u
    then do:
      find first buf_parts no-lock
        where buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = buf_goods.artic
          and buf_parts.prod-type = buf_goods.prod-type
          and buf_parts.prod-code = buf_goods.prod-code
          and buf_parts.out-code  = {&free-code}
          and buf_parts.status_   = false
        no-error .
      if available buf_parts
      then do:
        assign
          p-cst-code = buf_parts.cst-code
        .
      end.
    end.
    else do:
      find first buf_parts no-lock
        where buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = buf_goods.artic
          and buf_parts.prod-type = buf_goods.prod-type
          and buf_parts.prod-code = buf_goods.prod-code
          and buf_parts.out-code  = {&free-code}
          and buf_parts.in-code   = p-in-code
          and buf_parts.part-code = p-part-code
        no-error .
      if available buf_parts
      then do:
        assign
          p-cst-code = buf_parts.cst-code
        .
      end.
    end.
  end.

end procedure. /* gdcstcod_cst-code */


/* $Workfile$ e n d */