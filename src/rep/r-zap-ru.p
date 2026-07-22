block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-zap-ru.p $
$Archive: rep/r-zap-ru.p $

Состояние запаса для Ручки.ру

Автор: Кочетков Михаил Юрьевич
Дата создания: 07/03/08
Author: Michael Kochetkov
Creation date: 07/03/08

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-zap-ru.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-zap-ru.p $":U .
define variable vss-description as character no-undo init "Состояние запаса для Ручки.ру".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ trg/prdoclib.i }
{ trg/factord.i  }
{ cmp/library.i  }
{ ref/grplibfn.i }
{ cmp/r-pril.i   }
{ rep/f-fdec.i   }   /* Функции для форматирования полей для передачи в EXcel         */
{ gbl/paramls.i  }
define variable g#report-num as integer no-undo .
run get-report-num   in my-handle (output g#report-num).
{ rep/mcrexcel.i }

  DEFINE temp-table gds-prop no-undo
    field   qnty             as decimal
    field   obj-type         as  char
    field   obj-code         as  integer
    field   obj-name         as  char
    field   gds-code         as  integer
    field   b-code           as  integer
    field   b-str            as  character
    INDEX pi  IS PRIMARY   obj-type obj-code gds-code
  .

  define variable s-date as character no-undo .
  assign s-date = string(x-Date-Alone,"99.99.9999") .

  define buffer buf_gds-obj  for gds-obj.
  define buffer buf_stk-line for stk-line.
  define buffer buf_prod-bc  for prod-bc.

  define variable Counter1     as integer   no-undo .
  define variable is-empty-scale  as logical   no-undo .
  define variable v-root-node as integer   no-undo .
  define variable CurrGrpName  as character no-undo .
  define variable v-qnty as decimal   no-undo .

  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .

  define variable v-fact-order as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input x-date-Alone + 1, output v-fact-order ).

  assign
    Counter1 = 0 .
  .
  { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

  for each gds-prop :
    delete gds-prop .
  end.
  if x-SelectGood = {&g-all} then do: /* все товары */
    for each obj-list :
      for each buf_gds-obj no-lock
        where buf_gds-obj.obj-type  = obj-list.obj-type
          and buf_gds-obj.obj-code  = obj-list.obj-code
        :
        run Fill-Temp in this-procedure .
      end.
    end.
  end.
  else do:
    for each obj-list :                /* встать на объект */
      case x-SelectGood :
        when {&g-all} then do:
        end.
        when {&g-prod} then do:    /* не все производители */
          for each G#cli : /* встать на производителя */
            for each buf_gds-obj  no-lock
              where buf_gds-obj.obj-type  = obj-list.obj-type
                and buf_gds-obj.obj-code  = obj-list.obj-code
                and buf_gds-obj.prod-type = G#cli.obj-type
                and buf_gds-obj.prod-code = G#cli.obj-code
            use-index pi  :
              run Fill-Temp in this-procedure .
            end .
          end.                /* do ... по производителям */
        end .
        when {&g-grp} then do:    /* не все группы товаров */
          for each tmp#grp :
            run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output CurrGrpName ) .
            for each buf_gds-obj no-lock
              where buf_gds-obj.obj-type = obj-list.obj-type
                and buf_gds-obj.obj-code = obj-list.obj-code
                and buf_gds-obj.grp-name begins CurrGrpName
              use-index obj-grp :
              run Fill-Temp in this-procedure .
            end .
          end.    /* do i = 1 to num-entries ( gdsgrp_recids ) : */
        end.
        otherwise do:
         /* список товаров */
          for each gds-list ,
              each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.artic     = gds-list.artic
              and buf_gds-obj.prod-type = gds-list.prod-type
              and buf_gds-obj.prod-code = gds-list.prod-code
            :
            run Fill-Temp in this-procedure .
          end.
        end.

      end case.
    end.                    /* for each ... по объектам */
  end.

  { gbl/working.i }

  /* macr_excel - для экселя */
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .

  run PutColumnTitulExcel in this-procedure .

  for each gds-prop by gds-prop.obj-name :
    assign v-col =  1 .
    run macr_excel_char ( s-date                    , v-row, v-col) .       assign v-col = v-col + 1 .
    run macr_excel_char ( gds-prop.obj-name         , v-row, v-col) .       assign v-col = v-col + 1 .
    run macr_excel_char ( string(gds-prop.obj-code) , v-row, v-col) .       assign v-col = v-col + 1 .
    run macr_excel_char (if trim(gds-prop.b-str)<>"" then string(gds-prop.b-str) else string(gds-prop.b-cod)   , v-row, v-col) .       assign v-col = v-col + 1 .
    run macr_excel_sum  ( gds-prop.qnty             , v-row, v-col, 3) .    assign v-col = v-col + 1 .
    assign  v-row = v-row + 1 .
  end.

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run paramls-write in this-procedure
      (input "charcol"
      ,input ""
      ,input "3,4,5"
      ) . /*Вывод текстовый*/
  run end-proc .

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

  { gbl/stopwork.i }

  run rep/runexcel.p (v-file-name ).



procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
    assign
      v-row = 1
      v-col = 1
    .
/*    run macr_excel_char ("Реестр документов движения серийных МЦ", v-row, 2) .*/
/*    run macr_cell_format ( 11, yes, no, ?, v-row, 2, v-row, 2) .*/
/*    assign v-row = v-row + 1 .*/
    run macr_excel_char ("DATE", v-row, v-col) .
    run macr_cell_size (10,?, v-row, v-col, ?, ?).              assign v-col = v-col + 1 .
    run macr_excel_char ("Store NAME", v-row, v-col) .
    run macr_cell_size (40,?, v-row, v-col, ?, ?).              assign v-col = v-col + 1 .
    run macr_excel_char ("Store №", v-row, v-col) .
    run macr_cell_size (10,?, v-row, v-col, ?, ?).              assign v-col = v-col + 1 .
    run macr_excel_char ("Article", v-row, v-col) .
    run macr_cell_size (16,?, v-row, v-col, ?, ?).              assign v-col = v-col + 1 .
    run macr_excel_char ("Stock_Left", v-row, v-col) .
    run macr_cell_size (15,?, v-row, v-col, ?, ?).

/*    run macr_cell_bordur ( v-row, 1, v-row, v-col) .*/
    run macr_cell_format ( 10, yes, no, 35, v-row, 1, v-row, v-col) .

    assign
      v-row = v-row + 1
      v-col = 1
    .
  end.
end procedure. /* PutColumnTitulExcel */


procedure is-page :
  do
  on error undo, return error return-value
  :
    if  ( v-row ) >= 63000 then do:
      Output stream Macr_Excel  close .
      run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
      run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
      output stream  Macr_Excel to value(v-file-name) .
      assign v-ind = v-ind + 1 .
      run PutColumnTitulExcel in this-procedure .
    end.
  end.
end procedure. /* is-page */


procedure Fill-Temp :
  do
  on error undo, return error return-value
  :
    /* Было ли на этом объекте хотя бы какое-то движение данного товара */
    /*  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .*/
    if buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .

    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }

    /* смотрим признаки */
    { gbl/rootnode.i   buf_gds-obj.artic   buf_gds-obj.prod-type   buf_gds-obj.prod-code  v-root-node }
    { gbl/prtat.i v-root-node  "'empty-scale=request'"  is-empty-scale }

    assign v-qnty = 0 .

    if is-empty-scale = yes then do:  /* шкалы нет */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-cost}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order
      use-index category no-error .
      if available buf_stk-line then assign v-qnty = buf_stk-line.fact-qnty .
      if v-qnty = 0 then next .

      create gds-prop .
      assign
        gds-prop.gds-code  = buf_gds-obj.gds-code
        gds-prop.obj-type  = obj-list.obj-type
        gds-prop.obj-code  = obj-list.obj-code
        gds-prop.obj-name  = obj-list.obj-name
        gds-prop.qnty      = v-qnty
      .
      { gbl/gdsbcode.i  buf_gds-obj.gds-code  ?  gds-prop.b-code  no-error }
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip
        "Артикул товара" skip buf_gds-obj.artic   view-as alert-box error .
      end.
          find first buf_prod-bc no-lock
              where  buf_prod-bc.b-code = gds-prop.b-code
                and  buf_prod-bc.bc-on  = yes
          no-error.
          if available buf_prod-bc
          then do:
            assign
               gds-prop.b-str = buf_prod-bc.b-str
            .
          end.

    end.
    else do:  /* шкальный товар */
      run  prdoclib-init-prt-obj-by-factord in this-procedure  /* на начало */
        ( input buf_gds-obj.obj-type
        , input buf_gds-obj.obj-code
        , input buf_gds-obj.artic
        , input buf_gds-obj.prod-type
        , input buf_gds-obj.prod-code
        , input v-fact-order
        , input false ) .
      for each temp-prt-obj no-lock :
        if temp-prt-obj.fact-qnty = 0 then next .
        create gds-prop .
        assign
          gds-prop.gds-code  = buf_gds-obj.gds-code
          gds-prop.obj-type  = obj-list.obj-type
          gds-prop.obj-code  = obj-list.obj-code
          gds-prop.obj-name  = obj-list.obj-name
          gds-prop.qnty      = temp-prt-obj.fact-qnty
        .
        { gbl/gdsbcode.i buf_gds-obj.gds-code temp-prt-obj.prt-code gds-prop.b-code  no-error  }
        if error-status :error then do:
          message  vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip
            "Артикул товара"   buf_gds-obj.artic skip  "Код признака" temp-prt-obj.prt-code skip error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        end.
          find first buf_prod-bc no-lock
              where  buf_prod-bc.b-code = gds-prop.b-code
                and  buf_prod-bc.bc-on  = yes
          no-error.
          if available buf_prod-bc
          then do:
            assign
               gds-prop.b-str = buf_prod-bc.b-str
            .
          end.

      end.
    end.
  end.
end procedure. /* Fill-Temp */