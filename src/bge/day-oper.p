block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: day-oper.p $
$Archive: bge/day-oper.p $

Экспорт документов по архивам

Автор: Хныкин Павел Андреевич
Дата создания: 04/05/06
Author: Pavel Khnykin
Creation date: 04/05/06

Input:
    v-oper-num  - номер операции (неверный номер - запись в лог).
    dFrom     - начальная дата.
    dTo       - конечная дата.
    sOutFile  - имя файла .xm1 для вывода (вызывающая программа создает и по завершении
                экспорта переименовывает этот файл в .xml. Сделано для синхронизации с
                блоком импорта во внешней бухгалтерии.
    sLogFile  - полное имя файла для записи событий.
*/

define input parameter p-object-state    as character              no-undo.
define input parameter p-obj-type        as character              no-undo.
define input parameter p-obj-code        as integer                no-undo.
define input parameter p-date            as date                   no-undo.
define input parameter p-fact-order-from like ub.stk-tot.fact-order   no-undo.
define input parameter p-fact-order-to   like ub.stk-tot.fact-order   no-undo.
define input parameter soutfile          as character              no-undo.
define input parameter slogfile          as character              no-undo.
define input parameter hedt              as handle                 no-undo.
define input parameter hcnt              as handle                 no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: day-oper.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/day-oper.p $":U .
define variable vss-description as character no-undo init "Экспорт документов по архивам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ bge/bge-xml.i  }


&SCOP FRAME-NAME F-DUMMY

def temp-table temp_good no-undo
    field gds-code              like ub.goods.gds-code
    field artic                 like ub.goods.artic
    field prod-type             like ub.goods.prod-type
    field prod-code             like ub.goods.prod-code
    field gds-name              like ub.goods.gds-name
    field qnty-first            like ub.stk-line.fact-qnty
    field qnty-last             like ub.stk-line.fact-qnty
    index pi is primary unique gds-code
.
define temp-table temp_good-sum no-undo
    field tag-name              as character               /* base, rubl или doc */
    field first-rubl            like ub.stk-line.sum-rubl
    field first-base            like ub.stk-line.sum-base
    field last-rubl             like ub.stk-line.sum-rubl
    field last-base             like ub.stk-line.sum-base
    field write-result          as logical
    index pi is primary unique tag-name
.
define temp-table temp_turn-over no-undo
    field sum-type              like ub.ot-tot.sum-type
    field ext-doc-type          like ub.ot-tot.ext-doc-type
    field qnty                  like ub.ot-tot.fact-qnty
    field sum-rubl              like ub.ot-tot.sum-rubl
    field sum-base              like ub.ot-tot.sum-base
    field write-result          as logical
    index pi is primary unique sum-type ext-doc-type
.

define variable v-good-counter  as integer        no-undo.
define variable v-qnty          as integer        no-undo.
define variable v-write-good    as logical        no-undo.
define variable v-host-code     as integer       no-undo.
define variable v-base-code     as integer       no-undo.
define variable v-base-code-okv as integer       no-undo.

def buffer buf_gds-obj for ub.gds-obj.

do
for buf_gds-obj
on error undo, return error
:

OUTPUT STREAM stmXMLOut TO VALUE(sOutFile + "xm1") CONVERT TARGET "1251" APPEND.

RUN wp-XMLWriteCNT(hCNT, "").

create temp_good.

if index( p-object-state, "start" ) <> 0
then do:
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
    run wp-xmltagopen( 2, "operation","").
    run wp-xmltagput( 3, "codeOperation", "objectDay", 0 ).
    run wp-xmltagput( 3, "store"     , p-obj-type + string(p-obj-code), 0 ).
    run wp-xmltagput( 4, "valutCode" , string(v-base-code), 0 ).
    run wp-xmltagput( 4, "valutCodeOKV" , string(v-base-code-okv), 0 ).
end.

run wp-xmltagopen( 3, "day","").
run wp-xmltagput( 4, "date", string(p-date,"99.99.9999"), 0 ).

good-on-object:
for each buf_gds-obj no-lock
   where buf_gds-obj.obj-type   = p-obj-type
     and buf_gds-obj.obj-code   = p-obj-code
:
/*---START--------- Не было движения в этот день на этом объекте ---------------------*/
    if buf_gds-obj.first-doc > p-date
        or ( buf_gds-obj.last-doc < p-date
            and buf_gds-obj.fact-qnty = 0
            and buf_gds-obj.avrg-qnty = 0
           )
    then do:
        next good-on-object.
    end.
/*---END----------- Не было движения в этот день на этом объекте ---------------------*/
    assign
        temp_good.gds-code              = buf_gds-obj.gds-code
        temp_good.artic                 = buf_gds-obj.artic
        temp_good.prod-type             = buf_gds-obj.prod-type
        temp_good.prod-code             = buf_gds-obj.prod-code
        temp_good.gds-name              = ""
        temp_good.qnty-first            = 0
        temp_good.qnty-last             = 0
        v-write-good                    = no
    .

    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Pri_Vnesh}          , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Ras_Vnesh}          , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Ras_Vnesh_VP}       , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Ras_Vnesh_Kass}     , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Vozvrat_Vnesh}      , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Vozvrat_Vnesh_Kass} , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Spi_Vnesh}          , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Inv}                , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Peresort}           , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Corr_Acc_Price}     , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Chg_Purch_Code}     , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Corr_Minus_Parts}   , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Pri_Perem}          , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Ras_Perem}          , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Vozvrat_Perem}      , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Ras_Prvo}           , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Spi_Prvo}           , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Pri_Prvo}           , input recid( buf_gds-obj ) ).
    run form-turn-over in this-procedure ( input {&arh-csdt}, input {&TDEDT_Overturn}           , input recid( buf_gds-obj ) ).

    run form-stk in this-procedure ( input {&arh-cost}, input "cost", input recid( buf_gds-obj ) , output temp_good.qnty-first, output temp_good.qnty-last ).
    run form-stk in this-procedure ( input {&arh-crsa}, input "sale", input recid( buf_gds-obj ) , output v-qnty, output v-qnty ).
    if v-write-good = yes
    then do:
        run write-result in this-procedure
          (input recid(buf_gds-obj)
          ) .
    end.
end.

run wp-xmltagclose(3, "day").

if index( p-object-state, "end" ) <> 0
then do:
    run wp-xmltagclose(2, "operation").
end.
/*    { rep/repfrm.i off}*/
output stream stmxmlout close.
{ gbl/stopwork.i }

end.






/*==========================================================================*/
procedure form-turn-over :
define input parameter p-sum-type       as character       no-undo.
define input parameter p-ext-doc-type   as character       no-undo.
define input parameter p-gds-obj-recid  as recid           no-undo.

    define buffer buf_gds-obj       for ub.gds-obj.
    define buffer buf_stk-line      for ub.stk-line.
do
for buf_gds-obj
  , buf_stk-line
on error undo, return error
:
find first buf_gds-obj no-lock
     where recid( buf_gds-obj ) = p-gds-obj-recid
.
find first temp_turn-over
     where temp_turn-over.sum-type      = p-sum-type
       and temp_turn-over.ext-doc-type  = p-ext-doc-type
no-error.
if not available temp_turn-over
then do:
    create temp_turn-over.
    assign
        temp_turn-over.sum-type     = p-sum-type
        temp_turn-over.ext-doc-type = p-ext-doc-type
    .
end.
assign
    temp_turn-over.qnty         = 0
    temp_turn-over.sum-rubl     = 0
    temp_turn-over.sum-base     = 0
.
find last buf_stk-line no-lock
    where buf_stk-line.obj-type     = buf_gds-obj.obj-type
      and buf_stk-line.obj-code     = buf_gds-obj.obj-code
      and buf_stk-line.artic        = buf_gds-obj.artic
      and buf_stk-line.prod-type    = buf_gds-obj.prod-type
      and buf_stk-line.prod-code    = buf_gds-obj.prod-code
      and buf_stk-line.sum-type     = p-sum-type + p-ext-doc-type
      and buf_stk-line.cat-id       = {&root-cat-id}
      and buf_stk-line.fact-order  <= p-fact-order-to
use-index category
no-error.
if available buf_stk-line
then do:
    assign
        temp_turn-over.qnty         = temp_turn-over.qnty     + buf_stk-line.fact-qnty
        temp_turn-over.sum-rubl     = temp_turn-over.sum-rubl + buf_stk-line.sum-rubl
        temp_turn-over.sum-base     = temp_turn-over.sum-base + buf_stk-line.sum-base
    .
    find last buf_stk-line no-lock
        where buf_stk-line.obj-type     = buf_gds-obj.obj-type
          and buf_stk-line.obj-code     = buf_gds-obj.obj-code
          and buf_stk-line.artic        = buf_gds-obj.artic
          and buf_stk-line.prod-type    = buf_gds-obj.prod-type
          and buf_stk-line.prod-code    = buf_gds-obj.prod-code
          and buf_stk-line.sum-type     = p-sum-type + p-ext-doc-type
          and buf_stk-line.cat-id       = {&root-cat-id}
          and buf_stk-line.fact-order  <= p-fact-order-from
    use-index category
    no-error.
    if available buf_stk-line
    then do:
        assign
            temp_turn-over.qnty       = temp_turn-over.qnty     - buf_stk-line.fact-qnty
            temp_turn-over.sum-rubl   = temp_turn-over.sum-rubl - buf_stk-line.sum-rubl
            temp_turn-over.sum-base   = temp_turn-over.sum-base - buf_stk-line.sum-base
        .
    end.
end.
if   temp_turn-over.qnty     = 0
 and temp_turn-over.sum-rubl = 0
 and temp_turn-over.sum-base = 0
then do:
    assign
        temp_turn-over.write-result = no
    .
end.
else do:
    assign
        temp_turn-over.write-result = yes
        v-write-good                = yes
    .
end.
end.
end procedure. /* form-turn-over */






/*==========================================================================*/
procedure form-stk :
define input parameter p-sum-type       as character       no-undo.
define input parameter p-tag-name       as character       no-undo.
define input parameter p-gds-obj-recid  as recid           no-undo.
define output parameter p-qnty-first    as decimal  init 0 no-undo.
define output parameter p-qnty-last     as decimal  init 0 no-undo.

    define buffer buf_gds-obj       for ub.gds-obj.
    define buffer buf_stk-line      for ub.stk-line.
do
for buf_gds-obj
  , buf_stk-line
on error undo, return error
:
    find first buf_gds-obj no-lock
         where recid( buf_gds-obj ) = p-gds-obj-recid
    .
    find first temp_good-sum
        where temp_good-sum.tag-name = p-tag-name
    no-error.
    if not available temp_good-sum
    then do:
        create temp_good-sum.
        assign
            temp_good-sum.tag-name          = p-tag-name
        .
    end.
    assign
        temp_good-sum.first-rubl        = 0
        temp_good-sum.first-base        = 0
        temp_good-sum.last-rubl         = 0
        temp_good-sum.last-base         = 0
    .
    find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = p-sum-type
          and buf_stk-line.cat-id    = {&root-cat-id}
          and buf_stk-line.fact-order <= p-fact-order-to
    use-index category
    no-error.
    if available buf_stk-line /* нет остатков на конечную дату */
    then do:
        assign
            p-qnty-last             = buf_stk-line.fact-qnty
            temp_good-sum.last-rubl = temp_good-sum.last-rubl + buf_stk-line.sum-rubl
            temp_good-sum.last-base = temp_good-sum.last-base + buf_stk-line.sum-base
        .
    end.

    if  buf_gds-obj.last-doc < p-date
    then do:
        /*---START--------- Движения не было, но на начало остатки были ---------------------*/
        assign
            p-qnty-first                = p-qnty-last
            temp_good-sum.first-rubl    = temp_good-sum.last-rubl
            temp_good-sum.first-base    = temp_good-sum.last-base
        .
        /*---END----------- Движения не было, но на начало остатки были ---------------------*/
    end.
    else do:
        find last buf_stk-line no-lock
            where buf_stk-line.obj-type  = buf_gds-obj.obj-type
              and buf_stk-line.obj-code  = buf_gds-obj.obj-code
              and buf_stk-line.artic     = buf_gds-obj.artic
              and buf_stk-line.prod-type = buf_gds-obj.prod-type
              and buf_stk-line.prod-code = buf_gds-obj.prod-code
              and buf_stk-line.sum-type  = p-sum-type
              and buf_stk-line.cat-id    = {&root-cat-id}
              and buf_stk-line.fact-order <= p-fact-order-from
        use-index category
        no-error.
        if available buf_stk-line
        then do:
            assign
                p-qnty-first                = p-qnty-first             + buf_stk-line.fact-qnty
                temp_good-sum.first-rubl    = temp_good-sum.first-rubl + buf_stk-line.sum-rubl
                temp_good-sum.first-base    = temp_good-sum.first-base + buf_stk-line.sum-base
            .
        end.
    end.
    if   p-qnty-first             = 0
     and temp_good-sum.first-rubl = 0
     and temp_good-sum.first-base = 0
    then do:
        assign
            temp_good-sum.write-result = no
        .
    end.
    else do:
        assign
            temp_good-sum.write-result = yes
            v-write-good               = yes
        .
    end.
end.
end procedure. /* form-stk */






/*==========================================================================*/
procedure write-result :
define input parameter p-gds-obj-recid  as recid           no-undo.

    define buffer buf_gds-obj       for ub.gds-obj.
do
for buf_gds-obj
on error undo, return error
:
    process events.
    find first buf_gds-obj no-lock
         where recid( buf_gds-obj ) = p-gds-obj-recid
    .
    assign
        v-good-counter = v-good-counter + 1
    .
    run wp-xmltagopen( 4, "good", "" ).
    run wp-xmltagput( 5, "code"       , string( temp_good.gds-code )       , 0 ).
    run wp-xmltagput( 5, "artic"      , temp_good.artic                    , 0 ).
    run wp-xmltagput( 5, "prodType"   , temp_good.prod-type                , 0 ).
    run wp-xmltagput( 5, "prodCode"   , string( temp_good.prod-code )      , 0 ).
    run wp-xmltagput( 5, "name"       , temp_good.gds-name                 , 0 ).
    run wp-xmltagput( 5, "qntyStart"  , string( temp_good.qnty-first )     , 0 ).
    run wp-xmltagput( 5, "qntyEnd"    , string( temp_good.qnty-last )      , 0 ).
    for each temp_good-sum
       where temp_good-sum.write-result = yes
    :
        run wp-xmltagopen( 5, "restSumType", "" ).
        run wp-xmltagput( 6, "name"       , string( temp_good-sum.tag-name ) , 0 ).
        run wp-xmltagput( 6, "sumStartR"  , string( temp_good-sum.first-rubl ) , 0 ).
        run wp-xmltagput( 6, "sumStartB"  , string( temp_good-sum.first-base ) , 0 ).
        run wp-xmltagput( 6, "sumEndR"    , string( temp_good-sum.last-rubl )  , 0 ).
        run wp-xmltagput( 6, "sumEndB"    , string( temp_good-sum.last-base )  , 0 ).
        run wp-xmltagclose( 5, "restSumType" ).
    end.
    for each temp_turn-over
       where temp_turn-over.write-result = yes
    break by temp_turn-over.ext-doc-type
          by temp_turn-over.sum-type
    :
        if first-of( temp_turn-over.ext-doc-type  )
        then do:
            run wp-xmltagopen( 5, "docType", "" ).
            run wp-xmltagput( 6, "name"       , string( temp_turn-over.ext-doc-type ) , 0 ).
        end.
        run wp-xmltagopen( 6, "sumType", "" ).
        run wp-xmltagput( 7, "name"       , string( temp_turn-over.sum-type ) , 0 ).
        run wp-xmltagput( 7, "qnty"       , string( temp_turn-over.qnty     ) , 0 ).
        run wp-xmltagput( 7, "sumR"       , string( temp_turn-over.sum-rubl ) , 0 ).
        run wp-xmltagput( 7, "sumB"       , string( temp_turn-over.sum-base ) , 0 ).
        run wp-xmltagclose( 6, "sumType" ).
        if last-of( temp_turn-over.ext-doc-type  )
        then do:
            run wp-xmltagclose( 5, "docType" ).
        end.
    end.
    run wp-xmltagclose( 4, "good" ).

    if v-good-counter modulo 25 = 0
    then do:
        run wp-XMLWriteCnt( hcnt, "Товар " + buf_gds-obj.obj-type + string( buf_gds-obj.obj-code ) + "  " + string( v-good-counter ) ).
        process events.
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