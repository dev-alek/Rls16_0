/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Резервирование и снятие резервов по одной партии

Автор: Чернова Светлана Александровна
Дата создания: 02/14/07
Author: Svetlana Chernova
Creation date: 02/14/07

create: Перваков Михаил Сергеевич
Дата создания: 04/26/01

                   Свободная зона            Архив                Расходная зона

                    buf_parts              buf_parts                buf_parts
                   out-code =              out-code =               out-code =
                   {&free-code}        buf_trn-doc.doc-code       {&output-code}
                         |              l-edit-reserv = true           |
                         \                      |                      /
                          \---------------------+---------------------/
                                                |
                                                |
                                               \ /
                                                '
Инвентаризация:
  chg-qnty < 0       unrsrv-parts   ----->>  buf_parts     ----->>       rsrv-parts
  chg-qnty > 0        rsrv-parts    <<-----  buf_parts     <<-----       unrsrv-parts
Расход, Списание:                                                                                               '
  chg-qnty < 0                               buf_parts     ----->>       rsrv-parts
  chg-qnty > 0                               buf_parts     <<-----       unrsrv-parts
Возврат:
  chg-qnty < 0       unrsrv-parts   ----->>  buf_parts
  chg-qnty > 0        rsrv-parts    <<-----  buf_parts

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ trg/markchng.i }

procedure partrsrv :

  define input parameter  p-chg-qnty      as decimal   no-undo .
  define input parameter  p-goods-serial  as logical   no-undo .
  define input parameter  p-goods-twounit as logical   no-undo .
  define input parameter  p-unreserv-only as logical   no-undo .
  define parameter buffer buf_orig_parts  for ub.parts .
  define parameter buffer buf_trn-doc     for ub.trn-doc .
  define output parameter p-real-chg-qnty as decimal   no-undo .
  define output parameter p-parts-recid   as recid     no-undo .
  define input  parameter p-mark          as character  no-undo .

  define variable vss-description as character no-undo init "$Workfile$ Резервирование и снятие резервов по одной партии".

  define buffer buf_parts  for ub.parts .
  define buffer rsrv-parts for ub.parts .
  define buffer unrsrv-parts for ub.parts .
  define buffer buf_parts-attr for ub.parts-attr .
  
  define buffer free_marking-lines for ub.marking-lines .

  define variable lok                as logical   no-undo .
  define variable v-sign-chg-qnty    as integer   no-undo .
  define variable v-sign-rsrv-qnty   as integer   no-undo .
  define variable v-rsrv-qnty        as decimal   no-undo .
  define variable v-orig-unrsrv-code as character no-undo .
  define variable v-new-rsrv-code    as character no-undo .
  define variable v-new-unrsrv-code  as character no-undo .
  define variable v-unrsrv-qnty      as decimal   no-undo .

  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-izlcstpr        as logical no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define variable part-key-rec      as character no-undo .
  
  define variable v-part-code-int   as integer no-undo .
  define variable v-old-part-code   as character no-undo .
  define variable v-part-gds-code   as integer   no-undo .
  
  { gbl/objsrv.i }
  
  do transaction
  on error undo, return error
  :
    if buf_trn-doc.ext-doc-type = {&TDEDT_Inv}
    then do :
        delete object v-tth no-error.
        run adm/shattri.p (
           input "get":U
          ,input buf_orig_parts.obj-type
          ,input buf_orig_parts.obj-code
          ,input {&attr-inv-obj}
          ,input  "izlcstpr"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-izlcstpr
          ,output v-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          delete object v-tth no-error.      
        if error-status:error then do:
          v-izlcstpr = false .
/*          message "Ошибка при получение параметра izlcstpr"*/
/*          view-as alert-box.                               */
/*          return error.                                    */
        end.  
    end.
    else do :
        v-izlcstpr = false .
    end.

    assign
      p-parts-recid = ?
    .
    if p-chg-qnty = 0 then do:
      assign
        p-parts-recid = recid(buf_orig_parts)
      .
      return .
    end.

    assign
      v-sign-chg-qnty = 0
    .
    if p-chg-qnty < 0 then do:
      assign
        v-sign-chg-qnty = -1
      .
    end.
    if p-chg-qnty > 0 then do:
      assign
        v-sign-chg-qnty = 1
      .
    end.
    assign
      v-sign-rsrv-qnty = v-sign-chg-qnty
    .
    if lookup(buf_trn-doc.doc-type, {&expense_write-off}) > 0 then do:
      assign
        v-sign-rsrv-qnty = - v-sign-chg-qnty
      .
    end.

    /* находим резервную партию по документу */
    run partcopy in this-procedure
      (input  false                /* p-free-output-copy */
      ,input  buf_trn-doc.doc-code /* p-out-code         */
      ,buffer buf_orig_parts       /* buf_orig_parts     */
      ,buffer buf_parts            /* buf_parts          */
      ,input  p-mark
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании партии" skip
        "Объект" buf_orig_parts.obj-type buf_orig_parts.obj-code skip
        "Артикул" buf_orig_parts.artic buf_orig_parts.prod-type buf_orig_parts.prod-code skip
        "Партия" buf_orig_parts.in-code buf_orig_parts.part-code skip
        "Резерв" buf_trn-doc.doc-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    if buf_parts.in-code = buf_parts.out-code then do:
      assign
        v-rsrv-qnty = abs(p-chg-qnty)
      .

      /* если происходит уменьшение зарезервированной партии */
      /* не позволяем сделать партию с отрицательными количествами */
      if buf_trn-doc.doc-type <> {&inventory} then do:
        if buf_parts.qnty < 0
        or buf_parts.fact-qnty < 0 then do:
          message
            vss-workfile vss-revision vss-description skip
            "Резервирование невозможно" skip
            "Партия зарезервированная за обычным документом имеет отрицательное количество" skip
            view-as alert-box error .
          undo, return error .
        end.
        if v-sign-rsrv-qnty < 0 then do:
          assign
            v-rsrv-qnty = min(abs(buf_parts.qnty), v-rsrv-qnty)
          .
        end.
      end.

      assign
        buf_parts.qnty      = buf_parts.qnty      + v-rsrv-qnty * v-sign-rsrv-qnty
        buf_parts.fact-qnty = buf_parts.fact-qnty + v-rsrv-qnty * v-sign-rsrv-qnty
      .
      if p-goods-twounit = true
      then do:
        if buf_parts.qnty < 0 then do:
          message
            "Порожденная партия ювелирных изделий не может иметь отрицательное количество" skip
            "Количество" buf_parts.qnty skip
            view-as alert-box error .
          undo, return error .
        end.

        if buf_parts.qnty = 0 then do:
          assign
            buf_parts.cli-qnty = 0
          .
        end.

        if  buf_parts.qnty <> 0
        and buf_parts.cli-qnty <> 1
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Порожденная партия ювелирных изделий должна иметь определенное клиентское количество" skip
            "qnty" buf_parts.qnty skip
            "cli-qnty" buf_parts.cli-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      else do:
        if buf_parts.cli-base-rate <> 0
        then do:
          assign
            buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
          .
        end.
        else do:
          assign
            buf_parts.cli-qnty = 0
          .
        end.
      end.

      assign
        p-chg-qnty      = p-chg-qnty      - v-rsrv-qnty * v-sign-chg-qnty
        p-real-chg-qnty = p-real-chg-qnty + v-rsrv-qnty * v-sign-chg-qnty
      .
      /* отладочные сообщения */
/*      assign*/
/*        lok = false*/
/*      .*/
/*      message*/
/*        "edit in-code = out-code" skip*/
/*        "buf_parts.qnty"     buf_parts.qnty skip*/
/*        "buf_parts.cli-qnty" buf_parts.cli-qnty skip*/
/*        "p-chg-qnty"         p-chg-qnty skip*/
/*        "p-real-chg-qnty"    p-real-chg-qnty skip*/
/*        view-as alert-box question button yes-no update lok .*/
/*      if lok <> true then do:*/
/*        undo, return error .*/
/*      end.*/
    end.
    else do:
      assign
        v-orig-unrsrv-code =  { trg/partsprm.i "rsrv-code" buf_trn-doc. buf_parts.qnty }
        v-new-rsrv-code    =  ( if p-chg-qnty > 0
                                then {&free-code}
                                else {&output-code}
                              )
        v-new-unrsrv-code  =  ( if p-chg-qnty > 0
                                then {&output-code}
                                else {&free-code}
                              )
      .

      /* отладочные сообщения */
/*      assign*/
/*        lok = false*/
/*      .*/
/*      message*/
/*        "v-orig-unrsrv-code" v-orig-unrsrv-code skip*/
/*        "v-new-rsrv-code"    v-new-rsrv-code    skip*/
/*        "v-new-unrsrv-code"  v-new-unrsrv-code  skip*/
/*        "v-sign-rsrv-qnty"   v-sign-rsrv-qnty   skip*/
/*        "v-sign-chg-qnty"    v-sign-chg-qnty    skip*/
/*        view-as alert-box question button yes-no update lok .*/
/*      if lok <> true then do:*/
/*        undo, return error .*/
/*      end.*/

      /* разрезервируем ранее зарезервированное количество */
      if v-new-rsrv-code = v-orig-unrsrv-code then do:

        assign
          v-rsrv-qnty = min(abs(buf_parts.qnty), abs(p-chg-qnty) )
        .
        
        if v-izlcstpr and buf_parts.out-code <> v-new-rsrv-code and p-chg-qnty > 0
        then do :
            find first rsrv-parts exclusive-lock
                where rsrv-parts.obj-type  = buf_parts.obj-type
                  and rsrv-parts.obj-code  = buf_parts.obj-code
                  and rsrv-parts.artic     = buf_parts.artic
                  and rsrv-parts.prod-type = buf_parts.prod-type
                  and rsrv-parts.prod-code = buf_parts.prod-code
                  and rsrv-parts.in-code   = buf_parts.out-code
                  and rsrv-parts.out-code  = v-new-rsrv-code
                  and rsrv-parts.part-code = buf_parts.part-code
                no-error.
        end.  
        if not available rsrv-parts
        then do :
            run partcopy in this-procedure
              (input  true            /* p-free-output-copy */
              ,input  v-new-rsrv-code /* p-out-code         */
              ,buffer buf_parts       /* buf_orig_parts     */
              ,buffer rsrv-parts      /* buf_parts          */
              ,input p-mark
              ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании партии" skip
                "Объект" buf_parts.obj-type buf_parts.obj-code skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "Партия" buf_parts.in-code buf_parts.part-code skip
                "Резерв" v-new-rsrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
        end.    
        if not v-izlcstpr or (v-izlcstpr and p-chg-qnty > 0)
        then
        assign
          rsrv-parts.qnty      = rsrv-parts.qnty      + v-rsrv-qnty
          rsrv-parts.fact-qnty = rsrv-parts.fact-qnty + v-rsrv-qnty
        .
        if p-goods-twounit = true then do:
          assign
            rsrv-parts.cli-qnty = rsrv-parts.cli-qnty + abs(buf_parts.cli-qnty)
          .
        end.
        else do:
          if rsrv-parts.cli-base-rate <> 0
          then do:
            assign
              rsrv-parts.cli-qnty = rsrv-parts.fact-qnty / rsrv-parts.cli-base-rate
            .
          end.
          else do:
            assign
              rsrv-parts.cli-qnty = 0
            .
          end.
        end.

        assign
          buf_parts.qnty      = buf_parts.qnty      + v-rsrv-qnty * v-sign-rsrv-qnty
          buf_parts.fact-qnty = buf_parts.fact-qnty + v-rsrv-qnty * v-sign-rsrv-qnty
        .
        if p-goods-twounit = true then do:
          assign
            buf_parts.cli-qnty = 0
          .
        end.
        else do:
          if buf_parts.cli-base-rate <> 0
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
            .
          end.
          else do:
            assign
              buf_parts.cli-qnty = 0
            .
          end.
        end.

        assign
          p-chg-qnty      = p-chg-qnty      - v-rsrv-qnty * v-sign-chg-qnty
          p-real-chg-qnty = p-real-chg-qnty + v-rsrv-qnty * v-sign-chg-qnty
        .

        /* отладочные сообщения */
/*        assign*/
/*          lok = false*/
/*        .*/
/*        message*/
/*          "rsrv" skip*/
/*          "v-rsrv-qnty"        v-rsrv-qnty skip*/
/*          "buf_parts.qnty"     buf_parts.qnty skip*/
/*          "buf_parts.cli-qnty" buf_parts.cli-qnty skip*/
/*          "p-chg-qnty"         p-chg-qnty skip*/
/*          "p-real-chg-qnty"    p-real-chg-qnty skip*/
/*          view-as alert-box question button yes-no update lok .*/
/*        if lok <> true then do:*/
/*          undo, return error .*/
/*        end.*/
      end.

      /* производим резервирование товара */
      if p-chg-qnty <> 0
      and (
           (buf_trn-doc.doc-type = {&inventory}
           and p-unreserv-only = false
           )
          or v-new-unrsrv-code = v-orig-unrsrv-code
          )
      then do:
        
        if v-izlcstpr and buf_parts.out-code <> v-new-unrsrv-code and p-chg-qnty < 0
        then do :
            find first unrsrv-parts exclusive-lock
                where unrsrv-parts.obj-type  = buf_parts.obj-type
                  and unrsrv-parts.obj-code  = buf_parts.obj-code
                  and unrsrv-parts.artic     = buf_parts.artic
                  and unrsrv-parts.prod-type = buf_parts.prod-type
                  and unrsrv-parts.prod-code = buf_parts.prod-code
                  and unrsrv-parts.in-code   = buf_parts.in-code
                  and unrsrv-parts.out-code  = v-new-unrsrv-code
                  and unrsrv-parts.part-code = buf_parts.part-code
                no-error.
        end.  
        if not available unrsrv-parts
        then do :
            run partcopy in this-procedure
              (input  true              /* p-free-output-copy */
              ,input  v-new-unrsrv-code /* p-out-code         */
              ,buffer buf_parts         /* buf_orig_parts     */
              ,buffer unrsrv-parts      /* buf_parts          */
              ,input  p-mark
              ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании партии" skip
                "Объект" buf_parts.obj-type buf_parts.obj-code skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "Партия" buf_parts.in-code buf_parts.part-code skip
                "Резерв" v-new-rsrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
        end.
        assign
          v-unrsrv-qnty = min( (if unrsrv-parts.qnty > 0
                                then unrsrv-parts.qnty
                                else 0
                                )
                          , abs(p-chg-qnty))
        .

        assign
          buf_parts.qnty      = buf_parts.qnty      + v-unrsrv-qnty * v-sign-rsrv-qnty
          buf_parts.fact-qnty = buf_parts.fact-qnty + v-unrsrv-qnty * v-sign-rsrv-qnty
        .
        if p-goods-twounit = true then do:
          assign
            buf_parts.cli-qnty = buf_parts.cli-qnty + unrsrv-parts.cli-qnty * v-sign-rsrv-qnty
          .
        end.
        else do:
          if buf_parts.cli-base-rate <> 0
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
            .
          end.
          else do:
            assign
              buf_parts.cli-qnty = 0
            .
          end.
        end.
        
        if num-entries(buf_parts.part-code, "_") = 2
        and buf_parts.qnty > 0
        and buf_parts.out-code <> {&free-code}
        and buf_parts.out-code <> {&output-code}
        and buf_trn-doc.ext-doc-type = {&TDEDT_Inv}
        then do :
          v-old-part-code = buf_parts.part-code .
          v-part-code-int = 0 .
          
          buf_parts.part-code = entry(2, buf_parts.part-code, "_") no-error .
          do while error-status:error :
            v-part-code-int = v-part-code-int + 1 .
            buf_parts.part-code = string(integer(entry(2, buf_parts.part-code, "_")) + v-part-code-int) no-error .
          end .
          
          { gbl/gds-code.i
            buf_parts.artic
            buf_parts.prod-type
            buf_parts.prod-code
            v-part-gds-code
          }
          
          find first buf_parts-attr exclusive-lock where buf_parts-attr.in-code   = buf_parts.in-code
                                                     and buf_parts-attr.gds-code  = v-part-gds-code
                                                     and buf_parts-attr.part-code = buf_parts.part-code
                                                     no-error.
          if not available buf_parts-attr then do:
            find first ub.parts-attr no-lock where ub.parts-attr.in-code   = buf_parts.in-code
                                               and ub.parts-attr.gds-code  = v-part-gds-code
                                               and ub.parts-attr.part-code = v-old-part-code
                                               no-error.
            if available ub.parts-attr then do:
              create buf_parts-attr.
              buffer-copy ub.parts-attr to buf_parts-attr
              assign
                buf_parts-attr.part-code = buf_parts.part-code
              .
            end.
          end.
        end .

        if not v-izlcstpr or (v-izlcstpr and p-chg-qnty < 0)
        then
        assign
          unrsrv-parts.qnty      = unrsrv-parts.qnty      - v-unrsrv-qnty
          unrsrv-parts.fact-qnty = unrsrv-parts.fact-qnty - v-unrsrv-qnty
        .
        if p-goods-twounit = true
        then do:
          assign
            unrsrv-parts.cli-qnty = 0
          .
        end.
        else do:
          if unrsrv-parts.cli-base-rate <> 0
          then do:
            assign
              unrsrv-parts.cli-qnty = unrsrv-parts.fact-qnty / unrsrv-parts.cli-base-rate
            .
          end.
          else do:
            assign
              unrsrv-parts.cli-qnty = 0
            .
          end.

        end.

        assign
          p-chg-qnty      = p-chg-qnty      - v-unrsrv-qnty * v-sign-chg-qnty
          p-real-chg-qnty = p-real-chg-qnty + v-unrsrv-qnty * v-sign-chg-qnty
        .
        /* отладочные сообщения */
/*        assign*/
/*          lok = false*/
/*        .*/
/*        message*/
/*          "unrsrv" skip*/
/*          "v-unrsrv-qnty"      v-unrsrv-qnty skip*/
/*          "buf_parts.qnty"     buf_parts.qnty skip*/
/*          "buf_parts.cli-qnty" buf_parts.cli-qnty skip*/
/*          "p-chg-qnty"         p-chg-qnty skip*/
/*          "p-real-chg-qnty"    p-real-chg-qnty skip*/
/*          view-as alert-box question button yes-no update lok .*/
/*        if lok <> true then do:*/
/*          undo, return error .*/
/*        end.*/
      end.
    end.

    if available unrsrv-parts
    and unrsrv-parts.qnty      = 0
    and unrsrv-parts.fact-qnty = 0
    then do:
      if p-goods-twounit = true then do:
        if unrsrv-parts.cli-qnty <> 0 then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении партии" skip
            "Объект" unrsrv-parts.obj-type unrsrv-parts.obj-code skip
            "Артикул" unrsrv-parts.artic unrsrv-parts.prod-type unrsrv-parts.prod-code skip
            "Партия" unrsrv-parts.in-code unrsrv-parts.part-code skip
            "Резерв" unrsrv-parts.out-code skip
            "qnty" unrsrv-parts.qnty skip
            "fact-qnty" unrsrv-parts.fact-qnty skip
            "cli-qnty" unrsrv-parts.cli-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.

      define variable origpart-key-rec as character no-undo .
      define buffer buf_gen-attr for ub.gen-attr .
      define buffer buf1_gen-attr for ub.gen-attr .
      run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                                        ,input (buffer unrsrv-parts:handle)
                                        ,output part-key-rec).
      run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                                        ,input (buffer buf_parts:handle)
                                        ,output origpart-key-rec).

      if  v-new-rsrv-code <> {&output-code} then do:
      /*Меняем free-code на номер документа*/
        for each ub.gen-attr no-lock where ub.gen-attr.table-name = {&excise-mark}
                                            and ub.gen-attr.p-key =  part-key-rec :
          find first buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}
                                            and buf_gen-attr.p-key =  origpart-key-rec
                                            and buf_gen-attr.attr-code = ub.gen-attr.attr-code no-error .
        if not available (buf_gen-attr) then do:
            create buf_gen-attr .
            buffer-copy ub.gen-attr to buf_gen-attr
            assign
                buf_gen-attr.p-key = origpart-key-rec
            no-error .                                  
        end.                                                 
          find first buf1_gen-attr no-lock where recid (buf1_gen-attr) = recid (ub.gen-attr).
          find current buf1_gen-attr exclusive-lock.                                                   
          delete buf1_gen-attr .
      end.
      end.    
/*      else do:                                                                         */
/*      for each ub.gen-attr exclusive-lock where ub.gen-attr.table-name = {&excise-mark}*/
/*                                            and ub.gen-attr.p-key =  part-key-rec :    */
/*         delete ub.gen-attr .                                                          */
/*                                                                                       */
/*      end.                                                                             */
/*      end.                                                                             */
      define variable v-gds-code as integer   no-undo .

      { gbl/gds-code.i
        unrsrv-parts.artic
        unrsrv-parts.prod-type
        unrsrv-parts.prod-code
        v-gds-code
        no-error
      }
      
      for each ub.marking-lines where ub.marking-lines.gds-code = v-gds-code
        and ub.marking-lines.obj-type = unrsrv-parts.obj-type
        and ub.marking-lines.obj-code = unrsrv-parts.obj-code
        and ub.marking-lines.in-code = unrsrv-parts.in-code
        and ub.marking-lines.out-code = unrsrv-parts.out-code
        and ub.marking-lines.part-code = unrsrv-parts.part-code
        and ub.marking-lines.prt-code = unrsrv-parts.prt-code:
          delete ub.marking-lines.
      end.
      delete unrsrv-parts .
    end.
    else do:
      assign
        p-parts-recid = recid(unrsrv-parts)
      .
    end.

    if available rsrv-parts
    and rsrv-parts.qnty      = 0
    and rsrv-parts.fact-qnty = 0
    then do:
      if p-goods-twounit = true then do:
        if rsrv-parts.cli-qnty <> 0 then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении партии" skip
            "Объект" rsrv-parts.obj-type rsrv-parts.obj-code skip
            "Артикул" rsrv-parts.artic rsrv-parts.prod-type rsrv-parts.prod-code skip
            "Партия" rsrv-parts.in-code rsrv-parts.part-code skip
            "Резерв" rsrv-parts.out-code skip
            "qnty" rsrv-parts.qnty skip
            "fact-qnty" rsrv-parts.fact-qnty skip
            "cli-qnty" rsrv-parts.cli-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                                        ,input (buffer rsrv-parts:handle)
                                        ,output part-key-rec).                                
      for each ub.gen-attr no-lock where ub.gen-attr.table-name = {&excise-mark}
                                            and ub.gen-attr.p-key =  part-key-rec :
            find first buf_gen-attr no-lock where recid (buf_gen-attr) = recid (ub.gen-attr).
            find current buf_gen-attr exclusive-lock.
            delete buf_gen-attr.                               
      end.

      { gbl/gds-code.i
        rsrv-parts.artic
        rsrv-parts.prod-type
        rsrv-parts.prod-code
        v-gds-code
        no-error
      }
      
      for each ub.marking-lines where ub.marking-lines.gds-code = v-gds-code
        and ub.marking-lines.obj-type = rsrv-parts.obj-type
        and ub.marking-lines.obj-code = rsrv-parts.obj-code
        and ub.marking-lines.in-code = rsrv-parts.in-code
        and ub.marking-lines.out-code = rsrv-parts.out-code
        and ub.marking-lines.part-code = rsrv-parts.part-code
        and ub.marking-lines.prt-code = rsrv-parts.prt-code:
          delete ub.marking-lines.
      end.
      
      delete rsrv-parts .
    end.
    else do:
      assign
        p-parts-recid = recid(rsrv-parts)
      .
    end.

    if  buf_parts.qnty      = 0
    and buf_parts.fact-qnty = 0 then do:
      if p-goods-twounit = true then do:
        if buf_parts.cli-qnty <> 0 then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении партии" skip
            "Объект" buf_parts.obj-type buf_parts.obj-code skip
            "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
            "Партия" buf_parts.in-code buf_parts.part-code skip
            "Резерв" buf_parts.out-code skip
            "qnty" buf_parts.qnty skip
            "fact-qnty" buf_parts.fact-qnty skip
            "cli-qnty" buf_parts.cli-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.

      define variable part-key-rec_free as character no-undo .
      run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
                                            
      for each ub.gen-attr no-lock where ub.gen-attr.table-name = {&excise-mark}
                                            and ub.gen-attr.p-key =  part-key-rec :
        if (entry (8,part-key-rec,{&delim-key}) <> {&free-code}) and (entry (8,part-key-rec,{&delim-key}) <> entry (7,part-key-rec,{&delim-key})) then do: /*расход*/
        part-key-rec_free = part-key-rec .     
        entry (8,part-key-rec_free,{&delim-key}) = {&free-code} .

        find first buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}
                    and buf_gen-attr.attr-code = ub.gen-attr.attr-code
                    and num-entries (buf_gen-attr.p-key, {&delim-key}) >= 8
                    and entry(8, buf_gen-attr.p-key, {&delim-key}) = {&free-code}
                    no-error .
                if not available (buf_gen-attr) then 
                do:
                    create buf_gen-attr.
                    buffer-copy ub.gen-attr except ub.gen-attr.p-key to buf_gen-attr .
                    assign
                        buf_gen-attr.p-key = part-key-rec_free
                        . 
                end.  
                                               
        end.                                                    
        find first buf1_gen-attr no-lock where recid (buf1_gen-attr) = recid (ub.gen-attr).
        find current buf1_gen-attr exclusive-lock.                                                   
        delete buf1_gen-attr .
            
      end.
      release buf_gen-attr.
      
      { gbl/gds-code.i
        buf_parts.artic
        buf_parts.prod-type
        buf_parts.prod-code
        v-gds-code
        no-error
      }
      
      for each ub.marking-lines where ub.marking-lines.gds-code = v-gds-code
        and ub.marking-lines.obj-type = buf_parts.obj-type
        and ub.marking-lines.obj-code = buf_parts.obj-code
        and ub.marking-lines.in-code = buf_parts.in-code
        and ub.marking-lines.out-code = buf_parts.out-code
        and ub.marking-lines.part-code = buf_parts.part-code
        and ub.marking-lines.prt-code = buf_parts.prt-code:
          if chg-qnty < 0
          then do :
            for first ub.marking exclusive-lock where ub.marking.mark = ub.marking-lines.mark :
              find first free_marking-lines no-lock where free_marking-lines.mark       = ub.marking-lines.mark
                                                      and free_marking-lines.gds-code   = ub.marking-lines.gds-code
                                                      and free_marking-lines.obj-type   = ub.marking-lines.obj-type
                                                      and free_marking-lines.obj-code   = ub.marking-lines.obj-code
                                                      and free_marking-lines.in-code    = ub.marking-lines.in-code
                                                      and free_marking-lines.out-code   = {&free-code}
                                                      and free_marking-lines.part-code  = ub.marking-lines.part-code
                                                      and free_marking-lines.prt-code   = ub.marking-lines.prt-code
                                                      no-error .
              if not available free_marking-lines
              then do :
                create free_marking-lines .
                assign
                  free_marking-lines.mark       = ub.marking-lines.mark
                  free_marking-lines.doc-level  = ub.marking-lines.doc-level
                  free_marking-lines.gds-code   = ub.marking-lines.gds-code
                  free_marking-lines.obj-type   = ub.marking-lines.obj-type
                  free_marking-lines.obj-code   = ub.marking-lines.obj-code
                  free_marking-lines.in-code    = ub.marking-lines.in-code
                  free_marking-lines.out-code   = {&free-code}
                  free_marking-lines.part-code  = ub.marking-lines.part-code
                  free_marking-lines.prt-code   = ub.marking-lines.prt-code
                .
              end .
              ub.marking.sts = stsMarkWhenDeleteGoods(if avail buf_trn-doc then buf_trn-doc.doc-code else ?,
                                                      ub.marking-lines.mark).
            end .
          end .
          delete ub.marking-lines.
      end.
      
      delete buf_parts .
    end.
    else do:
      /* определяем поле rsrv-free */
      assign
        buf_parts.rsrv-free = { trg/partsprm.i "part-rsrv-free" buf_trn-doc. buf_parts.qnty }
      .

      /* проверяем знаки в зарезервированной партии */
      /* отрицательные партии допускаются только для документов инвентаризации */
      if  buf_trn-doc.doc-type <> {&inventory}
      and (buf_parts.qnty < 0
           or buf_parts.fact-qnty < 0
          )
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Партии с отрицательным количеством допустимы" skip
          "только для документа инвентаризации" skip
          "Объект" buf_parts.obj-type buf_parts.obj-code skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Партия" buf_parts.in-code buf_parts.part-code skip
          "Резерв" buf_trn-doc.doc-code skip
          "Количество по документу" buf_parts.qnty skip
          "Фактическое количество" buf_parts.fact-qnty skip
          view-as alert-box error .
        undo, return error .
      end.

      /* встаем на зарезервированную партию */
      assign
        p-parts-recid = recid(buf_parts)
      .
    end.
  end.

end procedure. /* partrsrv */


procedure partrsrv-need-rsrv :

  define input  parameter p-parts-in-code   as character no-undo .
  define input  parameter p-parts-out-code  as character no-undo .
  define output parameter p-need-rsrv-parts as logical   no-undo .

  do
  on error undo, return error return-value
  :

    if p-parts-out-code <> p-parts-in-code
    then do:
      assign
        p-need-rsrv-parts = true
      .
    end.
    else do:
      assign
        p-need-rsrv-parts = false
      .
    end.
  end.

end procedure. /* partrsrv-need-rsrv */

/* $Workfile$ e n d */