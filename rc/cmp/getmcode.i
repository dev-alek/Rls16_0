/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

процедура поиска максимального значения кода внутри активного диапазона и корректировки статуса code-range

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/02
Author: Dmitry Ukhanov
Creation date: 03/22/02

*/
{ cmp/operlist.i }

define stream getmc-stream .

procedure get-max-code :

  define input  parameter p-action         as   character                 no-undo .
  define input  parameter p-db-num         like {1}.db.db-num             no-undo .
  define input  parameter p-curr-type-cdrg like {1}.code-range.range-type no-undo .
  define input  parameter p-first-code     like {1}.code-range.first-code no-undo .
  define input  parameter p-last-code      like {1}.code-range.last-code  no-undo .
  define input  parameter p-view-mess      as   logical                   no-undo .
  define output parameter v-b-code         as   integer                   no-undo .
                          /* v-b-code в случае p-action = "get-m-code" это максимальный код                         */
                          /* v-b-code в случае p-action = "f-u" это кол-во откорректированых статусов code-range */
  do
  on error undo, return error return-value
  :
    define variable v-main-bcode     like {1}.bar-code.b-code no-undo .
    define variable l-prod-bc-global as   logical             no-undo .
    define variable l-prod-bc-weight as   logical             no-undo .
    define variable l-prod-bc-pgweight as   logical             no-undo .
    define variable rec-cnt          as   integer             no-undo .
    define variable str-u-f          as   character           no-undo .
    define variable str-u-f-rng      as   character           no-undo .
    define variable ind              as   integer             no-undo .
    define variable v-msg              as   character           no-undo initial "":U.
    define variable v-ret-msg          as   character           no-undo initial "":U.

    define frame get-max-code-inf
      rec-cnt label "Просмотрено"
      with view-as dialog-box side-labels row 11 centered
      title "..........................................." three-d
    .

    define buffer buf_code-range   for {1}.code-range .
    define buffer buf-c_code-range for {1}.code-range .
    define buffer buf_bar-code     for {1}.bar-code .
    define buffer buf_place        for {1}.place .
    define buffer buf_goods        for {1}.goods .
    define buffer buf_units        for {1}.units .
    define buffer buf_prod-bc      for {1}.prod-bc .
    define buffer buf_dis-card     for {1}.dis-card .
    define buffer buf_dis-rule     for {1}.dis-rule .
    define buffer buf_dis-time-rule     for {1}.dis-time-rule .
    define buffer buf_firm         for {1}.firm .
    define buffer buf_person       for {1}.person .
    define buffer buf_contract     for {1}.contract .

    if p-curr-type-cdrg = {&loc-ss-code}
    or p-curr-type-cdrg = {&gbl-ss-code}
    then do:
      assign
        v-b-code = ?
      .
      return. /* т.к. для этого диапазона нет sequence */
    end.

    if p-curr-type-cdrg = {&loc-sc-code}
    or p-curr-type-cdrg = {&loc-pg-code}
      or p-curr-type-cdrg = {&loc-ss-code}
    then do:
      assign
        p-db-num = 0
      .
    end.

    case p-action :
      when "get-m-code":U then do:
        assign
          v-b-code = p-first-code
        .
      end.
      when "f-u":U then do:
        assign
          v-b-code = 0
        .
      end.
    end case.
    case p-curr-type-cdrg :
      when {&gbl-dc-code} then do:       /* для диапазона кодов дисконтных карт */
        { cmp/getmc.i '{1}.dis-card' 'card-num' }
      end.
      when {&gbl-ct-code} then do:       /* для диапазона кодов договоров */
        { cmp/getmc.i '{1}.contract' 'contract-code' }
      end.
      when {&gbl-ca-code} then do:       /* для диапазона кодов договоров */
        { cmp/getmc.i '{1}.rule-by-call' 'call#_id' }
      end.
      when {&gbl-fd-code} then do:       /* для диапазона кодов фин документов */
        { cmp/getmc.i '{1}.fin-doc' 'fin-doc-code' }
      end.
      when {&gbl-fm-code} then do:       /* для диапазона кодов организаций */
        { cmp/getmc.i '{1}.firm' 'firm-code' }
      end.
      when {&gbl-pn-code} then do:       /* для диапазона кодов физических лиц */
        { cmp/getmc.i '{1}.person' 'psn-code' }
      end.
      when {&gbl-dr-code} then do:       /* для диапазона кодов правил скидок */
        { cmp/getmc.i '{1}.dis-rule,{1}.dis-time-rule' 'rule-num,time-rule-num' }
      end.
      when {&gbl-bc-code} then do:       /* для диапазона глобальных собственных кодов */
        { cmp/getmc.i '{1}.bar-code,{1}.place' 'b-code,pl-code' }
      end.
      when {&gbl-sc-code}
      or when {&loc-sc-code}
      then do:                           /* для диапазонов весовых кодов */
        case p-action :
          when "get-m-code":U then do:
            assign
              frame get-max-code-inf :title = "Поиск максимального значения кода"
            .
          end.
          when "f-u":U then do:
            assign
              frame get-max-code-inf :title = "Корректировка статуса code-range"
            .
            run mark-all-used-as-free in this-procedure (
                                       input  p-db-num
                                      ,input  p-curr-type-cdrg
                                      ,output str-u-f
                                      ,output str-u-f-rng
                                    ).
          end.
        end case.

        view frame get-max-code-inf.
        assign
          rec-cnt = 0
        .
        display
          rec-cnt
          with frame get-max-code-inf
        .

        for each buf_units no-lock
            where lookup({&weight}, buf_units.type) > 0
        on error undo, return error
        :
          for each buf_goods no-lock
            where buf_goods.unit-base = buf_units.unit-name
          on error undo, return error
          :
            assign
              rec-cnt = rec-cnt + 1
            .

            if ( rec-cnt modulo 10 ) = 0 then do:
              display
                rec-cnt
                with frame get-max-code-inf
              .
            end.

            run mc_gdsbcode in this-procedure (
                             input  buf_goods.gds-code
                            ,input  ?
                            ,output v-main-bcode
                          ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при поиске корневого бар-кода" skip
                "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            for each buf_prod-bc no-lock
                where buf_prod-bc.b-code = v-main-bcode
            on error undo, return error
            :
              if p-curr-type-cdrg = {&loc-sc-code}
                and buf_prod-bc.bc-on = FALSE
              then do:
                next.
              end.
              run mc_prodbcat in this-procedure (
                               buffer buf_prod-bc
                              ,input  'global=request':u
                              ,output l-prod-bc-global
                            ) no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
                  "Основной бар-код" buf_prod-bc.b-code skip
                  "Дополнительный бар-код" buf_prod-bc.b-str skip
                  "Действие global=request" skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
              run mc_prodbcat in this-procedure (
                               buffer buf_prod-bc
                              ,input  'weight=request':u
                              ,output l-prod-bc-weight
                            ) no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
                  "Основной бар-код" buf_prod-bc.b-code skip
                  "Дополнительный бар-код" buf_prod-bc.b-str skip
                  "Действие weight=request" skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.

              if l-prod-bc-weight
                and ( ( l-prod-bc-global
                        and p-curr-type-cdrg = {&gbl-sc-code}
                      )
                      or
                      ( not l-prod-bc-global
                        and p-curr-type-cdrg = {&loc-sc-code}
                      )
                    )
              then do:
                case p-action :
                  when "get-m-code":U then do:

                    if integer( buf_prod-bc.b-str ) >= p-first-code
                      and integer( buf_prod-bc.b-str ) <= p-last-code
                      and integer( buf_prod-bc.b-str ) > v-b-code
                    then do:
                      assign
                        v-b-code = integer( buf_prod-bc.b-str )
                      .
                    end.
                  end.
                  when "f-u":U then do:
                    for each buf_code-range
                      where buf_code-range.db-num     = p-db-num
                        and buf_code-range.range-type = p-curr-type-cdrg
                        and buf_code-range.stts       = "f":U
                        and buf_code-range.first-code <= integer( buf_prod-bc.b-str )
                        and buf_code-range.last-code  >= integer( buf_prod-bc.b-str )
                    on error undo, return error
                    :
                      assign
                        buf_code-range.stts = "u":U
                      .
                      if lookup( string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code ), str-u-f-rng ) <> 0 then do:
                        assign
                          str-u-f-rng = diff-list( str-u-f-rng
                                                  ,string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code )
                                                  ,",":U
                                                  )
                        .
                      end.
                      if lookup( buf_code-range.range-type + {&delim-key} + string( buf_code-range.first-code ), str-u-f ) = 0 then do:
                        assign
                          v-b-code = v-b-code + 1
                          v-msg     = substitute( "Диапазон кодов с &2 по &3&1"
                                                  + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                                  , {&new-line}
                                                  , buf_code-range.first-code
                                                  , buf_code-range.last-code
                                                  , buf_prod-bc.b-str
                                                )
                          v-ret-msg = v-ret-msg + v-msg
                        .

                        if p-view-mess = true then do:
                          message
                            v-msg
                            view-as alert-box information.
                        end.
                      end.
                    end.
                  end.
                end case.
              end.
            end.
          end. /*for each buf_goods no-lock*/
        end.
        if p-action = "f-u":U then do:
          do ind = 1 to num-entries( str-u-f-rng ):
            assign
              v-b-code  = v-b-code + 1
              v-msg     = substitute( "Диапазон кодов &2&1"
                                      + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                      , {&new-line}
                                      , entry( ind, str-u-f-rng )
                                    )
              v-ret-msg = v-ret-msg + {&new-line} + v-msg
            .
            if p-view-mess = true then do:
              message
                v-msg
                view-as alert-box information.
            end.
          end.
        end.
        hide frame get-max-code-inf no-pause .
      end.
      when {&loc-pg-code}
      then do:                           /* для диапазонов штучных весовых кодов */
        case p-action :
          when "get-m-code":U then do:
            assign
              frame get-max-code-inf :title = "Поиск максимального значения кода"
            .
          end.
          when "f-u":U then do:
            assign
              frame get-max-code-inf :title = "Корректировка статуса code-range"
            .
            run mark-all-used-as-free in this-procedure (
                                       input  p-db-num
                                      ,input  p-curr-type-cdrg
                                      ,output str-u-f
                                      ,output str-u-f-rng
                                    ).
          end.
        end case.

        view frame get-max-code-inf.
        assign
          rec-cnt = 0
        .
        display
          rec-cnt
          with frame get-max-code-inf
        .
        for each buf_prod-bc no-lock where
                buf_prod-bc.b-str >= "00100"
            and buf_prod-bc.b-str <= "99999"
            and buf_prod-bc.bc-on-type = {&loc-pg-code}
            and length(buf_prod-bc.b-str) = 5
        on error undo, return error
        :
            assign
              rec-cnt = rec-cnt + 1
            .

            if ( rec-cnt modulo 10 ) = 0 then do:
              display
                rec-cnt
                with frame get-max-code-inf
              .
            end.
            if p-curr-type-cdrg = {&loc-pg-code}
              and buf_prod-bc.bc-on = FALSE
            then do:
              next.
            end.
            run mc_prodbcat in this-procedure (
                              buffer buf_prod-bc
                            ,input  'pgweight=request':u
                            ,output l-prod-bc-pgweight
                          ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
                "Основной бар-код" buf_prod-bc.b-code skip
                "Дополнительный бар-код" buf_prod-bc.b-str skip
                "Действие weight=request" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            if l-prod-bc-pgweight
            and p-curr-type-cdrg = {&loc-pg-code}
            then do:
              case p-action :
                when "get-m-code":U then do:

                  if integer( buf_prod-bc.b-str ) >= p-first-code
                    and integer( buf_prod-bc.b-str ) <= p-last-code
                    and integer( buf_prod-bc.b-str ) > v-b-code
                  then do:
                    assign
                      v-b-code = integer( buf_prod-bc.b-str )
                    .
                  end.
                end.
                when "f-u":U then do:
                  for each buf_code-range
                    where buf_code-range.db-num     = p-db-num
                      and buf_code-range.range-type = p-curr-type-cdrg
                      and buf_code-range.stts       = "f":U
                      and buf_code-range.first-code <= integer( buf_prod-bc.b-str )
                      and buf_code-range.last-code  >= integer( buf_prod-bc.b-str )
                  on error undo, return error
                  :
                  assign
                  buf_code-range.stts = "u":U
                    .
                  if lookup( string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code ), str-u-f-rng ) <> 0 then do:
                      assign
                        str-u-f-rng = diff-list( str-u-f-rng
                                                ,string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code )
                                                ,",":U
                                                )
                      .
                  end.
                  if lookup( buf_code-range.range-type + {&delim-key} + string( buf_code-range.first-code ), str-u-f ) = 0 then do:
                      assign
                        v-b-code = v-b-code + 1
                        v-msg     = substitute( "Диапазон кодов с &2 по &3&1"
                                                + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                                , {&new-line}
                                                , buf_code-range.first-code
                                                , buf_code-range.last-code
                                                , buf_prod-bc.b-str
                                              )
                        v-ret-msg = v-ret-msg + v-msg
                      .
                    if p-view-mess = true then do:
                      message
                        v-msg
                        view-as alert-box information.
                    end.
                  end.
                end. /*for each buf_code-range*/
              end. /*when "f-u":U then do:*/
            end case.
          end. /*if l-prod-bc-pgweight*/
        end. /*for each buf_prod-bc no-lock*/

        if p-action = "f-u":U then do:
          do ind = 1 to num-entries( str-u-f-rng ):
            assign
              v-b-code = v-b-code + 1
              v-msg     = substitute( "Диапазон кодов &2&1"
                                      + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                      , {&new-line}
                                      , entry( ind, str-u-f-rng )
                                    )
              v-ret-msg = v-ret-msg + {&new-line} + v-msg
            .
            if p-view-mess = true then do:
              message
                v-msg
                view-as alert-box information.
            end.
          end.
        end.
        hide frame get-max-code-inf no-pause .
      end. /*when {&loc-pg-code}*/
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "get-max-code" skip
          "Непредусмотрена обработка диапазона кодов " p-curr-type-cdrg
          view-as alert-box error.
        return error.
      end.
    end case.
  end.

  return v-ret-msg.

end procedure. /* get-max-code */

procedure mark-all-used-as-free :
  define input  parameter p-db-num         like {1}.db.db-num             no-undo .
  define input  parameter p-curr-type-cdrg like {1}.code-range.range-type no-undo .
  define output parameter p-str-u-f        as   character                 no-undo .
  define output parameter p-str-u-f-rng    as   character                 no-undo .
  do
  on error undo, return error
  :
    define buffer buf_code-range   for {1}.code-range.
    define buffer buf-c_code-range for {1}.code-range .

    assign
      p-str-u-f     = "":U
      p-str-u-f-rng = "":U
    .
    for each buf_code-range share-lock
        where buf_code-range.db-num     = p-db-num
          and buf_code-range.range-type = p-curr-type-cdrg
          and buf_code-range.stts       = "u":U
    on error undo, return error
    :
      find first buf-c_code-range exclusive-lock
        where rowid( buf-c_code-range ) = rowid( buf_code-range )
      .
      assign
        buf-c_code-range.stts = "c":U
      .
      release buf-c_code-range .

      assign
        buf_code-range.stts = "f":U
        p-str-u-f     = p-str-u-f + ",":U + buf_code-range.range-type + {&delim-key} + string( buf_code-range.first-code )
        p-str-u-f-rng = p-str-u-f-rng + ",":U + string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code )
      .
    end.
    assign
      p-str-u-f     = substring( p-str-u-f, 2, length( p-str-u-f ) - 1 )
      p-str-u-f-rng = substring( p-str-u-f-rng, 2, length( p-str-u-f-rng ) - 1 )
    .
  end.
end procedure. /* mark-all-used-as-free */

procedure mc_prodbcat : /* это копия, оригинал (prodbcat) в library.p */

  do
  on error undo, return error
  :

    /*Задает/получает различные признаки дополнительного бар-кода

      значения p-action
      список значений действий разделенных запятыми

      global=request     - является ли бар-код локальным для данной базы данных
        локальный код это
          код, который имеет единицу измерени
            весовой
            или
            дробно-бензиновый

            и длина бар-кода строго меньше 6

        все остальные - глобальные
      pgweight=request     - является ли бар-код штучным весовым
    */

    define parameter buffer buf_prod-bc  for {1}.prod-bc .
    define input  parameter p-action           as character no-undo .
    define output parameter p-return-attribute as logical no-undo .

    def var vss-description as character no-undo init "prodbcat-01: определение параметров дополнительного бар-кода".

    define buffer buf_bar-code   for {1}.bar-code   .
    define buffer buf_units      for {1}.units      .
    define buffer buf_code-range for {1}.code-range .

    define variable p-code-int as integer no-undo .
    define variable v-cdrg-type as character no-undo .

    if not available buf_prod-bc then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задан дополнительный бар-код" skip
        view-as alert-box error .
      undo, return error .
    end.

    find first buf_bar-code no-lock
      where buf_bar-code.b-code = buf_prod-bc.b-code
      no-error .
    if not available buf_bar-code then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильная ссылка на основной бар-код" skip
        "Основной бар-код" buf_prod-bc.b-code skip
        "Дополнительный бар-код" buf_prod-bc.b-str skip
        view-as alert-box error .
      undo, return error .
    end.

    find first buf_units no-lock
      where buf_units.unit-name = buf_bar-code.unit-cli
      no-error .
    if not available buf_units then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена единица измерения основного бар-кода" skip
        "Основной бар-код" buf_bar-code.b-code skip
        "Единица измерения" buf_bar-code.unit-cli skip
        view-as alert-box error .
      undo, return error .
    end.

    def var ind                    as integer   no-undo .
    def var v-num-entries-p-action as integer   no-undo .
    def var v-action               as character no-undo .

    assign
      v-num-entries-p-action = num-entries(p-action)
    .
    assign
      p-return-attribute = true
    .

    _ind:
    do ind = 1 to v-num-entries-p-action
    :
     if ind > 1 and p-return-attribute = false then return.
      assign
        v-action = entry(ind, p-action)
      .

      case v-action :
        when "global=request":u
        then do:
          /* определяем код глобальный или нет */
          if not (buf_prod-bc.bc-on-type = ''
          or buf_prod-bc.bc-on-type = {&gbl-sc-code}
          or buf_prod-bc.bc-on-type = {&gbl-ss-code}) then do:
            assign
              p-return-attribute = false
            .
          end.

        end.
        when "weight=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = {&loc-sc-code}
          or buf_prod-bc.bc-on-type = {&gbl-sc-code}) then do:
            assign
              p-return-attribute = false.

          end.

        end.
        when "pgweight=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = {&loc-pg-code}) then do:
            assign
              p-return-attribute = false.
          end.
        end.
        when "petrolium=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = {&loc-pt-code}) then do:
            assign
              p-return-attribute = false.

          end.
        end.
        when "scaleable=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = {&loc-ss-code}
          or buf_prod-bc.bc-on-type = {&gbl-ss-code}) then do:
            assign
              p-return-attribute = false.
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестное значение параметра v-action " skip
            "v-action" v-action skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error .
        end.
      end case. /* v-action */
    end.
  end.

end procedure. /* mc_prodbcat */

procedure mc_gdsbcode : /* это копия, оригинал (prodbcat) в library.p */

  /* gdsbcode-01: получение первичного бар-кода признака */

  define input  parameter p-gds-code  like {1}.bar-code.gds-code  no-undo .
  define input  parameter p-node-code like {1}.bar-code.node-code no-undo .
  define output parameter p-b-code    like {1}.bar-code.b-code    no-undo .

  def var vss-description as character no-undo init "gdsbcode-01: определение первичного бар-кода признака".
  def var vss-proc-revision as character no-undo init "library.p gdsbcode-01" .

  define buffer buf_bar-code for {1}.bar-code .

  def var v-unit-base like {1}.goods.unit-base no-undo .

  do
  on error undo, return error
  :

    if p-node-code = ? then do:
      run mc_gdsrootnode in this-procedure (
         input  p-gds-code
        ,output p-node-code
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого признака товара" skip
          "Код товара" p-gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error . /* --->>>--- */
      end.
    end.

    run mc_unitbase in this-procedure (
       input  p-gds-code  /* p-gds-code  */
      ,output v-unit-base /* p-unit-base */
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка определения базовой единицы измерения товара" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.

    find first buf_bar-code no-lock
      where buf_bar-code.gds-code  = p-gds-code
        and buf_bar-code.node-code = p-node-code
        and buf_bar-code.part-code = ""
        and buf_bar-code.in-code   = ""
        and buf_bar-code.unit-cli  = v-unit-base
      no-error .
    if not available buf_bar-code then do:
      undo, return error vss-proc-revision + ":" + {&new-line}
        + "Не найден первичный бар-кода признака " + {&new-line}
        + "Код товара " + string(p-gds-code) + {&new-line}
        + "Код признака " + string(p-node-code) + {&new-line}
        + "Базовая единица измерения " + string(v-unit-base) + {&new-line}
        .
    end.
    assign
      p-b-code = buf_bar-code.b-code
    .
  end.

end procedure. /* mc_gdsbcode */

procedure mc_gdsrootnode :

  /* определение корневого признака товара по коду товара */

  define input  parameter p-gds-code  like {1}.goods.gds-code no-undo .
  define output parameter p-root-node like {1}.goods.prt-root no-undo .

  def var vss-description as character no-undo init "gdsrootnode-01: определение корневого признака товара по коду товара".

  define buffer buf_goods   for {1}.goods .

  do
  on error undo, return error
  :

    find first buf_goods no-lock
      where buf_goods.gds-code  = p-gds-code
      no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.

    run mc_prt-root-to-node-code in this-procedure (
       input  buf_goods.prt-root /* p-prt-root  */
      ,output p-root-node        /* p-root-node */
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры prt-root-to-node-code" skip
        "Товар" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "Указатель на корень шкалы" buf_goods.prt-root skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error . /* --->>>--- */
    end.
  end.

end procedure. /* mc_gdsrootnode */

procedure mc_prt-root-to-node-code :

  define input  parameter p-prt-root  like {1}.goods.prt-root no-undo .
  define output parameter p-root-node like {1}.goods.prt-root no-undo .

  def var vss-description as character no-undo init "prt-root-to-node-code-01: определение корневого признака шкалы по коду шкалы".

  define buffer buf_gds-prt for {1}.gds-prt .

  do
  on error undo, return error
  :
    find buf_gds-prt no-lock
      where buf_gds-prt.upper-code = p-prt-root
      no-error .
    if not available buf_gds-prt then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден корень шкалы" skip
        "Указатель на корень шкалы" p-prt-root skip
        view-as alert-box error .
      undo, return error . /* --->>>--- */
    end.
    assign
      p-root-node = buf_gds-prt.node-code
    .
  end.

end procedure. /* mc_prt-root-to-node-code */

procedure mc_unitbase :

  define input  parameter p-gds-code  like {1}.goods.gds-code  no-undo .
  define output parameter p-unit-base like {1}.goods.unit-base no-undo .

  def var vss-description as character no-undo init "unitbase-01: определение базовой единицы измерения товара".

  define buffer buf_goods for {1}.goods .

  do
  on error undo, return error
  :
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error . /* --->>>--- */
    end.

    assign
      p-unit-base = buf_goods.unit-base
    .
  end.

end procedure. /* mc_unitbase */


/* $Workfile$ */