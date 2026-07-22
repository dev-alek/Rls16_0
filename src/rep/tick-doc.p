block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: tick-doc.p $
$Archive: rep/tick-doc.p $

Печать ценников (этикеток)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/98
Author: Dmitry Ukhanov
Creation date: 03/22/98

*/


define input parameter parparentproc        as handle           no-undo.
define input parameter DocRecid             as recid            no-undo.
define input parameter DocType              as char             no-undo.
define input parameter p-price-celection    as integer          no-undo.   /*Параметры из формы печати списка документов*/
define input parameter p-print-zero         as logical          no-undo.   /* ........................................  */
define input parameter p-sort-by-group      as logical          no-undo.   /* ........................................  */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tick-doc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/tick-doc.p $":U .
define variable vss-description as character no-undo init "Печать ценников (этикеток)".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i  }

define buffer b-price-list for ub.price-list.

define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .

define variable Action as character init "DOCUMENT" no-undo.
define variable v-rb-is-base as logical no-undo .
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable v-base-code     like ub.sysconf.base-code no-undo.
define variable v-host-code     like ub.sysconf.host-code no-undo .
define NEW SHARED STREAM OutStream.

define variable v-user-id as character no-undo .

run get-userid in parparentproc
  ( output v-user-id
  ).
if DocType = "trn" then do:
  find first ub.trn-doc no-lock
    where recid( ub.trn-doc ) = DocRecid
    .
  assign
    p-obj-type = ub.trn-doc.obj-type
    p-obj-code = ub.trn-doc.obj-code
    .
end.
else do:
  find first ub.price-doc no-lock
    where recid( ub.price-doc ) = DocRecid
    .
  assign
    p-obj-type = ub.price-doc.obj-type
    p-obj-code = ub.price-doc.obj-code
   .
end.

{ rep/new-prn.i new }
{ rep/tick-beg.i DocType }

if DocType = "trn" then do:
  assign
    v-doc-code = ub.trn-doc.doc-code
    v-fact-order = ub.trn-doc.fact-order
    .
end.
else do:
  assign
    v-fact-order = ub.price-doc.fact-order
   .
end.


define variable how-pcnt-kat as character no-undo .
define variable dflt-cd as character no-undo .
{ str/howpcntk.i p-obj-type p-obj-code how-pcnt-kat dflt-cd no-error }

run get-report-num in parparentproc (
    output g#report-num
).


run get-quest-print in parparentproc (
    output g#quest-print
).



PROCEDURE tick-trn:
define variable v-table-name    as character no-undo .     /* имя таблицы, где будем искать */
define variable v-goods    as character no-undo .     /* имя таблицы, где будем искать */
define variable v-query-prepare as character no-undo .     /* описание выборки - query  */
define variable qh as widget-handle no-undo . /* qwery */
define variable bh as widget-handle no-undo . /* buffer */
define variable bg as widget-handle no-undo . /* buffer */

  do
  on error undo, return error return-value
  :
 v-table-name = "doc-line" .
 v-goods      = "goods" .

 case list-sort :
 when "artic" then do:
    v-query-prepare =
      substitute ('
        for each doc-line no-lock where doc-line.doc-code = &3&2&3  by &1' ,
                "doc-line.artic" ,
                ub.trn-doc.doc-code  ,
                {&double-quote}) .
 end.
 when "b-code" then do:
    v-query-prepare =
      substitute ('
        for each doc-line no-lock where doc-line.doc-code = &3&2&3 ,
            first goods no-lock where
                  goods.artic     = doc-line.artic and
                  goods.prod-type = doc-line.prod-type and
                  goods.prod-code = doc-line.prod-code by &1' ,
                "goods.gds-code" ,
                ub.trn-doc.doc-code  ,
                {&double-quote}) .
 end.

 when "order-num" then do:
    v-query-prepare =
      substitute ('
        for each doc-line no-lock where doc-line.doc-code = &3&2&3 by &1' ,
                "doc-line.line-num" ,
                ub.trn-doc.doc-code  ,
                {&double-quote}) .
 end.
 when "gds-name" then do:
    v-query-prepare =
      substitute ('
        for each doc-line no-lock where doc-line.doc-code = &3&2&3 ,
            first goods no-lock where
                  goods.artic     = doc-line.artic and
                  goods.prod-type = doc-line.prod-type and
                  goods.prod-code = doc-line.prod-code by &1' ,
                "goods.gds-name" ,
                ub.trn-doc.doc-code  ,
                {&double-quote}) .
 end.
 otherwise do:
    v-query-prepare =
      substitute ('
        for each doc-line no-lock where doc-line.doc-code = &3&2&3 by &1' ,
                "doc-line.line-num" ,
                ub.trn-doc.doc-code  ,
                {&double-quote}) .

 end.
 end case.

    create buffer bh for table v-table-name.
    create buffer bg for table v-goods.
    create query qh.

      if list-sort =  "gds-name" or
         list-sort =  "b-code"
      then do:
         qh:set-buffers (bh, bg).
      end.
      else do:
         qh:set-buffers (bh).
      end.

      qh:query-prepare (v-query-prepare).
      qh:query-open ().
      /* Обработка первой записи */
      qh:get-first ().
      if bh:available <> true then do: /* если первая запись не доступна - выходим */
         qh:query-close() .
         delete object qh.
         delete object bh.
         return.
       end.

      /* Обработка остальной выборки */
      do while qh:query-off-end = false :
          /* Обработка строки */
          run tick-trn-line in this-procedure (input  bh:recid ) .
          qh:get-next().
      end.
    qh:query-close() .
    delete object qh.
    delete object bh.
  end.

END PROCEDURE.

PROCEDURE tick-trn-line:
define input  parameter p-recid as recid no-undo .

  { gbl/rbisbase.i
    v-rb-is-base
  }

  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  { gbl/basecode.i v-host-code v-base-code  }


  for each ub.doc-line no-lock
    where recid(ub.doc-line) = p-recid

  :

    find first ub.goods no-lock
      where ub.goods.prod-type = ub.doc-line.prod-type
        and ub.goods.prod-code = ub.doc-line.prod-code
        and ub.goods.artic     = ub.doc-line.artic
      .
    find first ub.gds-prt no-lock
      where ub.gds-prt.upper-code = ub.goods.prt-root
      .
    assign
      rootnode_code = ub.gds-prt.node-code
      v-part-code = "":U
      .
    case BCodeType:
      when "main" then do:
        for each ub.gds-dtl no-lock
          where ub.gds-dtl.prod-type = ub.doc-line.prod-type
            and ub.gds-dtl.prod-code = ub.doc-line.prod-code
            and ub.gds-dtl.artic = ub.doc-line.artic
            and ub.gds-dtl.doc-code = ub.doc-line.doc-code
        :
          find first ub.bar-code
            where ub.bar-code.gds-code = ub.goods.gds-code
              and ub.bar-code.unit-cli = ub.goods.unit-base
              and ub.bar-code.node-code = ub.gds-dtl.prt-code
              and ub.bar-code.part-code = ""
              and ub.bar-code.in-code = ""
            .
          find first ub.units no-lock
            where ub.units.unit-name = ub.bar-code.unit-cli
            .
          if lookup({&twounit}, units.type) > 0 then do:
            assign nakl-qnty = ub.doc-line.cli-qnty .
          end.
          else do:
            assign nakl-qnty = ( if can-do( {&fact}, ub.trn-doc.status_ ) then ub.gds-dtl.fact-qnty else ub.gds-dtl.doc-qnty ) .
          end.
          assign
            pr-doc-rubl = ub.gds-dtl.price-rubl
          .
          if v-rb-is-base = true then do:
            assign
              pr-doc-rb = ub.gds-dtl.price-base
            .
          end.
          else do:
            assign
              pr-doc-rb = ub.gds-dtl.price-rubl
            .
          end.
          { rep/ticket.i }
        end.
      end.
      when "part" then do:
        for each ub.parts no-lock
          where ub.parts.obj-type = ub.trn-doc.obj-type
            and ub.parts.obj-code = ub.trn-doc.obj-code
            and ub.parts.artic = ub.goods.artic
            and ub.parts.prod-type = ub.goods.prod-type
            and ub.parts.prod-code = ub.goods.prod-code
            and ub.parts.out-code = ub.trn-doc.doc-code
        :
          find first ub.bar-code no-lock
            where ub.bar-code.gds-code  = ub.goods.gds-code
              and ub.bar-code.unit-cli  = ub.goods.unit-base
              and ub.bar-code.node-code = rootnode_code
              and ub.bar-code.part-code = ub.parts.part-code
              and ub.bar-code.in-code   = ub.parts.in-code
            no-error.
          if not available ub.bar-code then
            message "На товар, артикул - " ub.goods.artic " (" ub.goods.prod-type " " ub.goods.prod-code "), нет бар-кода партии!" view-as alert-box error.
          else
            do:
              find first ub.units no-lock
                where ub.units.unit-name = ub.bar-code.unit-cli
                .
              if ub.units.type = {&twounit} then do:
                assign
                  nakl-qnty = ub.parts.cli-qnty
                .
              end.
              else do:
                assign
                  nakl-qnty = ( if can-do( {&fact}, ub.trn-doc.status_ ) then ub.parts.fact-qnty else parts.qnty )
                .
              end.
              assign
                v-part-code = ub.parts.part-code
              .
              { rep/ticket.i }
            end.
        end.
      end.
      when "subs" then  do:
        if TickOnS then do:
          for each ub.gds-dtl no-lock
            where ub.gds-dtl.prod-type = ub.doc-line.prod-type
              and ub.gds-dtl.prod-code = ub.doc-line.prod-code
              and ub.gds-dtl.artic     = ub.doc-line.artic
              and ub.gds-dtl.doc-code  = ub.doc-line.doc-code
            ,each ub.bar-code no-lock
            where ub.bar-code.gds-code  = ub.goods.gds-code
              and ub.bar-code.unit-cli  = UnitName
              and ub.bar-code.node-code = ub.gds-dtl.prt-code
              and ub.bar-code.part-code = ""
              and ub.bar-code.in-code   = ""
          :
            assign
              pr-doc-rubl = ub.gds-dtl.price-rubl
            .
            if v-rb-is-base = true then do:
              assign
                pr-doc-rb = ub.gds-dtl.price-base
              .
            end.
            else do:
              assign
                pr-doc-rb = ub.gds-dtl.price-rubl
              .
            end.
            if qntytype = "документ" then do:
              assign
              nakl-qnty = ( if can-do( {&fact}, ub.trn-doc.status_ ) then ub.gds-dtl.fact-qnty else ub.gds-dtl.doc-qnty ) .
            end.

            { rep/ticket.i }
          end.
        end.
        else do:
          find first ub.gds-dtl no-lock
            where ub.gds-dtl.prod-type = ub.doc-line.prod-type
              and ub.gds-dtl.prod-code = ub.doc-line.prod-code
              and ub.gds-dtl.artic     = ub.doc-line.artic
              and ub.gds-dtl.doc-code  = ub.doc-line.doc-code
            .
          find first ub.bar-code no-lock
            where ub.bar-code.gds-code  = ub.goods.gds-code
              and ub.bar-code.unit-cli  = UnitName
              and ub.bar-code.node-code = rootnode_code
              and ub.bar-code.part-code = ""
              and ub.bar-code.in-code   = ""
            no-error.
          if available ub.bar-code then do:
            assign
              pr-doc-rubl = ub.gds-dtl.price-rubl
            .
            if v-rb-is-base = true then do:
              assign
                pr-doc-rb = ub.gds-dtl.price-base
              .
            end.
            else do:
              assign
                pr-doc-rb = ub.gds-dtl.price-rubl
              .
            end.
            if qntytype = "документ" then do:
              assign
                nakl-qnty = ( if can-do( {&fact}, ub.trn-doc.status_ ) then ub.gds-dtl.fact-qnty else ub.gds-dtl.doc-qnty )
              .
            end.
            { rep/ticket.i }
          end.
        end.
      end.
    end case.
  end.
END PROCEDURE.


PROCEDURE tick-price:
define variable v-table-name    as character no-undo .     /* имя таблицы, где будем искать */
define variable v-goods    as character no-undo .     /* имя таблицы, где будем искать */
define variable v-query-prepare as character no-undo .     /* описание выборки - query  */
define variable qh as widget-handle no-undo . /* qwery */
define variable bh as widget-handle no-undo . /* buffer */
define variable bg as widget-handle no-undo . /* buffer */

  do
  on error undo, return error return-value
  :
 v-table-name = "price-list" .
 v-goods      = "goods" .

 case list-sort :
 when "artic" then do:
    v-query-prepare =
      substitute ('
        for each price-list no-lock where price-list.doc-num = &3&2&3  by &1' ,
                "price-list.artic" ,
                ub.price-doc.doc-num  ,
                {&double-quote}) .
 end.
 when "b-code" then do:
    v-query-prepare =
      substitute ('
        for each price-list no-lock where price-list.doc-num = &3&2&3  by &1' ,
                "price-list.b-code" ,
                ub.price-doc.doc-num  ,
                {&double-quote}) .
 end.

 when "order-num" then do:
    v-query-prepare =
      substitute ('
        for each price-list no-lock where price-list.doc-num = &3&2&3  by &1' ,
                "price-list.line-num" ,
                ub.price-doc.doc-num  ,
                {&double-quote}) .
 end.
 when "gds-name" then do:
    v-query-prepare =
      substitute ('
        for each price-list no-lock where price-list.doc-num = &3&2&3 ,
            first goods no-lock where
                  goods.artic     = price-list.artic and
                  goods.prod-type = price-list.prod-type and
                  goods.prod-code = price-list.prod-code by &1' ,
                "goods.gds-name" ,
                ub.price-doc.doc-num  ,
                {&double-quote}) .
 end.
otherwise do:
    v-query-prepare =
      substitute ('
        for each price-list no-lock where price-list.doc-num = &3&2&3  by &1' ,
                "price-list.line-num" ,
                ub.price-doc.doc-num  ,
                {&double-quote}) .

end.
 end case.

    create buffer bh for table v-table-name.
    create buffer bg for table v-goods.
    create query qh.
      if list-sort =  "gds-name" then do:
         qh:set-buffers (bh, bg).
      end.
      else do:
         qh:set-buffers (bh).
      end.

      qh:query-prepare (v-query-prepare).
      qh:query-open ().
      /* Обработка первой записи */
      qh:get-first ().
      if bh:available <> true then do: /* если первая запись не доступна - выходим */
         qh:query-close() .
         delete object qh.
         delete object bh.
         return.
       end.

      /* Обработка остальной выборки */
      do while qh:query-off-end = false :
          /* Обработка строки */
          run tick-price-line in this-procedure (input  bh:recid ) .
          qh:get-next().
      end.
    qh:query-close() .
    delete object qh.
    delete object bh.
  end.

END PROCEDURE.

procedure tick-price-line :
define input  parameter p-recid  as recid no-undo .
  do
  on error undo, return error return-value
  :
  define variable cur-rt like ub.price-list.road-tax   no-undo.
  define variable cur-ex like ub.price-list.excise     no-undo.
  define variable cur-dn like ub.price-list.doc-num    no-undo.
  define variable v-is-chg as logical   no-undo .

  for each b-price-list no-lock
    where recid( b-price-list ) = p-recid and true
  :
    assign
      v-is-chg = true
    .

    if OnlyChgPr = true then do:
      { gbl/ichprise.i
        b-price-list.b-code
        b-price-list.doc-num
        v-is-Chg
      }
    end.
    if v-is-Chg = true then do:
      find first ub.goods no-lock
        where ub.goods.prod-type = b-price-list.prod-type
          and ub.goods.prod-code = b-price-list.prod-code
          and ub.goods.artic     = b-price-list.artic
        .
      find first ub.gds-prt no-lock
        where ub.gds-prt.upper-code = ub.goods.prt-root .

      assign
        v-part-code = "":U
        pr-doc-rb = b-price-list.price-sale
        pr-doc-rubl = b-price-list.price-sale
        .
      { gbl/bcodeprc.i
        b-price-list.obj-type
        b-price-list.obj-code
        b-price-list.b-code
        0
        b-price-list.fact-order
        cur-dn
        pr-doc-rb-old
        cur-rt
        cur-ex
        no-error }

      assign
        pr-doc-rubl-old = pr-doc-rb-old
      .

      if v-rb-is-base = true
        and v-base-code <> 0
      then do:
        assign
          pr-doc-rubl = pr-doc-rubl * curr-rate
          pr-doc-rubl-old = pr-doc-rubl-old * curr-rate
        .
      end.
      CASE BCodeType:
        when "main" then do:
/*  Не понятно почему нельзя  :-(.
if ub.gds-prt.node-name <> {&empty-scale}*/
/*            AND v-cntxp-doc-prt*/
/*          then do:*/
/*            message "Товар ~"" ub.goods.gds-name "~" (" ub.goods.artic " " ub.goods.prod-type " " ub.goods.prod-code ") "*/
/*                            " имеет признаки !" SKIP*/
/*                            "Этикетка не может быть распечатана из документа переоценки !"*/
/*                            view-as alert-box MESSAGE.*/
/*          end.*/
/*          else do:*/
          if TickOnS   and  b-price-list.main-price = no then do:
              find first ub.bar-code no-lock
              where ub.bar-code.gds-code  = ub.goods.gds-code
                and ub.bar-code.unit-cli  = ub.goods.unit-base
                and ub.bar-code.b-code = ub.b-price-list.b-code
              no-error .
              if available ub.bar-code then do:
               nakl-qnty = b-price-list.doc-qnty .
              { rep/ticket.i }
              end.
          end.
          else if not TickOnS and b-price-list.main-price then do:
            find first ub.bar-code no-lock
              where ub.bar-code.gds-code  = ub.goods.gds-code
                and ub.bar-code.unit-cli  = ub.goods.unit-base
                and ub.bar-code.node-code = ub.gds-prt.node-code
                and ub.bar-code.part-code = ""
                and ub.bar-code.in-code   = ""
              .

            if ub.bar-code.b-code = b-price-list.b-code then do:
              assign
                nakl-qnty = b-price-list.doc-qnty
             .
              { rep/ticket.i }
            end.
          end.               /*end.*/
        end.
      when "part" then do:
        for each ub.parts no-lock
          where ub.parts.obj-type = b-price-list.obj-type
            and ub.parts.obj-code = b-price-list.obj-code
            and ub.parts.artic = ub.goods.artic
            and ub.parts.prod-type = ub.goods.prod-type
            and ub.parts.prod-code = ub.goods.prod-code
            and ub.parts.out-code = b-price-list.doc-num
        :
            find first ub.bar-code no-lock
              where ub.bar-code.gds-code = ub.goods.gds-code
                and ub.bar-code.unit-cli = ub.goods.unit-base
                and ub.bar-code.node-code = ub.gds-prt.node-code
                and ub.bar-code.part-code = ub.parts.part-code
                and ub.bar-code.in-code = ub.parts.in-code
              no-error.
            if available ub.bar-code
              and ( ( ub.bar-code.in-code <> ""
                      and b-price-list.b-code = ub.bar-code.b-code
                    )
                    or ( ub.bar-code.in-code = ""
                         and b-price-list.main-price = true
                       )
                  )
            then do:
              assign
                nakl-qnty = ( if can-do( {&act-overvalue}, ub.price-doc.status_ ) then ub.parts.fact-qnty else ub.parts.qnty )
                v-part-code = ub.parts.part-code
              .
              { rep/ticket.i }
            end.
          end.
        end.
        when "subs" then  do:
          if TickOnS   and  b-price-list.main-price = no then do:
              find first ub.bar-code no-lock
              where ub.bar-code.gds-code  = ub.goods.gds-code
                and ub.bar-code.unit-cli  = ub.goods.unit-base
                and ub.bar-code.b-code = ub.b-price-list.b-code
              no-error .
              if available ub.bar-code then do:
               nakl-qnty = b-price-list.doc-qnty .
              { rep/ticket.i }
              end.
          end.
          else do:
            find first ub.bar-code no-lock
              where ub.bar-code.gds-code  = ub.goods.gds-code
                and ub.bar-code.unit-cli  = unitname
                and ub.bar-code.node-code = ub.gds-prt.node-code
                and ub.bar-code.part-code = ""
                and ub.bar-code.in-code   = ""
              no-error.
            if available ub.bar-code then do:
              { rep/ticket.i }
            end.
          end.
        end.
      end case.
    end.
  end.                  /* for each b-price-list where ... */

  end.

end procedure. /* tick-price-line */



if DocType = "trn" then do:
  run tick-trn.
end.
else do: /* DocType = "price" */
  run tick-price.
end.


{ rep/tick-end.i }