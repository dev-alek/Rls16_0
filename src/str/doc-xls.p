block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: doc-xls.p $
$Archive: str/doc-xls.p $

экспорт списка документов в формате EXCEL

Автор: Чернова Светлана Александровна
Дата создания: 04/12/06
Author: Svetlana Chernova
Creation date: 04/12/06


*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: doc-xls.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/doc-xls.p $":U .
define variable vss-description as character no-undo initial "Экспорт списка товаров в формате EXCEL":U .

{ cmp/vssrevis.i }

{ cmp/str-glbl.i }


{ cmp/doc-list.i doc-list def  " shared " }
{ cmp/r-pril.i new }
&glob doc-list_name buf-doc-list

{ cmp/r-page1.i new }
define variable g#report-num as integer no-undo .
{ rep/opclexcl.i }
{ gbl/prtmpldf.i }
{ gbl/waitfram.i }
{ str/trdcalib.i }
{ gbl/lineattr.i }


define variable icolumn   as integer no-undo.
define variable ii as integer no-undo.
define variable vat-value like ub.doc-line.vat-pc no-undo .
define variable slt-value like ub.doc-line.slt-pc no-undo .
define variable v-rec as recid no-undo .
define variable jj as integer no-undo .
define variable jj-1 as integer no-undo .
define variable j-n as integer no-undo .
define variable f-value as character no-undo .
define variable f-value-1 as character no-undo .
define variable f-name as character no-undo .
define variable f-name-1 as character no-undo .
define variable f-n as character no-undo .
define variable v-length as integer no-undo .
define variable v-num-clmn as integer no-undo .
define variable v-bc-ne as integer no-undo .
define variable v-pbc-ne as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-f-name like ub.gds-prt.f-name no-undo .
define variable v-osn-frm as character no-undo .
define variable v-eng-frm as character no-undo .
define variable bar-code-field-handle as handle no-undo .
define variable prod-bc-field-handle as handle no-undo .
define variable v-recid_file as recid no-undo extent 3.

&scop table-list 'trn-doc,price-doc,inkas'



define buffer buf_filter for ubflt.filter.
{ gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }


FUNCTION get-function returns character(
input p-f-name as character,
input p-format as character) :

  do
  on error undo, return error
  :
    CASE p-f-name:
      when "iColumn":U then do:
        return string(iColumn, p-format).
      end.
      when "qnty":U then do:
        return string(doc-list.fact-num,  p-format).
      end.
    END CASE.

  end.

end FUNCTION. /* get-function */

run init-prn-template in this-procedure .
run gbl/prntput.p (c-point, output v-rec).
run gbl/prntmpl.w (
                input parparentproc
              , input "":U /*bttn*/
              , input c-point
              , input Tbl
              , input join-tbl
              , input Fld
              , input Lab
              , input Spr
              , input v-size
              , input v-format
              , input Dim
              , input-output v-rec
              , OUTPUT V-LENGTH
              , OUTPUT V-NUM-CLMN
            ).
if v-rec = ? then return.
find first ubflt.filter no-lock where
           recid(ubflt.filter) = v-rec no-error .
if not avail ubflt.filter then return.
/*получим значения из метасхемы*/
do ii = 1 to 3:
  find first _file no-lock where
            _file._file-name = entry(ii, {&table-list}).
  assign
  v-recid_file[ii] = recid(_file).
end.



/*перекодируем*/
do jj = 1 to num-entries(ubflt.filter.Fields-sort):
  assign
  f-name-1 = "":U
  .
  do jj-1 = 1 to num-entries(entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U):
    case entry(1, entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U), "."):
      when "trn-doc":U  then do:
        f-n = entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U)    .
      end.
      when "doc-attr":U then do:
        assign
        f-n = entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U)
        .
      end.
      when "function":U then do:
        assign
        f-n = entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U)
        .
      end.
    END CASE.
    assign
    f-name-1 = f-name-1 + (if f-name-1 = "":U then "":U else "{&delim-flt}":U) + f-n
    .
  end. /*jj-1*/
  assign
  f-name = f-name + (if f-name = "":U then "":U else {&comma-char}) + f-name-1
  .
end. /* jj */

/*message f-name . */
assign
j-n = num-entries(f-name)
.
Make-excel = yes.
run get-report-num  in parParentProc(output g#report-num).
if Make-Excel then
RUN OpenForExcel in this-procedure .


FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.

FIND FIRST sheetf where
           sheetf.sheet-num = 1 No-ERROR.


assign
ReportName = "Список документов"
sheetf.Excel-Column-Lable = ubflt.filter.Fields-sort-rus
sheetf.sizes = ubflt.filter.Where-ysl
.

run waitfram-show in this-procedure ("Экспорт в EXCEL. Ждите ...").
run rep/extitle.p (1).
iColumn = 0.  /* Начинаем писать со второй строки, 1-я - заголовок */

define variable v-name-field as character no-undo .
define variable v-type as character no-undo .
/*
message
"Fields-sort-rus "  ubflt.filter.Fields-sort-rus    skip
"Fields-sort     "  ubflt.filter.Fields-sort        skip
"Flds            "  ubflt.filter.Flds               skip
"Naim            "  ubflt.filter.Naim               skip
"Num-flt         "  ubflt.filter.Num-flt            skip
"Tbl             "  ubflt.filter.Tbl                skip
"Where-ysl-rus   "  ubflt.filter.Where-ysl-rus      skip
"Where-ysl       "  ubflt.filter.Where-ysl          skip
"call-point      "  ubflt.filter.call-point         skip
"lst-cend        "  ubflt.filter.lst-cend           skip

.
*/
/*
return.
*/
FOR EACH doc-list no-lock :
  if (iColumn modulo 10) = 0 then  run waitfram-show in this-procedure ("Экспортировано в EXCEL строк : " + string (iColumn)).
  assign
    iColumn = iColumn + 1
  .

  do jj = 1 to j-n:
    assign
    f-value = "":U
    .
    CASE entry(1, entry(jj, f-name), ".") :
      when "doc-attr":U then do:
            { str/tdat-val.i
                doc-list.doc-code
                "entry( 2, ( entry( jj, ubflt.filter.Fields-sort ) ), '.' )"
                f-value
                v-type
            }
      end.
      when "function":U then do:
              /*message substr(entry(jj, f-name) , 10 )  entry(jj, ubflt.filter.Where-ysl-rus, {&delim-par}) " -func-".*/
              f-value = get-function(substr(entry(jj, f-name) , 10 ), entry(jj, ubflt.filter.Where-ysl-rus, {&delim-par})) .
      end.
      otherwise do:
        if index(entry(jj, f-name), "{&delim-flt}":U) > 0 then do:
/*           message 888 skip entry(1, entry(jj, f-name), "."). */
          do jj-1 = 1 to num-entries(entry(jj, f-name), "{&delim-flt}":U):
            assign
            f-value-1 = "":U.
            assign
            f-value = f-value + (if f-value = "":U then "":U else {&space-char}) + f-value-1
            .
          end.
        end.
        else do: /* все поля кроме функций */
           v-name-field = entry(jj, ubflt.filter.Fields-sort) .
            run ret-value (
                 input   doc-list.doc-type
               , input   entry( 1 , v-name-field , "." )
               , input   doc-list.doc-code
               , input   entry(2 , v-name-field  , "." )
               , output  f-value   ).
        end.
        .
      end.     /*      if index(f-name, "{&delim-flt}":U) = 0 */
    END CASE.

    /* печать Excel */
     if (entry( jj , ubflt.filter.lst-cend) = {&type-date} or
         entry( jj , ubflt.filter.lst-cend) = "date":U )
         or
         entry( jj , ubflt.filter.Where-ysl-rus, {&delim-par} ) = "99:99"
        then
            assign
              f-value =  SUBSTITUTE ('="&1"', f-value) .  /* Дату и время печатаем в формате =" " */
              .

        {&PutExcel}
          string(f-value, substitute("X(&1)", entry( jj , ubflt.filter.Where-ysl)))
          (if jj < j-n
          then {&tabulation}
          else {&new-line})
          .
  end. /*do jj = 1 to j-n:*/
END.
sheetf.colformat = v-osn-frm + {&delim-par} + v-eng-frm.

{&pageExcel}

FInd first Sheetf where
           Sheetf.sheet-num = 2 No-ERROR.
if not avail sheetf then
create sheetf.
assign
Sheetf.Sheet-num = 2
sheetf.Excel-Column-Lable =  "№ п/п,Действие,Записей,итого,Множество"
sheetf.sizes = "9,9,9,12,155"
.
run rep/extitle.p (2).


run waitfram-show in this-procedure ("Экспорт в EXCEL истории").

for each doc-list-hist:
  {&PutExcel}
  (if doc-list-hist.line = 0
   then string(doc-list-hist.id, ">>>>>>>>9")
   else '':U)
  {&tabulation}
  (if doc-list-hist.item_ <> '':U
   then doc-list-hist.hist-mode
   else '':U)  {&tabulation}
   (if doc-list-hist.item_ <> '':U
   then string(doc-list-hist.num-add, "->>>>>>>>9")
   else '':U)  {&tabulation}
  (if doc-list-hist.item_ <> '':U
  then string(doc-list-hist.num-recs, ">>>>>>>>9")
  else '':U)  {&tabulation}
  doc-list-hist.des
  skip.
end.


run waitfram-hide in this-procedure .
{&CloseExcel}
run waitfram-hide in this-procedure .
/*непосредственно открытие Excel*/

if Make-Excel then do:
   run rep/runexcel.p (
                   string( session:temp-directory +
                         {&DF_Name} +
                         string( g#report-num ) + ".txt":U )
                 ) .
end.

if Make-Excel then
RUN CLoseForExcel in this-procedure .

procedure init-prn-template :
define variable na                   as integer            no-undo .
DEFINE VARIABLE vtooltip             as character           no-undo.
DEFINE VARIABLE vlabel               as character           no-undo .
DEFINE VARIABLE vtype                as character           no-undo .
DEFINE VARIABLE vformat              as character           no-undo .
DEFINE VARIABLE vuser-can-edit       as character           no-undo .
DEFINE VARIABLE voutput-display      as character           no-undo .
DEFINE VARIABLE vother               as character           no-undo .


  do
  on error undo, return error
  :
    assign
    join-tbl = 'Накладные,Атрибуты,Другое'
    tbl      = 'trn-doc,doc-attr,function'
    c-point  = "Список документов" + {&delim-par} +  "PRNT":u
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
    v-size = "":U
    v-format = "":U

    .
run prnfield-add in this-procedure('doc-code', 'Номер', '',         16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('doc-type', 'Тип', 'trn-type', 6, "X(6)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('status_', 'Статус', 'trn-stat', 8, "X(8)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure ('flag_', 'OK', '',              3, "X(3)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('doc-date', 'Дата док-та', '',  11,  "99/99/9999":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('fact-date', 'Дата факт', '',    11, "99/99/9999":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('shift-date', 'Дата смены', '',  11, "99/99/9999":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('shift-num', 'Порядок смены', '',  6, "X(6)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
                                    run prnfield-add in this-procedure('shift-name', 'Номер смены', '',  6, "X(6)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
                                    run prnfield-add in this-procedure('cli-type', 'Тип контрагента', '', 3, "X(3)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('cli-code', 'Код контрагента', '', 9, "X(9)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('cli-name', 'Контрагент', '',     20, "X(20)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('obj-type', 'Тип объекта', '',     3, "X(3)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('obj-code', 'Код объекта', '',     5, "X(5)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('ext-doc-type', 'Расширенный тип', '',   16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('rsrv-date', 'Дата резервирования', '',   11, "99/99/99":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('boss', 'Менеджер', '',                             16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('doc-qnty', 'Кол-во по док.', '',                    16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('fact-qnty', 'Кол-во факт', '',                      16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('tot-doc', 'Сумма (вал)', '',                        16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('tot-calc', 'Скидка (вал)', '',                      16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('tot-rubl', 'Сумма ({&abbr_rub})', '',                       16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('discnt-rubl', 'Скидка ({&abbr_rub})', '',                   16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('discnt-pc', 'Скидка (%)', '',                       16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('discnt-type', 'Тип скидки', '',                     16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('tot-fact', 'Сумма (факт)', '',                      16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('pay-code', 'Код оплаты', 'pay',                     16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('internal', 'Внутренняя', '',                        16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('creid', 'Создал', '',                               16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('agnt', 'Исполнитель', 'cli',                        16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('wrkr', 'Кладовщик', 'cli',                          16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('out-code', 'На док-т', '',                          16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('acc-date', 'Проводка', '',                          16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('base-rate', 'Курс', '',                             16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('inv-num', 'Инвойс', '',                             16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('ord-num', 'Заказ', '',                              16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('office', 'Услуги', '',                              3, "X(3)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('print-rubl', '{&abbr_rublevy_firstshift}', '',                        3, "X(3)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('ship-num', 'Отгрузка', '',                          16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('ship-date', 'Дата отгрузки', '',                    11, "99/99/99":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('ov', 'Акт', '',                                     3, "X(3)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('tot-ov', 'Сумма акта', '',                          16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('exch-code', 'Валюта', 'cur',                        16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('fact-num', 'Порядок закрытия', '',                  16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('PS', 'Примечание', '',                              80, "X(80)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('purch-code', 'Тип приобретения', 'purch-code',      16, "X(16)":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('flora-pay-date', 'Оплата заказа БУКЕТЫ', '',         11, "99/99/99":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.
run prnfield-add in this-procedure('flora-order-date', 'Дата выполненя заказа БУКЕТЫ', '',         11, "99/99/99":U,
                                    input-output fld, input-output lab, input-output spr,  input-output v-size, input-output v-format, input-output dim)  no-error.

  assign
    fld = fld
    lab = lab
    dim = dim + {&comma-char}
    .

    define variable  p-fillin_width   as integer   no-undo . /* ширина          */
    define variable   p-fillin_height  as integer   no-undo . /* высота          */
    define variable sum-na as integer   no-undo .
    define variable vproc-attr       as character no-undo .
    define variable vfull-screen-val as character no-undo .
    define variable vsort as integer   no-undo .

    sum-na = num-entries( {&trdcattr-list} ) .
    /* добавим атрибуты товара на объекте */
    do na = 1 to sum-na:
       { str/tdat-cod.i
           "entry( na, {&trdcattr-list} )"
           vtype
           vformat
           p-fillin_width
           p-fillin_height
           vlabel
           vuser-can-edit
           voutput-display
           vother
           vproc-attr
           vfull-screen-val
           vsort
           no-error
      }
      if NOT error-status :error and voutput-display = "yes":U  then do:
        vlabel = replace (vlabel , "," , " " ) .
        run prnfield-add in this-procedure(
            entry(na, {&trdcattr-list}),
                 vlabel,
                 'ATTR.' + VTYPE,
                 prnfield_get-fsize ( vtype, vformat, vlabel),
                 vformat,
        input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
      end.
    end.



    assign
    fld = fld
    lab = lab
    dim = dim + {&comma-char}
    .

    run prnfield-add in this-procedure('iColumn', '№', 'function.integer', 7, ">>>>>>9":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
  end.

end procedure. /* init-prn-template */

procedure ret-value :
  do
  on error undo, return error return-value
  :
define input  parameter p-doc-type as character no-undo .
define input  parameter p-table as character no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter p-pole as character no-undo .
define output parameter p-ret as character no-undo .

DEFINE VARIABLE ii AS INTEGER no-undo .
DEFINE VARIABLE qh AS WIDGET-HANDLE no-undo .
define variable usl as character no-undo .
define variable v-trn-doc as character no-undo .
define variable v-doc-num-field as character no-undo .

DEFINE VARIABLE buf_din_trn-doc AS WIDGET-HANDLE.
define buffer BUF_field for ub._field.
&scop doc-num-field-list 'trn-doc.doc-code,inkas.inkas-code,price-doc.doc-num'

  CASE p-doc-type:
    when {&cash-desk} then do:
      assign
      ii = LOOKUP('INKAS', {&TABLE-LIST})
      v-trn-doc = "inkas"
      v-doc-num-field = "inkas-code"
      .
    end.
    when {&OVERVALUE} then do:
      assign
      ii = LOOKUP('PRICE-DOC', {&TABLE-LIST})
      v-trn-doc = "price-doc"
      v-doc-num-field = "doc-num"
      .
    end.
    OTHERWISE do:
      assign
      ii = LOOKUP('TRN-DOC', {&TABLE-LIST})
      v-trn-doc = "trn-doc"
      v-doc-num-field = "doc-code"
      .
    end.
  END CASE.
  if lookup(p-table + '.' + p-pole, {&doc-num-field-list}) > 0 then do:
    assign
    p-ret = p-doc-code
    .
    return.
  end.
  else do:
    find first buf_field no-lock where
              buf_field._file-recid = v-recid_FILE[II]
          AND buf_field._field-name = p-pole no-error .
    if not available buf_field then do:
      if v-trn-doc = "inkas" then do:
        /*воспользуемся тем, что есть документ  сномером равным продаже*/
        find first buf_field no-lock where
                  buf_field._file-recid = v-recid_FILE[LOOKUP('TRN-DOC', {&TABLE-LIST})]
              AND buf_field._field-name = p-pole no-error .
        if available buf_field then do:
          assign
          v-doc-num-field = 'doc-code'
          v-trn-doc = 'trn-doc'.
        end.
        else do:
          assign
          p-ret = '[Не определено]'.
          return.
        end.
      end. /*if inkas - попробуем через докумекнт*/
      else do:
        assign
        p-ret = '[Не определено]'.
        return.
      end.
    end.
  end.
  CREATE BUFFER buf_din_trn-doc FOR TABLE v-trn-doc.
  CREATE QUERY qh.
  usl = SUBSTITUTE ( "for each &2 no-lock  where  &2.&3 = '&1' " , p-doc-code, v-trn-doc, v-doc-num-field )    .
  qh:SET-BUFFERS  ( buf_din_trn-doc ).
  qh:QUERY-PREPARE ( usl ).
  qh:QUERY-OPEN.
  qh:GET-FIRST.
  p-ret = buf_din_trn-doc:BUFFER-FIELD(p-pole):BUFFER-VALUE   .
  DELETE WIDGET qh.
  DELETE WIDGET buf_din_trn-doc.

end. /*doe*/
end procedure. /* ret-value */