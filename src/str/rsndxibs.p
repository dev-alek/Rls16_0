block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rsndxibs.p $
$Archive: str/rsndxibs.p $

Досылка недошедших до POS IBM-XML по расписанию

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/05
Author: Bakhtadze Natalya
Creation date: 11/18/05

*/

define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cre-db-num     as integer      no-undo .
define input parameter p-task-type      as character    no-undo.
define input parameter p-task-num       as integer      no-undo.
define input parameter p-db-num         as integer      no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rsndxibs.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rsndxibs.p $":U .
define variable vss-description as character no-undo init "Досылка недошедших до POS IBM-XML по расписанию".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ adm/auto-def.i    }
{ ref/shd-attr.i    }
{ cmp/ini-lib.i }
{ gbl/cur-time.i }

do
on error undo, return error return-value
:
  define variable v-counter                   as integer      no-undo.
  define variable v-param-list                as character    no-undo.
  define variable v-param-type                as character    no-undo.
  define variable v-range                     as integer      no-undo.
  define variable v-host-code                 as integer      no-undo.
  define variable v-parameter                 as character    no-undo .
  define variable v-dir-name  as character no-undo .
  define variable v-dir-type  as character no-undo .
  define variable v-can-read  as logical   no-undo .
  define variable v-file-name as character no-undo .
  define variable path as character no-undo .
  define variable file as character no-undo .
  define variable glog        as logical   no-undo .

&scop display-message    run write-log-and-file in p-log-handle (  ~
        input 1                                                      ~
      , input log-file-name                                          ~
      , input 1                                                      ~
      , input ~{&my-message~})


  assign
  log-file-name = "shd-free.log".

  run gbl/set-gbl.p
    (input  true
    ,input  g#auto-user-id
    ,input  g#auto-user-password
    ) no-error .
  if error-status:error
  then do:
      run write-to-log in p-log-handle( vss-workfile + {&space-char}
                      + "!!!Ошибка при инициализации переменных g#..." + {&new-line}
                      + error-status:get-message(error-status:num-messages)
                      + return-value
                      ) .
      return error.
  end. /*if error-status:error*/

  run schedule-attr-value in this-procedure (
        input p-cre-db-num
      , input p-task-type
      , input p-task-num
      , input {&attr-schedule-param-list-h}
      , output v-param-list
      , output v-param-type
  ).
  if v-param-list = "":U then do:

&scop my-message   substitute("!!!Не заданы параметры досылки данных файлов, недошедших до POS IBM-XML, в задаче &1&2" ~
                                    , p-task-num                                                                       ~
                                    , ~{&new-line~})

      {&display-message}.
      return.
  end.
  assign
  v-dir-name = entry(1, v-param-list, {&delim-par} )
  no-error
  .
  if error-status :error then do:
&scop my-message substitute("!!!Ошибки при получении параметров досылки&1" +  ~
                          "&2&1&3&1"                                                ~
                          , error-status:get-message(1)                             ~
                          , return-value )
    {&display-message}.
  end.
  case v-dir-name:
    when 'ini':U then do:
      run verify-ini-entry in this-procedure (
                                          INPUT  'out'
                                          ,INPUT  'kassa-ibm-xml'
                                          ,INPUT substitute("отсутствует параметр &1 секция &2 в ini-файле"
                                                            , 'out'
                                                            , 'kassa-ibm-xml')
                                          ,INPUT no
                                          ,output v-dir-name) no-error .
      if error-status:error or v-dir-name = ? then do:
&scop my-message  return-value
        {&dispaly-message}.
        return .
      end.
      RUN verify-file in this-procedure (
                                         input v-dir-name + "undelivered":U
                                        ,input substitute("Не найден каталог &1 параметр &2, секция &3 ini-файла"
                                                      , v-dir-name + "undelivered":U
                                                      , 'kassa-ibm-xml'
                                                      , 'out')
                                        ,input no
                                        ,output  glog) no-error.
      if error-status:error or not glog then do:
&scop my-message  return-value
        {&dispaly-message}.
        return .
      end.
      v-dir-name = v-dir-name + "undelivered":U.
    end.
    otherwise do:
      v-dir-name = v-dir-name.
    end.
  END CASE.
  assign
  file-info:file-name = v-dir-name
  v-dir-type = file-info:file-type
  v-can-read = ( index( v-dir-type, "R" ) > 0 )
  .
  if index( v-dir-type, "D" ) = 0 then do:
&scop my-message substitute("!!!Выбранный каталог &1 - недоступен", v-dir-name)
    {&display-message}.
    return .
  end.
  if not v-can-read then do:
&scop my-messsage substitute("!!!Из выбранного каталога &1 чтение файла невозможно", v-dir-name)
    {&display-message}.
    return .
  end.
  run str/rsndxibm.p (
                   input parparentproc
                  ,input p-parent-handle
                  ,input p-log-handle
                  ,input (v-dir-name  + {&delim-par} + "yes" ) /*директория и режим resend*/

                  ) no-error.
  if error-status:error then do:
      run set-view-log in p-log-handle(yes).
  end.
end. /*doe*/