/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами Ассортиментной Матрицы

Автор: Чернова Светлана Александровна
Дата создания: 07/07/09
Author: Svetlana Chernova
Creation date: 07/07/09

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined (include_attr-lib) = 0 &then
{ gbl/attr-lib.i }
&endif

procedure assmatat-code :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-type           as character no-undo . /* тип атрибута */
  define output parameter p-format         as character no-undo . /* формат атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */

  do
  on error undo, return error
  :
    &scop proc-name assmatat-code
    {&run_proc_attr-lib}
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.

procedure assmatat-tooltip :

  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .

  do
  on error undo, return error
  :
    &scop proc-name assmatat-tooltip
    {&run_proc_attr-lib}
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure assmatat-value :

  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-value     like ub.assortment-matrix-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .

  do
  on error undo, return error
  :
    &scop proc-name assmatat-value
    {&run_proc_attr-lib}
      (input  p-asmt-id
      ,input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure assmatat-write :

  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define input parameter p-value     like ub.assortment-matrix-attr.attr-value no-undo .

  do
  on error undo, return error
  :
    &scop proc-name assmatat-write
    {&run_proc_attr-lib}
      (input  p-asmt-id
      ,input  p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure assmatat-exist :

  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .

  do
  on error undo, return error
  :
    &scop proc-name assmatat-exist
    {&run_proc_attr-lib}
      (input  p-asmt-id
      ,input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.

procedure assmatat-delete :

  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code     like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.

  do
  on error undo, return error
  :
    &scop proc-name assmatat-delete
    {&run_proc_attr-lib}
      (input  p-asmt-id
      ,input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure assmatat-news :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-news           as logical   no-undo . /* ходит в новости */

  do
  on error undo, return error
  :
    &scop proc-name assmatat-news
    {&run_proc_attr-lib}
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.

/*секция pop-up меню при ручном редактировании */
procedure assmatat-manual-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    &scop proc-name assmatat-manual-edit
    {&run_proc_attr-lib}
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.


procedure assmatat-batch-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    &scop proc-name assmatat-batch-edit
    {&run_proc_attr-lib}
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.


/* $Workfile$ e n d */