block-level on error undo, throw.
/*

$Revision: bf04b0e5cfa2, 2256, rls $
$Author: druban $
$Date: Wed Dec 25 15:24:01 2019 +0300 $
$Workfile: reclckgo.p $
$Archive: utl/reclckgo.p $

Утилита пересчета остатков в кг по топливным товарам

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/31/07
Author: Dmitry Ukhanov
Creation date: 10/31/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 04/12/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter parobj-type like ub.trn-doc.obj-type no-undo.
define input parameter parobj-code like ub.trn-doc.obj-code no-undo.
define input parameter p-action      as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: bf04b0e5cfa2, 2256, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:24:01 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: reclckgo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/reclckgo.p $":U .
define variable vss-description as character no-undo init "процедура импорта пакета".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }

main_block:
do
on error  undo, return error substitute("&1. error main_block. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on endkey undo, return error substitute("&1. endkey main_block")
on stop   undo, return error substitute("&1. stop main_block")
:

  define stream LogStream.
  define variable v-log-file-name as character no-undo .

  define variable v-pl-after-qnty  like ub.pl-gds.cli-fact-qnty    no-undo.
  define variable v-after-cli-qnty like ub.inv-line.after-cli-qnty no-undo.
  define variable v-qnty           like ub.doc-pl.fact-qnty        no-undo .
  define variable v-cli-qnty       like ub.doc-pl.cli-fact-qnty    no-undo .
  define variable v-crt-cli-qnty   like ub.doc-pl.cli-fact-qnty    no-undo .
  define variable v-new-cli-qnty   like ub.doc-pl.cli-fact-qnty    no-undo .
  define variable v-pl-qnty        as integer   no-undo .
  define variable v-correct-qnty   as decimal   no-undo .
  define variable v-recalc-doc-pl  as logical   no-undo .
  define variable v-sign           as decimal   no-undo .
  define variable v-free-qnty-pl   like ub.pl-gds.free-qnty        no-undo.
  define variable v-fact-qnty-pl   like ub.pl-gds.fact-qnty        no-undo.
  define variable v-free-qnty      like ub.gds-obj.free-qnty       no-undo.
  define variable v-fact-qnty      like ub.gds-obj.fact-qnty       no-undo.
  define variable varschartic      as character no-undo .
  define variable varnotes         as character no-undo.
  define variable varlns-cnt       as integer   no-undo.
  define variable varis-petrolium  as logical   no-undo.
  define variable varis-pieces     as logical   no-undo.

  define buffer buf_sys-ctrl       for ub.sys-ctrl .
  define buffer buf_goods          for ub.goods .
  define buffer buf_doc-line       for ub.doc-line .
  define buffer buf_inv-line       for ub.inv-line .
  define buffer buf-first_trn-doc  for ub.trn-doc .
  define buffer buf-first_doc-line for ub.doc-line .
  define buffer buf-first_inv-line for ub.inv-line .
  define buffer buf-prev_doc-line  for ub.doc-line .
  define buffer buf-prev_inv-line  for ub.inv-line .
  define buffer buf_trn-doc        for ub.trn-doc .
  define buffer buf-parts_trn-doc  for ub.trn-doc .
  define buffer buf-parts_doc-pl   for ub.doc-pl .
  define buffer buf_doc-pl         for ub.doc-pl .
  define buffer buf_gds-obj        for ub.gds-obj .
  define buffer buf_pl-gds         for ub.pl-gds .
  define buffer buf-all_pl-gds     for ub.pl-gds .
  define buffer buf_parts          for ub.parts .

  define frame d-info
    buf_goods.gds-code    label "Товар"    format ">>>>>>>>>9" skip
    buf_doc-line.doc-code label "Документ" format "x(50)" skip
    buf_trn-doc.fact-date label "Дата"     format "99/99/9999" skip
    with view-as dialog-box side-labels 1 columns three-d title "Пересчет топливного остатка"
  .

  find first buf_sys-ctrl no-lock .
  assign
    v-log-file-name = substitute( "reclckgo-&1.log":U, buf_sys-ctrl.db-num )
  .
  run str/chs-gds.w
    ( input parparentproc
     ,input parobj-type
     ,input parobj-code
     ,input '':U
     ,input '':U
     ,input "Утилита пересчета остатков в кг по топливным товарам"
     ,input {&all} /*режим вызова справочника товаров*/
     ,input ?
     ,input ?
     ,input ?
     ,input ?
     ,input-output varschartic
     ,output varnotes
    ) no-error.

  view frame d-info.

  output stream LogStream to value( v-log-file-name ) append.
  put stream LogStream unformatted
    skip(1)
    substitute( "&1 &2. Запуск &3 для объекта &4 &5"
                ,string( today, "99/99/9999" )
                ,string( time, "HH:MM:SS" )
                ,(if p-action = "calc":U then "пересчета" else "проверки" )
                ,parobj-type
                ,parobj-code
              )
    skip
    .
  output stream LogStream close.

  lns-cnt:
  do varlns-cnt = 1 to num-entries (varnotes)
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where recid(buf_goods) = integer (entry (varlns-cnt, varnotes))
    .
    { str/is-petrl.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      varis-petrolium
      varis-pieces
    }
    if not( varis-petrolium = true
            and varis-pieces = false
          )
    then do:
      next lns-cnt.
    end.

    output stream LogStream to value( v-log-file-name ) append.
    put stream LogStream unformatted
      skip(1)
      substitute( "Товар: код &1, артикул &2, производитель &3 &4", buf_goods.gds-code, buf_goods.artic, buf_goods.prod-type, buf_goods.prod-code )
      skip(1)
      .
    output stream LogStream close.

    assign
      v-after-cli-qnty = 0.0
      v-qnty           = 0.0
      v-cli-qnty       = 0.0
    .

    find first buf_gds-obj exclusive-lock
      where buf_gds-obj.obj-type  = parobj-type
        and buf_gds-obj.obj-code  = parobj-code
        and buf_gds-obj.artic     = buf_goods.artic
        and buf_gds-obj.prod-type = buf_goods.prod-type
        and buf_gds-obj.prod-code = buf_goods.prod-code
      no-error .
    if not available buf_gds-obj then do:
      output stream LogStream to value( v-log-file-name ) append.
      put stream LogStream unformatted
        substitute( "Не было движения товара на объекте &1 &2 !", parobj-type, parobj-code )
        skip(1)
        .
      output stream LogStream close.
      next lns-cnt.
    end.

    find first buf-first_doc-line share-lock /* именно первый документ */
      where buf-first_doc-line.obj-type   = parobj-type
        and buf-first_doc-line.obj-code   = parobj-code
        and buf-first_doc-line.prod-type  = buf_goods.prod-type
        and buf-first_doc-line.prod-code  = buf_goods.prod-code
        and buf-first_doc-line.artic      = buf_goods.artic
        and buf-first_doc-line.status_    = {&fact}
        and buf-first_doc-line.fact-order > 0.0
      use-index fact-order
      no-error.
    if available buf-first_doc-line then do:
      find first buf-first_trn-doc share-lock
        where buf-first_trn-doc.doc-code = buf-first_doc-line.doc-code
        .
      find first buf-first_inv-line share-lock
        where buf-first_inv-line.doc-code  = buf-first_doc-line.doc-code
          and buf-first_inv-line.artic     = buf-first_doc-line.artic
          and buf-first_inv-line.prod-type = buf-first_doc-line.prod-type
          and buf-first_inv-line.prod-code = buf-first_doc-line.prod-code
        no-error.
      if available buf-first_inv-line then do:
        if lookup( buf-first_trn-doc.ext-doc-type, {&TDEDT_out_list} ) > 0 then do:
          assign
            v-sign = -1.0
          .
        end.
        else do:
          assign
            v-sign = 1.0
          .
        end.

        for each buf_doc-pl exclusive-lock
          where buf_doc-pl.out-code = buf-first_doc-line.doc-code
            and buf_doc-pl.gds-code = buf_goods.gds-code
            and buf_doc-pl.obj-type = buf-first_doc-line.obj-type
            and buf_doc-pl.obj-code = buf-first_doc-line.obj-code
        on error undo, return error return-value
        :
          assign
            v-qnty     = v-qnty     + buf_doc-pl.fact-qnty * v-sign
            v-cli-qnty = v-cli-qnty + buf_doc-pl.cli-fact-qnty * v-sign
          .
        end.

        if buf-first_trn-doc.doc-type = {&inventory} then do:
          if buf-first_doc-line.cli-qnty <> v-cli-qnty * v-sign then do:
            output stream LogStream to value( v-log-file-name ) append.
            put stream LogStream unformatted
              substitute("Ошибка в первом документе." ) skip
              substitute("Документ &1 (&2)", buf-first_doc-line.doc-code, buf-first_trn-doc.doc-type) skip
              substitute("Сумма по местам хранения &1 (&2)", v-cli-qnty * v-sign, buf_goods.unit-cli) skip
              substitute("Сумма по строке &1 (&2)", buf-first_doc-line.cli-qnty, buf_goods.unit-cli) skip
              substitute("Сумма по местам хранения &1 (&2)", v-qnty * v-sign, buf_goods.unit-base) skip
              substitute("Сумма по строке &1 (&2)", buf-first_doc-line.fact-qnty, buf_goods.unit-base) skip
              .
            output stream LogStream close.
            if p-action = "calc":U then do:
              undo, next lns-cnt.
            end.
          end.
          else do:
            assign
              v-after-cli-qnty = buf-first_inv-line.after-cli-qnty - buf-first_doc-line.cli-qnty
            .
          end.
        end.
        else do:
          if buf-first_inv-line.wast-cli-qnty <> v-cli-qnty * v-sign then do:
            output stream LogStream to value( v-log-file-name ) append.
            put stream LogStream unformatted
              substitute("Ошибка в первом документе." ) skip
              substitute("Документ &1 (&2)", buf-first_doc-line.doc-code, buf-first_trn-doc.doc-type) skip
              substitute("Сумма по местам хранения &1 (&2)", v-cli-qnty * v-sign, buf_goods.unit-cli) skip
              substitute("Сумма по строке &1 (&2)", buf-first_inv-line.wast-cli-qnty, buf_goods.unit-cli) skip
              substitute("Сумма по местам хранения &1 (&2)", v-qnty * v-sign, buf_goods.unit-base) skip
              substitute("Сумма по строке &1 (&2)", buf-first_doc-line.fact-qnty, buf_goods.unit-base) skip
              substitute("Плотность &1", buf-first_doc-line.fact-density) skip
              .
            output stream LogStream close.
            if p-action = "calc":U then do:
              undo, next lns-cnt.
            end.
          end.
          else do:
            assign
              v-after-cli-qnty = buf-first_inv-line.after-cli-qnty - buf-first_inv-line.wast-cli-qnty * v-sign
            .
          end.
        end.
      end.
    end.

    for each buf_doc-line exclusive-lock
      where buf_doc-line.obj-type  = parobj-type
        and buf_doc-line.obj-code  = parobj-code
        and buf_doc-line.prod-type = buf_goods.prod-type
        and buf_doc-line.prod-code = buf_goods.prod-code
        and buf_doc-line.artic     = buf_goods.artic
        and buf_doc-line.status_   = {&fact}
      use-index fact-order
    on error undo, return error return-value
    :

      find first buf_trn-doc exclusive-lock
        where buf_trn-doc.doc-code = buf_doc-line.doc-code
      .
      display
        buf_goods.gds-code
        buf_doc-line.doc-code
        buf_trn-doc.fact-date
        with frame d-info
      .
      output stream LogStream to value( v-log-file-name ) append.
      put stream LogStream unformatted
        substitute( "Документ: &1", string( buf_trn-doc.doc-code, "X(25)") ) space(1)
        .
      output stream LogStream close.

      find first buf_inv-line exclusive-lock
        where buf_inv-line.doc-code  = buf_doc-line.doc-code
          and buf_inv-line.artic     = buf_doc-line.artic
          and buf_inv-line.prod-type = buf_doc-line.prod-type
          and buf_inv-line.prod-code = buf_doc-line.prod-code
        no-error.
      if not available buf_inv-line then do:
        output stream LogStream to value( v-log-file-name ) append.
        put stream LogStream unformatted
          skip
          substitute("Отсутствует информация о весовом кол-ве товара (not available inv-line)" ) space(1)
          .
        output stream LogStream close.
        if p-action = "calc":U then do:
          undo, next lns-cnt.
        end.
      end. /* if not available buf_inv-line */
      else do: /* if available buf_inv-line */
        find last buf-prev_doc-line exclusive-lock
          where buf-prev_doc-line.obj-type   = buf_doc-line.obj-type
            and buf-prev_doc-line.obj-code   = buf_doc-line.obj-code
            and buf-prev_doc-line.prod-type  = buf_goods.prod-type
            and buf-prev_doc-line.prod-code  = buf_goods.prod-code
            and buf-prev_doc-line.artic      = buf_goods.artic
            and buf-prev_doc-line.status_    = {&fact}
            and buf-prev_doc-line.fact-order < buf_doc-line.fact-order
          use-index fact-order
          no-error.
        if available buf-prev_doc-line then do:
          find first buf-prev_inv-line exclusive-lock
            where buf-prev_inv-line.doc-code  = buf-prev_doc-line.doc-code
              and buf-prev_inv-line.artic     = buf-prev_doc-line.artic
              and buf-prev_inv-line.prod-type = buf-prev_doc-line.prod-type
              and buf-prev_inv-line.prod-code = buf-prev_doc-line.prod-code
            no-error.
          if available buf-prev_inv-line
            and p-action = "calc":U
            and absolute( v-after-cli-qnty - buf-prev_inv-line.after-cli-qnty ) > 0.001
          then do:
            output stream LogStream to value( v-log-file-name ) append.
            put stream LogStream unformatted
              skip(1)
              substitute("Ошибка расчета документа!!! Нарастающий итог (до документа) &1, а по предыдущему документу &2", v-after-cli-qnty, buf-prev_inv-line.after-cli-qnty ) skip
              .
            output stream LogStream close.
            undo, next lns-cnt.
          end.
        end.

        output stream LogStream to value( v-log-file-name ) append.
        put stream LogStream unformatted
          skip
          substitute("перед док: &1 (&2)"
                     ,(if p-action = "calc":U then string(v-after-cli-qnty, "->,>>>,>>>,>>9.999" ) else string(buf_inv-line.before-cli-qnty, "->,>>>,>>>,>>9.999" ) )
                     ,buf_goods.unit-cli
                    ) space(1)
          .
        output stream LogStream close.

        if lookup( buf_trn-doc.ext-doc-type, {&TDEDT_out_list} ) > 0 then do:
          assign
            v-sign = -1.0
          .
        end.
        else do:
          assign
            v-sign = 1.0
          .
        end.

        assign
          v-pl-qnty       = 0
          v-qnty          = 0.0
          v-cli-qnty      = 0.0
          v-recalc-doc-pl = false
        .

        for each buf_doc-pl exclusive-lock
          where buf_doc-pl.out-code = buf_doc-line.doc-code
            and buf_doc-pl.gds-code = buf_goods.gds-code
            and buf_doc-pl.obj-type = buf_doc-line.obj-type
            and buf_doc-pl.obj-code = buf_doc-line.obj-code
        on error undo, return error return-value
        :
          assign
            v-pl-qnty  = v-pl-qnty  + 1
            v-qnty     = v-qnty     + buf_doc-pl.fact-qnty * v-sign
            v-cli-qnty = v-cli-qnty + buf_doc-pl.cli-fact-qnty * v-sign
          .
        end.

        output stream LogStream to value( v-log-file-name ) append.
        put stream LogStream unformatted
          substitute( "мест хр.: &1"
                      , string( v-pl-qnty, ">>9")
                    )
          space(1)
          .
        output stream LogStream close.


        /* если литры по строке и по резервуарам сходятся, то проверим разбивку кг по резерервуарам */
        if absolute( buf_doc-line.fact-qnty - v-qnty * v-sign ) <= 0.001 /* по литрам сходится */
          and v-cli-qnty = 0.0                                           /* по резервуарам не проставлено почему-то */
        then do:
          case buf_trn-doc.doc-type :
            when {&inventory} then do:
              if v-pl-qnty = 1 /* по инвентаризации можно "размазать" только если один резервуар */
                and absolute( buf_doc-line.cli-qnty - v-cli-qnty * v-sign ) > 0.001 /* расхождение кг по резервуарам*/
              then do:
                assign
                  v-recalc-doc-pl = true
                  v-new-cli-qnty = buf_doc-line.cli-qnty * v-sign
                .
              end.
            end. /* {&inventory} */
            otherwise do:
              if absolute( buf_inv-line.wast-cli-qnty - v-cli-qnty * v-sign ) > 0.001 /* расхождение кг по резервуарам */
              then do:
                assign
                  v-recalc-doc-pl = true
                  v-new-cli-qnty = buf_inv-line.wast-cli-qnty * v-sign
                .
              end.
            end. /* otherwise */
          end case.
        end.

        if p-action = "calc":U
          and v-recalc-doc-pl = true
        then do:
          block_correct-doc-pl:
          do
          on error  undo block_correct-doc-pl, leave block_correct-doc-pl
          on endkey undo block_correct-doc-pl, leave block_correct-doc-pl
          on stop   undo block_correct-doc-pl, leave block_correct-doc-pl
          :
            assign
              v-crt-cli-qnty = 0.0
              v-correct-qnty = v-new-cli-qnty * v-sign
            .
            for each buf_doc-pl exclusive-lock
              where buf_doc-pl.out-code = buf_doc-line.doc-code
                and buf_doc-pl.gds-code = buf_goods.gds-code
                and buf_doc-pl.obj-type = buf_doc-line.obj-type
                and buf_doc-pl.obj-code = buf_doc-line.obj-code
              break by buf_doc-pl.pl-code
            on error  undo block_correct-doc-pl, leave block_correct-doc-pl
            on endkey undo block_correct-doc-pl, leave block_correct-doc-pl
            on stop   undo block_correct-doc-pl, leave block_correct-doc-pl
            :

              if first( buf_doc-pl.pl-code )
                and last( buf_doc-pl.pl-code )
              then do:
                assign
                  buf_doc-pl.cli-fact-qnty = v-new-cli-qnty * v-sign
                  v-correct-qnty = 0.0
                .
              end.
              else do:
                if v-qnty <> 0.0 then do:
                  assign
                    buf_doc-pl.cli-fact-qnty = v-new-cli-qnty * buf_doc-pl.fact-qnty / v-qnty /* знак здесь специально не учитывается */
                    v-correct-qnty = v-correct-qnty - buf_doc-pl.cli-fact-qnty
                  .
                  if last( buf_doc-pl.pl-code )
                    and absolute( v-correct-qnty ) <= 0.001
                    and absolute( v-correct-qnty ) > 0.0
                  then do:
                    assign
                      buf_doc-pl.cli-fact-qnty = buf_doc-pl.cli-fact-qnty + v-correct-qnty
                      v-correct-qnty = 0.0
                    .
                  end.
                end.
                else do: /* v-qnty = 0.0 */
                  if v-new-cli-qnty = 0.0 then do:
                    assign
                      buf_doc-pl.cli-fact-qnty = 0.0
                      v-correct-qnty = 0.0
                    .
                  end.
                  else do:
/*????????????????????????????????????????????????????????????????*/
/* надо как-то размазать килограммы по резервуарам не имея литров */
/*????????????????????????????????????????????????????????????????*/
                  end.
                end.
              end.

              assign
                v-crt-cli-qnty = v-crt-cli-qnty + buf_doc-pl.cli-fact-qnty * v-sign
              .
            end.
            if v-correct-qnty <> 0.0
              or v-crt-cli-qnty <> v-new-cli-qnty
            then do:
              undo block_correct-doc-pl .
            end.
            else do:
              assign
                v-cli-qnty = v-crt-cli-qnty
              .
            end.
          end.
        end.

        case buf_trn-doc.doc-type :
          when {&inventory}
          then do:
            if absolute( buf_doc-line.cli-qnty - v-cli-qnty * v-sign ) <= 0.001
              and absolute( buf_doc-line.fact-qnty - v-qnty * v-sign ) <= 0.001
            then do:
              if p-action = "calc":U then do:
                assign
                  buf_doc-line.cli-qnty = v-cli-qnty * v-sign
                .
              end.

              output stream LogStream to value( v-log-file-name ) append.
              put stream LogStream unformatted
                substitute("по инв: &1 (&2)"
                           ,string(buf_doc-line.cli-qnty, "->,>>>,>>>,>>9.999" )
                           ,buf_goods.unit-cli
                          )
                space(1)
                .
              output stream LogStream close.
            end.
            else do:
              output stream LogStream to value( v-log-file-name ) append.
              put stream LogStream unformatted
                skip(1)
                substitute("Ошибка в строке инвентаризации. &1", (if v-recalc-doc-pl = true and p-action <> "calc":U then "(Возможно исправится при пересчете)" else "":U ) ) skip
                substitute("Сумма по местам хранения &1 (&2)", v-cli-qnty * v-sign, buf_goods.unit-cli) skip
                substitute("Сумма по строке &1 (&2)", buf_doc-line.cli-qnty, buf_goods.unit-cli) skip
                substitute("Сумма по местам хранения &1 (&2)", v-qnty * v-sign, buf_goods.unit-base) skip
                substitute("Сумма по строке &1 (&2)", buf_doc-line.fact-qnty, buf_goods.unit-base) skip
                .
              output stream LogStream close.

              if p-action = "calc":U then do:
                undo, next lns-cnt.
              end.
            end.
          end.
          otherwise do:
            if absolute( buf_inv-line.wast-cli-qnty - v-cli-qnty * v-sign ) <= 0.001
              and absolute( buf_doc-line.fact-qnty - v-qnty * v-sign ) <= 0.001
            then do:
              if p-action = "calc":U then do:
                assign
                  buf_inv-line.wast-cli-qnty = v-cli-qnty * v-sign
                .
              end.
              output stream LogStream to value( v-log-file-name ) append.
              put stream LogStream unformatted
                substitute("по док: &1 (&2)"
                           ,string(buf_inv-line.wast-cli-qnty, "->,>>>,>>>,>>9.999" )
                           ,buf_goods.unit-cli
                          )
                space(1)
                .
              output stream LogStream close.
            end.
            else do:
              output stream LogStream to value( v-log-file-name ) append.
              put stream LogStream unformatted
                skip(1)
                substitute("Ошибка в строке документа. &1", (if v-recalc-doc-pl = true and p-action <> "calc":U then "(Возможно исправится при пересчете)" else "":U ) ) skip
                substitute("Сумма по местам хранения &1 (&2)", v-cli-qnty * v-sign, buf_goods.unit-cli) skip
                substitute("Сумма по строке &1 (&2)", buf_inv-line.wast-cli-qnty, buf_goods.unit-cli) skip
                substitute("Сумма по местам хранения &1 (&2)", v-qnty * v-sign, buf_goods.unit-base) skip
                substitute("Сумма по строке &1 (&2)", buf_doc-line.fact-qnty, buf_goods.unit-base) skip
                substitute("Плотность &1", buf_doc-line.fact-density) skip
                .
              output stream LogStream close.
              if p-action = "calc":U then do:
                undo, next lns-cnt.
              end.
            end.
          end.
        end case.

        if p-action = "calc":U then do:
          assign
            buf_inv-line.before-cli-qnty = v-after-cli-qnty
            buf_inv-line.after-cli-qnty  = buf_inv-line.before-cli-qnty + v-cli-qnty
          .
          if buf_trn-doc.doc-type = {&inventory} then do:
            assign
              buf_inv-line.wast-cli-qnty = buf_inv-line.after-cli-qnty
            .
          end.
        end.

        assign
          v-after-cli-qnty = v-after-cli-qnty + v-cli-qnty
        .
        output stream LogStream to value( v-log-file-name ) append.
        put stream LogStream unformatted
          substitute("после док: &1 (&2)"
                     ,string( buf_inv-line.after-cli-qnty, "->,>>>,>>>,>>9.999" )
                     ,buf_goods.unit-cli
                    )
          skip
          .
        output stream LogStream close.

        if available buf-prev_inv-line
          and absolute( buf_inv-line.before-cli-qnty - buf-prev_inv-line.after-cli-qnty ) > 0.001
        then do:
          output stream LogStream to value( v-log-file-name ) append.
          put stream LogStream unformatted
            skip(1)
            substitute("Ошибка между документами!!! Нарастающий итог (до док.) &1, а по предыдущему документу &2", buf_inv-line.before-cli-qnty, buf-prev_inv-line.after-cli-qnty ) skip
            .
          output stream LogStream close.
        end.
      end. /* if available buf_inv-line */
    end. /* for each buf_doc-line */

    assign
      v-free-qnty = 0.0
      v-fact-qnty = 0.0
    .

    for each buf_pl-gds exclusive-lock
      where buf_pl-gds.gds-code = buf_goods.gds-code
        and buf_pl-gds.obj-type = parobj-type
        and buf_pl-gds.obj-code = parobj-code
      break by buf_pl-gds.pl-code
    on error undo, return error return-value
    :

      if p-action = "calc":U then do:
        if buf_gds-obj.fact-qnty = 0.0 then do:
          assign
            buf_pl-gds.cli-fact-qnty = v-after-cli-qnty
          .
          if v-after-cli-qnty <> 0.0 then do:
            for each buf-all_pl-gds exclusive-lock
              where buf-all_pl-gds.gds-code = buf_pl-gds.gds-code
                and buf-all_pl-gds.obj-type = buf_pl-gds.obj-type
                and buf-all_pl-gds.obj-code = buf_pl-gds.obj-code
            on error undo, return error return-value
            :
              if buf-all_pl-gds.pl-code <> buf_pl-gds.pl-code then do:
                assign
                  buf_pl-gds.cli-fact-qnty = buf_pl-gds.cli-fact-qnty - buf-all_pl-gds.cli-fact-qnty
                .
              end.
            end.
          end.
        end.
        else do:
          assign
            buf_pl-gds.cli-fact-qnty = v-after-cli-qnty / buf_gds-obj.fact-qnty * buf_pl-gds.fact-qnty
          .
        end.
      end.
      assign
        v-pl-after-qnty = v-pl-after-qnty + buf_pl-gds.cli-fact-qnty
      .
      if last( buf_pl-gds.pl-code ) then do:
        if p-action = "calc":U
          and absolute( v-after-cli-qnty - v-pl-after-qnty ) <= 0.001
        then do:
          assign
            buf_pl-gds.cli-fact-qnty = buf_pl-gds.cli-fact-qnty + v-after-cli-qnty - v-pl-after-qnty
          .
        end.
      end.

      if p-action = "calc":U then do:
        assign
          buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-fact-qnty
        .
      end.
      assign
        v-free-qnty-pl = 0.0
        v-fact-qnty-pl = 0.0
      .
      for each buf_parts share-lock
        where buf_parts.prod-type = buf_goods.prod-type
          and buf_parts.prod-code = buf_goods.prod-code
          and buf_parts.artic     = buf_goods.artic
          and buf_parts.obj-type  = buf_pl-gds.obj-type
          and buf_parts.obj-code  = buf_pl-gds.obj-code
          and buf_parts.status_   = no
          and buf_parts.rsrv-free = yes
          and buf_parts.obj-type  = buf_pl-gds.obj-type
          and buf_parts.obj-code  = buf_pl-gds.obj-code
          and buf_parts.pl-code   = buf_pl-gds.pl-code
        break by buf_parts.out-code
      on error undo, return error return-value
      :
        if buf_parts.out-code <> {&free-code} then do:
          find first buf-parts_trn-doc exclusive-lock
            where buf-parts_trn-doc.doc-code = buf_parts.out-code
            .
          if buf-parts_trn-doc.status_ <> {&fact} then do:
            find first buf-parts_doc-pl exclusive-lock
              where buf-parts_doc-pl.obj-type = buf_parts.obj-type
                and buf-parts_doc-pl.obj-code = buf_parts.obj-code
                and buf-parts_doc-pl.pl-code  = buf_parts.pl-code
                and buf-parts_doc-pl.out-code = buf_parts.out-code
                and buf-parts_doc-pl.gds-code = buf_goods.gds-code
              .

            if buf-parts_trn-doc.doc-type = {&inventory} then do:
              if buf_parts.in-code = buf_parts.out-code then do:
                assign
                  v-fact-qnty-pl = v-fact-qnty-pl - absolute(buf_parts.qnty)
                .
                if p-action = "calc":U then do:
                  assign
                    buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-free-qnty
                                              + absolute(buf_parts.qnty) * (buf-parts_doc-pl.cli-rest-af-qnty - buf-parts_doc-pl.cli-rest-bf-qnty)
                                                                          / (buf-parts_doc-pl.rest-af-qnty - buf-parts_doc-pl.rest-bf-qnty)
                  .
                end.
              end.
            end.
            else do:
              if buf_parts.in-code <> buf_parts.out-code then do:
                assign
                  v-fact-qnty-pl = v-fact-qnty-pl + absolute(buf_parts.qnty)
                .
                if p-action = "calc":U then do:
                  assign
                    buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-free-qnty - absolute(buf_parts.qnty) * buf-parts_doc-pl.cli-fact-qnty / buf-parts_doc-pl.fact-qnty
                  .
                end.
              end.
            end.
          end.
        end.
        else do: /* {&free-code} */
          assign
            v-free-qnty-pl = v-free-qnty-pl + absolute(buf_parts.qnty)
            v-fact-qnty-pl = v-fact-qnty-pl + absolute(buf_parts.qnty)
          .
        end.
      end.
      assign
        v-free-qnty = v-free-qnty + v-free-qnty-pl
        v-fact-qnty = v-fact-qnty + v-fact-qnty-pl
      .
      if v-free-qnty-pl <> buf_pl-gds.free-qnty then do:
        output stream LogStream to value( v-log-file-name ) append.
        put stream LogStream unformatted
          substitute('Кол-во "свободно" по партиям (&1 &2) не совпадает с кол-вом (&3 &2) на месте хранения &4'
                     ,v-free-qnty-pl
                     ,buf_goods.unit-base
                     ,buf_pl-gds.free-qnty
                     ,buf_pl-gds.pl-code
                    )
          skip
          .
        output stream LogStream close.
      end.
      if v-fact-qnty-pl <> buf_pl-gds.fact-qnty then do:
        output stream LogStream to value( v-log-file-name ) append.
        put stream LogStream unformatted
          substitute('Кол-во "факт" по партиям (&1 &2) не совпадает с кол-вом (&3 &2) на месте хранения &4'
                     ,v-fact-qnty-pl
                     ,buf_goods.unit-base
                     ,buf_pl-gds.fact-qnty
                     ,buf_pl-gds.pl-code
                    )
          skip
          .
        output stream LogStream close.
      end.
    end.
    if v-free-qnty <> buf_gds-obj.free-qnty then do:
      output stream LogStream to value( v-log-file-name ) append.
      put stream LogStream unformatted
        substitute('Кол-во "свободно" по товару (&1 &2) не совпадает с кол-вом (&3 &2) по партиям'
                   ,buf_gds-obj.free-qnty
                   ,buf_goods.unit-base
                   ,v-free-qnty
                  )
        skip
        .
      output stream LogStream close.
    end.
    if v-fact-qnty <> buf_gds-obj.fact-qnty then do:
      output stream LogStream to value( v-log-file-name ) append.
      put stream LogStream unformatted
        substitute('Кол-во "факт" по товару (&1 &2) не совпадает с кол-вом (&3 &2) по партиям'
                   ,buf_gds-obj.fact-qnty
                   ,buf_goods.unit-base
                   ,v-fact-qnty
                  )
        skip
        .
      output stream LogStream close.
    end.

  end.

end.

hide frame d-info.

message
  "Расчет закончен" skip
  substitute( "Полная информация находится в файле: &1", search( v-log-file-name ) )
  view-as alert-box information.

return .