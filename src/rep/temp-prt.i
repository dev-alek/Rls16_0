/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполнение таблицы остатков товара по объектам

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/
{ gbl/cur-time.i }

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character no-undo format "x(65)":U initial "@(#)$Workfile$ $Revision$".

define temp-table temp_prt-obj no-undo
  field artic       like ub.prt-obj.artic
  field obj-type    like ub.prt-obj.obj-type
  field obj-code    like ub.prt-obj.obj-code
  field host-code   like ub.prt-obj.host-code
  field obj-name    like ub.clients.obj-name
  field qnty        like ub.prt-obj.fact-qnty
  field free-qnty   like ub.prt-obj.free-qnty
  field price       like ub.prt-obj.price-sale
&if '{1}' = 'kg' &then
  field fact-qty-kg like ub.prt-obj.fact-qnty
  field free-qty-kg like ub.prt-obj.free-qnty
  field price-kg    like ub.prt-obj.price-sale
&endif
  field sdate       like ub.trn-doc.fact-date
  field stime       as   character
  field stime-int   as   integer
  field db-num      like ub.db.db-num
  field db-name     like ub.db.db-name
  index pi          is   unique primary           obj-type obj-code
  index ie1                             host-code obj-type obj-code
.

procedure fill-temp_prt-obj :
  define input  parameter p-artic       as character no-undo .
  define input  parameter p-prod-type   as character no-undo .
  define input  parameter p-prod-code   as integer   no-undo .
  define input  parameter p-host-code   as integer   no-undo .
  define input  parameter p-node        as integer   no-undo .
  define input  parameter p-firm-global as character no-undo .
&if '{1}' = 'kg' &then
  define input  parameter p-is-ptrl     as logical   no-undo .
&endif
  define output parameter p-total-fact  as decimal   no-undo .
  define output parameter p-total-sum   as decimal   no-undo .
&if '{1}' = 'kg' &then
  define output parameter p-fact-kg     as decimal   no-undo .
  /* define output parameter p-sum-kg      as decimal   no-undo . */
&endif

  do on error undo, return error return-value :
    define buffer buf_temp_prt-obj for temp_prt-obj .
    define buffer buf_prt-obj      for ub.prt-obj .
    define buffer buf_clients      for ub.clients .
    define buffer buf_db           for ub.db .
    define buffer buf_trn-doc      for ub.trn-doc .
    define buffer buf_db-status    for ub.db-status .

    for each buf_temp_prt-obj on error undo, return error return-value :
      delete buf_temp_prt-obj .
    end.

    if p-firm-global = "firm" then do: /* одна фирма */
      for each buf_prt-obj no-lock where
               buf_prt-obj.artic     = p-artic     and
               buf_prt-obj.prod-type = p-prod-type and
               buf_prt-obj.prod-code = p-prod-code and
               buf_prt-obj.prt-code  = p-node      and
               buf_prt-obj.host-code = p-host-code on error undo, return error return-value :
        find buf_temp_prt-obj no-lock where
             buf_temp_prt-obj.artic    = buf_prt-obj.artic    and
             buf_temp_prt-obj.obj-type = buf_prt-obj.obj-type and
             buf_temp_prt-obj.obj-code = buf_prt-obj.obj-code no-error .
        if not available buf_temp_prt-obj then do:
          create buf_temp_prt-obj.
          assign buf_temp_prt-obj.artic     = buf_prt-obj.artic
                 buf_temp_prt-obj.obj-type  = buf_prt-obj.obj-type
                 buf_temp_prt-obj.obj-code  = buf_prt-obj.obj-code
                 buf_temp_prt-obj.host-code = p-host-code
                 buf_temp_prt-obj.qnty      = buf_prt-obj.fact-qnty
                 buf_temp_prt-obj.free-qnty = buf_prt-obj.free-qnty
                 buf_temp_prt-obj.price     = buf_prt-obj.price-sale
                 buf_temp_prt-obj.obj-name  = ?
                 buf_temp_prt-obj.sdate     = ?
                 buf_temp_prt-obj.stime     = ?
                 buf_temp_prt-obj.stime-int = ?
                 buf_temp_prt-obj.db-num    = ?
                 buf_temp_prt-obj.db-name   = ?
          .
&if '{1}' = 'kg' &then
        if p-is-ptrl = yes then do:
          run get-weight-qty in this-procedure ( buffer buf_prt-obj,
                                                 output buf_temp_prt-obj.free-qty-kg,
                                                 output buf_temp_prt-obj.fact-qty-kg  ) no-error.
          if error-status :error then do: undo, return error return-value. end.
          run get-weight-prc in this-procedure ( buffer buf_prt-obj,
                                                 output buf_temp_prt-obj.price-kg     ) no-error.
          if error-status :error then do: undo, return error return-value. end.
        end. /* petrol */
&endif
        end. /* if not available buf_temp_prt-obj */
      end. /* for each buf_prt-obj */
    end. /* одна фирма */
    else do: /* все фирмы */
      for each buf_prt-obj no-lock where
               buf_prt-obj.artic     = p-artic     and
               buf_prt-obj.prod-type = p-prod-type and
               buf_prt-obj.prod-code = p-prod-code and
               buf_prt-obj.prt-code  = p-node      on error undo, return error return-value :
        find buf_temp_prt-obj no-lock where
             buf_temp_prt-obj.artic    = buf_prt-obj.artic    and
             buf_temp_prt-obj.obj-type = buf_prt-obj.obj-type and
             buf_temp_prt-obj.obj-code = buf_prt-obj.obj-code no-error .
        if not available buf_temp_prt-obj then do:
          create buf_temp_prt-obj.
          assign buf_temp_prt-obj.artic     = buf_prt-obj.artic
                 buf_temp_prt-obj.obj-type  = buf_prt-obj.obj-type
                 buf_temp_prt-obj.obj-code  = buf_prt-obj.obj-code
                 buf_temp_prt-obj.host-code = ?
                 buf_temp_prt-obj.qnty      = buf_prt-obj.fact-qnty
                 buf_temp_prt-obj.free-qnty = buf_prt-obj.free-qnty
                 buf_temp_prt-obj.price     = buf_prt-obj.price-sale
                 buf_temp_prt-obj.obj-name  = ?
                 buf_temp_prt-obj.sdate     = ?
                 buf_temp_prt-obj.stime     = ?
                 buf_temp_prt-obj.stime-int = ?
                 buf_temp_prt-obj.db-num    = ?
                 buf_temp_prt-obj.db-name   = ?
          .
&if '{1}' = 'kg' &then
        if p-is-ptrl = yes then do:
          run get-weight-qty in this-procedure ( buffer buf_prt-obj,
                                                 output buf_temp_prt-obj.free-qty-kg,
                                                 output buf_temp_prt-obj.fact-qty-kg  ) no-error.
          if error-status :error then do: undo, return error return-value. end.
          run get-weight-prc in this-procedure ( buffer buf_prt-obj,
                                                 output buf_temp_prt-obj.price-kg     ) no-error.
          if error-status :error then do: undo, return error return-value. end.
        end. /* petrol */
&endif
        end. /* if not available buf_temp_prt-obj */
      end. /* for each buf_prt-obj */
    end. /* все фирмы */

    assign
      p-total-fact = 0
      p-total-sum  = 0
    .

    for each buf_temp_prt-obj on error undo, return error return-value :
      assign
        p-total-fact = p-total-fact + buf_temp_prt-obj.qnty
        p-total-sum  = p-total-sum  + buf_temp_prt-obj.qnty        * buf_temp_prt-obj.price
&if '{1}' = 'kg' &then
        p-fact-kg    = p-fact-kg    + buf_temp_prt-obj.fact-qty-kg
        /* p-sum-kg     = p-sum-kg     + buf_temp_prt-obj.fact-qty-kg * buf_temp_prt-obj.price-kg */
&endif
      .

      find first buf_clients no-lock where
                 buf_clients.obj-type = buf_temp_prt-obj.obj-type and
                 buf_clients.obj-code = buf_temp_prt-obj.obj-code no-error .
      if available buf_clients then do:
        assign
          buf_temp_prt-obj.db-num   = buf_clients.db-num
          buf_temp_prt-obj.obj-name = buf_clients.obj-name
        .
      end.

      find first buf_db no-lock where buf_db.db-num = buf_temp_prt-obj.db-num no-error.
      if available buf_db then do:
        assign
          buf_temp_prt-obj.db-num  = buf_db.db-num
          buf_temp_prt-obj.db-name = buf_db.db-name
        .
      end.

      if buf_temp_prt-obj.db-num = g#db-num then do:
        run cur-time in this-procedure ( output buf_temp_prt-obj.sdate, output buf_temp_prt-obj.stime-int ) .
      end.
      else do:
        find first buf_db-status no-lock where buf_db-status.db-num = buf_temp_prt-obj.db-num no-error .
        if available buf_db-status then do:
          assign
            buf_temp_prt-obj.sdate     = buf_db-status.stock-date
            buf_temp_prt-obj.stime-int = buf_db-status.stock-time
          .
        end.
      end.
      if buf_temp_prt-obj.stime-int <> ? then do:
        assign
          buf_temp_prt-obj.stime = string( buf_temp_prt-obj.stime-int, 'HH:MM:SS':U )
        .
      end.
    end. /* for each buf_temp_prt-obj */
  end. /* on error */
end procedure. /* fill-temp_prt-obj */

&if '{1}' = 'kg' &then
  procedure get-weight-qty :
    define        parameter buffer loc-prt-obj   for ub.prt-obj.
    define output parameter        p-free-qty-kg as  decimal no-undo initial 0.0.
    define output parameter        p-fact-qty-kg as  decimal no-undo initial 0.0.

    define buffer buf_doc-line for ub.doc-line.
    define buffer buf_inv-line for ub.inv-line.

    do on error undo, return error return-value :
      if available loc-prt-obj then do:
        for each buf_doc-line no-lock where
                 buf_doc-line.obj-type   = loc-prt-obj.obj-type  and
                 buf_doc-line.obj-code   = loc-prt-obj.obj-code  and
                 buf_doc-line.prod-type  = loc-prt-obj.prod-type and
                 buf_doc-line.prod-code  = loc-prt-obj.prod-code and
                 buf_doc-line.artic      = loc-prt-obj.artic     and
                 buf_doc-line.status_    = {&fact}               and
                 buf_doc-line.fact-order > 0                     use-index fact-order
              by buf_doc-line.fact-order   descending :
          find first buf_inv-line no-lock where
                     buf_inv-line.doc-code  = buf_doc-line.doc-code  and
                     buf_inv-line.artic     = buf_doc-line.artic     and
                     buf_inv-line.prod-code = buf_doc-line.prod-code and
                     buf_inv-line.prod-type = buf_doc-line.prod-type no-error.
          if available buf_inv-line then do:
            assign p-fact-qty-kg = ( if buf_inv-line.after-cli-qnty = ? then 0.0 else buf_inv-line.after-cli-qnty ).
            if loc-prt-obj.free-qnty <> ? and loc-prt-obj.fact-qnty <> ? and loc-prt-obj.fact-qnty <> 0.0 then do:
              assign p-free-qty-kg = loc-prt-obj.free-qnty / loc-prt-obj.fact-qnty * p-fact-qty-kg.
            end.
            leave.
          end. /* if available buf_inv-line */
        end. /* for each buf_doc-line */
      end. /* if available loc-prt-obj */
    end. /* on error */
  end procedure. /* get-weight-qty */

  procedure get-weight-prc :
    define        parameter buffer loc-prt-obj  for ub.prt-obj.
    define output parameter        p-price-sale as  decimal no-undo initial 0.0.

    define variable is-base as logical no-undo.

    define buffer buf_doc-line for ub.doc-line.
    define buffer buf_inv-line for ub.inv-line.

    do on error undo, return error return-value :
      if available loc-prt-obj then do:
        { gbl/rbisbase.i is-base no-error }
        if error-status :error then do: return error return-value. end.
        for each buf_doc-line no-lock where
                 buf_doc-line.obj-type   = loc-prt-obj.obj-type  and
                 buf_doc-line.obj-code   = loc-prt-obj.obj-code  and
                 buf_doc-line.prod-type  = loc-prt-obj.prod-type and
                 buf_doc-line.prod-code  = loc-prt-obj.prod-code and
                 buf_doc-line.artic      = loc-prt-obj.artic     and
                 buf_doc-line.status_    = {&fact}               and
                 buf_doc-line.fact-order > 0                     use-index fact-order
              by buf_doc-line.fact-order   descending :
          find first buf_inv-line no-lock where
                     buf_inv-line.doc-code  = buf_doc-line.doc-code  and
                     buf_inv-line.artic     = buf_doc-line.artic     and
                     buf_inv-line.prod-code = buf_doc-line.prod-code and
                     buf_inv-line.prod-type = buf_doc-line.prod-type no-error.
          if available buf_inv-line then do:
            assign p-price-sale = ( if is-base = yes then buf_inv-line.wast-base else buf_inv-line.wast-rubl ).
            leave.
          end. /* if available buf_inv-line */
        end. /* for each buf_doc-line */
      end. /* if available loc-prt-obj */
    end. /* on error */
  end procedure. /* get-weight-prc */
&endif

/* $Workfile$   E n d */

