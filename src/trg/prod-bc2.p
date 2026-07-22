block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение ДопБК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/16/08
Author: Bakhtadze Natalya
Creation date: 11/16/08

*/

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-silent as logical   no-undo .
/* как отслеживать изменение имени товара для исключения дублей */
define input  parameter dif-pdbc as logical no-undo initial no.
/* запретить в одной БД добавление Доп.БК на товар, если он есть на другом товаре */
define input  parameter pbc-veto  as logical no-undo.
define input  parameter send-ref as logical   no-undo .

define input  parameter p-cdrg-type as character no-undo .
define input  parameter p-ean-type as character no-undo .
define parameter buffer buf_goods for ub.goods.
define input  parameter p-b-code as integer   no-undo .
define input  parameter p-nedeMark as logical   no-undo .
define input-output  parameter p-b-str as character no-undo .
define output parameter p-recid as recid no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение ДопБК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ trg/new-bcod.i }
{ gbl/is-num.i   }
{ ref/gds-attr.i }

define variable glog as logical   no-undo .
define variable v-on as logical   no-undo .
define variable v-code as integer   no-undo .
define variable v-mess as character no-undo .
define variable v-b-str as character no-undo .
define variable add-on as logical   no-undo .
define variable dopi as integer   no-undo .
define variable bar_code as character no-undo .
define variable v-b-code as integer   no-undo .
define variable f-sc-code as integer   no-undo .
define variable v-empty-scale as logical no-undo .
define variable v-is-weight as logical no-undo .
define variable v-is-pgweight as logical no-undo .
define variable v-is-global as logical no-undo .

define variable dopst as character no-undo .
define variable par-bc-pfx  as character no-undo.                  /* для чтения параметра конфигурации */
define variable par-pl-pfx  as character no-undo.                  /* для чтения параметра конфигурации */
define variable par-bc-frmt as character no-undo.                  /* для чтения параметра конфигурации */
define variable par-pl-frmt as character no-undo.                  /* для чтения параметра конфигурации */
define variable v-param-type                as character                no-undo.
define variable v-value-character           as character                no-undo.
define variable v-value-date                as date                     no-undo.
define variable v-value-decimal             as decimal                  no-undo.
define variable v-value-integer             as INTEGER                  no-undo.
define variable v-value-logical             AS LOGICAL                  no-undo.
define variable v-tth                       as handle                   no-undo.


define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_prod-bc-attr for ub.prod-bc-attr.
define buffer buf2_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_units for ub.units.
define buffer u-base for ub.units.
define buffer buf_code-range for ub.code-range.
define buffer dubl_prod-bc for ub.prod-bc .

define buffer same-prod-bc for ub.prod-bc.
define buffer same-bar-code for ub.bar-code.
define buffer same-goods for ub.goods.
define buffer same-gds-prt  for ub.gds-prt.

  find first buf_bar-code no-lock where
            buf_bar-code.b-code = p-b-code no-error.
  if not available buf_bar-code then do:
    v-mess = substitute("Не найден бар-код &1, к которому добавляется ДопБК &2"
                       , p-b-code
                       , p-b-str).
    run err-mess in this-procedure ( input-output v-mess).
    undo, return error (if p-silent then v-mess else '').
  end.
  if buf_bar-code.gds-code <> buf_goods.gds-code then do:
    v-mess = substitute("&1 Неверно заданы параметры: товара с кодом  &2, бар-код &3 для товара с кодом &4"
                       , vss-workfile
                       , buf_goods.gds-code
                       , buf_bar-code.b-code
                       , buf_bar-code.gds-code).
    run err-mess in this-procedure ( input-output v-mess).
    undo, return error (if p-silent then v-mess else '').
  end.
  find buf_units no-lock where
       buf_units.unit-name = buf_bar-code.unit-cli .
  find u-base no-lock where
       u-base.unit-name = buf_goods.unit-base  .
  if  lookup( {&bottle}, u-base.type ) > 0
  and buf_goods.unit-base <> buf_bar-code.unit-cli
  then do:
    v-mess = substitute( "Нельзя создать код для неосновной единицы измерения&1" +
                         "к товару, у которого основная единица измерения типа &2"
                         , {&new-line}
                         ,{&bottle}).
    run err-mess in this-procedure ( input-output v-mess).
    undo, return error (if p-silent then v-mess else '').
  end.
  if dif-pdbc = ? then do:
    run adm/shattri.p (
        input "get":U
        ,input  '':U /*p-obj-type*/
        ,input  0 /*p-obj-code*/
        ,input  {&attr-gds-ref}
        ,input  {&attr-gds-ref_dif-pdbc} /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output dif-pdbc
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error.
    delete object v-tth.
  end.
  if pbc-veto = ? then do:
    run adm/shattri.p (
        input "get":U
        ,input  '':U /*p-obj-type*/
        ,input  0 /*p-obj-code*/
        ,input  {&attr-gds-ref}
        ,input  {&attr-gds-ref_pbc-veto} /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output pbc-veto
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error.
    delete object v-tth.
  end.

  define variable v-attr-sale-trk as character no-undo .
  define variable v-attr-type as character no-undo .
  
  run gds-attr-value in this-procedure (
                               input buf_goods.gds-code
                              ,input {&attr-ptrl-as-good}
                              ,output v-attr-sale-trk
                              ,output v-attr-type) no-error.

  case p-cdrg-type:
    when {&loc-sc-code} then do:
      if lookup({&weight}, u-base.type) = 0 then do:
        v-mess = substitute("Локальный весовой код можно создать только для товара, у которого основная единица измерения ВЕСОВАЯ").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      /*проверим что бар-код главный*/
      { gbl/gdsbcode.i buf_goods.gds-code ? v-b-code }
      if v-b-code <> p-b-code then do:
        v-mess = substitute("Локальный весовой код можно создать только для ГЛАВНОГО бар-кода товара").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      if p-b-str <> ''
      and p-b-str <> ? then do:
        assign
        v-is-weight = no
        v-is-global = ?
        .
        { gbl/prodbctv.i
         p-b-str
         buf_bar-code.unit-cli
         buf_goods.unit-base
         "'weight=request'"
         v-is-weight
         no-error
         }
        { gbl/prodbctv.i
         p-b-str
         buf_bar-code.unit-cli
         buf_goods.unit-base
         "'global=request'"
         v-is-global                            	
         no-error
         }
         if not (v-is-weight and (not v-is-global)) then do:
            v-mess = substitute("Заданный код &1 не является локальным весовым кодом", p-b-str).
            run err-mess in this-procedure ( input-output v-mess).
            undo, return error (if p-silent then v-mess else '').
         end.
      end.
      else do:
      assign
      f-sc-code = - 1
      .
      _sc-code:
      do while (v-code = 0 or v-code <> f-sc-code):
        /*т.е. пока не сделает полный цикл по всем диапазонам лок вес кодов - если уже сделал то все - ВСЕ КОДЫ ВКЛЮЧЕНЫ места нет*/
        assign
        f-sc-code = if f-sc-code = - 1
                    then v-code
                    else f-sc-code
        .
        run gen-b-code IN THIS-PROCEDURE (input {&loc-sc-code}, output v-code) no-error.
        if v-code = 0
        or v-code = ?
        or error-status:error then do:
          v-mess = substitute("Не удалось создать глобальный весовой код&1&2&1&3"
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value ).
          run err-mess in this-procedure ( input-output v-mess).
          return (if p-silent then v-mess else '').
        end.
        find first dubl_prod-bc No-lock where
                  dubl_prod-bc.b-str = string(v-code, '99999':U)
              AND  dubl_prod-bc.bc-on = yes no-error .
        if not avail dubl_prod-bc then do:
          assign
          f-sc-code = 0
          .
          LEAVE _sc-code.
        end.
      end.
      if v-code = f-sc-code then do:
        v-mess = substitute("Не удалось создать весовой код&1"  +
                            "Диапазоны локальных весовых кодов ПОЛНОСТЬЮ заняты&1"  +
                            "Выключите неиспользуемые локальные весовые коды&1"  +
                            "И повторите попытку"
                            ,{&new-line}).
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
        p-b-str = string(v-code, "99999":U).
      end.
      if p-silent then do:
        { ref/cves-pbd.i "string(v-code, '99999':U)"  buf_goods.artic buf_goods.prod-type buf_goods.prod-code "error" "silence" }
      end.
      else do:
        { ref/cves-pbd.i "string(v-code, '99999':U)"  buf_goods.artic buf_goods.prod-type buf_goods.prod-code "error" }
      end.
      add-on = yes.
    end.
    when {&gbl-sc-code} then do:
      if lookup({&weight}, u-base.type) = 0 then do:
        v-mess = substitute("Глобальный весовой код можно создать только для товара, у которого основная единица измерения ВЕСОВАЯ").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      /*проверим что бар-код главный*/
      { gbl/gdsbcode.i buf_goods.gds-code ? v-b-code }
      if v-b-code <> p-b-code then do:
        v-mess = substitute("Глобальный весовой код можно создать только для ГЛАВНОГО бар-кода товара").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      if p-b-str <> ''
      and p-b-str <> ? then do:
        assign
        v-is-weight = no
        v-is-global = no
        .
        { gbl/prodbctv.i
         p-b-str
         buf_bar-code.unit-cli
         buf_goods.unit-base
         "'weight=request'"
         v-is-weight
         no-error
         }
        { gbl/prodbctv.i
         p-b-str
         buf_bar-code.unit-cli
         buf_goods.unit-base
         "'global=request'"
         v-is-global
         no-error
         }
         if not (v-is-weight and v-is-global) then do:
            v-mess = substitute("Заданный код &1 не является глобальным весовым кодом", p-b-str).
            run err-mess in this-procedure ( input-output v-mess).
            undo, return error (if p-silent then v-mess else '').
         end.
      end.
      else do:
      run trg/isvescod.p ( input p-b-code
                          ,input yes
                          ,input yes
                          ,input yes
                          ,input ""
                          ,output glog
                          ,output v-on
                          ,output v-b-str ) no-error.
      if error-status:error then undo, return error return-value .
      if glog and v-on then do:
        v-mess = substitute("У товара уже есть глобальный весовой код").
        run err-mess in this-procedure ( input-output v-mess).
        return (if p-silent then v-mess else '').
      end.
      run gen-b-code IN THIS-PROCEDURE (input {&gbl-sc-code}, output v-code) no-error.
      if v-code = 0
      or v-code = ?
      or error-status:error then do:
        v-mess = substitute("Не удалось создать глобальный весовой код&1&2&1&3"
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value ).
        run err-mess in this-procedure ( input-output v-mess).
        return (if p-silent then v-mess else '').
      end.
        p-b-str = string(v-code, "99999":U).
      end.
        if p-silent then do:
          { ref/cves-pbd.i "string(v-code, '99999':U)"  buf_goods.artic buf_goods.prod-type buf_goods.prod-code "error" "silence" }
        end.
        else do:
          { ref/cves-pbd.i "string(v-code, '99999':U)"  buf_goods.artic buf_goods.prod-type buf_goods.prod-code "error" }
        end.

      add-on = yes.
    end. /*when {&gbl-sc-code} then do:*/
    when {&loc-pg-code} then do:
      if lookup({&pieces}, u-base.type) = 0 then do:
        v-mess = substitute("Локальный штучный код для весов можно создать только для товара, у которого основная единица измерения ШТУЧНАЯ").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      { gbl/gdscdat.i
        buf_goods.gds-code
        'empty-scale=request':u
        v-empty-scale
      }
      if v-empty-scale = false then do:
        v-mess = substitute("Локальный штучный код для весов можно создать только для товара с пустой шкалой").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      { gbl/gdsbcode.i buf_goods.gds-code ? v-b-code }
      if v-b-code <> p-b-code then do:
        v-mess = substitute("Локальный штучный код для весов можно создать только для ГЛАВНОГО бар-кода товара").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      run trg/ispgwcod.p (
                          input p-b-code
                        ,input yes /*p-question-pgweight*/
                        ,input no /*p-question-global*/
                        ,input yes /*p-question-on*/
                        ,input ""
                        ,output glog
                        ,output v-on
                        ,output v-b-str ) no-error.
      if error-status:error then undo, return error return-value .
      if glog and v-on then do:
        v-mess = substitute("У товара уже есть локальный штучный код для весов").
        run err-mess in this-procedure ( input-output v-mess).
        return (if p-silent then v-mess else '').
      end.
      if p-b-str <> ''
      and p-b-str <> ? then do:
        assign
        v-is-pgweight = no
        v-is-global = ?
        .
        { gbl/prodbctv.i
         p-b-str
         buf_bar-code.unit-cli
         buf_goods.unit-base
         "'pgweight=request'"
         v-is-pgweight
         no-error
         }
        { gbl/prodbctv.i
         p-b-str
         buf_bar-code.unit-cli
         buf_goods.unit-base
         "'global=request'"
         v-is-global
         no-error
         }
         if not (v-is-pgweight and not (v-is-global)) then do:
            v-mess = substitute("Заданный код &1 не является локальным штучным кодов для весов", p-b-str).
            run err-mess in this-procedure ( input-output v-mess).
            undo, return error (if p-silent then v-mess else '').
         end.
      end.
      else do:
      run gen-b-code IN THIS-PROCEDURE (input {&loc-pg-code}, output v-code) no-error.
      if v-code = 0
      or v-code = ?
      or error-status:error then do:
        v-mess = substitute("Не удалось создать локальный штучный код для весов&1&2&1&3"
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value ).
        run err-mess in this-procedure ( input-output v-mess).
        return (if p-silent then v-mess else '').
      end.
        p-b-str = string(v-code, "99999":U).
      end.
        if p-silent then do:
          { ref/cves-pbd.i "string(v-code, '99999':U)"  buf_goods.artic buf_goods.prod-type buf_goods.prod-code "error" "silence" }
        end.
        else do:
          { ref/cves-pbd.i "string(v-code, '99999':U)"  buf_goods.artic buf_goods.prod-type buf_goods.prod-code "error" }
        end.
      add-on = yes.
    end. /*when {&loc-pg-code} then do:*/
    when  ''
    or
    when {&loc-ss-code}
    or
    when {&gbl-ss-code}
    then do:
      if p-b-str = '' then do:
        v-mess = "Не задан ДопБк".
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      if lookup ({&weight}, buf_units.type) > 0
      then do:
        v-mess =  "Для собственного кода с весовой единицей измерения нельзя создать дополнительный код.".
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      dopi = 0.
      assign
      dopi = integer(p-b-str) no-error .
      if p-cdrg-type = {&loc-ss-code}
      or p-cdrg-type = {&gbl-ss-code} then do:
        if  not (lookup({&weight}, u-base.type) > 0
        and buf_units.type = {&divisional})
        then do:
          v-mess = "Взвешиваемый код можно задать только для товара, у которого основная единица измерения ВЕСОВАЯ и только для бар-кода с единицой измерения ДРОБНАЯ".
          run err-mess in this-procedure ( input-output v-mess).
          undo, return error (if p-silent then v-mess else '').
        end.
        if dopi = 0
        then do:
          v-mess = "Взвешиваемый код должен быть целым положительным числом, не превышающим 2147483647".
          run err-mess in this-procedure ( input-output v-mess).
          undo, return error (if p-silent then v-mess else '').
        end.
        if trim(string(dopi, ">>>>>>>>9")) <> p-b-str then do:
          v-mess =  "Взвешиваемый код не должен содержать лидирующих нулей,&1" +
                   "десятичных разделителей и других спец. символов" .
          run err-mess in this-procedure ( input-output v-mess).
          undo, return error (if p-silent then v-mess else '').
        end.
        if p-cdrg-type = {&loc-ss-code} then do:
          /*проверим корректность с точки диапазона взвешиваемых кодов*/
          find first buf_code-range no-lock
            where buf_code-range.range-type  = {&loc-ss-code}
              and buf_code-range.db-num      = 0
              and buf_code-range.first-code <= dopi
              and buf_code-range.last-code  >= dopi
            no-error .
        end.
        if p-cdrg-type =  {&gbl-ss-code} then do:
          find first buf_code-range no-lock
            where buf_code-range.range-type  = {&gbl-ss-code}
              and buf_code-range.db-num      = g#db-num
              and buf_code-range.first-code <= dopi
              and buf_code-range.last-code  >= dopi
            no-error .
        end.
        if not available buf_code-range
        then do:
          v-mess = substitute("Введенное Вами значение &1 лежит вне диапазона кодов для взвешивания товара&2" +
                              "или в системе нет таких диапазонов"
                             , p-b-str
                             , {&new-line}).
          run err-mess in this-procedure ( input-output v-mess).
          undo, return error (if p-silent then v-mess else '').
        end.
      end.
      else do:
        /* 21/II-2019 проверка исключена по просьбе Сибинтек:
          
Согласно высланной инструкции добавили баркод для adblue под номером 13,
но т.к. код для сопутствующих товаров код  должен содержать минимум 5 символов,
пакет от ERP с этим изменением выдал ошибку при распаковке и остановил обмен на заправочных станциях.

Есть ли возможность изменить ограничение по символам для сопутствующих товаров в ТБД,
чтобы пакет корректно распаковался?
          
        if length(p-b-str) < 6 then do:
          v-mess =  "ДопБк должен быть длиннее 5 разрядов.".
          run err-mess in this-procedure ( input-output v-mess).
          undo, return error (if p-silent then v-mess else '').
        end.
        */
        if can-find( first buf_code-range no-lock
          where buf_code-range.range-type  = {&gbl-ss-code}
            and buf_code-range.db-num      = g#db-num
            and buf_code-range.first-code <= dopi
            and buf_code-range.last-code  >= dopi)
        or can-find(first buf_code-range no-lock
            where buf_code-range.range-type  = {&gbl-ss-code}
              and buf_code-range.first-code <= dopi
              and buf_code-range.last-code  >= dopi) then do:
          v-mess = substitute("Значение &1 лежит в диапазоне кодов для взвешивания товара&2"  +
                              "такой код можно ввести только для товара с ВЕСОВОЙ основной ед изм&2"  +
                              "и бар-кода с дополнительной ед. изм. типа ДРОБНАЯ"
                              ,p-b-str
                              , {&new-line}).
          run err-mess in this-procedure ( input-output v-mess).
          undo, return error (if p-silent then v-mess else '').
        end.
        if length(p-b-str) < 6 and not v-attr-sale-trk = 'yes' then do:
          v-mess =  "ДопБк должен быть длиннее 5 разрядов.".
          run err-mess in this-procedure ( input-output v-mess).
          undo, return error (if p-silent then v-mess else '').
        end.
      end.
    end. /*when '' then do:*/
    when {&loc-pt-code}
    then do:
      /* дробный (разливной) бензин:
        - запрещено добавлять собственные коды
        - запрещено добавлять доп. бар-коды
        - можно добавлять дополнительный топливный
          (2 разрядный, разновидность весового, только добавляется вручную)
        - дополнительный топливный может быть только один
      */
      { gbl/gdsbcode.i buf_goods.gds-code ? v-b-code }
      if v-b-code <> p-b-code then do:
        v-mess = substitute("Топливынй код можно создать только для ГЛАВНОГО бар-кода товара").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      if p-b-str = '' then do:
        v-mess = "Не задан ДопБк".
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      if not (lookup ({&petrolium},  u-base.type) > 0
            and lookup ({&divisional}, u-base.type) > 0
            and buf_goods.gds-type = {&gds-goods})
      then do:
        v-mess = substitute("Топливный код можно задать только для товара (но не услуги) с основной единицей измерения типа &1 &2"
                           , {&petrolium}
                           ,{&divisional}).
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.

      if length(p-b-str) > 2 then do:
        v-mess = substitute("Топливный код не должен быть длиннее 2 разрядов").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.

      dopi = 0.
      assign
      dopi = integer(p-b-str) no-error .

      if trim(string(dopi, ">>>>>>>>9")) <> p-b-str then do:
      v-mess =  "Топливный код не должен содержать лидирующих нулей,&1" +
                  "десятичных разделителей и других спец. символов" .
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      /* проверяем, что топливный код - единственный */
     /* 21/II-2019 проверка уже была закомментирована
      find first buf2_prod-bc no-lock
        where buf2_prod-bc.b-code = p-b-code
          and buf2_prod-bc.b-str <> p-b-str no-error.
      if available buf2_prod-bc then do:
        v-mess =  substitute("Уже есть другой топливный код (&1) у товара. Топливный код должен быть только один.", buf2_prod-bc.b-str).
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      */
    end. /*when {&loc-pt-code} */
    when 'unq-artc' then do:
      if buf_goods.artic <> p-b-str then do:
        v-mess =  substitute("При включенной настройке unq-artc &1<Уникальный цифровой артикул, ДопБК=артикулу>&1 ДопБК должен быть равен артикулу", {&new-line}).
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      dopi = ?.
      dopi = integer(buf_goods.artic) no-error.
      if dopi = 0
      or dopi = ?
      or trim(string(dopi, ">>>>>>9")) <> buf_goods.artic
      or length(buf_goods.artic) > 7 then do:
        v-mess =  substitute("При включенной настройке unq-artc &1<Уникальный цифровой артикул, ДопБК=артикулу>&1" +
                             "ДопБК не может=0, ДоБК не может =?, ДопБК не может быть> 9999999"
                             , {&new-line}).
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      p-cdrg-type = ''.
    end.
    when {&gtin} then do:
        end.
    otherwise do:
      v-mess = substitute("Задан неизвестный тип диапазона для ДопбК = &1", p-cdrg-type).
      run err-mess in this-procedure ( input-output v-mess).
      undo, return error (if p-silent then v-mess else '').
    end.
  end case.

  if p-cdrg-type eq {&gtin}

  then do:
      if length(p-b-str) > 2 and lookup ({&petrolium},  u-base.type) > 0
        then do:
        v-mess = substitute("Топливный код не должен быть длиннее 2 разрядов").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.

      dopi = 0.
      assign
      dopi = integer(p-b-str) no-error .

     if length(p-b-str) ne 14  and lookup ({&petrolium}, u-base.type) = 0
     then do:
        v-mess = "В GTIN должно быть 14 цифр.".
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
     end.
     else if not is-numeral (p-b-str,"digit")
     then do:
        v-mess = "В GTIN должны быть только цифры.".
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else ''). 
     end. 
  end.
  else do:
     if ( /* длинный доп. БК */
          length (p-b-str) > 13 and
          not is-numeral ((p-b-str),
                            "letter,digit")) or
          (/* EAN или другой не длинный доп. БК */
          length (p-b-str) <= 13 and
          not is-numeral ((p-b-str),
                            "digit"))
      then do:
        v-mess = "В бар-коде не должно быть пробелов и недопустимых символов.".
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
  end. 
  /* берем бар-код без контрольной суммы */
  bar_code = substr (p-b-str, 1, length (p-b-str) - 1).
  run str/chk-sum.p
    (input-output bar_code
    ) no-error .
  if error-status :error
  then do:
     if p-ean-type = "EAN"
     then do:
        v-mess = "Бар-код должен быть EAN8 или EAN13.".
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
     end.
     else if p-cdrg-type eq {&gtin}
     then do:
        v-mess = "Бар-код должен быть GTIN.".
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
     end.
  end.
  if     p-cdrg-type eq {&gtin}
     and substr (bar_code, length (bar_code), 1) <> substr (p-b-str, length (bar_code), 1)
  then do:
     v-mess = "Бар-код должен быть GTIN." .
     if session:debug-alert 
     then
        v-mess = v-mess + " Ваш код " + p-b-str + " Правильный GTIN " + bar_code.
     run err-mess in this-procedure ( input-output v-mess).
     undo, return error (if p-silent then v-mess else '').
  end.
  else if ((length (p-b-str) <> 8 and
        length (p-b-str) <> 13) or
      substr (bar_code, length (bar_code), 1) <> substr (p-b-str, length (bar_code), 1)) and
      p-ean-type = "EAN"
  then do:
    v-mess = "Бар-код должен быть EAN8 или EAN13.".
    if session:debug-alert
       and (   length (p-b-str) eq 8 
            or length (p-b-str) eq 13) 
     then
        v-mess = v-mess + " Ваш код " + p-b-str + " Правильный EAN " + bar_code.
    run err-mess in this-procedure ( input-output v-mess).
    undo, return error (if p-silent then v-mess else '').
  end.
  run gbl/conf-rd.p ( input "bc-pfx"
                      ,input  ""
                      ,input ""
                      ,input 0
                      ,input ""
                      ,input ""
                      ,input ""
                      ,input yes
                      ,output par-bc-pfx
                      ,output dopst) no-error.
  if error-status :error
  or dopst <> "C":U
  then do:
    v-mess = substitute("Ошибка при определении параметра bc-pfx.&1&2", error-status:get-message(1) ).
    run err-mess in this-procedure ( input-output v-mess).
    undo, return error (if p-silent then v-mess else '').
  end.
  run gbl/conf-rd.p ( input "bc-frmt"
                      ,input ""
                      ,input ""
                      ,input 0
                      ,input ""
                      ,input ""
                      ,input ""
                      ,input yes
                      ,output par-bc-frmt
                      ,output dopst) no-error.
  if error-status :error
  or dopst <> "C":U
  then do:
    v-mess = substitute("Ошибка при определении параметра bc-frmt.&1&2", error-status:get-message(1) ).
    run err-mess in this-procedure ( input-output v-mess).
    undo, return error (if p-silent then v-mess else '').
  end.
  run gbl/conf-rd.p ( input "pl-pfx"
                      ,input ""
                      ,input ""
                      ,input 0
                      ,input ""
                      ,input ""
                      ,input ""
                      ,input no
                      ,output par-pl-pfx
                      ,output dopst) no-error.
  if error-status :error or dopst <> "C":U then
    par-pl-pfx = ?. /* при выходе с ошибкой возвращает непонятно что */
  run gbl/conf-rd.p ( input "pl-frmt"
                      ,input ""
                      ,input ""
                      ,input 0
                      ,input ""
                      ,input ""
                      ,input ""
                      ,input no
                      ,output par-pl-frmt
                      ,output dopst) no-error.
  if error-status :error or dopst <> "C":U then
    par-pl-frmt = ?. /* при выходе с ошибкой возвращает непонятно что */
  if p-b-str begins par-bc-pfx and
      (length (p-b-str) = 13 and
      par-bc-frmt = "EAN13" or
      length (p-b-str) = 8 and
      par-bc-frmt = "EAN8") or
      (p-b-str begins par-pl-pfx and
      par-pl-pfx <> ? and
      par-pl-frmt <> ?) and
      (length (p-b-str) = 13 and
      par-pl-frmt = "EAN13" or
      length (p-b-str) = 8 and
      par-pl-frmt = "EAN8")
  then do:
    v-mess = "Бар-код имеет префикс, зарезервированный для собственных товарных (складских мест) бар-кодов.".
    run err-mess in this-procedure ( input-output v-mess).
    undo, return error (if p-silent then v-mess else '').
  end.
  p-b:
  do transaction
  on error undo, return error return-value
  :
    add-on = yes.
    for each same-prod-bc
        where same-prod-bc.b-str = p-b-str
    on error undo p-b, return error return-value
    :
      if same-prod-bc.b-code = p-b-code
      then do:
        v-mess = "Такой дополнительный бар-код уже существует.".
        run err-mess in this-procedure ( input-output v-mess).
        undo p-b, return (if p-silent then v-mess else '') .
      end.
      if length (p-b-str) < 3
      then do:
        v-mess =  "Повторные дополнительные коды для топливных товаров запрещены.".
        run err-mess in this-procedure ( input-output v-mess).
        undo p-b, return (if p-silent then v-mess else '') .

      end.
      /* проверка на совпадение названий поставщика и бар-кода */
      find same-bar-code where
            same-bar-code.b-code = same-prod-bc.b-code no-lock no-error.
      if available same-bar-code then do:
        find same-goods where
              same-goods.gds-code = same-bar-code.gds-code no-lock no-error.
        if available same-goods then do:
          if  same-goods.prod-type = buf_goods.prod-type
          and same-goods.prod-code = buf_goods.prod-code
          and dif-pdbc = yes
          then do:
            /* НАСТРОЙКА ЗАПРЕТА ПОВТОРНЫХ ДОПБК ДЛЯ ОДНОГО ПРОИЗВОДИТЕЛЯ */
            v-mess = substitute("Такой дополнительный бар-код уже существует для производителя: &1&2"
                                ,buf_goods.prod-type
                                ,buf_goods.prod-code).
            run err-mess in this-procedure ( input-output v-mess).
            undo p-b, return (if p-silent then v-mess else '') .
          end.
          find  same-gds-prt where
                same-gds-prt.node-code = same-bar-code.node-code no-lock no-error.
          if available same-gds-prt then do:
            v-mess = substitute("Для добавляемого дополнительного бар-кода найден повторный бар-код :&1&2&1&1" +
                                  "Артикул :&3&1" +
                                  "Код товара :&4&1" +
                                  "Название :&5&1" +
                                  "Единица измерения :&6&1&1" +
                                  "Признак :&7&1" +
                                  "Номер партии :&8&1" +
                                  "Номер ПН :&9"
                                ,{&new-line}
                                ,p-b-str
                                ,same-goods.artic
                                ,same-goods.gds-code
                                ,same-goods.gds-name
                                ,same-bar-code.unit-cli
                                ,same-gds-prt.f-name
                                ,same-bar-code.part-code
                                ,same-bar-code.in-code).
            if not p-silent
            and not g#news then do:
              message
              v-mess
              view-as alert-box warning.
              
            end.
            if p-cdrg-type eq {&gtin}
            then
               undo p-b, return (if p-silent then v-mess else '') .
          end. /* if available same-gds-prt */
          if pbc-veto = yes then do:
            if same-goods.gds-code <> buf_goods.gds-code then do:
              v-mess = substitute("Такой дополнительный бар-код  (&1) уже существует для товара:&2&3" +
                                  "Код товара: &4&2" +
                                  "Артикул: &5&2" +
                                  "Производитель: &6&7&2" +
                                  "Наименование: &8&2" +
                                  "Добавление повторных бар-кодов запрещено."
                                  ,p-b-str
                                  ,{&new-line}
                                  ,{&tabulation}
                                  ,same-goods.gds-code
                                  ,same-goods.prod-type
                                  ,same-goods.prod-code
                                  ,same-goods.artic
                                  ,same-goods.gds-name ).
              run err-mess in this-procedure ( input-output v-mess).
              undo p-b, return (if p-silent then v-mess else '') .
            end.
          end. /* veto */
        end. /* if available same-goods */
      end. /* if available same-bar-code */
      run trg/bc-upd.p
        (input parparentproc
        ,input p-b-code
        ,input p-b-str
        ,input yes
        ,input p-silent  /*not mute*/
        ,input send-ref
        ,input recid(same-prod-bc)
        ,input ?
        ) no-error .
      if error-status :error
      then do:
        if return-value <> "":U
        then do:
          v-mess = return-value .
          run err-mess in this-procedure ( input-output v-mess).
        end.
        undo p-b, return (if p-silent then v-mess else '') .
      end.
      assign
        add-on = no
      .
    end. /* for each same-prod-bc */

    if not add-on
    and not p-silent
    then do:
      define variable v-ok as logical   no-undo .
      assign
        v-ok = true
      .
      message
        "Добавляемый бар-код будет добавлен как ВЫКЛЮЧЕННЫЙ" skip
        "(поскольку были найдены повторные бар-коды)." skip
        "Продолжить?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        undo p-b, return (if p-silent then v-mess else '') .
      end.
    end.
  end. /* transaction */
do
on error undo, return error return-value
:
  create buf_prod-bc.
  assign
  buf_prod-bc.b-str = p-b-str
  buf_prod-bc.b-code = p-b-code
  buf_prod-bc.bc-on = add-on
  buf_prod-bc.bc-on-type = p-cdrg-type
  p-recid = recid(buf_prod-bc)
  .
  if p-nedeMark 
  then do:
     create buf_prod-bc-attr.
     assign
        buf_prod-bc-attr.b-str  = p-b-str
        buf_prod-bc-attr.b-code = p-b-code 
        buf_prod-bc-attr.attr-code = {&mark}
        buf_prod-bc-attr.attr-value = "yes"
     .
  end.
end.



PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Создание ДопБК для товара с кодом &1 на бар-код &2:&3&4"
                         , buf_goods.gds-code
                         , p-b-code
                         , {&new-line}
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.