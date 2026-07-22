/*

$Revision: f29df1d5f130, 3104, rls $
$Author: DRuban $
$Date: Вт авг 09 09:15:01 2022 +0300 $
$Workfile: rsrvindl.i $
$Archive: trg/rsrvindl.i $

Снятие резервов по инвентаризации (уничтожение партий)

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/28/01

Такое быстрое снятие резерва возможно только в том случае
если не происходит уменьшение свободных количеств в остатках товара

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: rsrvindl.i $ $Revision: f29df1d5f130, 3104, rls $".
{ trg/markchng.i }

procedure rsrvindl :
  define input  parameter p-trn-doc-recid  as recid     no-undo .
  define input  parameter p-doc-line-recid as recid     no-undo .
  define input  parameter p-reserv-pl-code as logical   no-undo .

  define variable v-sign as decimal no-undo .
  define variable v-gds-code as integer no-undo .

  define buffer buf_doc-parts for ub.parts .
  define buffer buf_parts     for ub.parts .
  define buffer buf_trn-doc   for ub.trn-doc .
  define buffer buf_doc-line  for ub.doc-line .
  define buffer buf_doc-pl    for ub.doc-pl .
  define buffer buf_goods     for ub.goods .
  define buffer orig_marking-lines for ub.marking-lines .
  define buffer buf_marking-lines for ub.marking-lines .
  define buffer buf_marking   for ub.marking .

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where recid(buf_trn-doc) = p-trn-doc-recid
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Указатель" p-trn-doc-recid skip
        view-as alert-box error .
      undo, return error .
    end.

    find first buf_doc-line no-lock
      where recid(buf_doc-line) = p-doc-line-recid
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Указатель" p-doc-line-recid skip
        view-as alert-box error .
      undo, return error .
    end.

    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Артикул" buf_doc-line.artic skip
        "Производитель" buf_doc-line.prod-type buf_doc-line.prod-code
        view-as alert-box error .
      undo, return error .
    end.

    define variable v-rsrv-code as character no-undo .

    for each buf_doc-parts
      where buf_doc-parts.out-code  = buf_doc-line.doc-code
        and buf_doc-parts.obj-type  = buf_doc-line.obj-type
        and buf_doc-parts.obj-code  = buf_doc-line.obj-code
        and buf_doc-parts.artic     = buf_doc-line.artic
        and buf_doc-parts.prod-type = buf_doc-line.prod-type
        and buf_doc-parts.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
      if buf_doc-parts.status_ <> no then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при снятии резервов" skip
          "Партия имеет недопустимый статус" skip
          "Документ" buf_doc-line.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Статус" buf_doc-parts.status_ skip
          view-as alert-box error .
        undo, return error .
      end.

      if buf_doc-parts.in-code <> buf_doc-parts.out-code then do:
        /* если партия была зарезервирована                        */
        /* то ее необходимо переместить в свободную расходную зону */

        if p-reserv-pl-code  then do:
          /* вызываем со знаком минус - необходимо снять резервы */
          run trndocrs-pl-gds-accum in this-procedure
            (input buf_doc-parts.pl-code
            ,input (- buf_doc-parts.qnty)
            ,input 0.0
            ,input 0.0
            ,input 0.0
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при изменении зарезервированных количеств trndocrs-pl-gds-accum" skip
              "Документ"  buf_doc-line.doc-code skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
        end.

        assign
          v-rsrv-code = { trg/partsprm.i "rsrv-code" buf_trn-doc. buf_doc-parts.fact-qnty }
        .
        run partcopy in this-procedure
          (input  true          /* p-free-output-copy */
          ,input  v-rsrv-code   /* p-out-code         */
          ,buffer buf_doc-parts /* buf_orig_parts     */
          ,buffer buf_parts     /* buf_parts          */
          ,input  ""
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при копировании партии" skip
            "Документ"  buf_doc-line.doc-code skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.

        assign
          buf_parts.qnty       = buf_parts.qnty       + abs(buf_doc-parts.qnty)
          buf_parts.fact-qnty  = buf_parts.qnty
          buf_parts.cli-qnty   = buf_parts.cli-qnty   + abs(buf_doc-parts.cli-qnty)
        .
      end.

      assign
        buf_doc-parts.qnty      = 0
        buf_doc-parts.fact-qnty = 0
        buf_doc-parts.real-qnty = 0
        buf_doc-parts.cli-qnty  = 0
      .
      
      { gbl/objsrv.i }
   
      { gbl/gds-code.i
        buf_doc-parts.artic
        buf_doc-parts.prod-type
        buf_doc-parts.prod-code
        v-gds-code
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при кода товара" skip
          "Документ" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          view-as alert-box error .
        undo, return error .
      end.
  
      for each orig_marking-lines exclusive-lock where orig_marking-lines.gds-code = v-gds-code
                                                  and orig_marking-lines.obj-type = buf_doc-parts.obj-type
                                                  and orig_marking-lines.obj-code = buf_doc-parts.obj-code
                                                  and orig_marking-lines.in-code  = buf_doc-parts.in-code
                                                  and orig_marking-lines.out-code = buf_doc-parts.out-code
                                                  and orig_marking-lines.part-code = buf_doc-parts.part-code
                                                  and orig_marking-lines.prt-code = buf_doc-parts.prt-code:
        find first buf_marking-lines no-lock where  buf_marking-lines.mark       = orig_marking-lines.mark
                                                and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                and buf_marking-lines.in-code    = buf_parts.in-code
                                                and buf_marking-lines.out-code   = buf_parts.out-code
                                                and buf_marking-lines.part-code  = buf_parts.part-code
                                                and buf_marking-lines.prt-code   = buf_parts.prt-code
                                                no-error .
        if not available buf_marking-lines
        then do :
          create buf_marking-lines .
          assign
            buf_marking-lines.mark       = orig_marking-lines.mark
            buf_marking-lines.doc-level  = orig_marking-lines.doc-level
            buf_marking-lines.gds-code   = buf_goods.gds-code
            buf_marking-lines.obj-type   = buf_parts.obj-type
            buf_marking-lines.obj-code   = buf_parts.obj-code
            buf_marking-lines.in-code    = buf_parts.in-code
            buf_marking-lines.out-code   = buf_parts.out-code
            buf_marking-lines.part-code  = buf_parts.part-code
            buf_marking-lines.prt-code   = buf_parts.prt-code
          . 
        end .
        for first buf_marking exclusive-lock where buf_marking.mark = buf_marking-lines.mark 
          and not (available (buf_trn-doc) and buf_trn-doc.ext-doc-type = {&TDEDT_inv}):
            /* BTS-572 - статус марки не меняем для док-тов инвентаризации */
          buf_marking.sts = stsMarkWhenDeleteGoods(if avail buf_trn-doc then buf_trn-doc.doc-code else ?,
                                                   buf_marking-lines.mark).
        end . 
        delete orig_marking-lines .
      end.
      
      delete buf_doc-parts .
    end.

    if p-reserv-pl-code  then do:
/*      if lookup( buf_doc-line.ext-doc-type, {&TDEDT_out_list} ) > 0 then do:*/
/*        assign*/
/*          v-sign = -1.0*/
/*        .*/
/*      end.*/
/*      else do:*/
/*        /* оставляем все как есть */*/
/*        assign*/
/*          v-sign = 1.0*/
/*        .*/
/*        if lookup( buf_doc-line.ext-doc-type, {&TDEDT_in_list} ) = 0 then do:*/
/*          undo, return error substitute( '&1. Тип "&2" не внесен в списки документов уменьшающих(увеличивающих) остатки!', vss-workfile, buf_doc-line.ext-doc-type).*/
/*        end.*/
/*      end.*/

      for each buf_doc-pl
        where buf_doc-pl.out-code = buf_doc-line.doc-code
          and buf_doc-pl.gds-code = buf_goods.gds-code
          and buf_doc-pl.obj-type = buf_doc-line.obj-type
          and buf_doc-pl.obj-code = buf_doc-line.obj-code
      on error undo, return error
      :
        /* вызываем со знаком минус - необходимо снять резервы */
        run trndocrs-pl-gds-accum in this-procedure
          (input buf_doc-pl.pl-code
          ,input 0.0
          ,input (- buf_doc-pl.cli-doc-qnty) /*(- buf_doc-pl.cli-doc-qnty * v-sign)*/
          ,input 0.0
          ,input 0.0
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при изменении зарезервированных количеств trndocrs-pl-gds-accum" skip
            "Документ"  buf_doc-line.doc-code skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
  end.

end.
/* $Workfile: rsrvindl.i $ e n d */