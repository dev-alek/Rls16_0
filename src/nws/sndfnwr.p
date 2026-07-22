block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sndfnwr.p $
$Archive: nws/sndfnwr.p $

Пересылка масива файлов на массив БД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/04/06
Author: Bakhtadze Natalya
Creation date: 08/04/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sndfnwr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/sndfnwr.p $":U .
define variable vss-description as character no-undo init "Пересылка масива файлов на массив БД".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/fileslsh.i }


define variable v-view-log as logical no-undo .
define variable log-file-name as character no-undo init "sndfrnwr.txt".

define shared temp-table tt-ext-file no-undo like ub.ext-file.
define shared temp-table tt-db       no-undo like ub.db.
define shared temp-table tt-ext-file-par no-undo like ub.ext-file-par.
define buffer buf_tt-db for tt-db.
define buffer buf_tt-ext-file for tt-ext-file.
define buffer locked_ext-file for ub.ext-file.
define buffer buf_ext-file for ub.ext-file.
define buffer last_ext-file for ub.ext-file.

define variable p-mode as character no-undo .
define variable p-path-type as integer no-undo.
define variable p-path as character no-undo .
define variable p-status_  as character no-undo .
define variable v-file-num as integer no-undo .
define variable v-start as logical no-undo .
define variable v-cycled as logical no-undo .
define variable v-start-search as integer no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-file-num-sign as integer no-undo .


FUNCTION get-char-path-type  returns CHARACTER ( input p-path-type as integer, input p-mode as character):
if p-mode = {&save-db}
or p-mode = {&save-db-and-run}
or p-mode = {&save-this-db}
then do:
  return '':U.
end.
CASE p-path-type:
  when 0 then do:
    return "Относительный".
  end.
  when 1 then do:
    return "Абсолютный".
  end.
  when 2 then do:
    return "По настройкам ini-файла IBS TH".
  end.
END CASE.

END FUNCTION.



&scop view-log   ~{ str/cdviewlg.i   ~
                    "'!!!При пересылке/сохранении файлов произошли ошибки!!!'" ~
                    "'sndfrnwr.txt'" ~}   ~
                    return


assign
p-mode          = entry(1, p-parameter, {&delim-par})
p-path-type     = integer(entry(2, p-parameter, {&delim-par}))
p-path          = entry(3, p-parameter, {&delim-par})
p-status_        = entry(4, p-parameter, {&delim-par})
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

/*для получения номер блокируем ext-file с номером 0*/

v-current-db-num = - 1.
if (p-mode = {&save-this-db}
        or
        (p-mode = {&save-install}
        and
        p-status_ = {&manual})
   ) then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Сохранение файлов&1" +
                          "режим &2&1"
                        , {&new-line}
                        , p-mode
                        )).

end.
else do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Пересылка файлов&1" +
                          "режим &2, тип пути к файлу на удаленном компьютере &3,&1" +
                          "Путь &4"
                        , {&new-line}
                        , p-mode
                        , get-char-path-type ( input p-path-type, p-mode)
                        , p-path
                        )).
end.


for EACH buf_tt-db NO-LOCK,
    EACH buf_tt-ext-file NO-LOCK:
  if buf_tt-db.db-num <> v-current-db-num then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("------------БД &2&1"
                            , {&new-line}
                            , buf_tt-db.db-num
                            )).
   end.
   v-current-db-num = buf_tt-db.db-num.

   main-block:
   do
   on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
   on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
   on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
   :
    v-file-num = next-value(s-sost, {&db-name_schema}).
      if p-mode = {&save-this-db}
      or (p-mode = {&save-install}
          and
          p-status_ = {&manual}) then do:
        v-file-num-sign = - 1.
      end.
      else do:
        v-file-num-sign = 1.
    end.
    v-file-num = v-file-num * v-file-num-sign.
    create buf_ext-file.
    buffer-copy buf_tt-ext-file except status_ db-num from-db-num file-num to buf_ext-file
    assign
    buf_Ext-file.status_ = (if p-status_ = '':U then p-mode else p-status_)
    buf_ext-file.db-num = buf_tt-db.db-num
    buf_ext-file.from-db-num = g#db-num
    buf_ext-file.file-num = v-file-num
    buf_Ext-file.update-user-name = g#userid
    .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Файл &1"
                            , buf_tt-ext-file.file-name
                            )).
    if p-status_ = {&auto}
    or p-status_ = ""
    then do:
      run nws/bin-e.p (
                     input buf_ext-file.db-num
                    ,input buf_ext-file.from-db-num
                    ,INPUT v-file-num
                    ,input buf_tt-ext-file.file-name
                    ,input p-path-type
                    ,input p-path
                    ,input p-mode
                    ,input buf_tt-ext-file.status_
                    ,buffer buf_ext-file
                    ,input table tt-ext-file-par
                    ) no-error.
      if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("!!!Ошибка при пересылке файла на БД &8&1" +
                                "режим &2, тип пути к файлу на удаленном компьютере &3,&1" +
                                "Путь &4,&1" +
                                "Файл &5,&1&6&1БД &7 (от БД &8)"
                                , {&new-line}
                                , p-mode
                                , get-char-path-type ( input p-path-type, p-mode)
                                , p-path
                                , buf_tt-ext-file.file-name
                                , error-status:get-message(1)
                                , return-value
                                , buf_tt-db.db-num
                                , g#db-num
                                )).
          assign
          v-view-log = yes.
      end.
      else do:
        if valid-handle(p-parent-handle)
        and lookup("cb_set-ext-file_file-num", p-parent-handle:internal-entries) > 0 then do:
          run cb_set-ext-file_file-num in p-parent-handle ( input buf_ext-file.db-num
                                                           ,input buf_ext-file.from-db-num
                                                           ,input v-file-num) no-error.
        end.
      end.
      if p-mode <> {&save-db}
      and p-mode <> {&save-db-and-run}
      and p-mode <> {&save-this-db} then do:
      assign
      buf_ext-file.file-name = buf_ext-file.file-name  + '>' + prepare-path(p-path).
    end.
    end.
  end. /*doe*/

END.
{&view-log}.