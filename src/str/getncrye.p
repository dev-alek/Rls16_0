block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getncrye.p $
$Archive: str/getncrye.p $

Получение архива чеков с кассы NCR за предыдущий операционный день

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
/*
p-parameter включает
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
 которые далее определены как переменные с префиксом p-

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getncrye.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/getncrye.p $":U .
define variable vss-description as character no-undo init "Получение архива чеков с кассы NCR за предыдущий операционный день".
{ cmp/vssrevis.i }


{ str/get-chk.i  NEW}
{ str/get-chkf.i }
{ bge/bgelib.i }
{ str/cd-xml.i  }
define variable log-file-name as character no-undo init 'get-chkf.log'.
{ str/waitp.i }

/*образыв бывших input parameter*/
define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .

define variable v-view-log as logical no-undo .
define variable v-mes as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .

define buffer get-chk-lock_batchprocess for ub.batchprocess .


&scop view-log     ~{ str/cdviewlg.i   ~
                    "substitute('!!!При приеме информации с касс &1&2 произошли ошибки!!!'  ~
                                 ,p-obj-type                                                ~
                                 ,p-obj-code)"                                               ~
                    "'get-chkf.log'" ~}   ~
                    return

assign
p-obj-type = entry(1, p-parameter, {&delim-par})
p-obj-code = integer(entry(2, p-parameter, {&delim-par}))
no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.

{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }

{ str/lockgchk.i }


_cash-desk:
FOR EACH ub.cash-desk NO-LOCK WHERE
         ub.cash-desk.obj-code = p-obj-code AND
         ub.cash-desk.cash-on
BREAK
by ub.cash-desk.pos-type
with frame a :
  IF FIRST-OF(ub.cash-desk.pos-type) then do:
    CASE ub.cash-desk.pos-type:
      when {&cd-type-ncr-gm}
      or when {&cd-type-ncr-AS-R}
      then  do:
        run str/get-inis.p (
                         input p-obj-type
                       , input p-obj-code
                       , input cash-desk.pos-type
                       , input cash-desk.remote
                       , input "get":U /*некий параметр который говорит для чего нам настройки*/
                       , output out
                       , output out2
                       , output in_
                       , output spl
                       , output sav
                       , output yestr
                       )  no-error .
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute(
                                "!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                                , cash-desk.pos-type
                                , p-obj-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                )).
            assign
            v-view-log = yes.
            {&view-log}.
        end.
        /*пошлем запрос на сервер*/
        if search( out + 'yestr.dat' ) = ? then  do:
          output to value( out + 'yestr.da0' ) convert target "ibm866".
          output close.
        end.
        else do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute(
                                "!!!Не могу отправить запрос на сервер NCR маг&1" +
                                "Возможно, в каталоге &2&3" +
                                "остался файл yestr.dat&3" +
                                "предыдущего недошедшего до кассы запроса - УДАЛЯЕТСЯ..."
                                , p-obj-code
                                , out
                                , {&new-line}
                                )).
          assign
          v-view-log = yes.
          OS-DELETE value( out + 'yestr.da0' ) .
          OS-DELETE value( out + 'yestr.dat' ) .
          output to value( out + 'yestr.da0' ) convert target "ibm866".
          output close.
        end.
        OS-RENAME VALUE(out + 'yestr.da0') VALUE(out + 'yestr.dat').
        os-er = OS-ERROR.
        if os-er <> 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute(
                                "!!!Ошибки при записи файлов запроса на кассу &1 маг&2 по адресу &3&4" +
                                "Ошибки в работе локальной сети или нарушение прав доступа!"
                                , cash-desk.cash-num
                                , p-obj-code
                                , (out + 'spl.dat')
                                , {&new-line}
                                )).
          assign
          v-view-log = yes.
          {&view-log}.
        end.

        RUN waitp in this-procedure (
             input no
            ,input (out + 'yestr.dat')
            ,input 'Чтение архива чеков с сервера NCR'
            ,input ' Подождите 15 сек '
            ,input 'Сервер не ответил.'
            ,input 'Сервер не ответил. Если Вы уверены, что с сервером нет связи нажмите кнопку!'
            ,input 15) NO-ERROR .
        if error-status:error then do:
          next _cash-desk.
        end.
        run waitp in this-procedure (
                     input no
                    ,input "":U
                    ,input "Прием архива чеков с кассы"
                    ,input "Подождите 20 сек"
                    ,input "Подождите 20 сек"
                    ,input "Подождите 20 сек"
                    ,input 20) no-error .
        if error-status:error then  NEXT _CASH-DESK.
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "Проверьте наличие архива чеков - файл &1 "
                                , (yestr + "hocidc.001":U)
                              )
                                          ).

      END. /*when*/
    END CASE .
  END. /*First-of cash-desk.pos-type*/
END. /*for each*/