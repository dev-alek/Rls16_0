block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00037001.p $
$Archive: cut/00037001.p $

Файл пирога обрезания. Относится к категории 37.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/05/09
Author: Dmitry Ukhanov
Creation date: 08/05/09


Обработка таблиц:
icnt-doc
icnt-line

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00037001.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00037001.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 37.".
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ utl/tt-objs.i  }
define variable v-beg-fact-order as integer no-undo .

define buffer buf_clients for src.clients .

define buffer old-icnt-doc       for src.icnt-doc.
define buffer old-next-icnt-doc  for src.icnt-doc.
define buffer new-icnt-doc       for dst.icnt-doc.
define buffer old-icnt-line      for src.icnt-line.
define buffer old-next-icnt-line for src.icnt-line.
define buffer new-icnt-line      for dst.icnt-line.
define variable varfind-next-line as logical no-undo.

do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }

on WRITE of dst.icnt-doc  override do: end.
on WRITE of dst.icnt-line override do: end.
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
      for each old-icnt-doc where old-icnt-doc.obj-type  =  buf_clients.obj-type and
                                  old-icnt-doc.obj-code  =  buf_clients.obj-code and
                                  old-icnt-doc.status_   =  {&fact}               no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        if old-icnt-doc.fact-date >= vardate-actual-docs then do:
          run copy-body in this-procedure.
        end.
        else do:
          old-icnt-line:
          for each old-icnt-line where old-icnt-line.doc-code = old-icnt-doc.doc-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
            assign
              varfind-next-line = no.
            for first old-next-icnt-doc where old-next-icnt-doc.obj-type   = old-icnt-doc.obj-type   and
                                              old-next-icnt-doc.obj-code   = old-icnt-doc.obj-code   and
                                              old-next-icnt-doc.status_    = {&fact}                 and
                                              old-next-icnt-doc.fact-order > old-icnt-doc.fact-order no-lock,
              first old-next-icnt-line where old-next-icnt-line.doc-code    = old-next-icnt-doc.doc-code and
                                             old-next-icnt-line.obj-type    = old-icnt-line.obj-type     and
                                             old-next-icnt-line.obj-code    = old-icnt-line.obj-code     and
                                             old-next-icnt-line.pump-code   = old-icnt-line.pump-code    and
                                             old-next-icnt-line.nozzle-code = old-icnt-line.nozzle-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
              assign
                varfind-next-line = yes.
            end.
            if varfind-next-line = no then do:
              run copy-body in this-procedure.
              leave old-icnt-line.
            end.
          end.
        end.
      end.
    end.
    else do:
      for each old-icnt-doc where old-icnt-doc.obj-type  =  buf_clients.obj-type and
                                  old-icnt-doc.obj-code  =  buf_clients.obj-code and
                                  old-icnt-doc.status_   =  {&fact}              no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          run copy-body in this-procedure.
      end.
    end.
  end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: icnt-doc icnt-line.".
end.
procedure copy-body:
create new-icnt-doc.
buffer-copy old-icnt-doc to new-icnt-doc.
for each old-icnt-line where old-icnt-line.doc-code = old-icnt-doc.doc-code no-lock :
   create new-icnt-line.
   buffer-copy old-icnt-line to new-icnt-line.
end.
end procedure.