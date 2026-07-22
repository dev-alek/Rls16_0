block-level on error undo, throw.
/*

$Revision: 842df30dc91c, 1422, test $
$Author: EShklyar $
$Date: Пт июн 29 17:59:55 2018 +0300 $
$Workfile: alcmarks.p $
$Archive: utl/alcmarks.p $

Утилита проверки целостности свободной зоны марок и восстановления

Автор: Шкляр Елена
Дата создания: 07/23/08
Author: Elena Shklyar
Creation date: 07/23/08

*/

define variable vss-revision    as character no-undo initial "$Revision: 842df30dc91c, 1422, test $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Пт июн 29 17:59:55 2018 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: alcmarks.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/alcmarks.p $":U .
define variable vss-description as character no-undo initial "Утилита проверки целостности свободной зоны марок и восстановления".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/str-glbl.i }
{ bge/egais-mark.i }
    { gbl/key-rec.i  }
    { cmp/r-page1.i  }
    { ref/grplibfn.i }
    { ref/gds-attr.i }
{ str/marks.i    }

    define buffer buf_parts    for ub.parts .
    define buffer buf_goods    for ub.goods .
    define buffer buf_trn-doc  for ub.trn-doc .
    define buffer buf_doc-line for ub.doc-line .
    define buffer bf_parts     for ub.parts .
    define buffer bp_parts     for ub.parts .
    define buffer bf_trn-doc   for ub.trn-doc .
    define buffer bf_doc-line  for ub.doc-line .
    define buffer buf_gen-attr for ub.gen-attr .
    define buffer buf_obj-list for obj-list.
    define buffer buf_gds-list for gds-list.
    
    define VARIABLE v-count-mark              as INTEGER   no-undo .
    define VARIABLE v-alc-code                as character no-undo .
    define variable v-parts-income            as character no-undo .
    define variable v-parts-expence           as character no-undo .
    define variable v-parts-free              as character no-undo .
    define variable hndl-proc-egais-marks-lib as handle.
    define VARIABLE v-mark                    as character no-undo .
    /*    define VARIABLE v-marks-income            as character no-undo .*/
    /*    define VARIABLE v-marks-expence           as character no-undo .*/
    /*    define VARIABLE v-marks-free              as character no-undo .*/
    define VARIABLE v-rezerv                  as integer   no-undo .
    define VARIABLE ii                        as integer   no-undo .
    define VARIABLE jj                        as integer   no-undo .
    define VARIABLE v-in-code                 as character no-undo .
    define variable v-txt-name                as character no-undo initial 'log-marks.txt'. /* Имя лога */
    define VARIABLE v-attr-value              as character no-undo .
    define VARIABLE v-value                   as character no-undo .
    
    define stream str-marks .

    define temp-table tt-marks like ub.gen-attr .
    define buffer buf_tt-marks for tt-marks .
    /*    define temp-table   tt-marks-expence            like ub.gen-attr .    */
    /*    define buffer       buf_tt-marks-expence        for tt-marks-expence .*/
    define temp-table tt-marks-free like ub.gen-attr .
    define buffer buf_tt-marks-free for tt-marks-free .
    define temp-table tt-goods like ub.goods .
    define buffer buf_tt-goods for tt-goods . 
    
    output stream str-marks to value(v-txt-name)   .
    /*определение товара*/
    
    case X-selectgood:
        when {&g-grp} then
            do:
                define variable v-curr-grp-name as character no-undo .
                for each tmp#grp no-lock
                    :
                    run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
                    for each buf_goods no-lock where buf_goods.grp-name begins v-curr-grp-name:

                        RUN gds-attr-value (
                            INPUT buf_goods.gds-code,
                            INPUT {&attr-alcohol-prod},
                            OUTPUT v-attr-value,
                            OUTPUT v-value
                            ).
                        if v-attr-value = "yes" then 
                        do:
                            create tt-goods .
                            buffer-copy buf_goods to tt-goods no-error.
                            v-attr-value = "no" .  
                        end.  
                    end.
                end.
            end.
        when {&g-all} then
            do:
                for each buf_goods no-lock :
                    RUN gds-attr-value (
                        INPUT buf_goods.gds-code,
                        INPUT {&attr-alcohol-prod},
                        OUTPUT v-attr-value,
                        OUTPUT v-value
                        ).
                    if v-attr-value = "yes" then 
                    do:
                        create tt-goods .
                        buffer-copy buf_goods to tt-goods no-error.
                        v-attr-value = "no" .
                    end.
                end.                
            end.

        when {&g-choice} or 
        when {&g-one} then                                          
            do:                                                                             
                for each buf_gds-list no-lock :
                    RUN gds-attr-value (
                        INPUT buf_gds-list.gds-code,
                        INPUT {&attr-alcohol-prod},
                        OUTPUT v-attr-value,
                        OUTPUT v-value
                        ).
                    if v-attr-value = "yes" then 
                    do:
                        create tt-goods .
                        buffer-copy buf_gds-list to tt-goods no-error.
                        v-attr-value = "no" .
                    end.
                end.    
            end.                                                                            
    end case.
    

    for each buf_obj-list,
        each buf_tt-goods
        :
            
        /*поиск свободных партий*/
        for each buf_parts no-lock where buf_parts.artic = buf_tt-goods.artic
            and buf_parts.prod-code = buf_tt-goods.prod-code
            and buf_parts.prod-type = buf_tt-goods.prod-type
            and buf_parts.obj-code = buf_obj-list.obj-code
            and buf_parts.obj-type = buf_obj-list.obj-type
            and buf_parts.out-code = {&free-code}: 
            find FIRST buf_trn-doc where buf_trn-doc.doc-code = buf_parts.in-code
                and buf_trn-doc.doc-type = {&income} no-error .
            if AVAILABLE buf_trn-doc then 
            do:                            
                for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_parts.in-code
                    and buf_doc-line.artic = buf_parts.artic
                    and buf_doc-line.prod-code = buf_parts.prod-code
                    and buf_doc-line.prod-type = buf_parts.prod-type:
                    /*                            v-count-mark = buf_doc-line.fact-qnty .*/
                    find first bp_parts no-lock where bp_parts.in-code =  buf_doc-line.doc-code 
                        and bp_parts.out-code = buf_doc-line.doc-code no-error .
                    if AVAILABLE bp_parts then 
                    do:                                                          
                        run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                            ,input (buffer bp_parts:handle)
                            ,output v-parts-income).
                        /*Ищем марки в партии*/  
                        jj = 0 .  
                        for each buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}
                            and buf_gen-attr.p-key  = v-parts-income :
                            find first tt-marks where tt-marks.p-key = buf_gen-attr.p-key
                                and tt-marks.attr-code = buf_gen-attr.attr-code
                                and tt-marks.table-name = buf_gen-attr.table-name
                                and tt-marks.whole-send-news = buf_gen-attr.whole-send-news no-error .  
                            if not AVAILABLE tt-marks then 
                            do:
                                create tt-marks .
                                buffer-copy buf_gen-attr to tt-marks .
                                jj = jj + 1.          
                            end.
                        end.             
                                       
                    end. /*if AVAILABLE bp_parts then do:*/
                    
                    /*Проверка на соответствии марок и товаров в партии*/                            
                    if jj <> buf_doc-line.fact-qnty then 
                    do:
                        put stream str-marks unformatted
                            substitute ("В ПН &1 кол-во товара &2 не соответствует кол-ву марок" 
                            , buf_doc-line.doc-code
                            , buf_doc-line.artic
                            , jj )
                            skip .
                    
                    end.    
                                
                    if jj <> 0 then 
                    do:

                        for each bf_parts no-lock where bf_parts.in-code = buf_parts.in-code
                            and bf_parts.out-code <> {&free-code}: 
                            find FIRST bf_trn-doc where bf_trn-doc.doc-code = bf_parts.out-code
                                and bf_trn-doc.doc-type = {&expense} no-error .
                            if AVAILABLE bf_trn-doc then 
                            do:                            
                                for each bf_doc-line no-lock where bf_doc-line.doc-code = bf_trn-doc.doc-code
                                    and bf_doc-line.artic = bf_parts.artic
                                    and bf_doc-line.prod-code = bf_parts.prod-code
                                    and bf_doc-line.prod-type = bf_parts.prod-type:

                                    run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                                        ,input (buffer bf_parts:handle)
                                        ,output v-parts-expence).
                                    /*Ищем марки в расходах*/
                                    for each buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}
                                        and buf_gen-attr.p-key  = v-parts-expence :
                                                                                                                                  
                                        /*Удаляем марки, которые есть в расходе из темповой таблицы*/
                                        find first buf_tt-marks where buf_tt-marks.attr-code = buf_gen-attr.attr-code no-error.
                                        if AVAILABLE buf_tt-marks then 
                                        do:
                                            delete buf_tt-marks .
                                        end.
                                        else 
                                        do:
                                            put stream str-marks unformatted
                                                substitute ("В ПН &1 нет марки &2 из расхода &3" 
                                                , buf_doc-line.doc-code
                                                , buf_gen-attr.attr-code
                                                , bf_doc-line.doc-code )
                                                skip .
                                        end.        
                                    end.   

                                    run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                                        ,input (buffer buf_parts:handle)
                                        ,output v-parts-free).
                                    /*Ищем марки в свободной зоне*/
                                    for each buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}
                                        and buf_gen-attr.p-key  = v-parts-free :
                                        /*Удаляем марки, которые есть в свободной зоне из темповой таблицы*/
                                        find first buf_tt-marks where buf_tt-marks.attr-code = buf_gen-attr.attr-code no-error.
                                        if AVAILABLE buf_tt-marks then 
                                        do:
                                            delete buf_tt-marks .
                                        end.
                                        else 
                                        do:
                                            put stream str-marks unformatted
                                                substitute ("В free-zone есть марка &1, которой нет в ПН и в РН" 
                                                , buf_tt-marks.attr-code )
                                                skip .
                                        end.        
                                            

                                        for each buf_tt-marks :
                                            put stream str-marks unformatted
                                                substitute ("В ПН есть марка, которой нет ни в РН и в free-zone" 
                                                , buf_tt-marks.attr-code )
                                                skip .
                                        end.   
                                    end.    
                                end. /*for each bf_doc-line no-lock where bf_doc-line.doc-code = bf_parts.in-code*/             
                            end. /*if AVAILABLE bf_trn-doc then */
                        end. /*for each bf_parts no-lock where buf_parts.in-code = entry(ii, v-in-code, ";")*/ 
                            
                    end. /*if jj <> 0 then do:*/
            
                end. /*for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_parts.in-code*/      
            end. /*if AVAILABLE buf_trn-doc then do: */
        end. /*for each buf_parts no-lock where buf_parts.artic = buf_goods.artic*/
    end.
    output stream str-marks close.
    MESSAGE "Проверка завершена"
        VIEW-AS ALERT-BOX.
             