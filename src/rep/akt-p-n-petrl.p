/*

$Revision: 65bbcd1738dd, 2884, rls $
$Author: EShklyar $
$Date: Пн ноя 22 19:49:11 2021 +0300 $
$Workfile: akt-p-n-petrl.p $
$Archive: rep/akt-p-n-petrl.p $

Акт приема и недовоза нефтепродуктов

Автор: Сливенко Сергей Андреевич
Дата создания: 10/14/11
Author: Sergey Slivenko
Creation date: 10/14/11

*/

using ibs.th.str.*.
block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 65bbcd1738dd, 2884, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:11 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: akt-p-n-petrl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/akt-p-n-petrl.p $":U .
define variable vss-description as character no-undo init "Акт приема и недовоза нефтепродуктов".
{ cmp/vssrevis.i }

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.

define stream out-stream.

/*{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i }
{ str/lib-calc.i }

{ cmp/r-pril.i new  }
{ cmp/r-page1.i new }
/*{ str/get-pr.i def  } */
/*{ str/trdcalib.i    }   */
{ ref/grplibfn.i    }
/*{ gbl/getcntxt.i def }  */
{ gbl/rep-clb.i }

{ str/lib-trn.i  }
/*{ str/trdcalib.i } */
{ rep/w-rep.i    }
{ rep/fmtcli.i   }
/*{ rep/torgconf.i }   */
{ str/getctxtp.i def }
{ gbl/paramls.i  }            */

    { cmp/str-glbl.i }
    { cmp/library.i  }
    { cmp/r-pril.i   }
    { str/lib-trn.i  }
    { str/trdcalib.i }
    { rep/w-rep.i    }
    { rep/fmtcli.i   }
    { rep/torgconf.i }
    { str/getctxtp.i def }
    { gbl/paramls.i  }

/*    { gbl/std-func.i }*/
    { ref/sr-izm.i sr-izmerenia ds}
    { ref/sr-izm.i " " proc }
    { gbl/ptrlprop.i def}
    { ref/gds-attr.i }
    { ref/gdsoattr.i }
    { str/lib-calc.i }
    
/* Для вызова функции конвертации даты к виду: "01 Января 2014г" */
&scop f-l MonthNameRusCase
    { gbl/std-func.i {&f-l} }

define variable g#report-num    as integer      no-undo .
define variable g#quest-print   as logical      no-undo .
define variable g#log           as logical      no-undo .
{ rep/apn-xl.i  }

define variable is-petrolium as logical no-undo.
define variable is-pieces as logical no-undo.
define variable v-attr-value as character no-undo.
define variable v-attr-type as character no-undo.
define variable v-nakl as character no-undo.
define variable v-date as character no-undo.
define variable v-t-start as character no-undo.
define variable v-t-end as character no-undo.
define buffer buf_clob-bind for ub.clob-bind.

define variable v-doc-code          like ub.trn-doc.doc-code   no-undo.
define variable v-gds-code          like ub.goods.gds-code     no-undo.
define variable v-car-num           as   character             no-undo.
define variable v-car-vol           as   character             no-undo. /* Объём по паспорту (л) (из строки Накл > ДопИнфо [doc-line-attr]) */
define variable v-num-passport      as   character             no-undo.
define variable v-norm-doc          as   character             no-undo.
define variable v-certif-fuel       as   character             no-undo.
define variable v-validity-certif   as   character             no-undo.
define variable v-num-plotn         as   character             no-undo.
define variable v-date-pov-plotn    as   date                  no-undo.
define variable v-passport-plotn    as   character             no-undo.
define variable v-tests             as   character             no-undo.
define variable v-autoent-obj-type  as   character             no-undo.
define variable v-autoent-obj-code  as   character             no-undo.
define variable v-autoent-obj-name  as   character             no-undo.
define variable v-item-pour         as   character             no-undo.
define variable v-date-pour         as   character             no-undo.
define variable v-time-pour         as   character             no-undo.
define variable v-tank-vol          as   character             no-undo.
define variable v-tank-temp         as   character             no-undo.
define variable v-doc-not           as   logical               no-undo.
define variable v-spisok-not-doc    as   character             no-undo. 
define variable v-tank-water        as   character             no-undo.
define variable v-tank-density      as   character             no-undo.
define variable v-tank-weight       as   character             no-undo.
define variable v-time-income       as   character             no-undo.
define variable v-date-start        like ub.rvs-line.real-date no-undo.
define variable v-time-start        like ub.rvs-line.real-time no-undo.
define variable v-date-end          like ub.rvs-line.real-date no-undo.
define variable v-time-end          like ub.rvs-line.real-time no-undo.
define variable v-mouth             as   character             no-undo. /* Оъём горловины. (из  строки Накл > ДопИнфо [doc-line-attr]) */
define variable v-fio               as   character             no-undo.
define variable v-ptbotype          as   character             no-undo.
define variable v-ptbocode          as   character             no-undo.
define variable v-a-b-tarir         as   character             no-undo.
define variable v-DD-Month-YYYY     as   character             no-undo.
define variable v-DD-MM-YYYY        as   character             no-undo.
define variable v-str-address       as   character             no-undo.
define variable v-inspection-cert   as   character             no-undo.
define variable v-date-cert         as   date                  no-undo.
define variable v-clients-obj-name  as   character             no-undo.
define variable v-clients-boss-name as   character             no-undo. /* ФИО Менеджера (код которого в trn-doc.boss) */
define variable v-diameter          as   decimal               no-undo.
define variable v-dens-temp         as   character             no-undo.
define variable v-place-si          as   character             no-undo.
define variable v-tank-vol-pomi     as   character             no-undo.
define variable v-tank-density-pomi as   character             no-undo. /* "Плотность приведенная" */
define variable v-diff-qnty-kg      as   decimal               no-undo. /* ТЗ: Поле-5.6 "Количество НП (кг) как разница данных между ТТН и Результатов измерений(расчёта)" */
define variable v-error-meas-kg     as   decimal               no-undo. /* ТЗ: Поле-6.4 "Погрешность измерений (кг) факт" */
define variable v-shortage-surplus-kg as decimal               no-undo. /* ТЗ: Поле-7.6 "Недостаёт/Излишествует (кг)" */
define variable v-diff-qnty-kg-15C  as   decimal               no-undo. /* ТЗ: Поле-5.7 "Количество НП (кг) как разница данных между ТТН и Результатов измерений(расчёта)" */
define variable v-error-meas-kg-15C as   decimal               no-undo. /* ТЗ: Поле-6.5 "Погрешность измерений (кг) факт" */
define variable v-shortage-surplus-kg-15C as decimal           no-undo. /* ТЗ: Поле-7.7 "Недостаёт/Излишествует (кг)" */
define variable v-pl-code           like ub.place.pl-code      no-undo.
define variable v-tank-name-and-coord as character             no-undo.
define variable v-normal-wastage    as   decimal               no-undo. /* Норма естественной убыли из атрибутов товара на объекте */
define variable v-type              as   character             no-undo.
define variable v-norm-natur-loss   as   decimal               no-undo. /* Поле 8.4 Норма естественной убыли (НЕУ) <вычисляемое значение!> */
define variable v-norm-natur-loss-15C as decimal               no-undo. /* Поле 8.5 Норма естественной убыли (НЕУ) привед к 15С(или20С, см. настройки маг) <вычисляемое значение!> */
define variable stfactplvalue as character no-undo.
define variable stfactpltype  as character no-undo.
define variable varupdate     as logical   no-undo initial yes.
define variable varrevision   as logical   no-undo initial no.
define variable varpercrev    as decimal   no-undo initial ?.
define variable varauto-tank  as logical   no-undo initial no.
define variable varpercauto   as decimal   no-undo initial ?.
define variable varinv        as logical   no-undo initial no.
define variable varpercinv    as decimal   no-undo initial ?.
define variable varinv-set    as logical   no-undo initial no.
define variable K1            as decimal   no-undo.
define variable v-InfoSectionsTotal as class InfoSectionsTotal no-undo .
def var iNum as int no-undo init 1.

/* Переменные вычисляемые библиотекой ПО МИ (Роснефть) */
define variable v-tank-density-pomi-dll as decimal             no-undo. /* "Плотность приведенная" - расчитанная в DLL ПО МИ */
define variable v-tank-vol-pomi-dll     as decimal             no-undo. /* "Объём топлива приведенный" - расчитанный в DLL ПО МИ */
define variable v-tank-weight-pomi-dll  as decimal             no-undo. /* "Количество (кг)" - рассчитанное в DLL ПО МИ */

    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_doc-line-attr for ub.doc-line-attr.
    define buffer buf_doc-attr      for ub.doc-attr.
    define buffer buf_goods         for ub.goods.
    define buffer buf_clients       for ub.clients.
    define buffer buf_person        for ub.person.

/* ************************  Function Implementations ***************** */

function fnc-convert-dot-to-colon returns character 
(input p-data as decimal, p-accur as character) forward.

function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date) forward.

v-InfoSectionsTotal = new InfoSectionsTotal().

do
/*&scop f-l MonthNameRusCase,Sparse*/
:
    { gbl/working.i }

    { str/getctxtp.i get p-mainmenu-handle }

    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).

    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).


    find first buf_trn-doc no-lock
         where recid( buf_trn-doc ) = rec_id.

    { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-nids} v-attr-value v-attr-type }
    if v-attr-value > "" then do :
      assign v-nakl = v-attr-value .
    end .
    else do :
      assign v-nakl = buf_trn-doc.doc-code .
    end.

    for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code break by buf_doc-line.doc-code :
      find first buf_goods where buf_goods.artic     = buf_doc-line.artic
                             and buf_goods.prod-code = buf_doc-line.prod-code
                             and buf_goods.prod-type = buf_doc-line.prod-type no-lock no-error.

      assign
          v-doc-code = buf_doc-line.doc-code
          v-gds-code = buf_goods.gds-code
      .
      v-InfoSectionsTotal:Initialization(v-doc-code, v-gds-code).
      v-InfoSectionsTotal:GetDBAllAttr().
    do iNum = 1 to v-InfoSectionsTotal:SectionNum:
    
    { str/is-petrl.i
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      is-petrolium
      is-pieces
      no-error
      }
      if error-status :error
      then do:
        return error return-value .
      end.
    if is-petrolium then
    do:
       run gds-attr-value in this-procedure
          (  input buf_goods.gds-code
          ,input {&attr-fuel-type}
          ,output v-attr-value
          ,output v-attr-type
          ) .
       if v-attr-value = "lgas" then 
       do:
          return error return-value .
       end.
        run get-DD-month-YYYY(input buf_trn-doc.doc-date, output v-DD-Month-YYYY).

/*        run get-DD-MM-YYYY(input buf_trn-doc.doc-date, output v-DD-MM-YYYY).*/

        run proc-get-address(input buf_trn-doc.obj-type, input buf_trn-doc.obj-code, output v-str-address).
        v-str-address = trim(v-str-address, " ").
        v-str-address = trim(v-str-address, ",").

        { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }
        run apn-xl-init in this-procedure .
        put stream out-stream unformatted
            {&new-line}
          + "Печатная форма предназначена только для вывода в Microsoft Excel."
          + {&new-line}
        .
        output stream out-stream close.
        

        find first clients where clients.obj-code = buf_trn-doc.boss and
                                 clients.obj-type = {&prs} no-lock no-error.
        find first person where person.psn-code = buf_trn-doc.boss no-lock no-error.

        run loc-get-set-attr in this-procedure
          ( input "get-attr":U
          ) no-error.


        /* Находим имя объекта */
        define variable v-obj-name as character no-undo.
        for first buf_clients where
        buf_clients.obj-type = buf_trn-doc.obj-type and
        buf_clients.obj-code = buf_trn-doc.obj-code
        no-lock:
            v-obj-name = buf_clients.obj-name.
        end.
        /* ТЗ:Поле - без номера! "Наименование объекта" */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-object}
/*            , input buf_trn-doc.obj-code*/
            , input v-obj-name
        ).

        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-str_date}
            , input v-DD-Month-YYYY
        ).

        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-obj_address}
            , input v-str-address
        ).

        do: /* Название Клиента (из: Топливная Накладная по кнопке "ДопИнфо" см. поле "Автопредприятие") */
            for first buf_clients where
            buf_clients.obj-type = v-autoent-obj-type and
            buf_clients.obj-code = integer(trim(v-autoent-obj-code))
            no-lock:
                v-autoent-obj-name = buf_clients.obj-name.
            end.
            run apn-xl-write-cell-data in this-procedure (
                  input {&apn-xl-cli_name_auto_ent}
                , input v-autoent-obj-name
            ).
        end. /* Название Клиента (из: Топливная Накладная по кнопке "ДопИнфо" см. поле "Автопредприятие") */

        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-driver_name}
            , input v-fio
        ).

        do: /* Поле-6 "Клиент" (Получение и вывод свей фирмы, которой принадлежит данный объект) */
            for first buf_clients where
            buf_clients.obj-type = {&cmp} and
            buf_clients.obj-code = buf_trn-doc.host-code
            no-lock:
                v-clients-obj-name = buf_clients.obj-name.
            end.
            run apn-xl-write-cell-data in this-procedure (
                  input {&apn-xl-host_name}
                , input v-clients-obj-name
            ).
        end. /* Получение и вывод свей фирмы, которой принадлежит данный объект */

        if available clients then
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-mngr_name}
            , input string(clients.obj-name + ' ' + person.name1 + ' ' + person.name2)
        ).
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-gds-name}
            , input buf_goods.gds-name
        ).
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-doc-code}
            , input v-nakl
        ).
        { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-dids} v-attr-value v-attr-type }
        if v-attr-value > "" then v-date = v-attr-value.
        else do :
              if integer(substring(string(date(buf_trn-doc.doc-date), "99/99/9999") , 1, 2)) > 12
                then v-date = string(date(buf_trn-doc.doc-date), "99/99/9999").
                else v-date = substring(string(date(buf_trn-doc.doc-date), "99/99/9999") , 4, 3)
                            + substring(string(date(buf_trn-doc.doc-date), "99/99/9999") , 1, 3)
                            + substring(string(date(buf_trn-doc.doc-date), "99/99/9999") , 7, 4).
        end.
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-doc-date}
            , input fnc-DD-MM-YYYY(date(v-date))
        ).
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-cli-name}
            , input buf_trn-doc.cli-name
        ).

        /* Поле-13. "Пункт налива" (Название клиента из ТопливнаяНакладная > ДопИнфо > поле "Нефтебаза") */
        do:
            for first buf_clients where
            buf_clients.obj-type = v-ptbotype and
            buf_clients.obj-code = integer(v-ptbocode)
            no-lock:
            run apn-xl-write-cell-data in this-procedure (
                  input {&apn-xl-point_fill_fuel}
                , input buf_clients.obj-name
            ).
            end.
        end.

        /* Поле-14 "ВРЕМЯ и дата налива" (Строка ТоплНакладной > ДопИнфо > поле "Время налива") */
        do: /*  */
            run apn-xl-write-cell-data in this-procedure (
                  input {&apn-xl-time_pour}
                , input v-time-pour
            ).
        end. /*  */

        /* Поле-15 "Время и ДАТА налива" (Дата накладной поставщика из атрибутов ТН) */
        do: /* dids */
            run gbl/trdcat-v.p (
                  input buf_trn-doc.doc-code
                , input {&trdcattr-date-pour} /* Дата приходной накладной поставщика */
                , output v-attr-value
                , output v-attr-type
            ).
            run apn-xl-write-cell-data in this-procedure (
                  input {&apn-xl-trn_date_ic}
                , input fnc-DD-MM-YYYY(date(v-attr-value))
            ).
        end. /* dids */

        /* Поле-16 "Гос. номер автоцистерны" (из ТоплНакладная > ДопИнфо > поле "Гос. номер автоцистерны") */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-car-num}
            , input v-car-num
        ).

        /* Поле-5(повторный вывод) "Ф.И.О. водителя" */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-driver_name2}
            , input v-fio
        ).

        /* Поле-17 "Номер свидетельства о поверке и дата поверки автоцистерны" (из ТоплНакладная > ДопИнфо > "Свидетельство о поверке...") */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-inspection_cert}
            , input v-inspection-cert
        ).


        /* Поле-17 "Номер свидетельства о поверке и дата поверки автоцистерны" (из ТоплНакладная > ДопИнфо > "Свидетельство о поверке...") */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-date_cert}
            , input v-date-cert
        ).

        /* Поле-18 "Объём автоцистерны (по паспорту автоцистерны или свидетельству о поверке в л)" (из строки ТоплНакл > ДопИнф > поле "Объём по паспорту") */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-car_vol}
            , input v-car-vol
        ).

        /* Поле-9 "Паспорт качества" (из строки ТоплНакл > ДопИнф > поле "Паспорт качества №") */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-num_passport}
            , input v-num-passport
        ).

        /* Поле-22 "Нормативный документ завода-изготовителя (ГОСТ, ТУ на марку моторного топлива) из паспорта качества" (из строки ТоплНакл > ДопИнф > поле "Нормативный документ завода-изготовителя (ГОСТ, ТУ на марку моторного топлива) из паспорта качества") */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-norm_doc}
            , input v-norm-doc
        ).

        /* Поле-23 "Сертификат соответствия завода-изготовителя (на марку моторного топлива) и срок его действия из паспорта качества № " (из строки ТоплНакл > ДопИнф > поле "Сертификат соответствия завода-изготовителя (на марку моторного топлива)№") */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-certif_fuel}
            , input v-certif-fuel
        ).

        
        v-validity-certif = if fnc-DD-MM-YYYY (input date (v-validity-certif)) <> "" and  fnc-DD-MM-YYYY (input date (v-validity-certif)) <> ? then  fnc-DD-MM-YYYY (input date (v-validity-certif)) else v-validity-certif no-error.
        /* Поле-24 "Сертификат соответствия завода-изготовителя (на марку моторного топлива) и срок его действия из паспорта качества № " (из строки ТоплНакл > ДопИнф > поле "Срок действия сертификата соответствия завода-изготовителя (на марку моторного топлива)№") */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-validity_certif}
            , input v-validity-certif
        ).

/*        /* "Докуметы НЕ представленные*/              */
/*        run apn-xl-write-cell-data in this-procedure (*/
/*              input {&apn-xl-doc-not}                 */
/*            , input v-validity-certif                 */
/*        ).                                            */
/*                                                      */
/*                                                      */
/*        /* Список не предоставленных документов */    */
/*        run apn-xl-write-cell-data in this-procedure (*/
/*              input {&apn-xl-spisok-doc-not}          */
/*            , input v-validity-certif                 */
/*        ).                                            */
  run sr-izmerenia_fill-sr-izm in this-procedure ( input {&lookup}
                                               , buffer buf_clob-bind).
  find first sr-izmerenia no-lock where sr-izmerenia.node-code = integer(v-place-si) no-error.
      if available sr-izmerenia then do:
          if sr-izmerenia.sr-type-id = 1 or sr-izmerenia.sr-type-id = 2 then do:
            /* Поле-25 "Нефтеденсиметр (ареометр) АНТ-1, ГОСТ 18481-81 № " (из строки ТоплНакл > ДопИнф > поле "Ареометр №") */
            run apn-xl-write-cell-data in this-procedure (
                  input {&apn-xl-num_areom}
                , input v-num-plotn
            ).
            /* Поле-26 "Дата поверки" (из строки ТоплНакл > ДопИнф > поле "Дата поверки ареометра") */

            run apn-xl-write-cell-data in this-procedure (
                  input {&apn-xl-date_pov_areom}
                , input fnc-DD-MM-YYYY(v-date-pov-plotn) 
            ).
          end.
          if sr-izmerenia.sr-type-id = 3 or sr-izmerenia.sr-type-id = 4 then do:
            /* Поле-27 "Плотномер: ПЛОТ-3Б-1П, ГОСТ  АУТП.414122.006 ТУ(1)  №" (из строки ТоплНакл > ДопИнф > поле "Плотномер №") */
            run apn-xl-write-cell-data in this-procedure (
                  input {&apn-xl-num_plotn}
                , input v-num-plotn
            ).
            /* Поле-28 "Паспорт№" (из строки ТоплНакл > ДопИнф > поле "Паспорт № плотномера") */
            run apn-xl-write-cell-data in this-procedure (
                  input {&apn-xl-passport_plotn}
                , input v-passport-plotn
            ).
    
            /* Поле-29 "Дата поверки" (из строки ТоплНакл > ДопИнф > поле "Дата поверки плотномера") */
            run apn-xl-write-cell-data in this-procedure (
                  input {&apn-xl-date_pov_plotn}
                , input fnc-DD-MM-YYYY(v-date-pov-plotn)
            ).

          end.
                                   
      end.
         
        /* Поле-21 "... резервуара:" (из справ складск мест (ub.place) ТЗ: Выводить "Координата1" и "Название резервуара" из справ складск мест. Если "Координата1" не задана, то использовать код резервуара" */
            for first ub.doc-pl where
            ub.doc-pl.obj-type = buf_trn-doc.obj-type and
            ub.doc-pl.obj-code = buf_trn-doc.obj-code and
            ub.doc-pl.gds-code = v-gds-code and
            ub.doc-pl.out-code = buf_trn-doc.doc-code
            no-lock:
                v-pl-code = ub.doc-pl.pl-code.
            end.
                for first ub.place where
                ub.place.obj-type = buf_trn-doc.obj-type and
                ub.place.obj-code = buf_trn-doc.obj-code and
                ub.place.pl-code = ub.doc-pl.pl-code
                no-lock:
                    v-tank-name-and-coord = (if trim(ub.place.loc1) <> "" then ub.place.loc1
                                             else string(ub.place.pl-code)) +
                                             " " +
                                            (if trim(ub.place.pl-name) <> "" then ub.place.pl-name
                                             else "").
                end.
            run apn-xl-write-cell-data in this-procedure (
                  input {&apn-xl-tank_name_and_coord}
                , input v-tank-name-and-coord
            ).
        /* Поле-21 ... */

        /* Поле-3(повтор) "Дата приёма НП" (из Накл поле doc-date) */
/*        run get-DD-MM-YYYY(input buf_trn-doc.doc-date, output v-DD-MM-YYYY).*/
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-date-start}
/*            , input string(buf_trn-doc.doc-date, "99/99/9999")*/
            , input fnc-DD-MM-YYYY(buf_trn-doc.doc-date)
        ).
/*        if v-date-start <> ? then                     */
/*        run apn-xl-write-cell-data in this-procedure (*/
/*              input {&apn-xl-date-start}              */
/*            , input v-date-start                      */
/*        ).                                            */

        define variable v-hours   as integer no-undo.
        define variable v-minutes as integer no-undo.
        if v-time-start <> ? or v-time-start <> 0 then do :
           v-minutes = (v-time-start modulo 3600) / 60.
           v-hours   = truncate (v-time-start / 3600, 0).
           v-t-start = string(v-hours) + ":" + string(v-minutes).
           run apn-xl-write-cell-data in this-procedure (
                input {&apn-xl-time-start}
              , input v-t-start
           ).
        end.
        if v-time-end <> ? or v-time-end <> 0 then do :
           v-minutes = (v-time-end modulo 3600) / 60.
           v-hours   = truncate (v-time-end / 3600, 0).
           v-t-end   = string(v-hours) + ":" + string(v-minutes).
           run apn-xl-write-cell-data in this-procedure (
                input {&apn-xl-time-end}
              , input v-t-end
           ).
        end.
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-doc-qnty}
            , input fnc-convert-dot-to-colon(v-InfoSectionsTotal:GetInfoSectionProp(iNum):DocQnty, "->>>>>>>>9.999")
        ).

        if v-a-b-tarir <> "0" then do:   
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-a_b_tarir_fact}
            , input fnc-convert-dot-to-colon(decimal(v-a-b-tarir), "->>>>>>>>9.99") 
        ).
        end.
        else do:
        v-a-b-tarir = "По планку".
        run apn-xl-write-cell-data in this-procedure (
                input {&apn-xl-a_b_tarir_fact}
              , input v-a-b-tarir
           ).
        end.
        
        /* ТЗ: Поле-2.4. к таблице Акта. (ТЗ: Сумма значений "Объём по паспорту (л) и "Объём горловины" по строке Накладной > ДопИнф [doc-line-attr])*/
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-tank-vol}
            , input fnc-convert-dot-to-colon((decimal(v-car-vol) + decimal(v-mouth)), "->>>>>>>>9.999")
        ).
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-doc-density}
            , input fnc-convert-dot-to-colon(v-InfoSectionsTotal:GetInfoSectionProp(iNum):DocDensity, "->>>>>>>>9.9999")
        ).

        /* ТЗ: Поле-3.4. к таблице Акта. (из строки Накладной > ДопИнф [doc-line-attr]) */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-tank-density}
            , input fnc-convert-dot-to-colon(decimal(v-tank-density), "->>>>>>>>9.9999")
        ).
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-temperature}
            , input fnc-convert-dot-to-colon(buf_doc-line.temperature, "->>>>>>>>9.9")
        ).

        /* ТЗ: Поле-4.4. к таблице Акта. ТЗ: значение поля "Температура замера плотности" (из строки Накладной > ДопИнф [doc-line-attr "dens-temp"]) */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-dens_temp_fact}
            , input fnc-convert-dot-to-colon(decimal(v-dens-temp), "->>>>>>>>9.9")
        ).

        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-cli-qnty}
            , input fnc-convert-dot-to-colon(v-InfoSectionsTotal:GetInfoSectionProp(iNum):CliQnty, "->>>>>>>>9.999")
        ).

        /* Поле-5(повторный вывод) "Водитель-экспедитор" */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-driver_name3}
            , input v-fio
        ).

        do: /* Поле-6(повторный вывод) "От Клиента" (ТЗ: Получение и вывод свей фирмы, которой принадлежит данный объект) */
            /* Исправление Арн 29.05.2015. По заявке от Заказчика - в это поле в разрез с ТЗ необходимо занести ФИО из поля "Менеджер" Приходной Накладной(его код - в trn-doc.wrkr) */

            for first buf_clients where
                      buf_clients.obj-type = {&prs} and
                      buf_clients.obj-code = buf_trn-doc.boss
            no-lock:
                v-clients-boss-name = trim(buf_clients.obj-name).               /* Фамилия + */
                for first buf_person where
                          buf_person.psn-code = buf_trn-doc.boss
                no-lock:
                    v-clients-boss-name =
                        trim(v-clients-boss-name) + " " +
                        (if trim(buf_person.name1) = "" then ""
                        else caps(substring(trim(buf_person.name1), 1, 1)) + ". ") +  /* + Имя(сокращ) + */
                        (if trim(buf_person.name1) = "" or trim(buf_person.name2) = "" then ""
                        else caps(substring(trim(buf_person.name2), 1, 1)) + ".").    /* + Отчество(сокращ) */
                end.
            end.
            if available buf_clients then
            run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-host_name2}
            , input v-clients-boss-name
        ).
            
        end. /* Исправление Арн 29.05.2015. */

        /* ТЗ:Поле-(неопр, принимаем за Поле-8) "Сливной резервуар ... с нефтепродуктом марки:" (ТЗ: Наименование товара по строке ПН) */
        
        def var str1 as char no-undo.
        
        if not v-InfoSectionsTotal:GetInfoSectionProp(iNum):SectionName = ""
          then str1 = substitute (' (секция - &1)', v-InfoSectionsTotal:GetInfoSectionProp(iNum):SectionName). 
          else str1 = "". 
        
        if buf_goods.engl-name <> "" then do:
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-gds_name7}
            , input buf_goods.engl-name + str1 
        ).
        end.
        else do:
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-gds_name7}
            , input buf_goods.gds-name + str1
        ).
        end.

        /* ТЗ:Поле-8 Excel:"с нефтепродуктом марки:" (ТЗ: Наименование товара по строке ПН) */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-gds_name3}
            , input buf_goods.engl-name
        ).

        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-gds_name2}
            , input buf_goods.engl-name
        ).

        /* ТЗ:Поле-5.4. ТЗ: 5.4 = 2.4 * 3.4 (кол-во (л) ПН на плотность ПН (кг/куб.дм)) */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-fact_qnty_kg}
            , input fnc-convert-dot-to-colon(((decimal(v-car-vol) + decimal(v-mouth)) * decimal(v-tank-density)), "->>>>>>>>9.999")
        ).

        /* ТЗ:Поле-6.4. "Погрешность измерений (кг) факт" ТЗ: 6.4 = 5.4 * (если: "stfactpl" <> "" тогда: "stfactpl"/100 иначе: 0,0065) */
        /* где "stfactpl" => параметр конфигурации системы ТН: "Определение работы с фактическим количеством бензина во внешнем приходе". */
        { gbl/conf-rd.i
          "'stfactpl'"
          "''"
          "''"
          0
          "''"
          "''"
          "''"
          no
          stfactplvalue
          stfactpltype
          no-error
        }
        if not error-status :error
          and stfactplvalue <> ?
          and stfactplvalue <> "?"
        then do:
          { str/chkqtpl.i
            stfactplvalue
            varupdate
            varrevision
            varpercrev
            varauto-tank
            varpercauto
            varinv
            varpercinv
            varinv-set
            no-error
          }
          if error-status :error then do:
            message
              return-value skip
              error-status :get-message( 1 )
              view-as alert-box.
            undo, return error .
          end.
          if varrevision = yes then do:
            assign
              K1 = varpercrev.
          end.
          if varauto-tank = yes then do:
            assign
              K1 = varpercauto.
          end.
          if varinv = yes then do:
            assign
              K1 = varpercinv.
          end.
        end.
        if K1 = ? then do:
          assign
            K1 = 0.0065
          .
        end.
        else do:
          assign
            K1 = K1 / 100.
        end.
        
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-error_meas_kg}
            , input fnc-convert-dot-to-colon((((decimal(v-car-vol) + decimal(v-mouth)) * decimal(v-tank-density)) * K1), "->>>>>>>>9.999")
        ).

        /* ТЗ:Поле-8.4. "Норма естественной убыли (НЕУ) по факту ТЗ: 8.4 = 5.4 * 0,001 * нормы естественной убыли[которая в goods.normal-wastage]. */
        run gdsoattr-value in this-procedure
                          ( input  {&attr-normal-wastage-o}
                           ,input  v-gds-code
                           ,input  buf_trn-doc.obj-type
                           ,input  buf_trn-doc.obj-code
                           ,output v-normal-wastage
                           ,output v-type
                          ) no-error.
        v-norm-natur-loss = (((decimal(v-car-vol) + decimal(v-mouth)) * decimal(v-tank-density)) * 0.001) * v-normal-wastage.
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-norm_natur_losses}
            , input fnc-convert-dot-to-colon((v-norm-natur-loss), "->>>>>>>>9.999")
        ).

        /* ТЗ:Поле-9.4. "Сумма ПИ + НЕУ факт" ТЗ: 9.4 = 6.4 + 8.4 */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-sum_errm_and_norml_kg}
            , input fnc-convert-dot-to-colon(
                                            ((((decimal(v-car-vol) + decimal(v-mouth)) * decimal(v-tank-density)) * K1) + 
                                            v-norm-natur-loss)
                                            , "->>>>>>>>9.999")
        ).

        /* ТЗ:Поле-2.5 "Кол-во по НП приведённое к 15С по результатам измерений(расчёта)" (ТЗ: по строке ПН > ДопИнф > поле:"Объём топлива приведённый") */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-tank_vol_pomi_15C}
            , input fnc-convert-dot-to-colon(decimal(v-tank-vol-pomi), "->>>>>>>>9.999")
        ).

        /* ТЗ:Поле-3.5 "Плотность НП (кг/куб.м) приведённое к 15С по результатам измерений(расчёта)" (ТЗ: по строке ПН > ДопИнф > поле:"Плотность приведённая") */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-tank_density_pomi_15C}
            , input fnc-convert-dot-to-colon(decimal(v-tank-density-pomi), "->>>>>>>>9.9999")
        ).

        /* ТЗ:Поле-5.5 "Количество НП (кг) приведённое к 15С по результатам измерений(расчёта)" (ТЗ: по строке ПН > ДопИнф > поле:"Вес топлива") */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-tank_weight_kg_15C}
            , input fnc-convert-dot-to-colon(decimal(v-tank-weight), "->>>>>>>>9.999")
        ).

        /* ТЗ:Поле-6.5 "Погрешность измерений (кг) приведённое к 15С по результатам измерений(расчёта)" (ТЗ: по упрощённой схеме: 6.5 = 5.5 * 0,0065) */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-error_meas_kg_15C}
            , input fnc-convert-dot-to-colon((decimal(v-tank-weight) * K1), "->>>>>>>>9.999")
        ).

        /* ТЗ:Поле-8.5 "Норма естественной убыли (НЕУ) приведённое к 15С по результатам измерений(расчёта)" (ТЗ: по упрощённой схеме: 8.5 = 5.5 * 0,001 * нормы естественной убыли[которая в goods.normal-wastage]) */
        v-norm-natur-loss-15C = (decimal(v-tank-weight) * 0.001) * v-normal-wastage.
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-norm_natur_losses_15C}
            , input fnc-convert-dot-to-colon(v-norm-natur-loss-15C, "->>>>>>>>9.999")
        ).

        /* ТЗ:Поле-9.5. "Сумма ПИ + НЕУ приведённое к 15С по результатам измерений(расчёта)" ТЗ: 9.5 = 6.5 + 8.5 */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-sum_errm_and_norm_15C}
            , input fnc-convert-dot-to-colon(
                                            ((decimal(v-tank-weight) * K1) + 
                                            v-norm-natur-loss-15C)
                                            , "->>>>>>>>9.999")
        ).

        /* ТЗ:Поле-2.6 "Кол-во по НП как разница данных между ТТН и Результатов измерений(расчёта)" ТЗ: 2.6 = 2.2 - 2.4 */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-diff_tank_vol_pomi}
            , input fnc-convert-dot-to-colon(
                                              - v-InfoSectionsTotal:GetInfoSectionProp(iNum):DocQnty + (decimal(v-car-vol) + decimal(v-mouth))
                                              , "->>>>>>>>9.999")
        ).

        /* ТЗ:Поле-3.6 "Плотность НП (кг/куб.м) как разница данных между ТТН и Результатов измерений(расчёта)" ТЗ: 3.6 = 3.2 - 3.4 */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-diff_tank_density_pomi}
            , input fnc-convert-dot-to-colon(
                                            (- v-InfoSectionsTotal:GetInfoSectionProp(iNum):DocDensity + decimal(v-tank-density))
                                            , "->>>>>>>>9.9999")
        ).

        /* ТЗ:Поле-4.6 "Температура НП (С) как разница данных между ТТН и Результатов измерений(расчёта)" ТЗ: 4.6 = 4.2 - 4.4 */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-diff_dens_temp}
            , input fnc-convert-dot-to-colon(
                                            (- buf_doc-line.temperature + decimal(v-dens-temp))
                                            , "->>>>>>>>9.9")
        ).

        /* ТЗ:Поле-5.6 "Количество НП (кг) как разница данных между ТТН и Результатов измерений(расчёта)" ТЗ: 5.6 = 5.2 - 5.4 */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-diff_qnty_kg}
            , input fnc-convert-dot-to-colon(
                                            ( - v-InfoSectionsTotal:GetInfoSectionProp(iNum):CliQnty +
                                            ((decimal(v-car-vol) + decimal(v-mouth)) * decimal(v-tank-density)))
                                            , "->>>>>>>>9.999")
        ).

        /* ТЗ:Поле-7.6 "Недостаёт/Излишествует (кг)" ТЗ: если: 0 < 5.6         < 6.4 тогда: 5.6 - 6.4;
                                                         если: 0 > 5.6 и |5.6| > 6.4 тогда: 5.6 + 6.4; 
                                                         если:     |5.6|      =< 6.4 тогда: 0 */
        /* Вычисление переменной v-shortage-surplus-kg (Недостаёт/Излишествует) */
        do: /* v */
            /* ТЗ: Поле-5.6 "Количество НП (кг) как разница данных между ТТН и Результатов измерений(расчёта)" */
            v-diff-qnty-kg = (- v-InfoSectionsTotal:GetInfoSectionProp(iNum):CliQnty +
                             ((decimal(v-car-vol) + decimal(v-mouth)) * decimal(v-tank-density))).

            /* ТЗ: Поле-6.4 "Погрешность измерений (кг) факт" */
            v-error-meas-kg = (((decimal(v-car-vol) + decimal(v-mouth)) * decimal(v-tank-density)) * K1).


            if /*absolute(v-diff-qnty-kg) <= v-error-meas-kg*/ false then /*выводим без учета погрешности измерения*/
            do:
                v-shortage-surplus-kg = 0.
            end.
            else
            do:
                if v-diff-qnty-kg < 0 then do:
                  v-shortage-surplus-kg = v-diff-qnty-kg + v-norm-natur-loss .
                end.
                else v-shortage-surplus-kg = v-diff-qnty-kg - v-norm-natur-loss.
            end.
        end. /* v */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-shortage_surplus_kg}
            , input fnc-convert-dot-to-colon(v-shortage-surplus-kg, "->>>>>>>>9.999")
        ).

        /* ТЗ:Поле-8.6. "Норма естественной убыли (НЕУ) как разница данных между ТТН и Результатов измерений(расчёта)" ТЗ: 8.6 = 7.6 - 8.4 */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-diff_norm_natur_losses}
            , input fnc-convert-dot-to-colon(
                                            (v-norm-natur-loss)
                                            , "->>>>>>>>9.999")
        ).

        run proc-calc-library-pomi (
            input decimal(buf_doc-line.doc-qnty),
            input decimal(buf_doc-line.doc-qnty),
            input decimal(0),
            input v-diameter,
            input decimal(buf_doc-line.temperature),
            input decimal(buf_doc-line.doc-density),
            input decimal(buf_doc-line.temperature),
            input integer(v-place-si),
            input v-doc-code,
            input v-gds-code,
            output v-tank-density-pomi-dll, /* "Плотность приведенная" - расчитанная в DLL ПО МИ */
            output v-tank-vol-pomi-dll,     /* "Объём топлива приведенный" - расчитанный в DLL ПО МИ */
            output v-tank-weight-pomi-dll   /* "Количество (кг)" - рассчитанное в DLL ПО МИ */
        ).

        /* ТЗ: Поле-2.3. к таблице Акта. "Количество НП (л) по ТТН приведенное к 15С" (ТЗ: Объём по ТТН, приведённый к 15С)*/
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-tank_vol_pomi_DLL}
            , input fnc-convert-dot-to-colon(v-tank-vol-pomi-dll, "->>>>>>>>9.999")
        ).

        /* ТЗ: Поле-3.3. к таблице Акта. "Плотность НП (кг/куб.дм) по ТТН приведенное к 15С" (ТЗ: Плотность по ТТН, приведённое к 15С)*/
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-tank_density_pomi_DLL}
            , input fnc-convert-dot-to-colon(v-tank-density-pomi-dll, "->>>>>>>>9.9999")
        ).

        /* ТЗ: Поле-5.3. к таблице Акта. "Количество НП (кг) по ТТН приведенное к 15С" (ТЗ: Масса по ТТН, приведённое к 15С)*/
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-tank_weight_DLL}
            , input fnc-convert-dot-to-colon(v-tank-weight-pomi-dll, "->>>>>>>>9.999")
        ).

        /* ТЗ:Поле-3.7 "Плотность НП (кг/куб.м) как разница данных между ТТН и Результатов измерений(расчёта) приведённая к 15С" ТЗ: 3.7 = 3.3 - 3.5 */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-diff_tnk_dens_pomi_15C}
            , input fnc-convert-dot-to-colon(
                                            (- v-tank-density-pomi-dll + decimal(v-tank-density-pomi))
                                            , "->>>>>>>>9.9999")
        ).

        /* ТЗ:Поле-2.7. "Норма естественной убыли (НЕУ) как разница данных между ТТН и Результатов измерений(расчёта)" ТЗ: 2.7 = 2.3 - 2.5 */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-diff_tank_vol_pomi_15C}
            , input fnc-convert-dot-to-colon(
                                            (- v-tank-vol-pomi-dll + decimal(v-tank-vol-pomi))
                                            , "->>>>>>>>9.999")
        ).

        /* ТЗ:Поле-5.7 "Количество НП (кг) как разница данных между ТТН и Результатов измерений(расчёта)" ТЗ: 5.7 = 5.3 - 5.5 */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-diff_qnty_kg_15C}
            , input fnc-convert-dot-to-colon(
                                            (- v-tank-weight-pomi-dll + decimal(v-tank-weight))
                                            , "->>>>>>>>9.999")
        ).

        /* ТЗ:Поле-7.7 "Недостаёт/Излишествует (кг) приведённо к 15С" ТЗ: если: 0 < 5.7         < 6.5 тогда: 5.7 - 6.5;
                                                                          если: 0 > 5.7 и |5.7| > 6.5 тогда: 5.7 + 6.5; 
                                                                          если:     |5.7|      =< 6.5 тогда: 0 */
        /* Вычисление переменной v-shortage-surplus-kg (Недостаёт/Излишествует) */
        do: /* v2 */
            /* ТЗ: Поле-5.7 "Количество НП (кг) как разница данных между ТТН и Результатов измерений(расчёта)" */
            v-diff-qnty-kg-15C = - v-tank-weight-pomi-dll + decimal(v-tank-weight).

            /* ТЗ: Поле-6.5 "Погрешность измерений (кг) факт" */
            v-error-meas-kg-15C = decimal(v-tank-weight) * K1.

            if /*absolute(v-diff-qnty-kg-15C) <= v-error-meas-kg-15C*/ false then /*выводим без учета погрешности измерений*/
            do:
                v-shortage-surplus-kg-15C = 0.
            end.
            else
            do:
                if v-diff-qnty-kg-15C < 0 then do:
                v-shortage-surplus-kg-15C = v-diff-qnty-kg-15C + v-norm-natur-loss-15C .
                end.
                else v-shortage-surplus-kg-15C = v-diff-qnty-kg-15C - v-norm-natur-loss-15C.
            end.

        end. /* v2 */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-shor_surplus_kg_15C}
            , input fnc-convert-dot-to-colon(v-shortage-surplus-kg-15C, "->>>>>>>>9.999")
        ).

        /* ТЗ:Поле-8.7 "Норма естественной убыли (НЕУ) как разница данных между ТТН и Результатов измерений(расчёта)" ТЗ: 8.7 = 7.7 - 8.5 */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-diff_norm_nat_los_15C}
            , input fnc-convert-dot-to-colon(
                                            (v-norm-natur-loss-15C)
                                            , "->>>>>>>>9.999")
        ).

        /* ТЗ - без номера "от Перевозчика" */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-driver_name4}
            , input v-fio
        ).

        /* ТЗ - без номера "от Клиента" */ 
        /* Исправление Арн 29.05.2015. По заявке от Заказчика - в это поле в разрез с ТЗ необходимо занести ФИО из поля "Кладовщик" Приходной Накладной(его код - в trn-doc.wrkr) */
        run apn-xl-write-cell-data in this-procedure (
              input {&apn-xl-host_name3}
            /*, input v-clients-obj-name*/
            , input v-clients-boss-name
        ).

        /* ТЗ:Поле 1 ТЗ: Номер документа в формате "ПР№/порядковый номер строки из doc-line.line-num буква Н или Б" (если: 7.6 > 8.4 или 7.7 > 8.5 тогда "Н"
                                                                                                                     иначе: "Б" */
            define variable v-num-doc as character no-undo.
            v-num-doc = v-nakl + "/" + string(buf_doc-line.line-num).
            if v-shortage-surplus-kg > v-norm-natur-loss or v-shortage-surplus-kg-15C > v-norm-natur-loss-15C then
            do:
                v-num-doc = v-num-doc + "Н".
            end.
            else
            do:
                v-num-doc = v-num-doc + "Б".
            end.
            run apn-xl-write-cell-data in this-procedure (
                  input {&apn-xl-num_doc}
                , input (v-num-doc)
            ).
        /* ТЗ:Поле 1 */

        run apn-xl-close in this-procedure.

    end.    /*      if is-petrolium        */
    end.
    end.    /*        for each buf_doc-line     */
       { rep/q-print.i 4 }
       { gbl/stopwork.i }

end.



/* **********************  Internal Procedures  *********************** */

procedure get-DD-MM-YYYY:
/* Получение даты в формате "01.01.2014" */

    define input parameter p-dat-date as date no-undo.
    define output parameter p-str-date as character no-undo.

    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").

end procedure.

procedure get-DD-Month-YYYY:
/* Получение даты в формате "01 Января 2014г." */
    define input parameter p-dat-date as date no-undo.
    define output parameter p-str-date as character no-undo.

    define variable v-str-date as character no-undo.
    define variable v-str-day as character no-undo.
    define variable v-num-month as character no-undo.
    define variable v-str-month as character no-undo.
    define variable v-str-year as character no-undo.

    v-str-date = string(p-dat-date).

    do: /* Получаем день в формате цифры, вида NN. */
        v-str-day = string(entry(1, v-str-date, "/")).
    end. /* Получаем день в формате цифры, вида NN. */

    do: /* Получаем прописью месяц */
    v-num-month = entry(2, v-str-date, "/").
    v-str-month = MonthNameRusCase(integer(v-num-month), 2).
/*
        v-num-month = entry(2, v-str-date, "/").
        case v-num-month:
            when "01" then
                do:
                    assign v-str-month = "Января".
                end.
            when "02" then
                do:
                    assign v-str-month = "Февраля".
                end.
            when "03" then
                do:
                    assign v-str-month = "Марта".
                end.
            when "04" then
                do:
                    assign v-str-month = "Апреля".
                end.
            when "05" then
                do:
                    assign v-str-month = "Мая".
                end.
            when "06" then
                do:
                    assign v-str-month = "Июня".
                end.
            when "07" then
                do:
                    assign v-str-month = "Июля".
                end.
            when "08" then
                do:
                    assign v-str-month = "Августа".
                end.
            when "09" then
                do:
                    assign v-str-month = "Сентября".
                end.
            when "10" then
                do:
                    assign v-str-month = "Октября".
                end.
            when "11" then
                do:
                    assign v-str-month = "Ноября".
                end.
            when "12" then
                do:
                    assign v-str-month = "Декабря".
                end.
        end case.
*/
    end. /* Получаем прописью месяц */

    do: /* Получаем год в формате цифры, вида "NNNN" */
/*        v-str-year = entry(3, v-str-date, "/").*/
        v-str-year = string(year(p-dat-date)).
    end. /* Получаем год в формате цифры, вида "NNNN" */

    /* Получаем цифро-буквенную дату в одной строке */
    p-str-date = v-str-day + " " + v-str-month + " " + v-str-year + "г.".

end procedure.

procedure loc-get-set-attr :

  define input  parameter p-mode-attr as character no-undo .

  &scop loc-find-doc-attr ~
  find first buf_doc-attr ~
    where buf_doc-attr.doc-code  = v-doc-code ~
      and buf_doc-attr.attr-code = "~{&attr-name~}" ~
    no-error.

  &scop loc-get-doc-attr ~
    if available buf_doc-attr then do: ~
      assign ~
        v-~{&attr-name~} = buf_doc-attr.attr-value ~
      . ~
    end.
  &scop loc-get-doc-attr-date ~
    if available buf_doc-attr then do: ~
      assign ~
        v-~{&attr-name~} = date(buf_doc-attr.attr-value) ~
      . ~
    end.

  &scop loc-get-attr ~
      assign ~
        v-~{&attr-name~} = string(v-InfoSectionsTotal:GetInfoSectionProp(iNum):~{&attr-name-class~}~)~
      .
      
  &scop loc-get-attr-date ~
      assign ~
        v-~{&attr-name~} = v-InfoSectionsTotal:GetInfoSectionProp(iNum):~{&attr-name-class~}~
      .

  &scop loc-get-attr-int ~
      assign ~
        v-~{&attr-name~} = v-InfoSectionsTotal:GetInfoSectionProp(iNum):~{&attr-name-class~}~
      .


  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define buffer buf_doc-line-attr for ub.doc-line-attr .

    &scop attr-name {&bef-trdcattr-car-num}
    {&loc-find-doc-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-doc-attr}
    end.
    else do:
/*      {&loc-create-attr}
      {&loc-set-attr} ничего создовать в будущем не будем */
    end.

    &scop attr-name {&bef-trdcattr-inspection-cert}
    {&loc-find-doc-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-doc-attr}
    end.

    &scop attr-name {&bef-trdcattr-date-cert}
    {&loc-find-doc-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-doc-attr-date}
    end.

    &scop attr-name {&bef-trdcattr-autoent}
    {&loc-find-doc-attr}
    if p-mode-attr = "get-attr":U then do:
      &scop attr-name autoent-obj-type
      assign
        v-{&attr-name} = entry (1, buf_doc-attr.attr-value, ";")
      no-error.
    end.

    &scop attr-name {&bef-trdcattr-autoent}
    {&loc-find-doc-attr}
    if p-mode-attr = "get-attr":U then do:
      &scop attr-name autoent-obj-code
      assign
        v-{&attr-name} = entry (2, buf_doc-attr.attr-value, ";")
      no-error.
    end.
 

    &scop attr-name {&bef-trdcattr-ptb-item-pour}
    {&loc-find-doc-attr}
    if p-mode-attr = "get-attr":U then do:
      &scop attr-name item-pour
      {&loc-get-doc-attr}
    end.

    &scop attr-name {&bef-trdcattr-time-income}
    {&loc-find-doc-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-doc-attr}
    end.

    &scop attr-name {&bef-trdcattr-fio-driver}
    {&loc-find-doc-attr}
    if p-mode-attr = "get-attr":U then do:
      &scop attr-name fio
      {&loc-get-doc-attr}
    end.
    else do:

    end.

    &scop attr-name {&bef-trdcattr-ptbobj}
    {&loc-find-doc-attr}
    if p-mode-attr = "get-attr":U then do:
      &scop attr-name ptbotype
      assign
        v-{&attr-name} = entry (1, buf_doc-attr.attr-value, ";")
      no-error.
    end.
    else do:

    end.

    &scop attr-name {&bef-trdcattr-ptbobj}
    {&loc-find-doc-attr}
    if p-mode-attr = "get-attr":U then do:
      &scop attr-name ptbocode
      assign
        v-{&attr-name} = entry (2, buf_doc-attr.attr-value, ";")
      no-error.
    end.
    else do:

    end.

    &scop attr-name {&bef-trdcattr-time-pour}
    {&loc-find-doc-attr}
    if p-mode-attr = "get-attr":U then do:
      &scop attr-name time-pour
      assign
        v-{&attr-name} = buf_doc-attr.attr-value 
      no-error.
    end.
    else do:

    end.

    &scop attr-name {&bef-trdcattr-doc-not}
    {&loc-find-doc-attr}
    if p-mode-attr = "get-attr":U then do:
      &scop attr-name doc-not
      assign
        v-{&attr-name} = logical(buf_doc-attr.attr-value) 
      no-error.
    end.
    else do:

    end.
    
    &scop attr-name {&bef-trdcattr-spisok-not-doc}
    {&loc-find-doc-attr}
    if p-mode-attr = "get-attr":U then do:
      &scop attr-name spisok-not-doc
      assign
        v-{&attr-name} = buf_doc-attr.attr-value 
      no-error.
    end.
    else do:

    end.
    &scop attr-name car-vol
    &scop attr-name-class CarVol
    {&loc-get-attr}

    &scop attr-name dens-temp
    &scop attr-name-class DensTemp
    {&loc-get-attr}

    &scop attr-name tank-vol-pomi
    &scop attr-name-class TankVolPomi
    {&loc-get-attr}

    &scop attr-name tank-density-pomi
    &scop attr-name-class TankDensityPomi
    {&loc-get-attr}

    &scop attr-name place-si
    &scop attr-name-class PlaceSi
    {&loc-get-attr}

    &scop attr-name tests
    &scop attr-name-class Tests
    {&loc-get-attr}

    &scop attr-name certif-fuel
    &scop attr-name-class CertifFuel
    {&loc-get-attr}

    &scop attr-name norm-doc
    &scop attr-name-class NormDoc
    {&loc-get-attr}
        
    &scop attr-name num-passport
    &scop attr-name-class NumPassport
    {&loc-get-attr}
    
    &scop attr-name validity-certif
    &scop attr-name-class ValidityCertif
    {&loc-get-attr}

    &scop attr-name num-plotn
    &scop attr-name-class NumPlotn
    {&loc-get-attr}

    &scop attr-name passport-plotn
    &scop attr-name-class PassportPlotn
    {&loc-get-attr}
         
    &scop attr-name date-pov-plotn
    &scop attr-name-class DatePovPlotn
    {&loc-get-attr-date}

    /*v-time-pour = string (v-InfoSectionsTotal:GetInfoSectionProp(iNum):TimePour:Hour) + ":" + string (v-InfoSectionsTotal:GetInfoSectionProp(iNum):TimePour:Min).*/
 
    &scop attr-name date-start
    &scop attr-name-class DateStart
    {&loc-get-attr-date}

    &scop attr-name time-start
    &scop attr-name-class TimeStart
    {&loc-get-attr-int}

    &scop attr-name date-end
    &scop attr-name-class DateEnd
    {&loc-get-attr-date}

    &scop attr-name time-end
    &scop attr-name-class TimeEnd
    {&loc-get-attr-int}

    &scop attr-name tank-vol
    &scop attr-name-class TankVol
    {&loc-get-attr}

    &scop attr-name tank-temp
    &scop attr-name-class TankTemp
    {&loc-get-attr}

    &scop attr-name tank-water
    &scop attr-name-class TankWater
    {&loc-get-attr}

    &scop attr-name tank-density
    &scop attr-name-class TankDensity
    {&loc-get-attr}

    &scop attr-name tank-weight
    &scop attr-name-class TankWeight
    {&loc-get-attr}

    &scop attr-name mouth
    &scop attr-name-class Mouth
    {&loc-get-attr}

    &scop attr-name a-b-tarir
    &scop attr-name-class ABTarir
    {&loc-get-attr}

    return .

  end.
end procedure.

procedure proc-calc-library-pomi:
/* Вычисления с использованием библиотеки ПО МИ */

    define input parameter p-car-vol as decimal no-undo. /* Объём по транспорту (л). */
    define input parameter p-tank-vol as decimal no-undo. /* Объём топлива */
    define input parameter p-a-b-tarir as decimal no-undo. /* Уровень цистерны относительно тарировочной планки */
    define input parameter p-diameter as decimal no-undo. /* Диаметр горловины */
    define input parameter p-tank-temp as decimal no-undo. /* Температура замера объёма */
    define input parameter p-tank-density as decimal no-undo. /* Плотность топлива */
    define input parameter p-dens-temp as decimal no-undo. /* Температура замера плотности */
    define input parameter p-place-si as integer no-undo. /* Средство измерения */
    define input parameter p-doc-code like ub.trn-doc.doc-code no-undo.
    define input parameter p-gds-code like ub.goods.gds-code no-undo.
    define output parameter p-tank-density-pomi as decimal no-undo.
    define output parameter p-tank-vol-pomi as decimal no-undo.
    define output parameter p-tank-weight as decimal no-undo.
    

    define variable ToolType as integer no-undo.
    define variable DeltaAbs_R as decimal no-undo.
    define variable DeltaAbs_Tv as decimal no-undo.
    define variable DeltaAbs_Tr as decimal no-undo.

    define variable temp-for-pomi as integer no-undo.
    define variable error-string as character no-undo.
    define variable v-mm as com-handle.
    define variable v-proc as character no-undo.
    define variable v-gds-attr-value as character no-undo.
    define variable v-gds-attr-type as character no-undo.
    define variable v-fuel-type as character no-undo.

    define variable rdc-dnstvalue as character no-undo.
    define variable rdc-dnsttype as character no-undo.

    define buffer buf_clob-bind for ub.clob-bind.


    run gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", no, output rdc-dnstvalue, output rdc-dnsttype) no-error.
/*    if rdc-dnstvalue = "" or rdc-dnstvalue = ? then rdc-dnstvalue = "not".*/
/*    WAIT-FOR GO OF FRAME {&FRAME-NAME}. */ 
/*run  gbl/inidebug.p.*/
    case rdc-dnstvalue:
        when "pomi-rn" then
        do: /* "pomi-rn" */
            _trpomi:
                do on error undo, return no-apply:
                    /*данные по средству измерения резервуара для ПО МИ*/
                    run sr-izmerenia_fill-sr-izm in this-procedure (input {&lookup}, buffer buf_clob-bind).
                    find first sr-izmerenia no-lock where sr-izmerenia.node-code = p-place-si no-error.
                    if error-status :error or not available sr-izmerenia then
                    do:
                        message
                            substitute('Не найдено средство измерения с кодом &1', p-place-si) skip
                        view-as alert-box error.
                        undo _trpomi, return no-apply.
                    end.
                    else
                    do:
                        assign
                            ToolType = sr-izmerenia.sr-type-id
                            DeltaAbs_R = sr-izmerenia.sr-abs-err-dens
                            DeltaAbs_Tv = sr-izmerenia.sr-abs-err-temp-vol
                            DeltaAbs_Tr = sr-izmerenia.sr-abs-err-temp-dens
                        .
                    end.
                    /*..........................................*/
                    find first ub.trn-doc no-lock where ub.trn-doc.doc-code = p-doc-code no-error.
                    { gbl/ptrlprop.i
                        run
                        trn-doc.obj-type
                        trn-doc.obj-code
                    }
                    if not error-status :error then
                    do:
                        if ptrlprop-temp-for-pomi = 1 then temp-for-pomi = 15.
                                                      else temp-for-pomi = 20.
                    end.
                    v-proc = "ADMM.MethodOfMetering31N" .
    
                    release object v-mm no-error.
                    v-mm = ?.
    
                    create value("ADMM.MethodOfMetering31N") v-mm no-error.
                    if error-status:error or not valid-handle(v-mm) then
                    do:
                        release object v-mm no-error.
                        v-mm = ?.
                        message
                            substitute('Не удается подключиться к COM-серверу библиотеки для работы с ПО МИ ') skip
                        view-as alert-box error.
                        undo _trpomi, return no-apply.
                    end.
                    else
                    do:
/*                    if p-car-vol = "?" or p-car-vol = "0" then                              */
/*                    do:                                                                     */
/*                        message                                                             */
/*                            "Заполнены не все поля, необходимые " skip                      */
/*                            "для работы библиотеки ПО МИ"         skip                      */
/*                            "Введите Объем по паспорту в литрах"  skip                      */
/*                        view-as alert-box error.                                            */
/*                        apply "entry" to f-car-vol in frame {&frame-name}.                  */
/*                        undo _trpomi, return no-apply.                                      */
/*                    end.                                                                    */
/*                    if p-a-b-tarir = ? or p-a-b-tarir = 0 then                              */
/*                    do:                                                                     */
/*                        message                                                             */
/*                            "Заполнены не все поля, необходимые " skip                      */
/*                            "для работы библиотеки ПО МИ"         skip                      */
/*                            "Введите Уровень цистерны относительно тарировочной планки" skip*/
/*                        view-as alert-box error.                                            */
/*                        apply "entry" to p-a-b-tarir in frame {&frame-name}.                */
/*                        undo _trpomi, return no-apply.                                      */
/*                    end.                                                                    */
/*                    if p-diameter = ? or p-diameter = 0 then                                */
/*                    do:                                                                     */
/*                        message                                                             */
/*                            "Заполнены не все поля, необходимые " skip                      */
/*                            "для работы библиотеки ПО МИ"         skip                      */
/*                            "Введите Внутренний диаметр горловины" skip                     */
/*                        view-as alert-box error.                                            */
/*                        apply "entry" to p-diameter in frame {&frame-name}.                 */
/*                        undo _trpomi, return no-apply.                                      */
/*                    end.                                                                    */
/*                    if p-tank-temp = ? then                                                 */
/*                    do:                                                                     */
/*                        message                                                             */
/*                            "Заполнены не все поля, необходимые " skip                      */
/*                            "для работы библиотеки ПО МИ" skip                              */
/*                            "Введите Температуру" skip                                      */
/*                        view-as alert-box error.                                            */
/*                        apply "entry" to p-tank-temp in frame {&frame-name}.                */
/*                        undo _trpomi, return no-apply.                                      */
/*                    end.                                                                    */
/*                    if p-tank-density = ? or p-tank-density = 0 then                        */
/*                    do:                                                                     */
/*                        message                                                             */
/*                            "Заполнены не все поля, необходимые " skip                      */
/*                            "для работы библиотеки ПО МИ" skip                              */
/*                            "Введите Плотность топлива для ПО МИ" skip                      */
/*                        view-as alert-box error.                                            */
/*                        apply "entry" to p-tank-density in frame {&frame-name}.             */
/*                        undo _trpomi, return no-apply.                                      */
/*                    end.                                                                    */

                            v-mm:V_real         = if p-car-vol <> ? then p-car-vol else 0.
                            v-mm:DeltaH         = if p-a-b-tarir <> ? then p-a-b-tarir else 0 .
                            v-mm:Dgor           = if p-diameter <> ? then p-diameter else 0 .
                            v-mm:Tv             = if p-tank-temp <> ? then p-tank-temp else 0 .
                            v-mm:Tr             = if p-dens-temp <> ? then p-dens-temp else 0 .
                            v-mm:R              = if p-tank-density <> ? then (p-tank-density * 1000) else 0 .
                            v-mm:Tcy            = if temp-for-pomi <> ? then temp-for-pomi else 0 .
                            v-mm:ToolType       = if ToolType <> ? then ToolType else 0 .
/*                            v-mm:A_Reservoir    = 0.0000125 .*/
                            v-mm:DeltaOtn_V     = 0.4 .
                            v-mm:DeltaAbs_R     = if DeltaAbs_R <> ? then DeltaAbs_R else 0 .
                            v-mm:DeltaAbs_Tv    = if DeltaAbs_Tv <> ? then DeltaAbs_Tv else 0 .
                            v-mm:DeltaAbs_Tr    = if DeltaAbs_Tr <> ? then DeltaAbs_Tr else 0 .
                        .
/*                output stream outstream to value ("pomi.log") append.*/
/*                put stream outstream                                 */
/*                                       cur-time-string()       skip  */
/*                    'Процедура'        v-proc                  skip  */
/*                    'V_real         =' p-car-vol               skip  */
/*                    'DeltaH         =' p-a-b-tarir             skip  */
/*                    'Dgor           =' p-diameter              skip  */
/*                    'Tv             =' p-tank-temp             skip  */
/*                    'Tr             =' p-dens-temp             skip  */
/*                    'R              =' (p-tank-density * 1000) skip  */
/*                    'Tcy            =' temp-for-pomi           skip  */
/*                    'ToolType       =' ToolType                skip  */
/*                    'A_Reservoir    =' 0.0000125               skip  */
/*                    'DeltaOtn_V     =' 0.4                     skip  */
/*                    'DeltaAbs_R     =' DeltaAbs_R              skip  */
/*                    'DeltaAbs_Tv    =' DeltaAbs_Tv             skip  */
/*                    'DeltaAbs_Tr    =' DeltaAbs_Tr             skip  */
/*                .                                                    */
/*                output stream outstream close.                       */
  
                        v-mm:Exec().
                        if v-mm:Result <> 0 then
                        do:
                            error-string = v-mm:ResultDetail.
/*                        output stream outstream to value ("pomi.log") append.   */
/*                        put stream outstream error-string format "x(1024)" skip.*/
/*                        output stream outstream close.                          */
                            release object v-mm no-error.
                            v-mm = ?.
                            message
                                substitute('Ошибка работы библиотеки ПО МИ &1',error-string)
                            view-as alert-box error.
                            undo _trpomi, return no-apply.
                        end.
                        else
                        do:
                            assign
                                p-tank-density-pomi = decimal(v-mm:Rcy) / 1000
                                p-tank-vol-pomi = v-mm:Vcy
                                p-tank-weight = v-mm:Mcy
                            .
/*                            display                                              */
/*                                p-tank-density-pomi                              */
/*                                p-tank-vol-pomi                                  */
/*                                f-tank-weight                                    */
/*                            with frame {&frame-name}.                            */
/*                            output stream outstream to value ("pomi.log") append.*/
/*                            put stream outstream                                 */
/*                                "v-mm:Rcy" p-tank-density-pomi skip              */
/*                                "v-mm:Vcy" p-tank-vol-pomi skip                  */
/*                                "v-mm:Mcy" f-tank-weight skip.                   */
/*                            output stream outstream close.                       */
                            release object v-mm no-error.
                            v-mm = ?.
                        end.
                    end.
                end.
        end. /* "pomi-rn" */
        when "th" then
        do:
            run gds-attr-value in this-procedure
                (  input p-gds-code
                ,  input {&attr-fuel-type}
                , output v-gds-attr-value
                , output v-gds-attr-type
                ) no-error.
            if not error-status:error and lookup (v-gds-attr-value, "petrol,diesel-sum,diesel-wint") > 0 then
            do:
                assign v-fuel-type = v-gds-attr-value.

                run str/rdcdnst.p (input p-tank-density * 1000
                    ,input p-dens-temp
                    ,input p-tank-vol
                    ,input p-tank-temp
                    ,input v-fuel-type
                    ,output p-tank-density-pomi 
                    ,output p-tank-vol-pomi)
                no-error.
                if not error-status:error then
                do:
                    assign p-tank-weight = p-tank-density-pomi * p-tank-vol-pomi.
/*                    display                  */
/*                        p-tank-vol-pomi    */
/*                        p-tank-density-pomi*/
/*                        p-tank-weight        */
/*                    with frame {&frame-name}.*/
                end.
                else
                do:
                    message
                        substitute('Ошибка при рассчете приведенных значений плотности и объема: &1', return-value)
                    view-as alert-box error.
                    undo, return no-apply.
                end.
            end.
            else
            do:
                message
                    substitute('Ошибка определения типа топлива &1 или не верный тип товлива &2', return-value, v-gds-attr-value)
                view-as alert-box error.
                undo, return no-apply.
            end.
        end.
    end case.

end procedure.

procedure proc-get-address:
/* Получение адреса любого клиента */
    define input parameter p-cli-obj-type like clients.obj-type no-undo.
    define input parameter p-cli-obj-code like clients.obj-code no-undo.
    define output parameter p-str-address as character no-undo.

    p-cli-obj-type = trim(p-cli-obj-type). /* Все текстовые переменные принудительно очищаем от пробелов. */

    case p-cli-obj-type:
        when {&cmp} then /* Если это "орг" */
        do:
            find first firm where firm.firm-code = p-cli-obj-code no-lock.
            if available firm then
            do:
                p-str-address =
                (if trim(firm.post-addr1) = "" then (if trim(firm.post-addr2) = "" then "" else trim(firm.post-addr2) + ".")
                else (if trim(firm.post-addr2) = "" then trim(firm.post-addr1) + "."
                      else trim(firm.post-addr1) + ", " + trim(firm.post-addr2) + ".")).
            end.
        end.
        when {&shop} then /* Если это "маг" */
        do:
            find first shop where shop.obj-code = p-cli-obj-code no-lock.
                if available shop then
                do:
                    p-str-address =
                    (if trim(shop.addres1) = "" then
                        (if trim(shop.addres2) = "" then "" else trim(shop.addres2) + ".")
                     else (if trim(shop.addres2) = "" then trim(shop.addres1) + "."
                           else trim(shop.addres1) + ", " + trim(shop.addres2) + ".")).
                end.
            end.
        when {&stock} then /* Если это "скл" (склад). */
        do:
            find first store where store.obj-code = p-cli-obj-code no-lock.
            if available store then
            do:
                p-str-address =
                (if trim(store.addres1) = "" then (if trim(store.addres2) = "" then ""
                                                  else ", " + trim(store.addres2) + ".")
                else (if trim(store.addres2) = "" then ", " + trim(store.addres1) + "."
                      else ", " + trim(store.addres1) + trim(store.addres2) + ".")).
            end.
        end.
        when {&prs} then /* Если это "чел" (человек). */
        do:
            find first person where person.psn-code = p-cli-obj-code no-lock.
            if available person then
            do:
                p-str-address =
                (if trim(person.address) = ""  then "" else trim(person.address) + ".").
            end.
        end.
    end case.

end procedure.


/* ************************  Function Implementations ***************** */

function fnc-convert-dot-to-colon returns character 
(input p-data as decimal, input p-accur as character):
/* Конвертация десятичной точки в запятую с передачей параметра форматирования числа */

	define variable result as character no-undo.
    define variable v-str-result as character no-undo.

    p-data = round(p-data, 4). /* Чтобы не выйти случайно за рамки формата числа при выводе (несоотвесвие формата результата и формата отображения - приводит к ош) */
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).

	return v-str-result.

end function.

function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date):
/* Преобразование даты в формат: "01.01.2014" */

    define variable result as character no-undo.
    define variable p-str-date as character no-undo.

    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").

		return p-str-date.

end function.
