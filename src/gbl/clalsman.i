/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

выбор многих объекта из cli-all.w

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/25/09
Author: Bakhtadze Natalya
Creation date: 06/25/09

*/

procedure cli-all_select-many :

  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .

  define variable v-rid-list as character no-undo .
  define variable v-recid as recid no-undo .
  define buffer buf_clients for ub.clients.


  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock where
              buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code no-error.
    if available buf_clients then do:
      v-recid = recid(buf_clients).
    end.
    run ref/cli-all.w (
                    input parparentproc
                  ,input "b-sel,b-mark"
                  ,input {&g___object}
                  ,input {&all}
                  ,input {&current}
                  ,input v-recid
                  ,input ",,,,,,NO,,"
                  ,input substitute("lock-cli-type=yes;parent-handle=&1", string( this-procedure:handle))
                  ,output v-rid-list ) NO-ERROR.
    if v-rid-list <> '' then do:
      assign
      p-user-select = yes
      .
    end.
  end.


end procedure. /* userobjs_select-many */