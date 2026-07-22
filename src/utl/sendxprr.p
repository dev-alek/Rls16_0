block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sendxprr.p $
$Archive: utl/sendxprr.p $

Пакет рассылки на кассы IBM-XML файла параметров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/26/09
Author: Bakhtadze Natalya
Creation date: 06/26/09

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendxprr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/sendxprr.p $":U .
define variable vss-description as character no-undo init "Пакет рассылки на кассы IBM-XML файла параметров".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/fileslsh.i }
{ gbl/key-rec.i }

define variable p-path as character no-undo .


define variable v-view-log as logical no-undo .
define variable log-file-name as character no-undo init "sendxprr.txt".
define variable p-mode as character no-undo .

define variable v-cash-desk-uniq-key-rec as character no-undo .
define variable v-ext-file-uniq-key-rec as character no-undo .
define variable v-parameter as character no-undo .
define variable action as character no-undo .


define temp-table tt-cash-desk no-undo like ub.cash-desk.
define buffer buf_tt-cash-desk for tt-cash-desk.
define buffer buf2_tt-cash-desk for tt-cash-desk.
define new shared temp-table tt-ext-file no-undo like ub.ext-file.
define new shared temp-table tt-db       no-undo like ub.db.
define new shared temp-table tt-ext-file-par no-undo like ub.ext-file-par.
define buffer buf_tt-db for tt-db.
define buffer buf_tt-ext-file for tt-ext-file.
define buffer buf_db for ub.db.
define temp-table rtt-ext-file no-undo like ub.ext-file.
define buffer buf_rtt-ext-file for rtt-ext-file.

{ nws/bintrn.i }


&scop view-log   ~{ str/cdviewlg.i   ~
                    "'!!!При пересылке/сохранении файлов произошли ошибки!!!'" ~
                    log-file-name ~}   ~
                    return

&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)


assign
p-path          = entry(1, p-parameter, {&delim-par})
action          = entry(2, p-parameter, {&delim-par})
no-error
.

if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.

/*найдем список касс*/
run cb_get-cash-desk-list in p-parent-handle ( input this-procedure:handle) no-error.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.
for each tt-db:
 delete tt-db.
end.
for each tt-ext-file:
  delete tt-ext-file.
end.
for each tt-ext-file-par:
  delete tt-ext-file-par.
end.
define variable v-unc-file-name as character no-undo .
run bintrn_create-file-record in this-procedure ( input p-path
                                                , input {&table_cash-desk} + {&delim-key}
                                                , input '' /*p-obj-type*/
                                                , input 0 /*p-obj-code*/
                                                , output v-unc-file-name
                                                ) no-error.
if error-status:error then do:
  &scop my-message    substitute("Ошибка при подготовке файла &1 к пересылке &2" + ~
              "&3&2&4" ~
              , v-full-path ~
              , ~{&new-line~} ~
              , error-status:get-message(1) ~
              , return-value ) ~
  {&dsiplay-message}.
  return error.
end.

main-block:
for each buf_tt-cash-desk
break
by buf_tt-cash-desk.db-num
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if first-of(buf_tt-cash-desk.db-num) then do:
  /*надо создать tt-db tt-ext-file tt-ext-file-par */
    find first buf_db no-lock where
              buf_db.db-num = buf_tt-cash-desk.db-num.
    create buf_tt-db.
    buffer-copy buf_db to buf_tt-db.
    release buf_tt-db.
    if buf_db.db-num = g#db-num then do:
      p-mode = {&save-this-db}.
    end.
    else do:
      p-mode = {&save-db}.
    end.
    /*номер файла получим с через callbcack*/
    run nws/sndfnwr.p ( input parparentproc
                        ,input this-procedure:handle
                        ,input p-log-handle
                        ,input (p-mode + {&delim-par} +
                                string(0) + {&delim-par} + /*относительны путь*/
                                p-path + {&delim-par} +
                                '' /*p-status_ здесь не важен*/  )) no-error.
    find first buf_tt-db where buf_tt-db.db-num = buf_tt-cash-desk.db-num.
    delete buf_tt-db.
  end. /*if first-of(buf_tt-cash-desk.db-num) then do:*/
end. /*for each buf_tt-cash-desk */


main-block:
for each buf_tt-cash-desk
break
by buf_tt-cash-desk.db-num
by buf_tt-cash-desk.obj-code
by buf_tt-cash-desk.pos-type
by buf_tt-cash-desk.cash-num
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if first-of(buf_tt-cash-desk.db-num) then do:
    find first buf_rtt-ext-file no-lock where
              buf_rtt-ext-file.db-num = buf_tt-cash-desk.db-num no-error.
    if not available buf_rtt-ext-file then do:
      &scop my-message substitute("Не удалось отослать файл параметров &1 в БД &2", p-path, buf_tt-cash-desk.db-num)
      {&display-message}.
    end.
    else do:
      assign
      v-ext-file-uniq-key-rec = ''.
        run gen-key-rec in this-procedure ( input {&table_ext-file}
                                          ,input (buffer buf_rtt-ext-file:handle)
                                          ,output v-ext-file-uniq-key-rec) no-error.

      &scop my-message substitute("Отсылка файла параметров &1 на кассы БД &2", p-path, buf_tt-cash-desk.db-num)
      {&display-message}.
      for each buf2_tt-cash-desk where
              buf2_tt-cash-desk.db-num = buf_tt-cash-desk.db-num
      by buf2_tt-cash-desk.db-num
      by buf2_tt-cash-desk.obj-code
      by buf2_tt-cash-desk.pos-type
      by buf2_tt-cash-desk.cash-num
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
         assign
         v-cash-desk-uniq-key-rec = ''.
         run gen-key-rec in this-procedure ( input {&table_cash-desk}
                                            ,input (buffer buf2_tt-cash-desk:handle)
                                            ,output v-cash-desk-uniq-key-rec) no-error.

         assign
         v-parameter = v-cash-desk-uniq-key-rec + {&delim-par} +
                       v-ext-file-uniq-key-rec + {&delim-par} +
                       action .
         if buf2_tt-cash-desk.db-num = g#db-num then do:
            run str/send-xpr.p ( input parparentproc
                                ,input this-procedure:handle
                                ,input p-log-handle
                                ,input v-parameter ) no-error.
           if error-status:error then do:
              &scop my-message substitute("Не удалась отсылка файла параметров &1 на касссу &2:&3&4&3&5" ~
                                          , p-path ~
                                          , v-cash-desk-uniq-key-rec ~
                                          , ~{&new-line~} ~
                                          , error-status:get-message(1) ~
                                          , return-value )
              {&display-message}.
           end.
         end.
         else do:
            run nws/cr-route.p (
                          input {&send-cmd}
                          ,input "command" + {&delim-nws} +
                                 "run-file" + {&delim-nws} + "str/send-xpr.p" + {&delim-nws} + v-parameter
                          ,input ?
                          ,input string(buf_tt-cash-desk.db-num)
                          ) no-error .
            if error-status:error then do:
              &scop my-message substitute("Не удалась команда отсылки файла параметров &1 на касссу &2:&3&4&3&5" ~
                                          , p-path ~
                                          , v-cash-desk-uniq-key-rec ~
                                          , ~{&new-line~} ~
                                          , error-status:get-message(1) ~
                                          , return-value )
              {&display-message}.
            end.
         end.
      end.
    end.
  end.
end.




procedure cb_set-cash-desk-list :
define input parameter p-db-num as integer no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-cash-num as integer no-undo .
define input parameter p-version as character no-undo .

define buffer buf_tt-cash-desk for tt-cash-desk.

do
on error undo, return error
:
  find first buf_tt-cash-desk where
            buf_tt-cash-desk.db-num = p-db-num
       and  buf_tt-cash-desk.obj-code = p-obj-code
       and  buf_tt-cash-desk.pos-type = p-pos-type
       and  buf_tt-cash-desk.cash-num = p-cash-num no-error.
  if not available buf_tt-cash-desk then do:
    create buf_tt-cash-desk.
    assign
    buf_tt-cash-desk.db-num = p-db-num
    buf_tt-cash-desk.obj-code = p-obj-code
    buf_tt-cash-desk.pos-type = p-pos-type
    buf_tt-cash-desk.cash-num = p-cash-num
    buf_tt-cash-desk.version = p-version
    .
    release buf_tt-cash-desk.
  end.
end.
end procedure. /* cb_set-cash-desk-list */

procedure cb_set-ext-file_file-num :
define input parameter p-db-num as integer no-undo .
define input parameter p-from-db-num as integer no-undo .
define input parameter p-file-num as integer no-undo .
define buffer buf_tt-ext-file for tt-ext-file.
define buffer buf_rtt-ext-file for rtt-ext-file.
do
on error undo, return error
:
  find first buf_tt-ext-file.
  find first buf_rtt-ext-file where
            buf_rtt-ext-file.db-num = p-db-num
        and buf_rtt-ext-file.from-db-num = p-from-db-num
        and buf_rtt-ext-file.file-num = p-file-num no-error.
  if not available buf_rtt-ext-file then do:
    create buf_rtt-ext-file.
    buffer-copy buf_tt-ext-file
    except db-num from-db-num file-num
    to buf_rtt-ext-file
    assign
    buf_rtt-ext-file.db-num = p-db-num
    buf_rtt-ext-file.from-db-num = p-from-db-num
    buf_rtt-ext-file.file-num = p-file-num
    .
    release buf_rtt-ext-file.
  end.
end.

end procedure. /* cb_set-ext-file_file-num */