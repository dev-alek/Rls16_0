/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

тригера интерфейса

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 07/01/04 3:23

*/

on choose of r-{1} in frame dialog-frame /* r-button */
do:
   run proc-r-{1} in this-procedure no-error .
   if error-status :error then
      return no-apply.
end.


on mouse-select-dblclick of {2}{1}-code in frame {&frame-name}
do:
  apply "CHOOSE" to r-{1} in frame {&frame-name}.
  return no-apply .
end.
on mouse-select-dblclick of {2}{1}-type in frame {&frame-name}
do:
  apply "CHOOSE" to r-{1} in frame {&frame-name}.
  return no-apply .
end.


procedure proc-r-{1} :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
 define variable v-recid as recid no-undo .
 define variable old-types as character no-undo .
 define variable v-host-code like ub.sysconf.host-code no-undo .
 define buffer {1}#clients for ub.clients.
 define variable v-user-select as logical   no-undo .
 define variable v-obj-type    as character no-undo .
 define variable v-obj-code    as integer   no-undo .

  { gbl/hostcode.i
    {3}obj-type
    {3}obj-code
    v-host-code
  }
  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-host-code
    {3}obj-type
    {3}obj-code
    v-user-select
    v-obj-type
    v-obj-code
  }
  if v-user-select <> true
  then do:
    return error return-value .
  end.

    find first {1}#clients no-lock
      where {1}#clients.obj-type = v-obj-type
        and {1}#clients.obj-code = v-obj-code
         no-error.
    if avail {1}#clients then
        assign
            {2}{1}-type = {1}#clients.obj-type
            {2}{1}-code = {1}#clients.obj-code
            {2}{1}-name = {1}#clients.obj-name
            .
    else
       assign
          {2}{1}-type = ""
          {2}{1}-name = ""
          {2}{1}-code = ?
          .


    display
        {2}{1}-type
        {2}{1}-name
        {2}{1}-code
        with frame {&frame-name} .

end.
end procedure.

procedure leave-proc-{1} :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  def buffer buf_clients for ub.clients.

  assign frame {&frame-name}
     {2}{1}-type
     {2}{1}-code
      .

  if {2}{1}-code <> ? and {2}{1}-code <> 0 and
     {2}{1}-type <> ? and {2}{1}-type <> ""
      then do:
      find first buf_clients no-lock where
                buf_clients.obj-type =  {2}{1}-type  and
                buf_clients.obj-code  = {2}{1}-code no-error.

          if error-status :error or not available buf_clients then do:
              message "Неправильно задан "  {2}{1}-code:label in frame {&frame-name}.
                assign
                {2}{1}-type = ""
                {2}{1}-name = ""
                {2}{1}-code = ?
                .
              display
              {2}{1}-type
              {2}{1}-name
              {2}{1}-code
              with frame {&frame-name}.
              apply "CHOOSE" to r-{1} in frame {&frame-name} .
          end.

          if available buf_clients then do:
                {2}{1}-type  = buf_clients.obj-type .
                {2}{1}-name  = buf_clients.obj-name .
                {2}{1}-code  = buf_clients.obj-code .
          end.
 end.
 else do:
      assign
        {2}{1}-type = ""
        {2}{1}-name = ""
        {2}{1}-code = ?

        .
  end.
 display
  {2}{1}-type
  {2}{1}-name
  {2}{1}-code
  with frame {&frame-name}.
 end. /* do */
end procedure. /* leave-proc-{1} */

/* $Workfile$ e n d */