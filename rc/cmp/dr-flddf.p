block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dr-flddf.p $
$Archive: cmp/dr-flddf.p $

Программа генерации файла dr-flddf.i

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/06/08
Author: Bakhtadze Natalya
Creation date: 08/06/08

================================================================================
Одиночные препроцессинги должны быть описаны следующим образом:
{ cmp/cr-prep.i 1 <имя_препроцессинга>  <русское_значение> <русское_описание> <английское_значение> <английское_описание>}

обязательные параметры:
  <имя_препроцессинга>  <русское_значение> <английское_значение>

необязательные параметры:
  <русское_описание>
  <английское_описание>

Если не нужно указывать расширенное описание
  в качестве описания необходимо указать пробел окруженный кавычками " "
   <английское_описание> можно просто не указывать.
  Недопустимо указывать пустую строку "", так как при этом возникнет ошибка компиляции,
  которую будет трудно обнаружить.
================================================================================
Определения списка определений, разделенных знаком ","
{ cmp/cr-prep.i 2 <препроцессинг_1> <препроцессинг_2> <препроцессинг_3> }
================================================================================
Если при описании значения необходимо указать препроцессинг, который будет
раскрываться в программе, то необходимо указывать семь знаков тильда и фигурную скобку.
  (см. VAT-pay-no-SLT )

Допустимо ограниченное применения прямого объявления для фрагментов кода
  (см. VAT-pay-no-SLT )
================================================================================
Процедура добавления новых глобальных определений:

1. Взять для изменений один из файлов (checkout)
    cmp/dr-flddf.p
2. Добавить необходимые изменения в файл
3. Выложить измененный файл (checkin)
4. Сгенерировать русскую версию dr-flddf.i
   Выложить русскую версию версию dr-flddf.i в vss
5. Сгенерировать английскую версию dr-flddf.i
   Выложить английскую версию версию dr-flddf.i в vss

Коментарий к cr-prep.i:
параметр 1 - тип создания препроцессинга:
               1 - одиночный препроцессинг,
               2 - список из одиночных препроцессингов
  для 1:
      2 - название препроцессинга
      3(рус) или 5(англ) - текстовая фраза - значение препроцессинга
      4(рус) или 6(англ) - полное название препроцессинга для образования соответствующих списков названий
          пример: (адм - Администратор)
  для 2:
      2..10 - имена препроцессингов
      Образуется список с именем {2}_{3}_..._{10}
*/

define input  parameter p-dir-name  as character no-undo .
define output parameter p-num-lines as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dr-flddf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/dr-flddf.p $":U .
define variable vss-description as character no-undo init "Программа генерации файла dr-flddf.i".
{ cmp/vssrevis.i }
{ cmp/filwrlib.i }
{ cmp/abbr-nc.i }


&glob language {1}

&glob tilda ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
&glob scop-begin ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~&
&glob scop-end   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

&if "{&language}" = "rus"  &then
  &glob lang-value        3
  &glob lang-description  4
&elseif "{&language}" = "eng" &then
  &glob lang-value        5
  &glob lang-description  6
&else
  message
    "Необходимо задать указать язык используемый для генерации dr-flddf.i" skip
    "В качестве параметра компиляции необходимо задать 'rus' или 'eng'" skip
    view-as alert-box .
  return error .
&endif

define variable v-file-name as character no-undo .

assign
  v-file-name = 'cmp/dr-flddf.new'
.

run filwrlib_set-file-name in this-procedure
  (input v-file-name
  ) .

run filwrlib_clear-file in this-procedure  .

run filwrlib_append-new-line in this-procedure (input "/*" ) .
run filwrlib_append-new-line in this-procedure (input "" ) .
run filwrlib_append-new-line in this-procedure (input "$" + "Revision: " + "$" ) .
run filwrlib_append-new-line in this-procedure (input "$" + "Author: " + "$" ) .
run filwrlib_append-new-line in this-procedure (input "$" + "Date: " + "$" ) .
run filwrlib_append-new-line in this-procedure (input "$" + "Workfile: " + "$" ) .
run filwrlib_append-new-line in this-procedure (input "$" + "Archive: " + "$" ) .
run filwrlib_append-new-line in this-procedure (input "                                        " ) .
run filwrlib_append-new-line in this-procedure (input "Файл глобальных определений" ) .
run filwrlib_append-new-line in this-procedure (input "" ) .
run filwrlib_append-new-line in this-procedure (input "Автор: Бахтадзе Наталья Викторовна" ) .
run filwrlib_append-new-line in this-procedure (input "Дата создания: 08/06/08" ) .
run filwrlib_append-new-line in this-procedure (input "Author: Bakhtadze Natalya" ) .
run filwrlib_append-new-line in this-procedure (input "Creation date: 06/06/08" ) .
run filwrlib_append-new-line in this-procedure (input "" ) .
run filwrlib_append-new-line in this-procedure (input "Этот файл сгенерирован автоматически" ) .
run filwrlib_append-new-line in this-procedure (input "Все изменения необходимо вносить в файл dr-flddf.p" ) .
run filwrlib_append-new-line in this-procedure (input "" ) .
run filwrlib_append-new-line in this-procedure (input "*/" ) .
run filwrlib_append-new-line in this-procedure (input "&if defined(dr-flddf_i) = 0 &then" ) .
run filwrlib_append-new-line in this-procedure (input "&glob dr-flddf_i" ) .
run filwrlib_append-new-line in this-procedure (input "&global-define language {&language}" ).
run filwrlib_append-new-line in this-procedure (input '&if "~{1~}" = "class" &then' ) .
run filwrlib_append-new-line in this-procedure (input '&else' ) .
run filwrlib_append-new-line in this-procedure (input "if g#language <> '' and g#language <> '{&language}':U then do:" ) .
run filwrlib_append-new-line in this-procedure (input "  undo, return error substitute( '&1. incorrect language&2dr-flddf: {&language}&2db: &3':U, this-procedure :file-name, chr(10), g#language  )." ) .
run filwrlib_append-new-line in this-procedure (input "end." ) .
run filwrlib_append-new-line in this-procedure (input '&endif' ) .

run filwrlib_append-new-line in this-procedure ( input "&global-define dr-flddf_dr-fields {&dr-flddf_dr-fields}" ).


{ cmp/cr-prep.i 1 dr-flddf_cntxt_chk-discnt-table   cntxt_chk-discnt-table              "Ссылка на Массив Скидок"                   cntxt_chk-discnt-table   "Discnt-Array Handle" }
{ cmp/cr-prep.i 1 dr-flddf_cntxt_chk-gds-table      cntxt_chk-gds-table                 "Ссылка на Массив Строк товаров"            cntxt_chk-gds-table      "Item-lines-Array Handle" }
{ cmp/cr-prep.i 1 dr-flddf_cntxt_chk-pay-table      cntxt_chk-pay-table                 "Ссылка на Массив Строк Оплат"              cntxt_chk-pay-table      "Pay-lines-Array Handle" }

&glob dr-flddf_cntxt-fields '~
{&bef-dr-flddf_cntxt_chk-discnt-table}~
,{&bef-dr-flddf_cntxt_chk-gds-table}~
,{&bef-dr-flddf_cntxt_chk-pay-table}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define dr-flddf_cntxt-fields {&dr-flddf_cntxt-fields}" ).

{ cmp/cr-prep.i 1 dr-flddf_gline_line-num           gline_line-num                      "Номер строки товара"                       gline_line-num           "Current Line No" }
{ cmp/cr-prep.i 1 dr-flddf_gline_src-discnt         gline_src-discnt                    "Текущая скидка на ед.товара"               gline_src-discnt         "Current discnt per/unit" }
{ cmp/cr-prep.i 1 dr-flddf_gline_src-code           gline_src-code                      "Код товара в чеке"                         gline_src-code           "Item Code in Line" }
{ cmp/cr-prep.i 1 dr-flddf_gline_src-price          gline_src-price                     "Текущая цена"                              gline_src-price          "Current price" }
{ cmp/cr-prep.i 1 dr-flddf_gline_start-src-price    gline_start-src-price               "Цена по прайс-листу"                       gline_start-src-price    "Pricelist price" }
{ cmp/cr-prep.i 1 dr-flddf_gline_price-base         gline_price-base                    "Текущая цена в основных ед.изм."           gline_price-base         "Current price for Main unit" }
{ cmp/cr-prep.i 1 dr-flddf_gline_src-qnty           gline_src-qnty                      "Текущее кол-во"                            gline_src-qnty           "Current qnty" }
{ cmp/cr-prep.i 1 dr-flddf_gline_doc-qnty           gline_doc-qnty                      "Кол-во в основных ед.изм"                  gline_doc-qnty           "Base Unit Qnty" }
{ cmp/cr-prep.i 1 dr-flddf_gline_b-code             gline_b-code                        "Основной бар-код"                           gline_b-code             "Barcode" }
{ cmp/cr-prep.i 1 dr-flddf_gline_gds-code           gline_gds-code                      "Код товара"                                gline_gds-code           "GoodsCode" }
{ cmp/cr-prep.i 1 dr-flddf_gline_sum-grp-code       gline_sum-grp-code                  "Код группы"                                gline_sum-grp-code       "Group Code" }
{ cmp/cr-prep.i 1 dr-flddf_gline_src-base           gline_src-base                      "Сумма брутто"                              gline_src-base           "Line Brutto Sum" }
{ cmp/cr-prep.i 1 dr-flddf_gline_src-price-netto    gline_src-price-netto               "Эффективная цена(нетто)"                   gline_src-price-netto    "Effective price" }
{ cmp/cr-prep.i 1 dr-flddf_gline_price-base-netto   gline_price-base-netto              "Эффективная цена(нетто) для осн.ед.изм"    gline_price-base-netto   "Effective price for Main unit" }
{ cmp/cr-prep.i 1 dr-flddf_gline_without-gds-discnt gline_without-gds-discnt            "Нет товарн. скидки на товар"               gline_without-gds-discnt "Without Item Discnt" }
{ cmp/cr-prep.i 1 dr-flddf_gline_without-subtotal-discnt gline_without-subtotal-discnt  "Не участвует в скидке на итог"             gline_without-gds-discnt "Without Subtotal Discnt" }
{ cmp/cr-prep.i 1 dr-flddf_gline_cli-base-rate      gline_cli-base-rate                 "Коэфф для упаковки"                        gline_cli-base-rate      "Pack coeff" }
{ cmp/cr-prep.i 1 dr-flddf_gline_recalc-line-num    gline_recalc-line-num               "Строка начала пересчета скидок"            gline_recalc-line-num    "Recalc Line-num" }



&glob dr-flddf_gline-fields '~
{&bef-dr-flddf_gline_line-num}~
,{&bef-dr-flddf_gline_src-discnt}~
,{&bef-dr-flddf_gline_src-code}~
,{&bef-dr-flddf_gline_src-price}~
,{&bef-dr-flddf_gline_start-src-price}~
,{&bef-dr-flddf_gline_price-base}~
,{&bef-dr-flddf_gline_src-qnty}~
,{&bef-dr-flddf_gline_doc-qnty}~
,{&bef-dr-flddf_gline_b-code}~
,{&bef-dr-flddf_gline_gds-code}~
,{&bef-dr-flddf_gline_sum-grp-code}~
,{&bef-dr-flddf_gline_src-price-netto}~
,{&bef-dr-flddf_gline_price-base-netto}~
,{&bef-dr-flddf_gline_without-gds-discnt}~
,{&bef-dr-flddf_gline_without-subtotal-discnt}~
,{&bef-dr-flddf_gline_cli-base-rate}~
,{&bef-dr-flddf_gline_recalc-line-num}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define dr-flddf_gline-fields {&dr-flddf_gline-fields}" ).

{ cmp/cr-prep.i 1 dr-flddf_pline_line-num           pline_line-num                      "Номер строки оплат"                        pline_line-num           "Current Line No" }
{ cmp/cr-prep.i 1 dr-flddf_pline_exch-rate          pline_exch-rate                     "Курс валюты оплат к нац.вал."              pline_exch-rate          "Current Currency Rate" }
{ cmp/cr-prep.i 1 dr-flddf_pline_exch-scale         pline_exch-scale                    "Масштаб курса валюты оплат к нац.вал."     pline_exch-scale         "Current Currency Scale" }
{ cmp/cr-prep.i 1 dr-flddf_pline_tot-sum            pline_tot-sum                       "Текущая сумма опат в вал.платежа"          pline_tot-sum            "Current Payment Sum" }
{ cmp/cr-prep.i 1 dr-flddf_pline_recalc-line-num    pline_recalc-line-num               "Строка начала пересчета скидок"            pline_recalc-line-num    "Recalc Line-num" }

&glob dr-flddf_pline-fields '~
{&bef-dr-flddf_pline_line-num}~
,{&bef-dr-flddf_pline_exch-rate}~
,{&bef-dr-flddf_pline_exch-scale}~
,{&bef-dr-flddf_pline_tot-sum}~
,{&bef-dr-flddf_pline_recalc-line-num}~
':U


run filwrlib_append-new-line in this-procedure ( input "&global-define dr-flddf_pline-fields {&dr-flddf_pline-fields}" ).


{ cmp/cr-prep.i 1 dr-flddf_doc_chk-date             doc_chk-date                   "Дата чека"                                 doc_chk-date            "Receipt Date" }
{ cmp/cr-prep.i 1 dr-flddf_doc_chk-time             doc_chk-time                   "Время чека"                                doc_chk-date            "Receipt Time" }
{ cmp/cr-prep.i 1 dr-flddf_doc_dc-category          doc_dc-category                "Категория ДК"                              doc_dc-category         "Category of DC" }
{ cmp/cr-prep.i 1 dr-flddf_doc_dc-d-pcnt            doc_dc-d-pcnt                   % скидки на товар по ДК"                   doc_dc-d-pcnt           "DC item discount %" }
{ cmp/cr-prep.i 1 dr-flddf_doc_dc-cash-d-pcnt       doc_dc-cash-d-pcnt              % скидки на итог по ДК"                    doc_dc-cash-d-pcnt      "DC subtotal discount %" }
{ cmp/cr-prep.i 1 dr-flddf_doc_recalc-gline-num     doc_recalc-gline-num           "Товарная Строка начала пересчета скидок"   doc_recalc-gline-num    "Item Recalc Line-num" }
{ cmp/cr-prep.i 1 dr-flddf_doc_recalc-pline-num     doc_recalc-pline-num           "Оплатная Строка начала пересчета скидок"   doc_recalc-pline-num    "Payment Recalc Line-num" }
{ cmp/cr-prep.i 1 dr-flddf_doc_st-for-discnt-r-b    doc_st-for-discnt-r-b          "Сумма для начисления скидки на итог в вал.продаж"  doc_st-for-discnt-r-b   "Sum for subtotal discnt" }
{ cmp/cr-prep.i 1 dr-flddf_doc_to-pay-r-b           doc_to-pay-r-b                 "Текущая сумма подлежащая оплате"           doc_to-pay-r-b          "Sum for payment" }
{ cmp/cr-prep.i 1 dr-flddf_doc_base-rate            doc_base-rate                  "Курс баз.вал. в чеке"                      doc_base-rate           "Base Rate" }
{ cmp/cr-prep.i 1 dr-flddf_doc_obj-code             doc_obj-code                   "№ маг-на"                                  doc_obj-code            "Shop #" }


&glob dr-flddf_doc-fields '~
{&bef-dr-flddf_doc_chk-date}~
,{&bef-dr-flddf_doc_chk-time}~
,{&bef-dr-flddf_doc_dc-category}~
,{&bef-dr-flddf_doc_dc-d-pcnt}~
,{&bef-dr-flddf_doc_dc-cash-d-pcnt}~
,{&bef-dr-flddf_doc_recalc-gline-num}~
,{&bef-dr-flddf_doc_recalc-pline-num}~
,{&bef-dr-flddf_doc_st-for-discnt-r-b}~
,{&bef-dr-flddf_doc_to-pay-r-b}~
,{&bef-dr-flddf_doc_base-rate}~
,{&bef-dr-flddf_doc_obj-code}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define dr-flddf_doc-fields {&dr-flddf_doc-fields}" ).

{ cmp/cr-prep.i 1 dr-flddf_dline_discnt-value-abs        dline_discnt-value-abs            "Абс. сумма текущей линии скидки"              dline_discnt-value-abs   "Current Discnt Sum" }
{ cmp/cr-prep.i 1 dr-flddf_dline_discnt-value-pcnt       dline_discnt-value-pcnt           "Эфф. % текущей линии"                         dline_discnt-value-pcnt  "Current Discnt %" }
{ cmp/cr-prep.i 1 dr-flddf_dline_rule-num                dline_rule-num                    "№ применяемого правила"                       dline_rule-num           "Current discnt rule No" }
{ cmp/cr-prep.i 1 dr-flddf_dline_nonunique               dline_nonunique                   "Детализация"                                  dline_nonunique          "Detail" }
{ cmp/cr-prep.i 1 dr-flddf_dline_templ-rl-root           dline_templ-rl-root               "Шаблон применяемого правила"                  dline_templ-rl-root      "Current discnt rule Template" }
{ cmp/cr-prep.i 1 dr-flddf_dline_value-type              dline_value-type                  "Тип значения применной скидки"                dline_value-type         "Current discnt rule Value Type" }
{ cmp/cr-prep.i 1 dr-flddf_dline_delta-discnt            dline_delta-discnt                "Эфф. дельта скидки на ед.товара"              dline_delta-discnt       "Eff delta discnt per unit" }
{ cmp/cr-prep.i 1 dr-flddf_dline_discnt-role             dline_discnt-role                 "Роль скидки"                                  dline_discnt-role        "Discnt role" }
{ cmp/cr-prep.i 1 dr-flddf_dline_charkey                 dline_charkey                     "Метка связанной скидки"                       dline_charkey            "Constrained Discnt Label" }
{ cmp/cr-prep.i 1 dr-flddf_dline_intended                dline_intended                    "Еще Может выполниться"                        dline_intended           "Intended" }
{ cmp/cr-prep.i 1 dr-flddf_dline_object-sum              dline_object-sum                  "Сумма обложения"                              dline_object-sum         "Sum for discnt" }
{ cmp/cr-prep.i 1 dr-flddf_dline_not-found               dline_not-found                   "Не проходит"                                  dline_not-found          "Not found" }

&glob dr-flddf_dline-fields '~
{&bef-dr-flddf_dline_discnt-value-abs}~
,{&bef-dr-flddf_dline_discnt-value-pcnt}~
,{&bef-dr-flddf_dline_rule-num}~
,{&bef-dr-flddf_dline_nonunique}~
,{&bef-dr-flddf_dline_templ-rl-root}~
,{&bef-dr-flddf_dline_value-type}~
,{&bef-dr-flddf_dline_delta-discnt}~
,{&bef-dr-flddf_dline_discnt-role}~
,{&bef-dr-flddf_dline_charkey}~
,{&bef-dr-flddf_dline_intended}~
,{&bef-dr-flddf_dline_object-sum}~
,{&bef-dr-flddf_dline_not-found}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define dr-flddf_dline-fields {&dr-flddf_dline-fields}" ).

/* новые переменные необходимо добавлять перед данной строчкой */

define variable v-num-lines          as integer   no-undo .

run filwrlib_append-new-line in this-procedure (input "&global-define dr-flddf_vss-revision '"  + trim(vss-revision, "$") + "':U" ) .

run filwrlib_append-new-line in this-procedure
  (input "&endif"
  ) .

os-delete value(p-dir-name + '/dr-flddf.i') .

os-create-dir value(p-dir-name) .

os-rename value(v-file-name) value(p-dir-name + '/dr-flddf.i') .

run filwrlib_num-lines-get in this-procedure
  (output v-num-lines
  ) .

assign
  p-num-lines = v-num-lines
.