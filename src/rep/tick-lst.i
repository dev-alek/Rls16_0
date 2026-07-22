/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать ценников (этикеток) по списку

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/98
Author: Dmitry Ukhanov
Creation date: 03/22/98

*/
&scop need-prn ~
  if prn-prt = false ~
    and bar-code.node-code <> rootnode_code ~
  then do: ~
    next. ~
  end. ~
  if prn-prt = true then do: ~
    find first gds-prt no-lock ~
      where gds-prt.node-code = bar-code.node-code ~
    . ~
    if gds-prt.is-term = false then do: ~
      next. ~
    end. ~
  end. ~


if NOT can-find(first {1}) then
    RETURN.

for each {1}
&if "{2}" = "artic" &then
by {1}.artic
by {1}.prod-type
by {1}.prod-code
&endif
&if "{2}" = "b-code" &then
by {1}.gds-code
&endif
&if "{2}" = "order-num" &then
by {1}.order-num
&endif
&if "{2}" = "gds-name" &then
by {1}.gds-name
&endif
:
  find ub.goods no-lock
    where ub.goods.prod-type = {1}.prod-type
      and ub.goods.prod-code = {1}.prod-code
      and ub.goods.artic = {1}.artic
  .
  find ub.gds-prt no-lock
    where ub.gds-prt.upper-code = goods.prt-root
  .
  assign
    rootnode_code = ub.gds-prt.node-code
    list-qnty = {1}.qnty
    v-part-code   = "":U
    v-promo-code  = {1}.promo-code
    v-ActionId    = {1}.ActionId
    v-db-num      = {1}.db-num
  .

  if v-cntxp-doc-prt AND TickOnS AND can-find(first ub.gds-prt where ub.gds-prt.upper-code = rootnode_code) then do:
    assign
      prn-prt = TRUE
    .
  end.
  else do:
    assign
      prn-prt = FALSE
    .
  end.

  CASE BCodeType:
    when "main" then do:
      if TicketType = "уп" then do:
        for each ub.bar-code no-lock
            where ub.bar-code.gds-code = ub.goods.gds-code
              and ub.bar-code.part-code = ""
              and ub.bar-code.in-code = ""
              and ub.bar-code.unit-cli <> ub.goods.unit-base
        on error undo, return error :
          {&need-prn}
          { rep/ticket.i }
        end.
      end.
      else do:
        for each ub.bar-code no-lock
           where ub.bar-code.gds-code = ub.goods.gds-code
             and ub.bar-code.unit-cli = ub.goods.unit-base
             and ub.bar-code.part-code = ""
             and ub.bar-code.in-code = ""
        on error undo, return error :
          {&need-prn}
          { rep/ticket.i }
        end.
      end.
    end.
    when "part" then do:
      for each ub.parts no-lock
         where ub.parts.artic = ub.goods.artic
           and ub.parts.prod-type = ub.goods.prod-type
           and ub.parts.prod-code = ub.goods.prod-code
           and ub.parts.rsrv-free = yes
         ,each ub.bar-code no-lock
         where ub.bar-code.gds-code  = ub.goods.gds-code
           and ub.bar-code.unit-cli  = ub.goods.unit-base
           and ub.bar-code.part-code = ub.parts.part-code
           and ub.bar-code.in-code   = ub.parts.in-code
      on error undo, return error :
        {&need-prn}
        assign
          v-part-code = ub.parts.part-code
        .
        { rep/ticket.i }
      end.
    end.
    when "subs" then do:
      for each ub.bar-code no-lock
         where ub.bar-code.gds-code = ub.goods.gds-code
           and ub.bar-code.unit-cli = unitname
           and ub.bar-code.part-code = ""
           and ub.bar-code.in-code = ""
      on error undo, return error :
        {&need-prn}
        { rep/ticket.i }
      end.
    end.
  END CASE.
end. /* for each {1}........*/

{ rep/tick-end.i }

/* $Workfile$ e n d */