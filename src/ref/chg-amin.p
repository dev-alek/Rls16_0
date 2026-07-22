block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chg-amin.p $
$Archive: ref/chg-amin.p $

Процедура изменения Amin

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 05/27/05
*/

define input  parameter p-new as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chg-amin.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/chg-amin.p $":U .
define variable vss-description as character no-undo init "Процедура изменения Amin".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ cmp/obj-list.i }
{ cmp/gds-list.i  gds-list def shared }
{ ref/gds-ind1.i }

 /* Проверка прав */
 define variable v-log as logical   no-undo .
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_assort-izt_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
 if not v-log then return  .

define buffer buf_gds-obj-prop for ub.gds-obj-prop .
define buffer buf_gds-obj      for ub.gds-obj .
define variable v-i as integer   no-undo .
define variable Temp1 as integer   no-undo .

define variable v-gds-prop-recid as recid no-undo .
define variable v-num as integer no-undo init 1.


for each obj-list :
    run waitfram-show ("Объект " + obj-list.obj-name ) .
    v-i = 0.
    for each gds-list :
        v-i = v-i + 1 .
        { rep/r-mess.i v-i 1 }
        find first buf_gds-obj-prop no-lock  where
                   buf_gds-obj-prop.gds-code = gds-list.gds-code and
                   buf_gds-obj-prop.obj-code = obj-list.obj-code and
                   buf_gds-obj-prop.obj-type = obj-list.obj-type no-error .
           if not available buf_gds-obj-prop then
           do:
                find first buf_gds-obj no-lock  where
                          buf_gds-obj.gds-code = gds-list.gds-code and
                          buf_gds-obj.obj-code = obj-list.obj-code and
                          buf_gds-obj.obj-type = obj-list.obj-type no-error .
                          if available buf_gds-obj then do:
                              run gds-ind1
                                  (input-output v-gds-prop-recid
                                  ,buf_gds-obj.gds-code
                                  ,buf_gds-obj.obj-type
                                  ,buf_gds-obj.obj-code
                                  ,?
                                  ,p-new
                                  ,?
                                  ,?
                                  ,?
                                  ,?
                                  )  .

                          end.
                          else next.
           end.
           else do:
                run gds-ind1
                    (input-output v-gds-prop-recid
                    ,buf_gds-obj-prop.gds-code
                    ,buf_gds-obj-prop.obj-type
                    ,buf_gds-obj-prop.obj-code
                    ,?
                    ,p-new
                    ,?
                    ,?
                    ,?
                    ,?
                    )  .
            end.
      end.
 end.
run waitfram-hide.