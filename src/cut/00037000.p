block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00037000.p $
$Archive: cut/00037000.p $

Файл пирога обрезания. Относится к категории 37.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/05/09
Author: Dmitry Ukhanov
Creation date: 08/05/09

Обработка таблиц:
rvs-doc
rvs-doc-attr
rvs-line
rvs-line-attr
rvs-line-pump
rvs-line-pump-attr
rvs-pump
rvs-pump-attr


*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00037000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00037000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 37.".
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ utl/tt-objs.i  }

define buffer old-rvs-doc  for src.rvs-doc.
define buffer new-rvs-doc  for dst.rvs-doc.
define buffer old-rvs-doc-attr  for src.rvs-doc-attr.
define buffer new-rvs-doc-attr  for dst.rvs-doc-attr.
define buffer old-rvs-line for src.rvs-line.
define buffer new-rvs-line for dst.rvs-line.
define buffer old-rvs-line-attr for src.rvs-line-attr.
define buffer new-rvs-line-attr for dst.rvs-line-attr.
define buffer old-rvs-line-pump for src.rvs-line-pump.
define buffer new-rvs-line-pump for dst.rvs-line-pump.
define buffer old-rvs-line-pump-attr for src.rvs-line-pump-attr.
define buffer new-rvs-line-pump-attr for dst.rvs-line-pump-attr.
define buffer old-rvs-pump for src.rvs-pump.
define buffer new-rvs-pump for dst.rvs-pump.
define buffer old-rvs-pump-attr for src.rvs-pump-attr.
define buffer new-rvs-pump-attr for dst.rvs-pump-attr.



do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }

on WRITE of dst.rvs-doc       override do: end.
on WRITE of dst.rvs-doc-attr  override do: end.
on WRITE of dst.rvs-line      override do: end.
on WRITE of dst.rvs-line-attr override do: end.
on WRITE of dst.rvs-line-pump override do: end.
on WRITE of dst.rvs-line-pump-attr override do: end.
on WRITE of dst.rvs-pump override do: end.
on WRITE of dst.rvs-pump-attr override do: end.


define variable v-beg-fact-order as integer no-undo .

define buffer buf_clients for src.clients .

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
      for each old-rvs-doc no-lock
         where old-rvs-doc.obj-type   = buf_clients.obj-type
           and old-rvs-doc.obj-code   = buf_clients.obj-code
           and old-rvs-doc.status_    = {&fact}
           and old-rvs-doc.fact-order >= v-beg-fact-order
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
      :
        run copy-body in this-procedure.
      end.
    end.
    else do:
      for each old-rvs-doc no-lock
         where old-rvs-doc.obj-type   = buf_clients.obj-type
           and old-rvs-doc.obj-code   = buf_clients.obj-code
           and old-rvs-doc.status_    = {&fact}
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
      :
        run copy-body in this-procedure.
      end.
    end.
  end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: rvs-doc rvs-doc-attr rvs-line rvs-line-attr rvs-line-pump rvs-line-pump-attr rvs-pump rvs-pump-attr ".
end.

procedure copy-body:
create new-rvs-doc.                                                                                                        ~
buffer-copy old-rvs-doc to new-rvs-doc.                                                                                    ~
for each old-rvs-line no-lock                                                                                              ~
  where old-rvs-line.rvs-code = old-rvs-doc.rvs-code                                                                       ~
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) ~
:                                                                                                                          ~
  create new-rvs-line.                                                                                                     ~
  buffer-copy old-rvs-line to new-rvs-line.                                                                                ~
end.                                                                                                                       ~
for each old-rvs-line-attr no-lock                                                                                              ~
  where old-rvs-line-attr.rvs-code = old-rvs-doc.rvs-code                                                                       ~
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) ~
:                                                                                                                          ~
  create new-rvs-line-attr.                                                                                                     ~
  buffer-copy old-rvs-line-attr to new-rvs-line-attr.                                                                                ~
end.                                                                                                                       ~
for each old-rvs-line-pump no-lock                                                                                         ~
  where old-rvs-line-pump.rvs-code = old-rvs-doc.rvs-code                                                                  ~
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) ~
:                                                                                                                          ~
  create new-rvs-line-pump.                                                                                                ~
  buffer-copy old-rvs-line-pump to new-rvs-line-pump.                                                                      ~
end.
for each old-rvs-line-pump-attr no-lock                                                                                         ~
  where old-rvs-line-pump-attr.rvs-code = old-rvs-doc.rvs-code                                                                  ~
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) ~
:                                                                                                                          ~
  create new-rvs-line-pump-attr.                                                                                                ~
  buffer-copy old-rvs-line-pump-attr to new-rvs-line-pump-attr.                                                                      ~
end.
for each old-rvs-pump no-lock                                                                                         ~
  where old-rvs-pump.rvs-code = old-rvs-doc.rvs-code                                                                  ~
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) ~
:                                                                                                                          ~
  create new-rvs-pump.                                                                                                ~
  buffer-copy old-rvs-pump to new-rvs-pump.                                                                      ~
end.
for each old-rvs-pump-attr no-lock                                                                                         ~
  where old-rvs-pump-attr.rvs-code = old-rvs-doc.rvs-code                                                                  ~
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) ~
:                                                                                                                          ~
  create new-rvs-pump-attr.                                                                                                ~
  buffer-copy old-rvs-pump-attr to new-rvs-pump-attr.                                                                      ~
end.
for each old-rvs-doc-attr no-lock                                                                                              ~
  where old-rvs-doc-attr.rvs-code = old-rvs-doc.rvs-code                                                                       ~
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) ~
:                                                                                                                          ~
  create new-rvs-doc-attr.                                                                                                     ~
  buffer-copy old-rvs-doc-attr to new-rvs-doc-attr.                                                                                ~
end.                                                                                                                       ~
                                                                                                             ~
end procedure.