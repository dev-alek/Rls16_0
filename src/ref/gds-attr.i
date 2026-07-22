/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ѕиблиотека дл€ работы с атрибутами товара

јвтор: Ѕахтадзе Ќаталь€ ¬икторовна
ƒата создани€: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined (include_attr-lib) = 0 &then
{ gbl/attr-lib.i}
&endif

procedure gds-attr-name :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-type           as character no-undo . /* тип атрибута */
  define output parameter p-format         as character no-undo . /* формат атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может измен€ть в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */

  do
  on error undo, return error
  :
    &scop proc-name gds-attr-name
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

procedure gds-attr-tooltip :

  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .

  do
  on error undo, return error
  :
    &scop proc-name gds-attr-tooltip
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

procedure gds-attr-value :

  define input  parameter p-gds-code as integer   no-undo .  /* gds-code */
  define input  parameter p-code     as character no-undo .  /* код атрибута */
  define output parameter p-value    as character no-undo .  /* значение атрибута */
  define output parameter p-type     as character no-undo .

  do
  on error undo, return error
  :
    &scop proc-name gds-attr-value
    {&run_proc_attr-lib}
      (input  p-gds-code
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

procedure gds-attr-write :

  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .

  do
  on error undo, return error
  :
    &scop proc-name gds-attr-write
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure gds-attr-exist :

  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .

  do
  on error undo, return error
  :

    &scop proc-name gds-attr-exist
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.

procedure gds-attr-delete :

  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .

  do
  on error undo, return error
  :
    &scop proc-name gds-attr-delete
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.

procedure gds-attr-news :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-news           as logical   no-undo . /* ходит в новости */

  do
  on error undo, return error
  :
    &scop proc-name gds-attr-news
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

procedure gds-attr-copy-to :

  define input  parameter p-gds-code as integer   no-undo .  /*  gds-code */
  define input  parameter p-code     as character no-undo .  /* код атрибута */
  define input  parameter p-bh       as handle no-undo .     /* буфер поле которого заполним */


  do
  on error undo, return error
  :
    &scop proc-name gds-attr-copy-to
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.

procedure gds-attr-copy :

  define input  parameter p-code as character no-undo . /* код атрибута */
  define output parameter p-copy as logical   no-undo . /* копируетс€ при копировании товара - если включены соответ настройки */

  do
  on error undo, return error
  :
    &scop proc-name gds-attr-copy
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


procedure gds-attr_check-ptrl-divis :

  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  /*может быть {&add-def} {&update} {&deletion}*/
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name gds-attr_check-ptrl-divis
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.

procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .

  do
  on error undo, return error
  :
    &scop proc-name gds-glob-sum-grps
    {&run_proc_attr-lib}
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure. /* gds-obj-sum-grps */

procedure gds-attr_gds-ptrl-densities :

  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name gds-attr_gds-ptrl-densities
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.

procedure gds-attr_gds-CommodityCode :

  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name gds-attr_gds-CommodityCode
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.

procedure gds-attr_check-office-type :

  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  /*может быть {&add-def} {&update} {&deletion}*/
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name gds-attr_check-office-type
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.


procedure gds-attr_check-mark-type :

  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  /*может быть {&add-def} {&update} {&deletion}*/
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name gds-attr_check-mark-type
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.

procedure gds-attr_check-emrc-type :

  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  /*может быть {&add-def} {&update} {&deletion}*/
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name gds-attr_check-emrc-type
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.

procedure gds-attr_check-group-np :

  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  /*может быть {&add-def} {&update} {&deletion}*/
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name gds-attr_check-group-np
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.



procedure gds-attr_check-item-matter-mark :

  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  /*может быть {&add-def} {&update} {&deletion}*/
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name gds-attr_check-item-matter-mark
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.

procedure gds-attr_check-type-method-calc :

  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  /*может быть {&add-def} {&update} {&deletion}*/
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name gds-attr_check-type-method-calc
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.

procedure gds-attr_check-is-loyalty-payment :

  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  /*может быть {&add-def} {&update} {&deletion}*/
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name gds-attr_check-is-loyalty-payment
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.

procedure gds-attr_init-15x80 :

  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name gds-attr_init-15x80
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.

procedure gds-attr_init-8x50 :

  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name gds-attr_init-8x50
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.

procedure gds-attr_init-6x50 :

  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name gds-attr_init-6x50
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.




procedure gds-attr-manual-edit :

  define input  parameter p-code        as character no-undo . /* код атрибута */
  define output parameter p-section-num as integer no-undo .

  do
  on error undo, return error
  :
    &scop proc-name gds-attr-manual-edit
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


procedure gds-attr-batch-edit :

  define input  parameter p-code        as character no-undo . /* код атрибута */
  define output parameter p-section-num as integer   no-undo .

  do
  on error undo, return error
  :
    &scop proc-name gds-attr-batch-edit
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

procedure gds-attr_check-can-energy-value :

  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  /*может быть {&add-def} {&update} {&deletion}*/
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .


  do
  on error undo, return error return-value
  :
    &scop proc-name gds-attr_check-can-energy-value
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.

procedure gds-attr_check-can-set-dt-seasons :
  /* провер€ет, может ли быть установлен этому товару атрибут "—езон ƒ“" */
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
    &scop proc-name gds-attr_check-can-set-dt-seasons
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.

procedure isExemplarGoods :

  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.

  do
  on error undo, return error
  :
    &scop proc-name isExemplarGoods
    {&run_proc_attr-lib}
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.

procedure isVolumArticGoods :

  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.

  do
  on error undo, return error
  :
    &scop proc-name isVolumArticGoods
    {&run_proc_attr-lib}
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.

/* $Workfile$ e n d */