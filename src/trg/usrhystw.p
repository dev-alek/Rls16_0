block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории пользователя.

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 04/01/08
Author: Victor Guntner
Creation date: 04/01/08

Input:

Output:

*/
&Glob main-tbl c-user-log
trigger procedure for write of ub.{&main-tbl}
  new buffer new-{&main-tbl}
  old buffer old-{&main-tbl}
.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo init "Тригер изменение {&main-tbl}". 

{ trg/trghistnws.i 
  &nws  = yes
  &nobufhist = yes
  
}

if not g#news
and not g#esys
and not (buffer new-{&main-tbl}:handle:buffer-compare (buffer old-{&main-tbl}:handle)) 
then do:
  if new-{&main-tbl}.head-table  = 'rvd-reasons':U
  or new-{&main-tbl}.head-table  = 'schedule':U
  or new-{&main-tbl}.head-table  = 'mi-change-1C':U
  then do :
    { gbl/rum-runa.i
       ?
       this-procedure:handle
       ?
       {&edoc-proc_event_user-action}
       " buffer new-{&main-tbl}:handle "
       ?
       ''
       ''
       no-error
    }
    if error-status:error 
    then do:
      message return-value view-as alert-box.
    end.
  end .
end .