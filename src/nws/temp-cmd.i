/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для работы с c_m_d-b_u_s_h

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/31/06
Author: Bakhtadze Natalya
Creation date: 10/31/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/key-rec.i }

define {1} temp-table temp-cmd no-undo
field cmd-code as integer
field db-list as character
index pi is unique primary
db-list
index icmd
cmd-code
.

define {1} temp-table temp-smart-route no-undo
field key-field as character
field db-num as integer
index pi is unique primary
key-field
db-num
.

define {1} temp-table temp-no-route no-undo
field rec-ord as integer
field db-num as integer
index pi is unique primary
db-num
rec-ord
index iro
rec-ord
.


define {1} temp-table temp-smart-link no-undo
field uniq-key-rec as character
field key-field as character
field rec-ord as integer
field is-smart as logical
index pi is unique primary
key-field
uniq-key-rec
rec-ord
index iu
uniq-key-rec
index iro
rec-ord
.

define {1} temp-table temp-nws-outline no-undo
like ub.nws-outline.


&glob add-dump ~
run add-dump in ~{&cmd-proc-handle~}                                                                         ~
  (input ~{&cmd-code~}                                                                                       ~
  ,input ~{&table__~}                                                                                        ~
  ,input ~{&action__~}                                                                                       ~
  ,input ~{&buffer-handle~}                                                                                  ~
  ,input ~{&gate-rec~}                                                                                       ~
  ,output v-rec-ord_                                                                                         ~
  ) no-error .                                                                                               ~
if error-status :error                                                                                       ~
then do:                                                                                                     ~
delete procedure ~{&cmd-proc-handle~} .                                                                      ~
  undo {&block-label}, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4" ~
                                      ,vss-workfile                                                          ~
                                      ,vss-revision                                                          ~
                                      ,vss-description                                                       ~
                                      ,~{&new-line~}                                                         ~
                                      ,~{&table__~}                                                          ~
                                      ,~{&cmd-code~}                                                         ~
                                      ,error-status:get-message(1)                                           ~
                                      ,return-value                                                          ~
                                      ) .                                                                    ~
end


&glob add-dump-ext ~
run add-dump in ~{&cmd-proc-handle~}                                                                         ~
  (input ~{&cmd-code~}                                                                                       ~
  ,input ~{&table__~}                                                                                        ~
  ,input ~{&action__~}                                                                                       ~
  ,input ~{&buffer-handle~}                                                                                  ~
  ,input ~{&gate-rec~}                                                                                       ~
  ,output ~{&rec-ord~}                                                                                       ~
  ) no-error .                                                                                               ~
if error-status :error                                                                                       ~
then do:                                                                                                     ~
delete procedure ~{&cmd-proc-handle~} .                                                                      ~
  undo {&block-label}, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4" ~
                                      ,vss-workfile                                                          ~
                                      ,vss-revision                                                          ~
                                      ,vss-description                                                       ~
                                      ,~{&new-line~}                                                         ~
                                      ,~{&table__~}                                                          ~
                                      ,~{&cmd-code~}                                                         ~
                                      ,error-status:get-message(1)                                           ~
                                      ,return-value                                                          ~
                                      ) .                                                                    ~
end


&glob copy-dump ~
run copy-dump in ~{&cmd-proc-handle~}                                                                         ~
  (input ~{&src-cmd-code~}                                                                                       ~
  ,input ~{&trg-cmd-code~}                                                                                        ~
  ,input ~{&rec-ord~}                                                                                  ~
  ,input ~{&uniq-key-rec~}                                                                                  ~
  ) no-error .                                                                                               ~
if error-status :error                                                                                       ~
then do:                                                                                                     ~
delete procedure ~{&cmd-proc-handle~} .                                                                      ~
  undo {&block-label}, return error substitute("&1 &2 &3&4Ошибка при копировании записи &5 из команды с кодом &6 в команду с кодом &7&4&8&4&9&4" ~
                                      ,vss-workfile                                                          ~
                                      ,vss-revision                                                          ~
                                      ,vss-description                                                       ~
                                      ,~{&new-line~}                                                         ~
                                      ,~{&uniq-key-rec~}                                                     ~
                                      ,~{&src-cmd-code~}                                                     ~
                                      ,~{&trg-cmd-code~}                                                     ~
                                      ,error-status:get-message(1)                                           ~
                                      ,return-value                                                          ~
                                      ) .                                                                    ~
end


procedure create-smart-route :
define input parameter p-key-field as character no-undo .
define input parameter p-db-num as integer no-undo .
define buffer buf_temp-smart-route for temp-smart-route.

  do
  on error undo, return error
  :
    find first buf_temp-smart-route where
              buf_temp-smart-route.key-field = p-key-field
          and buf_temp-smart-route.db-num = p-db-num no-error.
    if not available buf_temp-smart-route then do:
      create buf_temp-smart-route.
      assign
      buf_temp-smart-route.key-field = p-key-field
      buf_temp-smart-route.db-num = p-db-num
      .
    end.
  end.

end procedure. /* create-smart-route */


procedure create-smart-route-link :
define input parameter p-tbl-name as character no-undo .
define input parameter p-bh_tbl-name as handle no-undo .
define input parameter p-key-field as character no-undo .
define input parameter p-rec-ord as integer no-undo .
define input parameter p-is-smart as logical no-undo .

define variable v-key-rec as character no-undo .
define buffer buf_temp-smart-link for temp-smart-link.

  do
  on error undo, return error
  :
    run gen-key-rec in this-procedure ( input p-tbl-name
                                       ,input p-bh_tbl-name
                                       ,output v-key-rec     ).

   find first buf_temp-smart-link where
              buf_temp-smart-link.uniq-key-rec = v-key-rec
           and buf_temp-smart-link.key-field = p-key-field
           and buf_temp-smart-link.rec-ord = p-rec-ord
           no-error .
   if not available buf_temp-smart-link then do:
     create buf_temp-smart-link.
     assign
     buf_temp-smart-link.uniq-key-rec = v-key-rec
     buf_temp-smart-link.key-field = p-key-field
     buf_temp-smart-link.rec-ord = p-rec-ord
     buf_temp-smart-link.is-smart = p-is-smart
     .
   end.
  end.

end procedure. /* create-smart-route-link */

procedure create-nws-outline :
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code as integer no-undo .
define input parameter p-outline-type as character no-undo .
define input parameter p-charkey_one as character no-undo .
define input parameter p-charkey_two as character no-undo .
define input parameter p-charkey_three as character no-undo .
define input parameter p-key#_one as integer no-undo .
define input parameter p-key#_two as integer no-undo .
define input parameter p-key#_three as integer no-undo .

define variable v-no-id as integer no-undo .
define variable v-rec-ord as integer no-undo .

  do
  on error undo, return error return-value
  :
    find last temp-nws-outline use-index pi no-error .
    v-no-id = (if available temp-nws-outline
               then (temp-nws-outline.no-id  + 1)
               else 1).
    create temp-nws-outline.
    assign
    temp-nws-outline.charkeY_one = p-charkey_one
    temp-nws-outline.charkeY_two = p-charkey_two
    temp-nws-outline.charkeY_three = p-charkey_three
    temp-nws-outline.key#_one = p-key#_one
    temp-nws-outline.key#_two = p-key#_two
    temp-nws-outline.key#_three = p-key#_three
    temp-nws-outline.no-id = v-no-id
    temp-nws-outline.outline-type = p-outline-type
    .
    &scop cmd-proc-handle p-cmd-proc-handle
    &scop cmd-code p-cmd-code
    &scop table__ {&table_nws-outline}
    &scop buffer-handle (buffer temp-nws-outline:handle)
    &scop rec-ord v-rec-ord
    &scop action__ '+update'
    &scop gate-rec ''
    {&add-dump-ext}.
    run  create-smart-route in this-procedure (
                                                input ({&table_nws-outline} + {&delim-par} + string(temp-nws-outline.no-id))
                                               ,input -1).
    run create-smart-route-link in this-procedure (
                                                   input {&table_nws-outline}
                                                  ,input (buffer temp-nws-outline:handle)
                                                  ,input ({&table_nws-outline} + {&delim-par} + string(temp-nws-outline.no-id))
                                                  ,input v-rec-ord
                                                  ,input no
                                                  ).

  end.

end procedure. /* create-nws-outline */


procedure create-no-route :
define input parameter p-rec-ord as integer no-undo .
define input parameter p-db-num as integer no-undo .

define buffer buf_temp-no-route for temp-no-route.

do
on error undo, return error
:
   find first buf_temp-no-route where
              buf_temp-no-route.rec-ord = p-rec-ord
           and buf_temp-no-route.db-num = p-db-num no-error .
   if not available buf_temp-no-route then do:
     create buf_temp-no-route.
     assign
     buf_temp-no-route.rec-ord = p-rec-ord
     buf_temp-no-route.db-num = p-db-num
     .

   end.
end.

end procedure. /* create-no-route */


procedure clear-from-rec-ord :
define input parameter p-rec-ord as integer no-undo .
define buffer buf_temp-no-route for temp-no-route.
define buffer buf_temp-smart-link for temp-smart-link.

do
on error undo, return error
:

for each buf_temp-no-route where
        buf_temp-no-route.rec-ord > p-rec-ord:
  delete buf_temp-no-route.
end.
for each buf_temp-smart-link where
        buf_temp-smart-link.rec-ord > p-rec-ord:
   delete buf_temp-smart-link.
end.
end.
end procedure. /* cleare-from-rec-ord */

/* $Workfile$ e n d */