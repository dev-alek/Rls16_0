block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cbnki-1s.p $
$Archive: bge/cbnki-1s.p $

Разбор файла системы КЛИЕНТ-БАНК формата 1s

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/21/05
Author: Bakhtadze Natalya
Creation date: 07/21/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .


define input parameter p-file-name as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-bik       like ub.fin-bank.bik      no-undo .
define input parameter p-code-bank like ub.fin-bank.code-bank no-undo .
define input parameter p-adresat   as character no-undo .
define input parameter p-do-create as logical no-undo .
define input parameter p-create-no-th as logical no-undo .
define input parameter p-encoding  as character no-undo .
define input parameter p-rs-hsch   as integer no-undo .
define input-output parameter p-view-log       as logical no-undo .
define output parameter p-count as integer no-undo .
define output parameter p-processed as integer no-undo .
define output parameter p-created as integer no-undo .
define output parameter p-count-statement as integer no-undo .
define output parameter p-processed-statement as integer no-undo .
define output parameter p-created-statement as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cbnki-1s.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/cbnki-1s.p $":U .
define variable vss-description as character no-undo init "Разбор файла системы КЛИЕНТ-БАНК формата 1s".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ bge/clbnkd.i "SHARED" }
{ bge/clbnkd.i "hfields" "SHARED" }
{ ref/fndocip.i }
{ ref/fnstmip.i }
{ gbl/cur-time.i }
{ trg/f-docath.i }
{ trg/factord.i }
{ trg/new-bcod.i }

&scop display-message   run write-log-and-file in p-log-handle (                             ~
                                                                  input 1                    ~
                                                                , input log-file-name        ~
                                                                , input 1                    ~
                                                                , input ~{&my-message~})

FUNCTION cbnki-period-to-String returns character(input  p-date1 as date, input p-date2 as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date1), "9999":U) + {&slash-char} +
             string(Month(p-date1), "99":U) + {&slash-char} +
             string(DAY(p-date1), "99":U) + '-':U +
             string(YEAR(p-date2), "9999":U) + {&slash-char} +
             string(Month(p-date2), "99":U) + {&slash-char} +
             string(DAY(p-date2), "99":U).

return v-date-str.
END FUNCTION.


define variable log-file-name as character no-undo init "ext-cbnk.log".
define variable sss as character no-undo .
define variable var-file-line-num as integer no-undo .
define variable ii as integer no-undo .
define variable n-entry as character no-undo extent 2.
define variable v-count as integer no-undo .
define variable gbl-type as character no-undo .
define variable gbl-schet as character no-undo .
DEFINE VARIABLE accept-types               as   character no-undo init "Платежное поручение".
define variable exist as logical no-undo init yes.
define variable exist-statement as logical no-undo init yes.
define variable in-doc as integer no-undo .
define variable in-statement as integer no-undo .
define variable v-version-TH as character no-undo .
define variable v-exchange-file as logical no-undo .
define variable v-crit-err   as logical no-undo .
define variable v-seq as integer no-undo .
define variable v-seq-statement as integer no-undo .
define variable v-bank-date-chr as character no-undo .
define stream PrnLibStream.

define temp-table tt-1s-fin-doc no-undo like ub.fin-doc
field fin-doc-code-th as integer
.
define temp-table tt-th-fin-doc no-undo like ub.fin-doc.
define temp-table tt-1s-fin-statement no-undo like ub.fin-statement.
define temp-table tt-th-fin-statement no-undo like ub.fin-statement.

DEFINE TEMP-TABLE tt0-fin-doc-attr NO-UNDO LIKE ub.fin-doc-attr.
DEFINE TEMP-TABLE tt0-fin-doc-tax NO-UNDO LIKE ub.fin-doc-tax.
DEFINE TEMP-TABLE tt0-payment NO-UNDO LIKE ub.payment.


do
on error undo, return error
:
  for each tt-1s-fin-doc:
    delete tt-1s-fin-doc.
  end.
  for each tt-th-fin-doc:
    delete tt-th-fin-doc.
  end.
  if p-encoding = 'WIndows-1251' then do:
    input stream PRnLibStream from value( p-file-name ).
  end.
  else do:
    input stream PRnLibStream from value( p-file-name ) convert source p-encoding.
  end.
  &scop my-message substitute("&3Чтение файла импорта &1 Отправитель &2&3" + ~
                              "Банк с БИК &4"                              ~
                              ,  p-file-name                               ~
                              , p-adresat                                  ~
                              , ~{&new-line~}                              ~
                              , p-bik   )
              {&display-message}.

  _repeat:
  REPEAT :
  _line:
  DO TRANSACTION:
    import stream PrnLibStream unformatted sss.
    assign
    var-file-line-num = var-file-line-num + 1
    .
    if var-file-line-num modulo 50 = 0 then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Файл &1: прочитано строк &2", p-file-name, var-file-line-num)).
    end.
    if sss = "" or sss = ? then do:
        assign
        n-entry[1] = ""
        n-entry[2] = ""
        .
        leave _line.
    end.
    assign
    n-entry[1] = entry(1, sss, "=")
    n-entry[2] = (if num-entries(sss, '=':U) > 1
                  then substring(sss, length(n-entry[1]) + 2)
                  else '':U)
    .
    /*сохраним во временной таблице*/
  END.
  DO TRANSACTION :
    if n-entry[2] = 'Windows'
    or n-entry[2] = 'DOS' then do:
      if (n-entry[2] = 'Windows'
      and p-encoding <> 'WIndows-1251'
      )
      or (n-entry[2] = 'DOS'
      and p-encoding <> 'ibm866') then do:
          input stream PrnLibStream close.
          p-view-log = yes.
&scop my-message substitute("!!!Неверно выбрана кодировка: выбрана &1,&2а в импортируемом файле &3&2Файл &4"  ~
                        , (if p-encoding = 'Windows-1251' then 'Windows' else 'DOS')                         ~
                        , ~{&new-line~}                                                                      ~
                        , n-entry[2]                                                                         ~
                        , p-file-name                                             )
          {&display-message}.
          return.
      end.
    end.
    CASE n-entry[1]:

      when '1CClientBankExchange' then do:
        assign
        v-exchange-file = yes
        .
      end.
      when 'КонецФайла' then do:
        if in-doc > 0 then do:
          assign
          v-crit-err = yes
          p-view-log = yes.
  &scop my-message substitute("!!!Метка <КонецФайла> в середине секции документа:&1Импорт прерван&1"  ~
                            , ~{&new-line~}                                                         ~
                                 )
              {&display-message}.
          return.
        end.
      end.
      when ''
      or
      when 'КонецДокумента'
      then do:
        /*надо уладить все дела со принятыми докуменмами!!!*/
        run proc-end-doc in this-procedure no-error .
        if error-status:error  then do:
          v-crit-err = yes.
          if (return-value = '':U or
          return-value = 'error')
          then do:
            input stream PrnLibStream close.
            p-view-log = yes.
  &scop my-message substitute("!!!Ошибки при чтении файла:&1&2 &3&1Импорт прерван&1"  ~
                            , ~{&new-line~}                                                                      ~
                            , error-status:get-message(1)                                                        ~
                            , return-value                                   )
              {&display-message}.
            return.
          end.
          else do:
            p-view-log = yes.
  &scop my-message return-value
              {&display-message}.
          end.
        end.
        if return-value = 'error' then do:
          input stream PrnLibStream close.
          return.
        end.
      end.
      when 'ДатаСоздания' then do:
        assign
        v-bank-date-chr = n-entry[2]
        .
      end.
      when 'Получатель' then do:
        if in-doc = 0 then do:
          run gbl/getvers.p (output v-version-TH).
          v-version-TH = substitute('IBS TH &1', v-version-TH).
          if n-entry[2] <> v-version-TH then do:
            input stream PrnLibStream close.
              p-view-log = yes.
  &scop my-message substitute("!!!Неверный получатель: &1&2, ожидалось &3&2Файл &4"  ~
                            , n-entry[2]                         ~
                            , ~{&new-line~}                                                                      ~
                            , v-version-TH                                                                         ~
                            , p-file-name                                             )
              {&display-message}.
              return.
          end.
        end.
      end.
      when 'Отправитель' then do:
        if n-entry[2] <> p-adresat then do:
          input stream PrnLibStream close.
            p-view-log = yes.
&scop my-message substitute("!!!Неверный отправитель: &1&2, ожидалось &3&2Файл &4"  ~
                          , n-entry[2]                         ~
                          , ~{&new-line~}                                                                      ~
                          , p-adresat                                                                          ~
                          , p-file-name                                             )
            {&display-message}.
            return.
        end.
      end.
      when 'ВерсияФормата' then do:
        if n-entry[2] <> {&cl-bank-1s-version} then do:
           input stream PrnLibStream close.
            p-view-log = yes.
&scop my-message substitute("!!!Неверная версия формата: &1&2, ожидалось &3&2Файл &4"  ~
                          , n-entry[2]                         ~
                          , ~{&new-line~}                                                                      ~
                          , {&cl-bank-1s-version}                                                              ~
                          , p-file-name                                             )
            {&display-message}.
            return.
        end.
      end.
      when 'СекцияДокумент' then  do:  /* Заголовок документа любого типа */
        /*если мы здесь то начинается новый документ надо уладить все дела со старыми!!!*/
        if not v-exchange-file then do:
           input stream PrnLibStream close.
            p-view-log = yes.
&scop my-message "!!!Отсутствует признак файла обмена (1CClientBankExchange)"
            {&display-message}.
            return.
        end.
        run proc-end-gen in this-procedure no-error .
        if error-status:error  then do:
          v-crit-err = yes.
          if (return-value = '':U or
          return-value = 'error')
          then do:
            input stream PrnLibStream close.
            p-view-log = yes.
  &scop my-message substitute("!!!Ошибки при чтении файла:&1&2 &3&1Импорт прерван&1"  ~
                            , ~{&new-line~}                                                                      ~
                            , error-status:get-message(1)                                                        ~
                            , return-value                                   )
              {&display-message}.
            return.
          end.
          else do:
            p-view-log = yes.
  &scop my-message return-value
              {&display-message}.
          end.
        end.
        if return-value = 'error' then do:
          input stream PrnLibStream close.
          return.
        end.
        run proc-00-doc in this-procedure no-error .
        if return-value = 'error' then do:
          input stream PrnLibStream close.
          return.
        end.
      end. /*when 00*/
      when 'РасчСчет' then  do:  /* Заголовок данных по выписке */
        assign
        gbl-schet = n-entry[2].
      end.
      when 'СекцияРасчСчет' then  do:  /* Заголовок данных по выписке */
        /*если мы здесь то надо уладить все дела со старыми документами!!!*/
        if not v-exchange-file then do:
           input stream PrnLibStream close.
            p-view-log = yes.
&scop my-message "!!!Отсутствует признак файла обмена (1CClientBankExchange)"
            {&display-message}.
            return.
        end.
        run proc-end-gen in this-procedure no-error .
        if error-status:error  then do:
          v-crit-err = yes.
          if (return-value = '':U or
          return-value = 'error')
          then do:
            input stream PrnLibStream close.
            p-view-log = yes.
  &scop my-message substitute("!!!Ошибки при чтении файла:&1&2 &3&1Импорт прерван&1"  ~
                            , ~{&new-line~}                                                                      ~
                            , error-status:get-message(1)                                                        ~
                            , return-value                                   )
              {&display-message}.
            return.
          end.
          else do:
            p-view-log = yes.
  &scop my-message return-value
              {&display-message}.
          end.
        end.
        if return-value = 'error' then do:
          input stream PrnLibStream close.
          return.
        end.
        run proc-00-statement in this-procedure no-error .
        if return-value = 'error' then do:
          input stream PrnLibStream close.
          return.
        end.
      end. /*when 01*/
      when 'КонецРасчСчет' then  do:  /* Конец данных по выписке */
        /*надо уладить все дела со принятой выпиской!!!*/
        run proc-end-statement in this-procedure no-error .
        if error-status:error  then do:
          v-crit-err = yes.
          if (return-value = '':U or
          return-value = 'error')
          then do:
            input stream PrnLibStream close.
            p-view-log = yes.
  &scop my-message substitute("!!!Ошибки при чтении файла:&1&2 &3&1Импорт прерван&1"  ~
                            , ~{&new-line~}                                                                      ~
                            , error-status:get-message(1)                                                        ~
                            , return-value                                   )
              {&display-message}.
            return.
          end.
          else do:
            p-view-log = yes.
  &scop my-message return-value
              {&display-message}.
          end.
        end.
        if return-value = 'error' then do:
          input stream PrnLibStream close.
          return.
        end.
      end.
      otherwise do:
        find first temp_hfields where
                    temp_hfields.label_ = (n-entry[1] + '=':U) no-error.
          if available temp_hfields then do:
            if (not exist and temp_hfields.subject = {&table_fin-doc})
            or (not exist-statement and temp_hfields.subject = {&table_fin-statement})
            then do:
              if in-doc > 0
              and in-statement = 0
              then do:
                assign
                TEMP_hfields.value_ = n-entry[2]
                temp_hfields.readed = yes
                .
              end.
              if in-statement > 0
              and in-doc = 0
              then do:
                assign
                TEMP_hfields.value_ = n-entry[2]
                temp_hfields.readed = yes
                .
              end.
              if in-doc = 0
              and in-statement = 0 then do:
                /*тэги документа вне секции документ*/
                /*надо выругаться*/
                assign
                in-doc = 0
                in-statement = 0
                exist = yes
                exist-statement = yes
                p-view-log = yes.
&scop my-message substitute("!!!Поле &1 вне секции документа или секции выписки пл счету&2Файл &3 строка &4"  ~
                          , temp_hfields.label_                                     ~
                          , ~{&new-line~}                                           ~
                          , p-file-name                                             ~
                          , var-file-line-num                     )
                {&display-message}.
                input stream PrnLibStream close.
                return.
              end.
            end. /*if not exist and not exist-statement*/
          end.
          else do:
            /*неизвестное нам поле!!!*/
            /*надо выругаться*/
            if in-doc > 0 then do:
              p-view-log = yes.
  &scop my-message substitute("!!!Неизвестное поле <&1> при импорте документа&2Файл &3"  ~
                            , n-entry[1]                                              ~
                            , ~{&new-line~}                                           ~
                            , p-file-name                                             ~
                            , var-file-line-num)
              {&display-message}.
            end.
            if in-statement > 0 then do:
              p-view-log = yes.
  &scop my-message substitute("!!!Неизвестное поле <&1> при импорте выписки&2Файл &3"  ~
                            , n-entry[1]                                              ~
                            , ~{&new-line~}                                           ~
                            , p-file-name                                             ~
                            , var-file-line-num)
              {&display-message}.
            end.
          end.
        end. /*otherwise*/
      END CASE .
    END.
  END .
  DO TRANSACTION:
    run proc-end-gen in this-procedure no-error .
    if error-status:error  then do:
      v-crit-err = yes.
      if (return-value = '':U or
      return-value = 'error')
      then do:
        input stream PrnLibStream close.
        p-view-log = yes.
&scop my-message substitute("!!!Ошибки при чтении файла:&1&2 &3&1Импорт прерван&1"  ~
                        , ~{&new-line~}                                                                      ~
                        , error-status:get-message(1)                                                        ~
                        , return-value                                   )
          {&display-message}.
        return.
      end.
      else do:
        p-view-log = yes.
&scop my-message return-value
          {&display-message}.
      end.
    end.
    if return-value = 'error' then do:
      input stream PrnLibStream close.
      return.
    end.
  END.
  assign
  error-status:error = false.
  input stream PrnLibStream close.
end.
run show-counter in p-log-handle .
run write-counter in p-log-handle ('':U).

if not v-crit-err then do:
  run proc-write-out in this-procedure no-error.
  if error-status:error then do:
    run hide-counter in p-log-handle.
              p-view-log = yes.
  &scop my-message substitute("!!!Ошибка при обработке импортируемых документов&1&2 &3&1&4&1"  ~
                            , ~{&new-line~}                                           ~
                            , error-status:get-message(1)                             ~
                            , return-value                                            ~
                            , 'все импортированные изменения НЕ будут сохранены'               )
              {&display-message}.
    assign
    p-processed = 0
    p-created = 0
    .

  end.
end.

procedure proc-00-doc:

  do
  on error undo, return error
  :
    assign
    gbl-type = n-entry[2]
    p-count = p-count + 1
    .
    if can-do(accept-types,  gbl-type ) then do:
      /*очистим поля*/
      for each temp_hfields where temp_hfields.subject = {&table_fin-doc}:
        assign
        temp_hfields.value_ = ?
        temp_hfields.imported = no
        temp_hfields.readed = no
        .
      end.
      find first temp_hfields where
                temp_hfields.subject = {&table_fin-doc}
            and temp_hfields.label_ = (n-entry[1] + '=':U).
      assign
      TEMP_hfields.value_ = n-entry[2]
      TEMP_hfields.readed = yes
      .
      assign
      in-doc = var-file-line-num
      exist = no
      .

    end. /*если 1мы это принимаем*/
    else do:
      /*какие-то неизвестные нам виды типы документов*/
      assign
      exist = yes
      . /* Предпологаем что уже есть в базе */
      return.
    end.
  end.

end procedure. /* proc-00-doc */

procedure proc-00-statement:
define variable gbl-r-schet as character no-undo .
  do
  on error undo, return error
  :
    assign
    gbl-r-schet = n-entry[2]
    p-count-statement = p-count-statement + 1
    .
    if p-rs-hsch = 2 then do:
      find first temp_hfin-schet no-lock where
              temp_hfin-schet.host-code = p-host-code
          AND temp_hfin-schet.r-schet = gbl-r-schet no-error .
      if not available temp_hfin-schet then do:
        assign
        exist-statement = yes.
        return.
      end.
    end.
    else do :
      /*очистим поля*/
      for each temp_hfields where temp_hfields.subject = {&table_fin-statement}:
        assign
        temp_hfields.value_ = ?
        temp_hfields.imported = no
        temp_hfields.readed = no
        .
      end.
      find first temp_hfields where
                temp_hfields.subject = {&table_fin-statement}
            and temp_hfields.label_ = ('РасчСчет' + '=':U)  .
      assign
      TEMP_hfields.value_ = gbl-schet
      TEMP_hfields.readed = yes
      .
      find first temp_hfields where
                temp_hfields.subject = {&table_fin-statement}
            and temp_hfields.label_ = ('ДатаСоздания' + '=':U) .
      assign
      TEMP_hfields.value_ = v-bank-date-chr
      TEMP_hfields.readed = yes
      .
      find first temp_hfields where
                temp_hfields.subject = {&table_fin-statement}
            and temp_hfields.label_ = (n-entry[1] + '=':U).
      assign
      TEMP_hfields.value_ = n-entry[2]
      TEMP_hfields.readed = yes
      .
      assign
      in-statement = var-file-line-num
      exist-statement = no
      .
    end. /*если мы это принимаем*/
  end.

end procedure. /* proc-00-statement */



procedure proc-end-gen :

  do
  on error undo, return error
  :
    if in-doc > 0 then do:
      run proc-end-doc in this-procedure .
    end.
    if in-statement > 0 then do:
      run proc-end-statement in this-procedure .
    end.
  end.

end procedure. /* proc-end-gen */


procedure proc-end-doc :
define variable h-buffer as handle no-undo .
define variable h-field as handle no-undo .
define variable ii as integer no-undo .
define variable v-dop as character no-undo .
define variable v-dop2 as character no-undo .
define variable v-inn as integer no-undo .
define variable v-skip as logical no-undo .
define variable v-mess as character no-undo .
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_temp_hfields for temp_hfields.
define buffer find_first-fin-bank for ub.fin-bank.
define buffer receiver-firm for ub.firm.
define buffer receiver-person for ub.person.
define buffer payer-firm for ub.firm.
define buffer payer-person for ub.person.



  _main:
  do
  on error undo _main, return error
  :
     /*теперь пишем в tt-1s-fin-doc*/
    if in-doc = 0 or exist then return.
    assign
    in-doc = 0
    exist  = yes
    .
    find first temp_hfields no-lock where
              temp_hfields.subject = {&table_fin-doc}
          and temp_Hfields.name_ = 'fact-date'
          AND temp_Hfields.readed = yes
              no-error.
    if not available temp_hfields then do:
&scop my-message substitute("!!!Отсутствует обязательный реквизит платежа <ДатаСписано>(<ДатаПоступило>)&1Файл &2 строка НАЧАЛА ДОКУМЕНТА &3"  ~
                           , ~{&new-line~}                                           ~
                           , p-file-name                                             ~
                           , var-file-line-num                                        )
                  {&display-message}.
           p-view-log = yes.
           assign
           in-doc = 0
           exist = yes.
           return "error".
     end.
     create tt-1s-fin-doc.
     assign
     tt-1s-fin-doc.status_ = {&fin-fact}.
     assign
     tt-1s-fin-doc.fin-doc-code = - (v-seq + 1)
     v-seq = v-seq + 1
     .
     assign
     h-buffer = buffer tt-1s-fin-doc:handle
     .
     do ii = 1 to h-buffer:num-fields:
       assign
       h-field = h-buffer:buffer-field(ii)
       .
       find first temp_hfields no-lock where
                 temp_hfields.subject = {&table_fin-doc}
             and temp_hfields.name_ = h-field:name
             AND temp_hfields.readed = yes  no-error.
       if available temp_hfields then do:
         CASE h-field:data-type:
           when 'date' then do:
              assign
              h-field:buffer-value = date(temp_hfields.value_)
              no-error .
           end.
           when 'integer' then do:
              assign
              h-field:buffer-value = integer(temp_hfields.value_)
              no-error .
           end.
          when 'decimal' then do:
              assign
              h-field:buffer-value = decimal(temp_hfields.value_)
              no-error .
           end.
           when 'logical' then do:
              assign
              h-field:buffer-value = logical(temp_hfields.value_)
              no-error .
           end.
           when 'character' then do:
             assign
             h-field:buffer-value = temp_hfields.value_
             .
           end.
           otherwise do:
             error-status:error = no.
           end.
         END CASE.
         if error-status:error then do:
&scop my-message substitute("!!!Неверное значение поля &1: &5&2Файл &3 строка НАЧАЛА ДОКУМЕНТА &4"  ~
                           , temp_hfields.label_                                     ~
                           , ~{&new-line~}                                           ~
                           , p-file-name                                             ~
                           , var-file-line-num                                       ~
                           , temp_hfields.value_                      )

                  {&display-message}.
           p-view-log = yes.
           delete tt-1s-fin-doc.
           assign
           in-doc = 0
           exist = yes.
           return "error".
         end.
         assign
         temp_Hfields.imported = yes.
      end. /*if available temp_hfields then do:*/
    end. /*do ii*/
     /*теперь переприсвоим составные и сложные поля*/
&scop assign-imported find first buf_temp_hfields where buf_temp_hfields.subject = ~{&table_fin-doc~}      ~
                                                    and buf_temp_hfields.name_ = ~{&field-name~} no-error. ~
                      if available buf_temp_hfields then do:                                            ~
                        assign                                                                     ~
                        buf_temp_hfields.imported = yes.                                               ~
                      end
    for each temp_hfields where
              temp_hfields.imported = no
          AND temp_hfields.readed = yes
          and temp_hfields.subject = {&table_fin-doc}
          :
       CASE temp_hfields.name_ :
        when 'fin-ext-doc-type/' then do:
          CASE temp_hfields.value_ :
            when 'Платежное поручение' then do:
              for each find_first-fin-bank where
                      find_first-fin-bank.host-code = p-host-code
                  AND find_first-fin-bank.bik       = p-bik
                  AND find_first-fin-bank.status_   = {&current-status},
                  first buf_fin-schet no-lock where
                        buf_fin-schet.host-code = find_first-fin-bank.host-code
                    and buf_fin-schet.code-bank = find_first-fin-bank.code-bank
                    AND buf_fin-schet.r-schet =  tt-1s-fin-doc.payer-r-schet
                    and buf_fin-schet.status_ = {&current-status}
                    and buf_fin-schet.cli-type = {&cmp}
                    and buf_fin-schet.cli-code = find_first-fin-bank.host-code:
                LEAVE.
              end.
              if available buf_fin-schet then do:
                assign
                tt-1s-fin-doc.fin-ext-doc-type = {&FDEDT_Expense_Cashless}
                tt-1s-fin-doc.fin-doc-type = {&expense-Cashless}
                tt-1s-fin-doc.host-code    = p-host-code
                tt-1s-fin-doc.payer-type = {&cmp}
                tt-1s-fin-doc.payer-code = buf_fin-schet.cli-code
                tt-1s-fin-doc.payer-code-schet = buf_fin-schet.code-schet
                tt-1s-fin-doc.curr-code = buf_fin-schet.curr-code
                .
&scop field-name 'payer-type'
                {&assign-imported}.
&scop field-name 'payer-code'
                {&assign-imported}.
&scop field-name 'payer-code-bank'
                {&assign-imported}.
&scop field-name 'payer-code-schet'
                {&assign-imported}.
&scop field-name 'curr-code'
                {&assign-imported}.

                /*проверим что мы хотим закачивать по данному расчетному счета*/
                if p-rs-hsch = 2 then do:
                  find first temp_hfin-schet no-lock where
                          temp_hfin-schet.host-code = tt-1s-fin-doc.host-code
                      AND temp_hfin-schet.code-schet = tt-1s-fin-doc.payer-code-schet no-error .
                  if not available temp_hfin-schet then do:
                    assign
                    v-skip = yes.
                  end.
                end.
                /*заполним те поля получателя которых нет в импорте*/
                if not v-skip then do:
                  find first buf_fin-bank no-lock where
                            buf_Fin-bank.host-code = tt-1s-fin-doc.host-code
                        AND buf_Fin-bank.bik = tt-1s-fin-doc.receiver-bik
                        AND buf_Fin-bank.cor-acc = tt-1s-fin-doc.receiver-c-schet
                        and buf_fin-bank.status_ = {&current-status} no-error.
                  if not available buf_fin-bank then do:
                    v-mess = substitute("!!!Не найден в БД (или удален) банк ПОЛУЧАТЕЛЯ&1 - БИК &2&1Коррсчет &3"
                                       , {&new-line}
                                       , tt-1s-fin-doc.receiver-bik
                                       , tt-1s-fin-doc.receiver-c-schet
                                       ).
                    undo _main, return error v-mess.
                  end.
                  for each buf_fin-schet no-lock where
                          buf_fin-schet.host-code = tt-1s-fin-doc.host-code
                      AND buf_fin-schet.code-bank =  buf_fin-bank.code-bank
                      AND buf_fin-schet.r-schet =  tt-1s-fin-doc.receiver-r-schet
                      AND buf_fin-schet.status_ = {&current-status}:
                    if buf_fin-schet.cli-type = {&cmp} then do:
                      find first receiver-firm no-lock where
                              receiver-firm.firm-code = buf_fin-schet.cli-code
                          and receiver-firm.inn = tt-1s-fin-doc.receiver-inn no-error.
                      if available receiver-firm then leave.
                    end.
                    if buf_fin-schet.cli-type = {&prs} then do:
                      find first receiver-person no-lock where
                             receiver-person.psn-code = buf_fin-schet.cli-code
                          and receiver-person.inn = tt-1s-fin-doc.receiver-inn no-error.
                      if available receiver-person then leave.
                    end.
                  end.
                  if not available buf_fin-schet then do:
                    assign
                    v-mess =  substitute("!!!Не найден в БД (или удален) счет ПОЛУЧАТЕЛЯ&1 банк с БИК &2 (вн код &3),&1р/с &4, {&abbr_inn_allshift} &5 "
                                       , {&new-line}
                                       , tt-1s-fin-doc.receiver-bik
                                       , buf_fin-bank.code-bank
                                       , tt-1s-fin-doc.receiver-r-schet
                                       , tt-1s-fin-doc.receiver-inn
                                       ).
                    undo _main, return error v-mess.
                  end.
                  assign
                  tt-1s-fin-doc.receiver-code-schet = buf_fin-schet.code-schet
                  tt-1s-fin-doc.receiver-type = buf_fin-schet.cli-type
                  tt-1s-fin-doc.receiver-code = buf_fin-schet.cli-code
                  .
&scop field-name 'receiver-code-schet'
                {&assign-imported}.
&scop field-name 'receiver-code'
                {&assign-imported}.
&scop field-name 'receiver-type'
                {&assign-imported}.

                end. /*if not v-skip then do:*/
              end.
              else do:
                for each find_first-fin-bank where
                        find_first-fin-bank.host-code = p-host-code
                    AND find_first-fin-bank.bik       = p-bik
                    AND find_first-fin-bank.status_   = {&current-status},
                    first buf_fin-schet no-lock where
                          buf_fin-schet.host-code = find_first-fin-bank.host-code
                      and buf_fin-schet.code-bank = find_first-fin-bank.code-bank
                      AND buf_fin-schet.r-schet =  tt-1s-fin-doc.receiver-r-schet
                      and buf_fin-schet.status_ = {&current-status}
                      and buf_fin-schet.cli-type = {&cmp}
                      and buf_fin-schet.cli-code = find_first-fin-bank.host-code:
                  LEAVE.
                end.
                if available buf_fin-schet then do:
                  assign
                  tt-1s-fin-doc.fin-ext-doc-type = {&FDEDT_Income_Cashless}
                  tt-1s-fin-doc.fin-doc-type = {&income-Cashless}
                  tt-1s-fin-doc.host-code    = p-host-code
                  tt-1s-fin-doc.receiver-type = {&cmp}
                  tt-1s-fin-doc.receiver-code = buf_fin-schet.cli-code
                  tt-1s-fin-doc.receiver-code-schet = buf_fin-schet.code-schet
                  tt-1s-fin-doc.curr-code = buf_fin-schet.curr-code
                  .
&scop field-name 'receiver-type'
                {&assign-imported}.
&scop field-name 'receiver-code'
                {&assign-imported}.
&scop field-name 'receiver-code-schet'
                {&assign-imported}.
&scop field-name 'curr-code'
                {&assign-imported}.
                end.
                else do:
                /*
                Это вообще не наш платеж!!!!!
                */
                  assign
                  v-seq = v-seq + 1
                  v-mess = substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +
                              'счета ПЛАТЕЛЬЩИКА И ПОЛУЧАТЕЛЯ отсутствуют в БД'
                            , tt-1s-fin-doc.prn-doc-code
                            , p-host-code
                            , {&new-line}
                            , tt-1s-fin-doc.payer-name
                            , tt-1s-fin-doc.receiver-name                                  ).
                  assign
                  v-crit-err = yes.
                  undo _main, return error v-mess.
                end.
                /*проверим что мы хотим закачивать по данному расчетному счета*/
                if p-rs-hsch = 2 then do:
                  find first temp_hfin-schet no-lock where
                          temp_hfin-schet.host-code = tt-1s-fin-doc.host-code
                      AND temp_hfin-schet.code-schet = tt-1s-fin-doc.receiver-code-schet no-error .
                  if not available temp_hfin-schet then do:
                    assign
                    v-skip = yes.
                  end.
                end.
                if not v-skip then do:
                  /*заполним те поля получателя которых нет в импорте*/
                  find first buf_fin-bank no-lock where
                            buf_Fin-bank.host-code = tt-1s-fin-doc.host-code
                        AND buf_Fin-bank.bik = tt-1s-fin-doc.payer-bik
                        AND buf_fin-bank.status_ = {&current-status}
                        AND buf_fin-bank.cor-acc = tt-1s-fin-doc.payer-c-schet  no-error.
                  if not available buf_fin-bank then do:
                    v-mess = substitute("!!!Не найден (или удален) в БД банк ПЛАТЕЛЬЩИКА&1 - БИК &2&1Коррсчет &3"
                                       , {&new-line}
                                       , tt-1s-fin-doc.payer-bik
                                       , tt-1s-fin-doc.payer-c-schet
                                       ).
                    undo _main, return error v-mess.
                  end.
                  for each buf_fin-schet no-lock where
                          buf_fin-schet.host-code = tt-1s-fin-doc.host-code
                      AND buf_fin-schet.code-bank =  buf_fin-bank.code-bank
                      AND buf_fin-schet.r-schet =  tt-1s-fin-doc.payer-r-schet
                      AND buf_fin-schet.status_ = {&current-status} :
                    if buf_fin-schet.cli-type = {&cmp} then do:
                      find first payer-firm no-lock where
                              payer-firm.firm-code = buf_fin-schet.cli-code
                          and payer-firm.inn = tt-1s-fin-doc.payer-inn no-error.
                      if available payer-firm then leave.
                    end.
                    if buf_fin-schet.cli-type = {&prs} then do:
                      find first payer-person no-lock where
                             payer-person.psn-code = buf_fin-schet.cli-code
                          and payer-person.inn = tt-1s-fin-doc.payer-inn no-error.
                      if available payer-person then leave.
                    end.
                  end.
                  if not available buf_fin-schet then do:
                    assign
                    v-mess =  substitute("!!!Не найден в БД (или удален) счет ПЛАТЕЛЬЩИКА&1 банк с БИК &2 (вн код &3),&1р/с &4, {&abbr_inn_allshift} &5 "
                                       , {&new-line}
                                       , tt-1s-fin-doc.payer-bik
                                       , buf_fin-bank.code-bank
                                       , tt-1s-fin-doc.payer-r-schet
                                       , tt-1s-fin-doc.payer-inn
                                       ).

                    undo _main, return error v-mess.
                  end.
                  assign
                  tt-1s-fin-doc.payer-code-schet = buf_fin-schet.code-schet
                  tt-1s-fin-doc.payer-type = buf_fin-schet.cli-type
                  tt-1s-fin-doc.payer-code = buf_fin-schet.cli-code
                  .
&scop field-name 'payer-code-schet'
                {&assign-imported}.
&scop field-name 'payer-code'
                {&assign-imported}.
&scop field-name 'payer-type'
                {&assign-imported}.

                end. /*if not v-skip then do:*/
              end.
            end.
          END CASE.
          if v-skip = yes then do:
            v-mess = substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +
                              'счет ПЛАТЕЛЬЩИКА(ПОЛУЧАТЕЛЯ) НЕ ВЫБРАН для импорта - пропускаем'
                            , tt-1s-fin-doc.prn-doc-code
                            , p-host-code
                            , {&new-line}
                            , tt-1s-fin-doc.payer-name
                            , tt-1s-fin-doc.receiver-name                                  ).
              delete tt-1s-fin-doc.
            return.
          end.
&scop field-name 'fin-ext-doc-type/'
                {&assign-imported}.
&scop field-name 'fin-doc-type'
                {&assign-imported}.
&scop field-name 'host-code'
                {&assign-imported}.
        end.
        when 'payer-inn/payer-name' then do:
          if tt-1s-fin-doc.payer-inn = ? then do:
            /*разберем строку*/
            assign
            v-inn = index(temp_hfields.value_, ' {&abbr_inn_allshift} ')
            .
            if v-inn = 0 then do:
              assign
              v-inn = index(temp_hfields.value_, '{&abbr_inn_allshift} ')
              .
            end.
            if v-inn <> 0 then do:
              assign
              v-dop = substring(temp_hfields.value_, v-inn + 1).
              _ii:
              do ii = 1 to num-entries(v-dop, {&space-char} ):
                v-dop2 = substring(v-dop, length(entry(ii, v-dop, {&space-char} ))  + 2).
                if entry(ii, v-dop, {&space-char} ) <> '':U then do:
                  assign
                  tt-1s-fin-doc.payer-inn = entry(ii, v-dop, {&space-char} )
                  tt-1s-fin-doc.payer-name = (if tt-1s-fin-doc.payer-name = '':U then trim(v-dop2) else tt-1s-fin-doc.payer-name)
                  .
                  leave _ii.
                end.
              end. /*do-ii*/
            end. /*if v-inn <> 0 then do:*/
          end.
        end.
        when 'receiver-inn/receiver-name' then do:
          if tt-1s-fin-doc.receiver-inn = ? then do:
            /*разберем строку*/
            assign
            v-inn = index(temp_hfields.value_, ' {&abbr_inn_allshift} ')
            .
            if v-inn = 0 then do:
              assign
              v-inn = index(temp_hfields.value_, '{&abbr_inn_allshift} ')
              .
            end.
            if v-inn <> 0 then do:
              assign
              v-dop = substring(temp_hfields.value_, v-inn + 1).
              _ii:
              do ii = 1 to num-entries(v-dop, {&space-char} ):
                v-dop2 = substring(v-dop, length(entry(ii, v-dop, {&space-char} ))  + 2).
                if entry(ii, v-dop, {&space-char} ) <> '':U then do:
                  assign
                  tt-1s-fin-doc.receiver-inn = entry(ii, v-dop, {&space-char} )
                  tt-1s-fin-doc.receiver-name = (if tt-1s-fin-doc.receiver-name = '':U then trim(v-dop2) else tt-1s-fin-doc.receiver-name)
                  .
                  leave _ii.
                end.
              end. /*do-ii*/
            end. /*if v-inn <> 0 then do:*/
          end.
        end. /* when 'reciever-inn/receiver-name' then do:*/
        when 'naznach-plat/' then do:
          tt-1s-fin-doc.naznach-plat = temp_hfields.value_
          .
&scop field-name 'naznach-plat/'
                {&assign-imported}.
        end.
        otherwise do:
          error-status:error = no.
        end.
      END CASE.
    end. /*for each temp_hfields where*/
    /*посчитаем сколько */
    run show-counter in p-log-handle .
    run write-counter in p-log-handle (substitute("Импорт БИК &1 Фирма &2: считано документов &3"
                                    , p-bik
                                    , p-host-code
                                    , p-count)).

    assign
    in-doc = 0
    exist  = yes
    .
  end. /*doe*/

end procedure. /* proc-end */

procedure proc-end-statement:
define variable h-buffer as handle no-undo .
define variable h-field as handle no-undo .
define variable ii as integer no-undo .
define variable v-skip as logical no-undo .
define variable v-mess as character no-undo .
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_clients for ub.clients.
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_temp_hfields for temp_hfields.
define buffer find_first-fin-bank for ub.fin-bank.
  _main:
  do
  on error undo _main, return error
  :
     /*теперь пишем в tt-1s-fin-doc*/
    if in-statement = 0
    or exist-statement then return.
    assign
    in-statement = 0
    exist-statement  = yes
    .
    find first temp_hfields no-lock where
              temp_hfields.subject = {&table_fin-statement}
          and temp_Hfields.name_ = 'start-date'
          AND temp_Hfields.readed = yes
              no-error.
    if not available temp_hfields then do:
&scop my-message substitute("!!!Отсутствует обязательный реквизит выписки <ДатаНачала>&1Файл &2 строка НАЧАЛА ВЫПИСКИ &3"  ~
                           , ~{&new-line~}                                           ~
                           , p-file-name                                             ~
                           , var-file-line-num                                        )
                  {&display-message}.
           p-view-log = yes.
           assign
           in-doc = 0
           exist = yes.
           return "error".
     end.
    find first temp_hfields no-lock where
              temp_hfields.subject = {&table_fin-statement}
          and temp_Hfields.name_ = 'end-date'
          AND temp_Hfields.readed = yes
              no-error.
    if not available temp_hfields then do:
&scop my-message substitute("!!!Отсутствует обязательный реквизит выписки <ДатаКонца>&1Файл &2 строка НАЧАЛА ВЫПИСКИ &3"  ~
                           , ~{&new-line~}                                           ~
                           , p-file-name                                             ~
                           , var-file-line-num                                        )
                  {&display-message}.
           p-view-log = yes.
           assign
           in-doc = 0
           exist = yes.
           return "error".
     end.
     create tt-1s-fin-statement.
     assign
     tt-1s-fin-statement.sttm-code = v-seq-statement + 1
     v-seq-statement = v-seq-statement + 1
     .
     assign
     h-buffer = buffer tt-1s-fin-statement:handle
     .
     do ii = 1 to h-buffer:num-fields:
       assign
       h-field = h-buffer:buffer-field(ii)
       .
       find first temp_hfields no-lock where
                 temp_hfields.subject = {&table_fin-statement}
             and temp_hfields.name_ = h-field:name
             AND temp_hfields.readed = yes  no-error.
       if available temp_hfields then do:
         CASE h-field:data-type:
           when 'date' then do:
              assign
              h-field:buffer-value = date(temp_hfields.value_)
              no-error .
           end.
           when 'integer' then do:
              assign
              h-field:buffer-value = integer(temp_hfields.value_)
              no-error .
           end.
          when 'decimal' then do:
              assign
              h-field:buffer-value = decimal(temp_hfields.value_)
              no-error .
           end.
           when 'logical' then do:
              assign
              h-field:buffer-value = logical(temp_hfields.value_)
              no-error .
           end.
           when 'character' then do:
             assign
             h-field:buffer-value = temp_hfields.value_
             .
           end.
           otherwise do:
             error-status:error = no.
           end.
         END CASE.
         if error-status:error then do:
&scop my-message substitute("!!!Неверное значение поля &1: &5&2Файл &3 строка НАЧАЛА ВЫПИСКИ &4"  ~
                           , temp_hfields.label_                                     ~
                           , ~{&new-line~}                                           ~
                           , p-file-name                                             ~
                           , var-file-line-num                                       ~
                           , temp_hfields.value_                      )

                  {&display-message}.
           p-view-log = yes.
           delete tt-1s-fin-statement.
           assign
           in-doc = 0
           exist = yes.
           return "error".
         end.
         assign
         temp_Hfields.imported = yes.
      end. /*if available temp_hfields then do:*/
    end. /*do ii*/
     /*теперь переприсвоим составные и сложные поля*/
&scop assign-imported find first buf_temp_hfields where  buf_temp_hfields.subject = ~{&table_fin-statement~} ~
                                                     and buf_temp_hfields.name_ = ~{&field-name~} no-error. ~
                      if available buf_temp_hfields then do:                                            ~
                        assign                                                                     ~
                        buf_temp_hfields.imported = yes.                                               ~
                      end
    for each temp_hfields where
              temp_hfields.subject = {&table_fin-statement}
          and temp_hfields.imported = no
          AND temp_hfields.readed = yes :
       CASE temp_hfields.name_ :
        when 'fins-ext-doc-type/' then do:
          for each find_first-fin-bank where
                  find_first-fin-bank.host-code = p-host-code
              AND find_first-fin-bank.bik       = p-bik
              AND find_first-fin-bank.status_   = {&current-status},
              first buf_fin-schet no-lock where
                    buf_fin-schet.host-code = find_first-fin-bank.host-code
                and buf_fin-schet.code-bank = find_first-fin-bank.code-bank
                AND buf_fin-schet.r-schet =  tt-1s-fin-statement.r-schet
                and buf_fin-schet.status_ = {&current-status}
                and buf_fin-schet.cli-type = {&cmp}
                and buf_fin-schet.cli-code = find_first-fin-bank.host-code:
            LEAVE.
          end.
          if available buf_fin-schet then do:
            find first buf_clients no-lock where
                      buf_clients.obj-type = {&cmp}
                 and  buf_clients.obj-code = p-host-code.
            assign
            tt-1s-fin-statement.fins-ext-doc-type = {&FSEDT_standard-sttm}
            tt-1s-fin-statement.fins-doc-type = {&standard-sttm}
            tt-1s-fin-statement.host-code    = p-host-code
            tt-1s-fin-statement.code-schet = buf_fin-schet.code-schet
            tt-1s-fin-statement.c-schet = buf_fin-schet.c-schet
            tt-1s-fin-statement.cl-bank = {&cl-bank-1s}
            tt-1s-fin-statement.code-bank = buf_fin-schet.code-bank
            tt-1s-fin-statement.curr-code = buf_fin-schet.curr-code
            tt-1s-fin-statement.bank-name = find_first-fin-bank.bank-name
            tt-1s-fin-statement.bank-city = find_first-fin-bank.bank-city
            tt-1s-fin-statement.bik = find_first-fin-bank.bik
            tt-1s-fin-statement.status_ = {&fin-new}
            tt-1s-fin-statement.cli-name = buf_clients.obj-name
            .
&scop field-name 'start-date'
            {&assign-imported}.
&scop field-name 'end-date'
            {&assign-imported}.
&scop field-name 'start-sum-doc'
            {&assign-imported}.
&scop field-name 'end-sum-doc'
            {&assign-imported}.
&scop field-name 'in-sum-doc'
            {&assign-imported}.
&scop field-name 'out-sum-doc'
            {&assign-imported}.
&scop field-name 'r-schet'
            {&assign-imported}.
&scop field-name 'code-schet'
            {&assign-imported}.
&scop field-name 'cli-name'
            {&assign-imported}.
&scop field-name 'bank-name'
            {&assign-imported}.
&scop field-name 'bank-city'
            {&assign-imported}.
&scop field-name 'code-bank'
            {&assign-imported}.
&scop field-name 'cl-bank'
            {&assign-imported}.
&scop field-name 'bik'
            {&assign-imported}.



            /*проверим что мы хотим закачивать по данному расчетному счета*/
            if p-rs-hsch = 2 then do:
              find first temp_hfin-schet no-lock where
                      temp_hfin-schet.host-code = tt-1s-fin-statement.host-code
                  AND temp_hfin-schet.code-schet = tt-1s-fin-statement.code-schet no-error .
              if not available temp_hfin-schet then do:
                assign
                v-skip = yes.
              end.
            end.
            /*заполним те поля получателя которых нет в импорте*/
            if not v-skip then do:
              find first buf_Clients no-lock where
                        buf_clients.obj-type = {&cmp}
                    and buf_clients.obj-code = p-host-code no-error.
              if not available buf_clients then do:
                v-mess = substitute("!!!Не найден в БД ДЕРЖАТЕЛЬ СЧЕТА &1&2 - БИК &3&1Коррсчет &4"
                                    , tt-1s-fin-statement.r-schet
                                    , {&new-line}
                                    , tt-1s-fin-statement.bik
                                    , tt-1s-fin-statement.c-schet
                                    ).
                undo _main, return error v-mess.
              end.
              assign
              tt-1s-fin-statement.cli-name = buf_clients.obj-name
              .
            end. /*if not v-skip then do:*/
          end.
          else do:
          /*
          Это вообще не наша выписка !!!!!
          */
            assign
            v-seq-statement = v-seq-statement + 1
            v-mess = substitute("!!!Выписка &1 фирма &2&3Счет &4 БИК &5:&3"  +
                        'счет для ВЫПИСКИ отсутствует в БД'
                      , cbnki-period-to-String(tt-1s-fin-statement.start-date, tt-1s-fin-statement.end-date)
                      , p-host-code
                      , {&new-line}
                      , tt-1s-fin-statement.r-schet
                      , tt-1s-fin-statement.bik       ).
            assign
            v-crit-err = yes.
            undo _main, return error v-mess.
          end.
          if v-skip = yes then do:
            v-mess = substitute("!!!Выписка &1 фирма &2&3Счет &4 БИК &5"  +
                              'счет НЕ ВЫБРАН для импорта - пропускаем'
                            , cbnki-period-to-String(tt-1s-fin-statement.start-date, tt-1s-fin-statement.end-date)
                            , p-host-code
                            , {&new-line}
                            , tt-1s-fin-statement.r-schet
                            , tt-1s-fin-statement.bik                                  ).
              delete tt-1s-fin-statement.
            return.
          end.
&scop field-name 'fins-ext-doc-type/'
                {&assign-imported}.
&scop field-name 'fins-doc-type'
                {&assign-imported}.
&scop field-name 'host-code'
                {&assign-imported}.
        end.
        otherwise do:
          error-status:error = no.
        end.
      END CASE.
    end. /*for each temp_hfields where*/
    /*посчитаем сколько */
    run show-counter in p-log-handle .
    run write-counter in p-log-handle (substitute("Импорт БИК &1 Фирма &2: считано выписок &3"
                                    , p-bik
                                    , p-host-code
                                    , p-count-statement)).

    assign
    in-statement = 0
    exist-statement  = yes
    .
  end. /*doe*/

end procedure. /* proc-end-statement */



procedure proc-write-out :
define variable v-do as logical no-undo .
define variable h-buffer as handle no-undo .
define variable h-field as handle no-undo .
define variable h-1s-buffer as handle no-undo .
define variable h-1s-field as handle no-undo .
define variable v-date like ub.fin-doc.fact-date no-undo .
define variable v-result as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-create as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-do-bank as logical no-undo .
define variable v-do-fact as logical no-undo .
define buffer buf_fin-doc for ub.fin-doc.
define buffer buf_fin-statement for ub.fin-statement.

  _main:
  do  transaction
  on error undo, return error return-value
  :
    _tt-1s-fin-doc:
    for each tt-1s-fin-doc
    on error undo _main, return error
    :
      assign
      v-do = no
      v-create = no
      .
      find first buf_fin-doc where
                buf_fin-doc.prn-doc-code = tt-1s-fin-doc.prn-doc-code
            AND  buf_fin-doc.host-code = p-host-code
            AND  buf_fin-doc.doc-date = tt-1s-fin-doc.doc-date
            AND  buf_fin-doc.fin-ext-doc-type = tt-1s-fin-doc.fin-ext-doc-type
            AND  buf_fin-doc.payer-r-schet = tt-1s-fin-doc.payer-r-schet
            AND  buf_fin-doc.receiver-r-schet = tt-1s-fin-doc.receiver-r-schet no-error .
      v-do = no.
      if available buf_fin-doc then do:
        if buf_fin-doc.status_ = {&fin-bank}
        and tt-1s-fin-doc.fact-date <> ?
        then do:
          assign
          v-do = yes
          .
        end.
        else do:
            if tt-1s-fin-doc.fact-date = ? then do:
              assign
              v-do = no.
            end.
            else do:
  &scop my-message substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +  ~
                              'находится в статусе &6, закрыть на факт НЕВОЗМОЖНО'                     ~
                            , tt-1s-fin-doc.prn-doc-code                                 ~
                            , p-host-code                                             ~
                            , ~{&new-line~}                                           ~
                            , buf_fin-doc.payer-name                                  ~
                            , buf_fin-doc.receiver-name                               ~
                            , buf_fin-doc.status_)
                    {&display-message}.
              p-view-log = yes.
              undo _main, return error .
            end.
        end.
      end. /*if available buf_fin-doc then do:*/
      else do:
          /*надо скреатить если p-do-create*/
&scop my-message substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +  ~
                              'отсутствует в БД&6'                     ~
                            , tt-1s-fin-doc.prn-doc-code                                 ~
                            , p-host-code                                             ~
                            , ~{&new-line~}                                           ~
                            , tt-1s-fin-doc.payer-name                                  ~
                            , tt-1s-fin-doc.receiver-name                                ~
                            , (if p-do-create then ' согласно настройкам он будет создан' else '')  )
          {&display-message}.
          /*и закрыть до статуса банк*/
        if p-do-create then do:
           assign
           v-create = yes
           v-do = no
           .
        end.
        else do:
          NEXT _tt-1s-fin-doc.
        end.
      end.
      if v-do or v-create then do:
        create tt-th-fin-doc.
        assign
        tt-th-fin-doc.stat-pl = ''
        tt-th-fin-doc.ocher-pl = "6":U
        .
        assign
        h-buffer = buffer tt-th-Fin-doc:handle
        h-1s-buffer = buffer tt-1s-Fin-doc:handle
        .
        if not v-create then
        buffer-copy buf_fin-doc to tt-th-fin-doc.
        _tt:
        for each temp_hfields where
                temp_hfields.imported = yes
            and temp_hfields.subject = {&table_fin-doc}:
          if tt-1s-fin-doc.fin-EXT-doc-type = {&FDEDT_Income_Cashless} then do:
             if lookup(temp_hfields.name_ , {&only-expense-fields}) > 0
             then next _tt.
          end.
          if index(temp_hfields.name , {&slash-char}) > 0 then do:
            CASE temp_hfields.name:
              when 'payer-INN/payer-name':U
              then do:
                assign
                tt-th-fin-doc.payer-inn = tt-1s-fin-doc.payer-inn
                .
                next _tt.
              end.
              when 'receiver-INN/receiver-name':U
              then do:
                assign
                tt-th-fin-doc.receiver-inn = tt-1s-fin-doc.receiver-inn
                .
                next _tt.
              end.
              otherwise do:
                h-field = h-buffer:buffer-field(entry(1, temp_hfields.name_, {&slash-char})).
                h-1s-field = h-1s-buffer:buffer-field(entry(1, temp_hfields.name_, {&slash-char})).
              end.
            END CASE.
          end.
          else do:
            h-field = h-buffer:buffer-field(temp_hfields.name_).
            h-1s-field = h-1s-buffer:buffer-field(temp_hfields.name_).
            if h-field:name = 'fact-date' then NEXT _tt.
          end.
          assign
          h-field:buffer-value = h-1s-field:buffer-value
          .
        end.
        if not v-create then do:
          /*отредактируем документ согласно тому что из банка пришло если ЭТО НАДО*/
          v-result = '':U.
          buffer-compare tt-th-fin-doc to buf_fin-doc
          save result in v-result.
          if v-result <> '':U then do:
            assign
            v-doc-rec = recid(buf_fin-doc).
  &scop prfx tt-th-fin-doc.
            run ref/findoc0.p (
            input-output v-doc-rec
                  ,input ({&update} + {&delim-par} + 'cl-bank')
                  ,input yes /*p-silent*/
                  {&all-fin-doc-params-doc-status-transfer}
                  {&all-fin-doc-params-doc-status-transfer-2}
                  ,input table tt0-fin-doc-tax
                  ,input table tt0-fin-doc-attr
                  ,input no /*p-save-payment*/
                  ,input table tt0-payment
            ) no-error.
            if error-status:error then do:
              p-view-log = yes.
  &scop my-message substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +  ~
                                'ОШИБКА ПРИ ОБНОВЛЕНИИ ДОКУМЕНТА изменениями из системы КЛИЕНТ-БАНК&3:&6 &7'                     ~
                              , tt-1s-fin-doc.prn-doc-code                                 ~
                              , p-host-code                                             ~
                              , ~{&new-line~}                                           ~
                              , tt-1s-fin-doc.payer-name                                  ~
                              , tt-1s-fin-doc.receiver-name                                ~
                              , error-status:get-message(1)                               ~
                              , return-value   )
              {&display-message}.
              undo _main, return error .
            end.
          end. /*if v-result*/
        end.
      end. /*if v-do or v-create*/
      if v-create then do:
        run proc-create-fin-doc in this-procedure ( buffer tt-th-fin-doc
                                                   ,buffer tt-1s-fin-doc
                                                   ) no-error .
        if error-status:error then do:
          p-view-log = yes.
&scop my-message substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +  ~
                              'ОШИБКА ПРИ  СОЗДАНИИ ДОКУМЕНТА:&3&6 &7'                     ~
                            , tt-1s-fin-doc.prn-doc-code                                 ~
                            , p-host-code                                             ~
                            , ~{&new-line~}                                           ~
                            , tt-1s-fin-doc.payer-name                                  ~
                            , tt-1s-fin-doc.receiver-name                                ~
                            , error-status:get-message(1)                               ~
                            , return-value   )
          {&display-message}.
          undo _main, return error .
        end. /*if error-status:error then do:*/

      end. /*if v-create*/
      if v-do then do:
        assign
        v-date = tt-1s-fin-doc.fact-date
        .
        run trg/findstat.p (
                         input parparentproc
                        ,input buf_fin-doc.host-code
                        ,input buf_fin-doc.fin-doc-code
                        ,input {&close-doc}
                        ,input 'cl-bank'
                        ,input {&fin-fact}
                        ,input-output v-date
                        ,input yes /*p-silent*/
                                      ) no-error .
        if error-status:error then do:
  &scop my-message substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +  ~
                                'ОШИБКА ПРИ ЗАКРЫТИИ ДОКУМЕНТА НА ФАКТ:&3&6&3&7'                     ~
                              , tt-1s-fin-doc.prn-doc-code                                 ~
                              , p-host-code                                             ~
                              , ~{&new-line~}                                           ~
                              , tt-1s-fin-doc.payer-name                                  ~
                              , tt-1s-fin-doc.receiver-name                                ~
                              , error-status:get-message(1)                               ~
                              , return-value   )
            {&display-message}.
            undo _main, return error .
        end. /*if error-status:error then do:*/
        assign
        tt-1s-fin-doc.status_ = {&fin-fact}
        tt-th-fin-doc.status_ = {&fin-fact}
        .
      end. /*if v-do then do:*/
      if available buf_fin-doc then do:
        tt-1s-fin-doc.fin-doc-code-th = buf_fin-doc.fin-doc-code.
      end.
      assign
      p-processed = p-processed + 1
      .
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Импорт: БИК &1 Фирма &2: ОБРАБОТАНО документов &3"
                                      , p-bik
                                      , p-host-code
                                      , p-processed)).
    end. /*for each tt-1s-fin-doc*/
    _tt-1s-fin-statement:
    for each tt-1s-fin-statement
    on error undo _main, return error
    :
      assign
      v-do = no
      v-create = no
      .
      find first buf_fin-statement where
                 buf_fin-statement.host-code = p-host-code
            AND  buf_fin-statement.start-date = tt-1s-fin-statement.start-date
            AND  buf_fin-statement.end-date = tt-1s-fin-statement.end-date
            AND  buf_fin-statement.fins-ext-doc-type = tt-1s-fin-statement.fins-ext-doc-type
            AND  buf_fin-statement.code-bank = tt-1s-fin-statement.code-bank
            AND  buf_fin-statement.code-schet = tt-1s-fin-statement.code-schet
            no-error .
      assign
      v-do-bank = no
      v-do-fact = no
      .
      if available buf_fin-statement then do:
        v-doc-rec = recid(buf_fin-statement).
        if buf_fin-statement.status_ = {&fin-bank}
        then do:
          assign
          v-do-fact = yes
          .
        end.
        else do:
          if buf_fin-statement.status_ = {&fin-new} and tt-1s-fin-statement.bank-date <> ? then do:
            assign
            v-do-bank = yes.
          end.
          else do:
    &scop my-message substitute("!!!Выписка &1 фирма &2&3Счет &4 БИК &5&3"  +      ~
                                'находится в статусе &6, закрыть на банк НЕВОЗМОЖНО'  ~
                              , cbnki-period-to-String(tt-1s-fin-statement.start-date, tt-1s-fin-statement.end-date) ~
                              , p-host-code                                           ~
                              , ~{&new-line~}                                         ~
                              , buf_fin-statement.r-schet                             ~
                              , buf_fin-statement.bik                                 ~
                              , buf_fin-statement.status_)
                      {&display-message}.
              p-view-log = yes.
              undo _main, return error .
          end.
        end.
      end. /*if available buf_fin-statement then do:*/
      else do:
          /*надо скреатить */
          /*и закрыть до статуса банк*/
        assign
        v-create = yes
        v-do-fact = yes
        v-do-bank = yes
        .
      end.
      if not v-create then do:
        /*сначала подключим к выписке все импортированные документы*/
        run proc-insert-statement-lines in this-procedure ( (buffer buf_Fin-statement:handle) ).
        buffer-copy buf_fin-statement to tt-th-fin-statement.
      end.
      if v-do-bank or v-do-fact or v-create then do:
        create tt-th-fin-statement.
        assign
        h-buffer = buffer tt-th-fin-statement:handle
        h-1s-buffer = buffer tt-1s-fin-statement:handle
        .
        _tt:
        for each temp_hfields where
                temp_hfields.imported = yes
            and temp_hfields.subject = {&table_fin-statement}:
          if temp_hfields.name_ = 'fins-ext-doc-type/' then NEXT _tt.
          h-field = h-buffer:buffer-field(temp_hfields.name_).
          if h-field:name = 'fact-date' then NEXT _tt.
          if h-field:name = 'bank-date' then NEXT _tt.
          h-1s-field = h-1s-buffer:buffer-field(temp_hfields.name_).
          assign
          h-field:buffer-value = h-1s-field:buffer-value
          .
        end.
        if not v-create then do:
          /*отредактируем выписку согласно тому что из банка пришло если ЭТО НАДО*/
          v-result = ''.
          buffer-compare tt-th-fin-statement
          using num-docs start-sum-doc end-sum-doc in-sum-doc out-sum-doc
          to buf_fin-statement
          save result in v-result.
          if v-result <> '':U then do:
            assign
            v-doc-rec = recid(buf_fin-statement).
  &scop prfx tt-th-fin-statement.
            define variable v-lines-exist as logical no-undo .
            run ref/finsttm0.p
                            (input yes   /*silent*/
                            ,input-output v-doc-rec
                            ,input       ({&update} + {&delim-par} + 'cl-bank')
                            ,input {&cl-bank-1s} /*p-author*/
                            {&all-fin-statement-params-doc-status-transfer}
                            ,input {&fin-new}
                            ,input v-lines-exist
                            ) no-error .
            if error-status:error then do:
              p-view-log = yes.
  &scop my-message substitute("!!!Выписка &1 фирма &2&3Счет &4 БИК &5&3"  +  ~
                                'ОШИБКА ПРИ ОБНОВЛЕНИИ выписки изменениями из системы КЛИЕНТ-БАНК&3:&6 &7' ~
                              , cbnki-period-to-String(tt-1s-fin-statement.start-date, tt-1s-fin-statement.end-date) ~
                              , p-host-code                                             ~
                              , ~{&new-line~}                                           ~
                              , tt-1s-fin-statement.r-schet                                  ~
                              , tt-1s-fin-statement.bik                                ~
                              , error-status:get-message(1)                               ~
                              , return-value   )
              {&display-message}.
              undo _main, return error .
            end.
          end. /*if v-result*/
        end. /*if not v-create then do:*/
      end. /*if v-do or v-create*/
      if v-create then do:
        run proc-create-fin-statement in this-procedure ( buffer tt-th-fin-statement) no-error .
        if error-status:error then do:
          p-view-log = yes.
&scop my-message substitute("!!!Выписка &1 фирма &2&3Счета &4 БИК &5&3"  +  ~
                              'ОШИБКА ПРИ  СОЗДАНИИ ВЫПИСКИ:&3&6 &7'                     ~
                            , cbnki-period-to-String(tt-1s-fin-statement.start-date, tt-1s-fin-statement.end-date) ~
                            , p-host-code                                              ~
                            , ~{&new-line~}                                            ~
                            , tt-1s-fin-statement.r-schet                              ~
                            , tt-1s-fin-statement.BIK                                  ~
                            , error-status:get-message(1)                               ~
                            , return-value   )
          {&display-message}.
          undo _main, return error .
        end.
        find first buf_Fin-statement no-lock where
                  buf_fin-statement.host-code = p-host-code
              and buf_fin-statement.sttm-code = tt-th-fin-statement.sttm-code.
        /*подключим к выписке все импортированные документы*/
        run proc-insert-statement-lines in this-procedure ( (buffer buf_Fin-statement:handle) ).
      end. /*if v-create*/
      if buf_fin-statement.num-docs = buf_fin-statement.num-docs-th
      and buf_fin-statement.start-sum-doc = buf_fin-statement.start-sum-doc-th
      and buf_fin-statement.end-sum-doc = buf_fin-statement.end-sum-doc-th
      and buf_fin-statement.in-sum-doc = buf_fin-statement.in-sum-doc-th
      and buf_fin-statement.out-sum-doc = buf_fin-statement.out-sum-doc-th
      and buf_fin-statement.sum-doc = buf_fin-statement.sum-doc-th then do:
        if buf_fin-statement.status_ = {&fin-new} then do:
          run trg/finsstat.p (
                          input buf_fin-statement.host-code
                          ,input buf_fin-statement.sttm-code
                          ,input {&close-doc}
                          ,input {&cl-bank-1s}
                          ,input {&fin-bank}
                          ,input-output tt-1s-fin-statement.bank-date
                          ,input yes /*p-silent*/
                                        ) no-error .
          if error-status:error then do:
    &scop my-message substitute("!!!Выписка &1 фирма &2&3Счета &4 БИК &5&3"  +  ~
                                  'ОШИБКА ПРИ ЗАКРЫТИИ ВЫПИСКИ НА БАНК&3:&6 &7'    ~
                                , cbnki-period-to-String(tt-1s-fin-statement.start-date, tt-1s-fin-statement.end-date) ~
                                , p-host-code                                      ~
                                , ~{&new-line~}                                    ~
                                , tt-1s-fin-statement.r-schet                      ~
                                , tt-1s-fin-statement.bik                          ~
                                , error-status:get-message(1)                      ~
                                , return-value   )
              {&display-message}.
              undo _main, return error .
          end. /*if error-status:error then do:*/
        end.
        if buf_fin-statement.status_ = {&fin-bank} then do:
          run cur-time in this-procedure(output v-today, output v-time).
          assign
          v-date = v-today
          .
          run trg/finsstat.p (
                          input buf_fin-statement.host-code
                          ,input buf_fin-statement.sttm-code
                          ,input {&close-doc}
                          ,input {&cl-bank-1s}
                          ,input {&fin-fact}
                          ,input-output v-date
                          ,input yes /*p-silent*/
                                        ) no-error .
          if error-status:error then do:
    &scop my-message substitute("!!!Выписка &1 фирма &2&3Счета &4 БИК &5&3"  +  ~
                                  'ОШИБКА ПРИ ЗАКРЫТИИ ВЫПИСКИ НА ФАКТ&3:&6 &7'    ~
                                , cbnki-period-to-String(tt-1s-fin-statement.start-date, tt-1s-fin-statement.end-date) ~
                                , p-host-code                                      ~
                                , ~{&new-line~}                                    ~
                                , tt-1s-fin-statement.r-schet                      ~
                                , tt-1s-fin-statement.bik                          ~
                                , error-status:get-message(1)                      ~
                                , return-value   )
              {&display-message}.
              undo _main, return error .
          end. /*if error-status:error then do:*/
        end.
      end.
      assign
      p-processed-statement = p-processed-statement + 1
      .
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Импорт: БИК &1 Фирма &2: ОБРАБОТАНО выписок &3"
                                      , p-bik
                                      , p-host-code
                                      , p-processed-statement)).


    end. /*for each tt-1s-fin-statement*/
  end. /*doe*/

end procedure. /* proc-write-out */


procedure proc-create-fin-doc :
define parameter buffer buf_tt-th-fin-doc for tt-th-fin-doc.
define parameter buffer buf_tt-1s-fin-doc for tt-1s-fin-doc.

define variable v-doc-rec as recid no-undo .
define variable v-curr-abbr like ub.currency.curr-abbr no-undo.
define variable v-contract-rate like ub.fin-doc.exch-rate no-undo.
define variable v-contract-scale like ub.fin-doc.exch-scale no-undo.
define variable v-base-code like ub.sysconf.host-code no-undo.
define variable v-mess as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-fd-code as integer no-undo .

define buffer buf_sysconf for ub.sysconf.
define buffer buf_firm for ub.firm.
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc.
define buffer buf_fin-code-an-uchet for ub.fin-code-an-uchet.
define buffer buf_fin-code-cel-nazn for ub.fin-code-cel-nazn.
define buffer buf_fin-doc for ub.fin-doc.
define buffer receiver-firm for ub.firm.
define buffer receiver-person for ub.person.
define buffer payer-firm for ub.firm.
define buffer payer-person for ub.person.


  do
  on error undo, return error
  :
    run gen-b-code in this-procedure ( input {&gbl-fd-code}
                                     , output v-fd-code) no-error .
    if error-status:error then do:
      undo, return error substitute("Ошибка при генерации внутреннего номера фин. док-та:&1&2&1&3"
                                   , {&new-line}
                                   , error-status:get-message(1)
                                   , return-value ).
    end.
    /*в буфере buf_tt-th-fin-doc некоторые поля уже заполнены*/
    assign
    buf_tt-th-fin-doc.contract-curr = 0
    buf_tt-th-fin-doc.base-rate = 1
    buf_tt-th-fin-doc.base-scale = 1
    buf_tt-th-fin-doc.exch-rate = 1
    buf_tt-th-fin-doc.exch-scale = 1
    buf_tt-th-fin-doc.contract-rate = 1
    buf_tt-th-fin-doc.contract-scale = 1
    buf_tt-th-fin-doc.obj-type      = '':U
    buf_tt-th-fin-doc.obj-code      = 0
    buf_tt-th-fin-doc.contract-code = 0
    buf_tt-th-fin-doc.fin-doc-code  = v-fd-code
    buf_tt-th-fin-doc.status_       = {&fin-new}
    buf_tt-th-fin-doc.user-db-num-doc = g#db-num
    buf_tt-th-fin-doc.user-name-doc = g#userid
    buf_tt-th-fin-doc.doc-author    = {&cl-bank-1s}
    .
    CASE buf_tt-th-fin-doc.fin-ext-doc-type:
      when {&FDEDT_Expense_Cashless} then do:
        find first buf_sysconf where
                  buf_sysconf.host-code = buf_tt-th-fin-doc.payer-code.
        v-base-code = buf_sysconf.base-code.
        find first buf_firm where
                  buf_firm.firm-code = buf_tt-th-fin-doc.payer-code
        .
        assign
        buf_tt-th-fin-doc.payer-sign1  = buf_firm.director
        buf_tt-th-fin-doc.payer-sign2  = buf_sysconf.snr-accnt
        buf_tt-th-fin-doc.host-code    = buf_tt-th-fin-doc.payer-code
        .
        if buf_tt-th-fin-doc.payer-code <> p-host-code then do:
          /*чужая платежка*/
          undo, return error substitute("!!!В файле для фирмы &1 обнаружена платежка фирмы &2"
                                        ,p-host-code
                                        ,buf_tt-th-fin-doc.payer-code).
        end.
        find first buf_fin-bank no-lock where
                  buf_Fin-bank.host-code = buf_tt-th-fin-doc.host-code
              AND buf_Fin-bank.bik = buf_tt-th-fin-doc.receiver-bik
              AND buf_Fin-bank.cor-acc = buf_tt-th-fin-doc.receiver-c-schet no-error.
        if not available buf_fin-bank then do:
          assign
          v-mess = substitute("!!!Не найден в БД (или удален) банк ПОЛУЧАТЕЛЯ&1 - БИК &2&1Коррсчет &3"
                              , {&new-line}
                              , buf_tt-th-fin-doc.receiver-bik
                              , buf_tt-th-fin-doc.receiver-c-schet
                              ).
          undo, return error v-mess.
        end.
        if buf_fin-bank.status_ <> {&current-status} then do:
          undo, return error substitute("!!!банк ПОЛУЧАТЕЛЯ БИК &1 имеет статус", buf_fin-bank.status_).
        end.
        for each buf_fin-schet no-lock where
                buf_fin-schet.host-code = buf_tt-th-fin-doc.host-code
            AND buf_fin-schet.code-bank =  buf_fin-bank.code-bank
            AND buf_fin-schet.r-schet =  buf_tt-th-fin-doc.receiver-r-schet
            AND buf_fin-schet.status_ =  {&current-status} :
          if buf_fin-schet.cli-type = {&cmp} then do:
            find first receiver-firm no-lock where
                    receiver-firm.firm-code = buf_fin-schet.cli-code
                and receiver-firm.inn = tt-1s-fin-doc.receiver-inn no-error.
            if available receiver-firm then leave.
          end.
          if buf_fin-schet.cli-type = {&prs} then do:
            find first receiver-person no-lock where
                    receiver-person.psn-code = buf_fin-schet.cli-code
                and receiver-person.inn = tt-1s-fin-doc.receiver-inn no-error.
            if available receiver-person then leave.
          end.
        end.
        if not available buf_fin-schet then do:
          assign
          v-mess =  substitute("!!!Не найден в БД (или удален) счет ПОЛУЧАТЕЛЯ&1 банк с БИК &2 (вн код &3),&1р/с &4, {&abbr_inn_allshift} &5"
                    , {&new-line}
                    , buf_tt-th-fin-doc.receiver-bik
                    , buf_fin-bank.code-bank
                    , buf_tt-th-fin-doc.receiver-r-schet
                    , buf_tt-th-fin-doc.receiver-inn
                    ).
          undo, return error v-mess.
        end.
        assign
        buf_tt-th-fin-doc.receiver-code-schet = buf_fin-schet.code-schet
        buf_tt-th-fin-doc.receiver-c-schet = buf_fin-schet.c-schet
        buf_tt-th-fin-doc.receiver-type = buf_fin-schet.cli-type
        buf_tt-th-fin-doc.receiver-code = buf_fin-schet.cli-code
        buf_tt-th-fin-doc.cel-nazn-code = buf_sysconf.cel-nazn-code-out
        buf_tt-th-fin-doc.an-uchet-code = buf_sysconf.an-uchet-code-out
        buf_tt-th-fin-doc.cor-acc       = buf_sysconf.cor-acc-out
        .
      end.
      when {&FDEDT_income_Cashless} then do:
        find first buf_sysconf where
                  buf_sysconf.host-code = buf_tt-th-fin-doc.receiver-code.
        v-base-code = buf_sysconf.base-code.
        buf_tt-th-fin-doc.host-code     = buf_tt-th-fin-doc.receiver-code.
        if buf_tt-th-fin-doc.receiver-code <> p-host-code then do:
          /*чужая платежка*/
          undo, return error substitute("!!!В файле для фирмы &1 обнаружена платежка фирмы &2"
                                        ,p-host-code
                                        ,buf_tt-th-fin-doc.receiver-code).
        end.
        find first buf_fin-bank no-lock where
                  buf_Fin-bank.host-code = buf_tt-th-fin-doc.host-code
              AND buf_Fin-bank.bik = buf_tt-th-fin-doc.payer-bik
              AND buf_Fin-bank.cor-acc = buf_tt-th-fin-doc.payer-c-schet  no-error.
        if not available buf_fin-bank then do:
          assign
          v-mess = substitute("!!!Не найден в БД (или удален) банк ПЛАТЕЛЬЩИКА&1 - БИК &2&1Коррсчет &3"
                              , {&new-line}
                              , buf_tt-th-fin-doc.payer-bik
                              , buf_tt-th-fin-doc.payer-c-schet
                              ).
          undo, return error v-mess.
        end.
        if buf_fin-bank.status_ <> {&current-status} then do:
          undo, return error substitute("!!!банк ПЛАТЕЛЬЩИКА БИК &1 имеет статус", buf_fin-bank.status_).
        end.
        for each buf_fin-schet no-lock where
                buf_fin-schet.host-code = buf_tt-th-fin-doc.host-code
            AND buf_fin-schet.code-bank =  buf_fin-bank.code-bank
            AND buf_fin-schet.r-schet =  buf_tt-th-fin-doc.payer-r-schet
            AND buf_fin-schet.status_ = {&current-status} :
          if buf_fin-schet.cli-type = {&cmp} then do:
            find first payer-firm no-lock where
                    payer-firm.firm-code = buf_fin-schet.cli-code
                and payer-firm.inn = tt-1s-fin-doc.payer-inn no-error.
            if available payer-firm then leave.
          end.
          if buf_fin-schet.cli-type = {&prs} then do:
            find first payer-person no-lock where
                    payer-person.psn-code = buf_fin-schet.cli-code
                and payer-person.inn = tt-1s-fin-doc.payer-inn no-error.
            if available payer-person then leave.
          end.
        end.
        if not available buf_fin-schet then do:
          assign
          v-mess =  substitute("!!!Не найден в БД (или удален) счет ПЛАТЕЛЬЩИКА&1 банк с БИК &2 (вн код &3),&1р/с &4, {&abbr_inn_allshift} &5"
                    , {&new-line}
                    , buf_tt-th-fin-doc.payer-bik
                    , buf_fin-bank.code-bank
                    , buf_tt-th-fin-doc.payer-r-schet
                    , buf_tt-th-fin-doc.payer-inn
                    ).
          undo, return error v-mess.
        end.
        assign
        buf_tt-th-fin-doc.payer-code-schet = buf_fin-schet.code-schet
        buf_tt-th-fin-doc.payer-c-schet = buf_fin-schet.c-schet
        buf_tt-th-fin-doc.payer-type = buf_fin-schet.cli-type
        buf_tt-th-fin-doc.payer-code = buf_fin-schet.cli-code
        buf_tt-th-fin-doc.cel-nazn-code = buf_sysconf.cel-nazn-code-in
        buf_tt-th-fin-doc.an-uchet-code = buf_sysconf.an-uchet-code-in
        buf_tt-th-fin-doc.cor-acc       = buf_sysconf.cor-acc-in
        .
      end.
    END CASE.
    /* извлечение из findocip.i*/
    { gbl/baserate.i  buf_tt-th-fin-doc.host-code buf_tt-th-fin-doc.doc-date buf_tt-th-fin-doc.base-rate buf_tt-th-fin-doc.base-scale }
    { gbl/exchrate.i  buf_tt-th-fin-doc.curr-code buf_tt-th-fin-doc.doc-date buf_tt-th-fin-doc.exch-rate buf_tt-th-fin-doc.exch-scale v-curr-abbr }
    { gbl/exchrate.i  buf_tt-th-fin-doc.contract-curr buf_tt-th-fin-doc.doc-date buf_tt-th-fin-doc.contract-rate buf_tt-th-fin-doc.contract-scale v-curr-abbr }

&scop get-f-sum-contract     buf_tt-th-fin-doc.sum-contr = (if buf_tt-th-fin-doc.contract-curr = 0 ~
                                                      then buf_tt-th-fin-doc.sum-rubl ~
                                                      else buf_tt-th-fin-doc.sum-rubl / (buf_tt-th-fin-doc.contract-rate / buf_tt-th-fin-doc.contract-scale) ~
                                                    )

    CASE buf_tt-th-fin-doc.curr-code:
      when 0 then do:
        assign
        buf_tt-th-fin-doc.sum-rubl = buf_tt-th-fin-doc.sum-doc
        buf_tt-th-fin-doc.sum-base = buf_tt-th-fin-doc.sum-doc / buf_tt-th-fin-doc.base-rate * buf_tt-th-fin-doc.base-scale
        {&get-f-sum-contract}
        .
      end. /*when buf_tt-th-fin-doc.curr-code = 0*/
      when v-base-code then do:
        assign
        buf_tt-th-fin-doc.sum-rubl = buf_tt-th-fin-doc.sum-doc * buf_tt-th-fin-doc.exch-rate / buf_tt-th-fin-doc.exch-scale
        buf_tt-th-fin-doc.sum-base = buf_tt-th-fin-doc.sum-rubl / buf_tt-th-fin-doc.base-rate * buf_tt-th-fin-doc.base-scale
        {&get-f-sum-contract}
        .
      end. /*when base-code*/
      otherwise do: /*ОПЛАТА НЕ В БАЗ ВАЛ И НЕ В Р_У_БЛЯХ*/
        assign
        buf_tt-th-fin-doc.sum-rubl = buf_tt-th-fin-doc.sum-doc * buf_tt-th-fin-doc.exch-rate / buf_tt-th-fin-doc.exch-scale
        buf_tt-th-fin-doc.sum-base = buf_tt-th-fin-doc.sum-rubl / buf_tt-th-fin-doc.base-rate * buf_tt-th-fin-doc.base-scale
        {&get-f-sum-contract}
        .
      end. /*when ОПЛАТА НЕ В БАЗ ВАЛ И НЕ В Р_У_БЛЯХ*/
    END CASE.
    /*проставим правильные значения кодов*/
    if buf_tt-th-fin-doc.cor-acc <> 0 then do:
      find first buf_fin-code-cor-acc no-lock where
                buf_fin-code-cor-acc.host-code = p-host-code
            AND buf_fin-code-cor-acc.fin-code = buf_tt-th-fin-doc.cor-acc .
      assign
      buf_tt-th-fin-doc.cor-acc-value = buf_fin-code-cor-acc.code-value
      .
    end.
    if buf_tt-th-fin-doc.cor-acc1 <> 0 then do:
      find first buf_fin-code-cor-acc no-lock where
                buf_fin-code-cor-acc.host-code = p-host-code
            AND buf_fin-code-cor-acc.fin-code = buf_tt-th-fin-doc.cor-acc1.
      assign
      buf_tt-th-fin-doc.cor-acc1-value = buf_fin-code-cor-acc.code-value
      .
    end.
    if buf_tt-th-fin-doc.AN-UCHET-CODE <> 0 then do:
      find first buf_fin-code-AN-UCHET no-lock where
                buf_fin-code-an-uchet.host-code = p-host-code
            AND buf_fin-code-an-uchet.fin-code = buf_tt-th-fin-doc.an-uchet-code.
      assign
      buf_tt-th-fin-doc.an-uchet-value = buf_fin-code-an-uchet.code-value
      .
    end.
    if buf_tt-th-fin-doc.cel-nazn-code <> 0 then do:
        find first buf_fin-code-cel-nazn no-lock where
                  buf_fin-code-cel-nazn.host-code = p-host-code
              AND buf_fin-code-cel-nazn.fin-code = buf_tt-th-fin-doc.cel-nazn-code.
       assign
       buf_tt-th-fin-doc.cel-nazn-value = buf_fin-code-cel-nazn.code-value
       .
    end.
    run proc-create-default-tax  in this-procedure (buffer buf_tt-th-fin-doc).
    assign
    v-doc-rec = ?.
&scop prfx buf_tt-th-fin-doc.
    run ref/findoc0.p (
    input-output v-doc-rec
          ,input ({&add-def} + {&delim-par} + 'cl-bank')
          ,input yes /*p-silent*/
          {&all-fin-doc-params-doc-status-transfer}
          {&all-fin-doc-params-doc-status-transfer-2}
          ,input table tt0-fin-doc-tax
          ,input table tt0-fin-doc-attr
          ,input no /*p-save-payment*/
          ,input table tt0-payment
    ) no-error.
    if error-status:error then do:
      undo, return error return-value .
    end.
    else do:
      find first buf_fin-doc no-lock where recid(buf_fin-doc) = v-doc-rec.
      assign
      buf_tt-1s-fin-doc.fin-doc-code-th = buf_fin-doc.fin-doc-code.
      assign
      p-created = p-created + 1
      .
    end.
    /*закроем до статуса разр*/
    run cur-time in this-procedure(output v-today, output v-time).
    run trg/findstat.p (
                     input parparentproc
                    ,input buf_fin-doc.host-code
                    ,input buf_fin-doc.fin-doc-code
                    ,input {&close-doc}
                    ,input 'cl-bank'
                    ,input {&fin-permitted}
                    ,input-output v-today
                    ,input yes /*p-silent*/
                                  ) no-error .
    if error-status:error then do:
&scop my-message substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +  ~
                            'ОШИБКА ПРИ ЗАКРЫТИИ СОЗДАННОГО ДОКУМЕНТА ДО СТАТУСА РАЗРЕШЕН:&3&6&3&7'                     ~
                          , buf_tt-1s-fin-doc.prn-doc-code                                 ~
                          , p-host-code                                             ~
                          , ~{&new-line~}                                           ~
                          , buf_tt-1s-fin-doc.payer-name                                  ~
                          , buf_tt-1s-fin-doc.receiver-name                                ~
                          , error-status:get-message(1)                               ~
                          , return-value   )
        {&display-message}.
        undo, return error .
    end. /*if error-status:error then do:*/
    assign
    buf_tt-1s-fin-doc.status_ = {&fin-permitted}
    buf_tt-1s-fin-doc.perm-date = v-today
    buf_tt-th-fin-doc.status_ = {&fin-permitted}
    buf_tt-th-fin-doc.perm-date = v-today
    .
    /*закроем до статуса банк*/
    run cur-time in this-procedure(output v-today, output v-time).
    run trg/findstat.p (
                     input parparentproc
                    ,input buf_fin-doc.host-code
                    ,input buf_fin-doc.fin-doc-code
                    ,input {&close-doc}
                    ,input 'cl-bank'
                    ,input {&fin-bank}
                    ,input-output v-today
                    ,input yes /*p-silent*/
                                  ) no-error .
    if error-status:error then do:
&scop my-message substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +  ~
                            'ОШИБКА ПРИ ЗАКРЫТИИ СОЗДАННОГО ДОКУМЕНТА ДО СТАТУСА БАНК:&3&6&3&7'                     ~
                          , buf_tt-1s-fin-doc.prn-doc-code                                 ~
                          , p-host-code                                             ~
                          , ~{&new-line~}                                           ~
                          , buf_tt-1s-fin-doc.payer-name                                  ~
                          , buf_tt-1s-fin-doc.receiver-name                                ~
                          , error-status:get-message(1)                               ~
                          , return-value   )
        {&display-message}.
        undo, return error .
    end. /*if error-status:error then do:*/
    assign
    buf_tt-1s-fin-doc.status_ = {&fin-bank}
    buf_tt-1s-fin-doc.pay-date = v-today
    buf_tt-th-fin-doc.status_ = {&fin-bank}
    buf_tt-th-fin-doc.pay-date = v-today
    .
  end. /*doe*/

end procedure. /* proc-create-fin-doc */


procedure proc-create-default-tax :
define parameter buffer buf_tt-fin-doc for tt-th-fin-doc.
  do
  on error undo, return error
  :

      find tt0-fin-doc-tax where
                tt0-fin-doc-tax.fin-doc-code = buf_tt-fin-doc.fin-doc-code
          AND tt0-fin-doc-tax.host-code = buf_tt-fin-doc.host-code no-error .
      if not avail tt0-fin-doc-tax
      and not AMBIGUOUS tt0-fin-doc-tax
      then do:
        create tt0-fin-doc-tax.
      end.
      if AMBIGUOUS tt0-fin-doc-tax then return.
      assign
      tt0-fin-doc-tax.fin-doc-code = buf_tt-fin-doc.fin-doc-code
      tt0-fin-doc-tax.host-code = buf_tt-fin-doc.host-code
      tt0-fin-doc-tax.line-num  = 1
      tt0-fin-doc-tax.slt-pc    = 0
      tt0-fin-doc-tax.sum-line-doc = buf_tt-fin-doc.sum-doc
      tt0-fin-doc-tax.sum-slt-line-doc = 0
      tt0-fin-doc-tax.sum-vat-line-doc = 0
      tt0-fin-doc-tax.vat-pc           = 0
      tt0-fin-doc-tax.with-slt         = no
      tt0-fin-doc-tax.with-vat         = no
      tt0-fin-doc-tax.sum-line-doc     = buf_tt-fin-doc.sum-doc
      .
      release tt0-fin-doc-tax.

  end. /*doe*/
end procedure. /* proc-create-default-tax */

procedure proc-insert-statement-lines :
define input parameter p-bh as handle no-undo .

define variable v-host-code as integer no-undo .
define variable v-start-date as date no-undo .
define variable v-end-date as date no-undo .
define variable v-mess as character no-undo .
define variable v-ii as integer no-undo .
define variable v-status_ as character no-undo .
define buffer buf_tt-1s-fin-doc for tt-1s-fin-doc.
define buffer buf_tt-th-fin-doc for tt-th-fin-doc.
define buffer buf_fin-doc for ub.fin-doc.




main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  assign
  v-host-code = p-bh:buffer-field("host-code"):buffer-value
  v-start-date = p-bh:buffer-field("start-date"):buffer-value
  v-end-date = p-bh:buffer-field("end-date"):buffer-value
  .
  do v-ii = 1 to 2:
    if v-ii = 1 then v-status_ = {&fin-fact}.
    if v-ii = 2 then v-status_ = {&fin-bank}.

    _line:
    for each buf_tt-1s-fin-doc no-lock where
          buf_tt-1s-fin-doc.host-code = v-host-code
      and  buf_tt-1s-fin-doc.status_ = v-status_
      and  buf_tt-1s-fin-doc.fact-date >= v-start-date
      and  buf_tt-1s-fin-doc.fact-date <= v-end-date
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      if  not (buf_tt-1s-fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
      and  buf_tt-1s-fin-doc.payer-code-schet = p-bh:buffer-field("code-schet"):buffer-value)
      and  not (buf_tt-1s-fin-doc.fin-ext-doc-type = {&FDEDT_income_cashless}
      and buf_tt-1s-fin-doc.receiver-code-schet = p-bh:buffer-field("code-schet"):buffer-value)  then next _line.
      find first buf_tt-th-fin-doc no-lock where
                buf_tt-th-fin-doc.host-code = p-host-code
            and buf_tt-th-fin-doc.fin-doc-code = buf_tt-1s-fin-doc.fin-doc-code-th no-error.
      if not available buf_tt-th-fin-doc
      and p-create-no-th then do:
        /*сделаем платеж не включенный в TH*/
        define variable v-line-rec as recid no-undo .
        run ref/finsttml.p (
                      INPUT NO /*p-silent*/
                      ,INPUT-OUTPUT v-line-rec
                      ,INPUT {&add-def}
                      ,INPUT p-bh:buffer-field("host-code"):buffer-value
                      ,INPUT p-bh:buffer-field("sttm-code"):buffer-value
                      ,INPUT 0   /*fin-doc-code*/
                      ,INPUT buf_tt-1s-fin-doc.pay-date
                      ,INPUT buf_tt-1s-fin-doc.prn-doc-code
                      ,INPUT buf_tt-1s-fin-doc.fin-ext-doc-type
                      ,input (if buf_tt-1s-fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                             then buf_tt-1s-fin-doc.receiver-bik
                             else buf_tt-1s-fin-doc.payer-bik)
                      ,input (if buf_tt-1s-fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                             then buf_tt-1s-fin-doc.receiver-bank-name
                             else buf_tt-1s-fin-doc.payer-bank-name)
                      ,input (if buf_tt-1s-fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                             then buf_tt-1s-fin-doc.receiver-bank-city
                             else buf_tt-1s-fin-doc.payer-bank-city)
                      ,input (if buf_tt-1s-fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                             then buf_tt-1s-fin-doc.receiver-c-schet
                             else buf_tt-1s-fin-doc.payer-c-schet )
                             /*корр счет кому заплатили или от кого получили*/
                      ,input (if buf_tt-1s-fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                             then buf_tt-1s-fin-doc.receiver-r-schet
                             else buf_tt-1s-fin-doc.payer-r-schet )
                      ,input (if buf_tt-1s-fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                             then buf_tt-1s-fin-doc.receiver-name
                             else buf_tt-1s-fin-doc.payer-name )
                      ,input (if buf_tt-1s-fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                             then buf_tt-1s-fin-doc.receiver-inn
                             else buf_tt-1s-fin-doc.payer-inn )
                      ,input (if buf_tt-1s-fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                             then buf_tt-1s-fin-doc.receiver-kpp
                             else buf_tt-1s-fin-doc.payer-kpp )
                      ,INPUT buf_tt-1s-fin-doc.sum-doc
                      ,INPUT {&cl-bank-1s}
                      ,input buf_tt-1s-fin-doc.naznach-plat
                        )
            no-error.
        if error-status:error then do:
          v-mess = substitute("Ошибка при включении в выписку импортированного платежа&1" +
                              "Выписка &2 Фирма &3&1Счет &4 БИК &5&1"
                              ,{&new-line}
                              ,cbnki-period-to-String(p-bh:buffer-field("start-date"):buffer-value, p-bh:buffer-field("end-date"):buffer-value)
                              ,p-bh:buffer-field("hostcode"):buffer-value
                              ,p-bh:buffer-field("r-schet"):buffer-value
                              ,p-bh:buffer-field("bik"):buffer-value)  +
                   substitute("Документ &1&2&3&2&4"
                              , buf_tt-1s-fin-doc.prn-doc-code
                              ,{&new-line}
                              , error-status:get-message(1)
                              , return-value )   .
&scop my-message v-mess
          {&display-message}.

          undo _line, next _line.
        end.
      end. /*if not available buf_tt-th-fin-doc then do:*/
      else do:
        find first buf_fin-doc no-lock where
                  buf_fin-doc.host-code = v-host-code
              and buf_fin-doc.fin-doc-code = buf_tt-th-fin-doc.fin-doc-code no-error.
        if not available buf_fin-doc then do:

        end.
        if buf_fin-doc.sttm-code = 0 then do:
          /*включим в выписку*/
          run ref/finsttml.p (
                         INPUT NO /*p-silent*/
                        ,INPUT-OUTPUT v-line-rec
                        ,INPUT {&add-def}
                        ,INPUT p-bh:buffer-field("host-code"):buffer-value
                        ,INPUT p-bh:buffer-field("sttm-code"):buffer-value
                        ,INPUT buf_tt-th-fin-doc.fin-doc-code   /*fin-doc-code*/
                        ,INPUT buf_tt-th-fin-doc.pay-date
                        ,INPUT buf_tt-th-fin-doc.prn-doc-code
                        ,INPUT buf_tt-th-fin-doc.fin-ext-doc-type
                        ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                              then buf_fin-doc.receiver-bik
                              else buf_fin-doc.payer-bik)
                        ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                              then buf_fin-doc.receiver-bank-name
                              else buf_fin-doc.payer-bank-name)
                        ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                              then buf_fin-doc.receiver-bank-city
                              else buf_fin-doc.payer-bank-city)
                        ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                              then buf_fin-doc.receiver-c-schet
                              else buf_fin-doc.payer-c-schet )
                              /*корр счет кому заплатили или от кого получили*/
                        ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                              then buf_fin-doc.receiver-r-schet
                              else buf_fin-doc.payer-r-schet )
                        ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                              then buf_fin-doc.receiver-name
                              else buf_fin-doc.payer-name )
                        ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                              then buf_fin-doc.receiver-inn
                              else buf_fin-doc.payer-inn )
                        ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                              then buf_fin-doc.receiver-kpp
                              else buf_fin-doc.payer-kpp )
                        ,INPUT buf_tt-th-fin-doc.sum-doc
                        ,INPUT {&cl-bank-1s}
                        ,input buf_tt-th-fin-doc.ps
                          )
              no-error.
          if error-status:error then do:
            v-mess = substitute("Ошибка при включении в выписку импортированного платежа&1" +
                                "Выписка &2 Фирма &3&1Счет &4 БИК &5&1"
                                ,{&new-line}
                                ,cbnki-period-to-String(p-bh:buffer-field("start-date"):buffer-value, p-bh:buffer-field("end-date"):buffer-value)
                                ,p-bh:buffer-field("hostcode"):buffer-value
                                ,p-bh:buffer-field("r-schet"):buffer-value
                                ,p-bh:buffer-field("bik"):buffer-value) +
                    substitute("Документ &1&2&3&2&4"
                                , buf_tt-1s-fin-doc.prn-doc-code
                                ,{&new-line}
                                , error-status:get-message(1)
                                , return-value ).
&scop my-message v-mess
          {&display-message}.

            undo _line, next _line.
          end.
        end. /*if not available buf_fin-statement-line then do:*/
        else do:
          if  buf_fin-doc.sttm-code = p-bh:buffer-field("sttm-code"):buffer-value then do:
            next _line.
          end.
          else do:
              /*скажем что включена в другую выписку*/
            v-mess = substitute("Не удалось включить в выписку импортированный платеж&1" +
                                "&1Платеж уже привязан к другой выписке" +
                                "Выписка &2 Фирма &3&1Счет &4 БИК &5&1"
                                ,{&new-line}
                                ,cbnki-period-to-String(p-bh:buffer-field("start-date"):buffer-value, p-bh:buffer-field("end-date"):buffer-value)
                                ,p-bh:buffer-field("hostcode"):buffer-value
                                ,p-bh:buffer-field("r-schet"):buffer-value
                                ,p-bh:buffer-field("bik"):buffer-value) +
                    substitute("Документ &1&2&3&2&4"
                                , buf_tt-1s-fin-doc.prn-doc-code
                                ,{&new-line}
                                , error-status:get-message(1)
                                , return-value ).
&scop my-message v-mess
          {&display-message}.
            undo _line, next _line.
          end.
        end. /*else if not available buf_fin-statement-line then do:*/
      end. /*else if not available buf_tt-th-fin-doc then do:*/
    end. /*for each buf_tt-1s-fin-doc no-lock where*/
  end. /*v-ii*/
  _line2:
  for each buf_fin-doc no-lock where
        buf_fin-doc.host-code = v-host-code
    and  buf_fin-doc.status_ = {&fin-fact}
    and  buf_fin-doc.fact-date >= v-start-date
    and  buf_fin-doc.fact-date <= v-end-date
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if  not (buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
    and  buf_fin-doc.payer-code-schet = p-bh:buffer-field("code-schet"):buffer-value)
    and  not (buf_fin-doc.fin-ext-doc-type = {&FDEDT_income_cashless}
    and buf_fin-doc.receiver-code-schet = p-bh:buffer-field("code-schet"):buffer-value)  then next _line2.
    if buf_fin-doc.sttm-code = 0 then do:
      /*включим в выписку*/
      run ref/finsttml.p (
                      INPUT NO /*p-silent*/
                    ,INPUT-OUTPUT v-line-rec
                    ,INPUT {&add-def}
                    ,INPUT p-bh:buffer-field("host-code"):buffer-value
                    ,INPUT p-bh:buffer-field("sttm-code"):buffer-value
                    ,INPUT buf_fin-doc.fin-doc-code   /*fin-doc-code*/
                    ,INPUT buf_fin-doc.pay-date
                    ,INPUT buf_fin-doc.prn-doc-code
                    ,INPUT buf_fin-doc.fin-ext-doc-type
                    ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                          then buf_fin-doc.receiver-bik
                          else buf_fin-doc.payer-bik)
                    ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                          then buf_fin-doc.receiver-bank-name
                          else buf_fin-doc.payer-bank-name)
                    ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                          then buf_fin-doc.receiver-bank-city
                          else buf_fin-doc.payer-bank-city)
                    ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                          then buf_fin-doc.receiver-c-schet
                          else buf_fin-doc.payer-c-schet )
                          /*корр счет кому заплатили или от кого получили*/
                    ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                          then buf_fin-doc.receiver-r-schet
                          else buf_fin-doc.payer-r-schet )
                    ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                          then buf_fin-doc.receiver-name
                          else buf_fin-doc.payer-name )
                    ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                          then buf_fin-doc.receiver-inn
                          else buf_fin-doc.payer-inn )
                    ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                          then buf_fin-doc.receiver-kpp
                          else buf_fin-doc.payer-kpp )
                    ,INPUT buf_fin-doc.sum-doc
                    ,INPUT {&cl-bank-1s}
                    ,input buf_fin-doc.ps
                      )
          no-error.
      if error-status:error then do:
        v-mess = substitute("Ошибка при включении платежа в выписку&1" +
                            "Выписка &2 Фирма &3&1Счет &4 БИК &5&1"
                            ,{&new-line}
                            ,cbnki-period-to-String(p-bh:buffer-field("start-date"):buffer-value, p-bh:buffer-field("end-date"):buffer-value)
                            ,p-bh:buffer-field("hostcode"):buffer-value
                            ,p-bh:buffer-field("r-schet"):buffer-value
                            ,p-bh:buffer-field("bik"):buffer-value) +
                substitute("Документ &1&2&3&2&4"
                            , buf_tt-1s-fin-doc.prn-doc-code
                            ,{&new-line}
                            , error-status:get-message(1)
                            , return-value ).
&scop my-message v-mess
      {&display-message}.

        undo _line2, next _line2.
      end.
    end. /*if not available buf_fin-statement-line then do:*/
    else do:
      if  buf_fin-doc.sttm-code = p-bh:buffer-field("sttm-code"):buffer-value then do:
        next _line2.
      end.
      else do:
          /*скажем что включена в другую выписку*/
        v-mess = substitute("Не удалось включить платеж в выписку&1" +
                            "&1Платеж уже привязан к другой выписке" +
                            "Выписка &2 Фирма &3&1Счет &4 БИК &5&1"
                            ,{&new-line}
                            ,cbnki-period-to-String(p-bh:buffer-field("start-date"):buffer-value, p-bh:buffer-field("end-date"):buffer-value)
                            ,p-bh:buffer-field("hostcode"):buffer-value
                            ,p-bh:buffer-field("r-schet"):buffer-value
                            ,p-bh:buffer-field("bik"):buffer-value) +
                substitute("Документ &1&2&3&2&4"
                            , buf_tt-1s-fin-doc.prn-doc-code
                            ,{&new-line}
                            , error-status:get-message(1)
                            , return-value ).
&scop my-message v-mess
      {&display-message}.
        undo _line2, next _line2.
      end.
    end. /*else if not available buf_fin-statement-line then do:*/
  end.
end. /*doe*/

end procedure. /* proc-insert-statement-lines */

procedure proc-create-fin-statement :
define parameter buffer buf_tt-th-fin-statement for tt-th-fin-statement.

define variable v-doc-rec as recid no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_fin-statement for ub.fin-statement.


  do
  on error undo, return error
  :
    /*в буфере buf_tt-th-fin-statement некоторые поля уже заполнены*/

    run cur-time in this-procedure ( output v-today, output v-time).
    assign
    buf_tt-th-fin-statement.prn-doc-code = cbnki-period-to-String(tt-th-fin-statement.start-date
                                                                  ,tt-th-fin-statement.end-date)
    buf_tt-th-fin-statement.status_      = {&fin-new}
    buf_tt-th-fin-statement.doc-date     = v-today
    buf_tt-th-fin-statement.sum-doc      = buf_tt-th-fin-statement.in-sum-doc - buf_tt-th-fin-statement.out-sum-doc
    buf_tt-th-fin-statement.fins-ext-doc-type = {&FSEDT_standard-sttm}
    .
&scop prfx buf_tt-th-fin-statement.
 run ref/finsttm0.p
                 (input yes   /*silent*/
                 ,input-output v-doc-rec
                 ,input  {&add-def}
                 ,input  {&cl-bank-1s} /*p-author*/
                 {&all-fin-statement-params-doc-status-transfer}
                 ,input buf_tt-th-fin-statement.status_
                 ,input no /*p-lines-exist*/
                 ) no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.
    else do:
      assign
      p-created-statement = p-created-statement + 1
      .
      find first buf_fin-statement no-lock where
                recid(buf_fin-statement) = v-doc-rec.
      assign
      buf_tt-th-fin-statement.sttm-code = buf_fin-statement.sttm-code
      .
    end.
  end. /*doe*/


end procedure. /* proc-create-fin-statement */