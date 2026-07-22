/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined (include_attr-lib) = 0 &then
{ gbl/attr-lib.i {2}}
&endif

&if "{2}" = "class"
&then
method public void gdsoattr-name (
  input p-code            as character,
  output p-type           as character,
  output p-format         as character,
  output p-label          as character,
  output p-user-can-edit  as logical,
  output p-output-display as logical,
  output p-other          as character
  ):
  do:
&else
procedure gdsoattr-name :
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
&endif
    &scop proc-name gdsoattr-name
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
end.

&if "{2}" = "class"
&then
method public void gdsoattr-tooltip (
  input  p-code    as character,
  output p-tooltip as character,
  output p-label   as character
  ):
  do:
&else
procedure gdsoattr-tooltip :

  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gdsoattr-tooltip
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
end.


&if "{2}" = "class"
&then
method public character gdsoattr-value (
  input  p-code     like ub.gds-obj-attr.attr-code,
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  output p-type     as   character
  ):
  define variable p-value like ub.gds-obj-attr.attr-value no-undo .
  do:
&else
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gdsoattr-value
    {&run_proc_attr-lib}
      (input  p-code
      ,input  p-gds-code
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
&if "{2}" = "class"
&then
  return p-value.
&endif
end.

&if "{2}" = "class"
&then
method public integer gdsoattr-gds-code (
  input p-code     like ub.gds-obj-attr.attr-code,
  input p-value    like ub.gds-obj-attr.attr-value,
  input p-obj-type like ub.gds-obj-attr.obj-type,
  input p-obj-code like ub.gds-obj-attr.obj-code
  ):
  do:
  define variable p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
&else
procedure gdsoattr-gds-code :

  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gdsoattr-gds-code
    {&run_proc_attr-lib}
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return p-gds-code.
&endif
end.

&if "{2}" = "class"
&then
method public void gdsoattr-write (
  input p-gds-code like ub.gds-obj-attr.gds-code,
  input p-obj-type like ub.gds-obj-attr.obj-type,
  input p-obj-code like ub.gds-obj-attr.obj-code,
  input p-code     like ub.gds-obj-attr.attr-code,
  input p-value    like ub.gds-obj-attr.attr-value
  ):
  do:
&else
procedure gdsoattr-write :

  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gdsoattr-write
    {&run_proc_attr-lib}
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end.

&if "{2}" = "class"
&then
method public logical gdsoattr-exist (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input  p-code     like ub.gds-obj-attr.attr-code
  ):
  do:
  define variable p-exist    as logical no-undo .
&else
procedure gdsoattr-exist :

  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gdsoattr-exist
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return p-exist.
&endif
end.

&if "{2}" = "class"
&then
method public logical gdsoattr-delete (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input  p-code     like ub.gds-obj-attr.attr-code
  ):
  do:
  define variable p-deleted    as logical no-undo .
&else
procedure gdsoattr-delete :

  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gdsoattr-delete
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return p-deleted.
&endif
end.

&if "{2}" = "class"
&then
method public logical gds-obj-doc-tickets (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input-output p-value as character
  ):
  do:
  define variable p-setted    as logical no-undo .
&else
procedure gds-obj-doc-tickets :

  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gds-obj-doc-tickets
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return p-setted.
&endif
end. /* gds-obj-gds-margin */

&if "{2}" = "class"
&then
method public logical gds-obj-dop-alt-name (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input-output p-value as character
  ):
  do:
  define variable p-setted    as logical no-undo .
&else
procedure gds-obj-dop-alt-name :

  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gds-obj-dop-alt-name
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return p-setted.
&endif
end. /* gds-obj-dop-alt-name */

&if "{2}" = "class"
&then
method public logical gds-obj-gds-margins (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input-output p-value as character
  ):
  do:
  define variable p-setted    as logical no-undo .
&else
procedure gds-obj-gds-margins :

  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gds-obj-gds-margins
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return p-setted.
&endif
end. /* gds-obj-gds-margin */


&if "{2}" = "class"
&then
method public logical gds-obj-normal-wastage (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input-output p-value as character
  ):
  do:
  define variable p-setted    as logical no-undo .
&else
procedure gds-obj-normal-wastage :

  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gds-obj-normal-wastage
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return p-setted.
&endif
end. /* gds-obj-normal-wastage */


&if "{2}" = "class"
&then
method public void gds-attr-margin-value (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  output p-min-value        as decimal,
  output p-max-value        as decimal,
  output p-increase-pc      as decimal,
  output p-rmethod          as character,
  output p-base             as decimal,
  output p-range-margin     as integer,
  output p-exists-margin    as logical,
  output p-range-increase   as integer,
  output p-exists-increase  as logical,
  output p-range-rmethod    as integer,
  output p-exists-rmethod   as logical
  ):
  do:
&else
procedure gds-attr-margin-value :

  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gds-attr-margin-value
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.

&if "{2}" = "class"
&then
method public class ibs.th.ref.normwastsub gds-o-normal-wastage-value (
  input objNormWast as class ibs.th.ref.normwastsub
  ):
  do:
&else
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
&endif
    &scop proc-name gds-o-normal-wastage-value
    {&run_proc_attr-lib}
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return objNormWast.
&endif
end.

&if "{2}" = "class"
&then
method public logical gdsoattr-copy (
  input p-code as character
  ):
  define variable p-copy as logical no-undo .
  do:
&else
procedure gdsoattr-copy :

  define input  parameter p-code as character no-undo . /* код атрибута */
  define output parameter p-copy as logical   no-undo . /* копируется при копировании товара - если включены соответ настройки */

  do
  on error undo, return error
  :
&endif
    &scop proc-name gdsoattr-copy
    {&run_proc_attr-lib}
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return p-copy.
&endif
end.

&if "{2}" = "class"
&then
method public integer gds-attr_check-code-dt-seasons (
  input  p-code     like ub.goods.gds-code,
  input  p-obj-type like ub.clients.obj-type,
  input  p-obj-code like ub.clients.obj-code,
  output p-gds-code like ub.goods.gds-code
  ):
  define variable p-dt-code as integer no-undo .
  do:
&else
procedure gds-attr_check-code-dt-seasons :

  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gds-attr_check-code-dt-seasons
    {&run_proc_attr-lib}
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return p-dt-code.
&endif
end. /* gds-attr_check-code-dt-seasons */

&if "{1}" = "interface" or "{1}" = "trigger"  &then

/*секция pop-up меню при ручном редактировании */
&if "{2}" = "class"
&then
method public integer gdsoattr-manual-edit (
  input p-code as character
  ):
  define variable p-section-num as integer no-undo .
  do:
&else
procedure gdsoattr-manual-edit :

  define input  parameter p-code        as character no-undo . /* код атрибута */
  define output parameter p-section-num as integer no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gdsoattr-manual-edit
    {&run_proc_attr-lib}
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return p-section-num.
&endif
end.

&endif


&if "{1}" = "interface" &then
&if "{2}" = "class"
&then
method public integer gdsoattr-batch-edit (
  input p-code as character
  ):
  define variable p-section-num as logical no-undo .
  do:
&else
procedure gdsoattr-batch-edit :

  define input  parameter p-code        as character no-undo . /* код атрибута */
  define output parameter p-section-num as integer   no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gdsoattr-batch-edit
    {&run_proc_attr-lib}
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return p-section-num.
&endif
end.

&if "{2}" = "class"
&then
method public logical gds-obj-sum-grps (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input-output p-value as character
  ):
  do:
  define variable p-setted    as logical no-undo .
&else
procedure gds-obj-sum-grps :

  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gds-obj-sum-grps
    {&run_proc_attr-lib}
      (input {2}
      ,input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return p-setted.
&endif
end. /* gds-obj-sum-grps */


&if "{2}" = "class"
&then
method public character gds-obj-init-increase-pc (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code
  ):
  do:
  define variable p-value    as character no-undo .
&else
procedure gds-obj-init-increase-pc :

  define input  parameter p-gds-code like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj.obj-type no-undo .
  define input  parameter p-obj-code like ub.gds-obj.obj-code no-undo .
  define output parameter p-value    as character no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gds-obj-init-increase-pc
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return p-value.
&endif
end. /* gds-obj-init-increase-pc */


&if "{2}" = "class"
&then
method public logical gds-obj-round-method (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input-output p-value as character
  ):
  do:
  define variable p-setted    as logical no-undo .
&else
procedure gds-obj-round-method :

  define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gds-obj-round-method
    {&run_proc_attr-lib}
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return p-setted.
&endif
end. /* gds-obj-round-method */


&if "{2}" = "class"
&then
method public logical gds-obj-taracode (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input-output p-value as character
  ):
  do:
  define variable p-setted    as logical no-undo .
&else
procedure gds-obj-taracode :

  define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  do
  on error undo, return error return-value
  :
&endif
    &scop proc-name gds-obj-taracode
    {&run_proc_attr-lib}
      (input {2}
      ,input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return p-setted.
&endif
end. /* gds-obj-taracode */


&if "{2}" = "class"
&then
method public logical gds-obj-attr_check-ptrl-divis (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input  p-value      as character,
  input  p-mode       as character,
  output p-error-code as character
  ):
  do:
  define variable p-correct    as logical no-undo .
&else
procedure gds-obj-attr_check-ptrl-divis :

  define input  parameter p-gds-code like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj.obj-type no-undo .
  define input  parameter p-obj-code like ub.gds-obj.obj-code no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical   no-undo .
  define output parameter p-error-code  as character no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gds-obj-attr_check-ptrl-divis
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return p-correct.
&endif
end. /* gds-obj-attr_check-ptrl-divis */

&if "{2}" = "class"
&then
method public logical gds-obj-dt-seasons (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input-output p-value as character
  ):
  do:
  define variable p-setted    as logical no-undo .
&else
procedure gds-obj-dt-seasons :

  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  do
  on error undo, return error
  :
&endif
    &scop proc-name gds-obj-dt-seasons
    {&run_proc_attr-lib}
      (input {2}
      ,input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
&if "{2}" = "class"
&then
  return p-setted.
&endif
end. /* gds-obj-dt-seasons */

&endif

/* $Workfile$ e n d */
