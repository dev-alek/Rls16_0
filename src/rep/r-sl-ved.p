block-level on error undo, throw.
/*

$Revision: a8e2cf75ddf6, 2506, rls $
$Author: EShklyar $
$Date: Ср июл 08 17:09:06 2020 +0300 $
$Workfile: r-sl-ved.p $
$Archive: rep/r-sl-ved.p $

Общая сличительная ведомость

Автор: Шаланин Сергей
Дата создания: 24/11/15
Author: Shalanin Sergey
Creation date: 24/11/15


*/

define variable vss-revision    as character no-undo init "$Revision: ":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июл 08 17:09:06 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-sl-ved.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-sl-ved.p $":U .
define variable vss-description as character no-undo init "Общая сличислительная ведомость".
{ cmp/vssrevis.i }


define input parameter parParentProc   as widget-handle no-undo.


define variable v-cntxt-host-name-obj    as character no-undo .
define variable v-report-name            as character no-undo.         /* Наименование отчёта */
define variable v-period                 as character no-undo.              /* Период за который формируется отчёт */
define variable v-short-obj-list         as character no-undo.      /* Перечень выбранных объектов "в одну строку" */
define variable v-choice-gds             as character no-undo. /* Список выбранных товаров. Вывод - в шапке отчёта */
define variable v-choice-obj             as character no-undo. /* Выбранный пользователем параметр "Выбор объекта" (в окне параметров). Вывод в шапке отчёта */
define variable v-full-path-RepView      as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm      as character no-undo.   /* Полный путь к файлу отчёта */
define variable v-par-type               as character no-undo.

define variable v-unit-OKEI              as integer   no-undo.
define variable v-unit-name              as char      no-undo.
define variable v-obj-code               as integer   no-undo.
define variable v-obj-type               as char      no-undo.
define variable var-x-sum-type           like doc-line-sum.sum-type no-undo.
define variable var-x-ost-sum-type       like doc-line-sum.sum-type no-undo.
define variable v-print-rubl             as logical   no-undo .
define variable v-curr-r-b               as character no-undo .
define variable num-g#                   as integer   no-undo.
 
define variable p-object                 as char.
define variable FixProdAttr              as character no-undo.
define variable v-izl-sum                as decimal.
define variable v-izl-qnty               as decimal.
define variable v-ned-sum                as decimal.
define variable v-ned-qnty               as decimal.
define variable v-grp-code               like ub.gds-grp.node-code no-undo.
define variable v-grp-name               like ub.goods.grp-name no-undo.
define variable ii-grp                   as integer   no-undo.
define variable v-found                  as logical   no-undo.

define variable v-temp-f-o               as decimal   no-undo .
define variable v-shift-end-fact-order   as decimal   no-undo .
define variable v-shift-start-fact-order as decimal   no-undo .
define variable v-inv-end-fact-order     as decimal   no-undo .
define variable v-inv-start-fact-order   as decimal   no-undo .

define variable p-doc-date               like trn-doc.doc-date.
define variable CurrGrpName              as character no-undo .
define variable p-doc-code               as char.
define variable v-host-code              as integer   no-undo.
define variable v-curr-code              as integer   no-undo.
define variable g#report-num             as integer   no-undo .
define variable pom-grp                  as integer.

define stream  macr_excel .
define stream  out-stream .
define stream OutStr-html.

define variable v-lvl-num       as integer.
define variable v-file-name     as character no-undo .
define variable v-file-name-ind as integer   no-undo .
define variable v-line          as character no-undo .

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
define variable v-cntxt-obj-name as character no-undo .


{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i new }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ rep/r-sale.i   }
{ trg/factord.i  }
define variable v-sys-key as character no-undo.


define buffer buf_units    for units.
define buffer buf_trn-doc  for trn-doc.
define buffer buf_doc-line for doc-line.
define buffer buf_goods    for goods.

define temp-table temp-doc no-undo
    field number     as integer
    field gds-code   like goods.gds-code
    field gds-name   like goods.gds-name
    field izl-sum    as decimal
    field izl-qnty   as decimal
    field ned-sum    as decimal
    field ned-qnty   as decimal
    field obj-code   as integer
    field obj-type   as char
    field doc-code   as char
    field OKEI       as integer
    field grp-code   like goods.grp-code
    field unit-name  as char
    field grp-lvl    as integer
    field lvl-num    as integer
    field upper-code as integer
    field lvl        as integer
    INDEX tt-doc is primary doc-code obj-code obj-type
    index tt-grp            grp-lvl  obj-type obj-code 
    .


/* ************************  Function Implementations ***************** */
function fnc-DD-MM-YYYY returns character 
    (input p-dat-date as date) forward.

function fnc-convert-dot-to-colon returns character 
    (input p-data as decimal, input p-accur as character) forward.
/* ***************************  Main Block  *************************** */

{ gbl/currsysk.i
  v-sys-key
   no-error
 }
if error-status :error then 
do:
    message
        vss-workfile vss-revision vss-description skip
        "Ошибка при чтении параметра конфигурации" '"sys-key"' skip    
        error-status :get-message( 1 ) skip
        return-value skip
        view-as alert-box error .
    return.
end.
   
   
     

if error-status :error then 
do:
    message
        vss-workfile vss-revision vss-description skip
        "Ошибка при чтении параметра конфигурации" '"sys-key"' skip
        error-status :get-message( 1 ) skip
        return-value skip
        view-as alert-box error .
    return.
end.

do
    for buf_trn-doc
    , buf_doc-line
    on error undo, return error
    :
    { gbl/working.i }

   
  
end.



case X-selectgood:

    when {&g-grp} then
        do:
            for each tmp#grp no-lock
                :
                num-g# = num-g# + 1.
                if num-g# = 1 then FixProdAttr = string(tmp#grp.node-code).
                if num-g# > 1 then leave.
            end.
        end.
end case.

/*        if X-selectgood = {&g-grp} then                                                                                             */
/*        do:                                                                                                                         */
/*            assign                                                                                                                  */
/*                v-grp-code = integer(FixProdAttr)               /* В режиме Один(ONE) - получение "временного" КОДА ГруппыТоваров */*/
/*            .                                                                                                                       */
/*                                                                                                                                    */
/*            run grplib-get-full-name in this-procedure (        /* Получение полного имени ГруппыТоваров (инклуд ref/grplibfn.i) */ */
/*                                                         input v-grp-code                                                           */
/*                                                        ,output v-grp-name)                                                         */
/*            .                                                                                                                       */
/*        end.                                                                                                                        */
/* *********************** */
{ rep/ostatok.i }
define variable x-date-start-t like stk-tot.shift-date no-undo.
    
      
run ostatok (
    input 0  ,
    input ""  ,yes,
    input x-date-start - 1 ,
    input date('')      ,  x-Shift-Start,x-Shift-End,
    input {&arh-crsa}   ,
    input {&root-cat-id},
    input false ,

    output  v-temp-f-o  ,
    output  v-temp-f-o   ,
    output  v-temp-f-o   ,
    output  v-temp-f-o     ,
    output  v-temp-f-o     ,
    output  v-shift-start-fact-order ).
        
run ostatok (
    input 0  ,
    input ""  ,yes,
    input x-date-start  ,
    input x-date-end    ,  x-Shift-Start,x-Shift-End,
    input {&arh-crsa}   ,
    input {&root-cat-id},
    input false ,

    output  v-temp-f-o  ,
    output  v-temp-f-o   ,
    output  v-temp-f-o   ,
    output  v-temp-f-o     ,
    output  v-temp-f-o     ,
    output  v-shift-end-fact-order ).
    

for each obj-list
    :
    { gbl/hostname.i obj-list.obj-type obj-list.obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }

    for each ub.trn-doc where
        ub.trn-doc.obj-type = obj-list.obj-type and
        ub.trn-doc.obj-code = obj-list.obj-code 
        and
        trn-doc.fact-order  <= v-shift-end-fact-order and
        trn-doc.fact-order   > v-shift-start-fact-order
        :
              
        case x-SET_PAY_TYPE :
            when {&p-cost} then 
                do:
                    assign
                        var-x-sum-type     = {&arh-cost}
                        var-x-ost-sum-type = {&arh-cost}
                        .
                end.
            when {&p-crsa} then 
                do:
                    assign
                        var-x-sum-type     = {&arh-crsa}
                        var-x-ost-sum-type = {&arh-crsa}
                        .
                end.
            when {&p-sale} then 
                do:
                    assign
                        var-x-sum-type     = {&arh-sale}
                        var-x-ost-sum-type = {&arh-crsa}
                        .
                end.
            otherwise 
            do:
                assign
                    var-x-sum-type     = {&arh-cost}
                    var-x-ost-sum-type = {&arh-cost}
                    .
            end.

        end case.
        run doc-calc.
    end. /* for each trn-doc */

    run transform-tt-level.
end. /* for each obj-list */ 






run get-full-path-RepViewer(output v-full-path-RepView).   
  
run get-report-num in parParentProc(output g#report-num).

run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).

run create-file(v-file-name-rep-htm). 

v-report-name = "Общая сличительная ведомость".

run proc-create-HTML (input v-file-name-rep-htm
    ,input v-cntxt-host-name-obj
    ,input v-report-name
    ,input p-doc-code
    ,input p-doc-date
    ,input p-object
    ,input v-izl-sum
    ,input v-izl-qnty
    ,input v-ned-sum
    ,input v-ned-qnty
    
    ).

run search-full-path-Report(input v-file-name-rep-htm).

run Report-Viewer(input v-full-path-RepView, input v-file-name-rep-htm).



procedure doc-calc:
    
    
  
    define variable p-gds-name    as character.
    define variable p-grp-code    as integer.
    define variable p-gds-code    as integer.
    define variable v-gds-name    as char.
    define variable p-okei        as integer.
    define variable p-ned-qnty    as decimal.
    define variable p-unit-name   as char.
    define variable p-ned-sum     as decimal.
    define variable p-izl-sum     as decimal.
    define variable p-izl-qnty    as decimal.
    define variable p-unit-base   as char.
    define variable help-grp-code as integer.
define variable p-help-grp-code as integer.
         
    _chk: for each doc-line where doc-line.doc-code = trn-doc.doc-code 
        and doc-line.obj-type = obj-list.obj-type 
        and doc-line.obj-code = obj-list.obj-code
        and doc-line.ext-doc-type = {&TDEDT_Inv} 
        and doc-line.status_ = {&fact}
        and doc-line.fact-qnty <> 0         
        /*          and                                             */
        /*                                                          */
        /*        doc-line.fact-order  <= v-shift-end-fact-order and*/
        /*        doc-line.fact-order   > v-shift-start-fact-order  */
        no-lock :
    
        find first buf_goods where buf_goods.prod-type = doc-line.prod-type and
            buf_goods.prod-code = doc-line.prod-code and 
            buf_goods.artic = doc-line.artic .
        p-gds-code = buf_goods.gds-code.
        p-grp-code = buf_goods.grp-code.
        p-gds-name = buf_goods.gds-name. 
        p-unit-base = buf_goods.unit-base.

        case x-SelectGood: 
        
            when {&g-choice} or
            when {&g-spis}     or
            when {&g-one}   then 
                do:
                                      run tt-lvl (input p-grp-code, output help-grp-code  ) .
                    
                    find  first gds-list no-lock
                        where gds-list.artic     = doc-line.artic
                        and gds-list.prod-type = doc-line.prod-type
                        and gds-list.prod-code = doc-line.prod-code
                        no-error .
                    if not available gds-list then next.
                    
                end.
     
            when {&g-all}  then 
                do: /* все товары */
                  run tt-lvl (input p-grp-code, output help-grp-code  ) .
                end.
                
            when {&g-grp} then 
                do :
                    assign
                        v-grp-name = ""
                        v-found    = no
                        .
                   
                    _ii-grp: do ii-grp = 1 to num-entries(buf_goods.grp-name, {&delim-grp}) - 1     /* 1 */ /* где {&delim-grp} = CHR(47) = "/". Фактически это уровни вложенности данной группы товаров */
                        :
                        assign
                            v-grp-name = v-grp-name + entry(ii-grp, buf_goods.grp-name, {&delim-grp}) + {&delim-grp} /* Вытаскиваем из полной цепочки - имя каждой группы для каждого уровня. Цепочка от корня до тек группы. */
                            .
                          
                                     
                        if can-find(first tmp#grp no-lock where
                            tmp#grp.grp-name = v-grp-name) then
                        do:
                       
                                                     
                            v-found = yes.
                            leave _ii-grp.
                        end.        
                    end. /* 1 */
                          
                    if not v-found then next _chk.
                   
          
                    
                end.
                

            otherwise
            do:     /*список товаров*/
                find  first gds-list no-lock
                    where doc-line.artic     = gds-list.artic
                    and doc-line.prod-type = gds-list.prod-type
                    and doc-line.prod-code = gds-list.prod-code no-error .
                if not available  gds-list then next.

            end.
        end case. 
        

        if   x-SelectGood = {&g-grp} then 
        do: 

            run tt-grp (input buf_goods.grp-code, output p-help-grp-code) .
            
            
            help-grp-code = p-help-grp-code.
        end.
        
        
        p-doc-date =  trn-doc.doc-date.
        p-doc-code = doc-line.doc-code.
        p-object = obj-list.obj-name.
           
           
      
           
        find first temp-doc where temp-doc.gds-code = p-gds-code and
            temp-doc.obj-code = doc-line.obj-code and
            temp-doc.obj-type = doc-line.obj-type 
            no-error.      
        if not available temp-doc then 
        do:
      
            create temp-doc.
            assign
                temp-doc.gds-code = p-gds-code   
                temp-doc.doc-code = doc-line.doc-code
                temp-doc.obj-code = doc-line.obj-code 
                temp-doc.obj-type = doc-line.obj-type
                temp-doc.gds-name = p-gds-name
                temp-doc.grp-code = help-grp-code.
                
            find first units no-lock 
                where units.unit-name = p-unit-base.
            temp-doc.okei = units.OKEI.
            temp-doc.unit-name =  units.unit-name.
   
        end.

  
         

        find first doc-line-sum 
            where 
            doc-line-sum.doc-code = doc-line.doc-code
            and
            doc-line-sum.gds-code = p-gds-code
            and doc-line-sum.sum-type = {&sum-general-doc}
            .



        if  available doc-line-sum
            then
        do:
                
            if doc-line-sum.fact-qnty >= 0
                then
            do:
                  
                assign
                    p-izl-qnty = doc-line-sum.fact-qnty
                    p-ned-qnty = 0.0
                    .
                    
                if var-x-sum-type = {&arh-crsa}
                    then 
                do:
                     
                    assign
                        p-izl-sum = doc-line-sum.sale-sum-rubl
                        p-ned-sum = 0.0
                        .
                end.
           
                else 
                do:
                    assign
                        p-izl-sum = doc-line-sum.cost-sum-rubl
                        p-ned-sum = 0.0
                        .
                end.
            end.
              
            else 
            do:
                assign
                    p-izl-qnty = 0.0
                    p-ned-qnty = (-1) * doc-line-sum.fact-qnty
                    .
                if var-x-sum-type = {&arh-crsa}
                    then 
                do:
                     
                      
                    assign
                        p-izl-sum = 0.0
                        p-ned-sum = (-1.0) * doc-line-sum.sale-sum-rubl
                        .
               
                end.
                else 
                do: 
                      
                    assign
                        p-izl-sum = 0.0
                        p-ned-sum = (-1.0) * doc-line-sum.cost-sum-rubl
                        .
                end.
            end.
        end.
        else 
        do:
            if var-x-sum-type = {&arh-crsa}
                then 
            do:
                 
                if doc-line.fact-qnty >= 0
                    then 
                do: 
                    assign
                        p-izl-qnty = doc-line.fact-qnty
                        p-ned-qnty = 0.0
                        p-izl-sum  = doc-line.price-base * doc-line.fact-qnty.
                    p-ned-sum  = 0.0
                        .
                end.
                else  
                do:
                    assign
                        p-izl-qnty = 0.0
                        p-ned-qnty = (-1.0) * doc-line.fact-qnty
                        p-izl-sum  = 0.0
                        p-ned-sum  = (-1.0) * doc-line.price-base * doc-line.fact-qnty.
                    .
                end.
            end.   
 
            else 
            do:
                if doc-line.fact-qnty >= 0
                    then 
                do:
                    assign
                        p-izl-qnty = doc-line.fact-qnty
                        p-ned-qnty = 0.0
                        p-izl-sum  = doc-line.price-rubl * doc-line.fact-qnty.
                    p-ned-sum  = 0.0
                        . 
                end.
                else 
                do:
                    assign
                        p-izl-qnty = 0.0
                        p-ned-qnty = (-1.0) * doc-line.fact-qnty
                        p-izl-sum  = 0.0
                        p-ned-sum  = (-1.0) * doc-line.price-rubl * doc-line.fact-qnty.
                           
                end.
            end.
      
        end.
        temp-doc.izl-sum = p-izl-sum + temp-doc.izl-sum.
        temp-doc.izl-qnty = p-izl-qnty + temp-doc.izl-qnty.
        temp-doc.ned-sum = p-ned-sum + temp-doc.ned-sum.
        temp-doc.ned-qnty = p-ned-qnty + temp-doc.ned-qnty.       
    
    
     
    
        v-izl-sum = v-izl-sum + p-izl-sum.
        v-izl-qnty = v-izl-qnty + p-izl-qnty.
        v-ned-sum = v-ned-sum + p-ned-sum.
        v-ned-qnty = v-ned-qnty + p-ned-qnty.

    
    end. 
        
end procedure.

procedure tt-grp: 
    
 
    
    define input parameter p-grp-code as integer.
    define output parameter tt-hp-grp-code as integer .
      
    
        find first gds-grp  no-lock  where gds-grp.node-code = p-grp-code   no-error.
        
         if available gds-grp then
        do:
            
          
        
    find first tmp#grp where tmp#grp.node-code  =  p-grp-code  no-error.
    
    if available tmp#grp then 
    do:
             tt-hp-grp-code = p-grp-code.

        end.
       
    

    else
    do :
        run tt-grp(input gds-grp.upper-code, output tt-hp-grp-code).
    end.
end.
     
      
end procedure.
    
    
    
procedure transform-tt-level:

    define buffer buftt_temp-doc for temp-doc.
    define variable v-gds-name     as character no-undo.
    define variable v-cur-lvl      as integer   no-undo.
    define variable v-upper-code   as integer   initial ? no-undo.
    define variable v-ii           as integer   no-undo.
    define variable p-grp-izl-sum  as decimal.
    define variable v-lvl          as integer.
    define variable p-grp-izl-qnty as decimal.
    define variable p-grp-ned-sum  as decimal.
    define variable p-grp-ned-qnty as decimal.
    define buffer buftt2_temp-doc for temp-doc.
    /*  define variable help-grp-code as integer.*/
    do while v-upper-code <> 0:

        v-upper-code = 0.
        for each temp-doc where temp-doc.grp-lvl =  v-cur-lvl
            and temp-doc.obj-type = obj-list.obj-type 
            and  temp-doc.obj-code = obj-list.obj-code    
            use-index tt-grp
            break by temp-doc.grp-code 
              
            :
            v-ii = v-ii + 1.
  
  
  
                  
            if first-of (temp-doc.grp-code)  then
            do:
                assign
                    p-grp-izl-sum  = 0
                    p-grp-izl-qnty = 0
                    p-grp-ned-sum  = 0 
                    p-grp-ned-qnty = 0.
                  
                find first ub.gds-grp where 
                    ub.gds-grp.node-code = temp-doc.grp-code
                    no-lock no-error.
                      
                if available ub.gds-grp then
                do:
                      
                    /*                      if temp-doc.grp-lvl <> 0 then  temp-doc.lvl-num = gds-grp.lvl-num.*/
                    assign
                      
                        v-gds-name = ub.gds-grp.node-name
                        v-lvl      = gds-grp.lvl-num.
                    v-upper-code = gds-grp.upper-code.
                end.

            end.                 
            assign
                p-grp-izl-sum  = p-grp-izl-sum + temp-doc.izl-sum  /* Количество */
                p-grp-izl-qnty = p-grp-izl-qnty + temp-doc.izl-qnty        /* Сумма без скидки */
                p-grp-ned-sum  = p-grp-ned-sum + temp-doc.ned-sum                 /* Сумма со скидкой */
                p-grp-ned-qnty = p-grp-ned-qnty + temp-doc.ned-qnty            /* Количество покупок*/
                .
                
            /*               temp-doc.upper-code = if  temp-doc.grp-lvl = 0 then temp-doc.grp-code else v-upper-code.*/
                
            if  temp-doc.grp-lvl <> 0 then
            do:
                assign
                    temp-doc.gds-name = v-gds-name
                    /*                    temp-chk.gds-code = string(temp-chk.grp-code) /* Вывод в подитоговой строке для ГРУПП ТОВАРОВ кода этих самых групп (1-е поле таблицы Excel) */*/
                    .
            end.
            /*               if temp-doc.grp-lvl <> 0 then temp-doc.lvl-num = v-lvl.*/
                
           
            if last-of (temp-doc.grp-code) and v-upper-code <> 0  and temp-doc.gds-code <> 0  then  
            do :
         
                /*         message temp-doc.lvl-num "name"    temp-doc.gds-name view-as alert-box.*/
                find first  buftt_temp-doc where 
                    buftt_temp-doc.obj-code = obj-list.obj-code and
                    buftt_temp-doc.obj-type = obj-list.obj-type and 
                    buftt_temp-doc.lvl-num = 2 and 
                    buftt_temp-doc.grp-lvl =  buftt_temp-doc.grp-lvl + 1 and 
                    buftt_temp-doc.grp-code   =  (if temp-doc.grp-lvl = 0 then temp-doc.grp-code
                    else v-upper-code)         
                    and
                    /*              buftt_temp-doc.lvl-num = v-lvl and*/
                    buftt_temp-doc.gds-code = 0 no-error.
             
             
                if not available  buftt_temp-doc  then 
                do:  
                    create buftt_temp-doc .
 
                    assign
                        /*                                         buftt_temp-doc.lvl-num = v-lvl*/
                        buftt_temp-doc.lvl-num  = 2
                        buftt_temp-doc.grp-lvl  = buftt_temp-doc.grp-lvl + 1 
                        buftt_temp-doc.grp-code = (if temp-doc.grp-lvl = 0 then temp-doc.grp-code
                          else v-upper-code)         
                
                        buftt_temp-doc.obj-code = obj-list.obj-code
                        buftt_temp-doc.obj-type = obj-list.obj-type
                        buftt_temp-doc.gds-code = 0.
                end.
                assign 
            
                    buftt_temp-doc.gds-name = v-gds-name
                    buftt_temp-doc.izl-qnty = buftt_temp-doc.izl-qnty + p-grp-izl-qnty
                    buftt_temp-doc.izl-sum  = buftt_temp-doc.izl-sum + p-grp-izl-sum
                    buftt_temp-doc.ned-qnty = buftt_temp-doc.ned-qnty + p-grp-ned-qnty
                    buftt_temp-doc.ned-sum  = buftt_temp-doc.ned-sum +  p-grp-ned-sum . 
            end.
        end. /* temp-chk */
        v-cur-lvl = v-cur-lvl + 1.

    end. /* do while */

    for each buftt2_temp-doc where buftt2_temp-doc.grp-code <> 0  and 
        buftt2_temp-doc.gds-code = 0 and  buftt2_temp-doc.lvl-num = 2 : 
        /*run  gbl/inidebug.p.*/

        for each buftt_temp-doc where buftt_temp-doc.grp-code = buftt2_temp-doc.grp-code and buftt2_temp-doc.grp-lvl <> buftt_temp-doc.grp-lvl and   buftt2_temp-doc.lvl-num = 2 and   buftt_temp-doc.gds-code = 0   : 
                        
                       
            assign
                buftt2_temp-doc.izl-qnty = buftt_temp-doc.izl-qnty + buftt2_temp-doc.izl-qnty
                buftt2_temp-doc.izl-sum  = buftt_temp-doc.izl-sum  +  buftt2_temp-doc.izl-sum 
                buftt2_temp-doc.ned-qnty = buftt_temp-doc.ned-qnty  + buftt2_temp-doc.ned-qnty 
                buftt2_temp-doc.ned-sum  = buftt_temp-doc.ned-sum + buftt2_temp-doc.ned-sum .
            /*                      buftt_temp-chk.gds-name   = v-gds-name  .*/
                        
            delete buftt_temp-doc.
        end.
    end.

end procedure.



procedure tt-lvl:
    
    define input parameter p-grp-code as integer.
    define output parameter hp-grp-code as integer .
    find first gds-grp  no-lock  where gds-grp.node-code = p-grp-code  and gds-grp.upper-code <> 1  no-error.
    
    if available gds-grp then 
    do:
        hp-grp-code = p-grp-code.
        pom-grp = hp-grp-code.

        if gds-grp.upper-code <> 1    then 
        do:
            run tt-lvl(input gds-grp.upper-code, output hp-grp-code).
          
        end.
      
    end.
    else 
    do : 
        hp-grp-code =  pom-grp.
    end.
        
  

end procedure.


procedure proc-create-HTML:    
  
    define input parameter p-file-name-rep-htm as character no-undo.
    define input parameter v-cntxt-host-name-obj as char.
    define input parameter p-report-name as character no-undo.
    define input parameter p-doc-code as char.
    define input parameter p-doc-date as date.
    define input parameter p-object as char.
    define input parameter v-izl-sum as decimal.
    define input parameter v-izl-qnty as decimal.
    define input parameter v-ned-sum as decimal.
    define input parameter v-ned-qnty as decimal.
   
    
    define variable p-number as integer.
    define variable v-number as integer.
    define buffer buf_temp-doc-html for temp-doc.
    p-number = 1 .
    v-number = 1.
    do:  /* Системная шапка HTML */
    
     
     
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
        put stream OutStr-html unformatted
            "<!DOCTYPE HTML>" skip
            ' <html>' skip
            '  <head>' skip
            '   <meta charset="utf-8">' skip
            '    <style type="text/css">' skip
              
            '      table ' + chr(123) + ' border-collapse: collapse; font-size:9pt; font-family:Calibri; table-layout: fixed; width: 540px; hight:  padding: 8px;  ' + chr(125) skip
            '      td ' + chr(123) ' border: 1px black solid; word-wrap:break-word; ' + chr(125) skip
            '      htm' skip
            '      .rotate ' + chr(123) skip
            '        -webkit-transform: rotate(-90deg);' skip
            '        -moz-transform: rotate(-90deg);' skip
            '        -ms-transform: rotate(-90deg);' skip
            '        -o-transform: rotate(-90deg);' skip
            '        transform: rotate(-90deg);' skip


            '        -webkit-transform-origin: 50% 50%;' skip
            '        -moz-transform-origin: 50% 50%;' skip
            '        -ms-transform-origin: 50% 50%;' skip
            '        -o-transform-origin: 50% 50%;' skip
            '        transform-origin: 50% 50%;' skip


            '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
            '          ' + chr(125) skip
            '            th' + ' ' + chr(123) skip
            '            border: 1px black solid;' skip
            '            word-wrap: break-word;' skip
            '          ' + chr(125) skip
            '   </style>' skip
            '  </head>' skip
            . 
    end. 
   
    /*ТИТУЛЬНЫЙ ЛИСТ ОТЧЕТА СЧИТИТЕЛЬНАЯ ВЕДОМОСТЬ*/
    do:
        put stream OutStr-html unformatted

            '     <body>' skip
            '  <A NAME="тит"><H1><EM></EM></H1></A>' skip
            '<TABLE name="тит"  fit_to_page="true" orientation="landscape" CELLSPACING="0" COLS="16" BORDER="0">'skip
            '  <COLGROUP SPAN="10" WIDTH="66">'skip
            ' <COLGROUP WIDTH="30">'skip
            '<COLGROUP WIDTH="110">'skip
            '<COLGROUP SPAN="3" WIDTH="66">'skip
            '<COLGROUP WIDTH="133"></COLGROUP>' skip

  

            '<TR>'skip
            '<TD  style="width: 6px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 79px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 11px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 42px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 56px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 89px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 15px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 63px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 49px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 53px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 9px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 125px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 79px; text-align: left;border: none"></TD>'skip
            '<TD colspan="3" style="text-align: left;border: none"> Унифицированная форма № ИНВ-19</TD>'skip
           
            '</TR>'skip
    
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD colspan="3"style="text-align: left;border: none">Утверждена постановлением Госкомстата</TD>'skip
           
            '</TR>'skip
    
            '<TR>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD colspan = "3" style="text-align: left;border: none"> России от 18.08.98 № 88 </TD>'skip
   
            '</TR>'skip
    
            '<TR>'skip
            '<TD HEIGHT="18" style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="width: 42px; text-align: left;border: none"></TD>'skip
            '<TD  style="width: 73px; text-align: left;border: none"></TD>'skip
            '<TD STYLE="width: 127px; border:  1px solid black; text-align: left;">Код</TD>'skip
            '</TR>'skip
    
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  colspan = "2" style="text-align: right;border: none">Форма по ОКУД</TD>'skip
            '<TD STYLE="border: 1px solid black;text-align: left;">0317017</TD>'skip
            '</TR>'skip
    
            '<TR>'skip
            '<TD COLSPAN="7"  HEIGHT="17" STYLE="border: none; border-bottom: 1px solid black; text-align: center;"> ' + v-cntxt-host-name-obj + '  </TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none">по ОКПО</TD>'skip
            '<TD STYLE="border: 1px solid black;text-align: left;"> 17863254 </TD>'skip
            '</TR>'skip
    
            '<TR>'skip
         
            '<TD colspan="7" style="text-align: center; border: none"> (организация) </TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left; border: none"></TD>'skip
            '<TD STYLE="border: 1px solid black;text-align: left;"></TD>'skip
            '</TR>'skip
    
            '<TR>'skip
    
            '<TD  COLSPAN="7" HEIGHT="17"  STYLE="border: none;border-bottom: 1px solid black; text-align: center;"> ' + p-object  +  '</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD STYLE="border: 1px solid black;text-align: left;"></TD>'skip
            '</TR>'skip
    
            '<TR>'skip
           
            '<TD colspan="7" style="text-align: center;border: none">(структурное подразделение)</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD STYLE="border: 1px solid black;text-align: left;"></TD>'skip
            '</TR>'skip
    
            '<TR>'skip
    
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD STYLE="border: 1px solid black;text-align: left;"></TD>'skip
            '</TR>'skip
    
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD colspan="5" style="text-align: left;border: none">Основание для проведения инвентаризации:</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD COLSPAN=4 style="text-align: left;border: none"> приказ,постановление,распоряжеие</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD STYLE="border: 1px solid black ;text-align: left;">номер</TD>'skip
            '<TD STYLE="border: 1px solid black ;text-align: center;">621-02.6</TD>'skip
            '</TR>'skip
    
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD colspan="3" style="text-align: left;border: none">(ненужное зачеркнуть)</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD STYLE="border: 1px solid black ;text-align: left;">дата</TD>'skip
            '<TD STYLE="border: 1px solid black ;text-align: center;">7.18.2013</TD>'skip
            '</TR>'skip
    
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD STYLE="border: 1px solid black;text-align: left;"></TD>'skip
            '</TR>'skip
            .
    end.
    do:
        put stream OutStr-html unformatted
    
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD colspan="3" style="text-align: left;border: none">Дата начала инвентаризации</TD>'skip
           
            '<TD STYLE="border: 1px solid black ;text-align: center;">' + fnc-DD-MM-YYYY(date(string(X-Date-Start,"99/99/9999"))) + '</TD>'skip
            '</TR>'skip
    
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD colspan="3" style="text-align: left;border: none"> Дата окончания инвентаризации </TD>'skip
            '<TD STYLE="border: 1px solid black ;text-align: center;"> ' + fnc-DD-MM-YYYY(date(string(p-doc-date,"99.99.9999"))) +  '</TD>'skip
            '</TR>'skip
    
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD colspan="2" style="text-align: left;border: none">Вид операции</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD STYLE="border: 1px solid black ;text-align: center;"> инвентаризация </TD>'skip
            '</TR>'skip
    
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
    
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
    
            '<TR>'skip
            '<TD HEIGHT="18" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none">Номер документа:</TD>'skip
            '<TD colspan="2" style="text-align: left;border: none">Дата составления</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            .
        
    end.
    
    
    
    do:  /* Титульный лист отчета */
        put stream OutStr-html unformatted
            '<TR>'skip
            '<TD HEIGHT="19" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            /*            '<TD style="text-align: left;border: none"></TD>'skip*/
            '<TD colspan = "5" style="font-weight: bold; text-align: left; border: none"> СЛИЧИТЕЛЬНАЯ ВЕДОМОСТЬ</TD>'skip
            '<TD STYLE="border: 1px solid black; text-align: left;"> ' +  p-doc-code + '</td>' skip
            '<TD colspan="2" STYLE="border: 1px solid black; text-align: left;"> ' + fnc-DD-MM-YYYY(date(string(p-doc-date,"99.99.9999"))) + '</td>' skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD colspan ="9" style="font-weight: bold; text-align: left; border: none">результатов инвентаризации товарно-материальных ценностей</TD>'skip
            /*        '<TD style="text-align: left;border: none"></TD>'skip*/
            /*        '<TD style="text-align: left;border: none"></TD>'skip*/
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD colspan="12" style="text-align: left;border: none">Проведена инвентаризация фактического наличия ценностей, находящихся на ответственном хранении</TD>'skip
            /*            '<TD style="text-align: left;border: none"></TD>'skip*/
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            
            '<TR>'skip
            /*            '<TD HEIGHT="17" style="text-align: left; border-bottom: 1px solid black;"></TD>'skip*/
            /*            STYLE="border-bottom: 1px solid black;   text-align: center;"*/
            '<TD colspan="4" style="text-align: center; border: none;border-bottom: 1px solid black;"> Ст. оператор </TD>'skip
            /*            '<TD STYLE="border-bottom: 1px solid black;  text-align: left;"></TD>'skip*/
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD COLSPAN="3" STYLE="border: none;border-bottom: 1px solid black;  text-align: center;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '</TR>'skip
            
            '<TR>'skip
            /*            '<TD  HEIGHT="17" STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip*/
            '<TD colspan= "4" STYLE="border: none;border-bottom: 1px solid black; text-align: center;">(должность)</TD>'skip
            '<TD STYLE="text-align: left; border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD colspan="4" style="text-align: center;border: none;">(фамилия, имя, отчество)</TD>'skip
            /*            '<TD style="text-align: left;border: none"></TD>'skip*/
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '</TR>'skip
            
            
            '<TR>'skip
            /*            '<TD  HEIGHT="17" STYLE=" border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip*/
            '<TD colspan="4" style="text-align: center; border: none;border-bottom: 1px solid black;"> оператор </TD>'skip
            /*            '<TD STYLE="border: none;border-bottom: 1px solid black;  text-align: left;"></TD>'skip*/
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD COLSPAN="3" STYLE="border: none; border-bottom: 1px solid black;  text-align: center;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            
            '</TR>'skip
            
            '<TR>'skip
            /*            '<TD STYLE="border: none ; border-top: 1px solid black; text-align: left;"></TD>'skip*/
            '<TD colspan="4" STYLE="border: none ; text-align: center;"> (должность)</TD>'skip
            /*          '<TD STYLE="border: none ; border-top: 1px solid black; text-align: left;"></TD>'skip*/
            '<TD STYLE="text-align: left; border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD colspan= "4" style="text-align: center;border: none">(фамилия, имя, отчество)</TD>'skip
            /*              '<TD style="text-align: left;border: none"></TD>'skip*/
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
     
            '</TR>'skip
            
            '<TR>'skip
            '<TD  HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip.
    end.
    do:  /* Титульный лист отчета */
        put stream OutStr-html unformatted
            '<TR>'skip
            '<TD  HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD COLSPAN=9 style="text-align: left;border: none"> по состоянию на 1 Августа 2013 г. </TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
        
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD colspan="6"style="text-align: left;border: none"> При инвентаризации установлено следующее:</TD>'skip
            /*         '<TD style="text-align: left;border: none"></TD>'skip*/
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</tr>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            .
               
    end.
    do: 
        put stream OutStr-html unformatted
            '</tbody>'
            '   </table>' skip
            '  </body>' skip.
    end.

    do:  /* Параметры "глобальной" таблицы отчёта */
        put stream OutStr-html unformatted
            ' <body>' skip
            '   <table name="Слич"  outline_below="false" orientation="landscape">' skip
            '     <thead>' skip
            '       <tr class="set_columns">' skip                          
            '         <td style="width:20px; border: none;"></td>' skip 
            '         <td style="width:135px; border: none;"></td>' skip 
            '         <td style="width:48px; border: none;"></td>' skip 
            '         <td style="width:25px; border: none;"></td>' skip 
            '         <td style="width:39px; border: none;"></td>' skip 
            '         <td style="width:35px; border: none;"></td>' skip 
            '         <td style="width:30px; border: none;"></td>' skip 
            '         <td style="width:47px; border: none;"></td>' skip 
            '         <td style="width:65px; border: none;"></td>' skip 
            '         <td style="width:47px; border: none;"></td>' skip 
            '         <td style="width:65px; border: none;"></td>' skip 
            '         <td style="width:40px; border: none;"></td>' skip 
            '         <td style="width:40px; border: none;"></td>' skip 
            '         <td style="width:40px; border: none;"></td>' skip 
            '         <td style="width:34px; border: none;"></td>' skip 
            '         <td style="width:37px; border: none;"></td>' skip 
            '         <td style="width:43px; border: none;"></td>' skip 
     
     
            '         <td style="width:45px; border: none;"></td>' skip 
            '         <td style="width:52px; border: none;"></td>' skip 
                           
            '         <td style="width: 55px; border: none;"></td>' skip 
            '         <td style="width: 53px; border: none;"></td>' skip    
            '         <td style="width: 50px; border: none;"></td>' skip 
            '         <td style="width: 55px; border: none;"></td>' skip 
                             
            '         <td style="width: 50px; border: none;"></td>' skip 
            '         <td style="width: 50px; border: none;"></td>' skip 
            '         <td style="width: 46px; border: none;"></td>' skip 
            '         <td style="width: 45px; border: none;"></td>' skip 
            '         <td style="width: 50px; border: none;"></td>' skip 
            '         <td style="width: 45px; border: none;"></td>' skip  
            '         <td style="width: 50px; border: none;"></td>' skip 
            '         <td style="width: 50px; border: none;"></td>' skip 
            '         <td style="width: 50px; border: none;"></td>' skip                               
      
            
            '       </tr>' skip
            .
             
    end.
    

    do:  /* Шапка таблицы отчёта (видимой, как таблица) */
        put stream OutStr-html unformatted
            '     <tbody>' skip
            '       <tr style="height: 30px;">' skip
            '         <th   style="background-color:#ffffcc; font-size:9pt; text-align: center;">№</th>' skip
            '         <th   colspan="2"  style="background-color:#ffffcc; font-size:9pt; text-align: center;">Товарно материальные ценности</th>' skip
            '         <th colspan="2"  style="background-color:#ffffcc; font-size:9pt;text-align: center;">Единица </th>' skip
            '         <th  colspan="2" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Номер</th>' skip
            '         <th  colspan="4"  style="background-color:#ffffcc;font-size:9pt; text-align: center;">Результат инвентаризации</th>' skip
            '         <th colspan="6" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Отрегулировано за счет уточнения записей в учете</th>' skip
            '         <th  colspan="6" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Пересортица</th>' skip
            '         <th  colspan="3" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Приходуются</th>' skip
            '         <th  colspan="6" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Окончательные недостачи</th>' skip
              
                   
            '</tr >'   skip    
            '<tr style="height: 125px;">' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> </th>' skip
          
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;">наименование,характеристика(вид, сорт, группа)</th>' skip
           
            '         <th  style="background-color:#ffffcc; font-size:9pt; text-align: center;">код(номенклатурный номер)</th>' skip
            '         <th  style="background-color:#ffffcc; font-size:9pt; text-align: center;">код по ОКЕИ</th>' skip             
            '         <th  style="background-color:#ffffcc; font-size:9pt; text-align: center;">наименование</th>' skip
            '         <th style="background-color:#ffffcc;  font-size:9pt; text-align: center;">инвентарный</th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt;  text-align: center;">паспорта (документа о регистрации)</th>' skip
            '         <th colspan = "2" style="background-color:#ffffcc; font-size:9pt;  text-align: center;">излишек</th>' skip
            '         <th colspan = "2" style="background-color:#ffffcc; font-size:9pt; text-align: center;">недостача</th>' skip
            '         <th colspan = "3" style="background-color:#ffffcc; font-size:9pt; text-align: center;">излишек</th>' skip
            '         <th colspan = "3" style="background-color:#ffffcc; font-size:9pt; text-align: center;">недостача</th>' skip
            '         <th colspan = "3" style="background-color:#ffffcc; font-size:9pt; text-align: center;">излишки, зачтенные в покрытие недостач</th>' skip
            '         <th colspan = "3" style="background-color:#ffffcc;  font-size:9pt; text-align: center;">недостачи, покрытые излишками</th>' skip
            '         <th colspan = "3" style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip
            '         <th colspan = "2" style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip
            '         <th colspan = "2" style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip
            '         <th colspan = "2" style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip
            '</tr>'skip

            '<tr style="height: 112px;">' skip


            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> </th>' skip
          
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip
           
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip
            '         <th style="background-color:#ffffcc;  font-size:9pt;text-align: center;"></th>' skip             
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip

            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество</th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб. коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб. коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб. коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> номер счета,статьи,заказа </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб. коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> номер счета,статьи,заказа </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб. коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> порядковый номер зачтенных излишков </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб. коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> порядковый номер зачтенных излишков </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб. коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> номер счета </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб.коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб.коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб.коп. </th>' skip                    
                                                           
            '</tr>'skip
  

                     
            '       <tr>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">1</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">2</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">3</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">4</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">5</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">6</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">7</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">8</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">9</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">10</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">11</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">12</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">13</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">14</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">15</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">16</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">17</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">18</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">19</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">20</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">21</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">22</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">23</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">24</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">25</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">26</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">27</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">28</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">29</th>' skip 
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">30</th>' skip  
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">31</th>' skip  
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">32</th>' skip                         
            '       </tr>' skip.
            
       
            
        output stream OutStr-html close.
    
             
    end.  
                                                                                                           
    do:    
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
    
        find first buf_temp-doc-html no-lock no-error.
        if not error-status:error and available buf_temp-doc-html then
        do:
            for each buf_temp-doc-html where buf_temp-doc-html.gds-code > 0 no-lock
                by buf_temp-doc-html.obj-type by buf_temp-doc-html.obj-code
                :
                /*            where                                                                          */
                /*                buf-html-temp-chk.grp-code = 0 and buf-html-temp-chk.upper-code = 0 no-lock*/
                /*                by buf-html-temp-chk.obj-type by buf-html-temp-chk.obj-code                */
    
                put stream OutStr-html unformatted
                    '       <tr level="1">' skip
                    '         <td  style="display: yes; font-size:9pt; text-align: left">' + if p-number <> ? then fnc-convert-dot-to-colon( p-number, "->>>>>>>9")   + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  left">'  + buf_temp-doc-html.gds-name +  '</td>'  skip
                    '         <td style="display: yes; font-size:9pt; text-align:  left">'   + if buf_temp-doc-html.gds-code <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.gds-code, "->>>>>>>9")   + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  left">'   + if buf_temp-doc-html.OKEI <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.okei, "->>>>>>>9")  + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  left">'    +  buf_temp-doc-html.unit-name + '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  left">'  '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'    + if buf_temp-doc-html.izl-qnty <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.izl-qnty, "->>>>>>>9.99")  + '</td>' else "?" + '</td>' skip 
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'   + if buf_temp-doc-html.izl-sum <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.izl-sum, "->>>>>>>9.99")  + '</td>' else "?" + '</td>' skip 
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'   + if buf_temp-doc-html.ned-qnty <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.ned-qnty, "->>>>>>>9.99")  + '</td>' else "?" + '</td>' skip      
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'  + if buf_temp-doc-html.ned-sum <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.ned-sum, "->>>>>>>9.99")  + '</td>' else "?" + '</td>' skip 
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip         
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'  '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip     
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'  '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip      
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'  '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip        
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'  '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip         
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'  '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip  
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip 
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip  
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip 
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip  
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip 
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip  
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip 
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip  
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip 
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip            
                    '       </tr>' skip
                    .
                p-number = p-number + 1.
            end.   
        end.   
                
    end.
    do:
        put stream OutStr-html unformatted
 
            ' <body>' skip
            '     <thead>' skip
            '<tr>' skip
            '<TD style="text-align:  left; font-size:9pt;border: none"></TD>'skip
            '<TD style="text-align:  left; font-size:9pt; border: none"> Итого:</TD>'skip
            '<TD style="text-align:  left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align:  left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align:  left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align:  left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align:  left; font-size:9pt; border: none"></TD>'skip
            '         <td style=" text-align: right; font-size:9pt; border: 1px solid black;"> '+ if v-izl-qnty <> ? then fnc-convert-dot-to-colon( v-izl-qnty, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
            '         <td style=" text-align: right; font-size:9pt; border: 1px solid black;">'+ if v-izl-sum <> ? then fnc-convert-dot-to-colon( v-izl-sum, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
            '         <td style=" text-align: right; font-size:9pt; border: 1px solid black;">'+ if v-ned-qnty <> ? then fnc-convert-dot-to-colon( v-ned-qnty, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
            '         <td style=" text-align: right; font-size:9pt; border: 1px solid black;">'+ if v-ned-sum <> ? then fnc-convert-dot-to-colon( v-ned-sum, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '       </tr>' skip
         
            '<tr>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '       </tr>' skip
         
         
            '<tr>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td colpan = "3" style="border: none;  font-size:9pt; text-align: right;"> Бухгалтер:  </td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <TD STYLE="border: none; border-bottom: 1px solid black;  font-size:9pt; text-align: left;"></TD>'skip
            '         <TD STYLE="border: none; border-bottom: 1px solid black; font-size:9pt;  text-align: left;"></TD>'skip
            '         <TD STYLE="border: none; border-bottom: 1px solid black; font-size:9pt;  text-align: left;"></TD>'skip
            '         <TD STYLE="border: none; border-bottom: 1px solid black; font-size:9pt;  text-align: left;"></TD>'skip
            '         <td colspan = "2" style="border: none; font-size:9pt;  text-align: center;"> </td>' skip
            '         <td style="border: none; font-size:9pt;  text-align: center;"></td>' skip
            '         <td style="border: none; font-size:9pt;  text-align: center;"></td>' skip
            '         <td colspan = "5" style="border: none; font-size:9pt;  text-align: left;">Материально ответственное(ые) лицо(а)</td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '       </tr>' skip
            '<tr>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '       </tr>' skip
            '<tr>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '       </tr>' skip.
         
    end.  
    do: 
        put stream OutStr-html unformatted
            
            
            '  </body>' 
            '</thead>'skip.
    end.
         
         
     
    do:  /* Шапка таблицы отчёта (ИТОГИ ПО ГРУППАМ) */
        put stream OutStr-html unformatted


            '     <tbody>' skip
            '       <tr>' skip
            '         <th    style="background-color:#ffffcc;  font-size:9pt; text-align: center;">№</th>' skip
            '         <th    colspan = "2" rowspan = "3" style="background-color:#ffffcc;  font-size:9pt; text-align: center;">Группа</th>' skip
            '         <th    colspan = "8"  style="background-color:#ffffcc;  font-size:9pt; text-align: center;">Результаты инвентаризации</th>' skip
            '       </tr>' skip
 
            '       <tr>' skip
            '         <th      style="background-color:#ffffcc;  font-size:9pt; text-align: center;"></th>' skip
            '         <th     colspan = "5" style="background-color:#ffffcc; font-size:9pt;  text-align: center;">излишек</th>' skip
            '         <th     colspan = "3" style="background-color:#ffffcc; font-size:9pt;  text-align: center;">недостача</th>' skip
            '       </tr>' skip
 
            '       <tr>' skip
            '         <th     style="background-color:#ffffcc; font-size:9pt;  text-align: center;"></th>' skip
            '         <th    colspan = "2" style="background-color:#ffffcc;  font-size:9pt; text-align: center;">количество</th>' skip
            '         <th   colspan = "3"  style="background-color:#ffffcc;  font-size:9pt; text-align: center;">сумма,руб. коп.</th>' skip
            '         <th     style="background-color:#ffffcc;  font-size:9pt; text-align: center;">количество</th>' skip
            '         <th   colspan = "2"  style="background-color:#ffffcc;  font-size:9pt; text-align: center;">сумма,руб. коп.</th>' skip
            '       </tr>' skip
                       
                       
            '       <tr>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt;  text-align: center">1</th>' skip
            '         <th colspan = "2"num="" style="background-color:#ffffcc; font-size:9pt;  text-align: center">2</th>' skip
            '         <th colspan = "2" num="" style="background-color:#ffffcc;  font-size:9pt; text-align: center">3</th>' skip
            '         <th  colspan = "3" num="" style="background-color:#ffffcc;  font-size:9pt; text-align: center">4</th>' skip
            '         <th num="" style="background-color:#ffffcc;  font-size:9pt; text-align: center">5</th>' skip
            '         <th colspan = "2"  num="" style="background-color:#ffffcc;  font-size:9pt; text-align: center">6</th>' skip
            '       </tr>' skip
                     
            .
  
    end.
    
    
    
    do:
      

        find first buf_temp-doc-html no-lock no-error.
        if not error-status:error and available buf_temp-doc-html then
        do:
            for each buf_temp-doc-html  where buf_temp-doc-html.lvl-num = 2 no-lock
                break by  buf_temp-doc-html.grp-code
                :
                if last-of(buf_temp-doc-html.grp-code) then 
                do:
    
                    put stream OutStr-html unformatted
                        '       <tr level="1">' skip
                        '         <td  style="display: yes;  font-size:9pt; text-align: left">' + if v-number <> ? then fnc-convert-dot-to-colon( v-number, "->>>>>>>9")   + '</td>' else "?" + '</td>' skip
                        '         <td colspan = "2" style="display: yes;  font-size:9pt; text-align:  right">'  + buf_temp-doc-html.gds-name +  '</td>'  skip
                        '         <td colspan = "2" style="display: yes; font-size:9pt;  text-align:  right">'    + if buf_temp-doc-html.izl-qnty <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.izl-qnty, "->>>>>>>9.99")  + '</td>' else "?" + '</td>' skip 
                        '         <td  colspan = "3" style="display: yes; font-size:9pt;  text-align:  right">'   + if buf_temp-doc-html.izl-sum <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.izl-sum, "->>>>>>>9.99")  + '</td>' else "?" + '</td>' skip 
                        '         <td style="display: yes; font-size:9pt;  text-align:  right">'   + if buf_temp-doc-html.ned-qnty <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.ned-qnty, "->>>>>>>9.99")  + '</td>' else "?" + '</td>' skip      
                        '         <td colspan = "2" style="display: yes; font-size:9pt;  text-align:  right">'  + if buf_temp-doc-html.ned-sum <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.ned-sum, "->>>>>>>9.99")  + '</td>' else "?" + '</td>' skip 
                        '       </tr>' skip
                        .
                    v-number = v-number + 1.
                end.
            end.
        end.
    end.
    

               
    do: 
        put stream OutStr-html unformatted
            '     </tbody>' skip
            '   </table>' skip
            '  </body>' skip
            ' </html>' skip
            . /* Точка для закрытия Put */
        output stream OutStr-html close.
    end. 
                                                                                              
end procedure.

procedure get-full-path-RepViewer:  /* Получение полного пути к исполняемому файлу RV.exe (output Полный_путь_имя_файла_RV.exe) */
    /* Получение полного пути к exe-файлу просмотровщика отчётов */
    define output parameter p-fill-path-RepView as character no-undo.

    if search("exe\ReportViewer\reportviewer.exe") <> ? then
    do:
        p-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
    end.
    else
    do:
        message "Не найдена программа просмотра отчёта!" view-as alert-box error.
    end.
end procedure.


procedure search-full-path-Report:  /* Только проверка, есть файл отчёта HTML или нет(тогда вывод сбщ-ош) */
    /* Поиск файла */
    define input parameter p-file-name as character no-undo.

    if search(p-file-name) = ? then
    do:
        message "Не найден файл отчёта: " p-file-name view-as alert-box error.
    end.
    else
    do:
        p-file-name = search(p-file-name).
    end.

end procedure.


procedure create-file:              /* СоздЛюбогоФайлаНаДиске(input полный_путь_с_именем) */
    /* Создание пустого файла (во входном параметре: полный путь и имя файла) */
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.

end procedure.


procedure define-full-path-Report:  /* Получение полного пути к отчёту html (input №Отчёта, output Полный_путь_имя_файла_отчHTML) */
    /* Получение полного пути к отчёту html */
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.

    p-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(p-rep-num) + ".html".

end procedure.


procedure Report-Viewer:            /* Запуск на выполнение RV (input Полный_путь_имя_файла_RV, input Полный_путь_имя_файла_отчHTML) */
    /* Запуск программы "Просмотровщик Отчётов" - ReportViewer. */
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.

    os-command no-wait value(p-full-path-RepView + " true " + search(p-file-name-rep-htm)).

end procedure.


function fnc-DD-MM-YYYY returns character 
    (input p-dat-date as date):
    /* Преобразование даты в формат: "01.01.2014" */

    define variable result     as character no-undo.
    define variable p-str-date as character no-undo.

    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").

    return p-str-date.

end function.





function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character):
    /* Конвертация десятичной точки в запятую с передачей параметра форматирования числа (accuracy - точность) */

    define variable result       as character no-undo.
    define variable v-str-result as character no-undo.
    /*message "dbg-p-data = " p-data skip "p-accur = " p-accur view-as alert-box.*/
    p-data = round(p-data, 2). /* Чтобы не выйти случайно за рамки формата числа при выводе (несоотвесвие формата результата и формата отображения - приводит к ош) */
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).

    return v-str-result.

end function.
