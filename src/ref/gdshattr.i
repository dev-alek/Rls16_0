/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами товара на фирме

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined (include_attr-lib) = 0 &then
{ gbl/attr-lib.i }
&endif


procedure gdshattr-name :
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


    &scop proc-name gdshattr-name
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


procedure gdshattr-tooltip :
define input  parameter p-code    as character no-undo .
define output parameter p-tooltip as character no-undo .
define output parameter p-label   as character no-undo .

  do
  on error undo, return error
  :


    &scop proc-name gdshattr-tooltip
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


procedure gdshattr-value :
define input  parameter p-code as character no-undo .   /* код атрибута */
define input  parameter p-obj-type as character no-undo .  /* obj-type  */
define input  parameter p-obj-code as int no-undo .        /*  obj-code */
define input  parameter p-gds-code as int no-undo .        /*  gds-code */
define output parameter p-value as character no-undo .  /* значение атрибута */
define output parameter p-type     as character no-undo .

  do
  on error undo, return error
  :


  &scop proc-name gdshattr-value
  {&run_proc_attr-lib}
    (input  p-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  p-gds-code
    ,output p-value
    ,output p-type
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.

procedure gdshattr-h-value :
define input  parameter p-code as character no-undo .   /* код атрибута */
define input  parameter p-host-code as integer no-undo . /*кодф ирмы*/
define input  parameter p-gds-code as int no-undo .        /*  gds-code */
define output parameter p-value as character no-undo .  /* значение атрибута */
define output parameter p-type     as character no-undo .

  do
  on error undo, return error
  :

  &scop proc-name gdshattr-h-value
  {&run_proc_attr-lib}
    (input  p-code
    ,input  p-host-code
    ,input  p-gds-code
    ,output p-value
    ,output p-type
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.


end.
end procedure.


procedure gdshattr-write :
define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
define input parameter p-obj-type like ub.clients.obj-type   no-undo .
define input parameter p-obj-code like ub.clients.obj-code   no-undo .
define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
define input parameter p-value    like ub.gds-host-attr.attr-value no-undo .

  do
  on error undo, return error
  :

    &scop proc-name gdshattr-write
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

end procedure.

procedure gdshattr-EXIST :
define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
define input parameter p-obj-type like ub.clients.obj-type   no-undo .
define input parameter p-obj-code like ub.clients.obj-code   no-undo .
define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
define OUTPUT parameter p-EXIST   AS LOGICAL no-undo .


  do
  on error undo, return error
  :
    &scop proc-name gdshattr-exist
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

end procedure.


procedure gdshattr-DELETE :
define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
define input parameter p-obj-type like ub.clients.obj-type   no-undo .
define input parameter p-obj-code like ub.clients.obj-code   no-undo .
define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
define output parameter p-DELETED  AS LOGICAL no-undo .


  do
  on error undo, return error
  :
    &scop proc-name gdshattr-delete
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

end procedure.

procedure gdshattr-news :
define input  parameter p-code           as character no-undo . /* код атрибута */
define output parameter p-news           as logical   no-undo . /* ходит в новости */


  do
  on error undo, return error
  :
    &scop proc-name gdshattr-news
    {&run_proc_attr-lib}
      (
       input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.

  end.
end procedure.

procedure gdshattr-copy :
define input  parameter p-code           as character no-undo . /* код атрибута */
define output parameter p-copy           as logical   no-undo . /* копируется при копировании товара - если включены соответ настройки */

  do
  on error undo, return error
  :
    &scop proc-name gdshattr-copy
    {&run_proc_attr-lib}
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.

  end.
end procedure.



&if "{1}" = "interface" &then

procedure gdshattr-manual-edit :
define input  parameter p-code           as character no-undo . /* код атрибута */
define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :

  &scop proc-name gdshattr-manual-edit
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


procedure gdshattr-batch-edit :
define input  parameter p-code           as character no-undo . /* код атрибута */
define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :

  &scop proc-name gdshattr-batch-edit
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



/* 26/II-2019 не используется. Справочник операторов сотовой связи (ОСС) перенесён в БПА
procedure gds-host-oss-props :
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .

DEFINE VARIABLE v-value as character no-undo .
define buffer buf_goods for ub.goods.

  do
  on error undo, return error return-value :
    assign
    v-value = p-value.
    run ref/oss-prop.w (
                     input parparentproc
                    ,input {&update}
                    ,input p-gds-code
                    ,input-output v-value) no-error .

    if p-value <> v-value then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end. /*doe*/

end procedure. /* gds-host-oss-props  */

procedure gds-host-oss-propsd :
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-attr-code like ub.gds-host-attr.attr-code no-undo .
define input parameter p-value as character no-undo .
define input parameter p-obj-type like ub.gds-obj.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj.obj-code no-undo .

define buffer buf_goods for ub.goods.

  do
  on error undo, return error return-value :
    run ref/oss-prop.w (
                     input parparentproc
                    ,input {&lookup}
                    ,input p-gds-code
                    ,input-output p-value) no-error .
  end. /*doe*/

end procedure. /* gds-host-oss-propsd  */
*/

&endif

/* $Workfile$ e n d */