block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: snd-grup.p $
$Archive: str/snd-grup.p $

Пересылка групп товара по всем объектам БД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/13/04
Author: Bakhtadze Natalya
Creation date: 05/13/04

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-parameter   as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: snd-grup.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/snd-grup.p $":U .
define variable vss-description as character no-undo init "Пересылка групп товара по всем объектам БД".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }


define variable v-view-log as logical no-undo .
define variable log-file-name as character no-undo init "send-cd.txt".
define variable v-stop as logical no-undo .
define variable p-db-num like ub.db.db-num no-undo .

assign
p-db-num = integer(p-parameter)
no-error .

def buffer cli-shops for ub.clients.

FOR EACH cli-shops no-lock where
          cli-shops.obj-type = {&shop} and
          cli-shops.db-num = p-db-num:


  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Отсылка групп товаров на кассы магазина &1", cli-shops.obj-code)
                                        ).

  run str/sendgrup.p (   input parparentproc
                    ,input p-parent-handle
                    ,input p-log-handle
                    ,input(string(cli-shops.obj-code) + {&delim-par} + "R":U )
                                              ) .


  if error-status:error or
  return-value = "yes":U then do:
    run set-view-log in p-log-handle(yes).
  end.

end.

run get-stop-state in p-log-handle (output v-stop).


run get-view-log in p-log-handle(output v-view-log).
{ str/cdviewlg.i
"'!!!При отсылке информации на кассы произошли ошибки!!!'"
"'send-cd.txt'" }