block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 27 апр. 2020 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 27 апр. 2020 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

/*** при раскомментировании тела процедуры входные параметры удалить ***/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-is-dynamic as logical no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .
/****************/

/*
{rul\send1cerp.i}

procedure local-proc-main:
   define variable Vobj as class ibs.th.bge.1crn.subjects.exp-mark no-undo .
   Vobj = new ibs.th.bge.1crn.subjects.exp-mark().
   Vobj:BufHandle = m-oldbh.
   
   SubObj = cast (vobj ,ibs.th.bge.1crn.subjects.iexpsubject).
end.

procedure local-load-ruleset-context:
    case p-ruleset-id:
      when {&edoc-proc_18_event_mark_165} 
      then do:
          if    m-has-newbh
            and m-newbh:table <> {&table_marking} 
          then 
            undo, return error substitute("Передан неверный буфер вместо буфера для &1",  {&table_marking}).
          
          if    m-has-oldbh
            and m-oldbh:table <> {&table_marking} 
/*            and m-oldbh:table <> "tt-fin"*/
          then
            undo, return error substitute("Передан неверный буфер вместо буфера для &1",  {&table_marking}).
          
        end.
      otherwise 
      do:
        undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
      end.
    end case.
end.
*/