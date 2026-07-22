block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: showcli.p $
$Archive: ref/showcli.p $

Показать клиента

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type    as character no-undo .
define input parameter p-obj-code    as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: showcli.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/showcli.p $":U .
define variable vss-description as character no-undo init "Показать клиента".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define var loc#log as logical no-undo.

define buffer buf_sysconf for ub.sysconf .

do
on error undo, return error return-value
:
  find first ub.clients no-lock
    where ub.clients.obj-type = p-obj-type
      and ub.clients.obj-code = p-obj-code
    no-error .
  if not available ub.clients
  then do:
    message
      "Ошибка задания входных параметров" skip
      "Не найден клиент" p-obj-type p-obj-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  define variable ri as recid no-undo .

  assign
    ri = recid (ub.clients)
  .

  CASE p-obj-type :
    when {&cmp}
    then do:
      { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_client-reference_lookup':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      loc#log
      }
      if not loc#log
      then do:
        return.
      end.

      find first buf_sysconf no-lock
        where buf_sysconf.host-code = ub.clients.obj-code
        no-error .
      if available buf_sysconf
      then do:
        /* показать собственную фирму */
        run adm/config.w
          (input  parparentproc
          ,input  ub.clients.obj-code
          ,input  {&lookup}
          ,input  false
          ) .
      end.
      else do:
        run ref/firmi.w
          (input  parparentproc
          ,input  {&lookup}
          ,input  ub.clients.obj-code
          ,input  ub.clients.grp-code
          ,input  "cli-all"
          ,input-output ri
          ) .
      end.
    end.
    when {&prs}
    then do:
      { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_client-reference_lookup':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      loc#log
      }
      if not loc#log
      then do:
        return.
      end.
      run ref/personi.w
        (input  parparentproc
        ,input  {&lookup}
        ,input  ub.clients.obj-code
        ,input  ub.clients.grp-code
        ,input  'cli-all':U
        ,input-output ri
        ).
    end.
    when {&shop}
    then do:
      run adm/shopi.w
        (input  parParentProc
        ,input  0                   /* p-host-code - на просмотр можно 0!*/
        ,input  ub.clients.obj-code
        ,input  {&lookup}
        ,input-output ri
        ).
    end.
    when {&stock}
    then do:
      run adm/storei.w
        (input  parParentProc
        ,input  0                   /* p-host-code - на просмотр можно 0!*/
        ,input  ub.clients.obj-code
        ,input  {&lookup}
        ,input-output ri
        ).
    end.
    otherwise do:
      message
        "showcli.p: Неизвестный тип клиента" skip
        "p-obj-type" p-obj-type skip
        view-as alert-box error .
      return .
    end.
  end case .

end.