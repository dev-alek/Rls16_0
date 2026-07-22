block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: way-oper.p $
$Archive: bge/way-oper.p $

Экспорт товаров в пути

Автор: Хныкин Павел Андреевич
Дата создания: 03/31/06
Author: Pavel Khnykin
Creation date: 03/31/06

Input:

Output:

Параметры:
    v-oper-num  - номер операции (неверный номер - запись в лог).
    dFrom     - начальная дата.
    dTo       - конечная дата.
    v-xml-file-name  - имя файла .xm1 для вывода (вызывающая программа создает и по завершении
                экспорта переименовывает этот файл в .xml. Сделано для синхронизации с
                блоком импорта во внешней бухгалтерии. )
    v-log-file-name  - полное имя файла для записи событий.

*/
define input parameter p-obj-type        as character              no-undo.
define input parameter p-obj-code        as integer                no-undo.
define input parameter v-xml-file-name   as character              no-undo.
define input parameter v-log-file-name   as character              no-undo.
define input parameter hedt              as handle                 no-undo.
define input parameter hcnt              as handle                 no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: way-oper.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/way-oper.p $":U .
define variable vss-description as character no-undo init "Экспорт товаров в пути".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ bge/bge-xml.i  }

&scoped-define FRAME-NAME F-DUMMY

    define temp-table temp_good no-undo
        field gds-code              like ub.goods.gds-code
        field artic                 like ub.goods.artic
        field prod-type             like ub.goods.prod-type
        field prod-code             like ub.goods.prod-code
        field gds-name              like ub.goods.gds-name
        field doc-qnty              like ub.stk-line.fact-qnty
        field fact-qnty             like ub.stk-line.fact-qnty
        index pi is primary unique artic prod-type prod-code
    .

    define variable v-qnty      as integer          no-undo.
    define variable v-no-goods  as logical init yes no-undo.
    define variable v-host-code as integer       no-undo.
    define variable v-base-code as integer       no-undo.
define variable v-base-code-okv     as integer       no-undo.

    def buffer buf_goods    for ub.goods.
    def buffer buf_trn-doc  for ub.trn-doc.
    def buffer buf_doc-line for ub.doc-line.

do
for buf_goods
  , buf_trn-doc
  , buf_doc-line
on error undo, return error
:

output stream stmXMLOut to value( v-xml-file-name + "xm1" ) convert target "1251" append.

run wp-XMLWriteCNT( hCNT, "" ).


run form-temp_good in this-procedure ( input {&income},     input  1 ).
run form-temp_good in this-procedure ( input {&expense},    input -1 ).
run form-temp_good in this-procedure ( input {&return},     input -1 ).
run form-temp_good in this-procedure ( input {&write-off},  input -1 ).

if v-no-goods = no
then do:
    run wp-xmltagopen( 2, "operation","").
    run wp-xmltagput( 3, "codeOperation", "objectDay", 0 ).
    run wp-xmltagput( 3, "store"     , p-obj-type + string(p-obj-code), 0 ).
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

    run write-result in this-procedure .

    run wp-xmltagclose(2, "operation").
end.

/*    { rep/repfrm.i off}*/
output stream stmxmlout close.
{ gbl/stopwork.i }

end.



/*==========================================================================*/
procedure write-result :
do
on error undo, return error
:
define variable v-good-counter  as integer   init 0     no-undo.

    process events.

    for each temp_good
    :
        assign
            v-good-counter = v-good-counter + 1
        .
        run wp-xmltagopen( 3, "good", "" ).
        run wp-xmltagput( 4, "code"       , string( temp_good.gds-code )       , 0 ).
        run wp-xmltagput( 4, "artic"      , temp_good.artic                    , 0 ).
        run wp-xmltagput( 4, "prodType"   , temp_good.prod-type                , 0 ).
        run wp-xmltagput( 4, "prodCode"   , string( temp_good.prod-code )      , 0 ).
        run wp-xmltagput( 4, "name"       , temp_good.gds-name                 , 0 ).
        run wp-xmltagput( 4, "docQnty"    , string( temp_good.doc-qnty )       , 0 ).
        run wp-xmltagput( 4, "factQnty"   , string( temp_good.fact-qnty )      , 0 ).
        run wp-xmltagclose( 3, "good" ).

        if v-good-counter modulo 10 = 0
        then do:
            run wp-XMLWriteCnt( hcnt, "Товар " + string( v-good-counter ) ).
            process events.
        end.
    end.
/*            { rep/repfrm.i disp v-good-counter}*/
end.
end procedure. /* write-result */




/*==========================================================================*/
procedure form-temp_good :
define input parameter p-doc-type       as character    no-undo.
define input parameter p-operation-sign as integer      no-undo.

    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_goods         for ub.goods.
do
for buf_trn-doc
  , buf_doc-line
  , buf_goods
on error undo, return error
:
opened-internal-trn-doc:
for each buf_trn-doc no-lock
   where buf_trn-doc.obj-type = p-obj-type
     and buf_trn-doc.obj-code = p-obj-code
     and buf_trn-doc.internal = yes
     and buf_trn-doc.doc-type = p-doc-type
     and ( buf_trn-doc.status_  = {&wayb}
            or buf_trn-doc.status_ = {&inquiry}
            or buf_trn-doc.status_ = {&manufactured}
         )
:
    for each buf_doc-line no-lock
       where buf_doc-line.doc-code = buf_trn-doc.doc-code
    :
        assign
            v-no-goods = no
        .
        find first temp_good
             where temp_good.artic      = buf_doc-line.artic
               and temp_good.prod-type  = buf_doc-line.prod-type
               and temp_good.prod-code  = buf_doc-line.prod-code
        no-error.
        if not available temp_good
        then do:
            create temp_good.
            find first buf_goods no-lock
                 where buf_goods.artic        = buf_doc-line.artic
                   and buf_goods.prod-type    = buf_doc-line.prod-type
                   and buf_goods.prod-code    = buf_doc-line.prod-code
            no-error.
            if available buf_goods
            then do:
                assign
                    temp_good.gds-code    = buf_goods.gds-code
                    temp_good.gds-name    = buf_goods.gds-name
                .
            end.        /* available buf_goods */
            else do:
                assign
                    temp_good.gds-code    = 0
                    temp_good.gds-name    = ""
                .
            end.        /* NOT ( available buf_goods ) */
            assign
                temp_good.artic       = buf_doc-line.artic
                temp_good.prod-type   = buf_doc-line.prod-type
                temp_good.prod-code   = buf_doc-line.prod-code
                temp_good.doc-qnty    = 0
                temp_good.fact-qnty   = 0
            .
        end.
        assign
            temp_good.doc-qnty    = temp_good.doc-qnty  + ( p-operation-sign * buf_doc-line.doc-qnty )
            temp_good.fact-qnty   = temp_good.fact-qnty + ( p-operation-sign * buf_doc-line.fact-qnty )
        .
    end.

end.


end.
end procedure. /* form-temp_good */



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