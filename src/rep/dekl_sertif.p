/*

$Revision: ff7c46c71de5, 3298, rls $
$Author: EShklyar $
$Date: 2023/03/29 08:48:06 $
$Workfile: dekl_sertif.p $
$Archive: rep/dekl_sertif.p $

Сертификаты/декларации

Автор: Шкляр Елена 
Дата создания: 08/07/14
Author: Elena Shklyar
Creation date: 08/07/14

*/

using ibs.th.gbl.sys.objsrv.
using ibs.th.str.marking.sts.*.
block-level on error undo, throw.

define variable vss-revision    as character no-undo init "$Revision: ff7c46c71de5, 3298, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/03/29 08:48:06 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dekl_sertif.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/dekl_sertif.p $":U .
define variable vss-description as character no-undo init "Сертификаты/декларации".
{ cmp/vssrevis.i }
{ str/temp_upd.i }

define input parameter parparentproc    as widget-handle  no-undo.
define input parameter table for tt-sert-utd .


{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ str/lib-trn.i  }
{ str/utd-attr.i }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }
{ gbl/objsrv.i }

&global-define month-list-for-date 'января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря':U
/* Для вызова функции конвертации даты к виду: "01 Января 2014г" */
&scop f-l MonthNameRusCase

{ gbl/std-func.i {&f-l} }

define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define variable ii as integer no-undo .
  
define buffer buf_utd       for ub.utd .
define buffer buf_utd-lines for ub.utd-lines .
define buffer buf_clients   for ub.clients .

FUNCTION GdsName RETURNS CHARACTER
  ( input p-gds-code as integer)  FORWARD.
  
FUNCTION CliName RETURNS CHARACTER
  (input p-cli-code as integer, input p-cli-type as character)  FORWARD.
   
FUNCTION get-DD-Month-YYYY RETURNS CHARACTER
  ( input p-dat-date as date)  FORWARD.
  
define temp-table tt-sert-lines no-undo
  field doc-id   as integer
  field db-num   as integer
  field gds-name as character 
  field gds-code as integer
  field gds-TH   as character 
  field sertif   as character 
  field linenum  as integer
  field rowspan  as integer
  index pi doc-id db-num gds-code linenum
  .

do
  on error undo, return error return-value
  :
  /*Сбор данных*/
  for each tt-sert-utd:
  find first buf_utd no-lock where buf_utd.doc-id = tt-sert-utd.doc-id and buf_utd.db-num = tt-sert-utd.db-num no-error .
  if not available (buf_utd) then 
  do:
    message "УПД не найден"
      view-as alert-box.
    return .
  end.

  for each buf_utd-lines no-lock where buf_utd-lines.doc-id = buf_utd.doc-id and buf_utd-lines.db-num = buf_utd.db-num:
    create tt-sert-lines .
    assign 
      tt-sert-lines.db-num   = buf_utd-lines.db-num
      tt-sert-lines.doc-id   = buf_utd-lines.doc-id
      tt-sert-lines.linenum  = buf_utd-lines.LineNum
      tt-sert-lines.gds-code = buf_utd-lines.gds-code
      tt-sert-lines.gds-name = buf_utd-lines.ProductCode

      .
    
    tt-sert-lines.sertif = GetAttrUtdlines(buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.linenum,"doc_sertif").
    tt-sert-lines.gds-TH = GdsName(buf_utd-lines.gds-code) .
    tt-sert-lines.rowspan = if tt-sert-lines.sertif <> ? then num-entries(tt-sert-lines.sertif,{&delim-par}) else 1.

  end.
  end.
    
  /*печать*/
  run get-report-num (output p-report-id).
    
  v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   

                        
  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
  put stream OutStr-html unformatted
  {rep/htmlhead.i}
    .   
   
  for each tt-sert-utd:    
/*    if can-find (first tt-sert-lines no-lock where tt-sert-lines.db-num = tt-sert-utd.db-num and*/
/*      tt-sert-lines.doc-id = tt-sert-utd.doc-id and tt-sert-lines.sertif <> ? ) then            */
/*    do:                                                                                         */
      put stream OutStr-html unformatted
        '<body>' skip
        '<TABLE name="sertif"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
        '<thead>' skip
        .
      put stream OutStr-html unformatted
        '<tr class="set_columns">' skip
        '<td style="width: 50px;"></td>' skip
        '<td style="width: 100px;"></td>' skip
        '<td style="width: 350px;"></td>' skip
        '<td style="width: 450px;"></td>' skip
        '</tr>' skip

        '<tr><td colspan="4">УПД ' + string(tt-sert-utd.DocumentNumber) + ' от ' + string(tt-sert-utd.DocumentDate,"99.99.9999") + '</td></tr>'
        '<tr>' skip
        '<td colspan="4">' + CliName(tt-sert-utd.cli-code, tt-sert-utd.cli-type) + '</td>' skip
        '</tr>' skip
        .
      put stream OutStr-html unformatted
        '<TR><TD colspan="4"></TD></TR>' skip
        '</thead>' skip
        '<tbody>' skip
        .
    
      put stream OutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight: bold;">№ п/п</TD>' skip
        '<TD text_wrap="true" style="text-align: left; font-weight: bold;">Код товара</TD>' skip
        '<TD text_wrap="true" style="text-align: left; font-weight: bold;">Наименование ТН</TD>' skip
        '<TD text_wrap="true" style="text-align: left; font-weight: bold;">Сертификат/Декларация</TD>' skip
        '</TR>' skip .
      ii = 0 .
      for each tt-sert-lines no-lock where tt-sert-lines.db-num = tt-sert-utd.db-num and
        tt-sert-lines.doc-id = tt-sert-utd.doc-id by tt-sert-lines.linenum by tt-sert-lines.rowspan:
    
        put stream OutStr-html unformatted
          '<TR>' skip
          '<TD text_wrap="true" rowspan="' + string(tt-sert-lines.rowspan)+ '" style="text-align: center;">' + if tt-sert-lines.linenum <> ? then string(tt-sert-lines.linenum) + '</TD>' else ""  + '</TD>' skip
          '<TD text_wrap="true" rowspan="' + string(tt-sert-lines.rowspan)+ '" style="text-align: left;">' + if tt-sert-lines.gds-code <> ? then string(tt-sert-lines.gds-code) + '</TD>' else ""  + '</TD>' skip
/*          '<TD text_wrap="true" rowspan="' + string(tt-sert-lines.rowspan)+ '" style="text-align: left;">' + if tt-sert-lines.gds-name <> ? then string(tt-sert-lines.gds-name) + '</TD>' else ""  + '</TD>' skip*/
          '<TD text_wrap="true"  rowspan="' + string(tt-sert-lines.rowspan)+ '"style="text-align: left;">' + if tt-sert-lines.gds-TH <> ? then string (tt-sert-lines.gds-TH) + '</TD>' else ""  + '</TD>' skip
          .
        do ii = 1 to tt-sert-lines.rowspan:
          if ii > 1 then 
          do:
            put stream OutStr-html unformatted
              '<TR>'.    
          end.
          put stream OutStr-html unformatted
            '<TD text_wrap="true" style="text-align: left;">' + if tt-sert-lines.sertif <> ? then entry(ii,tt-sert-lines.sertif,{&delim-par}) + '</TD>' else ""  + '</TD>' skip
            .
          put stream OutStr-html unformatted
            '</TR>'.    
        end.
      end.
      put stream OutStr-html unformatted
        '</tbody>' skip
        '<tfoot>' skip
        '</tfoot>' skip
        '</table>' skip
        '</body>' skip .

 
      put stream OutStr-html unformatted

        '</html>' skip
        .

  end.
output stream OutStr-html close.  
  end.
run prn-lib-reportviewer in this-procedure (
  input this-procedure
  ,input v-file-name-rep-htm
  ,input "" 
  ) no-error.
if error-status:error then
do:
  message return-value view-as alert-box.
  return .
end.
                                                                                                                


function get-DD-Month-YYYY returns character
  (input p-dat-date as date):
    
  define variable v-str-date  as character no-undo.
  define variable v-str-day   as character no-undo.
  define variable v-num-month as character no-undo.
  define variable v-str-month as character no-undo.
  define variable v-str-year  as character no-undo.

  v-str-date = string(p-dat-date).

  do: /* Получаем день в формате цифры, вида NN. */
    v-str-day = string(entry(1, v-str-date, "/")).
  end. /* Получаем день в формате цифры, вида NN. */

  do: /* Получаем прописью месяц */
    v-num-month = entry(2, v-str-date, "/").
    v-str-month = MonthNameRusCase(integer(v-num-month), 2).

  end. /* Получаем прописью месяц */

  do: /* Получаем год в формате цифры, вида "NNNN" */
    /*        v-str-year = entry(3, v-str-date, "/").*/
    v-str-year = string(year(p-dat-date)).
  end. /* Получаем год в формате цифры, вида "NNNN" */

  /* Получаем цифро-буквенную дату в одной строке */
  return '" ' + v-str-day + ' "' + " " + v-str-month + " " + v-str-year + " г.".

end function.

 
FUNCTION GdsName RETURNS CHARACTER
  ( input p-gds-code as integer) :
  /*------------------------------------------------------------------------------
    Purpose:  
      Notes:  
  ------------------------------------------------------------------------------*/
  define variable v-gds-name as character no-undo .
  define buffer buf_goods for ub.goods .
  
  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
  if available (buf_goods) then v-gds-name = buf_goods.gds-name .
  RETURN v-gds-name.   /* Function return value. */

END FUNCTION.


FUNCTION CliName RETURNS CHARACTER
  (input p-cli-code as integer, input p-cli-type as character) :
  /*------------------------------------------------------------------------------
    Purpose:  
      Notes:  
  ------------------------------------------------------------------------------*/
  define variable v-cli-name as character no-undo .
  find first buf_clients no-lock where buf_clients.obj-code = p-cli-code
    and buf_clients.obj-type = p-cli-type no-error .
  if available (buf_clients) then v-cli-name = buf_clients.obj-name .
  RETURN v-cli-name.   /* Function return value. */

END FUNCTION.

PROCEDURE get-report-num :

    define output parameter p-report-num as integer no-undo .

    do
        on error undo, return error return-value
        :
        run gbl/getrpnum.p (output p-report-num).
    end.

END PROCEDURE.