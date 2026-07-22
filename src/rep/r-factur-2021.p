block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать счета-фактуры

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 09/15/05
Author: Victor Guntner
Creation date: 09/15/05

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id           as recid                no-undo.
define input parameter invers           as logical              no-undo.
define input parameter p-mode           as character            no-undo.   /* используется для анализа sys-key */
define input parameter p-round          as character            no-undo.   /* 'round' включает округление */
define input parameter p-no-slt         as logical              no-undo .  /* yes - не печатаем строку НП */
define input parameter p-reverse        as logical              no-undo .  /* Меняем местами грузополучателя и плательщика */


&scoped-define gds-len          42
&scoped-define footer-tab-stop1 40
&scoped-define gds-gtd-fill     "           -           ":U
&global-define month-list-for-date 'января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря':U
/* Для вызова функции конвертации даты к виду: "01 Января 2014г" */
&scop f-l MonthNameRusCase,Sparse
{ gbl/std-func.i {&f-l} }

do
    on error undo, return error
    :
    define variable vss-revision    as character no-undo initial "$Revision$":U .
    define variable vss-author      as character no-undo initial "$Author$":U .
    define variable vss-date        as character no-undo initial "$Date$":U .
    define variable vss-workfile    as character no-undo initial "$Workfile$":U .
    define variable vss-archive     as character no-undo initial "$Archive$":U .
    define variable vss-description as character no-undo initial "Печать счета-фактуры.":U .

{ cmp/vssrevis.i     }
   { cmp/str-glbl.i     }
    { cmp/library.i      }
    { cmp/r-pril.i       }
    { cmp/breakstr.i     }
   { str/trdcalib.i     }
    { str/in-vatp.i def  }
    { str/out-vatp.i def }
{ cmp/croslist.i     }
{ str/hvrdtax.i      }
    { gbl/tax-name.i     }
   { rep/r-factur21.i def }
    { rep/fmtcli.i       }
    { rep/torgconf.i     }
    { rep/p-fmt.i        }
   { gbl/clntattr.i     }
    { gbl/thbjattr.i     }
   { ref/extclass.i     }
    { gbl/prn-lib.i }
{ rep/html-conv.i }
    define variable g#report-num as integer no-undo.
   
    define variable g#log        as logical no-undo.

    { gbl/paramls.i      }
    { str/getctxtp.i def }
    { gbl/getcntxt.i def }

    define shared variable PrintScale                  as logical   no-undo.
    define shared variable CostPrice                   as logical   no-undo.

    define        variable v-must-print-scale          as logical   no-undo.
    define        variable tdoc-prt                    as logical   no-undo.
    define        variable p-sf-par                    as logical   no-undo.
    define        variable PrevPage                    as integer   initial 0 no-undo.

    define        variable rep-artic                   as logical   no-undo.

    define        variable str                         as character no-undo.
    define        variable gds-str                     as character no-undo.
    define        variable gds-str1                    as character no-undo.
    define        variable gds-str2                    as character no-undo.
    define        variable rootnode_code               as integer   no-undo.

    define        variable v-lines-counter             as integer   no-undo.
    define        variable v-node-code                 like gds-prt.upper-code no-undo.

    define        variable v-qnty                      as decimal   no-undo.
    define        variable v-doc-qnty                  as decimal   no-undo.
    define        variable v-price                     as decimal   no-undo.
    define        variable v-price-no-VAT              as decimal   no-undo.
    define        variable v-sum                       as decimal   no-undo.
    define        variable v-doc-sum                   as decimal   no-undo.
    define        variable v-sum-no-VAT                as decimal   no-undo.
    define        variable v-doc-sum-no-VAT            as decimal   no-undo.
    define        variable v-sum-actciz                as decimal   no-undo.
    define        variable v-VAT                       as decimal   no-undo.
    define        variable v-doc-VAT                   as decimal   no-undo.
    define        variable v-SLT                       as decimal   no-undo.
    define        variable v-vat-pc                    as decimal   no-undo.
    define        variable v-slt-pc                    as decimal   no-undo.

    define        variable v-parts-price               as decimal   no-undo.
    define        variable v-parts-price-no-VAT        as decimal   no-undo.
    define        variable v-parts-sum                 as decimal   no-undo.
    define        variable v-parts-sum-no-VAT          as decimal   no-undo.
    define        variable v-parts-sum-actciz          as decimal   no-undo.
    define        variable v-parts-VAT                 as decimal   no-undo.
    define        variable v-parts-SLT                 as decimal   no-undo.

    define        variable v-tot-sum                   as decimal   no-undo.
    define        variable v-tot-sum1                  as decimal   no-undo.
    define        variable v-tot-sum2                  as decimal   no-undo.
    define        variable v-tot-VAT                   as decimal   no-undo.
    define        variable v-tot-VAT1                  as decimal   no-undo.
    define        variable v-tot-VAT2                  as decimal   no-undo.
    define        variable v-tot-SLT                   as decimal   no-undo.
    define        variable v-tot-sum-no-VAT            as decimal   no-undo.
    define        variable v-tot-sum-no-VAT1           as decimal   no-undo.
    define        variable v-tot-sum-no-VAT2           as decimal   no-undo.

    define        variable v-diff-sum-no-VAT           as decimal   no-undo.
    define        variable v-diff-VAT                  as decimal   no-undo.
    define        variable v-diff-sum                  as decimal   no-undo.

    define        variable v-prt-qnty                  as decimal   no-undo.
    define        variable v-prt-doc-qnty              as decimal   no-undo.
    define        variable v-prt-VAT                   as decimal   no-undo.
    define        variable v-prt-doc-VAT               as decimal   no-undo.
    define        variable v-prt-SLT                   as decimal   no-undo.
    define        variable v-prt-sum-no-VAT            as decimal   no-undo.
    define        variable v-prt-doc-sum-no-VAT        as decimal   no-undo.
    define        variable v-prt-sum                   as decimal   no-undo.
    define        variable v-prt-doc-sum               as decimal   no-undo.

    define        variable v-tot-prt-qnty              as decimal   no-undo.
    define        variable v-tot-prt-doc-qnty          as decimal   no-undo.
    define        variable v-tot-prt-VAT               as decimal   no-undo.
    define        variable v-tot-prt-doc-VAT           as decimal   no-undo.
    define        variable v-tot-prt-SLT               as decimal   no-undo.
    define        variable v-tot-prt-sum-no-VAT        as decimal   no-undo.
    define        variable v-tot-prt-doc-sum-no-VAT    as decimal   no-undo.
    define        variable v-tot-prt-sum               as decimal   no-undo.
    define        variable v-tot-prt-doc-sum           as decimal   no-undo.

    define        variable v-prt-name                  as character no-undo.
    define        variable v-country                   as character no-undo.
    define        variable v-GTD                       as character no-undo.
    define        variable v-single-line               as character no-undo.
    define        variable v-propis                    as character no-undo.
    define        variable v-propis-cop                as character no-undo.
    define        variable v-pokazately                as character no-undo.

    define        variable t-addres                    as character no-undo.
    define        variable t-phone                     as character no-undo.
    define        variable t-inn                       as character no-undo.
    define        variable t-num                       as character no-undo.
    define        variable v-print-doc                 as character no-undo.
    define        variable v-par-type                  as character no-undo.
    define        variable v-curr-abbr                 as character no-undo.
    define        variable v-void-decimal              as decimal   no-undo.
    define        variable v-sum-VAT                   as decimal   no-undo.
    define        variable v-sum-SLT                   as decimal   no-undo.
    define        variable v-sum-tax                   as decimal   no-undo.

    define        variable v-unit-code                 as character no-undo.
    define        variable v-country-code              as character no-undo.
    define        variable v-host-code                 as integer   no-undo.
    define        variable v-curr-code                 as integer   no-undo.
    define        variable v-r-factur-is-vozvrat-vnesh as logical   no-undo.
    define        variable tmp-var                     as character no-undo.
    define        variable FullGdsName                 as logical   no-undo.
    define        variable v-cntxa-report-num          as integer   no-undo .
    define        variable v-uaes-code                 as character no-undo. /* Код вида товара в соответствии с единой Товарной номенклатурой внешнеэкономической деятельности ЕАЭС */
    /* HTML */
    define        variable p-report-id                 as character no-undo .
    define        variable v-file-name-rep-html        as character no-undo .
    define        variable ii                          as integer   no-undo .
    define        variable v-name-report               as character no-undo .
    define        variable v-obj-name                  as character no-undo .
    define stream Out-Stream.
    define stream OutStr-html.
    /* Определение переменных для грузополучателя */
    define variable v-trdcattr-type  as character no-undo .
    define variable v-code-rec       as integer   no-undo .
    define variable v-type-rec       as character no-undo .
    define variable v-recipient-code as character no-undo .
    define variable v-codefirm-rec   as character no-undo .
    define variable v-curcode-rec    as integer   no-undo .
    define variable v-out-name       as character no-undo .

    define variable v-outhdobj       as logical   init no no-undo .   /* для межфирменных документов печатать в поле грузополучатель объект получателя*/
    define variable v-outhdobj-str   as character no-undo .
    define variable v-cli-type       as character no-undo .
    define variable v-cli-code       as integer   no-undo .
    define variable v-is-hold-doc    as logical   no-undo .

    define variable v-start-str      as character no-undo .
    define variable v-add-str        as character no-undo .

    define buffer buf_trn-doc     for trn-doc.
    define buffer buf_our_clients for clients.
    define buffer buf_clients     for clients.
    define buffer buf_firm        for firm.
    define buffer buf_sysconf     for sysconf.
    define buffer buf_country     for country.
    define buffer buf_parts-attr  for parts-attr.

    run get-report-num  (output g#report-num).
    /*  run get-quest-print in parParentProc(output g#quest-print).*/
    v-file-name-rep-html = session:temp-directory + string(g#report-num) + ".html".
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
    output close.
   
    output stream OutStr-html to value(v-file-name-rep-html) convert target 'UTF-8'.
    put stream OutStr-html unformatted
        "<!DOCTYPE HTML>" skip
        ' <html>' skip
        '  <head>' skip
        '   <meta charset="utf-8">' skip
        '    <style type="text/css">' skip

        '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
        '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
        '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
        '   </style>' skip
        '  </head>' skip
        '<body>' skip
        .
      
    /*Печать*/
    put stream OutStr-html unformatted
        '<TABLE fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0" name="Отчет">'skip
        .

    put stream OutStr-html unformatted
        '<thead>' skip
        '<tr class="set_columns">' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '<td style="width: 6px;"></td>' skip
        '</tr>' skip
        .

    put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="117" style="text-align: center;"></td>' skip
        '<td colspan="50" style="text-align: right;">Приложение №1</td>' skip
        '</tr>'
        '<tr>' skip
        '<td colspan="117" style="text-align: center;"></td>' skip
        '<td colspan="50" style="text-align: right;">к постановлению Правительства</td>' skip
        '</tr>'
        '<tr>' skip
        '<td colspan="117" style="text-align: center;"></td>' skip
        '<td colspan="50" style="text-align: right;">Российской Федерации</td>' skip
        '</tr>'
        '<tr>' skip
        '<td colspan="117" style="text-align: center;"></td>' skip
        '<td colspan="50" style="text-align: right;">от 26 декабря 2011 г. № 1137</td>' skip
        '</tr>'    
        '<tr style="height: 5px;">' skip
        '<td colspan="117" style="text-align: center;"></td>' skip
        '<td colspan="50" style="text-align: right;"></td>' skip
        '</tr>'    
        '<tr>' skip
        '<td colspan="117" style="text-align: center;"></td>' skip
        '<td colspan="50" style="text-align: right;">(в ред. Постановления Правительства РФ от 02.04.2021 № 534)</td>' skip
        '</tr>'    
        '<tr>' skip
        '<td colspan="117" style="text-align: center;"></td>' skip
        '<td colspan="50" style="text-align: right;"></td>' skip
        '</tr>'
        '<tr>' skip
        '<td colspan="117" style="text-align: center;"></td>' skip
        '<td colspan="50" style="text-align: right;"></td>' skip
        '</tr>'
        '<tr>' skip
        '<td colspan="167" style="text-align: center;">I. Форма счета-фактуры, применяемого при расчетах по налогу на добавленную стоимость</td>' skip
        '</tr>'    
        '<tr>' skip
        '<td colspan="167" style="text-align: center;"></td>' skip
        '</tr>'    
        .

    find first buf_trn-doc no-lock
        where recid( buf_trn-doc ) = rec_id
        .
    v-r-factur-is-vozvrat-vnesh = (buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}) .

    { gbl/hostcode.i
    buf_trn-doc.obj-type
    buf_trn-doc.obj-code
    v-host-code
}
    if printRubl then v-curr-code = 0 .
    else 
    do:
        { gbl/basecode.i
        v-host-code
        v-curr-code
    }
    end.
    run torgconf-read in this-procedure (
        input "factur"
        , input v-host-code
        , input buf_trn-doc.obj-type
        , input buf_trn-doc.obj-code
        ) no-error.
    if error-status :error
        then 
    do:
        message
            vss-workfile vss-revision vss-description
            skip 
            "Ошибка чтения параметров печати формы."
            skip 
            "Форма будет напечатана с параметрами по умолчанию."
            skip return-value
            skip trim( error-status :get-message( 1 ) )
            trim( error-status :get-message( 2 ) )
            trim( error-status :get-message( 3 ) )
            view-as alert-box error.
    end.

/*То что нужно для Грузополучателя */
    { gbl/hold-doc.i buf_trn-doc.doc-code v-is-hold-doc }
    if v-is-hold-doc then 
    do:
        /*если документ межфирменного перемещения, то смотрим что писать а грузополучатель . параметр outhdobj */
        run gbl/conf-rd.p ("outhdobj", v-host-code, buf_trn-doc.obj-type, buf_trn-doc.obj-code, "", "", "", no
            , output v-outhdobj-str , output v-par-type) no-error.
        if error-status :error then v-outhdobj-str = "" .
        else if lookup( "factur", v-outhdobj-str ) <> 0
                then 
            do:
                assign
                    v-outhdobj = yes
                    .
            end.
    end.

    assign
        v-cli-type = buf_trn-doc.cli-type
        v-cli-code = buf_trn-doc.cli-code
        .

    /* есть ли атрибут Грузополучатель*/
    run torgconf-get-recepient-param (
        input buf_trn-doc.doc-code
        , output v-code-rec
        , output v-type-rec
        , output v-codefirm-rec
        , output v-curcode-rec
        ).
    if v-code-rec = 0 and /*Если не указан грузополучатель в атрибутах и для межфирм. перемещений настроен   outhdobj, то в грузополучатель кладем объект-получатель */
        v-outhdobj = yes and
        v-is-hold-doc = yes
        then 
    do:
        assign
            v-type-rec = buf_trn-doc.hold-obj-type
            v-code-rec = buf_trn-doc.hold-obj-code
            .
    end.

    run torgconf-get-sup-param in this-procedure (
        input v-type-rec
        , input v-code-rec
        , input v-curcode-rec
        ) no-error.
    if error-status :error
        then 
    do:
        message
            vss-workfile vss-revision vss-description
            skip 
            "Ошибка чтения параметров объекта документа."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box warning.
    end.
    run torgconf-get-ship-param in this-procedure (
        input buf_trn-doc.host-code
        , input v-type-rec
        , input v-code-rec
        , input v-curcode-rec
        ) no-error.
    if error-status :error
        then 
    do:
        message
            vss-workfile vss-revision vss-description
            skip 
            "Ошибка чтения параметров объекта клиента документа."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box warning.
    end.

    run torgconf-get-self-param in this-procedure (
        input buf_trn-doc.obj-type
        , input buf_trn-doc.obj-code
        , input v-curr-code
        ) no-error.
    if error-status :error
        then 
    do:
        message
            vss-workfile vss-revision vss-description
            skip 
            "Ошибка чтения параметров объекта документа."
            skip return-value
            skip trim( error-status :get-message( 1 ) )
            trim( error-status :get-message( 2 ) )
            trim( error-status :get-message( 3 ) )
            view-as alert-box warning.
    end.

    run torgconf-get-cli-param in this-procedure (
        input buf_trn-doc.host-code
        , input v-cli-type
        , input v-cli-code
        , input v-curr-code
        ) no-error.

    if error-status :error
        then 
    do:
        message
            vss-workfile vss-revision vss-description
            skip 
            "Ошибка чтения параметров объекта клиента документа."
            skip return-value
            skip trim( error-status :get-message( 1 ) )
            trim( error-status :get-message( 2 ) )
            trim( error-status :get-message( 3 ) )
            view-as alert-box warning.
    end.

    define variable v-param-type as character no-undo .
    define variable v-tth        as handle    no-undo .

    run adm/shattri.p (
        input "get":U
        ,input  '' /*p-obj-type*/
        ,input  0 /*p-obj-code*/
        ,input  {&attr-prt-glob}
        ,input  {&attr-prt-glob_rep-artic} /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output rep-artic
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) /*no-error*/ .
    if error-status:error or rep-artic = ? then 
    do:
        delete object v-tth no-error.
        define variable v-tooltip      as character no-undo .
        define variable v-label        as character no-undo .
        define variable v-tooltip-code as character no-undo .
        run thbjattr_tooltip in this-procedure (
            input  {&attr-prt-glob}
            ,input  {&attr-prt-glob_rep-artic}
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code ) no-error.
        if error-status:error then 
        do:
            assign
                v-tooltip-code = {&attr-prt-glob_rep-artic}
                v-tooltip      = {&attr-prt-glob}
                .
        end.
        message
            substitute("Не найден или незаполнен параметр:&2&1&2Секция <&3>"
            , v-tooltip-code
            , {&new-line}
            ,v-tooltip)
            view-as alert-box error .
        return .
    end.

    delete object v-tth no-error.

    assign
        v-single-line   = fill("-", 201)
        v-lines-counter = 1
        .
    run gbl/conf-rd.p ( "FGdsNinD", buf_trn-doc.host-code, buf_trn-doc.obj-type, buf_trn-doc.obj-code, "", "", "", no
        , output tmp-var, output v-par-type ) no-error.
    IF error-status:error
        then 
    do:
        assign
            FullGdsName = no
            .
    end.
    else 
    do:
        assign
            FullGdsName = ( tmp-var = "yes" )
            .
    end.

    run print-header in this-procedure (
        input buf_trn-doc.doc-code
        , output v-curr-abbr
        ).


    /*---S---------------- По строке документа -----------------------*/
    put stream OutStr-html unformatted
        '<TR style="height: 110px;">' skip
        '<TD text_wrap="true" rowspan="2" colspan="4" style="text-align: center;">№ п/п</TD>' skip
        '<TD text_wrap="true" rowspan="2" colspan="15" style="text-align: center;">Наименование товара (описание выполненных работ, оказанных услуг), имущественного права</TD>' skip
        '<TD text_wrap="true" rowspan="2" colspan="6" style="text-align: center;">Код вида товара</TD>' skip
        '<TD text_wrap="true" colspan="16" style="text-align: center;">Единица измерения</TD>' skip
        '<TD text_wrap="true" rowspan="2" colspan="7" style="text-align: center;">Количество (объем)</TD>' skip
        '<TD text_wrap="true" rowspan="2" colspan="9" style="text-align: center;">Цена (тариф) за единицу измерения</TD>' skip
        '<TD text_wrap="true" rowspan="2" colspan="11" style="text-align: center;">Стоимость товаров (работ, услуг), имущественных прав без налога - всего</TD>' skip
        '<TD text_wrap="true" rowspan="2" colspan="7" style="text-align: center;">В том числе сумма акциза</TD>' skip
        '<TD text_wrap="true" rowspan="2" colspan="7" style="text-align: center;">Налоговая ставка</TD>' skip
        '<TD text_wrap="true" rowspan="2" colspan="9" style="text-align: center;">Сумма налога, предъявляемая покупателю</TD>' skip
        '<TD text_wrap="true" rowspan="2" colspan="13" style="text-align: center;">Стоимость товаров (работ, услуг), имущественных прав с налогом - всего</TD>' skip
        '<TD text_wrap="true" colspan="17" style="text-align: center;">Страна происхождения товара</TD>' skip
        '<TD text_wrap="true" rowspan="2" colspan="15" style="text-align: center;">Регистрационный номер декларации на товары или регистрационный номер партии товара, подлежащего прослеживаемости</TD>' skip
        '<TD text_wrap="true" colspan="16" style="text-align: center;">Количественная единица измерения товара, используемая в целях осуществления прослеживаемости</TD>' skip
        '<TD text_wrap="true" rowspan="2" colspan="15" style="text-align: center;">Количество товара, подлежащего прослеживаемости, в количественной единице измерения товара, используемой в целях осуществления прослеживаемости</TD>' skip
        '</TR>'skip   
        '<TR style="height: 60px;">' skip
        '<TD text_wrap="true" colspan="5" style="text-align: center;">код</TD>' skip
        '<TD text_wrap="true" colspan="11" style="text-align: center;">условное обозначение (нициональное)</TD>' skip
        '<TD text_wrap="true" colspan="7" style="text-align: center;">цифровой код</TD>' skip
        '<TD text_wrap="true" colspan="10" style="text-align: center;">краткое наименование</TD>' skip
        '<TD text_wrap="true" colspan="7" style="text-align: center;">код</TD>' skip
        '<TD text_wrap="true" colspan="9" style="text-align: center;">условное обозначение</TD>' skip
        '</TR>'skip
        '<TR>' skip
        '<TD colspan="4" style="text-align: center;">1</TD>' skip
        '<TD colspan="15" style="text-align: center;">1а</TD>' skip
        '<TD colspan="6" style="text-align: center;">1б</TD>' skip
        '<TD colspan="5" style="text-align: center;">2</TD>' skip
        '<TD colspan="11" style="text-align: center;">2а</TD>' skip
        '<TD colspan="7" style="text-align: center;">3</TD>' skip
        '<TD colspan="9" style="text-align: center;">4</TD>' skip
        '<TD colspan="11" style="text-align: center;">5</TD>' skip
        '<TD colspan="7" style="text-align: center;">6</TD>' skip
        '<TD colspan="7" style="text-align: center;">7</TD>' skip
        '<TD colspan="9" style="text-align: center;">8</TD>' skip
        '<TD colspan="13" style="text-align: center;">9</TD>' skip
        '<TD colspan="7" style="text-align: center;">10</TD>' skip
        '<TD colspan="10" style="text-align: center;">10а</TD>' skip
        '<TD colspan="15" style="text-align: center;">11</TD>' skip
        '<TD colspan="7" style="text-align: center;">12</TD>' skip
        '<TD colspan="9" style="text-align: center;">12а</TD>' skip
        '<TD colspan="15" style="text-align: center;">13</TD>' skip
        '</TR>'skip     
        .
    define variable jj as integer no-undo .

    for each doc-line no-lock
        where doc-line.doc-code = buf_trn-doc.doc-code
        break &if "{&sort-prod}" = "yes" &then by ( doc-line.prod-type + string( doc-line.prod-code ) ) &endif by doc-line.artic
        :
        run print-line in this-procedure .
    end.        /*for  each doc-line ...*/
    /*---E---------------- По строке документа -----------------------*/
    put stream OutStr-html unformatted
        '</tbody>' skip.
    run print-footer in this-procedure .
    put stream OutStr-html unformatted
        '</tfoot>' skip
        '</table>' skip
        '</body>' skip
        '</html>' skip
        .
                            
    output stream OutStr-html close.     

    { gbl/stopwork.i }

    def var Log-Res as logical no-undo .
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_waybills-to-file_print':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    no
    Log-Res
}
    if Log-Res
        then 
    do:
    run prn-lib-reportviewer-report-name in this-procedure (
        input THIS-PROCEDURE
        ,input v-file-name-rep-html
        ).
        if error-status:error then
        do:
            message return-value view-as alert-box.
            return .
        end.
    end.
    else 
    do:
    run prn-lib-reportviewer-report-name in this-procedure (
        input THIS-PROCEDURE
        ,input v-file-name-rep-html
        ).
        if error-status:error then
        do:
            message return-value view-as alert-box.
            return .
        end.
    end.

end.

/*===============================================================================================*/
procedure print-more:
    do
        on error undo, return error
        :
        define variable v-start-string as character no-undo.
        define variable v-add-string   as character no-undo.
        assign
            v-start-string = gds-str2
            .

        do while trim(v-start-string) <> "" :
            assign 
                gds-str = v-start-string.
            v-add-string = breakstr(gds-str, {&gds-len}, input-output v-add-string, input-output v-start-string).
        end. /* DO WHILE ... */
    end.
end procedure.

/*==========================================================================*/
procedure print-line :
do
on error undo, return error
:
define variable v-print-parts     as logical    init no       no-undo.

assign v-add-str = ""
       v-start-str = ""
.
    find first ub.goods no-lock
         where ub.goods.prod-type = ub.doc-line.prod-type
           and ub.goods.prod-code = ub.doc-line.prod-code
           and ub.goods.artic = ub.doc-line.artic
    .
    find first ub.country no-lock
         where ub.country.alpha1 = ub.goods.alpha1
    no-error.
    if lookup( "zum", p-mode ) <> 0
    then do:
        assign
            v-country = ub.goods.engl-name
        .
    end.
    else do:
        if available ub.country and ub.country.num-code <> 643 /*Россия*/
        then do:
            assign
                v-country-code = " " + string(ub.country.num-code)
                v-country = ub.country.short-name
            .
        end.
        else do:
            assign
                v-country-code = ""
                v-country = ""
            .
        end.
    end.
    assign
        gds-str  = ''
        gds-str1 = ''
        gds-str2 = ''
    .
    find first ub.Units no-lock
         where ub.units.unit-name = ub.goods.unit-base
    .
    if v-uaes-code = "" then v-uaes-code = "-" . 
    v-unit-code = (if ub.units.OKEI = 0 then "-" else string(ub.units.OKEI)) .
    if (units.type = "{&bef-divisional},{&bef-twounit}"  or  ub.units.type = "{&bef-divisional},{&bef-altunit}" )
    then do:
        assign
            str =  (if rep-artic then (string(ub.goods.artic,"x(16)") +  " ") else "")  + string(ub.goods.Sort,"x(5)") + " " + trim(ub.goods.gds-name)
                                                                                 + " " + trim(ub.goods.PS)
        .
    end.
    else do:
        assign
            str = (if rep-artic then (string(ub.goods.artic,"x(16)") +  " ") else "")  + trim(ub.goods.gds-name)
        .
    end.
    assign
        Gds-str1 = breakstr(str, {&gds-len}, input-output gds-str1, input-output gds-str2)
    .
    do while trim(gds-str2) <> "" :
        assign
            gds-str = gds-str2
            gds-str1 = breakstr(gds-str, {&gds-len}, input-output gds-str1, input-output gds-str2)
        .
    end.
    assign
        gds-str1 = breakstr(str, {&gds-len}, input-output gds-str1, input-output gds-str2).
    .

    find first ub.gds-prt no-lock
         where ub.gds-prt.upper-code = ub.doc-line.prt-root
    .
    assign
        rootnode_code = ub.gds-prt.node-code
    .
    assign
            v-tot-prt-qnty          = 0
            v-tot-prt-doc-qnty      = 0
            v-tot-prt-VAT           = 0
            v-tot-prt-doc-VAT       = 0
            v-tot-prt-SLT           = 0
            v-tot-prt-sum-no-VAT    = 0
            v-tot-prt-doc-sum-no-VAT    = 0
            v-tot-prt-sum           = 0
            v-tot-prt-doc-sum           = 0
                v-VAT           = 0
                v-doc-VAT       = 0
                v-SLT           = 0
                v-sum-no-VAT    = 0
                v-doc-sum-no-VAT = 0
                v-tax           = 0
    .
    if ( ub.gds-prt.node-name <> {&empty-scale} )
/*    and ( not invers )*/
    then do:
        /*---S------------- Не пустая шкала и не от поставщика ---------------------*/
        assign
            v-tot-prt-qnty          = 0
            v-tot-prt-doc-qnty      = 0
            v-tot-prt-VAT           = 0
            v-tot-prt-doc-VAT       = 0
            v-tot-prt-SLT           = 0
            v-tot-prt-sum-no-VAT    = 0
            v-tot-prt-doc-sum-no-VAT    = 0
            v-tot-prt-sum           = 0
            v-tot-prt-doc-sum           = 0
            v-must-print-scale      = PrintScale
        .
        if v-must-print-scale = yes
        then do:
          define variable is-printed as logical initial no no-undo .
          for each ub.parts no-lock
             where ub.parts.out-code  = ub.doc-line.doc-code
               and ub.parts.obj-type  = ub.doc-line.obj-type
               and ub.parts.obj-code  = ub.doc-line.obj-code
               and ub.parts.artic     = ub.doc-line.artic
               and ub.parts.prod-type = ub.doc-line.prod-type
               and ub.parts.prod-code = ub.doc-line.prod-code
          :
            /*---S------------- По партиям - для печати ГТД ---------------------*/
            jj = jj + 1 . 
            assign v-GTD = (if trim(ub.parts.cst-code) <> "" then ub.parts.cst-code else "             -             ").
            if available ub.country
            and ub.country.alpha1 = "RU":U
            then do:
                assign
                    v-GTD       = "             -             ":U
                    v-country   = "":U
                    v-country-code = "":U
                .
            end.

            find first buf_parts-attr no-lock
              where buf_parts-attr.in-code   = ub.parts.in-code
                and buf_parts-attr.gds-code  = ub.goods.gds-code
                and buf_parts-attr.part-code = ub.parts.part-code
            no-error .
            if available buf_parts-attr
              and buf_parts-attr.country-code <> 0
              then do:
                  find first buf_country
                  where buf_country.num-code = buf_parts-attr.country-code
                  no-error.
                  if available buf_country
                  and buf_country.num-code <> ub.country.num-code
                  and buf_country.short-name <> "" and ub.country.num-code <> 643
                  then do :
                       assign
                          v-country-code = " " + string(buf_country.num-code)
                          v-country = buf_country.short-name
                        .
                       if buf_country.alpha1 = "RU":U
                       then do :
                          assign
                            v-country-code = "":U
                            v-country = "":U
                            v-GTD     = "             -             ":U
                          .
                       end .
                  end.
            end.
           /*---S------------- Печатать по шкале ---------------------*/
            if is-printed = no then do:
              assign is-printed = yes .
              if lookup ( "corr", p-mode ) <> 0 then do :
              end.
              else do :
                            put stream OutStr-html unformatted
                                '<TR>' skip
                                '<TD colspan="4" style="text-align: center;">' + string(jj) + '</TD>' skip
                                '<TD colspan="15" style="text-align: center;"></TD>' skip
                                '<TD colspan="6" style="text-align: center;"></TD>' skip
                                '<TD colspan="5" style="text-align: center;"></TD>' skip
                                '<TD colspan="11" style="text-align: center;"></TD>' skip
                                '<TD colspan="7" style="text-align: center;"></TD>' skip
                                '<TD colspan="9" style="text-align: center;"></TD>' skip
                                '<TD colspan="11" style="text-align: center;"></TD>' skip
                                '<TD colspan="7" style="text-align: center;"></TD>' skip
                                '<TD colspan="7" style="text-align: center;"></TD>' skip
                                '<TD colspan="9" style="text-align: center;"></TD>' skip
                                '<TD colspan="13" style="text-align: center;"></TD>' skip
                                '<TD colspan="7" style="text-align: center;">' + v-country-code + '</TD>' skip
                                '<TD colspan="10" style="text-align: center;">' + v-country + '</TD>' skip
                                '<TD colspan="15" style="text-align: center;">' + v-GTD + '</TD>' skip
                                '<TD colspan="7" style="text-align: center;"></TD>' skip
                                '<TD colspan="9" style="text-align: center;"></TD>' skip
                                '<TD colspan="15" style="text-align: center;"></TD>' skip
                                '</TR>'skip     
                                .   
            end.
            end.
            else do:
              if v-GTD <> "" and v-GTD <> "             -             " then do:
                            put stream OutStr-html unformatted
                                '<TR>' skip
                                '<TD colspan="4" style="text-align: center;">' + string(jj) + '</TD>' skip
                                '<TD colspan="15" style="text-align: center;"></TD>' skip
                                '<TD colspan="6" style="text-align: center;"></TD>' skip
                                '<TD colspan="5" style="text-align: center;"></TD>' skip
                                '<TD colspan="11" style="text-align: center;"></TD>' skip
                                '<TD colspan="7" style="text-align: center;"></TD>' skip
                                '<TD colspan="9" style="text-align: center;"></TD>' skip
                                '<TD colspan="11" style="text-align: center;"></TD>' skip
                                '<TD colspan="7" style="text-align: center;"></TD>' skip
                                '<TD colspan="7" style="text-align: center;"></TD>' skip
                                '<TD colspan="9" style="text-align: center;"></TD>' skip
                                '<TD colspan="13" style="text-align: center;"></TD>' skip
                                '<TD colspan="7" style="text-align: center;"></TD>' skip
                                '<TD colspan="10" style="text-align: center;"></TD>' skip
                                '<TD colspan="15" style="text-align: center;">' + v-GTD + '</TD>' skip
                                '<TD colspan="7" style="text-align: center;"></TD>' skip
                                '<TD colspan="9" style="text-align: center;"></TD>' skip
                                '<TD colspan="15" style="text-align: center;"></TD>' skip
                                '</TR>'skip     
                                .    
              end.
            end.
          end.
          if is-printed = no then do:
                    put stream OutStr-html unformatted
                        '<TR>' skip
                        '<TD colspan="4" style="text-align: center;">' + string(jj) + '</TD>' skip
                        '<TD text_wrap="true" colspan="15" style="text-align: center;">' + if rep-artic then (string(goods.artic,"x(16)") +  " ") + goods.gds-name  /*  p-Name     */ + '</TD>' else goods.gds-name + '</td>' skip
                        '<TD colspan="6" style="text-align: center;"></TD>' skip
                        '<TD colspan="5" style="text-align: center;"></TD>' skip
                        '<TD colspan="11" style="text-align: center;"></TD>' skip
                        '<TD colspan="7" style="text-align: center;"></TD>' skip
                        '<TD colspan="9" style="text-align: center;"></TD>' skip
                        '<TD colspan="11" style="text-align: center;"></TD>' skip
                        '<TD colspan="7" style="text-align: center;"></TD>' skip
                        '<TD colspan="7" style="text-align: center;"></TD>' skip
                        '<TD colspan="9" style="text-align: center;"></TD>' skip
                        '<TD colspan="13" style="text-align: center;"></TD>' skip
                        '<TD colspan="7" style="text-align: center;">' + v-country-code + '</TD>' skip
                        '<TD colspan="10" style="text-align: center;">' + v-country + '</TD>' skip
                        '<TD colspan="15" style="text-align: center;"></TD>' skip
                        '<TD colspan="7" style="text-align: center;"></TD>' skip
                        '<TD colspan="9" style="text-align: center;"></TD>' skip
                        '<TD colspan="15" style="text-align: center;"></TD>' skip
                        '</TR>'skip     
                        .
            if FullGdsName
            and gds-str1 <> "":U then do :
               run print-more in this-procedure.
            end.
          end.
          /*  run print-more in this-procedure. */
          /*---E------------- Печатать по шкале ---------------------*/
        end.        /* if v-must-print-scale = yes */
        for each ub.gds-dtl no-lock
           where ub.gds-dtl.prod-type  = ub.doc-line.prod-type
             and ub.gds-dtl.prod-code  = ub.doc-line.prod-code
             and ub.gds-dtl.artic      = ub.doc-line.artic
             and ub.gds-dtl.doc-code   = ub.doc-line.doc-code
        :
            /*---S------------- for each ub.gds-dtl ---------------------*/
            find first ub.gds-prt no-lock
                 where ub.gds-prt.node-code = ub.gds-dtl.prt-code
            .
            if CostPrice = yes
            then do:
                { str/in-vatp.i calc ub.doc-line. buf_trn-doc. g }
                assign
                    v-VAT       = ( if PrintRubl then vat-rubl-loc      else vat-base-loc )
                    v-SLT       = ( if PrintRubl then slt-rubl-loc      else slt-base-loc )
                .
                if v-VAT = ?        then assign v-VAT       = 0.
                if v-SLT = ?        then assign v-SLT       = 0.
                assign
/*                        v-price-no-VAT = ( if PrintRubl*/
/*                                        then price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - road-tax-rubl-loc*/
/*                                        else price-base-with-tax-loc - vat-base-loc - slt-base-loc - road-tax-base-loc)*/
                    v-price-no-VAT   = ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc ) - v-VAT - v-SLT
                    v-prt-qnty       = ub.gds-dtl.fact-qnty
                    v-prt-doc-qnty   = ub.gds-dtl.doc-qnty
                .
                if v-r-factur-is-vozvrat-vnesh = yes
                then do:
                    assign
                        v-price-no-VAT = v-price-no-VAT -
                                        ( if PrintRubl
                                            then ( transport-rubl-loc + other-rubl-loc )
                                            else ( transport-base-loc + other-base-loc ) )
                    .
                end.
                if p-round = 'round':U
                then do:
                    run p-fmt-round in this-procedure (
                          input v-prt-qnty
                        , input v-price-no-VAT
                        , input v-VAT
                        , input v-SLT
                        , input 0
                        , output v-price-no-VAT
                        , output v-VAT
                        , output v-SLT
                        , output v-prt-VAT
                        , output v-prt-SLT
                        , output v-void-decimal
                        , output v-prt-sum-no-VAT
                        , output v-void-decimal
                    ).
/*                    assign*/
/*                        v-vat-pc            = v-VAT / v-price-no-VAT*/
/*                        v-slt-pc            = v-SLT / ( v-price-no-VAT + v-VAT )*/
/*                        v-price-no-VAT      = round( v-price-no-VAT, 2 )*/
/*                        v-VAT               = round( v-price-no-VAT * v-vat-pc, 2 )*/
/*                        v-prt-SLT           = round( ( v-price-no-VAT + v-VAT ) * v-prt-qnty * v-slt-pc, 2 )*/
/*                        v-prt-VAT           = round( v-VAT          * v-prt-qnty, 2 )*/
/*                        v-prt-sum-no-VAT    = round( v-price-no-VAT * v-prt-qnty, 2 )*/
/*                    .*/
                end.        /* if p-round = 'round':U */
                else do:
                    assign
                        v-prt-VAT       =  v-VAT            * v-prt-qnty
                        v-prt-doc-VAT   =  v-VAT            * v-prt-doc-qnty
                        v-prt-SLT        = v-SLT            * v-prt-qnty
                        v-prt-sum-no-VAT = v-price-no-VAT   * v-prt-qnty
                        v-prt-doc-sum-no-VAT = v-price-no-VAT   * v-prt-doc-qnty
                    .
                end.        /* if NOT( p-round = 'round':U ) */
                assign
                    v-price          = v-price-no-VAT + v-VAT
                    v-prt-sum        = v-prt-sum-no-VAT + v-prt-VAT
                    v-prt-doc-sum    = v-prt-doc-sum-no-VAT + v-prt-doc-VAT
                .
                assign
                    v-tot-prt-qnty          = v-tot-prt-qnty        + v-prt-qnty
                    v-tot-prt-doc-qnty      = v-tot-prt-doc-qnty    + v-prt-doc-qnty
                    v-tot-prt-VAT           = v-tot-prt-VAT         + v-prt-VAT
                    v-tot-prt-doc-VAT       = v-tot-prt-doc-VAT     + v-prt-doc-VAT
                    v-tot-prt-SLT           = v-tot-prt-SLT         + v-prt-SLT
                    v-tot-prt-sum-no-VAT    = v-tot-prt-sum-no-VAT  + v-prt-sum-no-VAT
                    v-tot-prt-doc-sum-no-VAT = v-tot-prt-doc-sum-no-VAT  + v-prt-doc-sum-no-VAT
                    v-tot-prt-sum           = v-tot-prt-sum         + v-prt-sum
                    v-tot-prt-doc-sum       = v-tot-prt-doc-sum     + v-prt-doc-sum
                .
            end.        /* CostPrice = yes  */
            else do:
                { str/out-vatp.i calc-gds-dtl ub.doc-line. buf_trn-doc. ub.gds-dtl. }
                assign
                    v-VAT = ( if PrintRubl then vat-rubl-buyer else vat-base-buyer )
                    v-SLT = ( if PrintRubl then slt-rubl-sale else slt-base-sale )
                .
                if v-VAT = ? then assign v-VAT = 0.
                if v-SLT = ? then assign v-SLT = 0.
                assign
                    v-price-no-VAT   = ( if PrintRubl then price-rubl-with-tax-sale else price-base-with-tax-sale ) - v-VAT - v-SLT
                    v-prt-qnty       = ub.gds-dtl.fact-qnty
                    v-prt-doc-qnty   = ub.gds-dtl.doc-qnty
                .
                if p-round = 'round':U
                then do:
                    run p-fmt-round in this-procedure (
                          input v-prt-qnty
                        , input v-price-no-VAT
                        , input v-VAT
                        , input v-SLT
                        , input 0
                        , output v-price-no-VAT
                        , output v-VAT
                        , output v-SLT
                        , output v-prt-VAT
                        , output v-prt-SLT
                        , output v-void-decimal
                        , output v-prt-sum-no-VAT
                        , output v-void-decimal
                    ).
/*                    assign*/
/*                        v-vat-pc            = v-VAT / v-price-no-VAT*/
/*                        v-slt-pc            = v-SLT / ( v-price-no-VAT + v-VAT )*/
/*                        v-price-no-VAT      = round( v-price-no-VAT, 2 )*/
/*                        v-VAT               = round( v-price-no-VAT * v-vat-pc, 2 )*/
/*                        v-prt-SLT           = round( ( v-price-no-VAT + v-VAT ) * v-prt-qnty * v-slt-pc, 2 )*/
/*                        v-prt-VAT           = round( v-VAT          * v-prt-qnty, 2 )*/
/*                        v-prt-sum-no-VAT    = round( v-price-no-VAT * v-prt-qnty, 2 )*/
/*                    .*/
                end.        /* p-round = 'round':U */
                else do:
                    assign
                        v-prt-VAT        = v-VAT          * v-prt-qnty
                        v-prt-doc-VAT    = v-VAT          * v-prt-doc-qnty
                        v-prt-SLT        = v-SLT          * v-prt-qnty
                        v-prt-sum-no-VAT = v-price-no-VAT * v-prt-qnty
                        v-prt-doc-sum-no-VAT = v-price-no-VAT * v-prt-doc-qnty
                    .
                end.        /* NOT ( p-round = 'round':U ) */
                assign
                    v-price          = v-price-no-VAT + v-VAT
                    v-prt-sum        = v-prt-sum-no-VAT + v-prt-VAT
                    v-prt-doc-sum        = v-prt-doc-sum-no-VAT + v-prt-doc-VAT
                .
                assign
                    v-tot-prt-qnty          = v-tot-prt-qnty        + v-prt-qnty
                    v-tot-prt-doc-qnty      = v-tot-prt-doc-qnty    + v-prt-doc-qnty
                    v-tot-prt-VAT           = v-tot-prt-VAT         + v-prt-VAT
                    v-tot-prt-doc-VAT       = v-tot-prt-doc-VAT     + v-prt-doc-VAT
                    v-tot-prt-SLT           = v-tot-prt-SLT         + v-prt-SLT
                    v-tot-prt-sum-no-VAT    = v-tot-prt-sum-no-VAT  + v-prt-sum-no-VAT
                    v-tot-prt-doc-sum-no-VAT = v-tot-prt-doc-sum-no-VAT  + v-prt-doc-sum-no-VAT
                    v-tot-prt-sum           = v-tot-prt-sum         + v-prt-sum
                    v-tot-prt-doc-sum       = v-tot-prt-doc-sum     + v-prt-doc-sum
                .
            end.        /* NOT ( CostPrice = yes  ) */
            if v-must-print-scale
            then do:
                /*---S------------- Печатать шкалу ---------------------*/
                find first ub.bar-code no-lock
                     where ub.bar-code.gds-code    = ub.goods.gds-code
                       and ub.bar-code.unit-cli    = ub.goods.unit-base
                       and ub.bar-code.node-code   = ub.gds-dtl.prt-code
                       and ub.bar-code.part-code   = ""
                       and ub.bar-code.in-code     = ""
                .
                assign
                    v-prt-name = ""
                .
                do while available ub.gds-prt:
                    if available ub.gds-prt
                    then do:
                        assign
                            v-prt-name     = "\" + string( ub.gds-prt.node-name, "X(10)" ) + v-prt-name
                            v-node-code   = ub.gds-prt.upper-code
                        .
                    end.
                    find first ub.gds-prt no-lock
                         where ub.gds-prt.node-code = v-node-code
                           and ub.gds-prt.root <> yes
                    no-error.
                end.
                if lookup ( "corr" , p-mode ) <> 0 then do :
                end.
                else do :
                        put stream OutStr-html unformatted
                            '<TR>' skip
                            '<TD colspan="4" style="text-align: center;">' + string(jj) + '</TD>' skip
                            '<TD text_wrap="true" colspan="15" style="text-align: center;">' + string(v-prt-name) + '</TD>' skip
                            '<TD colspan="6" style="text-align: center;">' + v-uaes-code + '</TD>' skip
                            '<TD colspan="5" style="text-align: center;">' + v-unit-code + '</TD>' skip
                            '<TD colspan="11" style="text-align: center;">' + goods.unit-base + '</TD>' skip
                            '<TD colspan="7" style="text-align: center;">' + string(v-prt-qnty)+ '</TD>' skip
                            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-price-no-VAT,"->>>>>>>>>>>9.99",2) + '" colspan="9" style="text-align: right;">' + fnc-convert-dot-to-colon(v-price-no-VAT,"->>>>>>>>>>>9.99",2) + '</TD>' skip
                            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-prt-doc-sum-no-VAT,"->>>>>>>>>>>9.99",2) + '" colspan="11" style="text-align: right;">' + fnc-convert-dot-to-colon(v-prt-doc-sum-no-VAT,"->>>>>>>>>>>9.99",2) + '</TD>' skip
                            '<TD colspan="7" style="text-align: center;">без акциза</TD>' skip
                            '<TD colspan="7" style="text-align: center;">' + string (doc-line.VAT-pc) + '</TD>' skip
                            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-prt-VAT,"->>>>>>>>>>>9.99",2) + '" colspan="9" style="text-align: right;">' + fnc-convert-dot-to-colon(v-prt-VAT,"->>>>>>>>>>>9.99",2) + '</TD>' skip
                            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-prt-sum,"->>>>>>>>>>>9.99",2) + '" colspan="13" style="text-align: right;">' + fnc-convert-dot-to-colon(v-prt-sum,"->>>>>>>>>>>9.99",2) + '</TD>' skip
                            '<TD colspan="7" style="text-align: center;"></TD>' skip
                            '<TD colspan="10" style="text-align: center;"></TD>' skip
                            '<TD colspan="15" style="text-align: center;"></TD>' skip
                            '<TD colspan="7" style="text-align: center;"></TD>' skip
                            '<TD colspan="9" style="text-align: center;"></TD>' skip
                            '<TD colspan="15" style="text-align: center;"></TD>' skip
                            '</TR>'skip
                            .
                end.
                /*---E------------- Печатать шкалу ---------------------*/
            end.
            /*---E------------- for each ub.gds-dtl ---------------------*/
        end.

        assign
            v-qnty          = v-tot-prt-qnty
            v-doc-qnty      = v-tot-prt-doc-qnty
            v-VAT           = v-tot-prt-VAT
            v-doc-VAT       = v-tot-prt-doc-VAT
            v-SLT           = v-tot-prt-SLT
            v-sum-no-VAT    = v-tot-prt-sum-no-VAT
            v-doc-sum-no-VAT = v-tot-prt-doc-sum-no-VAT
            v-sum           = v-tot-prt-sum
            v-doc-sum       = v-tot-prt-doc-sum
        .

        if not v-must-print-scale
        then do:
            /*---S------------- Не печатать признаки ---------------------*/
            assign v-price-no-VAT = v-sum-no-VAT / v-qnty.
            find first ub.bar-code no-lock
                    where ub.bar-code.gds-code = ub.goods.gds-code
                    and ub.bar-code.unit-cli = ub.goods.unit-base
                    and ub.bar-code.node-code = rootnode_code
                    and ub.bar-code.part-code = ""
                    and ub.bar-code.in-code = ""
            .
            for each ub.parts no-lock
                where ub.parts.out-code = ub.doc-line.doc-code
                    and ub.parts.obj-type = ub.doc-line.obj-type
                    and ub.parts.obj-code = ub.doc-line.obj-code
                    and ub.parts.artic = ub.doc-line.artic
                    and ub.parts.prod-type = ub.doc-line.prod-type
                    and ub.parts.prod-code = ub.doc-line.prod-code
            :
                    /*---S------------- По партиям ---------------------*/
                    jj = jj + 1 .
                    assign v-GTD = (if trim(ub.parts.cst-code) <> "" then ub.parts.cst-code else "             -             ").
                    if available ub.country
                    and ub.country.alpha1 = "RU":U
                    then do:
                        assign
                            v-GTD       = "             -             ":U
                            v-country   = "":U
                            v-country-code = "":U
                        .
                    end.
                    find first buf_parts-attr no-lock
                      where buf_parts-attr.in-code   = ub.parts.in-code
                        and buf_parts-attr.gds-code  = ub.goods.gds-code
                        and buf_parts-attr.part-code = ub.parts.part-code
                    no-error .
                    if available buf_parts-attr
                      and buf_parts-attr.country-code <> 0
                      then do:
                          find first buf_country
                          where buf_country.num-code = buf_parts-attr.country-code
                          no-error.
                          if available buf_country
                          and buf_country.num-code <> ub.country.num-code
                          and buf_country.short-name <> "" and ub.country.num-code <> 643
                          then do :
                              assign
                                  v-country-code = " " + string(buf_country.num-code)
                                  v-country = buf_country.short-name
                                .
                              if buf_country.alpha1 = "RU":U
                              then do :
                                  assign
                                    v-country-code = "":U
                                    v-country = "":U
                                    v-GTD     = "             -             ":U
                                  .
                              end .
                          end.
                    end.
                    if lookup ( "corr" , p-mode) <> 0 then do :
                    end.
                    else do :
                        put stream OutStr-html unformatted
                            '<TR>' skip
                            '<TD colspan="4" style="text-align: center;">' + string(jj) + '</TD>' skip
                            '<TD text_wrap="true" colspan="15" style="text-align: center;">' + if rep-artic then (string(ub.goods.artic) + " " + string (ub.goods.gds-name)) + '</TD>' else string(ub.goods.gds-name) + '</td>' skip
                            '<TD colspan="6" style="text-align: center;">' + v-uaes-code + '</TD>' skip
                            '<TD colspan="5" style="text-align: center;">' + v-unit-code + '</TD>' skip
                            '<TD colspan="11" style="text-align: center;">' + ub.goods.unit-base + '</TD>' skip
                            '<TD colspan="7" style="text-align: center;">' + string(ub.parts.fact-qnty) + '</TD>' skip
                            '<TD colspan="9" style="text-align: center;">' + string(v-price-no-VAT)+ '</TD>' skip
                            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon((v-sum-no-VAT * ub.parts.fact-qnty / v-qnty),"->>>>>>>>>>>9.99",2) + '" colspan="11" style="text-align: right;">' + if v-qnty <> 0 then fnc-convert-dot-to-colon((v-sum-no-VAT * ub.parts.fact-qnty / v-qnty),"->>>>>>>>>>>9.99",2) + '</TD>' else "0" + '</td>' skip
                            '<TD colspan="7" style="text-align: center;">без акциза</TD>' skip
                            '<TD colspan="7" style="text-align: center;">' + string (doc-line.VAT-pc) + '</TD>' skip
                            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(( v-VAT * ub.parts.fact-qnty / v-qnty ),"->>>>>>>>>>>9.99",2) + '" colspan="9" style="text-align: right;">' + if v-qnty <> 0 then fnc-convert-dot-to-colon(( v-VAT * ub.parts.fact-qnty / v-qnty ),"->>>>>>>>>>>9.99",2) + '</TD>' else "0" + '</td>' skip
                            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon((v-sum * ub.parts.fact-qnty / v-qnty),"->>>>>>>>>>>9.99",2) + '" colspan="13" style="text-align: right;">' + if v-qnty <> 0 then fnc-convert-dot-to-colon((v-sum * ub.parts.fact-qnty / v-qnty),"->>>>>>>>>>>9.99",2) + '</TD>' else "0" + '</TD>' skip
                            '<TD colspan="7" style="text-align: center;">' + v-country-code + '</TD>' skip
                            '<TD colspan="10" style="text-align: center;">' + v-country + '</TD>' skip
                            '<TD colspan="15" style="text-align: center;">' + v-GTD + '</TD>' skip
                            '<TD colspan="7" style="text-align: center;"></TD>' skip
                            '<TD colspan="9" style="text-align: center;"></TD>' skip
                            '<TD colspan="15" style="text-align: center;"></TD>' skip
                            '</TR>'skip
                            .    
                    if FullGdsName
                    and goods.gds-name <> "":U then do :
                      run print-more in this-procedure.
                    end.
                    end.
                    v-lines-counter = v-lines-counter + 1 .
                    /*---E------------- По партиям ---------------------*/
            end.
            /*---E------------- Не печатать признаки ---------------------*/
        end.
        /*---E------------- Не пустая шкала и не от поставщика ---------------------*/
    end.
    else do:
        /*---S------------- Пустая шкала или от поставщика ---------------------*/
        find first ub.bar-code no-lock
                where ub.bar-code.gds-code = ub.goods.gds-code
                and ub.bar-code.unit-cli = ub.goods.unit-base
                and ub.bar-code.node-code = rootnode_code
                and ub.bar-code.part-code = ""
                and ub.bar-code.in-code = ""
        .
        if CostPrice = yes
        then do:
            /*---S------------------- Счет-фактура от поставщика -----------------*/
            assign v-qnty = ub.doc-line.doc-qnty.

            { str/in-vatp.i calc ub.doc-line. buf_trn-doc. g }
            assign
                v-VAT       = ( if PrintRubl then vat-rubl-loc      else vat-base-loc )
                v-SLT       = ( if PrintRubl then slt-rubl-loc      else slt-base-loc )
                v-tax-price = ( if PrintRubl then road-tax-rubl-loc else road-tax-base-loc )
            .
            if v-VAT = ?        then assign v-VAT       = 0.
            if v-SLT = ?        then assign v-SLT       = 0.
            if v-tax-price = ?  then assign v-tax-price = 0.
            assign
                    v-price-no-VAT = ( if PrintRubl
                                        then price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - road-tax-rubl-loc
                                        else price-base-with-tax-loc - vat-base-loc - slt-base-loc - road-tax-base-loc)
            .
            if v-r-factur-is-vozvrat-vnesh = yes
            then do:
                assign
                    v-price-no-VAT = v-price-no-VAT
                                    - ( if PrintRubl
                                        then ( transport-rubl-loc + other-rubl-loc )
                                        else ( transport-base-loc + other-base-loc ) )
                .
            end.
            /*---E------------------- Счет-фактура от поставщика -----------------*/
        end.
        else do:
            /*---S---------------------- Обычный счет-фактура --------------------*/
            find first ub.gds-dtl no-lock
                 where ub.gds-dtl.doc-code = ub.doc-line.doc-code
                   and ub.gds-dtl.prod-type = ub.doc-line.prod-type
                   and ub.gds-dtl.prod-code = ub.doc-line.prod-code
                   and ub.gds-dtl.artic = ub.doc-line.artic
                   and ub.gds-dtl.prt-code = rootnode_code
            .
            assign
                v-qnty = ub.gds-dtl.fact-qnty
                v-doc-qnty = ub.gds-dtl.doc-qnty
            .
            { str/out-vatp.i calc-gds-dtl ub.doc-line. buf_trn-doc. ub.gds-dtl. }
            assign
                v-VAT       = ( if PrintRubl then vat-rubl-buyer        else vat-base-buyer )
                v-SLT       = ( if PrintRubl then slt-rubl-sale         else slt-base-sale )
                v-tax-price = ( if PrintRubl then road-tax-rubl-sale    else road-tax-base-sale )
                v-doc-VAT   = v-VAT
            .
            if v-VAT = ?        then assign v-VAT       = 0.
            if v-SLT = ?        then assign v-SLT       = 0.
            if v-tax-price = ?  then assign v-tax-price = 0.

            assign
                v-price-no-VAT = ( if PrintRubl
                                   then price-rubl-with-tax-sale
                                   else price-base-with-tax-sale ) - v-VAT - v-SLT - v-tax-price
            .
            /*---E---------------------- Обычный счет-фактура --------------------*/
        end.
        if p-round = 'round':U
        then do:
                run p-fmt-round in this-procedure (
                      input v-qnty
                    , input v-price-no-VAT
                    , input v-VAT
                    , input v-SLT
                    , input v-tax-price
                    , output v-price-no-VAT
                    , output v-void-decimal
                    , output v-void-decimal
                    , output v-VAT
                    , output v-SLT
                    , output v-tax
                    , output v-sum-no-VAT
                    , output v-void-decimal
                ).
/*            assign*/
/*                        v-vat-pc            = v-VAT / v-price-no-VAT*/
/*                        v-slt-pc            = v-SLT / ( v-price-no-VAT + v-VAT )*/
/*                        v-price-no-VAT      = round( v-price-no-VAT, 2 )*/
/*                        v-VAT               = round( round( v-price-no-VAT * v-vat-pc, 2 ) * v-qnty, 2 )*/
/*                        v-SLT               = round( ( v-price-no-VAT * v-qnty + v-VAT ) * v-slt-pc, 2 )*/
/*                        v-sum-no-VAT        = round( v-price-no-VAT * v-qnty, 2 )*/
/*                        v-tax               = round( v-tax-price * v-qnty, 2 )*/
/*            .*/
        end.        /* p-round = 'round':U */
        else do:
            assign
                v-VAT           = v-VAT * v-qnty
                v-doc-VAT       = v-doc-VAT * v-doc-qnty
                v-SLT           = v-SLT * v-qnty
                v-sum-no-VAT    = v-price-no-VAT * v-qnty
                v-doc-sum-no-VAT = v-price-no-VAT * v-doc-qnty
                v-tax           = v-tax-price * v-qnty
            .
        end.        /* NOT ( p-round = 'round':U ) */
        assign
            v-sum           = v-sum-no-VAT + v-VAT
            v-doc-sum       = v-doc-sum-no-VAT + v-doc-VAT
        .
        if ub.goods.gds-type = {&gds-office}
        or PrintScale
        then do:
            /*---S------------- Услуга ---------------------*/
          if lookup ( "corr" , p-mode ) <> 0 then do :
          end.
          else do :
                    put stream OutStr-html unformatted
                        '<TR>' skip
                        '<TD colspan="4" style="text-align: center;">' + string(jj) + '</TD>' skip
                        '<TD text_wrap="true" colspan="15" style="text-align: center;">' + if rep-artic then string(ub.goods.artic + " " + ub.goods.gds-name) + '</TD>' else string(ub.goods.gds-name) + '</td>' skip
                        '<TD colspan="6" style="text-align: center;">' + v-uaes-code + '</TD>' skip
                        '<TD colspan="5" style="text-align: center;">' + v-unit-code + '</TD>' skip
                        '<TD colspan="11" style="text-align: center;">' + if invers then doc-line.unit-cli + '</TD>' else goods.unit-base + '</td>'skip
                        '<TD colspan="7" style="text-align: center;">' + string(v-qnty)+ '</TD>' skip
                        '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-price-no-VAT,"->>>>>>>>>>>9.99",2) + '" colspan="9" style="text-align: right;">' + fnc-convert-dot-to-colon(v-price-no-VAT,"->>>>>>>>>>>9.99",2) + '</TD>' skip
                        '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-sum-no-VAT,"->>>>>>>>>>>9.99",2) + '" colspan="11" style="text-align: right;">' + fnc-convert-dot-to-colon(v-sum-no-VAT,"->>>>>>>>>>>9.99",2) + '</TD>' skip
                        '<TD colspan="7" style="text-align: center;">без акциза</TD>' skip
                        '<TD colspan="7" style="text-align: center;">' + string (doc-line.VAT-pc,"99") + '</TD>' skip
                        '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-VAT,"->>>>>>>>>>>9.99",2) + '" colspan="9" style="text-align: right;">' + fnc-convert-dot-to-colon(v-VAT,"->>>>>>>>>>>9.99",2) + '</TD>' skip
                        '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-sum,"->>>>>>>>>>>9.99",2) + '" colspan="13" style="text-align: right;">' + fnc-convert-dot-to-colon(v-sum,"->>>>>>>>>>>9.99",2) + '</TD>' skip
                        '<TD colspan="10" style="text-align: center;">' + v-country-code + '</TD>' skip
                        '<TD colspan="15" style="text-align: center;">' + v-country + '</TD>' skip
                        '<TD colspan="7" style="text-align: center;"></TD>' skip
                        '<TD colspan="9" style="text-align: center;"></TD>' skip
                        '<TD colspan="15" style="text-align: center;"></TD>' skip
                        '</TR>'skip
                        .
            if FullGdsName
            and gds-str1 <> "":U then do :
               run print-more in this-procedure.
            end.
          end.

            assign v-lines-counter = v-lines-counter + 1.
            /*---E------------- Услуга ---------------------*/
        end.
        else do:
            /*---S------------- Не услуга ---------------------*/
            define variable v-first-parts   as logical     no-undo.
            assign
                v-first-parts = yes
            .
            for each ub.parts no-lock
               where ub.parts.out-code  = ub.doc-line.doc-code
                 and ub.parts.obj-type  = ub.doc-line.obj-type
                 and ub.parts.obj-code  = ub.doc-line.obj-code
                 and ub.parts.artic     = ub.doc-line.artic
                 and ub.parts.prod-type = ub.doc-line.prod-type
                 and ub.parts.prod-code = ub.doc-line.prod-code
            :
                /*---S------------- Для каждой партии ---------------------*/
                jj = jj + 1 .
                assign
                    v-GTD       = (if trim(ub.parts.cst-code) <> "" then ub.parts.cst-code else "             -             ")
                    v-prt-qnty  = ub.parts.fact-qnty
                    v-prt-doc-qnty = ub.parts.qnty
                .
                if available ub.country
                and ub.country.alpha1 = "RU":U
                then do:
                    assign
                        v-GTD       = "             -             ":U
                        v-country-code   = "":U
                        v-country   = "":U
                    .
                end.
                find first buf_parts-attr no-lock
                  where buf_parts-attr.in-code   = ub.parts.in-code
                    and buf_parts-attr.gds-code  = ub.goods.gds-code
                    and buf_parts-attr.part-code = ub.parts.part-code
                no-error .
                if available buf_parts-attr
                  and buf_parts-attr.country-code <> 0
                  then do:
                      find first buf_country
                      where buf_country.num-code = buf_parts-attr.country-code
                      no-error.
                      if available buf_country
                      and buf_country.num-code <> ub.country.num-code
                      and buf_country.short-name <> "" and ub.country.num-code <> 643
                      then do :
                          assign
                              v-country-code = " " + string(buf_country.num-code)
                              v-country = buf_country.short-name
                            .
                          if buf_country.alpha1 = "RU":U
                          then do :
                              assign
                                v-country-code   = "":U
                                v-country = "":U
                                v-GTD     = "             -             ":U
                              .
                          end .
                      end.
                end.
                
                if CostPrice = yes
                then do:
/* Если приход, то цену по партиям не осреднять, печатать как есть */
                    { str/in-vatp.i calc-parts ub.parts. buf_trn-doc. g }
                    assign
                        v-parts-VAT       = ( if PrintRubl then vat-rubl-loc      else vat-base-loc )
                        v-parts-SLT       = ( if PrintRubl then slt-rubl-loc      else slt-base-loc )
                        v-tax-price       = ( if PrintRubl then road-tax-rubl-loc else road-tax-base-loc )
                    .
                    if v-parts-VAT = ?  then assign v-parts-VAT = 0.
                    if v-parts-SLT = ?  then assign v-parts-SLT = 0.
                    if v-tax-price = ?  then assign v-tax-price = 0.
                    assign
                        v-parts-price-no-VAT    =
                                          ( if PrintRubl
                                          then price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - road-tax-rubl-loc
                                          else price-base-with-tax-loc - vat-base-loc - slt-base-loc - road-tax-base-loc )
                        v-parts-sum             =
                                          ( if PrintRubl
                                          then price-rubl-with-tax-loc
                                          else price-base-with-tax-loc ) * v-prt-qnty
                    .
                    if v-r-factur-is-vozvrat-vnesh = yes
                    then do:
                        assign
                            v-parts-price-no-VAT = v-parts-price-no-VAT
                                            - ( if PrintRubl
                                                then ( transport-rubl-loc + other-rubl-loc )
                                                else ( transport-base-loc + other-base-loc ) )
                            v-parts-sum          = v-parts-sum
                                            - ( ( if PrintRubl
                                                  then ( transport-rubl-loc + other-rubl-loc )
                                                  else ( transport-base-loc + other-base-loc ) ) * v-prt-qnty )
                        .
                    end.
                    if p-round = 'round':U
                    then do:
                        if v-first-parts = yes
                        then do:
                            assign
                                v-first-parts   = no
                                v-sum-no-VAT    = 0
                                v-VAT           = 0
                                v-SLT           = 0
                                v-tax           = 0
                                v-sum           = 0
                            .
                        end.
                        run p-fmt-round in this-procedure (
                              input v-prt-qnty
                            , input v-parts-price-no-VAT
                            , input v-parts-VAT
                            , input v-parts-SLT
                            , input v-tax-price
                            , output v-parts-price-no-VAT
                            , output v-parts-VAT
                            , output v-parts-SLT
                            , output v-sum-VAT
                            , output v-sum-SLT
                            , output v-sum-tax
                            , output v-parts-sum-no-VAT
                            , output v-parts-sum
                        ).
/*                        assign*/
/*                            v-vat-pc                = v-parts-VAT / v-parts-price-no-VAT*/
/*                            v-slt-pc                = v-parts-SLT / ( v-parts-price-no-VAT + v-parts-VAT )*/
/*                            v-parts-price-no-VAT    = round( v-parts-price-no-VAT, 2 )*/
/*                            v-parts-VAT             = round( v-parts-price-no-VAT * v-vat-pc, 2 )*/
/*                            v-parts-SLT             = round( ( v-parts-price-no-VAT * v-prt-qnty + v-parts-VAT ) * v-slt-pc, 2 )*/
/*                            v-parts-sum             = round( ( v-parts-price-no-VAT + v-parts-VAT + v-parts-SLT*/
/*                                                                + ( if PrintRubl*/
/*                                                                    then road-tax-rubl-loc*/
/*                                                                    else road-tax-base-loc )*/
/*                                                             ) * v-prt-qnty, 2 )*/
/*                        .*/
                        assign
                            v-sum-no-VAT    = v-sum-no-VAT  + v-parts-sum-no-VAT
                            v-VAT           = v-VAT         + v-sum-VAT
                            v-SLT           = v-SLT         + v-sum-SLT
                            v-tax           = v-tax         + v-sum-tax
                            v-sum           = v-sum         + v-parts-sum
                        .
                    end.        /* p-round = 'round':U */
                    if lookup ( "corr" , p-mode ) <> 0 then do :
                    end.
                    else do :
                            put stream OutStr-html unformatted
                                '<TR>' skip
                                '<TD colspan="4" style="text-align: center;">' + string(jj) + '</TD>' skip
                                '<TD text_wrap="true" colspan="15" style="text-align: center;">' + if rep-artic then string(ub.goods.artic + " " + ub.goods.gds-name) + '</TD>' else string(ub.goods.gds-name) + '</td>' skip
                                '<TD colspan="6" style="text-align: center;">' + v-uaes-code + '</TD>' skip
                                '<TD colspan="5" style="text-align: center;">' + v-unit-code + '</TD>' skip
                                '<TD colspan="11" style="text-align: center;">' + if invers then doc-line.unit-cli + '</TD>' else goods.unit-base + '</td>'skip
                                '<TD colspan="7" style="text-align: center;">' + string(v-prt-qnty)+ '</TD>' skip
                                '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-parts-price-no-VAT,"->>>>>>>>>>>9.99",2) + '" colspan="9" style="text-align: right;">' + fnc-convert-dot-to-colon(v-parts-price-no-VAT,"->>>>>>>>>>>9.99",2) + '</TD>' skip
                                '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon((v-parts-price-no-VAT * v-prt-qnty),"->>>>>>>>>>>9.99",2) + '" colspan="11" style="text-align: right;">' + fnc-convert-dot-to-colon((v-parts-price-no-VAT * v-prt-qnty),"->>>>>>>>>>>9.99",2) + '</TD>' skip
                                '<TD colspan="7" style="text-align: center;">без акциза</TD>' skip
                                '<TD colspan="7" style="text-align: center;">' + string (doc-line.VAT-pc,"99") + '</TD>' skip
                                '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon((v-parts-VAT * v-prt-qnty),"->>>>>>>>>>>9.99",2) + '" colspan="9" style="text-align: right;">' + if v-qnty <> 0 then fnc-convert-dot-to-colon((v-parts-VAT * v-prt-qnty),"->>>>>>>>>>>9.99",2) + '</TD>' else "0" + '</td>' skip
                                '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon((v-parts-sum),"->>>>>>>>>>>9.99",2) + '" colspan="13" style="text-align: right;">' + fnc-convert-dot-to-colon((v-parts-sum),"->>>>>>>>>>>9.99",2) + '</TD>' skip
                                '<TD colspan="7" style="text-align: center;">' + v-country-code + '</TD>' skip
                                '<TD colspan="10" style="text-align: center;">' + v-country + '</TD>' skip
                                '<TD colspan="15" style="text-align: center;">' + v-GTD + '</TD>' skip
                                '<TD colspan="7" style="text-align: center;"></TD>' skip
                                '<TD colspan="9" style="text-align: center;"></TD>' skip
                                '<TD colspan="15" style="text-align: center;"></TD>' skip
                                '</TR>'skip.
                end.
                end.
                else do:
                  if lookup ( "corr" , p-mode ) <> 0 then do:
                  end.
                  else do :
                            put stream OutStr-html unformatted
                                '<TR>' skip
                                '<TD colspan="4" style="text-align: center;">' + string(jj) + '</TD>' skip
                                '<TD text_wrap="true" colspan="15" style="text-align: center;">' + if rep-artic then string (ub.goods.artic + " " + ub.goods.gds-name) + '</TD>' else string(ub.goods.gds-name) + '</td>' skip
                                '<TD colspan="6" style="text-align: center;">' + v-uaes-code + '</TD>' skip
                                '<TD colspan="5" style="text-align: center;">' + v-unit-code + '</TD>' skip
                                '<TD colspan="11" style="text-align: center;">' + if invers then doc-line.unit-cli + '</TD>' else goods.unit-base + '</td>'skip
                                '<TD colspan="7" style="text-align: center;">' + string(v-prt-qnty)+ '</TD>' skip
                                '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-price-no-VAT,"->>>>>>>>>>>9.99",2) + '" colspan="9" style="text-align: right;">' + fnc-convert-dot-to-colon(v-price-no-VAT,"->>>>>>>>>>>9.99",2) + '</TD>' skip
                                '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon((v-price-no-VAT * v-prt-qnty),"->>>>>>>>>>>9.99",2) + '" colspan="11" style="text-align: right;">' + fnc-convert-dot-to-colon((v-price-no-VAT * v-prt-qnty),"->>>>>>>>>>>9.99",2) + '</TD>' skip
                                '<TD colspan="7" style="text-align: center;">без акциза</TD>' skip
                                '<TD colspan="7" style="text-align: center;">' + string (doc-line.VAT-pc,"99") + '</TD>' skip
                                '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon((v-Vat / v-qnty * v-prt-qnty),"->>>>>>>>>>>9.99",2) + '" colspan="9" style="text-align: right;">' + if v-qnty <> 0 then fnc-convert-dot-to-colon((v-Vat / v-qnty * v-prt-qnty),"->>>>>>>>>>>9.99",2) + '</TD>' else "0" + '</TD>' skip
                                '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(((v-price-no-VAT + v-VAT / v-qnty) * v-prt-qnty),"->>>>>>>>>>>9.99",2) + '" colspan="13" style="text-align: right;">' + if v-qnty <> 0 then fnc-convert-dot-to-colon(((v-price-no-VAT + v-VAT / v-qnty) * v-prt-qnty),"->>>>>>>>>>>9.99",2) + '</TD>' else "0" + '</TD>' skip
                                '<TD colspan="7" style="text-align: center;">' + v-country-code + '</TD>' skip
                                '<TD colspan="10" style="text-align: center;">' + v-country + '</TD>' skip
                                '<TD colspan="15" style="text-align: center;">' + v-GTD + '</TD>' skip
                                '<TD colspan="7" style="text-align: center;"></TD>' skip
                                '<TD colspan="9" style="text-align: center;"></TD>' skip
                                '<TD colspan="15" style="text-align: center;"></TD>' skip
                                '</TR>'skip.
                end.
                end.
                if FullGdsName and lookup ( "corr" , p-mode ) = 0
                and gds-str1 <> "":U then do :
                   run print-more in this-procedure.
                end.

                { rep/r-factur21.i tax prt-}

                assign v-lines-counter = v-lines-counter + 1.
                /*---E------------- Для каждой партии ---------------------*/
            end.
            /*---E------------- Не услуга ---------------------*/
        end.
        /*---E------------- Пустая шкала или от поставщика ---------------------*/
    end.
    assign
        v-tot-sum-no-VAT    = v-tot-sum-no-VAT  + v-sum-no-VAT  + v-tax
        v-tot-VAT           = v-tot-VAT         + v-VAT
        v-tot-SLT           = v-tot-SLT         + v-SLT
        v-tot-tax           = v-tot-tax         + v-tax
        v-tot-sum           = v-tot-sum         + v-sum         + v-tax
    .
    if lookup ("corr" , p-mode) <> 0 then do :
      if v-diff-sum-no-VAT > 0 then v-tot-sum-no-VAT1   = v-tot-sum-no-VAT1 + v-diff-sum-no-VAT.
      if v-diff-sum-no-VAT < 0 then v-tot-sum-no-VAT2   = v-tot-sum-no-VAT2 + abs(v-diff-sum-no-VAT).
      if v-diff-VAT        > 0 then v-tot-VAT1          = v-tot-VAT1        + v-diff-VAT.
      if v-diff-VAT        < 0 then v-tot-VAT2          = v-tot-VAT2        + abs(v-diff-VAT).
      if v-diff-sum        > 0 then v-tot-sum1          = v-tot-sum1        + v-diff-sum.
      if v-diff-sum        < 0 then v-tot-sum2          = v-tot-sum2        + abs(v-diff-sum).

      put stream Out-stream
          v-single-line format "X(199)"
      .
    end.
end.
end procedure. /* print-line */


/*==========================================================================*/
procedure print-header :
    define input parameter p-doc-code           as character    no-undo.
    define output parameter p-curr-abbr         as character    no-undo.

    define variable v-print-doc      as character no-undo.
    define variable v-par-type       as character no-undo.
    define variable t-num            as character no-undo.
    define variable v-obj-prt-on     as logical   no-undo.
    define variable t-inn            as character no-undo.
    define variable v-plat-rasch-doc as character no-undo.
    define variable v-curr-name      as character no-undo.
    define variable v-base-name      as character no-undo.
    define variable v-base-abbr      as character no-undo.
    define variable v-rubl-name      as character no-undo.
    define variable t-currency       as character no-undo.
    define variable v-suppNUM        as character no-undo.
    define variable v-ordNUM         as character no-undo.
    define variable v-attr-type      as character no-undo.  
    define variable v-idContr        as character no-undo.    
    define variable v-ship-doc       as character no-undo .
    define variable v-status         as character no-undo .
    define variable v-chet-date      as character no-undo .
    define variable v-chet-month     as character no-undo .
    define variable v-chet-yyyy      as character no-undo .
    define buffer buf_trn-doc     for trn-doc.
    define buffer buf_doc-line    for ub.doc-line.
    define buffer buf_currency    for currency.
    define buffer buf_ext-classif for ub.ext-classif.
    do
        for buf_trn-doc
        , buf_currency
        on error undo, return error
        :
        find first buf_trn-doc no-lock
            where buf_trn-doc.doc-code = p-doc-code
            .
    { gbl/getsect.i run {&cmp} buf_trn-doc.host-code {&attr-prt-firm} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'factur01' then v-print-doc =  string(thbjattr_thbj-attr.property-value-logical) .
    end.
        assign
            p-sf-par = no
            .
        run torgconf-get-form-header in this-procedure (
            input Invers
            , input buf_trn-doc.doc-code
            , input ( v-print-doc = "yes" )
            , input buf_trn-doc.doc-date
            , input buf_trn-doc.fact-date
            , input buf_trn-doc.doc-type
            , input buf_trn-doc.status_
            , input p-reverse
            , input p-sf-par
            ).
        { gbl/objat.i
        buf_trn-doc.obj-type
        buf_trn-doc.obj-code
        "'doc-prt=request'"
        v-obj-prt-on
    }
        if v-obj-prt-on = no
            or invers
            then 
        do:
            assign
                PrintScale = no
                .
        end.
        find first buf_currency no-lock
            where buf_currency.curr-code = buf_trn-doc.exch-code
            .
        assign
            p-curr-abbr = buf_currency.curr-abbr
            v-curr-name = buf_currency.curr-name + ", код " + string(buf_currency.okv-code)
            .
        define variable v-base-code as integer no-undo .
        { gbl/basecode.i
      v-host-code
      v-base-code
    }
        for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
            each ub.parts no-lock
             where ub.parts.out-code  = buf_doc-line.doc-code
               and ub.parts.obj-type  = buf_doc-line.obj-type
               and ub.parts.obj-code  = buf_doc-line.obj-code
               and ub.parts.artic     = buf_doc-line.artic
               and ub.parts.prod-type = buf_doc-line.prod-type
               and ub.parts.prod-code = buf_doc-line.prod-code:
            ii = ii + 1 .
        end.  
        v-ship-doc = "1 - " + string (ii) .
        find first buf_currency no-lock
            where buf_currency.curr-code = v-base-code
            .
        assign
            v-base-name = buf_currency.curr-name  + ", код " + string(buf_currency.okv-code)
            v-base-abbr = buf_currency.curr-abbr
            .
        find first buf_currency no-lock
            where buf_currency.curr-code = 0
            .
        assign
            v-rubl-name = buf_currency.curr-name  + ", код " + string(buf_currency.okv-code)
            .
        assign
            t-num = substitute( "&1         от &2 &3"
                        , v-torgconf-doc-code
                        , v-torgconf-doc-date
                        , ( if buf_trn-doc.status_ <> {&fact}
                            then string( "(" + caps( buf_trn-doc.status_ ) + ")" )
                            else "":U )
                )
            .  
        run get-DD(input v-torgconf-doc-date, output v-chet-date) .
        run get-Month(input v-torgconf-doc-date, output v-chet-month) .
        run get-YYYY(input v-torgconf-doc-date, output v-chet-yyyy) .
                                
        assign
            t-inn = substitute( "&1&2&3", v-torgconf-supplier-inn, ( if ((v-torgconf-supplier-kpp = "":U) AND (v-torgconf-supplier-inn = "":U)) then "":U else "/":U ), v-torgconf-supplier-kpp )
            .
        /* заполняется внутри torgconf-read()
           по имени формы "factur",
           которое должно присутствать в значении параметра "outappr",
           взятого из gbl/conf-rd.p -> confrddb() ->  config where param-code = p-code and config.db-num = p-db-num
        */
        if v-torgconf-outappr = yes
            then 
        do:
        /*         put stream OutStr-html unformatted                                                                                                              */
        /*            '<tr>' skip                                                                                                                                  */
        /*            '<td colspan="117" style="text-align: center;"></td>' skip                                                                                   */
        /*            '<td colspan="50" style="text-align: right;">Приложение №1</td>' skip                                                                        */
        /*            '</tr>'                                                                                                                                      */
        /*            '<tr>' skip                                                                                                                                  */
        /*            '<td colspan="117" style="text-align: center;"></td>' skip                                                                                   */
        /*            '<td colspan="50" style="text-align: right;">к постановлению Правительства</td>' skip                                                        */
        /*            '</tr>'                                                                                                                                      */
        /*            '<tr>' skip                                                                                                                                  */
        /*            '<td colspan="117" style="text-align: center;"></td>' skip                                                                                   */
        /*            '<td colspan="50" style="text-align: right;">Российской Федерации</td>' skip                                                                 */
        /*            '</tr>'                                                                                                                                      */
        /*            '<tr>' skip                                                                                                                                  */
        /*            '<td colspan="117" style="text-align: center;"></td>' skip                                                                                   */
        /*            '<td colspan="50" style="text-align: right;">от 26 декабря 2011 г. № 1137</td>' skip                                                         */
        /*            '</tr>'                                                                                                                                      */
        /*            '<tr>' skip                                                                                                                                  */
        /*            '<td colspan="117" style="text-align: center;"></td>' skip                                                                                   */
        /*            '<td colspan="50" style="text-align: right;"></td>' skip                                                                                     */
        /*            '</tr>'                                                                                                                                      */
        /*            '<tr>' skip                                                                                                                                  */
        /*            '<td colspan="117" style="text-align: center;"></td>' skip                                                                                   */
        /*            '<td colspan="50" style="text-align: right;">(в ред. Постановления Правительства РФ от 02.04.2021 № 534)</td>' skip                          */
        /*            '</tr>'                                                                                                                                      */
        /*            '<tr>' skip                                                                                                                                  */
        /*            '<td colspan="117" style="text-align: center;"></td>' skip                                                                                   */
        /*            '<td colspan="50" style="text-align: right;"></td>' skip                                                                                     */
        /*            '</tr>'                                                                                                                                      */
        /*            '<tr>' skip                                                                                                                                  */
        /*            '<td colspan="117" style="text-align: center;"></td>' skip                                                                                   */
        /*            '<td colspan="50" style="text-align: right;"></td>' skip                                                                                     */
        /*            '</tr>'                                                                                                                                      */
        /*            '<tr>' skip                                                                                                                                  */
        /*            '<td colspan="167" style="text-align: center;">I. Форма счета-фактуры, применяемого прирасчетах по налогу на добавленную стоимость</td>' skip*/
        /*            '</tr>'                                                                                                                                      */
        /*            '<tr>' skip                                                                                                                                  */
        /*            '<td colspan="167" style="text-align: center;"></td>' skip                                                                                   */
        /*            '</tr>'                                                                                                                                      */
        /*            .                                                                                                                                            */
        END.
        v-status = if buf_trn-doc.status_ <> {&fact}
            then string( "(" + caps( buf_trn-doc.status_ ) + ")" )
            else "":U .

        put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="35" style="text-align:right;">СЧЕТ-ФАКТУРА N</td>' skip
            '<td colspan="5" style="text-align: right;"></td>' skip
            '<td colspan="11" style="border-bottom: 1px solid black; text-align: center;">' + v-torgconf-doc-code + '</td>' skip
            '<td colspan="4" style="text-align: right;">от "</td>' skip
            '<td colspan="11" style="border-bottom: 1px solid black; text-align: center;">' + v-chet-date + '</td>' skip
            '<td colspan="3" style="text-align: left;">"</td>' skip
            '<td colspan="51" style="border-bottom: 1px solid black; text-align: center;">' + v-chet-month + " " + v-chet-yyyy + "г." + '</td>' skip
            '<td></td>' skip
            '<td colspan="46">(1)</td>' skip
            '</tr>'
            '<tr>' skip
            '<td colspan="35" style="text-align: right;">ИСПРАВЛЕНИЕ №</td>' skip
            '<td colspan="5" style="text-align: right;"></td>' skip
            '<td colspan="11" style="border-bottom: 1px solid black;"></td>' skip
            '<td colspan="4" style="text-align: right;">от "</td>' skip
            '<td colspan="11" style="border-bottom: 1px solid black;"></td>' skip
            '<td colspan="3" style="text-align: left;">"</td>' skip
            '<td colspan="51" style="border-bottom: 1px solid black;"></td>' skip
            '<td></td>' skip
            '<td colspan="46">(1а)</td>' skip
            '</tr>'
            /*            '<tr height="1">' skip                                            */
            /*            '<td colspan="35"></td>' skip                                     */
            /*            '<td colspan="5"></td>' skip                                      */
            /*            '<td colspan="11" style="border-top: 1px solid black;"></td>' skip*/
            /*            '<td colspan="4"></td>' skip                                      */
            /*            '<td colspan="5" style="border-top: 1px solid black;"></td>' skip */
            /*            '<td colspan="3"></td>' skip                                      */
            /*            '<td colspan="27" style="border-top: 1px solid black;"></td>' skip*/
            /*            '<td></td>' skip                                                  */
            /*            '<td colspan="30">(1а)</td>' skip                                 */
            /*            '<td colspan="46"></td>' skip                                     */
            /*            '</tr>'                                                           */
            '<tr>' skip
            '<td colspan="9" style="text-align: left;">Продавец</td>' skip
            '<td></td>' skip
            '<td colspan="110" style="border-bottom: 1px solid black;">' + v-torgconf-supplier-name + IF v-torgconf-supplier-engl-name = "":U THEN "":U ELSE SUBSTITUTE(" (&1)", v-torgconf-supplier-engl-name ) + '</td>' skip
            '<td></td>' skip
            '<td colspan="46">(2)</td>' skip
            '</tr>'
            '<tr>' skip
            '<td colspan="6" style="text-align: left;">Адрес</td>' skip
            '<td></td>' skip
            '<td colspan="113" style="border-bottom: 1px solid black;">' + v-torgconf-supplier-addr + '</td>' skip
            '<td></td>' skip
            '<td colspan="46">(2а)</td>' skip
            '</tr>'
            '<tr>' skip
            '<td colspan="18" style="text-align: left;">{&abbr_inn_allshift}/{&abbr_kpp_allshift} продавца</td>' skip
            '<td></td>' skip
            '<td colspan="101" style="border-bottom: 1px solid black;">' + t-inn + '</td>' skip
            '<td></td>' skip
            '<td colspan="46">(2б)</td>' skip
            '</tr>'        

            .      

        /* вывод на экран грузоотправителя*/
        /* message     v-torgconf-cargo-from-name skip v-torgconf-organization skip v-torgconf-cargo-from-sf-value view-as alert-box.*/
        if LOOKUP( "serv", p-mode ) <> 0 then v-out-name = '---------------------'  .
        else if
                buf_trn-doc.doc-type <> {&income}
                and ( not invers )
                and buf_trn-doc.office = no
                and v-torgconf-outobj = no
                and v-torgconf-outasend = no
                and v-torgconf-outsend = no
                and v-torgconf-outares = no
                and LOOKUP( "TopAukc", p-mode ) = 0
                then v-out-name = "Он же".
            else v-out-name =  v-torgconf-cargo-from-sf-value.
        put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="34" style="text-align: left;">Грузоотправитель и его адрес</td>' skip
            '<td></td>' skip
            '<td colspan="85" style="border-bottom: 1px solid black;">' + v-out-name + '</td>' skip
            '<td></td>' skip
            '<td colspan="46">(3)</td>' skip
            '</tr>'
            .
                { str/tdat-val.i p-doc-code {&trdcattr-idCountryContr} v-idContr v-attr-type no-error }
    
        assign
            t-inn = substitute( "&1&2&3",
                             v-torgconf-saler-inn,
                             ( if v-torgconf-saler-kpp = "":U then "":U else "/":U ),
                             v-torgconf-saler-kpp )
            .
        if lookup( "GreenL", p-mode ) <> 0
            then 
        do:
            assign
                v-plat-rasch-doc = "":U
                .
        end.
        else 
        do:
            assign
                v-plat-rasch-doc = " N ":U + ( if p-round = 'round':U then ": ":U else " ":U ) + fill( " ", 6 ) + v-torgconf-plat-rasch-doc
                .
        end.
        /* Вывод на экран грузополучателя */
        /* Здесь какая-то кривизна, видимо v-torgconf-consignee был создан когда появился атрибут грузополучатель для документов, но не работает для приходов.  */
        if LOOKUP( "serv", p-mode ) <> 0 then v-out-name = '---------------------'  .
        else if     buf_trn-doc.doc-type <> {&income}
                and buf_trn-doc.doc-type <> {&return}
                then v-out-name =  v-torgconf-consignee.
            else v-out-name =  v-torgconf-cargo-to-value .

        put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="34" style="text-align: left;">Грузополучатель и его адрес</td>' skip
            '<td></td>' skip
            '<td colspan="85" style="border-bottom: 1px solid black;">' + v-out-name + '</td>' skip
            '<td></td>' skip
            '<td colspan="46">(4)</td>' skip
            '</tr>'
            '<tr>' skip
            '<td colspan="31" style="text-align: left;">К платежно-расчетному документу</td>' skip
            '<td></td>' skip
            '<td colspan="88" style="border-bottom: 1px solid black;">' + string(v-plat-rasch-doc) + '</td>' skip
            '<td></td>' skip
            '<td colspan="46">(5)</td>' skip
            '</tr>'  
            '<tr>' skip
            '<td colspan="24" style="text-align: left;">Документ об отгрузке № п/п</td>' skip
            '<td></td>' skip
            '<td colspan="16" style="border-bottom: 1px solid black; text-align: center;">' + v-ship-doc + '</td>' skip
            '<td colspan="4" style="text-align: center;">№</td>' skip
            '<td colspan="16" style="border-bottom: 1px solid black; text-align: center;">' + buf_trn-doc.doc-code + '</td>' skip
            '<td colspan="4" style="text-align: center;">от</td>' skip    
            '<td colspan="55" style="border-bottom: 1px solid black; text-align: center;">' + string(buf_trn-doc.doc-date) + '</td>' skip
            '<td></td>' skip
            '<td colspan="46">(5а)</td>' skip
            '</tr>'        
            '<tr>' skip
            '<td colspan="24" style="text-align: left;">Покупатель</td>' skip
            '<td></td>' skip
            '<td colspan="95" style="border-bottom: 1px solid black;">' + string(v-torgconf-saler-name) + " (" + string(v-torgconf-saler-code) + ")" '</td>' skip
            '<td></td>' skip
            '<td colspan="46">(6)</td>' skip
            '</tr>'
            '<tr>' skip
            '<td colspan="6" style="text-align: left;">Адрес</td>' skip
            '<td></td>' skip
            '<td colspan="113" style="border-bottom: 1px solid black;">' + v-torgconf-saler-addr + '</td>' skip
            '<td></td>' skip
            '<td colspan="46">(6а)</td>' skip
            '</tr>'
            '<tr>' skip
            '<td colspan="24" style="text-align: left;">{&abbr_inn_allshift}/{&abbr_kpp_allshift} покупателя</td>' skip
            '<td></td>' skip
            '<td colspan="95" style="border-bottom: 1px solid black;">' + t-inn + '</td>' skip
            '<td></td>' skip
            '<td colspan="46">(6б)</td>' skip
            '</tr>'
            .

        assign
            t-currency = ( trim( ( if invers and buf_trn-doc.doc-type <> {&income} then v-curr-name else ( if PrintRubl then v-rubl-name else v-base-name  ) ) ) )
            .

        put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="35" style="text-align: left;">Валюта: наименование, код</td>' skip
            '<td></td>' skip
            '<td colspan="84" style="border-bottom: 1px solid black;">' + string(trim( ( if invers and buf_trn-doc.doc-type <> {&income} then v-curr-name else ( if PrintRubl then v-rubl-name else v-base-name  ) ) ) ) + '</td>' skip
            '<td></td>' skip
            '<td colspan="46">(7)</td>' skip
            '</tr>'
            '<tr>' skip
            '<td colspan="74" style="text-align: left;">Идентификатор государственного контракта, договора (соглашения) (при наличии)</td>' skip
            '<td></td>' skip
            '<td colspan="45" style="border-bottom: 1px solid black;">' + trim(v-idContr) + '</td>' skip
            '<td></td>' skip
            '<td colspan="46">(8)</td>' skip
            '</tr>'
            '<tr>' skip
            '<td colspan="117" style="text-align: center;"></td>' skip
            '<td colspan="50" style="text-align: right;"></td>' skip
            '</tr>'  
            '</thead>'
            '<tbody>'.
    end.
end procedure. /* print-header */


/*==========================================================================*/
procedure print-footer :

    define variable v-base-code as integer   no-undo .
    define variable v-base-abbr as character no-undo .

    define buffer buf_currency for ub.currency.

    do
        on error undo, return error
        :
  
        put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="57" style="text-align:left;">Всего к оплате (9)</td>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-tot-sum-no-VAT,"->>>>>>>>>>>9.99",2) + '" colspan="11" style="text-align: right; border: 1px solid black;">' + fnc-convert-dot-to-colon(v-tot-sum-no-VAT,"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<td colspan="14" style="text-align:center; border: 1px solid black;">Х</td>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-tot-VAT,"->>>>>>>>>>>9.99",2) + '" colspan="9" style="text-align: right; border: 1px solid black;">' + fnc-convert-dot-to-colon(v-tot-VAT,"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-tot-sum,"->>>>>>>>>>>9.99",2) + '" colspan="13" style="text-align: right; border: 1px solid black;">' + fnc-convert-dot-to-colon(v-tot-sum,"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<td colspan="63"></td>' skip
            '</tr>'
            .
        put stream OutStr-html unformatted
            '<tfoot>' skip
            '<tr>' skip
            '<td colspan="87" style="text-align:left;">Руководитель организации</td>' skip
            '<td colspan="80" style="text-align:left;">Главный бухгалтер</td>' skip
            '</tr>'
            .     

        put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="38" style="text-align:left;">или иное уполномоченное лицо</td>' skip
            '<TD colspan="16" style="text-align: center;"></TD>'
            '<TD colspan="2"></TD>' skip
            '<TD colspan="29" style="text-align: center;">' + v-torgconf-main-boss + '</TD>'
            '<TD colspan="2"></TD>'
            '<td colspan="33" style="text-align:left;">или иное уполномоченное лицо</td>' skip
            '<TD colspan="16" style="text-align: center;"></TD>'
            '<TD colspan="2"></TD>' skip
            '<TD colspan="29" style="text-align: center;">' + v-torgconf-main-buh + '</TD>'
            '</TR>'skip
            '<tr>' skip
            '<td colspan="38" style="text-align:left;"></td>' skip
            '<TD colspan="16" style="text-align: center; border-top: 1px solid black;">(подпись)</TD>'
            '<TD colspan="2"></TD>' skip
            '<TD colspan="29" style="text-align: center; border-top: 1px solid black;">(ф.и.о.)</TD>'
            '<TD colspan="2"></TD>'
            '<td colspan="33" style="text-align:left;"></td>' skip
            '<TD colspan="16" style="text-align: center; border-top: 1px solid black;">(подпись)</TD>'
            '<TD colspan="2"></TD>' skip
            '<TD colspan="29" style="text-align: center; border-top: 1px solid black;">(ф.и.о.)</TD>'
            '</TR>'skip                    
            .
 
        if v-torgconf-outegrp = no
            then 
        do :
            if trim(v-torgconf-self-host-name) = "":U
                then 
            do:
                v-torgconf-self-host-name = fill("_", 42).
            end.


            put stream OutStr-html unformatted
                '<tr>' skip
                '<td colspan="87" style="text-align:left;">Индивидуальный предприниматель</td>' skip
                '<td colspan="80" style="text-align:center;"></td>' skip
                '</tr>'
                .     
            if v-torgconf-self-host-egrip-date <> "":U
                or v-torgconf-self-host-egrip-num  <> "":U
                then 
            do:
                put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td colspan="38" style="text-align:left;">или иное уполномоченное лицо</td>' skip
                    '<TD colspan="16" style="text-align: center;"></TD>'
                    '<TD colspan="2"></TD>' skip
                    '<TD colspan="29" style="text-align: center;">' +  string(v-torgconf-self-host-name) + '</TD>'
                    '<TD colspan="2"></TD>'
                    '<td colspan="80" style="text-align:left;">' + substitute( "ЕГРИП N &1 от &2 ", v-torgconf-self-host-egrip-num, v-torgconf-self-host-egrip-date ) + '</td>' skip
                    '</TR>'skip
                    .
            end.
            else 
            do :
                put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td colspan="38" style="text-align:left;">или иное уполномоченное лицо</td>' skip
                    '<TD colspan="16" style="text-align: center;"></TD>'
                    '<TD colspan="2"></TD>' skip
                    '<TD colspan="29" style="text-align: center;"></TD>'
                    '<TD colspan="2"></TD>'
                    '<td colspan="80" style="text-align:left;"></td>' skip
                    '</TR>'skip         
                    .
            end.
            put stream OutStr-html unformatted
                '<tr>' skip
                '<td colspan="38" style="text-align:left;"></td>' skip
                '<TD colspan="16" style="text-align: center; border-top: 1px solid black;">(подпись)</TD>'
                '<TD colspan="2"></TD>' skip
                '<TD colspan="29" style="text-align: center; border-top: 1px solid black;">(ф.и.о.)</TD>'
                '<TD colspan="2"></TD>'
                '<TD colspan="80" style="text-align: center; border-top: 1px solid black;">(реквизиты свидетельства о государственной регистрации индивидуального предпринимателя)</TD>'
                '</TR>'skip                    
                .
        end.
    end.
end procedure. /* print-footer */

procedure get-DD:
    
    /* Получение даты в формате "01 Января 2014г." */
    define input parameter p-dat-date as date no-undo.
    define output parameter p-str-day as character no-undo.

    define variable v-str-date  as character no-undo.
    define variable v-str-day   as character no-undo.
    define variable v-num-month as character no-undo.
    define variable v-str-month as character no-undo.
    define variable v-str-year  as character no-undo.

    v-str-date = string(p-dat-date).

    do: /* Получаем день в формате цифры, вида NN. */
        p-str-day = string(entry(1, v-str-date, "/")).
    end. /* Получаем день в формате цифры, вида NN. */

end procedure.

procedure get-Month:
    
    /* Получение даты в формате "01 Января 2014г." */
    define input parameter p-dat-date as date no-undo.
    define output parameter p-str-month as character no-undo.

    define variable v-str-date  as character no-undo.
    define variable v-str-day   as character no-undo.
    define variable v-num-month as character no-undo.
    define variable v-str-month as character no-undo.
    define variable v-str-year  as character no-undo.

    v-str-date = string(p-dat-date).

    do: /* Получаем прописью месяц */
        v-num-month = entry(2, v-str-date, "/").
        p-str-month = MonthNameRusCase(integer(v-num-month), 2).

    end. /* Получаем прописью месяц */

end procedure.

procedure get-YYYY:
    
    /* Получение даты в формате "01 Января 2014г." */
    define input parameter p-dat-date as date no-undo.
    define output parameter p-str-year as character no-undo.

    define variable v-str-date  as character no-undo.
    define variable v-str-day   as character no-undo.
    define variable v-num-month as character no-undo.
    define variable v-str-month as character no-undo.
    define variable v-str-year  as character no-undo.

    v-str-date = string(p-dat-date).

    do: /* Получаем год в формате цифры, вида "NNNN" */
        /*        v-str-year = entry(3, v-str-date, "/").*/
        p-str-year = string(year(p-dat-date)).
    end. /* Получаем год в формате цифры, вида "NNNN" */

end procedure.

PROCEDURE get-report-num :
    define output parameter p-report-num as integer no-undo .

    do
        on error undo, return error
        :
        if v-cntxa-report-num = 0 then 
        do:
            run gbl/getrpnum.p (output p-report-num).
            v-cntxa-report-num = p-report-num.
        end.
        else 
        do:
            assign
                p-report-num = v-cntxa-report-num
                .
        end.
    end.

END PROCEDURE.