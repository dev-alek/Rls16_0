block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-reply.p $
$Archive: gbl/rt-reply.p $

Процедура формирования ответов для радиотерминала

Автор: Хныкин Павел Андреевич
Дата создания: 27/02/07
Author: Pavel Khnykin
Creation date: 27/02/07

create: Перваков Михаил Сергеевич
Дата создания: 09/09/05

*/

define input  parameter p-max-user-num as integer   no-undo .
define input  parameter p-rtexpdt      as date      no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-reply.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-reply.p $":U .
define variable vss-description as character no-undo init "Процедура формирования ответов для радиотерминала".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/sys-time.i }
{ cmp/strcodec.i }

define stream sinp .
define stream sout .

define variable v-current-user-num as integer   no-undo .

define temp-table temp-session no-undo
  field session-id                as character
  field session-user-login        as character
  field session-remote-device     as character
  field session-start-time        as decimal
  field session-last-request-time as decimal

  index pi is primary unique session-id
  .

define temp-table temp-param no-undo
  field param-code     as character
  field param-value    as character

  index pi is primary unique param-code
  .

procedure rt-reply_process-request :

  define input  parameter p-callback-handle as handle    no-undo .
  define input  parameter p-directory-in    as character no-undo .
  define input  parameter p-directory-out   as character no-undo .
  define input  parameter p-file-name       as character no-undo .

  define variable v-request       as character no-undo .
  define variable v-session-id    as character no-undo .
  define variable v-session-valid as logical   no-undo .

  do
  on error undo, return error return-value
  :
    run read-param-data in this-procedure
      (input  p-directory-in + '/' + p-file-name
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.

    run get-param-data in this-procedure
      (input  'request'
      ,output v-request
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.

    if today > p-rtexpdt
    then do:
      message
        "Истек срок действия лицензии для работы с радиотерминалом" skip
        "Сегодня" today skip
        "Срок окончания лицензии" p-rtexpdt skip
        "Параметр rtexpdt" skip
        view-as alert-box error .
      return .
    end.

    run w-reqsrv_show-request in p-callback-handle
      (input  substitute('&1 request &2':u
                        ,p-file-name
                        ,v-request
                        )
      ) .

    { gbl/working.i }

    case v-request :
      when '01'
      then do:
        define variable v-request01-remote-device  as character no-undo .
        define variable v-request01-session-id     as character no-undo .
        define variable v-request01-user-login     as character no-undo .
        define variable v-request01-session-valid  as logical   no-undo .
        define variable v-request01-error-message  as character no-undo .
        define variable v-request01-obj-type       as character no-undo .
        define variable v-request01-obj-code       as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request01-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request01-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request01-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request01-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request01-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request01-session-id
          ,input  v-request01-remote-device
          ,output v-request01-session-valid
          ,output v-request01-error-message
          ) .

        run gbl/rt-req01.p
          (input  p-directory-out
          ,input  p-file-name
          ,input  v-request01-session-valid
          ,input  v-request01-error-message
          ,input  v-request01-user-login
          ,input  v-request01-obj-type
          ,input  v-request01-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req01.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '02'
      then do:
        define variable v-request02-remote-device  as character no-undo .
        define variable v-request02-session-id     as character no-undo .
        define variable v-request02-user-login     as character no-undo .
        define variable v-request02-session-valid  as logical   no-undo .
        define variable v-request02-error-message  as character no-undo .
        define variable v-request02-obj-type       as character no-undo .
        define variable v-request02-obj-code       as character no-undo .
        define variable v-request02-bar-code       as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request02-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request02-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request02-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request02-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request02-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'bar_code':u
          ,output v-request02-bar-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request02-session-id
          ,input  v-request02-remote-device
          ,output v-request02-session-valid
          ,output v-request02-error-message
          ) .

        run gbl/rt-req02.p
          (input  p-callback-handle
          ,input  p-directory-out
          ,input  p-file-name
          ,input  v-request02-session-valid
          ,input  v-request02-error-message
          ,input  v-request02-user-login
          ,input  v-request02-obj-type
          ,input  v-request02-obj-code
          ,input  v-request02-bar-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req02.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '03'
      then do:
        define variable v-request03-remote-device  as character no-undo .
        define variable v-request03-session-id     as character no-undo .
        define variable v-request03-user-login     as character no-undo .
        define variable v-request03-session-valid  as logical   no-undo .
        define variable v-request03-error-message  as character no-undo .
        define variable v-request03-obj-type       as character no-undo .
        define variable v-request03-obj-code       as character no-undo .
        define variable v-request03-bar-code       as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request03-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request03-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request03-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request03-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request03-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'bar_code':u
          ,output v-request03-bar-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request03-session-id
          ,input  v-request03-remote-device
          ,output v-request03-session-valid
          ,output v-request03-error-message
          ) .

        run gbl/rt-req03.p
          (input  p-callback-handle
          ,input  p-directory-out
          ,input  p-file-name
          ,input  v-request03-session-valid
          ,input  v-request03-error-message
          ,input  v-request03-user-login
          ,input  v-request03-obj-type
          ,input  v-request03-obj-code
          ,input  v-request03-bar-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req03.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '04'
      then do:
        define variable v-request04-remote-device     as character no-undo .
        define variable v-request04-session-id        as character no-undo .
        define variable v-request04-user-login        as character no-undo .
        define variable v-request04-session-valid     as logical   no-undo .
        define variable v-request04-error-message     as character no-undo .
        define variable v-request04-obj-type          as character no-undo .
        define variable v-request04-obj-code          as character no-undo .
        define variable v-request04-host-code         as character no-undo .
        define variable v-request04-status            as character no-undo .
        define variable v-request04-cop-check         as character no-undo .
        define variable v-request04-prod-artic-search as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request04-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request04-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request04-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request04-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request04-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'host_code':u
          ,output v-request04-host-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'status':u
          ,output v-request04-status
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'cop_check':u
          ,output v-request04-cop-check
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'prod_artic_search':u
          ,output v-request04-prod-artic-search
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request04-session-id
          ,input  v-request04-remote-device
          ,output v-request04-session-valid
          ,output v-request04-error-message
          ) .

        run gbl/rt-req04.p
          (input  p-directory-out
          ,input  p-file-name
          ,input  v-request04-session-valid
          ,input  v-request04-error-message
          ,input  v-request04-user-login
          ,input  v-request04-obj-type
          ,input  v-request04-obj-code
          ,input  v-request04-host-code
          ,input  v-request04-status
          ,input  v-request04-cop-check
          ,input  v-request04-prod-artic-search
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req04.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '05'
      then do:
        define variable v-request05-remote-device  as character no-undo .
        define variable v-request05-session-id     as character no-undo .
        define variable v-request05-user-login     as character no-undo .
        define variable v-request05-session-valid  as logical   no-undo .
        define variable v-request05-error-message  as character no-undo .
        define variable v-request05-obj-type       as character no-undo .
        define variable v-request05-obj-code       as character no-undo .
        define variable v-request05-host-code      as character no-undo .
        define variable v-request05-doc-type       as character no-undo .
        define variable v-request05-doc-code       as character no-undo .
        define variable v-request05-doc-time       as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request05-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request05-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request05-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request05-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request05-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'host_code':u
          ,output v-request05-host-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_type':u
          ,output v-request05-doc-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_code':u
          ,output v-request05-doc-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_time':u
          ,output v-request05-doc-time
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request05-session-id
          ,input  v-request05-remote-device
          ,output v-request05-session-valid
          ,output v-request05-error-message
          ) .

        run gbl/rt-req05.p
          (input  p-directory-out
          ,input  p-file-name
          ,input  v-request05-session-valid
          ,input  v-request05-error-message
          ,input  v-request05-user-login
          ,input  v-request05-obj-type
          ,input  v-request05-obj-code
          ,input  v-request05-host-code
          ,input  v-request05-doc-type
          ,input  v-request05-doc-code
          ,input  v-request05-doc-time
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req05.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '06'
      then do:
        define variable v-request06-remote-device  as character no-undo .
        define variable v-request06-session-id     as character no-undo .
        define variable v-request06-user-login     as character no-undo .
        define variable v-request06-session-valid  as logical   no-undo .
        define variable v-request06-error-message  as character no-undo .
        define variable v-request06-obj-type       as character no-undo .
        define variable v-request06-obj-code       as character no-undo .
        define variable v-request06-host-code      as character no-undo .
        define variable v-request06-cli-type       as character no-undo .
        define variable v-request06-cli-code       as character no-undo .
        define variable v-request06-doc-type       as character no-undo .
        define variable v-request06-status         as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request06-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request06-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request06-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request06-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request06-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'host_code':u
          ,output v-request06-host-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'cli_type':u
          ,output v-request06-cli-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'cli_code':u
          ,output v-request06-cli-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_type':u
          ,output v-request06-doc-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'status':u
          ,output v-request06-status
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request06-session-id
          ,input  v-request06-remote-device
          ,output v-request06-session-valid
          ,output v-request06-error-message
          ) .

        run gbl/rt-req06.p
          (input  p-directory-out
          ,input  p-file-name
          ,input  v-request06-session-valid
          ,input  v-request06-error-message
          ,input  v-request06-user-login
          ,input  v-request06-obj-type
          ,input  v-request06-obj-code
          ,input  v-request06-host-code
          ,input  v-request06-cli-type
          ,input  v-request06-cli-code
          ,input  v-request06-doc-type
          ,input  v-request06-status
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req06.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '07'
      then do:
        define variable v-request07-remote-device  as character no-undo .
        define variable v-request07-session-id     as character no-undo .
        define variable v-request07-user-login     as character no-undo .
        define variable v-request07-session-valid  as logical   no-undo .
        define variable v-request07-error-message  as character no-undo .
        define variable v-request07-obj-type       as character no-undo .
        define variable v-request07-obj-code       as character no-undo .
        define variable v-request07-host-code      as character no-undo .
        define variable v-request07-cli-type       as character no-undo .
        define variable v-request07-cli-code       as character no-undo .
        define variable v-request07-doc-type       as character no-undo .
        define variable v-request07-status         as character no-undo .
        define variable v-request07-doc-code-first as character no-undo .
        define variable v-request07-doc-code-last  as character no-undo .
        define variable v-request07-direction      as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request07-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request07-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request07-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request07-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request07-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'host_code':u
          ,output v-request07-host-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'cli_type':u
          ,output v-request07-cli-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'cli_code':u
          ,output v-request07-cli-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_type':u
          ,output v-request07-doc-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'status':u
          ,output v-request07-status
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_code_first':u
          ,output v-request07-doc-code-first
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_code_last':u
          ,output v-request07-doc-code-last
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'direction':u
          ,output v-request07-direction
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request07-session-id
          ,input  v-request07-remote-device
          ,output v-request07-session-valid
          ,output v-request07-error-message
          ) .

        run gbl/rt-req07.p
          (input  p-directory-out
          ,input  p-file-name
          ,input  v-request07-session-valid
          ,input  v-request07-error-message
          ,input  v-request07-user-login
          ,input  v-request07-obj-type
          ,input  v-request07-obj-code
          ,input  v-request07-host-code
          ,input  v-request07-cli-type
          ,input  v-request07-cli-code
          ,input  v-request07-doc-type
          ,input  v-request07-status
          ,input  v-request07-doc-code-first
          ,input  v-request07-doc-code-last
          ,input  v-request07-direction
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req07.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '08'
      then do:
        define variable v-request08-remote-device  as character no-undo .
        define variable v-request08-session-id     as character no-undo .
        define variable v-request08-user-login     as character no-undo .
        define variable v-request08-session-valid  as logical   no-undo .
        define variable v-request08-error-message  as character no-undo .
        define variable v-request08-obj-type       as character no-undo .
        define variable v-request08-obj-code       as character no-undo .
        define variable v-request08-host-code      as character no-undo .
        define variable v-request08-cli-type       as character no-undo .
        define variable v-request08-cli-code       as character no-undo .
        define variable v-request08-doc-type       as character no-undo .
        define variable v-request08-status         as character no-undo .
        define variable v-request08-doc-time       as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request08-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request08-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request08-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request08-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request08-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'host_code':u
          ,output v-request08-host-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'cli_type':u
          ,output v-request08-cli-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'cli_code':u
          ,output v-request08-cli-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_type':u
          ,output v-request08-doc-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'status':u
          ,output v-request08-status
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_time':u
          ,output v-request08-doc-time
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.


        run validate-session in this-procedure
          (input  v-request08-session-id
          ,input  v-request08-remote-device
          ,output v-request08-session-valid
          ,output v-request08-error-message
          ) .

        run gbl/rt-req08.p
          (input  p-directory-out
          ,input  p-file-name
          ,input  v-request08-session-valid
          ,input  v-request08-error-message
          ,input  v-request08-user-login
          ,input  v-request08-obj-type
          ,input  v-request08-obj-code
          ,input  v-request08-host-code
          ,input  v-request08-cli-type
          ,input  v-request08-cli-code
          ,input  v-request08-doc-type
          ,input  v-request08-status
          ,input  v-request08-doc-time
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req08.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '09'
      then do:
        define variable v-request09-remote-device     as character no-undo .
        define variable v-request09-session-id        as character no-undo .
        define variable v-request09-user-login        as character no-undo .
        define variable v-request09-session-valid     as logical   no-undo .
        define variable v-request09-error-message     as character no-undo .
        define variable v-request09-obj-type          as character no-undo .
        define variable v-request09-obj-code          as character no-undo .
        define variable v-request09-host-code         as character no-undo .
        define variable v-request09-doc-type          as character no-undo .
        define variable v-request09-doc-code          as character no-undo .
        define variable v-request09-bar-code          as character no-undo .
        define variable v-request09-fact-qnty         as character no-undo .
        define variable v-request09-prod-artic        as character no-undo .
        define variable v-request09-prod-artic-search as character no-undo .
        define variable v-request09-deadline-date     as character no-undo .
        define variable v-request09-cop-check         as character no-undo .
        define variable v-request09-price-docf        as character no-undo .


        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request09-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request09-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request09-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request09-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request09-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'host_code':u
          ,output v-request09-host-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_type':u
          ,output v-request09-doc-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_code':u
          ,output v-request09-doc-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'bar_code':u
          ,output v-request09-bar-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'fact_qnty':u
          ,output v-request09-fact-qnty
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'prod_artic':u
          ,output v-request09-prod-artic
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'prod_artic_search':u
          ,output v-request09-prod-artic-search
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'deadline_date':u
          ,output v-request09-deadline-date
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'cop_check':u
          ,output v-request09-cop-check
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'price_docf':u
          ,output v-request09-price-docf
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request09-session-id
          ,input  v-request09-remote-device
          ,output v-request09-session-valid
          ,output v-request09-error-message
          ) .

        run gbl/rt-req09.p
          (input  p-callback-handle               /* parparentproc        */
          ,input  p-directory-out                 /* p-directory-out      */
          ,input  p-file-name                     /* p-file-name          */
          ,input  v-request09-session-valid       /* p-session-valid      */
          ,input  v-request09-error-message       /* p-error-message      */
          ,input  v-request09-user-login          /* p-user-login         */
          ,input  v-request09-obj-type            /* p-obj-type           */
          ,input  v-request09-obj-code            /* p-obj-code           */
          ,input  v-request09-host-code           /* p-host-code          */
          ,input  v-request09-doc-type            /* p-doc-type           */
          ,input  v-request09-doc-code            /* p-doc-code           */
          ,input  v-request09-bar-code            /* p-bar-code           */
          ,input  v-request09-fact-qnty           /* p-fact-qnty          */
          ,input  v-request09-prod-artic          /* p-prod-artic         */
          ,input  v-request09-prod-artic-search   /* p-prod-artic-search  */
          ,input  v-request09-deadline-date       /* p-deadline-date      */
          ,input  v-request09-cop-check           /* p-cop-check          */
          ,input  v-request09-price-docf          /* p-price-docf         */
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req09.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '10'
      then do:
        define variable v-request10-remote-device  as character no-undo .
        define variable v-request10-session-id     as character no-undo .
        define variable v-request10-user-login     as character no-undo .
        define variable v-request10-session-valid  as logical   no-undo .
        define variable v-request10-error-message  as character no-undo .
        define variable v-request10-obj-type       as character no-undo .
        define variable v-request10-obj-code       as character no-undo .
        define variable v-request10-host-code      as character no-undo .
        define variable v-request10-doc-type       as character no-undo .
        define variable v-request10-doc-code       as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request10-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request10-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request10-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request10-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request10-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'host_code':u
          ,output v-request10-host-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_type':u
          ,output v-request10-doc-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_code':u
          ,output v-request10-doc-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request10-session-id
          ,input  v-request10-remote-device
          ,output v-request10-session-valid
          ,output v-request10-error-message
          ) .

        run gbl/rt-req10.p
          (input  p-callback-handle
          ,input  p-directory-out
          ,input  p-file-name
          ,input  v-request10-session-valid
          ,input  v-request10-error-message
          ,input  v-request10-user-login
          ,input  v-request10-obj-type
          ,input  v-request10-obj-code
          ,input  v-request10-host-code
          ,input  v-request10-doc-type
          ,input  v-request10-doc-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req10.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '11'
      then do:
        define variable v-request11-remote-device  as character no-undo .
        define variable v-request11-session-id     as character no-undo .
        define variable v-request11-user-login     as character no-undo .
        define variable v-request11-session-valid  as logical   no-undo .
        define variable v-request11-error-message  as character no-undo .
        define variable v-request11-obj-type       as character no-undo .
        define variable v-request11-obj-code       as character no-undo .
        define variable v-request11-host-code      as character no-undo .
        define variable v-request11-doc-type       as character no-undo .
        define variable v-request11-doc-code       as character no-undo .
        define variable v-request11-status         as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request11-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request11-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request11-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request11-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request11-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'host_code':u
          ,output v-request11-host-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_type':u
          ,output v-request11-doc-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_code':u
          ,output v-request11-doc-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'status':u
          ,output v-request11-status
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request11-session-id
          ,input  v-request11-remote-device
          ,output v-request11-session-valid
          ,output v-request11-error-message
          ) .

        run gbl/rt-req11.p
          (input  p-callback-handle
          ,input  p-directory-out
          ,input  p-file-name
          ,input  v-request11-session-valid
          ,input  v-request11-error-message
          ,input  v-request11-user-login
          ,input  v-request11-obj-type
          ,input  v-request11-obj-code
          ,input  v-request11-host-code
          ,input  v-request11-doc-type
          ,input  v-request11-doc-code
          ,input  v-request11-status
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req11.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '12'
      then do:
        define variable v-request12-remote-device  as character no-undo .
        define variable v-request12-user-login     as character no-undo .
        define variable v-request12-function       as character no-undo .
        define variable v-request12-random-number  as character no-undo .
        define variable v-request12-password       as character no-undo .
        define variable v-request12-session-id     as character no-undo .
        define variable v-request12-password-valid as logical   no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request12-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request12-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'function':u
          ,output v-request12-function
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'random_number':u
          ,output v-request12-random-number
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'password':u
          ,output v-request12-password
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run gen-session-id in this-procedure
          (output v-request12-session-id
          ) .

        run gbl/rt-req12.p
          (input  p-directory-out
          ,input  p-file-name
          ,input  v-current-user-num
          ,input  p-max-user-num
          ,input  v-request12-user-login
          ,input  v-request12-function
          ,input  v-request12-random-number
          ,input  v-request12-password
          ,input  v-request12-session-id
          ,output v-request12-password-valid
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req12.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.

        if v-request12-password-valid = true
        then do:
          run register-session-id in this-procedure
            (input  v-request12-session-id
            ,input  v-request12-user-login
            ,input  v-request12-remote-device
            ) .
        end.
      end.
      when '13'
      then do:
        define variable v-request13-session-id    as character no-undo .
        define variable v-request13-remote-device as character no-undo .
        define variable v-request13-session-valid as logical   no-undo .
        define variable v-request13-error-message as character no-undo .

        run get-param-data in this-procedure
          (input  'session_id'
          ,output v-request13-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'remote_device'
          ,output v-request13-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request13-session-id
          ,input  v-request13-remote-device
          ,output v-request13-session-valid
          ,output v-request13-error-message
          ) .

        if v-request13-session-valid = true
        then do:
          /* удалить информацию о сессии */
          run delete-session in this-procedure
            (input v-request13-session-id
            ) .
        end.

        run gbl/rt-req13.p
          (input  p-directory-out
          ,input  p-file-name
          ,input  v-request13-session-valid
          ,input  v-request13-error-message
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req13.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '14'
      then do:
        define variable v-request14-remote-device     as character no-undo .
        define variable v-request14-session-id        as character no-undo .
        define variable v-request14-user-login        as character no-undo .
        define variable v-request14-session-valid     as logical   no-undo .
        define variable v-request14-error-message     as character no-undo .
        define variable v-request14-obj-type          as character no-undo .
        define variable v-request14-obj-code          as character no-undo .
        define variable v-request14-host-code         as character no-undo .
        define variable v-request14-doc-type          as character no-undo .
        define variable v-request14-doc-code          as character no-undo .
        define variable v-request14-bar-code          as character no-undo .
        define variable v-request14-cli-qnty          as character no-undo .
        define variable v-request14-unit-cli          as character no-undo .
        define variable v-request14-cli-base-rate     as character no-undo .
        define variable v-request14-line-number       as character no-undo .
        define variable v-request14-price-cli         as character no-undo .
        define variable v-request14-prod-artic        as character no-undo .
        define variable v-request14-prod-artic-search as character no-undo .
        define variable v-request14-price-docf        as character no-undo .
        define variable v-request14-deadline-date     as character no-undo .
        define variable v-request14-cop-check         as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request14-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request14-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request14-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request14-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request14-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'host_code':u
          ,output v-request14-host-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_type':u
          ,output v-request14-doc-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_code':u
          ,output v-request14-doc-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'bar_code':u
          ,output v-request14-bar-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'cli_qnty':u
          ,output v-request14-cli-qnty
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'unit_cli':u
          ,output v-request14-unit-cli
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'cli_base_rate':u
          ,output v-request14-cli-base-rate
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'line_number':u
          ,output v-request14-line-number
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'price_cli':u
          ,output v-request14-price-cli
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'prod_artic':u
          ,output v-request14-prod-artic
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'prod_artic_search':u
          ,output v-request14-prod-artic-search
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'price_docf':u
          ,output v-request14-price-docf
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'deadline_date':u
          ,output v-request14-deadline-date
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'cop_check':u
          ,output v-request14-cop-check
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request14-session-id
          ,input  v-request14-remote-device
          ,output v-request14-session-valid
          ,output v-request14-error-message
          ) .

        run gbl/rt-req14.p
          (input  p-callback-handle             /* parparentproc        */
          ,input  p-directory-out               /* p-directory-out      */
          ,input  p-file-name                   /* p-file-name          */
          ,input  v-request14-session-valid     /* p-session-valid      */
          ,input  v-request14-error-message     /* p-error-message      */
          ,input  v-request14-user-login        /* p-user-login         */
          ,input  v-request14-obj-type          /* p-obj-type           */
          ,input  v-request14-obj-code          /* p-obj-code           */
          ,input  v-request14-host-code         /* p-host-code          */
          ,input  v-request14-doc-type          /* p-doc-type           */
          ,input  v-request14-doc-code          /* p-doc-code           */
          ,input  v-request14-bar-code          /* p-bar-code           */
          ,input  v-request14-cli-qnty          /* p-cli-qnty           */
          ,input  v-request14-unit-cli          /* p-unit-cli           */
          ,input  v-request14-cli-base-rate     /* p-cli-base-rate      */
          ,input  v-request14-line-number       /* p-line-number        */
          ,input  v-request14-price-cli         /* p-price-cli          */
          ,input  v-request14-prod-artic        /* p-prod-artic         */
          ,input  v-request14-prod-artic-search /* p-prod-artic-search  */
          ,input  v-request14-price-docf        /* p-price-docf         */
          ,input  v-request14-deadline-date     /* p-deadline-date      */
          ,input  v-request14-cop-check         /* p-cop-check          */
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req14.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '15'
      then do:
        define variable v-request15-remote-device  as character no-undo .
        define variable v-request15-session-id     as character no-undo .
        define variable v-request15-user-login     as character no-undo .
        define variable v-request15-session-valid  as logical   no-undo .
        define variable v-request15-error-message  as character no-undo .
        define variable v-request15-obj-type       as character no-undo .
        define variable v-request15-obj-code       as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request15-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request15-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request15-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request15-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request15-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request15-session-id
          ,input  v-request15-remote-device
          ,output v-request15-session-valid
          ,output v-request15-error-message
          ) .

        run gbl/rt-req15.p
          (input  p-callback-handle
          ,input  p-directory-out
          ,input  p-file-name
          ,input  v-request15-session-valid
          ,input  v-request15-error-message
          ,input  v-request15-user-login
          ,input  v-request15-obj-type
          ,input  v-request15-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req15.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '16'
      then do:
        define variable v-request16-remote-device     as character no-undo .
        define variable v-request16-session-id        as character no-undo .
        define variable v-request16-user-login        as character no-undo .
        define variable v-request16-session-valid     as logical   no-undo .
        define variable v-request16-error-message     as character no-undo .
        define variable v-request16-obj-type          as character no-undo .
        define variable v-request16-obj-code          as character no-undo .
        define variable v-request16-host-code         as character no-undo .
        define variable v-request16-doc-type          as character no-undo .
        define variable v-request16-doc-code          as character no-undo .
        define variable v-request16-bar-code          as character no-undo .
        define variable v-request16-prod-artic        as character no-undo .
        define variable v-request16-prod-artic-search as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request16-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request16-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request16-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request16-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request16-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'host_code':u
          ,output v-request16-host-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_type':u
          ,output v-request16-doc-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_code':u
          ,output v-request16-doc-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'bar_code':u
          ,output v-request16-bar-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'prod_artic':u
          ,output v-request16-prod-artic
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'prod_artic_search':u
          ,output v-request16-prod-artic-search
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request16-session-id
          ,input  v-request16-remote-device
          ,output v-request16-session-valid
          ,output v-request16-error-message
          ) .

        run gbl/rt-req16.p
          (input  p-callback-handle             /* parparentproc        */
          ,input  p-directory-out               /* p-directory-out      */
          ,input  p-file-name                   /* p-file-name          */
          ,input  v-request16-session-valid     /* p-session-valid      */
          ,input  v-request16-error-message     /* p-error-message      */
          ,input  v-request16-user-login        /* p-user-login         */
          ,input  v-request16-obj-type          /* p-obj-type           */
          ,input  v-request16-obj-code          /* p-obj-code           */
          ,input  v-request16-host-code         /* p-host-code          */
          ,input  v-request16-doc-type          /* p-doc-type           */
          ,input  v-request16-doc-code          /* p-doc-code           */
          ,input  v-request16-bar-code          /* p-bar-code           */
          ,input  v-request16-prod-artic        /* p-prod-artic         */
          ,input  v-request16-prod-artic-search /* p-prod-artic-search  */
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req16.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '17'
      then do:
        define variable v-request17-remote-device     as character no-undo .
        define variable v-request17-session-id        as character no-undo .
        define variable v-request17-user-login        as character no-undo .
        define variable v-request17-session-valid     as logical   no-undo .
        define variable v-request17-error-message     as character no-undo .
        define variable v-request17-obj-type          as character no-undo .
        define variable v-request17-obj-code          as character no-undo .
        define variable v-request17-host-code         as character no-undo .
        define variable v-request17-doc-type          as character no-undo .
        define variable v-request17-doc-code          as character no-undo .
        define variable v-request17-bar-code          as character no-undo .
        define variable v-request17-prod-artic        as character no-undo .
        define variable v-request17-prod-artic-search as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request17-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request17-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request17-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request17-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request17-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'host_code':u
          ,output v-request17-host-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_type':u
          ,output v-request17-doc-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_code':u
          ,output v-request17-doc-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'bar_code':u
          ,output v-request17-bar-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'prod_artic':u
          ,output v-request17-prod-artic
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'prod_artic_search':u
          ,output v-request17-prod-artic-search
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request17-session-id
          ,input  v-request17-remote-device
          ,output v-request17-session-valid
          ,output v-request17-error-message
          ) .

        run gbl/rt-req17.p
          (input  p-callback-handle             /* parparentproc        */
          ,input  p-directory-out               /* p-directory-out      */
          ,input  p-file-name                   /* p-file-name          */
          ,input  v-request17-session-valid     /* p-session-valid      */
          ,input  v-request17-error-message     /* p-error-message      */
          ,input  v-request17-user-login        /* p-user-login         */
          ,input  v-request17-obj-type          /* p-obj-type           */
          ,input  v-request17-obj-code          /* p-obj-code           */
          ,input  v-request17-host-code         /* p-host-code          */
          ,input  v-request17-doc-type          /* p-doc-type           */
          ,input  v-request17-doc-code          /* p-doc-code           */
          ,input  v-request17-bar-code          /* p-bar-code           */
          ,input  v-request17-prod-artic        /* p-prod-artic         */
          ,input  v-request17-prod-artic-search /* p-prod-artic-search  */
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req17.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '18'
      then do:
        define variable v-request18-remote-device  as character no-undo .
        define variable v-request18-obj-type       as character no-undo .
        define variable v-request18-obj-code       as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request18-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request18-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request18-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run gbl/rt-req18.p
          (input  p-directory-out
          ,input  p-file-name
          ,input  v-request18-obj-type
          ,input  v-request18-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req18.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '19'
      then do:
        define variable v-request19-remote-device  as character no-undo .
        define variable v-request19-obj-type       as character no-undo .
        define variable v-request19-obj-code       as character no-undo .
        define variable v-request19-bar-code       as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request19-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request19-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request19-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'bar_code':u
          ,output v-request19-bar-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run gbl/rt-req19.p
          (input  p-callback-handle
          ,input  p-directory-out
          ,input  p-file-name
          ,input  v-request19-obj-type
          ,input  v-request19-obj-code
          ,input  v-request19-bar-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req19.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '20'
      then do:
        define variable v-request20-remote-device  as character no-undo .
        define variable v-request20-session-id     as character no-undo .
        define variable v-request20-user-login     as character no-undo .
        define variable v-request20-obj-type       as character no-undo .
        define variable v-request20-obj-code       as character no-undo .
        define variable v-request20-host-code      as character no-undo .
        define variable v-request20-cli-type       as character no-undo .
        define variable v-request20-cli-code       as character no-undo .
        define variable v-request20-doc-code       as character no-undo .
        define variable v-request20-doc-type       as character no-undo .
        define variable v-request20-status         as character no-undo .
        define variable v-request20-doc-line-first as character no-undo .
        define variable v-request20-doc-line-last  as character no-undo .
        define variable v-request20-direction      as character no-undo .
        define variable v-request20-session-valid  as logical   no-undo .
        define variable v-request20-error-message  as character no-undo .


        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request20-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request20-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request20-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request20-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request20-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'host_code':u
          ,output v-request20-host-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'cli_type':u
          ,output v-request20-cli-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'cli_code':u
          ,output v-request20-cli-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_code':u
          ,output v-request20-doc-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_type':u
          ,output v-request20-doc-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'status':u
          ,output v-request20-status
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_line_first':u
          ,output v-request20-doc-line-first
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_line_last':u
          ,output v-request20-doc-line-last
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'direction':u
          ,output v-request20-direction
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request20-session-id
          ,input  v-request20-remote-device
          ,output v-request20-session-valid
          ,output v-request20-error-message
          ) .

        run gbl/rt-req20.p
          (input  p-callback-handle           /* parparentproc    */
          ,input  p-directory-out             /* p-directory-out  */
          ,input  p-file-name                 /* p-file-name      */
          ,input  v-request20-session-valid   /* p-session-valid  */
          ,input  v-request20-error-message   /* p-error-message  */
          ,input  v-request20-user-login      /* p-user-login     */
          ,input  v-request20-obj-type        /* p-obj-type       */
          ,input  v-request20-obj-code        /* p-obj-code       */
          ,input  v-request20-host-code       /* p-host-code      */
          ,input  v-request20-cli-type        /* p-cli-type       */
          ,input  v-request20-cli-code        /* p-cli-code       */
          ,input  v-request20-doc-code        /* p-doc-code       */
          ,input  v-request20-doc-type        /* p-doc-type       */
          ,input  v-request20-status          /* p-status         */
          ,input  v-request20-doc-line-first  /* p-doc-line-first */
          ,input  v-request20-doc-line-last   /* p-doc-line-last  */
          ,input  v-request20-direction       /* p-direction      */

          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req20.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '21'
      then do:
        define variable v-request21-remote-device  as character no-undo .
        define variable v-request21-session-id     as character no-undo .
        define variable v-request21-user-login     as character no-undo .
        define variable v-request21-obj-type       as character no-undo .
        define variable v-request21-obj-code       as character no-undo .
        define variable v-request21-host-code      as character no-undo .
        define variable v-request21-doc-code       as character no-undo .
        define variable v-request21-doc-type       as character no-undo .
        define variable v-request21-gds-code       as character no-undo .
        define variable v-request21-session-valid  as logical   no-undo .
        define variable v-request21-error-message  as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request21-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request21-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request21-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request21-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request21-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'host_code':u
          ,output v-request21-host-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_type':u
          ,output v-request21-doc-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_code':u
          ,output v-request21-doc-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'gds_code':u
          ,output v-request21-gds-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request21-session-id
          ,input  v-request21-remote-device
          ,output v-request21-session-valid
          ,output v-request21-error-message
          ) .

        run gbl/rt-req21.p
          (input  p-callback-handle           /* parparentproc    */
          ,input  p-directory-out             /* p-directory-out  */
          ,input  p-file-name                 /* p-file-name      */
          ,input  v-request21-session-valid   /* p-session-valid  */
          ,input  v-request21-error-message   /* p-error-message  */
          ,input  v-request21-user-login      /* p-user-login     */
          ,input  v-request21-obj-type        /* p-obj-type       */
          ,input  v-request21-obj-code        /* p-obj-code       */
          ,input  v-request21-host-code       /* p-host-code      */
          ,input  v-request21-doc-code        /* p-doc-code       */
          ,input  v-request21-doc-type        /* p-doc-type       */
          ,input  v-request21-gds-code        /* p-gds-code       */
          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req21.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      when '22'
      then do:
        define variable v-request22-remote-device  as character no-undo .
        define variable v-request22-session-id     as character no-undo .
        define variable v-request22-user-login     as character no-undo .
        define variable v-request22-obj-type       as character no-undo .
        define variable v-request22-obj-code       as character no-undo .
        define variable v-request22-host-code      as character no-undo .
        define variable v-request22-cli-type       as character no-undo .
        define variable v-request22-cli-code       as character no-undo .
        define variable v-request22-doc-type       as character no-undo .
        define variable v-request22-doc-code       as character no-undo .
        define variable v-request22-status         as character no-undo .
        define variable v-request22-gds-code       as character no-undo .
        define variable v-request22-session-valid  as logical   no-undo .
        define variable v-request22-error-message  as character no-undo .

        run get-param-data in this-procedure
          (input  'remote_device':u
          ,output v-request22-remote-device
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'session_id':u
          ,output v-request22-session-id
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'user_id':u
          ,output v-request22-user-login
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_type':u
          ,output v-request22-obj-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'obj_code':u
          ,output v-request22-obj-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'host_code':u
          ,output v-request22-host-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'cli_type':u
          ,output v-request22-cli-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'cli_code':u
          ,output v-request22-cli-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_type':u
          ,output v-request22-doc-type
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'doc_code':u
          ,output v-request22-doc-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'status':u
          ,output v-request22-status
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run get-param-data in this-procedure
          (input  'gds_code':u
          ,output v-request22-gds-code
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.

        run validate-session in this-procedure
          (input  v-request22-session-id
          ,input  v-request22-remote-device
          ,output v-request22-session-valid
          ,output v-request22-error-message
          ) .

        run gbl/rt-req22.p
          (input  p-callback-handle           /* parparentproc    */
          ,input  p-directory-out             /* p-directory-out  */
          ,input  p-file-name                 /* p-file-name      */
          ,input  v-request22-session-valid   /* p-session-valid  */
          ,input  v-request22-error-message   /* p-error-message  */
          ,input  v-request22-user-login      /* p-user-login     */
          ,input  v-request22-obj-type        /* p-obj-type       */
          ,input  v-request22-obj-code        /* p-obj-code       */
          ,input  v-request22-host-code       /* p-host-code      */
          ,input  v-request22-cli-type        /* p-cli-type       */
          ,input  v-request22-cli-code        /* p-cli-code       */
          ,input  v-request22-doc-type        /* p-doc-type       */
          ,input  v-request22-doc-code        /* p-doc-code       */
          ,input  v-request22-status          /* p-status         */
          ,input  v-request22-gds-code        /* p-gds-code       */

          ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("Ошибка при вызове функции rt-req22.p. &1 &2"
                                       ,error-status :get-message(1)
                                       ,return-value
                                       ) .
        end.
      end.
      otherwise do:
        undo, return error substitute("Неизвестный запрос &1", v-request) .
      end.
    end case .

    { gbl/stopwork.i }

    run w-reqsrv_show-description in p-callback-handle
      (input substitute("Работает &1 из &2 пользователей"
                       ,v-current-user-num
                       ,p-max-user-num
                       )
      ) .
  end.

end procedure. /* rt-reply_process-request */


procedure read-param-data :

  define input  parameter p-file-name as character no-undo .

  define buffer buf_temp-param for temp-param .

  define variable v-read-string as character no-undo .
  define variable v-param-code  as character no-undo .
  define variable v-param-value as character no-undo .

  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error return-value
    :
      delete buf_temp-param .
    end.

    input stream sinp from value (p-file-name) .


    repeat
    :
      assign
        v-read-string = ''
      .

      import stream sinp unformatted v-read-string .

      if num-entries(v-read-string, ':':u) <> 2
      then do:
        undo, return error substitute("Ошибка структуры строки файла &1", v-read-string) .
      end.

      assign
        v-param-code  = entry(1, v-read-string, ':':u)
        v-param-value = str-decode(entry(2, v-read-string, ':':u), '')
      .

      find first buf_temp-param
        where buf_temp-param.param-code = v-param-code
        no-error .
      if available buf_temp-param
      then do:
        undo, return error substitute("Попытка повторного создания параметра с кодом &1", v-param-code) .
      end.

      create buf_temp-param .
      assign
        buf_temp-param.param-code     = v-param-code
        buf_temp-param.param-value    = v-param-value
      .
    end.

    input stream sinp close .
  end.

end procedure. /* read-param-data */


procedure get-param-data :

  define input  parameter p-param-code     as character no-undo .
  define output parameter p-param-value    as character no-undo .

  define buffer buf_temp-param for temp-param .

  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code = p-param-code
      no-error .
    if available buf_temp-param
    then do:
      assign
        p-param-value = buf_temp-param.param-value
      .
    end.
    else do:
      undo, return error substitute("Не найден параметр &1", p-param-code) .
    end.
  end.

end procedure. /* get-param-data */


procedure gen-session-id :

  define output parameter p-session-id    as character no-undo .

  define variable v-session-id as character no-undo .

  define buffer buf_temp-session for temp-session .

  define variable v-char-list as character no-undo .

  assign
    v-char-list = '0123456789abcdefghijklmnopqrstuvwxyz'
  .

  do
  on error undo, return error return-value
  :
    do while true
    :
      assign
        v-session-id = substring(v-char-list, random(1,length(v-char-list)), 1)
                     + substring(v-char-list, random(1,length(v-char-list)), 1)
                     + substring(v-char-list, random(1,length(v-char-list)), 1)
                     + substring(v-char-list, random(1,length(v-char-list)), 1)
                     + substring(v-char-list, random(1,length(v-char-list)), 1)
                     + substring(v-char-list, random(1,length(v-char-list)), 1)
                     + substring(v-char-list, random(1,length(v-char-list)), 1)
                     + substring(v-char-list, random(1,length(v-char-list)), 1)
                     + substring(v-char-list, random(1,length(v-char-list)), 1)
                     + substring(v-char-list, random(1,length(v-char-list)), 1)
                     + substring(v-char-list, random(1,length(v-char-list)), 1)
                     + substring(v-char-list, random(1,length(v-char-list)), 1)
                     + substring(v-char-list, random(1,length(v-char-list)), 1)
                     + substring(v-char-list, random(1,length(v-char-list)), 1)
                     + substring(v-char-list, random(1,length(v-char-list)), 1)
                     + substring(v-char-list, random(1,length(v-char-list)), 1)
      .

      find first buf_temp-session
        where buf_temp-session.session-id = v-session-id
        no-error .
      if not available buf_temp-session
      then do:
        assign
          p-session-id = v-session-id
        .

        return . /* --->>>--- */
      end.
    end.
  end.

end procedure. /* gen-session-id */

procedure register-session-id :

  define input  parameter p-session-id    as character no-undo .
  define input  parameter p-user-login    as character no-undo .
  define input  parameter p-remote-device as character no-undo .

  define buffer buf_temp-session for temp-session .

  do
  on error undo, return error return-value
  :
    find first buf_temp-session
      where buf_temp-session.session-id = p-session-id
      no-error .
    if available buf_temp-session
    then do:
      undo, return error substitute("Уже существует сессия с идентификатором &1", p-session-id) .
    end.

    /* с одного терминала может работать только пользователь */
    for each buf_temp-session
      where buf_temp-session.session-remote-device = p-remote-device
    on error undo, return error return-value
    :
      run delete-session in this-procedure
        (input buf_temp-session.session-id
        ) .
    end.

    assign
      v-current-user-num = v-current-user-num + 1
    .
    create buf_temp-session .
    assign
      buf_temp-session.session-id            = p-session-id
      buf_temp-session.session-user-login    = p-user-login
      buf_temp-session.session-remote-device = p-remote-device
    .
    assign
      buf_temp-session.session-start-time = sys-time_get-mjd-func()
      buf_temp-session.session-last-request-time = buf_temp-session.session-start-time
    .
  end.

end procedure. /* gen-session-id */


procedure validate-session :

  define input  parameter p-session-id    as character no-undo .
  define input  parameter p-remote-device as character no-undo .
  define output parameter p-session-valid as logical   no-undo .
  define output parameter p-message       as character no-undo .

  define buffer buf_temp-session for temp-session .

  do
  on error undo, return error return-value
  :
    find first buf_temp-session
      where buf_temp-session.session-id = p-session-id
      no-error .
    if not available buf_temp-session
    then do:
      assign
        p-session-valid = false
        p-message       = substitute("Неизвестный идентификатор сессии &1", p-session-id)
      .
      return .
    end.

    if buf_temp-session.session-remote-device <> p-remote-device
    then do:
      assign
        p-session-valid = false
        p-message       = "Не совпадает адрес удаленного компьютера с адресом сессии. "
                        + substitute("Адрес удаленного компьютера &1", p-remote-device)
      .
      return .
    end.

    define variable v-cur-time-mjd as decimal   no-undo .

    assign
      v-cur-time-mjd = sys-time_get-mjd-func()
    .

    if v-cur-time-mjd > buf_temp-session.session-last-request-time + 0.03
    then do:
      assign
        p-session-valid = false
        p-message       = "Превышено предельное время неактивного состояния сессии. "
                        + "Сессия автоматически завершена"
      .
      run delete-session in this-procedure
        (input p-session-id
        ) .

      return .
    end.

    assign
      buf_temp-session.session-last-request-time = v-cur-time-mjd
    .
    assign
      p-session-valid = true
    .
  end.

end procedure. /* validate-session */


procedure delete-session :

  define input  parameter p-session-id    as character no-undo .

  define buffer buf_temp-session for temp-session .

  do
  on error undo, return error return-value
  :
    find first buf_temp-session
      where buf_temp-session.session-id = p-session-id
      no-error .
    if available buf_temp-session
    then do:
      assign
        v-current-user-num = v-current-user-num - 1
      .
      delete buf_temp-session .
    end.
  end.

end procedure. /* delete-session */