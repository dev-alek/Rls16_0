/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/08/09
Author: Bakhtadze Natalya
Creation date: 06/08/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined (include_attr-lib) = 0 &then
{ gbl/attr-lib.i }
&endif

procedure bc-attr_name :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-type           as character no-undo . /* тип атрибута */
  define output parameter p-format         as character no-undo . /* формат атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  define output parameter p-range          as integer   no-undo . /*области действия атрибута*/
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */

  do
  on error undo, return error
  :
    &scop proc-name bc-attr_name
    {&run_proc_attr-lib}
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-range
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

procedure bc-attr_tooltip :

  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .

  do
  on error undo, return error
  :
    &scop proc-name bc-attr_tooltip
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

procedure bc-attr_value :

  define input  parameter p-b-code as integer   no-undo .  /* b-code */
  define input  parameter p-code     as character no-undo .  /* код атрибута */
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-value    as character no-undo .  /* значение атрибута */
  define output parameter p-type     as character no-undo .

  do
  on error undo, return error
  :
    &scop proc-name bc-attr_value
    {&run_proc_attr-lib}
      (input  p-b-code
      ,input  p-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.

procedure bc-attr_write :

  define input parameter p-b-code like ub.bar-code-attr.b-code   no-undo .
  define input parameter p-code     like ub.bar-code-attr.attr-code  no-undo .
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-value    like ub.bar-code-attr.attr-value no-undo .

  do
  on error undo, return error
  :
    &scop proc-name bc-attr_write
    {&run_proc_attr-lib}
      (input  p-b-code
      ,input  p-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure bc-attr_exist :

  define input  parameter p-b-code like ub.bar-code-attr.b-code   no-undo .
  define input  parameter p-code     like ub.bar-code-attr.attr-code  no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-exist    as logical no-undo .

  do
  on error undo, return error
  :

    &scop proc-name bc-attr_exist
    {&run_proc_attr-lib}
      (input  p-b-code
      ,input  p-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.

procedure bc-attr_delete :

  define input  parameter p-b-code like ub.bar-code-attr.b-code   no-undo .
  define input  parameter p-code     like ub.bar-code-attr.attr-code  no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-deleted  as logical no-undo .

  do
  on error undo, return error
  :
    &scop proc-name bc-attr_delete
    {&run_proc_attr-lib}
      (input  p-b-code
      ,input  p-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure bc-attr_manual-edit :

  define input  parameter p-code        as character no-undo . /* код атрибута */
  define output parameter p-section-num as integer no-undo .

  do
  on error undo, return error
  :
    &scop proc-name bc-attr_manual-edit
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


procedure bc-attr_batch-edit :

  define input  parameter p-code        as character no-undo . /* код атрибута */
  define output parameter p-section-num as integer   no-undo .

  do
  on error undo, return error
  :
    &scop proc-name bc-attr_batch-edit
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

&if "{2}" &then

procedure bc-attr_taracode-bc :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-b-code like ub.bar-code-attr.b-code no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
    &scop proc-name bc-attr_taracode-bc
    {&run_proc_attr-lib}
      (input  parparentproc
      ,input  p-b-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output  p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.


end procedure.

&endif

/* $Workfile$ e n d */