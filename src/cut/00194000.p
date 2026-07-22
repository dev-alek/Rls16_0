block-level on error undo, throw.
/*

$Revision: 36493b7e3299, 155, rls $
$Author: EShklyar $
$Date: Tue Feb 17 18:03:53 2015 +0400 $
$Workfile: 00194000.p $
$Archive: cut/00194000.p $

Файл пирога обрезания. Относится к категории 194.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/06
Author: Bakhtadze Natalya
Creation date: 06/23/06

Обработка таблиц:
c-wth-doc
c-wth-line
c-wth-dtl
c-wth-parts

*/

define variable vss-revision    as character no-undo init "$Revision: 36493b7e3299, 155, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Feb 17 18:03:53 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00194000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00194000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 194.".
define buffer old-c-wth-doc    for src.c-wth-doc.
define buffer new-c-wth-doc    for dst.c-wth-doc.
define buffer old-c-wth-line   for src.c-wth-line.
define buffer new-c-wth-line   for dst.c-wth-line.
define buffer old-c-wth-dtl    for src.c-wth-dtl.
define buffer new-c-wth-dtl    for dst.c-wth-dtl.
define buffer old-c-wth-parts   for src.c-wth-parts.
define buffer new-c-wth-parts   for dst.c-wth-parts.



define buffer new-shop         for dst.shop .
define buffer new-store        for dst.store .

define variable var-fact-order-docs as decimal no-undo .
define variable v-host-code like src.sysconf.host-code no-undo .

define stream LogStream.

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ utl/tt-objs.i  }


do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }
on WRITE of dst.c-wth-doc    override do: end.
on WRITE of dst.c-wth-line   override do: end.
on WRITE of dst.c-wth-dtl    override do: end.
on WRITE of dst.c-wth-parts  override do: end.

if not varstay-history  then return. 
if vardate-actual-docs <> ? then do:
   run factord-end-day in this-procedure ( vardate-actual-docs - 1, output var-fact-order-docs).

  for each new-shop no-lock
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    if vartype-cut = 1 then do:
      find first tt-objs where tt-objs.obj-type = {&shop} and
                                tt-objs.obj-code = new-shop.obj-code no-error.
    end.
    if vartype-cut = 0      or
        (vartype-cut = 1 and available tt-objs) then do:
      for each old-c-wth-doc where old-c-wth-doc.host-code  = new-shop.host-code and
                              old-c-wth-doc.obj-type  = {&shop} and
                                old-c-wth-doc.obj-code   = new-shop.obj-code and
                                old-c-wth-doc.status_    = {&fact}              and
                                old-c-wth-doc.fact-order >= var-fact-order-docs  no-lock
      use-index stat-fact
      on error undo, return error
      :
      create new-c-wth-doc.
      buffer-copy old-c-wth-doc to new-c-wth-doc.

        for each old-c-wth-line no-lock
          where old-c-wth-line.doc-code = new-c-wth-doc.doc-code
          and   old-c-wth-line.chip-num = new-c-wth-doc.chip-num
          and   old-c-wth-line.corr-user-db-num = new-c-wth-doc.corr-user-db-num
        on error undo, return error
        :
            create new-c-wth-line.
            buffer-copy old-c-wth-line to new-c-wth-line.
        end.

        for each old-c-wth-dtl no-lock
          where old-c-wth-dtl.doc-code  = new-c-wth-doc.doc-code
          and   old-c-wth-dtl.chip-num = new-c-wth-doc.chip-num
          and   old-c-wth-dtl.corr-user-db-num = new-c-wth-doc.corr-user-db-num
        on error undo, return error
        :
          create new-c-wth-dtl.
          buffer-copy old-c-wth-dtl to new-c-wth-dtl.
          for each  old-c-wth-parts no-lock
          where old-c-wth-parts.obj-type = new-c-wth-doc.obj-type
            and old-c-wth-parts.obj-code = new-c-wth-doc.obj-code
            and old-c-wth-parts.w-p-code = new-c-wth-dtl.w-p-code
            and old-c-wth-parts.wth-code = new-c-wth-dtl.wth-code
            and old-c-wth-parts.par-code = new-c-wth-dtl.par-code
            and old-c-wth-parts.out-code  = new-c-wth-doc.doc-code
        on error undo, return error
        :
           if   old-c-wth-parts.chip-num = new-c-wth-doc.chip-num
            and   old-c-wth-parts.corr-user-db-num = new-c-wth-doc.corr-user-db-num then next.
            create new-c-wth-parts.
            buffer-copy old-c-wth-parts to new-c-wth-parts.
          end.
        end.
      end. /*for each old-c-wth-doc where old-c-wth-doc.obj-type  = new-clients.obj-type and*/
    end. /*if vartype-cut = 0      or*/
    run export-c-wth-parts in this-procedure ( input {&shop}, input new-shop.obj-code).
  end. /*for each new-shop no-lock*/

  for each new-store no-lock
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    if vartype-cut = 1 then do:
      find first tt-objs where tt-objs.obj-type = {&stock} and
                                tt-objs.obj-code = new-store.obj-code no-error.
    end.
    if vartype-cut = 0      or
        (vartype-cut = 1 and available tt-objs) then do:
      for each old-c-wth-doc where old-c-wth-doc.host-code  = new-store.host-code and
                              old-c-wth-doc.obj-type  = {&stock} and
                                old-c-wth-doc.obj-code   = new-store.obj-code and
                                old-c-wth-doc.status_    = {&fact}              and
                                old-c-wth-doc.fact-order >= var-fact-order-docs  no-lock
      use-index stat-fact
      on error undo, return error
      :
      create new-c-wth-doc.
      buffer-copy old-c-wth-doc to new-c-wth-doc.

        for each old-c-wth-line no-lock
          where old-c-wth-line.doc-code = new-c-wth-doc.doc-code
          and   old-c-wth-line.chip-num = new-c-wth-doc.chip-num
          and   old-c-wth-line.corr-user-db-num = new-c-wth-doc.corr-user-db-num
        on error undo, return error
        :
            create new-c-wth-line.
            buffer-copy old-c-wth-line to new-c-wth-line.
        end.

        for each old-c-wth-dtl no-lock
          where old-c-wth-dtl.doc-code  = new-c-wth-doc.doc-code
          and   old-c-wth-dtl.chip-num = new-c-wth-doc.chip-num
          and   old-c-wth-dtl.corr-user-db-num = new-c-wth-doc.corr-user-db-num
        on error undo, return error
        :
          create new-c-wth-dtl.
          buffer-copy old-c-wth-dtl to new-c-wth-dtl.
          for each  old-c-wth-parts no-lock
          where old-c-wth-parts.obj-type = new-c-wth-doc.obj-type
            and old-c-wth-parts.obj-code = new-c-wth-doc.obj-code
            and old-c-wth-parts.w-p-code = new-c-wth-dtl.w-p-code
            and old-c-wth-parts.wth-code = new-c-wth-dtl.wth-code
            and old-c-wth-parts.par-code = new-c-wth-dtl.par-code
            and old-c-wth-parts.out-code  = new-c-wth-doc.doc-code
        on error undo, return error
        :
           if   old-c-wth-parts.chip-num = new-c-wth-doc.chip-num
            and   old-c-wth-parts.corr-user-db-num = new-c-wth-doc.corr-user-db-num then next.
            create new-c-wth-parts.
            buffer-copy old-c-wth-parts to new-c-wth-parts.
          end.

        end.
      end. /*for each old-c-wth-doc where old-c-wth-doc.obj-type  = new-clients.obj-type and*/
    end.
    run export-c-wth-parts in this-procedure ( input {&stock}, input new-store.obj-code).
  end. /*for each new-store no-lock*/
end. /*if vardate-actual-docs <> ? then do:*/


procedure export-c-wth-parts :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define buffer new-wth-gds for dst.wth-gds.
define buffer new-wth-parts for dst.wth-parts.

/*
NDEX-FIELD "obj-type" ASCENDING
INDEX-FIELD "obj-code" ASCENDING
INDEX-FIELD "w-p-code" ASCENDING
INDEX-FIELD "wth-code" ASCENDING
INDEX-FIELD "par-code" ASCENDING
INDEX-FIELD "in-code" ASCENDING
INDEX-FIELD "out-code" ASCENDING
INDEX-FIELD "ser-code" ASCENDING
INDEX-FIELD "db-num" ASCENDING
INDEX-FIELD "fact-rangeFrom" ASCENDING
INDEX-FIELD "fact-rangeTo" ASCENDING

*/

for each new-wth-parts no-lock where
        new-wth-parts.obj-type = p-obj-type
    and new-wth-parts.obj-code = p-obj-code,
    each old-c-wth-parts no-lock
    where old-c-wth-parts.obj-type  = p-obj-type
      and old-c-wth-parts.obj-code  = p-obj-code
      and old-c-wth-parts.w-p-code = new-wth-parts.w-p-code
      and old-c-wth-parts.wth-code = new-wth-parts.wth-code
      and old-c-wth-parts.par-code = new-wth-parts.par-code
      and old-c-wth-parts.in-code = new-wth-parts.in-code
      and old-c-wth-parts.out-code = new-wth-parts.out-code
      and old-c-wth-parts.ser-code = new-wth-parts.ser-code
      and old-c-wth-parts.db-num = new-wth-parts.db-num
      and old-c-wth-parts.fact-rangeFrom = new-wth-parts.fact-rangefrom
      and old-c-wth-parts.fact-rangeto = new-wth-parts.fact-rangeto
  on error undo, return error
  :
      create new-c-wth-parts.
      buffer-copy old-c-wth-parts to new-c-wth-parts.
  end.
end procedure. /* export-c-wth-parts */

output stream str-gen close.
return "Произведен экспорт таблиц: c-wth-doc c-wth-line c-wth-dtl c-wth-parts".
end. /*do*/