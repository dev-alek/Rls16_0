block-level on error undo, throw.
/*

$Revision: 84c6c67137c5, 2693, rls $
$Author: EShklyar $
$Date: Пт дек 18 18:16:05 2020 +0300 $
$Workfile: r-ddinam.p $
$Archive: rep/r-ddinam.p $

Движение денежных средств

Автор: Комаров Иван Сергеевич
Дата создания: 04/29/10
Author: Ivan Komarov
Creation date: 04/29/10

*/
define input parameter iParam as ibs.th.ref.sobj.sParamObj no-undo .
define var parparentproc as widget-handle no-undo .
parparentproc = iParam:my-handle.
define var p-parent-handle          as handle                  no-undo .
define var p-rdbh                   as handle                  no-undo . /*destination*/
define var p-log-handle             as handle                  no-undo .
/* define input parameter p-parent-handle          as handle                  no-undo .
define input parameter p-log-handle             as handle                  no-undo .
define input parameter p-cont-handle            as handle                  no-undo .
define input parameter p-call-handle            as handle                  no-undo .
define input parameter p-rebh                   as handle                  no-undo . /*для ошибок*/
 */
define input parameter p-report-id              as character               no-undo .
define input parameter p-log-file-name          as character               no-undo .
define input parameter p-batch                  as integer                 no-undo .
define input parameter p-codex-id               as integer                 no-undo .
define input parameter p-ruleset-id             as integer                 no-undo .
define input parameter p-det-obj                as logical                 no-undo .
define input parameter p-det-oper               as logical                 no-undo .
define input parameter p-plain-txt              as   logical               no-undo .
define input parameter p-xls                    as   logical               no-undo .
define input parameter p-dir-name               as   character             no-undo .

define variable vss-revision    as character no-undo init "$Revision: 84c6c67137c5, 2693, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пт дек 18 18:16:05 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ddinam.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ddinam.p $":U .
define variable vss-description as character no-undo init "Движение денежных средств".
{ cmp/vssrevis.i }
{cmp\r-sheetf.i }
define variable v-delim as character no-undo.
{cmp\obj-list.i local} /* obj-list s*/
iParam:get-obj-list(output table obj-list).
{ cmp/library.i }


{ cmp/str-glbl.i }
   { cmp/r-pril.i new }
   { rep/r-sym.i    }
{ rep/f-fdec.i   }
   { gbl/cur-time.i }
      { gbl/prn-lib.i  }
      { ref/grplib.i   }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ rep/r-sale.i   }
{ trg/factord.i  }
define variable g#report-num as integer no-undo .
{ gbl/paramls.i  }
{ rep/ostatok.i  }
{ rep/fostatok.i  &arh-name = "arh-fin-doc-schet-nal-obj" }
{ rep/ost-line.i }
{ str/farh-def.i }
{ cmp/trg-def.i }
{ rep/html-conv.i }
{ rep/reprumpr.i print-plain-text,print-printer,print-xls }

define NEW SHARED variable is-rosneft as logical no-undo init NO.

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
define variable v-cntxt-obj-name as character no-undo .

/*переменные для вывода отчета в HTML*/
define stream Out-Stream.
define stream OutStr-html.


&scop display-message ~
   if VALID-HANDLe(p-log-handle) ~
   then do:                        ~
   if p-batch > 0 then do: ~
     run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input p-log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~). ~
   end. ~
   else do: ~
      run write-to-log in p-log-handle ( input ~{&my-message~}). ~
   end. ~
   end. ~
   else do: ~
      message ~{&my-message~} view-as alert-box. ~
   end


define temp-table temp-fin-doc no-undo
    FIELD sheet-num     as integer
    FIELD host-code     as integer
    FIELD obj-code      as integer
    FIELD obj-type      as character
    FIELD obj-name      as character
    FIELD ost-begin     as decimal
    FIELD income-realiz as decimal
    FIELD income-ras    as decimal
    FIELD income-other  as decimal
    FIELD expense-bank  as decimal
    FIELD expense-ras   as decimal
    FIELD expense-other as decimal
    FIELD ost-end       as decimal
    FIELD ost-end-ras   as decimal
    FIELD staff-curr1   as character
    FIELD staff-curr2   as character
    FIELD staff-curr3   as character
    FIELD staff-curr4   as character
    FIELD staff-curr5   as character
    FIELD staff-next1   as character
    FIELD staff-next2   as character
    FIELD staff-next3   as character
    FIELD staff-next4   as character
    FIELD staff-next5   as character
	field cashbook      as character 
  	field cashbookid    as integer
  INDEX pi is primary unique host-code obj-code obj-type cashbookid
  .
  

define buffer buf_clients                   for ub.clients .
define buffer buf_obj-list                  for obj-list .
define buffer buf_fin-doc                   for ub.fin-doc .
define buffer buf_arh-fin-doc-schet-nal-obj for ub.arh-fin-doc-schet-nal-obj .
define buffer buf_clients-attr              for ub.clients-attr .
define buffer buf_shift-staff               for ub.shift-staff .
define buffer buf_sysconf                   for ub.sysconf .
define buffer buf_cashbook                  for ub.CashBook .
define buffer buf_chk-doc                   for ub.chk-doc .
define buffer buf_shift-obj                 for ub.shift-obj .
define buffer buf_cash-pay                  for ub.cash-pay .
define buffer buf_chk-pay                   for ub.chk-pay .
define buffer buf_chk-gds-pay               for ub.chk-gds-pay .
define buffer buf_chk-gds                   for ub.chk-gds .
define buffer buf_bar-code                  for ub.bar-code .
define buffer buf_goods-attr                for ub.goods-attr .

define variable v-cash              as integer   no-undo .
define variable v-count             as integer   no-undo .
define variable v-str               as integer   no-undo .
define variable v-firm              as character no-undo .
define variable v-object            as character no-undo .
define variable v-host-code         as integer   no-undo .
define variable v-sum-begin         as decimal   no-undo .
define variable sum1                as decimal   no-undo .

define variable f-ost-begin         as character no-undo .
define variable f-cashf-begin       as character no-undo .
define variable f-income-realiz     as character no-undo .
define variable f-income-other      as character no-undo .
define variable f-expense-bank      as character no-undo .
define variable f-expense-other     as character no-undo .
define variable f-ost-end           as character no-undo .
define variable f-cashf-end         as character no-undo .

define variable v-ost-begin         as decimal   no-undo .
define variable v-income-realiz     as decimal   no-undo .
define variable v-income-ras        as decimal   no-undo .
define variable v-income-other      as decimal   no-undo .
define variable v-expense-bank      as decimal   no-undo .
define variable v-expense-ras       as decimal   no-undo .
define variable v-expense-other     as decimal   no-undo .
define variable v-ost-end           as decimal   no-undo .
define variable v-ost-end-ras       as decimal   no-undo .
define variable v-sheet             as integer   no-undo .
define variable v-obj-name          as character no-undo .
define variable v-obj-type1         as character no-undo .
define variable v-obj-code1         as integer   no-undo .
define variable v-num-obj           as integer   no-undo .

define variable v-col1              as decimal   no-undo .
define variable v-col2              as decimal   no-undo .
define variable v-col3              as decimal   no-undo .
define variable v-col45             as decimal   no-undo .
define variable v-col4              as decimal   no-undo .
define variable v-col5              as decimal   no-undo .
define variable v-col6              as decimal   no-undo .
define variable v-col7              as decimal   no-undo .
define variable v-col31             as decimal   no-undo .
define variable v-col41             as decimal   no-undo .

define variable v-col1-propis       as character no-undo .
define variable v-col3-propis       as character no-undo .
define variable v-col45-propis      as character no-undo .
define variable v-col4-propis       as character no-undo .
define variable v-col5-propis       as character no-undo .
define variable v-col6-propis       as character no-undo .
define variable v-col7-propis       as character no-undo .
define variable abbr                as character no-undo .

define variable v-ost-begin-all     as decimal   no-undo .
define variable v-income-realiz-all as decimal   no-undo .
define variable v-income-ras-all    as decimal   no-undo .
define variable v-income-other-all  as decimal   no-undo .
define variable v-expense-bank-all  as decimal   no-undo .
define variable v-expense-ras-all   as decimal   no-undo .
define variable v-expense-other-all as decimal   no-undo .
define variable v-ost-end-all       as decimal   no-undo .
define variable v-ost-end-ras-all   as decimal   no-undo .

define variable x-store-code        like ub.clients.obj-code no-undo .
define variable x-store-type        like ub.clients.obj-type no-undo .

define variable Fact-order-1        like ub.stk-tot.Fact-order no-undo .
define variable Fact-order-2        like ub.stk-tot.Fact-order no-undo .

define variable v-obj-type          as character no-undo .
define variable v-obj-code          as integer   no-undo init -1.

define variable Counter1            as integer   no-undo .
define variable v-date-name         as character no-undo .
define variable v-shift-on          as logical   no-undo .
define variable v-sheet-num         as integer   no-undo .

define variable v-user-action       as character no-undo .
define variable v-printed           as logical   no-undo .
define variable disabledoptions     as integer   no-undo .
define variable v-orient-page       as character no-undo .
define variable v-file-name         as character no-undo .
define variable v-file-name-ind     as integer   no-undo .
define variable v-line              as character no-undo .
define variable v-underline         as character no-undo .
define variable v-fio-sign          as character no-undo .
define variable v-par-type          as character no-undo .
define variable v-cashbook          as character no-undo .
define variable v-cashbookid        as integer   no-undo .
define variable v-shift-date        as date      no-undo .
define variable v-shift-num         like ub.shift-obj.shift-name no-undo .
define variable v-shift-name        like ub.shift-obj.shift-name no-undo .
define variable v-curr-time         as character no-undo .

define stream  macr_excel .
define stream  out-stream .
define stream OutStr-html .
define variable v-file-name-rep-htm as character no-undo .
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnc-cur-time-print Dialog-Frame 
FUNCTION fnc-cur-time-print returns character FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
run get-report-num (output p-report-id).
    
v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".  

v-curr-time = fnc-cur-time-print().
      
for each obj-list by obj-list.obj-name :
    if v-obj-code = -1 then 
    do:
        assign
            v-obj-type = obj-list.obj-type
            v-obj-code = obj-list.obj-code.
    end.
    else 
    do:
        assign
            v-obj-type = ''
            v-obj-code = 0
            .
    end.

    assign
        v-shift-on = yes
        .
if p-det-oper and obj-list.db-num = g#db-num then do:        
/*Проверка на закрытую смены*/

for first ub.shift-obj no-lock where ub.shift-obj.obj-code = obj-list.obj-code and 
                                     ub.shift-obj.obj-type = obj-list.obj-type and
                                     ub.shift-obj.status_ = {&sht-closed} and
                                     ub.shift-obj.shift-date = iParam:X-date-end and
                                     ub.shift-obj.shift-num = iParam:X-shift-end:
                                        
           &scop my-message substitute("&1Оперативный отчет снимается ТОЛЬКО за открытую смену" + ~
                                       ~{&new-line~} ~
                                       , return-value   ~
                                       ,error-status:get-message(1) )
         {&display-message}. 
         
         undo, return error .                                      

end.  
/*докачать все чеки*/

    { gbl/curshift.i obj-list.obj-type obj-list.obj-code v-shift-date v-shift-num v-shift-name no-error }
   if error-status:error then 
   do:
   /*      undo, return error substitute("&1 &2 &3&4Не удалось определить дату и время текущей смены&4&5&4&6"*/
   /*                                   ,vss-workfile                                                        */
   /*                                   ,vss-revision                                                        */
   /*                                   ,vss-description                                                     */
   /*                                   , error-status:get-message(1)                                        */
   /*                                   , return-value ).                                                    */
   end.
   else 
   do:
      run str/diallog.w (  input parparentproc
         , input this-procedure
         , input 'str/get-chkf.p':U
         , input (obj-list.obj-type + {&delim-par} + string(obj-list.obj-code) + {&delim-par} +
         string(0)  + {&delim-par} + string(0) + {&delim-par} + string(- 1) + {&delim-par} +
         string(v-shift-num) + {&delim-par} + replace(string(v-shift-date, "99/99/9999"), {&slash-char} , "":U)
         )
         , input no /*p-auto-go*/
         , input '':U
         , input 'Прием чеков с касс') no-error .
    
    
      IF error-status:error then 
      do:
         return error "Ошибка при получении чеков с касс".
      end.
      run rep/rpychk0.p ( input "r-shft3f"
         ,input obj-list.obj-type
         ,input obj-list.obj-code
         ,input ? /*p-date-from*/
         ,input ? /*p-date-to*/
         ,input v-shift-date /*p-shift-date-from*/
         ,input v-shift-date /*p-shift-date-to*/
         ,input 1 /*p-shift-num-start*/
         ,input 99 /*p-shift-num-end*/
         ,input ? /*p-inkas-code*/
         ) no-error.
      if error-status:error then 
      do:
         message error-status:get-message(1) view-as alert-box.
      end.
   end.
end.        
    if iparam:x-tog-shift then 
    do :
    { gbl/objat.i
        obj-list.obj-type
        obj-list.obj-code
        "'shift-on=request'"
        v-shift-on
        no-error
        }
        if error-status :error
            then 
        do:
           &scop my-message substitute("&1 &2 &3&4" +  ~
                                       "Невозможно определить тип сменный/не сменный&4" + ~
                                       "для заданного объекта.&4" + ~
                                       "Объект: &5&6&4&7&4&8"  ~
                                       ,vss-workfile  ~
                                       ,vss-revision  ~
                                       ,vss-description ~
                                       ,~{&new-line~} ~
                                       ,obj-list.obj-type  ~
                                       ,obj-list.obj-code ~
                                       , return-value   ~
                                       ,error-status:get-message(1) )
            {&display-message}.
            undo, return error .
        end.
        if v-shift-on = no
            then 
        do:
          &scop my-message substitute("Неверно задан тип объекта &1&2&3"  + ~
                                      "Объект не сменный." ~
                                      ,obj-list.obj-type ~
                                      ,obj-list.obj-code ~
                                      , ~{&new-line~} )
            {&display-message}.
        end.
    end.
    if v-shift-on or iparam:x-tog-shift = no then 
        if v-obj-name <> "" then 
        do :
            assign
                v-obj-name = v-obj-name + ", " + obj-list.obj-name
                .
        end.
        else 
        do :
            assign
                v-obj-name = obj-list.obj-name
                .
        end.
    end.

{ gbl/working.i }

assign  
  Counter1 = 0 .
{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */

/* собирание данных */

find first buf_clients
  where buf_clients.obj-type = {&cmp}
  and   buf_clients.obj-code = v-cntxt-host-code-obj
  no-lock
  .
assign 
  v-firm = buf_clients.obj-name  .

for each   temp-fin-doc :
  delete temp-fin-doc .
end .

assign
  v-ost-begin = 0
  .
  
  
run report-exec in this-procedure .

if iParam:x-TOG-Shift then do:
   if iParam:x-Shift-Alone = 1 then v-date-name = "По смене: №" +  string(iParam:x-Shift-Start) + " " + string(iParam:x-Date-Start,"99.99.9999").
   else v-date-name = "За смены: c №" +  string (iParam:x-Shift-Start) + " " + string (iParam:x-Date-Start,"99.99.9999") + " по №" + string (iParam:x-Shift-End) + " " + string (iParam:x-Date-End,"99.99.9999").
end.
else v-date-name = "За период с " +  string (iParam:x-Date-Start) + " по " + string (iParam:x-Date-End).


if is-rosneft then 
do: 
  assign
    temp-fin-doc.income-realiZ = temp-fin-doc.income-realiZ + temp-fin-doc.income-other
    temp-fin-doc.income-other  = 0
    . 
end.       
        
/*печатать шапку*/
run get-report-num (output p-report-id).
    
v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   


output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
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
        .


     put stream OutStr-html unformatted
        '<body>' skip
        /*Первая таблица*/
        .
put stream OutStr-html unformatted
    '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
	'<td style="width: 100px;"></td>' skip
    '</tr>' skip
    .
if p-det-oper then do:
put stream OutStr-html unformatted

        '<tr>' skip
        '<td colspan="9" style="font-size:16px;font-weight:bold; text-align: center;">Оперативный отчет о движении денежных средств</td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="9" style="text-align: center;"> За период с ' + string(iparam:x-Date-Start) + ' по ' + string(iparam:x-Date-End) + '</td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="9">' + v-curr-time + '</td>' skip
        '</tr>' skip
.
end.
else do:
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="9" style="font-weight: bold;">ДВИЖЕНИЕ ДЕНЕЖНЫХ СРЕДСТВ</td>' skip
    '</tr>' skip
    '<tr>' skip
    '<td colspan="9" style="font-weight: bold;"> За период с ' + string(iparam:x-Date-Start) + ' по ' + string(iparam:x-Date-End) + '</td>' skip
    '</tr>' skip    
 	'<tr>' skip
    '<td colspan="9">' + v-curr-time + '</td>' skip
    '</tr>' skip
    .
end.
put stream OutStr-html unformatted
        '</thead>' skip .

    put stream OutStr-html unformatted
        '<thead>' skip
       
        .        
if not p-det-obj then do:               
     put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="9">' + v-obj-name + '</td>' skip
        '</tr>' skip
        .
end.        
    put stream OutStr-html unformatted
        '</thead>' skip
        '<tbody>' skip
        
        . 
if p-det-oper then do:
        put stream OutStr-html unformatted
            '<TR>' skip
            '<th rowspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Кассовая книга</th>' skip
            '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Остаток денежных средств на начало смены</TD>' skip
            '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Приход</TD>' skip
            '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Расход</TD>' skip
            '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Остаток денежных средств на конец смены</TD>' skip
            '</TR>'skip       
            '<TR>' skip
            '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Фактический</TD>' skip            
            '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Фактический</TD>' skip
            '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Расчетный</TD>' skip
            '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Фактический</TD>' skip
            '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Расчетный</TD>' skip
            '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Фактический</TD>' skip
            '<TD text_wrap="true" style="text-align: center; font-weight: bold; background-color: silver;">Расчетный</TD>' skip
            '</TR>'skip    
            '<tr>' skip
            '<td style="text-align: center;">1</td>' skip
            '<td colspan="2" style="text-align: center;">2</td>' skip
            '<td style="text-align: center;">3</td>' skip
            '<td style="text-align: center;">4</td>' skip
            '<td style="text-align: center;">5</td>' skip
            '<td style="text-align: center;">6</td>' skip
            '<td style="text-align: center;">7</td>' skip
            '<td style="text-align: center;">8</td>' skip
            '</tr>' skip
            .  
    for each buf_obj-list: 
if p-det-obj then do:       
   put stream OutStr-html unformatted
   '<tr>' skip
   '<TD text_wrap="true" colspan="9" style="text-align: left; font-weight: bold;">' + buf_obj-list.obj-name + '</TD>' skip
   '</tr>' skip
   .   
   end.
    for each temp-fin-doc where  temp-fin-doc.obj-code = buf_obj-list.obj-code and
        temp-fin-doc.obj-type = buf_obj-list.obj-type:
      put stream OutStr-html unformatted
        '<tr>' skip
                '<td num="#0.00" style="text-align: right;">' + string(temp-fin-doc.cashbook) + '</td>' skip
                '<TD colspan="2" text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.ost-begin),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.ost-begin),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.income-realiz),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.income-realiz),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.income-ras),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.income-ras),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.expense-bank),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.expense-bank),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.expense-ras),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.expense-ras),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.ost-end),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.ost-end),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.ost-end-ras),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(temp-fin-doc.ost-end-ras),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '</tr>' skip    
.
      ASSIGN
        v-col1 = v-col1 + temp-fin-doc.ost-begin 
        v-col2 = v-col2 + temp-fin-doc.income-realiz
        v-col3 = v-col3 + temp-fin-doc.income-ras
        v-col4 = v-col4 + temp-fin-doc.expense-bank
        v-col5 = v-col5 + temp-fin-doc.expense-ras
        v-col6 = v-col6 + temp-fin-doc.ost-end
        v-col7 = v-col7 + temp-fin-doc.ost-end-ras
        .
    end.
    put stream OutStr-html unformatted
        '<tr>' skip
            '<td num="#0.00" style="text-align: right; font-weight: bold;">Итого:</td>' skip
            '<TD colspan="2" text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(v-col1),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(v-col1),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(v-col2),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(v-col2),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(v-col3),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(v-col3),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(v-col4),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(v-col4),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(v-col5),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(v-col5),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(v-col6),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(v-col6),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(v-col7),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(v-col7),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '</tr>' skip      
.    
end.
end.
else do:
put stream OutStr-html unformatted
        '<tr>' skip
        '<th rowspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Кассовая книга</th>' skip
        '<th rowspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Остаток денежных средств на начало смены</th>' skip
        '<th rowspan="2" style="text-align: center; font-weight: bold; background-color: silver;">в т.ч. кассовый фонд</th>' skip
        '<th colspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Приход</th>' skip
        '<th colspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Расход</th>' skip
        '<th rowspan="2" style="text-align: center; font-weight: bold; background-color: silver;">Остаток денежных средств на конец смены</th>' skip
        '<th rowspan="2" style="text-align: center; font-weight: bold; background-color: silver;">в т.ч. кассовый фонд</th>' skip                
        '</tr>' skip
        '<tr>' skip
        '<th style="text-align: center; font-weight: bold; background-color: silver;">Реализация</th>' skip
        '<th style="text-align: center; font-weight: bold; background-color: silver;">Прочее</th>' skip
        '<th style="text-align: center; font-weight: bold; background-color: silver;">Инкассация в банк</th>' skip
        '<th style="text-align: center; font-weight: bold; background-color: silver;">Другие</th>' skip
        '</tr>' skip
        '<tr>' skip
        '<th style="text-align: center;">5.1</th>' skip
        '<th style="text-align: center;">5.2</th>' skip
        '<th style="text-align: center;">5.3</th>' skip
        '<th style="text-align: center;">5.4</th>' skip
        '<th style="text-align: center;">5.5</th>' skip
        '<th style="text-align: center;">5.6</th>' skip
        '<th style="text-align: center;">5.7</th>' skip      
        '<th style="text-align: center;">5.8</th>' skip
        '<th style="text-align: center;">5.9</th>' skip
        '</tr>' skip
        .
    for each buf_obj-list:
if p-det-obj then do:        
   put stream OutStr-html unformatted
   '<tr>' skip
   '<TD text_wrap="true" colspan="9" style="text-align: left; font-weight: bold;">' + buf_obj-list.obj-name + '</TD>' skip
   '</tr>' skip
   .   
end.   
    for each temp-fin-doc where  temp-fin-doc.obj-code = buf_obj-list.obj-code and
        temp-fin-doc.obj-type = buf_obj-list.obj-type:
      put stream OutStr-html unformatted
        '<tr>' skip
                '<td num="#0.00" style="text-align: right;">' + string(temp-fin-doc.cashbook) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(temp-fin-doc.ost-begin) + '</td>' skip
                '<td num="#0.00" style="text-align: right;"></td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(temp-fin-doc.income-realiZ) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(temp-fin-doc.income-other) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(temp-fin-doc.expense-bank) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(temp-fin-doc.expense-other) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(temp-fin-doc.ost-end) + '</td>' skip
                '<td num="#0.00" style="text-align: right;"></td>' skip
            '</tr>' skip    
.
      ASSIGN
        v-col1  = v-col1 + temp-fin-doc.ost-begin 
        v-col3  = v-col3 + (temp-fin-doc.income-realiZ + temp-fin-doc.income-other) 
        v-col45 = v-col45 + (temp-fin-doc.expense-bank + temp-fin-doc.expense-other) 
        v-col4  = v-col4 + temp-fin-doc.expense-bank
        v-col5  = v-col5 + temp-fin-doc.expense-other
        v-col6  = v-col6 + temp-fin-doc.ost-end
        v-col31 = v-col31 + temp-fin-doc.income-realiz
        v-col41 = v-col41 + temp-fin-doc.income-other
        .
      
    end.
    put stream OutStr-html unformatted
      '<tr>' skip
                '<td num="#0.00" style="text-align: right;">Итого:</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(v-col1) + '</td>' skip
                '<td num="#0.00" style="text-align: right;"></td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(v-col31) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(v-col41) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(v-col4) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(v-col5) + '</td>' skip
                '<td num="#0.00" style="text-align: right;">' + string(v-col6) + '</td>' skip
                '<td num="#0.00" style="text-align: right;"></td>' skip
            '</tr>' skip    
.       
end. 
end. 

    /*Подвал*/
    run rep/wp-rub.p ( input (v-col1), output v-col1-propis,  output abbr ).
    run rep/wp-rub.p ( input (v-col3), output v-col3-propis,  output abbr ).
    run rep/wp-rub.p ( input (v-col45), output v-col45-propis, output abbr ).
    run rep/wp-rub.p ( input (v-col4), output v-col4-propis,  output abbr ).
    run rep/wp-rub.p ( input (v-col5), output v-col5-propis,  output abbr ).
    run rep/wp-rub.p ( input (v-col6), output v-col6-propis,  output abbr ).
    run rep/wp-rub.p ( input (v-col7), output v-col7-propis,  output abbr ).
    
if p-det-oper then do:
    put stream OutStr-html unformatted  
        '<tfoot>' skip
        .
    put stream OutStr-html unformatted
        '<TR>' skip
        '<TD colspan = "8" text_wrap="true" style=></TD>' skip
        '</TR>' skip
      
        '<TR>' skip
        '<TD text_wrap="true">Остаток фактический:</TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true" colspan="5" style="border-bottom: 1px solid black;">' + string(v-col6-propis) + '</TD>' skip
        '</TR>' skip
        '<TR>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true" colspan="5" style="text-align: center;">(прописью)</TD>' skip
        '</TR>' skip
        .    
    put stream OutStr-html unformatted
        '<TR>' skip
        '<TD colspan = "8" text_wrap="true" style=></TD>' skip
        '</TR>' skip
      
        '<TR>' skip
        '<TD text_wrap="true">Остаток расчетный:</TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true" colspan="5" style="border-bottom: 1px solid black;">' + string(v-col7-propis) + '</TD>' skip
        '</TR>' skip
        '<TR>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true" colspan="5" style="text-align: center;">(прописью)</TD>' skip
        '</TR>' skip
        .            

    put stream OutStr-html unformatted
        '<TR>' skip
        '<TD colspan = "8" text_wrap="true"></TD>' skip
        '</TR>' skip
      
        '<TR>' skip
        '<TD text_wrap="true" colspan="2">Отчет составили:</TD>' skip
        '<TD text_wrap="true" colspan="2" style="border-bottom: 1px solid black;"></TD>' skip //' + string(temp-fin-doc.staff-curr1) + '
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true">Отчет приняли:</TD>' skip
        '<TD text_wrap="true" colspan="2" style="border-bottom: 1px solid black;"></TD>' skip //' + string(temp-fin-doc.staff-next1) + '
        '</TR>' skip
        '<TR>' skip
        '<TD text_wrap="true" colspan="2"></TD>' skip
        '<TD text_wrap="true" colspan="2" style="text-align: center;">Ф.И.О.   (подписи)</TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true"></TD>' skip
        '<TD text_wrap="true" colspan="2" style="text-align: center;">Ф.И.О.   (подписи)</TD>' skip
        '</TR>' skip
        .            
end.
else do:
    if is-rosneft then 
    do:
      put stream OutStr-html unformatted
        '<tfoot>' skip
       '<tr style="height:30px;">' skip
                '<td colspan="9"></td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="3" style="text-align: left;">Принято по смене</td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: left;">' + v-col1-propis + '</td>' skip
       '</tr>' skip               
       '<tr>' skip
                '<td colspan="4" style="text-align: left;"></td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>' skip
       '</tr>' skip     
       '<tr>' skip
                '<td colspan="3" style="text-align: left;">Выручка за смену</td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="6" style="text-align: left;">' + v-col3-propis + '</td>' skip
       '</tr>' skip  
       '<tr>' skip
                '<td colspan="4" style="text-align: left;"></td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>' skip
       '</tr>' skip     
       '<tr>' skip
                '<td colspan="3" style="text-align: left;">Сдано: в банк</td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="6" style="text-align: left;">' + v-col45-propis + '</td>' skip
       '</tr>' skip  
       '<tr>' skip
                '<td colspan="4" style="text-align: left;"></td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>' skip
       '</tr>' skip     
       '<tr>' skip
                '<td colspan="3" style="text-align: left;">Сдано: в офис</td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: left;">' + v-col4-propis + '</td>' skip
       '</tr>' skip  
       '<tr>' skip
                '<td colspan="4" style="text-align: left;"></td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>' skip
       '</tr>' skip     
       '<tr>' skip
                '<td colspan="3" style="text-align: left;">Итого инкассировано</td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: left;">' + v-col5-propis + '</td>' skip
       '</tr>' skip                                
       '<tr>' skip
                '<td colspan="4" style="text-align: left;"></td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>' skip
       '</tr>' skip     
       '<tr>' skip
                '<td colspan="3" style="text-align: left;">Передано по смене: наличных денег</td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: left;">' + v-col6-propis + '</td>' skip
       '</tr>' skip     
       '<tr>' skip
                '<td colspan="4" style="text-align: left;"></td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>' skip
       '</tr>' skip     
.
      put stream OutStr-html unformatted                                                                     
                  '<tr> <!--Подвал-->' skip
                    '<td colspan="9"></td>' skip
                  '</tr>' skip
                    '<tr>' skip 
                    '<td colspan="3" style="height:30px;"> Отчет составил и смену сдал:</td>' skip
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip   // temp-fin-doc.staff-curr1
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip /// temp-fin-doc.staff-curr1
                  '</tr>' skip
                  '<tr>' skip 
                    '<td colspan="3"></td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px; text-align: center;">должность</td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px; text-align: center;">подпись</td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px; text-align: center;">расшифровка подписи</td>' skip
                  '</tr>' skip
                    '<tr>' skip 
                    '<td colspan="3" style="height:30px;"> Смену принял:</td>' skip
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip    // temp-fin-doc.staff-curr2
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip  // temp-fin-doc.staff-next2
                  '</tr>' skip
                  '<tr>' skip 
                    '<td colspan="3"></td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px;  text-align: center;">должность</td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px;  text-align: center;">подпись</td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px; text-align: center;">расшифровка подписи</td>' skip
                  '</tr>' skip
                    '<tr>' skip
                    '<td colspan="3" style="height:30px;"> Отчет проверил:</td>' skip
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip
                    '<td></td>' skip
                    '<td style="border-bottom: 1px solid black; text-align: center;"></td>' skip
                  '</tr>' skip
                  '<tr>' skip 
                    '<td colspan="3"></td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px; text-align: center;">должность</td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px; text-align: center;">подпись</td>' skip
                    '<td></td>' skip
                    '<td style="font-size:10px; text-align: center;">расшифровка подписи</td>' skip
                  '</tr>' skip
                  '</tfoot>' skip
                  .
        /*            temp-fin-doc.staff-curr3 */
      
    end.
    else 
    do:
      put stream OutStr-html unformatted
        '<tfoot>' skip
       '<tr style="height:30px;">' skip
                '<td colspan="7"></td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="2" style="text-align: left;">Принято по смене</td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="4" style="text-align: left;">' + v-col1-propis + '</td>' skip
       '</tr>' skip  
       '<tr>' skip
                '<td colspan="2" style="text-align: left;"></td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="4" style="text-align: center; border-top: 1px solid black;">(прописью)</td>' skip
       '</tr>' skip                    
       '<tr>' skip
                '<td colspan="2" style="text-align: left;">Передано по смене: наличных денег</td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="4" style="text-align: left;">' + v-col6-propis + '</td>' skip
       '</tr>' skip
       '<tr>' skip
                '<td colspan="2" style="text-align: left;"></td>' skip
                '<td style="text-align: right;"></td>' skip
                '<td colspan="4" style="text-align: center; border-top: 1px solid black;">(прописью)</td>' skip
       '</tr>' skip     
.
      put stream OutStr-html unformatted                                                                     
                  '<tr>' skip //<!--Подвал-->
                    '<td colspan="8" style="height:30px;"></td>' skip
                  '</tr>' skip
                    '<tr>' skip 
                    '<td colspan="8" style="height:30px;"> СМЕНУ СДАЛ:  __________________</td>' skip //temp-fin-doc.staff-curr1
                  '</tr>' skip
                  '<tr>' skip 
                    '<td colspan="8"> СМЕНУ ПРИНЯЛ: </td>' skip
                  '</tr>' skip
            '</tfoot>' skip
.          
    end.    
end.
    put stream OutStr-html unformatted                                                                     
        '</tbody>' skip
        '</table>' skip
        '</body>' skip
        '</html>' skip
.                                                                                                    
    output stream OutStr-html close.

run prn-lib-reportviewer-report-name in this-procedure (
  input parParentProc
  ,input v-file-name-rep-htm
  ).
         
procedure report-exec :

    for each buf_obj-list no-lock :
      { gbl/hostcode.i buf_obj-list.obj-type buf_obj-list.obj-code v-host-code }

            if p-det-oper then 
            do:
               find first buf_cash-pay no-lock where buf_cash-pay.is-cash = true no-error .
               if available (buf_cash-pay) then v-cash = buf_cash-pay.cdpay-code .
               
                  for each buf_chk-doc no-lock where buf_chk-doc.obj-code = buf_obj-list.obj-code and
                     buf_chk-doc.obj-type = buf_obj-list.obj-type and
                     buf_chk-doc.shift-date = v-shift-date and
                     buf_chk-doc.shift-name = string(v-shift-name) and
                     buf_chk-doc.shift-num = integer(v-shift-num):   /*Не обязательно неучтенные - все чеки берем. считаем, что по чекам нет ПКО*/
                        
                     for each buf_chk-gds-pay no-lock where buf_chk-gds-pay.doc-code = buf_chk-doc.doc-code and buf_chk-gds-pay.pay-code = v-cash:
                        find first buf_goods-attr where buf_goods-attr.gds-code = buf_chk-gds-pay.gds-code
                                    and buf_goods-attr.attr-code = "cash-book-id" no-lock no-error.
                        /*                        if (available  buf_goods-attr  and buf_goods-attr.attr-value = string(buf_cashbook.id)) /* Если есть книга и она равна той, по которой сейчас цикл, то считаем*/*/
                        /*                               or (not available buf_goods-attr  and  buf_cashbook.id = 0) then  /* или если книги нет и сейчас нулевая, то считаем*/                                   */
                        /*                        do:      
                                                                                                                                                                                  */
                        if available (buf_goods-attr) then 
                        do:
                           find first temp-fin-doc where  temp-fin-doc.obj-code = buf_obj-list.obj-code and
                              temp-fin-doc.obj-type = buf_obj-list.obj-type and
                              temp-fin-doc.cashbookid = integer(buf_goods-attr.attr-value) no-error .
                           if not available (temp-fin-doc) then 
                           do:
                              create temp-fin-doc.
                              assign
                                 temp-fin-doc.obj-code   = buf_obj-list.obj-code
                                 temp-fin-doc.obj-type   = buf_obj-list.obj-type
                                 temp-fin-doc.obj-name   = buf_obj-list.obj-name
                                 temp-fin-doc.cashbookid = integer(buf_goods-attr.attr-value)
                                 .
                           end.
                        end.
                        else 
                        do:
                           find first temp-fin-doc where  temp-fin-doc.obj-code = buf_obj-list.obj-code and
                              temp-fin-doc.obj-type = buf_obj-list.obj-type and
                              temp-fin-doc.cashbookid = 0 no-error .
                           if not available (temp-fin-doc) then 
                           do:
                              create temp-fin-doc.
                              assign
                                 temp-fin-doc.obj-code   = buf_obj-list.obj-code
                                 temp-fin-doc.obj-type   = buf_obj-list.obj-type
                                 temp-fin-doc.obj-name   = buf_obj-list.obj-name
                                 temp-fin-doc.cashbookid = 0
                                 .
                           end.                        
                        end.   
                            if buf_chk-doc.chk-type = integer({&rcpt-sale}) then
                            do:
                                assign
                                   temp-fin-doc.income-ras = temp-fin-doc.income-ras + buf_chk-gds-pay.tot-r-b .         /* Все продажи кладем в приход */                                                
                            end. /*if buf_chk-doc.chk-type = integer({&rcpt-sale}) then*/
                            else if buf_chk-doc.chk-type = integer({&rcpt-return}) or buf_chk-doc.chk-type = integer({&rcpt-return-write-off}) then
                            do:                                                                                                                                     
                                /* Определим расход это или возврат */
                                  find first chk-gds-attr where ub.chk-gds-attr.doc-code = buf_chk-gds-pay.doc-code
                                                    and ub.chk-gds-attr.line-num = buf_chk-gds-pay.line-num
                                                    and ub.chk-gds-attr.attr-code = "cstype"
                                  no-lock no-error.
                                  
                                  if available chk-gds-attr and integer (chk-gds-attr.attr-value) eq 37 then do:

                                     temp-fin-doc.expense-ras   = temp-fin-doc.expense-ras  - buf_chk-gds-pay.tot-r-b .   /* Расход */
                                  end.     
                                  else
                                  assign
                                      temp-fin-doc.income-ras = temp-fin-doc.income-ras + buf_chk-gds-pay.tot-r-b .   /* Возврат, поэтому уменьшаем приход */
                            end.
/*                        end.*/
                     end. /* chk-gds-pay */

                  end. /*for each buf_chk-doc no-lock where buf_chk-doc.obj-code = buf_shift-obj.obj-code and*/
            end.       /*if p-det-oper then*/

      
      find first ub.cashbook no-lock where ub.cashbook.Status_ = 0 no-error .
      if not available (ub.cashbook) then
      do:
         assign
            v-ost-begin         = 0
            v-ost-begin-all     = 0
            v-income-realiZ-all = 0
            v-income-other-all  = 0
            v-expense-bank-all  = 0
            v-expense-other-all = 0
            v-ost-end-all       = 0
            v-income-ras-all    = 0
            v-expense-ras-all   = 0
            v-ost-end-ras-all   = 0
            .

         assign
            fact-order-1    = 0
            fact-order-2    = 0
            v-ost-begin     = 0
            v-income-realiZ = 0
            v-income-ras    = 0
            v-income-other  = 0
            v-expense-bank  = 0
            v-expense-ras   = 0
            v-expense-other = 0
            v-ost-end       = 0
            v-ost-end-ras   = 0
            .
         run fostatok in this-procedure (
            input   v-host-code
            ,input   buf_obj-list.obj-code
            ,input   buf_obj-list.obj-type
            ,input   iparam:x-tog-shift
            ,input   iparam:x-date-start - 1
            ,input   date('')
            ,input   iparam:x-shift-start
            ,input   iparam:X-shift-end
            ,input   yes /*xTog-obj*/
            ,input   0 /*p-curr-code*/
            ,input   0
            ,output  v-sum-begin
            ,output  Fact-order-1)
            no-error .
         run fostatok in this-procedure (
            input   v-host-code
            ,input   buf_obj-list.obj-code
            ,input   buf_obj-list.obj-type
            ,input   iparam:x-tog-shift
            ,input   iparam:x-date-end
            ,input   iparam:x-date-end
            ,input   iparam:X-shift-end
            ,input   iparam:X-shift-end
            ,input   yes /*xTog-obj*/
            ,input   0 /*p-curr-code*/
            ,input   0
            ,output  sum1
            ,output  Fact-order-2)
            no-error .

         for each buf_arh-fin-doc-schet-nal-obj no-lock
            where buf_arh-fin-doc-schet-nal-obj.host-code         = v-host-code
            and buf_arh-fin-doc-schet-nal-obj.obj-type          = buf_obj-list.obj-type
            and buf_arh-fin-doc-schet-nal-obj.obj-code          = buf_obj-list.obj-code
            and buf_arh-fin-doc-schet-nal-obj.cli-type          = {&cmp}
            and buf_arh-fin-doc-schet-nal-obj.cli-code          = v-host-code
            and buf_arh-fin-doc-schet-nal-obj.fin-code-acc      = 0
            and buf_arh-fin-doc-schet-nal-obj.cashbookid        = 0
            and buf_arh-fin-doc-schet-nal-obj.curr-code         = 0
            and buf_arh-fin-doc-schet-nal-obj.fin-ext-doc-type  = "":U
            and buf_arh-fin-doc-schet-nal-obj.calc-curr-code    = 0
            and buf_arh-fin-doc-schet-nal-obj.sum-type          = (if iparam:x-tog-shift then {&arh-fin-doc-schet-nal-obj-shift-obj} else {&arh-fin-doc-schet-nal-obj-obj} )
            and buf_arh-fin-doc-schet-nal-obj.fact-order       > fact-order-1
            and buf_arh-fin-doc-schet-nal-obj.fact-order       <= fact-order-2
            :
            find first buf_fin-doc
               where buf_fin-doc.host-code         = v-host-code
               and buf_fin-doc.fin-doc-code      = buf_arh-fin-doc-schet-nal-obj.fin-doc-code
               and buf_fin-doc.CashBookId        = buf_arh-fin-doc-schet-nal-obj.cashbookid
               and buf_fin-doc.obj-type          = buf_obj-list.obj-type
               and buf_fin-doc.obj-code          = buf_obj-list.obj-code
               and buf_fin-doc.status_           = {&fact}
               and (buf_fin-doc.fin-ext-doc-type = {&income-cash}
               or buf_fin-doc.fin-ext-doc-type   = {&expense-cash} )
               no-error.
            if available buf_fin-doc then
            do :
             &scop fin-doc-obj-type buf_fin-doc.obj-type
             &scop fin-doc-obj-code buf_fin-doc.obj-code
               if buf_fin-doc.trn-doc-code = {&fin-doc-cash-book-name} then
               do:
                  assign
                     Counter1 = Counter1 + 1.
                  { rep/repfrm.i disp Counter1 }
                  if buf_fin-doc.fin-ext-doc-type = {&income-cash} then
                  do :
                     find first buf_sysconf no-lock
                        where buf_sysconf.host-code = v-host-code
                        no-error.
                     if available buf_sysconf
                        and buf_fin-doc.payer-type = buf_sysconf.sale-type
                        and buf_fin-doc.payer-code = buf_sysconf.sale-code
                        then
                     do:   /*контрагент-реализация*/
                        assign
                           v-income-realiZ = v-income-realiZ + buf_fin-doc.sum-doc
                           v-income-ras    = v-income-ras + buf_fin-doc.sum-doc
                           .
                     end.
                      else do:
                        find first ub.CashBook no-lock where ub.CashBook.cli-code = buf_fin-doc.payer-code
                        and ub.CashBook.cli-type = buf_fin-doc.payer-type no-error .
                        if available (ub.CashBook) then do:
                        assign
                          v-income-realiZ = v-income-realiZ + buf_fin-doc.sum-doc
                        .
                        end.
                        else do:  
                        find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = buf_fin-doc.CashBookId and
                        ub.CashBookRule.Code = "Avanscli-code" and ub.CashBookRule.RuleValue = string(buf_fin-doc.payer-code) no-error .
                        if available (ub.CashBookRule) and buf_fin-doc.payer-type = {&cmp} then do:
                        assign
                          v-income-realiZ = v-income-realiZ + buf_fin-doc.sum-doc
                        .
                        end.
                        else do:                         
                        assign
                          v-income-other = v-income-other + buf_fin-doc.sum-doc
                        .
                        end.
                        end.
                      end.
                  end.
                  else
                  do :
                     find first buf_clients-attr
                        where buf_clients-attr.obj-type  = buf_fin-doc.receiver-type
                        and buf_clients-attr.obj-code  = buf_fin-doc.receiver-code
                        and buf_clients-attr.attr-code = {&attr-is-inkassator}
                        and buf_clients-attr.attr-value = "yes"
                        use-index pi no-error.
                     if available buf_clients-attr then
                     do :
                        assign
                           v-expense-bank = v-expense-bank + buf_fin-doc.sum-doc
                           .
                     end.
                     else
                     do :
                        if p-det-oper then v-expense-bank = v-expense-bank + buf_fin-doc.sum-doc .
                        assign
                           v-expense-other = v-expense-other + buf_fin-doc.sum-doc
                           .
                     end.
                  end.
               end.
            end. /*if available buf_fin-doc then do :*/
         end. /*for each buf_arh-fin-doc-schet-nal-obj no-lock*/
         assign
            v-ost-begin = v-ost-begin + v-sum-begin
            .
            find first temp-fin-doc where  temp-fin-doc.obj-code = buf_obj-list.obj-code and
               temp-fin-doc.obj-type = buf_obj-list.obj-type and
               temp-fin-doc.cashbookid = 0 no-error .
            if not available (temp-fin-doc) then
            do:
               create temp-fin-doc.
               assign
                  temp-fin-doc.obj-code   = buf_obj-list.obj-code
                  temp-fin-doc.obj-type   = buf_obj-list.obj-type
                  temp-fin-doc.obj-name   = buf_obj-list.obj-name
                  temp-fin-doc.cashbookid = 0
                  .
            end.
               assign
                  temp-fin-doc.cashbook      = "Основная деятельность"
                  temp-fin-doc.ost-begin     = temp-fin-doc.ost-begin + v-ost-begin
                  temp-fin-doc.income-realiZ = temp-fin-doc.income-realiZ + v-income-realiZ
                  temp-fin-doc.income-other  = temp-fin-doc.income-other + v-income-other
                  temp-fin-doc.income-ras    = temp-fin-doc.income-ras + v-income-ras
                  temp-fin-doc.expense-bank  = temp-fin-doc.expense-bank + v-expense-bank
                  temp-fin-doc.expense-other = temp-fin-doc.expense-other + v-expense-other
                  temp-fin-doc.expense-ras   = temp-fin-doc.expense-ras + v-expense-ras
                  temp-fin-doc.ost-end-ras   = temp-fin-doc.ost-end-ras + (temp-fin-doc.ost-begin + temp-fin-doc.income-ras - temp-fin-doc.expense-ras)
                  .
if p-det-oper then temp-fin-doc.ost-end       = temp-fin-doc.ost-end + (temp-fin-doc.ost-begin + temp-fin-doc.income-realiZ - temp-fin-doc.expense-bank) .
else temp-fin-doc.ost-end       = temp-fin-doc.ost-end + (temp-fin-doc.ost-begin + ( temp-fin-doc.income-realiZ + temp-fin-doc.income-other ) - ( temp-fin-doc.expense-bank + temp-fin-doc.expense-other )) .
         end. /*   if not available (ub.cashbook) */

         for each buf_cashbook no-lock where buf_cashbook.Status_ = 0:
  
         assign
            v-ost-begin         = 0
            v-ost-begin-all     = 0
            v-income-realiZ-all = 0
            v-income-other-all  = 0
            v-expense-bank-all  = 0
            v-expense-other-all = 0
            v-ost-end-all       = 0
            v-income-ras-all    = 0
            v-expense-ras-all   = 0
            v-ost-end-ras-all   = 0
            .

         assign
            fact-order-1    = 0
            fact-order-2    = 0
            v-ost-begin     = 0
            v-income-realiZ = 0
            v-income-ras    = 0
            v-income-other  = 0
            v-expense-bank  = 0
            v-expense-ras   = 0
            v-expense-other = 0
            v-ost-end       = 0
            v-ost-end-ras   = 0
            .
            run fostatok in this-procedure (
               input   v-host-code
               ,input   buf_obj-list.obj-code
               ,input   buf_obj-list.obj-type
               ,input   iparam:x-tog-shift
               ,input   iparam:x-date-start - 1
               ,input   date('')
               ,input   iparam:x-shift-start
               ,input   iparam:X-shift-end
               ,input   yes /*xTog-obj*/
               ,input   0 /*p-curr-code*/
               ,input   buf_cashbook.id
               ,output  v-sum-begin
               ,output  Fact-order-1)
               no-error .
            run fostatok in this-procedure (
               input   v-host-code
               ,input   buf_obj-list.obj-code
               ,input   buf_obj-list.obj-type
               ,input   iparam:x-tog-shift
               ,input   iparam:x-date-end
               ,input   iparam:x-date-end
               ,input   iparam:X-shift-end
               ,input   iparam:X-shift-end
               ,input   yes /*xTog-obj*/
               ,input   0 /*p-curr-code*/
               ,input   buf_cashbook.id
               ,output  sum1
               ,output  Fact-order-2)
               no-error .

            for each buf_arh-fin-doc-schet-nal-obj no-lock
               where buf_arh-fin-doc-schet-nal-obj.host-code         = v-host-code
               and buf_arh-fin-doc-schet-nal-obj.obj-type          = buf_obj-list.obj-type
               and buf_arh-fin-doc-schet-nal-obj.obj-code          = buf_obj-list.obj-code
               and buf_arh-fin-doc-schet-nal-obj.cli-type          = {&cmp}
               and buf_arh-fin-doc-schet-nal-obj.cli-code          = v-host-code
               and buf_arh-fin-doc-schet-nal-obj.fin-code-acc      = 0
               and buf_arh-fin-doc-schet-nal-obj.cashbookid        = buf_cashbook.id
               and buf_arh-fin-doc-schet-nal-obj.curr-code         = 0
               and buf_arh-fin-doc-schet-nal-obj.fin-ext-doc-type  = "":U
               and buf_arh-fin-doc-schet-nal-obj.calc-curr-code    = 0
               and buf_arh-fin-doc-schet-nal-obj.sum-type          = (if iparam:x-tog-shift then {&arh-fin-doc-schet-nal-obj-shift-obj} else {&arh-fin-doc-schet-nal-obj-obj} )
               and buf_arh-fin-doc-schet-nal-obj.fact-order       > fact-order-1
               and buf_arh-fin-doc-schet-nal-obj.fact-order       <= fact-order-2
               :
               find first buf_fin-doc
                  where buf_fin-doc.host-code         = v-host-code
                  and buf_fin-doc.fin-doc-code      = buf_arh-fin-doc-schet-nal-obj.fin-doc-code
                  and buf_fin-doc.CashBookId        = buf_arh-fin-doc-schet-nal-obj.cashbookid
                  and buf_fin-doc.obj-type          = buf_obj-list.obj-type
                  and buf_fin-doc.obj-code          = buf_obj-list.obj-code
                  and buf_fin-doc.status_           = {&fact}
                  and (buf_fin-doc.fin-ext-doc-type = {&income-cash}
                  or buf_fin-doc.fin-ext-doc-type   = {&expense-cash} )
                  no-error.
               if available buf_fin-doc then 
               do :
             &scop fin-doc-obj-type buf_fin-doc.obj-type
             &scop fin-doc-obj-code buf_fin-doc.obj-code
                  if buf_fin-doc.trn-doc-code = {&fin-doc-cash-book-name} then 
                  do:
                     assign 
                        Counter1 = Counter1 + 1.
                { rep/repfrm.i disp Counter1 }
                     if buf_fin-doc.fin-ext-doc-type = {&income-cash} then 
                     do :
                        find first buf_sysconf no-lock
                           where buf_sysconf.host-code = v-host-code
                           no-error.
                        if available buf_sysconf
                           and buf_fin-doc.payer-type = buf_sysconf.sale-type
                           and buf_fin-doc.payer-code = buf_sysconf.sale-code
                           then 
                        do:   /*контрагент-реализация*/
                           assign
                              v-income-realiZ = v-income-realiZ + buf_fin-doc.sum-doc
                              v-income-ras    = v-income-ras + buf_fin-doc.sum-doc
                              .
                        end.
                      else do:
                        find first ub.CashBook no-lock where ub.CashBook.cli-code = buf_fin-doc.payer-code
                        and ub.CashBook.cli-type = buf_fin-doc.payer-type no-error .
                        if available (ub.CashBook) then do:
                        assign
                          v-income-realiZ = v-income-realiZ + buf_fin-doc.sum-doc
                        .
                        end.
                        else do:  
                        find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = buf_fin-doc.CashBookId and
                        ub.CashBookRule.Code = "Avanscli-code" and ub.CashBookRule.RuleValue = string(buf_fin-doc.payer-code) no-error .
                        if available (ub.CashBookRule) and buf_fin-doc.payer-type = {&cmp} then do:
                        assign
                          v-income-realiZ = v-income-realiZ + buf_fin-doc.sum-doc
                        .
                        end.
                        else do:                         
                        assign
                          v-income-other = v-income-other + buf_fin-doc.sum-doc
                        .
                        end.
                        end.
                      end.

                     end.              
                     else 
                     do :
                        find first buf_clients-attr
                           where buf_clients-attr.obj-type  = buf_fin-doc.receiver-type
                           and buf_clients-attr.obj-code  = buf_fin-doc.receiver-code
                           and buf_clients-attr.attr-code = {&attr-is-inkassator}
                           and buf_clients-attr.attr-value = "yes"
                           use-index pi no-error.
                        if available buf_clients-attr then 
                        do :
                           assign
                              v-expense-bank = v-expense-bank + buf_fin-doc.sum-doc
                              .
                        end.
                        else 
                        do :
                           if p-det-oper then v-expense-bank = v-expense-bank + buf_fin-doc.sum-doc .
                           assign
                              v-expense-other = v-expense-other + buf_fin-doc.sum-doc
                              .
                        end.
                        v-expense-ras = v-expense-ras + buf_fin-doc.sum-doc.
                     end.
                  end.
               end.
            end.
            assign
               v-ost-begin = v-ost-begin + v-sum-begin
               .
            
               find first temp-fin-doc where  temp-fin-doc.obj-code = buf_obj-list.obj-code and
                  temp-fin-doc.obj-type = buf_obj-list.obj-type and
                  temp-fin-doc.cashbookid = buf_cashbook.id no-error .
               if not available (temp-fin-doc) then 
               do:    
                  create temp-fin-doc.
                  assign
                     temp-fin-doc.obj-code   = buf_obj-list.obj-code
                     temp-fin-doc.obj-type   = buf_obj-list.obj-type
                     temp-fin-doc.obj-name   = buf_obj-list.obj-name
                     temp-fin-doc.cashbookid = buf_cashbook.id
                     .
                end.                                  
                  assign
                     temp-fin-doc.ost-begin     = temp-fin-doc.ost-begin + v-ost-begin
                     temp-fin-doc.income-realiZ = temp-fin-doc.income-realiZ + v-income-realiZ
                     temp-fin-doc.income-other  = temp-fin-doc.income-other + v-income-other
                     temp-fin-doc.income-ras    = temp-fin-doc.income-ras + v-income-ras
                     temp-fin-doc.expense-bank  = temp-fin-doc.expense-bank + v-expense-bank
                     temp-fin-doc.expense-other = temp-fin-doc.expense-other + v-expense-other
                     temp-fin-doc.expense-ras   = temp-fin-doc.expense-ras + v-expense-ras
                  temp-fin-doc.ost-end-ras   = temp-fin-doc.ost-end-ras + (temp-fin-doc.ost-begin + temp-fin-doc.income-ras - temp-fin-doc.expense-ras)
                     .  
               if p-det-oper then temp-fin-doc.ost-end       = temp-fin-doc.ost-end + (temp-fin-doc.ost-begin + temp-fin-doc.income-realiZ - temp-fin-doc.expense-bank) .
               else temp-fin-doc.ost-end       = temp-fin-doc.ost-end + (temp-fin-doc.ost-begin + ( temp-fin-doc.income-realiZ + temp-fin-doc.income-other ) - ( temp-fin-doc.expense-bank + temp-fin-doc.expense-other )) .
                     
                  if buf_cashbook.id = 0 then temp-fin-doc.cashbook       = "Основная деятельность" . 
                  else temp-fin-doc.cashbook = buf_cashbook.CashBookName .        
      end.
      end.
      end procedure . /*report-exec*/      

PROCEDURE get-report-num :

   define output parameter p-report-num as integer no-undo .

   do
      on error undo, return error return-value
      :
      run gbl/getrpnum.p (output p-report-num).
   end.

END PROCEDURE.
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-cur-time Dialog-Frame 
PROCEDURE proc-cur-time :
do on error undo, return error:

        define output parameter p-today as date no-undo.
        define output parameter p-time as integer no-undo.

        define variable v-date1 as date no-undo.
        define variable v-date2 as date no-undo.
        define variable v-time as integer no-undo.

        assign
          v-date1 = today
          v-time = time
          v-date2 = today
        .

        if v-date1 <> v-date2 then
            do:
                /* если вызов функции происходил в момент смены даты, */
                /* то необходимо сделать повторный запрос */
                assign
                    v-date1 = today
                    v-time  = v-time
                    v-date2 = today
                .
            end.

        assign
            p-today = v-date1
            p-time  = v-time
        .
    end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnc-cur-time-print Dialog-Frame 
FUNCTION fnc-cur-time-print returns character:

    /* возвращает текущую дату и время печати */
    /* длина строки 33 символа */

    define variable v-date as date no-undo.
    define variable v-time as integer no-undo.

    run proc-cur-time(output v-date, output v-time).

    return "Дата печати: " + string(v-date, "99.99.9999":U) + " " + string(v-time, "HH:MM":U).

end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME