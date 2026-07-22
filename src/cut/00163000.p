block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00163000.p $
$Archive: cut/00163000.p $

Файл пирога обрезания. Относится к категории 163.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/05/09
Author: Bakhtadze Natalya
Creation date: 08/05/09

Обработка таблиц:
sert
c-sert
sert-attr
sert-join
sert-join-attr

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00163000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00163000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 163.".

{ cmp/str-glbl.i }


define buffer old-sert           for src.sert.
define buffer new-sert           for dst.sert.
define buffer old-c-sert         for src.c-sert.
define buffer new-c-sert         for dst.c-sert.
define buffer old-sert-attr      for src.sert-attr.
define buffer new-sert-attr      for dst.sert-attr.
define buffer old-sert-join      for src.sert-join.
define buffer new-sert-join      for dst.sert-join.
define buffer old-sert-join-attr for src.sert-join-attr.
define buffer new-sert-join-attr for dst.sert-join-attr.


define buffer new-clients   for dst.clients.
define buffer new-bar-code  for dst.bar-code.

define variable varmoved-sert as logical no-undo.
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }
on WRITE of dst.sert      override do: end.
on WRITE of dst.c-sert         override do: end.
on WRITE of dst.sert-attr      override do: end.
on WRITE of dst.sert-join override do: end.
on WRITE of dst.sert-join-attr override do: end.

for each old-sert no-lock ,
   first new-clients where new-clients.obj-type = old-sert.cli-type and
                           new-clients.obj-code = old-sert.cli-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   assign varmoved-sert = yes.
   old-sert-join-label:
   for each old-sert-join where old-sert-join.cli-type  = old-sert.cli-type  and
                                old-sert-join.cli-code  = old-sert.cli-code  and
                                old-sert-join.sert-code = old-sert.sert-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
       find first new-bar-code where new-bar-code.b-code = old-sert-join.b-code no-lock no-error.
       if not available new-bar-code then do:
          assign varmoved-sert = no.
          leave old-sert-join-label.
       end.
   end.
   if varmoved-sert = yes then do:
      create new-sert.
      buffer-copy old-sert to new-sert.
      for each old-sert-join where old-sert-join.cli-type  = old-sert.cli-type  and
                                   old-sert-join.cli-code  = old-sert.cli-code  and
                                   old-sert-join.sert-code = old-sert.sert-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
         create new-sert-join.
         buffer-copy old-sert-join to new-sert-join.
      end.
      for each old-sert-join-attr where old-sert-join-attr.cli-type  = old-sert.cli-type  and
                                   old-sert-join-attr.cli-code  = old-sert.cli-code  and
                                   old-sert-join-attr.sert-code = old-sert.sert-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
         create new-sert-join-attr.
         buffer-copy old-sert-join-attr to new-sert-join-attr.
      end.
      if varstay-history then do:
        for each old-c-sert where old-c-sert.cli-type  = old-sert.cli-type  and
                                    old-c-sert.cli-code  = old-sert.cli-code  and
                                    old-c-sert.sert-code = old-sert.sert-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          create new-c-sert.
          buffer-copy old-c-sert to new-c-sert.
        end.
      end.
      for each old-sert-attr where old-sert-attr.cli-type  = old-sert.cli-type  and
                                   old-sert-attr.cli-code  = old-sert.cli-code  and
                                   old-sert-attr.sert-code = old-sert.sert-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
         create new-sert-attr.
         buffer-copy old-sert-attr to new-sert-attr.
      end.
   end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: sert c-sert sert-attr sert-join sert-joint-attr.".
end.