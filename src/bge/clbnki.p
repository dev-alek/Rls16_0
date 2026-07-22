block-level on error undo, throw.
/*

$Revision: cb1b05444cdf, 212, rls $
$Author: EShklyar $
$Date: Tue Jun 30 11:12:07 2015 +0400 $
$Workfile: clbnki.p $
$Archive: bge/clbnki.p $

ИМПОРТ из системы КЛИЕНТ-БАНК

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
define variable p-format                as character    no-undo.
/*формат выгрузки - пока может быть только  {&cl-bank-1s} */
define variable p-encoding              as character    no-undo.
define variable p-rs-1                  as integer      no-undo.
define variable p-rs-hsch               as integer      no-undo.
define variable p-create                as logical no-undo .
define variable p-no-th-create          as logical no-undo .



define variable vss-revision    as character no-undo init "$Revision: cb1b05444cdf, 212, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Jun 30 11:12:07 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clbnki.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/clbnki.p $":U .
define variable vss-description as character no-undo init "ИМПОРТ из системы КЛИЕНТ-БАНК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i NEW }
{ gbl/prn-lib.i }
{ cmp/ini-lib.i }
{ bge/clbnkd.i "SHARED" }
{ bge/clbnkd.i "hfields" "NEW SHARED" }

define variable v-input-error as logical no-undo .
define variable v-view-log as logical no-undo .
define variable v-esm as character no-undo .
define variable log-file-name as character no-undo init 'ext-cbnk.log'.

&scop display-message   run write-log-and-file in p-log-handle (                             ~
                                                                  input 1                    ~
                                                                , input log-file-name        ~
                                                                , input 1                    ~
                                                                , input ~{&my-message~})

&glob view-log  ~{ str/cdviewlg.i                                                              ~
"substitute('!!!В процессе Импорта из системы КЛИЕНТ-БАНК  произошли ошибки!!!')"          ~
"'ext-cbnk.log'" not-delete ~}


if num-entries(p-parameter, {&delim-par}) <> 4
then do:
  assign
  v-input-error = yes
  v-esm         = substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 4"
                             , num-entries(p-parameter, {&delim-par})).
  .
end.
else do:
  if num-entries(entry(2, p-parameter, {&delim-par})) <> 9
  then do:
    assign
    v-input-error = yes
    v-esm         = substitute("Неверное количество ENTRY в 2-ом ENTRY составного параметре - &1, должно быть 9"
                              , num-entries(entry(2, p-parameter, {&delim-par}))).
    .

  end.
  if num-entries(entry(3, p-parameter, {&delim-par})) <> 5
  then do:
    assign
    v-input-error = yes
    v-esm         = substitute("Неверное количество ENTRY в 3-ом ENTRY составного параметре - &1, должно быть 5"
                              , num-entries(entry(3, p-parameter, {&delim-par}))).
    .

  end.

  assign
  p-auto = integer(entry(1, p-parameter, {&delim-par}) )
  p-format  = entry( 1, entry(2, p-parameter, {&delim-par}) )
  p-encoding  = entry( 2, entry(2, p-parameter, {&delim-par}) )
  p-rs-1 = integer( entry( 3, entry(2, p-parameter, {&delim-par})) )
  p-curr-host-code = integer(entry(4, entry(2, p-parameter, {&delim-par})))
  p-rs-hsch = integer( entry( 6, entry(2, p-parameter, {&delim-par}) ) )
  p-create  = logical( entry( 8, entry(2, p-parameter, {&delim-par}) ) )
  p-no-th-create  = (if num-entries(entry(2, p-parameter, {&delim-par})) > 8
                     and p-create = no
                     then logical( entry( 9, entry(2, p-parameter, {&delim-par}) ) )
                     else no)
  /*p-action пропускаем и так ясно :)*/
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
and p-rs-hsch <> 1
then do:
  v-esm = substitute("Несопоставимые значения параметра выбора фирмы (&1)" +
                     " и параметра выбора счетов фирмы (&2)"
                     , p-rs-1
                     , p-rs-hsch
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


&glob cl-bank-code p-format

run proc-main in this-procedure no-error .

if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка при импорте данных из системы КЛИЕНТ-БАНК в формате&1&2&3 &4"
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


procedure proc-main :
/*выгрузка в формате 1s*/
define buffer buf_sysconf for ub.sysconf.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_fin-bank for ub.fin-bank.
define variable ii as integer no-undo .
define variable v-count as integer no-undo .
define variable v-processed as integer no-undo .
define variable v-created as integer no-undo .
define variable v-count-statement as integer no-undo .
define variable v-processed-statement as integer no-undo .
define variable v-created-statement as integer no-undo .

define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .



  do
  on error undo, return error return-value
  :

&scop my-message substitute("Импорт документов из системы КЛИЕНТ-БАНК по формату &1", {&cl-bank-name})
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
       _buf_fin-schet:
       for each buf_Fin-schet no-lock where
               buf_fin-schet.host-code = buf_sysconf.host-code
           AND buf_fin-schet.cli-type  = {&cmp}
           AND buf_fin-schet.cli-code  = buf_sysconf.host-code
           and buf_fin-schet.status_   = {&current-status}:
          if p-rs-hsch = 2  then do:
            /*счета фирмы выборочно*/
            find first temp_hfin-schet no-lock where
                      temp_hfin-schet.host-code = buf_sysconf.host-code
                  AND temp_hfin-schet.code-schet = buf_fin-schet.code-schet
                  AND temp_hfin-schet.code-bank = buf_fin-schet.code-bank  no-error.
            if not available temp_hfin-schet then next _buf_fin-schet.
          end.
          else do:
          end.
          find first buf_fin-bank no-lock where
                    buf_fin-bank.host-code = buf_sysconf.host-code
                AND buf_fin-bank.code-bank = buf_fin-schet.code-bank.
          find first temp-bik where
                    temp-bik.host-code = buf_sysconf.host-code
                AND temp-bik.bik       = buf_fin-bank.bik no-error.
          if not available temp-bik then do:
             run get-inis-from-bik-host in this-procedure (
                                                           input buf_sysconf.host-code
                                                          ,input buf_fin-bank.bik
                                                          ,input buf_fin-bank.code-bank) no-error .
             if error-status:error then do:
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input  substitute( "!!!Ошибка получения пути к файлу импорта для загрузки в формате &1&2 Фирма &3 Банк с БИК &4&2&5 &6&2" +
                                       "!!!Финдокументы по фирме &3 БИК &4 импортироваться не будут!"
                                                , {&cl-bank-name}
                                                , {&new-line}
                                                , buf_fin-bank.host-code
                                                , buf_fin-bank.bik
                                                , return-value
                                                , error-status :get-message( 1 )
                                            )
                                                    ).
              assign
              v-view-log = yes.
             end. /*if error-status:error then do:*/
          end. /*if not available temp-bik then do:*/
          find first temp-bik where
                    temp-bik.host-code = buf_sysconf.host-code
                AND temp-bik.bik       = buf_fin-bank.bik no-error.
          if not available temp-bik
          or temp-bik.o_name = '':u then next _buf_fin-schet.
       end. /*for each buf_Fin-schet no-lock where*/
     end. /*for each buf_sysconf*/
    /*теперь имеем таблицу temp-bik в которой прописаны все пути к файлам*/
    _temp-bik:
    for each temp-bik:
      run gbl/filename.p (
                      input temp-bik.o_name
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
      if error-status:error then do:
&scop my-message substitute("!!!Отсутствует файл &1 для импорта&2банк с БИК &3 фирма &4"   ~
                        ,temp-bik.o_name                                                   ~
                        ,~{&new-line~}                                                     ~
                        ,temp-bik.bik                                                      ~
                        ,temp-bik.host-code)
        {&display-message}.
        delete temp-bik.
        assign
        v-view-log = yes.
        next _temp-bik.
      end.
      CASE p-format:
        when {&cl-bank-1s} then do:
          find first temp_hfields no-lock no-error.
          if not available temp_hfields then do:
            run create-temp-hfields in this-procedure ('imp').
          end.
          run bge/cbnki-1s.p (
                           input parparentproc
                          ,input p-log-handle
                          ,input temp-bik.o_name
                          ,input temp-bik.host-code
                          ,input temp-bik.bik
                          ,input temp-bik.code-bank
                          ,input temp-bik.adresat
                          ,input p-create
                          ,input p-no-th-create
                          ,input p-encoding
                          ,input p-rs-hsch
                          ,input-output v-view-log
                          ,output v-count
                          ,output v-processed
                          ,output v-created
                          ,output v-count-statement
                          ,output v-processed-statement
                          ,output v-created-statement
                          ) no-error .
        end.
      END CASE.
      if error-status:error then do:
&scop my-message substitute("!!!Ошибка при импорта данных по финдокументам:&1БИК &2 фирма &3&1&4 &5" ~
                          , ~{&new-line~}                                                         ~
                          , temp-bik.bik                                                          ~
                          , temp-bik.host-code                                                    ~
                          , error-status:get-message(1)                                           ~
                          , return-value )
          {&display-message}.
        assign
        v-view-log = yes.
      end.
      else do:
&scop my-message substitute("БИК &1 Фирма &2&4 - файл импорта &3:&4" +                            ~
                            "в файле &8 документов&4" +                                             ~
                            "обработано документов: &5&4" +                                       ~
                            "в т.ч. создано в статусе &6 - &7&4"                                    ~
                     ,temp-bik.bik                                                                ~
                     ,temp-bik.host-code                                                          ~
                     ,temp-bik.o_name                                                             ~
                     ,~{&new-line~}                                                               ~
                     ,v-processed                                                                 ~
                     ,~{&fin-new~}                                                                ~
                     ,v-created                                                                   ~
                     ,v-count  )  +                                                               ~
                 substitute("в файле &5 выписок&1" +                                             ~
                            "обработано выписок: &2&1" +                                       ~
                            "в т.ч. создано в статусе &3 - &4&1"                                    ~
                     ,~{&new-line~}                                                               ~
                     ,v-processed-statement                                                       ~
                     ,~{&fin-new~}                                                                ~
                     ,v-created-statement                                                         ~
                     ,v-count-statement )

      {&display-message}.
      end.
      os-append value( temp-bik.o_name ) value( temp-bik.f_name) .
      if os-error = 0 then
      os-delete value( temp-bik.o_name ) .

    end. /*for each temp-bik*/
  end.
end procedure. /* proc-main*/


procedure get-inis-from-bik-host :
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-bik       like ub.fin-bank.bik no-undo .
define input parameter p-code-bank like ub.fin-bank.code-bank no-undo .

define variable loc-in_ as character no-undo .
define variable loc-spl as character no-undo .
define variable loc-sav as character no-undo .
define variable loc-out as character no-undo .
define variable loc-adresat as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable ii as integer no-undo .
define variable v-doc-type-1s as character no-undo .

define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_temp_hfin-schet for temp_hfin-schet.

  do
  on error undo, return error
  :
    /*определим директории для закгрузки*/
    create temp-bik.
    assign
    temp-bik.host-code = p-host-code
    temp-bik.code-bank = p-code-bank
    temp-bik.bik       = p-bik
    .
    run bge/cbnkinis.p (
                         input parparentproc
                       , input p-format
                       , input p-bik
                       , input p-host-code
                       , input "get":U /*некий параметр который говорит для чего нам настройки*/
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
      return error.
    end.
    /**/
    run cur-time in this-procedure(output v-today, output v-time).
    assign
    temp-bik.f_name = substitute("&1&2\&3_&4_&5.spl"
                               ,loc-in_
                               ,loc-sav
                               ,string(day(v-today), "99")
                               ,string(month(v-today), "99")
                               ,string(year(v-today) modulo 100, "99")
                               )
    temp-bik.o_name = substitute("&1&2\&3", loc-in_, loc-spl , 'KL_to_1C.txt')
    temp-bik.adresat = loc-adresat
    .
  end.

end procedure. /* get-inis-from-bik-host */