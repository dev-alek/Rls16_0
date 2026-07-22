block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Программа генерации файла str-glbl.i

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

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
    cmp/str-glbl.p
    cmp/str-glb2.p
    cmp/str-glb3.p
    cmp/str-glb4.p
    cmp/str-glb5.p
    cmp/str-glbt.p
2. Добавить необходимые изменения в файл
3. Выложить измененный файл (checkin)
4. Сгенерировать русскую версию str-glbl.i
   Выложить русскую версию версию str-glbl.i в vss
5. Сгенерировать английскую версию str-glbl.i
   Выложить английскую версию версию str-glbl.i в vss

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

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Программа генерации файла str-glbl.i".
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
    "Необходимо задать указать язык используемый для генерации str-glbl.i" skip
    "В качестве параметра компиляции необходимо задать 'rus' или 'eng'" skip
    view-as alert-box .
  return error .
&endif

define variable v-file-name as character no-undo .

assign
  v-file-name = 'str-glbl.new'
.

run filwrlib_set-file-name in this-procedure
  (input v-file-name
  ) .

run filwrlib_clear-file in this-procedure  .

run filwrlib_append-new-line in this-procedure (input "/*" ) .
run filwrlib_append-new-line in this-procedure (input "" ) .
run filwrlib_append-new-line in this-procedure (input "$" + "Revision:" + "$" ) .
run filwrlib_append-new-line in this-procedure (input "$" + "Author:" + "$" ) .
run filwrlib_append-new-line in this-procedure (input "$" + "Date:" + "$" ) .
run filwrlib_append-new-line in this-procedure (input "$" + "Workfile:" + "$" ) .
run filwrlib_append-new-line in this-procedure (input "$" + "Archive:" + "$" ) .
run filwrlib_append-new-line in this-procedure (input "                                        " ) .
run filwrlib_append-new-line in this-procedure (input "Файл глобальных определений" ) .
run filwrlib_append-new-line in this-procedure (input "" ) .
run filwrlib_append-new-line in this-procedure (input "Автор: Перваков Михаил Сергеевич" ) .
run filwrlib_append-new-line in this-procedure (input "Дата создания: 04/05/06" ) .
run filwrlib_append-new-line in this-procedure (input "Author: Mikhail Pervakov" ) .
run filwrlib_append-new-line in this-procedure (input "Creation date: 04/05/06" ) .
run filwrlib_append-new-line in this-procedure (input "" ) .
run filwrlib_append-new-line in this-procedure (input "Этот файл сгенерирован автоматически" ) .
run filwrlib_append-new-line in this-procedure (input "Все изменения необходимо вносить в файл str-glbl.p" ) .
run filwrlib_append-new-line in this-procedure (input "" ) .
run filwrlib_append-new-line in this-procedure (input "*/" ) .
run filwrlib_append-new-line in this-procedure (input "&if defined(str-glbl_i) = 0 &then" ) .
run filwrlib_append-new-line in this-procedure (input "&glob str-glbl_i" ) .
run filwrlib_append-new-line in this-procedure (input "&global-define language {&language}" ).
run filwrlib_append-new-line in this-procedure (input '&if "~{1~}" = "class" &then' ) .
run filwrlib_append-new-line in this-procedure (input '&global-define CommentStartClass /~~* ' ) .
run filwrlib_append-new-line in this-procedure (input '&else' ) .
run filwrlib_append-new-line in this-procedure (input '&global-define CommentStartNoClass /~~* ' ) .

run filwrlib_append-new-line in this-procedure (input "define new global shared variable g#language as character no-undo ." ) .
run filwrlib_append-new-line in this-procedure (input "if g#language <> '' and g#language <> '{&language}':U then do:" ) .
run filwrlib_append-new-line in this-procedure (input "  undo, return error substitute( '&1. incorrect language&2str-glbl: {&language}&2db: &3':U, this-procedure :file-name, chr(10), g#language  )." ) .
run filwrlib_append-new-line in this-procedure (input "end." ) .
run filwrlib_append-new-line in this-procedure (input '&endif' ) .
run filwrlib_append-new-line in this-procedure (input "/* имена национальной валюты и её производных */" ) .
run filwrlib_append-new-line in this-procedure (input "~{ cmp/abbr-nc.i ~}" ) .
run filwrlib_append-new-line in this-procedure (input "/* Имена таблиц БД */" ) .
run filwrlib_append-new-line in this-procedure (input "~{ cmp/tbl-name.i ~}" ) .

/* имя базы данных */
&glob db-name ub
run filwrlib_append-new-line in this-procedure ( input "&global-define db-name {&db-name}" ).
&glob db-name_schema ub
run filwrlib_append-new-line in this-procedure ( input "&global-define db-name_schema {&db-name_schema}" ).
&glob db-name-news io
run filwrlib_append-new-line in this-procedure ( input "&global-define db-name-news {&db-name-news}" ).
&glob db-alias-list '{&db-name-news}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define db-alias-list {&db-alias-list}" ).
&glob key-unload-db 'unload-db':U
run filwrlib_append-new-line in this-procedure ( input "&global-define key-unload-db {&key-unload-db}" ).

/* Разделитель для формирования строк в СПН */
&glob delim-nws chr(1)
run filwrlib_append-new-line in this-procedure ( input "&global-define delim-nws {&delim-nws}" ).

/* Разделитель для формирования уникального ключа записи */ /* И ТОЛЬКО ДЛЯ ЭТОГО!!! */
&glob delim-key chr(3)
run filwrlib_append-new-line in this-procedure ( input "&global-define delim-key {&delim-key}  /* Разделитель для формирования уникального ключа записи */ /* И ТОЛЬКО ДЛЯ ЭТОГО!!! */ " ).

/* Разделитель для формирования замены delim-key  в key-rec уникального ключа записи */ /* И ТОЛЬКО ДЛЯ ЭТОГО!!! */
&glob delim-key-rep chr(2) + chr(9) + chr (2)
run filwrlib_append-new-line in this-procedure ( input "&global-define delim-key-rep {&delim-key-rep}  /* Разделитель для формирования замены delim-key  в key-rec уникального ключа записи */ /* И ТОЛЬКО ДЛЯ ЭТОГО!!! */ " ).


/* Разделитель для формирования списка параметров */
&glob delim-par chr(4)
run filwrlib_append-new-line in this-procedure ( input "&global-define delim-par {&delim-par}" ).

/* Разделитель для формирования уникального ключа строки маршрутизации СПН */ /* И ТОЛЬКО ДЛЯ ЭТОГО!!! */
&glob delim-urt chr(5)
run filwrlib_append-new-line in this-procedure ( input "&global-define delim-urt {&delim-urt}" ).

/* Разделитель для формирования команд СПН */ /* И ТОЛЬКО ДЛЯ ЭТОГО!!! */
&glob delim-cmd chr(6)
run filwrlib_append-new-line in this-procedure ( input "&global-define delim-cmd {&delim-cmd}" ).

/* Разделитель полей при экспорте/импорте записей таблиц в пакеты СПН */ /* И ТОЛЬКО ДЛЯ ЭТОГО!!! */
&glob delim-nps chr(7)
run filwrlib_append-new-line in this-procedure ( input "&global-define delim-nps {&delim-nps} /* Разделитель полей при экспорте/импорте записей таблиц в пакеты СПН */ /* И ТОЛЬКО ДЛЯ ЭТОГО!!! */ " ).

/* Разделитель полей соответствия имен полей, меток и формата для показа изменнений исторических таблиц */
&glob delim-flf chr(8)
run filwrlib_append-new-line in this-procedure ( input "&global-define delim-flf {&delim-flf} /* Разделитель полей соответствия имен полей, меток и формата для показа изменнений исторических таблиц */ " ).

/* Префикс для технических марок (для маркированной продукции) */
&glob tech-mark-prefix 'tech_':U
run filwrlib_append-new-line in this-procedure ( input "&global-define tech-mark-prefix {&tech-mark-prefix}" ).

/* Супер системный ключ */
&glob SuperSysKey 'ExpertekIBS':U
run filwrlib_append-new-line in this-procedure ( input "&global-define SuperSysKey {&SuperSysKey}" ).

/* типы маршрутизации */
&glob send-tbl-oxml 'send-tbl-oxml':U
run filwrlib_append-new-line in this-procedure ( input "&global-define send-tbl-oxml {&send-tbl-oxml}" ).
&glob send-cmd-oxml 'send-cmd-oxml':U
run filwrlib_append-new-line in this-procedure ( input "&global-define send-cmd-oxml {&send-cmd-oxml}" ).
&glob send-tbl 'send-tbl':U
run filwrlib_append-new-line in this-procedure ( input "&global-define send-tbl {&send-tbl}" ).
&glob send-cmd 'send-cmd':U
run filwrlib_append-new-line in this-procedure ( input "&global-define send-cmd {&send-cmd}" ).
&glob send-del-tbl 'send-del-tbl':U
run filwrlib_append-new-line in this-procedure ( input "&global-define send-del-tbl {&send-del-tbl}" ).

/* действия процедур, вызываемых по новостям */
&glob nwspck-end  '**END OF PACKET**':U
run filwrlib_append-new-line in this-procedure ( input "&global-define nwspck-end {&nwspck-end}" ).
&glob cmd-request-goods 'cmd-request-goods':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-request-goods {&cmd-request-goods}" ).
&glob cmd-transfer-goods 'cmd-transfer-goods':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-transfer-goods {&cmd-transfer-goods}" ).
&glob cmd-parts-split 'cmd-parts-split':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-parts-split {&cmd-parts-split}" ).
&glob cmd-imp-rec-without-trg 'cmd-imp-rec-without-trg':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-imp-rec-without-trg {&cmd-imp-rec-without-trg}" ).
&glob cmd-del-rec-without-trg 'cmd-del-rec-without-trg':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-del-rec-without-trg {&cmd-del-rec-without-trg}" ).
&glob cmd-send-binary 'cmd-send-binary':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-send-binary {&cmd-send-binary}" ).
&glob cmd-send-lob 'cmd-send-lob':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-send-lob {&cmd-send-lob}" ).
&glob cmd-process-saledc 'cmd-process-saledc':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-process-saledc {&cmd-process-saledc}" ).
&glob cmd-dct-send 'cmd-dct-send':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-dct-send {&cmd-dct-send}" ).
&glob cmd-rum-send 'cmd-rum-send':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-rum-send {&cmd-rum-send}" ).
&glob cmd-trn-doc-fact 'cmd-trn-doc-fact':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-trn-doc-fact {&cmd-trn-doc-fact}" ).
&glob cmd-rcv-doc-rcv 'cmd-rcv-doc-rcv':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-rcv-doc-rcv {&cmd-rcv-doc-rcv}" ).
&glob cmd-rcv-doc-fact 'cmd-rcv-doc-fact':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-rcv-doc-fact {&cmd-rcv-doc-fact}" ).
&glob cmd-ord-doc-fact 'cmd-ord-doc-fact':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-ord-doc-fact {&cmd-ord-doc-fact}" ).
&glob cmd-s-f-doc-fact 'cmd-s-f-doc-fact':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-s-f-doc-fact {&cmd-s-f-doc-fact}" ).
&glob cmd-esys-general 'cmd-esys-general':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-esys-general {&cmd-esys-general}" ).
&glob cmd-pdf-fact 'cmd-pdf-fact':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-pdf-fact {&cmd-pdf-fact}" ).
&glob cmd-parts-fact-corr 'cmd-parts-fact-corr':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-parts-fact-corr {&cmd-parts-fact-corr}" ).
&glob cmd-nws2esys-general 'cmd-nws2esys-general':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-nws2esys-general {&cmd-nws2esys-general}" ).
&glob cmd-chg-utd-sts 'cmd-chg-utd-sts':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cmd-chg-utd-sts {&cmd-chg-utd-sts}" ).




/* Разделитель для формирования имен групп товаров клиентов и т.д. */
&glob delim-grp chr(47)
run filwrlib_append-new-line in this-procedure ( input "&global-define delim-grp {&delim-grp}" ).

/*запрещенные символы для названия файлов и директорий*/
&glob file-name-invalid-char '\/:*?""<>|':U
run filwrlib_append-new-line in this-procedure ( input "&global-define file-name-invalid-char {&file-name-invalid-char}" ).

&glob file-name-invalid-char-name 'b-slash,slash,colon,star,question,d-quote,d-quote,less-t,great-t,pipe':U
run filwrlib_append-new-line in this-procedure ( input "&global-define file-name-invalid-char-name {&file-name-invalid-char-name}" ).


/* Специальные символы */
&glob backspace       chr(8)
run filwrlib_append-new-line in this-procedure ( input "&global-define backspace {&backspace}" ).
&glob tabulation      chr(9)
run filwrlib_append-new-line in this-procedure ( input "&global-define tabulation {&tabulation}" ).
&glob new-line        chr(10)
run filwrlib_append-new-line in this-procedure ( input "&global-define new-line {&new-line}" ).
&glob new-page chr(12)
run filwrlib_append-new-line in this-procedure ( input "&global-define new-page {&new-page}" ).
&glob carriage-return chr(13)
run filwrlib_append-new-line in this-procedure ( input "&global-define carriage-return {&carriage-return}" ).
&glob space-char      chr(32)
run filwrlib_append-new-line in this-procedure ( input "&global-define space-char {&space-char}" ).
&glob double-quote    chr(34)
run filwrlib_append-new-line in this-procedure ( input "&global-define double-quote {&double-quote}" ).
&glob dollar          chr(36)
run filwrlib_append-new-line in this-procedure ( input "&global-define dollar {&dollar}" ).
&glob ampersand    chr(38)
run filwrlib_append-new-line in this-procedure ( input "&global-define ampersand {&ampersand}" ).
&glob single-quote    chr(39)
run filwrlib_append-new-line in this-procedure ( input "&global-define single-quote {&single-quote}" ).
&glob comma-char      chr(44)
run filwrlib_append-new-line in this-procedure ( input "&global-define comma-char {&comma-char}" ).
&glob slash-char      chr(47)
run filwrlib_append-new-line in this-procedure ( input "&global-define slash-char {&slash-char}" ).
&glob colon-char      chr(58)
run filwrlib_append-new-line in this-procedure ( input "&global-define colon-char {&colon-char}" ).
&glob question-mark   chr(63)
run filwrlib_append-new-line in this-procedure ( input "&global-define question-mark {&question-mark}" ).
&glob back-slash-char chr(92)
run filwrlib_append-new-line in this-procedure ( input "&global-define back-slash-char {&back-slash-char}" ).
&glob back-quote      chr(96)
run filwrlib_append-new-line in this-procedure ( input "&global-define back-quote {&back-quote}" ).
&glob left-brace      chr(123)
run filwrlib_append-new-line in this-procedure ( input "&global-define left-brace {&left-brace}" ).
&glob vertical-line     chr(124)
run filwrlib_append-new-line in this-procedure ( input "&global-define vertical-line {&vertical-line}" ).
&glob right-brace     chr(125)
run filwrlib_append-new-line in this-procedure ( input "&global-define right-brace {&right-brace}" ).
&glob tilda-char      chr(126)
run filwrlib_append-new-line in this-procedure ( input "&global-define tilda-char {&tilda-char}" ).
&glob delete-char      chr(127)
run filwrlib_append-new-line in this-procedure ( input "&global-define delete-char {&delete-char}" ).
&glob start-comment chr(47) + chr(42)
run filwrlib_append-new-line in this-procedure ( input "&global-define start-comment {&start-comment}" ).
&glob end-comment chr(42) + chr(47)
run filwrlib_append-new-line in this-procedure ( input "&global-define end-comment {&end-comment}" ).
&glob std-vss-header {&start-comment} + {&new-line} + {&new-line} + {&dollar} + 'Revision: ':U + {&dollar} + {&new-line} + {&dollar} + 'Author: ':U + {&dollar} + {&new-line} + {&dollar} + 'Date: ':U + {&dollar} +  {&new-line} + {&dollar} + 'Workfile: ':U + {&dollar} + {&new-line}  + {&dollar} + 'Archive: ':U + {&dollar} + {&new-line} + {&new-line} + 'ФАЙЛ ГЕНЕРИРУЕТСЯ ПРОЦЕДУРОЙ ' + program-name(1) + {&new-line} + {&new-line} + {&end-comment} + {&new-line}
run filwrlib_append-new-line in this-procedure ( input "&global-define std-vss-header {&std-vss-header}" ).
&glob std-vss-tail {&start-comment} + ' ':U + {&dollar} + 'Workfile: ':U + {&dollar} + ' e n d ':U + {&end-comment} + {&new-line}
run filwrlib_append-new-line in this-procedure ( input "&global-define std-vss-tail {&std-vss-tail}" ).
&glob end-of-age      12/31/9999
run filwrlib_append-new-line in this-procedure ( input "&global-define end-of-age {&end-of-age}" ).



/* определение типов - для передачи информации о типе в параметрах */
&glob type-char 'C':U
run filwrlib_append-new-line in this-procedure ( input "&global-define type-char {&type-char}" ).
&glob type-log  'L':U
run filwrlib_append-new-line in this-procedure ( input "&global-define type-log {&type-log}" ).
&glob type-dec  'D':U
run filwrlib_append-new-line in this-procedure ( input "&global-define type-dec {&type-dec}" ).
&glob type-int  'I':U
run filwrlib_append-new-line in this-procedure ( input "&global-define type-int {&type-int}" ).
&glob type-date 'T':U
run filwrlib_append-new-line in this-procedure ( input "&global-define type-date {&type-date}" ).
&glob type-widget-handle 'W':U
run filwrlib_append-new-line in this-procedure ( input "&global-define type-widget-handle {&type-widget-handle}" ).
&glob type-com-handle 'H':U
run filwrlib_append-new-line in this-procedure ( input "&global-define type-com-handle {&type-com-handle}" ).
&glob type-object 'O':U
run filwrlib_append-new-line in this-procedure ( input "&global-define type-object {&type-object}" ).

&glob cntxt-global 'global':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cntxt-global {&cntxt-global}" ).
&glob cntxt-firm 'firm':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cntxt-firm {&cntxt-firm}" ).
&glob cntxt-object 'object':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cntxt-object {&cntxt-object}" ).

&glob action-item-type_disable 'disable':U
run filwrlib_append-new-line in this-procedure ( input "&global-define action-item-type_disable {&action-item-type_disable}" ).
&glob action-item-type_enable 'enable':U
run filwrlib_append-new-line in this-procedure ( input "&global-define action-item-type_enable {&action-item-type_enable}" ).

&glob rpt-code_column-width 'column-width':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rpt-code_column-width {&rpt-code_column-width}" ).

&glob uls-normal 0
run filwrlib_append-new-line in this-procedure ( input "&global-define uls-normal {&uls-normal}" ).
&glob uls-disabled 1
run filwrlib_append-new-line in this-procedure ( input "&global-define uls-disabled {&uls-disabled}" ).

&glob menu-code-main 0
run filwrlib_append-new-line in this-procedure ( input "&global-define menu-code-main {&menu-code-main}" ).

&glob action-head-code-main 0
run filwrlib_append-new-line in this-procedure ( input "&global-define action-head-code-main {&action-head-code-main}" ).

/* Разделитель сложного поля для фильтра */
&glob delim-flt *
run filwrlib_append-new-line in this-procedure ( input "&global-define delim-flt {&delim-flt}" ).
&glob delim-flt-tilda ^
run filwrlib_append-new-line in this-procedure ( input "&global-define delim-flt-tilda {&delim-flt-tilda}" ).

/* форматы сложного поля для rcs-таблиц работающих в кассах */
&glob cd-goods-obj-format '>>>>9':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-goods-obj-format {&cd-goods-obj-format}" ).
&glob cd-goods-code-format '99999':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-goods-code-format {&cd-goods-code-format}" ).
&glob cd-goods-longcode-format '->>>>>>>>9':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-goods-longcode-format {&cd-goods-longcode-format}" ).



/* типы бар-кодов */
&GLOB barcode-ean8 'ean8':U
run filwrlib_append-new-line in this-procedure ( input "&global-define barcode-ean8 {&barcode-ean8}" ).
&GLOB barcode-ean13 'ean13':U
run filwrlib_append-new-line in this-procedure ( input "&global-define barcode-ean13 {&barcode-ean13}" ).
&GLOB barcode-3of9 '3of9':U
run filwrlib_append-new-line in this-procedure ( input "&global-define barcode-3of9 {&barcode-3of9}" ).
&GLOB barcode-ean128 'ean128':U
run filwrlib_append-new-line in this-procedure ( input "&global-define barcode-ean128 {&barcode-ean128}" ).

/* валюта продажи: базовая  р у б л и */
{ cmp/cr-prep.i 1 r-b  r-b "Тип валюты продаж"   r-b "Sales currency type" }
{ cmp/cr-prep.i 1 r-b-rubl  rubl "{&scop-begin}abbr_rub{&scop-end}." rubl "rubl" }
{ cmp/cr-prep.i 1 r-b-base  base "вал." base "base" }

/* Типы состояния основных средств */
{ cmp/cr-prep.i 1 os-reserve  Резерв            " " reserve  }
{ cmp/cr-prep.i 1 os-used     Используется      " " used     }
{ cmp/cr-prep.i 1 os-amortiz  Амортизировано    " " amortiz  }
{ cmp/cr-prep.i 1 os-destroy  Ликвидировано     " " destroy  }
{ cmp/cr-prep.i 1 os-transf   БезвозПередано    " " transfer }
{ cmp/cr-prep.i 1 os-sell     Продано           " " sell     }


/* _________________________________________________________________________________________ */

/*                    ПРЕПРОЦЕССИНГИ ДЛЯ ПЕРЕВОДА НА РАЗНЫЕ ЯЗЫКИ                            */

/* _________________________________________________________________________________________ */

/* типы записей BatchProcess */
{ cmp/cr-prep.i 1 btpr-normal     "N"  " " "N" }
{ cmp/cr-prep.i 1 btpr-executing  "X"  " " "X" }
{ cmp/cr-prep.i 1 btpr-deleted    "D"  " " "D" }

{ cmp/cr-prep.i 1 btpr-type-autonws    "autonws" " " "autonws" } /* "Обмен новостями" */
{ cmp/cr-prep.i 1 btpr-type-autoarh    "autoarh" " " "autoarh" } /* "Расчет архивов"  */
{ cmp/cr-prep.i 1 btpr-type-autoexp    "autoexp" " " "autoexp" } /* "Экспорт"         */
{ cmp/cr-prep.i 1 btpr-type-autooxml   "autooxml" " " "autooxml" } /* "OpenXML"         */
{ cmp/cr-prep.i 1 btpr-type-autoupg    "autoupg" " " "autoupg" } /* "Upgrade"         */
{ cmp/cr-prep.i 1 btpr-type-autogetcd  "autogcd" " " "autogcd" } /* "Прием информации с касс"         */
{ cmp/cr-prep.i 1 btpr-type-autosale   "autosale" " " "autosale" } /* "Автоматическая работа с продажей" */
{ cmp/cr-prep.i 1 btpr-type-autosuz    "autosuz" " " "autosuz" } /* "Отчеты в excel для суздальского" */
{ cmp/cr-prep.i 1 btpr-type-autocbnk   "autocbnk" " " "autocbnk" } /* "Автоматическая работа с системой клиент-банк" */
{ cmp/cr-prep.i 1 btpr-type-autofree   "autofree" " " "autofree" } /* "Выполнение по расписанию произвольного задания" */
{ cmp/cr-prep.i 1 btpr-type-mercury    "mercury" " " "mercury" } /* "Выполнение по расписанию обмена с ФГИС Меркурий" */
{ cmp/cr-prep.i 1 btpr-type-is_motp    "is_motp" " " "is_motp" } /* "Выполнение по расписанию обмена с ИС МОТП" */
{ cmp/cr-prep.i 1 btpr-type-is_diadoc  "is_diadoc" " " "is_diadoc" } /* "Выполнение по расписанию обмена с ИС МОТП" */
{ cmp/cr-prep.i 1 btpr-type-hddtest    "hddtest" " " "hddtest" } /* "Выполнение по расписанию запросов на кассу о состоянии HDD" */
{ cmp/cr-prep.i 1 btpr-type-cutdbs     "cutdbs"  " " "cutdbs"  } /* "Обрезание документов по БД"      */
{ cmp/cr-prep.i 1 btpr-type-lock-route "lkrt"    " " "lkrt"    } /* блокировка маршрутизации          */
{ cmp/cr-prep.i 1 btpr-type-lock-ext-sys-route "lkes"    " " "lkes"  } /* блокировка маршрутизации внешней системы OpenXML  */
{ cmp/cr-prep.i 1 btpr-type-arh        "arh"     " " "arh"     }
{ cmp/cr-prep.i 1 btpr-type-ahsp       "ahsp"    " " "ahsp"    }
{ cmp/cr-prep.i 1 btpr-type-prc        "prc"     " " "prc"     }
{ cmp/cr-prep.i 1 btpr-type-trnhd      "trnhd"   " " "trnhd"   }
{ cmp/cr-prep.i 1 btpr-type-twotpl     "twotpl"   " " "twotpl" } /* Двойники в приоритетах ТПЛ */
{ cmp/cr-prep.i 1 btpr-type-lock       "lock"    " " "lock"    }
{ cmp/cr-prep.i 1 btpr-type-lock-user  "lusr"    " " "lusr"    }
{ cmp/cr-prep.i 1 btpr-type-hold       "hold"    " " "hold"    }
{ cmp/cr-prep.i 1 btpr-type-hinv       "hinv"    " " "hinv"    }
{ cmp/cr-prep.i 1 btpr-type-hspi       "hspi"    " " "hspi"    }
{ cmp/cr-prep.i 1 btpr-type-aht        "aht"     " " "aht"     }
{ cmp/cr-prep.i 1 btpr-type-rt-doc     "rt-doc"  " " "rt-doc"  }
{ cmp/cr-prep.i 1 btpr-type-rt-line    "rt-line" " " "rt-line" }
{ cmp/cr-prep.i 1 btpr-type-rt-bcprint "bcprint" " " "bcprint" }
{ cmp/cr-prep.i 1 btpr-type-oxml-new   "oxmlnew" " " "oxmlnew" }
{ cmp/cr-prep.i 1 btpr-type-mt-poslock "mtposlck" " " "mtposlck" }
{ cmp/cr-prep.i 1 btpr-type-sktsrv     "sktsrv" " " "sktsrv"   }
{ cmp/cr-prep.i 1 btpr-type-is_PM      "is_PM"  " " "is_PM"    } /* "Выполнение по расписанию выгрузку в ИС ПМ" */

&glob btpr-type-gds 'gds':U
run filwrlib_append-new-line in this-procedure ( input "&global-define btpr-type-gds {&btpr-type-gds}" ).
&glob btpr-type-dcard 'dcard':U
run filwrlib_append-new-line in this-procedure ( input "&global-define btpr-type-dcard {&btpr-type-dcard}" ).
&glob btpr-type-goa 'goa':U
run filwrlib_append-new-line in this-procedure ( input "&global-define btpr-type-goa {&btpr-type-goa}" ).
&glob btpr-type-seller 'slr':U
run filwrlib_append-new-line in this-procedure ( input "&global-define btpr-type-seller {&btpr-type-seller}" ).
&glob btpr-type-cashier 'cshr':U
run filwrlib_append-new-line in this-procedure ( input "&global-define btpr-type-cashier {&btpr-type-cashier}" ).
&glob btpr-type-move-object 'mvob':U
run filwrlib_append-new-line in this-procedure ( input "&global-define btpr-type-move-object {&btpr-type-move-object}" ).
&glob btpr-type-bcode 'bcode':U
run filwrlib_append-new-line in this-procedure ( input "&global-define btpr-type-bcode {&btpr-type-bcode}" ).
&glob btpr-type-fgrp 'fgrp':U
run filwrlib_append-new-line in this-procedure ( input "&global-define btpr-type-fgrp {&btpr-type-fgrp}" ).
&glob btpr-type-ren-art 'rnar':U
run filwrlib_append-new-line in this-procedure ( input "&global-define btpr-type-ren-art {&btpr-type-ren-art}" ).
&glob btpr-type-nws-coll 'coll':u
run filwrlib_append-new-line in this-procedure ( input "&global-define btpr-type-nws-coll {&btpr-type-nws-coll}" ).


&Glob bef-nws-coll_inn-uniq ncoll_inn
run filwrlib_append-new-line in this-procedure ( input "&global-define bef-nws-coll_inn-uniq {&bef-nws-coll_inn-uniq}" ).
&Glob nws-coll_inn-uniq '{&bef-nws-coll_inn-uniq}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define nws-coll_inn-uniq {&nws-coll_inn-uniq}" ).
&Glob bef-nws-coll_inn-uniq-full Коллизия по ~{&abbr_inn_allshift}
run filwrlib_append-new-line in this-procedure ( input "&global-define bef-nws-coll_inn-uniq-full {&bef-nws-coll_inn-uniq-full}" ).
&Glob nws-coll_inn-uniq-full '{&bef-nws-coll_inn-uniq-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define nws-coll_inn-uniq-full {&nws-coll_inn-uniq-full}" ).


&glob nws-coll_codes ~
'{&bef-nws-coll_inn-uniq}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define nws-coll_codes {&nws-coll_codes}" ).

&glob nws-coll_codes-full ~
'{&bef-nws-coll_inn-uniq-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define nws-coll_codes-full {&nws-coll_codes-full}" ).

&glob nws-coll_name entry (lookup (~~~~~~~{&nws-coll_code}, {&nws-coll_codes}), {&nws-coll_codes-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define nws-coll_name {&nws-coll_name}" ).


/* типы межфирменных архивов */
/* основные межфирменные архивы */
&glob hold-main-cat-code  1
run filwrlib_append-new-line in this-procedure ( input "&global-define hold-main-cat-code {&hold-main-cat-code}" ).
/* архивы инвентаризации */
&glob hold-inv-cat-code  2
run filwrlib_append-new-line in this-procedure ( input "&global-define hold-inv-cat-code {&hold-inv-cat-code}" ).
/* архивы списания */
&glob hold-spi-cat-code  3
run filwrlib_append-new-line in this-procedure ( input "&global-define hold-spi-cat-code {&hold-spi-cat-code}" ).

/* Перечислимые типы */
{ cmp/cr-prep.i 1 update        ИЗМЕНЕНИЕ           " " UPDATE}
{ cmp/cr-prep.i 1 autoupdate    АВТОИЗМЕНЕНИЕ       " " AUTOUPDATE}
{ cmp/cr-prep.i 1 lookup        ПРОСМОТР            " " LOOKUP}
{ cmp/cr-prep.i 1 add-def       ДОБАВЛЕНИЕ          " " CREATE}
{ cmp/cr-prep.i 1 leave         ОСТАВИТЬ            " " LEAVE}
{ cmp/cr-prep.i 1 deleted-stat_ " ---  УДАЛЕН  ---" " " " ---  DELETED ---"}
{ cmp/cr-prep.i 2 update add-def}
{ cmp/cr-prep.i 1 add-copy      КОПИРОВАНИЕ         " " COPY}
{ cmp/cr-prep.i 1 add-import    ДОБАВЛЕНИЕ-ИМПОРТ   " " add-import}
{ cmp/cr-prep.i 1 select        ВЫБОР               " " select}
{ cmp/cr-prep.i 1 verify        ПРОВЕРКА            " " verify}
{ cmp/cr-prep.i 1 inv-def       БЕЗ_ПРИЗНАКОВ       " " NO-SCALE}
{ cmp/cr-prep.i 1 prt-def       ШКАЛА               " " SCALE}
{ cmp/cr-prep.i 1 empty-scale   "_Пустая шкала"     " " EMPTY-SCALE}
{ cmp/cr-prep.i 1 g#term        терм                " " term}
{ cmp/cr-prep.i 1 g#root        корн                " " root}
{ cmp/cr-prep.i 1 free-code     free-zone           " " free-zone}
{ cmp/cr-prep.i 1 output-code   out-zone            " " out-zone}
{ cmp/cr-prep.i 1 forged        фальшивый           " " forged}         /*фальшивая зона*/
{ cmp/cr-prep.i 1 put-zone      put-zone            " " put-zone}
{ cmp/cr-prep.i 1 cli-zone      cli-zone            " " cli-zone}
{ cmp/cr-prep.i 1 oldret-code   "стар. приход"      " " OLD-ACCEPT}
{ cmp/cr-prep.i 1 part-split    #                   " " #}


{ cmp/cr-prep.i 1 flag          ФЛАГ                " " FLAG}
{ cmp/cr-prep.i 1 type          ТИП                 " " TYPE}
{ cmp/cr-prep.i 1 c-type        УД_ТИП              " " DEL_TYPE}
{ cmp/cr-prep.i 1 in_           ВНУ                 " " INT}
{ cmp/cr-prep.i 1 attr          АТР                 " " attr}

{ cmp/cr-prep.i 1 inquiry       запрос              " " inqr}
{ cmp/cr-prep.i 1 wayb          накл                " " wayb}
{ cmp/cr-prep.i 1 permitted     разрешен            " " perm}
{ cmp/cr-prep.i 1 fact          факт                " " fact}
{ cmp/cr-prep.i 1 free          свободно            " " free}
{ cmp/cr-prep.i 1 cash-desk     касс                " " POS}
{ cmp/cr-prep.i 1 expected      ожид                " " expt}
{ cmp/cr-prep.i 1 manufactured  прво                " " mnfc}
{ cmp/cr-prep.i 1 ready         готов               " " read}
{ cmp/cr-prep.i 1 rejected      отказ               " " reject}
&glob trn-stat '{&bef-inquiry},{&bef-wayb},{&bef-permitted},{&bef-fact},{&bef-cash-desk},{&bef-manufactured},{&bef-ready},{&bef-rejected}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define trn-stat {&trn-stat}" ).

{ cmp/cr-prep.i 1 income        при                 " " acp }
{ cmp/cr-prep.i 1 expense       рас                 " " exp }
{ cmp/cr-prep.i 1 write-off     спи                 " " off }
{ cmp/cr-prep.i 1 return        возврат             " " ret }
{ cmp/cr-prep.i 1 inventory     инв                 " " inv }
&glob trn-type '{&bef-income},{&bef-expense},{&bef-write-off},{&bef-return},{&bef-inventory}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define trn-type {&trn-type}" ).

{ cmp/cr-prep.i 1 corr_acc_pr_view куц " " cap }

{ cmp/cr-prep.i 1 icnt-doc      инв-сч-трк           " " inv-cnt-pump }
{ cmp/cr-prep.i 1 icnt-err      сч-трк-погр          " " err-cnt-pump }

&glob icnt-type '{&bef-icnt-doc}~
,{&bef-icnt-err}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define icnt-type {&icnt-type}" ).

/* для бухгалтерии - список внутренних кодов операций по продажам */
&GLOB bgh-std-inner-sale '{&bef-expense},{&bef-return},inkas-pay':U
run filwrlib_append-new-line in this-procedure ( input "&global-define bgh-std-inner-sale {&bgh-std-inner-sale}" ).

{ cmp/cr-prep.i 1 close-doc      "<закрытие документа>"                         " " "<close document>"}
{ cmp/cr-prep.i 1 open-doc       "<открытие документа>"                         " " "<open document>"}
{ cmp/cr-prep.i 1 reserv-doc     "<резервирование по документу>"                " " "<reserv document>"}
{ cmp/cr-prep.i 1 frozze-doc     "<перевод документа в нередактируемый статус>" " " "<frozze document>"}
{ cmp/cr-prep.i 1 close-fact     "<закрытие документа на факт>"                 " " "<close document fact>"}
/*для фин блока - при отказе банка надо сохранять документ а не удалять его совсем из статуса банк*/
{ cmp/cr-prep.i 1 reject-doc     "<отказ от документа>"                         " " "<reject document>"}

{ cmp/cr-prep.i 1 del-fact           "удаление документа закрытого на факт"           " " "delete document in status fact"}
{ cmp/cr-prep.i 1 del-ptrl-prev-shft "удаление документа по топливу в прошлых сменах" " " "delete document on petrol in prev shift"}
{ cmp/cr-prep.i 1 add-back-date      "добавление документа задним числом"             " " "add document back date"}
{ cmp/cr-prep.i 1 add-ptrl-back-date "добавление топлива в документ задним числом"   " " "add petrol in document back date"}
{ cmp/cr-prep.i 1 del-sale-fact      "удаление продажи закрытой на факт"              " " "delete sale in status fact"}
{ cmp/cr-prep.i 1 del-manuf-fact     "удаление производства закрытого на факт"        " " "delete manufactured close in fact"}
{ cmp/cr-prep.i 1 chkslpr            "право на закрытие расхода ниже учетной цен"     " " "close expense less acc-price"}

{ cmp/cr-prep.i 1 g___new       новый               " " new}
{ cmp/cr-prep.i 1 order         приказ              " " order}
{ cmp/cr-prep.i 1 act-overvalue акт                 " " overvl}
&glob pr-stat  '{&bef-new},{&bef-order},{&bef-permitted},{&bef-act-overvalue}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define pr-stat {&pr-stat}" ).

/* Статусы заказов */
{ cmp/cr-prep.i 1 ord-accept                  "согласование"        " "   agreement}
{ cmp/cr-prep.i 1 ord-rejection               "отказ"               " "   rejection}
{ cmp/cr-prep.i 1 ord-rcv                     "поставка"            " "   reciev}
{ cmp/cr-prep.i 1 ord-close                   "закрыто"             " "   close}
{ cmp/cr-prep.i 1 ord-alloc                   "распределение"       " "   allocation}
{ cmp/cr-prep.i 1 ord-req                     "запрос"              " "   request}
{ cmp/cr-prep.i 1 ord-per                     "разрешено"           " "   allocatur}
{ cmp/cr-prep.i 1 ord-ship                    "отгружено"           " "   shipment}

&glob order-status-all {&g___new},{&fact},{&ord-accept},{&ord-rejection},{&ord-rcv},{&ord-close},{&ord-alloc},{&ord-req},{&ord-per},{&ord-ship}
run filwrlib_append-new-line in this-procedure ( input "&global-define order-status-all {&order-status-all}" ).
&glob ord-status '{&bef-g___new},{&bef-fact},{&bef-ord-accept},{&bef-ord-rejection},{&bef-ord-rcv},{&bef-ord-close},{&bef-ord-alloc},{&bef-ord-req},{&bef-ord-per},{&bef-ord-ship}'
run filwrlib_append-new-line in this-procedure ( input "&global-define ord-status {&ord-status}" ).

/*Статусы ДопРасходов*/
{ cmp/cr-prep.i 1 add-close                   "закрыт"             " "   close}
&glob add-status '{&bef-g___new},{&bef-fact},{&bef-add-close}'
run filwrlib_append-new-line in this-procedure ( input "&global-define add-status {&add-status}" ).

&glob fbr-stat '{&bef-new},{&bef-permitted},{&bef-fact}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fbr-stat {&fbr-stat}" ).

{ cmp/cr-prep.i 1 rvs-before-doc   перед_док          " " before_doc }
{ cmp/cr-prep.i 1 rvs-after-doc    после_док          " " after_doc  }
{ cmp/cr-prep.i 1 rvs-shift        смена              " " shift      }
{ cmp/cr-prep.i 1 rvs-control      контроль           " " control    }
{ cmp/cr-prep.i 1 test-asi         проверка           " " test-asi   }
{ cmp/cr-prep.i 1 sht-expected     ожд                " " exp        }
{ cmp/cr-prep.i 1 sht-current      тек                " " cur        }
{ cmp/cr-prep.i 1 sht-closed       зкр                " " cls        }
{ cmp/cr-prep.i 1 sht-canceled     отм                " " cnl        }
{ cmp/cr-prep.i 1 rvs-froze        нередакт           " " froze      }
{ cmp/cr-prep.i 1 doc-froze        нередакт           " " froze      }

&glob sht-stts '{&bef-sht-expected},{&bef-sht-current},{&bef-sht-closed},{&bef-sht-canceled}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define sht-stts {&sht-stts}" ).
/*приоритет в котором будут браться смены - если если НЕСКОЛЬКО смен для одного shift-name по одному shift-date*/
&glob sht-stts-rank '2,3,1,0':U
run filwrlib_append-new-line in this-procedure ( input "&global-define sht-stts-rank {&sht-stts-rank}" ).


/* статусы системной даты объекта */
{ cmp/cr-prep.i 1 objdt-current    тек                " " cur        }
{ cmp/cr-prep.i 1 objdt-closed     зкр                " " cls        }

&glob objdt-stts '{&bef-objdt-current},{&bef-objdt-closed}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define objdt-stts {&objdt-stts}" ).

/*причины открытия-закрытия кассовых смен*/
{ cmp/cr-prep.i 1 cash-desk-on    касса-вкл         " " cash-desk-on}
{ cmp/cr-prep.i 1 obj-shift-open  смена-объект-откр " " obj-shift-open}
{ cmp/cr-prep.i 1 receipt-in      прием-чек         " " receipt-in}

{ cmp/cr-prep.i 1 gds-goods     т                   " " I}
{ cmp/cr-prep.i 1 gds-office    у                   " " S}
&glob gds-type '{&bef-gds-goods},{&bef-gds-office}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define gds-type {&gds-type}" ).

/*значения gds-obj.insalepr*/

{ cmp/cr-prep.i 1 no-insalepr-int    0         " " 0 }
{ cmp/cr-prep.i 1 insalepr-int    1         " " 1 }

&glob insalepr-int-values '~
{&bef-no-insalepr-int}~
,{&bef-insalepr-int}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define insalepr-int-values {&insalepr-int-values}" ).



/* способы округления продажной цены */
{ cmp/cr-prep.i 1 pr-round-9end    9-окончание      " " 9-ended}
{ cmp/cr-prep.i 1 pr-round-9-99end 9-99окончание    " " 9-99ended}
{ cmp/cr-prep.i 1 pr-round-integer Без-дробных      " " Integer}
{ cmp/cr-prep.i 1 pr-round-select  Произвольно      " " Optional}
{ cmp/cr-prep.i 1 pr-round-up      Вверх            " " Up}
{ cmp/cr-prep.i 1 pr-round-coef    Коэффициент      " " Coefficient}
{ cmp/cr-prep.i 1 pr-round-off     Отключено        " " Disabled}

&glob pr-rounds '{&bef-pr-round-9end},{&bef-pr-round-9-99end},{&bef-pr-round-integer},{&bef-pr-round-select},{&bef-pr-round-up},{&bef-pr-round-coef},{&bef-pr-round-off}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define pr-rounds {&pr-rounds}" ).

&glob pr-rounds-need-coef '{&bef-pr-round-select},{&bef-pr-round-up},{&bef-pr-round-coef},{&bef-pr-round-9-99end}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define pr-rounds-need-coef {&pr-rounds-need-coef}" ).


&glob pr-round-name entry (lookup (~~~~~~~{&pr-round-code}, {&pr-rounds})
run filwrlib_append-new-line in this-procedure ( input "&global-define pr-round-name {&pr-round-name}" ).

/* способы вычисления продажной цены */
{ cmp/cr-prep.i 1 pr-calc-goods        Товар            " " Item}
{ cmp/cr-prep.i 1 pr-calc-grp          Группа           " " Group}
{ cmp/cr-prep.i 1 pr-calc-cost         Учетная          " " Cost}
{ cmp/cr-prep.i 1 pr-calc-costobj      Учет-объект      " " Cost-Оbj}
{ cmp/cr-prep.i 1 pr-calc-rsrv         Учет-резерв      " " Cost-rsrv}
{ cmp/cr-prep.i 1 pr-calc-last         Приходная        " " Accept}
{ cmp/cr-prep.i 1 pr-calc-lastobj      Прих-объект      " " Accept-Obj}
{ cmp/cr-prep.i 1 pr-calc-inp          Начальная        " " Initial}
{ cmp/cr-prep.i 1 pr-calc-old          Старая           " " Actual}
{ cmp/cr-prep.i 1 pr-calc-new          Новая            " " New}
{ cmp/cr-prep.i 1 pr-calc-obj          Объект           " " Object}
{ cmp/cr-prep.i 1 pr-calc-wbill        Накладная        " " WayBill}
{ cmp/cr-prep.i 1 pr-calc-wbill-novat  Накл-безНДС      " " WayBill-VAT}
{ cmp/cr-prep.i 1 pr-calc-cost-novat   Учет-безНДС      " " Cost-VAT}
{ cmp/cr-prep.i 1 pr-calc-old-novat    Стар-безНДС      " " Actual-VAT}
{ cmp/cr-prep.i 1 pr-calc-ov           Переоценка       " " OverValue}
{ cmp/cr-prep.i 1 pr-calc-pdf          ДокФормЦены      " " PriceForm}
{ cmp/cr-prep.i 1 pr-calc-no           Отсутствует      " " Manual}
{ cmp/cr-prep.i 1 pr-calc-scale        Признак          " " Scale}
{ cmp/cr-prep.i 1 pr-calc-special      Специальная      " " Special}
{ cmp/cr-prep.i 1 pr-calc-fix          Не-считать       " " Skip}
{ cmp/cr-prep.i 1 pr-calc-base         Основная         " " Base}
{ cmp/cr-prep.i 1 pr-common            Единая           " " Common}
{ cmp/cr-prep.i 1 pr-calc-specif       Спецификация     " " Specification}
{ cmp/cr-prep.i 1 pr-calc-cost-wbill        Учет+накл        " " Cost-WayBill}
{ cmp/cr-prep.i 1 pr-calc-cost-wbill-novat  Уч+накл-НДС      " " Cost-WayBill-VAT}
{ cmp/cr-prep.i 1 pr-calc-slt               НсП              " " SLT-pc}
{ cmp/cr-prep.i 1 pr-calc-slt-wbill         НсП+накл               " " SLT-wbill}
{ cmp/cr-prep.i 1 pr-calc-cost-gr           УчетнаяS               " " CostS}
{ cmp/cr-prep.i 1 pr-calc-rsrv-gr           Учет-рзрвS             " " Cost-rsrvS}
{ cmp/cr-prep.i 1 pr-calc-last-gr           ПриходнаяS             " " AcceptS}
{ cmp/cr-prep.i 1 pr-calc-cost-novat-gr     Учет-НДСS      " " Cost-VATS}
{ cmp/cr-prep.i 1 pr-calc-undo              Откат_цен      " " Undo}
{ cmp/cr-prep.i 1 pr-calc-prod              Производит      " " Prod}
{ cmp/cr-prep.i 1 pr-calc-prod-vat          Произв-НДС      " " Prod-VAT}
{ cmp/cr-prep.i 1 pr-calc-level-prod        ПорогПр-НДС     " " level-prod}
{ cmp/cr-prep.i 1 pr-calc-level-prod-vat    ПорогПр+НДС     " " level-prod-vat}
/* Методы  автоматической переоценки из карточки товара */
&glob pr-calc-methods {&pr-calc-cost},{&pr-calc-grp},{&pr-calc-rsrv},{&pr-calc-wbill},{&pr-calc-wbill-novat},{&pr-calc-cost-novat},{&pr-calc-cost-wbill},{&pr-calc-cost-wbill-novat},{&pr-calc-fix},{&pr-calc-slt},{&pr-calc-prod},{&pr-calc-prod-vat},{&pr-calc-level-prod},{&pr-calc-level-prod-vat}
run filwrlib_append-new-line in this-procedure ( input "&global-define pr-calc-methods {&pr-calc-methods}" ).
&glob pr-calc-methods-list  '{&bef-pr-calc-cost},{&bef-pr-calc-grp},{&bef-pr-calc-rsrv},{&bef-pr-calc-wbill},{&bef-pr-calc-wbill-novat},{&bef-pr-calc-cost-novat},{&bef-pr-calc-cost-wbill},{&bef-pr-calc-cost-wbill-novat},{&bef-pr-calc-fix},{&bef-pr-calc-prod},{&bef-pr-calc-prod-vat},{&bef-pr-calc-level-prod},{&bef-pr-calc-level-prod-vat},{&bef-pr-calc-specif}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define pr-calc-methods-list {&pr-calc-methods-list}" ).
/* Методы  автоматической переоценки из корректировки группы товара */
&glob pr-calc-methods-grp {&pr-calc-cost},{&pr-calc-rsrv},{&pr-calc-wbill},{&pr-calc-wbill-novat},{&pr-calc-cost-novat},{&pr-calc-cost-wbill},{&pr-calc-cost-wbill-novat},{&pr-calc-fix},{&pr-calc-prod},{&pr-calc-prod-vat},{&pr-calc-level-prod},{&pr-calc-level-prod-vat}
run filwrlib_append-new-line in this-procedure ( input "&global-define pr-calc-methods-grp {&pr-calc-methods-grp}" ).
&glob pr-calc-methods-grp-list '{&bef-pr-calc-cost},{&bef-pr-calc-rsrv},{&bef-pr-calc-wbill},{&bef-pr-calc-wbill-novat},{&bef-pr-calc-cost-novat},{&bef-pr-calc-cost-wbill},{&bef-pr-calc-cost-wbill-novat},{&bef-pr-calc-fix},{&bef-pr-calc-prod},{&bef-pr-calc-prod-vat},{&bef-pr-calc-level-prod},{&bef-pr-calc-level-prod-vat},{&bef-pr-calc-specif}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define pr-calc-methods-grp-list {&pr-calc-methods-grp-list}" ).
/* Методы  переоценки из интерфейса */
&glob pr-calc-methods-inf {&pr-calc-goods},{&pr-calc-cost},{&pr-calc-costobj},{&pr-calc-rsrv},{&pr-calc-last},{&pr-calc-lastobj},{&pr-calc-old},{&pr-calc-new},{&pr-calc-obj},{&pr-calc-wbill},{&pr-calc-ov},{&pr-calc-wbill-novat},{&pr-calc-cost-novat},{&pr-calc-old-novat},{&pr-common},{&pr-calc-slt},{&pr-calc-slt-wbill},{&pr-calc-undo},{&pr-calc-no},{&pr-calc-fix},{&pr-calc-prod},{&pr-calc-prod-vat},{&pr-calc-level-prod},{&pr-calc-level-prod-vat}
run filwrlib_append-new-line in this-procedure ( input "&global-define pr-calc-methods-inf {&pr-calc-methods-inf}" ).
&glob pr-calc-methods-inf-list '{&bef-pr-calc-goods},{&bef-pr-calc-cost},{&bef-pr-calc-costobj},{&bef-pr-calc-rsrv},{&bef-pr-calc-last},{&bef-pr-calc-lastobj},{&bef-pr-calc-old},{&bef-pr-calc-new},{&bef-pr-calc-obj},{&bef-pr-calc-wbill},{&bef-pr-calc-ov},{&bef-pr-calc-wbill-novat},{&bef-pr-calc-cost-novat},{&bef-pr-calc-old-novat},{&bef-pr-common},{&bef-pr-calc-slt},{&bef-pr-calc-slt-wbill},{&bef-pr-calc-undo},{&bef-pr-calc-no},{&bef-pr-calc-fix},{&bef-pr-calc-prod},{&bef-pr-calc-prod-vat},{&bef-pr-calc-level-prod},{&bef-pr-calc-level-prod-vat},{&bef-pr-calc-specif}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define pr-calc-methods-inf-list {&pr-calc-methods-inf-list}" ).
/* Методы  переоценки из интерфейса ДНЦ */
&glob pr-calc-methods-inf-DFP '{&bef-pr-calc-goods},{&bef-pr-calc-cost-gr},{&bef-pr-calc-rsrv-gr},{&bef-pr-calc-last-gr},{&bef-pr-calc-old},{&bef-pr-calc-new},{&bef-pr-calc-obj},{&bef-pr-calc-wbill},{&bef-pr-calc-ov},{&bef-pr-calc-pdf},{&bef-pr-calc-wbill-novat},{&bef-pr-calc-cost-novat-gr},{&bef-pr-calc-old-novat},{&bef-pr-common},{&bef-pr-calc-no},{&bef-pr-calc-undo},{&bef-pr-calc-fix},{&bef-pr-calc-prod},{&bef-pr-calc-prod-vat},{&bef-pr-calc-level-prod},{&bef-pr-calc-level-prod-vat},{&bef-pr-calc-specif}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define pr-calc-methods-inf-DFP {&pr-calc-methods-inf-DFP}" ).


/* действия истории (act) */
{ cmp/cr-prep.i 1 h-delete         у                удаление  d delete}
{ cmp/cr-prep.i 1 h-create         с                создание  c create}
{ cmp/cr-prep.i 1 h-update         и                изменение u update}

&glob h-actions '{&bef-h-delete},{&bef-h-create},{&bef-h-update}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define h-actions {&h-actions}" ).

/* типы документов истории (tbl-name) */
{ cmp/cr-prep.i 1 h-wbill          накладная            " "       waybill}
{ cmp/cr-prep.i 1 h-rvs            сверка               " "       revision}
{ cmp/cr-prep.i 1 h-icnt           инв-сч-трк           " "       inv-cnt-pump}
{ cmp/cr-prep.i 1 h-ov             переоценка           " "       overvalue}
{ cmp/cr-prep.i 1 h-gdsgrp         гр-товаров           " "       goodsgroup}
{ cmp/cr-prep.i 1 h-fbrggrp        гр-блюд              " "       fbrgdsgroup}
{ cmp/cr-prep.i 1 h-cligrp         гр-клиентов          " "       clientsgroup}
{ cmp/cr-prep.i 1 h-autotrans      автопров.            " "       autotrans}
{ cmp/cr-prep.i 1 h-trans          проводки             " "       transaction}
{ cmp/cr-prep.i 1 h-trans-cont     состав_проводки      " "       trans-cont}
{ cmp/cr-prep.i 1 h-trans-grp      группа_проводок      " "       trans-grp}
{ cmp/cr-prep.i 1 h-invoice        инвойсы              " "       invoice}
{ cmp/cr-prep.i 1 h-account        счета                " "       account}
{ cmp/cr-prep.i 1 h-analitic       аналитика            " "       analitic}
{ cmp/cr-prep.i 1 h-balance        баланс               " "       balance}
{ cmp/cr-prep.i 1 h-form           форма                " "       form}
{ cmp/cr-prep.i 1 h-correspondence корреспонденция      " "       correspondence}
{ cmp/cr-prep.i 1 h-recipe         рецепт               " "       recipe}
{ cmp/cr-prep.i 1 h-recipeline     рецепт               " "       recipeline}
{ cmp/cr-prep.i 1 h-mnfc           производство         " "       manufacturing}
{ cmp/cr-prep.i 1 h-sale           продажа              " "       sale}
{ cmp/cr-prep.i 1 h-alt-bc         доп-БК               " "       alt-barcode}
{ cmp/cr-prep.i 1 h-company        фирма                " "       company}
{ cmp/cr-prep.i 1 h-person         человек              " "       person}
{ cmp/cr-prep.i 1 h-shop           магазин              " "       shop}
{ cmp/cr-prep.i 1 h-store          склад                " "       store}
{ cmp/cr-prep.i 1 h-to             ТО                   " "       ТО}
{ cmp/cr-prep.i 1 h-tax-goods      ставки_на_товар      " "       tax-goods}
{ cmp/cr-prep.i 1 h-tax            категория_налога     " "       tax}
{ cmp/cr-prep.i 1 h-tax-gds-grp    налоги_на_группу     " "       tax-gds-grp}
{ cmp/cr-prep.i 1 h-card           д-карта              " "       card}
{ cmp/cr-prep.i 1 h-shop-rate      маг-курс             " "       shop-rate}
{ cmp/cr-prep.i 1 h-property       признак              " "       property}
{ cmp/cr-prep.i 1 h-goods          товар                " "       goods}
{ cmp/cr-prep.i 1 h-pay            оплата               " "       payment}
{ cmp/cr-prep.i 1 h-cash-goods     кас_тов              " "       cashgoods}
{ cmp/cr-prep.i 1 h-unit           ед_изм               " "       unit-name}
{ cmp/cr-prep.i 1 h-amount         суммы                " "       amount}
{ cmp/cr-prep.i 1 h-place          склд.место           " "       place}
{ cmp/cr-prep.i 1 h-pump           ТРК                  " "       pump}
{ cmp/cr-prep.i 1 h-nozzle         пистолет_ТРК         " "       nozzle}
{ cmp/cr-prep.i 1 h-shift          смена                " "       shift}
{ cmp/cr-prep.i 1 h-wealth         МЦ                   " "       wealth}
{ cmp/cr-prep.i 1 h-wth-par        номинал_МЦ           " "       wth-par}
{ cmp/cr-prep.i 1 h-wth-place      место_хран_МЦ        " "       wth-place}
{ cmp/cr-prep.i 1 h-wth-doc        док_перемщ_МЦ        " "       wth-doc}
{ cmp/cr-prep.i 1 h-config         конфигурация         " "       config}
{ cmp/cr-prep.i 1 h-auto-tank      автоцистерны         " "       auto-tank}
{ cmp/cr-prep.i 1 h-auto-tank-meas метки_автоцист       " "       auto-tank-meas}
{ cmp/cr-prep.i 1 h-fbr-prn        принтер_кухни        " "       kitchen_printer}
{ cmp/cr-prep.i 1 h-fbr-prn-grp    группа_тов-принтер_кухни  " "  dish_group-kitchen_printer}

&glob h-tbl-names '{&bef-h-wbill},{&bef-h-ov},{&bef-h-gdsgrp},{&bef-h-fbrggrp},{&bef-h-cligrp},~
{&bef-h-autotrans},{&bef-h-trans},{&bef-h-trans-cont},{&bef-h-trans-grp},{&bef-h-invoice},~
{&bef-h-account},{&bef-h-analitic},{&bef-h-balance},{&bef-h-form},{&bef-h-correspondence},~
{&bef-h-recipe},{&bef-h-recipeline},{&bef-h-mnfc},{&bef-h-sale},{&bef-h-alt-bc},~
{&bef-h-company},{&bef-h-person},{&bef-h-shop},{&bef-h-store},~
{&bef-h-to},{&bef-h-tax-goods},{&bef-h-tax},~
{&bef-h-pump},{&bef-h-nozzle},{&bef-h-place},{&bef-h-card},{&bef-h-shop-rate},~
{&bef-h-property},{&bef-h-goods},{&bef-h-pay},~
{&bef-h-cash-goods},{&bef-h-tax-goods},{&bef-h-unit},{&bef-h-amount},~
{&bef-h-shift},{&bef-h-wealth},{&bef-h-wth-par},{&bef-h-wth-place},~
{&bef-h-wth-doc},{&bef-h-config},{&bef-h-fbr-prn},{&bef-h-fbr-prn-grp}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define h-tbl-names {&h-tbl-names}" ).

/* типы настроек конфигурации */
{ cmp/cr-prep.i 1 cnf-enc          к                " " c}
{ cmp/cr-prep.i 1 cnf-obl          о                " " o}
{ cmp/cr-prep.i 1 cnf-sal          п                " " s}

&glob cnf-type-list ',{&bef-cnf-obl},{&bef-cnf-enc},{&bef-cnf-sal}':U  /* первый параметр обязательно пустой */
run filwrlib_append-new-line in this-procedure ( input "&global-define cnf-type-list {&cnf-type-list}" ).

/* кодированные параметры конфигурации */
&glob cnf-type-list-protect '{&bef-cnf-enc},{&bef-cnf-sal}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cnf-type-list-protect {&cnf-type-list-protect}" ).

/* обязательные параметры конфигурации */
&glob cnf-type-list-mandatory '{&bef-cnf-enc},{&bef-cnf-obl}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cnf-type-list-mandatory {&cnf-type-list-mandatory}" ).

/* неограниченное время действия параметра конфигурации */
&glob beg-unlim-lcns 01/01/1900 /* начало не ограничено */
run filwrlib_append-new-line in this-procedure ( input "&global-define beg-unlim-lcns {&beg-unlim-lcns}" ).
&glob end-unlim-lcns 01/01/9999 /* окончание не ограничено */
run filwrlib_append-new-line in this-procedure ( input "&global-define end-unlim-lcns {&end-unlim-lcns}" ).

/* привязки параметров конфигурации     */
{ cmp/cr-prep.i 1 cnf-no           Нет              " " no     }
{ cmp/cr-prep.i 1 cnf-company      Фирма            " " company}
{ cmp/cr-prep.i 1 cnf-object       Объект           " " object }

/* все типы привязок параметров */
&glob cnf-type-restr '{&bef-cnf-no},{&bef-cnf-company},{&bef-cnf-object}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cnf-type-restr {&cnf-type-restr}" ).

/* типы привязок параметров допустимые для параметров типа cnf-type-list-mandatory */
&glob cnf-type-restr-protect '{&bef-cnf-no}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cnf-type-restr-protect {&cnf-type-restr-protect}" ).

/* Сокращения для НДС в ПН */
{ cmp/cr-prep.i 1 inc-VAT          "в т. ч."        " " include}
{ cmp/cr-prep.i 1 no-VAT           нет              " " exclude}
{ cmp/cr-prep.i 1 without-VAT      "без"            " " without}

/* Сокращения для налога с продаж в ПН*/
&glob inc-SLT         {&inc-VAT}
run filwrlib_append-new-line in this-procedure ( input "&global-define inc-SLT {&inc-SLT}" ).
&glob no-SLT          {&no-VAT}
run filwrlib_append-new-line in this-procedure ( input "&global-define no-SLT {&no-SLT}" ).
&glob without-SLT     {&without-VAT}
run filwrlib_append-new-line in this-procedure ( input "&global-define without-SLT {&without-SLT}" ).

/* дополнительные параметры, которые пересекаются в перечислимых типах с предыдущими */

{ cmp/cr-prep.i 1 acc-office-without бух-без        " "                    acc-without }
{ cmp/cr-prep.i 1 acc-office-all     бух-все        " "                    acc-all     }
{ cmp/cr-prep.i 1 ext-acc-office-all бгх-все        " "                    eac-all     }
{ cmp/cr-prep.i 1 work               работа         " "                    work        }
{ cmp/cr-prep.i 1 c-work             уд_работа      " "                    del_work    }

/* ошибки при приеме чеков */
{ cmp/cr-prep.i 1 gds-err          0                " "                    0       } 
{ cmp/cr-prep.i 1 summa-err        сум-ош           " "                    Sum-Err }
{ cmp/cr-prep.i 1 card-err         карт-ош          " "                    Card-Err}
{ cmp/cr-prep.i 1 serial-err       сер-ош           " "                    Ser-Err }
{ cmp/cr-prep.i 1 dtl-err          при-ош           " "                    Dtl-Err }
{ cmp/cr-prep.i 1 shift-err        смн-ош           " "                    Shft-Err}
{ cmp/cr-prep.i 1 pay-err          опл-ош           " "                    Pay-Err }
{ cmp/cr-prep.i 1 discount-err     скидка-ош        " "                    Dsnt-Err}
{ cmp/cr-prep.i 1 goods-err        тов-ош           " "                    Gds-Err }
{ cmp/cr-prep.i 1 amount-err       кол-ош           " "                    Qnty-Err}
{ cmp/cr-prep.i 1 prt-err          прт-ош           " "                    Prt-Err }
{ cmp/cr-prep.i 1 staff-err        перс-ош           " "                   Staf-Err}

&glob chk-err-list '{&bef-gds-err},{&bef-summa-err},{&bef-serial-err},{&bef-Dtl-Err},{&bef-Pay-Err},{&bef-discount-err},{&bef-goods-err},{&bef-amount-err},{&bef-Prt-Err}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define chk-err-list {&chk-err-list}" ).

/* Типы единиц измерения!!!Первые три буквы в длинном названии должны обязательно совпадать с коротким!!!*/
{ cmp/cr-prep.i 1 pieces           шту              штучный               pie pieces    }
{ cmp/cr-prep.i 1 divisional       дро              дробный               div divisional}
{ cmp/cr-prep.i 1 serial           сер              серийный              ser serial    }
{ cmp/cr-prep.i 1 weight           вес              весовой               wei weight    }
{ cmp/cr-prep.i 1 petrolium        топ              топливо               pet petrolium }
{ cmp/cr-prep.i 1 twounit          2ед              2едизма               2un 2units    }
{ cmp/cr-prep.i 1 altunit          доп              дополнительный        alt altunit   }
{ cmp/cr-prep.i 1 saleparts        прп              прпарт                slp slparts   }
{ cmp/cr-prep.i 1 bottle           сте              стеклопосуда          bot bottle    }
{ cmp/cr-prep.i 2 serial weight petrolium twounit bottle}

&glob unit-type-list '{&bef-pieces},{&bef-divisional},{&bef-serial},{&bef-weight},{&bef-petrolium},{&bef-twounit},{&bef-saleparts},{&bef-altunit},{&bef-bottle}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define unit-type-list {&unit-type-list}" ).
&glob unit-types '{&bef-pieces-full},{&bef-divisional-full},{&bef-serial-full},{&bef-weight-full},{&bef-petrolium-full},{&bef-twounit-full},{&bef-saleparts-full},{&bef-altunit-full},{&bef-bottle-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define unit-types {&unit-types}" ).
&glob unit-type-name entry (lookup (ENTRY(1,~~~~~~~{&unit-type-code}), {&unit-type-list}), {&unit-types})
run filwrlib_append-new-line in this-procedure ( input "&global-define unit-type-name {&unit-type-name}" ).
&glob unit-type-tax-list '{&bef-pieces},{&bef-divisional},{&bef-serial},{&bef-weight},{&bef-petrolium},{&bef-bottle}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define unit-type-tax-list {&unit-type-tax-list}" ).

/* второй дополнительный тип единицы измерения для топлива */
&glob unit-types-toplivo '{&bef-pieces-full},{&bef-divisional-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define unit-types-toplivo {&unit-types-toplivo}" ).
&glob unit-type-name-toplivo if num-entries(~~~~~~~{&unit-type-code}) > 1  then (',':U + entry (lookup (entry(2,~~~~~~~{&unit-type-code}), '{&bef-pieces},{&bef-divisional},{&bef-serial},{&bef-weight},{&bef-petrolium},{&bef-twounit},{&bef-saleparts},{&bef-altunit},{&bef-bottle}':U), {&unit-types})) else '':U
run filwrlib_append-new-line in this-procedure ( input "&global-define unit-type-name-toplivo {&unit-type-name-toplivo}" ).


{ cmp/cr-prep.i 1 percentive       %                процентный            %   percentive}
{ cmp/cr-prep.i 1 absolute         abs              абсолютный            abs absolute}

/* типы налогов */
&glob tax-types '{&bef-percentive-full},{&bef-absolute-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define tax-types {&tax-types}" ).
&glob tax-type-name entry (lookup (~~~~~~~{&tax-type-code}, '{&bef-percentive},{&bef-absolute}':U), {&tax-types})
run filwrlib_append-new-line in this-procedure ( input "&global-define tax-type-name {&tax-type-name}" ).

/* Типы кодов (собственный код товара, лок.вес.код, глоб.вес.код, ...) */
{ cmp/cr-prep.i 1 gbl-bc-code        bcgb             " " bcgb}  /* глобальный собственный код */
{ cmp/cr-prep.i 1 loc-sc-code        sclc             " " sclc}  /* локальный весовой код */
{ cmp/cr-prep.i 1 gbl-sc-code        scgb             " " scgb}  /* глобальный весовой код */
{ cmp/cr-prep.i 1 loc-ss-code        sslc             " " sslc}  /* локальный взвешиваемый код */
{ cmp/cr-prep.i 1 gbl-ss-code        ssgb             " " ssgb}  /* глобальный взвешиваемый код */
{ cmp/cr-prep.i 1 loc-pg-code        pglc             " " pglc}  /* локальный штучный код */
{ cmp/cr-prep.i 1 loc-pt-code        ptlc             " " ptlc}  /* локальный топливный код */
{ cmp/cr-prep.i 1 gbl-dc-code        dcgb             " " dcgb}  /* глобальный код дисконтной карты*/
{ cmp/cr-prep.i 1 gbl-dr-code        drgb             " " drgb}  /* глобальный код правила скидок*/
{ cmp/cr-prep.i 1 gbl-fm-code        fmgb             " " fmgb}  /* глобальный код организации*/
{ cmp/cr-prep.i 1 gbl-pn-code        pngb             " " pngb}  /* глобальный код физического лица*/
{ cmp/cr-prep.i 1 gbl-ct-code        ctgb             " " ctgb}  /* глобальный код договора*/
{ cmp/cr-prep.i 1 gbl-ca-code        cagb             " " cagb}  /* глобальный код точки привязки*/
{ cmp/cr-prep.i 1 gbl-fd-code        fdgb             " " fdgb}  /* глобальный код фин документам*/
{ cmp/cr-prep.i 1 gtin               GTIN             " " GTIN}  /* GTIN */

{ cmp/cr-prep.i 1 mark               mark             " " mark}  /* требует обязательную маркитровку */
 

&glob grp-bcode  '{&bef-loc-ss-code},{&bef-gbl-bc-code},{&bef-loc-sc-code},{&bef-gbl-sc-code},{&bef-gbl-ss-code},{&bef-loc-pg-code},{&bef-loc-pt-code}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define grp-bcode {&grp-bcode}" ).

{ cmp/cr-prep.i 1 gbl----pbc        0                " "  0}  /* Обычный prod-bc */
{ cmp/cr-prep.i 1 loc-sc-pbc        -1               " " -1}  /* локальный весовой код */
{ cmp/cr-prep.i 1 gbl-sc-pbc        1                " "  1}  /* глобальный весовой код */
{ cmp/cr-prep.i 1 loc-pg-pbc        -4               " " -4}  /* локальный штучный код */
{ cmp/cr-prep.i 1 loc-ss-pbc        -2               " " -2}  /* локальный взвешиваемый код */
{ cmp/cr-prep.i 1 gbl-ss-pbc        2                " "  2}  /* глобальный взвешиваемый код */
{ cmp/cr-prep.i 1 loc-pt-pbc        -3               " " -3}  /* локальный топливный код */

&glob pbc-types  '{&bef-gbl----pbc},{&bef-loc-ss-pbc},{&bef-loc-sc-pbc},{&bef-gbl-sc-pbc},{&bef-loc-pg-pbc},{&bef-gbl-ss-pbc},{&bef-loc-pt-pbc}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define pbc-types {&pbc-types}" ).


/* Алгоритм расчета учетных цен */
{ cmp/cr-prep.i 1 fifo             FIFO             " " FIFO}

/* Список префиксов весового товара */
&glob scales-pref '21,23,25':U
run filwrlib_append-new-line in this-procedure ( input "&global-define scales-pref {&scales-pref}" ).

&glob pgscales-pref '24IIIIIQQ000C,28IIIIIQQQ00C':U
run filwrlib_append-new-line in this-procedure ( input "&global-define pgscales-pref {&pgscales-pref}" ).


/* Список типов скидок для складских документов */
{ cmp/cr-prep.i 1 percent          процент          " " percent}
{ cmp/cr-prep.i 1 card             карта            " " card}
{ cmp/cr-prep.i 1 group            группа           " " group}
{ cmp/cr-prep.i 1 amount           сумма            " " amount}
{ cmp/cr-prep.i 1 row              строка           " " row}
{ cmp/cr-prep.i 1 price_list       прайс-лист       " " price_list}

&glob d-type-pc   '{&bef-percent},{&bef-card},{&bef-group}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define d-type-pc {&d-type-pc}" ).
&glob d-type-list '{&bef-percent},{&bef-card},{&bef-group},{&bef-amount},{&bef-row},{&bef-price_list}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define d-type-list {&d-type-list}" ).
&glob INNER-LINES INNER-LINES 6 LIST-ITEMS {&percent}, {&card}, {&group}, {&amount}, {&row}, {&price_list}
run filwrlib_append-new-line in this-procedure ( input "&global-define INNER-LINES {&INNER-LINES}" ).

/*списки*/
/*рас,спи*/                     { cmp/cr-prep.i 2 expense   write-off}
/*при,возврат*/                 { cmp/cr-prep.i 2 income    return}
/*накл,запрос*/                 { cmp/cr-prep.i 2 wayb      inquiry}
/*факт,разрешен*/               { cmp/cr-prep.i 2 fact      permitted}
/*факт,разрешен,накл,прво*/     { cmp/cr-prep.i 2 fact      permitted   wayb          manufactured }
/*касс,карта,группа*/           { cmp/cr-prep.i 2 cash-desk card group}
/*рас,при,возврат,спи*/         { cmp/cr-prep.i 2 expense   income      return        write-off}
/*при,рас,спи*/                 { cmp/cr-prep.i 2 income    expense     write-off}
/*приказ,разрешен,акт*/         { cmp/cr-prep.i 2 order     permitted   act-overvalue}
/*рас,возврат*/                 { cmp/cr-prep.i 2 expense   return}
/*рас,спи,возврат*/             { cmp/cr-prep.i 2 expense   write-off   return}
/*рас,при*/                     { cmp/cr-prep.i 2 expense   income}
/*спи,возврат*/                 { cmp/cr-prep.i 2 write-off return}
/*касс,карта,группа*/           { cmp/cr-prep.i 2 cash-desk card group}
/*процент,сумма,карта,группа*/  { cmp/cr-prep.i 2 percent amount card group}
/*сер,вес*/                     { cmp/cr-prep.i 2 serial weight}
/*т,у,сер-ош,при-ош*/           { cmp/cr-prep.i 2 gds-goods gds-office serial-err dtl-err}
/*т,у,сумма,сер-ош,при-ош*/     { cmp/cr-prep.i 2 gds-goods gds-office amount serial-err dtl-err}
/*т,у,сумма*/                   { cmp/cr-prep.i 2 gds-goods gds-office amount}

/*------------------------расширеные типы товара------------------------------*/
{ cmp/cr-prep.i 1 gds-bottle     bg " " bg " "}
{ cmp/cr-prep.i 1 gds-serial     sg " " sg " "}
{ cmp/cr-prep.i 1 gds-ordin      og " " og " "}
{ cmp/cr-prep.i 1 gds-off-ordin  os " " os " "}
{ cmp/cr-prep.i 1 gds-gold       gg " " gg " "}
{ cmp/cr-prep.i 1 gds-pcptrl     pp " " pp " "}
{ cmp/cr-prep.i 1 gds-lptrl      lp " " lp " "}
{ cmp/cr-prep.i 1 gds-kgptrl     kp " " kp " "}

/* --------------- статусы БД -------------------- */
&glob sttsDB-copy 'copy-DB':U
run filwrlib_append-new-line in this-procedure ( input "&global-define sttsDB-copy {&sttsDB-copy}" ).
&glob sttsDB-f_lock 'full-lock-DB':u
run filwrlib_append-new-line in this-procedure ( input "&global-define sttsDB-f_lock {&sttsDB-f_lock}" ).
&glob sttsDB-cutld 'sttsDB-cutld':u
run filwrlib_append-new-line in this-procedure ( input "&global-define sttsDB-cutld {&sttsDB-cutld}" ).

/* -------- типы резервирования ------------------ */
&glob rsrvtype_doc 'rsrv-doc':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrvtype_doc {&rsrvtype_doc}" ).
&glob rsrvtype_fact 'rsrv-fact':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrvtype_fact {&rsrvtype_fact}" ).
&glob rsrvtype_pri-doc 'rsrv-pri-doc':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrvtype_pri-doc {&rsrvtype_pri-doc}" ).
&glob rsrvtype_pri-fact 'rsrv-pri-fact':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrvtype_pri-fact {&rsrvtype_pri-fact}" ).

/* -------- параметры вызова резервирования ------ */
&glob rsrv-dtl_action_reserv 'reserv':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_action_reserv {&rsrv-dtl_action_reserv}" ).
&glob rsrv-dtl_action_reserv-sozdanie 'reserv-create':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_action_reserv-sozdanie {&rsrv-dtl_action_reserv-sozdanie}" ).
&glob rsrv-dtl_no-message 'no-message':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_no-message {&rsrv-dtl_no-message}" ).
&glob rsrv-dtl_no-msg-create 'no-msg-create':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_no-msg-create {&rsrv-dtl_no-msg-create}" ).
&glob rsrv-dtl_no-msg-no-chk-acta-cr 'no-msg-no-chk-acta-cr':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_no-msg-no-chk-acta-cr {&rsrv-dtl_no-msg-no-chk-acta-cr}" ).
&glob rsrv-dtl_copy-cst 'copy-cst':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_copy-cst {&rsrv-dtl_copy-cst}" ).
&glob rsrv-dtl_cst-code 'cst-code':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_cst-code {&rsrv-dtl_cst-code}" ).
&glob rsrv-dtl_contract-code 'contract-code':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_contract-code {&rsrv-dtl_contract-code}" ).
&glob rsrv-dtl_rsrv-single-part 'rsrv-single-part':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_rsrv-single-part {&rsrv-dtl_rsrv-single-part}" ).
&glob rsrv-dtl_rsrv-in-code 'rsrv-in-code':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_rsrv-in-code {&rsrv-dtl_rsrv-in-code}" ).
&glob rsrv-dtl_rsrv-part-code 'rsrv-part-code':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_rsrv-part-code {&rsrv-dtl_rsrv-part-code}" ).
&glob rsrv-dtl_old-part-code 'old-part-code':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_old-part-code {&rsrv-dtl_old-part-code}" ).
&glob rsrv-dtl_ps 'ps':u
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_ps {&rsrv-dtl_ps}" ).
&glob rsrv-dtl_dop 'dop':u
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_dop {&rsrv-dtl_dop}" ).
&glob rsrv-dtl_cre-part-code 'cre-part-code':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_cre-part-code {&rsrv-dtl_cre-part-code}" ).
&glob rsrv-dtl_mark-db-num 'mark-db-num':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_mark-db-num {&rsrv-dtl_mark-db-num}" ).
&glob rsrv-dtl_mark-code 'mark-code':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_mark-code {&rsrv-dtl_mark-code}" ).
&glob rsrv-dtl_alc-bottling-date 'alc-bottling-date':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_alc-bottling-date {&rsrv-dtl_alc-bottling-date}" ).
&glob rsrv-dtl_alc-ref-ab-path 'alc-ref-ab-path':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_alc-ref-ab-path {&rsrv-dtl_alc-ref-ab-path}" ).
&glob rsrv-dtl_alc-quality-certif-path 'alc-quality-certif-path':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_alc-quality-certif-path {&rsrv-dtl_alc-quality-certif-path}" ).
&glob rsrv-dtl_alc-certif-path 'alc-certif-path':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_alc-certif-path {&rsrv-dtl_alc-certif-path}" ).
&glob rsrv-dtl_alc-imp-type 'alc-imp-type':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_alc-imp-type {&rsrv-dtl_alc-imp-type}" ).
&glob rsrv-dtl_alc-imp-code 'alc-imp-code':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_alc-imp-code {&rsrv-dtl_alc-imp-code}" ).
&glob rsrv-dtl_pl-code 'plcode':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_pl-code {&rsrv-dtl_pl-code}" ).
&glob rsrv-dtl_cli-qnty 'cli-qnty':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_cli-qnty {&rsrv-dtl_cli-qnty}" ).
&glob rsrv-dtl_hold-code-parent 'hold-code-parent':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_hold-code-parent {&rsrv-dtl_hold-code-parent}" ).
&glob rsrv-dtl_part-code-parent 'part-code-parent':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_part-code-parent {&rsrv-dtl_part-code-parent}" ).
&glob rsrv-dtl_negative-check 'negative-check':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_negative-check {&rsrv-dtl_negative-check}" ).
&glob rsrv-dtl_purch-code-list 'purch-code-list':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_purch-code-list {&rsrv-dtl_purch-code-list}" ).
&glob rsrv-dtl_last-date 'last-date':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_last-date {&rsrv-dtl_last-date}" ).
&glob rsrv-dtl_hold-date 'hold-date':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_hold-date {&rsrv-dtl_hold-date}" ).
&glob rsrv-dtl_partlist 'partlist':U
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_partlist {&rsrv-dtl_partlist}" ).
&glob rsrv-dtl_sale-negative-check-on 'sale-negative-check-on':u
run filwrlib_append-new-line in this-procedure ( input "&global-define rsrv-dtl_sale-negative-check-on {&rsrv-dtl_sale-negative-check-on}" ).




/* -------- типы операций с документами в системе новостей ------ */
&glob nwsdochs_action_create 'create':U
run filwrlib_append-new-line in this-procedure ( input "&global-define nwsdochs_action_create {&nwsdochs_action_create}" ).
&glob nwsdochs_action_update 'update':U
run filwrlib_append-new-line in this-procedure ( input "&global-define nwsdochs_action_update {&nwsdochs_action_update}" ).
&glob nwsdochs_action_delete 'delete':U
run filwrlib_append-new-line in this-procedure ( input "&global-define nwsdochs_action_delete {&nwsdochs_action_delete}" ).
&glob nwsdochs_action_update_err 'update_err':U
run filwrlib_append-new-line in this-procedure ( input "&global-define nwsdochs_action_update_err {&nwsdochs_action_update_err}" ).
&glob nwsdochs_action_delete_err 'delete_err':U
run filwrlib_append-new-line in this-procedure ( input "&global-define nwsdochs_action_delete_err {&nwsdochs_action_delete_err}" ).
&glob nwsdochs_action_command-bush 'command-bush':U
run filwrlib_append-new-line in this-procedure ( input "&global-define nwsdochs_action_command-bush {&nwsdochs_action_command-bush}" ).
&glob nwsdochs_action_command-pbush 'command-pbush':U
run filwrlib_append-new-line in this-procedure ( input "&global-define nwsdochs_action_command-pbush {&nwsdochs_action_command-pbush}" ).



/* параметры вызова окна редактирования партий */
&glob parts-l_object-all 'все':U
run filwrlib_append-new-line in this-procedure ( input "&global-define parts-l_object-all {&parts-l_object-all}" ).
&glob parts-l_object-current 'текущий':U
run filwrlib_append-new-line in this-procedure ( input "&global-define parts-l_object-current {&parts-l_object-current}" ).
&glob parts-l_parts-all 'все':U
run filwrlib_append-new-line in this-procedure ( input "&global-define parts-l_parts-all {&parts-l_parts-all}" ).
&glob parts-l_parts-rest 'остатки':U
run filwrlib_append-new-line in this-procedure ( input "&global-define parts-l_parts-rest {&parts-l_parts-rest}" ).
&glob parts-l_parts-free 'свободно':U
run filwrlib_append-new-line in this-procedure ( input "&global-define parts-l_parts-free {&parts-l_parts-free}" ).
&glob parts-l_parts-document 'документ':U
run filwrlib_append-new-line in this-procedure ( input "&global-define parts-l_parts-document {&parts-l_parts-document}" ).
&glob parts-l_parts-no-reserv 'без-резервирования':U
run filwrlib_append-new-line in this-procedure ( input "&global-define parts-l_parts-no-reserv {&parts-l_parts-no-reserv}" ).
&glob parts-l_parts-no-diff-check 'no-diff-check':U
run filwrlib_append-new-line in this-procedure ( input "&global-define parts-l_parts-no-diff-check {&parts-l_parts-no-diff-check}" ).
&glob parts-l_parts-chg-qnty 'chg-qnty':U
run filwrlib_append-new-line in this-procedure ( input "&global-define parts-l_parts-chg-qnty {&parts-l_parts-chg-qnty}" ).
&glob parts-l_call-reference 'справочник':U
run filwrlib_append-new-line in this-procedure ( input "&global-define parts-l_call-reference {&parts-l_call-reference}" ).
&glob parts-l_call-choose 'выбор':U
run filwrlib_append-new-line in this-procedure ( input "&global-define parts-l_call-choose {&parts-l_call-choose}" ).
&glob parts-l_call-document 'документ':U
run filwrlib_append-new-line in this-procedure ( input "&global-define parts-l_call-document {&parts-l_call-document}" ).

/* TDEDT - trn-doc extended doc-type  */
{ cmp/cr-prep.i 1 TDEDT_Pri_Vnesh          ie "приход внешний"                     ie "income external"    }
{ cmp/cr-prep.i 1 TDEDT_Ras_Vnesh          ee "расход внешний"                     ee "expense external"   }
{ cmp/cr-prep.i 1 TDEDT_Ras_Vnesh_VP       ep "возврат пост."                      ep "return to supplier" }
{ cmp/cr-prep.i 1 TDEDT_Ras_Vnesh_Kass     es "касса продажа"                      es "cash sale"          }
{ cmp/cr-prep.i 1 TDEDT_Vozvrat_Vnesh      re "возврат внешний"                    re "return external"    }
{ cmp/cr-prep.i 1 TDEDT_Vozvrat_Vnesh_Kass rs "касса возврат"                      rs "cash return"        }
{ cmp/cr-prep.i 1 TDEDT_Spi_Vnesh          we "списание"                           we "write off"          }
{ cmp/cr-prep.i 1 TDEDT_Inv                vt "инвентаризация"                     vt "inventory"          }
{ cmp/cr-prep.i 1 TDEDT_Peresort           vp "пересортица"                        vp "regrading"          }
{ cmp/cr-prep.i 1 TDEDT_Pri_Perem          iv "приход внутренний"                  iv "income internal"    }
{ cmp/cr-prep.i 1 TDEDT_Ras_Perem          ev "расход внутренний"                  ev "expense internal"   }
{ cmp/cr-prep.i 1 TDEDT_Vozvrat_Perem      rv "возврат внутренний"                 rv "return internal"    }
{ cmp/cr-prep.i 1 TDEDT_Ras_Prvo           em "расход  произв."                    em "expense manuf."     }
{ cmp/cr-prep.i 1 TDEDT_Spi_Prvo           wm "списан. произв."                    wm "write off manuf."   }
{ cmp/cr-prep.i 1 TDEDT_Pri_Prvo           im "приход  произв."                    im "income manuf"       }
{ cmp/cr-prep.i 1 TDEDT_Corr_Acc_Price     ap "коррекция учетных цен"              ap "corr. acc. price"   }
{ cmp/cr-prep.i 1 TDEDT_Corr_Minus_Parts   mp "корректировка отрицательных партий" mp "corr minus parts"   }
{ cmp/cr-prep.i 1 TDEDT_Chg_Purch_Code     pc "смена типа приобретения"            pc "change purch code"  }
{ cmp/cr-prep.i 1 TDEDT_Overturn           ot "переоценка"                         ot "overturn"           }
{ cmp/cr-prep.i 1 TDEDT_Pri_Object         io "приход внутриобъектный"             io "income object"      }
{ cmp/cr-prep.i 1 TDEDT_Ras_Object         eo "расход внутриобъектный"             eo "expense object"     }

&glob TDEDT_Receipt '{&bef-TDEDT_Pri_Vnesh},~
{&bef-TDEDT_Vozvrat_Vnesh},~
{&bef-TDEDT_Pri_Perem},~
{&bef-TDEDT_Vozvrat_Perem},~
{&bef-TDEDT_Pri_Prvo},~
{&bef-TDEDT_Pri_Object}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define TDEDT_Receipt {&TDEDT_Receipt}" ).

&glob TDEDT_Realization '{&bef-TDEDT_Ras_Vnesh},~
{&bef-TDEDT_Ras_Vnesh_VP},~
{&bef-TDEDT_Ras_Vnesh_Kass},~
{&bef-TDEDT_Vozvrat_Vnesh_Kass},~
{&bef-TDEDT_Spi_Vnesh},~
{&bef-TDEDT_Inv},~
{&bef-TDEDT_Peresort},~
{&bef-TDEDT_Corr_Acc_Price},~
{&bef-TDEDT_Corr_Minus_Parts},~
{&bef-TDEDT_Chg_Purch_Code},~
{&bef-TDEDT_Ras_Perem},~
{&bef-TDEDT_Ras_Prvo},~
{&bef-TDEDT_Spi_Prvo},~
{&bef-TDEDT_Ras_Object}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define TDEDT_Realization {&TDEDT_Realization}" ).

&glob TDEDT_incorrect_sign '{&bef-TDEDT_Inv},{&bef-TDEDT_Peresort},{&bef-TDEDT_Vozvrat_Vnesh_Kass}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define TDEDT_incorrect_sign {&TDEDT_incorrect_sign}" ).

&glob TDEDT_List '{&bef-TDEDT_Pri_Vnesh},~
{&bef-TDEDT_Ras_Vnesh},~
{&bef-TDEDT_Ras_Vnesh_VP},~
{&bef-TDEDT_Ras_Vnesh_Kass},~
{&bef-TDEDT_Vozvrat_Vnesh},~
{&bef-TDEDT_Vozvrat_Vnesh_Kass},~
{&bef-TDEDT_Spi_Vnesh},~
{&bef-TDEDT_Inv},~
{&bef-TDEDT_Peresort},~
{&bef-TDEDT_Pri_Perem},~
{&bef-TDEDT_Ras_Perem},~
{&bef-TDEDT_Vozvrat_Perem},~
{&bef-TDEDT_Ras_Prvo},~
{&bef-TDEDT_Spi_Prvo},~
{&bef-TDEDT_Pri_Prvo},~
{&bef-TDEDT_Overturn},~
{&bef-TDEDT_Corr_Acc_Price},~
{&bef-TDEDT_Corr_Minus_Parts},~
{&bef-TDEDT_Chg_Purch_Code},~
{&bef-TDEDT_Pri_Object},~
{&bef-TDEDT_Ras_Object}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define TDEDT_List {&TDEDT_List}" ).

/* типы документов увеличивающих остаток */
&glob TDEDT_in_list '{&bef-TDEDT_Pri_Vnesh},~
{&bef-TDEDT_Vozvrat_Vnesh},~
{&bef-TDEDT_Vozvrat_Vnesh_Kass},~
{&bef-TDEDT_Inv},~
{&bef-TDEDT_Peresort},~
{&bef-TDEDT_Corr_Acc_Price},~
{&bef-TDEDT_Corr_Minus_Parts},~
{&bef-TDEDT_Chg_Purch_Code},~
{&bef-TDEDT_Pri_Perem},~
{&bef-TDEDT_Vozvrat_Perem},~
{&bef-TDEDT_Pri_Prvo},~
{&bef-TDEDT_Pri_Object}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define TDEDT_in_list {&TDEDT_in_list}" ).

/* типы документов уменьшающих остаток */
&glob TDEDT_out_list '{&bef-TDEDT_Ras_Vnesh},~
{&bef-TDEDT_Ras_Vnesh_VP},~
{&bef-TDEDT_Ras_Vnesh_Kass},~
{&bef-TDEDT_Spi_Vnesh},~
{&bef-TDEDT_Ras_Perem},~
{&bef-TDEDT_Ras_Prvo},~
{&bef-TDEDT_Spi_Prvo},~
{&bef-TDEDT_Ras_Object}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define TDEDT_out_list {&TDEDT_out_list}" ).

&glob TDEDT_List-full '{&bef-TDEDT_Pri_Vnesh-full},~
{&bef-TDEDT_Ras_Vnesh-full},~
{&bef-TDEDT_Ras_Vnesh_VP-full},~
{&bef-TDEDT_Ras_Vnesh_Kass-full},~
{&bef-TDEDT_Vozvrat_Vnesh-full},~
{&bef-TDEDT_Vozvrat_Vnesh_Kass-full},~
{&bef-TDEDT_Spi_Vnesh-full},~
{&bef-TDEDT_Inv-full},~
{&bef-TDEDT_Peresort-full},~
{&bef-TDEDT_Pri_Perem-full},~
{&bef-TDEDT_Ras_Perem-full},~
{&bef-TDEDT_Vozvrat_Perem-full},~
{&bef-TDEDT_Ras_Prvo-full},~
{&bef-TDEDT_Spi_Prvo-full},~
{&bef-TDEDT_Pri_Prvo-full},~
{&bef-TDEDT_Overturn-full},~
{&bef-TDEDT_Corr_Acc_Price-full},~
{&bef-TDEDT_Corr_Minus_Parts-full},~
{&bef-TDEDT_Chg_Purch_Code-full},~
{&bef-TDEDT_Pri_Object-full},~
{&bef-TDEDT_Ras_Object-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define TDEDT_List-full {&TDEDT_List-full}" ).

/* Список документов без переоценки */
&glob TDEDT_List-ov '{&bef-TDEDT_Pri_Vnesh},~
{&bef-TDEDT_Ras_Vnesh},~
{&bef-TDEDT_Ras_Vnesh_VP},~
{&bef-TDEDT_Vozvrat_Vnesh},~
{&bef-TDEDT_Spi_Vnesh},~
{&bef-TDEDT_Inv},~
{&bef-TDEDT_Peresort},~
{&bef-TDEDT_Pri_Perem},~
{&bef-TDEDT_Ras_Perem},~
{&bef-TDEDT_Vozvrat_Perem},~
{&bef-TDEDT_Corr_Acc_Price},~
{&bef-TDEDT_Pri_Object},~
{&bef-TDEDT_Ras_Object}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define TDEDT_List-ov {&TDEDT_List-ov}" ).

&glob TDEDT_List-ov-full '{&bef-TDEDT_Pri_Vnesh-full},~
{&bef-TDEDT_Ras_Vnesh-full},~
{&bef-TDEDT_Ras_Vnesh_VP-full},~
{&bef-TDEDT_Vozvrat_Vnesh-full},~
{&bef-TDEDT_Spi_Vnesh-full},~
{&bef-TDEDT_Inv-full},~
{&bef-TDEDT_Peresort-full},~
{&bef-TDEDT_Pri_Perem-full},~
{&bef-TDEDT_Ras_Perem-full},~
{&bef-TDEDT_Vozvrat_Perem-full},~
{&bef-TDEDT_Corr_Acc_Price-full},~
{&bef-TDEDT_Pri_Object-full},~
{&bef-TDEDT_Ras_Object-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define TDEDT_List-ov-full {&TDEDT_List-ov-full}" ).

&glob TDEDT_List-not-ver-reason '{&bef-TDEDT_Ras_Vnesh_Kass},~
{&bef-TDEDT_Ras_Prvo},~
{&bef-TDEDT_Spi_Prvo},~
{&bef-TDEDT_Pri_Prvo},~
{&bef-TDEDT_Overturn},~
{&bef-TDEDT_Vozvrat_Vnesh_Kass},~
{&bef-TDEDT_Corr_Minus_Parts},~
{&bef-TDEDT_Chg_Purch_Code}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define TDEDT_List-not-ver-reason {&TDEDT_List-not-ver-reason}" ).


{ cmp/cr-prep.i 1 TDEICNT_Inv                ip "инв.счт.ТРК"                        ip "pump.cnt.inventory" }
{ cmp/cr-prep.i 1 TDEICNT_Err-meas           em "изм.погр.ТРК"                       em "pump.err.measurement"     }

&glob TDEICNT_List '{&bef-TDEICNT_Inv},~
{&bef-TDEICNT_Err-meas}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define TDEICNT_List {&TDEICNT_List}" ).

&glob TDEICNT_List-full '{&bef-TDEICNT_Inv-full},~
{&bef-TDEICNT_Err-meas-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define TDEICNT_List-full {&TDEICNT_List-full}" ).

/* типы обрабатываемых накладных для авт генерации фин-обязательств */
/* по приходу */
&glob in-fo-tdedt '{&bef-TDEDT_Pri_Vnesh},{&bef-TDEDT_Ras_Vnesh_VP},':U
run filwrlib_append-new-line in this-procedure ( input "&global-define in-fo-tdedt {&in-fo-tdedt}" ).
&glob in-fo-sign '1,-1,':U
run filwrlib_append-new-line in this-procedure ( input "&global-define in-fo-sign {&in-fo-sign}" ).
/* по расходу */
&glob ex-fo-tdedt '{&bef-TDEDT_ras_Vnesh},{&bef-TDEDT_Ras_Vnesh_Kass},{&bef-TDEDT_Vozvrat_Vnesh},{&bef-TDEDT_Vozvrat_Vnesh_Kass},{&bef-TDEDT_Spi_Vnesh},{&bef-TDEDT_Spi_Prvo},{&bef-TDEDT_Chg_Purch_Code},':U
run filwrlib_append-new-line in this-procedure ( input "&global-define ex-fo-tdedt {&ex-fo-tdedt}" ).
&glob ex-fo-sign '1,1,-1,-1,1,1,1,':U
run filwrlib_append-new-line in this-procedure ( input "&global-define ex-fo-sign {&ex-fo-sign}" ).
/*типы обрабатываемой инвентаризации */
&glob inv-fo-tdedt '{&bef-TDEDT_Inv},{&bef-TDEDT_Corr_Acc_Price},{&bef-TDEDT_Corr_Minus_Parts},{&bef-TDEDT_Peresort},':U
run filwrlib_append-new-line in this-procedure ( input "&global-define inv-fo-tdedt {&inv-fo-tdedt}" ).
&glob inv-fo-sign '1,1,1,1,':U
run filwrlib_append-new-line in this-procedure ( input "&global-define inv-fo-sign {&inv-fo-sign}" ).

/* WDEDT - wth-doc extended doc-type  */
{ cmp/cr-prep.i 1 WDEDT_Inc_Ext     ie "приход внешний"                        ie "income external"     }
{ cmp/cr-prep.i 1 WDEDT_Exp_Ext     ee "расход внешний"                        ee "expense external"    }
{ cmp/cr-prep.i 1 WDEDT_Inc_Int     ii "приход внутренний"                     ii "income internal"     }
{ cmp/cr-prep.i 1 WDEDT_Exp_Int     ei "расход внутренний"                     ei "expense internal"    }
{ cmp/cr-prep.i 1 WDEDT_Inc_Obj     ij "приход внутри объекта"                 ij "income into object"  }
{ cmp/cr-prep.i 1 WDEDT_Exp_Obj     ej "расход внутри объекта"                 ej "expense into object" }
{ cmp/cr-prep.i 1 WDEDT_Inc_Obj_Free fj "приход внутриобъектн. в своб. зону"    fj "income into object"  }
{ cmp/cr-prep.i 1 WDEDT_Exp_Obj_Free jj "расход внутриобъектн. из своб. зоны"   jj "expense into object" }
{ cmp/cr-prep.i 1 WDEDT_Inc_Obj_Put  pj "приход внутриобъектн. в зону погаш."   pj "income into object"  }
{ cmp/cr-prep.i 1 WDEDT_Exp_Obj_Put  oj "расход внутриобъектн. из зоны погаш."  oj "expense into object" }
{ cmp/cr-prep.i 1 WDEDT_Wrt_Off     we "списание"                              we "write off"           }
{ cmp/cr-prep.i 1 WDEDT_Cas_Inc     ci "приход внешний через кассы"            ci "cass income"         }
{ cmp/cr-prep.i 1 WDEDT_Cas_Exp     ce "возврат покупателю через кассы"        ce "cass expense"        }
{ cmp/cr-prep.i 1 WDEDT_Inv         iy "инвентаризация"                        iy "inventory"           }
{ cmp/cr-prep.i 1 WDEDT_Dec         de "декларация"                            de "declaration"         }
{ cmp/cr-prep.i 1 WDEDT_Ret_Int     rj "возврат внутренний"                    rj "return internal"     }
{ cmp/cr-prep.i 1 WDEDT_Inc_Int_Put ip "приход внутр. в зону погашения"        ip "put-zone income internal"     }
{ cmp/cr-prep.i 1 WDEDT_Exp_Int_Put ep "расход внутр. из зоны погашения"       ep "put-zone expense internal"    }
{ cmp/cr-prep.i 1 WDEDT_Ret_Int_Put rp "возврат внутр. в зону погашения"       rp "put-zone return internal"     }
{ cmp/cr-prep.i 1 WDEDT_Inc_Int_Free ff "приход внутр. в своб. зону"           ff "free-zone income internal"     }
{ cmp/cr-prep.i 1 WDEDT_Exp_Int_Free ef "расход внутр. из своб. зоны"          ef "free-zone expense internal"    }
{ cmp/cr-prep.i 1 WDEDT_Ret_Int_Free rf "возврат внутр. в своб зону"           rf "free-zone return internal"     }
{ cmp/cr-prep.i 1 WDEDT_Put_Cash    pc "погашение через кассу"                 pc "put by cash"     }
{ cmp/cr-prep.i 1 WDEDT_Put_Sale    ps "погашение за реализованное топливо"    ps "put realized"    }
{ cmp/cr-prep.i 1 WDEDT_Put_Cli     pz "возврат от покупателя"                 pz "put unrealized"  }
{ cmp/cr-prep.i 1 WDEDT_Dst_free    df "уничтожение в свободной зоне"          df "destruction unrealized"     }
{ cmp/cr-prep.i 1 WDEDT_Dst_Put     dp "уничтожение в зоне погашения"          dp "destruction put-zone"     }
{ cmp/cr-prep.i 1 WDEDT_Dst_Cli     dc "уничтожение в зоне клиента"            dc "destruction"  }
{ cmp/cr-prep.i 1 WDEDT_exch        xc "обмен"                                 xc "exchange"     }

&glob WDEDT_List '{&bef-WDEDT_Inc_Ext},~
{&bef-WDEDT_Exp_Ext},~
{&bef-WDEDT_Inc_Int},~
{&bef-WDEDT_Exp_Int},~
{&bef-WDEDT_Inc_Obj},~
{&bef-WDEDT_Exp_Obj},~
{&bef-WDEDT_Inc_Obj_Free},~
{&bef-WDEDT_Exp_Obj_Free},~
{&bef-WDEDT_Inc_Obj_Put},~
{&bef-WDEDT_Exp_Obj_Put},~
{&bef-WDEDT_Wrt_Off},~
{&bef-WDEDT_Cas_Inc},~
{&bef-WDEDT_Cas_Exp},~
{&bef-WDEDT_Inv},~
{&bef-WDEDT_Ret_Int},~
{&bef-WDEDT_Inc_Int_Put},~
{&bef-WDEDT_Exp_Int_Put},~
{&bef-WDEDT_Ret_Int_Put},~
{&bef-WDEDT_Inc_Int_Free},~
{&bef-WDEDT_Exp_Int_Free},~
{&bef-WDEDT_Ret_Int_Free},~
{&bef-WDEDT_Put_Cash},~
{&bef-WDEDT_Put_Sale},~
{&bef-WDEDT_Put_Cli},~
{&bef-WDEDT_Dst_Free},~
{&bef-WDEDT_Dst_Put},~
{&bef-WDEDT_Dst_Cli},~
{&bef-WDEDT_Dec},~
{&bef-WDEDT_exch}':u

run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_List {&WDEDT_List}" ).
/*Внутриобъектные*/
&glob WDEDT_Obj '{&bef-WDEDT_Inc_Obj},~
{&bef-WDEDT_Inc_Obj_put},~
{&bef-WDEDT_Inc_Obj_Free},~
{&bef-WDEDT_Exp_Obj_Free},~
{&bef-WDEDT_Exp_Obj_Put},~
{&bef-WDEDT_Exp_Obj}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_Obj {&WDEDT_Obj}" ).


&glob WDEDT_List-full '{&bef-WDEDT_Inc_Ext-full},~
{&bef-WDEDT_Exp_Ext-full},~
{&bef-WDEDT_Inc_Int-full},~
{&bef-WDEDT_Exp_Int-full},~
{&bef-WDEDT_Inc_Obj-full},~
{&bef-WDEDT_Exp_Obj-full},~
{&bef-WDEDT_Inc_Obj_Free-full},~
{&bef-WDEDT_Exp_Obj_Free-full},~
{&bef-WDEDT_Inc_Obj_Put-full},~
{&bef-WDEDT_Exp_Obj_Put-full},~
{&bef-WDEDT_Wrt_Off-full},~
{&bef-WDEDT_Cas_Inc-full},~
{&bef-WDEDT_Cas_Exp-full},~
{&bef-WDEDT_Inv-full},~
{&bef-WDEDT_Ret_Int-full},~
{&bef-WDEDT_Inc_Int_Put-full},~
{&bef-WDEDT_Exp_Int_Put-full},~
{&bef-WDEDT_Ret_Int_Put-full},~
{&bef-WDEDT_Inc_Int_Free-full},~
{&bef-WDEDT_Exp_Int_Free-full},~
{&bef-WDEDT_Ret_Int_Free-full},~
{&bef-WDEDT_Put_Cash-full},~
{&bef-WDEDT_Put_Sale-full},~
{&bef-WDEDT_Put_Cli-full},~
{&bef-WDEDT_Dst_Free-full},~
{&bef-WDEDT_Dst_Put-full},~
{&bef-WDEDT_Dst_Cli-full},~
{&bef-WDEDT_Dec-full},~
{&bef-WDEDT_exch-full}':u
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_List-full {&WDEDT_List-full}" ).
 /*приход*/
&glob WDEDT_List-Income '{&bef-WDEDT_Inc_Ext},~
{&bef-WDEDT_Inc_Int},~
{&bef-WDEDT_Inc_Obj},~
{&bef-WDEDT_Inc_Obj_Free},~
{&bef-WDEDT_Inc_Obj_Put},~
{&bef-WDEDT_Inc_Int_Put},~
{&bef-WDEDT_Inc_Int_Free},~
{&bef-WDEDT_Put_Cash},~
{&bef-WDEDT_Put_Sale},~
{&bef-WDEDT_Put_Cli},~
{&bef-WDEDT_Cas_Inc}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_List-Income {&WDEDT_List-Income}" ).
 /*возврат*/
&glob WDEDT_List-return '{&bef-WDEDT_Ret_Int},~
{&bef-WDEDT_Ret_Int_Free},~
{&bef-WDEDT_Ret_Int_Put}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_List-Return {&WDEDT_List-Return}" ).
 /*списание*/
&glob WDEDT_List-Write-Off '{&bef-WDEDT_Wrt_Off},~
{&bef-WDEDT_Dst_Cli},~
{&bef-WDEDT_Dst_Put},~
{&bef-WDEDT_Dst_Free}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_List-Write-Off {&WDEDT_List-Write-Off}" ).

 /*расход*/
&glob WDEDT_List-expense '{&bef-WDEDT_Exp_Ext},~
{&bef-WDEDT_Exp_Int},~
{&bef-WDEDT_Exp_Obj},~
{&bef-WDEDT_Exp_Obj_free},~
{&bef-WDEDT_Exp_Obj_Put},~
{&bef-WDEDT_Cas_Exp},~
{&bef-WDEDT_Exp_Int_Free},~
{&bef-WDEDT_Exp_Int_Put}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_List-expense {&WDEDT_List-expense}" ).
 /*погашение*/
&glob WDEDT_List-Put '{&bef-WDEDT_Put_Cash},~
{&bef-WDEDT_Put_Cli},~
{&bef-WDEDT_Put_Sale}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_List-Put {&WDEDT_List-Put}" ).

  /*внутренние*/
&glob WDEDT_List-internal '{&bef-WDEDT_Exp_Int},~
{&bef-WDEDT_Inc_Int},~
{&bef-WDEDT_Cas_Inc},~
{&bef-WDEDT_Cas_Exp},~
{&bef-WDEDT_Dec},~
{&bef-WDEDT_Inc_Int_Put},~
{&bef-WDEDT_Exp_Int_Put},~
{&bef-WDEDT_Ret_Int_Put},~
{&bef-WDEDT_Inc_Int_Free},~
{&bef-WDEDT_Exp_Int_Free},~
{&bef-WDEDT_Ret_Int_Free}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_List-Internal {&WDEDT_List-internal}" ).
/*Внешние */
&glob WDEDT_List-external '{&bef-WDEDT_Inc_Ext},~
{&bef-WDEDT_Exp_Ext},~
{&bef-WDEDT_Wrt_Off},~
{&bef-WDEDT_Put_Cash},~
{&bef-WDEDT_Put_Sale},~
{&bef-WDEDT_Inv},~
{&bef-WDEDT_Put_Cli},~
{&bef-WDEDT_Dst_Free},~
{&bef-WDEDT_Dst_Put},~
{&bef-WDEDT_Dst_Cli},~
{&bef-WDEDT_exch}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_List-External {&WDEDT_List-external}" ).

&glob WDEDT_List-Incass '{&bef-WDEDT_Exp_Ext},~
{&bef-WDEDT_Exp_Int},~
{&bef-WDEDT_Exp_Obj},~
{&bef-WDEDT_Wrt_Off},~
{&bef-WDEDT_Cas_Exp},~
{&bef-WDEDT_Exp_Int_Put},~
{&bef-WDEDT_Exp_Int_Free}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_List-Incass {&WDEDT_List-Incass}" ).

 /*список расш. типов, работающих только с серийными МЦ*/
&glob WDEDT_List-Ser '{&bef-WDEDT_Inc_Int},~
{&bef-WDEDT_Inc_Obj_Free},~
{&bef-WDEDT_Exp_Obj_Free},~
{&bef-WDEDT_Inc_Obj_Put},~
{&bef-WDEDT_Exp_Obj_Put},~
{&bef-WDEDT_Inc_Int_Put},~
{&bef-WDEDT_Exp_Int_Put},~
{&bef-WDEDT_Ret_Int_Put},~
{&bef-WDEDT_Inc_Int_Free},~
{&bef-WDEDT_Exp_Int_Free},~
{&bef-WDEDT_Ret_Int_Free},~
{&bef-WDEDT_Put_Cash},~
{&bef-WDEDT_Put_Sale},~
{&bef-WDEDT_Put_Cli},~
{&bef-WDEDT_Dst_Free},~
{&bef-WDEDT_Dst_Put},~
{&bef-WDEDT_Dst_Cli},~
{&bef-WDEDT_exch}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_List-Ser {&WDEDT_List-Ser}" ).
 /*список расш. типов, расботающих только с НЕсерийными МЦ*/
&glob WDEDT_List-UnSer '{&bef-WDEDT_Inc_Obj},~
{&bef-WDEDT_Exp_Int},~
{&bef-WDEDT_Ret_Int},~
{&bef-WDEDT_Exp_Obj},~
{&bef-WDEDT_Wrt_Off},~
{&bef-WDEDT_Cas_Inc},~
{&bef-WDEDT_Cas_Exp},~
{&bef-WDEDT_Inv},~
{&bef-WDEDT_Dec}':u
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_List-UnSer {&WDEDT_List-UnSer}" ).
 /*список расшир. типов, для которых не производится резервирования из к.л. зоны, а просто порождаются партии*/
&glob WDEDT_Not-Rezerv '{&bef-WDEDT_Inc_Ext},~
{&bef-WDEDT_Inc_Int_Put},~
{&bef-WDEDT_Ret_Int_Put},~
{&bef-WDEDT_Inc_Obj_Free},~
{&bef-WDEDT_Inc_Obj_Put},~
{&bef-WDEDT_Inc_Int_Free},~
{&bef-WDEDT_Ret_Int_Free}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_Not-Rezerv {&WDEDT_Not-Rezerv}" ).
 /*список расшир. типов, для которых создаются связанные документа*/
&glob WDEDT_OutDoc '{&bef-WDEDT_Exp_Int_Put},~
{&bef-WDEDT_Inc_Int_Put},~
{&bef-WDEDT_Inc_Int_Free},~
{&bef-WDEDT_Inc_Obj_Free},~
{&bef-WDEDT_Inc_Int},~
{&bef-WDEDT_Exp_Int},~
{&bef-WDEDT_Inc_Obj_Put},~
{&bef-WDEDT_Exp_Int_Free}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_OutDoc {&WDEDT_OutDoc}" ).

 /* список расшир. типов, которые ходят по новосятм в УБД, только если включен спец.параметр */
&glob WDEDT_NwsDoc '{&bef-WDEDT_Exp_Int_Put},~
{&bef-WDEDT_Inc_Int_Put},~
{&bef-WDEDT_Inc_Obj_Put},~
{&bef-WDEDT_Ret_Int_Put},~
{&bef-WDEDT_Dst_Put},~
{&bef-WDEDT_Exp_Obj_Put}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_NwsDoc {&WDEDT_NwsDoc}" ).

/*список расширенных типов документов по чекам МЦ*/
&glob WDEDT_rcpt-wth '~
{&bef-WDEDT_Exp_OBJ}~
,{&bef-WDEDT_EXP_EXT}~
,{&bef-WDEDT_INC_OBJ}~
,{&bef-WDEDT_INV}~
,{&bef-WDEDT_DEC}~
':U
 run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_rcpt-wth {&WDEDT_rcpt-wth}" ).


/*список расширенных типов документов по чекам товарным - выручка*/
&glob WDEDT_rcpt-gds '~
{&bef-WDEDT_Cas_Inc}~
,{&bef-WDEDT_Cas_Exp}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_rcpt-gds {&WDEDT_rcpt-gds}" ).



 /*  Список зон партий МЦ  */
&glob WDEDT_List-Zone '{&bef-free-code},~
{&bef-output-code},~
{&bef-cli-zone},~
{&bef-forged},~
{&bef-put-zone}':u
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_List-Zone {&WDEDT_List-Zone}" ).

 /*Список зон (in - кторые складываются, out-вычитаются) для расчета остатков по зоне*/
&glob WDEDT_SUM_Free-In '{&bef-WDEDT_Inc_Ext},~
{&bef-WDEDT_Inc_Int_Free},~
{&bef-WDEDT_Ret_Int_Free}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_SUM_Free-In {&WDEDT_SUM_Free-In}" ).

&glob WDEDT_SUM_Free-Out '{&bef-WDEDT_Exp_Ext},~
{&bef-WDEDT_Exp_Int_Free},~
{&bef-WDEDT_Dst_free}':u
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_SUM_Free-Out {&WDEDT_SUM_Free-Out}" ).

&glob WDEDT_SUM_Put-In '{&bef-WDEDT_Inc_Int_Put},~
{&bef-WDEDT_Put_Cash},~
{&bef-WDEDT_Put_Sale},~
{&bef-WDEDT_Put_Cli},~
{&bef-WDEDT_Ret_Int_Put}':u
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_SUM_Put-In {&WDEDT_SUM_Put-In}" ).

&glob WDEDT_SUM_Put-Out '{&bef-WDEDT_Exp_Int_Put},~
{&bef-WDEDT_Dst_Put}':u
run filwrlib_append-new-line in this-procedure ( input "&global-define WDEDT_SUM_Put-Out {&WDEDT_SUM_Put-Out}" ).


{ cmp/cr-prep.i 1 declaration        декл                " " decl }
{ cmp/cr-prep.i 1 exchange           обмен               " " exchange }


/* типы source-type для payment */
{ cmp/cr-prep.i 1 pmnt-cash-desk     касс                " " POS }
{ cmp/cr-prep.i 1 pmnt-ord-doc       заказ               " " order }
{ cmp/cr-prep.i 1 pmnt-trn-doc       накл                " " waybill }
{ cmp/cr-prep.i 1 pmnt-fin-doc       платеж              " " bill }


/*типы source-type для wth-doc */
{ cmp/cr-prep.i 1 wthd-cash-desk     касса               " " POS}
{ cmp/cr-prep.i 1 wthd-wth-doc       док.МЦ              " " wealthdoc}

/* константы для архивов */
&glob arh-delta 0.0000000001
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-delta {&arh-delta}" ).
&glob min-shift-num 1
run filwrlib_append-new-line in this-procedure ( input "&global-define min-shift-num {&min-shift-num}" ).
&glob max-shift-num 24
run filwrlib_append-new-line in this-procedure ( input "&global-define max-shift-num {&max-shift-num}" ).

/* константы для вызова внешних программ */
&glob extprog_exec 'exec':U
run filwrlib_append-new-line in this-procedure ( input "&global-define extprog_exec {&extprog_exec}" ).
&glob extprog_check 'check':U
run filwrlib_append-new-line in this-procedure ( input "&global-define extprog_check {&extprog_check}" ).
&glob extprog_setup 'setup':U
run filwrlib_append-new-line in this-procedure ( input "&global-define extprog_setup {&extprog_setup}" ).
&glob extprog_rptview 'rptview':U
run filwrlib_append-new-line in this-procedure ( input "&global-define extprog_rptview {&extprog_rptview}" ).
&glob extprog_altprn 'altprn':U
run filwrlib_append-new-line in this-procedure ( input "&global-define extprog_altprn {&extprog_altprn}" ).
&glob extprog_txt2pdf 'txt2pdf':U
run filwrlib_append-new-line in this-procedure ( input "&global-define extprog_txt2pdf {&extprog_txt2pdf}" ).

&glob arh-sale 'sale':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-sale {&arh-sale}" ).
&glob arh-crsa 'crsa':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-crsa {&arh-crsa}" ).
&glob arh-cost 'cost':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-cost {&arh-cost}" ).
&glob arh-sadt 'sadt':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-sadt {&arh-sadt}" ).
&glob arh-cgdt 'cgdt':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-cgdt {&arh-cgdt}" ).
&glob arh-csdt 'csdt':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-csdt {&arh-csdt}" ).
&glob arh-sale-service 'sasr':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-sale-service {&arh-sale-service}" ).
&glob arh-crsa-service 'cgsr':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-crsa-service {&arh-crsa-service}" ).
&glob arh-cost-service 'cssr':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-cost-service {&arh-cost-service}" ).
&glob arh-sadt-service 'adsr':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-sadt-service {&arh-sadt-service}" ).
&glob arh-cgdt-service 'gdsr':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-cgdt-service {&arh-cgdt-service}" ).
&glob arh-csdt-service 'sdsr':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-csdt-service {&arh-csdt-service}" ).
&glob aht-repayment 'r':U
run filwrlib_append-new-line in this-procedure ( input "&global-define aht-repayment {&aht-repayment}" ).
&glob aht-cons_acc 'c':U
run filwrlib_append-new-line in this-procedure ( input "&global-define aht-cons_acc {&aht-cons_acc}" ).
&glob aht-cons_benf 'b':U
run filwrlib_append-new-line in this-procedure ( input "&global-define aht-cons_benf {&aht-cons_benf}" ).
&glob aht-resp_stor 's':U
run filwrlib_append-new-line in this-procedure ( input "&global-define aht-resp_stor {&aht-resp_stor}" ).
&glob aht-service 'v':U
run filwrlib_append-new-line in this-procedure ( input "&global-define aht-service {&aht-service}" ).
&glob aht-old_cons 'o':U
run filwrlib_append-new-line in this-procedure ( input "&global-define aht-old_cons {&aht-old_cons}" ).
&glob aht-stk-normal 'n':U
run filwrlib_append-new-line in this-procedure ( input "&global-define aht-stk-normal {&aht-stk-normal}" ).
&glob arh-VAT 'v':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-VAT {&arh-VAT}" ).
&glob arh-SLT 's':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-SLT {&arh-SLT}" ).
&glob arh-VATSLT 'x':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-VATSLT {&arh-VATSLT}" ).
&glob arh-supp 'p':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-supp {&arh-supp}" ).
&glob arh-repayment 'prch':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-repayment {&arh-repayment}" ).
&glob arh-cons_acc 'cacc':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-cons_acc {&arh-cons_acc}" ).
&glob arh-cons_benf 'benf':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-cons_benf {&arh-cons_benf}" ).
&glob arh-resp_stor 'stor':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-resp_stor {&arh-resp_stor}" ).
&glob arh-old_cons 'cons':U
run filwrlib_append-new-line in this-procedure ( input "&global-define arh-old_cons {&arh-old_cons}" ).
&glob single-cat-id '##':U
run filwrlib_append-new-line in this-procedure ( input "&global-define single-cat-id {&single-cat-id}" ).
&glob root-cat-id '##,##':U
run filwrlib_append-new-line in this-procedure ( input "&global-define root-cat-id {&root-cat-id}" ).

/* константы для блокировки ресурсов */
&glob lock-prc-calc-arh 'btpr':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-calc-arh {&lock-prc-calc-arh}" ).
&glob lock-prc-calc-aht 'ahtb':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-calc-aht {&lock-prc-calc-aht}" ).
&glob lock-prc-calc-supp-arh 'ahsp':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-calc-supp-arh {&lock-prc-calc-supp-arh}" ).
&glob lock-prc-restore-arh 'rsar':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-restore-arh {&lock-prc-restore-arh}" ).
&glob lock-prc-stop-arh-restore 'rsrs':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-stop-arh-restore {&lock-prc-stop-arh-restore}" ).
&glob lock-prc-stop-arh-news 'rsrn':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-stop-arh-news {&lock-prc-stop-arh-news}" ).
&glob lock-prc-restore-ahsp 'rsas':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-restore-ahsp {&lock-prc-restore-ahsp}" ).
&glob lock-prc-stop-ahsp-restore 'rsss':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-stop-ahsp-restore {&lock-prc-stop-ahsp-restore}" ).
&glob lock-prc-stop-ahsp-news 'rssn':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-stop-ahsp-news {&lock-prc-stop-ahsp-news}" ).
&glob lock-prc-restore-aht 'rsat':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-restore-aht {&lock-prc-restore-aht}" ).
&glob lock-prc-stop-aht-restore 'rsts':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-stop-aht-restore {&lock-prc-stop-aht-restore}" ).
&glob lock-prc-stop-aht-news 'rstn':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-stop-aht-news {&lock-prc-stop-aht-news}" ).
&glob lock-prc-calc-prc 'ahpr':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-calc-prc {&lock-prc-calc-prc}" ).
&glob lock-prc-calc-hold 'hold':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-calc-hold {&lock-prc-calc-hold}" ).
&glob lock-prc-calc-hinv 'hinv':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-calc-hinv {&lock-prc-calc-hinv}" ).
&glob lock-prc-calc-hspi 'hspi':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-calc-hspi {&lock-prc-calc-hspi}" ).
&glob lock-prc-get-chk 'gchk':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-get-chk {&lock-prc-get-chk}" ).
&glob lock-prc-put-dis-card 'pcd2':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-put-dis-card {&lock-prc-put-dis-card}" ).
&glob lock-prc-auto-wth-doc 'awth':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-auto-wth-doc {&lock-prc-auto-wth-doc}" ).
&glob lock-prc-put-ncr-gm 'pncr':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-put-ncr-gm {&lock-prc-put-ncr-gm}" ).
&glob lock-prc-loc-sc-code 'lscc':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-loc-sc-code {&lock-prc-loc-sc-code}" ).
&glob lock-prc-btpr-gds 'gds':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-btpr-gds {&lock-prc-btpr-gds}" ).
&glob lock-prc-btpr-dcard 'dcrd':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-btpr-dcard {&lock-prc-btpr-dcard}" ).
&glob lock-prc-btpr-goa 'goa':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-btpr-goa {&lock-prc-btpr-goa}" ).
&glob lock-prc-btpr-cashier 'cshr':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-btpr-cashier {&lock-prc-btpr-cashier}" ).
&glob lock-prc-btpr-seller 'slr':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-btpr-seller {&lock-prc-btpr-seller}" ).
&glob lock-prc-btpr-move-object 'mvob':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-btpr-move-object {&lock-prc-btpr-move-object}" ).
&glob lock-prc-goods-rename-artic 'grar':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-goods-rename-artic {&lock-prc-goods-rename-artic}" ).
&glob lock-prc-goods-rename-gds-code 'grgc':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-goods-rename-gds-code {&lock-prc-goods-rename-gds-code}" ).
&glob lock-prc-gds-obj-create 'gdoc':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-gds-obj-create {&lock-prc-gds-obj-create}" ).
&glob lock-prc-cre-pck 'cpck':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-cre-pck {&lock-prc-cre-pck}" ).
&glob lock-prc-cre-olbkp 'obkp':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-cre-olbkp {&lock-prc-cre-olbkp}" ).
&glob lock-prc-inc-sale 'inkr':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-inc-sale {&lock-prc-inc-sale}" ).
&glob lock-prc-rtexch 'rtex':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-rtexch {&lock-prc-rtexch}" ).
&glob lock-prc-mtexch 'mtex':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-mtexch {&lock-prc-mtexch}" ).
&glob lock-prc-schd-free 'schd':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-schd-free {&lock-prc-schd-free}" ).
&glob lock-prc-create-user 'crus':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-create-user {&lock-prc-create-user}" ).

&glob lock-prc-subtype-enable 'enable':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-subtype-enable {&lock-prc-subtype-enable}" ).
&glob lock-prc-subtype-disable 'disable':U
run filwrlib_append-new-line in this-procedure ( input "&global-define lock-prc-subtype-disable {&lock-prc-subtype-disable}" ).

&glob archive-history-calc-start 'calc-start':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-calc-start {&archive-history-calc-start}" ).
&glob archive-history-calc-stop 'calc-stop':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-calc-stop {&archive-history-calc-stop}" ).
&glob archive-history-check-start 'check-start':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-check-start {&archive-history-check-start}" ).
&glob archive-history-check-stop 'check-stop':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-check-stop {&archive-history-check-stop}" ).
&glob archive-history-set-calc 'set-calc':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-set-calc {&archive-history-set-calc}" ).
&glob archive-history-set-del 'set-del':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-set-del {&archive-history-set-del}" ).
&glob archive-history-set-recalc 'set-recalc':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-set-recalc {&archive-history-set-recalc}" ).
&glob archive-history-set-disable 'set-disable':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-set-disable {&archive-history-set-disable}" ).
&glob archive-history-clear-disable 'clear-disable':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-clear-disable {&archive-history-clear-disable}" ).
&glob archive-history-init-start 'init-start':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-init-start {&archive-history-init-start}" ).
&glob archive-history-init-stop 'init-stop':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-init-stop {&archive-history-init-stop}" ).
&glob archive-history-delall-start 'delall-start':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-delall-start {&archive-history-delall-start}" ).
&glob archive-history-delall-stop 'delall-stop':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-delall-stop {&archive-history-delall-stop}" ).
&glob archive-history-deldet-start 'deldet-start':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-deldet-start {&archive-history-deldet-start}" ).
&glob archive-history-deldet-stop 'deldet-stop':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-deldet-stop {&archive-history-deldet-stop}" ).
&glob archive-history-rstfil-start 'rstfil-start':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-rstfil-start {&archive-history-rstfil-start}" ).
&glob archive-history-rstfil-stop 'rstfil-stop':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-rstfil-stop {&archive-history-rstfil-stop}" ).
&glob archive-history-rstdoc-start 'rstdoc-start':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-rstdoc-start {&archive-history-rstdoc-start}" ).
&glob archive-history-rstdoc-stop 'rstdoc-stop':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-rstdoc-stop {&archive-history-rstdoc-stop}" ).
&glob archive-history-ren-gds-code 'ren-gds-code':U
run filwrlib_append-new-line in this-procedure ( input "&global-define archive-history-ren-gds-code {&archive-history-ren-gds-code}" ).

&glob user-window-maximize    'wndmax':U
run filwrlib_append-new-line in this-procedure ( input "&global-define user-window-maximize {&user-window-maximize}" ).
&glob user-window-size-store  'wndstore':U
run filwrlib_append-new-line in this-procedure ( input "&global-define user-window-size-store {&user-window-size-store}" ).

/* новые переменные необходимо добавлять перед данной строчкой */

define variable v-num-lines          as integer   no-undo .
define variable v-str-glbl2-revision as character no-undo .
define variable v-str-glbl3-revision as character no-undo .
define variable v-str-glbl4-revision as character no-undo .
define variable v-str-glbl5-revision as character no-undo .
define variable v-str-glblt-revision as character no-undo .

/* вызов части 2 */
run cmp/str-glb2.p
  (input  v-file-name
  ,output v-num-lines
  ,output v-str-glbl2-revision
  ) "{&language}"
  .
run filwrlib_num-lines-add in this-procedure
  (input v-num-lines
  ) .
/* конец вызова части 2 */

/* вызов части 3 */
run cmp/str-glb3.p
  (input  v-file-name
  ,output v-num-lines
  ,output v-str-glbl3-revision
  ) "{&language}"
  .
run filwrlib_num-lines-add in this-procedure
  (input v-num-lines
  ) .
/* конец вызова части 3 */

/* вызов части 4 */
run cmp/str-glb4.p
  (input  v-file-name
  ,output v-num-lines
  ,output v-str-glbl4-revision
  ) "{&language}"
  .
run filwrlib_num-lines-add in this-procedure
  (input v-num-lines
  ) .
/* конец вызова части 4 */

/* вызов части 5 */
run cmp/str-glb5.p
  (input  v-file-name
  ,output v-num-lines
  ,output v-str-glbl5-revision
  ) "{&language}"
  .
run filwrlib_num-lines-add in this-procedure
  (input v-num-lines
  ) .
/* конец вызова части 5 */

/* вызов части t */
run cmp/str-glbt.p
  (input  v-file-name
  ,output v-num-lines
  ,output v-str-glblt-revision
  ) "{&language}"
  .
run filwrlib_num-lines-add in this-procedure
  (input v-num-lines
  ) .
/* конец вызова части t */



run filwrlib_append-new-line in this-procedure (input "&global-define str-glbl_vss-revision '"  + trim(vss-revision, "$") + "':U" ) .
run filwrlib_append-new-line in this-procedure (input "&global-define str-glbl2_vss-revision '" + trim(v-str-glbl2-revision, "$") + "':U" ) .
run filwrlib_append-new-line in this-procedure (input "&global-define str-glbl3_vss-revision '" + trim(v-str-glbl3-revision, "$") + "':U" ) .
run filwrlib_append-new-line in this-procedure (input "&global-define str-glbl4_vss-revision '" + trim(v-str-glbl4-revision, "$") + "':U" ) .
run filwrlib_append-new-line in this-procedure (input "&global-define str-glbl5_vss-revision '" + trim(v-str-glbl5-revision, "$") + "':U" ) .
run filwrlib_append-new-line in this-procedure (input "&global-define str-glblt_vss-revision '" + trim(v-str-glblt-revision, "$") + "':U" ) .

run filwrlib_append-new-line in this-procedure
  (input "&endif"
  ) .

os-delete value(p-dir-name + '/str-glbl.i') .

os-create-dir value(p-dir-name) .
os-rename value(v-file-name) value(p-dir-name + '/str-glbl.i') .

/*if os-error <> 0
then 
   message "os-error" os-error
   view-as alert-box.
*/
os-delete value(v-file-name).
run filwrlib_num-lines-get in this-procedure
  (output v-num-lines
  ) .

assign
  p-num-lines = v-num-lines
.