/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Закачка в накладную - сообщение

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 10/30/02 11:59

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&If "{1}"  <> "" &Then
message 123 vss-include-info{&vssseq} .
for each in-bc :
message   "in-bc" skip
       in-bc.nm "/*строка по порядку                               */  " skip
      in-bc.bar-str    "/*входящая строка для разбора                     */  " skip
      in-bc.bar-code   "/*входящий бар-код                                */  " skip
      in-bc.rez        "/*результат анализа                               */  " skip
      in-bc.err-msg    "/*сообщения об ошибках и предупреждениях          */  " skip
      in-bc.des        "/*описание которое ляжет в log-file               */  " skip
      .
end.

for each  un-bc :
message "/*объедененные бар-коды из загружаемых файлов*/  un-bc"                   skip
      un-bc.nm           " /*строка по порядку                                */  " skip
      un-bc.bar-code     " /*входящий бар-код                                 */  " skip
      un-bc.entity       "  /*сущность: товар, признак, партия, складское место*/ " skip
      un-bc.b-c          "  /*собственный бар-код                              */ " skip
      un-bc.rate         "  /*коэффициент пересчета                             */ " skip
      un-bc.TYPE-bc      "  /*тип бар-кода                                     */ " skip
      un-bc.wt           "  /*вес                                              */ " skip
      un-bc.file-qnty    "  /*кол-во пришедшее из последнего загруженого файла */ " skip
      un-bc.scn-qnty     "  /*кол-во                                           */ " skip
      un-bc.scn-pl       "  /*складское место                                  */ " skip
     "/*Общеинформационные поля предназначенные для создания информационного экрана по бар-коду*/" skip
     "/*товар*/                                                                                  " skip
      un-bc.artic                                                                                  skip
      un-bc.prod-type                                                                              skip
      un-bc.prod-code                                                                              skip
      un-bc.gds-name                                                                               skip
      un-bc.prod-name                                                                              skip
      un-bc.unit-base                                                                              skip
      un-bc.units-type                                                                             skip
     "/*признак*/ "                                                                                  skip
      un-bc.f-name                                                                                 skip
     "/*партия*/  "                                                                                  skip
      un-bc.in-code          " /*номер внешней приходной накладной*/"                                skip
      un-bc.fact-date        " /*дата внешней приходной накладной*/ "                                skip
      un-bc.part-code        " /*код партии*/      "                                                 skip
     "/*дополнительные поля*/ "                                                                      skip
      un-bc.rez                        " /*результат анализа                     */  "               skip
      un-bc.err-msg                    " /*сообщения об ошибках и предупреждениях*/  "               skip
      un-bc.des                        " /*описание данного бар-кода             */  "               skip
     "/*складские места*/"                                                                           skip
      un-bc.pl-name                                                                                skip
      un-bc.loc1                                                                                   skip
      un-bc.loc2                                                                                   skip
      un-bc.loc3                                                                                   skip
      un-bc.loc4                                                                                   skip
     "/*описание единицы измерения бар-кода*/"                                                       skip
      un-bc.unit-name                                                                              skip
      un-bc.long-name                                                                              skip
     "/*основной бар-код*/"                                                                          skip
      un-bc.b-c-base                                                                               skip
      un-bc.unit-name-base                                                                         skip
      un-bc.long-name-base                                                                         skip

      .
end.

/*исходящие проанализированные бар-коды*/
for each  anlz-bc :
message   "anlz-bc" skip
      anlz-bc.nm         " /*строка по порядку                               */"   skip
      anlz-bc.b-c        " /*бар-код                                         */"   skip
      anlz-bc.scn-qnty   " /*кол-во                                          */"   skip
      anlz-bc.scn-pl     " /*складское место                                 */"   skip
      anlz-bc.rez        " /*результат анализа                               */"   skip
      anlz-bc.err-msg    " /*сообщения об ошибках и предупреждениях          */"   skip
      anlz-bc.des        " /*описание данного бар-кода                       */"   skip
      anlz-bc.upd-line   " /*если линия редактировалась руками*/               "   skip

      .
end.

for each  main-bc :
message "main-bc"  skip
      main-bc.nm                  " /*строка по порядку                               */ "  skip
      main-bc.b-c                 " /*бар-код                                         */ "  skip
      main-bc.scn-qnty            " /*кол-во                                          */ "  skip
      main-bc.scn-pl              " /*складское место                                 */ "  skip
      main-bc.rez                 " /*результат анализа                               */ "  skip
      main-bc.des                 " /*описание данного бар-кода                       */ "  skip
      .
end.
&Endif
/* $Workfile$ e n d */