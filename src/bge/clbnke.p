block-level on error undo, throw.
/*

$Revision: cb1b05444cdf, 212, rls $
$Author: EShklyar $
$Date: Tue Jun 30 11:12:07 2015 +0400 $
$Workfile: clbnke.p $
$Archive: bge/clbnke.p $

ЭКСПОРТ в систему КЛИЕНТ-БАНК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/19/05
Author: Bakhtadze Natalya
Creation date: 07/19/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character        no-undo.
/*p-parameter включает в себ
*/
define variable p-auto                  as integer      no-undo.
define variable p-curr-host-code        as integer      no-undo.
define variable p-rs-1                  as integer      no-undo.
define variable p-rs-hsch               as integer      no-undo.
define variable p-rs-csch               as integer      no-undo.
define variable p-format                as character    no-undo.
/*формат выгрузки - пока может быть только  {&cl-bank-1s} */
define variable p-encoding              as character    no-undo.

/*
define variable p-days-amount           as integer      no-undo.
define variable p-rs-date               as integer      no-undo.
define variable p-days-ago              as integer      no-undo.
*/
define variable p-date-from             as date         no-undo.
define variable p-date-to               as date         no-undo.
define variable p-doc-type-list         as character no-undo .



define variable vss-revision    as character no-undo init "$Revision: cb1b05444cdf, 212, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Jun 30 11:12:07 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clbnke.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/clbnke.p $":U .
define variable vss-description as character no-undo init "ЭКСПОРТ в систему КЛИЕНТ-БАНК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ cmp/ini-lib.i }
{ bge/clbnkd.i "SHARED" }
{ bge/clbnkd.i "hfields" }
{ ref/fd-attr.i force-history }
{ trg/f-docath.i }

define variable v-input-error as logical no-undo .
define variable v-view-log as logical no-undo .
define variable v-esm as character no-undo .
define variable v-date-range as character no-undo .
define variable log-file-name as character no-undo init 'ext-cbnk.log'.
define stream PrnLibStream.


&scop display-message   run write-log-and-file in p-log-handle (                             ~
                                                                  input 1                    ~
                                                                , input log-file-name        ~
                                                                , input 1                    ~
                                                                , input ~{&my-message~})

&glob view-log  ~{ str/cdviewlg.i                                                              ~
"substitute('!!!В процессе Экспорта в систему КЛИЕНТ-БАНК  произошли ошибки!!!')"          ~
"'ext-cbnk.log'" not-delete ~}


if num-entries(p-parameter, {&delim-par}) <> 4
then do:
  assign
  v-input-error = yes
  v-esm         = substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 3"
                             , num-entries(p-parameter, {&delim-par})).
  .
end.
else do:
  if num-entries(entry(2, p-parameter, {&delim-par})) <> 9
  then do:
    assign
    v-input-error = yes
    v-esm         = substitute("Неверное количество ENTRY в 2-ом ENTRY составного параметре - &1, должно быть 9"
                              , num-entries(entry(1, p-parameter, {&delim-par}))).
    .

  end.
  if num-entries(entry(3, p-parameter, {&delim-par})) <> 5
  then do:
    assign
    v-input-error = yes
    v-esm         = substitute("Неверное количество ENTRY в 3-ом ENTRY составного параметре - &1, должно быть 5"
                              , num-entries(entry(2, p-parameter, {&delim-par}))).
    .

  end.

  assign
  p-auto = integer(entry(1, p-parameter, {&delim-par}) )
  p-format  = entry( 1, entry(2, p-parameter, {&delim-par}) )
  p-encoding  = entry( 2, entry(2, p-parameter, {&delim-par}) )
  p-rs-1 = integer( entry( 3, entry(2, p-parameter, {&delim-par})) )
  p-curr-host-code = integer(entry(4, entry(2, p-parameter, {&delim-par})))
  /*p-action пропускаем и так ясно :)*/
  p-rs-hsch = integer( entry( 6, entry(2, p-parameter, {&delim-par}) ) )
  p-rs-csch = integer( entry( 7, entry(2, p-parameter, {&delim-par}) ) )
  v-date-range = entry(3, p-parameter, {&delim-par})
  p-doc-type-list = entry(4, p-parameter, {&delim-par})
  /*
  p-rs-date       = integer( entry( 1, entry(2, p-parameter, {&delim-par}) ) )
  p-days-amount   = integer( entry( 2, entry(2, p-parameter, {&delim-par}) ) )
  p-days-ago      = integer( entry( 3, entry(2, p-parameter, {&delim-par}) ) )
  p-date-from     = date( entry( 4, entry(2, p-parameter, {&delim-par}) ) )
  p-date-to       = date( entry( 5, entry(2, p-parameter, {&delim-par}) ) )
  */
  no-error .
  if error-status:error then do:
    assign
    v-esm = error-status:get-message(1)
    v-input-error = yes
    .
  end.
end.

if v-input-error = yes then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , v-esm
                         , return-value
                         )).
  assign
  v-view-log = yes.
  return.
end.
if p-rs-1 <> 1
and p-rs-1 <> 2 then do:
  v-esm = substitute("Неизвестное значение параметра выбора фирмы:&1", p-rs-1).
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , v-esm
                         , return-value
                         )).
  assign
  v-view-log = yes.
  return.
end.
if p-rs-1 <> 2
and (p-rs-hsch <> 1
     or
     p-rs-csch <> 1)
then do:
  v-esm = substitute("Несопоставимые значения параметра выбора фирмы (&1)" +
                     " и параметра выбора счетов фирмы (&2)" +
                     " и/или параметра выбора счетов контрагента (&3)"
                     , p-rs-1
                     , p-rs-hsch
                     , p-rs-csch
                     ).
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , v-esm
                         , return-value
                         )).
  assign
  v-view-log = yes.
  return.
end.
run analyze-date-range in this-procedure (
    input v-date-range
    , output p-date-from
    , output p-date-to
) no-error.
if error-status :error
or p-date-from  = ?
or p-date-to    = ?
then do:

  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input  substitute( "Ошибка входных параметров:Не удалось определить интервал дат для выгрузки.&1&2 &3"
                                    , {&new-line}
                                    , return-value
                                    , error-status :get-message( 1 )
                                )
                                         ).
  assign
  v-view-log = yes.
  return.
end.

&glob cl-bank-code p-format

CASE p-format:
  when {&cl-bank-1s} then do:
     run proc-main-1s in this-procedure no-error .
  end.
END CASE.

if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка при экспорте данных в систему КЛИЕНТ-БАНК в формате&1&2&3 &4"
                         , {&cl-bank-name}
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
  return "error":U.
end.
{&view-log}.



procedure proc-main-1s :
/*выгрузка в формате 1s*/
define buffer buf_sysconf for ub.sysconf.
define buffer buf_fin-doc for ub.fin-doc.
define variable v-count as integer no-undo .
define variable ii as integer no-undo .


  do
  on error undo, return error return-value
  :

&scop my-message substitute("Экспорт документов в систему КЛИЕНТ-БАНК по формату &1", {&cl-bank-name})
    {&display-message}.

    if p-rs-1 = 1 then do:
&scop my-message substitute("     Фирмы: Все")
      {&display-message}.
    end.
    else do:
&scop my-message substitute("     Фирмы:")
      {&display-message}.
      for each temp_obj-list no-lock:
        &scop my-message substitute("     &1&2", temp_obj-list.obj-type, temp_obj-list.obj-code)
              {&display-message}.
      end.
    end.
    if p-rs-hsch = 1 then do:
&scop my-message substitute("     Счета фирм: Все")
      {&display-message}.
    end.
    else do:
&scop my-message substitute("     Счета фирм:")
      {&display-message}.
      for each temp_hfin-schet no-lock:
        &scop my-message  SUBSTITUTE("&1 &2&3 &4/&5",           ~
                               temp_hfin-schet.r-schet          ~
                              ,temp_hfin-schet.cli-type         ~
                              ,temp_hfin-schet.cli-code         ~
                              ,temp_hfin-schet.code-bank        ~
                              ,temp_hfin-schet.code-schet)
              {&display-message}.
      end.
    end.
    if p-rs-csch = 1 then do:
&scop my-message substitute("     Счета контрагентов: Все")
      {&display-message}.
    end.
    else do:
&scop my-message substitute("     Счета контрагентов:")
      {&display-message}.
      for each temp_cfin-schet no-lock:
        &scop my-message  SUBSTITUTE("&1 &2&3 &4/&5",           ~
                               temp_cfin-schet.r-schet          ~
                              ,temp_cfin-schet.cli-type         ~
                              ,temp_cfin-schet.cli-code         ~
                              ,temp_cfin-schet.code-bank        ~
                              ,temp_cfin-schet.code-schet)
              {&display-message}.
      end.
    end.
&scop my-message substitute("     Типы документов:")
    {&display-message}.
&scop fin-ext-doc-type-code entry(ii, p-doc-type-list)
     do ii = 1 to num-entries(p-doc-type-list):
&scop my-message substitute("&1", ~{&fin-ext-doc-type-name~} )
    {&display-message}.
     end.
&scop my-message substitute("     Интервал дат: с &1 по &2", string(p-date-from, "99/99/9999"), string(p-date-to, "99/99/9999"))
    {&display-message}.
&scop my-message substitute("     Кодировка: &1",  if p-encoding = "windows-1251" then 'Windows' else 'DOS')
    {&display-message}.
     _buf_sysconf:
     for each buf_sysconf  no-lock:
       if p-rs-1 = 2 then do:
         find first temp_obj-list no-lock where
                    temp_obj-list.obj-type = {&cmp}
                AND temp_obj-list.obj-code = buf_sysconf.host-code no-error .
         if not available temp_obj-list then next _buf_sysconf.
       end.

       do ii = 1 to num-entries(p-doc-type-list):
        /*INDEX iext-type-status*/
        _buf_fin-doc:
        for each buf_fin-doc no-lock where
                buf_fin-doc.host-code = buf_sysconf.host-code
            AND  buf_fin-doc.fin-ext-doc-type = entry(ii, p-doc-type-list)
            and status_ = {&fin-bank}
            and buf_fin-doc.doc-date >= p-date-from
            AND buf_fin-doc.doc-date <= p-date-to:
          if p-rs-hsch = 2  then do:
            /*счета фирмы выборочно*/
            find first temp_hfin-schet no-lock where
                      temp_hfin-schet.host-code = buf_sysconf.host-code
                  AND temp_hfin-schet.code-schet = buf_fin-doc.payer-code-schet no-error.
            if not available temp_hfin-schet then next _buf_fin-doc.
          end.
          if p-rs-csch = 2  then do:
            /*счета контрагентов выборочно*/
            find first temp_cfin-schet no-lock where
                      temp_cfin-schet.host-code = buf_sysconf.host-code
                  AND temp_cfin-schet.code-schet = buf_fin-doc.receiver-code-schet no-error.
            if not available temp_cfin-schet then next _buf_fin-doc.
          end.
          find first temp-bik where
                    temp-bik.host-code = buf_fin-doc.host-code
                AND temp-bik.bik = buf_fin-doc.payer-bik no-error.
          if not available temp-bik then do:
            run export-header-1s in this-procedure (
                                                    input buf_fin-doc.host-code
                                                  , input buf_fin-doc.payer-bik
                                                    ) no-error .
            if error-status:error then do:
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input  substitute( "!!!Ошибка записи заголовка файла для выгрузки в формате &1&2 Фирма &3 Банк с БИК &4&2&5 &6&2" +
                                       "!!!Финдокументы по фирме &3 БИК &4 экспортироваться не будут!"
                                                , {&cl-bank-name}
                                                , {&new-line}
                                                , buf_fin-doc.host-code
                                                , buf_fin-doc.payer-bik
                                                , return-value
                                                , error-status :get-message( 1 )
                                            )
                                                    ).
              assign
              v-view-log = yes.
            end. /*if error-status:error then do:*/
          end. /*  if not availabe temp-bik        */
          find first temp-bik where
                    temp-bik.host-code = buf_fin-doc.host-code
                AND temp-bik.bik = buf_fin-doc.payer-bik no-error.
          if not available temp-bik
          or temp-bik.f_name = '':U then next _buf_fin-doc.
          CASE buf_fin-doc.fin-ext-doc-type:
            when {&FDEDT_Expense_Cashless} then do:
              run export-fin-doc-ec-1s in this-procedure (
                                                        buffer buf_fin-doc
                                                      , input temp-bik.f_name
                                                      , input temp-bik.adresat
                                                      ) no-error .
            end.
          END CASE.
          if error-status:error then do:
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input  substitute( "Ошибка экспорта финдокумента &5 при выгрузке в формате &1&2&3 &4"
                                                , {&cl-bank-name}
                                                , {&new-line}
                                                , return-value
                                                , error-status :get-message( 1 )
                                                , buf_fin-doc.prn-doc-code
                                            )
                                                    ).
            assign
            v-view-log = yes.
            NEXT _buf_fin-doc.
          end. /*if error-status:error then do:*/
          else do:
            assign
            v-count = v-count + 1
            temp-bik.d-count = temp-bik.d-count + 1
            .
            run show-counter in p-log-handle .
            run write-counter in p-log-handle (substitute("Экспорт БИК &1 Фирма &2: экспортировано документов &3"
                                            , temp-bik.bik
                                            , temp-bik.host-code
                                            , temp-bik.d-count)).
          end.
        end. /*_buf_fin-doc:*/
      end.
    end. /*for each buf_sysconf  no-lock,*/
    ii = 0.
    for each temp-bik no-lock:
      if temp-bik.f_name = '':U then next.
      run export-footer-1s in this-procedure (
                                              input temp-bik.host-code
                                            , input temp-bik.bik
                                            , input temp-bik.f_name
                                            , input temp-bik.o_name
                                            , input temp-bik.d-count).
      assign
      ii = 1.
    end.
    if ii = 0 then do:
&scop my-message "!!!Не удалось экспортировать финдокументы или найдено ни одного финдокумента для экспорта"
      {&display-message}.
    end.
  end.

end procedure. /* proc-main-1s */

procedure export-header-1s :
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-bik       like ub.fin-bank.bik no-undo .

define variable loc-in_ as character no-undo .
define variable loc-spl as character no-undo .
define variable loc-sav as character no-undo .
define variable loc-out as character no-undo .
define variable loc-adresat as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable ii as integer no-undo .
define variable v-doc-type-1s as character no-undo .
define variable v-version as character no-undo .

define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_temp_hfin-schet for temp_hfin-schet.
define buffer find_first-fin-bank for ub.fin-bank.

  do
  on error undo, return error
  :
    find first buf_fin-bank no-lock where
                buf_fin-bank.host-code = p-host-code
            AND buf_fin-bank.bik = p-bik.
    create temp-bik.
    assign
    temp-bik.host-code = p-host-code
    temp-bik.bik       = p-bik
    .
    /*определим директории для выгрузки*/
    run bge/cbnkinis.p (
                         input parparentproc
                       , input p-format
                       , input p-bik
                       , input p-host-code
                       , input "send":U /*некий параметр который говорит для чего нам настройки*/
                       , output loc-out
                       , output LOC-in_
                       , output LOC-spl
                       , output LOC-sav
                       , output loc-adresat
                       )  no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Не удалось получить настройки для системы КЛИЕНТ-БАНК формата &1 для БИК &2 фирма &3 из ini-файла:&4&5 &6"
                              , p-format
                              , p-bik
                              , p-host-code
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value)).
      assign
      v-view-log = yes.
      undo,  return error.
    end.
    /**/
    assign
    temp-bik.f_name = substitute("&1&2\&3.dat", loc-out, loc-spl, substring( string( next-value( s-spool, {&db-name_schema}), '99999999999999999999'), 13, 8 ), '.dat')
    temp-bik.o_name = substitute("&1&2\&3", loc-out, loc-spl , '1C_to_KL.txt')
    temp-bik.adresat = loc-adresat
    .
    if p-encoding <> 'windows-1251' then do:
      output stream PrnLibStream
      to value(  temp-bik.f_name ) convert target p-encoding.
    end.
    else do:
      output stream PrnLibStream
      to value(  temp-bik.f_name ) .
    end.

    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).

    run gbl/getvers.p (output v-version).
    v-version = substitute('IBS TH &1', v-version).
    put stream PrnLibStream unformatted
    '1CClientBankExchange' skip
    'ВерсияФормата=1.01'   skip
    'Кодировка=' (if p-encoding = 'windows-1251' then 'Windows':U else 'DOS') skip
    'Отправитель=' v-version skip
    'Получатель=' loc-adresat skip
    'ДатаСоздания=' string(v-today, "99/99/9999") skip
    'ВремяСоздания=' string(v-time, "HH:MM:SS") skip
    'ДатаНачала=' string(p-date-from, "99/99/9999") skip
    'ДатаКонца=' string(p-date-to, "99/99/9999") skip
    .
    _buf_fin-schet:
    FOR EACH find_first-fin-bank no-lock where
            find_first-fin-bank.host-code = p-host-code
        AND find_first-fin-bank.bik       = p-bik
        AND find_first-fin-bank.status_   = {&current-status},
       each buf_fin-schet no-lock where
            buf_fin-schet.host-code = p-host-code
       AND  buf_fin-schet.code-bank = find_first-fin-bank.code-bank
       AND  buf_fin-schet.status_       = {&current-status}:
      if p-rs-csch = 2 then do:
          find first buf_temp_hfin-schet no-lock where
                    buf_temp_hfin-schet.host-code = buf_fin-schet.host-code
                AND buf_temp_hfin-schet.code-schet = buf_fin-schet.code-schet no-error.
          if not available buf_temp_hfin-schet then next _buf_fin-schet.
      end.
      put stream PrnLibStream unformatted
      'РасчСчет='  buf_fin-schet.r-schet skip
      .
    end.
    do ii = 1 to num-entries(p-doc-type-list):
      CASE entry(ii, p-doc-type-list):
        when {&FDEDT_Expense_Cashless} then do:
          v-doc-type-1s =  'Платежное поручение'.
        end.
      END CASE.
      put stream PrnLibStream unformatted
      'Документ='  v-doc-type-1s skip.
      .
    end.
&scop my-message substitute("БИК &1 Фирма &2 - файл экспорта &3" ~
                     ,temp-bik.bik                                                                ~
                     ,temp-bik.host-code                                                          ~
                     ,temp-bik.o_name                                                             ~
                     )
    output stream PrnLibStream close.

  end.

end procedure. /* export-header-1s */

procedure export-fin-doc-ec-1s :
define parameter buffer buf_fin-doc for ub.fin-doc.
define input parameter p-f_name as character no-undo .
define input parameter p-adresat as character no-undo .

define variable h_fin-doc as handle no-undo .
define variable h_field as handle no-undo .

define buffer locked_fin-doc for ub.fin-doc.
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_rfin-bank for ub.fin-bank.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_rfin-schet for ub.fin-schet.

  do
  on error undo, return error
  :
    find first locked_fin-doc where
               recid(locked_fin-doc) = recid(buf_fin-doc).
    if p-encoding <> 'windows-1251' then do:
      output stream PrnLibStream
      to value(  p-f_name ) convert target p-encoding append.
    end.
    else do:
      output stream PrnLibStream
      to value(  p-f_name ) append.
    end.
    find first buf_fin-schet no-lock where
              buf_fin-schet.host-code = buf_fin-doc.host-code
          AND buf_fin-schet.code-schet = buf_fin-doc.payer-code-schet .
    if buf_fin-schet.status_ <> {&current-status} then do:
&scop my-message substitute("!!!Финдокумент &1 (фирма &2)&3Счет Плательщика имеет статус &4&3Экспорт невозможен" ~
                            , buf_fin-doc.prn-doc-code                                                           ~
                            , buf_fin-doc.host-code                                                              ~
                            , ~{&new-line~}                                                                      ~
                            ,buf_fin-schet.status_                                                                )

      {&display-message}.
      output stream PrnLibStream close.
      return.
    end.
    find first buf_fin-bank no-lock where
              buf_fin-bank.host-code = buf_fin-doc.host-code
          AND buf_fin-bank.code-bank = buf_fin-schet.code-bank .
    if buf_fin-bank.status_ <> {&current-status} then do:
&scop my-message substitute("!!!Финдокумент &1 (фирма &2)&3Банк Плательщика имеет статус &4&3Экспорт невозможен" ~
                            , buf_fin-doc.prn-doc-code                                                           ~
                            , buf_fin-doc.host-code                                                              ~
                            , ~{&new-line~}                                                                      ~
                            ,buf_fin-bank.status_                                                                )

      {&display-message}.
      output stream PrnLibStream close.
      return.
    end.
    find first buf_rfin-schet no-lock where
              buf_rfin-schet.host-code = buf_fin-doc.host-code
          AND buf_rfin-schet.code-schet = buf_fin-doc.receiver-code-schet .
    if buf_rfin-schet.status_ <> {&current-status} then do:
&scop my-message substitute("!!!Финдокумент &1 (фирма &2)&3Счет Получателя имеет статус &4&3Экспорт невозможен"  ~
                            , buf_fin-doc.prn-doc-code                                                           ~
                            , buf_fin-doc.host-code                                                              ~
                            , ~{&new-line~}                                                                      ~
                            ,buf_rfin-schet.status_                                                                )
      {&display-message}.
      output stream PrnLibStream close.
      return.
    end.
    find first buf_rfin-bank no-lock where
              buf_rfin-bank.host-code = buf_fin-doc.host-code
          AND buf_rfin-bank.code-bank = buf_rfin-schet.code-bank .
    if buf_fin-bank.status_ <> {&current-status} then do:
&scop my-message substitute("!!!Финдокумент &1 (фирма &2)&3Банк Получателя имеет статус &4&3Экспорт невозможен" ~
                            , buf_fin-doc.prn-doc-code                                                           ~
                            , buf_fin-doc.host-code                                                              ~
                            , ~{&new-line~}                                                                      ~
                            ,buf_rfin-bank.status_                                                                )

      {&display-message}.
      output stream PrnLibStream close.
      return.
    end.
    assign
    h_fin-doc = buffer locked_fin-doc:handle
    .
    find first temp_hfields no-lock no-error.
    if not available temp_hfields then do:
      run create-temp-hfields in this-procedure ('exp').
    end.
    put stream PrnLibStream unformatted
    'СекцияДокумент=Платежное поручение' skip.
    for each temp_hfields by temp_hfields.order_:
      CASE temp_hfields.name_:
        when 'doc-date' then do:
          put stream PrnLibStream unformatted
          temp_hfields.label_ string(h_fin-doc:buffer-field(temp_hfields.name_):buffer-value, "99.99.9999") skip
          .
        end.
        when 'sum-doc' then do:
          put stream PrnLibStream unformatted
          temp_hfields.label_ trim(string(h_fin-doc:buffer-field(temp_hfields.name_):buffer-value, ">>>>>>>>>>>>9.99")) skip
          .
        end.
        when "payer-inn/payer-name"
        OR
        WHEN "RECEIVER-inn/RECEIVER-name"
        then do:
          put stream PrnLibStream unformatted
          temp_hfields.label_
          substitute("{&abbr_inn_allshift} &1 &2"
                      ,h_fin-doc:buffer-field(entry(1, temp_hfields.name_, {&slash-char})):buffer-value
                      ,h_fin-doc:buffer-field(entry(2, temp_hfields.name_, {&slash-char})):buffer-value
                    )
          skip
          .
        end.
        when 'naznach-plat/' then do:
          put stream PrnLibStream unformatted
          temp_hfields.label_
          replace(h_fin-doc:buffer-field(entry(1, temp_hfields.name_, {&slash-char})):buffer-value, '@', '')
          skip.
        end.
        otherwise do:
          if h_fin-doc:buffer-field(temp_hfields.name_):data-type = 'date':U then do:
            put stream PrnLibStream unformatted
            temp_hfields.label_ string(h_fin-doc:buffer-field(temp_hfields.name_):buffer-value, "99.99.9999") skip
            .
          end.
          else do:
            put stream PrnLibStream unformatted
            temp_hfields.label_ h_fin-doc:buffer-field(temp_hfields.name_):buffer-value skip
            .
          end.
        end.
      END CASE.
    end.
    put stream PrnLibStream unformatted
    'КонецДокумента' skip.
    output stream PRnLibStream close.
    assign
    locked_fin-doc.pay-author = p-adresat.
  end.

end procedure. /* export-fin-doc-ec-1s */


procedure export-footer-1s :
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-bik       like ub.fin-bank.bik      no-undo .
define input parameter p-f_name    as character no-undo .
define input parameter p-o_name    as character no-undo .
define input parameter p-count     as integer no-undo .
define variable v-os-err as integer no-undo .
define variable v-os-err-name as character no-undo .

  do
  on error undo, return error
  :

    if p-encoding <> 'windows-1251' then do:
      output stream PrnLibStream
      to value(  p-f_name ) convert target p-encoding append.
    end.
    else do:
      output stream PrnLibStream
      to value(  p-f_name ) append.
    end.
    put stream PrnLibStream unformatted
    'КонецФайла'
    skip.
    output stream PRnLibStream close.
    OS-RENAME value(p-f_name ) value(p-o_name).
    assign
    v-os-err = os-error.
    if v-os-err <> 0 then do:
      if v-os-err <> 10 then do:
       run gbl/os-errnm.p (v-os-err, output v-os-err-name).
      end.
&scop my-message substitute("БИК &1 Фирма &2&4 - файл экспорта &3:&4экспортировано документов: &5&4" +  ~
                            "!!!Не удалось сохранить файл с именем &6:&4&7" ~
                     ,p-bik                                                                ~
                     ,p-host-code                                                          ~
                     ,p-f_name                                                             ~
                     ,~{&new-line~}                                                         ~
                     ,p-count                                                              ~
                     ,p-o_name                                                             ~
                     ,(if v-os-err = 10 then 'Возможно не был перемещен файл, полученный в предудыщем сеансе экспорта' else v-os-err-name ))

       {&display-message}.
    end.
    else do:
&scop my-message substitute("БИК &1 Фирма &2&4 - файл экспорта &3:&4экспортировано документов: &5" ~
                     ,p-bik                                                                ~
                     ,p-host-code                                                          ~
                     ,p-o_name                                                             ~
                     ,~{&new-line~}                                                         ~
                     ,p-count)
      {&display-message}.
    end.
  end.

end procedure. /* export-footer-1s */


procedure analyze-date-range :
do
on error undo, return error
:
define input parameter p-date-range  as character    no-undo.
define output parameter p-date-from  as date         no-undo.
define output parameter p-date-to    as date         no-undo.

    define variable v-today         as date      no-undo.
    define variable v-time          as integer   no-undo.
    define variable v-days-ago      as integer       no-undo.
    define variable v-days-amount   as integer       no-undo.
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).

    case entry( 1, p-date-range )
    :
        when "0"
        then do:
            assign
                v-days-ago    = integer( entry( 3, p-date-range ) )
                v-days-amount = integer( entry( 2, p-date-range ) )
            .
            assign
                p-date-from = v-today - v-days-ago
                p-date-to   = v-today - v-days-ago + v-days-amount
            .
            if p-date-to > v-today
            then do:
                assign
                  p-date-to = v-today
                .
            end.
        end.
        when "1"
        then do:
            assign
                p-date-from = date( entry( 4, p-date-range ) )
                p-date-to   = v-today
            .
        end.
        when "2"
        then do:
            assign
                p-date-from = date( entry( 4, p-date-range ) )
                p-date-to   = date( entry( 5, p-date-range ) )
            .
        end.
        otherwise do:
            assign
                p-date-from = ?
                p-date-to   = ?
            .
        end.
    end case.
end.
end procedure. /* analyze-date-range */