block-level on error undo, throw.
/*

$Revision: 3e87f6d879b9, 3293, rls $
$Author: VSpiridonov $
$Date: 2023/03/29 08:48:06 $
$Workfile: r-km4.p $
$Archive: rep/r-km4.p $

Журнал кассира операциониста КМ-4

Автор: Комаров Иван Сергеевич
Дата создания: 06/01/10
Author: Ivan Komarov
Creation date: 06/01/10

Автор1: Белоусов Илья Александрович
Дата создания1: 18.08.08

*/

define temp-table tt-cash-desk no-undo like ub.cash-desk.

define input parameter parparentproc            as widget-handle           no-undo .
define input parameter p-parent-handle          as handle                  no-undo .
define input parameter p-log-handle             as handle                  no-undo .
define input parameter p-cont-handle            as handle                  no-undo .
define input parameter p-call-handle            as handle                  no-undo .
define input parameter p-rebh                   as handle                  no-undo . /*для ошибок*/
define input parameter p-rdbh                   as handle                  no-undo . /*destination*/
define input parameter p-report-id              as character               no-undo .
define input parameter p-log-file-name          as character               no-undo .
define input parameter p-batch                  as integer                 no-undo .
define input parameter p-codex-id               as integer                 no-undo .
define input parameter p-ruleset-id             as integer                 no-undo .

define input parameter p-plain-txt              as logical                 no-undo .
define input parameter p-xls                    as logical                 no-undo .
define input parameter p-dir-name               as character               no-undo .

define input parameter table for tt-cash-desk .




define variable vss-revision    as character no-undo initial "$Revision: 3e87f6d879b9, 3293, rls $":U .
define variable vss-author      as character no-undo initial "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo initial "$Date: 2023/03/29 08:48:06 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-km4.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-km4.p $":U .
define variable vss-description as character no-undo initial "Журнал кассира операциониста КМ-4".

define variable g#report-num              as integer              no-undo .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ gbl/paramls.i  }
{ gbl/getcntxt.i def } 
{ gbl/cur-time.i     }
{ cmp/breakstr.i     }
{ rep/r-cliprp.i def }
{ str/lib-trn.i      }
{ str/valddnst.i def }
{ gbl/cd-attr.i      }
{ cmp/abbr-nc.i      }
/* { gbl/getsect.i  def } */
{ rep/fmtcli.i       }
{ rep/torgconf.i     }
{ trg/factord.i  }

{ rep/reprumpr.i print-plain-text,print-printer,print-xlt }
{ rep/r-sym.i        }

{ rep/fostatok.i  &arh-name = "arh-fin-doc-schet-nal-obj" }
{ str/farh-def.i }
{ gbl/std-func.i }

{ gbl/getcntxt.i get }


define temp-table temp-str no-undo
   field cash-num        as integer
   field z-number        as integer
   field chk-num         as integer
   field zero-counter    as integer
   field summ-begin      as character
   field summ-end        as character
   field summ-sale       as decimal
   field summ-nal        as decimal
   field summ-return     as decimal
   field person          as character
   field chk-date        as date
   field chk-time        as integer
   field chk-time-1      as integer
   field chk-time-2      as integer
   field shift-date      as date
   field shift-num       as integer
   field chk-shift-open-time as logical /* используется в km6.i для условия заполнения chk-time-1 */
   field summ-return-prod  as decimal
      INDEX pi  IS PRIMARY
        chk-date
        chk-time
        .

  define stream  macr_excel .

define stream OutStr-html.

define variable v-cntxt-host-name-obj as character no-undo .
define        variable v-report-name            as character no-undo.         /* Наименование отчёта */
define        variable v-period                 as character no-undo.              /* Период за который формируется отчёт */
define        variable v-short-obj-list         as character no-undo.      /* Перечень выбранных объектов "в одну строку" */
define        variable v-choice-gds             as character no-undo. /* Список выбранных товаров. Вывод - в шапке отчёта */
define        variable v-choice-obj             as character no-undo. /* Выбранный пользователем параметр "Выбор объекта" (в окне параметров). Вывод в шапке отчёта */
define        variable v-full-path-RepView      as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define        variable v-file-name-rep-htm      as character no-undo.   /* Полный путь к файлу отчёта */
define        variable v-par-type               as character no-undo. 
define variable v-file-name     as character no-undo .
      
        define stream Out-Stream.

define buffer buf_clients      for ub.clients .
define buffer This_Object      for ub.clients .
define buffer buf_sale-clients for ub.clients .
define buffer buf_chk-pay      for ub.chk-pay.
define buffer buf_cash-desk    for ub.cash-desk.
define buffer buf_firm         for ub.firm.
define buffer buf_tt-cash-desk for tt-cash-desk.
define buffer buf_obj-list     for obj-list.
define buffer buf_z_chk-doc-pred for ub.chk-doc.
define buffer buf_z_chk-doc    for ub.chk-doc.
define buffer buf_chk-doc      for ub.chk-doc.
define buffer buf_fin-doc      for ub.fin-doc.
define buffer buf_arh-fin-doc-schet-nal-obj for ub.arh-fin-doc-schet-nal-obj .
define buffer buf_sysconf      for ub.sysconf.
define buffer buf_shift-cash   for ub.shift-cash.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf_chk-pay-attr for ub.chk-pay-attr.

define variable v-shift-name    as character    no-undo.
define variable  number-cash as integer no-undo.
define variable sum1-shift      as decimal initial 0     no-undo .
define variable sum2-shift      as decimal initial 0     no-undo .
define variable v-summ-total    as decimal initial 0     no-undo .
define variable v-summ-return   as decimal initial 0     no-undo .
define variable v-sum-begin     as decimal initial 0     no-undo .
define variable v-sum-end       as decimal initial 0     no-undo .
define variable Fact-order-1    like ub.stk-tot.Fact-order no-undo.
define variable Fact-order-2    like ub.stk-tot.Fact-order no-undo.
define variable v-pko-num       as character             no-undo .
define variable v-pko-date      as date                  no-undo .

define variable PgNPP           as integer               no-undo .
define variable v-b-code        as integer               no-undo .
define variable v-kop           as integer               no-undo .
define variable Lines_Counter   as integer initial 0     no-undo .

define variable Line            as character             no-undo .
define variable UndLine         as character             no-undo .
define variable empty-str09-2   as character             no-undo .
define variable empty-str09-3   as character             no-undo .
define variable empty-str09-10  as character             no-undo .
define variable v-person        as character             no-undo .


define variable v-organization  as character    no-undo.
define variable v-object        as character    no-undo.
define variable v-object-addr   as character    no-undo.

define variable close-date as char no-undo.
define variable v-search as character.
define variable v-boss          as character             no-undo .
define variable v-post          as character             no-undo .
define variable v-cashier       as character             no-undo .
define variable PropisSumAll    as character             no-undo .
define variable PropisSumAll-2  as character             no-undo .
define variable v-kkm-code-reg  as character             no-undo .
define variable v-kkm-code-prod as character             no-undo .
define variable v-kkm-model     as character             no-undo .
define variable v-kkm-type      as character             no-undo .
define variable v-kkm-programm  as character             no-undo .
define variable v-outprncd      as character             no-undo .
define variable v-kkm-num       as character             no-undo .

define variable v-par-code      as character             no-undo .

define variable v-base-code     as integer               no-undo .
define variable v-curr-r-b      as character             no-undo .
define variable v-PrintTitul    as integer               no-undo .
define variable sheet-list      as character             no-undo .
define variable sheet-list-copy-from   as character      no-undo .
define variable v-start         as logical   initial yes no-undo .
define variable v-obj-code      as integer               no-undo .
define variable v-is-cash-list as character no-undo. /* Список кодов оплаты наличными */
define variable v-itogo-sum-sale as decimal no-undo.
define variable v-itogo-sum as decimal no-undo.
define variable v-itogo-nal as decimal no-undo.
define variable v-i as integer no-undo.
define variable v-ii as integer no-undo.
define variable v-txt-1 as character no-undo.
define variable v-txt-2 as character no-undo.
define variable  v-obj-type as character no-undo.




function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date) forward.

function fnc-convert-dot-to-colon returns character 
(input p-data as decimal, input p-accur as character) forward.

/* Получим список кодов наличной оплаты */
for each buf_cash-pay where buf_cash-pay.is-cash:
    v-is-cash-list = v-is-cash-list + string(buf_cash-pay.cdpay-code) + ','.
end.


for each buf_obj-list
  no-lock :
   assign
      v-obj-code = buf_obj-list.obj-code
      v-obj-type =  buf_obj-list.obj-type  
   .
  for each tt-cash-desk  no-lock
     where tt-cash-desk.obj-code = buf_obj-list.obj-code
  break
  by tt-cash-desk.db-num
  by tt-cash-desk.obj-code
  by tt-cash-desk.pos-type
  by tt-cash-desk.cash-num
    :
      /* по строкам документа */
/*      { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */*/

      /* сначала заполняем таблицу */
      { rep/km4.i }
    if not can-find(first temp-str where temp-str.cash-num = tt-cash-desk.cash-num) then next.
   
  end.
end.
find first temp-str no-error.
if not available temp-str then do:
  &scop my-message "Не было чеков за выбранный период!!"
  if p-batch > 0 then do:
    {&display-message}.
    run cb_write-report-error in p-parent-handle ( input p-rebh
                                                  ,input p-report-id
                                                  ,input ?
                                                  ,input {&severity-high}
                                                  ,input {&my-message}).
    RETURN.
  end.
  else do:
    {&display-message}.
    return.
  end.
end.
   FIND FIRST buf_cash-desk WHERE buf_cash-desk.cash-num = tt-cash-desk.cash-num
                              AND buf_cash-desk.db-num   = tt-cash-desk.db-num
                              AND buf_cash-desk.obj-code = tt-cash-desk.obj-code
                              AND buf_cash-desk.pos-type = tt-cash-desk.pos-type
                            NO-LOCK
                            NO-ERROR
                            .
   FIND first This_Object  WHERE This_Object.obj-type = {&shop}
                       AND This_Object.obj-code = tt-cash-desk.obj-code
                     NO-LOCK.
   FIND first ub.clients  WHERE ub.clients.obj-type   = {&cmp}
                       AND ub.clients.obj-code     = This_Object.host-code
                     NO-LOCK.

   find first buf_firm where buf_firm.firm-code = ub.clients.obj-code
                       no-lock
                       .
  FIND FIRST buf_cash-desk WHERE buf_cash-desk.cash-num = tt-cash-desk.cash-num
                    AND buf_cash-desk.obj-code = This_Object.obj-code
                    AND Buf_cash-desk.db-num   = This_Object.db-num
                  NO-LOCK
                  NO-ERROR
                  .
    /*      в версии 15.0 модель кассы задается в атрибутах, в 16.0 - в параметрах   */

    /*  run cd-attr-value in this-procedure (
        input  tt-cash-desk.db-num
        ,input  tt-cash-desk.obj-code
        ,input  tt-cash-desk.pos-type
        ,input  tt-cash-desk.cash-num
        ,input  tt-cash-desk.fr-type
        ,output v-kkm-model                              
        , output v-kkm-type
        ) . */

    v-kkm-model = tt-cash-desk.pos-type.

    assign
        v-boss          = buf_firm.director              	
        v-kkm-code-reg  = buf_cash-desk.registration-code
        v-kkm-code-prod = buf_cash-desk.serial-code.
       
   
     run torgconf-read in this-procedure (
      input "outprncd"
    , input This_Object.host-code
    , input This_Object.obj-type
    , input This_Object.obj-code
    ) no-error.

   { rep/r-cliprp.i }

  Case This_Object.obj-type :
    when {&shop} then do:
      find first ub.shop
      where ub.shop.obj-code = This_Object.obj-code
        no-error.
        if available ub.shop then do:
          assign v-object-addr = ub.shop.addres1.
        end.
    end.
    when {&stock} then do:
      find first ub.store
      where ub.store.obj-code = This_Object.obj-code
        no-error.
        if available ub.store then do:
          assign v-object-addr = ub.store.addres1.
        end.
    end.
  end case.
  
    if x-tog-shift then 
    do:
        assign 
            v-shift-name = substitute("№&1 от &2", string(x-shift-alone), string(x-date-start)) .
    end.

    if v-torgconf-outprncd = yes then
    do:
        assign
            v-organization = string( CAPS( ub.clients.obj-name )  + " (" + string(ub.clients.obj-code) + ") " ) + t-addres + " " + t-phone
            v-object       = string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ") " ) + v-object-addr
            .
    end.
    else 
    do:
        assign
            v-organization = string( CAPS( ub.clients.obj-name ) ) + " " + t-addres + " " + t-phone
            v-object       = string( CAPS( This_Object.obj-name ) ) + " " + v-object-addr
            .
    end.

    find last  shift-obj where shift-obj.obj-code = v-obj-code and   shift-obj.obj-type = v-obj-type  and shift-obj.shift-date = x-Date-Start and shift-obj.shift-num   >= x-Shift-Start no-lock no-error .
  

  if available shift-obj then do:
        if shift-obj.close-date = ?  then shift-obj.close-date = today.
      close-date = fnc-DD-MM-YYYY(date(string(shift-obj.close-date,"99/99/9999"))).
      end. 
      else do:
          close-date = fnc-DD-MM-YYYY(date(string(today,"99/99/9999"))).
          end.

    /* Excel */
    v-ii = num-entries(v-organization, " ") + 1.
    if v-ii = 1 then /* Если в v-organization содержится одно огромное слово > 87 символов, то ничего не переносим на другую строку. */
    do:
        v-txt-1 = v-organization.
    end.
    else
    do:
        if length(v-organization) > 78 then
        do:
            do v-i = 1 to v-ii + 1:
                v-txt-1 = v-txt-1 + (if v-txt-1 = "" then "" else " ") + entry(v-i, v-organization, " ").
                if length(v-txt-1) + 1 + length(entry((v-i + 1), v-organization, " ")) > 78 then /* поместится-ли с текущими блоками - следующий (+1)? Если нет, то оставляем текущие в v-txt-1 */
                do:
                    leave.
                end.
            end.
            v-txt-2 = substring(v-organization, length(v-txt-1) + 2).
        end.
        else
        do:
            v-txt-1 = v-organization.
        end.
    end.


run get-full-path-RepViewer(output v-full-path-RepView).   
  
run get-report-num in parParentProc(output g#report-num).


v-report-name = "KM-4".

    for each temp-str : 
        assign
         v-kkm-programm  = (if tt-cash-desk.pos-type = {&cd-type-ibm-xml}
                      or tt-cash-desk.pos-type = {&cd-type-ibm}
                      then  (if tt-cash-desk.cash-os = "LINUX"
                              then "UniFO-L V 4.0.K"
                              else "UniFO-IBS V 4.0.K" )
                      else '')
        
            v-kkm-num   = "(" + trim(string(temp-str.cash-num)) + ")"
        
            number-cash = temp-str.cash-num.
    
        run define-full-path-Report(input g#report-num, input number-cash, output v-file-name-rep-htm).
        run create-file(v-file-name-rep-htm). 
        run html-rep.
    
  
        run search-full-path-Report(input v-file-name-rep-htm).
        v-search = v-search + " "  + search(v-file-name-rep-htm).


    end.
    run Report-Viewer(input v-full-path-RepView, input v-search).



procedure html-rep:
    output stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8'.
            put stream OutStr-html unformatted
             "<!DOCTYPE HTML>" skip
                ' <html>' skip
                '  <head>' skip
                '   <meta charset="utf-8">' skip
          '    <style type="text/css">' skip
              
                '      table ' + chr(123) + ' border-collapse: collapse; font-size:9pt; font-family:Times New Roman; table-layout: fixed; width: 540px; hight:  padding: 8px;  ' + chr(125) skip
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
    '<TD  style="width: 130px; text-align: left;border: none"></TD>'skip
    '<TD style="width: 50px; text-align: left;border: none"></TD>'skip
    '<TD style="width: 54px; text-align: left;border: none"></TD>'skip
    '<TD style="width: 89px; text-align: left;border: none"></TD>'skip
    '<TD style="width: 72px; text-align: left;border: none"></TD>'skip
    '<TD style="width: 44px; text-align: left;border: none"></TD>'skip
    '<TD style="width: 20px; text-align: left;border: none"></TD>'skip
    '<TD style="width: 28px; text-align: left;border: none"></TD>'skip
    '<TD style="width: 20px; text-align: left;border: none"></TD>'skip
    '<TD style="width: 100px; text-align: left;border: none"></TD>'skip
    '<TD style="width: 40px; text-align: left;border: none"></TD>'skip
    '<TD style="width: 65px; text-align: left;border: none"></TD>'skip
    '<TD style="width: 40px; text-align: left;border: none"></TD>'skip
    '<TD style="width: 40px; text-align: left;border: none"></TD>'skip
        
    '<TD colspan="3" style=" font-size:9pt; text-align:  left;border: none"> Унифицированная форма № КМ-4</TD>'skip
           
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
    '<TD style="width: 40px; text-align: left;border: none"></TD>'skip
    '<TD style="width: 40px; text-align: left;border: none"></TD>'skip
        
    '<TD colspan="3"style="text-align: left; font-size:9pt; border: none">Утверждена постановлением Госкомстата</TD>'skip
           
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
    '<TD style="width: 40px; text-align: left;border: none"></TD>'skip
    '<TD style="width: 40px; text-align: left;border: none"></TD>'skip
        
    '<TD colspan = "3" style="font-size:9pt; text-align:  left;border: none"> России от 25.12.98 № 132 </TD>'skip
    '</TR>'skip
            
            
        '<TR>'skip
        '<TD HEIGHT="18" style="text-align: left;border: none"></TD>'skip
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
        '<TD  style="text-align: width: 64px left;border: none"></TD>'skip
        '<TD  style="width: 42px; text-align: left;border: none"></TD>'skip
        '<TD  style="width: 100px; text-align: left;border: none"></TD>'skip
        '<TD  colspan = "2" STYLE="font-size:10pt; border:  1px solid black; text-align: center">Код</TD>'skip
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
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style=" font-size:10pt;  text-align: right;border: none">Форма по ОКУД</TD>'skip
        '<TD colspan = "2" STYLE="border: 1px solid black; font-size:10pt; text-align: center">0330104</TD>'skip
        '</TR>'skip
            
        
            
        '<TR>'skip
        '<TD   COLSPAN="14"  HEIGHT="17" STYLE="border: none;border-bottom: 1px solid black;  text-align: center"> ' + v-organization  + '  </TD>'skip
        '<TD   style="text-align: right; font-size:10pt; border: none">по ОКПО</TD>'skip
        '<TD   colspan = "2" STYLE="border: 1px solid black;text-align: left"></TD>'skip
        '</TR>'skip
            
            
               
        '<TR>'skip
        '<TD COLSPAN="14"  HEIGHT="17" STYLE="font-size:7pt; border: none;border-bottom: 1px solid black;  text-align: center">  (организация, адрес,  номер  телефона)     </TD>'skip  
        '<TD STYLE="border: none;font-size:10pt; text-align: right">ИНН</TD>'skip
        '<TD colspan = "2" STYLE="border: 1px solid black;text-align: left"></TD>'skip
        '</TR>'skip


        '<TR>'skip
        '<TD COLSPAN="13"  HEIGHT="17" STYLE="border: none;border-bottom: 1px solid black;  text-align: center"> ' + v-object +  '  </TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD  style="text-align: left;border: none"></TD>'skip
        '<TD colspan = "2" STYLE="border: 1px solid black;text-align: left"></TD>'skip
        '</TR>'skip

    
        '<TR>'skip
        '<TD style="text-align: left;border: none "></TD>'skip
        '<TD colspan="10" style=" font-size:7pt; text-align: center;border: none">(структурное подразделение)</TD>'skip
        '<TD style="text-align: left;border: none"></TD>'skip         
        '<TD colspan="3" style=" font-size:10pt; text-align: right ;border: none">Вид деятельности по ОКДП </TD>'skip
        '<TD colspan = "2" STYLE="border: 1px solid black;text-align: left"></TD>'skip
        '</TR>'skip

        '<TR>'skip
        '<TD  style="text-align: left;border: none">Контрольно-</TD>'skip
        '<TD COLSPAN="11"  HEIGHT="17" STYLE="border: none;border-bottom: 1px solid black;  text-align: center"> ' + v-kkm-model + string(v-kkm-num) +  '  </TD>'skip
        '<TD  style=" font-size:10pt; text-align: left;border: none">номер</TD>'skip
        '<TD  colspan = "2" STYLE="border: 1px solid black; text-align: left">производителя</TD>'skip
       
        '<TD colspan = "2" STYLE="border: 1px solid black;text-align: left"></TD>'skip
        '</TR>'skip
        
           .
            end.
             do:
     put stream OutStr-html unformatted
     
     
    '<TR>'skip
    '<TD  style="text-align: left;border: none">кассовая машина</TD>'skip
    '<TD  colspan = "10" style="font-size:7pt; text-align: center;border: none">(модель (класс, тип, марка))</TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
     '<TD style="text-align: left;border: none"></TD>'skip
    '<TD  colspan = "2" STYLE="border: 1px solid black;text-align: left">регистрационный</TD>'skip
   
    '<TD colspan = "2" STYLE="border: 1px solid black;text-align: left"></TD>'skip
    '</TR>'skip
        
    '<TR>'skip
    '<TD colspan = "2" style="text-align: left;border: none">Прикладная программа</TD>'skip
    '<TD COLSPAN= "12"  HEIGHT="17" STYLE="border: none;border-bottom: 1px solid black;  text-align: center"> '+  v-kkm-programm + '  </TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD colspan = "2" STYLE="border: 1px solid black;text-align: left"></TD>'skip
    '</TR>'skip
         
    '<TR>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD colspan = "10" style=" font-size:7pt; text-align: center;border: none">(наименование)</TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip  
    '<TD colspan = "2" style=" font-size:10pt; text-align: right;border: none">Вид операции</TD>'skip
    '<TD colspan = "2" STYLE="border: 1px solid black;text-align: left"></TD>'skip
    '</TR>'skip
         
         
    ' <TR>'skip
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
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;width: 60px; border: none"></TD>'skip
    '<TD  style="text-align: left; width: 60px; border: none"></TD>'skip
  
    '</TR>'skip
         
    ' <TR>'skip
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
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '</TR>'skip
         
    ' <TR>'skip
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
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '</TR>'skip
         
    ' <TR>'skip
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
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '</TR>'skip
         
    ' <TR>'skip
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
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '</TR>'skip
         
     ' <TR>'skip
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
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '</TR>'skip
         
            .
            end.
             do:
     put stream OutStr-html unformatted
         
         ' <TR>'skip
    '<TD HEIGHT="28" style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD colspan = "6" style="text-align:center; font-weight: bold; font-size:28pt; border: none">Ж  У  Р  Н  А  Л</TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '</TR>'skip
    
    ' <TR>'skip
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
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip 
    '</TR>'skip
         
         
                
    ' <TR>'skip
    '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD colspan = "6" style="text-align: center; font-weight: bold; font-size:12pt; border: none">КАССИРА - ОПЕРАЦИОНИСТА</TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '</TR>'skip
         
    ' <TR>'skip
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
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '</TR>'skip
    
    ' <TR>'skip
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
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '</TR>'skip
/*         fnc-DD-MM-YYYY(date(string(buf_income.doc-date,"99/99/9999")))*/
    ' <TR>'skip
    '<TD  HEIGHT="17" style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left; font-weight: bold; border: none">за период с </TD>'skip
    '<TD  COLSPAN="2"  HEIGHT="17" STYLE="border: none;border-bottom: 1px solid black;  text-align: center"> ' +  fnc-DD-MM-YYYY(date(string(x-date-start,"99/99/9999"))) + '  </TD>'skip
    '<TD  style="text-align: left; font-weight: bold; border: none">по</TD>'skip
    '<TD  COLSPAN="3"  HEIGHT="17" STYLE="border: none;border-bottom: 1px solid black;  text-align: center"> ' +    close-date      +  '  </TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left; font-weight: bold; border: none">года</TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '</TR>'skip
     
    ' <TR style="height: 50pt;">'skip
    '<TD HEIGHT="17" colspan = "17" style="text-align: left;border: none"></TD>'skip

    '</TR>'skip
    
    
    ' <TR>'skip
/*    '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip*/
    '<TD colspan= "4" style="text-align: right;border: none">Лицо, ответственное за ведение журнала</TD>'skip
    '<TD COLSPAN="4"  HEIGHT="17" STYLE="border: none;border-bottom: 1px solid black;  text-align: center"> '  '  </TD>'skip
    '<TD style="text-align: left;border: none"></TD>'skip
    '<TD COLSPAN="8"  HEIGHT="17" STYLE="border: none;border-bottom: 1px solid black;  text-align: center"> '  '  </TD>'skip
    '</TR>'skip
    
    ' <TR>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
/*    '<TD  style="text-align: left;border: none"></TD>'skip*/
    '<TD colspan = "4" style="text-align: center; font-size:7pt;border: none"> (должность) </TD>'skip
    '<TD  style="text-align: left;border: none"></TD>'skip
    '<TD COLSPAN="8" style="text-align: center; font-size:7pt;border: none">(фамилия, имя, отчество)</TD>'skip
    '</TR>'skip
    
    .
    end.
    
    do: 
                put stream OutStr-html unformatted
            '</tbody>'
                '   </table>' skip
                '  </body>' skip.
            end.
            
     do:       
         /* Параметры "глобальной" таблицы отчёта */
         put stream OutStr-html unformatted
             ' <body>' skip
             '   <table name=" KM-'+  string(v-kkm-num)  + '"  fit_to_page="true" outline_below="false"  orientation="landscape">' skip
             '     <thead>' skip
             '       <tr class="set_columns">' skip                          
             '         <td style="width:100px; border: none;"></td>' skip 
             '         <td style="width:150px; border: none;"></td>' skip 
             '         <td style="width:150px; border: none;"></td>' skip 
             '         <td style="width:150px; border: none;"></td>' skip 
             '         <td style="width:150px; border: none;"></td>' skip 
             '         <td style="width:150px; border: none;"></td>' skip 
             '         <td style="width:150px; border: none;"></td>' skip 
             '         <td style="width:150px; border: none;"></td>' skip 
             '         <td style="width:150px; border: none;"></td>' skip 
             '         <td style="width:150px; border: none;"></td>' skip 
             
             '</tr>' skip
             '     </thead>' skip
             
             .
                    end.  
      
       
            
    do:  /* Шапка таблицы отчёта (видимой, как таблица) */
            put stream OutStr-html unformatted
            '     <tbody>' skip
            '<tr>' skip
            '         <th   rowspan = "5"   style="background-color:#ffffcc; font-size:9pt; text-align: center">Дата (смена)</th>' skip
            '         <th   rowspan = "5"   style="background-color:#ffffcc; font-size:9pt; text-align: center">Номер отдела (секции)</th>' skip
            '         <th   rowspan = "5"   style="background-color:#ffffcc; font-size:9pt; text-align: center">Фамилия, имя, отчество кассира</th>' skip
            '         <th   rowspan = "5"   style="background-color:#ffffcc; font-size:9pt; text-align: center">Порядковый номер контрольного счетчика (отчета фискальной памяти) на конец рабочего дня (смены)</th>' skip
            '         <th   colspan = "5"   style="background-color:#ffffcc; font-size:9pt; text-align: center">Показания</th>' skip
            '         <th   rowspan = "5"   style="background-color:#ffffcc; font-size:9pt; text-align: center">Сумма выручки за рабочий день (смену),руб. коп.</th>' skip
            '</tr>' skip
            
            '<tr>' skip
            '         <th  rowspan = "4"  style="background-color:#ffffcc; font-size:9pt; text-align: center">контрольного счетчика (отчета фискальной памяти), регистрирующего количество переводов показаний суммирующего денежного счетчика</th>' skip
            '         <th  colspan = "4"  style="background-color:#ffffcc;font-size:9pt; text-align: center">суммирующих денежных счетчиков</th>' skip           
            '</tr>' skip
            
            '<tr>'  skip
            '         <th   colspan = "3"  style="background-color:#ffffcc; font-size:9pt; text-align: center">на начало рабочего дня (смены)</th>' skip
            '         <th   style="background-color:#ffffcc; font-size:9pt; text-align: center">на конец рабочего дня (смены)</th>' skip
            '</tr>' skip
            
            
            '<tr>'  skip
            '         <th   rowspan = "2" style="background-color:#ffffcc; font-size:9pt; text-align: center">сумма,руб. коп.</th>' skip        
            '         <th   colspan = "2" style="background-color:#ffffcc; font-size:9pt; text-align: center">подпись</th>' skip
            '         <th   rowspan = "2" style="background-color:#ffffcc; font-size:9pt; text-align: center">сумма,руб. коп.</th>' skip        
            '</tr>' skip
            
            '<tr>'   skip
            '         <th    style="background-color:#ffffcc; font-size:9pt; text-align: center">кассира</th>' skip        
            '         <th    style="background-color:#ffffcc; font-size:9pt; text-align: center">администратора</th>' skip                
            '</tr>' skip
            
            '<tr>'skip
                        '         <th   style="background-color:#ffffcc; font-size:9pt; text-align: center">1</th>' skip        
                        '         <th   style="background-color:#ffffcc; font-size:9pt; text-align: center">2</th>' skip        
                        '         <th   style="background-color:#ffffcc; font-size:9pt; text-align: center">3</th>' skip        
                        '         <th   style="background-color:#ffffcc; font-size:9pt; text-align: center">4</th>' skip        
                        '         <th   style="background-color:#ffffcc; font-size:9pt; text-align: center">5</th>' skip        
                        '         <th   style="background-color:#ffffcc; font-size:9pt; text-align: center">6</th>' skip        
                        '         <th   style="background-color:#ffffcc; font-size:9pt; text-align: center">7</th>' skip        
                        '         <th   style="background-color:#ffffcc; font-size:9pt; text-align: center">8</th>' skip        
                        '         <th   style="background-color:#ffffcc; font-size:9pt; text-align: center">9</th>' skip        
                        '         <th   style="background-color:#ffffcc; font-size:9pt; text-align: center">10</th>' skip        
            
            
            '</tr>'skip
           '</tbody>' skip
            .
                output stream OutStr-html close.      
    end.  
    
    
    do:    
        output stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8'.
/*        for each temp-str where temp-str.cash-num = tt-cash-desk.cash-num:*/
      
            put stream OutStr-html unformatted
                '       <tr level="1">' skip
                '         <td style="display: yes; font-size:9pt; text-align:  right">' + v-shift-name +  '</td>' skip         
                '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                '         <td style="display: yes; font-size:9pt; text-align:  right">' + temp-str.person +  '</td>' skip     
                '         <td style="display: yes; font-size:9pt; text-align:  right">' + string(temp-str.z-number) +  '</td>' skip
                '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip      
                '         <td style="display: yes; font-size:9pt; text-align:  right">'  '</td>' skip
                '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip        
                '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip        
                '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip        
                '         <td style="display: yes; font-size:9pt; text-align:  right">'  +  if  temp-str.summ-sale  <> ?  then fnc-convert-dot-to-colon( temp-str.summ-sale, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip        
                '</tr>' skip
               
                    .
                      
                    end.
                     do:
     put stream outstr-html unformatted
     
     
     
     '<tr>'skip
                     '         <td colspan = "4" style="border: none; text-align:  right;">' '</td>' skip
/*                     '         <td style="display: yes; font-size:9pt; border: none ; text-align:  right">' '</td>' skip                     */
/*                     '         <td style="display: yes; font-size:9pt; border : none; text-align:  right">' '</td>' skip                     */
/*                                          '         <td style="display: yes; font-size:9pt; border : none; text-align:  right">' '</td>' skip*/
                     
                     '         <td  style="display: yes; font-size:9pt; text-align: left;">Итого за день (смену) </td>' skip
                          '         <td style="display: yes; font-size:9pt;   text-align:  right;">' '</td>' skip
                          '         <td style="display: yes; font-size:9pt; text-align:  right;">X</td>' skip
                          '         <td style="display: yes; font-size:9pt; text-align:  right;">X</td>' skip
                          '         <td style="display: yes; font-size:9pt; text-align:  right;">' '</td>' skip
                '         <td style="display: yes; font-size:9pt; text-align:  right;">'  +  if  temp-str.summ-sale  <> ?  then fnc-convert-dot-to-colon( temp-str.summ-sale, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip        

     '</tr>'skip
    .
    
    
    end.  
                   
                    
                .           
/*        end.*/

                     do: 
        put stream OutStr-html unformatted
/*            '</tbody>' skip*/
'  </body>' skip
            '   </table>' skip
               .
         end.   
           
            do:       
 /* Параметры "глобальной" таблицы отчёта */
     put stream OutStr-html unformatted
         '   <table name="KM-' +  string(v-kkm-num)  + '-2" fit_to_page="true" outline_below="false" cellspacing="0" border="0" orientation="landscape">' skip
       '  <colgroup width="113"></colgroup>'skip
    '<colgroup width="70"></colgroup>' skip
    '<colgroup width="68"></colgroup>' skip
    '<colgroup width="99"></colgroup>' skip
    '<colgroup width="150"></colgroup>' skip
    '<colgroup width="128"></colgroup>' skip
    '<colgroup width="150"></colgroup>' skip
    '<colgroup width="165"></colgroup>' skip
    
     '     <thead>' skip
     '       <tr class="set_columns">' skip                          
     '         <td style="width:100px; border: none;"></td>' skip 
     '         <td style="width:150px; border: none;"></td>' skip 
     '         <td style="width:150px; border: none;"></td>' skip 
     '         <td style="width:150px; border: none;"></td>' skip 
     '         <td style="width:150px; border: none;"></td>' skip 
     '         <td style="width:150px; border: none;"></td>' skip 
     '         <td style="width:150px; border: none;"></td>' skip   
     '         <td style="width:150px; border: none;"></td>' skip   
             '</tr>' skip
              '     </thead>' skip
             .
                    end.  
           
    do:  /* Шапка таблицы отчёта (видимой, как таблица) */
        put stream OutStr-html unformatted
/*            '     <tbody>' skip*/
            '<tr>' skip
            '         <td    colspan = "4" style="background-color:#ffffcc; border:  1px solid black; font-weight: bold; font-size:9pt; text-align: center">Сдано</td>' skip
            '         <td    style="background-color:#ffffcc;  font-size:9pt;  font-weight: bold;  border: none; border-top: 1px solid black;   border-right: 1px solid black;  text-align: center">Сумма денег</td>' skip
            '         <td    colspan = "3" style="background-color:#ffffcc; font-size:9pt; font-weight: bold;   border:  1px solid black; text-align: center">Подпись на конец рабочего дня (смены)</td>' skip
            '</tr>'skip
            
            '<tr>' skip
            '         <td    style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border: none; border-right: 1px solid black; border-left: 1px solid black;  text-align: center"></td>' skip
            '         <td   rowspan = "2" colspan = "2" style="background-color:#ffffcc; font-weight: bold; border:  1px solid black; font-size:9pt; text-align: center">оплачено по документам</td>' skip
            '         <td    style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border: none; border-right: 1px solid black; border-left: 1px solid black;  text-align: center"></td>' skip
                        '         <td  valign="middle"   style="background-color:#ffffcc;  font-size:9pt;  font-weight: bold;   border-right: 1px solid black;  border: none; text-align: center"> возвращенная </td>' skip
            
            '         <td     style="background-color:#ffffcc; font-size:9pt;  border: none; font-weight: bold;  border-left: 1px solid black; border-right: 1px solid black; text-align: center"></td>'  skip
            
            ' <td     style="background-color:#ffffcc; font-size:9pt; border: none;   font-weight: bold; border-right: 1px solid black;  text-align: center"> </td>'  skip
           
            ' <td      style="background-color:#ffffcc; font-size:9pt;  border: none; font-weight: bold; border-right: 1px solid black; text-align: center"> </td>'  skip
            '</tr>'skip
            
            
            
              '<tr>' skip
                          '         <td    style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border: none; border-right: 1px solid black;  border-left: 1px solid black; text-align: center"></td>' skip
                          '         <td    style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border: none; border-right: 1px solid black; border-left: 1px solid black;  text-align: center"></td>' skip
              
                                      '         <td  valign="middle"   style="background-color:#ffffcc;  font-size:9pt;  border-right: 1px solid black;   font-weight: bold;  border: none; text-align: center"> покупателям (клиентам)  </td>' skip
              
            '         <td    style="background-color:#ffffcc; font-size:9pt;  border: none; font-weight: bold;border-right: 1px solid black;   border-left: 1px solid black;  text-align: center"></td>' skip
            '         <td   style="background-color:#ffffcc; font-size:9pt;  border: none; font-weight: bold; border-right: 1px solid black;   text-align: center">администратора</td>' skip
                        '         <th    style="background-color:#ffffcc;  border: none; font-weight: bold;  border-right: 1px solid black;  font-size:9pt; text-align: center"></td>' skip
            
            '</tr>'skip
   
            
            
        '<tr >' skip
                    '         <td    style="background-color:#ffffcc; font-size:9pt; font-weight: bold;   border: none; border-right: 1px solid black; border-left: 1px solid black;  text-align: center">наличными,</td>' skip
        
        '         <td   style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border: none; border-right: 1px solid black; border-left: 1px solid black;   text-align: center"></td>' skip
        '         <td     style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border: none; border-right: 1px solid black; border-left: 1px solid black;  text-align: center"></td>' skip
                    '         <td    style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border: none; border-right: 1px solid black; border-left: 1px solid black;  text-align: center"></td>' skip
        
        '         <td  valign="middle"   style="background-color:#ffffcc;  font-size:9pt;  font-weight: bold;  border-right: 1px solid black;  border: none; text-align: center"> по неиспользованным  </td>' skip
        
        '         <td    style="background-color:#ffffcc; font-size:9pt; border: none; font-weight: bold; border-right: 1px solid black;   border-left: 1px solid black;   text-align: center">кассира</td>' skip
        '         <td    style="background-color:#ffffcc; font-size:9pt; border: none; font-weight: bold; border-right: 1px solid black;  text-align: center">(старшего кассира)</td>' skip
        '         <td    style="background-color:#ffffcc; font-size:9pt; border: none; font-weight: bold;  border-right: 1px solid black; text-align: center">руководителя</td>' skip
            
        '</tr>'skip
   
        '<tr>' skip
                    '         <td    style="background-color:#ffffcc; font-size:9pt; font-weight: bold;   border: none; border-right: 1px solid black; border-left: 1px solid black;  text-align: center">руб. коп.</td>' skip
                '         <td   style="background-color:#ffffcc; font-size:9pt; font-weight: bold;   border: none; border-right: 1px solid black; border-left: 1px solid black;  text-align: center"></td>' skip
                '         <td   style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border: none; border-right: 1px solid black; border-left: 1px solid black; text-align: center"></td>' skip
                    '         <td    style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border: none; border-right: 1px solid black; border-left: 1px solid black;  text-align: center"></td>' skip
        
                '         <td  valign="middle"   style="background-color:#ffffcc;  font-size:9pt;  font-weight: bold;   border-right: 1px solid black;  border: none; text-align: center"> кассовым чекам,   </td>' skip
        
        '         <td    style="background-color:#ffffcc; font-size:9pt; border: none; font-weight: bold; border-right: 1px solid black; border-left: 1px solid black; text-align: center"></td>' skip
        '         <td    style="background-color:#ffffcc; font-size:9pt; border: none; font-weight: bold; border-right: 1px solid black;  text-align: center">Показания счетчиков сняли</td>' skip
          '         <td    style="background-color:#ffffcc; font-size:9pt; border: none; font-weight: bold;  border-right: 1px solid black;  text-align: center">(старшего кассира)</td>' skip
            
        '</tr>'skip
   
        '<tr>' skip
                    '         <td    style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border: none; border-right: 1px solid black; border-left: 1px solid black; text-align: center"></td>' skip
                        '         <td  style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border: none; border-right: 1px solid black; border-left: 1px solid black;   text-align: center">количество</td>' skip
                '         <td    style="background-color:#ffffcc; font-size:9pt; font-weight: bold; border: none; border-right: 1px solid black; border-left: 1px solid black;  text-align: center">сумма,руб. коп.</td>' skip
                    '         <td    style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border: none; border-right: 1px solid black; border-left: 1px solid black;  text-align: center">всего руб.коп.</td>' skip
        
                        '         <td  valign="middle"   style="background-color:#ffffcc;  font-size:9pt;  font-weight: bold;  border-right: 1px solid black;  border: none; text-align: center">  руб. коп. </td>' skip
        
        '         <td    style="background-color:#ffffcc; font-size:9pt; border: none; font-weight: bold; border-right: 1px solid black;border-left: 1px solid black;    text-align: center">Деньги и оплаченные</td>' skip
        '         <td    style="background-color:#ffffcc; font-size:9pt; border: none; font-weight: bold; border-right: 1px solid black; text-align: center">Деньги принял</td>' skip
        '         <td    style="background-color:#ffffcc; font-size:9pt; border: none; font-weight: bold;  border-right: 1px solid black;   text-align: center"></td>' skip
               
        '</tr>'skip
   
   
        '<tr >' skip
                    '         <td    style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border: none; border-right: 1px solid black;  border-left: 1px solid black;    text-align: center"></td>' skip
                        '         <td   style="background-color:#ffffcc; font-size:9pt; font-weight: bold;   border: none; border-right: 1px solid black; border-left: 1px solid black;  text-align: center"></td>' skip
                '         <td     style="background-color:#ffffcc; font-size:9pt; font-weight: bold; border: none; border-right: 1px solid black; border-left: 1px solid black;  text-align: center"></td>' skip
                    '         <td    style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border: none; border-right: 1px solid black; border-left: 1px solid black;  text-align: center"></td>' skip
        
                        '         <td  valign="middle"   style="background-color:#ffffcc;  font-size:9pt;  font-weight: bold;  border: none; text-align: center">    </td>' skip
      
        '         <td    style="background-color:#ffffcc; font-size:9pt; border: none; font-weight: bold; border-right: 1px solid black;  border-left: 1px solid black;   text-align: center">счета сдал</td>' skip
        '         <td    style="background-color:#ffffcc; font-size:9pt; border: none;  font-weight: bold; border-right: 1px solid black;  text-align: center"></td>' skip
        '         <td    style="background-color:#ffffcc; font-size:9pt; border: none; font-weight: bold; border-right: 1px solid black;  text-align: center"></td>' skip
            
        '</tr>'skip
   
    
        '<tr >' skip
                    '         <td    style="background-color:#ffffcc; font-size:9pt; font-weight: bold;   border: none; border-right: 1px solid black;  border-left: 1px solid black;  text-align: center"></td>' skip
                        '         <td   style="background-color:#ffffcc; font-size:9pt; font-weight: bold;   border: none; border-right: 1px solid black; border-left: 1px solid black;   text-align: center"></td>' skip
                '         <td    style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border: none; border-right: 1px solid black; border-left: 1px solid black;  text-align: center"></td>' skip
                    '         <td    style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border: none; border-right: 1px solid black; border-left: 1px solid black;  text-align: center"></td>' skip
        
                '         <td    style="background-color:#ffffcc; font-size:9pt;  border: none; font-weight: bold; border-right: 1px solid black; text-align: center"></td>' skip
                '         <td   style="background-color:#ffffcc; font-size:9pt;  border: none; font-weight: bold; border-right: 1px solid black; border-left: 1px solid black;   text-align: center"></td>' skip
        
        '         <td    style="background-color:#ffffcc; font-size:9pt;  border: none; font-weight: bold; border-right: 1px solid black; text-align: center"></td>' skip
        '         <td    style="background-color:#ffffcc; font-size:9pt;  border: none; font-weight: bold;  border-right: 1px solid black; text-align: center"></td>' skip
            
        '</tr>'skip
   
            '<tr>'skip
            '         <td   style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border:  1px solid black; text-align: center">11</td>' skip        
            '         <td   style="background-color:#ffffcc; font-size:9pt; font-weight: bold; border:  1px solid black; text-align: center">12</td>' skip        
            '         <td   style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border:  1px solid black; text-align: center">13</td>' skip        
            '         <td   style="background-color:#ffffcc; font-size:9pt; font-weight: bold;  border:  1px solid black; text-align: center">14</td>' skip        
            '         <td   style="background-color:#ffffcc; font-size:9pt;  font-weight: bold; border:  1px solid black; text-align: center">15</td>' skip        
            '         <td   style="background-color:#ffffcc; font-size:9pt;  font-weight: bold; border:  1px solid black;  text-align: center">16</td>' skip        
            '         <td   style="background-color:#ffffcc; font-size:9pt; font-weight: bold; border:  1px solid black; text-align: center">17</td>' skip        
            '         <td   style="background-color:#ffffcc; font-size:9pt; font-weight: bold; border:  1px solid black; text-align: center">18</td>' skip        
            '</tr>'skip
            .
        output stream OutStr-html close.      
    end.  
    
    
    do:    
        output stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8'.
/*        for each temp-str where temp-str.cash-num = tt-cash-desk.cash-num:*/
            put stream OutStr-html unformatted
            '     <tbody>' skip
                '       <tr level="1">' skip   
                '         <td style="display: yes; font-size:9pt; text-align:  right">'  +  if  temp-str.summ-nal  <> ?  then fnc-convert-dot-to-colon( temp-str.summ-nal, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip               
                '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip     
                '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip  
                '         <td style="display: yes; font-size:9pt; text-align:  right">'  +  if  temp-str.summ-return  <> ?  then fnc-convert-dot-to-colon( temp-str.summ-return, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                 
                '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip        
                '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip        
                '</tr>' skip       
                .           
    end.
    
    do:
        put stream outstr-html unformatted
            '<tr>'skip          
                '         <td style="display: yes; font-size:9pt; text-align:  right">'  +  if  temp-str.summ-nal  <> ?  then fnc-convert-dot-to-colon( temp-str.summ-nal, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip               
            '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
            '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
            '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                '         <td style="display: yes; font-size:9pt; text-align:  right">'  +  if  temp-str.summ-return  <> ?  then fnc-convert-dot-to-colon( temp-str.summ-return, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip                 
            '</tr>'skip
            .
    
    
    end.
        
    do: 
        put stream OutStr-html unformatted
            ' </tbody>' skip
            ' </thead>' skip
            ' </table>' skip
            ' </body>' skip
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
     define input parameter number-cash-tt as integer.
    define output parameter p-file-name-rep-htm as character no-undo.

    p-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(p-rep-num + number-cash-tt) + ".html".

end procedure.


procedure Report-Viewer:            /* Запуск на выполнение RV (input Полный_путь_имя_файла_RV, input Полный_путь_имя_файла_отчHTML) */
/* Запуск программы "Просмотровщик Отчётов" - ReportViewer. */
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter v-search as character no-undo.

    os-command no-wait value(p-full-path-RepView + " true " + v-search).

end procedure.


function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date):
/* Преобразование даты в формат: "01.01.2014" */

    define variable result as character no-undo.
    define variable p-str-date as character no-undo.

    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").

        return p-str-date.

end function.





function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character):
/* Конвертация десятичной точки в запятую с передачей параметра форматирования числа (accuracy - точность) */

    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
/*message "dbg-p-data = " p-data skip "p-accur = " p-accur view-as alert-box.*/
    p-data = round(p-data, 2). /* Чтобы не выйти случайно за рамки формата числа при выводе (несоотвесвие формата результата и формата отображения - приводит к ош) */
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).

    return v-str-result.

end function.
    
    
    
         
        
        

