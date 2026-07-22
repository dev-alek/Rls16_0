/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура получения номера кода (бар-код, весовой код, ...)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/99
Author: Dmitry Ukhanov
Creation date: 03/22/99

*/
/*
Процедура получает номер из sequence
Сравнивает полученное значение с активным диапазоном
Если sequence вышел за пределы диапазона, то производится смена активного диапазона
и переустановка значения sequence
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


procedure gen-b-code :

  define input  parameter type-code like ub.code-range.range-type no-undo . /* тип кода, значение которого хотим получить */
  define output parameter p-b-code  like ub.bar-code.b-code       no-undo . /* выходное значение бар-кода                 */

  do
  on error  undo, return error substitute( "&1 (gen-b-code). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-b-code). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-b-code). endkey", vss-workfile )
  :
    define buffer buf_thbj-attr     for ub.thbj-attr .
    define buffer buf_sys-ctrl   for ub.sys-ctrl .
    define buffer buf_code-range for ub.code-range .

    define variable l-code         as   integer              no-undo .
    define variable v-db-num       like ub.db.db-num         no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .

    if type-code = {&loc-ss-code}
    or type-code = {&gbl-ss-code}
    then do:
      /* диапазон локальных взвешиваемых кодов */
      message
        "Нельзя генерировать локальный или глобальный взвешиваемый код." skip
        "Обратитесь к администратору системы."
        view-as alert-box error .
      undo, return error (if type-code = {&loc-ss-code} then "loc-ss-code":U else "gbl-ss-code" ) .
    end.

    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    run get-next-seq( input  type-code,
                      output l-code
                    ).

    find first buf_sys-ctrl no-lock.
    if type-code = {&loc-sc-code}
    or type-code = {&loc-pg-code}
    then do:
      /* диапазон локальных весовых кодов всегда привязан к ГБД */
      assign
        v-db-num = 0
      .
    end.
    else do:
      assign
        v-db-num = buf_sys-ctrl.db-num
      .
    end.
    find first buf_code-range no-lock
      where buf_code-range.db-num     = v-db-num
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "a"
      use-index stts
      no-error .
    if available buf_code-range
       and l-code <= buf_code-range.last-code
       and l-code >= buf_code-range.first-code then do:
      /* значение внутри активного диапазона - выставляем его по sequence */
      assign
        p-b-code = l-code
      .
    end.
    else do:
      if available buf_code-range
         and l-code < buf_code-range.last-code then do:
        message
          substitute( "Последовательность для создания кодов с типом &1 имеет неверное значение.", type-code ) skip
          "Обратитесь к администратору системы."
          view-as alert-box error .
        undo, return error "sequence":U .
      end.
      /* завхватываем thbj-attr */
      /* чтобы никто другой не мог одновременно менять диапазон */
      do transaction
      on error undo, return error
      :
        find first buf_thbj-attr exclusive-lock
          where buf_thbj-attr.upper-prop-code = {&attr-code-range}
            and buf_thbj-attr.prop-code = cfg-param-code
            and buf_thbj-attr.obj-type   = {&db}
            and buf_thbj-attr.obj-code   = v-db-num
          no-error .
        if not available buf_thbj-attr then do:
          find first buf_thbj-attr exclusive-lock
            where buf_thbj-attr.upper-prop-code = {&attr-code-range}
              and buf_thbj-attr.prop-code = cfg-param-code
              and buf_thbj-attr.obj-type   = ''
              and buf_thbj-attr.obj-code   = 0
            no-error .
          if not available buf_thbj-attr then do:
            if not locked buf_thbj-attr then do:
              message
                substitute( "Отсутствует параметр 'длина диапазона кодов' (&1) для БД &2.", cfg-param-code, buf_sys-ctrl.db-num ) skip
                "Обратитесь к администратору системы."
                view-as alert-box error .
            end.
            /* если пользователь отказался подождать, */
            /* то ему не дадим менять диапазон и бар-код не дадим ! */
            undo, return error "config":U .
          end. /*if not available buf_thbj-attr then do:*/
        end. /*if not available buf_thbj-attr then do:*/

        run get-next-seq( input type-code,
                          output l-code
                        ).
        /* если диапазон сменился другим пользователем */
        /* то надо перечитать значение sequence, */
        /* если не сменился, то требуется смена диапазона и смена sequence */
        find first buf_code-range
          where buf_code-range.db-num     = v-db-num
            and buf_code-range.range-type = type-code
            and buf_code-range.stts       = "a"
          use-index stts
          no-error .
        if available buf_code-range
        and l-code <= buf_code-range.last-code
        and l-code >= buf_code-range.first-code
        then do:
          assign
            p-b-code = l-code
          .
        end.
        else do:
          if available buf_code-range then do:
            /* диапазон никто не сменил */
            /* sequence за пределами диапазона */
            /* помечаем его как использованный */
            assign
              buf_code-range.stts = "u"
            .
          end.
          find first buf_code-range
            where buf_code-range.db-num     = v-db-num
              and buf_code-range.range-type = type-code
              and buf_code-range.stts       = "f"
            use-index stts
            no-error .
          if not available buf_code-range then do:
            message
              substitute( "Отсутствует свободный диапазон для кодов с типом &1.", type-code ) skip
              "Обратитесь к администратору системы"
              view-as alert-box error .
            undo, return error "code-range":U .
          end.

          /* создаем новый диапазон и присваиваем новое значение seq */
          assign
            buf_code-range.stts           = "a"
          .
          if buf_code-range.first-code = 1 then do:
            run set-seq-cr( input type-code,
                            input buf_code-range.first-code
                          ).
            assign
              p-b-code = 1
            .
          end.
          else do:
            run set-seq-cr( input type-code,
                            input ( buf_code-range.first-code - 1 )
                          ).
            run get-next-seq( input type-code,
                              output p-b-code
                            ).
          end.
        end.
      end.
    end.
  end.
end procedure.

procedure get-next-seq :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter next-seq  as   integer                  no-undo .

  do
  on error  undo, return error substitute( "&1 (get-next-seq). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-next-seq). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-next-seq). endkey", vss-workfile )
  :
    case type-code:
      when {&gbl-bc-code} then do:
        assign
          next-seq = next-value(s-bcgb-code, {&db-name_schema})
        .
      end.
      when {&gbl-sc-code} then do:
        assign
          next-seq = next-value(s-scgb-code, {&db-name_schema})
        .
      end.
      when {&loc-sc-code} then do:
        assign
          next-seq = next-value(s-sclc-code, {&db-name_schema})
        .
      end.
      when {&loc-pg-code} then do:
        assign
          next-seq = next-value(s-pglc-code, {&db-name_schema})
        .
      end.
      when {&gbl-dc-code} then do:
        assign
          next-seq = next-value(s-dcgb-code, {&db-name_schema})
        .
      end.
      when {&gbl-ct-code} then do:
        assign
          next-seq = next-value(s-ctgb-code, {&db-name_schema})
        .
      end.
      when {&gbl-dr-code} then do:
        assign
          next-seq = next-value(s-drgb-code, {&db-name_schema})
        .
      end.
      when {&gbl-fm-code} then do:
        assign
          next-seq = next-value(s-fmgb-code, {&db-name_schema})
        .
      end.
      when {&gbl-pn-code} then do:
        assign
          next-seq = next-value(s-pngb-code, {&db-name_schema})
        .
      end.
      when {&gbl-ca-code} then do:
        assign
          next-seq = next-value(s-cagb-code, {&db-name_schema})
        .
      end.
      when {&gbl-fd-code} then do:
        assign
          next-seq = next-value(s-fin-doc, {&db-name_schema})
        .
      end.
    end case.
  end.
end procedure. /* get-next-seq */

procedure set-seq-cr :
  define input parameter type-code like ub.code-range.range-type no-undo .
  define input parameter set-val   like ub.code-range.first-code no-undo .

  do
  on error  undo, return error substitute( "&1 (set-seq-cr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (set-seq-cr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (set-seq-cr). endkey", vss-workfile )
  :
    case type-code:
      when {&gbl-bc-code} then do:
        assign
          current-value(s-bcgb-code, {&db-name_schema}) = set-val
        .
      end.
      when {&gbl-sc-code} then do:
        assign
          current-value(s-scgb-code, {&db-name_schema}) = set-val
        .
      end.
      when {&loc-sc-code} then do:
        assign
          current-value(s-sclc-code, {&db-name_schema}) = set-val
        .
      end.
      when {&loc-pg-code} then do:
        assign
          current-value(s-pglc-code, {&db-name_schema}) = set-val
        .
      end.
      when {&gbl-dc-code} then do:
        assign
          current-value(s-dcgb-code, {&db-name_schema}) = set-val
        .
      end.
      when {&gbl-ct-code} then do:
        assign
          current-value(s-ctgb-code, {&db-name_schema}) = set-val
        .
      end.
      when {&gbl-dr-code} then do:
        assign
          current-value(s-drgb-code, {&db-name_schema}) = set-val
        .
      end.
      when {&gbl-fm-code} then do:
        assign
          current-value(s-fmgb-code, {&db-name_schema}) = set-val
        .
      end.
      when {&gbl-pn-code} then do:
        assign
          current-value(s-pngb-code, {&db-name_schema}) = set-val
        .
      end.
      when {&gbl-ca-code} then do:
        assign
          current-value(s-cagb-code, {&db-name_schema}) = set-val
        .
      end.
      when {&gbl-fd-code} then do:
        assign
          current-value(s-fin-doc, {&db-name_schema}) = set-val
        .
      end.
    end case.
  end.
end procedure. /* set-seq-cr */

procedure new-bcod-gen-code-range :

  do
  on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
  :
    /* процедура создания нового свободного code-range для  */

    define input parameter p-db-num  like ub.db.db-num             no-undo .
    define input parameter type-code like ub.code-range.range-type no-undo .

    define buffer buf_code-range      for ub.code-range .
    define buffer last_code-range     for ub.code-range .
    define buffer last-1_code-range   for ub.code-range .
    define buffer last-2_code-range   for ub.code-range .
    define buffer last-3_code-range   for ub.code-range .
    define buffer buf_sys-ctrl        for ub.sys-ctrl .

    define variable conf-par       as character no-undo . /* для чтения параметра конфигурации */
    define variable par-type       as character no-undo . /* тип параметра конфигурации */
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .

    define variable v-cre-cdrg as logical   no-undo .
    define variable v-cre-str  as character no-undo .
    define variable v-cr1      as integer no-undo .
    define variable v-cr2      as integer no-undo .
    define variable v-cr3      as integer no-undo .
    define variable v-cmax     as integer no-undo .

    find first buf_sys-ctrl no-lock .

    if buf_sys-ctrl.db-num <> 0 and type-code <> {&gbl-ca-code} then do:
      undo, return error substitute("&1 &2 &3&4Диапазоны кодов можно создавать только в ГБД&4База данных &5"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,{&new-line}
                                    , p-db-num
                                   ).
    end.

    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).

    /* если бар-код из второй половины используемого диапазона и нет
        для этой БД свободного диапазона то надо его назначить
      */

    /* ищем самый первый диапазон, не привязанный ни к одной из баз данных */
    /* привязываем его к базе данных и выходим из процедуры */
    for each buf_code-range
      where buf_code-range.db-num     = -1
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "f"
    by buf_code-range.first-code
    on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
    :
      assign
        buf_code-range.db-num = p-db-num
      .
      return . /* --->>>--- */
    end.

    /* непривязанные диапазоны отсутствуют */
    /* находим последний диапазон */

    assign
      v-cre-cdrg = TRUE
    .
       /* message    type-code view-as alert-box. */
    case type-code:
      when {&loc-sc-code}
      or when {&gbl-sc-code}
      or when {&loc-pg-code}
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = {&loc-sc-code}
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = {&gbl-sc-code}
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = {&loc-pg-code}
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
        if last_code-range.last-code + 1 > 99999 then do:
        /* Диапазон весовых кодов может быть в пределах от 100 до 99999 включительно */
        /* Если выходим за пределы, то больше ничего не создаем                      */
          assign
            v-cre-cdrg = FALSE
          .
        end.
      end.
      when {&gbl-bc-code}
      or when {&loc-ss-code}
      or when {&gbl-ss-code}
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = {&loc-ss-code}
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = {&gbl-bc-code}
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = {&gbl-ss-code}
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
      end.
      otherwise do:
        find last last_code-range no-lock
          where last_code-range.range-type = type-code
          no-error .
      end.
    end case.
    if not available last_code-range then do:
      undo, return error substitute("&1 &2 &3&4В БД нет ни одного диапазона с типом &5&4Не была проведена инициализация диапазонов!"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    , {&new-line}
                                    , type-code
                                   ) .
    end.
    define variable v-mes{&vssseq} as character no-undo .
    define variable v-param-type{&vssseq} as character no-undo .
    define variable v-value-character{&vssseq} as INTEGER no-undo .
    define variable v-value-date{&vssseq} as date no-undo .
    define variable v-value-decimal{&vssseq} as decimal no-undo .
    define variable v-value-integer{&vssseq} AS integer no-undo .
    define variable v-value-logical{&vssseq} AS LOGICAL no-undo .
    define variable v-tth{&vssseq} as handle no-undo .

    run adm/shattri.p (
        input "get":U
        ,input  {&db}
        ,input  p-db-num
        ,input  {&attr-code-range}
        ,input  cfg-param-code /*p-param-code*/
        ,output v-value-character{&vssseq}
        ,output v-value-date{&vssseq}
        ,output v-value-decimal{&vssseq}
        ,output v-value-integer{&vssseq}
        ,output v-value-logical{&vssseq}
        ,output v-param-type{&vssseq}
        ,INPUT-OUTPUT table-handle v-tth{&vssseq}
        ) no-error .

    if error-status :error then do:
      delete object v-tth{&vssseq}.
      v-mes{&vssseq} = substitute("Ошибка при получении размера диапазона собственных глобальных кодов&2&1&2&3"
                         , error-status:get-message(1)
                         , {&new-line}
                         , return-value ).
      undo, return error v-mes{&vssseq}.
    end.
    delete object v-tth{&vssseq}.

    if v-cre-cdrg = TRUE then do:
      create buf_code-range .
      assign
        buf_code-range.db-num     = p-db-num
        buf_code-range.range-type = type-code
        buf_code-range.stts       = "f"
        buf_code-range.first-code = last_code-range.last-code + 1
        buf_code-range.last-code  = last_code-range.last-code + integer(v-value-integer{&vssseq})
        v-cre-str = "Свободный диапазон успешно создан"
      .
    end.
    else do:
      assign
        v-cre-str = "Нет возможности создать свободный диапазон." + {&new-line}
                    + substitute( "Превышен предел диапазонов c типом &1", type-code )
      .
    end.

  end.

  return v-cre-str .

end procedure. /* new-bcod-gen-code-range */

procedure gen-new-code-range-if-neces :

  define input parameter v-db-num           like ub.db.db-num             no-undo .
  define input parameter v-range-type       like ub.code-range.range-type no-undo .
  define input parameter v-cur-code         as   integer                  no-undo .
  define input parameter v-g#news           as   logical                  no-undo .
  define input parameter v-g#db-num         like ub.db.db-num             no-undo .
  define input parameter v-g#news-source-db like ub.db.db-num             no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-new-code-range-if-neces). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-new-code-range-if-neces). endkey", vss-workfile )
  :
    define variable l-code-range-exist as logical   no-undo init false .
    define variable v-db-for-send      as character no-undo .
    define buffer buf_code-range  for ub.code-range .
    define buffer buf1_code-range for ub.code-range .
    define buffer buf_db          for ub.db .

/* нам необходимо найти code-range в соответствии с указанными условиями */
/*    find buf_code-range where*/
/*         buf_code-range.db-num = v-db-num and*/
/*         buf_code-range.range-type = v-range-type and*/
/*         buf_code-range.first-code <= v-cur-code and*/
/*         buf_code-range.last-code >= v-cur-code no-error.*/

    /* так реализован эффективный поиск */
    find first buf_code-range
      where buf_code-range.range-type = v-range-type
        and buf_code-range.last-code >= v-cur-code
      use-index last-codei
      no-error .
    if
    (
       available buf_code-range
       and
      (buf_code-range.db-num = v-db-num
        and
      buf_code-range.first-code <= v-cur-code
      )
    or
      (
        v-range-type = {&gbl-dr-code}
        AND
        v-cur-code = 0
      )
   )
   then do:
      assign
        l-code-range-exist = true
      .
      if v-g#news
      /* для удаленных баз используемые диапазоны помечаем сразу как использованные */
      /* т.к. диапазоны пересылаются только в УБД а обратно не ходят */
      and buf_code-range.stts = "f" then do:
        assign
          buf_code-range.stts = "u"
        .
      end.
    end.
    if not l-code-range-exist /* not available buf_code-range */
       and v-g#news-source-db <> 0
    then do:
      /* Если УБД то диапазон мог прийти после бар-кода,
         так как бар-код мог быть "подтянутым" к товару
       */
      undo, return error substitute("&1 &2 &3&4Отсутствует диапазон кодов для БД &5 Тип диапазона кодов &6 Код &7"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,{&new-line}
                                    ,v-db-num
                                    ,v-range-type
                                    ,v-cur-code
                                   ).
    end.

    if (not l-code-range-exist
        or ( v-cur-code >= int( (buf_code-range.first-code + buf_code-range.last-code) / 2 ) )
       )
    and ( not can-find (first buf1_code-range no-lock
                        where buf1_code-range.db-num = v-db-num
                          and buf1_code-range.range-type = v-range-type
                          and buf1_code-range.stts = "f"
                       )
        )
    then do:
      if v-g#db-num = 0 then do:
        /* создаем новый свободный диапазон */
        run new-bcod-gen-code-range in this-procedure
          (input v-db-num,
           input v-range-type
          ) no-error .
        if error-status :error then do:
          undo, return error substitute("Ошибка при создании нового свободного диапазона &1 Тип диапазона кодов &2 Код &3:&4&5 &6"
                                        , substitute("&1 &2 &3", vss-workfile, vss-revision, vss-description)
                                        ,v-db-num
                                        ,v-range-type
                                        ,v-cur-code
                                        ,{&new-line}
                                        ,error-status:get-message(1)
                                        ,return-value
                                       ).
        end.
      end.
      else do:
        if v-range-type = {&loc-sc-code}
        or v-range-type = {&loc-pg-code}
        then do:
          assign
            v-db-for-send = "":U
          .
          if v-g#db-num = 0 then do:
            for each buf_db no-lock
              where buf_db.db-num > 0
                and buf_db.db-num <> v-g#news-source-db
            on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
            :
              assign
                v-db-for-send = v-db-for-send + {&delim-nws} + string( buf_db.db-num )
              .
            end.
            assign
              v-db-for-send = right-trim( v-db-for-send, {&delim-nws} )
            .
          end.
          else do:
            if not v-g#news then do:
              assign
                v-db-for-send = "0":U
              .
            end.
          end.
          run nws/cr-route.p ( input {&send-cmd}
                        ,input ("command":U + {&delim-nws} + "create":U + {&delim-nws} +
                               "code-range":U + {&delim-nws} +
                               (if v-range-type = {&loc-sc-code}
                                then string( current-value(s-sclc-code, {&db-name_schema}))
                                else string( current-value(s-pglc-code, {&db-name_schema}))
                                ) + {&delim-nws} +
                                v-range-type)
                        ,input ?
                        ,input v-db-for-send
                        ) no-error .
          if error-status :error then do:
            undo, return error return-value.
          end.
        end.
      end.
    end.
  end.
end procedure. /* gen-new-code-range-if-neces */

procedure cre-loc-sc-code-range :
  define input parameter v-cur-code as integer no-undo .
define input parameter p-cdrg-type as character no-undo .
  do
  on error  undo, return error substitute( "&1 (cre-loc-sc-code-range). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (cre-loc-sc-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (cre-loc-sc-code-range). endkey", vss-workfile )
  :
    define buffer buf_code-range for ub.code-range .

    find first buf_code-range
         where buf_code-range.range-type = p-cdrg-type
           and buf_code-range.first-code >= v-cur-code
         no-error .
    if not available buf_code-range then do:
      /* создаем новый свободный диапазон */
      run new-bcod-gen-code-range in this-procedure
        ( input 0, /* диапазон локальных кодов всегда привязан в ГБД */
          input p-cdrg-type
        ) no-error .
      if error-status :error then do:
        undo, return error substitute( "Ошибка при создании нового свободного диапазона локальных весовых или штучных кодов&1"
                                       + "Код &2&1&3 &4"
                                      , {&new-line}
                                      , v-cur-code
                                      , error-status:get-message(1)
                                      , return-value
                                     ) .
      end.
    end.
  end.
end procedure. /* cre-loc-sc-code-range */

procedure mark-used-if-need :
define input parameter p-cur-code as integer no-undo .
define input parameter p-range-type like ub.code-range.range-type no-undo .
define input parameter p-db-num like ub.code-range.db-num no-undo .

  do
  on error  undo, return error substitute( "&1 (mark-used-if-need). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (mark-used-if-need). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (mark-used-if-need). endkey", vss-workfile )
  :

    DEFINE VARIABLE v-db-num like ub.code-range.db-num no-undo .
    define buffer buf_code-range for ub.code-range .

    assign
    v-db-num = if p-range-type = {&loc-sc-code}
               then 0
               else p-db-num
    .
    { trg/locklscc.i }
    find first buf_code-range
         where buf_code-range.range-type = p-range-type
           and buf_code-range.first-code >= p-cur-code
           and buf_code-range.last-code <= p-cur-code
           and buf_code-range.db-num = v-db-num
         no-error .

    if not available buf_code-range then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании поиске диапазона" skip
        "База данных" p-db-num skip
        "Код" p-cur-code skip
        "Тип" p-range-type
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_code-range.stts = "f":U then do:
      assign
      buf_code-range.stts = "u":U
      .
    end.
  end.

end procedure. /* mark-used-if-need */

/* $Workfile$ */