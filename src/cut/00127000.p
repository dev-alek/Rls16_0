block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00127000.p $
$Archive: cut/00127000.p $

Файл пирога обрезания. Относится к категории 127.

Автор: Чернова Светлана Александровна
Дата создания: 05/25/09
Author: Svetlana Chernova
Creation date: 05/25/09

Обработка таблиц:
ord-blank
ord-doc
ord-line
ord-dtl
ord-doc-rcv
ord-line-rcv
ord-dtl-rcv
c-ord-doc
c-ord-line
c-ord-doc-attr
c-ord-dtl
c-ord-line-attr


ord-cons
ord-gds-cons
ord-dtl-cons

ord-cons-attr
ord-cons-line-attr

ord-doc-attr
ord-line-attr

ord-rcv-attr
ord-rcv-line-attr

ord-chain
ord-chain-attr
ord-blank-attr
ord-dtl-attr

edi-status - частично

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00127000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00127000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 127.".
{ cmp/str-glbl.i }

define buffer old-ord-blank for src.ord-blank.
define buffer new-ord-blank for dst.ord-blank.

define buffer old-ord-doc   for src.ord-doc  .
define buffer new-ord-doc   for dst.ord-doc  .

define buffer old-edi-status   for src.edi-status  .
define buffer new-edi-status   for dst.edi-status  .


define buffer old-c-ord-doc   for src.c-ord-doc  .
define buffer new-c-ord-doc   for dst.c-ord-doc  .

define buffer old-c-ord-doc-attr   for src.c-ord-doc-attr  .
define buffer new-c-ord-doc-attr   for dst.c-ord-doc-attr  .

define buffer old-ord-doc-attr   for src.ord-doc-attr  .
define buffer new-ord-doc-attr   for dst.ord-doc-attr  .

define buffer old-ord-line  for src.ord-line .
define buffer new-ord-line  for dst.ord-line .

define buffer old-c-ord-line  for src.c-ord-line .
define buffer new-c-ord-line  for dst.c-ord-line .
define buffer old-c-ord-line-attr  for src.c-ord-line-attr .
define buffer new-c-ord-line-attr  for dst.c-ord-line-attr .


define buffer old-c-ord-dtl  for src.c-ord-dtl .
define buffer new-c-ord-dtl  for dst.c-ord-dtl .


define buffer old-ord-line-attr  for src.ord-line-attr .
define buffer new-ord-line-attr  for dst.ord-line-attr .

define buffer old-ord-dtl   for src.ord-dtl .
define buffer new-ord-dtl   for dst.ord-dtl .

define buffer old-ord-doc-rcv   for src.ord-doc-rcv  .
define buffer new-ord-doc-rcv   for dst.ord-doc-rcv  .

define buffer old-ord-rcv-attr   for src.ord-rcv-attr  .
define buffer new-ord-rcv-attr   for dst.ord-rcv-attr  .

define buffer old-ord-line-rcv  for src.ord-line-rcv .
define buffer new-ord-line-rcv  for dst.ord-line-rcv .

define buffer old-ord-rcv-line-attr   for src.ord-rcv-line-attr  .
define buffer new-ord-rcv-line-attr   for dst.ord-rcv-line-attr  .

define buffer old-ord-dtl-rcv   for src.ord-dtl-rcv .
define buffer new-ord-dtl-rcv   for dst.ord-dtl-rcv .

define buffer new-ord-cons     for dst.ord-cons.
define buffer new-ord-gds-cons for dst.ord-gds-cons.
define buffer new-ord-dtl-cons for dst.ord-dtl-cons.

define buffer old-ord-cons     for src.ord-cons.
define buffer old-ord-gds-cons for src.ord-gds-cons.
define buffer old-ord-dtl-cons for src.ord-dtl-cons.

define buffer new-ord-cons-attr       for dst.ord-cons-attr      .
define buffer new-ord-cons-line-attr  for dst.ord-cons-line-attr .
define buffer old-ord-cons-attr       for src.ord-cons-attr      .
define buffer old-ord-cons-line-attr  for src.ord-cons-line-attr .

define buffer new-ord-chain           for dst.ord-chain                .
define buffer new-ord-chain-attr      for dst.ord-chain-attr           .
define buffer new-ord-blank-attr      for dst.ord-blank-attr           .
define buffer new-ord-dtl-attr        for dst.ord-dtl-attr             .
define buffer old-ord-chain           for src.ord-chain                .
define buffer old-ord-chain-attr      for src.ord-chain-attr           .
define buffer old-ord-blank-attr      for src.ord-blank-attr           .
define buffer old-ord-dtl-attr        for src.ord-dtl-attr             .

define buffer old-sysconf     for src.sysconf.

define buffer new-shop        for dst.shop.
define buffer new-store       for dst.store.

define buffer new-clients   for dst.clients.

do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
{ utl/00000001.i }
{ cmp/library.i  }
{ trg/factord.i  }
define variable v-beg-fact-order as integer no-undo .
{ utl/tt-objs.i  }

define buffer buf_clients for src.clients .

on WRITE of dst.ord-blank             override do: end.
on WRITE of dst.ord-doc               override do: end.
on WRITE of dst.ord-line              override do: end.
on WRITE of dst.ord-dtl               override do: end.
on WRITE of dst.ord-doc-rcv           override do: end.
on WRITE of dst.ord-line-rcv          override do: end.
on WRITE of dst.ord-dtl-rcv           override do: end.
on WRITE of dst.c-ord-doc            override do: end.
on WRITE of dst.c-ord-doc-attr            override do: end.
on WRITE of dst.c-ord-line           override do: end.
on WRITE of dst.c-ord-line-attr           override do: end.
on WRITE of dst.c-ord-dtl           override do: end.
on WRITE of dst.ord-cons             override do: end.
on WRITE of dst.ord-gds-cons         override do: end.
on WRITE of dst.ord-dtl-cons         override do: end.
on WRITE of dst.ord-cons-attr        override do: end.
on WRITE of dst.ord-cons-line-attr   override do: end.
on WRITE of dst.ord-doc-attr         override do: end.
on WRITE of dst.ord-line-attr        override do: end.
on WRITE of dst.ord-rcv-attr         override do: end.
on WRITE of dst.ord-rcv-line-attr    override do: end.
on WRITE of dst.ord-chain            override do: end.
on WRITE of dst.ord-chain-attr       override do: end.
on WRITE of dst.ord-blank-attr       override do: end.
on WRITE of dst.ord-dtl-attr         override do: end.
on WRITE of dst.edi-status           override do: end.


define variable my-fact-order as decimal   no-undo .
run day-begin-fact-order (input vardate-actual-docs , output my-fact-order) .

for each old-ord-blank no-lock,
    first new-clients where new-clients.obj-type = old-ord-blank.cli-type and
                            new-clients.obj-code = old-ord-blank.cli-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-ord-blank.
    buffer-copy old-ord-blank to new-ord-blank.
    for each old-ord-blank-attr no-lock where
             old-ord-blank-attr.blank-name   = new-ord-blank.blank-name  and
             old-ord-blank-attr.cli-code     = new-ord-blank.cli-code    and
             old-ord-blank-attr.cli-type     = new-ord-blank.cli-type    :
        create new-ord-blank-attr.
        buffer-copy old-ord-blank-attr to new-ord-blank-attr.
    end.
end.

if vardate-actual-docs <> ? then do:
  for each buf_clients no-lock  where
          buf_clients.db-num <> ?
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :

    if vartype-cut = 1 then do:
        find first tt-objs where tt-objs.obj-type = buf_clients.obj-type and
                                tt-objs.obj-code = buf_clients.obj-code no-error.
    end.

    if vartype-cut = 0      or
        (vartype-cut = 1 and available tt-objs) then do:
          run proc-bod .
/*          run proc-bod ( input {&o-p}) .
          run proc-bod ( input {&f-p}) .
          run proc-bod ( input {&o-f}) .
          run proc-bod ( input {&o-o}) .
          run proc-bod ( input {&o-r}) .   */
          run proc-bod-cons .
          run proc-bod-rcv .
    end.
    else do:
          run proc-bod1 ( input {&o-p}) .
          run proc-bod1 ( input {&f-p}) .
          run proc-bod1 ( input {&o-f}) .
          run proc-bod1 ( input {&o-o}) .
          run proc-bod1 ( input {&o-r}) .
          run proc-bod1-cons .
          run proc-bod1-rcv .
    end.
  end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц для заказов .".
end.



procedure proc-bod :

  do
  on error undo, return error return-value
  :

/*define input  parameter p-val as character no-undo .*/

  /* for each old-sysconf no-lock :  */
      for each old-ord-doc where
          /*old-ord-doc.host-code = old-sysconf.host-code and    */
          old-ord-doc.obj-code  = buf_clients.obj-code and
          old-ord-doc.obj-type  = buf_clients.obj-type and
          /*old-ord-doc.doc-type  = p-val and */
          old-ord-doc.fact-order >= my-fact-order   and
          old-ord-doc.status_ = {&fact}
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          if old-ord-doc.doc-type <> {&o-p} and      /*На всякий случай проверка по типу. */
            old-ord-doc.doc-type <> {&f-p} and
            old-ord-doc.doc-type <> {&o-f} and
            old-ord-doc.doc-type <> {&o-o} and
            old-ord-doc.doc-type <> {&o-r} then next.
         run make-2 .
      end.
      for each old-ord-doc where
          /*old-ord-doc.host-code = old-sysconf.host-code and   */
          old-ord-doc.obj-code  = buf_clients.obj-code and
          old-ord-doc.obj-type  = buf_clients.obj-type and
        /*  old-ord-doc.doc-type  = p-val and  */
          old-ord-doc.status_ = {&ord-rcv}
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          if old-ord-doc.doc-type <> {&o-p} and      /*На всякий случай проверка по типу. */
            old-ord-doc.doc-type <> {&f-p} and
            old-ord-doc.doc-type <> {&o-f} and
            old-ord-doc.doc-type <> {&o-o} and
            old-ord-doc.doc-type <> {&o-r} then next.

         run make-2 .
      end.
      for each old-ord-doc where
        /*  old-ord-doc.host-code = old-sysconf.host-code and */
          old-ord-doc.obj-code  = buf_clients.obj-code and
          old-ord-doc.obj-type  = buf_clients.obj-type and
          /*old-ord-doc.doc-type  = p-val and  */
          old-ord-doc.status_ = {&ord-accept}
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          if old-ord-doc.doc-type <> {&o-p} and      /*На всякий случай проверка по типу. */
            old-ord-doc.doc-type <> {&f-p} and
            old-ord-doc.doc-type <> {&o-f} and
            old-ord-doc.doc-type <> {&o-o} and
            old-ord-doc.doc-type <> {&o-r} then next.

         run make-2 .
      end.
      for each old-ord-doc where
       /*   old-ord-doc.host-code = old-sysconf.host-code and  */
          old-ord-doc.obj-code  = buf_clients.obj-code and
          old-ord-doc.obj-type  = buf_clients.obj-type and
          /*old-ord-doc.doc-type  = p-val and  */
          old-ord-doc.status_ = {&g___new}
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          if old-ord-doc.doc-type <> {&o-p} and      /*На всякий случай проверка по типу. */
            old-ord-doc.doc-type <> {&f-p} and
            old-ord-doc.doc-type <> {&o-f} and
            old-ord-doc.doc-type <> {&o-o} and
            old-ord-doc.doc-type <> {&o-r} then next.

         run make-2 .
      end.
      for each old-ord-doc where
       /*   old-ord-doc.host-code = old-sysconf.host-code and  */
          old-ord-doc.obj-code  = buf_clients.obj-code and
          old-ord-doc.obj-type  = buf_clients.obj-type and
          /*old-ord-doc.doc-type  = p-val and  */
          old-ord-doc.status_ = {&ord-per}
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          if old-ord-doc.doc-type <> {&o-p} and      /*На всякий случай проверка по типу. */
            old-ord-doc.doc-type <> {&f-p} and
            old-ord-doc.doc-type <> {&o-f} and
            old-ord-doc.doc-type <> {&o-o} and
            old-ord-doc.doc-type <> {&o-r} then next.

         run make-2 .
      end.

   /*end. */
end.
end procedure. /* proc-bod */

procedure proc-bod-cons :
  do
  on error undo, return error return-value
  :

   if buf_clients.obj-type = {&cmp} then do :
      for each old-ord-cons where
          old-ord-cons.host-code  = buf_clients.obj-code and
          old-ord-cons.status_    = {&fact} and
          old-ord-cons.fact-date >= vardate-actual-docs

          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-ord-cons.
          buffer-copy old-ord-cons to new-ord-cons.

          /* ord-gds-cons */
          for each old-ord-gds-cons where
                   old-ord-gds-cons.cons-code = new-ord-cons.cons-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-gds-cons.
              buffer-copy old-ord-gds-cons to new-ord-gds-cons.
          end.
          /* ord-dtl-cons */
          for each old-ord-dtl-cons where
                   old-ord-dtl-cons.cons-code = new-ord-cons.cons-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-dtl-cons.
              buffer-copy old-ord-dtl-cons to new-ord-dtl-cons.
          end.
          /* ord-cons-attr */
          for each old-ord-cons-attr where
                   old-ord-cons-attr.cons-code = new-ord-cons.cons-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-cons-attr.
              buffer-copy old-ord-cons-attr to new-ord-cons-attr.
          end.
          /* ord-cons-line-attr */
          for each old-ord-cons-line-attr where
                   old-ord-cons-line-attr.cons-code = new-ord-cons.cons-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-cons-line-attr.
              buffer-copy old-ord-cons-line-attr to new-ord-cons-line-attr.
          end.
      end.
  end.



  end.
end procedure. /* proc-bod */


procedure proc-bod-rcv :

  do
  on error undo, return error return-value
  :
      for each old-ord-doc-rcv where
          old-ord-doc-rcv.obj-code  = buf_clients.obj-code and
          old-ord-doc-rcv.obj-type  = buf_clients.obj-type and
          old-ord-doc-rcv.status_   = {&fact}  and
          old-ord-doc-rcv.doc-code  = ""     and
          old-ord-doc-rcv.fact-order >= my-fact-order
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              run make-in.
      end.
  end.
end procedure. /* proc-bod */

procedure make-in :

  do
  on error undo, return error return-value
  :
  if can-find (first new-ord-doc-rcv no-lock where
                    new-ord-doc-rcv.rcv-code = old-ord-doc-rcv.rcv-code and
                    new-ord-doc-rcv.doc-code = old-ord-doc-rcv.doc-code ) then return .
    create new-ord-doc-rcv.
    buffer-copy old-ord-doc-rcv to new-ord-doc-rcv.


    for each  old-ord-chain where
              old-ord-chain.doc-code = new-ord-doc-rcv.rcv-code and
              old-ord-chain.doc-type = 'rcv'  and
              old-ord-chain.rel-doc-type = 'trn'
              no-lock on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):

        create new-ord-chain no-error .
        buffer-copy old-ord-chain to new-ord-chain no-error .
        if not error-status :error then do:
          for each  old-ord-chain-attr where
                    old-ord-chain-attr.db-num = new-ord-chain.db-num and
                    old-ord-chain-attr.rel-id = new-ord-chain.rel-id
                    no-lock on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
             find first new-ord-chain-attr no-lock where
                        new-ord-chain-attr.db-num = new-ord-chain.db-num and
                        new-ord-chain-attr.rel-id = new-ord-chain.rel-id no-error .
              if not available new-ord-chain-attr then do:
                create new-ord-chain-attr.
                buffer-copy old-ord-chain-attr to new-ord-chain-attr.
              end.
          end.
        end.
    end.


    /* ord-line-rcv */
    for each old-ord-line-rcv where
              old-ord-line-rcv.doc-code = new-ord-doc-rcv.doc-code and
              old-ord-line-rcv.rcv-code = new-ord-doc-rcv.rcv-code
              no-lock on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-ord-line-rcv.
        buffer-copy old-ord-line-rcv to new-ord-line-rcv.
    end.

    /* ord-dtl-rcv */
    for each old-ord-dtl-rcv where
             old-ord-dtl-rcv.doc-code = new-ord-doc-rcv.doc-code and
             old-ord-dtl-rcv.rcv-code = new-ord-doc-rcv.rcv-code
             no-lock on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-ord-dtl-rcv.
        buffer-copy old-ord-dtl-rcv to new-ord-dtl-rcv.
    end.

    /* ord-rcv-attr */
    for each old-ord-rcv-attr where
              old-ord-rcv-attr.doc-code = new-ord-doc-rcv.doc-code and
              old-ord-rcv-attr.rcv-code = new-ord-doc-rcv.rcv-code
              no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-ord-rcv-attr.
        buffer-copy old-ord-rcv-attr to new-ord-rcv-attr.
    end.

    /* ord-rcv-line-attr */
    for each old-ord-rcv-line-attr where
              old-ord-rcv-line-attr.doc-code = new-ord-doc-rcv.doc-code and
              old-ord-rcv-line-attr.rcv-code = new-ord-doc-rcv.rcv-code
              no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-ord-rcv-line-attr.
        buffer-copy old-ord-rcv-line-attr to new-ord-rcv-line-attr.
    end.

  end.

end procedure. /* make-in */


procedure make-2 :

  do
  on error undo, return error return-value
  :

          create new-ord-doc.
          buffer-copy old-ord-doc to new-ord-doc.

          /* ord-line */
          for each old-ord-line where
                   old-ord-line.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-line.
              buffer-copy old-ord-line to new-ord-line.
          end.
          /* ord-dtl */
          for each old-ord-dtl where
                   old-ord-dtl.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-dtl.
              buffer-copy old-ord-dtl to new-ord-dtl.
          end.

          /* ord-dtl-attr */
          for each old-ord-dtl-attr where
                   old-ord-dtl-attr.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-dtl-attr.
              buffer-copy old-ord-dtl-attr to new-ord-dtl-attr.
          end.

          /* ord-line-attr */
          for each old-ord-line-attr where
                   old-ord-line-attr.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-line-attr.
              buffer-copy old-ord-line-attr to new-ord-line-attr.
          end.
          /* ord-doc-attr */
          for each old-ord-doc-attr where
                   old-ord-doc-attr.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-doc-attr.
              buffer-copy old-ord-doc-attr to new-ord-doc-attr.
          end.
          /* ord-line-rcv */
          for each old-ord-doc-rcv where
                   old-ord-doc-rcv.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
            create new-ord-doc-rcv.
            buffer-copy old-ord-doc-rcv to new-ord-doc-rcv.

            /* edi-status */
            if new-ord-doc.whole-send-news > 0 then do:
              for each old-edi-status where
                        old-edi-status.tbl-name = {&table_ord-doc-rcv}
                    and old-edi-status.doc-code = new-ord-doc-rcv.rcv-code
                        no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                  create new-edi-status.
                  buffer-copy old-edi-status to new-edi-status.
              end.
              for each old-edi-status where
                        old-edi-status.tbl-name = {&table_ord-line-rcv}
                    and old-edi-status.doc-code begins (new-ord-doc-rcv.rcv-code + {&delim-par} )
                        no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                  create new-edi-status.
                  buffer-copy old-edi-status to new-edi-status.
              end.
            end. /*if new-ord-doc.whole-send-nes > 0 then do:*/
          end.

          /* ord-line-rcv */
          for each old-ord-line-rcv where
                   old-ord-line-rcv.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-line-rcv.
              buffer-copy old-ord-line-rcv to new-ord-line-rcv.
          end.

          /* ord-dtl-rcv */
          for each old-ord-dtl-rcv where
                   old-ord-dtl-rcv.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-dtl-rcv.
              buffer-copy old-ord-dtl-rcv to new-ord-dtl-rcv.
          end.

    /* ord-rcv-attr */
    for each old-ord-rcv-attr where
              old-ord-rcv-attr.doc-code = new-ord-doc.doc-code
              no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-ord-rcv-attr.
        buffer-copy old-ord-rcv-attr to new-ord-rcv-attr.
    end.

    /* ord-rcv-line-attr */
    for each old-ord-rcv-line-attr where
              old-ord-rcv-line-attr.doc-code = new-ord-doc.doc-code
              no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-ord-rcv-line-attr.
        buffer-copy old-ord-rcv-line-attr to new-ord-rcv-line-attr.
    end.

    /* edi-status */
    if new-ord-doc.whole-send-news > 0 then do:
      for each old-edi-status where
                old-edi-status.tbl-name = {&table_ord-doc}
            and old-edi-status.doc-code = new-ord-doc.doc-code
                no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-edi-status.
          buffer-copy old-edi-status to new-edi-status.
      end.

      for each old-edi-status where
                old-edi-status.tbl-name = {&table_ord-line}
            and old-edi-status.doc-code begins (new-ord-doc.doc-code + {&delim-par} )
                no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-edi-status.
          buffer-copy old-edi-status to new-edi-status.
      end.
    end. /*if new-ord-doc.whole-send-news > 0 then do:*/

    /*chain*/
    for each old-ord-chain of old-ord-doc
    no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-ord-chain.
          buffer-copy old-ord-chain to new-ord-chain.

          for each old-ord-chain-attr of old-ord-chain
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-ord-chain-attr.
          buffer-copy old-ord-chain-attr to new-ord-chain-attr.

          end.

    end.

    /* Перенос если нужно истории */
    if varstay-history = true then do:
          /* c-ord-doc */
          for each old-c-ord-doc where
                   old-c-ord-doc.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-c-ord-doc.
              buffer-copy old-c-ord-doc to new-c-ord-doc.
          end.

          /* c-ord-doc-attr */
          for each old-c-ord-doc-attr where
                   old-c-ord-doc-attr.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-c-ord-doc-attr.
              buffer-copy old-c-ord-doc-attr to new-c-ord-doc-attr.
          end.

          /* c-ord-line */
          for each old-c-ord-line where
                   old-c-ord-line.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-c-ord-line.
              buffer-copy old-c-ord-line to new-c-ord-line.
          end.
          /* c-ord-line-attr */
          for each old-c-ord-line-attr where
                   old-c-ord-line-attr.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-c-ord-line-attr.
              buffer-copy old-c-ord-line-attr to new-c-ord-line-attr.
          end.

          /* c-ord-dtl */
          for each old-c-ord-dtl where
                   old-c-ord-dtl.doc-code = new-ord-doc.doc-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-c-ord-dtl.
              buffer-copy old-c-ord-dtl to new-c-ord-dtl.
          end.

    end.

  end.

end procedure. /* make-2 */


procedure proc-bod1 :

  do
  on error undo, return error return-value
  :

define input  parameter p-val as character no-undo .

   for each old-sysconf no-lock :
      for each old-ord-doc where
          old-ord-doc.host-code = old-sysconf.host-code and
          old-ord-doc.obj-code  = buf_clients.obj-code and
          old-ord-doc.obj-type  = buf_clients.obj-type and
          old-ord-doc.doc-type  = p-val
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
         run make-2 .
      end.
   end.

end.
end procedure. /* proc-bod */

procedure proc-bod1-cons :

  do
  on error undo, return error return-value
  :

   if buf_clients.obj-type = {&cmp} then do :
      for each old-ord-cons where
          old-ord-cons.host-code  = buf_clients.obj-code and
          old-ord-cons.status_    = {&fact}

          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-ord-cons.
          buffer-copy old-ord-cons to new-ord-cons.

          /* ord-gds-cons */
          for each old-ord-gds-cons where
                   old-ord-gds-cons.cons-code = new-ord-cons.cons-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-gds-cons.
              buffer-copy old-ord-gds-cons to new-ord-gds-cons.
          end.
          /* ord-dtl-cons */
          for each old-ord-dtl-cons where
                   old-ord-dtl-cons.cons-code = new-ord-cons.cons-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-dtl-cons.
              buffer-copy old-ord-dtl-cons to new-ord-dtl-cons.
          end.
          /* ord-cons-attr */
          for each old-ord-cons-attr where
                   old-ord-cons-attr.cons-code = new-ord-cons.cons-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-cons-attr.
              buffer-copy old-ord-cons-attr to new-ord-cons-attr.
          end.
          /* ord-cons-line-attr */
          for each old-ord-cons-line-attr where
                   old-ord-cons-line-attr.cons-code = new-ord-cons.cons-code
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              create new-ord-cons-line-attr.
              buffer-copy old-ord-cons-line-attr to new-ord-cons-line-attr.
          end.




      end.
  end.



  end.
end procedure. /* proc-bod */


procedure proc-bod1-rcv :

  do
  on error undo, return error return-value
  :
      for each old-ord-doc-rcv where
          old-ord-doc-rcv.obj-code  = buf_clients.obj-code and
          old-ord-doc-rcv.obj-type  = buf_clients.obj-type and
          old-ord-doc-rcv.status_    = {&fact} and
          old-ord-doc-rcv.doc-code    = ""
          no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              run make-in.
      end.
  end.
end procedure. /* proc-bod */