/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для работы с форматом XML и выводом в LOG и EDITOR

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 09/15/05
Author: Victor Guntner
Creation date: 09/15/05

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&SCOP TabSpaces 4
&SCOP LogLineSize 80

DEF STREAM stmXMLHead.
DEF STREAM stmXMLBody.
DEF STREAM stmXMLLog.

{ gbl/cur-time.i }
{ gbl/xmlchar.i  }

&global-define back-slash-char chr(92)

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
      IF iFlagEmpty = 0 THEN RETURN "".
      ELSE IF iFlagEmpty = 1                    THEN RETURN sParName + "=&#034;&#034;".
      ELSE IF iFlagEmpty = 2 AND sToPlace = "0" THEN RETURN sParName + "=&#034;0&#034;".
      ELSE IF iFlagEmpty = 3 AND sToPlace = ""  THEN RETURN sParName + "=&#034;&#034;".
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

/*========================================================================*/
PROCEDURE wp-XMLTagOpen:
  DEF INPUT PARAM iStmNum   AS INTEGER NO-UNDO.
  DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
  DEF INPUT PARAM sTagName  AS CHAR NO-UNDO.
  DEF INPUT PARAM sParValue AS CHAR NO-UNDO.
/*  Процедура открывает тэг
    iTagLevel - условный уровень тэга (количество пробелов от начала файла * {&TabSpaces})
    sTagName - имя тэга
    sParValue - заполнитель параметров тэга,
        может передавать значения типа 'Адрес="ул. Салтыкова"'
*/
    run xmlchar-encode in this-procedure (
          input sParValue
        , output sParValue
    ).
   if istmnum = 1
   then do:
        PUT STREAM stmXMLHead UNFORMATTED {&new-line} + FILL(" ", {&TabSpaces} * iTagLevel) +
                        "<" + sTagName + (IF sParValue = "" OR sParValue = ? then "" ELSE " ") +
                        sParValue + ">".
   end.
   else do:
        PUT STREAM stmXMLBody UNFORMATTED {&new-line} + FILL(" ", {&TabSpaces} * iTagLevel) +
                        "<" + sTagName + (IF sParValue = "" OR sParValue = ? then "" ELSE " ") +
                        sParValue + ">".
   end.

END PROCEDURE.

/*========================================================================*/
PROCEDURE wp-XMLTagPut:
  DEF INPUT PARAM iStmNum   AS INTEGER NO-UNDO.
  DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
  DEF INPUT PARAM sTagName AS CHAR NO-UNDO.
  DEF INPUT PARAM sParValue AS CHAR NO-UNDO.
  DEF INPUT PARAM iFlagEmpty AS INTEGER NO-UNDO.
/*  Процедура создает закрытый тэг, заполняя его значением из sParValue
    iTagLevel - условный уровень тэга (количество пробелов от начала файла * {&TabSpaces})
    sTagName - имя тэга
    sParValue - текст, который нужно вписать между тэгами последнего уровня.
        можно передавать значения типа 'Адрес="ул. Салтыкова"'
    iFlagEmpty - что делать, если sParValue=? или sParValue="":U
        0  или любое из не перечисленных - не выводить ничего
        1 - выводить начало и конец тэга
        2 - то же, что и 0, но ничего не выводит и в случае sParValue = "0"
        3 - то же, что и 0, но ничего не выводит и в случае sParValue = "Yes"
*/
   if istmnum = 1
   then do:
        IF  iFlagEmpty = 1
        OR (iFlagEmpty = 0 AND (sParValue <> "" AND sParValue <> ?) )
        OR (iFlagEmpty = 2 AND (sParValue <> "" AND sParValue <> ? AND sParValue <> "0"))
        OR (iFlagEmpty = 3 AND (sParValue <> "" AND sParValue <> ? AND CAPS(sParValue) <> "NO"))
        THEN DO:
            run xmlchar-encode in this-procedure (
                  input sParValue
                , output sParValue
            ).
            PUT STREAM stmXMLHead UNFORMATTED {&new-line} + FILL(" ", {&TabSpaces} * iTagLevel) +
                                '<' + sTagName + '>' + sParValue + '</' + sTagName + '>'.
        END.
   end.
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
            PUT STREAM stmXMLBody UNFORMATTED {&new-line} + FILL(" ", {&TabSpaces} * iTagLevel) +
                                '<' + sTagName + '>' + sParValue + '</' + sTagName + '>'.
        END.
   end.

END PROCEDURE.

/*========================================================================*/
PROCEDURE wp-XMLTagClose:
  DEF INPUT PARAM iStmNum   AS INTEGER NO-UNDO.
  DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
  DEF INPUT PARAM sTagName AS CHAR NO-UNDO.
/*  Процедура закрывает тэг
    iTagLevel - условный уровень тэга (количество пробелов от начала файла * {&TabSpaces})
    sTagName - имя тэга
*/

   if istmnum = 1
   then do:
        PUT STREAM stmXMLHead UNFORMATTED  {&new-line} + FILL(" ", 4 * iTagLevel) + '</' + sTagName + '>'.
   end.
   else do:
        PUT STREAM stmXMLBody UNFORMATTED {&new-line} + FILL(" ", 4 * iTagLevel) + '</' + sTagName + '>'.
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

OUTPUT STREAM stmXMLLog TO VALUE(sFileName) APPEND.
    PUT STREAM stmXMLLog UNFORMATTED {&new-line}.
    PUT STREAM stmXMLLog UNFORMATTED (IF (iLogLevel = 0 OR sToWrite = "&DLine"
                                      OR sToWrite = "&Line") THEN "" ELSE
                                      cur-time-string-sec() + " ").
    PUT STREAM stmXMLLog UNFORMATTED
            (IF sToWrite = "&Line" THEN FILL("-", {&LogLineSize})
             ELSE IF sToWrite = "&DLine" THEN FILL("=", {&LogLineSize})
             ELSE sToWrite).
OUTPUT STREAM stmXMLLog CLOSE.

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
procedure rcs-xml-write-header:
do
on error undo, return error
:
define input parameter p-num-tables         as integer      no-undo.
define input parameter p-xml-file-name-head as character    no-undo.
define input parameter p-table-id-head      as character    no-undo.
define input parameter p-xml-file-name-body as character    no-undo.
define input parameter p-table-id-body      as character    no-undo.

    define variable v-reportnumber          as integer      no-undo.

    run get-next-reportnumber in this-procedure (
        output v-reportnumber
    ) no-error.
    if error-status :error
    then do:
        assign
            v-reportnumber = 0
        .
    end.
    output stream stmXMLHead to value( p-xml-file-name-head + ".xm1" ) convert target "1251".
        put stream stmXMLHead unformatted "<DESTINATION_ROID " + p-table-id-head + ">".
        run wp-xmltagopen( 1, 0, "mail Parameters","").
        run wp-xmltagput( 1, 1, "X-ReportType",    string( 1 ), 0).
        run wp-xmltagput( 1, 1, "X-IDChannel",     string( 3 ), 0).
        run wp-xmltagput( 1, 1, "X-ReportNumber",  string( v-reportnumber ), 0).
        run wp-xmltagclose( 1, 0, "mail Parameters").
        put stream stmXMLHead unformatted skip "<ROWSET>".
    output stream stmXMLHead close.
    if p-num-tables > 1
    then do:
        output stream stmXMLBody to value( p-xml-file-name-body + ".xm1" ) convert target "1251".
            put stream stmXMLBody unformatted "<DESTINATION_ROID " + p-table-id-body + ">".
            run wp-xmltagopen( 2, 0, "mail Parameters","").
            run wp-xmltagput( 2, 1, "X-ReportType",    string( 1 ), 0).
            run wp-xmltagput( 2, 1, "X-IDChannel",     string( 3 ), 0).
            run wp-xmltagput( 2, 1, "X-ReportNumber",  string( v-reportnumber ), 0).
            run wp-xmltagclose( 2, 0, "mail Parameters").
            put stream stmXMLBody unformatted skip "<ROWSET>".
        output stream stmXMLBody close.
    end.
end.
end procedure.


/*========================================================================*/
procedure rcs-xml-write-footer:
do
on error undo, return error
:
define input parameter p-num-tables         as integer      no-undo.
define input parameter p-xml-head-file-name as character    no-undo.
define input parameter p-xml-body-file-name as character    no-undo.

    define variable v-error-num     as integer           no-undo.
    output stream stmXMLHead to value( p-xml-head-file-name + ".xm1" ) convert target "1251" append.
       put stream stmXMLHead unformatted skip "</ROWSET>" {&new-line}.
    output stream stmXMLHead close.
    if p-num-tables > 1
    then do:
        output stream stmXMLBody to value( p-xml-body-file-name + ".xm1" ) convert target "1251" append.
            put stream stmXMLBody unformatted skip "</ROWSET>" {&new-line}.
        output stream stmXMLBody close.
    end.
end.
end procedure.

/*==========================================================================*/
function format-decimal returns character ( input p-decimal as decimal ).
    if p-decimal = ?
    then do:
        return "?".
    end.
    else do:
        if abs( p-decimal ) < 1
        then do:
            return right-trim( string( p-decimal, "-9.9999999999" ), "0" ).
        end.
        else do:
            return string( p-decimal ).
        end.
    end.
end function. /* format-decimal */

/*==========================================================================*/
procedure get-next-reportnumber :
do
on error undo, return error
:
define output parameter p-reportnumber as integer      no-undo.

    define buffer buf_usr-flt       for ubflt.usr-flt.

    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name  = {&all}
           and buf_usr-flt.call-point = {&sht-current}
    no-error .
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name    = {&all}
            buf_usr-flt.call-point   = {&sht-current}
            buf_usr-flt.Naim = "1"
        .
    end.
    assign
        p-reportnumber   = integer( buf_usr-flt.Naim )
        buf_usr-flt.Naim = string( p-reportnumber + 1 )
    .
end.
end procedure. /* get-next-reportnumber */

/* $Workfile$ e n d */