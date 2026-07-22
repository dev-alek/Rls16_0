block-level on error undo, throw.
/*

$Revision: 03c97b127fc3, 2119, rls $
$Author: SMMolotkov $
$Date: Wed Dec 25 15:23:52 2019 +0300 $
$Workfile: inv-5.p $
$Archive: rep/inv-5.p $

Инвентаризационная опись ИНВ-5

Автор: Молотков Сергей Михайлович
Дата создания: 07/11/18
Author: Molotkov Sergey
Creation date: 07/11/18

строка подключения через rep/load-do2.i :
{ rep/menu-doc.i {&TDEDT_Inv} "'*'" "'*'" "'*'"              "'Инвентаризационная опись ИНВ-5'"                                       "'cost,sale,rubl,base'" "'rep/inv-5.p'"     "'invent,no,no'"                     "'+-+++-+'"  "''"                  "'HTML'"      "''"                   ? }
  
*/
define input parameter parParentProc      as handle no-undo .
define input parameter rec_id             as recid no-undo .
define input parameter rep-tipe           as character no-undo.
define input parameter p-grp              as character no-undo. /* используется для печати только сумм по группам */
define input parameter print-graft        as logical          no-undo.

define variable vss-revision    as character no-undo initial "$Revision: 03c97b127fc3, 2119, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo initial "$Date: Wed Dec 25 15:23:52 2019 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: inv-5.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/inv-5.p $":U .
define variable vss-description as character no-undo initial "Формы по инвентаризации ".
{ cmp/vssrevis.i     }

{ cmp/str-glbl.i     } /* &sum-before-doc, &sum-after-doc */
{ rep/r-cliprp.i def } /* ищет t-okpo для ОКПО */
  { str/trdcalib.i }
&scop f-l MonthNameRusCase,Sparse
{ gbl/std-func.i {&f-l} }

  
  define temp-table temp-str no-undo
      /* Поставщик (получатель) */
      field   prod-type         as character
      field   prod-code         as integer
      field   prod-name         as character /* (2) наименование */
      field   prod-okpo         as character /* (3) код по ОКПО */
      
      /* Товарно-материальные ценности, принятые на ответственное хранение наименование */
      field   gds-name          as character /* (4) характеристика (вид, сорт, группа) */
      field   artic             as character /* (5) код (номенклатурный номер) */

      field   store-name        as character /* (6) Место хранения */
/* (7) Дата принятия груза на ответственное хранение */

      /* Документы, подтверждающие количество товарно-материальных ценностей, принятых на ответственное хранение */
/* (8) наименование */
/* (9) номер */
/* (10) дата */

      /* Единица измерения */
      field   unit-base         as character /* (11) наименование */
      field   OKEI              as integer   /* (12) код по ОКЕИ */

      /* Фактическое наличие */
      field   a-qnty            as decimal /* (13) количество */
      field   a-stoim           as decimal /* (14) стоимость товарно-материальных ценностей, руб. коп. */

      /* По данным бухгалтерского учёта */
      field   b-qnty            as decimal /* (15) количество */
      field   b-stoim           as decimal /* (16) стоимость товарно-материальных ценностей, руб. коп. */

  .
  
define variable g#gds-engl    as logical no-undo .   /* = v-cntxt-gds-engl   from mainmenu.w */
define variable g#report-num  as integer no-undo .   /* = v-cntxt-report-num from mainmenu.w */
define variable v-prn0        as character no-undo . /* = conf-rd.p ("invprn0"): "yes" - печатать нулевые строки */
define variable v-par-type    as character no-undo .
define variable v-organization as character no-undo . /* = "clients.obj-name (clients.obj-code)" */
define variable v-store-name   as character no-undo .
define variable v-doc-code     as character no-undo .
define variable v-doc-date     as date no-undo .
define variable v-sfact-date   as character no-undo .
define variable v-sfact-prop   as character no-undo . /* trn-doc.fact-date прописью */
define variable v-prod-name    as character no-undo .
define variable v-prod-okpo    as character no-undo .
define variable v-price-lastin as decimal no-undo .
define variable v-a-qnty       as decimal no-undo .
define variable v-a-stoim      as decimal no-undo .
define variable v-b-qnty       as decimal no-undo .
define variable v-b-stoim      as decimal no-undo .
define variable v-sum          as decimal no-undo .
define variable v-a-stoim-tot  as decimal no-undo .
define variable v-b-stoim-tot  as decimal no-undo .
define variable v-a-quant-tot  as decimal no-undo . /* | переменные -stiom-tot суммируют итог в рублях, */
define variable v-b-quant-tot  as decimal no-undo . /* | переменные -quant-tot складывают штуки с литрами. 20/V-2019 */
define variable PropisSumall   as character no-undo .
define variable abbr           as character no-undo .
define buffer buf_goods        for ub.goods .
define buffer buf_units        for ub.units .
define buffer buf_clients      for ub.clients . /* поставщик */
define buffer This_Object      for ub.clients . /* магазин */
define buffer buf_clients0     for ub.clients . /* организация */
/* документ инвентаризации */
define buffer buf_trn-doc      for ub.trn-doc .
define buffer buf_doc-line     for ub.doc-line .
define buffer buf_doc-line-sum for ub.doc-line-sum .
/* define buffer buf_gds-dtl      for ub.gds-dtl . */
/* документ последнего прихода */
define buffer buf_trn-doc2     for ub.trn-doc .
define buffer buf_doc-line2    for ub.doc-line .

do
on error undo, return error
:

   find first buf_trn-doc no-lock where recid(buf_trn-doc) = rec_id no-error .
   if not available buf_trn-doc then return error .

   assign
     g#gds-engl   = false
     g#report-num = 0
   .
   if valid-handle (parParentProc) then do :
     if can-do (parParentProc:internal-entries, "get-gds-engl":U) then
       run get-gds-engl   in parParentProc ( output g#gds-engl ).
     if can-do (parParentProc:internal-entries, "get-report-num":U) then
       run get-report-num in parParentProc ( output g#report-num ).
   end .

   run gbl/conf-rd.p ("invprn0", "", "", 0, "", "", "", no, output v-prn0, output v-par-type) no-error.
   if error-status:error then v-prn0 = 'yes' .

   /* взять наименование для объекта, в котором проводится инвентаризация */
   find first This_Object no-lock
        where This_Object.obj-type = buf_trn-doc.obj-type
          and This_Object.obj-code = buf_trn-doc.obj-code no-error .
   v-store-name = if available This_Object then This_Object.obj-name
                                           else substitute("&1&2", buf_trn-doc.obj-type, buf_trn-doc.obj-code) .
  
  assign
    v-prod-name    = ""
    v-prod-okpo    = ""
    v-price-lastin = 0          
    v-a-stoim-tot = 0
    v-b-stoim-tot = 0
    v-a-quant-tot = 0
    v-b-quant-tot = 0
  .
    
for each buf_doc-line no-lock
   where buf_doc-line.doc-code = buf_trn-doc.doc-code :
  find first buf_goods no-lock
       where buf_goods.prod-type = buf_doc-line.prod-type
         and buf_goods.prod-code = buf_doc-line.prod-code
         and buf_goods.artic     = buf_doc-line.artic    no-error.
  if not available buf_goods then next .
  find first buf_units no-lock
       where buf_units.unit-name = buf_doc-line.unit-cli no-error.
  if not available buf_units then do :
    find first buf_units no-lock
         where buf_units.unit-name = buf_goods.unit-base no-error.
    if not available buf_units then next .
  end .
  
  do : /* поставщик из последнего прихода, цена из последней приходной накладной */
    for each buf_doc-line2 no-lock
       where buf_doc-line2.obj-type  = buf_trn-doc.obj-type
         and buf_doc-line2.obj-code  = buf_trn-doc.obj-code
         and buf_doc-line2.prod-type = buf_doc-line.prod-type
         and buf_doc-line2.prod-code = buf_doc-line.prod-code
         and buf_doc-line2.artic     = buf_doc-line.artic
         and buf_doc-line2.ext-doc-type = {&TDEDT_Pri_Vnesh}
         and buf_doc-line2.status_   = {&fact},
       first buf_trn-doc2 no-lock
       where buf_trn-doc2.doc-code   = buf_doc-line2.doc-code
          by buf_doc-line2.fact-order descending :
      find first buf_clients no-lock
           where buf_clients.obj-type = buf_trn-doc2.cli-type
             and buf_clients.obj-code = buf_trn-doc2.cli-code no-error .
      if available buf_clients then do :
        { rep/r-cliprp.i buf_ }
        assign
          v-prod-name    = buf_clients.obj-name
          v-prod-okpo    = t-okpo
          v-price-lastin = buf_doc-line2.price-rubl
        .
        leave .
      end .
    end .
  end . /* end_of поставщик из последнего прихода */
  
  do : /* количества и суммы */
    /* 09/I-2019  doc-line-sum.crsa-sum-rubl не подходит */
    find first buf_doc-line-sum no-lock
         where buf_doc-line-sum.doc-code = buf_doc-line.doc-code
           and buf_doc-line-sum.gds-code = buf_goods.gds-code
           and buf_doc-line-sum.sum-type = {&sum-before-doc} no-error.
    if available buf_doc-line-sum then assign
      v-b-qnty  = buf_doc-line-sum.fact-qnty
      v-b-stoim = buf_doc-line-sum.cost-sum-rubl
    .
    else assign
      v-b-qnty  = 0
      v-b-stoim = 0
    .
    find first buf_doc-line-sum no-lock
         where buf_doc-line-sum.doc-code = buf_doc-line.doc-code
           and buf_doc-line-sum.gds-code = buf_goods.gds-code
           and buf_doc-line-sum.sum-type = {&sum-after-doc} no-error.
    if available buf_doc-line-sum then assign
      v-a-qnty  = buf_doc-line-sum.fact-qnty
      v-a-stoim = buf_doc-line-sum.cost-sum-rubl
    .
    else assign
      v-a-qnty  = v-b-qnty  + buf_doc-line.fact-qnty
    .
    v-a-stoim = v-a-qnty * v-price-lastin .
    if v-prn0 = "no" then do:
      if v-a-qnty = 0 and v-a-stoim = 0 and v-b-qnty = 0 and v-b-stoim = 0 then next .
    end.
  end . /* end_of количества и суммы */
  
  create temp-str.
  assign
    /* - лишние. prod-type - производитель, не поставщик.
    temp-str.prod-type   = buf_goods.prod-type
    temp-str.prod-code   = buf_goods.prod-code
    */
    temp-str.prod-name   = v-prod-name
    temp-str.prod-okpo   = v-prod-okpo
    temp-str.gds-name    = ( if g#gds-engl then buf_goods.engl-name else buf_goods.gds-name )
    temp-str.artic       = buf_doc-line.artic
    temp-str.store-name  = v-store-name
    
    temp-str.unit-base   = buf_units.unit-name
    temp-str.OKEI        = buf_units.OKEI
    temp-str.a-qnty      = v-a-qnty
    temp-str.a-stoim     = v-a-stoim /* в приходных ценах */
    temp-str.b-qnty      = v-b-qnty
    temp-str.b-stoim     = v-b-stoim /* в учётных ценах */
    
    v-a-stoim-tot = v-a-stoim-tot + v-a-stoim
    v-b-stoim-tot = v-b-stoim-tot + v-b-stoim
    v-a-quant-tot = v-a-quant-tot + v-a-qnty
    v-b-quant-tot = v-b-quant-tot + v-b-qnty
  .
end. /* end_of each_buf_doc-line */

   find first buf_clients0 no-lock
        where buf_clients0.obj-type = {&cmp}
          and buf_clients0.obj-code = buf_trn-doc.host-code no-error .
   v-organization =
   /* 10/I-2019  убрать код фирмы из наименования организации 
   if available buf_clients0 then substitute( "&1 (&2)", CAPS(buf_clients0.obj-name), buf_clients0.obj-code)
                             else substitute( "&1 (&2)", {&cmp}, buf_trn-doc.host-code)
   */                          
   if available buf_clients0 then substitute( "&1", CAPS(buf_clients0.obj-name))
                             else substitute( "&1 (&2)", {&cmp}, buf_trn-doc.host-code)
   .
   assign
     v-doc-code = buf_trn-doc.doc-code
     v-doc-date = buf_trn-doc.doc-date
   .
   if buf_trn-doc.fact-date = ? then assign
     v-sfact-date = ""
     v-sfact-prop = ""
   .
   else assign
     v-sfact-date = string(buf_trn-doc.fact-date,"99/99/9999")
     v-sfact-prop = "&laquo;" + string(day(buf_trn-doc.fact-date)) + "&raquo;" +
                    substitute(" &1 &2 г.",
                               MonthNameRusCase( month( buf_trn-doc.fact-date ), 2 ),
                               year(buf_trn-doc.fact-date)
                              )
   .
   run rep/wp-rub.p (input v-a-stoim-tot, output PropisSumall, output abbr) .

   
  /* ----- вывод на печать ----- */
{ rep/html-conv.i } /* fnc-convert-dot-to-colon() */
{ cmp/library.i   } /* filenmln() */
  { gbl/prn-lib.i   } /* prn-lib-get-report-name() */

  define variable v-report-name       as character no-undo .
  define variable v-file-name-rep-pg1 as character no-undo .
  define variable v-file-name-rep-pg2 as character no-undo .
  define variable v-file-name-rep-pg3 as character no-undo .
  define variable Lines_Counter       as integer   no-undo . /* (1) Номер по порядку */
  define variable v-fact-date         as character no-undo .
  define variable v-frame-str         as character no-undo .
  define variable v-prikaz-num        as character no-undo .
  define variable v-prikaz-date       as character no-undo .
  define variable p-type              as character no-undo.
  define variable v-pos-agent         as character no-undo .
  define variable v-fio-agent         as character no-undo .
  define variable v-pos-player1       as character no-undo .
  define variable v-fio-player1       as character no-undo .
  define variable v-pos-player2       as character no-undo .
  define variable v-fio-player2       as character no-undo .
  define variable v-pos-player3       as character no-undo .
  define variable v-fio-player3       as character no-undo .
  define variable v-inv-date          as character no-undo .
      
  define stream OutStr-html.

  run gbl/getrpnum.p (output g#report-num).
  run prn-lib-get-report-name in this-procedure ( input parParentProc, output v-report-name ).
  v-file-name-rep-pg1 = substitute( "&1pg1.html", v-report-name ) .
  v-file-name-rep-pg2 = substitute( "&1pg2.html", v-report-name ) .  
  v-file-name-rep-pg3 = substitute( "&1pg3.html", v-report-name ) .  
  
  { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-inv-date}
          v-inv-date
          p-type
          no-error
      }
  { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-prikaz-number}
          v-prikaz-num
          p-type
          no-error
      }
  { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-prikaz-date}
          v-prikaz-date
          p-type
          no-error
      }  


  { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-fio-agent}
          v-fio-agent
          p-type
          
      }
  { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-pos-agent}
          v-pos-agent
          p-type
          no-error
      }
  { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-fio-player1}
          v-fio-player1
          p-type
          no-error
      }
  { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-pos-player1}
          v-pos-player1
          p-type
          no-error
      }
  { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-fio-player2}
          v-fio-player2
          p-type
          no-error
      }
  { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-pos-player2}
          v-pos-player2
          p-type
          no-error
      }
  { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-fio-player3}
          v-fio-player3
          p-type
          no-error
      }
  { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-pos-player3}
          v-pos-player3
          p-type
          no-error
      }            
    v-prikaz-date = replace(v-prikaz-date,".","") .
    v-inv-date = replace(v-inv-date,".","") .
      
  Lines_Counter = 0 .
  /* 09/XI-2018 согласно образцу, приложенному к ТР, опись выводится на три листа:
     1. титульный лист
     2. табличная часть
     3. результаты инвентаризации, подписи комиссии
  */
  
/* &scoped-define css_page1nam border-bottom-style:solid; border-bottom-width:thin; text-align:center; */
&scoped-define css_page1tit      text-align:center; font-weight:bold;
&scoped-define css_align_righit  text-align:right; padding-right:4px;
&scoped-define css_align_center  text-align:center;
&scoped-define css_table_border  border-style:solid; border-width:thin;
&scoped-define css_cell_border   border: 1px solid black; 
&scoped-define css_border_bottom border-bottom: 1px solid black;  

  output stream OutStr-html to value(v-file-name-rep-pg1) convert target 'UTF-8' .

  /* -------- заголовок ----------------------------------------------------------------------------------- */
do :
  put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    '<html>' skip
    '<head>' skip
    '  <meta charset="utf-8">' skip
    '  <style type="text/css">' skip
    
    '      table.pg1 ~{border-collapse:collapse;~}' skip
    '      table.pg2 ~{border-collapse:collapse;~}' skip
    '      table.pg3 ~{border-collapse:collapse;~}' skip

    '      table.pg1 thead td ~{border-style:none;~}' skip
    '      table.pg1 thead td.page1kod ~{{&css_cell_border} text-align:center;~}' skip
    '      table.pg1 thead td.page1lab ~{{&css_align_righit}~}' skip
    '      table.pg1 thead td.page1nam ~{{&css_border_bottom} text-align:center;~}' skip
    '      table.pg1 thead td.page1und ~{{&css_align_center}~}' skip
    '      table.pg1 thead td.page1tit ~{{&css_page1tit}~}' skip
    '      table.pg1 thead td.page1til ~{{&css_align_center}~}' skip

    '      table.pg2 tbody td, table.pg2 tbody th ~{{&css_table_border}~}' skip
    '      table.pg2 tbody td:nth-child(13), table.pg2 tbody td:nth-child(14), table.pg2 tbody td:nth-child(15), table.pg2 tbody td:nth-child(16) ~{{&css_align_righit}~}' skip

    '      table.pg3 tbody td, table.pg3 tbody th ~{{&css_table_border}~}' skip
    '      table.pg3 tfoot td.page3nam ~{{&css_border_bottom}~}' skip
    '      table.pg3 tfoot td.page3und ~{{&css_align_center}~}' skip
    
    '  </style>' skip
    '</head>' skip
    '<body>' skip
  .
end .


  /* -------- лист1 ----------------------------------------------------------------------------------- */
do :
  
  
  
  put stream OutStr-html unformatted
    '<table class="pg1" name="стр1" orientation="landscape" fit_to_page="true" style="border:0;">' skip
    '<thead>' skip

    /* row 1 */
    '  <tr class="set_columns">' skip
    '    <td style="width: 333px;"></td>' skip /* Основание для проведения инвентаризации: 19+12+11+136+21+23+90+21=333 */
    '    <td style="width: 151px;"></td>' skip /* Подпись на расписке: Управляющий 45+106=151*/
    '    <td style="width:  16px;"></td>' skip /* Подпись на расписке: разделитель между должностью и подписью K=16 */
    '    <td style="width: 103px;"></td>' skip /* Подпись на расписке: подпись L=103 */
    '    <td style="width:  28px;"></td>' skip /* Номер документа M=28 */
    '    <td style="width:  53px;"></td>' skip /* Подпись на расписке: разделитель между подписью и расшифровекой подписи N=53 */
    '    <td style="width:  43px;"></td>' skip /* Унифицированная форма № ИНВ-5 O=43 */
    '    <td style="width:  25px;"></td>' skip /* по ОКПО P=25 */
    '    <td style="width:  46px;"></td>' skip /* Дата составления 42+4=46 */
    '    <td style="width:  95px;"></td>' skip /* коды S=95 */
    '    <td style="width:  47px;"></td>' skip /* правый край "Дата составления" T=47 */
    '  </tr>' skip

    /* row 2 - 31 */
    /* 20/XI-2018 есть подозрение, что ReportViewer игнорирует стили, описанные через классы, и
                  использует только стили, описанные inline. До выяснения дублируем описание стилей.
       10/I-2019  исключено заполнение полей, для которых в ТР отсутствует описание.
    */

    '  <tr>' skip /* 1..3 */
    '    <td colspan="6" rowspan="3"><br /></td>' skip
    '    <td colspan="5">Унифицированная форма № ИНВ-5</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="5">Утверждена постановлением Госкомстата</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="5">России от 18.08.98 № 88</td>' skip
    '  </tr>' skip

    '  <tr>' skip /* 4..7 */
    '    <td colspan="9"><br /></td>' skip
    '    <td colspan="2" class="page1kod" style="{&css_cell_border} text-align:center;">Код</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="6"><br /></td>' skip
    '    <td colspan="3" class="page1lab" style="{&css_align_righit}">Форма по ОКУД</td>' skip
    '    <td colspan="2" class="page1kod" style="{&css_cell_border} text-align:center;">0317006</td>' skip
    '  </tr>' skip

    '  <tr>' skip
    '    <td colspan="6" class="page1nam" style="{&css_border_bottom} text-align:center;">' v-organization '</td>' skip
    '    <td colspan="3" class="page1lab" style="{&css_align_righit}">по ОКПО</td>' skip
    '    <td colspan="2" class="page1kod" style="{&css_cell_border} text-align:center;">&nbsp;</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="6" class="page1und" style="{&css_align_center}">(организация)</td>' skip
    '    <td colspan="3">&nbsp;</td>' skip
    '    <td colspan="2" class="page1kod" style="{&css_cell_border} text-align:center;">&nbsp;</td>' skip
    '  </tr>' skip

    '  <tr>' skip /* 8..9 */
    '    <td colspan="6" class="page1nam" style="{&css_border_bottom} text-align:center;">' v-store-name '</td>' skip
    '    <td colspan="3">&nbsp;</td>' skip
    '    <td colspan="2" class="page1kod" style="{&css_cell_border} text-align:center;">&nbsp;</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="6" class="page1und" style="{&css_align_center}">(структурное подразделение)</td>' skip
    '    <td colspan="3" class="page1lab" style="{&css_align_righit}">Вид деятельности</td>' skip
    '    <td colspan="2" class="page1kod" style="{&css_cell_border} text-align:center;">&nbsp;</td>' skip
    '  </tr>' skip

    '  <tr>' skip /* 10..11 */
    '    <td class="page1lab" style="{&css_align_righit}">Основание для проведения инвентаризации:</td>' skip
    '    <td colspan="6" class="page1nam" style="{&css_border_bottom} text-align:center;">приказ, постановление, распоряжение</td>' skip
    '    <td colspan="2" class="page1kod page1lab"  style="{&css_cell_border} {&css_align_righit}">номер</td>' skip
    '    <td colspan="2" class="page1kod"           style="{&css_cell_border} text-align:center;">' + v-prikaz-num + '</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td>&nbsp;</td>' skip
    '    <td colspan="6" class="page1und" style="{&css_align_center}">(ненужное зачеркнуть)</td>' skip
    '    <td colspan="2" class="page1kod page1lab"  style="{&css_cell_border} {&css_align_righit}">дата</td>' skip
    '    <td colspan="2" class="page1kod"           style="{&css_cell_border} text-align:center;">' + string(v-prikaz-date, "99/99/9999") + '</td>' skip
    '  </tr>' skip

    '  <tr>' skip /* 12..15 */
    '    <td colspan="9" class="page1lab" style="{&css_align_righit}">Дата начала инвентаризации</td>' skip
    '    <td colspan="2" class="page1kod" style="{&css_cell_border} text-align:center;">' + if v-inv-date <> "" then string(v-inv-date,"99/99/9999") + '</td>' else string(v-doc-date,"99/99/9999") + '</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="9" class="page1lab" style="{&css_align_righit}">Дата окончания инвентаризации</td>' skip
    '    <td colspan="2" class="page1kod" style="{&css_cell_border} text-align:center;">' v-sfact-date '</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="9" class="page1lab" style="{&css_align_righit}">Вид операции</td>' skip
    '    <td colspan="2" class="page1kod" style="{&css_cell_border} text-align:center;">инвентаризация</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="9" class="page1lab" style="{&css_align_righit}">Номер счета бухгалтерского учета</td>' skip
    '    <td colspan="2" class="page1kod" style="{&css_cell_border} text-align:center;"><br /></td>' skip
    '  </tr>' skip

    '  <tr>' skip /* 16 */
    '    <td colspan="11"><br /></td>' skip
    '  </tr>' skip

    '  <tr>' skip /* 17..19 */
    '    <td colspan="4"><br /></td>' skip
    '    <td colspan="4" class="page1kod" style="{&css_cell_border} text-align:center;">Номер документа</td>' skip
    '    <td colspan="2" class="page1kod" style="{&css_cell_border} text-align:center;">Дата составления</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4" class="page1tit" style="{&css_page1tit}">ИНВЕНТАРИЗАЦИОННАЯ ОПИСЬ</td>' skip
    '    <td colspan="4" class="page1kod" style="{&css_cell_border} text-align:center;">' v-doc-code '</td>' skip
    '    <td colspan="2" class="page1kod" style="{&css_cell_border} text-align:center;">' v-doc-date '</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4" class="page1tit" style="{&css_page1tit}">товарно-материальных ценностей, принятых на комиссию</td>' skip
    '    <td colspan="6"><br /></td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip

    '  <tr>' skip /* 20..22 */
    '    <td colspan="11" class="page1til" style="{&css_align_center}">РАСПИСКА</td>' skip
    '  </tr>' skip
    '  <tr style="height: 40px;">' skip
    '    <td colspan="11" text_wrap="true">&nbsp;&nbsp;&nbsp;&nbsp;К началу проведения инвентаризации все расходные и приходные документы на товарно-материальные ценности сданы в бухгалтерию и все товарно-материальные ценности, поступившие на мою (нашу) ответственность, оприходованы, а выбывшие списаны в расход.</td>' skip
    '  </tr>' skip

    '  <tr>' skip /* 23..26 */
    '    <td class="page1lab" style="{&css_align_righit}">Материально ответственное(ые) лицо(а):</td>' skip
    '    <td             class="page1nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td rowspan="4">&nbsp;</td>' skip
    '    <td colspan="2" class="page1nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td rowspan="4"><br /></td>' skip
    '    <td colspan="5" class="page1nam" style="{&css_border_bottom}"><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td rowspan="3"><br /></td>' skip
    '    <td             class="page1und" style="{&css_align_center}">(должность)</td>' skip
    '    <td colspan="2" class="page1und" style="{&css_align_center}">(подпись)</td>' skip
    '    <td colspan="5" class="page1und" style="{&css_align_center}">(расшифровка подписи)</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td             class="page1nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td colspan="2" class="page1nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td colspan="5" class="page1nam" style="{&css_border_bottom}"><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td             class="page1und" style="{&css_align_center}">(должность) </td>' skip
    '    <td colspan="2" class="page1und" style="{&css_align_center}">(подпись)</td>' skip
    '    <td colspan="5" class="page1und" style="{&css_align_center}">(расшифровка подписи)</td>' skip
    '  </tr>' skip

    '  <tr>' skip /* 27..30 */
    '    <td colspan="11"><br /></td>' skip
    '  </tr>' skip
  .
  if buf_trn-doc.fact-date <> ? then put stream OutStr-html unformatted
    '  <tr>' skip
    '    <td colspan="11" text_wrap="true">По состоянию на ' v-sfact-prop ' произведено снятие фактических остатков ценностей, принятых (сданных) на комиссию.</td>' skip
    '  </tr>' skip
  .
  put stream OutStr-html unformatted
    '  <tr>' skip
    '    <td colspan="11"><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td>При инвентаризации установлено следующее:&nbsp;</td>' skip
    '    <td colspan="10"><br /></td>' skip
    '  </tr>' skip

    '</thead>' skip
    '<tbody>' skip
    '</tbody>' skip
    '<tfoot>' skip
    '</tfoot>' skip
    '</table>' skip
  .
end .  


  /* -------- лист2 ----------------------------------------------------------------------------------- */
do :
  put stream OutStr-html unformatted
    '<table class="pg2" name="стр2" orientation="landscape" fit_to_page="true" repeat_rows="1:4">' skip
    '<thead>' skip

    /* row 1 */
    '  <tr class="set_columns">' skip
    '    <td style="width:  45px;"></td>' skip /* (1) Номер по поряд-ку */
    
      /* Поставщик (получатель) */
    '    <td style="width: 134px;"></td>' skip /* (2) наименование */
    '    <td style="width:  78px;"></td>' skip /* (3) код по ОКПО */
      /* Товарно-материальные ценно-сти, принятые на комиссию */
    '    <td style="width: 102px;"></td>' skip /* (4) наименование, характеристика (вид, сорт, группа) */
    '    <td style="width:  77px;"></td>' skip /* (5) код (номенк-латурный но-мер) */
    
    '    <td style="width:  62px;"></td>' skip /* (6) Место хранения */
    '    <td style="width:  66px;"></td>' skip /* (7) Дата принятия груза на комиссию */
    
      /* Документы, подтверждаю-щие количество товарно-материальных ценностей, принятых на комиссию */
    '    <td style="width:  50px;"></td>' skip /* (8)  наиме-нова-ние */
    '    <td style="width:  54px;"></td>' skip /* (9)  номер */
    '    <td style="width:  43px;"></td>' skip /* (10) дата */
/*    '    <td style="width: 147px;"></td>' skip /* (8)+(9)+(10) */*/
      /* Единица измерения */
    '    <td style="width:  51px;"></td>' skip /* (11) наимено-вание */
    '    <td style="width:  46px;"></td>' skip /* (12) код по ОКЕИ */
      /* Фактическое на-личие */
    '    <td style="width:  77px;"></td>' skip /* (13) коли-чество */
    '    <td style="width:  72px;"></td>' skip /* (14) стоимость товарно-матери-альных ценностей, руб. коп. */
      /* По данным бухгал-терского учета */
    '    <td style="width:  71px;"></td>' skip /* (15) коли-чество */
    '    <td style="width:  75px;"></td>' skip /* (16) стоимость товарно-материаль-ных ценно-стей, руб. коп. */
    '  </tr>' skip
    
    '</thead>' skip
    '<tbody>' skip
    
    /* row 2..4 */
    '  <tr style="height: 120px;">' skip
    '    <th rowspan="2">Номер по поряд-ку</th>' skip
    '    <th colspan="2">Поставщик (получатель)</th>' skip
    '    <th colspan="2">Товарно-материальные ценности, принятые на комиссию</th>' skip
    '    <th rowspan="2">Место хранения</th>' skip
    '    <th rowspan="2">Дата принятия груза на комиссию</th>' skip
    '    <th colspan="3">Документы, подтверждающие количество товарно-материальных ценностей, принятых на комиссию</th>' skip
/*    '    <th            >Документы, подтверждающие количество товарно-материальных ценностей, принятых на комиссию</th>' skip*/
    '    <th colspan="2">Единица измерения</th>' skip
    '    <th colspan="2">Фактическое наличие</th>' skip
    '    <th colspan="2">По данным бухгалтерского учета</th>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <th>наименование</th>' skip
    '    <th>код по ОКПО</th>' skip
    '    <th>наименование, характеристика (вид, сорт, группа)</th>' skip
    '    <th>код (номенк-латурный номер)</th>' skip
    '    <th>наиме-нова-ние</th>' skip
    '    <th>номер</th>' skip
    '    <th>дата</th>' skip
/*    '    <th><br /></th>' skip*/
    '    <th>наиме-нова-ние</th>' skip
    '    <th>код по ОКЕИ</th>' skip
    '    <th>коли-чество</th>' skip
    '    <th>стоимость товарно-материаль-ных ценно-стей, руб. коп.</th>' skip
    '    <th>коли-чество</th>' skip
    '    <th>стоимость товарно-материаль-ных ценно-стей, руб. коп.</th>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <th>1</th>' skip
    '    <th>2</th>' skip
    '    <th>3</th>' skip
    '    <th>4</th>' skip
    '    <th>5</th>' skip
    '    <th>6</th>' skip
    '    <th>7</th>' skip
    '    <th>8</th>' skip
    '    <th>9</th>' skip
    '    <th>10</th>' skip
/*    '    <th><br /></th>' skip*/
    '    <th>11</th>' skip
    '    <th>12</th>' skip
    '    <th>13</th>' skip
    '    <th>14</th>' skip
    '    <th>15</th>' skip
    '    <th>16</th>' skip
    '  </tr>' skip
  .
end .
   for each temp-str :
     Lines_Counter = Lines_Counter + 1 .
     put stream OutStr-html unformatted
       '  <tr>'
       substitute('<td>&1</td>', Lines_Counter)
       substitute('<td text_wrap="true">&1</td>', temp-str.prod-name)
       substitute('<td>&1</td>', temp-str.prod-okpo)
       substitute('<td text_wrap="true">&1</td>', temp-str.gds-name)
       substitute('<td>&1</td>', temp-str.artic)
       substitute('<td>&1</td>', temp-str.store-name)
       '    <td><br /></td>'
       '    <td><br /></td>'
       '    <td><br /></td>'
       '    <td><br /></td>'
/*       '<td><br /></td>'*/
       substitute('<td>&1</td>', temp-str.unit-base)
       substitute('<td>&1</td>', temp-str.OKEI)
       substitute('<td num="0.000" val="&1">&1</td>', fnc-convert-dot-to-colon(temp-str.a-qnty, "->>>>>>>>>>>9.999",3)  )
       substitute('<td num="0.00"  val="&1">&1</td>', fnc-convert-dot-to-colon(temp-str.a-stoim,"->>>>>>>>>>>9.99", 2)  )
       substitute('<td num="0.000" val="&1">&1</td>', fnc-convert-dot-to-colon(temp-str.b-qnty, "->>>>>>>>>>>9.999",3)  )
       substitute('<td num="0.00"  val="&1">&1</td>', fnc-convert-dot-to-colon(temp-str.b-stoim,"->>>>>>>>>>>9.99", 2)  )
       '  </tr>' skip
     .
   end . /* end_of for_each_temp-str */
do :  
  put stream OutStr-html unformatted
    '  <tr>' skip
    '    <td colspan="12" style="{&css_align_righit}">Итого</td>' skip
    substitute('    <td num="0.000" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-a-quant-tot,"->>>>>>>>>>>9.999", 3)
              , "{&css_align_righit}"
              ) skip
    substitute('    <td num="0.00" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-a-stoim-tot,"->>>>>>>>>>>9.99", 2)
              , "{&css_align_righit}"
              ) skip
    substitute('    <td num="0.000" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-b-quant-tot,"->>>>>>>>>>>9.999", 3)
              , "{&css_align_righit}"
              ) skip
    substitute('    <td num="0.00" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-b-stoim-tot,"->>>>>>>>>>>9.99", 2)
              , "{&css_align_righit}"
              ) skip
    '  </tr>' skip
    '</tbody>' skip
    /* строка с итогами остаётся в tbody;
       в tfoot у неё в excel пропадают рамочки
    '<tfoot>' skip
    '</tfoot>' skip
    */
    '</table>' skip
  .
end .


  /* -------- лист3 ----------------------------------------------------------------------------------- */
do :
  put stream OutStr-html unformatted
    '<table class="pg3" name="стр3" orientation="landscape" fit_to_page="true">' skip
    '<thead>' skip
    
    /* row 1 */
    '  <tr class="set_columns">' skip
    '    <td style="width:  25px;"></td>' skip /* 1 Номер по поряд-ку A=25 */
    '    <td style="width:  20px;"></td>' skip /* 2 Всего по описи сумма 45-A=20 */
    '    <td style="width: 133px;"></td>' skip /* 3 Поставщик (получатель) | наименование */
    '    <td style="width:  78px;"></td>' skip /* 4 Поставщик (получатель) | код по ОКПО */
    '    <td style="width: 102px;"></td>' skip /* 5 Товарно-материальные ценно-сти, принятые на комиссию | наименование, характеристика (вид, сорт, группа) */
    '    <td style="width:  77px;"></td>' skip /* 6 Товарно-материальные ценно-сти, принятые на комиссию | код (номенк-латурный но-мер) */
    '    <td style="width:  30px;"></td>' skip /* 7 Место хранения J=30 */
    '    <td style="width:  32px;"></td>' skip /* 8 Управляющий 62-J=32 */
    
    '    <td style="width:  66px;"></td>' skip /* 9 Дата принятия груза на комиссию */
    '    <td style="width:  44px;"></td>' skip /* 10 Документы, подтверждаю-щие количество товарно-материальных ценностей, принятых на комиссию | наиме-нова-ние P=44 */
    '    <td style="width:   6px;"></td>' skip /* 11 Управляющий 50-P=6 */
    '    <td style="width:  54px;"></td>' skip /* 12 Документы, подтверждаю-щие количество товарно-материальных ценностей, принятых на комиссию | номер */
    '    <td style="width:  43px;"></td>' skip /* 13 Документы, подтверждаю-щие количество товарно-материальных ценностей, принятых на комиссию | дата  */

    '    <td style="width:  51px;"></td>' skip /* 14 Единица измерения | наимено-вание */
    '    <td style="width:  28px;"></td>' skip /* 15 (подпись) X=28 */
    '    <td style="width:  46px;"></td>' skip /* 16 Единица измерения | код по ОКЕИ Y=46-X=18 */
    
    '    <td style="width:  54px;"></td>' skip /* 17 Фактическое на-личие | коли-чество 77-AB=54 */
    '    <td style="width:  23px;"></td>' skip /* 18 (прописью) AB=23 */
    '    <td style="width:  72px;"></td>' skip /* 19 Фактическое на-личие | стоимость товарно-матери-альных ценностей, руб. коп. */
    '    <td style="width:  71px;"></td>' skip /* 20 По данным бухгал-терского учета | коли-чество 34+10=44 */
    '    <td style="width:  75px;"></td>' skip /* 21 По данным бухгал-терского учета | стоимость товарно-материаль-ных ценно-стей, руб. коп. 18+10+33=61 */
    '  </tr>' skip
    '</thead>' skip
    '<tbody>' skip
    
    /* row 2..4 */
    '  <tr style="height: 120px;">' skip
    '    <th colspan="2" rowspan="2">Номер по поряд-ку</th>' skip
    '    <th colspan="2">Поставщик (получатель)</th>' skip
    '    <th colspan="2">Товарно-материальные ценности, принятые на комиссию</th>' skip
    '    <th colspan="2" rowspan="2">Место хранения</th>' skip
    '    <th rowspan="2">Дата принятия груза на комиссию</th>' skip
    '    <th colspan="4">Документы, подтверждающие количество товарно-материальных ценностей, принятых на комиссию</th>' skip
    '    <th colspan="3">Единица измерения</th>' skip
    '    <th colspan="3">Фактическое наличие</th>' skip
    '    <th colspan="2">По данным бухгалтерского учета</th>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <th>наименование</th>' skip
    '    <th>код по ОКПО</th>' skip
    '    <th>наименование, характеристика (вид, сорт, группа)</th>' skip
    '    <th>код (номенк-латурный номер)</th>' skip
    '    <th>наиме-нова-ние</th>' skip
    '    <th colspan="2">номер</th>' skip
    '    <th>дата</th>' skip
    '    <th>наиме-нова-ние</th>' skip
    '    <th colspan="2">код по ОКЕИ</th>' skip
    '    <th>коли-чество</th>' skip
    '    <th colspan="2">стоимость товарно-материаль-ных ценно-стей, руб. коп.</th>' skip
    '    <th>коли-чество</th>' skip
    '    <th>стоимость товарно-материаль-ных ценно-стей, руб. коп.</th>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <th colspan="2">1</th>' skip
    '    <th>2</th>' skip
    '    <th>3</th>' skip
    '    <th>4</th>' skip
    '    <th>5</th>' skip
    '    <th colspan="2">6</th>' skip
    '    <th>7</th>' skip
    '    <th>8</th>' skip
    '    <th colspan="2">9</th>' skip
    '    <th>10</th>' skip
    '    <th>11</th>' skip
    '    <th colspan="2">12</th>' skip
    '    <th>13</th>' skip
    '    <th colspan="2">14</th>' skip
    '    <th>15</th>' skip
    '    <th>16</th>' skip
    '  </tr>' skip
    
    /* rows ИТОГО  */
    '  <tr>' skip
    '    <td colspan="16" style="{&css_align_righit}">Итого</td>' skip
    substitute('    <td num="0.000" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-a-quant-tot,"->>>>>>>>>>>9.999", 3)
              , "{&css_align_righit}"
              ) skip
    substitute('    <td colspan="2" num="0.00" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-a-stoim-tot,"->>>>>>>>>>>9.99", 2)
              , "{&css_align_righit}"
              ) skip
    substitute('    <td num="0.000" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-b-quant-tot,"->>>>>>>>>>>9.999", 3)
              , "{&css_align_righit}"
              ) skip
    substitute('    <td num="0.00" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-b-stoim-tot,"->>>>>>>>>>>9.99", 2)
              , "{&css_align_righit}"
              ) skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="16" style="{&css_align_righit}">Всего</td>' skip
    substitute('    <td num="0.000" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-a-quant-tot,"->>>>>>>>>>>9.999", 3)
              , "{&css_align_righit}"
              ) skip
    substitute('    <td colspan="2" num="0.00" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-a-stoim-tot,"->>>>>>>>>>>9.99", 2)
              , "{&css_align_righit}"
              ) skip
    substitute('    <td num="0.000" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-b-quant-tot,"->>>>>>>>>>>9.999", 3)
              , "{&css_align_righit}"
              ) skip
    substitute('    <td num="0.00" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-b-stoim-tot,"->>>>>>>>>>>9.99", 2)
              , "{&css_align_righit}"
              ) skip
    '  </tr>' skip

    
    '</tbody>' skip
    '<tfoot>' skip
    
    
    '  <tr>' skip
    '    <td><br /></td>' skip
    '    <td colspan="20" text_wrap="true">Все подсчеты итогов по строкам, страницам и в целом по инвентаризационной описи товарно-материальных ценностей, принятых на комиссию проверены.</td>' skip
    '  </tr>' skip
    
    '  <tr>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3">Всего по описи сумма</td>' skip
    '    <td colspan="16" class="page3nam" style="{&css_border_bottom}">' PropisSumall '</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4"><br /></td>' skip
    '    <td colspan="16" class="page3und" style="{&css_align_center}">(прописью)</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    
    '  <tr>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3">Председатель комиссии</td>' skip
    '    <td colspan="2" class="page3nam" style="{&css_border_bottom}"><br />' + v-pos-agent + '</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="8" class="page3nam" style="{&css_border_bottom}"><br />' + v-fio-agent + '</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4"><br /></td>' skip
    '    <td colspan="2" class="page3und" style="{&css_align_center}">(должность)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3und" style="{&css_align_center}">(подпись)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="8" class="page3und" style="{&css_align_center}">(расшифровка подписи)</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip

    '  <tr>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3">Состав комиссии:</td>' skip
    '    <td colspan="2" class="page3nam" style="{&css_border_bottom}"><br />' + v-pos-player1 + '</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="8" class="page3nam" style="{&css_border_bottom}"><br />' + v-fio-player1 + '</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4"><br /></td>' skip
    '    <td colspan="2" class="page3und" style="{&css_align_center}">(должность)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3und" style="{&css_align_center}">(подпись)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="8" class="page3und" style="{&css_align_center}">(расшифровка подписи)</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip

    '  <tr>' skip
    '    <td colspan="4"><br /></td>' skip
    '    <td colspan="2" class="page3nam" style="{&css_border_bottom}"><br />' + v-pos-player2 + '</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="8" class="page3nam" style="{&css_border_bottom}"><br />' + v-fio-player2 + '</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4"><br /></td>' skip
    '    <td colspan="2" class="page3und" style="{&css_align_center}">(должность)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3und" style="{&css_align_center}">(подпись)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="8" class="page3und" style="{&css_align_center}">(расшифровка подписи)</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4"><br /></td>' skip
    '    <td colspan="2" class="page3nam" style="{&css_border_bottom}"><br />' + v-pos-player3 + '</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="8" class="page3nam" style="{&css_border_bottom}"><br />' + v-fio-player3 + '</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4"><br /></td>' skip
    '    <td colspan="2" class="page3und" style="{&css_align_center}">(должность)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3und" style="{&css_align_center}">(подпись)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="8" class="page3und" style="{&css_align_center}">(расшифровка подписи)</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip    
  .
 
  if Lines_Counter > 0 then do:
    put stream OutStr-html unformatted
    '  <tr style="height: 40px;">' skip
    '    <td><br /></td>' skip
    '    <td text_wrap="true" colspan="20">'
    substitute("Все ценности, поименованные в настоящей инвентаризационной описи с № 1 по № &1, комиссией проверены в натуре в моем (нашем) присутствии и внесены в опись, в связи с чем претензий к инвентаризационной комиссии не имею (не имеем)."
              , Lines_Counter)
        '</td>' skip
    '  </tr>' skip
  .
  end .
  else do:
    put stream OutStr-html unformatted
    '  <tr style="height: 40px;">' skip
    '    <td><br /></td>' skip
    '    <td text_wrap="true" colspan="20">'
    substitute("Все ценности, поименованные в настоящей инвентаризационной описи с № 0 по № &1, комиссией проверены в натуре в моем (нашем) присутствии и внесены в опись, в связи с чем претензий к инвентаризационной комиссии не имею (не имеем)."
              , Lines_Counter)
        '</td>' skip
    '  </tr>' skip
  .    
  end.
  put stream OutStr-html unformatted
    '  <tr>' skip
    '    <td colspan="21">Ценности, перечисленные в описи, находятся на комиссию.</td>' skip
    '  </tr>' skip

    '  <tr>' skip
    '    <td colspan="2"><br /></td>' skip
    '    <td colspan="4">Материально ответственное(ые) лицо(а):</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3" class="page3nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="7"><br /></td>' skip
    '    <td colspan="4" class="page3und" style="{&css_align_center}">(должность)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3" class="page3und" style="{&css_align_center}">(подпись)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3und" style="{&css_align_center}">(расшифровка подписи)</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    
    '  <tr>' skip
    '    <td colspan="7"><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3" class="page3nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="7"><br /></td>' skip
    '    <td colspan="4" class="page3und" style="{&css_align_center}">(должность)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3" class="page3und" style="{&css_align_center}">(подпись)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3und" style="{&css_align_center}">(расшифровка подписи)</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    
    '  <tr>' skip
    '    <td colspan="2"><br /></td>' skip
    '    <td colspan="5">Указанные в настоящей описи данные и расчеты проверил</td>' skip
    '    <td colspan="4" class="page3nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3" class="page3nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="7"><br /></td>' skip
    '    <td colspan="4" class="page3und" style="{&css_align_center}">(должность)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3" class="page3und" style="{&css_align_center}">(подпись)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3und" style="{&css_align_center}">(расшифровка подписи)</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="10"><br /></td>' skip
    '    <td colspan="2">&laquo~;_____&raquo~;</td>' skip
    '    <td colspan="6" class="page3nam" style="{&css_border_bottom}"><br /></td>' skip
    '    <td colspan="3">_______&nbsp~;г.</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip


    '</tfoot>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
  .
end .
/*    
    '  <tr>' skip
    '    <td>*</td>' skip
    '    <td colspan="20">После принятия решения и на основании изменений в локально-нормативные документы Компании по отражению стоимостных показателей, показатель «стоимость товарно-материальных ценностей» заполняется на основании данных 1С:ERP.</td>' skip
    '  </tr>' skip
*/
  output stream OutStr-html close .

  run prn-lib-reportviewer-report-name in this-procedure
  ( input parParentProc /* 12/XI-2018 внутри prn-lib-reportviewer-report-name() параметр parParentProc не используется */ 
  , input substitute("&1", v-file-name-rep-pg1)
/*  , input substitute("&1 &2 &3", v-file-name-rep-pg1, v-file-name-rep-pg2, v-file-name-rep-pg3)*/
  ) .

   
end . /* end_of doe */
/* ------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------- */
