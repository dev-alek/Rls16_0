block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: plgdpust.p $
$Archive: utl/plgdpust.p $

Утилита по простановке статуса в записи pl-gds-pump

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: plgdpust.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/plgdpust.p $":U .
define variable vss-description as character no-undo init "Утилита по простановке статуса в записи pl-gds-pump".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
define buffer bf_clients         for ub.clients.
define buffer bf_pl-gds-pump     for ub.pl-gds-pump.
define buffer bf-cur_pl-gds-pump for ub.pl-gds-pump.
for each bf_clients where bf_clients.db-num = g#db-num on error undo, return error return-value :
  for each bf_pl-gds-pump where bf_pl-gds-pump.obj-type = bf_clients.obj-type and
                                bf_pl-gds-pump.obj-code = bf_clients.obj-code on error undo, return error return-value :
    if bf_pl-gds-pump.status_ = "" or
       bf_pl-gds-pump.status_ = ?  then do:
      find first bf-cur_pl-gds-pump where bf-cur_pl-gds-pump.obj-type  = bf_pl-gds-pump.obj-type  and
                                          bf-cur_pl-gds-pump.obj-code  = bf_pl-gds-pump.obj-code  and
                                          bf-cur_pl-gds-pump.gds-code  = bf_pl-gds-pump.gds-code  and
                                          bf-cur_pl-gds-pump.pump-code = bf_pl-gds-pump.pump-code and
                                          bf-cur_pl-gds-pump.pl-code  <> bf_pl-gds-pump.pl-code   and
                                          bf-cur_pl-gds-pump.status_   = {&current-status}        no-lock no-error.
      if available bf-cur_pl-gds-pump then do:
        assign
          bf_pl-gds-pump.status_ = {&blocked-status}.
      end.
      else do:
        assign
          bf_pl-gds-pump.status_ = {&current-status}.
      end.
    end.
  end.
end.
message "Смена статусов записей Резервуар-ТРК-Товар успешно завершена." view-as alert-box information.