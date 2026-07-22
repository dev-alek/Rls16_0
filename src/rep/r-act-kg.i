/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Аналог  r - a k t . i

Автор: Булгаков Андрей Николаевич
Дата создания: 05/25/05
Author: Andrew Bulgakoff
Creation date: 05/25/05

*/

&if     "{1}" = "calc"      &then
  find first ub.bar-code no-lock where ub.bar-code.b-code = ub.price-list.b-code.
  assign v-code-is-main = ( ub.bar-code.unit-cli = ub.goods.unit-base ).
  if v-code-is-main <> yes then do:
    assign v-not-main-unit-cli      = ub.bar-code.unit-cli
           v-not-main-cli-base-rate = ub.bar-code.cli-base-rate
           v-not-main-b-code        = ub.bar-code.b-code.
  end.
  find first ub.gds-prt no-lock where ub.gds-prt.node-code = ub.bar-code.node-code.
  assign v-gds-prt-node_name = ( if ub.gds-prt.upper-code = ub.goods.prt-root then
                               ( if ub.bar-code.in-code = "":U then ub.goods.gds-name       else
                               ( ub.bar-code.in-code + "    ":U + ub.bar-code.part-code ) ) else
  &if "{2}" = "not-main" &then ub.goods.gds-name + "//" + ub.gds-prt.f-name &else "    ":U + ub.gds-prt.f-name &endif ).
  run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Определили имя товара со шкалой ( "
                                 + dtm-char( v-gds-prt-node_name ) + " )" ).
  find first ub.gds-obj no-lock where
             ub.gds-obj.obj-type  = ub.price-list.obj-type  and
             ub.gds-obj.obj-code  = ub.price-list.obj-code  and
             ub.gds-obj.prod-type = ub.price-list.prod-type and
             ub.gds-obj.prod-code = ub.price-list.prod-code and
             ub.gds-obj.artic     = ub.price-list.artic     no-error.
  if available ub.gds-obj then do:
    assign v-gds-obj_last-price = ( if v-rb-is-base = yes then ub.gds-obj.last-base else ub.gds-obj.last-rubl ).
    if v-gds-obj_last-price = ? then do: assign v-gds-obj_last-price = 0. end.
    run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Нашли товар ( "
                                   + string( ub.price-list.artic ) + " )" + " на объекте ( "
                                   + ub.price-list.obj-type + string( ub.price-list.obj-code )
                                   + " ). Определили цену закупки ( " + dtm-char( string( v-gds-obj_last-price ) ) + " )" ).
  end.
  else do:
    assign v-gds-obj_last-price = 0.
    run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Не нашли товара ( "
                                   + string( ub.price-list.artic ) + " )" + " на объекте ( "
                                   + ub.price-list.obj-type + string( ub.price-list.obj-code )
                                   + " ). Назначили цену закупки ( 0 )" ).
  end.
  find first ub.gds-prt no-lock where ub.gds-prt.upper-code = ub.goods.prt-root.
  assign v-gds-prt-node_code = ub.gds-prt.node-code.
  { gbl/bcodeprc.i ub.price-list.obj-type
               ub.price-list.obj-code
               ub.price-list.b-code
               0
               ub.price-list.fact-order
               v-price-list_doc-num
               v-price-list_price-sale_old
               v-price-list_road-tax
               v-price-list_excise         }
  if v-price-list_price-sale_old = ? then do: assign v-price-list_price-sale_old = 0. end.
  find last ub.inv-line no-lock where
            ub.inv-line.obj-type   = ub.price-list.obj-type   and
            ub.inv-line.obj-code   = ub.price-list.obj-code   and
            ub.inv-line.prod-type  = ub.price-list.prod-type  and
            ub.inv-line.prod-code  = ub.price-list.prod-code  and
            ub.inv-line.artic      = ub.price-list.artic      and
            ub.inv-line.status_    = {&fact}                  and
            ub.inv-line.fact-order < ub.price-list.fact-order no-error.
  if available ub.inv-line then do:
    assign v-price-list_doc-qnty = ub.inv-line.after-qnty.
  end.
  else do:
    assign v-price-list_doc-qnty = 0.
  end.
  if v-price-list_doc-qnty = ? then do: assign v-price-list_doc-qnty = 0. end.
  assign v-cli-base-rate = ub.price-list.doc-qnty / v-price-list_doc-qnty.
  if v-cli-base-rate = ? then do: assign v-cli-base-rate = 0. end.
  assign v-gds-obj_last-price = v-gds-obj_last-price * v-cli-base-rate.
  if v-gds-obj_last-price = ? then do: assign v-gds-obj_last-price = 0. end.
  assign v-price-list_price-sale_new = ub.price-list.price-sale * v-cli-base-rate.
  if v-price-list_price-sale_new = ? then do: assign v-price-list_price-sale_new = 0. end.
  run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Определили продажную цену из прайс-листа ( "
                                 + dtm-char( string( v-price-list_price-sale_old ) ) + " )" ).
  { gbl/gdsbcode.i ub.goods.gds-code
               ub.bar-code.node-code
               v-price-list_b-code   }
  find first ub.bar-code no-lock where ub.bar-code.b-code = v-price-list_b-code.
  assign j-counter = j-counter + 1.
  if ( j-counter modulo 10 ) = 0 and j-counter >= 10 then do:
    run waitfram-show in this-procedure ( input substitute( "Обработано строк : &1...", j-counter ) ).
  end.
&elseif "{1}" = "group"     &then
  if v-shift-down = yes then do:
    down stream AktStr 1 with frame &if "{2}" = "cost" &then Akt-Cost &else Akt &endif.
    assign v-shift-down = no.
  end.
  if v-print-group = yes then do:
    run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Печать имени группы ( " + ub.goods.grp-name + " )" ).
    put stream AktStr ub.goods.grp-name format "x({&A4_CW0})":U at 1.
  end.
&elseif "{1}" = "third-tax" &then
  if hvrdtax( recid( ub.goods ) ) = yes then do:
    run tax-name in this-procedure ( input {&road-tax}, output v-taxname ).
    assign v-tax     = ub.price-list.road-tax * ub.price-list.doc-qnty
           v-tax-sum = v-tax-sum + v-tax.
    run writelog in this-procedure ( input log-file-name, input 5, input "r-act-kg.i Товар с третьим налогом ( "
                                   + dtm-char( v-taxname ) + " ), определили значение ( " + dtm-char( string( v-tax ) )
                                   + " ) и сумму всего ( " + dtm-char( string( v-tax-sum ) ) + " )" ).
  &if "{2}" = "fact" &then
    for each ub.parts where
             ub.parts.obj-type  = ub.price-list.obj-type  and
             ub.parts.obj-code  = ub.price-list.obj-code  and
             ub.parts.artic     = ub.price-list.artic     and
             ub.parts.prod-type = ub.price-list.prod-type and
             ub.parts.prod-code = ub.price-list.prod-code and
             ub.parts.out-code  = ub.price-list.doc-num
    break by ub.parts.road-tax-rubl
    :
      assign v-tax-parts-qnty = v-tax-parts-qnty + ub.parts.fact-qnty / ub.parts.cli-base-rate.
      if last-of( ub.parts.road-tax-rubl ) then do:
        assign v-parts_road-tax-rubl = ub.parts.road-tax-rubl * ub.parts.cli-base-rate.
        display stream AktStr "     В том числе"                            @ ub.price-list.artic
                              v-taxname                                     @ ub.goods.gds-name
                              v-tax-parts-qnty   when v-tax-parts-qnty <> ? @ ub.price-list.doc-qnty
                              v-parts_road-tax-rubl                         @ ub.price-list.price-sale
                              ub.parts.fact-qnty * ub.parts.road-tax-rubl   @ v-new-sum                sym1 sym6
        with frame &if "{3}" = "cost" &then Akt-Cost &else Akt &endif.
        down stream AktStr 1 with frame &if "{3}" = "cost" &then Akt-Cost &else Akt &endif.
        assign v-line-counter   = v-line-counter + 1
               v-tax-parts-qnty = 0.
      end. /* if last-of( ub.parts.road-tax-rubl ) */
    end. /* for each ub.parts */
  &else
    display stream AktStr "     В том числе"                                      @ ub.price-list.artic
                          v-taxname                                               @ ub.goods.gds-name
                          v-price-list_doc-qnty  when v-price-list_doc-qnty <> ?  @ ub.price-list.doc-qnty
                          ub.price-list.road-tax                                  @ ub.price-list.price-sale sym1 sym6
    with frame &if "{3}" = "cost" &then Prik-Cost &else Prik &endif.
    down stream AktStr 1 with frame &if "{3}" = "cost" &then Prik-Cost &else Prik &endif.
    assign v-line-counter = v-line-counter + 1.
  &endif
  end. /* if hvrdtax( recid( ub.goods ) ) */
&endif

/* $Workfile$   E n d */

