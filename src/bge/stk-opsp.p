block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: stk-opsp.p $
$Archive: bge/stk-opsp.p $

Экспорт товарных остатков BGE по поставщикам

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
define input parameter p-obj-type        as character              no-undo.
define input parameter p-obj-code        as integer                no-undo.
define input parameter p-date-from       as date                   no-undo.
define input parameter p-date-to         as date                   no-undo.
define input parameter p-fact-order-from like ub.stk-tot.fact-order   no-undo.
define input parameter p-fact-order-to   like ub.stk-tot.fact-order   no-undo.
define input parameter soutfile          as character              no-undo.
define input parameter slogfile          as character              no-undo.
define input parameter hedt              as handle                 no-undo.
define input parameter hcnt              as handle                 no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: stk-opsp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/stk-opsp.p $":U .
define variable vss-description as character no-undo init "Экспорт товарных остатков BGE по поставщикам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ bge/bge-xml.i }

&SCOP FRAME-NAME F-DUMMY

    def temp-table temp-good no-undo
        field gds-code                  like ub.goods.gds-code
        field supp-type                 like ub.stk-supp-line.cli-type
        field supp-code                 like ub.stk-supp-line.cli-code
        field artic                     like ub.goods.artic
        field prod-type                 like ub.goods.prod-type
        field prod-code                 like ub.goods.prod-code
        field gds-name                  like ub.goods.gds-name
        field qnty-first                like ub.stk-supp-line.fact-qnty
        field sum-first-rubl            like ub.stk-supp-line.sum-rubl
        field sum-first-base            like ub.stk-supp-line.sum-base
        field sum-VAT-first-rubl        like ub.stk-supp-line.VAT-rubl
        field sum-VAT-first-base        like ub.stk-supp-line.VAT-base
        field sum-other-first-rubl      like ub.stk-supp-line.other-rubl
        field sum-other-first-base      like ub.stk-supp-line.other-base
        field sum-transport-first-rubl  like ub.stk-supp-line.transport-rubl
        field sum-transport-first-base  like ub.stk-supp-line.transport-base
        field qnty-last                 like ub.stk-supp-line.fact-qnty
        field sum-last-rubl             like ub.stk-supp-line.sum-rubl
        field sum-last-base             like ub.stk-supp-line.sum-base
        field sum-VAT-last-rubl         like ub.stk-supp-line.VAT-rubl
        field sum-VAT-last-base         like ub.stk-supp-line.VAT-base
        field sum-other-last-rubl       like ub.stk-supp-line.other-rubl
        field sum-other-last-base       like ub.stk-supp-line.other-base
        field sum-transport-last-rubl   like ub.stk-supp-line.transport-rubl
        field sum-transport-last-base   like ub.stk-supp-line.transport-base
        index pi is primary unique gds-code supp-type supp-code
    .

    define variable v-good-counter  as integer       no-undo.
    define variable v-host-code     as integer       no-undo.
    define variable v-base-code     as integer       no-undo.
define variable v-base-code-okv as integer       no-undo.

    define buffer buf_goods         for ub.goods.
    define buffer buf_gds-obj       for ub.gds-obj.
    define buffer buf_clients       for ub.clients.
    define buffer buf_stk-supp-line for ub.stk-supp-line.

do
for buf_goods
  , buf_gds-obj
  , buf_clients
on error undo, return error
:

OUTPUT STREAM stmXMLOut TO VALUE(sOutFile + "xm1") CONVERT TARGET "1251" APPEND.

RUN wp-XMLWriteCNT(hCNT, "").

run wp-xmltagopen( 2, "operation","").
run wp-xmltagput( 3, "codeOperation", "stk", 0 ).
run wp-xmltagput( 3, "store"     , p-obj-type + string(p-obj-code), 0 ).
run wp-xmltagput( 3, "dateStart" , string(p-date-from,"99.99.9999"), 0 ).
run wp-xmltagput( 3, "dateEnd"   , string(p-date-to  ,"99.99.9999"), 0 ).
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

good-on-object:
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
/*---START--------- Не было движения за этот интервал на этом объекте ---------------------*/
    if buf_gds-obj.last-doc < p-date-from
    then do:
        for each buf_clients no-lock
        :
            find last buf_stk-supp-line no-lock
                where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
                  and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
                  and buf_stk-supp-line.cli-type  = buf_clients.obj-type
                  and buf_stk-supp-line.cli-code  = buf_clients.obj-code
                  and buf_stk-supp-line.artic     = buf_gds-obj.artic
                  and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
                  and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
                  and buf_stk-supp-line.sum-type  = {&arh-cost}
                  and buf_stk-supp-line.cat-id    = {&single-cat-id}
                  and buf_stk-supp-line.fact-order <= p-fact-order-to
            use-index category
            no-error.
            if available buf_stk-supp-line
            then do:
                create temp-good.
                assign
                    temp-good.gds-code                  = buf_gds-obj.gds-code
                    temp-good.supp-type                 = buf_clients.obj-type
                    temp-good.supp-code                 = buf_clients.obj-code
                    temp-good.artic                     = buf_gds-obj.artic
                    temp-good.prod-type                 = buf_gds-obj.prod-type
                    temp-good.prod-code                 = buf_gds-obj.prod-code
                    temp-good.qnty-first                = buf_stk-supp-line.fact-qnty
                    temp-good.qnty-last                 = buf_stk-supp-line.fact-qnty

                    temp-good.sum-last-rubl             = buf_stk-supp-line.sum-rubl
                    temp-good.sum-last-base             = buf_stk-supp-line.sum-base
                    temp-good.sum-VAT-last-rubl         = buf_stk-supp-line.VAT-rubl
                    temp-good.sum-VAT-last-base         = buf_stk-supp-line.VAT-base
                    temp-good.sum-other-last-rubl       = buf_stk-supp-line.other-rubl
                    temp-good.sum-other-last-base       = buf_stk-supp-line.other-base
                    temp-good.sum-transport-last-rubl   = buf_stk-supp-line.transport-rubl
                    temp-good.sum-transport-last-base   = buf_stk-supp-line.transport-base

                    temp-good.sum-first-rubl            = buf_stk-supp-line.sum-rubl
                    temp-good.sum-first-base            = buf_stk-supp-line.sum-base
                    temp-good.sum-VAT-first-rubl        = buf_stk-supp-line.VAT-rubl
                    temp-good.sum-VAT-first-base        = buf_stk-supp-line.VAT-base
                    temp-good.sum-other-first-rubl      = buf_stk-supp-line.other-rubl
                    temp-good.sum-other-first-base      = buf_stk-supp-line.other-base
                    temp-good.sum-transport-first-rubl  = buf_stk-supp-line.transport-rubl
                    temp-good.sum-transport-first-base  = buf_stk-supp-line.transport-base
                .
                find first buf_goods no-lock
                    where buf_goods.artic     = buf_gds-obj.artic
                      and buf_goods.prod-type = buf_gds-obj.prod-type
                      and buf_goods.prod-code = buf_gds-obj.prod-code
                no-error.
                if available buf_goods
                then do:
                    assign
                        temp-good.gds-name       = buf_goods.gds-name
                    .
                end.        /* available buf_goods */
                else do:
                    assign
                        temp-good.gds-name       = ""
                    .
                end.        /* NOT ( available buf_goods ) */
                run write-result in this-procedure (
                      input temp-good.gds-code
                    , input temp-good.supp-type
                    , input temp-good.supp-code
                ).
            end.        /* if available stk-supp-line */
            else do:
                /* Не было вообще движения товара для этого поставщика */
            end.
        end.        /* for each buf_clients */
        next good-on-object.
    end.        /* if buf_gds-obj.last-doc < p-date-from */
    if buf_gds-obj.first-doc > p-date-to
    then do:        /* Движение товара на объекте началось после заданного интервала дат */
        next good-on-object.
    end.
/*---END----------- Не было движения за этот интервал на этом объекте ---------------------*/
    for each buf_clients no-lock
    :
        create temp-good.
        assign
            temp-good.gds-code                  = buf_gds-obj.gds-code
            temp-good.supp-type                 = buf_clients.obj-type
            temp-good.supp-code                 = buf_clients.obj-code
            temp-good.artic                     = buf_gds-obj.artic
            temp-good.prod-type                 = buf_gds-obj.prod-type
            temp-good.prod-code                 = buf_gds-obj.prod-code

            temp-good.qnty-first                = 0
            temp-good.qnty-last                 = 0
            temp-good.sum-first-rubl            = 0
            temp-good.sum-first-base            = 0
            temp-good.sum-VAT-first-rubl        = 0
            temp-good.sum-VAT-first-base        = 0
            temp-good.sum-other-first-rubl      = 0
            temp-good.sum-other-first-base      = 0
            temp-good.sum-transport-first-rubl  = 0
            temp-good.sum-transport-first-base  = 0

            temp-good.sum-last-rubl             = 0
            temp-good.sum-last-base             = 0
            temp-good.sum-VAT-last-rubl         = 0
            temp-good.sum-VAT-last-base         = 0
            temp-good.sum-other-last-rubl       = 0
            temp-good.sum-other-last-base       = 0
            temp-good.sum-transport-last-rubl   = 0
            temp-good.sum-transport-last-base   = 0
        .
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
        end.        /* NOT ( available buf_goods ) */
        find last buf_stk-supp-line no-lock
            where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
              and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
              and buf_stk-supp-line.cli-type  = buf_clients.obj-type
              and buf_stk-supp-line.cli-code  = buf_clients.obj-code
              and buf_stk-supp-line.artic     = buf_gds-obj.artic
              and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
              and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
              and buf_stk-supp-line.sum-type  = {&arh-cost}
              and buf_stk-supp-line.cat-id    = {&single-cat-id}
              and buf_stk-supp-line.fact-order <= p-fact-order-to
        use-index category
        no-error.
        if available buf_stk-supp-line
        then do:
            assign
                temp-good.qnty-last                 = buf_stk-supp-line.fact-qnty
                temp-good.sum-last-rubl             = buf_stk-supp-line.sum-rubl
                temp-good.sum-last-base             = buf_stk-supp-line.sum-base
                temp-good.sum-VAT-last-rubl         = buf_stk-supp-line.VAT-rubl
                temp-good.sum-VAT-last-base         = buf_stk-supp-line.VAT-base
                temp-good.sum-other-last-rubl       = buf_stk-supp-line.other-rubl
                temp-good.sum-other-last-base       = buf_stk-supp-line.other-base
                temp-good.sum-transport-last-rubl   = buf_stk-supp-line.transport-rubl
                temp-good.sum-transport-last-base   = buf_stk-supp-line.transport-base
            .
        end.
/*        RUN wp-XMLWriteLog(sLogFile, 3, "Товар на конец периода: " + string(buf_gds-obj.artic) + " ---- " + string( temp-good.qnty-last ) ).*/
        find last buf_stk-supp-line no-lock
            where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
              and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
              and buf_stk-supp-line.cli-type  = buf_clients.obj-type
              and buf_stk-supp-line.cli-code  = buf_clients.obj-code
              and buf_stk-supp-line.artic     = buf_gds-obj.artic
              and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
              and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
              and buf_stk-supp-line.sum-type  = {&arh-cost}
              and buf_stk-supp-line.cat-id    = {&single-cat-id}
              and buf_stk-supp-line.fact-order <= p-fact-order-from
        use-index category
        no-error.
        if available buf_stk-supp-line
        then do:
            assign
                temp-good.qnty-first                = buf_stk-supp-line.fact-qnty
                temp-good.sum-first-rubl            = buf_stk-supp-line.sum-rubl
                temp-good.sum-first-base            = buf_stk-supp-line.sum-base
                temp-good.sum-VAT-first-rubl        = buf_stk-supp-line.VAT-rubl
                temp-good.sum-VAT-first-base        = buf_stk-supp-line.VAT-base
                temp-good.sum-other-first-rubl      = buf_stk-supp-line.other-rubl
                temp-good.sum-other-first-base      = buf_stk-supp-line.other-base
                temp-good.sum-transport-first-rubl  = buf_stk-supp-line.transport-rubl
                temp-good.sum-transport-first-base  = buf_stk-supp-line.transport-base
            .
        end.
/*        RUN wp-XMLWriteLog(sLogFile, 3, "Товар на начало периода: " + string(buf_gds-obj.artic) + " ---- " + string( temp-good.qnty-first ) ).*/
        run write-result in this-procedure (
              input temp-good.gds-code
            , input temp-good.supp-type
            , input temp-good.supp-code
        ) .
    end.        /* for each buf_clients */
end.        /* for each buf_gds-obj */

run wp-xmltagclose(2, "operation").
/*    { rep/repfrm.i off}*/
output stream stmxmlout close.
{ gbl/stopwork.i }

end.



/*==========================================================================*/
procedure write-result :
do
on error undo, return error
:
define input parameter p-gds-code   as integer      no-undo.
define input parameter p-supp-type  as character    no-undo.
define input parameter p-supp-code  as integer      no-undo.

    find first temp-good
         where temp-good.gds-code   = p-gds-code
           and temp-good.supp-type  = p-supp-type
           and temp-good.supp-code  = p-supp-code
    .
    if temp-good.qnty-first     <> 0
    or temp-good.sum-first-rubl <> 0
    or temp-good.sum-first-base <> 0
    or temp-good.qnty-last      <> 0
    or temp-good.sum-last-rubl  <> 0
    or temp-good.sum-last-base  <> 0
    then do:
        process events.
        assign
            v-good-counter = v-good-counter + 1
        .
        run wp-xmltagopen( 3, "good", "" ).
        run wp-xmltagput( 4, "code"       , string( temp-good.gds-code )       , 0 ).
        run wp-xmltagput( 4, "suppType"   , string( temp-good.supp-type )      , 0 ).
        run wp-xmltagput( 4, "suppCode"   , string( temp-good.supp-code )      , 0 ).
        run wp-xmltagput( 4, "artic"      , temp-good.artic                    , 0 ).
        run wp-xmltagput( 4, "prodType"   , temp-good.prod-type                , 0 ).
        run wp-xmltagput( 4, "prodCode"   , string( temp-good.prod-code )      , 0 ).
        run wp-xmltagput( 4, "name"       , temp-good.gds-name                 , 0 ).
        run wp-xmltagput( 4, "qntyStart"  , string( temp-good.qnty-first     ) , 0 ).

        run wp-xmltagput( input 4, input "sumStartR"            , input string( temp-good.sum-first-rubl            ) , input 0 ).
        run wp-xmltagput( input 4, input "sumStartB"            , input string( temp-good.sum-first-base            ) , input 0 ).
        run wp-xmltagput( input 4, input "sumStartVATR"         , input string( temp-good.sum-VAT-first-rubl        ) , input 0 ).
        run wp-xmltagput( input 4, input "sumStartVATB"         , input string( temp-good.sum-VAT-first-base        ) , input 0 ).
        run wp-xmltagput( input 4, input "sumStartOtherR"       , input string( temp-good.sum-other-first-rubl      ) , input 0 ).
        run wp-xmltagput( input 4, input "sumStartOtherB"       , input string( temp-good.sum-other-first-base      ) , input 0 ).
        run wp-xmltagput( input 4, input "sumStartTransportR"   , input string( temp-good.sum-transport-first-rubl  ) , input 0 ).
        run wp-xmltagput( input 4, input "sumStartTransportB"   , input string( temp-good.sum-transport-first-base  ) , input 0 ).

        run wp-xmltagput( input 4, input "qntyEnd"              , input string( temp-good.qnty-last                 ) , input 0 ).
        run wp-xmltagput( input 4, input "sumEndR"              , input string( temp-good.sum-last-rubl             ) , input 0 ).
        run wp-xmltagput( input 4, input "sumEndB"              , input string( temp-good.sum-last-base             ) , input 0 ).
        run wp-xmltagput( input 4, input "sumEndVATR"           , input string( temp-good.sum-VAT-last-rubl         ) , input 0 ).
        run wp-xmltagput( input 4, input "sumEndVATB"           , input string( temp-good.sum-VAT-last-base         ) , input 0 ).
        run wp-xmltagput( input 4, input "sumEndOtherR"         , input string( temp-good.sum-other-last-rubl       ) , input 0 ).
        run wp-xmltagput( input 4, input "sumEndOtherB"         , input string( temp-good.sum-other-last-base       ) , input 0 ).
        run wp-xmltagput( input 4, input "sumEndTransportR"     , input string( temp-good.sum-transport-last-rubl   ) , input 0 ).
        run wp-xmltagput( input 4, input "sumEndTransportB"     , input string( temp-good.sum-transport-last-base   ) , input 0 ).

        run wp-xmltagclose( 3, "good" ).
        if v-good-counter modulo 10 = 0
        then do:
            run wp-XMLWriteCnt( hcnt, string( v-good-counter ) ).
            process events.
        end.
    end.
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