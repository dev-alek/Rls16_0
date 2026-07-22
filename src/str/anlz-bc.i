/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Описание временных таблиц для разборщика бар-кодов

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
9 Dec 1999


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE TEMP-TABLE in-bc NO-UNDO
     FIELD nm        as INTEGER       /*строка по порядку                               */
     FIELD bar-str   AS CHARACTER     /*входящая строка для разбора                     */
     FIELD bar-code  as CHARACTER     /*входящий бар-код                                */
     FIELD rez       as CHARACTER     /*результат анализа                               */
     FIELD err-msg   as CHARACTER     /*сообщения об ошибках и предупреждениях          */
     FIELD des       as CHARACTER     /*описание которое ляжет в log-file               */
     INDEX pi IS PRIMARY nm.
&IF "{1}" = "" &THEN
DEFINE OUTPUT PARAMETER TABLE FOR in-bc.
&ENDIF
/*объедененные бар-коды из загружаемых файлов*/
DEFINE {1} SHARED TEMP-TABLE un-bc NO-UNDO
     FIELD nm             as INTEGER       /*строка по порядку                                */
     FIELD bar-code       as CHARACTER     /*входящий бар-код                                 */
     FIELD entity         as character     /*сущность: товар, признак, партия, складское место*/
     FIELD b-c            as INTEGER       /*собственный бар-код                              */
     FIELD rate           as DECIMAL       /*коэффициент пересчета*/
     FIELD TYPE-bc        as CHARACTER     /*тип бар-кода*/
     FIELD wt             as DECIMAL       /*вес*/
     FIELD file-qnty      as decimal       /*кол-во пришедшее из последнего загруженого файла */
     FIELD scn-qnty       as DECIMAL       /*кол-во                                           */
     FIELD scn-pl         as CHARACTER     /*складское место                                  */
     /*Общеинформационные поля предназначенные для создания информационного экрана по бар-коду*/
     /*товар*/
     FIELD artic          LIKE ub.goods.artic
     FIELD prod-type      LIKE ub.goods.prod-type
     FIELD prod-code      LIKE ub.goods.prod-code
     FIELD gds-name       LIKE ub.goods.gds-name
     FIELD prod-name      LIKE ub.clients.obj-name
     FIELD unit-base      LIKE ub.goods.unit-base
     FIELD units-type     LIKE ub.units.type
     /*признак*/
     FIELD f-name         LIKE ub.gds-prt.f-name
     /*партия*/
     FIELD in-code        LIKE ub.parts.in-code       /*номер внешней приходной накладной*/
     FIELD fact-date      LIKE ub.parts.fact-date     /*дата внешней приходной накладной*/
     FIELD part-code      LIKE ub.parts.part-code     /*код партии*/
     /*дополнительные поля*/
     FIELD rez            as CHARACTER             /*результат анализа                     */
     FIELD err-msg        as CHARACTER             /*сообщения об ошибках и предупреждениях*/
     FIELD des            as CHARACTER             /*описание данного бар-кода             */
     /*складские места*/
     FIELD pl-name        AS CHARACTER
     FIELD loc1           AS CHARACTER
     FIELD loc2           AS CHARACTER
     FIELD loc3           AS CHARACTER
     FIELD loc4           AS CHARACTER
     /*описание единицы измерения бар-кода*/
     FIELD unit-name      LIKE ub.units.unit-name
     FIELD long-name      LIKE ub.units.long-name
     /*основной бар-код*/
     FIELD b-c-base       LIKE ub.bar-code.b-code
     FIELD unit-name-base LIKE ub.units.unit-name
     FIELD long-name-base LIKE ub.units.long-name
     INDEX pi IS PRIMARY  nm
     INDEX bar-code bar-code
     INDEX b-c b-c
     INDEX file-qnty file-qnty.
/*исходящие проанализированные бар-коды*/
DEFINE {1} SHARED TEMP-TABLE anlz-bc NO-UNDO
     FIELD nm       as INTEGER              /*строка по порядку                               */
     FIELD b-c      as integer              /*бар-код                                         */
     FIELD scn-qnty as DECIMAL              /*кол-во                                          */
     FIELD scn-pl   as CHARACTER            /*складское место                                 */
     FIELD rez      as CHARACTER            /*результат анализа                               */
     FIELD err-msg  as CHARACTER            /*сообщения об ошибках и предупреждениях          */
     FIELD des      as CHARACTER            /*описание данного бар-кода                       */
     FIELD upd-line as logical initial no   /*если линия редактировалась руками*/
     INDEX pi IS PRIMARY nm
     INDEX b-c b-c.
DEFINE {1} SHARED TEMP-TABLE main-bc NO-UNDO
     FIELD nm       as INTEGER              /*строка по порядку                               */
     FIELD b-c      as integer              /*бар-код                                         */
     FIELD scn-qnty as DECIMAL              /*кол-во                                          */
     FIELD scn-pl   as CHARACTER            /*складское место                                 */
     FIELD rez      as CHARACTER            /*результат анализа                               */
     FIELD des      as CHARACTER            /*описание данного бар-кода                       */
     INDEX pi IS PRIMARY nm
     INDEX b-c b-c.

/* $Workfile$ */