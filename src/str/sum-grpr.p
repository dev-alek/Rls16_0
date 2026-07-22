block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sum-grpr.p $
$Archive: str/sum-grpr.p $

Запуск справочника групп товаров на кассах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sum-grpr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sum-grpr.p $":U .
define variable vss-description as character no-undo init "Запуск справочника групп товаров на кассах".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/getcntxt.i def }

DEFINE VARIABLE rid-list as character no-undo .
DEFINE VARIABLE choice as integer no-undo .
DEFINE VARIABLE v-exit  as logical no-undo .
define buffer buf_clients for ub.clients.

do
on error undo, return error
:

  { gbl/getcntxt.i get }
  find first buf_clients No-LOCK WHERE
             buf_clients.obj-type = v-cntxt-obj-type
         AND buf_clients.obj-code = v-cntxt-obj-code.
  do while v-exit = no:
    if v-cntxt-obj-type = {&shop} and buf_clients.db-num = v-cntxt-db-num then do:
      run gbl/d-askw.w (input "Работа со справочником групп товаров на кассах",
                    input "Выберите нужную функцию",
                    input "|^",
                    input "Работа со справочником|Передача на кассу|Удаление с кассы|Выход",
                    input "|||",
                    input 1,
                    input 4,
                    output choice).
      if choice = 4 then do:
        assign
        v-exit = yes
        .
        return.
      end.
    end.
    else do:
      run gbl/d-askw.w (input "Работа со справочником групп товаров на кассах",
                    input "Выберите нужную функцию",
                    input "|^",
                    input "Работа со справочником|Передача на кассу^disable|Удаление с кассы^disable|Выход",
                    input "|||",
                    input 1,
                    input 4,
                    output choice).
      if choice = 4 then do:
        assign
        v-exit = yes
        .
        return.
      end.
    end.

    CASE choice:
      when 1 then do:
        case v-cntxt-db-num :
          when 0 then do:
            run ref/sum-grps.w ( input parparentproc
                                ,input 'b-add':U
                                ,input-output rid-list).
          end.
          otherwise do:
            run ref/sum-grps.w ( input parparentproc
                                ,input  '':U
                                ,input-output rid-list).
          end.
        END CASE.
      end.
      when 2 then do:
        run str/sndgrup.p ( input parparentproc
                           ,input v-cntxt-obj-code
                           ,input 'U'
                           ,input '':U).
      end.
      when 3 then do:
        run str/sndgrup.p ( input parparentproc
                           ,input v-cntxt-obj-code
                           ,input 'D'
                           ,input '':U).
      end.
    END CASE.
  end. /*while v-exit*/

end.