block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка всех товаров в накладной на предмет учета по местам хранения и топливного учета.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/01/06
Author: Dmitry Ukhanov
Creation date: 11/01/06

*/

/* Parameter Definitions ---                                            */
define input parameter p-doc-code as character no-undo.

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Проверка всех товаров в накладной на предмет учета по местам хранения и топливного учета.":U.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/clntattr.i }
{ ref/gds-attr.i }
{ str/valddnst.i def      }
{ str/is-gas.i }
{ str/placelib.i }
{ str/trdcalib.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define variable v-reserv-pl       as logical   no-undo .
  define variable is-petrol         as logical   no-undo.
  define variable is-pieces         as logical   no-undo.
  define variable v-is-ptrl         as character no-undo.
  define variable v-data-type       as character no-undo.
  define variable v-chk-null-qnty   as logical   no-undo .
  define variable v-sign            as decimal   no-undo .
  define variable v-chk-rvs         as logical   no-undo .
  define variable v-attr-value      as character no-undo .
  define variable v-attr-type       as character no-undo .

  define variable v-pl-fact-qnty        as decimal   no-undo .
  define variable v-pl-doc-qnty         as decimal   no-undo .
  define variable v-pl-cli-qnty         as decimal   no-undo .
  define variable v-pl-cli-fact-qnty    as decimal   no-undo .
  define variable v-pl-cli-doc-qnty     as decimal   no-undo .
  define variable v-pl-rest-bf-qnty     as decimal   no-undo .
  define variable v-pl-cli-rest-bf-qnty as decimal   no-undo .
  define variable v-pl-rest-af-qnty     as decimal   no-undo .
  define variable v-pl-cli-rest-af-qnty as decimal   no-undo .

  define variable v-density         as decimal   no-undo .
  define variable v-before-cli-qnty as decimal   no-undo .
  define variable v-after-qnty      as decimal   no-undo .
  define variable v-after-cli-qnty  as decimal   no-undo .
  define variable v-last-invlin     as recid     no-undo .
/*  define variable is-lgas           as logical   no-undo.*/
  define variable trn-is-lgas-corr  as logical   no-undo.

  define variable is-vir as logical no-undo.
  define variable v-value as character no-undo.
  define variable v-ok as logical no-undo.
  
  define buffer buf_doc-line      for ub.doc-line.
  define buffer buf_inv-line      for ub.inv-line.
  define buffer buf_trn-doc       for ub.trn-doc.
  define buffer buf_goods         for ub.goods.
  define buffer buf_rvs-doc       for ub.rvs-doc.
  define buffer buf_rvs-line      for ub.rvs-line .
  define buffer buf_doc-pl        for ub.doc-pl .
  define buffer buf_pl-gds        for ub.pl-gds .
  define buffer buf-cre_trn-doc   for ub.trn-doc .
  define buffer buf_gds-obj       for ub.gds-obj .
  define buffer buf-next_doc-line for ub.doc-line .
  define buffer buf-next_inv-line for ub.inv-line .
  define buffer buf-prev_inv-line for ub.inv-line .

  { gbl/conf-rd.i
    "'is-ptrl'"
    "''"
    "''"
    0
    "''"
    "''"
    "''"
    no
    v-is-ptrl
    v-data-type
    no-error
  }
  if error-status :error
    or v-data-type <> "L"
    or lookup( v-is-ptrl, "yes,no" ) = 0
    or v-is-ptrl = "no"
  then do:
    return .
  end.

  find buf_trn-doc exclusive-lock
    where buf_trn-doc.doc-code = p-doc-code
  no-error.
  if not available buf_trn-doc then do:
    undo, return error substitute( "&1. Не найден документ &2", vss-workfile, p-doc-code ).
  end.

  if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}
    and buf_trn-doc.status_ = {&wayb}
  then do:
    return .
  end.
  
  if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Object}
  then do:
    return .
  end.

  else do:
    if lookup( buf_trn-doc.ext-doc-type, {&TDEDT_out_list} ) > 0 then do:
      assign
        v-sign = -1.0
      .
    end.
    else do:
      /* оставляем все как есть */
      assign
        v-sign = 1.0
      .
      if lookup( buf_trn-doc.ext-doc-type, {&TDEDT_in_list} ) = 0 then do:
        undo, return error substitute( '&1. Тип "&2" не внесен в списки документов уменьшающих(увеличивающих) остатки!', vss-workfile, buf_trn-doc.ext-doc-type).
      end.
    end.

    assign
      v-chk-null-qnty = true
    .
    if buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}
      or buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
    then do:
      find first buf-cre_trn-doc no-lock
        where buf-cre_trn-doc.doc-code = buf_trn-doc.out-code
        no-error .
      if available buf-cre_trn-doc
        and buf-cre_trn-doc.ext-doc-type = {&TDEDT_Inv}
      then do:
        assign
          v-chk-null-qnty = false
        .
      end.
    end.

    assign
      v-chk-rvs = false
    .

    if buf_trn-doc.doc-type = {&income} then do:
      assign
        v-chk-rvs = true
      .
      if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
        run clntattr-value in this-procedure
          ( input  buf_trn-doc.cli-type
           ,input  buf_trn-doc.cli-code
           ,input  {&attr-shftrep2}
           ,output v-attr-value            /* p-value    */
           ,output v-attr-type             /* p-type     */
          ) .
        if v-attr-value = "yes":U then do:
          /* это техпролив */
          assign
            v-chk-rvs = false
          .
        end.
      end.

      if v-chk-rvs = true then do:
        assign
          v-chk-rvs = false
        .
        block_chk_ptrl :
        for each buf_doc-line exclusive-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
        on error undo, return error return-value
        :
          { str/is-petrl.i
            buf_doc-line.artic
            buf_doc-line.prod-type
            buf_doc-line.prod-code
            is-petrol
            is-pieces
          }
          if is-petrol = true
            and is-pieces = false
          then do:
            find first buf_goods no-lock
              where buf_goods.artic     = buf_doc-line.artic
                and buf_goods.prod-type = buf_doc-line.prod-type
                and buf_goods.prod-code = buf_doc-line.prod-code
            .

/*            is-lgas = false.*/
            trn-is-lgas-corr = false.
            { str/tdat-val.i
                buf_doc-line.doc-code
                {&trdcattr-is-lgas-corr}
                v-attr-value
                v-attr-type
                no-error
            }
            if v-attr-value = "yes" then do:
            assign
              trn-is-lgas-corr = true.
            end.
/*            run gds-attr-value in this-procedure*/
/*              (  input buf_goods.gds-code       */
/*                ,input {&attr-fuel-type}        */
/*                ,output v-attr-value            */
/*                ,output v-attr-type             */
/*               ) no-error.                      */
/*            if v-attr-value = "lgas"            */
/*              then assign is-lgas = true.       */
            
            run gds-attr-value in this-procedure
              ( input  buf_goods.gds-code
              ,input  {&attr-ptrl-without-rvs}
              ,output v-attr-value
              ,output v-attr-type
              ) .
            
            find first buf_doc-pl no-lock
                where buf_doc-pl.obj-type = buf_doc-line.obj-type
                and buf_doc-pl.obj-code = buf_doc-line.obj-code
                and buf_doc-pl.out-code = buf_doc-line.doc-code
                and buf_doc-pl.gds-code = buf_goods.gds-code no-error.
            
            run placelib_get-attr(input {&place-virtual}
                                 ,input buf_doc-pl.obj-code
                                 ,input buf_doc-pl.obj-type
                                 ,input buf_doc-pl.pl-code 
                                 ,output v-value
                                 ,output v-ok) no-error.

            is-vir = if (v-ok and logical(v-value)) then true else false.
            
            if lookup(v-attr-value, 'true,yes':u) = 0 and not is-gas(buf_goods.gds-code) and not is-vir and 
              not trn-is-lgas-corr then do:
              assign
                v-chk-rvs = true
              .
              leave block_chk_ptrl.
            end.
          end.
        end.
      end.

      if buf_trn-doc.status_ = {&fact}
        and v-chk-rvs = true
      then do:
        find first buf_rvs-doc no-lock
          where buf_rvs-doc.out-code = buf_trn-doc.doc-code
            and buf_rvs-doc.rvs-type = {&rvs-before-doc}
          no-error .
        if not available buf_rvs-doc then do:
          undo, return error substitute( 'Вы не сделали сверку перед документом "&1" (тип "&2") .'
                                          , buf_trn-doc.doc-code
                                          , {&rvs-before-doc}
                                        ) .
        end.
        find first buf_rvs-doc no-lock
          where buf_rvs-doc.out-code = buf_trn-doc.doc-code
            and buf_rvs-doc.rvs-type = {&rvs-after-doc}
          no-error .
        if not available buf_rvs-doc then do:
          undo, return error substitute( 'Вы не сделали сверку после документа "&1" (тип "&2") .'
                                          , buf_trn-doc.doc-code
                                          , {&rvs-after-doc}
                                        ) .
        end.
      end.
    end.

    for each buf_doc-line exclusive-lock
      where buf_doc-line.doc-code = buf_trn-doc.doc-code
    on error undo, return error return-value
    :
      find first buf_goods no-lock
        where buf_goods.artic     = buf_doc-line.artic
          and buf_goods.prod-type = buf_doc-line.prod-type
          and buf_goods.prod-code = buf_doc-line.prod-code
      .
      
      run gds-attr-value in this-procedure
        (  input buf_goods.gds-code
          ,input {&attr-fuel-type}
          ,output v-attr-value
          ,output v-attr-type
         ) .
      if v-attr-value = "lgas" 
        then next.
      
      if is-gas(buf_goods.gds-code) then next.
      
      find first buf_doc-pl no-lock
                where buf_doc-pl.obj-type = buf_doc-line.obj-type
                and buf_doc-pl.obj-code = buf_doc-line.obj-code
                and buf_doc-pl.out-code = buf_doc-line.doc-code
                and buf_doc-pl.gds-code = buf_goods.gds-code no-error.
            
      run placelib_get-attr(input {&place-virtual}
                           ,input buf_doc-pl.obj-code
                           ,input buf_doc-pl.obj-type
                           ,input buf_doc-pl.pl-code 
                           ,output v-value
                           ,output v-ok) no-error.

      is-vir = if (v-ok and logical(v-value)) then true else false.
      
      if is-vir then next.
      
      { gbl/gdsobjat.i
        buf_doc-line.obj-type
        buf_doc-line.obj-code
        buf_doc-line.artic
        buf_doc-line.prod-type
        buf_doc-line.prod-code
        "'place-rsrv=request'"
        v-reserv-pl
      }

      { str/is-petrl.i
        buf_doc-line.artic
        buf_doc-line.prod-type
        buf_doc-line.prod-code
        is-petrol
        is-pieces
      }
      if is-petrol = true
        and is-pieces = false
      then do:
        find first buf_inv-line
          where buf_inv-line.doc-code  = buf_doc-line.doc-code
            and buf_inv-line.artic     = buf_doc-line.artic
            and buf_inv-line.prod-type = buf_doc-line.prod-type
            and buf_inv-line.prod-code = buf_doc-line.prod-code
          no-error.
        if not available buf_inv-line then do:
          undo, return error substitute( "Не найдена строка с информацией о кол-ве (&1) товара в документе &2 для товара &3."
                                        ,buf_goods.unit-cli
                                        ,buf_doc-line.doc-code
                                        ,buf_goods.gds-code
                                      ).
        end.
      end.

      if v-reserv-pl = true
        or ( is-petrol = true
            and is-pieces = false
          )
      then do:
        assign
          v-pl-fact-qnty        = 0.0
          v-pl-doc-qnty         = 0.0
          v-pl-cli-qnty         = 0.0
          v-pl-cli-fact-qnty    = 0.0
          v-pl-cli-doc-qnty     = 0.0
          v-pl-rest-af-qnty     = 0.0
          v-pl-cli-rest-af-qnty = 0.0
          v-pl-rest-bf-qnty     = 0.0
          v-pl-cli-rest-bf-qnty = 0.0
        .
        for each buf_doc-pl
          where buf_doc-pl.obj-type = buf_trn-doc.obj-type
            and buf_doc-pl.obj-code = buf_trn-doc.obj-code
            and buf_doc-pl.out-code = buf_trn-doc.doc-code
            and buf_doc-pl.gds-code = buf_goods.gds-code
        on error undo, return error return-value
        :
          assign
            v-pl-cli-qnty         = v-pl-cli-qnty         + buf_doc-pl.cli-qnty
            v-pl-fact-qnty        = v-pl-fact-qnty        + buf_doc-pl.fact-qnty
            v-pl-doc-qnty         = v-pl-doc-qnty         + buf_doc-pl.doc-qnty
            v-pl-cli-fact-qnty    = v-pl-cli-fact-qnty    + buf_doc-pl.cli-fact-qnty
            v-pl-cli-doc-qnty     = v-pl-cli-doc-qnty     + buf_doc-pl.cli-doc-qnty
            v-pl-rest-bf-qnty     = v-pl-rest-bf-qnty     + buf_doc-pl.rest-bf-qnty
            v-pl-cli-rest-bf-qnty = v-pl-cli-rest-bf-qnty + buf_doc-pl.cli-rest-bf-qnty
            v-pl-rest-af-qnty     = v-pl-rest-af-qnty     + buf_doc-pl.rest-af-qnty
            v-pl-cli-rest-af-qnty = v-pl-cli-rest-af-qnty + buf_doc-pl.cli-rest-af-qnty
          .
          if buf_trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh} then do:
            if absolute( buf_doc-pl.cli-qnty - buf_doc-pl.cli-doc-qnty ) > 0.001 then do:
              undo, return error substitute( 'Количество в единицах измерения поставщика по строке накладной: &2 для товара &3&1'
                                              + 'НЕ СОВПАДАЕТ с количеством на месте хранения &4!!!&1'
                                              + 'По ТТН &5 (&7)&1'
                                              + 'В ед. изм. поставщика &6 (&7)&1'
                                              , {&new-line}
                                              , buf_trn-doc.doc-code
                                              , buf_doc-pl.gds-code
                                              , buf_doc-pl.pl-code
                                              , buf_doc-pl.cli-qnty
                                              , buf_doc-pl.cli-doc-qnty
                                              , buf_goods.unit-cli
                                            ).
            end.
            if is-petrol = true
              and is-pieces = false
            then do:
              if buf_trn-doc.doc-type = {&inventory} then do:
                if buf_doc-pl.rest-af-qnty <> 0.0
                  and buf_doc-pl.cli-rest-af-qnty <> 0.0
                then do:
                  assign
                    v-density = buf_doc-pl.cli-rest-af-qnty / buf_doc-pl.rest-af-qnty
                  .
                end.
                else do:
                  assign
                    v-density = buf_doc-line.fact-density
                  .
                end.
                if buf_trn-doc.status_ = {&fact}
                  and valid-density( v-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> true
                then do:
                  undo, return error substitute( 'Плотность "стало" топлива по месту хранения не соответствует ожидаемому.&1'
                                                + 'Документ: &2&1'
                                                + 'Товар: &3&1'
                                                + 'Место хранения: &4&1'
                                                + 'Плотность: &5&1'
                                                + 'Кол-во: &6 (&8) и &7 (&9)&1'
                                                ,{&new-line}
                                                ,buf_trn-doc.doc-code
                                                ,buf_goods.gds-code
                                                ,buf_doc-pl.pl-code
                                                ,v-density
                                                ,buf_doc-pl.fact-qnty
                                                ,buf_doc-pl.cli-fact-qnty
                                                ,buf_goods.unit-base
                                                ,buf_goods.unit-cli
                                                ).
                end.
              end.
              else do:
                if buf_doc-pl.cli-doc-qnty <> 0.0
                  and buf_doc-pl.doc-qnty <> 0.0
                then do:
                  assign
                    v-density = buf_doc-pl.cli-doc-qnty / buf_doc-pl.doc-qnty
                  .
                end.
                else do:
                  assign
                    v-density = buf_doc-line.doc-density
                  .
                end.
                if valid-density( v-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> true then do:
                  undo, return error substitute( 'Заявленная плотность топлива по месту хранения не соответствует ожидаемому.&1'
                                                + 'Документ: &2&1'
                                                + 'Товар: &3&1'
                                                + 'Место хранения: &4&1'
                                                + 'Плотность: &5&1'
                                                + 'Кол-во: &6 (&8) и &7 (&9)&1'
                                                ,{&new-line}
                                                ,buf_trn-doc.doc-code
                                                ,buf_goods.gds-code
                                                ,buf_doc-pl.pl-code
                                                ,v-density
                                                ,buf_doc-pl.doc-qnty
                                                ,buf_doc-pl.cli-doc-qnty
                                                ,buf_goods.unit-base
                                                ,buf_goods.unit-cli
                                                ).
                end.
                if buf_doc-pl.cli-fact-qnty <> 0.0
                  and buf_doc-pl.fact-qnty <> 0.0
                then do:
                  assign
                    v-density = buf_doc-pl.cli-fact-qnty / buf_doc-pl.fact-qnty
                  .
                end.
                else do:
                  assign
                    v-density = buf_doc-line.fact-density
                  .
                end.
                if buf_trn-doc.status_ <> {&inquiry}
                  and not( buf_trn-doc.status_ = {&wayb}
                          and buf_trn-doc.flag_ = false
                        )
                  and valid-density( v-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> true
                then do:
                  undo, return error substitute( 'Фактическая плотность топлива по месту хранения не соответствует ожидаемому.&1'
                                                + 'Документ: &2&1'
                                                + 'Товар: &3&1'
                                                + 'Место хранения: &4&1'
                                                + 'Плотность: &5&1'
                                                + 'Кол-во: &6 (&8) и &7 (&9)&1'
                                                ,{&new-line}
                                                ,buf_trn-doc.doc-code
                                                ,buf_goods.gds-code
                                                ,buf_doc-pl.pl-code
                                                ,v-density
                                                ,buf_doc-pl.fact-qnty
                                                ,buf_doc-pl.cli-fact-qnty
                                                ,buf_goods.unit-base
                                                ,buf_goods.unit-cli
                                                ).
                end.
              end.
            end.
          end.
        end. /* for each tt-doc-pl */

        if buf_trn-doc.doc-type = {&inventory} then do:
          if buf_trn-doc.status_ <> {&wayb}
            and ( buf_doc-line.fact-qnty <> v-pl-doc-qnty
                  or buf_doc-line.fact-qnty <> v-pl-fact-qnty
                  or absolute( buf_doc-line.cli-qnty - v-pl-cli-doc-qnty ) > 0.001
                  or absolute( buf_doc-line.cli-qnty - v-pl-cli-fact-qnty ) > 0.001
                )
          then do:
            undo, return error substitute( 'Количество (разница) по строке накладной: &2 для товара &3&1'
                                            + 'НЕ СОВПАДАЕТ с суммарным количеством по местам хранения!!!&1'
                                            + 'По строке &4 (&6) &5 (&7)&1'
                                            , {&new-line}
                                            , buf_trn-doc.doc-code
                                            , buf_goods.gds-code
                                            , buf_doc-line.fact-qnty
                                            , buf_doc-line.cli-qnty
                                            , buf_goods.unit-base
                                            , buf_goods.unit-cli
                                          )
                             + substitute( 'По местам хр.(doc)  &2 (&6) &3 (&7)&1'
                                            + 'По местам хр.(fact) &4 (&6) &5 (&7)&1'
                                            , {&new-line}
                                            , v-pl-doc-qnty
                                            , v-pl-cli-doc-qnty
                                            , v-pl-fact-qnty
                                            , v-pl-cli-fact-qnty
                                            , buf_goods.unit-base
                                            , buf_goods.unit-cli
                                          )
                                          .
          end.
          if buf_trn-doc.status_ = {&fact}
            and ( buf_doc-line.doc-qnty <> v-pl-rest-af-qnty
                  or ( absolute( buf_inv-line.wast-cli-qnty - v-pl-cli-rest-af-qnty ) > 0.001
                       and is-petrol = true
                       and is-pieces = false
                     )
                )
          then do:
            undo, return error substitute( 'Количество "после инвентаризации" в строке накладной: &2 для товара &3&1'
                                            + 'НЕ СОВПАДАЕТ с суммарным количеством по местам хранения!!!&1'
                                            + 'По строке &4 (&8) &5 (&9)&1'
                                            + 'По местам хр. &6 (&8) &7 (&9)&1'
                                            , {&new-line}
                                            , buf_trn-doc.doc-code
                                            , buf_goods.gds-code
                                            , buf_doc-line.doc-qnty
                                            , buf_inv-line.wast-cli-qnty
                                            , v-pl-rest-af-qnty
                                            , v-pl-cli-rest-af-qnty
                                            , buf_goods.unit-base
                                            , buf_goods.unit-cli
                                          ).
          end.

        end. /* buf_trn-doc.doc-type = {&inventory} */
        else do:
          if absolute( buf_doc-line.cli-qnty - v-pl-cli-qnty ) > 0.001 then do:
            undo, return error substitute( 'Количество в единицах измерения поставщика в строке накладной: &2 для товара &3&1'
                                          + 'НЕ СОВПАДАЕТ с суммарным количеством по местам хранения!!!&1'
                                          + 'По строке &4 (&6)&1'
                                          + 'По местам хр. &5 (&6)&1'
                                          , {&new-line}
                                          , buf_trn-doc.doc-code
                                          , buf_goods.gds-code
                                          , buf_doc-line.cli-qnty
                                          , v-pl-cli-qnty
                                          , buf_doc-line.unit-cli
                                        ).
          end.
          if buf_doc-line.doc-qnty <> v-pl-doc-qnty
            or ( absolute( buf_doc-line.doc-qnty * buf_doc-line.doc-density - v-pl-cli-doc-qnty ) > 0.001
                and is-petrol = true
                and is-pieces = false
                )
          then do:
            undo, return error substitute( 'Заявленное количество в строке накладной: &2 для товара &3&1'
                                          + 'НЕ СОВПАДАЕТ с суммарным количеством по местам хранения!!!&1'
                                          + 'По строке &4 (&8) &5 (&9)&1'
                                          + 'По местам хр. &6 (&8) &7 (&9)&1'
                                          , {&new-line}
                                          , buf_trn-doc.doc-code
                                          , buf_goods.gds-code
                                          , buf_doc-line.doc-qnty
                                          , buf_doc-line.doc-qnty * buf_doc-line.doc-density
                                          , v-pl-doc-qnty
                                          , v-pl-cli-doc-qnty
                                          , buf_goods.unit-base
                                          , buf_goods.unit-cli
                                        ).
          end.
          if buf_trn-doc.status_ <> {&inquiry}
            and not( buf_trn-doc.status_ = {&wayb}
                    and buf_trn-doc.flag_ = false
                  )
            and ( buf_doc-line.fact-qnty <> v-pl-fact-qnty
                  or ( absolute( buf_doc-line.fact-qnty * buf_doc-line.fact-density - v-pl-cli-fact-qnty ) > 0.001
                      and is-petrol = true
                      and is-pieces = false
                    )
                )
          then do:
            undo, return error substitute( 'Фактическое количество в строке накладной: &2 для товара &3&1'
                                            + 'НЕ СОВПАДАЕТ с суммарным количеством по местам хранения!!!&1'
                                            + 'По строке &4 (&8) &5 (&9)&1'
                                            + 'По местам хр. &6 (&8) &7 (&9)&1'
                                            , {&new-line}
                                            , buf_trn-doc.doc-code
                                            , buf_goods.gds-code
                                            , buf_doc-line.fact-qnty
                                            , buf_doc-line.fact-qnty * buf_doc-line.fact-density
                                            , v-pl-fact-qnty
                                            , v-pl-cli-fact-qnty
                                            , buf_goods.unit-base
                                            , buf_goods.unit-cli
                                          ).
          end.
        end.

        if is-petrol = true
          and is-pieces = false
        then do:
          if ( ( buf_trn-doc.doc-type = {&inventory}
                and buf_trn-doc.status_ = {&fact}
              )
              or buf_trn-doc.doc-type <> {&inventory}
            )
          then do:
            if valid-density( buf_doc-line.doc-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> true
              or valid-density( buf_doc-line.fact-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> true
            then do:
              undo, return error substitute( 'Плотность товара &1 в строке документа &2 некорректная: &3 (док), &4 (факт)'
                                            ,buf_goods.gds-code
                                            ,buf_trn-doc.doc-code
                                            ,buf_doc-line.doc-density
                                            ,buf_doc-line.fact-density
                                          ).
            end.
          end.

          if buf_trn-doc.doc-type = {&inventory} then do:
            if buf_trn-doc.status_ <> {&wayb}
              and ( absolute( buf_inv-line.wast-cli-qnty - buf_doc-line.cli-qnty - buf_inv-line.before-cli-qnty) > 0.01
                    or buf_inv-line.wast-cli-qnty <> buf_inv-line.after-cli-qnty
                    or absolute( buf_inv-line.before-cli-qnty + buf_doc-line.cli-qnty - buf_inv-line.after-cli-qnty) > 0.01
                  )
            then do:
              undo, return error substitute( 'Ошибка в количествах (&5) "было", "по документу" и "стало"&1'
                                            + 'Документ &2&1'
                                            + 'Товар &3&1'
                                            + '"Было" &6 (&4)&1'
                                            + '"Было" &7 (&5) (inv-line.wast-cli-qnty - doc-line.cli-qnty)&1'
                                            + '"Было" &8 (&5) (inv-line.before-cli-qnty) &1'
                                            ,{&new-line}
                                            ,buf_trn-doc.doc-code
                                            ,buf_goods.gds-code
                                            ,buf_goods.unit-base
                                            ,buf_goods.unit-cli
                                            ,buf_doc-line.doc-qnty - buf_doc-line.fact-qnty
                                            ,buf_inv-line.wast-cli-qnty - buf_doc-line.cli-qnty
                                            ,buf_inv-line.before-cli-qnty
                                          )
                              + substitute( 'По документу &4 (&2)&1'
                                            + 'По документу &5 (&3)&1'
                                            + '"Стало" &6 (&2) &1'
                                            + '"Стало" &7 (&3) (inv-line.wast-cli-qnty)&1'
                                            + '"Стало" &8 (&3) (inv-line.after-cli-qnty)&1'
                                            ,{&new-line}
                                            ,buf_goods.unit-base
                                            ,buf_goods.unit-cli
                                            ,buf_doc-line.fact-qnty
                                            ,buf_doc-line.cli-qnty
                                            ,buf_doc-line.doc-qnty
                                            ,buf_inv-line.wast-cli-qnty
                                            ,buf_inv-line.after-cli-qnty
                                          ).
            end.
            if buf_trn-doc.status_ = {&fact}
              and absolute( buf_doc-line.doc-qnty * buf_doc-line.fact-density - buf_inv-line.wast-cli-qnty ) > 0.01
            then do:
              undo, return error substitute( 'Ошибка в количествах "стало"&1'
                                            + 'Документ &2&1'
                                            + 'Товар &3&1'
                                            + '"Стало" &6 (&4)&1'
                                            + '"Стало" &7 (&5)&1'
                                            + '"Стало" (плотность) &8&1'
                                            ,{&new-line}
                                            ,buf_trn-doc.doc-code
                                            ,buf_goods.gds-code
                                            ,buf_goods.unit-base
                                            ,buf_goods.unit-cli
                                            ,buf_doc-line.doc-qnty
                                            ,buf_inv-line.after-cli-qnty
                                            ,buf_doc-line.fact-density
                                          ).
            end.
          end.
          else do:
            if absolute( buf_doc-line.fact-qnty * buf_doc-line.fact-density - buf_inv-line.wast-cli-qnty ) > 0.001
              and ( buf_doc-line.fact-qnty <> 0
                    or ( buf_doc-line.fact-qnty = 0
                        and v-chk-null-qnty = true
                      )
                  )
            then do:
              undo, return error substitute( "Несоответствие по товару &2 в строке документа &3&1"
                                              + "Фактическое количество (&4): &6&1"
                                              + "Фактическое количество (&5): &7&1"
                                              + "Плотность: &8"
                                              ,{&new-line}
                                              ,buf_goods.gds-code
                                              ,buf_doc-line.doc-code
                                              ,buf_goods.unit-base
                                              ,buf_goods.unit-cli
                                              ,buf_doc-line.fact-qnty
                                              ,buf_inv-line.wast-cli-qnty
                                              ,buf_doc-line.fact-density
                                            ).
            end.
          end.

          if buf_trn-doc.status_ = {&fact} then do:
            if v-chk-rvs = true then do:
              run gds-attr-value in this-procedure
                ( input  buf_goods.gds-code
                ,input  {&attr-ptrl-without-rvs}
                ,output v-attr-value
                ,output v-attr-type
                ) .
              if lookup(v-attr-value, 'true,yes':u) = 0 then do:
                find first buf_rvs-line no-lock
                  where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                    and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                    and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                    and buf_rvs-line.gds-code = buf_goods.gds-code
                  no-error .
                if not available buf_rvs-doc then do:
                  undo, return error substitute( 'Вы не сделали сверку перед документом "&1" (тип "&2") по товару &3 ("&4").'
                                                , buf_trn-doc.doc-code
                                                , {&rvs-before-doc}
                                                , buf_goods.gds-code
                                                , buf_goods.gds-name
                                                ) .
                end.
                find first buf_rvs-line no-lock
                  where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                    and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                    and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                    and buf_rvs-line.gds-code = buf_goods.gds-code
                  no-error .
                if not available buf_rvs-doc then do:
                  undo, return error substitute( 'Вы не сделали сверку после документа "&1" (тип "&2") по товару &3 ("&4").'
                                                , buf_trn-doc.doc-code
                                                , {&rvs-after-doc}
                                                , buf_goods.gds-code
                                                , buf_goods.gds-name
                                                ) .
                end.
              end.
            end.

            if ( buf_trn-doc.doc-type <> {&inventory}
                and buf_inv-line.wast-cli-qnty = ?
              )
              or
              ( buf_trn-doc.doc-type = {&inventory}
                and buf_doc-line.cli-qnty = ?
              )
            then do:
              undo, return error substitute( 'Ошибка в нарастающем итоге&1'
                                              + 'Документ &2&1'
                                              + 'Товар &3&1'
                                              + 'По документу &5 (&4)&1'
                                              ,{&new-line}
                                              ,buf_trn-doc.doc-code
                                              ,buf_goods.gds-code
                                              ,buf_goods.unit-cli
                                              ,(if buf_trn-doc.doc-type = {&inventory} then buf_doc-line.cli-qnty else buf_inv-line.wast-cli-qnty )
                                            ).
            end.

            { str/lastinvl.i
              buf_inv-line.doc-code
              buf_inv-line.artic
              buf_inv-line.prod-type
              buf_inv-line.prod-code
              v-before-cli-qnty
              v-last-invlin
            }
            find first buf-prev_inv-line no-lock
              where recid( buf-prev_inv-line ) = v-last-invlin
              no-error .

            IF AVAILABLE buf-prev_inv-line THEN DO :
            case buf_trn-doc.doc-type :
              when {&inventory} then do:
                assign
                  v-after-cli-qnty = v-before-cli-qnty + buf_doc-line.cli-qnty
                .
              end.
              otherwise do:
                assign
                  v-after-cli-qnty = v-before-cli-qnty + buf_inv-line.wast-cli-qnty * v-sign
                .
              end.
            end case.
            if v-before-cli-qnty <> buf_inv-line.before-cli-qnty
              or v-after-cli-qnty <> buf_inv-line.after-cli-qnty
            then do:
              if abs(v-before-cli-qnty - buf_inv-line.before-cli-qnty) <= 0.001
              and abs(v-after-cli-qnty  -  buf_inv-line.after-cli-qnty) <= 0.001
              then do :
                assign
                  buf_inv-line.before-cli-qnty = v-before-cli-qnty
                  buf_inv-line.after-cli-qnty  = v-after-cli-qnty
                .
              end.
              else do :
              undo, return error substitute( 'Ошибка в нарастающем итоге&1'
                                              + 'Документ &2&1'
                                              + 'Товар &3&1'
                                              + '"Было" предыдущий документ (&5) &6 (&4)&1'
                                              + '"Было" текущий документ &7 (&4)&1'
                                              ,{&new-line}
                                              ,buf_trn-doc.doc-code
                                              ,buf_goods.gds-code
                                              ,buf_goods.unit-cli
                                              ,(if available buf-prev_inv-line then buf-prev_inv-line.doc-code else "":U)
                                              ,v-before-cli-qnty
                                              ,buf_inv-line.before-cli-qnty
                                            )
                              + substitute( 'По документу &3 (&2)&1'
                                              + '"Стало" текущий документ &4 (&2)&1'
                                              + '"Стало" должно быть &5 (&2)&1'
                                              ,{&new-line}
                                              ,buf_goods.unit-cli
                                              ,(if buf_trn-doc.doc-type <> {&inventory} then buf_inv-line.wast-cli-qnty else buf_doc-line.cli-qnty )
                                              ,buf_inv-line.after-cli-qnty
                                              ,v-after-cli-qnty
                                            ).
            end.
            end.
            END.

            find first buf-next_doc-line
              where buf-next_doc-line.obj-type   = buf_doc-line.obj-type
                and buf-next_doc-line.obj-code   = buf_doc-line.obj-code
                and buf-next_doc-line.prod-type  = buf_doc-line.prod-type
                and buf-next_doc-line.prod-code  = buf_doc-line.prod-code
                and buf-next_doc-line.artic      = buf_doc-line.artic
                and buf-next_doc-line.status_    = {&fact}
                and buf-next_doc-line.fact-order > buf_doc-line.fact-order
              no-error .
            if not available buf-next_doc-line then do:
              /* более поздних документов с этим товаром нет */
              assign
                v-after-qnty     = 0.0
                v-after-cli-qnty = 0.0
              .
              for each buf_pl-gds no-lock
                where buf_pl-gds.gds-code = buf_goods.gds-code
                  and buf_pl-gds.obj-type = buf_doc-line.obj-type
                  and buf_pl-gds.obj-code = buf_doc-line.obj-code
              on error undo, return error return-value
              :
                assign
                  v-after-qnty     = v-after-qnty     + buf_pl-gds.fact-qnty
                  v-after-cli-qnty = v-after-cli-qnty + buf_pl-gds.cli-fact-qnty
                .
              end.
              if absolute( v-after-cli-qnty - buf_inv-line.after-cli-qnty ) > 0.001 then do:
                undo, return error substitute( 'Ошибка в нарастающем итоге&1'
                                                + 'Документ &2&1'
                                                + 'Товар &3&1'
                                                + '"Стало" (текущий документ) &5 (&4)&1'
                                                + '"Стало" (по местам хр.) &6 (&4)'
                                                ,{&new-line}
                                                ,buf_trn-doc.doc-code
                                                ,buf_goods.gds-code
                                                ,buf_goods.unit-cli
                                                ,buf_inv-line.after-cli-qnty
                                                ,v-after-cli-qnty
                                              ).
              end.
              find first buf_gds-obj no-lock
                where buf_gds-obj.obj-type  = buf_doc-line.obj-type
                  and buf_gds-obj.obj-code  = buf_doc-line.obj-code
                  and buf_gds-obj.artic     = buf_doc-line.artic
                  and buf_gds-obj.prod-type = buf_doc-line.prod-type
                  and buf_gds-obj.prod-code = buf_doc-line.prod-code
              .
              if absolute( v-after-qnty - buf_gds-obj.fact-qnty ) > 0.001 then do:
                undo, return error substitute( 'Ошибка в итоговом кол-ве товара на местах хранения&1'
                                                + 'Документ &2&1'
                                                + 'Товар &3&1'
                                                + '"Стало" (на объекте) &5 (&4)&1'
                                                + '"Стало" (по местам хр.) &6 (&4)'
                                                ,{&new-line}
                                                ,buf_trn-doc.doc-code
                                                ,buf_goods.gds-code
                                                ,buf_goods.unit-base
                                                ,buf_gds-obj.fact-qnty
                                                ,v-after-qnty
                                              ).
              end.
            end.
            else do:
              /* закрытие задним числом */
              find first buf-next_inv-line
                where buf-next_inv-line.doc-code  = buf-next_doc-line.doc-code
                  and buf-next_inv-line.artic     = buf-next_doc-line.artic
                  and buf-next_inv-line.prod-type = buf-next_doc-line.prod-type
                  and buf-next_inv-line.prod-code = buf-next_doc-line.prod-code
                no-error.
              if not available buf-next_inv-line then do:
                undo, return error substitute( "Не найдена строка с информацией о кол-ве (&1) товара в документе &2 для товара &3."
                                              ,buf_goods.unit-cli
                                              ,buf-next_doc-line.doc-code
                                              ,buf_goods.gds-code
                                              ).
              end.
              if buf_inv-line.after-cli-qnty <> buf-next_inv-line.before-cli-qnty then do:
                undo, return error substitute( 'При закрытии документа задним числом не пересчитан нарастающий итог&1'
                                                + 'Документ &2&1'
                                                + 'Товар &3&1'
                                                + '"Стало" текущего документа &5 (&4)&1'
                                                + '"Было" следующего документа (&6) &7 (&4)'
                                                ,{&new-line}
                                                ,buf_trn-doc.doc-code
                                                ,buf_goods.gds-code
                                                ,buf_goods.unit-cli
                                                ,buf_inv-line.after-cli-qnty
                                                ,buf-next_doc-line.doc-code
                                                ,buf-next_inv-line.before-cli-qnty
                                              ).
              end.
            end.
          end.
        end.
      end.
    end. /* for each buf_doc-line */
  end.

  return .
end. /* on error */