/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для кассы R-KEEPER

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/27/05
Author: Bakhtadze Natalya
Creation date: 01/27/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*имена экспортируемых  из r-keeper файлов */
&if "{2}" = "temp" &then
&glob controls  1
&glob menu      2
&glob modify    3
&glob money     4
&glob personal  5
&glob reasons   6
&glob charges   7
&glob acheck    8
&glob adcheck   9
&glob apcheck  10
&glob archeck  11
&glob avcheck  12
&glob categ    13

&glob all-files      "control,menu,modify,money,personal,reasons,charges,acheck,adcheck,apcheck,archeck,avcheck,categ":U
&glob all-used-files "control,menu,modify,money,personal,reasons,charges,acheck,adcheck,apcheck,archeck,avcheck":U
&glob chk-used-files "control,menu,reasons,acheck,adcheck,apcheck,archeck,avcheck":U
&glob data-field-files  "acheck,avcheck,control"
&endif



define {1} temp-table {2}-categ no-undo
field  SIFR  as integer         column-label "Идентификатор"
field  NAME  as character       column-label "Название"
field  is-DEL  as logical       column-label "удаленная / действующая"
index pi is unique primary
sifr.

define {1} temp-table {2}-menu no-undo
field   SIFR          as integer       column-label "Идентификатор"
field   NAME          as character     column-label "Название"
field   CODE-chr      as character     column-label "Код"
field   TREETYPE      as character     column-label "Тип записи" /*'F','L' - блюдо;  'T' - группа блюд*/
field   CATEG         as integer       column-label "Идентификатор категории"
field   PRICE         as decimal       column-label "Цена блюда"
field   PARENT        as integer       column-label "Идентификатор группы"
field   DEL           as logical       column-label "удаленное / действующee"
field   bar-code-chr  as character     column-label "штрих-код"
&if "{2}" = "temp" &then
field   lvl-num       as integer
&endif
index pi is unique primary
SIFR
index itype
treetype
.

define {1} temp-table {2}-modify no-undo
field   SIFR       as integer      column-label "Идентификатор"
field   NAME       as character    column-label "Название"
field   REALPRICE  as decimal      column-label "Не используется"
field   DEL        as logical      column-label "удаленный / действующий"
field   parent     as integer      column-label "код группы"
index pi is unique primary
SIFR.

define {1} temp-table {2}-money no-undo
field   SIFR       as integer    column-label "Идентификатор"
field   NAME       as character  column-label "Название"
field   CODE-str   as character  column-label "код"
field   KURS       as decimal    column-label "курс"
field   PARENT     as integer    column-label "Идентификатор группы"
field   DEL        as logical    column-label "удаленная / действующая"
field   TIP        as integer    column-label "Тип платежа/валюты" /*"-наличные; 2-кредитные карты; 3-неплательщики; 4-безналичные*/
field   TREE       as logical    column-label "Тип записи"  /*T'-группа валют;  'F'-валюта*/
index pi is unique primary
sifr.


define {1} temp-table {2}-Personal no-undo
field   SIFR     as integer   column-label "Идентификатор"
field   NAME     as character column-label "имя"
field   CODE-str as character column-label  "код"
field   TYPE     as character column-label "тип" /*'W'-официант; 'M'-менеджер; 'K'-кассир; 'B'-бармен*/
field   DEL      as logical   column-label " удаленный / действующий"
index pi is unique primary
sifr.

define {1} temp-table {2}-Reasons no-undo /* - причины удалений*/
field  SIFR     as integer    column-label "Идентификатор"
field  NAME     as character  column-label "название"
field  USED     as logical    column-label "применять списание" /*'T'-списывать со склада; 'F'-не списывать*/
field  DEL      as logical    column-label "удаленная / действующая"
index pi is unique primary
sifr.

define {1} temp-table {2}-Charges   no-undo   /* - список скидок и наценок*/
field  SIFR     as integer    column-label "Идентификатор"
field  NAME     as character  column-label "Название"
field  DEL      as logical    column-label "удаленная / действующая"
index pi is unique primary
sifr.


define {1} temp-table {2}-Avcheck no-undo  /*- удаленные из заказов блюда*/
field  LOGICDATE as date  column-label "Кассовая дата"
field  REALDATE  as date  column-label "Физическая дата"
field  f_TIME      as character   column-label "Физическое время"
field  SIFR      as integer     column-label "Идентификатор"
field  COMP      as integer     column-label "Тип строчки" /*0 - блюдо;  1,2 - модификатор*/
field  QNT       as decimal     column-label "количество"
field  PRICE     as decimal      column-label "цена"
field  REASON    as integer    column-label "причина удаления"
field  MANAGER   as integer    column-label "Идентификатор менеджера"
field  WAITER    as integer    column-label "Идентификатор официанта"
field  TABLE_     as character  column-label "стол"
field  UNIT      as character  column-label "станция"
field  DEPART    as character  column-label "группа станций"
&if "{2}" = "temp" &then
field  sys_num   as integer    column-label "ссылка на номер чека которую мы сами прописали"
field  del-time   as decimal
field  line-num   as integer
&endif
index pi is primary
sifr
&if "{2}" = "temp" &then
index ifind
depart
unit
logicdate
del-time
index isys_num
sys_num
index iline-num
sys_num
line-num
&endif
.

define {1} temp-table {2}-Acheck no-undo  /* - список чеков*/
field  SYS_NUM     as integer column-label  "Идентификатор чека"
field  CNUM        as integer column-label "Номер чека"
field  LOGICDATE   as date column-label "кассовая дата закрытия чека"
field  REALDATE    as date column-label "физическая дата закрытия чека"
field  OPENTIME    as character column-label "время открытия заказа"
field  CLOSETIME   as character column-label "время закрытия заказа"
field  COVER       as integer column-label "кол-во гостей"
field  CASHIER     as integer column-label "Идентификатор кассира"
field  WAITER      as integer column-label "Идентификатор официанта"
field  UNIT        as character column-label "станция"
field  DEPART      as character column-label "группа станций"
field  TOTAL       as decimal column-label "сумма чека без всех скидок/наценок в базовой валюте"
field  BASEKURS    as decimal column-label "курс базовой валюты"
field  DELETED     as integer              /*0-чек не удален; иначе-Идентификатор причины удалени*/
field  MANAGER     as integer column-label "Идентификатор менеджера"
field  CHARGE      as decimal column-label "Не используется"
field  TABLE_      as integer column-label "стол"
field  OPENDATE    as date    column-label "Кассовая дата открытия заказа"
field  NACKURS     as decimal column-label "курс национальной валюты"
field  TAXSUM      as decimal column-label "сумма налога с продаж в базовой валюте"
field  TAXRATE     as decimal column-label "отношение налог с продаж/(сумма чека+налог)" /* без учета скидок на оплату и
                                  в предположении что оплата требует налог
                                 (причем налог тоже без учета скидок на оплату и ...)*/
field  DOP1        as decimal column-label "Не используется"
field  DOP2        as integer column-label "Не используется"
field  DOP3        as decimal column-label "Не используется"
field  DOP4        as decimal column-label "Не используется"
&if "{2}" = "temp" &then
field  start-time   as decimal
field  end-time     as decimal
&endif
index pi is unique primary
sys_num
&if "{2}" = "temp" &then
index ifind
depart
unit
logicdate
start-time
end-time
&endif
.


define {1} temp-table {2}-Adcheck no-undo  /*-  скидки (наценки) на чеки*/
field  SYS_NUM      as integer column-label "Идентификатор чека"
field  CNUM         as integer column-label "Номер чека"
field  SIFR         as integer column-label "Идентификатор скидки (наценки)"
field  SUM          as decimal column-label "сумма скидки (отрицательная) или наценки (положительная)"
field  CARDCOD      as integer column-label "Не используется"
field  PERSON       as integer column-label "0-автоматическая; иначе - Идентификатор применившего скидку"
/*????? */ field  dop1  as decimal column-label "?????????????????"
&if "{2}" = "temp" &then
field  line-num   as integer
&endif
index pi is primary
sys_num
&if "{2}" = "temp" &then
index iline-num
sys_num
line-num
&endif
.


define {1} temp-table {2}-Apcheck no-undo  /* - оплата чеков*/
field  SYS_NUM       as integer    column-label "Идентификатор чека"
field  CNUM          as integer    column-label "Номер чека"
field  CURRENCY      as integer    column-label "Идентификатор валюты"
field  BASESUMEQW    as decimal    column-label "сумма в базовой валюте, включающая скидку на валюту"
field  ORIGSUM       as decimal    column-label "сумма в валюте CURRENCY, не включающая скидку на валюту"
field  KURS          as decimal    column-label "курс валюты CURRENCY"
field  DISCOUNT      as decimal    column-label "скидка" /*(положительная) или наценка (отрицательная) на валюту в долях:*/
field  EXTRA         as character  column-label "Не используется"
field  DOP1          as decimal    column-label "Не используется"
field  DOP2          as decimal    column-label "Не используется"
field  DOP3          as logical    /*'T'-взимался налог с продаж; 'F'-не взималс??????????????*/
&if "{2}" = "temp" &then
field  line-num   as integer
&endif
index pi is primary
sys_num currency
&if "{2}" = "temp" &then
index iline-num
sys_num
line-num
&endif

.

define {1} temp-table {2}-Archeck  no-undo /*- блюда в чеках*/
field  SYS_NUM      as integer     column-label "Идентификатор чека"
field  CNUM         as integer     column-label "Номер чека"
field  SIFR         as integer     column-label "Идентификатор блюда или модификатора"
field  QNT          as decimal     column-label "количество порций"
field  PRICE        as decimal     column-label "цена по меню"
field  COMPONENT    as logical     column-label "'T'-модификатор; 'F'-блюдо"
field  PAYSUM       as decimal     column-label  "Сумма" /*Полученная сумма в базовой валюте, включая скидки на чек
             и не включая налог с продаж и скидки на оплату*/
field  DOP1         as decimal     column-label "Не используется"
field  NALOG        as decimal     column-label "налог с продаж в долях"
field  CONSUMANT    as logical     column-label "Консумант" /*'T'- консумант; 'F'-не консумант*/
field  PAYPRICE     as decimal     column-label "цена нетто " /*с учетом скидок на чек, но без учета НСП и скидок на оплату.*/
&if "{2}" = "temp" &then
field  line-num   as integer
&endif
index pi is primary
sys_num sifr
&if "{2}" = "temp" &then
index iline-num
sys_num
line-num
&endif
.

define {1} temp-table {2}-control  no-undo /*список экспортных файлов*/
field  FILE_        as character column-label "название файла"
field  RECORDS      as integer   column-label "количество записей"
field  RESTSIFR     as integer   column-label "Идентификатор ресторана"
field  RESTNAME     as character column-label "Название ресторана"
field  STARTDATE    as date      column-label "Начальная кассовая дата экспортируемой информации"
field  STOPDATE     as date      column-label "Конечная кассовая дата экспортируемой информации"
index pi is unique primary
file_.

/* $Workfile$ e n d */