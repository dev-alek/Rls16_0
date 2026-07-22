block-level on error undo, throw.
/*

$Revision: a8e2cf75ddf6, 2506, rls $
$Author: EShklyar $
$Date: Ср июл 08 17:09:06 2020 +0300 $
$Workfile: r-bonus-ot.p $
$Archive: rep/r-bonus-ot.p $

Отчёт по Бонусам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

*/

/*вызвается с тремя параметрами компиляции - WHERE-Phrase для chk-doc.d-card и
where-phrase для dis-card
where-phrase для chk-gds.b-code -> bar--code*/
define input parameter parparentproc    as handle no-undo.
define input parameter DcardMode        as character no-undo. /* Закладка-2 "Покупатели" (Все|Выборочно по картам) */
/*может быть ALL, ONE, LIST*/
define input parameter FixDCard         as character no-undo.
define input parameter ProdMode         as integer no-undo. /* Режим выбора товаров в 1-й вкладке отчёта (Все=1, ГруппыТоваров=..., Производители=..., Выборочно=..., Один=... */
/*может быть {g-all} {&g-prod} {&g-grp}*/
/*define input parameter FixProdAttr      as character no-undo.*/
/*DEFINE INPUT PARAMETER TotalOnly as logical no-undo.*/ /* ТН-3320. 26.11.2014г. Арн. */
/*define input parameter rs-goods         as integer no-undo. /* ТН-3320. 26.11.2014г. Арн. */*/
/*define input parameter StartPoint       as date no-undo.*/
/*define input parameter EndPoint         as date no-undo.*/
/*DEFINE INPUT PARAMETER T-time as logical no-undo.*/
/*define input parameter p-prodmode2 as character no-undo.*/
/*define input parameter t-imp            as logical no-undo.*/
define input parameter p-T-obj-detal    as logical no-undo.                             /* Флаг в интерфейсе параметров Закл-2 "Детализация по объктам" */
/*define input parameter p-lvl-grp        as character no-undo.*/
/*define input parameter UpLevel          as decimal format "->>>,>>>,>>9.99":U no-undo.  /* Параметры Закладка-2 поле ввода "Превышение суммы" */*/
define input parameter selectcard       as character no-undo.
/*define input parameter p-curr-r-b       as character no-undo.*/

define variable vss-revision    as character no-undo init "$Revision: a8e2cf75ddf6, 2506, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июл 08 17:09:06 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-bonus-ot.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-bonus-ot.p $":U .
define variable vss-description as character no-undo init "Отчёт по Бонусам".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i  }
{ cmp/library.i }
/*{ gbl/cur-time.i }*/
{ cmp/r-page1.i " " cmp }
/*{ cmp/r-page1.i }*/
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/operlist.i }
{ cmp/breakstr.i }
{ cmp/getdpcnt.i }
{ gbl/waitfram.i }
{ cmp/dc-list.i dc-list def "shared " }
/*{ cmp/dc-list.i dc-list def "new shared" }*/
{ ref/grplibfn.i }
{ rep/e-xldcd.i "NEW SHARED" }
{ gbl/getcntxt.i def }
{ str/lib-trn.i  }



define variable v-obj_qnty-bonus as decimal.
define variable  v-dcard_qnty-bonus as decimal.
define variable v-obj-sum-qnty-bonus as decimal.
define variable new-doc as logical no-undo.
define variable v-prod-type as character no-undo.
define variable v-prod-code as integer no-undo.
define variable v-grp-code like ub.gds-grp.node-code no-undo.
define variable v-gds-code like ub.goods.gds-code no-undo.
define variable v-grp-name like ub.goods.grp-name no-undo.
define variable v-card-num-chr as character no-undo.
define variable ii-grp as integer no-undo.
define variable v-found as logical no-undo.
define variable v-count as integer no-undo.
define variable v-shift-on as logical no-undo.
define variable v-grp-gds as character no-undo.
define variable is-petrol as logical no-undo. 
define variable is-pieces as logical no-undo.
define variable v-for-netto as decimal no-undo.
define variable v-prodmode2 as character no-undo.
define variable FixProdAttr as character no-undo.

define variable sym1 as character initial ":" no-undo. 
define variable sym2 as character initial ":" no-undo.
define variable Line as character no-undo.
define variable NotInc as logical no-undo.
define variable only-one-card-per-cli as integer no-undo.
define variable only-one-card-per-leg as integer no-undo.
define variable for-name as character no-undo.
define variable namebuf1 as character no-undo.
define variable namebuf2 as character no-undo.
define variable v-full-path-RepView as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm as character no-undo.   /* Полный путь к файлу отчёта */
define variable g#report-num as integer no-undo.            /* Номер отчёта (получим стандартной процедурой ТН) */
define variable v-report-name as character no-undo.         /* Наименование отчёта */
define variable v-period as character no-undo.              /* Период за который формируется отчёт */
define variable v-msg-noAllChk as character no-undo.        /* Предупреждение, если отчёт будет "(сформирован НЕ ПО ВСЕМ ЧЕКАМ)" */
define variable v-short-obj-list as character no-undo.      /* Сокращённый список выбранных Объектов "в одну строку" */
define variable v-sel-card-string as character no-undo.     /* Строка отчёта, где указана информация о выбранных ДКартах ("По ВСЕМ картам"|"Выборочно по картам" */
define variable v-sel-gds-string as character no-undo.      /* Строка отчёта, где указана информация о выбранных товарах ("По сформированному списку товаров (в списке 15 товаров)." */
define variable v-prod-mode-string as character no-undo.    /* Строка отчёта, где указана информация о выбранном режиме "По производителям" (По конкретным производителям(поставщикам)деталльно | По ВСЕМ производителям (одной строкой)) */
define variable v-legacy-string as character no-undo.       /* С учетом перевыпуска карт (приведены номера карт ПОСЛЕДНЕГО ВЫПУСКА) */
define variable v-subsid-string as character no-undo.       /* С учетом дополнительных карт (приведены номера ОСНОВНЫХ карт) */

define variable v-dcard_doc-qnty as decimal no-undo.
define variable v-dcard_sum-withoutdisc as decimal no-undo. /* Сумма без скидок */
define variable v-dcard_sum-withdisc as decimal no-undo.    /* Сумма со скидкой */
define variable v-dcard_discount as decimal no-undo.
/* ********* */
define variable v-obj_doc-qnty as decimal no-undo.
define variable v-obj_sum-withoutdisc as decimal no-undo.   /* Сумма без скидок */
define variable v-obj_sum-withdisc as decimal no-undo.      /* Сумма со скидкой */
define variable v-obj_discount as decimal no-undo.
define variable v-first-of-d-card as logical no-undo.       /* Первое вхождение в ДКарту (к расчёту чеков по ДКарте) */
define variable v-obj-chk-counter as integer no-undo.
define variable v-obj-type as character format "X(3)" no-undo. /* Для управл. условием where в запросе (для одноимённого поля) */
define variable v-obj-code as integer no-undo.              /* Для управл. условием where в запросе (для одноимённого поля) */
define variable v-obj-name as character no-undo.            /* Для управл. условием where в запросе (для одноимённого поля) */

/* ----------------------------------------------------- */
define variable num-g#              as integer no-undo.
define variable for-d-pcnt          as character no-undo.
define variable loc-d-pcnt          like ub.dis-card.d-pcnt no-undo.
define variable v-header-base-curr  as character no-undo.
define variable accum-counter       as integer no-undo.
define variable accum-qnty          as decimal no-undo.
define variable accum-sum           as decimal no-undo. 
define variable accum-discount      as decimal no-undo.
define variable accum-netto         as decimal no-undo.
define variable accum-counter-cli   as integer no-undo.
define variable accum-qnty-cli      as decimal no-undo.
define variable accum-sum-cli       as decimal no-undo.
define variable accum-discount-cli  as decimal no-undo.
define variable accum-netto-cli     as decimal no-undo.
define variable accum-counter-leg   as integer no-undo.
define variable accum-qnty-leg      as decimal no-undo.
define variable accum-sum-leg       as decimal no-undo.
define variable accum-discount-leg  as decimal no-undo.
define variable accum-netto-leg     as decimal no-undo.
define variable accum-counter-crd   as integer no-undo.
define variable accum-qnty-crd      as decimal no-undo.
define variable accum-sum-crd       as decimal no-undo.
define variable accum-discount-crd  as decimal no-undo.
define variable accum-netto-crd     as decimal no-undo.
define variable v-d-card            like ub.dis-card.d-card no-undo.
define variable v-ii                as integer no-undo.
define variable stream-pos          as integer no-undo.
define variable v-root-card         like ub.dis-card.d-card no-undo.
define variable v-cli-code          like ub.dis-card.cli-code no-undo.
define variable v-cli-type          like ub.dis-card.cli-type no-undo.
define variable v-cli-type-code     as character no-undo.
define variable v-cli-name          like ub.clients.obj-name no-undo.
define variable v-show-d-card       like ub.dis-card.d-card no-undo.
define variable ii                  as integer no-undo.
define variable v-base-code         like ub.sysconf.base-code no-undo.
define variable v-mes-noAll-chk     as character no-undo.
define variable v-accur-13          as character initial "->>>>>>>>>>>>9.99" no-undo.   /* Формат числа с плавающей точкой на 15 разрядов до и 2 разряда после десятичной запятой. ТРИЛЛИОН. */

define buffer buf_clients for ub.clients.
define buffer buf2_clients for ub.clients. /* dcard */
define buffer buf3_clients for ub.clients. /* prod */

/*define buffer buf_dis-card for ub.dis-card.*/
define buffer buf_currency for ub.currency.
/* ----------------------------------------------------- */

/*{ rep/e-xldcd.i "SHARED" }*/


define temp-table help-chk no-undo

    field doc-code as char
    field group-chk as integer
    index pi is primary unique  doc-code group-chk
    .


define temp-table my-table no-undo
    field note1 as character
    field note2 as character
    field note3 as character
    field note4 as character
    field note5 as character
    field note6 as character
    field note7 as character
    field note8 as character
    field note9 as character
    field note10 as character
    field note11 as character
.

/* Список номеров организаций, к которым принадлежат объекты (объекты будут выбраны из списка объектов в Закладке-1 Выбор объекта: Все по фирме(тек)|Текущий|Выборочно|Все */
/* Заполнится ниже по коду */
define temp-table obj-host no-undo
    field host-code like ub.sysconf.host-code
index pi is primary unique host-code.

define temp-table tt-selCliObjList no-undo
/* Список объектов, выбранных в параметрах Закладка-1 в формате данного Отчёта */
    field dbname-cliobjname as character /* По объектам: БД(имя) / Объект(имя_номер) */
.

define temp-table tt-CliObjType no-undo
/* Закладка-1 "Выбор товара" (Все|Группы товаров|Производители|Выборочно|Один). Основная причина создания tt - для режима "Производители", где необходимо хранение списка производителей. */
    field producer-name as character /* Наименование производителя (вида: "ООО Айсберг") */
.

define temp-table tt-selectgood no-undo
    field collection-name as character /* Заголовок информации, которую нужно вывести перед каким-либо списком(коллекцией) (например "По группам товаров:" (а со следующей строки ожидается построчный список товаров)) */
    field collection-element as character /* Наименование конкретного элемента(коллекции) (например "Группа-1") */
.

define temp-table tt-selGrpCds no-undo
/* Закладка-1 "Выбор товара" (Все|Группы товаров|Производители|Выборочно|Один). Основная причина создания tt - для режима "Группы товаров", где необходимо хранение списка групп товаров. */
    field GrpCds-name as character /* Наименование группы товаров */
.

define temp-table tt-selGdsList no-undo
/* Закладка-1 "Выбор товара" (Все|Группы товаров|Производители|Выборочно|Один). Основная причина создания tt - для режимов "Один"(попутно для "Выборочно"), где необходимо хранение списка производителей. */
    field gds-string as character /* Гибкая информация о товаре. */
.

define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_dcards for dcards.
define buffer buf-crd_dcards for dcards.
define buffer buf-crd2_dcards for dcards.
define buffer buf-obj_dcards for dcards.
define buffer buf-obj1_dcards for dcards.
define buffer buf-obj3_dcards for dcards.
define buffer X_dis-card for ub.dis-card.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_CHK-GDS for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_payment for ub.payment.
define buffer buf_payment-attr for ub.payment-attr.
define buffer buf_obj-list for obj-list.

define stream OutStr-html.
define stream MyWatch-strm. /* задать в области определения переменных */

/*find first buf_obj-list no-error.                                        */ /* АРН. 25.11.2014 */
/*/*if error-status:error then message "Ошибка-115" view-as alert-box.*/   */
/*/*if available obj-list then run prc-mes-no-shift-obj(buffer obj-list).*/*/
/*    if available buf_obj-list then do:                                   */

/* ************************  Function Implementations ***************** */

function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date) forward.

function fnc-convert-dot-to-colon returns character 
(input p-data as decimal, p-accur as character) forward.
/* ******************************************************************** */

run My-Rep.

run waitfram-hide in this-procedure .

/* **********************  Internal Procedures  *********************** */

procedure calc-chk:
/**********************************************/
    v-first-of-d-card = no. /* Сброс флага вхождения в ДКарту перед циклом */

    do:
        if dcardmode = "ONE":U then
        do:
            if not buf_chk-doc.d-card = FixDCard then return. /*next _chk-doc1.*/
        end.

        if dcardmode = "list":U then
        do:
            find first dc-list where
            dc-list.d-card = buf_chk-doc.d-card no-error.
            if not available dc-list then return. /*next _chk-doc1.*/
        end.
    end.

    process events.

    v-count = v-count + 1.
    if (v-count  modulo 10) = 0
    and  v-count >= 10 then
    do: /* g */
        run waitfram-show in this-procedure (input substitute("&1&2 обработано чеков &3"
                                                                ,obj-list.obj-type
                                                                ,obj-list.obj-code
                                                                ,v-count))
        .
    end. /* g */

    new-doc = yes.

    if p-T-obj-detal = yes /*and t-imp = no*/ then
    do:
        v-obj-type = obj-list.obj-type.
        v-obj-code = obj-list.obj-code.
        v-obj-name = obj-list.obj-name.
    end.
    else
    do:
        v-obj-type = "".
        v-obj-code = 0.
        v-obj-name = "".
    end.

   

    do:  /* A. _chk: for each buf_chk-gds */
        _chk: for each buf_chk-gds where buf_chk-gds.doc-code = buf_chk-doc.doc-code
              ,
              first buf_bar-code no-lock where
                    buf_bar-code.b-code = buf_chk-gds.b-code
              ,
              first buf_goods no-lock where
                    buf_goods.gds-code = buf_bar-code.gds-code 
                  
        :
            
case x-SelectGood: 
        
         when {&g-choice} or
         when {&g-spis}     or
         when {&g-one}   then 
                do:
                    find  first gds-list no-lock
                        where gds-list.artic     = buf_goods.artic
                        and gds-list.prod-type = buf_goods.prod-type
                        and gds-list.prod-code = buf_goods.prod-code
                        no-error .
                        if not available gds-list then next.
                    
                end.
        
        when {&g-all}  then 
                do: /* все товары */
                end.
                
/*        when {&g-grp} then                                                    */
/*                do :                                                          */
/*                                                                              */
/*                    find   first tmp#grp no-lock                              */
/*                        where tmp#grp.node-code = buf_goods.grp-code no-error.*/
/*                    if not available tmp#grp then next.                       */
/*                end.                                                          */
/*                                                                              */
/*            otherwise                                                      */
/*            do:     /*список товаров*/                                     */
/*                find  first gds-list no-lock                               */
/*                    where buf_goods.artic     = gds-list.artic             */
/*                    and buf_goods.prod-type = gds-list.prod-type           */
/*                    and buf_goods.prod-code = gds-list.prod-code no-error .*/
/*                    if not available  gds-list then next.                  */
/*                                                                           */
/*            end.                                                           */
end case.
      
      
            if buf_chk-gds.write-off-code <> ? and
               buf_chk-gds.write-off-code > 0 then next _CHk.

           
       
                if prodmode = {&g-prod} then
                do:  /* if prodmode = {&g-prod} */
                    if not can-find(first g#cli no-lock where
                                          g#cli.obj-type = buf_goods.prod-type and
                                          g#cli.obj-code = buf_goods.prod-code) then next _chk.
                end.

                if prodmode = {&g-grp} then
                do:  /* if prodmode = {&g-grp} */
                    assign
                        v-grp-name = ""
                        v-found = no
                    .

                    _ii-grp: do ii-grp = 1 to num-entries(buf_goods.grp-name, {&delim-grp}) - 1     /* 1 */ /* где {&delim-grp} = CHR(47) = "/". Фактически это уровни вложенности данной группы товаров */
                    :
                        assign
                            v-grp-name = v-grp-name + entry(ii-grp, buf_goods.grp-name, {&delim-grp}) + {&delim-grp} /* Вытаскиваем из полной цепочки - имя каждой группы для каждого уровня. Цепочка от корня до тек группы. */
                        .
                        if can-find(first tmp#grp no-lock where
                                          tmp#grp.grp-name = v-grp-name) then
                        do:
                            assign v-found = yes.
                            leave _ii-grp.
                        end.
                    end. /* 1 */                                                                    /* 1 */

                    if not v-found then next _chk.

                end. /*if prodmode = {&g-grp} then do:*/

                if prodmode = {&g-choice} then
                do:
                    if not can-find(first gds-list no-lock where
                                          gds-list.gds-code = buf_goods.gds-code) then next _chk.
                end.
       
            find first dcards where
                       dcards.obj-type = v-obj-type and
                       dcards.obj-code = v-obj-code and
                   /*    dcards.chk-date = buf_chk-doc.chk-date and */
                       dcards.d-card = buf_chk-doc.d-card and
                       dcards.b-code = buf_bar-code.b-code /*and*/
            no-error.

            if not available dcards then
            do:  /* Создаём уникальную запись в dcards (Товар-Имя-Артикул-Производитель-КодГруппыТовара-Объект) */
                create dcards.
                assign
                    dcards.obj-type     = v-obj-type
                    dcards.obj-code     = v-obj-code
                    dcards.obj-name     = v-obj-name
                    dcards.chk-date     = buf_chk-doc.chk-date
                    dcards.shift-date   = buf_chk-doc.shift-date
                    dcards.chk-doc-code = buf_chk-doc.doc-code
                    dcards.d-card       = buf_chk-doc.d-card
                    dcards.artic        = buf_goods.artic
                    dcards.gds-name     = buf_goods.gds-name
                    dcards.b-code       = buf_bar-code.b-code
                    dcards.prod-type    = buf_goods.prod-type
                    dcards.prod-code    = buf_goods.prod-code
                    dcards.doc-qnty     = 0
                    dcards.grp-code     = buf_goods.grp-code
                    dcards.gds-code     = buf_goods.gds-code
                .
            end. /* Создаём уникальную запись в dcards (Товар-Имя-Артикул-Производитель-КодГруппыТовара-Объект) */


            v-first-of-d-card = yes.    /* Флаг вхождения в ДКарту № NNN */





            assign /* Дописываем в каждую запись dcards */
                dcards.doc-qnty = dcards.doc-qnty + buf_chk-gds.doc-qnty                    /*    Кол-во товара */
                dcards.sale-price = buf_chk-gds.price-base  
                dcards.sum = dcards.sum + (buf_chk-gds.doc-qnty * dcards.sale-price)                                /*    Продажная Цена товара */
                
                  
                 new-doc = no
                        dcards.cli-type-code = buf_chk-doc.cli-type + string(buf_chk-doc.cli-code)
                         dcards.discount = dcards.discount + (buf_chk-gds.doc-qnty *                 /* 5. Скидка по ТОВАРУ */
                                  (buf_chk-gds.discnt +
                                  (buf_chk-gds.price-base - buf_chk-gds.price-base)))
                        dcards.sum-withdisc = dcards.sum - dcards.discount 
                        dcards.counter = dcards.counter + 1 .
              
         

            
       for  first   chk-discnt where chk-discnt.line-num = buf_chk-gds.line-num and chk-discnt.doc-code = buf_chk-gds.doc-code and chk-discnt.record-type = 4 :
                        assign dcards.qnty-bonus =  dcards.qnty-bonus + chk-discnt.discnt-value-abs.
                     
                     
                end.


              
          
           
        end. /* _chk: for each buf_chk-gds */




        if v-first-of-d-card = yes  then 
        do:  
            find first buf-crd_dcards where
                       buf-crd_dcards.grp-lvl = 1000 and 
                       buf-crd_dcards.obj-type = v-obj-type and
                       buf-crd_dcards.obj-code = v-obj-code and
                       buf-crd_dcards.d-card = dcards.d-card 
/*                      and                                                 */
/*                       buf-crd_dcards.cli-type-code = dcards.cli-type-code*/
            no-lock no-error.

            if not available buf-crd_dcards then
            do:
                create buf-crd_dcards.
                assign
                    buf-crd_dcards.grp-lvl = 1000
                    buf-crd_dcards.obj-type = v-obj-type
                    buf-crd_dcards.obj-code = v-obj-code
                    buf-crd_dcards.d-card = dcards.d-card
                    buf-crd_dcards.cli-type-code = dcards.cli-type-code
                    .
                   
              
            end.
            
            

            if available buf-crd_dcards then
            do:
                buf-crd_dcards.counter = buf-crd_dcards.counter + 1.

               
                
            end.
      

    end. /* A. _chk: for each buf_chk-gds */
end.
end procedure. /* calc-chk */

procedure My-Rep:


    run get-full-path-RepViewer(output v-full-path-RepView).    /* Перед работой с "Просмотровщиком отчёта" (main.exe) - убедимся, что он существует и получим полный путь к нему. */

    run get-report-num in parParentProc(output g#report-num).   /* Получим СТАНДАРТНЫМ МЕТОДОМ ТН номер файла отчёта. */

    run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).   /* Сформируем стандартизованное в ТН имя файла отчёта. */

    run create-file(v-file-name-rep-htm).   /* Создадим на диске пустой файл со сформированным по стандарту именем файла. */

   case X-selectgood:
        when {&g-prod} then
        do:
            for each g#cli no-lock  /*  */
            :
                num-g# = num-g# + 1.
                if num-g# = 1 then FixProdAttr = g#cli.obj-type + string(g#cli.obj-code).
                if num-g# > 1 then leave.
            end.
        end.
        when {&g-grp} then
        do:
            for each tmp#grp no-lock
            :
                num-g# = num-g# + 1.
                if num-g# = 1 then FixProdAttr = string(tmp#grp.node-code).
                if num-g# > 1 then leave.
            end.
        end.
        when {&g-choice} or when {&g-one} then
        do:
            for each gds-list no-lock
            :
                num-g# = num-g# + 1.
                if num-g# = 1 then
                FixProdAttr = string(gds-list.gds-code).
                if num-g# > 1 then leave.
            end.
        end.
    end case.

 


    run waitfram-show in this-procedure ("Подождите ...").

    
        if prodmode = {&g-prod} then
        do:
            assign
                v-prod-type = Substr(FixProdAttr, 1, 3)         /* В режиме Один(ONE) - получение ТИПА объекта Производителя */
                v-prod-code = integer(substr(FixProdAttr, 4))   /* В режиме Один(ONE) - получение КОДА объекта Производителя */
            .
        end.

        if prodmode = {&g-grp} then
        do:
            assign
                v-grp-code = integer(FixProdAttr)               /* В режиме Один(ONE) - получение "временного" КОДА ГруппыТоваров */
            .

            run grplib-get-full-name in this-procedure (        /* Получение полного имени ГруппыТоваров (инклуд ref/grplibfn.i) */
                                                         input v-grp-code
                                                        ,output v-grp-name)
            .
        end.

        if prodmode = {&g-one} then
        do:
            assign
                v-gds-code = integer(FixProdAttr)               /* В режиме Один(ONE) - получение КОДА Товара */
            .
        end.
    /* end. /* if v-prodmode2 = "ONE" */*/

    for each obj-host:
        delete obj-host.
    end.
    create obj-host.
    assign
        obj-host.host-code = 0
    . /*для глобальных карт*/

    _obj: for each obj-list /* _obj: for each obj-list: */
    :
        /*найдем по каким фирмам мы елозим это зависит от переключателя X_selectobject*/
        if obj-list.obj-type = {&shop} then
        do:  /* if obj-list.obj-type = {&shop} */
            find first buf_shop no-lock where
            buf_shop.obj-code = obj-list.obj-code.

            find first obj-host no-lock where
            obj-host.host-code = buf_shop.host-code no-error.

            if not available obj-host then
            do:
                create obj-host.
                assign
                    obj-host.host-code = buf_shop.host-code
                .
            end.
        end. /* if obj-list.obj-type = {&shop} */
        else
        do:  /* if obj-list.obj-type <> {&shop} */
            find first buf_store no-lock where
            buf_store.obj-code = obj-list.obj-code.

            find first obj-host no-lock where
            obj-host.host-code = buf_store.host-code no-error.

            if not available obj-host then
            do:
                create obj-host.
                assign
                    obj-host.host-code = buf_store.host-code
                .
            end.
        end. /* if obj-list.obj-type <> {&shop} */

        if x-TOG-Shift = yes then
        do:  /* if x-TOG-Shift = yes */
            if can-find(first ub.chk-doc where
            ub.chk-doc.obj-type = obj-list.obj-type and
            ub.chk-doc.obj-code = obj-list.obj-code and
            (ub.chk-doc.shift-date >= X-date-Start) and
            (ub.chk-doc.shift-date <= X-date-End) and
            ub.chk-doc.d-card <> "" and
            ub.chk-doc.out-code > "" ) then
                do:
                    _chk-doc1: for each buf_chk-doc no-lock where
                    buf_chk-doc.obj-type = obj-list.obj-type and
                    buf_chk-doc.obj-code = obj-list.obj-code and
                    (buf_chk-doc.shift-date > X-date-Start or (buf_chk-doc.shift-date = X-date-Start and buf_chk-doc.shift-num >= x-Shift-Start)) and
                    (buf_chk-doc.shift-date < X-date-End or (buf_chk-doc.shift-date = X-date-End and buf_chk-doc.shift-num <= x-Shift-End)) and
                    buf_chk-doc.d-card <> "":U and                  /* ДКарта */
                    buf_chk-doc.out-code <> ?                       /* Номер расходного документа не пустой. Т.е. учтённые Чеки */
                    :
                        do:
                            if lookup(string(buf_chk-doc.chk-type), {&no-d-card-receipt-codes}) > 0 then next _chk-doc1.
                            run calc-chk.
                        end.
                    end.    /* FOR EACH buf_chk-doc WHERE ... */
                end.
        end. /* if x-TOG-Shift = yes */
        else
        do:  /* if x-TOG-Shift = no */
            if can-find(first chk-doc where
            chk-doc.obj-type = obj-list.obj-type and
            chk-doc.obj-code = obj-list.obj-code and
            chk-doc.chk-date >= X-date-Start and
            chk-doc.chk-date <= X-date-End and
            chk-doc.d-card <> "" and
            chk-doc.out-code > "" ) then
            do:
                _chk-doc: for each buf_chk-doc no-lock where
                buf_chk-doc.obj-type = obj-list.obj-type and
                buf_chk-doc.obj-code = obj-list.obj-code and
                buf_chk-doc.chk-date >= X-date-Start and
                buf_chk-doc.chk-date <= X-date-End and
                buf_chk-doc.d-card <> "":U and
                buf_chk-doc.out-code <> ?
                :
                    do:
                        if lookup(string(buf_chk-doc.chk-type), {&no-d-card-receipt-codes}) > 0 then next _chk-doc.
                        run calc-chk.
                    end.
                end.    /* FOR EACH buf_chk-doc WHERE ... */
            end.

            /*
            При необходимости учета по покупкам постоянных оптовиков -
            добавить кусок, аналогичный тому, что есть в   x l s e a s o n . w
            отчет по производителю и классификатору
            */
        end. /* if x-TOG-Shift = no */

        if  p-T-obj-detal = yes /*and t-imp = no*/ then
        do:  /* Цель - только если dcards не пустая - разрешаем работать с Блоком формирования Групп в линейной таблице dcards с Детализацией по Объектам и с учётом флага "Детилизировано по Объекту" */
            if can-find(first dcards) then /* Если таблица dcards пуста - исключаем мусор (не может быть итогов, что ниже, без первичных данных) */
            do:  /* Блок формирования групп в линейной таблице dcards с Детализацией по Объектам и с учётом флага "Детилизировано по Объекту" | "Не детализировано по Объекту" */
                /* обнулить объектные переменные */
                assign
                    v-obj-chk-counter = 0
                    v-obj_doc-qnty = 0          /* Количество */
                    v-obj_sum-withdisc = 0   /* Сумма без скидки */
                    v-obj_qnty-bonus = 0
                .

                for each buf-obj_dcards where
                         buf-obj_dcards.obj-type = obj-list.obj-type and
                         buf-obj_dcards.obj-code = obj-list.obj-code and
                         buf-obj_dcards.grp-lvl = 0   
                break
                    by buf-obj_dcards.d-card
                :
                    if first-of(buf-obj_dcards.d-card) then
                    do:  /* if first-of(buf-obj_dcards.d-card) */
                        run transform-tt-level(input buf-obj_dcards.obj-type, input buf-obj_dcards.obj-code, input buf-obj_dcards.d-card /*, input dcards.obj-name*/ ). /* Преобразование созданной выше dcards в таблицу с уровнями и итогами по каждому уровню. */
                        do:  /* Переменные по уровню ДКарта - сбрасываются для нового обсчёта (обнуляются) */
                            assign
                                v-dcard_doc-qnty = 0        /* Количество */
                                v-dcard_sum-withdisc = 0 /* Сумма без скидки */
                                v-dcard_qnty-bonus = 0        /* Скидка */
                            .
                        end. /* Переменные по уровню ДКарта - сбрасываются для нового обсчёта (обнуляются) */
                    end. /* if first-of(buf-obj_dcards.d-card) */

                    /* Переменные по уровню "ДКарта" рассчитываются */
                    assign
                        v-dcard_doc-qnty = v-dcard_doc-qnty + buf-obj_dcards.doc-qnty               /* Карта. Количество */
/*                        v-dcard_sum-withoutdisc = v-dcard_sum-withoutdisc + buf-obj_dcards.sum      /* Карта. Сумма без скидки */*/
                        v-dcard_sum-withdisc = v-dcard_sum-withdisc + buf-obj_dcards.sum-withdisc   /* Карта. Сумма со скидкой */
                        v-dcard_qnty-bonus = v-dcard_qnty-bonus + buf-obj_dcards.qnty-bonus               /* Карта. Скидка */
                    .

                    /* Переменные по уровню "Объект" рассчитываются */
                    assign
/*                         v-obj-chk-counter = v-obj-chk-counter + buf-obj_dcards.counter          /* Кол-во Чеков по Объекту */*/
                         v-obj_doc-qnty = v-obj_doc-qnty + buf-obj_dcards.doc-qnty               /* Объект. Количество */
/*                        v-obj_sum-withoutdisc = v-obj_sum-withoutdisc + buf-obj_dcards.sum      /* Объект. Сумма без скидки */*/
                        v-obj_sum-withdisc = v-obj_sum-withdisc + buf-obj_dcards.sum-withdisc   /* Объект. Сумма со скидкой */
                       v-obj_qnty-bonus = v-obj_qnty-bonus + buf-obj_dcards.qnty-bonus               /* Объект. Скидка */
                    .
                    if last-of(buf-obj_dcards.d-card) then
                    do:
                        /* create buf-crd_dcards.*/ /* Внимание! Создание уровня для ДКарты мы теперь определили выше по коду из-за трудностей с расчётом кол-ва чеков по ДКартам */
                        find first buf-crd_dcards where
                                   buf-crd_dcards.grp-lvl = 1000 and
                                   buf-crd_dcards.obj-type = buf-obj_dcards.obj-type and
                                   buf-crd_dcards.obj-code = buf-obj_dcards.obj-code and
                                   buf-crd_dcards.d-card = buf-obj_dcards.d-card 
                                   /* and
                                   buf-crd_dcards.cli-type-code = buf-obj_dcards.cli-type-code */
                        no-error.

                        for first buf_clients where /* Получаем "Наименование клиента" (в данном случае - держателя ДКарты) */
                                  buf_clients.obj-type = substring(buf-obj_dcards.cli-type-code, 1, 3) and
                                  buf_clients.obj-code = integer(substring(buf-obj_dcards.cli-type-code, 4))
                        :
                            buf-crd_dcards.gds-name = buf_clients.obj-name.
                        end.

                        /* Итоговые суммы по ДКартe */
                        assign
                            buf-crd_dcards.doc-qnty = v-dcard_doc-qnty            /* Количество */
                            buf-crd_dcards.sum-withdisc = v-dcard_sum-withdisc          /* Сумма без скидки */
                            buf-crd_dcards.qnty-bonus = v-dcard_qnty-bonus            
                        .
    
                        /* Только по Кол-ву чеков ДКарт - суммируем Кол-во чеков по Объекту!!! */
                        v-obj-chk-counter = v-obj-chk-counter + buf-crd_dcards.counter.
    
                    end.
                end. /* for each buf-obj_dcards */

                /* Для условия "Детализация по объектам" = yes - здесь будут суммы-итоги по КАЖДОМУ объекту; а если = no - см блок "if p-T-obj-detal = no", для него здесь будет общая сумма по всем ДК и всем объектам */
                find first buf-obj1_dcards where /* Этот find first - Цель - для режима "Без детализации по Объектам" - не записывать пустые строки с кодом 2000. Иначе по циклу obj-list создадутся лишние для этого режима строки с одинаковыми полями!) */
                          buf-obj1_dcards.grp-lvl = 2000 and
                          buf-obj1_dcards.obj-type = obj-list.obj-type and
                          buf-obj1_dcards.obj-code = obj-list.obj-code and
                          buf-obj1_dcards.obj-name = obj-list.obj-name
                no-lock no-error.
                if not available buf-obj1_dcards then
                do:
                    create buf-obj1_dcards.         /* Цель - для режима "С детализ по Объекту"-здесь суммы всех ДК по Объекту; для режима "Без детализ по Объекту"(см цикл заполнения ниже "if p-T-obj-detal = no")-здесь будут суммы по всем ДК и всем объектам. */
                    assign
                        buf-obj1_dcards.grp-lvl = 2000
                        buf-obj1_dcards.obj-type = obj-list.obj-type
                        buf-obj1_dcards.obj-code = obj-list.obj-code
                        buf-obj1_dcards.obj-name = obj-list.obj-name
                    .
                end.
                if available buf-obj1_dcards then
                do:
                    /* Итоговые суммы по Объекту */
                    assign
                        buf-obj1_dcards.counter = v-obj-chk-counter          /* Кол-во Чеков по Объекту */
                        buf-obj1_dcards.doc-qnty = v-obj_doc-qnty         /* Количество */
/*                        buf-obj1_dcards.sum-withdisc = v-obj_sum-withdisc         /* Сумма без скидки */*/
                        buf-obj1_dcards.sum-withdisc = v-obj_sum-withdisc   /* Сумма со скидкой */
                        buf-obj1_dcards.qnty-bonus = v-obj_qnty-bonus           /* Скидка */
                    .
                end.
            end. /* Блок формирования групп в линейной таблице dcards с Детализацией по Объектам */
        end. /* Цель - только если dcards не пустая - разрешаем работать с Блоком формирования Групп в линейной таблице dcards с Детализацией по Объектам и с учётом флага "Детилизировано по Объекту" */
    end.                    /* _obj: for each obj-list: */


    /* Блок кода "подхватывает" сформированную выше dcards (см. _obj: for each obj-list:...) только для выбранного условия - Без детализациии по объектам!!! */
    /* Цель2 - по каждому Объекту есть повторяющиеся ДКарты(с итогами) - объединяем их в один итог по ДКарте */
    if p-T-obj-detal = no /*and t-imp = no*/ then
    do:  /* if p-T-obj-detal = no */
        if can-find(first dcards) then
        do:  /* Блок формирования групп с итогами в линейной таблице dcards по №ДКарт БЕЗ Детализации по Объектам */

            /* обнулить "АРЕНДОВАННЫЕ" переменные (изначально созданные для работы по Объектам, а сейчас - необходимо рассчитать аналогично сумму по всем ДК). Т.е арендуем, чтобы не создавать аналогичные по типу лишние переменные. */
            assign
                  v-obj-chk-counter = 0
                    v-obj_doc-qnty = 0          /* Количество */
                    v-obj_sum-withdisc = 0   /* Сумма без скидки */
  v-obj_qnty-bonus = 0.

            for each buf-obj3_dcards where
                     buf-obj3_dcards.grp-lvl = 0
            break
                by buf-obj3_dcards.d-card
            :
                if first-of(buf-obj3_dcards.d-card) then
                do:  /* if first-of(buf-obj3_dcards.d-card) */
                    run transform-tt-level(input buf-obj3_dcards.obj-type, input buf-obj3_dcards.obj-code, input buf-obj3_dcards.d-card /*, input dcards.obj-name*/ ). /* Преобразование созданной выше dcards в таблицу с уровнями и итогами по каждому уровню. */
                    do:  /* Переменные по уровню ДКарта - сбрасываются для нового обсчёта (обнуляются) */
                        assign
                            v-dcard_doc-qnty = 0        /* Количество */
/*                            v-dcard_sum-withoutdisc = 0 /* Сумма без скидки */*/
                            v-dcard_sum-withdisc = 0    /* Сумма со скидкой */
                            v-dcard_qnty-bonus = 0       
                        .
                    end. /* Переменные по уровню ДКарта - сбрасываются для нового обсчёта (обнуляются) */
                end. /* if first-of(buf-obj3_dcards.d-card) */

                /* Переменные по уровню "ДКарта" рассчитываются (наполняем итог определённой ДКарты) */
                assign
                    v-dcard_doc-qnty = v-dcard_doc-qnty + buf-obj3_dcards.doc-qnty               /* Карта. Количество */
/*                    v-dcard_sum-withoutdisc = v-dcard_sum-withoutdisc + buf-obj3_dcards.sum      /* Карта. Сумма без скидки */*/
                    v-dcard_sum-withdisc = v-dcard_sum-withdisc + buf-obj3_dcards.sum-withdisc   /* Карта. Сумма со скидкой */
                    v-dcard_qnty-bonus = v-dcard_qnty-bonus + buf-obj3_dcards.qnty-bonus               /* Карта. Скидка */
                .

               
                assign /* ВНИМАНИЕ!!! Делаем "АРЕНДУ" переменных созданных для Объектов, чтобы не создавать схожие новые переменные!!!!! */
/*                    v-obj_sum-withoutdisc = v-obj_sum-withoutdisc + buf-obj3_dcards.sum      /* По всем ДК и Объектам. Сумма без скидки */*/
                    v-obj_sum-withdisc = v-obj_sum-withdisc + buf-obj3_dcards.sum-withdisc   /* По всем ДК и Объектам. Сумма со скидкой */
                    v-obj_qnty-bonus = v-obj_qnty-bonus + buf-obj3_dcards.qnty-bonus               /* По всем ДК и Объектам. Скидка */
                .

                if last-of(buf-obj3_dcards.d-card) then
                do:  /* По завершении группы d-card - позиционируемся на grp-lvl = 1000 и записываем туда окончательные итоги */
                    /* Внимание! Создание уровня для ДКарты определены выше по коду из-за трудностей с расчётом кол-ва чеков по ДКартам */
                    find first buf-crd_dcards where
                               buf-crd_dcards.grp-lvl = 1000 and
                               buf-crd_dcards.obj-type = buf-obj3_dcards.obj-type and
                               buf-crd_dcards.obj-code = buf-obj3_dcards.obj-code and
                               buf-crd_dcards.d-card = buf-obj3_dcards.d-card 
                               /* and
                               buf-crd_dcards.cli-type-code = buf-obj3_dcards.cli-type-code */
                    no-lock no-error.
                    if available buf-crd_dcards then
                    do:
                        for first buf_clients where /* Получаем "Наименование клиента" (в данном случае - держателя ДКарты) */
                                  buf_clients.obj-type = substring(buf-obj3_dcards.cli-type-code, 1, 3) and
                                  buf_clients.obj-code = integer(substring(buf-obj3_dcards.cli-type-code, 4))
                        :
                            buf-crd_dcards.gds-name = buf_clients.obj-name.
                        end.

                        /* Итоговые суммы по ДКартe */
                        assign
                            buf-crd_dcards.doc-qnty = v-dcard_doc-qnty            /* Количество */
/*                            buf-crd_dcards.sum = v-dcard_sum-withoutdisc          /* Сумма без скидки */*/
                            buf-crd_dcards.sum-withdisc = v-dcard_sum-withdisc    /* Сумма со скидкой */
                            buf-crd_dcards.qnty-bonus = v-dcard_qnty-bonus          
                        .

                        /* Только по Кол-ву чеков ДКарт - суммируем Кол-во все ДКарты!!! */
                        v-obj-chk-counter = v-obj-chk-counter + buf-crd_dcards.counter.

                    end.
                end.
            end. /* for each buf-obj3_dcards */

            if can-find(first dcards) then /* Если таблица dcards пуста - исключаем мусор (не может быть этих итогов без первичных данных) */
            do:  /* Если таблица dcards не пустая - создаём запись с итогами по всем ДК */
                create buf-obj1_dcards.         /* Цель - для режима "Без детализ по Объекту" - здесь суммы по всем ДК и всем объектам и вывод строки в отчёт: "Итого по всем ДКартам". */
                assign
                    /* buf-obj1_dcards.obj-type = ""*/
                    /* buf-obj1_dcards.obj-code = 0 */
                    buf-obj1_dcards.obj-name = "ИТОГО"
                    buf-obj1_dcards.grp-lvl = 2000            
                    buf-obj1_dcards.counter = v-obj-chk-counter         /* Кол-во Чеков по Объекту */
                    buf-obj1_dcards.sum-withdisc = v-obj_sum-withdisc         /* Сумма без скидки */
                    buf-obj1_dcards.qnty-bonus = v-obj_qnty-bonus         
                .
                release buf-obj1_dcards.
            end. /* Если таблица dcards не пустая - создаём запись с итогами по всем ДК */
        end. /* Блок формирования групп с итогами в линейной таблице dcards по №ДКарт БЕЗ Детализации по Объектам */
    end. /* if p-T-obj-detal = no */


 
                                                                                                                                                                   

/*            do:  /* В ИТОГО по ДК lvl=2000 - добавим суммы ДК_из_ВС */                                                                       */
/*                for first buf-obj1_dcards where                                                                                              */
/*                          buf-obj1_dcards.obj-name   = "ИТОГО" and                                                                           */
/*                          buf-obj1_dcards.grp-lvl    = 2000                                                                                  */
/*                no-lock                                                                                                                      */
/*                :                                                                                                                            */
/*                    assign                                                                                                                   */
/*                        buf-obj1_dcards.counter = buf-obj1_dcards.counter + v-obj_doc-qnty  /* Кол-во платежей по ДК импортированной из ВС */*/
/*                        buf-obj1_dcards.sum = buf-obj1_dcards.sum + v-obj_sum-withoutdisc   /* Сумма по ДК импортированной из ВС */          */
/*                        /* buf-obj1_dcards.sum-withdisc = v-obj_sum-withdisc   /* Сумма со скидкой */*/                                      */
/*                         buf-obj1_dcards.qnty-bonus = v-obj_qnty-bonus           /* Скидка */                                                */
/*                    .                                                                                                                        */
/*                    release buf-obj1_dcards.                                                                                                 */
/*                end.                                                                                                                         */
/*            end. /* В ИТОГО по ДК lvl=2000 - добавим суммы ДК_из_ВС */                                                                       */
/*                                                                                                                                             */


    run waitfram-hide in this-procedure.

    /* ---------------------------------------------------------------------------------------- */
    /* Начало. Заполнение шапки отчёта (видимой как не таблица)                                 */
    if can-find(first dcards) then
    do:  /* if can-find(first dcards) */
        run prn-lib-open-stream in this-procedure (
                                                     input my-handle
                                                    ,input {&LS_PS_A4}
                                                    ,input yes /*p-is-stream*/
                                                    ,input no /*p-append*/
                                                   ).
        Line = fill("-", 200).
        form header
            line format "X(184)" at 1 skip
            "Продолжение - на следующей странице" at 30 skip
            with frame BottomFrame width {&DOS_CW_2} page-bottom no-labels no-box
        .
        view stream PrnLibStream frame BottomFrame.

        /*    v-mes-noAll-chk = (if NotInc then "(сформирован НЕ ПО ВСЕМ ЧЕКАМ)" else "").*/

        /*    for each obj-list:                                                             */
        /*        find first buf_clients where                                               */
        /*                   buf_clients.obj-type = obj-list.obj-type and                    */
        /*                   buf_clients.obj-code = obj-list.obj-code                        */
        /*        no-lock.                                                                   */
        /*        find first ub.db where                                                     */
        /*                   ub.db.db-num = buf_clients.db-num                               */
        /*        no-lock.                                                                   */
        /*        string(trim(string(ub.db.db-name, "X(30)")) + " / " + buf_clients.obj-name)*/

        /*    end. /*FOR EACH obj-list :*/*/

        /* Начало заполнение таблицы отчёта */
        assign
            /* Наименование отчёта */
            v-report-name = "Отчет по бонусам"
        .
        assign
            /* Период, за который формируется отчёт */
            v-period = str1
        .
        assign
            /* Условно. Выводится информационное сообщение в случае формирования отчёта не по всем чекам */
            v-msg-noAllChk = (if NotInc then "(сформирован НЕ ПО ВСЕМ ЧЕКАМ)" else "")
        .

        put stream PrnLibStream
            space(40) "Отчет по бонусам" skip
            space(40) str1 format "X(60)" skip
            space(20) (if NotInc then "(сформирован НЕ ПО ВСЕМ ЧЕКАМ)" else " ") format "x(40)" skip
            space(20) "По объектам :"
        .

        _short-list: for each obj-list no-lock
        :
            find first buf_clients where
                       buf_clients.obj-type = obj-list.obj-type and
                       buf_clients.obj-code = obj-list.obj-code no-lock
            .
            find first ub.db where
                       ub.db.db-num = buf_clients.db-num no-lock
            .

           
            do:  /* Список объектов "в одну строку" */
                v-short-obj-list = v-short-obj-list + (if length(v-short-obj-list) > 0 then ";  " else "") + /*trim(string(ub.db.db-name, "x(30)")) + " / " +*/ buf_clients.obj-name.

                if length(v-short-obj-list) > 100 then
                do:
                    v-short-obj-list = substring(v-short-obj-list, 1, 100) + "...".
                    leave _short-list.
                end.
            end. /* Список объектов "в одну строку" */



        end. /* FOR EACH obj-list: */

     

        case DcardMode: /* Закладка-2 "Покупатели": (Все|Выборочно по картам) */
            when "ALL":U then
            do:
                v-sel-card-string = "Покупатели: По ВСЕМ картам.".

            end.
            when "ONE":U then do:
                end.
   
            when "LIST":U then
            do:
                ii = 0.
                for each dc-list no-lock
                :
                    ii = ii + 1.
                end.

                v-sel-card-string = "Покупатели : По сформированному списку карт" + "(в списке " + string(ii) + " кар.)".

                do:  /* Откл. вывода отчёта на экран. ТН-3320 Арн. */
                    put stream PrnLibStream
                        space(10) string("По сформированному списку карт") format "x(50)" skip
                        substitute("В списке &1 карт", ii) skip
                    .
                end. /* Откл. вывода отчёта на экран. ТН-3320 Арн. */

            end.
        end case.       /* Закладка-2 "Покупатели": (Все|Выборочно по картам) */

        if X-SelectGood = {&g-all} then
        do:
/*            create tt-selectgood.                                                           */
/*            tt-selectgood.collection-name = "По ВСЕМ производителям (поставщикам).".        */
/*/*            v-prod-mode-string = "По ВСЕМ производителям (поставщикам).".*/               */
/*                                                                                            */
/*            do:  /* Откл. вывода отчёта на экран. ТН-3320 Арн. */                           */
/*                put stream PrnLibStream                                                     */
/*                    space(20) "По ВСЕМ производителям (поставщикам)." format "x(40)" skip(1)*/
/*                .                                                                           */
/*            end. /* Откл. вывода отчёта на экран. ТН-3320 Арн. */                           */

        end.
        else
        do:
            case X-selectgood: /* Закладка-1 "Выбор товаров" (Все|Группы товаров|Производители|Выборочно|Один) */
                when {&g-prod} then
                do:
                    do:  /* Откл. вывода отчёта на экран. ТН-3320 Арн. */
                        put stream PrnLibStream
                        space(20) "По производителям: " format "x(80)" skip(0).
                    end. /* Откл. вывода отчёта на экран. ТН-3320 Арн. */

                    _g#cli: for each g#cli
                    :
                        do:  /* Откл. вывода отчёта на экран. ТН-3320 Арн. */
                            put stream PrnLibStream
                                space(20) g#cli.obj-name format "x(80)" skip(0)
                            .
                        end. /* Откл. вывода отчёта на экран. ТН-3320 Арн. */

                        if available tt-selectgood then                                             /* Нюанс заполнения таблицы tt-selectgood */
                        do:                                                                         /* Нюанс заполнения таблицы tt-selectgood */
                            if tt-selectgood.collection-element = g#cli.obj-name then next.         /* Нюанс заполнения таблицы tt-selectgood */
                        end.                                                                        /* Нюанс заполнения таблицы tt-selectgood */
                        else
                        do:
                            create tt-selectgood.                                                    /* Нюанс заполнения таблицы tt-selectgood */
                            /* tt-selectgood.collection-element = g#cli.obj-name. /* Производитель */      /* Откл. построчное создание Производителя, см. реализацию его "одной строкой". Нюанс заполнения таблицы tt-selectgood */*/
                            /* tt-selectgood.collection-element = tt-selectgood.collection-element + g#cli.obj-name + "; ".*/
                        end.
                        if available tt-selectgood then
                        do:  /* if available tt-selectgood */
                            tt-selectgood.collection-element = tt-selectgood.collection-element + g#cli.obj-name + "; ".
                            if length(tt-selectgood.collection-element) > 100 then
                            do:
                                tt-selectgood.collection-element = substring(tt-selectgood.collection-element, 1, 100). /* Обрезаем строку до допустимых 100 симв (это с учётом последующего добавления концевика-троеточия: "..." чуть ниже!) */
                                tt-selectgood.collection-element = right-trim(tt-selectgood.collection-element, " "). /* очистка от концевого пробела " " */
                                tt-selectgood.collection-element = right-trim(tt-selectgood.collection-element, ";"). /* очистка от концевого разделителя ";" */
                                tt-selectgood.collection-element = tt-selectgood.collection-element + "...". /* добавка окончания "..." */
                                leave _g#cli.
                            end.
                        end. /* if available tt-selectgood */
                    end. /* for each g#cli */                                                       /* Нюанс заполнения таблицы tt-selectgood */
                    find first tt-selectgood no-lock no-error.                                      /* Нюанс заполнения таблицы tt-selectgood */
                    if not available tt-selectgood then                                             /* Нюанс заполнения таблицы tt-selectgood */
                    do:                                                                             /* Нюанс заполнения таблицы tt-selectgood */
                        create tt-selectgood.                                                       /* Нюанс заполнения таблицы tt-selectgood */
                    end.                                                                            /* Нюанс заполнения таблицы tt-selectgood */
                    tt-selectgood.collection-name = "Выбор товара: По производителям:".                           /* Нюанс заполнения таблицы tt-selectgood */
                end.
                when {&g-grp} then
                do:
                    do:  /* Откл. вывода отчёта на экран. ТН-3320 Арн. */
                        put stream PrnLibStream
                            space(20) "Выбор товара: По группам товаров: " format "x(80)" skip(0)
                        .
                    end. /* Откл. вывода отчёта на экран. ТН-3320 Арн. */

                    _tmp#grp: for each tmp#grp
                    :
                        do:  /* Откл. вывода отчёта на экран. ТН-3320 Арн. */
                            put stream PrnLibStream
                                space(20) tmp#grp.grp-name format "x(80)" skip(0)
                            .
                        end. /* Откл. вывода отчёта на экран. ТН-3320 Арн. */

                        if available tt-selectgood then                                             /* Нюанс заполнения таблицы tt-selectgood */
                        do:                                                                         /* Нюанс заполнения таблицы tt-selectgood */
                            if tt-selectgood.collection-element = tmp#grp.grp-name then next.       /* Нюанс заполнения таблицы tt-selectgood */
                        end.                                                                        /* Нюанс заполнения таблицы tt-selectgood */
                        else
                        do:
                            create tt-selectgood.                                                   /* Нюанс заполнения таблицы tt-selectgood */
                            /*tt-selectgood.collection-element = tmp#grp.grp-name. /* Откл. построчное формирование групп товаров(списка). Переделал в представление: "в одну строку" Группа товаров */   /* Нюанс заполнения таблицы tt-selectgood */*/
                        end.
                        if available tt-selectgood then
                        do:  /* if available tt-selectgood */
                            tt-selectgood.collection-element = tt-selectgood.collection-element + tmp#grp.grp-name + "; ".
                            if length(tt-selectgood.collection-element) > 100 then
                            do:
                                tt-selectgood.collection-element = substring(tt-selectgood.collection-element, 1, 100). /* Обрезаем строку до допустимых 100 симв (это с учётом последующего добавления концевика-троеточия: "..." чуть ниже!) */
                                tt-selectgood.collection-element = right-trim(tt-selectgood.collection-element, " "). /* очистка от концевого пробела " " */
                                tt-selectgood.collection-element = right-trim(tt-selectgood.collection-element, ";"). /* очистка от концевого разделителя ";" */
                                tt-selectgood.collection-element = tt-selectgood.collection-element + "...". /* добавка окончания "..." */
                                leave _tmp#grp.
                            end.
                        end. /* if available tt-selectgood */
                    end.                                                                            /* Нюанс заполнения таблицы tt-selectgood */
                    find first tt-selectgood no-lock no-error.                                      /* Нюанс заполнения таблицы tt-selectgood */
                    if not available tt-selectgood then                                             /* Нюанс заполнения таблицы tt-selectgood */
                    do:                                                                             /* Нюанс заполнения таблицы tt-selectgood */
                        create tt-selectgood.                                                       /* Нюанс заполнения таблицы tt-selectgood */
                    end.                                                                            /* Нюанс заполнения таблицы tt-selectgood */
                    tt-selectgood.collection-name = " По группам товаров:".                          /* Нюанс заполнения таблицы tt-selectgood */
                end.                                                                                
                when {&g-choice} then
                do:
                    ii = 0.
                    for each gds-list
                    :
                        ii = ii + 1.
                    end.

                    create tt-selectgood.
                    tt-selectgood.collection-name = " По сформированному списку товаров " + "(В списке " + string(ii) + " товаров).".

                    do:  /* Откл. вывода отчёта на экран. ТН-3320 Арн. */
                        put stream PrnLibStream
                            space(10) "По сформированному списку товаров " format "x(50)"
                            substitute("(В списке &1 товаров)", ii) skip
                        .
                    end. /* Откл. вывода отчёта на экран. ТН-3320 Арн. */
                end.
                when {&g-one} then
                do:
                    find first gds-list
                    .
                    create tt-selectgood.
                    tt-selectgood.collection-name = "Выбор товара:".
                    tt-selectgood.collection-element = string(gds-list.artic) + {&space-char} +
                                                      gds-list.prod-type + string(gds-list.prod-code) +
                                                      {&space-char} + gds-list.gds-name
                    .

                    do:  /* Откл. вывода отчёта на экран. ТН-3320 Арн. */
                        put stream PrnLibStream
                            space(20) "По товару: " format "x(10)"
                            gds-list.artic {&space-char} gds-list.prod-type gds-list.prod-code {&space-char} gds-list.gds-name skip(0)
                        .
                    end. /* Откл. вывода отчёта на экран. ТН-3320 Арн. */
                end.
            end case. /* X-selectgood: */

        end. /* else от if X-SelectGood = {&g-all} then do:*/

     

str1 = (if X-TOG-Shift then "С " + fnc-DD-MM-YYYY(date(string(X-Date-Start,"99/99/9999"))) + ", смена № "  + string(X-Shift-Start) +
                                " по " + fnc-DD-MM-YYYY(date(string(X-Date-End,"99/99/9999"))) + ", смена № " + string(X-Shift-End)
                           else
                                "За период с " + fnc-DD-MM-YYYY(date(string(X-Date-Start,"99/99/9999"))) + " по " + fnc-DD-MM-YYYY(date(string(X-Date-End,"99/99/9999")))
    ).

        run proc-create-HTML(
                                 input v-file-name-rep-htm
                                ,input v-report-name
                                ,input str1
                            ).

        run search-full-path-Report(input v-file-name-rep-htm). /* Проверка на наличие файла-отчёта, перед использованием его в RepViewer */

        run Report-Viewer(input v-full-path-RepView, input v-file-name-rep-htm). /* Запуск просмотровщика отчёта RepViewer */

    end. /* if can-find(first dcards) */
    else
    do:  /* if not can-find(first dcards) */
        message
            "На выбранных Вами объектах" skip
            "не было продаж " skip
            "в течение заданного Вами периода времени."
        view-as alert-box information.
        for each dcards:
            delete dcards.
        end.
    end. /* if not can-find(first dcards) */
/* **************************************** */
/* **************************************** */

end procedure. /* My-Rep */

procedure proc-create-HTML:
/* Вывод отчёта в файл html и через ReportView в Excel */

    define input parameter p-file-name-rep-htm as character no-undo.
    define input parameter p-report-name as character no-undo.
    define input parameter p-period as character no-undo.

    define variable v-message as character no-undo. 

    define buffer buf-html_clients for ub.clients.
    define buffer buf-obj2_dcards for dcards. /* Буфер для выборки по Объектам */
    define buffer buf-crd2_dcards for dcards. /* Буфер для выборки по ДКартам */
    define buffer buf-crd-imp_dcards for dcards. /* Буфер для выборки по ДКартам_из_Импорта */

    /* Системная шапка HTML */
    do:  /* Системная шапка HTML */
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
            put stream OutStr-html unformatted
                "<!DOCTYPE HTML>" skip
                ' <html>' skip
                '  <head>' skip
                '   <meta charset="utf-8">' skip
                '    <style type="text/css">' skip
                '      table ' + chr(123) + ' border-collapse: collapse; font-size: 9pt; table-layout: fixed; width: 500px; padding: 3px; ' + chr(125) skip
                '      td ' + chr(123) ' border: 1px black ridge; word-wrap:break-word; ' + chr(125) skip
                '      htm' skip
                '      .rotate ' + chr(123) skip
                '        -webkit-transform: rotate(-90deg);' skip
                '        -moz-transform: rotate(-90deg);' skip
                '        -ms-transform: rotate(-90deg);' skip
                '        -o-transform: rotate(-90deg);' skip
                '        transform: rotate(-90deg);' skip

                /* also accepts left, right, top, bottom coordinates; not required, but a good idea for styling */
                '        -webkit-transform-origin: 50% 50%;' skip
                '        -moz-transform-origin: 50% 50%;' skip
                '        -ms-transform-origin: 50% 50%;' skip
                '        -o-transform-origin: 50% 50%;' skip
                '        transform-origin: 50% 50%;' skip

                /* Should be unset in IE9+ I think.*/
                '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
                '          ' + chr(125) skip
                '            th' + ' ' + chr(123) skip
                '            border: 1px black solid;' skip
                '            word-wrap: break-word;' skip
                '          ' + chr(125) skip
                '   </style>' skip
                '  </head>' skip
            . /* Точка для закрытия Put */
    end. /* Системная шапка HTML */

    /* Установка системных параметров "глобальной" таблицы всего отчёта (кол-во и размерность колонок) */
    do:  /* Параметры "глобальной" таблицы отчёта */
            put stream OutStr-html unformatted
                ' <body>' skip
                '   <table name="Лист1" outline_below="false" orientation="Portrait" fit_to_page="true" >' skip
                '     <thead>' skip
                '       <tr class="set_columns">' skip                          /* Ниже - условная привязка-ориентир к разграфлённой таблице!!! */
                '         <td style="width: 150px; border: none;"></td>' skip   /* 1. Карта№ / Артикул */
                '         <td style="width: 200px; border: none;"></td>' skip   /* 2. Наименование */
                '         <td style="width: 130px; border: none;"></td>' skip    /* 3. Кол-во чеков */
                '         <td style="width: 80px; border: none;"></td>' skip    /* 4. Сумма */
             '         <td style="width: 80px; border: none;"></td>' skip   /* 5. Бонусы */
                '       </tr>' skip
            . /* Точка для закрытия Put */
    end. /* Параметры "глобальной" таблицы отчёта */

    /* Заполнение "глобальной" таблицы - блок шапки отчёта (часть отчёта, видимая как "не таблица") */
    do:  /* Шапка отчёта (видимого, как не таблица) */
            put stream OutStr-html unformatted
                '       <tr>' skip /* Строчный пункт-1. Пустая строка */
                '         <td style="border: none; height: 14px"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
           
                '       </tr>' skip
                '       <tr>' skip /* Строчный пункт-2. Наименование отчёта */
                '         <td colspan="5" style="border: none; height: 14px; font-weight: bold; text-align: center">' + p-report-name + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
        
                '       </tr>' skip
                '       <tr>' skip /* Строчный пункт-3. Период */
                '         <td colspan="5" style="border: none; height: 14px; font-weight: bold; text-align: center">' + p-period + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
        
                '       </tr>' skip
                '       <tr>' skip /* Строчный пункт-4. Пустая строка */
                '         <td style="border: none; height: 14px; font-weight: bold"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
            
                '       </tr>' skip
            .

            /* Строчный пункт-5(условный). Выводим предупреждающее сообщение в отчёт если: отчёт сформирован не по всем чекам. */
            if NotInc then
            do:
                run msg-html-noAllChk(output v-message).
                put stream OutStr-html unformatted
                    v-message
                .
            end.

            put stream OutStr-html unformatted
                '       <tr>' skip /* Строчный пункт-6. Наименование = "По объектам:" */
                '         <td colspan="5" style="border: none; height: 14px; font-weight: bold">По объектам:</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
              
                '       </tr>' skip
            .

    

            /* Вывод сокращённого списка Объектов "в одну строку" */
            put stream OutStr-html unformatted
                '       <tr>' skip /* Строчный пункт-6. По объектам */
                '         <td colspan="5" style="border: none; height: 14px">' + v-short-obj-list + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
         
                '       </tr>' skip
            .

            put stream OutStr-html unformatted
                '       <tr>' skip /* Строчный пункт-7. Пустая строка */
                '         <td style="border: none; height: 14px"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
              
                '       </tr>' skip
            .
            put stream OutStr-html unformatted
                '       <tr>' skip /* Строчный пункт-8. По списку ДКарт (показываем только кол-во!) */
                '         <td colspan="5" style="border: none; height: 14px">' + v-sel-card-string + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
            
                '       </tr>' skip
            .
            if /*(t-legacy or t-subsid) or*/ X-SelectGood <> {&g-all} then
            do:
                put stream OutStr-html unformatted
                    '       <tr>' skip /* Строчный пункт-9. Пустая строка */
                    '         <td style="border: none; height: 14px"></td>' skip
                    '         <td style="border: none"></td>' skip
                    '         <td style="border: none"></td>' skip
                    '         <td style="border: none"></td>' skip
                    '         <td style="border: none"></td>' skip
                  
                    '       </tr>' skip
                .
            end.
            /* Строчный пункт-10. "Выбор товара" (Параметры Закладка-1) + перечень некоторых данных к товару (согласно старинным ТЗ) */
            find first tt-selectgood no-lock no-error. /* Берём первый заголовок (ожидается один заголовок) */
            if available tt-selectgood then
            do:
                if tt-selectgood.collection-name <> ? or tt-selectgood.collection-name <> "":U then /* Подготовка к выводу на экран любой непустой записи */
                do:
                    put stream OutStr-html unformatted
                        '       <tr>' skip /* Строчный пункт-10(заголовок). Вывод режима выбора товаров (например лэйбл: "По группам товаров:") */
                        '         <td colspan="5" style="border: none; height: 14px">' + tt-selectgood.collection-name + '</td>' skip
                        '         <td style="border: none"></td>' skip
                        '         <td style="border: none"></td>' skip
                        '         <td style="border: none"></td>' skip
                        '         <td style="border: none"></td>' skip
                        '         <td style="border: none"></td>' skip
                        '       </tr>' skip
                    .
                end.
            end.
            if X-SelectGood <> {&g-all} then /* Печатаем пустую строку, если ожидается многострочный вывод ({&g-all} - подразумевает вывод одной строки, после которой пустострочье не нужно)  */
            do:
                define variable v-nn as integer initial 0 no-undo.
                for each tt-selectgood no-lock where /* Строчный пункт-10. Вывод в зависимости от режима разных списков (товаров, групп товаров, производителей) */
                : /* Список (набор elements) к заголовку ожидаем в основном многострочным */
                    if tt-selectgood.collection-element <> ? or tt-selectgood.collection-element <> "" then
                    do:
                        v-nn = v-nn + 1.
                        put stream OutStr-html unformatted
                            '       <tr>' skip /* Строчный пункт-10(содержание). Вывод в зависимости от режима разных списков (товаров, групп товаров, производителей, или ничего не выводим) */
                            '         <td colspan="5" style="border: none; height: 14px">' + tt-selectgood.collection-element + '</td>' skip
                            '         <td style="border: none"></td>' skip
                            '         <td style="border: none"></td>' skip
                            '         <td style="border: none"></td>' skip
                            '         <td style="border: none"></td>' skip
                            '         <td style="border: none"></td>' skip
                            '       </tr>' skip
                        .
                    end.
                end.
  
            end.


            /* Строчный пункт-14. Пустая строка, если была выведена хоть одна строка: "С учётом перевыпуска карт" или "С учётом дополнительных карт" (иначе - это будет лишняя пустая строка) */
            put stream OutStr-html unformatted
                '       <tr>' skip /* Строчный пункт-14. Пустая строка */
                '         <td style=" border: none; height: 14px"></td>' skip
                '         <td style=" border: none"></td>' skip
                '         <td style=" border: none"></td>' skip
                '         <td style=" border: none"></td>' skip
                '         <td style=" border: none"></td>' skip
     
                '       </tr>' skip
            .
    end. /* Шапка отчёта (видимого, как не таблица) */

    /* Заполнение "глобальной" таблицы - блок Шапки таблицы отчёта (часть отчёта, видимая как "шапка таблицы") */
    do:  /* Шапка таблицы отчёта (видимой, как таблица) */
            put stream OutStr-html unformatted
                '     <tbody>' skip
                '       <tr>' skip
                '         <th style="text-align: center; height: 30px">Номер Карты / Артикул товара</th>' skip
                '         <th style="text-align: center;">Наименование</th>' skip
                '         <th style="text-align: center;">Кол-во чеков/покупок</th>' skip
                '         <th style="text-align: center;">Сумма</th>' skip
                '         <th style="text-align: center;">Бонусы</th>' skip
  
                '       </tr>' skip
                '       <tr>' skip
                '         <th num="" style="text-align: center">1</th>' skip
                '         <th num="" style="text-align: center">2</th>' skip
                '         <th num="" style="text-align: center">3</th>' skip
                '         <th num="" style="text-align: center">4</th>' skip
                '         <th num="" style="text-align: center">5</th>' skip
           
                '       </tr>' skip
            . /* Точка для закрытия Put */
        output stream OutStr-html close.
    end. /* Шапка таблицы отчёта (видимой, как таблица) */

    /* Заполнение тела таблицы отчёта */
    do: /* b5 */
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.

        if p-T-obj-detal then /* Вывод информации по Объектам - только при включенном интерфейсном флаге параметров Закл-2: "Детализация по Объектам" */
        do:  /* if p-T-obj-detal = yes */
            /* Блок вывода в HTML N вложенных циклов: 1-по Объектам, 2-по ДКартам, 3-по группам товаров, 4-по товарам. */
            for each buf-obj2_dcards where
                     buf-obj2_dcards.grp-lvl = 2000 and /* 2000 - моё кодовое значение, для группы "Объекты" (наприм: "маг-77 / Лукойл 77") */
                     buf-obj2_dcards.artic = "" no-lock /* В артикуле здесь исключаем запись "по всем ДКартам из ВС", которую выводим после тек записей таблицы */
            :
                do:  /* Вывод подзаголовка(жирным шрифтом) строки по Объекту с итогами */
                    put stream OutStr-html unformatted
                        '       <tr level="1">' skip
                        '         <td style="display: yes; text-align: left; height: 20px; font-weight: bold">' + "Объект: " + (if buf-obj2_dcards.obj-name = ? then "" else buf-obj2_dcards.obj-name) + '</td>' skip
                        '         <td style="display: yes; text-align: left; font-weight: bold"></td>' skip
                        '         <td num="0" style="display: yes; text-align: right; font-weight: bold">' + string(buf-obj2_dcards.counter) + '</td>' skip /* Округление и преобразование точки в запятую для integer - не требуется */
                        '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-obj2_dcards.sum-withdisc) + '"' + '>' +
                                    fnc-convert-dot-to-colon(buf-obj2_dcards.sum-withdisc, v-accur-13) + '</td>' skip
                        '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-obj2_dcards.qnty-bonus) + '"' + '>' +
                                    fnc-convert-dot-to-colon(buf-obj2_dcards.qnty-bonus, v-accur-13) + '</td>' skip
                  
                        '       </tr>' skip
                    .
                end. /* Вывод подзаголовка(жирным шрифтом) строки по Объекту с итогами */

                for each buf-crd2_dcards where
                         buf-crd2_dcards.obj-type = buf-obj2_dcards.obj-type and
                         buf-crd2_dcards.obj-code = buf-obj2_dcards.obj-code and
                         buf-crd2_dcards.grp-lvl  = 1000 and /* 1000 - моё кодовое значение, для группы "ДКарты" */
                         buf-crd2_dcards.artic    = "" /* Отсекаем ДКарты, которые не из "импорт из ВС", а наши, из ТН */
                no-lock
                :
                    do:  /* Вывод подзаголовка(жирным шрифтом) строки по ДКарте с итогами */
                        put stream OutStr-html unformatted
                            '       <tr level="2">' skip
                            '         <td style="display: yes; text-align: left; height: 20px; font-weight: bold; padding-left: 10px">' + /* пробел-отступ для Excel */ string(fill(" ", (4))) + /*"ДК №: " +*/ (if buf-crd2_dcards.d-card <> ? then buf-crd2_dcards.d-card else "?") + '</td>' skip
                            '         <td style="display: yes; text-align: left; font-weight: bold">' +  buf-crd2_dcards.gds-name +  " (" + buf-crd2_dcards.cli-type-code + ")" + '</td>' skip
                            '         <td num="0" style="display: yes; text-align: right; font-weight: bold">' + string(buf-crd2_dcards.counter) + '</td>' skip /* Округление и преобразование точки в запятую для integer - не требуется */
                            '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-crd2_dcards.sum-withdisc) + '"' + '>' +
                                        fnc-convert-dot-to-colon(buf-crd2_dcards.sum-withdisc, v-accur-13) + '</td>' skip
                            '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-crd2_dcards.qnty-bonus) + '"' + '>' +
                                        fnc-convert-dot-to-colon(buf-crd2_dcards.qnty-bonus, v-accur-13) + '</td>' skip
     
                            '       </tr>' skip
                        .
                    end. /* Вывод подзаголовка(жирным шрифтом) строки по ДКарте с итогами */

                    if available buf-crd2_dcards then
                    do:
                        /* Вывод уровней: "Группы товаров" и "Товары" */
                        run tt-print-line (input buf-crd2_dcards.obj-type, input buf-crd2_dcards.obj-code, input buf-crd2_dcards.d-card, input 1, input 3). /* Вывод уровней: "Группы товаров" и "Товары" */
                    end.
                end.
            end. /* for each buf-crd2_dcards */


        end. /* if p-T-obj-detal = yes */
        else
        do:  /* if p-T-obj-detal = no */
            for each buf-obj2_dcards where
                      buf-obj2_dcards.grp-lvl = 2000 and    /* АРЕНДА по условию. 2000 - в данном условии:"Без детализации по Объектам"- уровень для суммы по всем "ДКартам" (исходное условие для 2000 - уровень групп по Объектам) */
                      buf-obj2_dcards.gds-name <> "ВС" and  /* Отсекаем Группу(вирт) "Импорт из ВС", её вывод после тек блока табл */
                      buf-obj2_dcards.artic <> "Импорт из ВС" no-lock /* Отсекаем Группу(вирт) "Импорт из ВС", её вывод после тек блока табл */
            :
                put stream OutStr-html unformatted
                    '       <tr level="1">' skip
                    '         <td style="display: yes; text-align: left; height: 20px; font-weight: bold">' + "Итого по всем ДКартам: " + '</td>' skip
                    '         <td style="display: yes; text-align: left; font-weight: bold"></td>' skip
                    '         <td num="0" style="display: yes; text-align: right; font-weight: bold">' + string(buf-obj2_dcards.counter) + '</td>' skip /* Округление и преобразование точки в запятую для integer - не требуется */
                    '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-obj2_dcards.sum-withdisc) + '"' + '>' +
                                fnc-convert-dot-to-colon(buf-obj2_dcards.sum-withdisc, v-accur-13) + '</td>' skip
                    '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-obj2_dcards.qnty-bonus) + '"' + '>' +
                                fnc-convert-dot-to-colon(buf-obj2_dcards.qnty-bonus, v-accur-13) + '</td>' skip
                    '       </tr>' skip
                .

                for each buf-crd2_dcards where
                         buf-crd2_dcards.grp-lvl = 1000 /* 1000 - моё кодовое значение, для группы "ДКарты" */
                no-lock
                :
                    do:  /* Вывод подзаголовка(жирным шрифтом) строки по ДКарте с итогами */
                        put stream OutStr-html unformatted
                            '       <tr level="2">' skip
                            '         <td style="display: yes; text-align: left; height: 20px; font-weight: bold; padding-left: 10px">' + /* пробел-отступ для Excel */ string(fill(" ", (4))) + /*"ДК №: " +*/ (if buf-crd2_dcards.d-card <> ? then buf-crd2_dcards.d-card else "?") + '</td>' skip
                            '         <td style="display: yes; text-align: left; font-weight: bold">' +  buf-crd2_dcards.gds-name + " (" + buf-crd2_dcards.cli-type-code + ")" + '</td>' skip
                            '         <td num="0" style="display: yes; text-align: right; font-weight: bold">' + string(buf-crd2_dcards.counter) + '</td>' skip
                            '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-crd2_dcards.sum-withdisc) + '"' + '>' +
                                        fnc-convert-dot-to-colon(buf-crd2_dcards.sum-withdisc, v-accur-13) + '</td>' skip
           
                            '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-crd2_dcards.qnty-bonus) + '"' + '>' +
                                        fnc-convert-dot-to-colon(buf-crd2_dcards.qnty-bonus, v-accur-13) + '</td>' skip
                            '       </tr>' skip
                        .
                    end. /* Вывод подзаголовка(жирным шрифтом) строки по ДКарте с итогами */
    
                    if available buf-crd2_dcards then
                    do:
                        /* Вывод уровня типа "Группы товаров", но на самом деле - только моего виртуального уровня "ВС" - то бишь "Импорт из Внешних систем" */
                        run tt-print-line (input buf-crd2_dcards.obj-type, input buf-crd2_dcards.obj-code, input buf-crd2_dcards.d-card, input 1, input 3). /* Вывод уровней: "Группы товаров" и "Товары" */
                    end.
                end.
            end. /* for each buf-obj2_dcards */
        end. /* if p-T-obj-detal = no */
    end. /* b5 */

    /* Заполнение подвала отчёта */
    do:  /* b6 */
                put stream OutStr-html unformatted
                '     </tbody>' skip
                '   </table>' skip
                '  </body>' skip
                ' </html>' skip
                . /* Точка для закрытия Put */
        output stream OutStr-html close.
    end. /* b6 */
end procedure.

procedure msg-html-noAllChk:
/* Сообщение в формате кода HTML о том, что отчёт сформирован не по всем чекам */
    define output parameter p-message as character no-undo.
        p-message =
                '       <tr>' + chr(10) + /* Строка после 4-й */
                '         <td style="border: none; height: 14px; font-weight: bold"></td>' + chr(10) +
                '         <td colspan="9" style="border: none">' + "сформирован НЕ ПО ВСЕМ ЧЕКАМ" + '</td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '       </tr>' + chr(10) +
                '       <tr>' + chr(10) + /* Пустая строка */
                '         <td style="border: none; height: 14px; font-weight: bold"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '       </tr>' + chr(10)
        .
end procedure.

procedure get-full-path-RepViewer:
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

procedure define-full-path-Report:
/* Получение полного пути к отчёту html */
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.

    p-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(p-rep-num) + ".html".

end procedure.

procedure search-full-path-Report:
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

procedure Report-Viewer:
/* Запуск программы "Просмотровщик Отчётов" - ReportViewer. */
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.

os-command no-wait value(p-full-path-RepView + " true " + search(p-file-name-rep-htm)).

end procedure.

procedure create-file:
/* Создание пустого файла (во входном параметре: полный путь и имя файла) */
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.

end procedure.

procedure tt-print-line:
/* Вывод линий таблицы с группировкой: 1) по имени группы товаров; 2) по уровню внутри группыю */
    define input parameter p-obj-type as character no-undo.
    define input parameter p-obj-code as integer no-undo.
    define input parameter p-d-card as character no-undo.
    define input parameter p-upper-code like ub.gds-grp.upper-code no-undo. /*  */
    define input parameter p-print-lvl as integer no-undo.                  /* Присвоенный динамичный уровень для отображения в отчёте */

    define variable v-display as character no-undo.                         /* Переменная для работы с одноимённым стилем HTML - displat (выводить/не выводить на экран WEB-браузера) */

    define buffer buf3_dcards for dcards.

    for each buf3_dcards where
             buf3_dcards.upper-code = p-upper-code and
             buf3_dcards.obj-type = p-obj-type and
             buf3_dcards.obj-code = p-obj-code and
             buf3_dcards.d-card = p-d-card
    no-lock
/*        by buf3_dcards.chk-date*/
    :
/* message buf3_dcards.upper-code buf3_dcards.grp-lvl buf3_dcards.gds-name p-print-lvl view-as alert-box. */
        if p-print-lvl < 3 then /* Выводим в HTML определённые уровни(p-print-lvl) - счёт с единицы и далее (1-й и 2-й ... на подобие в Excel) */
        do:  /* Выводим инфо в Веб-браузер (делаем видимой) */
            v-display = "yes".
        end. /* Выводим инфо в Веб-браузер (делаем видимой) */
        else
        do:  /* НЕ выводим инфо в Веб-браузер (инфа есть, но делаем её НЕвидимой) */
            v-display = "none".
        end. /* НЕ выводим инфо в Веб-браузер (инфа есть, но делаем её НЕвидимой) */

        do:  /* Печать строки таблицы: Уровеней: "Группа товаров" и "Товары" */
            if buf3_dcards.grp-lvl <> 0 then /* Условие когда выбраны ГРУППЫ ТОВАРОВ (Цель - печать жирным шрифтом) */
            do:
                put stream OutStr-html unformatted
                    '       <tr level="' + string(p-print-lvl) + '">' skip
/*                    '       <tr style="display: ' + v-display + '">' skip*/ /* Назначать стили дочерним элементам <td> здесь не стоит, т.к. у меня нарушилось формирование Level для Excel!!! */
                    '         <td style="display: ' + v-display + '; text-align: left; height: 20px; padding-left: ' + string((p-print-lvl - 0) * 10) + 'px; font-weight: bold">' + string(fill(" ", ((p-print-lvl - 1 /* минусуем из-за того, что 1-й уров мы захотели отобразить отступов!!! */) * 4))) + buf3_dcards.artic + '</td>' skip    /* Группа_товара для Группы или Артикул_товара для Товара */
                    '         <td style="display: ' + v-display + '; text-align: left; font-weight: bold">' + buf3_dcards.gds-name + '</td>' skip
                    '         <td num="0" style="display: ' + v-display + '; text-align: right; font-weight: bold">' + (if buf3_dcards.counter = 0 then "" else (string(if buf3_dcards.counter <> ? then string (buf3_dcards.counter) else "?"))) + '</td>' skip
                    '         <td num="0.00" style="display: ' + v-display + '; text-align: right; font-weight: bold">' + if buf3_dcards.sum-withdisc <> ? then fnc-convert-dot-to-colon(buf3_dcards.sum-withdisc, v-accur-13) + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: ' + v-display + '; text-align: right; font-weight: bold">' + if buf3_dcards.qnty-bonus <> ? then fnc-convert-dot-to-colon(buf3_dcards.qnty-bonus, v-accur-13) + '</td>' else "?" + '</td>' skip
                    '       </tr>' skip
                .
            end.
            else /* Иначе - если условие когда выбраны сами ТОВАРЫ (Цель - печать не жирным шрифтом) */
            do:
                put stream OutStr-html unformatted
                    '       <tr level="' + string(p-print-lvl) + '">' skip
/*                    '       <tr style="display: ' + v-display + '">' skip*/ /* Назначать стили дочерним элементам <td> здесь не стоит, т.к. у меня нарушилось формирование Level для Excel!!! */
                    '         <td style="display: ' + v-display + '; text-align: left; height: 20px; padding-left: ' + string((p-print-lvl - 0) * 10) + 'px">' + string(fill(" ", ((p-print-lvl - 1 /* минусуем из-за того, что 1-й уров мы захотели отобразить отступов!!! */) * 4))) + buf3_dcards.artic + '</td>' skip    /* Группа_товара для Группы или Артикул_товара для Товара */
                    '         <td style="display: ' + v-display + '; text-align: left">' + buf3_dcards.gds-name + '</td>' skip
                    '         <td num="0" style="display: ' + v-display + '; text-align: right">' + (if buf3_dcards.counter = 0 then "" else (string(if buf3_dcards.counter <> ? then string (buf3_dcards.counter) else "?"))) + '</td>' skip
                    '         <td num="0.00" style="display: ' + v-display + '; text-align: right">' + if buf3_dcards.sum-withdisc <> ? then fnc-convert-dot-to-colon(buf3_dcards.sum-withdisc, v-accur-13) + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: ' + v-display + '; text-align: right">' + if buf3_dcards.qnty-bonus <> ? then fnc-convert-dot-to-colon(buf3_dcards.qnty-bonus, v-accur-13) + '</td>' else "?" + '</td>' skip
                    '       </tr>' skip
                .
            end.
        end. /* Печать строки таблицы: Уровеней: "Группа товаров" и "Товары" */

        /* Рекурсивная конструкция, для формирования УРОВНЕЙ(номеров) по группам товаров и товарам */
        if buf3_dcards.grp-lvl <> 0 then run tt-print-line (input p-obj-type, input p-obj-code, input p-d-card, input buf3_dcards.grp-code, input p-print-lvl + 1).
    end. /* for each buf2_dcards */

end procedure.

procedure transform-tt-level:
/* Трансформация линейной таблицы в таблицу с уровнями */
/* и итогами для каждого уровня. */
/******************************************************/
    define input parameter p-obj-type as character no-undo.
    define input parameter p-obj-code as integer no-undo.
    define input parameter p-d-card like ub.dis-card.d-card no-undo.
/*    define input parameter p-obj-name as character no-undo.*/
 define variable v-qnty-bonus as decimal.
    define variable v-doc-qnty as decimal no-undo.
    define variable v-sum-withoutdisc as decimal no-undo.       /* Сумма без скидок */
    define variable v-sum-withdisc as decimal no-undo.          /* Сумма со скидкой */
    define variable v-discount as decimal no-undo.
    define variable v-gds-grp-name as character no-undo.
    define variable v-cur-lvl as integer no-undo.
    define variable v-upper-code as integer initial ? no-undo.
    define variable v-first-of as logical no-undo.
    define variable v-last-of as logical no-undo.
    define variable v-cur-recid as recid no-undo.   /* Флаг фиксации записи, когда выходим за пределы видимости созданной записи (create my-table) */
  define variable counter as integer.
    define buffer buf1_dcards for dcards.
    define buffer buf2_dcards for dcards.
/*    define buffer buf2_goods for ub.goods.*/
    define buffer bufobj_dcards for dcards.
    define buffer bufobj2_dcards for dcards.
    define buffer bufhl_dcards for dcards.

    do while v-upper-code <> 0 
    :
        v-upper-code = 0.
        v-gds-grp-name = ''.

        for each buf1_dcards where
                 buf1_dcards.grp-lvl  = v-cur-lvl and
                 buf1_dcards.obj-type = p-obj-type and
                 buf1_dcards.obj-code = p-obj-code and
                 buf1_dcards.d-card   = p-d-card
        break
            by buf1_dcards.grp-code
        :

            if first-of(buf1_dcards.grp-code) then
            do:
                assign
                    v-doc-qnty = 0          /* Количество */
/*                    v-sum-withoutdisc = 0   /* Сумма без скидки */*/
                    v-sum-withdisc = 0      /* Сумма со скидкой */
                    v-qnty-bonus = 0          /* Скидка */
                    counter = 0 
                .
                find first ub.gds-grp where
                           ub.gds-grp.node-code = buf1_dcards.grp-code
                no-lock no-error.
                if available ub.gds-grp then
                do:
                    assign
                        v-upper-code = ub.gds-grp.upper-code    /*  */
                        v-gds-grp-name = ub.gds-grp.node-name   /* Имя группы товаров */
                    .
                end.
                /*
                else assign
                        v-upper-code = ?    /*  */
                        v-gds-grp-name = '???'
                           /* Имя группы товаров */
                    .
                    */
            end.

            buf1_dcards.upper-code = if buf1_dcards.grp-lvl = 0 then buf1_dcards.grp-code else v-upper-code.

            if buf1_dcards.grp-lvl <> 0 then
            do:
                assign
                    buf1_dcards.gds-name = v-gds-grp-name
                    buf1_dcards.artic = string(buf1_dcards.grp-code) /* Вывод в подитоговой строке для ГРУПП ТОВАРОВ кода этих самых групп (1-е поле таблицы Excel) */
                .
            end.

            assign
                
                v-doc-qnty = v-doc-qnty + buf1_dcards.doc-qnty               /* Количество */
                v-sum-withdisc = v-sum-withdisc + buf1_dcards.sum-withdisc      /* Сумма без скидки */
                v-qnty-bonus = v-qnty-bonus + buf1_dcards.qnty-bonus
                counter = counter +  buf1_dcards.counter
            .


            if last-of (buf1_dcards.grp-code) then
            do:
                find first buf2_dcards where buf2_dcards.grp-code = (if buf1_dcards.grp-lvl = 0 then buf1_dcards.grp-code else v-upper-code)
                                          and  buf2_dcards.grp-lvl > buf1_dcards.grp-lvl
                                        and buf2_dcards.gds-code = 0
                                          and  buf2_dcards.obj-type = p-obj-type
                                          and  buf2_dcards.obj-code = p-obj-code
                                          and buf2_dcards.d-card = p-d-card no-error.
                if not available buf2_dcards then do:                           
                create buf2_dcards.

                assign
                    buf2_dcards.grp-code =
                        (if buf1_dcards.grp-lvl = 0 then buf1_dcards.grp-code
                         else v-upper-code)                             /* Группа товара (как-бы заголовок для группы) */
                   buf2_dcards.grp-lvl = buf1_dcards.grp-lvl + 1       /* Уровень группы (относительный, как порядок следования групп: 1, 2, ...) */
                  /*  buf2_dcards.gds-name = v-gds-grp-name    */           /* Наименование руппы товаров */
                    buf2_dcards.obj-type = p-obj-type
                    buf2_dcards.obj-code = p-obj-code
                    buf2_dcards.d-card = p-d-card
                  /*  buf2_dcards.qnty-bonus = v-qnty-bonus */
                  
                .
                
              /*  message   buf2_dcards.grp-code buf2_dcards.grp-lvl buf1_dcards.grp-code view-as alert-box.  */ 
                end.
                assign 
                                                                        
                                        buf2_dcards.counter = counter
                   
                    buf2_dcards.doc-qnty = buf2_dcards.doc-qnty + v-doc-qnty                   /* Количество */
                    buf2_dcards.sum-withdisc = buf2_dcards.sum-withdisc + v-sum-withdisc           /* Сумма со скидкой */
                    buf2_dcards.discount = buf2_dcards.discount + v-discount                   /* Скидка */
                    buf2_dcards.qnty-bonus = buf2_dcards.qnty-bonus + v-qnty-bonus
                    .
             
            end.
        end. /* for each buf1_dcards */
        if v-upper-code = ? then v-upper-code = 0.
        v-cur-lvl = v-cur-lvl + 1.

    end. /* do while v-upper-code <> 0 */
    
    
    for each  bufhl_dcards where  bufhl_dcards.grp-code <> 0  and 
         bufhl_dcards.d-card = p-d-card and  bufhl_dcards.gds-code = 0:
        for each buf2_dcards where buf2_dcards.grp-code =  bufhl_dcards.grp-code and buf2_dcards.grp-lvl <>  bufhl_dcards.grp-lvl and     buf2_dcards.d-card = p-d-card and buf2_dcards.gds-code = 0 :   
                        
                       
            assign
            bufhl_dcards.counter = buf2_dcards.counter + bufhl_dcards.counter 
                            bufhl_dcards.doc-qnty = buf2_dcards.doc-qnty +  bufhl_dcards.doc-qnty                   /* Количество */
                    bufhl_dcards.sum-withdisc = buf2_dcards.sum-withdisc +  bufhl_dcards.sum-withdisc           /* Сумма со скидкой */
                    bufhl_dcards.discount = buf2_dcards.discount +  bufhl_dcards.discount                   /* Скидка */
                    bufhl_dcards.qnty-bonus = buf2_dcards.qnty-bonus +  bufhl_dcards.qnty-bonus 
                    .
                        
                       delete  buf2_dcards .
        end.
                      
         
    end.

end procedure.

procedure my-watch-table: /* Процедура для моей ОТЛАДКИ! Арн. */
/* Запись наблюдаемых таблиц в файл */
&scope tt-table dcards
/*&scope tt-table gds-list*/
/*&scope tt-table X_dis-card*/
/*    define input parameter p-str1 as character no-undo.*/
/*    define input parameter p-table-name as character no-undo.*/

    define variable v-full-file-name as character no-undo.
    define variable v-message as character no-undo.
    define variable v-table-handle as handle no-undo.
    define variable v-cnt-field as integer no-undo.
    define variable v-list-field-name as character no-undo.
    define variable v-list-field-label as character no-undo.
    define variable v-list-field-type as character no-undo.

    define buffer {&tt-table} for {&tt-table}.
/*    define buffer buf5_dcards for {&tt-table}.*/
/*    define variable tt-handle as handle no-undo.*/

    /* Получаем:
       спискок полей таблицы - name;
       спискок полей таблицы - label;
       спискок типов полей таблицы - type. */
    v-table-handle = buffer {&tt-table}:handle.
    v-cnt-field = v-table-handle:num-fields.
    do v-ii = 1 to v-cnt-field:
        v-list-field-name =
            (if v-list-field-name <> "" then
               v-list-field-name + "$" + v-table-handle:buffer-field(v-ii):name
            else
                v-table-handle:buffer-field(v-ii):name).
        v-list-field-label =
            (if v-list-field-label <> "" then
               v-list-field-label + "$" + v-table-handle:buffer-field(v-ii):label
            else
                v-table-handle:buffer-field(v-ii):label).
        v-list-field-type =
            (if v-list-field-type <> "" then
               v-list-field-type + "$" + v-table-handle:buffer-field(v-ii):data-type
            else
                v-table-handle:buffer-field(v-ii):data-type).
    end.


    v-full-file-name = "C:\work15_0\my-watch-{&tt-table}.txt".

    if search(v-full-file-name) = ? then
        do:
            message "Не найден файл отчёта: " v-full-file-name view-as alert-box error.
        end.

    /* Сохранение потока в созданный файл my-watch-table.txt */
    output stream MyWatch-strm to value(v-full-file-name) /*append*/ /*no-convert*/ convert target "utf-8".
        put stream MyWatch-strm unformatted
            today format "99.99.9999" " " string(time, "HH:MM") " " "Исследуемая таблица: " "{&tt-table}" "." skip /* Для вывода текста, отдельных слов - только пробел, не ставить "+" */
            v-list-field-label skip
            v-list-field-name skip
            v-list-field-type skip
        .
        if not can-find(first {&tt-table}) then
        do:
            v-message = "Исследуемая таблица {&tt-table} пуста!".
            put stream MyWatch-strm unformatted
                v-message
            .
            message "My-watch-table: " v-message view-as alert-box information.
        end.

            for each /*buf5_dcards*/ {&tt-table} no-lock:
                export stream MyWatch-strm delimiter "$" /*buf5_dcards*/ {&tt-table}. /* Вставляем сюда вручную свою таблицу!!! */
            end.
    output stream MyWatch-strm close.
end procedure.

                                                                                                                                                                                                       

function fnc-convert-dot-to-colon returns character 
(input p-data as decimal, input p-accur as character):
/* Конвертация десятичной точки в запятую с передачей параметра форматирования числа (accuracy - выводим разряды после запятой). */
/* Возвращает: а)число с запятой, б)ноль, в)вопрос, в зависимости от того, что содержится во входном decimal. */

    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
/*message "dbg-p-data = " p-data skip "p-accur = " p-accur view-as alert-box.*/
    if p-data = ? then
    do:
        v-str-result = "?".
    end.
    else
    do:
        p-data = round(p-data, 2). /* Чтобы не выйти случайно за рамки формата числа при выводе (несоотвесвие формата результата и формата отображения - приводит к ош) */
        v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    end.

    return v-str-result.

end function.

function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date):
/* Преобразование даты в формат: "01.01.2014" */

    define variable result as character no-undo.
    define variable p-str-date as character no-undo.

    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").

        return p-str-date.

end function.

