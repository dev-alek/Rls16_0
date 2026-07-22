/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Метод возвращает можно ли добавить данный товар в матрицу

Автор: Чернова Светлана Александровна
Дата создания: 10/09/08
Author: Svetlana Chernova
Creation date: 10/09/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure ass-grp-gds-code-yes :
define input  parameter p-gds-code   as integer   no-undo .
define input  parameter p-node-code  as integer   no-undo .
define input  parameter p-id         as integer   no-undo .
define input  parameter p-db-num     as integer   no-undo .
define output parameter p-ask        as logical   no-undo .

define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .   /* Ограничение по группе */
define buffer buf1_gds-grp-obj-attr for ub.gds-grp-obj-attr  .  /* Количество в группе   */
define buffer buf_goods   for ub.goods  .
define buffer buf_gds-grp for ub.gds-grp  .
define buffer buf_gds-obj-prop for ub.gds-obj-prop  .

define variable v-grp-qnty as integer   no-undo .
define variable v-grp-lim as integer   no-undo .
  do
  on error undo, return error return-value
  :
p-ask = ? .

find first  ub.assortment-matrix no-lock where
            ub.assortment-matrix.asmt-id  = p-id and
            ub.assortment-matrix.db-num   = p-db-num and
            ub.assortment-matrix.asmt-type =  {&type-assmatr-shablon}
            no-error .
if available ub.assortment-matrix then do:
  p-ask = true .
  return .
end.

find first buf_gds-obj-prop no-lock where
          buf_gds-obj-prop.gds-code = p-gds-code and
          buf_gds-obj-prop.obj-type = ub.assortment-matrix.obj-type and
          buf_gds-obj-prop.obj-code = ub.assortment-matrix.obj-code and
          buf_gds-obj-prop.gdop-igt = {&ass-izd-del} no-error .
if available buf_gds-obj-prop then do:
  p-ask = true .
  return .
end.

find first buf_goods no-lock where buf_goods.gds-code = p-gds-code .

find first buf_gds-grp-obj-attr no-lock where
           buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimAssMat} and
           buf_gds-grp-obj-attr.obj-type  = string(p-id) and
           buf_gds-grp-obj-attr.obj-code  = p-db-num and
           buf_gds-grp-obj-attr.host-code = 0 and
           buf_gds-grp-obj-attr.node-code = p-node-code no-error .
if error-status :error then do:  /* нет заморочек по группам */
  p-ask = true .
  return .
end.

if buf_gds-grp-obj-attr.attr-value  = "0" then do:  /* Группу не использовать (=0) */
  p-ask = false  .
  return .
end.

  if buf_gds-grp-obj-attr.attr-value  = "" or
    buf_gds-grp-obj-attr.attr-value  = ?  or
    buf_gds-grp-obj-attr.attr-value  = "?" then do: /*Проверяем тогда вышестоящий уровень */
    find first buf_gds-grp no-lock where
                buf_gds-grp.node-code = p-node-code no-error .
      if available buf_gds-grp  then do:
          if buf_gds-grp.upper-code = 0 then do: /* Это вершний уровень */
              p-ask = true .
              return .
          end.
          else do:
              run ass-grp-gds-code-yes (
                 input   p-gds-code
                ,input   buf_gds-grp.upper-code
                ,input   p-id
                ,input   p-db-num
                ,output  p-ask
                ).
              if p-ask <> ? then return .  /* Однозначно да или нет */
        end.
      end.
  end.
  else do:
    v-grp-lim = int (buf_gds-grp-obj-attr.attr-value) no-error  .
    if v-grp-lim > 0 then do:
        v-grp-qnty = 0 .
        find first buf1_gds-grp-obj-attr no-lock where
                   buf1_gds-grp-obj-attr.attr-code = {&ggoattr-QntyAssMat} and
                   buf1_gds-grp-obj-attr.obj-type  = string(p-id) and
                   buf1_gds-grp-obj-attr.obj-code  = p-db-num and
                   buf1_gds-grp-obj-attr.host-code = 0 and
                   buf1_gds-grp-obj-attr.node-code = p-node-code no-error .
        if available buf1_gds-grp-obj-attr then do:
          v-grp-qnty = int(buf1_gds-grp-obj-attr.attr-value) .
        end.

        if v-grp-lim >= v-grp-qnty + 1 then p-ask = true .
        else p-ask = false .

        return .
    end.
  end.
  end.
end procedure. /* ass-grp-gds-code-yes */


procedure recalc-gds-assgrp :
/* пересчет после удаления или внесения товара в матрицу */
define input  parameter p-action     as character no-undo .
define input  parameter p-gds-code  as integer   no-undo .
define input  parameter p-node-code  as integer   no-undo .
define input  parameter p-id         as integer   no-undo .
define input  parameter p-db-num     as integer   no-undo .

define buffer buf_gds-grp for ub.gds-grp  .
define buffer curr_gds-grp for ub.gds-grp  .
define buffer buf1_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
define buffer buf_gds-obj-prop for ub.gds-obj-prop  .

define variable kk as character no-undo .

  do
  on error undo, return error return-value
  :

find first  ub.assortment-matrix no-lock where
            ub.assortment-matrix.asmt-id  = p-id and
            ub.assortment-matrix.db-num   = p-db-num and
            ub.assortment-matrix.asmt-type =  {&type-assmatr-shablon}
            no-error .
    if available ub.assortment-matrix then do:
      return .
    end.
/* ??? */
    find first buf_gds-obj-prop no-lock where
               buf_gds-obj-prop.gds-code = p-gds-code and
               buf_gds-obj-prop.obj-type = ub.assortment-matrix.obj-type and
               buf_gds-obj-prop.obj-code = ub.assortment-matrix.obj-code and
               buf_gds-obj-prop.gdop-igt = {&ass-izd-del}
               no-error .
    if available buf_gds-obj-prop then do:
      if p-action <> '--' then  do:
         return .
      end.
    end.

    find first buf1_gds-grp-obj-attr exclusive-lock where
               buf1_gds-grp-obj-attr.attr-code = {&ggoattr-QntyAssMat} and
               buf1_gds-grp-obj-attr.obj-type  = string(p-id) and
               buf1_gds-grp-obj-attr.obj-code  = p-db-num and
               buf1_gds-grp-obj-attr.host-code = 0 and
               buf1_gds-grp-obj-attr.node-code = p-node-code
               no-error .

    if available buf1_gds-grp-obj-attr then do:
       if p-action = '+' then  do:
          kk = string( int( buf1_gds-grp-obj-attr.attr-value ) + 1 ).
       end.
       else do:
          kk = string( int( buf1_gds-grp-obj-attr.attr-value ) - 1 ).
       end.
       buf1_gds-grp-obj-attr.attr-value = kk .
    end.
    else do:
        if p-action = '+' then  do:
            create buf1_gds-grp-obj-attr .
              assign
                buf1_gds-grp-obj-attr.attr-code  = {&ggoattr-QntyAssMat}
                buf1_gds-grp-obj-attr.obj-type   = string(p-id)
                buf1_gds-grp-obj-attr.obj-code   = p-db-num
                buf1_gds-grp-obj-attr.host-code  = 0
                buf1_gds-grp-obj-attr.node-code  = p-node-code
                buf1_gds-grp-obj-attr.attr-value = "1"
              .
        end.
    end.
   /*  */
   FIND FIRST curr_gds-grp WHERE
              curr_gds-grp.node-code = p-node-code
        NO-LOCK NO-ERROR.
   if AVAILABLE curr_gds-grp AND curr_gds-grp.upper-code > 0 then do:
      run recalc-gds-assgrp (p-action ,p-gds-code , curr_gds-grp.upper-code,p-id,p-db-num ) .
   end.
  end.
end procedure. /* recalc-gds-assgrp */