block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: u-ind.p $
$Archive: ref/u-ind.p $

Изменение ИЖТ по списку товаров

Автор: Чернова Светлана Александровна
Дата создания: 03/29/05
Author: Svetlana Chernova
Creation date: 03/29/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type    as character no-undo .
define input parameter p-obj-code    as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: u-ind.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/u-ind.p $":U .
define variable vss-description as character no-undo init "Изменение ИЖТ по списку товаров".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ cmp/obj-list.i new }

define variable  v-old as character no-undo .
define variable  v-new as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .

run create_obj-list ( p-obj-type , p-obj-code ) .


  run ref/graf-igt.w
      (output v-old, output v-new ).

  if not(v-old = "" and v-new = "")  then do:
      { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
      run str/gds-list.w
          (input parparentproc, input v-host-code, input p-obj-type, input p-obj-code ).
      run ref/chg-igt.p
          (input v-old, input v-new ,input true ) no-error  .
          if error-status :error then do:
              message vss-workfile vss-revision vss-description skip
              error-status :get-message(1)
              return-value
              .
          return .
          end.
  message "Изменение ИЖТ по списку товаров на объекте " + p-obj-type + " " + string(p-obj-code) + " завершено ." view-as alert-box information .
  end.
