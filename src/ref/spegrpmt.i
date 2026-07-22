/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Метод возвращает можно ли добавить данный товар в спецификацию

Автор: Чернова Светлана Александровна
Дата создания: 10/09/08
Author: Svetlana Chernova
Creation date: 10/09/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


procedure SpecGr-gds-code-yes :
define input  parameter p-gds-code   as integer   no-undo .
define input  parameter p-node-code  as integer   no-undo .
define input  parameter p-contract-num         as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define output parameter p-ask        as logical   no-undo .

define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .   /* Ограничение по группе */
define buffer buf1_gds-grp-obj-attr for ub.gds-grp-obj-attr  .  /* Количество в группе   */
define buffer buf_goods   for ub.goods  .
define buffer buf_gds-grp for ub.gds-grp  .

define variable v-grp-qnty as integer   no-undo .
define variable v-grp-lim as integer   no-undo .
  do
  on error undo, return error return-value
  :
p-ask = ? .
find first buf_goods no-lock where buf_goods.gds-code = p-gds-code .

find first buf_gds-grp-obj-attr no-lock where
           buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimSpecGr} and
           buf_gds-grp-obj-attr.obj-type  = string(p-contract-num) and
           buf_gds-grp-obj-attr.obj-code  = p-host-code and
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
              run SpecGr-gds-code-yes (
                 input   p-gds-code
                ,input   buf_gds-grp.upper-code
                ,input   p-contract-num
                ,input   p-host-code
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
                   buf1_gds-grp-obj-attr.attr-code = {&ggoattr-QntySpecGr} and
                   buf1_gds-grp-obj-attr.obj-type  = string(p-contract-num) and
                   buf1_gds-grp-obj-attr.obj-code  = p-host-code and
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
end procedure. /* SpecGr-gds-code-yes */


procedure recalc-gds-SpecGr :
/* пересчет после удаления или внесения товара в матрицу */
define input  parameter p-action     as character no-undo .
define input  parameter p-node-code  as integer   no-undo .
define input  parameter p-contract-num         as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .

define buffer buf_gds-grp for ub.gds-grp  .
define buffer curr_gds-grp for ub.gds-grp  .
define buffer buf1_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
define variable kk as character no-undo .

  do
  on error undo, return error return-value
  :

    find first buf1_gds-grp-obj-attr exclusive-lock where
               buf1_gds-grp-obj-attr.attr-code = {&ggoattr-QntySpecGr} and
               buf1_gds-grp-obj-attr.obj-type  = string(p-contract-num) and
               buf1_gds-grp-obj-attr.obj-code  = p-host-code and
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
                buf1_gds-grp-obj-attr.attr-code  = {&ggoattr-QntySpecGr}
                buf1_gds-grp-obj-attr.obj-type   = string(p-contract-num)
                buf1_gds-grp-obj-attr.obj-code   = p-host-code
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
      run recalc-gds-SpecGr (p-action ,curr_gds-grp.upper-code,p-contract-num,p-host-code ) .
   end.
  end.
end procedure. /* recalc-gds-SpecGr */