block-level on error undo, throw.
/*

$Revision: 36493b7e3299, 155, rls $
$Author: EShklyar $
$Date: Tue Feb 17 18:03:53 2015 +0400 $
$Workfile: 00038000.p $
$Archive: cut/00038000.p $

Файл пирога обрезания. Относится к категории 38.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/05/09
Author: Dmitry Ukhanov
Creation date: 08/05/09

Обработка таблиц:
c-rvs-doc
c-rvs-line
c-rvs-line-pump

*/

define variable vss-revision    as character no-undo init "$Revision: 36493b7e3299, 155, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Feb 17 18:03:53 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00038000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00038000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 38.".
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ utl/tt-objs.i  }

define buffer old-c-rvs-doc  for src.c-rvs-doc.
define buffer new-c-rvs-doc  for dst.c-rvs-doc.
define buffer old-c-rvs-line for src.c-rvs-line.
define buffer new-c-rvs-line for dst.c-rvs-line.
define buffer old-c-rvs-line-pump for src.c-rvs-line-pump.
define buffer new-c-rvs-line-pump for dst.c-rvs-line-pump.

do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }

on WRITE of dst.c-rvs-doc  override do: end.
on WRITE of dst.c-rvs-line override do: end.
on WRITE of dst.c-rvs-line-pump override do: end.

define variable v-beg-fact-order as integer no-undo .

define buffer buf_clients for src.clients .

if not varstay-history  then return .

if vardate-actual-docs <> ? then do:

  run day-begin-fact-order in this-procedure
    ( input vardate-actual-docs
     ,output v-beg-fact-order
    ).

  for each buf_clients no-lock
    where buf_clients.db-num <> ?
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    if vartype-cut = 1 then do:
      find first tt-objs where tt-objs.obj-type = buf_clients.obj-type and
                               tt-objs.obj-code = buf_clients.obj-code no-error.
    end.
    if vartype-cut = 0      or
       (vartype-cut = 1 and available tt-objs) then do:
      for each old-c-rvs-doc no-lock
        where old-c-rvs-doc.obj-type   = buf_clients.obj-type
          and old-c-rvs-doc.obj-code   = buf_clients.obj-code
          and old-c-rvs-doc.status_    = {&fact}
          and old-c-rvs-doc.fact-order >= v-beg-fact-order
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
      :
        run copy-body in this-procedure.
      end.
    end.
    else do:
      for each old-c-rvs-doc no-lock
        where old-c-rvs-doc.obj-type   = buf_clients.obj-type
          and old-c-rvs-doc.obj-code   = buf_clients.obj-code
          and old-c-rvs-doc.status_    = {&fact}
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
      :
        run copy-body in this-procedure.
      end.
    end.
  end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: c-rvs-doc c-rvs-line c-rvs-line-pump ".
end.
procedure copy-body:
create new-c-rvs-doc.
buffer-copy old-c-rvs-doc to new-c-rvs-doc.
for each old-c-rvs-line no-lock
  where old-c-rvs-line.rvs-code = old-c-rvs-doc.rvs-code and
        old-c-rvs-line.chip-num = old-c-rvs-doc.chip-num
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  create new-c-rvs-line.
  buffer-copy old-c-rvs-line to new-c-rvs-line.
end.
for each old-c-rvs-line-pump no-lock
  where old-c-rvs-line-pump.rvs-code = old-c-rvs-doc.rvs-code and
        old-c-rvs-line-pump.chip-num = old-c-rvs-doc.chip-num
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  create new-c-rvs-line-pump.
  buffer-copy old-c-rvs-line-pump to new-c-rvs-line-pump.
end.
end procedure.