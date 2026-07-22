block-level on error undo, throw.
/*

$Revision: 10060ac8659a, 2974, rls $
$Author: SSlivenko $
$Date: Ср апр 06 16:23:42 2022 +0300 $
$Workfile: oxmlinx.p $
$Archive: bge/oxmlinx.p $

Импорт из файла OpenXML


Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/19/08
Author: Bakhtadze Natalya
Creation date: 01/19/08

Input:
    parparentproc     - handle главного окна
    p-parent-handle       - handle вызывающей процедуры
    p-log-handle          - handle для записи лога (в handl-е должна быть поцедура write-log)
    p-parameter-string    - Строка параметров, через запятую. Первый параметр должен быть номером БД.

Output:

*/
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-parent-handle      as widget-handle    no-undo.
define input parameter p-log-handle         as handle           no-undo.
define input parameter p-parameter-string   as character        no-undo.


define variable vss-revision    as character no-undo init "$Revision: 10060ac8659a, 2974, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Ср апр 06 16:23:42 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: oxmlinx.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/oxmlinx.p $":U .
define variable vss-description as character no-undo init "Импорт из файла OpenXML".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ gbl/xmlchar.i  }
{ str/xmllib.i   } /* + подключает gbl/cur-time.i */
{ cmp/ini-lib.i  }
{ rul/xmlischn.i "new shared" }
{ bge/oxml-def.i }
{ gbl/orapreps.i }
{ rul/ora-rcpt.i proc }
{ gbl/filelist.i }
{ gbl/db-attr.i  }
{ bge/esysattr.i } // ext-system-attr-value для проверки сертификатов


function checkCertSubject returns logical private (input p-cert-subject as character,
                                                   input p-1cou-subject as character) :
// p-cert-subject приходит как "CN=ERP, OU=00000", p-1cou-subject содержит только сам код - "00000"
// lookup не ищет без пробела "OU=00000" в "CN=ERP, OU=00000" 
return index(
               p-cert-subject,
               substitute("OU=&1", p-1cou-subject)
            ) > 0 .
end function .


define variable v-num-params        as integer      no-undo.
define variable v-cur-db-num        as integer      no-undo.
define variable v-cr-db-num         as integer      no-undo.
define variable v-pack-num          as integer      no-undo.
define variable v-esys-id           as integer      no-undo.
define variable v-esys-db-num       as integer      no-undo init 0. /* Сейчас внешние системы заводятся только в ГБД. Однако уникальный индекс  */
define variable v-action            as character    no-undo.
define variable v-xml-file-name     as character    no-undo.
define variable v-log-file-name     as character    no-undo.
define variable v-list-file-name    as character    no-undo.
define variable v-source-dir        as character no-undo .
define variable v-target-dir        as character no-undo .
define variable v-temp-dir          as character no-undo .
define variable v-file-hash         as character no-undo .
define variable v-today             as date         no-undo.
define variable v-time              as integer      no-undo.
define variable v-parameter-list    as character    no-undo.
define variable v-file-name         as character    no-undo.
DEFINE VARIABLE v-full-path         as character    no-undo.
DEFINE VARIABLE v-file-name-no-ext  as character    no-undo.
DEFINE VARIABLE v-file-name-ext     as character    no-undo.
define variable v-path              as character    no-undo.
define variable v-success           as logical      no-undo.
define variable v-espr-pack-num     as integer      no-undo.
define variable v-espr-pack-name    as character    no-undo.
define variable v-rcvd-pack         as logical      no-undo.
define variable v-custom-pack-name  as character no-undo .
define variable v-custom-pack-flag  as logical   no-undo .
define variable v-msg-templ-start   as character no-undo .
define variable v-msg-templ-finish  as character no-undo .
define variable v-return-message    as character no-undo .
define variable v-take-count        as integer no-undo .
define variable v-analys-count      as integer no-undo .
define variable v-analys-ack        as integer no-undo .
define variable v-err-msg as character no-undo .
define variable v-ver-num as character no-undo .
define variable add-log-file-name0 as character no-undo .
define variable m-add-log-file-name as character no-undo .
define variable v-err-type as character no-undo .
define variable v-cmd-proc-handle as handle no-undo .
define variable v-cmd-code as integer no-undo .
define variable v-exch-file-date as character no-undo .
define variable v-return-error as integer no-undo .
define variable v-extsys-list as character no-undo .
define variable v-ack-snum_pack as character no-undo .
define variable v-1c-stat as integer no-undo .
define variable v-ack-err as character no-undo .
define variable v-sender-id as character no-undo .
define variable v-type as character no-undo .
define variable v-cert-enabled as logical no-undo . // true - проверить цифровую подпись
define variable v-cert-enstr   as character no-undo . // чтение v-cert-enabled строкой
define variable v-pack-data    as memptr no-undo .
define variable v-sign-data    as memptr no-undo .
define variable v-pkcs         as class ibs.th.gbl.pkcs no-undo .
define variable v-sign-file    as character no-undo . // имя файла с электронной подписью
define variable v-sign-fileext as character no-undo . // расширение файла с электронной подписью
define variable v-cert-issuer-name as character no-undo .
define variable v-cert-subj-name   as character no-undo .
define variable v-cert-repository  as integer no-undo .
define variable v-position     as integer no-undo . // позиция точки в имени файла
define variable v-attr-type    as character no-undo . // для чтения значений из ext-system-attr
define variable v-cert-subject as character no-undo . // владелец сертификата из входящего пакета
define variable v-1c-subj      as character initial "00000" no-undo . // так мы решили называть 1с
def var i as int.


define buffer buf_ext-system         for ub.ext-system.
define buffer buf_esys-pck-keys      for ub.esys-pck-keys.
define buffer next_filelist          for temp-filelist .
define temp-table tt-espcknum no-undo
  field tt-espr-pack-num  as integer
  field tt-espr-pack-name as character
  field tt-espr-pack-date as datetime /*доп. поле для SAP ERP*/
  index inum tt-espr-pack-num ascending
  index idate tt-espr-pack-date     ascending
.

do
for buf_ext-system
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

  run write-log in p-log-handle ( 1, "Загрузка данных из внешних систем..." ).
  do : // чтение параметров
    v-num-params = num-entries(p-parameter-string) .
    assign
      v-action      =          entry( 1, p-parameter-string )
      v-cur-db-num  = integer( entry( 2, p-parameter-string ) )
    .
    if v-num-params > 2 then do:
      assign
      v-extsys-list =          entry( 3, p-parameter-string )
      v-esys-db-num = integer( entry( 4, p-parameter-string ) ) /* для УБД всегда 0? */
      .
      if v-extsys-list = '' then v-extsys-list = '0'.
    end.
    if v-num-params > 4 then do:
      assign
      v-pack-num  = integer( entry( 4, p-parameter-string ) )
      v-cr-db-num = integer( entry( 5, p-parameter-string ) )
      .
    end.
    else v-pack-num = -1.
    run get-version-num in parparentproc ( output v-ver-num ).
  end . // end_of чтение параметров

  case v-action:
    /* @FUTU образец:
         Завершён приём и разбор пакетов данных. Принято пакетов 0, разобрано пакетов 0.
         В идеале ещё и:
         Разобрано из ранее принятых пакетов 0.
    */ 
    when "take":U then do:
      v-msg-templ-start  = "Прием пакетов данных из ВС &1 '&2'" .
      v-msg-templ-finish = "Завершен прием пакетов данных из ВС '&1'" .
    end.
    when "analys":U then do:
      v-msg-templ-start  = "Разбор данных из ВС &1 '&2'" .
      v-msg-templ-finish = "Завершен разбор данных из ВС '&1'" .
    end.
    when "take+analys":U then do:
      v-msg-templ-start  = "Прием и разбор пакетов данных из ВС &1 '&2'" .
      v-msg-templ-finish = "Завершен прием и разбор пакетов данных из ВС '&1'" .
    end.
    otherwise do:
      v-return-message = substitute( "Не предусмотрена операция &1", v-action ) .
      return error v-return-message.
    end.
  end case.

  /* код точки интеграции читаем заранее, до цикла;
     наличие точки интеграции проверяется внутри цикла только для метода доставки &esys-dm-erp-1C-RN */
  run db-attr-value in this-procedure
               (input  ibs.th.gbl.gbl-var:g#db-num
               ,input {&attr-int-point}
               ,output v-sender-id
               ,output v-type
  ) no-error .


    run xmlischn_fill in this-procedure ( input 4, input 2).
    run xmlischn_fill in this-procedure ( input 4, input 3).
    run xmlischn_fill in this-procedure ( input 11, input 4).
    run xmlischn_fill in this-procedure ( input 12, input 5).
    run xmlischn_fill in this-procedure ( input 13, input 4).
    run xmlischn_fill in this-procedure ( input 18, input 4).
    run xmlischn_fill in this-procedure ( input 18, input 8).
    run xmlischn_fill in this-procedure ( input 18, input 12).
    run xmlischn_fill in this-procedure ( input 18, input 16).
    run xmlischn_fill in this-procedure ( input 18, input 20).
    run xmlischn_fill in this-procedure ( input 18, input 24).
    run xmlischn_fill in this-procedure ( input 20, input 4).

    _ext-system:
    do i = 1 to num-entries(v-extsys-list)
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      v-esys-id = int(entry(i,v-extsys-list,';')).
      /* по всем внешним системам,
             где esys-have-import + esys-db-num-imp + esys-id
         Внутри цикла целевые действия выполняются только для buf_ext-system.esys-have-import = true
      */
      for each buf_ext-system no-lock
        where buf_ext-system.esys-have-import = yes
          and buf_ext-system.esys-db-num-imp = v-cur-db-num
          and (v-esys-id = 0
                or
                (buf_ext-system.esys-id = v-esys-id
                and
                buf_ext-system.db-num = v-esys-db-num)
              )
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      :
        assign
        add-log-file-name  = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.LOG", buf_ext-system.esys-id )
        g#esys-source-esys = buf_ext-system.esys-id
        m-add-log-file-name = add-log-file-name
        .
        
          if buf_ext-system.delivery-method = integer({&esys-dm-erp-1C-RN})
          then do :
              if (v-sender-id = ? or trim(v-sender-id) = "")
              then do :
                  run write-log in p-log-handle (
                        input 2
                      , input 'Нет атрибута БД "Номер точки интеграции". Без него работа с системой 1С-ERP не возможна!'
                  ).
                  undo _ext-system, next _ext-system.
              end.
          end.
          
        do:  /* 29/VIII-2018  параметры настройки ЭЦП добавлены в настройки внешней системы */
          run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  {&attr-esys-cert-sign}
                                     ,output v-cert-enstr
                                     ,output v-attr-type) no-error .
          if not error-status:error then v-cert-enabled = logical (v-cert-enstr) no-error .
          if error-status:error then do :
            run write-log in p-log-handle (
                                                  input 2
                                                , substitute("&1 Ошибка при чтении параметров ВС.&2&3&2&4&2&5"
                                                              ,vss-workfile
                                                              ,{&new-line}
                                                            ,substitute( "Параметр &1", {&attr-esys-cert-sign} ) 
                                                            ,substitute( "&1", error-status:get-message(error-status:num-messages) )
                                                            ,substitute( "&1", return-value )
                                                            )
                                  ) .
            undo _ext-system, next _ext-system.
          end .
          if v-cert-enabled then do :
            run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  {&attr-esys-cert-file-ext}
                                     ,output v-sign-fileext
                                     ,output v-attr-type) no-error .
            if not error-status:error then
            run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  {&attr-esys-cert-sign-issuer}
                                     ,output v-cert-issuer-name
                                     ,output v-attr-type) no-error .
            if not error-status:error then
            run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  {&attr-esys-cert-sign-subject}
                                     ,output v-cert-subj-name
                                     ,output v-attr-type) no-error .
                                     
            if error-status:error then do:
              run write-log in p-log-handle (
                                                  input 2
                                      , substitute("&1 Ошибка чтения настроек ВС.&2&3&2&4"
                                                  ,vss-workfile
                                                  ,{&new-line}
                                                  ,error-status:get-message(error-status:num-messages)
                                                  ,return-value
                                                  )
                                  ) .
              undo _ext-system, next _ext-system.
            end.
            v-cert-repository = ? .
            run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  {&attr-esys-cert-repository}
                                     ,output v-cert-enstr
                                     ,output v-attr-type) no-error .
            if v-cert-enstr > ""
            then
              v-cert-repository = integer(v-cert-enstr) no-error .    
            if v-cert-repository = ?
            then
              v-cert-repository = 0 .                  
            if v-cert-subj-name > "" then . else do :
              run write-log in p-log-handle (
                                        input 2
                                      , substitute("&1 Ошибка чтения настроек ВС.&2&3"
                                                  ,vss-workfile
                                                  ,{&new-line}
                                                  ,"Отсутствует имя Владельца сертификата (~"Субъект~") в параметрах настройки внешней системы"
                                                  )
                        ) .
              undo _ext-system, next _ext-system.
            end .
            if v-cert-issuer-name > "" then . else do :
              run write-log in p-log-handle (
                                        input 2
                                      , substitute("&1 Ошибка чтения настроек ВС.&2&3"
                                                  ,vss-workfile
                                                  ,{&new-line}
                                                  ,"Отсутствует имя Издателя сертификата в параметрах настройки внешней системы"
                                                  )
                        ) .
              undo _ext-system, next _ext-system.
            end .
            if not valid-object (v-pkcs) then v-pkcs = new ibs.th.gbl.pkcs().
          end .
          else assign
            v-cert-issuer-name = ""
            v-cert-subj-name   = ""
            v-sign-fileext     = ""
          .
        end . // end_of параметры настройки ЭЦП
          
          run bge/lockesys.p (
             input buf_ext-system.esys-id
            ,input buf_ext-system.db-num
            ,buffer buf_ext-system
            ,output v-success) no-error.
          if error-status:error or v-success = no 
          then do:
              run write-log in p-log-handle (
                    input 2
                  , input return-value
              ).
              undo _ext-system, next _ext-system.
          end.

        run write-log in p-log-handle (  input 2
               ,substitute(v-msg-templ-start, buf_ext-system.esys-id, buf_ext-system.esys-name ) ) .
        run write-log in p-log-handle (  input 2
                 ,( if v-cert-enabled then substitute("Используются файлы электронной подписи с расширением '.&1'", v-sign-fileext)
                                      else "Файлы электронной подписи не используются." )            
                                          ) .
          do:
                                          
            /*начинаем сканирование директории*/
            assign
              v-espr-pack-num = -1
              v-custom-pack-name = ''
            .
            // внутри espcknum.p очищается temp-filelist и вызывается его заполнение через run filelist-init
            run bge/espcknum.p ( input "get":U
                          ,input buf_ext-system.esys-id
                          ,input buf_ext-system.db-num
                          ,input buf_ext-system.delivery-method
                          ,input oxml-exch-dir
                          ,input oxml-heap-dir
                          ,input v-sign-fileext
                          ,input-output v-espr-pack-num    // передаётся в sxg-pack.p
                          ,input-output v-custom-pack-name // снаружи не используется; перед анализом обнуляется
                          ,output v-espr-pack-name // до анализа не используется; в анализе читается повторно
                          ,output v-source-dir // передаётся в sxg-pack.p
                          ,output v-target-dir // передаётся в sxg-pack.p
                          ,output v-temp-dir   // передаётся в sxg-pack.p
                          ,output v-log-file-name // до анализа не используется; в анализе - только для oracle-retail
                          ,output v-list-file-name // не используется
                          ,output v-custom-pack-flag // до анализа не используется; в анализе читается повторно
                        ) no-error.
            if error-status:error then do:
              run write-log in p-log-handle (
                                              input 2
                                            , substitute("&1 Ошибка при генерации номера пакета.&2&3&2&4"
                                                          ,vss-workfile
                                                          ,{&new-line}
                                                        , error-status:get-message(error-status:num-messages)
                                                        , return-value
                                                        )
                              ) .
              undo _ext-system, next _ext-system.
            end.

            assign
              v-take-count   = 0
              v-analys-count = 0
              v-analys-ack   = 0
              v-rcvd-pack = false
            .
            if lookup( v-action, "take,take+analys":U ) <> 0 then do:
              run write-log in p-log-handle (input 2 ,  substitute ("Копирование пакетов данных из &1 в &2", v-source-dir, v-target-dir)  ) .

              /* копируем скопом все файлы из exch в heap
                 17/X-2018 - для 1с копирует только файлы с номерами пакетов больше текущего;
                             пакеты с принятыми номерами повторно не копирует  
              */
              /*очищаем таблицу - чтобы туда потом написать названия файлов - они могут понадобиться в методе EXITE*/
                v-filelist-total-file-num = 0 .
                empty temp-table temp-filelist .
              /* 17/X-2018 внутри sxg-pack.p для get таблица temp-filelist очищается повторно,
                           но переменная v-filelist-total-file-num при этом не сбрасывается
                 Используется v-source-dir для взятия архивов arj и zip, либо остальных файлов
                 и v-target-dir для распаковки или копирования туда
              */
              run bge/sxg-pack.p (
                            input parparentproc
                            ,input this-procedure:handle /*p-parent-handle*/ /*место определения write-to-lo и write-to-screen*/
                            ,input p-log-handle /*место определения write-log-and-file*/
                            ,input "get":U
                            ,input true
                            ,input ?
                            ,input v-source-dir // получено из espcknum.p
                            ,input v-target-dir // получено из espcknum.p
                            ,input v-temp-dir   // получено из espcknum.p
                            ,input v-espr-pack-num /*p-esps-pack-num <> 0 потому что если надо переименовыват файлы с кривыми именами*/
                            ,input buf_ext-system.esys-id
                            ,input buf_ext-system.db-num
                            ,input v-cr-db-num
                            ,input buf_ext-system.delivery-method
                            ) no-error.
              if error-status:error then do:
                run write-log in p-log-handle ( input 2
                                                ,input substitute("&1 &2"
                                                          ,vss-workfile
                                                          ,return-value )
                                              ).
                undo _ext-system, next _ext-system.
              end.
            end.

            /* получение всех файлов, находящихся в heap, 
            для внешней системы типа OR APM (SPAR) - разибарются все файлы находящиеся в heap
            в дальнейшем после удачного разбора в обязательном порядке удаляются*/
            if buf_ext-system.delivery-method = integer({&esys-dm-contour-edi})
            or buf_ext-system.delivery-method = integer({&esys-dm-erp-1C-RN})
            then do:
              /* 16/X-2018 из всей директории в tt-espcknum лягут только файлы пакетов
                           с номерами выше v-espr-pack-num
                           Пакеты с уже существующими номерами могут оставаться в директории heap,
                           но в tt-espcknum для обработки они не попадают.
              */
              run get-num-namepack in this-procedure
                ( input v-target-dir
                , input buf_Ext-system.esys-id
                , input buf_Ext-system.db-num
                , input buf_ext-system.delivery-method
                ) 
              no-error.
              if error-status:error then do:
                  run write-log in p-log-handle (
                                                  input 2
                                                , substitute("&1 Ошибка при создание списка пакетов для приема. &2&3&2&4"
                                                              ,vss-workfile
                                                              ,{&new-line}
                                                            ,substitute( "&1", error-status:get-message(error-status:num-messages) )
                                                            ,substitute( "&1", return-value )
                                                            )
                                  ) .
                undo _ext-system, next _ext-system.
              end.
            end.

            if lookup( v-action, "analys,take+analys":U ) <> 0 then do:
              run write-log in p-log-handle (input 2 ,  substitute ("Разбор пакетов данных из &1", v-target-dir)  ) .
              rcvd-pack:
              do while TRUE
              on error undo, return error
              :
              v-custom-pack-name = ''.
              v-espr-pack-num = - abs(v-espr-pack-num).
              if buf_ext-system.delivery-method = integer({&esys-dm-exite-edi}) then do:
                find first temp-filelist no-error.
                if not available temp-filelist then do:
                  leave rcvd-pack.
                end.
                assign
                v-custom-pack-name = temp-filelist.file-name.
                delete temp-filelist.
              end.
              if buf_ext-system.delivery-method = integer({&esys-dm-contour-edi}) then do:
                find first tt-espcknum use-index inum no-error.
                if not available tt-espcknum then do:
                  leave rcvd-pack.
                end.
                assign
                v-custom-pack-name = tt-espcknum.tt-espr-pack-name.
                delete tt-espcknum.
              end.
              if buf_ext-system.delivery-method = integer({&esys-dm-erp-1C-RN})
              then do:
                /* при нормальной работе системы записей buf_esys-pck-keys не должно быть
                find last buf_esys-pck-keys no-lock use-index pi no-error.
                if available buf_esys-pck-keys then do:
                  find first tt-espcknum where tt-espcknum.tt-espr-pack-num > buf_esys-pck-keys.espr-pack-num use-index inum no-error.
                  if available tt-espcknum then do:
                    v-espr-pack-num = tt-espcknum.tt-espr-pack-num.
                  end.
                end.
                 */
                /* оставляем только файлы, подлежащие обработке
                23/VII-2019 чистка файлов выполнена внутри get-num-namepack()
                for each temp-filelist :
                  if  num-entries(temp-filelist.file-name, "_") = 4
                  or (num-entries(temp-filelist.file-name, "_") = 5 and temp-filelist.file-name begins "ack")
                  then . /* пакеты и аски оставляем */
                  else do :
                    delete temp-filelist.
                  end.
                end.
                */
                
                /* 21/XII-2018  Перестали приниматься ack_ с подтверждениями на отправленные нами пакеты.
                                Сначала обрабатываем все ack_ с подтверждениями на отправленные нами пакеты,
                                потом переходим к приёму новых пакетов. 
                */
                for each temp-filelist where temp-filelist.file-name begins "ack_" :
                        assign
                           v-custom-pack-name = temp-filelist.file-name
                           v-analys-ack = v-analys-ack + 1
                         .
                  run gbl/filename.p (
/* 21/XII-2018 почему-то не может найти файл по короткому имени input temp-filelist.file-name */
                                      input temp-filelist.full-name
                                      ,output v-full-path
                                      ,output v-path
                                      ,output v-file-name
                                      ,output v-file-name-no-ext
                                      ,output v-file-name-ext
                                      ) no-error .
                  if error-status :error then do:
                    run write-log in p-log-handle (
                                                  input 2
                      , ("Ошибка приёма подтверждения из файла " + temp-filelist.full-name + " : " + return-value)
                                                ) .
                    delete temp-filelist .
                    next .
                  end.

                  v-ack-snum_pack = entry(4, v-file-name, "_") .
                  run write-log in p-log-handle (input 2 ,
                    substitute ("Прием подтверждения на пакет номер &1 (файл &2)"
                              , v-ack-snum_pack 
                              , v-full-path
                               )
                                                ) .
                  run gbl/md5.p(v-full-path, output v-file-hash).
                  run write-to-log( substitute("Файл: &1; Контрольная сумма: &2.", v-full-path,  v-file-hash) ) .

                  // 26/IX-2018 - загрузить данные в mem-ptr и отдать их на вход в x-document вместо файла
                  set-size(v-pack-data) = 0 .
                  COPY-LOB FROM FILE v-full-path TO OBJECT v-pack-data NO-CONVERT NO-ERROR .
                  // 26/IX-2018 Да, аски тоже надо подписывать.
                  // Далее скопирована проверка подписи пакета данных                   
                  /* если включена проверка электронной подписи - то загрузить файл подписи и проверить подпись */
                  if v-cert-enabled then do on error undo, throw :
                    v-position = r-index(v-full-path, ".") .
                    v-sign-file = if v-position > 0 then substring(v-full-path, 1, v-position - 1) else v-full-path .
                    v-sign-file = substitute("&1.&2", v-sign-file, v-sign-fileext) .
                    file-info:file-name = v-sign-file .
                    if file-info:file-type = ? then
                      v-err-msg = substitute("Отсутствует файл электронной подписи &1", v-sign-file) .
                    else do :
                      v-err-msg = "" .  
                      COPY-LOB FROM FILE v-sign-file TO OBJECT v-sign-data NO-CONVERT .
                      /* проверка соответствия сертификата отправителю выполняется по sender-id;
                         для 1с sender-id жестко равен "00000" */
                      v-pkcs:putSign(v-sign-data) .
                      v-cert-subject = v-pkcs:getCertSubject() .
                      if checkCertSubject (v-cert-subject, v-1c-subj) then do :
                        v-pkcs:verifySign(v-pack-data) .
                      end .
                      else do :
                        v-err-msg = substitute("Идентификатор отправителя [&1] отличается от идентификатора подписавшей стороны [&2]"
                                             , v-1c-subj, v-cert-subject) .
                      end .
                      /* при возникновении ошибок проверьте, что в директории heap
                         присутствует только один комплект файлов с заданным v-espr-pack-num;
                         иначе ошибки могут возникать не на тестируемом пакете */
                    end .
                    catch exAppErrors as class Progress.Lang.AppError :
                      v-err-msg = exAppErrors:ReturnValue .
                      if v-err-msg > "" then . else do :
                        v-err-msg = exAppErrors:GetMessage(1) . 
                        if v-err-msg > "" then . else v-err-msg = "AppError в модуле {&FILE-NAME}" .
                      end .
                    end catch .
                    catch exProErrors as class Progress.Lang.ProError :
                      v-err-msg = exProErrors:GetMessage(1) . 
                      if v-err-msg > "" then . else v-err-msg = "ProError в модуле {&FILE-NAME}" .
                    end catch .
                    catch exAnyErrors as class Progress.Lang.Error:
                      v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
                    end catch .
                    finally: 
                      set-size(v-sign-data) = 0 .
                      if v-err-msg > "" then do :
                        set-size(v-pack-data) = 0 .
                        run write-log in p-log-handle ( input 2, input v-err-msg ).
                        // ack_ на ack_ не отправляем
                        undo _ext-system, next _ext-system.
                      end .
                    end finally.
                  end . // end_of if_cert
                  
                  run rul/rcv-ack_1c.p (input v-pack-data
                                       ,input buf_ext-system.esys-id
                                       ,output v-1c-stat
                                       ,output v-ack-err
                                        ) .
                                        
                  set-size(v-pack-data) = 0 .
                  case v-1c-stat : // Статус приема пакета:
                    when 0 then do : // успешно
                      os-delete value(v-full-path) .
                      run write-log in p-log-handle (input 2 ,
                        substitute ("Подтверждение на пакет номер &1 обработано. Статус: успешно. Файл &2 успешно удалён."
                              , v-ack-snum_pack 
                              , v-full-path
                               )
                                                ) .
                    end .
                    when 1 then do : // отсутствует пакет, следующий за последним принятым (для данной ошибки в поле error указывается номер отсутствующего пакета);
                      define variable v-one-pack-num as integer no-undo .
                      v-one-pack-num = integer (v-ack-err) no-error .
                      if v-one-pack-num > 0 then do :
                        run write-log in p-log-handle (input 2 ,
                        substitute ("Подтверждение на пакет номер &1 обработано. Статус: 1 - отсутствует пакет, следующий за последним принятым. Запрошена повторная отправка пакета [&2]."
                              , v-ack-snum_pack 
                              , v-ack-err
                               )
                                                ) .
                        run bge/oxmloutx.p ( input parparentproc
                                        ,input p-parent-handle
                                        ,input p-log-handle
                                        ,input substitute("one-pack,&1,&2,&3,&4,&5"
                                                    ,v-cur-db-num
                                                    ,buf_ext-system.esys-id
                                                    ,buf_ext-system.db-num
                                                    ,g#db-num
                                                    ,v-ack-err)
                                  ) no-error.
                        if error-status:error then do:
                          run write-log in p-log-handle (
                                                  input 2
                                                , ( vss-workfile + {&space-char}
                                        + substitute( "ERROR!!! Ошибка при отправке одного пакета данных в ВС &1", buf_ext-system.esys-id ) + {&new-line}
                                        + substitute( "&1", error-status:get-message(error-status:num-messages) ) + {&new-line}
                                        + substitute( "&1", return-value ) )
                                                ) .
                        end.
                        else os-delete value(v-full-path) .
                      end.
                      else do :
                        run write-log in p-log-handle (input 2 ,
                        substitute ("Ошибка обработки подтверждения на пакет номер &1. Статус: 1 - отсутствует пакет, следующий за последним принятым. Номер отсутствующего пакета [&2] не является числом."
                              , v-ack-snum_pack 
                              , v-ack-err
                               )
                                                ) .
                      end .                      
                    end .
                    when 4 then do : // прочие ошибки (приходит после возникновения различных run-time ошибок в 1с)
                      /* 30/VII-2019  Удалить файл и один раз отобразить сообщение в логе.
                                      Повторная информация об ошибках в тексте программы 1с не требуется. */
                      os-delete value(v-full-path) .
                      run write-log in p-log-handle (input 2 ,
                        substitute ("Подтверждение на пакет номер &1 обработано. Статус: 4 - прочие ошибки. Текст ошибки: &2. Файл &3 успешно удалён."
                              , v-ack-snum_pack
                              , v-ack-err
                              , v-full-path
                                    )
                                                ) .
                    end . 
                    otherwise do :
                      /* коды ошибок, отличные от 1, игнорируем:
                         2 – несоответствие файла данных и ЭП;
                         3 – ошибка формата файла данных; 
                      */
                      os-delete value(v-full-path) .
                      run write-log in p-log-handle (input 2 ,
                        substitute ("Подтверждение на пакет номер &1 обработано. Статус: &2. Текст ошибки: &3. Файл &4 успешно удалён."
                              , v-ack-snum_pack
                              , v-1c-stat 
                              , v-ack-err
                              , v-full-path
                               )
                                                ) .
                    end .
                  end case .
                                        
                  delete temp-filelist .
                end. /* end_of for_each temp-filelist_begins_ack */
                run write-log in p-log-handle (input 2 ,  substitute ("Разбор подтверждений из &1. Просмотрено файлов &2", v-target-dir, v-analys-ack)  ) .
                
              do : // выбор имени файла для импорта

                  /* 11/VII-2019 обработка ack_ закончена.
                                 При отсутствии замечаний условия, связанные с асками, ниже по тексту будут исключаться. */
                  if not can-find (first temp-filelist
                                   where num-entries(temp-filelist.file-name, "_") = 4
                                     and integer(entry(3, temp-filelist.file-name, "_")) = abs(v-espr-pack-num)) then do :
                    /* отсутствует пакет с ожидаемым номером v-espr-pack-num */
                    find first temp-filelist
                         where num-entries(temp-filelist.file-name, "_") = 4
                           and integer(entry(3, temp-filelist.file-name, "_")) > abs(v-espr-pack-num) no-error .
                    if available temp-filelist then do :     
                      /* есть пакет с номером после v-espr-pack-num */                                     
                      run write-log in p-log-handle ( input 2
                                  , ("Ожидается прием пакета с номером " + string(abs(v-espr-pack-num)) +
                             ", а в каталоге следующий пакет с номером " + entry(3, temp-filelist.file-name, "_"))
                                                            ) .
                      run rul/send-ack_1c.p ( input v-sender-id
                                          , input (abs(v-espr-pack-num))
                                          ,input 1
                                          ,input string(abs(v-espr-pack-num)) /* в поле описания ошибки <error> кладём номер пропущенного пакета */
                                          ,input buf_ext-system.esys-id
                                          ,input v-cert-subj-name
                                          ,input v-cert-issuer-name
                                          ,input v-sign-fileext
                                          ,input v-cert-repository
                                          ,input v-pkcs
                                          ) no-error .
                      if error-status:error then do :                                                               
                          run write-log in p-log-handle ( input 2
                                                , ( vss-workfile + {&space-char}
                                        + substitute( "Ошибка при отправке ack_ в ВС &1", buf_ext-system.esys-id) + {&new-line}
                                        + substitute( "&1", error-status:get-message(error-status:num-messages) ) + {&new-line}
                                        + substitute( "&1", return-value ) )
                                                ) .
                      end .
                    end .
                    else do :
                      /* нет пакетов с номером после v-espr-pack-num */                                     
                      run write-log in p-log-handle ( input 2
                                                ,substitute(" для ВС '&1' отсутствуют пакеты, подлежащие разбору", buf_ext-system.esys-name ) ) .
                      leave rcvd-pack.
                    end .
                  end . /* end_of отсутствует пакет с ожидаемым номером v-espr-pack-num */                   
              
                for each temp-filelist no-lock :
                    /* 21/XII-2018 вся обработка ack_ вынесена до обработки пакетов.
                                   Здесь условия по ack_ срабатывать больше не должны. */
                    if integer(entry(3, temp-filelist.file-name, "_")) = abs(v-espr-pack-num)
                    or temp-filelist.file-name begins "ack_"
                    or temp-filelist.file-name begins "err_"
                    then do :
                        assign v-custom-pack-name = temp-filelist.file-name.
                        if temp-filelist.file-name begins "ack_"
                        then
                        delete temp-filelist .
                        leave.
                    end.
                    delete temp-filelist.
                end.
              end . // end_of выбор имени файла для импорта
              end.
              run bge/espcknum.p ( input "get":U
                            ,input buf_ext-system.esys-id
                            ,input buf_ext-system.db-num
                            ,input buf_ext-system.delivery-method
                            ,input oxml-exch-dir
                            ,input oxml-heap-dir
                            ,input v-sign-fileext
                            ,input-output v-espr-pack-num
                            ,input-output v-custom-pack-name
                            ,output v-espr-pack-name
                            ,output v-source-dir
                            ,output v-target-dir
                            ,output v-temp-dir
                            ,output v-log-file-name
                            ,output v-list-file-name
                            ,output v-custom-pack-flag
                          ) no-error.
                if error-status:error then do:
                  run write-log in p-log-handle (
                                                  input 2
                                                , substitute("&1 Ошибка при генерации номера пакета.&2&3&2&4"
                                                              ,vss-workfile
                                                              ,{&new-line}
                                                            ,substitute( "&1", error-status:get-message(error-status:num-messages) )
                                                            ,substitute( "&1", return-value )
                                                            )
                                  ) .
                  undo _ext-system, next _ext-system.
                end.
                if v-espr-pack-name = '' then do:
                  next rcvd-pack.
                end.
                assign
                v-file-name = v-target-dir + {&back-slash-char} + v-espr-pack-name +
                            (if v-custom-pack-flag
                              then ''
                              else 'xml')
                .
                run write-log in p-log-handle (input 2 ,  substitute ("Разбор пакетов из &1. Обработка пакета &2", v-target-dir, v-file-name)  ) .
                
                run gbl/filename.p (
                                      input v-file-name
                                      ,output v-full-path
                                      ,output v-path
                                      ,output v-file-name
                                      ,output v-file-name-no-ext
                                      ,output v-file-name-ext
                                      ) no-error .
                if error-status :error then do:
                  /* исходный файл не найден, значит он еще не пришел */
                  leave rcvd-pack.
                end.
                if buf_ext-system.delivery-method = integer({&esys-dm-oracle-retail}) then do:
                  assign
                  add-log-file-name0 = add-log-file-name
                  add-log-file-name = add-log-file-name0 + {&delim-nws} + v-log-file-name + {&back-slash-char} + ora-rcpt_get-rcpt-name(v-file-name-no-ext) + ".LOG"
                  .
                  run gbl/dir-cre.p (
                                      input v-log-file-name
                                      ) no-error.
                  os-delete value(v-log-file-name + {&back-slash-char} + ora-rcpt_get-rcpt-name(v-file-name-no-ext) + ".LOG").
                end.
                v-err-type = ''.
                v-return-error = 0.
/*
                if v-file-name begins "ack_"
                and buf_ext-system.delivery-method = integer({&esys-dm-erp-1C-RN})
                then do :
 21/XII-2018  приём подтверждений перенесён выше, до импорта пакетов.
                Сначала принимаем подтверждения, потом проверяем номер пакета и,
                если есть пакет с ожидаемым номером - переходим к приёму пакета.
                end.
                else                                  
*/
                run gbl/md5.p(v-full-path, output v-file-hash).
                run write-to-log( substitute("Файл: &1; Контрольная сумма: &2.", v-full-path,  v-file-hash) ) .

                do :
                  /* 24/VIII-2018  файл с данными и файл с подписью могут придти в произвольном порядке;
                                   на то время, пока в bge/espcknum.p вставлен костыль, файлы с подписью
                                   из него приходить не будут вообще */

                  // 23/VIII-2018 - загрузить данные в mem-ptr и отдать их на вход в sax-reader вместо файла
                  set-size(v-pack-data) = 0 .
                  COPY-LOB FROM FILE v-full-path TO OBJECT v-pack-data NO-CONVERT NO-ERROR .
                  
                  /* если включена проверка электронной подписи - то загрузить файл подписи и проверить подпись */
                  if v-cert-enabled then do on error undo, throw :
                    v-position = r-index(v-full-path, ".") .
                    v-sign-file = if v-position > 0 then substring(v-full-path, 1, v-position - 1) else v-full-path .
                    v-sign-file = substitute("&1.&2", v-sign-file, v-sign-fileext) .
                    file-info:file-name = v-sign-file .
                    if file-info:file-type = ? then
                      v-err-msg = substitute("Отсутствует файл электронной подписи &1", v-sign-file) .
                    else do :
                      v-err-msg = "" .  
                      COPY-LOB FROM FILE v-sign-file TO OBJECT v-sign-data NO-CONVERT .
                      /* электронная подпись содержит в своём составе сертификат, которым она подписана;
                         проверка будет выполнена только если присланный сертификат выдан CA, который
                         присутствует в списке доверенных CA в локальном хранилище */
                      /* проверка соответствия сертификата отправителю выполняется по sender-id;
                         для 1с sender-id жестко равен "00000" */
                      v-pkcs:putSign(v-sign-data) .
                      v-cert-subject = v-pkcs:getCertSubject() .
                      if checkCertSubject (v-cert-subject, v-1c-subj) then do :
                        v-pkcs:verifySign(v-pack-data) .
                      end .
                      else do :
                        v-err-msg = substitute("Идентификатор отправителя [&1] отличается от идентификатора подписавшей стороны [&2]"
                                             , v-1c-subj, v-cert-subject) .
                      end .
                      /* при возникновении ошибок проверьте, что в директории heap
                         присутствует только один комплект файлов с заданным v-espr-pack-num;
                         иначе ошибки могут возникать не на тестируемом пакете */
                    end .
                    
                    // ошибки - в лог, и ... 
                    catch exAppErrors as class Progress.Lang.AppError :
                      v-err-msg = exAppErrors:ReturnValue .
                      if v-err-msg > "" then . else do :
                        v-err-msg = exAppErrors:GetMessage(1) . 
                        if v-err-msg > "" then . else v-err-msg = "AppError в модуле {&FILE-NAME}" .
                      end .
                    end catch .
                    catch exProErrors as class Progress.Lang.ProError :
                      v-err-msg = exProErrors:GetMessage(1) . 
                      if v-err-msg > "" then . else v-err-msg = "ProError в модуле {&FILE-NAME}" .
                    end catch .
                    catch exAnyErrors as class Progress.Lang.Error:
                      v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
                    end catch .
                    finally: 
                      set-size(v-sign-data) = 0 .
                      if v-err-msg > "" then do :
                        v-return-error = 1.
                        set-size(v-pack-data) = 0 .
                        /* 19/XI-2018 во всех асках писать номер пакета в тексте ошибки.
                           20/XI-2018 оказалось, что не номер пакета, а имя файла.
                        */
                        v-err-msg = substitute("Пакет &1. Файл &2. &3", v-espr-pack-num, v-full-path, v-err-msg) .
                        run write-log in p-log-handle ( input 2, input v-err-msg ).
                        // ... - и без сертификата блокируем дальнейшую работу
                        run rul/send-ack_1c.p
                        (input v-sender-id
                        ,input v-espr-pack-num // номер пакета
                        ,input 2               // status = 2 – несоответствие файла данных и ЭП;
                        ,input v-err-msg       // error - описание ошибки
                        ,input buf_ext-system.esys-id
                        ,input v-cert-subj-name
                        ,input v-cert-issuer-name
                        ,input v-sign-fileext
                        ,input v-cert-repository
                        ,input v-pkcs
                        ) no-error .
                        if error-status:error then do :
                          run write-log in p-log-handle (
                                                  input 2
                                                , ( vss-workfile + {&space-char}
                                        + substitute( "Ошибка отправки ack_ в ВС &1", buf_ext-system.esys-id) + {&new-line}
                                        + substitute( "&1", error-status:get-message(error-status:num-messages) ) + {&new-line}
                                        + substitute( "&1", return-value ) )
                                                ) .
                        end .
                        // undo _ext-system, next _ext-system.
                      end .
                    end finally.
                  end . // end_of if_cert
                  
                    
                  /* после проверки подписи отдать файл на чтение в cmdeigen.p,
                     где данные читаются уже mem-ptr через sax-reader.
                  @NOTE после того, как внутри bge/cmdeigen.p передали загруженный файл в xmllib.i,
                        и там полностью его распарсили - управление переходит в машину правил,
                        которая передаёт имя файла в parseSub, где файл снова читается с диска
                        и парсится, теперь уже по настоящему.
                  */
                  if v-return-error = 0 then do :
                    /* внутри bge/cmdeigen.p зачем-то выполнялась проверка активной транзакции */
                    if transaction then do:
                      message vss-workfile vss-revision vss-description skip
                        substitute("Вызов процедуры в действующей транзакции недопустим") skip
                      view-as alert-box error .
                      return error substitute( "&1. Вызов процедуры в действующей транзакции недопустим", vss-workfile ) .
                    end.
                    if add-log-file-name = ? and m-add-log-file-name > "" then
                       add-log-file-name = m-add-log-file-name.

                  run bge/cmdeigen.p (
                                        input parparentproc
                                        ,input this-procedure:handle
                                        ,input p-log-handle
                                        ,input buf_ext-system.esys-id
                                        ,input buf_ext-system.db-num
                                        ,input v-cur-db-num
                                        ,input v-full-path
                                        ,input v-file-name
                                        ,input v-pack-data
                                        ,input v-espr-pack-num
                                        ,input add-log-file-name
                                        ) no-error.
                  if error-status:error then v-return-error = 1.
                  end .
                  set-size(v-pack-data) = 0 .
                  if not can-find(first  ub.esys-pck-rcvd no-lock
                                    where ub.esys-pck-rcvd.esys-id  = buf_Ext-system.esys-id
                                      and ub.esys-pck-rcvd.db-num   = buf_Ext-system.db-num
                                      and ub.esys-pck-rcvd.espr-cr-db-num   = g#db-num
                                      and ub.esys-pck-rcvd.espr-pack-num = v-espr-pack-num
                                      )  /*пакет принят неполностью*/
                  then do:
                    v-return-error = 2.
                  end.
                  else v-analys-count = v-analys-count + 1 . // для итогового сообщения о количестве обработанных пакетов
                end.  

                if v-return-error > 0 then do:
                if v-err-type = '' then do:
                  assign
                  v-err-type = {&ora-err-type-PROCESSING}.
                end.
                v-err-msg = substitute( "Ошибка при разборе файла &1.&2&3&2&4"
                                        , v-file-name
                                        ,{&new-line}
                                        , return-value
                                        , (if v-return-error = 1
                                          then trim( error-status :get-message( 1 ) )
                                          else "Пакет принят неполностью")
                                      )         .
                run write-log in p-log-handle (
                                                input 2
                                                ,input v-err-msg ).
                  run send-msg-to-email in parparentproc
                      ( input substitute( "ТН (ver &2) БД &1. Ошибка OXML при импорте пакета из ВС &2"
                                        , v-ver-num
                                        , v-cur-db-num
                                        , buf_ext-system.esys-id )
                      ,input v-err-msg
                      ,input (if buf_ext-system.delivery-method = integer({&esys-dm-oracle-retail})
                              then entry(num-entries(add-log-file-name, {&delim-nws}), add-log-file-name, {&delim-nws})
                              else '')
                      ) no-error .
                  if error-status :error then do:
                    run write-log in p-log-handle (
                      input 2
                    , input substitute( "&1. &3&2&4", vss-workfile, {&new-line}, error-status:get-message(1), return-value )
                                                      ) .
                  end.
                end. /*if error-status:error*/
                if buf_ext-system.delivery-method = integer({&esys-dm-oracle-retail}) then do:
                  if v-exch-file-date = "" then do:
                    run cur-time in this-procedure ( output v-today, output v-time).
                    v-exch-file-date = string(datetime(v-today, mtime), "99/99/9999 HH:MM:SS").
                  end.
                  run rul/ora-rcpt.p (
                                        input parparentproc
                                      ,input this-procedure:handle
                                      ,input p-log-handle
                                      ,input v-cmd-proc-handle
                                      ,input v-cmd-code
                                      ,input buf_ext-system.esys-id
                                      ,input v-espr-pack-num
                                      ,input v-file-name
                                      ,input v-exch-file-date
                                      ,input entry(num-entries(add-log-file-name, {&delim-nws}), add-log-file-name, {&delim-nws})
                                      ,input v-err-type) no-error.
                  if error-status:error then do:
                    /*а непонятно что делать*/
                    v-err-msg = substitute( "Ошибка при разборе файла &1&2Не удалось сформировать квитанцию для пакета.&2&3&2&4"
                                            , v-file-name
                                            ,{&new-line}
                                            , return-value
                                            , error-status:get-message(1)
                                          )         .
                    os-delete value(entry(num-entries(add-log-file-name, {&delim-nws}), add-log-file-name, {&delim-nws})).
                    assign
                    add-log-file-name = add-log-file-name0
                    .
                    run write-log in p-log-handle (
                                                    input 2
                                                    ,input v-err-msg
                                                                      ).
                    run send-msg-to-email in parparentproc
                      ( input substitute( "ТН (ver &2) БД &1. Ошибка OXML при импорте пакета из ВС &2"
                                        , v-ver-num
                                        , v-cur-db-num
                                        , buf_ext-system.esys-id )
                      ,input v-err-msg
                      ,input (if buf_ext-system.delivery-method = integer({&esys-dm-oracle-retail})
                              then entry(num-entries(add-log-file-name, {&delim-nws}), add-log-file-name, {&delim-nws})
                              else '')
                      ) no-error .
                    if error-status :error then do:
                    run write-log in p-log-handle (
                      input 2
                    , input substitute( "&1. &3&2&4", vss-workfile, {&new-line}, error-status:get-message(1), return-value )
                                                      ) .
                    end.

                  end.
                  if v-err-type = '' then  do:
                    os-delete value(entry(num-entries(add-log-file-name, {&delim-nws}), add-log-file-name, {&delim-nws})).
                  end.
                  assign
                  add-log-file-name = add-log-file-name0
                  .
                end.
                if buf_ext-system.delivery-method = integer({&esys-dm-erp-1C-RN})
                and v-return-error > 0
                then do:
                  run gbl/ren-file.p (input v-full-path,
                                      input (v-path + "\err_" + v-file-name)
                                      ) no-error.
                  if v-cert-enabled then do :
                    v-position = r-index(v-sign-file, "\") .
                  run gbl/ren-file.p (input v-sign-file,
                                      input (v-path + "\err_" + substring(v-sign-file, v-position + 1))
                                      ) no-error.
                  end .
                end.
                if v-return-error > 0
                and buf_ext-system.delivery-method <> integer({&esys-dm-exite-edi})
                then do:
                  return error ''.
                end.
                assign
                  v-rcvd-pack = true
                .
                if not (v-espr-pack-name begins "ack_") then
                v-espr-pack-num = v-espr-pack-num + 1 .
                
                if ( v-pack-num <> -1
                    and v-espr-pack-num > v-pack-num
                  )
                  or lookup( v-action, "analys":U ) <> 0
                then do:
                  leave rcvd-pack.
                end.
              end.
            end.

            run gbl/del-file.p ( input v-temp-dir ) no-error .
            if error-status:error then do:
              run write-to-log( vss-workfile + {&space-char}
                                + substitute( "&1", return-value )
                              ).
            end.
            if (v-analys-count = 0) and (lookup( v-action, "take,take+analys":U ) > 0) then
              run write-log in p-log-handle (  input 2
                                                ,substitute(" для ВС '&1' нет разобранных пакетов", buf_ext-system.esys-name ) ) .
            run write-log in p-log-handle (  input 2
                                                ,substitute(v-msg-templ-finish, buf_ext-system.esys-name ) ) .
        end. /*if buf_ext-system.esys-have-export = yes*/
        add-log-file-name = ?.
      end.        /* for each buf_ext-system */
    end.  /* v-extsys-list */
    if valid-object(v-pkcs) then delete object v-pkcs .
    
    run write-log in p-log-handle (
          input 1
        , input "Загрузка данных по внешним системам завершена."
    ).
end.

procedure get-log-file-name :
define output parameter p-log-file-name as character no-undo .

  do
  on error undo, return error
  :
    p-log-file-name = add-log-file-name.
  end.

end procedure. /* get-log-file-name */

procedure set-err-type :
define input parameter p-err-type as character no-undo .
if v-err-type = '' then v-err-type = p-err-type. /*только первую ошибку устанавливаем*/
end procedure. /* set-err-type */


procedure set-exch-date-time :
define input parameter p-exch-file-date as character no-undo .
v-exch-file-date = p-exch-file-date.
end procedure. /* set-exch-date-time */


procedure cb_fill-filelist :
define input parameter p-file-name as character no-undo .
define input parameter p-dm as integer no-undo .
define variable v-file-name as character no-undo .

do
on error undo, return error
:
  
  find first temp-filelist where
            temp-filelist.file-name = p-file-name no-error.
  
  if p-dm = integer({&esys-dm-contour-edi})
  then do:

    if not available temp-filelist then do:
      create temp-filelist.
      if num-entries(p-file-name, '.':u) > 1
      then do:
        /* файл имеет расширение */
        assign
          temp-filelist.file-extension = entry(num-entries(p-file-name, '.':u), p-file-name,  '.':u )
          temp-filelist.file-name-no-ext = entry(num-entries(p-file-name, '.':u) - 1, p-file-name, '.':u )
        .
      end.
      else do:
        /* файл имеет пустое расширение */
        assign
          temp-filelist.file-extension = ''
          temp-filelist.file-extension = p-file-name
        .
      end.
      assign
      temp-filelist.file-name = p-file-name.
      release temp-filelist.
    end.

    
    
  end.
  else do:
    if not available temp-filelist then do:
      v-file-name = p-file-name.
      entry(1, v-file-name, "_") = "".
      create temp-filelist.
      assign
      temp-filelist.file-name = p-file-name
      temp-filelist.full-name = v-file-name
      .
      release temp-filelist.
    end.
  end.
end.

end procedure. /* cb_fill-filelist */

procedure get-num-namepack : /*получение имени и номеров пакетов для OR APM (SPAR), которые будут обработаны*/
define input parameter p-target-dir as character no-undo .
define input parameter p-esys-id as integer no-undo .
define input parameter p-db-num as integer no-undo .
define input parameter p-ext-sys-met as integer no-undo .

define variable v-file-pack-num as integer no-undo .
define variable datestr as character no-undo.
define variable timestr as character no-undo.

  define variable xml-source as character no-undo.
  define variable xml-result as character no-undo. 
  define variable java as character no-undo.
  define variable saxon as character no-undo.
  define variable xsl as character no-undo.
/*  define variable v-l-err as logical no-undo. 04/III-2019 не используется */
  define variable ii as integer no-undo.    

do
on error undo, return error
:
  /* 01/III-2019
     1. Нам надо забирать из EXCH только нужные расширения,
     2. и в разбор тоже надо брать только нужные файлы.
     Вызывается только для &esys-dm-contour-edi и для &esys-dm-erp-1C-RN
     3. и только файлы рассматриваемой внешней системы
  */
  case p-ext-sys-met :
    when {&bef-esys-dm-erp-1C-RN} then do :
      
      run filelist-init in this-procedure
      (input p-target-dir
      ,input true
      ,input "xml" // ,p7s,p7c"
      ,input ""
      ) no-error.
      if error-status:error then do:
        undo, return error .
      end.
      
      for each temp-filelist:
        /* пакеты и аски оставляем;
           прочие файлы игнорируем:
           - where temp-filelist.file-name begins "err_"
           - исключаем файлы с электронной подисью (такая же стоит в bge/espcknum.p):
             if (v-sign-fileext > "") and (temp-filelist.file-extension = v-sign-fileext)
           - ещё электронная подпись, связанная с bge/espcknum.p и bge/oxmlspci.w:
             if can-do("p7s,p7c", temp-filelist.file-extension)
           - в директорию импорта стали попадать файлы иконок, сслылок, и прочего,
             у которых другая структура имени и потом они ругаются на entry(3, ...):
             if num-entries(temp-filelist.file-name, "_") > 2 then . else delete temp-filelist .
        */
        if  num-entries(temp-filelist.file-name, "_") = 4 then do :
         /* if p-esys-id = integer (entry (2, temp-filelist.file-name-no-ext, "_")) then .
          else do :
            delete temp-filelist.
            next .  
          end . */
          v-file-pack-num = integer (entry (3, temp-filelist.file-name-no-ext, "_")) no-error .
          if error-status:error then do:
            /* ошибка возникнет при присвоении, если неверное имя пакета - например начинается не с номера пакета, пропускаем идем дальше.*/
            delete temp-filelist.
            next .  
          end.
          if v-espr-pack-num > v-file-pack-num then next .  
          create tt-espcknum.
          assign
            tt-espcknum.tt-espr-pack-name = temp-filelist.file-name
            tt-espcknum.tt-espr-pack-num  = v-file-pack-num
          .
        end .
        else if (  num-entries(temp-filelist.file-name, "_") = 5
                   and temp-filelist.file-name begins "ack"  ) then do :
          /*if p-esys-id = integer (entry (3, temp-filelist.file-name-no-ext, "_")) then .
          else do :
            delete temp-filelist.
            next .  
          end .*/
        end .
        else do :
          /* прочие файлы игнорируем */
          delete temp-filelist.
          next.
        end.
      end. /* end_of for_each temp-filelist */

    end . /* end_of when esys-dm-erp-1C-RN */
    when {&bef-esys-dm-contour-edi} then do :
      
      ii = 0.
      for each temp-filelist
         where temp-filelist.file-name begins "fail" 
      and not (temp-filelist.file-name matches "*Stsmsg*"
           or  temp-filelist.file-name matches "*unknown*") :
        ii = ii + 1.
        create tt-espcknum.
        assign
          tt-espcknum.tt-espr-pack-name = temp-filelist.file-name + "."
          tt-espcknum.tt-espr-pack-num = ii
        no-error.      
      end.
      for each temp-filelist where temp-filelist.file-name begins "ok" 
      and  not (temp-filelist.file-name matches "*Stsmsg*"
                or  temp-filelist.file-name matches "*unknown*") :
      ii = ii + 1.
      create tt-espcknum.
      assign
        tt-espcknum.tt-espr-pack-name = temp-filelist.file-name + "."
        tt-espcknum.tt-espr-pack-num = ii
      no-error.
      end.
      for each temp-filelist where temp-filelist.file-name begins "ORDRSP" :
      ii = ii + 1.
      create tt-espcknum.
      assign
        tt-espcknum.tt-espr-pack-name = temp-filelist.file-name + "."
        tt-espcknum.tt-espr-pack-num = ii
      no-error.
      end.
      for each temp-filelist where temp-filelist.file-name begins "DESADV" :
      ii = ii + 1.
      create tt-espcknum.
      assign
        tt-espcknum.tt-espr-pack-name = temp-filelist.file-name + "."
        tt-espcknum.tt-espr-pack-num = ii
      no-error.            
      end.
      
    end . /* end_of when esys-dm-contour-edi */
    otherwise return .
  end case .

  

/* 04/III-2019 - не используется
  if v-l-err then
    run write-log in p-log-handle (
          input 1
        , input substitute( "При преобразовании файла(ов) возникли ошибки. Проверьте целостность xml пакетов.")
    ).
*/
end.

end procedure. /* get-num-namepack */