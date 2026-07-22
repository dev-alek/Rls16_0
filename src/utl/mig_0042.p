block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mig_0042.p $
$Archive: utl/mig_0042.p $

Модификация таблиц  раздела Договоры

Автор: Чернова Светлана Александровна
Дата создания: 12/08/08
Author: Svetlana Chernova
Creation date: 12/08/08

*/

using Ibs.Th.Gbl.ProgressBar.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mig_0042.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mig_0042.p $":U .
define variable vss-description as character no-undo init "Модификация таблиц раздела Договоры".

{ cmp/vssrevis.i    }
{ utl/mig_0001.i    }
{ rep/prg-bar.i def }
{ rep/prg-bar.i run }


define variable v-progress-bar as class ProgressBar no-undo .
run prg-bar_init-cb-handle in this-procedure ( this-procedure ) .
define variable v-tot-rec as int64 no-undo .


run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Договоры") ).

{ utl/mig_0040.i "shared" }

on delete of ub.contract              override do: end.
on delete of ub.contract-attr         override do: end.
on delete of ub.contract-line         override do: end.
on delete of ub.contract-line-attr    override do: end.
on delete of ub.contract-specif       override do: end.
on delete of ub.contract-specif-attr  override do: end.
on delete of ub.c-contract            override do: end.
on delete of ub.c-contract-line       override do: end.
on delete of ub.c-contract-specif     override do: end.

  do
  on error undo, return error return-value
  :
  v-tot-rec = 0 .
  for each temp-sysconf no-lock where
    v-tot-rec = v-tot-rec + 1.
  end.

  run prg-bar_new in this-procedure ( 1, v-tot-rec).
  run prg-bar_title in this-procedure ( input "Обработка таблицы Договоры...":U).
  run prg-bar_show in this-procedure .

    for each temp-sysconf :
    run prg-bar_increment in this-procedure .

    for each ub.contract exclusive-lock where
             ub.contract.host-code = temp-sysconf.host-code :
        for each ub.contract-attr        exclusive-lock where
                 ub.contract-attr.host-code = temp-sysconf.host-code
             and ub.contract-attr.contract-code = ub.contract.contract-code :
             delete ub.contract-attr.
        end.
        for each ub.contract-line        exclusive-lock where
                 ub.contract-line.host-code = temp-sysconf.host-code
             and ub.contract-line.contract-num = ub.contract.contract-code :
            delete ub.contract-line.
        end.
        for each ub.contract-line-attr   exclusive-lock where
            ub.contract-line-attr.host-code = temp-sysconf.host-code
            and ub.contract-line-attr.contract-num = ub.contract.contract-code :
            delete ub.contract-line-attr.
        end.
        for each ub.contract-specif      exclusive-lock where
                 ub.contract-specif.host-code = temp-sysconf.host-code
             and ub.contract-specif.contract-num = ub.contract.contract-code :
             delete ub.contract-specif.
        end.


        for each ub.contract-specif-attr exclusive-lock where
                 ub.contract-specif-attr.host-code = temp-sysconf.host-code
             and ub.contract-specif-attr.contract-num = ub.contract.contract-code :
             delete ub.contract-specif-attr.
        end.

        for each ub.c-contract           exclusive-lock where
                 ub.c-contract.host-code     = temp-sysconf.host-code
             and ub.c-contract.contract-code = ub.contract.contract-code :
          delete ub.c-contract.
        end.

        for each ub.c-contract-line      exclusive-lock where
                 ub.c-contract-line.host-code = temp-sysconf.host-code
             and ub.c-contract-line.contract-num = ub.contract.contract-code :
             delete ub.c-contract-line.
        end.

        for each ub.c-contract-specif    exclusive-lock where
             ub.c-contract-specif.host-code = temp-sysconf.host-code
         and ub.c-contract-specif.contract-num = ub.contract.contract-code :
            delete ub.c-contract-specif.
         end.
       delete ub.contract.
    end.
    end.

    run prg-bar_delete-progress-bar in this-procedure .
end.