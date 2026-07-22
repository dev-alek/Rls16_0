/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для работы с форматом XML и выводом в LOG и EDITOR

Автор: Хныкин Павел Андреевич
Дата создания: 09/21/05
Author: Pavel Khnykin
Creation date: 09/21/05

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scoped-define TabSpaces 4
&scoped-define LogLineSize 80
&scoped-define ScnFileName 'bgescn.txt'

&global-define bge-xml_shedule-out-dir bge-xml_shedule-out-dir
&global-define bge-xml_shedule-parameters bge-xml_shedule-parameters
&global-define bge-xml_shedule-obj-list bge-xml_shedule-obj-list

DEF STREAM stmXMLOut.
DEF STREAM stmXMLLog.

{ gbl/cur-time.i }
{ gbl/xmlchar.i  }
{ gbl/strtdate.i }

define variable v-bge-xml-bgecliiv      as logical  init no  no-undo.       /* Включен параметр внешний приход выгружается как внутренний */
define variable v-bge-xml-bgeclall      as logical  init no  no-undo.       /* Справочник клиентов экспортировать полностью */
define variable v-bge-xml-bgedict       as logical  init no  no-undo.       /* Экспортировать справочники дисконтных карт, типов платежа и кассовых кодов оплат */
define variable v-bge-xml-bgeflold      as character         no-undo.       /* Вариант создания файлов (old, var, new, oracle) */
define variable v-bge-xml-bgefmt        as character         no-undo.       /* Формат вывода (xml, dbf) */
define variable v-bge-xml-shift-mode    as logical           no-undo.       /* Включён ли режим смен */
define variable v-bge-xml-bgeflnm-doc   as character         no-undo.       /* Список шаблонов для файлов выгрузки (если var) */
define variable v-bge-xml-bgeflnm-day   as character         no-undo.       /* Список шаблонов для файлов выгрузки (если var) */

define variable v-bge-xml-log-file-name as character    no-undo.
define variable v-bge-xml-dbf-file-name as character    no-undo.

define variable v-bge-xml-db-num-str    as character    no-undo . /* номер БД выгрузки */
define variable v-bge-xml-static-log-file-name as character    no-undo.

define temp-table temp_ext-doc-type no-undo
    field edt-key               as integer
    field ext-doc-type          as character
    field ext-doc-type-label    as character

    index pi is primary unique
        edt-key
.

define temp-table temp_bge-xml_goods no-undo
    field gds-code as integer
    index pi is primary unique gds-code
.
define temp-table temp_bge-xml_clients no-undo
    field obj-type as character
    field obj-code as integer
    field shift-date    as date
    field shift-num     as integer

    index pi is primary unique
        obj-type
        obj-code
.
define temp-table temp_bge-xml_dis-card no-undo
    field d-card as character

    index pi is primary unique
        d-card
.
define temp-table temp_doc-code no-undo
    field doc-code as character

    index pi is primary unique
        doc-code
.
define temp-table temp_del-doc-code no-undo
    field doc-code as character

    index pi is primary unique
        doc-code
.
define temp-table temp_pr-doc-num no-undo
    field doc-num as character

    index pi is primary unique
        doc-num
.
define temp-table temp_fin-doc-code no-undo
    field host-code as integer
    field fin-doc-code as integer

    index pi is primary unique
        host-code
        fin-doc-code
.
define temp-table temp_del-fin-doc-code no-undo
    field host-code as integer
    field fin-doc-code as integer
    field corr-user-db-num as integer
    field chip-num as integer

    index pi is primary unique
        host-code
        fin-doc-code
        corr-user-db-num
        chip-num
.

define temp-table temp_fin-ob no-undo
    field host-code as integer
    field fin-doc-code as character

    index pi is primary unique
        host-code
        fin-doc-code
.
define temp-table temp_del-fin-ob no-undo
    field host-code as integer
    field fin-doc-code as character
    field corr-user-db-num as integer
    field chip-num as integer

    index pi is primary unique
        host-code
        fin-doc-code
        corr-user-db-num
        chip-num
.

define temp-table temp_ord-doc-code no-undo
  field doc-code as character
index pi is primary unique
  doc-code
.
define temp-table tt-bge-xml-bgecliiv no-undo
  field obj-type  like ub.clients.obj-type
  field obj-code  like ub.clients.obj-code
index pi is primary unique
  obj-type
  obj-code
.

FUNCTION w-XMLPutParamInTag RETURNS CHAR (INPUT sParName AS CHAR, INPUT sToPlace AS CHAR,
                                          INPUT iFlagEmpty AS INTEGER).
/* Функция заменяет спецсимволы для строки XML на соответствующие строковые значения.
   Внимание! Длина строки не должна превышать 255 символов!
Пример.
        sXMLString = w-XMLPutParamInTag("Имя", 'Фирма "Рога & копыта"', 0)
        В результате sXMLString получает значение
              Имя="Фирма &#034;Рога &#038; копыта"
Параметры.
  sParName (input, char)  имя параметра
  sToPlace (input, char) значение строки для параметра
  iFlagEmpty (input, int) флаг обработки пустых строк и 0 в числовом поле, в примере:
      =0 - если sToPlace=? или sToPlace="0"  или sToPlace="", функция возвращает ""
      =1 -          .........................          функция возвращает Имя=&#034;&#034;
      =2 - если sToPlace=? или sToPlace="", функция возвращает "", но
           если sToPlace="0", функция возвращает Имя=&#034;0&#034;
      =3 - если sToPlace=? или sToPlace="0", функция возвращает "", но
           если sToPlace="", функция возвращает Имя=&#034;&#034;
*/

    DEF VAR sOut AS CHAR FORMAT "X(255)" NO-UNDO.

    IF sToPlace = "" OR sToPlace = ? OR sToPlace = "0" THEN
        DO:
            IF iFlagEmpty = 0                           THEN RETURN "".
            ELSE IF iFlagEmpty = 1                      THEN RETURN sParName + "=&#034;&#034;".
            ELSE IF iFlagEmpty = 2 AND sToPlace = "0"   THEN RETURN sParName + "=&#034;0&#034;".
            ELSE IF iFlagEmpty = 3 AND sToPlace = ""    THEN RETURN sParName + "=&#034;&#034;".
            ELSE RETURN "".
        END.
    ELSE DO:
        run xmlchar-encode in this-procedure (
              input sToPlace
            , output sToPlace
        ).
        ASSIGN
            sToPlace = sParName + '="' + sToPlace + '"'
        .
        RETURN sToPlace.
    END.

END FUNCTION.

/*==========================================================================*/
function bge-xml-date returns character
( input p-date as date )
:
  define variable v-date-str as character no-undo .
  run bge-xml-date-to-str in this-procedure ( input   p-date
                                            , output  v-date-str
                                            ) .
  return v-date-str.
end function.

/*==========================================================================*/
function bge-xml-str-date returns character
( input p-date-str as character )
:
  define variable v-date-str as character no-undo .
  run bge-xml-date-str-to-str in this-procedure ( input   p-date-str
                                                , output  v-date-str
                                                ) .
  return v-date-str.
end function.

/*==========================================================================*/
function bge-xml-normalize-dec returns decimal
( input p-val as decimal )
:
  return (if p-val = ? then 0 else p-val) .
end function.




/*========================================================================*/
PROCEDURE wp-XMLTagOpen:
DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
DEF INPUT PARAM sTagName AS CHAR NO-UNDO.
DEF INPUT PARAM sParValue AS CHAR NO-UNDO.

    define variable v-out-string    as character    no-undo.
do
on error undo, return error
:
/*  Процедура открывает тэг
    iTagLevel - условный уровень тэга (количество пробелов от начала файла * {&TabSpaces})
    sTagName - имя тэга
    sParValue - заполнитель параметров тэга,
        может передавать значения типа 'Адрес="ул. Салтыкова"'
*/
/*    run xmlchar-encode in this-procedure (*/
/*          input sParValue*/
/*        , output sParValue*/
/*    ).*/
    if v-bge-xml-bgefmt = "dbf":U
    then do:        /* идёт вывод только данных */

    end.        /* if v-bge-xml-bgefmt = "dbf":U */
    else do:
        assign
            v-out-string = substitute( "&1&2<&3&4>"
                                    , {&new-line}
                                    , fill( " ":U, {&TabSpaces} * iTagLevel)
                                    , sTagName
                                    , ( if sParValue = "":U or sParValue = ? then "":U else " " + sParValue )
                            )
        .
        put stream stmXMLOut unformatted
            v-out-string
        .
    end.        /* NOT ( if v-bge-xml-bgefmt = "dbf":U ) */
end.
END PROCEDURE.

/*========================================================================*/
PROCEDURE wp-XMLTagPut:
  DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
  DEF INPUT PARAM sTagName AS CHAR NO-UNDO.
  DEF INPUT PARAM sParValue AS CHAR NO-UNDO.
  DEF INPUT PARAM iFlagEmpty AS INTEGER NO-UNDO.

    define variable v-out-string    as character    no-undo.
do
on error undo, return error
:
/*  Процедура создает закрытый тэг, заполняя его значением из sParValue
    iTagLevel - условный уровень тэга (количество пробелов от начала файла * {&TabSpaces})
    sTagName - имя тэга
    sParValue - текст, который нужно вписать между тэгами последнего уровня.
        можно передавать значения типа 'Адрес="ул. Салтыкова"'
    iFlagEmpty - что делать, если sParValue=? или sParValue="":U
        0  или любое из не перечисленных - не выводить ничего
        1 - выводить начало и конец тэга
        2 - то же, что и 0, но ничего не выводит и в случае sParValue = "0"
        3 - то же, что и 0, но ничего не выводит и в случае sParValue = "No"
*/
    if v-bge-xml-bgefmt = "dbf":U
    then do:
        if v-bge-xml-dbf-file-name <> "":U
        then do:
            output stream stmXMLOut to value( v-bge-xml-dbf-file-name ) append.
            export stream stmXMLOut
                sTagName
                sParValue
            .
            output stream stmXMLOut close.
        end.
    end.        /* if v-bge-xml-bgefmt = "dbf":U */
    else do:
        IF  iFlagEmpty = 1
        OR (iFlagEmpty = 0 AND (sParValue <> "" AND sParValue <> ?) )
        OR (iFlagEmpty = 2 AND (sParValue <> "" AND sParValue <> ? AND sParValue <> "0"))
        OR (iFlagEmpty = 3 AND (sParValue <> "" AND sParValue <> ? AND CAPS(sParValue) <> "NO"))
        THEN DO:
            run xmlchar-encode in this-procedure (
                input sParValue
                , output sParValue
            ).
            assign
                v-out-string = substitute( "&1&2<&3>&4</&3>"
                                            , {&new-line}
                                            , FILL(" ", {&TabSpaces} * iTagLevel)
                                            , sTagName
                                            , sParValue
                            )
            .
            PUT STREAM stmXMLOut UNFORMATTED
                v-out-string
            .
        END.
    end.        /* NOT ( if v-bge-xml-bgefmt = "dbf":U ) */
end.
END PROCEDURE.

/*========================================================================*/
PROCEDURE wp-XMLTagClose:
DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
DEF INPUT PARAM sTagName AS CHAR NO-UNDO.

    define variable v-out-string    as character    no-undo.
do
on error undo, return error
:
/*  Процедура закрывает тэг
    iTagLevel - условный уровень тэга (количество пробелов от начала файла * {&TabSpaces})
    sTagName - имя тэга
*/
    if v-bge-xml-bgefmt = "dbf":U
    then do:

    end.        /* if v-bge-xml-bgefmt = "dbf":U */
    else do:
        assign
            v-out-string = substitute( "&1&2</&3>"
                                , ( if iTagLevel=0 then "":U else {&new-line} )
                                , fill( " ", {&TabSpaces} * iTagLevel )
                                , sTagName
                        )
        .
        PUT STREAM stmXMLOut UNFORMATTED
            v-out-string
        .
    end.        /* NOT ( if v-bge-xml-bgefmt = "dbf":U ) */
end.
END PROCEDURE.

/*========================================================================*/
PROCEDURE wp-XMLWriteLog:
  DEF INPUT PARAMETER sFileName AS CHAR     NO-UNDO.
  DEF INPUT PARAMETER iLogLevel AS INTEGER  NO-UNDO.
  DEF INPUT PARAMETER sToWrite  AS CHAR     NO-UNDO.
/*
  Процедура делает запись в файле, определенном параметром sFileName.
  Запись выглядит следующим образом:
     <Пробелы, определяемые параметром iLogLevel><Текущая дата><sToWrite>
  Специальные значения для iLogLevel:
       0 - не выводить дату (1 - без отступа)
  Специальные значения для sToWrite:
      "&Line"  - Вывести разделительную линию из символов "-"
      "&DLine" - Вывести разделительную линию из символов "="
    Длина разделительных линий задается в LogLineSize.
*/

define variable v-str              as character no-undo .
define variable v-error-append     as logical   no-undo .
define variable v-error-append-msg as character no-undo .

assign
  v-str = {&new-line}
          + (if (iLogLevel = 0 or sToWrite = "&DLine" or sToWrite = "&Line") then "" else cur-time-string-sec() + " ")
          + (if sToWrite = "&Line" then fill("-", {&LogLineSize}) else if sToWrite = "&DLine" then fill("=", {&LogLineSize}) else sToWrite)
  v-str = replace(v-str, ({&new-line} + {&carriage-return}), {&new-line} )
  v-str = replace(v-str, ({&carriage-return} + {&new-line}), {&new-line} )
  v-str = replace(v-str, {&new-line}, ({&carriage-return} + {&new-line}) )
.
run bge/bge-log.p (input v-str) no-error .
if error-status:error then do:
  assign
    v-error-append     = yes
    v-error-append-msg = return-value
  .
end.
/* в общий лог */
run gbl/fileapnd.p
  ( input sFileName
  , input v-str
  , input 10 /* время ожинания освобождения файла */
  ) no-error .
if error-status:error then do:
  assign
    v-error-append     = yes
    v-error-append-msg = substitute( "&1&2&3"
                                    , v-error-append-msg
                                    , {&new-line}
                                    , return-value
                                    )
  .
end.
if v-error-append
then do:
  return error substitute( "&1" , v-error-append-msg ) .
end.

END PROCEDURE.


/*========================================================================*/
PROCEDURE wp-XMLWriteEDT:
  DEF INPUT PARAMETER hEDT AS HANDLE NO-UNDO.
  DEF INPUT PARAMETER iLogLevel AS INTEGER  NO-UNDO.
  DEF INPUT PARAMETER sToWrite  AS CHAR     NO-UNDO.
/*
  Процедура выводит запись в EDITOR, определенный параметром hEDT.
  Запись выглядит следующим образом:
     <Текущая дата><Пробелы, определяемые параметром iLogLevel><sToWrite>
  Специальные значения для iLogLevel:
       0 - не выводить дату (1 - без отступа)
  Специальные значения для sToWrite:
      "&Line"  - Вывести разделительную линию из символов "-"
      "&DLine" - Вывести разделительную линию из символов "="
    Длина разделительных линий задается в LogLineSize.
*/
    if valid-handle ( hEDT )
    then do:
        hEDT :move-to-eof().
        hEDT :insert-string(IF (iLogLevel = 0 OR sToWrite = "&DLine"
                                        OR sToWrite = "&Line") THEN "" ELSE
                                        cur-time-string-sec() + " ").
        hEDT :insert-string(IF sToWrite = "&Line" THEN FILL("-", {&LogLineSize})
                ELSE IF sToWrite = "&DLine" THEN FILL("=", {&LogLineSize})
                ELSE FILL(" ", iLogLevel) + sToWrite).
        hEDT :insert-string({&new-line}).
    end.
    process events.
    output to {&ScnFileName} append.
        put unformatted
            {&new-line} string( (IF (iLogLevel = 0 OR sToWrite = "&DLine"
                                        OR sToWrite = "&Line") THEN "" ELSE
                                        STRING(TODAY) + " " + STRING(TIME, "hh:mm:ss") + " ") )
            string( (IF sToWrite = "&Line" THEN FILL("-", {&LogLineSize})
                ELSE IF sToWrite = "&DLine" THEN FILL("=", {&LogLineSize})
                ELSE FILL(" ", iLogLevel) + sToWrite) )
        .
    output close.
END PROCEDURE.

/*========================================================================*/
PROCEDURE wp-XMLShowCNT:
  DEF INPUT PARAMETER hCNT     AS HANDLE   NO-UNDO.
/*
  Процедура делает видимым FILL-IN, определенный параметром hCNT.
*/
    if valid-handle( hCNT )
    then do:
        ASSIGN hCNT :VISIBLE = TRUE.
    end.
END PROCEDURE.

/*========================================================================*/
PROCEDURE wp-XMLHideCNT:
  DEF INPUT PARAMETER hCNT     AS HANDLE   NO-UNDO.
/*
  Процедура скрывает FILL-IN, определенный параметром hCNT.
*/
    if valid-handle( hCNT )
    then do:
        ASSIGN hCNT :VISIBLE = FALSE.
    end.
END PROCEDURE.

/*========================================================================*/
PROCEDURE wp-XMLWriteCNT:
  DEF INPUT PARAMETER hCNT     AS HANDLE  NO-UNDO.
  DEF INPUT PARAMETER sCounter AS CHAR    NO-UNDO.
/*
  Процедура выводит значение sCounter в FILL-IN,
  определенный параметром hCNT.
*/
    if valid-handle( hCNT )
    then do:
        ASSIGN hCNT :SCREEN-VALUE = sCounter.
    end.
END PROCEDURE.

/*========================================================================*/
procedure bge-xml-write-header:
do
on error undo, return error
:
define input parameter p-xml-file-name  as character        no-undo.
define input parameter p-doc-name       as character        no-undo.
define input parameter p-version        as character        no-undo.
define input parameter p-db-num         as integer          no-undo.
define input parameter p-date-from      as date             no-undo.
define input parameter p-shift-num-from as integer          no-undo.
define input parameter p-date-to        as date             no-undo.
define input parameter p-shift-num-to   as integer          no-undo.
define input parameter p-obj-list       as character        no-undo.
define input parameter p-doc-type-list  as character        no-undo.
define input parameter p-pay-code       as logical          no-undo.
define input parameter p-cst            as logical          no-undo.
define input parameter p-parts          as logical          no-undo.
define input parameter p-chk-pay-code   as logical          no-undo.
define input parameter p-pay-desk       as logical          no-undo.
define input parameter p-pay-desk-cards as logical          no-undo.
define input parameter p-deleted        as logical          no-undo.
define input parameter p-opened-docs    as logical          no-undo.

define variable v-out-string    as character    no-undo.
output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251".

assign
    v-out-string = substitute( "&1&2&3"
                        , "<?xml version='1.0' encoding='windows-1251'?>":U
                        , {&new-line}
                        , "<IBS_Trade_House>":U )
.
/*  {&new-line} + "<?xml-stylesheet type='text/xsl' href='{&OutFileName}.xsl'?>" */

put stream stmXMLOut unformatted
    v-out-string
.
run wp-XMLTagOpen(1, "header","").
if v-bge-xml-bgeflold = "oracle":u
then do:
  run wp-XMLTagOpen in this-procedure  ( 2, "delivery", "").
  run wp-XMLTagput in this-procedure ( 3, "message","", 1).
  run wp-XMLTagput in this-procedure ( 3, "from","IBS Trade House", 1).
  run wp-XMLTagput in this-procedure ( 3, "to","Oracle Retail", 1).
  run wp-XMLTagClose in this-procedure ( 2, "delivery"    ).
end.
run wp-XMLTagOpen( 2, "manifest", "").
run wp-XMLTagOpen( 3, "document", "").
run wp-XMLTagput( 4, "name", p-doc-name, 0).
run wp-XMLTagput( 4, "description", "", 0).
run wp-XMLTagput( 4, "version", p-version, 0).
run wp-XMLTagclose( 3, "document" ).
run wp-XMLTagclose( 2, "manifest" ).
run wp-XMLTagclose( 1, "header" ).
run wp-XMLTagOpen(1, "options","").
run wp-XMLTagput( 2, "exportDate",      string( today,              "99/99/9999" ), 0).
run wp-XMLTagput( 2, "exportDateXml",   bge-xml-date( today )                     , 0).
run wp-XMLTagput( 2, "exportTime",      string( time,               "HH:MM:SS"   ), 0).
run wp-XMLTagput( 2, "baseNum",         string( p-db-num                         ), 0).
run wp-XMLTagput( 2, "dateFrom",        string( p-date-from,        "99/99/9999" ), 0).
run wp-XMLTagput( 2, "dateFromXml",     bge-xml-date( p-date-from )               , 0).
run wp-XMLTagput( 2, "shiftNumFrom",    string( p-shift-num-from                 ), 2).
run wp-XMLTagput( 2, "dateTo",          string( p-date-to,          "99/99/9999" ), 0).
run wp-XMLTagput( 2, "dateToXml",       bge-xml-date( p-date-to )                 , 0).
run wp-XMLTagput( 2, "shiftNumTo",      string( p-shift-num-to                   ), 2).
run wp-XMLTagput( 2, "objList",                 p-obj-list                        , 0).
run wp-XMLTagput( 2, "docTypeList",             p-doc-type-list                   , 0).
run wp-XMLTagput( 2, "payCode",         string( p-pay-code                       ), 0).
run wp-XMLTagput( 2, "cst",             string( p-cst                            ), 0).
run wp-XMLTagput( 2, "parts",           string( p-parts                          ), 0).
run wp-XMLTagput( 2, "chkPayCode",      string( p-chk-pay-code                   ), 0).
run wp-XMLTagput( 2, "chkPayDesk",      string( p-pay-desk                       ), 0).
run wp-XMLTagput( 2, "chkPayDeskCards", string( p-pay-desk-cards                 ), 0).
run wp-XMLTagput( 2, "deletedDocs",     string( p-deleted                        ), 0).
run wp-XMLTagput( 2, "openedDocs",      string( p-opened-docs                    ), 0).
run wp-XMLTagClose(1, "options").
run wp-XMLTagOpen( 1, "body", "" ).

output stream stmXMLOut close.
end.
end procedure.

/*========================================================================*/
procedure xml-bge-write-footer:
do
on error undo, return error return-value
:
define input parameter p-xml-file-name as character    no-undo.

define variable v-error-num     as integer           no-undo.

output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251" append.
run wp-XMLTagClose( 1, "body" ).
run wp-XMLTagClose( 0, "IBS_Trade_House" ).
output stream stmXMLOut close.

if v-bge-xml-bgeflold = "oracle":u
then do:
  define variable v-tmp-file-name         as character no-undo .
  define variable v-zip-file-name         as character no-undo .
  define variable v-exch-file-name        as character no-undo .
  define variable v-heap-file-name        as character no-undo .
  define variable v-i                     as integer   no-undo .
  define variable v-file-name             as character no-undo .
  define variable v-arc                   as character no-undo .
  define variable v-str                   as character no-undo .
  define variable v-exch-tmp-file-name    as character no-undo . /* tempfile exch директория */
  define variable v-bge-xml-tmp-exch-dir  as character no-undo . /* tempdir exch директория  */
  define variable v-bge-xml-exch-dir      as character no-undo . /* file exch директория */
  define variable v-bge-xml-heap-dir      as character no-undo . /* file heap директория */
  define variable v-bge-xml-compress-heap as logical   no-undo . /* сжимать ли heap */
  define variable v-home-dir              as character no-undo .
  define variable v-os-command            as character no-undo .

  get-key-value section "BGE" key "Dirfrg-acc" value v-home-dir.
  if v-home-dir = ?
  then do:            /* нет ключа */
    undo, return error substitute( "&1&2&3"
                                  , "Не найден параметр ini-файла, определяющий каталог экспорта.":u
                                  , {&new-line}
                                  , "Обратитесь к администратору.":u
                                  ).
  end.

  assign
    v-home-dir = v-home-dir
  .
  run gbl/dir-cre.p ( input v-home-dir ) no-error.
  if error-status :error
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Неверно задан каталог экспорта.":u
                                  , {&new-line}
                                  , "Обратитесь к администратору.":u
                                  ).
  end.

  get-key-value section "BGE" key "dir-exch" value v-bge-xml-exch-dir .
  if v-bge-xml-exch-dir = ?
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Не найден параметр ini-файла, определяющий каталог экспорта (exch).":u
                                  , {&new-line}
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  run gbl/dir-cre.p ( input v-bge-xml-exch-dir ) no-error.
  if error-status :error
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Неверно задан каталог экспорта (exch).":u
                                  , {&new-line}
                                  , "Обратитесь к администратору.":u
                                  ).
  end.

  get-key-value section "BGE" key "dir-heap" value v-bge-xml-heap-dir.
  if v-bge-xml-heap-dir = ?
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Не найден параметр ini-файла, определяющий каталог экспорта (heap).":u
                                  , {&new-line}
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  run gbl/dir-cre.p ( input v-bge-xml-heap-dir ) no-error.
  if error-status :error
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Неверно задан каталог экспорта (heap).":u
                                  , {&new-line}
                                  , "Обратитесь к администратору.":u
                                  ).
  end.

  get-key-value section "BGE" key "heap-compress" value v-str.
  assign
    v-i = int(v-str)
  no-error .
  if v-i = ? or v-i = 0
  then do:
    assign
      v-bge-xml-compress-heap = no
    .
  end.
  else do:
    assign
      v-bge-xml-compress-heap = yes
    .
  end.

  assign
    v-arc = search( "exe/7za.exe":u )
  .
  if v-arc = ? or v-arc = ""
  then do:
    undo, return error("Не найдена программа 7za.exe, невозможно упаковать файлы в архив.":u).
  end.

  assign
    v-file-name            = entry(num-entries( p-xml-file-name , {&slash-char} ) , p-xml-file-name , {&slash-char} )
    v-tmp-file-name        = session :temp-directory + v-file-name + "DAT":u
    v-zip-file-name        = session :temp-directory + v-file-name + "DAT.zip":u
    v-bge-xml-tmp-exch-dir = v-bge-xml-exch-dir + ".000"
    v-exch-tmp-file-name   = v-bge-xml-tmp-exch-dir + {&slash-char} + v-file-name + "tmp":u
    v-exch-file-name       = v-bge-xml-exch-dir + {&slash-char} + v-file-name + "DAT.zip":u
    v-heap-file-name       = v-bge-xml-heap-dir + {&slash-char} + v-file-name + "DAT":u
  .

  /*
    перенести в temp-dir и переименовать: .xm1 -> .DAT
  */
  run gbl/del-file.p (input v-tmp-file-name) .
  run gbl/del-file.p (input v-zip-file-name) .
  run bge/os_copy.p ("M", p-xml-file-name + "xm1":u, v-tmp-file-name, output v-error-num ).
  if v-error-num > 0
  then do:
      undo, return error substitute( "Ошибка переноса из &1 в &2. Код ошибки: &3"
                                   , p-xml-file-name + "xm1":u
                                   , v-tmp-file-name
                                   , v-error-num
                                   ).
  end.

  assign
    v-os-command     = substitute( "&1 a -tzip &2 &3"
                                 , v-arc
                                 , v-zip-file-name
                                 , v-tmp-file-name
                                 )
  .

  os-command silent value ( v-os-command ) .

  run gbl/del-file.p (input v-heap-file-name) .

  /* копируем в heap */
  if v-bge-xml-compress-heap = no
  then do:
    run bge/os_copy.p ("C", v-tmp-file-name, v-heap-file-name, output v-error-num ).
    if v-error-num > 0
    then do:
        undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                     , v-tmp-file-name
                                     , v-heap-file-name
                                     , v-error-num
                                     ) .
    end.
  end.
  else do:
    run bge/os_copy.p ("C", v-zip-file-name, v-heap-file-name + ".zip", output v-error-num ).
    if v-error-num > 0
    then do:
        undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                     , v-zip-file-name
                                     , v-heap-file-name
                                     , v-error-num
                                     ) .
    end.
  end.

  run gbl/del-file.p (input v-tmp-file-name) .


  run gbl/dir-cre.p ( input v-bge-xml-tmp-exch-dir ) no-error.
  if error-status :error then do:
    undo, return error substitute( "&1&2&3"
                                  , substitute( "Не удалось создать каталог &1.", v-bge-xml-tmp-exch-dir )
                                  , {&new-line}
                                  , "Обратитесь к администратору."
                                  ).
  end.
  run gbl/del-file.p (input v-exch-file-name) .
  run gbl/del-file.p (input v-exch-tmp-file-name ) .

  /* копируем zip в exch */
  run bge/os_copy.p ("M", v-zip-file-name, v-exch-tmp-file-name, output v-error-num ).
  if v-error-num > 0
  then do:
    undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                  , v-zip-file-name
                                  , v-exch-tmp-file-name
                                  , v-error-num
                                  ) .
  end.
  run bge/os_copy.p ("M", v-exch-tmp-file-name, v-exch-file-name , output v-error-num ).
  if v-error-num > 0
  then do:
    undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                  , v-exch-tmp-file-name
                                  , v-exch-file-name
                                  , v-error-num
                                  ) .
  end.
  run gbl/del-file.p (input v-bge-xml-tmp-exch-dir ) .
end.
else do:
  /*- переименовать: .xm1 -> .xml -*/
  run bge/os_copy.p ("M", p-xml-file-name + "xm1", p-xml-file-name + "xml", output v-error-num ).
  if v-error-num > 0
  then do:
    undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                  , p-xml-file-name + "xm1"
                                  , p-xml-file-name + "xml"
                                  , v-error-num
                                  ) .
  end.
end.
/*- права "a+rw" на файл -*/
if opsys = "unix"
then do:
    os-command silent chmod 666 value (p-xml-file-name + "xml") 2>/dev/null.
end.

end.
end procedure.

/*==========================================================================
Процедура возвращает имя файла для выгрузки (без расширения, с полным путем и точкой),
полное имя log-файла и признак того, что файл заблокирован.
Input:
    p-prefix            - для генерации названия.
    p-name              - для фиксированного названия.
    p-shared-process    - имя генерируется для выгрузки по расписанию.
Output:
    p-xml-file-name - полное имя файла выгрузки с точкой, без расширени
    p-log-file-name - полное имя log-файла
    p-locked        - yes если идет выгрузка в этот файл
*/
procedure xml-bge-filename0:
define input parameter p-prefix   as character no-undo .
define input parameter p-name     as character no-undo .
define input parameter p-shared-process as logical no-undo .
define input parameter p-home-dir as character no-undo . // из ini-параметра [BGE] Dirfrg-acc
define output parameter p-xml-file-name  as character no-undo .
// define output parameter p-fullfnamenoext as character no-undo .
define output parameter p-locked         as logical      no-undo.
define variable v-fullfnamenoext as character no-undo .
define variable v-fileext        as character no-undo .
define variable v-fullfname      as character no-undo .
define variable v-error-num      as integer   no-undo .
do
on error undo, return error
:
  
  case v-bge-xml-bgeflold :
    when "old" then do:
      v-fullfnamenoext = substitute ("&1&2&3&4", p-home-dir, {&slash-char}, p-name, v-bge-xml-db-num-str) .
      v-fileext       = ".xml":U .
      v-fullfname     = v-fullfnamenoext + v-fileext .
      p-xml-file-name = v-fullfname .
      run bge/os_copy.p ("D", p-xml-file-name, "", output v-error-num ).
      if v-error-num > 0 then do:
        return error.
      end.
    end.
    when "var" then do:
      case p-prefix :
        when "doc" then do:
          v-fullfnamenoext = substitute ("&1&2&3&4", p-home-dir, {&slash-char}, p-name, v-bge-xml-bgeflnm-doc) .
          v-fileext       = ".xml":U .
          v-fullfname     = v-fullfnamenoext + v-fileext .
          p-xml-file-name = v-fullfname .
        end.
        when "day" then do:
          v-fullfnamenoext = substitute ("&1&2&3&4", p-home-dir, {&slash-char}, p-name, v-bge-xml-bgeflnm-day) .
          v-fileext       = ".xml":U .
          v-fullfname     = v-fullfnamenoext + v-fileext .
          p-xml-file-name = v-fullfname .
        end.
        otherwise do:
          v-fullfnamenoext = substitute ("&1&2&3", p-home-dir, {&slash-char}, p-name) .
          v-fileext       = ".xml":U .
          v-fullfname     = v-fullfnamenoext + v-fileext .
          p-xml-file-name = v-fullfname .
        end.
      end case.
      run bge/os_copy.p ("D", p-xml-file-name, "", output v-error-num ).
      if v-error-num > 0 then do:
        return error.
      end.
    end.
    when "new" then do:
                run bge/genfname.p (
                    input p-home-dir
                    , input p-prefix
                    , input ""
                    , input "xml"
                    , input ""
                    , output p-xml-file-name
                ).
    end.
    when "no-parameter" then do:
      if p-shared-process then do:
                    run bge/genfname.p (
                        input p-home-dir
                        , input "d"
                        , input ""
                        , input "xml"
                        , input ""
                        , output p-xml-file-name
                    ).
      end.        /* if p-name = "document"  */
      else do:
        v-fullfnamenoext = substitute ("&1&2&3", p-home-dir, {&slash-char}, p-name) .
        v-fileext       = ".xml":U .
        v-fullfname     = v-fullfnamenoext + v-fileext .
        p-xml-file-name = v-fullfname .
        run bge/os_copy.p ("D", p-xml-file-name, "", output v-error-num ).
        if v-error-num > 0 then do:
          return error.
        end.
      end.        /* NOT ( if p-name = "document"  ) */
    end.        /* when "no-parameter" */
  end case.
  assign
    p-xml-file-name = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
    p-locked = ( search ( p-xml-file-name + "lk" ) <> ? )
  .
  
end .  
end procedure .
procedure xml-bge-filename :
do
on error undo, return error
:
define input parameter p-prefix             as character    no-undo.
define input parameter p-name               as character    no-undo.
define input parameter p-shared-process     as logical      no-undo.
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-locked            as logical      no-undo.

define variable v-home-dir          as character no-undo .
define variable v-error-num         as integer   no-undo .
define variable v-bge-xml-heap-dir  as character no-undo . /* heap директория */

    get-key-value section "BGE" key "Dirfrg-acc" value v-home-dir.
    if v-home-dir = ?
    then do:            /* нет ключа */
        message
          skip "Не найден параметр ini-файла, определяющий каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.

    if v-bge-xml-bgeflold <> "oracle"
    then do:
      assign
          v-home-dir = v-home-dir + {&slash-char} + "exp-acc"
      .
    end.
    run gbl/dir-cre.p ( input v-home-dir ) no-error.
    if error-status :error
    then do:
        message
          skip "Неверно задан каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if v-bge-xml-bgefmt = "dbf":U
    then do:        /* Выгрузка каждого документа ведётся в отдельный файл. Нужна только проверка каталога */
        assign
            p-xml-file-name = v-home-dir
            p-locked        = no
        .
    end.        /* if v-bge-xml-bgefmt = "dbf":U */
    else do:
        run xml-bge-filename0 in this-procedure (p-prefix, p-name, p-shared-process, v-home-dir,
          output p-xml-file-name, output p-locked) .
        /* 06/IX-2018 - вынесено в процедуру, т.к. изначально была потребность получить имя файла, без пути,
                        а не создавать повторно директорию выгрузки
        case v-bge-xml-bgeflold
        :
            when "old"
            then do:
                assign
                    p-xml-file-name = v-home-dir + {&slash-char} + p-name + v-bge-xml-db-num-str + ".xml":U
                .
                run bge/os_copy.p ("D", p-xml-file-name, "", output v-error-num ).
                if v-error-num > 0
                then do:
                    return error.
                end.
            end.
            when "var"
            then do:
                case p-prefix
                :
                    when "doc"
                    then do:
                        assign
                            p-xml-file-name = v-home-dir + {&slash-char} + v-bge-xml-bgeflnm-doc + ".xml":U
                        .
                    end.
                    when "day"
                    then do:
                        assign
                            p-xml-file-name = v-home-dir + {&slash-char} + v-bge-xml-bgeflnm-day + ".xml":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-xml-file-name = v-home-dir + {&slash-char} + p-name + ".xml":U
                        .
                    end.
                end case.
                run bge/os_copy.p ("D", p-xml-file-name, "", output v-error-num ).
                if v-error-num > 0
                then do:
                    return error.
                end.
            end.
            when "new"
            then do:
                run bge/genfname.p (
                    input v-home-dir
                    , input p-prefix
                    , input ""
                    , input "xml"
                    , input ""
                    , output p-xml-file-name
                ).
            end.
            when "no-parameter"
            then do:
                if p-shared-process = yes
                then do:
                    run bge/genfname.p (
                        input v-home-dir
                        , input "d"
                        , input ""
                        , input "xml"
                        , input ""
                        , output p-xml-file-name
                    ).
                end.        /* if p-name = "document"  */
                else do:
                    assign
                        p-xml-file-name = v-home-dir + {&slash-char} + p-name + ".xml":U
                    .
                    run bge/os_copy.p ("D", p-xml-file-name, "", output v-error-num ).
                    if v-error-num > 0
                    then do:
                        return error.
                    end.
                end.        /* NOT ( if p-name = "document"  ) */
            end.        /* when "no-parameter" */
        end case.
        assign
            p-xml-file-name = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
            p-locked = ( search ( p-xml-file-name + "lk" ) <> ? )
        .
        */
    end.        /* NOT ( if v-bge-xml-bgefmt = "dbf":U ) */

    if v-bge-xml-bgeflold = "oracle"
    then do:
      get-key-value section "BGE" key "dir-heap" value v-bge-xml-heap-dir.
      if v-bge-xml-heap-dir = ?
      then do:
        undo, return error substitute( "&1&2&3"
                                      , "Не найден параметр ini-файла, определяющий каталог экспорта (heap).":u
                                      , {&new-line}
                                      , "Обратитесь к администратору.":u
                                      ).
      end.
      run gbl/dir-cre.p ( input v-bge-xml-heap-dir ) no-error.
      if error-status :error
      then do:
        undo, return error substitute( "&1&2&3"
                                      , "Неверно задан каталог экспорта (heap).":u
                                      , {&new-line}
                                      , "Обратитесь к администратору.":u
                                      ).
      end.

      if r-index( v-bge-xml-heap-dir, {&slash-char} ) > r-index( v-bge-xml-heap-dir, {&back-slash-char} ) then do:
        assign
          p-log-file-name = substring( v-bge-xml-heap-dir, 1, r-index( v-bge-xml-heap-dir, {&slash-char} ) ) + {&slash-char} + "actions.log"
        .
      end.
      else do:
        assign
          p-log-file-name = substring( v-bge-xml-heap-dir, 1, r-index( v-bge-xml-heap-dir, {&back-slash-char} ) ) + {&slash-char} + "actions.log"
        .
      end.
    end.
    else do:
      assign
          p-log-file-name = v-home-dir + {&slash-char} + "actions.log"
      .
    end.
    assign
       v-bge-xml-static-log-file-name = p-log-file-name
    .
end.
end procedure. /* xml-bge-filename */

/*==========================================================================
Процедура чтения параметров внешней бухгалтерии.
Input:
    p-date-to   - Дата для получения файлов выгрузки документов и товаров по дням.
                    В остальных типах выгрузки можно задавать ?, тогда эти имена
                    генерироваться не будут.

    p-db-num    - Номер БД для получения файлов выгрузки документов и товаров по дням.
                    В остальных типах выгрузки можно задавать ?, тогда эти имена
                    генерироваться не будут.
*/
procedure bge-xml-read-config :
do
on error undo, return error return-value
:
define input  parameter p-last-date as date      no-undo .
define input  parameter p-db-num    as integer   no-undo .

    define variable v-bgeclall      as character     no-undo.
    define variable v-bgedict       as character     no-undo.
    define variable v-bgeshift      as character     no-undo.
    define variable v-par-type      as character     no-undo.
    define variable v-bgeflnm       as character     no-undo.
    define variable v-bgecliiv      as character     no-undo .
    define variable v-date-chars    as character case-sensitive  init "DD"      no-undo.
    define variable v-month-chars   as character case-sensitive  init "MM"      no-undo.
    define variable v-year-chars    as character case-sensitive  init "YY"      no-undo.
    define variable v-db-num-chars  as character case-sensitive  init "BBBBB"   no-undo.
    define variable v-db-num-str    as character     no-undo .
    define variable v-param-type      as character  no-undo .
    define variable v-value-character as character  no-undo .
    define variable v-value-date      as date       no-undo .
    define variable v-value-decimal   as decimal    no-undo .
    define variable v-value-integer   as integer    no-undo .
    define variable v-value-logical   as logical    no-undo .
    define variable v-tth             as handle      no-undo .

    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  {&attr-bge-export}
                      , input  {&attr-bge-export_bgeclall}
                      , output v-bgecliiv
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgecliiv = no
      .
    end.
    else do:
      /* если параметр есть, то разбираем его, флаги поставятся в процедуре */
      run bge-xml-fill-tt-bgecliiv in this-procedure ( input v-bgecliiv ).
    end.
    delete object v-tth.
    assign
        v-bge-xml-bgeclall = no
        v-bge-xml-bgedict  = no
    .
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  {&attr-bge-export}
                      , input  {&attr-bge-export_bgeclall}
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgeclall = no
      .
    end.
    else do:
      assign
        v-bge-xml-bgeclall = v-value-logical
      .
    end.
    delete object v-tth.

    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  {&attr-bge-export}
                      , input  {&attr-bge-export_bgedict}
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgedict = no
      .
    end.
    else do:
      assign
        v-bge-xml-bgedict = v-value-logical
      .
    end.
    delete object v-tth.

    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  {&attr-bge-export}
                      , input  {&attr-bge-export_bgefmt}
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgefmt  = "xml":U
      .
    end.
    else do:
      assign
        v-bge-xml-bgefmt  = v-value-character
      .
    end.
    delete object v-tth.

    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  {&attr-bge-export}
                      , input  {&attr-bge-export_bgeshift}
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
          v-bge-xml-shift-mode = no
      .
    end.
    else do:
      assign
          v-bge-xml-shift-mode = ( v-value-character = "distinct":U )
      .
    end.
    delete object v-tth.

    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  {&attr-bge-export}
                      , input  {&attr-bge-export_bgeflold}
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgeflold = "no-parameter":U
      .
    end.
    else do:
      assign
        v-bge-xml-bgeflold  = v-value-character
      .
    end.
    delete object v-tth.
    assign
      v-db-num-str          = ( if p-db-num <> ? then string(p-db-num ,"99999") else "":u )
      v-bge-xml-db-num-str  = v-db-num-str
    .
    if p-last-date <> ?
    then do:
        run adm/shattri.p ( input "get":U
                          , input  '':u
                          , input  0
                          , input  {&attr-bge-export}
                          , input  {&attr-bge-export_bgeflnm}
                          , output v-value-character
                          , output v-value-date
                          , output v-value-decimal
                          , output v-value-integer
                          , output v-value-logical
                          , output v-param-type
                          , input-output table-handle v-tth
                          ) no-error .
        if error-status :error
        then do:
          assign
            v-bgeflnm = '':U
          .
        end.
        else do:
          assign
            v-bgeflnm = v-value-character
          .
        end.
        delete object v-tth.

        if v-bge-xml-bgeflold = "var"
        then do:
            if v-bgeflnm = ?
            or num-entries( v-bgeflnm ) < 2
            then do:
                assign
                    v-bge-xml-bgeflold = "new"
                .
            end.        /* if v-bgeflnm = ? */
            else do:
                assign
                    v-bge-xml-bgeflnm-doc = entry( 1, v-bgeflnm )
                    v-bge-xml-bgeflnm-day = entry( 2, v-bgeflnm )
                .
                assign
                    v-bge-xml-bgeflnm-doc = replace( v-bge-xml-bgeflnm-doc, v-date-chars , string( day( p-last-date ), "99" ) )
                    v-bge-xml-bgeflnm-doc = replace( v-bge-xml-bgeflnm-doc, v-month-chars, string( month( p-last-date ), "99" ) )
                    v-bge-xml-bgeflnm-doc = replace( v-bge-xml-bgeflnm-doc, v-year-chars , substring( string( year( p-last-date ), "9999" ), 3, 2 ) )
                    v-bge-xml-bgeflnm-doc = replace( v-bge-xml-bgeflnm-doc, v-db-num-chars, v-db-num-str )
                    v-bge-xml-bgeflnm-day = replace( v-bge-xml-bgeflnm-day, v-date-chars , string( day( p-last-date ), "99" ) )
                    v-bge-xml-bgeflnm-day = replace( v-bge-xml-bgeflnm-day, v-month-chars, string( month( p-last-date ), "99" ) )
                    v-bge-xml-bgeflnm-day = replace( v-bge-xml-bgeflnm-day, v-year-chars , substring( string( year( p-last-date ), "9999" ), 3, 2 ) )
                    v-bge-xml-bgeflnm-day = replace( v-bge-xml-bgeflnm-day, v-db-num-chars, v-db-num-str )
                .
            end.        /* NOT ( if v-bgeflnm = ? ) */
        end.        /* if v-bge-xml-bgeflold = "var" */
    end.        /* if p-last-date <> ? */
end.
end procedure. /* bge-xml-read-config */

/*==========================================================================*/
procedure bge-xml-get-ref-filename :
define input parameter p-in-file-name       as character        no-undo.
define output parameter p-home-dir          as character        no-undo.
define output parameter p-out-file-name     as character        no-undo.
define output parameter p-locked            as logical          no-undo.

    define variable v-counter       as integer      no-undo.
    define variable v-error-level   as integer      no-undo.
do
on error undo, return error
:
    run bge/bge-ini.p (
          input "bge"
        , output p-home-dir
    ).
    if return-value <> "OK"
    then do:
        undo, return error.
    end.
    assign
        p-home-dir = p-home-dir + "\dict":U
    .
    /* удостовериться, что директория $FRG-ACC/{&SubDir} создана */
    run bge/dir_cd.p (
        input p-home-dir
        , input "CA"
    ).
    if return-value = "ERROR"
    then do:
        undo, return error.
    end.
    assign
        p-out-file-name = substitute( "&1\&2.", p-home-dir, p-in-file-name )
    .

    /* найти исходный файл */
    assign
        p-locked = ( search( p-out-file-name + "xml" ) <> ? ).
    .
    /* найти файл блокировки */
    wait-lock:
    do v-counter = 1 TO 3
    :
        p-locked = ( search( p-out-file-name + "lk" ) <> ? ).
        if p-locked = no
        then do:
            leave wait-lock.
        end.
        else do:
            readkey pause 1.
        end.
    END.
    if p-locked = yes
    then do:
        undo, return error.
    end.
    /* удалить старый файл */
    run bge/os_copy.p (
          input "D":U
        , input p-out-file-name + "xml":U
        , input "":U
        , output v-error-level
    ).
    if v-error-level > 0
    then do:
        undo, return error.
    end.

end.
end procedure. /* bge-xml-get-ref-filename */


/*==========================================================================*/
procedure bge-xml-write-ref-header :
define input parameter p-bge-name as character        no-undo.
define input parameter p-file-name as character        no-undo.

    define variable v-out-string    as character    no-undo.
do
on error undo, return error
:
    output stream stmXMLOut to value( p-file-name + "xm1") convert target "1251".
    put stream stmXMLOut unformatted
        "<?xml version='1.0' encoding='windows-1251'?>":U
    .
    /*PUT STREAM stmXMLOut UNFORMATTED {&new-line} + '<?xml-stylesheet type="text/xsl" href="{&OutFileName}.xsl"?>'.*/

    assign
        v-out-string = substitute( "&1&2"
                            , {&new-line}
                            , "<IBS_Trade_House>":U )
    .
    put stream stmXMLOut unformatted
        v-out-string
    .
    run wp-XMLTagOpen( 1, "header", "" ).

    if v-bge-xml-bgeflold = "oracle":u
    then do:
      run wp-XMLTagOpen in this-procedure  ( 2, "delivery", "").
      run wp-XMLTagput in this-procedure ( 3, "message","", 1).
      run wp-XMLTagput in this-procedure ( 3, "from","IBS Trade House", 1).
      run wp-XMLTagput in this-procedure ( 3, "to","Oracle Retail", 1).
      run wp-XMLTagClose in this-procedure ( 2, "delivery"    ).
    end.
    else do:
      run wp-XMLTagOpen( 2, "delivery", "" ).
      run wp-XMLTagOpen( 3, "to", "" ).
      run wp-XMLTagClose( 3, "to" ).
      run wp-XMLTagOpen( 3, "from", "" ).
      run wp-XMLTagClose( 3, "from" ).
      run wp-XMLTagClose( 2, "delivery" ).
    end.

    run wp-XMLTagOpen( 2, "manifest", "" ).
    run wp-XMLTagOpen( 3, "document", "" ).
    run wp-XMLTagPut( 4, "name", p-bge-name, 0 ).
    run wp-XMLTagPut( 4, "description", "", 0 ).
    run wp-XMLTagClose( 3, "document" ).
    run wp-XMLTagClose( 2, "manifest" ).
    run wp-XMLTagClose( 1, "header" ).
    run wp-XMLTagOpen( 1, "body", "" ).
end.
end procedure. /* bge-xml-write-ref-header */

/*==========================================================================*/
procedure bge-xml-write-ref-footer :
define input parameter p-file-name as character        no-undo.

    define variable v-error-level   as integer      no-undo.
do
on error undo, return error
:
    run wp-XMLTagClose in this-procedure ( input 1, input "body":U ).
    run wp-XMLTagClose in this-procedure ( input 0, input "IBS_Trade_House":U ).

    output stream stmXMLOut close.

    /*- переименовать: .xm1 -> .xml -*/
    run bge/os_copy.p (
          input "M":U
        , input p-file-name + "xm1":U
        , input p-file-name + "xml":U
        , output v-error-level
    ).
    if v-error-level > 0
    then do:
        undo, return error.
    end.
end.
end procedure. /* bge-xml-write-ref-footer */

/*==========================================================================*/
procedure bge-xml-out-dir :
define output parameter p-out-dir       as character    no-undo.
define output parameter p-log-file-name as character    no-undo.

do
on error undo, return error
:
    p-out-dir = ibs.th.gbl.gbl-inipar:dirfrgAcc .
    if p-out-dir = ?
    then do:            /* нет ключа */
        message
          skip substitute("Не найден параметр ini-файла, определяющий каталог экспорта (&1)."
                        , ibs.th.gbl.gbl-inipar:dirfrgAccKeyName)
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if v-bge-xml-bgeflold <> "oracle" then assign
      p-out-dir = substitute( "&1&2exp-acc":U, p-out-dir, {&slash-char} )
    .
    run gbl/dir-cre.p ( input p-out-dir ) no-error.
    if error-status :error  then do:
        run wp-XMLWriteLog in this-procedure (
              input p-log-file-name
            , input 0
            , input substitute( "Ошибка проверки или создания каталога &1. &2. &3."
                                , p-out-dir
                                , return-value
                                , trim( error-status :get-message( 1 ) )
                                )
        ).
        undo, return error.
    end.
    assign
        v-bge-xml-static-log-file-name = substitute( "&1&2actions.log":U, p-out-dir, {&slash-char} )
        p-log-file-name                = substitute( "&1&2actions.log":U, p-out-dir, {&slash-char} )
    .
end.
end procedure. /* bge-xml-out-dir */
procedure bge-xml-out-dir2 :
/* тоже самое, плюс дополнительно директория для выгрузки реестра */
define output parameter p-out-dir       as character    no-undo.
define output parameter p-out-dirR      as character    no-undo.
define output parameter p-log-file-name as character    no-undo.

do
on error undo, return error
:
    p-out-dir = ibs.th.gbl.gbl-inipar:dirfrgAcc .
    if p-out-dir = ?
    then do:            /* нет ключа */
        message
          skip substitute("Не найден параметр ini-файла, определяющий каталог экспорта (&1)."
                        , ibs.th.gbl.gbl-inipar:dirfrgAccKeyName)
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if v-bge-xml-bgeflold <> "oracle" then assign
          p-out-dirR = substitute( "&1&2exp-reestr":U, p-out-dir, {&slash-char} )
          p-out-dir  = substitute( "&1&2exp-acc":U,    p-out-dir, {&slash-char} )
      .
    else p-out-dirR = p-out-dir .
    run gbl/dir-cre.p ( input p-out-dir ) no-error.
    if error-status :error  then do:
        run wp-XMLWriteLog in this-procedure (
              input p-log-file-name
            , input 0
            , input substitute( "Ошибка проверки или создания каталога &1. &2. &3."
                                , p-out-dir
                                , return-value
                                , error-status :get-message( 1 )
                                )
        ).
        undo, return error.
    end.
    if p-out-dirR <> p-out-dir then do:
      run gbl/dir-cre.p ( input p-out-dirR ) no-error.
      if error-status :error then do:
        run wp-XMLWriteLog in this-procedure (
              input p-log-file-name
            , input 0
            , input substitute( "Ошибка проверки или создания каталога &1. &2. &3."
                                , p-out-dirR
                                , return-value
                                , error-status :get-message( 1 )
                                )
        ).
        p-out-dirR = p-out-dir .
      end.
    end .
    assign
      v-bge-xml-static-log-file-name = substitute( "&1&2actions.log":U, p-out-dir, {&slash-char} )
      p-log-file-name                = substitute( "&1&2actions.log":U, p-out-dir, {&slash-char} )
    .
end.
end procedure. /* bge-xml-out-dir2 */


procedure bge-xml-out-file :
do
on error undo, return error
:
define input parameter p-out-dir            as character        no-undo.
define input parameter p-prefix             as character        no-undo.
define input parameter p-sheduled           as logical          no-undo.
define output parameter p-xml-file-name     as character        no-undo.
define output parameter p-locked            as logical          no-undo.

define variable v-home-dir      as character     no-undo.
define variable v-error-num     as integer       no-undo.
define variable v-today             as date         no-undo.
define variable v-time              as integer      no-undo.

    if v-bge-xml-bgefmt = "dbf":U
    then do:        /* Выгрузка каждого документа ведётся в отдельный файл. Нужна только проверка каталога */
        assign
            p-xml-file-name = p-out-dir
            p-locked        = no
        .
    end.        /* if v-bge-xml-bgefmt = "dbf":U */
    else do:
        if v-bge-xml-bgeflold = "firm":U
        then do:
            run bge/genfname.p (
                  input p-out-dir
                , input p-prefix
                , input "":U
                , input "arj":U
                , input "":U
                , output p-xml-file-name
            ).
        end.        /* if v-bge-xml-bgeflold = "firm":U */
        else do:
            run bge/genfname.p (
                  input p-out-dir
                , input p-prefix
                , input "":U
                , input "xml":U
                , input "":U
                , output p-xml-file-name
            ).
        end.        /* NOT ( if v-bge-xml-bgeflold = "firm":U ) */
        assign
            p-xml-file-name = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
            p-locked = ( search ( p-xml-file-name + "lk":U ) <> ? )
        .
    end.        /* NOT ( if v-bge-xml-bgefmt = "dbf":U ) */
end.
end procedure. /* bge-xml-out-file */

/*==========================================================================*/
procedure bge-xml-init-ext-doc-type :

    define variable v-counter    as integer      no-undo.

    define buffer buf_temp_ext-doc-type     for temp_ext-doc-type.
do
for buf_temp_ext-doc-type
on error undo, return error
:
    empty temp-table buf_temp_ext-doc-type.
    do v-counter = 1 to num-entries( {&TDEDT_List} )
    :
        create buf_temp_ext-doc-type.
        assign
            buf_temp_ext-doc-type.edt-key               = v-counter
            buf_temp_ext-doc-type.ext-doc-type          = entry( v-counter, {&TDEDT_List} )
            buf_temp_ext-doc-type.ext-doc-type-label    = entry( v-counter, {&TDEDT_List-full} )
        .
    end.        /* do */
end.
end procedure. /* bge-xml-init-ext-doc-type */

/*==========================================================================*/
procedure bge-xml-get-decimal-shift-num :
define input parameter p-shift-date     as date             no-undo.
define input parameter p-shift-num      as integer          no-undo.
define output parameter p-shift-decimal as decimal          no-undo.

do
on error undo, return error
:
    assign
        p-shift-decimal = ( p-shift-date - 01/01/1990 ) + truncate( p-shift-num / 1000, 3 )
    .
end.
end procedure. /* get-decimal-shift-num */

/*==========================================================================*/
procedure bge-xml-ora-exp-filename :
  define input  parameter p-table-name  as character no-undo .
  define input  parameter p-doc-code    as character no-undo .
  define input  parameter p-obj-code    as integer   no-undo .
  define output parameter p-filename    as character no-undo .
  define output parameter p-seq-num     as integer   no-undo .

  define variable v-ora-exp-seq     as integer   no-undo .
  define variable v-ora-exp-seq-str as character no-undo .
  define variable v-home-dir        as character no-undo.

do
on error undo, return error return-value
:

  if v-bge-xml-bgeflold = "oracle":u
  then do:
    get-key-value section "BGE" key "Dirfrg-acc" value v-home-dir.
    if v-home-dir = ?
    then do:            /* нет ключа */
      undo, return error substitute( "&1&2&3":U
                                    , "Не найден параметр ini-файла, определяющий каталог экспорта.":U
                                    , {&new-line}
                                    , "Обратитесь к администратору.":U
                                    ).
    end.
    assign
        v-home-dir = v-home-dir
    .
    run gbl/dir-cre.p ( input v-home-dir ) no-error.
    if error-status :error
    then do:
      undo, return error substitute( "&1&2&3":U
                                    , "Неверно задан каталог экспорта.":U
                                    , {&new-line}
                                    , "Обратитесь к администратору.":U
                                    ).
    end.
    assign
      v-ora-exp-seq = ?
    .

    if  p-table-name <> ? and
        p-doc-code <> ?
    then do:
      /* ищем номер пакета - вдруг выгрузка повторная */
      run bge/get-oesq.p ( input p-table-name
                         , input p-doc-code
                         , output v-ora-exp-seq
                         ) no-error .
      if error-status :error = yes
      then do:
        undo, return error return-value .
      end.
    end.
    /* если номера нет, то береем новый */
    if v-ora-exp-seq = ?
    then do:
      run bge/oesq-get.p ( output v-ora-exp-seq ) no-error .
      if error-status :error
      then do:
        undo, return error return-value .
      end.
    end.
    if p-table-name <> ? and
       p-doc-code   <> ?
    then do:
      /* сразу закрепляем номер пакета за документом */
      run bge/oesqdoc.p ( input p-table-name
                        , input p-doc-code
                        , input v-ora-exp-seq
                        ) no-error .
      if error-status :error = yes
      then do:
        undo, return error return-value .
      end.
    end.
    assign
      p-seq-num  = v-ora-exp-seq
      p-filename = substitute("&1/&2-000_&3."
                             , v-home-dir
                             , ( if p-obj-code < 1000 then string( p-obj-code, "999") else string(p-obj-code))
                             , string(v-ora-exp-seq , "999999999")
                             )
    .
  end.
end.

end procedure. /* bge-xml-ora-exp-filename */

/*==========================================================================*/
procedure bge-xml-date-to-str :
  define input  parameter p-date  as date      no-undo .
  define output parameter p-str   as character no-undo .
do
on error undo, return error return-value
:
  if p-date <> ?
  then do:
    assign
      p-str = substitute( "&1-&2-&3"
                        , string( year(p-date)  , "9999")
                        , string( month(p-date) , "99"  )
                        , string( day(p-date)   , "99"  )
                        )
    .
  end.
  else do:
    assign
      p-str = ?
    .
  end.
end.

end procedure. /* bge-xml-date-to-str */

/*==========================================================================*/
procedure bge-xml-date-str-to-str :
  define input  parameter p-date-str  as character no-undo .
  define output parameter p-str       as character no-undo .

  define variable v-date          as date      no-undo .
  define variable v-date-valid    as logical   no-undo .
  define variable v-error-message as character no-undo .
do
on error undo, return error return-value
:
  assign
    p-str = ?
  .
  if p-date-str = ? or p-date-str = ""
  then do:
    return . /* --->>>--- */
  end.
  run strtdate in this-procedure ( input  p-date-str
                                 , output v-date
                                 , output v-date-valid
                                 , output v-error-message
                                 ).
  if v-date-valid <> true
  then do:
    return . /* --->>>--- */
  end.
  assign
    p-str = substitute( "&1-&2-&3"
                      , string( year(v-date)  , "9999")
                      , string( month(v-date) , "99"  )
                      , string( day(v-date)   , "99"  )
                      )
  .
end.
end procedure. /* bge-xml-date-str-to-str */

/*==========================================================================*/
/* 03/IX-2018 встроена внутрь функции bge-xml-normalize-dec()
procedure bge-xml-proc-normalize-dec :
  define input  parameter p-val-in  as decimal   no-undo .
  define output parameter p-val-out as decimal   no-undo .
do
on error undo, return error return-value
:
  assign
    p-val-out = if p-val-in = ? then 0 else p-val-in
  .
end.

end procedure. /* bge-xml-proc-normalize-dec */
*/
/*==========================================================================*/
procedure bge-xml-fill-tt-bgecliiv :
  define input  parameter p-str as character no-undo . /*строка в формате "тип,код;тип,код" */

  define buffer buf_tt-bge-xml-bgecliiv for tt-bge-xml-bgecliiv.
  define buffer buf_clients             for ub.clients.

  define variable v-i         as integer   no-undo .
  define variable v-count     as integer   no-undo .
  define variable v-cli-count as integer   no-undo .
  define variable v-client    as character no-undo .
  define variable v-obj-type  as character no-undo .
  define variable v-obj-code  as integer   no-undo .

do
on error undo, return error return-value
:
  empty temp-table buf_tt-bge-xml-bgecliiv.

  assign
    v-bge-xml-bgecliiv = no
    v-cli-count        = num-entries(p-str,';')
  .

  if v-cli-count > 0
  then do:
    _cli-cycle:
    do v-i = 1 to v-cli-count
    :
      assign
        v-client = entry(v-i , p-str, ';')
      .
      if num-entries(v-client) <> 2
      then do:
        undo, return error substitute("Неправильный формат записи контрагента в параметре 'bgecliiv'. Позиция записи &1." , v-i).
      end.
      assign
        v-obj-type = entry(1, v-client)
      .
      assign
        v-obj-code = integer(entry(2, v-client))
      no-error .
      if error-status :error
      then do:
        undo, return error substitute("Неправильный формат записи кода контрагента в параметре 'bgecliiv'. Позиция записи &1." , v-i).
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = v-obj-type
          and buf_clients.obj-code = v-obj-code
      no-error.
      if not available buf_clients
      then do:
        next _cli-cycle.
      end.
      find first buf_tt-bge-xml-bgecliiv no-lock
        where buf_tt-bge-xml-bgecliiv.obj-type = buf_clients.obj-type
          and buf_tt-bge-xml-bgecliiv.obj-code = buf_clients.obj-code
      no-error .
      if available buf_tt-bge-xml-bgecliiv
      then do:
        next _cli-cycle.
      end.
      create buf_tt-bge-xml-bgecliiv.
      assign
        buf_tt-bge-xml-bgecliiv.obj-type = buf_clients.obj-type
        buf_tt-bge-xml-bgecliiv.obj-code = buf_clients.obj-code
      .
    end. /* _cli-cycle: */
  end.
  else do:
    assign
      v-bge-xml-bgecliiv = no
    .
    return . /* --->>>--- */
  end.

  /* если есть записи, то устанавливаем флаг параметра */
  find first buf_tt-bge-xml-bgecliiv no-lock no-error .
  if available buf_tt-bge-xml-bgecliiv
  then do:
    assign
      v-bge-xml-bgecliiv = yes
    .
  end.
end.

end procedure. /* bge-xml-fill-tt-bgecliiv */

/*==========================================================================*/
/*
  Для определенных контрагентов маскируем расширеный тип документа
*/
/*==========================================================================*/
procedure bge-xml-resolve-ext-doc-type :
  define input  parameter p-ext-doc-type      as character no-undo .
  define input  parameter p-obj-type          as character no-undo .
  define input  parameter p-obj-code          as integer   no-undo .
  define output parameter p-out-ext-doc-type  as character no-undo .

  define buffer buf_tt-bge-xml-bgecliiv for tt-bge-xml-bgecliiv.
do
on error undo, return error return-value
:
  assign
    p-out-ext-doc-type = p-ext-doc-type
  .
  /* конвертируем только внешние приходы */
  if p-ext-doc-type <> {&TDEDT_Pri_Vnesh}
  then do:
    return . /* --->>>--- */
  end.
  if v-bge-xml-bgecliiv = yes
  then do:
    find first buf_tt-bge-xml-bgecliiv no-lock
      where buf_tt-bge-xml-bgecliiv.obj-type = p-obj-type
        and buf_tt-bge-xml-bgecliiv.obj-code = p-obj-code
    no-error .
    if available buf_tt-bge-xml-bgecliiv
    then do:
      assign
        p-out-ext-doc-type = {&TDEDT_Pri_Perem}
      .
    end.
  end.

end.
end procedure. /* resolve-ext-doc-type */

/*
  Процедура открытия тега не влияющая на схему ORA
*/
/* 03/IX-2018 - не используется
procedure safe-wp-xmltagopen :
  define input  parameter pTagLevel as integer   no-undo .
  define input  parameter pTagName  as character no-undo .
  define input  parameter pParValue as character no-undo .

do
on error undo, return error return-value
:
  if v-bge-xml-bgeflold = "oracle":u
  then do:
    return . /* --->>>--- */
  end.
  run wp-xmltagopen in this-procedure ( input pTagLevel
                                      , input pTagName
                                      , input pParValue
                                      ) .
end.
end procedure. /* safe-wp-xmltagopen */
*/

/*
  Процедура вывода тега не влияющая на схему ORA
*/
procedure safe-wp-xmltagput :
  define input  parameter pTagLevel   as integer   no-undo .
  define input  parameter pTagName    as character no-undo .
  define input  parameter pParValue   as character no-undo .
  define input  parameter pFlagEmpty  as integer   no-undo .

do
on error undo, return error return-value
:
  if v-bge-xml-bgeflold = "oracle":u
  then do:
    return . /* --->>>--- */
  end.
  run wp-xmltagput in this-procedure ( input pTagLevel
                                     , input pTagName
                                     , input pParValue
                                     , input pFlagEmpty
                                     ).
end.

end procedure. /* safe-wp-xmltagput */

/*
  Процедура закрытия тега не влияющая на схему ORA
*/
/* 03/IX-2018 - не используется
procedure safe-wp-xmltagclose :
  define input  parameter pTagLevel as integer   no-undo .
  define input  parameter pTagName  as character no-undo .

do
on error undo, return error return-value
:
  if v-bge-xml-bgeflold = "oracle":u
  then do:
    return . /* --->>>--- */
  end.
  run wp-xmltagclose in this-procedure ( input pTagLevel
                                       , input pTagName
                                       ).
end.

end procedure. /* safe-wp-xmltagclose */
*/

/* $Workfile$ e n d */