/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать датасет

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/05/09
Author: Bakhtadze Natalya
Creation date: 03/05/09

*/

procedure print-xml:
define input parameter p-dsh as handle no-undo .
define input parameter p-file-name-without-ext as character no-undo .
define variable glog as logical no-undo .
define variable v-rowid as rowid no-undo.
define variable v-rowid-list as character no-undo .
define variable v-rowid-list2 as character no-undo .
define variable v-ii as integer no-undo .
define variable v-th as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-dsh  as handle no-undo .

do
on error undo, return error
:
  case p-dsh:type:
    when "DATASET" then do:
      do v-ii = 1 to p-dsh:num-buffers:
        v-rowid-list = v-rowid-list +
                        (if v-ii = 1 then '' else {&comma-char}) +
                        (if p-dsh:get-buffer-handle(v-ii):available
                        then string(p-dsh:get-buffer-handle(v-ii):rowid)
                        else '').
      end .
      v-dsh = p-dsh.
    end.
    when "temp-table" then do:
      if p-dsh:default-buffer-handle:available then do:
        v-rowid-list = string(p-dsh:default-buffer-handle:rowid).
      end.
      v-dsh = p-dsh.
    end.
    when "buffer" then do:
      if not valid-handle(p-dsh:table-handle) then do:
        if p-dsh:available then do:
          create temp-table v-th  .
          v-th:create-like(p-dsh).
          v-th:temp-table-prepare(p-dsh:table).
          create buffer v-bh for table v-th.
          v-bh:buffer-create().
          v-bh:buffer-copy(p-dsh).
          v-bh:buffer-release().
          v-dsh = v-bh.
        end.
      end.
      else do:
        v-dsh = p-dsh.
      end.
    end.
  end case.
  glog = v-dsh:WRITE-XML("FILE"
                        , substitute("&1.xml", p-file-name-without-ext)
                        , yes /*lFormatted*/
                        , "windows-1251"
                        , '' /*cSchemaLocation*/
                        , no /*lWriteSchema*/
                        , no /*lMinSchema*/ ) no-error.

  case p-dsh:type:
    when "DATASET" then do:
      do v-ii = 1 to p-dsh:num-buffers:
        if entry(v-ii,v-rowid-list) <> '' then do:
           glog = p-dsh:get-buffer-handle(v-ii):find-by-rowid(TO-ROWID(entry(v-ii,v-rowid-list)))  .
        end.
        v-rowid-list2 = v-rowid-list2 +
                        (if v-ii = 1 then '' else {&comma-char}) +
                        (if p-dsh:get-buffer-handle(v-ii):available
                        then string(p-dsh:get-buffer-handle(v-ii):rowid)
                        else '').
      end .
    end.
    when "temp-table" then do:
      if v-rowid-list <> '' then do:
        p-dsh:default-buffer-handle:find-by-rowid(to-rowid(v-rowid-list)).
      end.
    end.
    when "buffer" then do:
      if not valid-handle(p-dsh:table-handle) then do:
        delete object v-bh.
        delete object v-th.
      end.
    end.
  end case.
end.

end procedure. /* libthpos_write-xml */