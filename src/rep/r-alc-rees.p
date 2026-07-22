/*

$Revision: 7596fb7dbb2f, 3446, rls $
$Author: EShklyar $
$Date: 2023/10/16 15:13:33 $
$Workfile: r-alc-rees.p $
$Archive: rep/r-alc-rees.p $

Реестр документов ЕГАИС

Автор: Шаланин Сергей
Дата создания: 11/04/16
Author: Shalanin Sergey
Creation date: 11/04/16


*/
using ibs.th.bge.egais.*.
block-level on error undo, throw.


define variable vss-revision    as character no-undo init "$Revision: ":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:33 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-alc-rees.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-alc-rees.p $":U .
define variable vss-description as character no-undo init "Реестр документов ЕГАИС".


{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  } /* Внутри вложен { cmp/obj-list.i {1}}, в котором формируется таблица obj-list. */
{ cmp/r-pril.i new  } 
{ gbl/attr-lib.i }
{ ref/extclass.i }
{ gbl/thbjattr.i }
{ibs/th/bge/egais/wb-egais.i}
{ gbl/prn-lib.i }

define input parameter p-column-list as character no-undo.

define variable parParentProc         as widget-handle no-undo.

DEFINE VARIABLE v-file-name           AS CHARACTER     NO-UNDO .
DEFINE VARIABLE g#report-num          AS INTEGER       NO-UNDO.

define variable qh-wb-egais           as handle        no-undo.


define variable v-cntxt-host-name-obj as character     no-undo .
define variable v-report-name         as character     no-undo.         /* Наименование отчёта */
define variable v-period              as character     no-undo.              /* Период за который формируется отчёт */
define variable v-short-obj-list      as character     no-undo.      /* Перечень выбранных объектов "в одну строку" */
define variable v-choice-gds          as character     no-undo. /* Список выбранных товаров. Вывод - в шапке отчёта */
define variable v-choice-obj          as character     no-undo. /* Выбранный пользователем параметр "Выбор объекта" (в окне параметров). Вывод в шапке отчёта */
define variable v-full-path-RepView   as character     no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm   as character     no-undo.   /* Полный путь к файлу отчёта */
define variable v-par-type            as character     no-undo.

define variable v-col1                as logical       no-undo init no.
define variable v-col2                as logical       no-undo init no.
define variable v-col3                as logical       no-undo init no.
define variable v-col4                as logical       no-undo init no.
define variable v-col5                as logical       no-undo init no.
define variable v-col6                as logical       no-undo init no.
define variable v-col7                as logical       no-undo init no .
define variable v-col8                as logical       no-undo init no .
define variable v-col9                as logical       no-undo init no .
define variable v-col10               as logical       no-undo init no .
define variable v-col11               as logical       no-undo init no .
define variable v-col12               as logical       no-undo init no.

DEFINE VARIABLE v-search              AS CHARACTER.

define variable v-value-character     as character     no-undo .
define variable v-value-decimal       as decimal       no-undo .
define variable v-value-integer       as integer       no-undo .
define variable v-value-logical       as logical       no-undo .
define variable v-value-type          as character     no-undo .
define variable v-value-date          as date          no-undo .
define variable v-ext-sys             as integer       no-undo .

define variable v-price               as decimal       no-undo.
define variable v-fs-rar              as character     no-undo .
define stream  macr_excel .
define stream  out-stream .
define stream OutStr-html.

define variable egaisWB as class WayBill no-undo.


/* ************************  Function Implementations ***************** */
function fnc-DD-MM-YYYY returns character 
    (input p-dat-date as date) forward.

function fnc-convert-dot-to-colon returns character 
    (input p-data as decimal, input p-accur as character) forward.
/* ***************************  Main Block  *************************** */
define variable bh-wb-gds-EG-header as handle no-undo.
define variable bh-wb-gds-EG        as handle no-undo.

define buffer buf_trn-doc   for trn-doc.
define buffer buf_clob-bind for clob-bind.
define buffer buf_clients   for clients.
define temp-table alc-rees no-undo
    field num          as character /* "№ накл." format "X(50)" */
    field wb-date      as date      /* "Дата" */
    field obj          as character /* "Объект" */
    field shippregid   as character /*  "ID поставщика" format "x(21)" */
    field cli          as character /*  "Контрагент" format "x(30)" */
    field cliname      as character  /*  "Название контрагента" format "x(30)" */
    field wb-type      as character  /*  "Тип" format "x(20)" */
    field trn-doc-code as character  /*  "№ накл. TH" */
    field status_      as character  /* "Статус" format "x(20)" */
    field is-sent      as character /* "Отправлена" */
    field wbregid      as character  /* "ID EGAIS" format "X(50)" */
    field Identity     as character /* "X(50)" */
    field uniq-key-rec as character /*  "X(50)" */
    field obj-type     as char
    field obj-code     as integer
    field inn          as char 
    field price        as decimal
    field kpp          as char
    field trn-date     as date 
    field trn-tot      as decimal
    field flag_        as char
    field rash_        as char
    index pi
    Identity 
    . 

run adm/shattri.p (
    input "get":U
    ,input '':U
    ,input 0
    ,input {&attr-egais-host}
    ,input {&attr-egais-host_egais-exsys}
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-value-type
    ,input-output TABLE thbjattr_thbj-attr
    ) no-error .
assign 
    v-ext-sys = v-value-integer . 
        
egaisWB = new WayBill ( "" , 0 , v-fs-rar , v-ext-sys ).
create query qh-wb-egais.

RUN get-full-path-RepViewer(OUTPUT v-full-path-RepView).   
  
RUN get-report-num IN my-handle (OUTPUT g#report-num).
/*if  x-SelectObject = {&o-choice} then do:*/   
for each obj-list no-lock
    :
       
        
    RUN define-full-path-Report(INPUT g#report-num, INPUT obj-list.obj-code , OUTPUT v-file-name-rep-htm).
    RUN create-file(v-file-name-rep-htm).       
    
    
    
    for each buf_clob-bind where buf_clob-bind.field-name_ = {&lob-egais-wb} and  date(entry (1, buf_clob-bind.descr, {&delim-par})) >= X-Date-Start and  date (entry (1, buf_clob-bind.descr, {&delim-par})) <= X-Date-End :
        /*v-info = string (tt-wb-header.wb-date) + {&-par} + tt-wb-header.num + {&-par} + tt-wb-info-client.regID + {&-par} + tt-wb-header.Identity + {&-par} + string (tt-wb-header.wbregid) + {&-par} + "нет" + {&-par} + "нет" + {&-par}.*/
        if entry (9, buf_clob-bind.descr, {&delim-par}) <> "" and entry (9, buf_clob-bind.descr, {&delim-par}) <> "0" and entry (9, buf_clob-bind.descr, {&delim-par}) <> obj-list.obj-type + string (obj-list.obj-code)
            then next.
         
        egaisWB:GetHndlTable(1, buf_clob-bind.uniq-key-rec).
        bh-wb-gds-EG-header = egaisWB:HndlHeader.
        bh-wb-gds-EG = egaisWB:HndlLine.
        
        v-price = 0 .
        bh-wb-gds-EG-header:find-first() no-error.

        bh-wb-gds-EG = egaisWB:GetHndlTable(2, buf_clob-bind.uniq-key-rec).
        qh-wb-egais:set-buffers (bh-wb-gds-EG).
        qh-wb-egais:query-prepare ("for each tt-wb-gds-EG ").
        qh-wb-egais:query-open.
  
        qh-wb-egais:GET-FIRST ().
        
  
        do while  bh-wb-gds-EG:available:
            v-price =  v-price + (bh-wb-gds-EG:buffer-field('price'):buffer-value())  *  (bh-wb-gds-EG:buffer-field('qnty'):buffer-value()  ).
            qh-wb-egais:get-next().
            if not bh-wb-gds-EG:available then leave.

        end.
        
        create alc-rees.
        assign
        
            alc-rees.wbregid      = bh-wb-gds-EG-header:buffer-field('wbregid'):buffer-value()
            alc-rees.price        = v-price
            alc-rees.INN          = bh-wb-gds-EG-header:buffer-field('INNShip'):buffer-value()
            alc-rees.KPP          = bh-wb-gds-EG-header:buffer-field('KPPShip '):buffer-value()
            alc-rees.wb-date      = date (entry (1, buf_clob-bind.descr, {&delim-par}))
            alc-rees.num          = entry (2, buf_clob-bind.descr, {&delim-par})
            alc-rees.shippregid   = entry (3, buf_clob-bind.descr, {&delim-par})
            alc-rees.Identity     = entry (4, buf_clob-bind.descr, {&delim-par})
            alc-rees.trn-doc-code = entry (6, buf_clob-bind.descr, {&delim-par})
            alc-rees.is-sent      = entry (7, buf_clob-bind.descr, {&delim-par})
            alc-rees.wb-type      = "приход вн."  
            when entry (8, buf_clob-bind.descr, {&delim-par}) = {&TDEDT_Pri_Vnesh}
            alc-rees.obj          = entry (9, buf_clob-bind.descr, {&delim-par}) .
            
        alc-rees.rash_ = entry (10, buf_clob-bind.descr, {&delim-par}) no-error.
        assign
            alc-rees.uniq-key-rec = buf_clob-bind.uniq-key-rec
            alc-rees.obj-type     = obj-list.obj-type
            alc-rees.obj-code     = obj-list.obj-code
            .
        find first trn-doc where trn-doc.doc-code = alc-rees.trn-doc no-lock no-error.
        if available trn-doc then 
        do: 
            assign
                alc-rees.trn-date = trn-doc.doc-date
                alc-rees.trn-tot  = trn-doc.tot-rubl
                alc-rees.flag_    = if trn-doc.flag_ then "да" else "нет".
            
        end.
        
        if alc-rees.rash_ <> "" then  alc-rees.status_ = alc-rees.rash_.
        
        
        find first ub.ext-classif no-lock 
            where ub.ext-classif.classif-subject = {&table_clients}
            and ub.ext-classif.classif-name = {&extclass_clients_esys}
            and ub.ext-classif.db-num = 0
            and ub.ext-classif.key#_one = v-ext-sys
            and ub.ext-classif.CharKey_Three = alc-rees.shippregid
            no-error.
        if available (ub.ext-classif) then 
        do:
            find first buf_clients where buf_clients.obj-type = entry (2, ub.ext-classif.uniq-key-rec, {&delim-key}) and buf_clients.obj-code = integer (entry (3, ub.ext-classif.uniq-key-rec, {&delim-key})) no-error.
            if available (buf_clients)
                then 
            do: 
                alc-rees.cli = buf_clients.obj-type + string (buf_clients.obj-code).
                alc-rees.cliname = buf_clients.obj-name.
            end.
        end.
        /*            alc-rees.wbregid = entry (5, buf_clob-bind.descr, {&delim-par}) no-error.*/
        find first buf_trn-doc where buf_trn-doc.doc-code = alc-rees.trn-doc-code no-error.
        if available (buf_trn-doc)
            then alc-rees.status_ = buf_trn-doc.status_ + (if buf_trn-doc.flag_ then "+" else "-").
    end.
    run proc-create-HTML (input obj-list.obj-code, input obj-list.obj-type, input obj-list.obj-name).

    v-search = v-search + " "  + v-file-name-rep-htm.
    v-search = trim(v-search," ") .
     
end.

run prn-lib-reportviewer in this-procedure (
    input parParentProc
    ,input v-search
    ,input "" 
    ) .
if error-status:error then
do:
    message return-value view-as alert-box.
    return .
end.  


procedure proc-create-HTML: 

    define input parameter p-obj-code as integer no-undo.
    define input parameter p-obj-type as character no-undo.
    define input parameter p-obj-name as character no-undo.

    DO:
        OUTPUT stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8'.
        PUT STREAM OutStr-html UNFORMATTED
            "<!DOCTYPE HTML>" SKIP
            ' <html>' SKIP
            '  <head>' SKIP
            '   <meta charset="utf-8">' SKIP
            '    <style type="text/css">' SKIP
              
            '      table ' + chr(123) + ' border-collapse: collapse; font-size:9pt; font-family:Calibri; table-layout: fixed; width: 540px; hight:  padding: 8px;  ' + chr(125) SKIP
            '      td ' + chr(123) ' border: 1px black solid; word-wrap:break-word; ' + chr(125) SKIP
            '      htm' SKIP
            '      .rotate ' + chr(123) SKIP
            '        -webkit-transform: rotate(-90deg);' SKIP
            '        -moz-transform: rotate(-90deg);' SKIP
            '        -ms-transform: rotate(-90deg);' SKIP
            '        -o-transform: rotate(-90deg);' SKIP
            '        transform: rotate(-90deg);' SKIP


            '        -webkit-transform-origin: 50% 50%;' SKIP
            '        -moz-transform-origin: 50% 50%;' SKIP
            '        -ms-transform-origin: 50% 50%;' SKIP
            '        -o-transform-origin: 50% 50%;' SKIP
            '        transform-origin: 50% 50%;' SKIP


            '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' SKIP
            '          ' + chr(125) SKIP
            '            th' + ' ' + chr(123) SKIP
            '            border: 1px black solid;' SKIP
            '            word-wrap: break-word;' SKIP
            '          ' + chr(125) SKIP
            '   </style>' SKIP
            '  </head>' SKIP
            . 
    END. 

    do:      
        PUT STREAM OutStr-html UNFORMATTED
            ' <body>' SKIP
            '   <table name="' + p-obj-name + '" fit_to_page="true" orientation="landscape" outline_below="false">' SKIP
        
            '     <thead>' SKIP
            '       <tr class="set_columns">' SKIP     
            
            .

        if lookup("Поставщик ЕГАИС",p-column-list) <> 0  then     
        do:
            v-col1 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                   
                '         <td style="width: 200px; border: none;"></td>' SKIP   
                . 
        end.
            
        if lookup("ID поставщика",p-column-list) <> 0  then      
        do:
            v-col2 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                  
                '         <td style="width: 100px; border: none;"></td>' SKIP 
                .
        end.
            
            
            
        if lookup("ИНН/КПП",p-column-list) <> 0  then         
        do:
            v-col3 = yes.
            PUT STREAM OutStr-html UNFORMATTED
               
                '         <td style="width: 150px; border: none;"></td>' SKIP   
                .  
        end.
           
            
        if lookup("Дата документа из ЕГАИС",p-column-list) <> 0  then    
        do:
            v-col4 = yes.
            PUT STREAM OutStr-html UNFORMATTED
               
                    
                '         <td style="width: 100px; border: none;"></td>' SKIP 
                .  
        end.
            
        if lookup("№ документа поставщика",p-column-list) <> 0  then 
        do:
            v-col5 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                        
                '         <td style="width: 100px; border: none;"></td>' SKIP 
                .
        end.
            
        if lookup("№ накладной в ЕГИС",p-column-list) <> 0  then    
        do:
            v-col6 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                    
                '         <td style="width: 115px; border: none;"></td>' SKIP 
                .
        end.
        
            
        if lookup("дата TH",p-column-list) <> 0  then      
        do:
            v-col7 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                  
                '         <td style="width: 100px; border: none;"></td>' SKIP 
                .
        end.
             
        if lookup("№ документа TH",p-column-list) <> 0  then  
        do:
            v-col8 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                      
                '         <td style="width: 70px; border: none;"></td>' SKIP  
                .
        end.
                         
        if lookup("Сумма документа TH",p-column-list) <> 0  then 
        do:
            v-col9 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                        
                '         <td style="width: 80px; border: none;"></td>' SKIP  
                .
        end.
        
        
        
        if lookup("Сумма документа ЕГАИС",p-column-list) <> 0  then      
        do:
            v-col10 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                  
                '         <td style="width: 100px; border: none;"></td>' SKIP  
                .
        end.
            
            
        if lookup("Cтатус",p-column-list) <> 0  then         
        do:
            v-col11 = yes.
            PUT STREAM OutStr-html UNFORMATTED
               
                '         <td style="width: 70px; border: none;"></td>' SKIP 
                .
        end.
         
                        
        if lookup("Расхождение(да/нет)",p-column-list) <> 0  then   
        do:
            v-col12 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                      
                '         <td style="width: 80px; border: none;"></td>' SKIP 
                .
        end.
                 
            
        PUT STREAM OutStr-html UNFORMATTED
             
           
            '       </tr>' SKIP
            .
    end.
        
    DO:  
     
        PUT STREAM OutStr-html UNFORMATTED        
  
            '<tr>' SKIP
            '         <td colspan="8" style="border: none;   text-align: center;  font-size: 12pt;  font-weight: bold;">Накладные,принятые с ЕГАИС. Объект:  ' + p-obj-name  + '  за период:  ' + string(x-date-start)  + ' - ' + string(X-Date-End) + '</td>' SKIP
            '</tr>' skip      
            
                  
            '  <tr>' SKIP
            '    <td colspan="8" style="border: none;   text-align: center;  font-size: 12pt;  font-weight: bold;"></td>' SKIP
            '</tr>' skip            
            
            '</thead>' SKIP
            
            .
            
    end.
  
    DO:
        PUT STREAM OutStr-html UNFORMATTED
            /*                '     <thead>' skip               */
            /*            '       <tr class="set_columns">' skip*/
        
            /*            '     <tbody>' SKIP                     */
            '     <tbody>' skip
            
            '       <tr style="height: 80px;">' SKIP
            .
        if v-col1 then     PUT STREAM OutStr-html UNFORMATTED        '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Поставщик ЕГАИС </th>' SKIP.
        if v-col2 then     PUT STREAM OutStr-html UNFORMATTED '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">ID Поставщика </th>' SKIP.
        if v-col3 then     PUT STREAM OutStr-html UNFORMATTED        '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">ИНН/КПП </th>' SKIP .
        if v-col4 then     PUT STREAM OutStr-html UNFORMATTED     '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Дата документа </th>' SKIP.
        if v-col5 then     PUT STREAM OutStr-html UNFORMATTED    '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">№ док.поставщика</th>' SKIP.
        if v-col6 then     PUT STREAM OutStr-html UNFORMATTED      '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">№ накладной в ЕГАИС</th>' SKIP .
        if v-col7 then     PUT STREAM OutStr-html UNFORMATTED  '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">дата TH </th>' SKIP.
        if v-col8 then     PUT STREAM OutStr-html UNFORMATTED '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">№ док. TH </th>' SKIP.
        if v-col9 then     PUT STREAM OutStr-html UNFORMATTED   '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">сумма док. TH </th>' SKIP.
        if v-col10 then    PUT STREAM OutStr-html UNFORMATTED   '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">сумма док. ЕГАИС </th>' SKIP.
        if v-col11 then    PUT STREAM OutStr-html UNFORMATTED  '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Статус </th>' SKIP.
        if v-col12 then    PUT STREAM OutStr-html UNFORMATTED   '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Расхождение (да/нет) </th>' SKIP.
            
        PUT STREAM OutStr-html UNFORMATTED     
            
            '</tr>'
            .
        output stream OutStr-html close.
            
            
    end.
    
    
    DO:
        OUTPUT stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8'.
        for each alc-rees where alc-rees.obj-type = p-obj-type and alc-rees.obj-code = p-obj-code  break by alc-rees.wb-date :
        
            PUT STREAM OutStr-html UNFORMATTED
                /*        for each buf_tt no-lock where buf_tt.obj-code = p-obj-code and buf_tt.obj-type = p-obj-type  and   buf_tt.cnt-line <> 0 break by buf_tt.exp-td-fact-date  by buf_tt.exp-time :*/
                /*            v-exp-volume-piece-litres = if buf_tt.exp-volume-piece-litres = 0 and buf_tt.exp-fact-qnty = 0 then "" else fnc-fmt-dec-tc-litres(buf_tt.exp-volume-piece-litres).        */
                /*            put stream OutStr-html unformatted                                                                                                                                        */
 
                '       <tr>' SKIP
                .
            if alc-rees.rash = "rejected" then 
            do: 
                    
        
                if v-col1 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#B22222;display: yes; text-align: left;border: 1px solid black;">'   +  alc-rees.cliname + '</td>'  SKIP.
                if v-col2 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#B22222;display: yes; text-align: left;border: 1px solid black;">'  +   alc-rees.shippregid + '</td>'  SKIP.
                if v-col3 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#B22222; display: yes; text-align: center;border: 1px solid black;">' + alc-rees.inn + "/" +  alc-rees.kpp + '</td>' SKIP.
                if v-col4 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#B22222;display: yes; text-align: center;border: 1px solid black;">'    + fnc-DD-MM-YYYY(date(string(alc-rees.wb-date,"99.99.9999"))) + '</td>' skip.
                if v-col5 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#B22222;display: yes; text-align: center;border: 1px solid black;">' + alc-rees.num +  '</td>' SKIP.
                if v-col6 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#B22222;display: yes; text-align: center;border: 1px solid black;">' + alc-rees.wbregid +  '</td>' SKIP.
                if v-col7 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#B22222;display: yes; text-align: center;border: 1px solid black;">' + if  fnc-DD-MM-YYYY(date(string(alc-rees.trn-date,"99.99.9999")))  <> ? then  fnc-DD-MM-YYYY(date(string(alc-rees.trn-date,"99.99.9999")))  + '</td>' else " " + '</td>' skip.
                if v-col8 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#B22222;display: yes; text-align: left;border: 1px solid black;">'  +    alc-rees.trn-doc-code     + '</td>'  SKIP.
                if v-col9 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#B22222;display: yes; text-align: left;border: 1px solid black;">'  + if alc-rees.trn-tot <> ?  then fnc-convert-dot-to-colon( alc-rees.trn-tot, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip.
                if v-col10 then     PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#B22222;display: yes; text-align: left;border: 1px solid black;"> '  + if alc-rees.price <> ?  then fnc-convert-dot-to-colon( alc-rees.price, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip.
                if v-col11 then     PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#B22222;display: yes; text-align: left;border: 1px solid black;">'  +    alc-rees.status_   + '</td>'  SKIP.
                if v-col12 then     PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#B22222;display: yes; text-align: left;border: 1px solid black;"> ' + alc-rees.flag_ + ' </td>'  SKIP.
      
            end.
            else 
            do: 
           
                if alc-rees.trn-doc = "отказ" then 
                do:
                    if v-col1 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#4169E1;display: yes; text-align: left;border: 1px solid black;">'   +  alc-rees.cliname + '</td>'  SKIP.
                    if v-col2 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#4169E1;display: yes; text-align: left;border: 1px solid black;">'  +   alc-rees.shippregid + '</td>'  SKIP.
                    if v-col3 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#4169E1; display: yes; text-align: center;border: 1px solid black;">' + alc-rees.inn + "/" +  alc-rees.kpp + '</td>' SKIP.
                    if v-col4 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#4169E1;display: yes; text-align: center;border: 1px solid black;">'           + fnc-DD-MM-YYYY(date(string(alc-rees.wb-date,"99.99.9999"))) + '</td>' skip.
                    if v-col5 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#4169E1;display: yes; text-align: center;border: 1px solid black;">' + alc-rees.num +  '</td>' SKIP.
                    if v-col6 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#4169E1;display: yes; text-align: center;border: 1px solid black;">' + alc-rees.wbregid +  '</td>' SKIP.
                    if v-col7 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#4169E1;display: yes; text-align: center;border: 1px solid black;">'  + if  fnc-DD-MM-YYYY(date(string(alc-rees.trn-date,"99.99.9999")))  <> ? then  fnc-DD-MM-YYYY(date(string(alc-rees.trn-date,"99.99.9999"))) + '</td>' else " " + '</td>' skip.
                    if v-col8 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#4169E1;display: yes; text-align: left;border: 1px solid black;">'  +    alc-rees.trn-doc-code     + '</td>'  SKIP.
                    if v-col9 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#4169E1;display: yes; text-align: left;border: 1px solid black;">' + if alc-rees.trn-tot <> ?  then fnc-convert-dot-to-colon( alc-rees.trn-tot, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip.
                    if v-col10 then     PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#4169E1;display: yes; text-align: left;border: 1px solid black;"> '  + if alc-rees.price <> ?  then fnc-convert-dot-to-colon( alc-rees.price, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip.
                    if v-col11 then     PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#4169E1;display: yes; text-align: left;border: 1px solid black;">'  +    alc-rees.status_   + '</td>'  SKIP.
                    if v-col12 then     PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#4169E1;display: yes; text-align: left;border: 1px solid black;"> ' + alc-rees.flag_ + ' </td>'  SKIP.
          
                end.
                else 
                do: 
               
                    if alc-rees.trn-doc = "нет" or alc-rees.rash = "Accepted" then 
                    do:
                   
                   
                   
                        if v-col1 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#A9A9A9;display: yes; text-align: left;border: 1px solid black;">'   +  alc-rees.cliname + '</td>'  SKIP.
                        if v-col2 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#A9A9A9;display: yes; text-align: left;border: 1px solid black;">'  +   alc-rees.shippregid + '</td>'  SKIP.
                        if v-col3 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#A9A9A9; display: yes; text-align: center;border: 1px solid black;">' + alc-rees.inn + "/" +  alc-rees.kpp + '</td>' SKIP.
                        if v-col4 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#A9A9A9;display: yes; text-align: center;border: 1px solid black;">'           + fnc-DD-MM-YYYY(date(string(alc-rees.wb-date,"99.99.9999"))) + '</td>' skip.
                        if v-col5 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#A9A9A9;display: yes; text-align: center;border: 1px solid black;">' + alc-rees.num +  '</td>' SKIP.
                        if v-col6 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#A9A9A9;display: yes; text-align: center;border: 1px solid black;">' + alc-rees.wbregid +  '</td>' SKIP.
                        if v-col7 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#A9A9A9;display: yes; text-align: center;border: 1px solid black;">' + if  fnc-DD-MM-YYYY(date(string(alc-rees.trn-date,"99.99.9999")))  <> ? then  fnc-DD-MM-YYYY(date(string(alc-rees.trn-date,"99.99.9999")))  + '</td>' else " " + '</td>' skip.
                        if v-col8 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#A9A9A9;display: yes; text-align: left;border: 1px solid black;">'  +    alc-rees.trn-doc-code     + '</td>'  SKIP.
                        if v-col9 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#A9A9A9;display: yes; text-align: left;border: 1px solid black;">'  + if alc-rees.trn-tot <> ?  then fnc-convert-dot-to-colon( alc-rees.trn-tot, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip.
                        if v-col10 then     PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#A9A9A9;display: yes; text-align: left;border: 1px solid black;"> '  + if alc-rees.price <> ?  then fnc-convert-dot-to-colon( alc-rees.price, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip.
                        if v-col11 then     PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#A9A9A9;display: yes; text-align: left;border: 1px solid black;">'  +    alc-rees.status_   + '</td>'  SKIP.
                        if v-col12 then     PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#A9A9A9;display: yes; text-align: left;border: 1px solid black;"> ' + alc-rees.flag_ + ' </td>'  SKIP.
                    end.
                    else 
                    do:
                        if v-col1 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="display: yes; text-align: left;border: 1px solid black;">'   +  alc-rees.cliname + '</td>'  SKIP.
                        if v-col2 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="display: yes; text-align: left;border: 1px solid black;">'  +   alc-rees.shippregid + '</td>'  SKIP.
                        if v-col3 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="display: yes; text-align: center;border: 1px solid black;">' + alc-rees.inn + "/" +  alc-rees.kpp + '</td>' SKIP.
                        if v-col4 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="display: yes; text-align: center;border: 1px solid black;">'  + fnc-DD-MM-YYYY(date(string(alc-rees.wb-date,"99.99.9999"))) + '</td>' skip.
                        if v-col5 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="display: yes; text-align: center;border: 1px solid black;">' + alc-rees.num +  '</td>' SKIP.
                        if v-col6 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="display: yes; text-align: center;border: 1px solid black;">' + alc-rees.wbregid +  '</td>' SKIP.
                        if v-col7 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="display: yes; text-align: center;border: 1px solid black;">' + if  fnc-DD-MM-YYYY(date(string(alc-rees.trn-date,"99.99.9999")))  <> ? then  fnc-DD-MM-YYYY(date(string(alc-rees.trn-date,"99.99.9999"))) + '</td>' else " " + '</td>' skip.
                        if v-col8 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="display: yes; text-align: left;border: 1px solid black;">'  +    alc-rees.trn-doc-code     + '</td>'  SKIP.
                        if v-col9 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="display: yes; text-align: left;border: 1px solid black;">'    + if alc-rees.trn-tot <> ?  then fnc-convert-dot-to-colon( alc-rees.trn-tot, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip.
                        if v-col10 then     PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="display: yes; text-align: left;border: 1px solid black;"> '   + if alc-rees.price <> ?  then fnc-convert-dot-to-colon( alc-rees.price, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip.
                        if v-col11 then     PUT STREAM OutStr-html UNFORMATTED   '         <td style="display: yes; text-align: left;border: 1px solid black;">'  +    alc-rees.status_   + '</td>'  SKIP.
                        if v-col12 then     PUT STREAM OutStr-html UNFORMATTED   '         <td style="display: yes; text-align: left;border: 1px solid black;"> ' + alc-rees.flag_ + ' </td>'  SKIP.
                        
                        
                    end.
                end.
          
            end.
       
            PUT STREAM OutStr-html UNFORMATTED         
                '</tr>' SKIP
                .
        
        end.
    

    end.
    
    DO: 
        PUT STREAM OutStr-html UNFORMATTED  
            '    </tbody>'
            '   </table>' SKIP
            '  </body>' SKIP
            ' </html>' SKIP
            . /* Точка для закрытия Put */
        OUTPUT stream OutStr-html close.
    END.
    
        
end procedure.


function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character):
/* Конвертация десятичной точки в запятую с передачей параметра форматирования числа (accuracy - точность) */

    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
/*message "dbg-p-data = " p-data skip "p-accur = " p-accur view-as alert-box.*/
    p-data = round(p-data, 2). /* Чтобы не выйти случайно за рамки формата числа при выводе (несоотвесвие формата результата и формата отображения - приводит к ош) */
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).

    return v-str-result.
    
    
END FUNCTION.
    
FUNCTION fnc-DD-MM-YYYY RETURNS CHARACTER 
    (INPUT p-dat-date AS DATE):
    /* Преобразование даты в формат: "01.01.2014" */

    DEFINE VARIABLE result     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE p-str-date AS CHARACTER NO-UNDO.

    p-str-date = REPLACE(STRING(p-dat-date,'99.99.9999'), "/", ".").

    RETURN p-str-date.

END FUNCTION.
    
    
PROCEDURE get-full-path-RepViewer:  /* Получение полного пути к исполняемому файлу RV.exe (output Полный_путь_имя_файла_RV.exe) */
    /* Получение полного пути к exe-файлу просмотровщика отчётов */
    DEFINE OUTPUT PARAMETER p-fill-path-RepView AS CHARACTER NO-UNDO.

    IF SEARCH("exe\ReportViewer\reportviewer.exe") <> ? THEN
    DO:
        p-fill-path-RepView = SEARCH("exe\ReportViewer\reportviewer.exe").
    END.
    ELSE
    DO:
        MESSAGE "Не найдена программа просмотра отчёта!" VIEW-AS ALERT-BOX ERROR.
    END.
END PROCEDURE.


PROCEDURE search-full-path-Report:  /* Только проверка, есть файл отчёта HTML или нет(тогда вывод сбщ-ош) */
    /* Поиск файла */  
    DEFINE INPUT PARAMETER p-file-name AS CHARACTER NO-UNDO.

    IF SEARCH(p-file-name) = ? THEN
    DO:
        MESSAGE "Не найден файл отчёта: " p-file-name VIEW-AS ALERT-BOX ERROR.
    END.
    ELSE
    DO:
        p-file-name = SEARCH(p-file-name).
    END.

END PROCEDURE.


PROCEDURE create-file:              /* СоздЛюбогоФайлаНаДиске(input полный_путь_с_именем) */
    /* Создание пустого файла (во входном параметре: полный путь и имя файла) */
    DEFINE INPUT PARAMETER p-file-name AS CHARACTER NO-UNDO.
    OUTPUT to value(STRING(p-file-name)).
    OUTPUT close.

END PROCEDURE.

PROCEDURE define-full-path-Report:  /* Получение полного пути к отчёту html (input №Отчёта, output Полный_путь_имя_файла_отчHTML) */
    /* Получение полного пути к отчёту html */
    DEFINE INPUT PARAMETER p-rep-num AS INTEGER NO-UNDO.
    DEFINE INPUT PARAMETER name-obj AS INTEGER.
    DEFINE OUTPUT PARAMETER p-file-name-rep-htm AS CHARACTER NO-UNDO.

    p-file-name-rep-htm = SESSION:TEMP-DIRECTORY +   "Объект" + string(name-obj) + ".html".

END PROCEDURE.


PROCEDURE Report-Viewer:            /* Запуск на выполнение RV (input Полный_путь_имя_файла_RV, input Полный_путь_имя_файла_отчHTML) */
    /* Запуск программы "Просмотровщик Отчётов" - ReportViewer. */
    DEFINE INPUT PARAMETER p-full-path-RepView AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER p-search AS CHARACTER NO-UNDO.
	
    OS-COMMAND NO-WAIT VALUE(p-full-path-RepView +  " true " + p-search).

END PROCEDURE.

