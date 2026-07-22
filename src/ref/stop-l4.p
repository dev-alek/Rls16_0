block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: stop-l4.p $
$Archive: ref/stop-l4.p $

Копирование стоплиста ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/24/08
Author: Bakhtadze Natalya
Creation date: 01/24/08

*/

define input parameter p-silent as logical no-undo .
define input parameter p-src-stop-list-code as character no-undo .
define output parameter p-trg-stop-list-code as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: stop-l4.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/stop-l4.p $":U .
define variable vss-description as character no-undo init "Копирование стоплиста ДК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/key-rec.i }
define variable v-mess as character no-undo .
define variable v-recid as recid no-undo .
define variable v-card-key-rec as character no-undo .
define variable v-client-key-rec as character no-undo .
define buffer src_stop-list for ub.stop-list.
define buffer trg_stop-list for ub.stop-list.
define buffer buf2_stop-list-line for ub.stop-list-line.
define buffer buf3_stop-list-line for ub.stop-list-line.
define buffer buf_dis-card for ub.dis-card.
define buffer buf2_dis-card for ub.dis-card.
define buffer buf_clients for ub.clients.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first src_stop-list share-lock where
            src_stop-list.stop-list-code = p-src-stop-list-code
        and src_stop-list.classif-type = {&table_dis-card} no-error.
  if not available src_stop-list then do:
    assign
    v-mess = substitute("Не найден столист-источник").
    run err-mess in this-procedure ( input-output v-mess).
    undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  run ref/stop-l1.p ( input p-silent
                 ,output p-trg-stop-list-code) no-error.
  if error-status:error then do:
    assign
    v-mess = substitute("Ошибка при создании стоплиста-копии&1&2&1&3"
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value ).
    run err-mess in this-procedure ( input-output v-mess).
    undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  find first trg_stop-list exclusive-lock where
              trg_stop-list.classif-type = {&table_dis-card}
          and trg_stop-list.stop-list-code = p-trg-stop-list-code no-error.
  if not available trg_stop-list then do:
    assign
    v-mess = substitute("Не найден созданный стоплист-копия&1&2&1&3"
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value ).
    run err-mess in this-procedure ( input-output v-mess).
    undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  for each buf2_stop-list-line no-lock where
          buf2_stop-list-line.stop-list-code = src_stop-list.stop-list-code
      and buf2_stop-list-line.classif-type = {&table_dis-card}
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    v-recid = ?.
    run ref/stop-ll1.p (
                      input {&add-def}
                    ,input no /*p-silent*/
                    ,input-output v-recid
                    ,input p-trg-stop-list-code
                    ,input buf2_stop-list-line.charkey_one
                    ,input buf2_stop-list-line.key#_one
                    ) no-error.
    if error-status:error then do:
      assign
      v-mess = substitute("Ошибка при создании строки в стоплисте-копии&1&2&1&3"
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value ).
      run err-mess in this-procedure ( input-output v-mess).
      undo main-block, return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  for each buf2_stop-list-line no-lock where
          buf2_stop-list-line.stop-list-code = trg_stop-list.stop-list-code
      and buf2_stop-list-line.classif-type = {&table_dis-card}
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if buf2_stop-list-line.key#_one = integer({&stop-client})
    or buf2_stop-list-line.key#_one = integer({&stop-card-and-client}) then do:
       /*првоерим что все карты попали в стоплист*/
       find first buf_dis-card no-lock where
                buf_dis-card.d-card = buf2_stop-list-line.charkey_one.
       for each buf2_dis-card no-lock where
                buf2_dis-card.cli-type = buf_dis-card.cli-type
            and buf2_dis-card.cli-code = buf_dis-card.cli-code,
           first buf_clients no-lock where
                buf_Clients.obj-type = buf_Dis-card.cli-type
            and buf_Clients.obj-code = buf_Dis-card.cli-code
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
         run gen-key-rec in this-procedure ( input {&table_dis-card}
                                            ,input buffer buf2_dis-card:handle
                                            ,output v-card-key-rec).
         run gen-key-rec in this-procedure ( input {&table_clients}
                                            ,input buffer buf_clients:handle
                                            ,output v-client-key-rec).
         find first buf3_stop-list-line no-lock where
                   buf3_stop-list-line.stop-list-code = buf2_stop-list-line.stop-list-code
                and buf3_stop-list-line.classif-type = {&table_dis-card}
                and (buf3_stop-list-line.resource_id = v-card-key-rec
                     or
                     buf3_stop-list-line.resource_id = v-client-key-rec)
                and buf3_stop-list-line.charkey_one = buf2_Dis-card.d-card
                no-error.
         if not available buf3_stop-list-line then do:
            v-recid = ?.
            run ref/stop-ll1.p (
                              input {&add-def}
                            ,input no /*p-silent*/
                            ,input-output v-recid
                            ,input p-trg-stop-list-code
                            ,input buf2_dis-card.d-card
                            ,input integer({&stop-client}))
                            ) no-error.
            if error-status:error then do:
              assign
              v-mess = substitute("Ошибка при дополнении стоплиста-копии новыми картами со статусом &4&1&2&1&3"
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                  , {&stop-client-full}
                                  ).
              run err-mess in this-procedure ( input-output v-mess).
              undo main-block, return error (if p-silent = yes then v-mess else '':U).
            end.
        end.
      end.
    end.
  end.
end.

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Копирование стоплиста: оригинал - стоплист &1, копия - стоплист &2"
                         , p-src-stop-list-code
                         , p-trg-stop-list-code
                         , {&new-line}
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.