block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: stk-oper.p $
$Archive: bge/stk-oper.p $

Экспорт товарных остатков BGE.

Автор: Хныкин Павел Андреевич
Дата создания: 03/31/06
Author: Pavel Khnykin
Creation date: 03/31/06

Input:

Output:

Параметры:
    p-obj-type              -
    p-obj-code              - объект
    p-date-from             - начальная дата.
    p-date-to               - конечная дата.
    p-fact-order-from       - начальный fact-order.
    p-fact-order-to         - конечный fact-order.
    sOutFile                - имя файла .xm1 для вывода (вызывающая программа создает и по завершении
                              экспорта переименовывает этот файл в .xml. Сделано для синхронизации с
                              блоком импорта во внешней бухгалтерии.
    sLogFile                - полное имя файла для записи событий.
    hEDT                    - handle элемента editor в форме вывода
    hCNT                    - handle элемента fill-in в форме вывода
*/

define input parameter p-obj-type        as char                   no-undo.
define input parameter p-obj-code        as integer                no-undo.
define input parameter p-date-from       as date                   no-undo.
define input parameter p-date-to         as date                   no-undo.
define input parameter p-fact-order-from like ub.stk-tot.fact-order   no-undo.
define input parameter p-fact-order-to   like ub.stk-tot.fact-order   no-undo.
define input parameter sOutFile          as character              no-undo.
define input parameter sLogFile          as character              no-undo.
define input parameter hEDT              as handle                 no-undo.
define input parameter hCNT              as handle                 no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: stk-oper.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/stk-oper.p $":U .
define variable vss-description as character no-undo init "Экспорт товарных остатков BGE.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ bge/bge-xml.i  }

define temp-table temp-good no-undo
    field gds-code                  like ub.goods.gds-code
    field artic                     like ub.goods.artic
    field prod-type                 like ub.goods.prod-type
    field prod-code                 like ub.goods.prod-code
    field gds-name                  like ub.goods.gds-name
    field free-qnty-date            as date
    field free-qnty-time            as integer
    field free-qnty                 as decimal
    field qnty-first                like ub.stk-line.fact-qnty
    field sum-first-rubl            like ub.stk-line.sum-base
    field sum-first-base            like ub.stk-line.sum-base
    field sum-Vat-first-rubl        like ub.stk-line.Vat-rubl
    field sum-Vat-first-base        like ub.stk-line.Vat-base
    field sum-other-first-rubl      like ub.stk-line.other-rubl
    field sum-other-first-base      like ub.stk-line.other-base
    field sum-transport-first-rubl  like ub.stk-line.transport-rubl
    field sum-transport-first-base  like ub.stk-line.transport-base
    field qnty-last                 like ub.stk-line.fact-qnty
    field sum-last-rubl             like ub.stk-line.sum-base
    field sum-last-base             like ub.stk-line.sum-base
    field sum-Vat-last-rubl         like ub.stk-line.Vat-rubl
    field sum-Vat-last-base         like ub.stk-line.Vat-base
    field sum-other-last-rubl       like ub.stk-line.other-rubl
    field sum-other-last-base       like ub.stk-line.other-base
    field sum-transport-last-rubl   like ub.stk-line.transport-rubl
    field sum-transport-last-base   like ub.stk-line.transport-base
    index gd is primary unique gds-code
.

    define variable v-good-counter  as integer       no-undo.
    define variable v-host-code     as integer       no-undo.
    define variable v-base-code     as integer       no-undo.
    define variable v-base-code-okv as integer      no-undo.
    define variable v-r-b-is-base   as logical      no-undo.
    define variable v-today         as date         no-undo.
    define variable v-time          as integer      no-undo.


    define buffer buf_goods     for ub.goods.
    define buffer buf_gds-obj   for ub.gds-obj.
    define buffer buf_stk-line  for ub.stk-line.

do
for buf_goods
  , buf_gds-obj
on error undo, return error
:
output stream stmXMLOut to value(sOutFile + "xm1") ConVERT TARGET "1251" append.

run wp-XMLWriteCNT(hCNT, "").

run wp-xmltagopen( 2, "operation","").
run wp-xmltagput( 3, "codeOperation", "stk", 0 ).
run wp-xmltagput( 3, "store"     , p-obj-type + string(p-obj-code), 0 ).
run wp-xmltagput( 3, "datestart" , string(p-date-from,"99.99.9999"), 0 ).
run wp-xmltagput( 3, "dateend"   , string(p-date-to  ,"99.99.9999"), 0 ).
{ gbl/rbisbase.i
    v-r-b-is-base
}
{ gbl/hostcode.i
    p-obj-type
    p-obj-code
    v-host-code
}
{ gbl/basecode.i
    v-host-code
    v-base-code
}
run get-base-code-okv in this-procedure (
      input v-base-code
    , output v-base-code-okv
).
run wp-xmltagput( 3, "valutCode" , string( v-base-code ), 0 ).
run wp-xmltagput( 3, "valutCodeOKV" , string( v-base-code-okv   ), 0 ).

goods-on-object:
for each buf_gds-obj no-lock
   where buf_gds-obj.obj-type = p-obj-type
     and buf_gds-obj.obj-code = p-obj-code
break by buf_gds-obj.artic
      by buf_gds-obj.prod-type
      by buf_gds-obj.prod-code
:
    for each temp-good
    :
        delete temp-good.
    end.
/*---start--------- Не было движения за этот интервал на этом объекте ---------------------*/
    if  buf_gds-obj.last-doc  < p-date-from
    then do:
            run cur-time in this-procedure (
                  output v-today
                , output v-time
            ).
            create temp-good.
            find first buf_goods no-lock
                    where buf_goods.artic     = buf_gds-obj.artic
                    and buf_goods.prod-type = buf_gds-obj.prod-type
                    and buf_goods.prod-code = buf_gds-obj.prod-code
            no-error.
            if available buf_goods
            then do:
                assign
                    temp-good.gds-name              = buf_goods.gds-name
                .
            end.        /* available buf_goods */
            else do:
                assign
                    temp-good.gds-name              = ""
                .
            end.        /* not ( available buf_goods ) */
            assign
                temp-good.gds-code              = buf_gds-obj.gds-code
                temp-good.artic                 = buf_gds-obj.artic
                temp-good.prod-type             = buf_gds-obj.prod-type
                temp-good.prod-code             = buf_gds-obj.prod-code
                temp-good.free-qnty-date        = v-today
                temp-good.free-qnty-time        = v-time
                temp-good.free-qnty             = buf_gds-obj.free-qnty
            .
            find last buf_stk-line no-lock
                where buf_stk-line.obj-type  = buf_gds-obj.obj-type
                  and buf_stk-line.obj-code  = buf_gds-obj.obj-code
                  and buf_stk-line.artic     = buf_gds-obj.artic
                  and buf_stk-line.prod-type = buf_gds-obj.prod-type
                  and buf_stk-line.prod-code = buf_gds-obj.prod-code
                  and buf_stk-line.sum-type  = {&arh-cost}
                  and buf_stk-line.cat-id    = '##,##'
                  and buf_stk-line.fact-order <= p-fact-order-to
            use-index category
            no-error.
            if available buf_stk-line
            then do:
                assign
                    temp-good.qnty-first                = buf_stk-line.fact-qnty
                    temp-good.qnty-last                 = temp-good.qnty-first

                    temp-good.sum-last-rubl             = buf_stk-line.sum-rubl
                    temp-good.sum-last-base             = buf_stk-line.sum-base
                    temp-good.sum-Vat-last-rubl         = buf_stk-line.Vat-rubl
                    temp-good.sum-Vat-last-base         = buf_stk-line.Vat-base
                    temp-good.sum-other-last-rubl       = buf_stk-line.other-rubl
                    temp-good.sum-other-last-base       = buf_stk-line.other-base
                    temp-good.sum-transport-last-rubl   = buf_stk-line.transport-rubl
                    temp-good.sum-transport-last-base   = buf_stk-line.transport-base

                    temp-good.sum-first-rubl            = temp-good.sum-last-rubl
                    temp-good.sum-first-base            = temp-good.sum-last-base
                    temp-good.sum-Vat-first-rubl        = temp-good.sum-Vat-last-rubl
                    temp-good.sum-Vat-first-base        = temp-good.sum-Vat-last-base
                    temp-good.sum-other-first-rubl      = temp-good.sum-other-last-rubl
                    temp-good.sum-other-first-base      = temp-good.sum-other-last-base
                    temp-good.sum-transport-first-rubl  = temp-good.sum-transport-last-rubl
                    temp-good.sum-transport-first-base  = temp-good.sum-transport-last-base
                .
            end.
            else do:
                assign
                    temp-good.qnty-first                = 0
                    temp-good.qnty-last                 = 0

                    temp-good.sum-last-rubl             = 0
                    temp-good.sum-last-base             = 0
                    temp-good.sum-Vat-last-rubl         = 0
                    temp-good.sum-Vat-last-base         = 0
                    temp-good.sum-other-last-rubl       = 0
                    temp-good.sum-other-last-base       = 0
                    temp-good.sum-transport-last-rubl   = 0
                    temp-good.sum-transport-last-base   = 0

                    temp-good.sum-first-rubl            = 0
                    temp-good.sum-first-base            = 0
                    temp-good.sum-Vat-first-rubl        = 0
                    temp-good.sum-Vat-first-base        = 0
                    temp-good.sum-other-first-rubl      = 0
                    temp-good.sum-other-first-base      = 0
                    temp-good.sum-transport-first-rubl  = 0
                    temp-good.sum-transport-first-base  = 0
                .
            end.
            run write-result in this-procedure (
                input v-r-b-is-base
            ).
            next goods-on-object.
    end.
    if buf_gds-obj.first-doc > p-date-to
    then do:
        next goods-on-object.
    end.
/*---end----------- Не было движения за этот интервал на этом объекте ---------------------*/
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    create temp-good.
    find first buf_goods no-lock
            where buf_goods.artic     = buf_gds-obj.artic
              and buf_goods.prod-type = buf_gds-obj.prod-type
              and buf_goods.prod-code = buf_gds-obj.prod-code
    no-error.
    if available buf_goods
    then do:
        assign
            temp-good.gds-name              = buf_goods.gds-name
        .
    end.        /* available buf_goods */
    else do:
        assign
            temp-good.gds-name              = ""
        .
    end.        /* not ( available buf_goods ) */
    assign
        temp-good.gds-code                  = buf_gds-obj.gds-code
        temp-good.artic                     = buf_gds-obj.artic
        temp-good.prod-type                 = buf_gds-obj.prod-type
        temp-good.prod-code                 = buf_gds-obj.prod-code
        temp-good.free-qnty-date            = v-today
        temp-good.free-qnty-time            = v-time
        temp-good.free-qnty                 = buf_gds-obj.free-qnty

        temp-good.qnty-first                = 0
        temp-good.qnty-last                 = 0

        temp-good.sum-first-rubl            = 0
        temp-good.sum-first-base            = 0
        temp-good.sum-Vat-last-rubl         = 0
        temp-good.sum-Vat-last-base         = 0
        temp-good.sum-other-last-rubl       = 0
        temp-good.sum-other-last-base       = 0
        temp-good.sum-transport-last-rubl   = 0
        temp-good.sum-transport-last-base   = 0

        temp-good.sum-last-rubl             = 0
        temp-good.sum-last-base             = 0
        temp-good.sum-Vat-last-rubl         = 0
        temp-good.sum-Vat-last-base         = 0
        temp-good.sum-other-last-rubl       = 0
        temp-good.sum-other-last-base       = 0
        temp-good.sum-transport-last-rubl   = 0
        temp-good.sum-transport-last-base   = 0
    .
    find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-cost}
          and buf_stk-line.cat-id    = {&root-cat-id}
          and buf_stk-line.fact-order <= p-fact-order-to
    use-index category
    no-error.
    if available buf_stk-line
    then do:
        assign
            temp-good.qnty-last                 = buf_stk-line.fact-qnty
            temp-good.sum-last-rubl             = buf_stk-line.sum-rubl   /*( v-price-sale * stk-line.fact-qnty )*/
            temp-good.sum-last-base             = buf_stk-line.sum-base
            temp-good.sum-Vat-last-rubl         = buf_stk-line.Vat-rubl
            temp-good.sum-Vat-last-base         = buf_stk-line.Vat-base
            temp-good.sum-other-last-rubl       = buf_stk-line.other-rubl
            temp-good.sum-other-last-base       = buf_stk-line.other-base
            temp-good.sum-transport-last-rubl   = buf_stk-line.transport-rubl
            temp-good.sum-transport-last-base   = buf_stk-line.transport-base
        .
    end.

    run wp-XMLWriteLog(sLogFile, 3, "Товар на конец периода: " + string(buf_gds-obj.artic) + " ---- " + string( temp-good.qnty-last ) ).

    find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-cost}
          and buf_stk-line.cat-id    = {&root-cat-id}
          and buf_stk-line.fact-order <= p-fact-order-from
    use-index category
    no-error.
    if available buf_stk-line
    then do:
        assign
            temp-good.qnty-first                 = buf_stk-line.fact-qnty
            temp-good.sum-first-rubl             = buf_stk-line.sum-rubl /*v-price-sale * stk-line.fact-qnty*/
            temp-good.sum-first-base             = buf_stk-line.sum-base
            temp-good.sum-Vat-first-rubl         = buf_stk-line.Vat-rubl
            temp-good.sum-Vat-first-base         = buf_stk-line.Vat-base
            temp-good.sum-other-first-rubl       = buf_stk-line.other-rubl
            temp-good.sum-other-first-base       = buf_stk-line.other-base
            temp-good.sum-transport-first-rubl   = buf_stk-line.transport-rubl
            temp-good.sum-transport-first-base   = buf_stk-line.transport-base
        .
    end.
    run wp-XMLWriteLog(sLogFile, 3, "Товар на начало периода: " + string(buf_gds-obj.artic) + " ---- " + string( temp-good.qnty-first ) ).

    run write-result in this-procedure (
        input v-r-b-is-base
    ).
end.

run wp-xmltagclose(2, "operation").
/*    { rep/repfrm.i off}*/
output stream stmxmlout close.
{ gbl/stopwork.i }

end.



/*==========================================================================*/
procedure write-result :
define input parameter p-r-b-is-base as logical          no-undo.
do
on error undo, return error
:
        if      temp-good.qnty-first <> temp-good.qnty-last
            or  temp-good.sum-first-rubl <> temp-good.sum-last-rubl
            or  temp-good.sum-first-base <> temp-good.sum-last-base  /*Если нет изменений и движения по товару, то нечего и выводить*/
        then do:
            process events.
            assign
                v-good-counter = v-good-counter + 1
            .
            run wp-xmltagopen( input 3, input "good", input "" ).
            run wp-xmltagput( input 4, input "code"                 , input string( temp-good.gds-code                  ) , input 0 ).
            run wp-xmltagput( input 4, input "artic"                , input string( temp-good.artic                     ) , input 0 ).
            run wp-xmltagput( input 4, input "prodType"             , input string( temp-good.prod-type                 ) , input 0 ).
            run wp-xmltagput( input 4, input "prodCode"             , input string( temp-good.prod-code                 ) , input 0 ).
            run wp-xmltagput( input 4, input "name"                 , input string( temp-good.gds-name                  ) , input 0 ).
            run wp-xmltagput( input 4, input "freeQntyDate"         , input string( temp-good.free-qnty-date,"99.99.9999"   ) , input 0 ).
            run wp-xmltagput( input 4, input "freeQntyTime"         , input string( temp-good.free-qnty-time,"hh:mm:ss"     ) , input 0 ).
            run wp-xmltagput( input 4, input "freeQnty"             , input string( temp-good.free-qnty                     ) , input 0 ).
            run wp-xmltagput( input 4, input "qntystart"            , input string( temp-good.qnty-first                ) , input 0 ).
            run wp-xmltagput( input 4, input "sumstartR"            , input string( temp-good.sum-first-rubl            ) , input 0 ).
            run wp-xmltagput( input 4, input "sumstartB"            , input string( temp-good.sum-first-base            ) , input 0 ).
            run wp-xmltagput( input 4, input "sumstartVatR"         , input string( temp-good.sum-Vat-first-rubl        ) , input 0 ).
            run wp-xmltagput( input 4, input "sumstartVatB"         , input string( temp-good.sum-Vat-first-base        ) , input 0 ).
            run wp-xmltagput( input 4, input "sumstartotherR"       , input string( temp-good.sum-other-first-rubl      ) , input 0 ).
            run wp-xmltagput( input 4, input "sumstartotherB"       , input string( temp-good.sum-other-first-base      ) , input 0 ).
            run wp-xmltagput( input 4, input "sumstartTransportR"   , input string( temp-good.sum-transport-first-rubl  ) , input 0 ).
            run wp-xmltagput( input 4, input "sumstartTransportB"   , input string( temp-good.sum-transport-first-base  ) , input 0 ).

            run wp-xmltagput( input 4, input "qntyend"              , input string( temp-good.qnty-last                 ) , input 0 ).
            run wp-xmltagput( input 4, input "sumendR"              , input string( temp-good.sum-last-rubl             ) , input 0 ).
            run wp-xmltagput( input 4, input "sumendB"              , input string( temp-good.sum-last-base             ) , input 0 ).
            run wp-xmltagput( input 4, input "sumendVatR"           , input string( temp-good.sum-Vat-last-rubl         ) , input 0 ).
            run wp-xmltagput( input 4, input "sumendVatB"           , input string( temp-good.sum-Vat-last-base         ) , input 0 ).
            run wp-xmltagput( input 4, input "sumendotherR"         , input string( temp-good.sum-other-last-rubl       ) , input 0 ).
            run wp-xmltagput( input 4, input "sumendotherB"         , input string( temp-good.sum-other-last-base       ) , input 0 ).
            run wp-xmltagput( input 4, input "sumendTransportR"     , input string( temp-good.sum-transport-last-rubl   ) , input 0 ).
            run wp-xmltagput( input 4, input "sumendTransportB"     , input string( temp-good.sum-transport-last-base   ) , input 0 ).
            run wp-xmltagclose( input 3, input "good" ).

            if v-good-counter modulo 100 = 0
            then do:
                run wp-XMLWriteCnt( hcnt, string( v-good-counter ) ).
                process events.
            end.
        end.
/*            { rep/repfrm.i disp v-good-counter}*/
end.
end procedure. /* eval-sum-and-write-result */




/*==========================================================================*/
procedure get-base-code-okv :
define input parameter p-base-code          as integer          no-undo.
define output parameter p-base-code-okv     as integer          no-undo.

    define buffer buf_currency      for ub.currency.
do
for buf_currency
on error undo, return error
:
    find first buf_currency no-lock
         where buf_currency.curr-code = p-base-code
    .
    assign
        p-base-code-okv = buf_currency.okv-code
    .
end.
end procedure. /* get-valutCode */