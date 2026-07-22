/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы для хранения информации о персистентных процедурах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/27/04
Author: Bakhtadze Natalya
Creation date: 11/27/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table temp-pers-proc no-undo
field proc-name as character
field vproc-handle as handle
field vparent-handle as handle
field user-name as character
field id as integer
field vpar as character
field rank-to-delete as integer
index pi is unique primary
proc-name
id
index puser
proc-name
user-name
index ppar
proc-name
vpar
index iparent
vparent-handle
proc-name
index iid
id
index ird
rank-to-delete
.
define variable v-per-proc-num as integer no-undo .

&if "{2}" = " " &then
&scop max-per-proc 200
&else
&scop max-per-proc {2}
&endif


procedure perproc-create-proc :
define input  parameter p-parent-handle as handle no-undo .
define input  parameter p-proc-name as character no-undo .
define input  parameter p-proc-handle  as handle no-undo .
define input  parameter p-run        as logical no-undo .
define input  parameter p-parameter as character no-undo .
define input  parameter p-userid as character no-undo .
define input  parameter p-rank-to-delete as integer no-undo .
define output parameter p-id as integer   no-undo .
define variable ii as integer   no-undo .
define variable v-proc-handle as handle no-undo .

define buffer buf_temp-pers-proc for temp-pers-proc.
define buffer buf0_temp-pers-proc for temp-pers-proc.

  do
  on error undo, return error return-value
  :

    if v-per-proc-num > {&max-per-proc} then return error '>'.
    find first buf0_temp-pers-proc no-lock where
              buf0_temp-pers-proc.proc-name = p-proc-name use-index pi    no-error.
    if not available buf0_temp-pers-proc then do:
      if p-run then do:
        run value(p-proc-name) persistent SET v-proc-handle (input p-parameter) no-error.
        if error-status :error then undo, return error return-value .
      end.
      else v-proc-handle = p-proc-handle.
      find last buf0_temp-pers-proc no-lock use-index iid  no-error.
      create buf_temp-pers-proc.
      assign
      buf_temp-pers-proc.proc-name = p-proc-name
      buf_temp-pers-proc.id = (if not available buf0_temp-pers-proc
                                then  0
                                else buf0_temp-pers-proc.id + 1)
      buf_temp-pers-proc.user-name = p-userid
      buf_temp-pers-proc.vpar      = p-parameter
      buf_temp-pers-proc.vparent-handle = p-parent-handle
      buf_temp-pers-proc.vproc-handle = v-proc-handle
      buf_temp-pers-proc.rank-to-delete = p-rank-to-delete
      p-id = buf_temp-pers-proc.id
      v-per-proc-num = v-per-proc-num + 1
      .
    end. /*if not available buf0_temp-pers-proc then do:*/
    else p-id = buf0_temp-pers-proc.id.
  end. /*doe*/

end procedure. /* perproc-create-proc */

procedure perproc-delete-proc-user :
define input  parameter p-proc-name as character no-undo .
define input  parameter p-user-name as character no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.

  do
  on error undo, return error return-value
  :

     for each buf_temp-pers-proc where
            buf_temp-pers-proc.proc-name = p-proc-name
       AND  buf_temp-pers-proc.user-name = p-user-name:
        APPLY "delete" to buf_temp-pers-proc.vproc-handle.
        delete procedure buf_temp-pers-proc.vproc-handle.
        delete buf_temp-pers-proc.
        v-per-proc-num = v-per-proc-num - 1.

     end.

  end.

end procedure. /* perproc-delete-proc */

procedure perproc-delete-proc-id :
define input  parameter p-id        as integer   no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.

  do
  on error undo, return error return-value
  :

     for each buf_temp-pers-proc where
        buf_temp-pers-proc.id        = p-id:
        APPLY "delete" to buf_temp-pers-proc.vproc-handle.
        delete procedure buf_temp-pers-proc.vproc-handle.
        delete buf_temp-pers-proc.
        v-per-proc-num = v-per-proc-num - 1.
     end.
  end. /*doe*/

end procedure. /* perproc-delete-proc */


procedure perproc-delete-by-rank :
define buffer buf_temp-pers-proc for temp-pers-proc.

  do
  on error undo, return error return-value
  :

    for each buf_temp-pers-proc where
    by buf_temp-pers-proc.rank-to-delete:
      APPLY "delete" to buf_temp-pers-proc.vproc-handle.
      delete procedure buf_temp-pers-proc.vproc-handle.
      delete buf_temp-pers-proc.
      v-per-proc-num = v-per-proc-num - 1.
    end.
  end. /*doe*/

end procedure. /* perproc-delete-proc */



procedure perproc-delete-proc-name-id :
define input  parameter p-proc-name as character no-undo .
define input  parameter p-id        as integer   no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.

  do
  on error undo, return error return-value
  :

     for each buf_temp-pers-proc where
            buf_temp-pers-proc.proc-name = p-proc-name
       AND  buf_temp-pers-proc.id        = p-id:
        APPLY "delete" to buf_temp-pers-proc.vproc-handle.
        delete procedure buf_temp-pers-proc.vproc-handle.
        delete buf_temp-pers-proc.
        v-per-proc-num = v-per-proc-num - 1.

     end.

  end. /*doe*/

end procedure. /* perproc-delete-proc */

procedure perproc-delete-par :
define input  parameter p-proc-name as character no-undo .
define input  parameter p-parameter as character no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.

  do
  on error undo, return error return-value
  :

     for each buf_temp-pers-proc where
            buf_temp-pers-proc.proc-name = p-proc-name
       AND  buf_temp-pers-proc.vpar      = p-parameter:
        APPLY "delete" to buf_temp-pers-proc.vproc-handle.
        delete procedure buf_temp-pers-proc.vproc-handle.
        delete buf_temp-pers-proc.
        v-per-proc-num = v-per-proc-num - 1.

     end.

  end.

end procedure. /* perproc-delete-par */

procedure perproc-delete-from-parent :
define input  parameter p-parent-handle as handle no-undo .
define input  parameter p-proc-name as character no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.

  do
  on error undo, return error return-value
  :
     if p-proc-name = "":u then do:
      for each buf_temp-pers-proc where
         buf_temp-pers-proc.vparent-handle      = p-parent-handle:
          APPLY "delete" to buf_temp-pers-proc.vproc-handle.
          delete procedure buf_temp-pers-proc.vproc-handle.
          delete buf_temp-pers-proc.
          v-per-proc-num = v-per-proc-num - 1.
      end.

     end.
     else do:
      for each buf_temp-pers-proc where
              buf_temp-pers-proc.proc-name = p-proc-name
        AND  buf_temp-pers-proc.vparent-handle      = p-parent-handle:
          APPLY "delete" to buf_temp-pers-proc.vproc-handle.
          delete procedure buf_temp-pers-proc.vproc-handle.
          delete buf_temp-pers-proc.
          v-per-proc-num = v-per-proc-num - 1.

      end.
    end.

  end.

end procedure. /* perproc-delete-par */


/* $Workfile$ e n d */