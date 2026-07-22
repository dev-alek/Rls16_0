block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : pack-list.p
    Purpose     : Печатные формы. Упаковочный лист поставщика.

    Description : Запуск процедуры формирования упаковочного листа по выбранной накладной.

    Author(s)   : SKiryxin
    Created     : Fri Mar 01 12:04:24 MSK 2013
    Notes       :
  ----------------------------------------------------------------------*/

/* 
$Revision: $
$Author: EShklyar $
$Date: Сб фев 20 15:59:21 2021 +0300 $
$Workfile: $
$Archive: rep/pack-list.p $ 
*/

define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pack-list.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/pack-list.p $":U .
define variable vss-description as character no-undo init "Запуск процедуры формирования 
                                                          упаковочного листа по выбранной накладной.".
{cmp/vssrevis.i}
  
/* ************************  Includes  ************************ */

{cmp/str-glbl.i}
{cmp/library.i}
{str/lib-trn.i}
{gbl/clntattr.i}
{rep/fmtcli.i}      /* для torgconf.i */
{rep/torgconf.i}    /* для шапки */
{ref/extclass.i}    /* для внешних классификаторов */

/* ************************  Input parametres  ************************ */

define input parameter p_mainmenu-handle as handle no-undo.
define input parameter p_recid as recid no-undo. /* От trn-doc */

/* ***************************  Definitions  ************************** */

/* ********** Variables ********** */

/* Для Excel */

define variable chExcel as com-handle. 
define variable chWorkbook as com-handle no-undo.
define variable chWorksheet as com-handle no-undo.
define variable c_rep-name as character no-undo.
  
/* Переменные для шапки отчета */

define variable i_obi-sup-num as integer no-undo.   /* Номер поставщика */
define variable c_ord-num as character no-undo.     /* Номер заказа магазина */
define variable d_order-date as date no-undo.       /* Дата заказа */
define variable c_doc-num as character no-undo.     /* Номер накладной */
define variable d_doc-date as date no-undo.         /* Дата товарной накоадной */
define variable i_mag-num as integer no-undo.       /* Номер магазина */
define variable i_pallet as integer no-undo.        /* Количество паллет */
define variable c_consignee as character no-undo.   /* Грузополучатель */
define variable c_consignor as character no-undo.   /* Грузоотправитель */

/* Переменные для подвала отчета */

define variable c_picker as character no-undo.  /* Комплектовщик */
define variable i_cur-list as integer no-undo.  /* Текущий лист */
define variable i_lists as integer no-undo.     /* Общее кол-во листов */

/* ********** Buffers ********** */

define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_goods for ub.goods.
define buffer buf_ext-artic for ub.ext-artic.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_clients for ub.clients.
define buffer buf_person for ub.person.

/* ********** Temp tables ********** */

/* Тело отчета */
define temp-table tt_list no-undo
field num as integer            /* Порядковый номер */
field obi-gds-art as character  /* Артикул ОБИ */
field gds-name as character     /* Наименование */
field sup-art as character      /* Артикул поставщика */
field units as character        /* Ед-ца измерения */
field brutto as decimal         /* Масса брутто */
field EAN as character          /* EAN артикула */
field qnty as decimal           /* Кол-во */
index ind_num is primary unique num.

/* ***************************  Main Block  *************************** */

find first buf_trn-doc where recid(buf_trn-doc) = p_recid no-lock. /* Сразу встанем на накладную */

run get_header in this-procedure. /* Заполним переменные для шапки */

run get_tt_list in this-procedure. /* Заполним временную таблицу с телом отчета */

run get_footer in this-procedure. /* Заполним переменные для подвала */

run create_empty_report in this-procedure. /* Создадим файл с нужным количеством страниц с шапкой и подвалом */

run fill_report in this-procedure. /* Заполним отчет данными из таблицы */

/* **********************  Internal Procedures  *********************** */

procedure get_header:
/*------------------------------------------------------------------------------
        Purpose: Заполнение переменных для шапки
        Notes:
------------------------------------------------------------------------------*/

define variable v-attr-value as character no-undo.
define variable v-attr-type as character no-undo.

/* Определение переменных для грузополучателя */
define variable v-trdcattr-type as character no-undo.
define variable v-code-rec as integer no-undo.
define variable v-type-rec as character no-undo.
define variable v-recipient-code as character no-undo.
define variable v-codefirm-rec as character no-undo.
define variable v-curcode-rec as integer no-undo.
define variable v-host-code as integer no-undo.
define variable v-outhdobj as logical init no no-undo.
define variable v-outhdobj-str as character no-undo.
define variable v-cli-type as character no-undo.
define variable v-cli-code as integer no-undo.
define variable v-is-hold-doc as logical no-undo.
define variable v-par-type as character no-undo.

/* Здесь взял все определения аналогично отчету ТОРГ12 */

/* Считаем параметры ТОРГ12 */
run torgconf-read in this-procedure (input "torg12":U,
                                     input buf_trn-doc.host-code,
                                     input buf_trn-doc.obj-type,
                                     input buf_trn-doc.obj-code) no-error.

run torgconf-get-self-param in this-procedure (input buf_trn-doc.obj-type,
                                               input buf_trn-doc.obj-code,
                                               input 0) no-error.

/*То что нужно для Грузополучателя */
{gbl/hold-doc.i buf_trn-doc.doc-code v-is-hold-doc}
if  v-is-hold-doc then do: /*если документ межфирмекнного перемещения, 
                             то смотрим что писать а грузополучатель. параметр outhdobj */
  run gbl/conf-rd.p ("outhdobj" , v-host-code, buf_trn-doc.obj-type, 
                     buf_trn-doc.obj-code, "", "", "", no, output v-outhdobj-str,
                     output v-par-type) no-error.
  
  if error-status :error then v-outhdobj-str = "".
  if lookup( "torg12", v-outhdobj-str ) <> 0 then v-outhdobj = yes.

end.

assign
v-cli-type = buf_trn-doc.cli-type
v-cli-code = buf_trn-doc.cli-code.

/* атрибут Грузополучатель*/
run torgconf-get-recepient-param (input buf_trn-doc.doc-code,
                                  output v-code-rec,
                                  output v-type-rec,
                                  output v-codefirm-rec,
                                  output v-curcode-rec) no-error.

if v-code-rec = 0 and v-outhdobj = yes and v-is-hold-doc = yes then do:
    assign
    v-type-rec = buf_trn-doc.hold-obj-type
    v-code-rec = buf_trn-doc.hold-obj-code.
end.

else if v-code-rec = 0 then do:
    v-type-rec = buf_trn-doc.cli-type.
    v-code-rec = buf_trn-doc.cli-code.
end.

run torgconf-get-sup-param in this-procedure (input v-type-rec,
                                              input v-code-rec,
                                              input v-curcode-rec) no-error.
if error-status :error then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров объекта документа."
    skip return-value
    skip trim(error-status :get-message(1))
         trim(error-status :get-message(2))
         trim(error-status :get-message(3))
    view-as alert-box warning.
end.

run torgconf-get-cli-param in this-procedure (input buf_trn-doc.host-code,
                                              input v-cli-type,
                                              input v-cli-code,
                                              input 0) no-error.
if error-status :error then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров объекта клиента документа."
    skip return-value
    skip trim(error-status :get-message(1))
         trim(error-status :get-message(2))
         trim(error-status :get-message(3))
    view-as alert-box warning.
end.

run torgconf-get-ship-param in this-procedure (input buf_trn-doc.host-code,
                                               input v-type-rec,
                                               input v-code-rec,
                                               input v-curcode-rec) no-error.
if error-status :error then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров объекта клиента документа."
    skip return-value
    skip trim(error-status :get-message(1))
         trim(error-status :get-message(2))
         trim(error-status :get-message(3))
    view-as alert-box warning.
end.

run torgconf-get-form-header in this-procedure (input no,
                                                input buf_trn-doc.doc-code,
                                                input no,
                                                input buf_trn-doc.doc-date,
                                                input buf_trn-doc.fact-date,
                                                input buf_trn-doc.doc-type,
                                                input buf_trn-doc.status_,
                                                input no,
                                                input no) no-error.

/* Теперь заполним шапку */

/* Определим номер поставщика */
find first buf_ext-classif no-lock
     where buf_ext-classif.classif-subject = {&table_clients}
       and buf_ext-classif.classif-name = {&extclass_code_firm_in_ext_client}
       and buf_ext-classif.db-num = -1
       and buf_ext-classif.Key#_One = v-torgconf-self-host-code
       and buf_ext-classif.Key#_Two = v-torgconf-sup-obj-code
       and buf_ext-classif.Key#_Three = 0
       and buf_ext-classif.CharKey_One = ''
       and buf_ext-classif.CharKey_Two = v-torgconf-sup-obj-type no-error.

if available(buf_ext-classif) then i_obi-sup-num = int(buf_ext-classif.CharKey_Three).

/* Определим основание для поставки товара */
run gbl/trdcat-v.p(input buf_trn-doc.doc-code,
                   input {&trdcattr-zakaz-number},
                   output c_ord-num,    /* Получили */
                   output v-attr-type) no-error.

/* Определим дату заказа */
run gbl/trdcat-v.p(input buf_trn-doc.doc-code,
                   input {&trdcattr-zakaz-date},
                   output v-attr-value,
                   output v-attr-type) no-error.
                   
d_order-date = date(v-attr-value).

c_doc-num = v-torgconf-vdoc-code. /* Номер накладной */

d_doc-date = buf_trn-doc.doc-date. /* Дата товарной накладной */

/* Определим номер магазина */
run clntattr-value in this-procedure (input buf_trn-doc.cli-type, 
                                      input buf_trn-doc.cli-code, 
                                      input {&attr-division-code}, 
                                      output v-attr-value, 
                                      output v-attr-type) no-error.

if v-attr-value <> "" then i_mag-num = integer(v-attr-value).

/* Определим количество мест */
run gbl/trdcat-v.p (input buf_trn-doc.doc-code,
                    input {&trdcattr-qntyplace},
                    output i_pallet, /* Получили */
                    output v-attr-type) no-error.

/* Грузополучатель */
c_consignee = v-torgconf-consignee.

/* Грузоотправитель */
c_consignor = v-torgconf-supplier.

end procedure. /* get_header */

procedure get_tt_list:
/*------------------------------------------------------------------------------
        Purpose: Заполнение временой таблицы с телом отчета
        Notes:
------------------------------------------------------------------------------*/

define variable ii as integer no-undo. /* Счетчик строк */

for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code no-lock:
    
    ii = ii + 1.

    create tt_list.
    assign
    tt_list.num = ii    /* Номер позиции */
    tt_list.qnty = buf_doc-line.fact-qnty.  /* Колв-во */

    find first buf_goods where buf_goods.artic = buf_doc-line.artic
                           and buf_goods.prod-code = buf_doc-line.prod-code
                           and buf_goods.prod-type = buf_doc-line.prod-type no-lock.
                                   
    assign
    tt_list.units = buf_goods.unit-base             /* Ед-ца измерения */
    tt_list.brutto = buf_goods.wt-base              /* Масса брутто */
    tt_list.gds-name = buf_goods.gds-name           /* Наименование */
    tt_list.sup-art = string(buf_goods.gds-code).   /* Артикул поставщика */
    
    find first buf_ext-artic where buf_ext-artic.cli-type = {&cmp}
                               and buf_ext-artic.cli-code = buf_trn-doc.cli-code
                               and buf_ext-artic.gds-code = buf_goods.gds-code
                               and buf_ext-artic.status_ <> {&deleted-status} no-lock no-error.
    
    if available(buf_ext-artic) then tt_list.obi-gds-art = buf_ext-artic.ext-artic. /* Артикул ОБИ */

    /* Получим все артикулы по данному товару */
    
    
    for each buf_bar-code where buf_bar-code.gds-code = buf_goods.gds-code 
                        and buf_bar-code.part-code = "" 
                        and buf_bar-code.in-code = "" no-lock:
    
        if buf_bar-code.stts_ <> 0 then next. /* Уберём удаленные (stts вне индекса) */
      
        for each buf_prod-bc where buf_prod-bc.b-code = buf_bar-code.b-code
                               and buf_prod-bc.b-str ne string(buf_bar-code.b-code) 
                               and buf_prod-bc.bc-on = yes no-lock:
      
            tt_list.EAN = tt_list.EAN + ";" + buf_prod-bc.b-str.
                 
        end. /* for each buf_prod-bc */

    end. /* for each buf_bar-code */
    
    tt_list.EAN = trim(tt_list.EAN,";"). /* Получили список всех артикулов */
    
end. /* for each buf_doc-line */

end procedure. /* get_tt_list */

procedure get_footer:
/*------------------------------------------------------------------------------
        Purpose: Заполнение переменных для подвала
        Notes:
------------------------------------------------------------------------------*/
/* Определим комплектовщика */

find first buf_clients where buf_clients.obj-type = {&prs} 
                         and buf_clients.obj-code = buf_trn-doc.wrkr no-lock no-error.

find first buf_person where buf_person.psn-code = buf_clients.obj-code no-lock no-error.

if available buf_clients then c_picker = substitute("&1 &2 &3",buf_clients.obj-name, 
                                                    buf_person.name1, buf_person.name2).

end procedure. /* get_footer */

procedure create_empty_report:
/*------------------------------------------------------------------------------
        Purpose: Создание файла с нужным количеством страниц с шапкой и подвалом
        Notes:
------------------------------------------------------------------------------*/
define variable ii as integer no-undo. /* Для цикла */

find last tt_list use-index ind_num no-error.

/* Определим кол-во страниц. К делению без остатка добавим 1, если остаток есть. */
i_lists = (tt_list.num - (tt_list.num modulo 15)) / 15 + (if tt_list.num modulo 15 <> 0 then 1 else 0).

/* Откроем excel */

c_rep-name = string(session:temp-directory + "rep_" + 
             replace(replace(string(now,"99.99.99 HH:MM:SS"),":","-")," ","_") + ".xls").

os-copy value(search("exe\pack-list.xls")) value(c_rep-name).

create "Excel.Application" chExcel no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
chWorkbook = chExcel:Workbooks:Open(c_rep-name).
chExcel:Visible = true.

chWorksheet = chWorkbook:sheets:item(1).

/* Заполним шапку */

chWorksheet:Range("C1"):Value = i_obi-sup-num.
chWorksheet:Range("J2"):Value = c_ord-num.
chWorksheet:Range("N2"):Value = d_order-date.
chWorksheet:Range("J4"):Value = c_doc-num.
chWorksheet:Range("N4"):Value = d_doc-date.
chWorksheet:Range("F6"):Value = trim(string(i_mag-num,">>999")).
chWorksheet:Range("T2"):Value = string(i_pallet,"99").
chWorksheet:Range("F8"):Value = c_consignee.
chWorksheet:Range("F11"):Value = c_consignor.

/* Заполним подвал */

chWorksheet:Range("G34"):Value = c_picker.
chWorksheet:Range("U34"):Value = i_lists.

/* Создадим нужное количество листов */

do ii = 1 to i_lists - 1:

    chWorksheet:Range("A1:V34"):Copy.
    chWorksheet:Range("A" + string(34 * ii + 1)):Select.
    chWorksheet:Paste.
    
    chWorksheet:Range("S" + string(34 * (ii + 1))):Value = ii + 1.
    
end. /* do ii = 1 to i_lists */

chWorksheet:range('A1'):Select.
chExcel:CutCopyMode = false.

end procedure. /* create_empty_report */

procedure fill_report:
/*------------------------------------------------------------------------------
        Purpose: Заполнение отчета данными из таблицы
        Notes:
------------------------------------------------------------------------------*/
define variable c_row as character no-undo. /* строка в excel */

i_cur-list = 1.

for each tt_list no-lock:
    
    c_row = string(14 + tt_list.num + 19 * (i_cur-list - 1)).
    
    chWorksheet:Range("B" + c_row):Value = tt_list.num.
    chWorksheet:Range("C" + c_row):Value = tt_list.obi-gds-art.
    chWorksheet:Range("E" + c_row):Value = tt_list.gds-name.
    chWorksheet:Range("I" + c_row):Value = tt_list.sup-art.
    chWorksheet:Range("L" + c_row):Value = tt_list.units.
    chWorksheet:Range("N" + c_row):Value = tt_list.brutto.
    chWorksheet:Range("P" + c_row):Value = tt_list.EAN.
    chWorksheet:Range("S" + c_row):Value = tt_list.qnty.
    chWorksheet:Range("T" + c_row):Formula = substitute("=Code_128(P&1)",c_row).
    
    /* Переход на следующий лист */
    if tt_list.num modulo 15 = 0 then i_cur-list = i_cur-list + 1.
    
end. /* for each tt_list */

/* Сохраним и отпустим Excel */
chExcel:DisplayAlerts = false.
chWorkbook:SaveAs(c_rep-name, -4143 , "" , "", false, false , 1).
chExcel:DisplayAlerts = true.
release object chWorksheet no-error.
release object chWorkbook no-error.
release object chExcel no-error.
end procedure. /* fill_report */
