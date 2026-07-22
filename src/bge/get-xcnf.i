/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка подтверждений принятых из ВС

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/23/08
Author: Bakhtadze Natalya
Creation date: 02/23/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ bge/esysattr.i }
{ gbl/cur-time.i }

procedure get-xcnf_get-xcnf :
define input  parameter p-esys-id as integer no-undo .
define input  parameter p-db-num as integer   no-undo .
define input  parameter p-cr-db-num as integer   no-undo .
define input  parameter p-pack-num as integer   no-undo .
define input  parameter p-delivery-method as integer no-undo .
define parameter buffer buf_temp-esys-pck-sent for THpck-sent.
define parameter buffer buf_temp-esys-pck-rcvd for THpck-rcvd.
define parameter buffer curr_temp-esys-pck-sent for THcurr-pack.
define output parameter p-rec-cnt as integer   no-undo .

define buffer buf_esys-pck-keys for ub.esys-pck-keys.
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_esys-pck-sent for ub.esys-pck-sent.
define buffer buf_esys-route for ub.esys-route.
define buffer buf_esys-all-attr for ub.esys-all-attr.


DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-del-cnt as integer no-undo .
define variable v-del-pck-num as integer   no-undo.
define frame del-route
v-del-pck-num   label "Пакет N" format ">>>>>>>>>9" skip
v-del-cnt       label "Записей" format ">>>>>>>>>9"
with view-as dialog-box side-labels 1 columns three-d title "Удаление маршрутизации"
.


main-block:
do
on error undo, return error return-value
:
  if p-delivery-method <> integer({&esys-dm-exite-edi}) then do:
  /*проверим номер текущего пакета*/
    find first curr_temp-esys-pck-sent where
              curr_temp-esys-pck-sent.THesys-id = p-esys-id
          and curr_temp-esys-pck-sent.THpack-num = p-pack-num no-error.
    if not available curr_temp-esys-pck-sent then do:
      undo, return error  substitute("Не найдена запись о текущем пакете &1 THcurr-pack в XML файлe &2:&3&4"
                                      , p-pack-num
                                      , p-xml-file-name
                                      , {&new-line}
                                      , error-status:get-message(1)).
    end.
    p-rec-cnt = p-rec-cnt + 1.
    run cur-time in this-procedure ( output v-today, output v-time) no-error .
    if error-status :error then do:
      &scop my-message  substitute("&1 Ошибка при определении текущей даты!", {&space-char})

    {&display-message}.
      undo, return error.
    end.
    if trim( curr_temp-esys-pck-sent.THcrc-pack ) = "" then do:
      undo, return error  substitute( "Ошибка обработки пакета: пакет N &1 в XML файлe &2 не имеет ключа!!!"
                                    , p-pack-num
                                    , p-xml-file-name ).
    end.
    if num-entries( curr_temp-esys-pck-sent.THcrc-pack, {&space-char} ) < 4 then do:
      undo, return error  substitute( "Ошибка обработки пакета: некорректный ключ (&1) пакета N &2 !!!"
                                  , curr_temp-esys-pck-sent.THcrc-pack
                                  , p-pack-num ).
    end.
  end. /*if p-delivery-method <> integer({&esys-dm-exite-edi}) then do:*/
  if p-delivery-method <> integer({&esys-dm-exite-edi}) then do:
    for each buf_temp-esys-pck-sent
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      /*список пакетов отправленных ВНЕШНЕЙ СИСТЕМОЙ*/
      p-rec-cnt = p-rec-cnt + 1.

      find buf_esys-pck-rcvd exclusive-lock
        where buf_esys-pck-rcvd.esys-id   = p-esys-id
          and buf_esys-pck-rcvd.db-num   = p-db-num
          and buf_esys-pck-rcvd.espr-cr-db-num   = p-cr-db-num
          and buf_esys-pck-rcvd.espr-pack-num = buf_temp-esys-pck-sent.THpack-num
        no-error.
      if not available buf_esys-pck-rcvd then do:
        create buf_esys-pck-rcvd.
        assign
        buf_esys-pck-rcvd.esys-id    = p-esys-id
        buf_esys-pck-rcvd.db-num     = p-db-num
        buf_esys-pck-rcvd.espr-cr-db-num     = p-cr-db-num
        buf_esys-pck-rcvd.espr-pack-num   = buf_temp-esys-pck-sent.THpack-num
        buf_esys-pck-rcvd.espr-rcvd       = buf_temp-esys-pck-sent.THrcvd
        buf_esys-pck-rcvd.espr-rcvd-recs  = 0
        buf_esys-pck-rcvd.espr-total-recs = buf_temp-esys-pck-sent.THtotal-recs
        buf_esys-pck-rcvd.espr-crc-pack   = buf_temp-esys-pck-sent.THcrc-pack
        buf_esys-pck-rcvd.custom-pack-name = buf_temp-esys-pck-sent.THfilename
        .
        find first buf_esys-all-attr share-lock where
                buf_esys-all-attr.attr-code = {&attr-custom-pack-name}
            and buf_esys-all-attr.table-name = {&table_esys-pck-rcvd}
            and buf_esys-all-attr.key1 = buf_esys-pck-rcvd.espr-pack-num
            and buf_esys-all-attr.key2 = p-esys-id
            and buf_esys-all-attr.key5 = p-db-num
            and buf_esys-all-attr.key6 = p-cr-db-num no-error.
        if available buf_esys-all-attr then do:
          buf_esys-pck-rcvd.custom-pack-name = buf_esys-all-attr.attr-value.
          delete buf_esys-all-attr.
        end.
      end. /*if not available buf_esys-pck-rcvd then do:*/
    end. /*for each buf_temp-esys-pck-sent*/
  end. /*if p-delivery-method <> integer({&esys-dm-exite-edi}) then do:*/
  for each buf_temp-esys-pck-rcvd
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    /*список пакетов полученных ВНЕШНЕЙ СИСТЕМОЙ*/
    p-rec-cnt = p-rec-cnt + 1.
    find buf_esys-pck-sent share-lock
      where buf_esys-pck-sent.esys-id  = p-esys-id
        and buf_esys-pck-sent.db-num   = p-db-num
        and buf_esys-pck-sent.esps-cr-db-num = p-cr-db-num
        and buf_esys-pck-sent.esps-pack-num = buf_temp-esys-pck-rcvd.THpack-num
      no-error.

    if available buf_esys-pck-sent then do:
      assign
        v-del-cnt = 0
      .
      view frame del-route .

      for each buf_esys-route
        where buf_esys-route.esys-id  = buf_esys-pck-sent.esys-id
          and buf_esys-route.db-num    = buf_esys-pck-sent.db-num
          and buf_esys-route.esr-cr-db-num    = buf_esys-pck-sent.esps-cr-db-num
          and buf_esys-route.esr-last-pack = buf_esys-pck-sent.esps-pack-num
      on error  undo, return error substitute("&1. error buf_esys-route &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      on endkey undo, return error substitute("&1. endkey buf_esys-route")
      on stop   undo, return error substitute("&1. stop buf_esys-route")
      :
        assign
          v-del-cnt = v-del-cnt + 1
        .
        do with frame del-route
        :
          assign
            v-del-pck-num :screen-value   = string( buf_esys-route.esr-last-pack, v-del-pck-num :format)
            v-del-cnt :screen-value       = string( v-del-cnt, v-del-cnt :format)
          .
        end.
        delete buf_esys-route.
      end.

      hide frame del-route .

      transaction_block_pck-rcvd:
      do /*transaction*/
      on error  undo, return error substitute("&1. error transaction_block_pck-rcvd &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      on endkey undo, return error substitute("&1. endkey transaction_block_pck-rcvd")
      on stop   undo, return error substitute("&1. stop transaction_block_pck-rcvd")
      :
        assign
          buf_esys-pck-sent.esps-rcvd        = yes
          buf_esys-pck-sent.esps-rcvdDate    = buf_temp-esys-pck-rcvd.thrcvddate
          buf_esys-pck-sent.esps-RcvdTimeInt = buf_temp-esys-pck-rcvd.thrcvdtimeint
          buf_esys-pck-sent.esps-RcvdTime    = string( buf_temp-esys-pck-rcvd.thrcvdtimeint, "HH:MM:SS" )
        .
      end.
    end.
    delete buf_temp-esys-pck-rcvd.
  end. /*   for each buf_temp-esys-pck-rcvd*/
end.

end procedure. /* get-xcnf_get-xcnf */


procedure get-xcnf_set-xcnf :
define input  parameter p-esys-id as integer no-undo .
define input  parameter p-db-num as integer   no-undo .
define input  parameter p-cr-db-num as integer   no-undo .
define input  parameter p-pack-num as integer   no-undo .
define input  parameter p-rec-cnt     as integer   no-undo.
define input  parameter p-headerh as handle.
define parameter buffer buf_temp-esys-pck-sent for THpck-sent.
define parameter buffer buf_temp-esys-pck-rcvd for THpck-rcvd.
define parameter buffer curr_temp-esys-pck-sent for THcurr-pack.


define variable v-present as logical no-undo .

define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_esys-pck-sent for ub.esys-pck-sent.
define buffer buf_esys-all-attr for ub.esys-all-attr.



do
on error undo, return error return-value
:
  transaction_block_end:
  do /*transaction*/
  on error  undo, return error substitute("&1. error transaction_block_end &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on endkey undo, return error substitute("&1. endkey transaction_block_end")
  on stop   undo, return error substitute("&1. stop transaction_block_end")
  :
    /* создать запись о данном пакете в целевой ( данной ) БД */
    find first buf_temp-esys-pck-sent
      where buf_temp-esys-pck-sent.THesys-id = p-esys-id
        and buf_temp-esys-pck-sent.THpack-num = p-pack-num
      no-error.

    if not available buf_temp-esys-pck-sent
    then do:
      undo, return error substitute( "&1. Отсутствует полная информация о пакете &2 для ВС &3"
                                    ,vss-workfile
                                    ,p-pack-num
                                    ,p-esys-id
                                  )  .
    end.
    &scop esys-id p-esys-id
    &scop esys-db-num p-db-num
    &scop cr-db-num p-cr-db-num
    &scop pack-num p-pack-num
    { bge/crexrpck.i }
    if new(buf_esys-pck-rcvd) then do:
      buf_esys-pck-rcvd.espr-rcvd       = buf_temp-esys-pck-sent.THrcvd.
    end.
    assign
    buf_esys-pck-rcvd.espr-rcvd-recs  = p-rec-cnt
    buf_esys-pck-rcvd.espr-total-recs = (if valid-handle(p-headerh)
                                         then (if p-headerh:table = "thheader"
                                               then p-headerh::THtotal-recs
                                               else 1)
                                         else 1)
    buf_esys-pck-rcvd.espr-CRC-pack   = buf_temp-esys-pck-sent.THCRC-pack
    buf_esys-pck-rcvd.custom-pack-name = buf_temp-esys-pck-sent.THfilename
    .
    find first buf_esys-all-attr share-lock where
            buf_esys-all-attr.attr-code = {&attr-custom-pack-name}
        and buf_esys-all-attr.table-name = {&table_esys-pck-rcvd}
        and buf_esys-all-attr.key1 = buf_esys-pck-rcvd.espr-pack-num
        and buf_esys-all-attr.key2 = p-esys-id
        and buf_esys-all-attr.key5 = p-db-num
        and buf_esys-all-attr.key6 = p-cr-db-num no-error.
    if available buf_esys-all-attr then do:
        buf_esys-pck-rcvd.custom-pack-name = buf_esys-all-attr.attr-value.
        delete buf_esys-all-attr.
    end.
    /* подтверждение на подтверждение -- возврат подтверждения */
    for each buf_esys-pck-rcvd exclusive-lock
      where buf_esys-pck-rcvd.esys-id = p-esys-id
        and buf_esys-pck-rcvd.db-num = p-db-num
        and buf_esys-pck-rcvd.espr-cr-db-num = p-cr-db-num
        and buf_esys-pck-rcvd.espr-rcvd   = no
    on error  undo, return error substitute("&1. error buf_esys-pck-rcvd &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on endkey undo, return error substitute("&1. endkey buf_esys-pck-rcvd")
    on stop   undo, return error substitute("&1. stop buf_esys-pck-rcvd")
    :
      find first buf_temp-esys-pck-sent no-lock
        where buf_temp-esys-pck-sent.thesys-id = p-esys-id
          and buf_temp-esys-pck-sent.THpack-num = buf_esys-pck-rcvd.espr-pack-num
        no-error .
      if not available buf_temp-esys-pck-sent then do:
        /* это значит, что в другой ВС получили подтверждение о приняти здесь этого пакета */
        /* и эта запись больше в пакет ( для той БД ) передаваться не будет                */
        assign
          buf_esys-pck-rcvd.espr-rcvd = yes
        .
      end.
    end.
    run get-xcnf_check-imp-rec in this-procedure
      ( input  "delete":U
      ,input  p-esys-id
      ,input  p-db-num
      ,input  p-cr-db-num
      ,input  p-pack-num
      ,input  ?
      ,output v-present
      ) no-error .
    if error-status :error then do:
      undo, return  error  substitute( "&1. Ошибка при удалении уникальных ключей строк пакета. &2", vss-workfile, return-value ).
    end.
    run ext-system-attr-write in this-procedure
      ( input p-esys-id
      ,input p-db-num
      ,input {&attr-need-gen-new-xpack}
      ,input "yes":U
      ) no-error.
    if error-status :error then do:
      undo, return error   substitute( "&1. Ошибка записи атрибута формирования нового пакета для ВС &2"
                                    ,vss-workfile
                                    ,p-esys-id~
                                  ).
    end.
  end. /* transaction_block_end */
end.

end procedure. /* get-xcnf_set-xcnf */


procedure get-xcnf_set0xcnf :
define input  parameter p-esys-id as integer no-undo .
define input  parameter p-db-num as integer   no-undo .
define input  parameter p-cr-db-num as integer   no-undo .
define input  parameter p-pack-num as integer   no-undo .
define input  parameter p-delivery-method as integer no-undo .
define input  parameter p-rec-cnt as integer   no-undo .
define input  parameter p-headerh as handle no-undo .

define variable v-present as logical no-undo .
define variable v-rcvd as logical no-undo .

define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_esys-all-attr for ub.esys-all-attr.
define buffer buf_temp-esys-pck-sent for THpck-sent.

  do
  on error undo, return error return-value
  :
    find buf_esys-pck-rcvd exclusive-lock
      where buf_esys-pck-rcvd.esys-id  = p-esys-id
        and buf_esys-pck-rcvd.db-num   = p-db-num
        and buf_esys-pck-rcvd.espr-cr-db-num   = p-cr-db-num
        and buf_esys-pck-rcvd.espr-pack-num = p-pack-num
      no-error.
    if not available buf_esys-pck-rcvd then do:
      create buf_esys-pck-rcvd.
      assign
      buf_esys-pck-rcvd.esys-id    = p-esys-id
      buf_esys-pck-rcvd.db-num     = p-db-num
      buf_esys-pck-rcvd.espr-cr-db-num     = p-cr-db-num
      buf_esys-pck-rcvd.espr-pack-num   = p-pack-num
      .
      find first buf_esys-all-attr share-lock where
              buf_esys-all-attr.attr-code = {&attr-custom-pack-name}
          and buf_esys-all-attr.table-name = {&table_esys-pck-rcvd}
          and buf_esys-all-attr.key1 = buf_esys-pck-rcvd.espr-pack-num
          and buf_esys-all-attr.key2 = p-esys-id
          and buf_esys-all-attr.key5 = p-db-num
          and buf_esys-all-attr.key6 = p-cr-db-num no-error.
      if available buf_esys-all-attr then do:
         buf_esys-pck-rcvd.custom-pack-name = buf_esys-all-attr.attr-value.
         delete buf_esys-all-attr.
      end.
    end.
    define variable v-recs as integer no-undo .
    define variable v-filename as character no-undo .
    if valid-handle(p-headerh) then do:
      case p-headerh:table:
        when  "THheader" then do:
          assign
          v-recs = p-headerh::THtotal-recs
          v-filename = p-headerh::THfilename
          .
        end.
        when "header_" then do:
          define variable v1-flag as logical no-undo .
          assign
          v-recs = 1
          v-filename =  get-short-pack-name( input "get"
                                          , input buf_esys-pck-rcvd.espr-pack-num
                                          , input p-delivery-method
                                          , input buf_esys-pck-rcvd.custom-pack-name
                                          , output v1-flag).

        end.
      end case.
    end.
    else do:
      if p-delivery-method = integer({&esys-dm-exite-edi})
      or p-delivery-method = integer({&esys-dm-erp-1C-RN})
      then do:
        assign
        v-recs = 1
        v-filename = buf_esys-pck-rcvd.custom-pack-name
        .
      end.
    end.
    if p-delivery-method = integer({&esys-dm-exite-edi}) then do:
      find first buf_temp-esys-pck-sent no-lock
        where buf_temp-esys-pck-sent.thesys-id = p-esys-id
          and buf_temp-esys-pck-sent.THpack-num = buf_esys-pck-rcvd.espr-pack-num
        no-error .
      /*если эта запись есть значит пакет разобрался с ИМПОРТОМ ДАННЫХ В БД - если записи нет пакет принят - но данные проигнорированы*/
      if available buf_temp-esys-pck-sent then do:
        v-rcvd = yes.
      end.
    end.
    else do:
      v-rcvd = yes.
    end.
    assign
    buf_esys-pck-rcvd.espr-total-recs = v-recs
    buf_esys-pck-rcvd.espr-rcvd-recs = p-rec-cnt
    buf_esys-pck-rcvd.espr-CRC-pack   = "" /*THcrc-pack*/
    buf_esys-pck-rcvd.espr-rcvd  = v-rcvd
    buf_esys-pck-rcvd.custom-pack-name = v-filename
    .

    ibs.th.bge.1crn.import.impmsgs:writeError2Db(
       p-esys-id
      ,p-db-num
      ,p-cr-db-num
      ,p-pack-num).

    run str/callnews.p
      (input {&table_esys-pck-rcvd}
      ,input (buffer buf_esys-pck-rcvd:handle)
      )  .
    run get-xcnf_check-imp-rec in this-procedure
      ( input  "delete":U
      ,input  p-esys-id
      ,input  p-db-num
      ,input  p-cr-db-num
      ,input  p-pack-num
      ,input  ?
      ,output v-present
      ) no-error .
    if error-status :error then do:
      undo, return  error  substitute( "&1. Ошибка при удалении уникальных ключей строк пакета. &2", vss-workfile, return-value ).
    end.
  end.

end procedure. /* get-xcnf_set0xcnf */



procedure get-xcnf_check-imp-rec :
  define input  parameter p-action   as character no-undo .
  define input  parameter p-esys-id  as integer no-undo .
  define input  parameter p-db-num   as integer   no-undo .
  define input  parameter p-cr-db-num as integer no-undo .
  define input  parameter p-pack-num as integer   no-undo .
  define input  parameter p-uniq-key as character no-undo .
  define output parameter p-present  as logical   no-undo .
  do
  on error  undo, return error substitute( "&1 (check-imp-rec). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (check-imp-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (check-imp-rec). endkey", vss-workfile )
  :
    define buffer buf_esys-pck-keys for ub.esys-pck-keys .

    case p-action :
      when "create":U then do:
        if not transaction then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Вызов процедуры check-imp-rec( create ) возможен только в одной транзакции с приемом записи!" )
            view-as alert-box error
          .
          return error .
        end.
        find first buf_esys-pck-keys
          where buf_esys-pck-keys.esys-id  = p-esys-id
            and buf_esys-pck-keys.db-num   = p-db-num
            and buf_esys-pck-keys.espr-cr-db-num = p-cr-db-num
            and buf_esys-pck-keys.espr-pack-num = p-pack-num
            and buf_esys-pck-keys.espr-uniq-key = p-uniq-key
          no-error .
        if available buf_esys-pck-keys then do:
          assign
            p-present = true
          .
        end.
        else do:
          do transaction
          on error undo, return error
          :
            create buf_esys-pck-keys .
            assign
            buf_esys-pck-keys.esys-id  = p-esys-id
            buf_esys-pck-keys.db-num   = p-db-num
            buf_esys-pck-keys.espr-cr-db-num = p-cr-db-num
            buf_esys-pck-keys.espr-pack-num = p-pack-num
            buf_esys-pck-keys.espr-uniq-key = p-uniq-key
            p-present = false
            .
          end.
        end.
      end.
      when "delete":U then do:
        for each buf_esys-pck-keys exclusive-lock
          where buf_esys-pck-keys.esys-id  = p-esys-id
            and buf_esys-pck-keys.db-num   = p-db-num
            and buf_esys-pck-keys.espr-cr-db-num = p-cr-db-num
            and buf_esys-pck-keys.espr-pack-num = p-pack-num
        on error  undo, return error substitute( "&1 (check-imp-rec). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        on stop   undo, return error substitute( "&1 (check-imp-rec). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (check-imp-rec). endkey", vss-workfile )
        :
          delete buf_esys-pck-keys.
        end.
      end.
    end case.
  end.
  return.
end procedure. /* check-imp-rec */

procedure get-xcnf_create-temp-esys-pck-rcvd :
define input parameter p-esys-id as integer no-undo .
define input parameter p-pack-num as integer no-undo .
define input parameter p-crc-pack as character no-undo .
define input parameter p-rcvd as logical no-undo .
define input parameter p-rcvd-recs as integer no-undo .
define input parameter p-total-recs as integer no-undo .
define input parameter p-rcvd-date as date no-undo .
define input parameter p-rcvd-time-int as integer no-undo .
define input parameter p-rcvd-time as character no-undo .
define buffer buf_temp-esys-pck-rcvd for THpck-rcvd.
/*создание записи о пакете который получила ВНЕШНЯЯ СИСТЕМА*/


do
on error undo, return error
:
  find first buf_temp-esys-pck-rcvd where
            buf_temp-esys-pck-rcvd.THesys-id = p-esys-id
        and buf_temp-esys-pck-rcvd.thpack-num = p-pack-num no-error.
  if not available buf_temp-esys-pck-rcvd then do:
    create buf_temp-esys-pck-rcvd.
    assign
    buf_temp-esys-pck-rcvd.thesys-id = p-esys-id
    buf_temp-esys-pck-rcvd.thpack-num = p-pack-num
    .
  end.
  assign
  buf_temp-esys-pck-rcvd.THcrc-pack  = p-crc-pack
  buf_temp-esys-pck-rcvd.THrcvd-recs   = p-rcvd-recs
  buf_temp-esys-pck-rcvd.THrcvd  = p-rcvd
  buf_temp-esys-pck-rcvd.THtotal-recs   = p-total-recs
  buf_temp-esys-pck-rcvd.THrcvddate  = p-rcvd-date
  buf_temp-esys-pck-rcvd.THrcvdtimeint = p-rcvd-time-int
  buf_temp-esys-pck-rcvd.THrcvdtime  = p-rcvd-time
  .
end.

end procedure. /* get-xcnf_create-temp-esys-pck-rcvd */

procedure get-xcnf_create-temp-esys-pck-sent :
define input parameter p-esys-id as integer no-undo .
define input parameter p-pack-num as integer no-undo .
define input parameter p-crc-pack as character no-undo .
define input parameter p-rcvd as logical no-undo .
define input parameter p-rcvd-recs as integer no-undo .
define input parameter p-total-recs as integer no-undo .
define input parameter p-rcvd-date as date no-undo .
define input parameter p-rcvd-time-int as integer no-undo .
define input parameter p-rcvd-time as character no-undo .
define buffer buf_temp-esys-pck-sent for THpck-sent.
/*создание записи о пакете который получили МЫ от внешней системы*/


do
on error undo, return error
:
  find first buf_temp-esys-pck-sent where
            buf_temp-esys-pck-sent.THesys-id = p-esys-id
        and buf_temp-esys-pck-sent.thpack-num = p-pack-num no-error.
  if not available buf_temp-esys-pck-sent then do:
    create buf_temp-esys-pck-sent.
    assign
    buf_temp-esys-pck-sent.thesys-id = p-esys-id
    buf_temp-esys-pck-sent.thpack-num = p-pack-num
    .
  end.
  assign
  buf_temp-esys-pck-sent.THcrc-pack  = p-crc-pack
  buf_temp-esys-pck-sent.THtotal-recs   = p-total-recs
  buf_temp-esys-pck-sent.THrcvd  = p-rcvd
  buf_temp-esys-pck-sent.THtotal-recs   = p-total-recs
  buf_temp-esys-pck-sent.THrcvddate  = p-rcvd-date
  buf_temp-esys-pck-sent.THrcvdtimeint = p-rcvd-time-int
  buf_temp-esys-pck-sent.THrcvdtime  = p-rcvd-time
  buf_temp-esys-pck-sent.THtotal-recs = p-total-recs
  .
end.
end procedure. /* get-xcnf_create-temp-esys-pck-sent */


procedure get-xcnf_find-pack-by-rd-uniq-key-rec :
/*ищем номер пакета по esys-route-dump.uniq-key-rec*/
define input parameter p-esys-id as integer no-undo .
define input parameter p-db-num as integer no-undo .
define input parameter p-uniq-key-rec as character no-undo .
define buffer buf_esys-route-dump for ub.esys-route-dump.
define buffer buf_esys-route for ub.esys-route.

do
on error undo, return error
:
  for each buf_esys-route-dump no-lock where
          buf_esys-route-dump.esrd-uniq-key-rec = p-uniq-key-rec,
      first buf_esys-route no-lock where
          buf_esys-route.esr-dump-ord   = buf_esys-route-dump.esrd-dump-ord
      and buf_esys-route.esys-id   = p-esys-id
      and buf_esys-route.db-num   = p-db-num:
    if buf_esys-route.esr-last-pack <> ?
    and buf_esys-route.esr-last-pack >= 0 then do:
      p-pack-num = buf_esys-route.esr-last-pack.

      return.
    end.
  end.
end.

end procedure. /* get-xcnf_find-pack-by-rd-uniq-key-rec */


procedure get-xcnf_find-pack-by-rd :
/*ищем номер пакета по esys-route-dump.esrd-dump-ord*/
define input parameter p-esys-id as integer no-undo .
define input parameter p-db-num as integer no-undo .
define input parameter p-dump-ord as int64 no-undo .
define buffer buf_esys-route-dump for ub.esys-route-dump.
define buffer buf_esys-route for ub.esys-route.

do
on error undo, return error
:
  for each buf_esys-route-dump no-lock where
          buf_esys-route-dump.esrd-dump-ord = p-dump-ord,
      first buf_esys-route no-lock where
          buf_esys-route.esr-dump-ord   = buf_esys-route-dump.esrd-dump-ord
      and buf_esys-route.esys-id   = p-esys-id
      and buf_esys-route.db-num   = p-db-num:
    if buf_esys-route.esr-last-pack <> ?
    and buf_esys-route.esr-last-pack >= 0 then do:
      p-pack-num = buf_esys-route.esr-last-pack.

      return.
    end.
  end.
end.

end procedure. /* get-xcnf_find-pack-by-rd */

/* $Workfile$ e n d */