block-level on error undo, throw.
/*

$Revision: 1f78fe327cdf, 1091, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: ththgdsi.p $
$Archive: cmp/ththgdsi.p $

Импорт данных по товарам из системы TH старой версии

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/12/08
Author: Bakhtadze Natalya
Creation date: 12/12/08

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 1f78fe327cdf, 1091, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ththgdsi.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/ththgdsi.p $":U .
define variable vss-description as character no-undo init "Импорт данных по товарам из системы TH старой версии".
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Позволяет запрашивать информацию о текущей версии файла

Автор: Перваков Михаил Сергеевич
Дата создания: 01/01/01
Author: Mikhail Pervakov
Creation date: 01/01/01

Позволяет регистрировать запуск программ и выдавать информацию о параметрах запуска
Данный файл необходимо вставлять в составе блока, описывающего процедуру
сразу после определения параметров вызова процедуры
Пример:
  def var vss-revision    as character no-undo init "$Revision$":u .
  def var vss-author      as character no-undo init "$Author$":u .
  def var vss-date        as character no-undo init "$Date$":u .
  def var vss-workfile    as character no-undo init "$Workfile$":u .
  def var vss-archive     as character no-undo init "$Archive$":u .
  def var vss-description as character no-undo init "" .
  { cmp/vssrevis.i }
*/
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure. /* vss-get-info */
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
  
end procedure. /* vss-get-parameters */

define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .

procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure. /* vss-logevent */

assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
/* $Workfile$ e n d */
 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Глобальные переменные, определяющие самые основные параметры системы

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

Предназначен для использования в триггерах системы и системе новостей

Параметры:
{1}  new - для первого определения глобальных переменных
     пусто - для доступа к глобальным переменным

Примеры использования:
  { cmp/trg-def.i new }            - первое определение глобальных переменных
  { cmp/trg-def.i }                - стандартное включение

*/


/* Компиляторные константы, общие для всех программ */
/*

$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$
                                        
Файл глобальных определений

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

Этот файл сгенерирован автоматически
Все изменения необходимо вносить в файл str-glbl.p

*/


define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.

/* имена национальной валюты и её производных */
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Файл аббревиатур и различных склонений и спряжений национальной валюты
                            РУССКИЙ

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/



/* $Workfile$   E n d */
 
/* Имена таблиц БД */
/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Глобальные определения имен таблиц

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

Файл автоматически создается процедурой utl/gen-tbln.p

*/

/* $Workfile: $ e n d */

 
/* Разделитель для формирования уникального ключа записи *//* И ТОЛЬКО ДЛЯ ЭТОГО!!! *//* Разделитель для формирования замены delim-key  в key-rec уникального ключа записи *//* И ТОЛЬКО ДЛЯ ЭТОГО!!! *//* Разделитель полей при экспорте/импорте записей таблиц в пакеты СПН *//* И ТОЛЬКО ДЛЯ ЭТОГО!!! *//* Разделитель полей соответствия имен полей, меток и формата для показа изменнений исторических таблиц */

 

/* ссылка на библиотеку */
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/




define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .










/* $Workfile$ e n d */
 


/* -------------------------------------------------------------------------------------- */
/* ****************************** Система новостей ************************************** */
/* -------------------------------------------------------------------------------------- */
/* yes - данная сессия работает в автоматическом режиме */
define   shared variable g#auto as logical no-undo.
/* yes -- работает система новостей, нужно для WRITE-триггеров документов */
define   shared variable g#news as logical no-undo.
/* yes -- работает система OpenXML, в триггерах таблиц вызывается str/calloxml.p */
define   shared variable g#oxml as logical no-undo.

/* yes -- мы находимся в режиме экспорта или импорта из ВС */
define   shared variable g#esys as logical no-undo.
/* номер БД, откуда пришли новости */
/* изменяется только во время приема новостей и используется в триггерах */
define   shared variable g#news-source-db as integer no-undo.
/* изменяется только во время приема данных с ВС и используется в триггерах */
define   shared variable g#esys-source-esys as integer no-undo.

/* -------------------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------------------- */
/* ****************************** БД **************************************************** */
/* -------------------------------------------------------------------------------------- */
define   shared variable g#db-num as integer   no-undo . /* код текущей БД */
/* -------------------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------------------- */
/* ****************************** ПОЛЬЗОВАТЕЛЬ ****************************************** */
/* -------------------------------------------------------------------------------------- */
define   shared variable g#userid as character no-undo . /* идентификатор пользователя */
define   shared variable g#passwd as character no-undo . /* пароль пользователя        */
/* -------------------------------------------------------------------------------------- */
/* $Workfile$ e n d */
 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Виды внешних классификаторов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/01/07
Author: Bakhtadze Natalya
Creation date: 08/01/07

*/

define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".





/*ext-classif.classif-subject*/

/*ext-classif.classif-name*/



















/* extclass_extended-data-list */           /*Здесь можно размещать ТОЛЬКО ТЕ ТАБЛИЦЫ, которые НЕ СВЯЗАНЫ с физическими таблицами ТН (!), т.е. таблицы виртуальные, хранящие свои поля в таблице ext-classif, но которые нужно гонять по новостям и формировать историю.    Пояснение: процедура-триггер типа extclasw.p для записи в таблицу ub.ext-classif, до недавнего времени ВСЕГДА генерировала уникальный ключ (процедурой: gen-key-fv) с использованием физич. таблиц ТН. Данный список теперь используется для проверки и обхода процедуры gen-key-fv (в файле триггера extclasw.p)). */



/* $Workfile$ e n d */
 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временные атрибуты БД для утилиты НАРЗАН - нижняя версия 15.0

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/11/09
Author: Bakhtadze Natalya
Creation date: 01/11/09

*/

define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*----------------------------ВНИМАНИЕ!!!------------------------------------------------- */
/*значения атрибутов имеющих логический тип должны записываться в базу чисто как yes или no*/
/*все форматирование осуществлять на верхнем уровне                                        */


/* соответстие групп клиентов */


/* соответстие клиентов */


/* соответстие групп товаров */

/* соответстие товаров */


/* импортирвоаны  ДК */

/* ожидаемое кол-во  ДК */



/* соответстие  объектов */




/* импорт перецоенков */

/* импорт прих накл */





/* сюда добавлять новые параметры */




/* ------------------------------------------------------------------- */







procedure thth150-db-attr-code :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-type           as character no-undo . /* тип атрибута */
    define output parameter p-format         as character no-undo . /* формат атрибута */
    define output parameter p-label          as character no-undo . /* лабел атрибута */
    define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
    define output parameter p-output-display as logical   no-undo . /* виден в броусе */
    define output parameter p-other          as character no-undo . /* еще чего - нибудь */

    case p-code :
            when 'thth150-cli-grp':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие групп клиентов"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие групп клиентов"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-gds-grp':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие групп товаров"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие групп товаров"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-clients':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие клиентов"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие клиентов"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-goods':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие товаров"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие товаров"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-dis-card':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ ДК"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ ДК"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-qnty-dis-card':U then do:     assign     p-label = "Ожидаемое кол-во ДК"     p-type = 'I':U      p-format = "999,999,999"     p-label = "Ожидаемое кол-во ДК"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-shop':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие объeктов TH"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие объeктов TH"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-contract':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ договора и спецификации"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ договора и спецификации"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-price-doc':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ переоценки"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ переоценки"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-trn-doc':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ приходные накладные"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ приходные накладные"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.


      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.

procedure thth150-db-attr-tooltip :

  do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
            when 'thth150-cli-grp':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие групп клиентов для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие групп клиентов" .   end.
            when 'thth150-gds-grp':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие групп товаров для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие групп товаров" .   end.
            when 'thth150-clients':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие клиентов для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие клиентов" .   end.
            when 'thth150-goods':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие товаров для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие товаров" .   end.
            when 'thth150-dis-card':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ ДК"     p-label = "ИМПОРТИРОВАНЫ ДК" .   end.
            when 'thth150-qnty-dis-card':U then do:     assign     p-tooltip = "Ожидаемое кол-во ДК"     p-label = "Ожидаемое кол-во ДК" .   end.
            when 'thth150-shop':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие объeктов TH для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие объeктов TH" .   end.
            when 'thth150-contract':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ договора и спецификации для двух систем IBS TH"     p-label = "ИМПОРТИРОВАНЫ договора и спецификации" .   end.
            when 'thth150-price-doc':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ переоценки"     p-label = "ИМПОРТИРОВАНЫ переоценки" .   end.
            when 'thth150-trn-doc':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ приходные накладные"     p-label = "ИМПОРТИРОВАНЫ приходные накладные" .   end.





      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.

end procedure.


procedure thth150-db-attr-value :

  do
  on error undo, return error
  :
    define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
    define output parameter p-value     like ub.db-attr.attr-value no-undo .
    define output parameter p-type      as character no-undo .

    define buffer buf_db-attr for ub.db-attr .

    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run thth150-db-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if avail buf_db-attr then do:
      assign
        p-value =  buf_db-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.

end procedure.


procedure thth150-db-attr-write :

  do
  on error undo, return error
  :
    define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input parameter p-code      like ub.db-attr.attr-code  no-undo .
    define input parameter p-value     like ub.db-attr.attr-value no-undo .

    define buffer buf_db-attr for ub.db-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run thth150-db-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if not available buf_db-attr then do:
      create buf_db-attr .
      assign
        buf_db-attr.db-num    = p-db-num
        buf_db-attr.attr-code = p-code
      .
    end.
    assign
      buf_db-attr.attr-value = p-value
    .
  end.

end procedure.


procedure thth150-db-attr-exist :

  do
  on error undo, return error
  :
    define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input parameter p-code      like ub.db-attr.attr-code  no-undo .
    define output parameter p-exist    as logical  no-undo .

    define buffer buf_db-attr for ub.db-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run thth150-db-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if  available buf_db-attr then do:
      p-exist = yes.
    end.
  end.

end procedure.

procedure thth150-db-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.db-attr.db-num     no-undo .
    define input parameter p-code     like ub.db-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.

    define buffer buf_db-attr for ub.db-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run thth150-db-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_db-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_db-attr.
      p-deleted = yes.
    end.
  end.

end procedure.


procedure thth150-db-attr-news :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */

    case p-code :
            when 'thth150-cli-grp':U then do:     assign     p-news = no.   end.
            when 'thth150-gds-grp':U then do:     assign     p-news = no.   end.
            when 'thth150-clients':U then do:     assign     p-news = no.   end.
            when 'thth150-goods':U then do:     assign     p-news = no.   end.
            when 'thth150-dis-card':U then do:     assign     p-news = no.   end.
            when 'thth150-qnty-dis-card':U then do:     assign     p-news = no.   end.
            when 'thth150-shop':U then do:     assign     p-news = no.   end.
            when 'thth150-contract':U then do:     assign     p-news = no.   end.
            when 'thth150-price-doc':U then do:     assign     p-news = no.   end.
            when 'thth150-trn-doc':U then do:     assign     p-news = no.   end.

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.

/* $Workfile$ e n d */
 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временные атрибуты БД для утилиты - нижняя версия 14

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/11/09
Author: Bakhtadze Natalya
Creation date: 01/11/09

*/

define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*----------------------------ВНИМАНИЕ!!!------------------------------------------------- */
/*значения атрибутов имеющих логический тип должны записываться в базу чисто как yes или no*/
/*все форматирование осуществлять на верхнем уровне                                        */


/* соответстие групп клиентов */


/* соответстие клиентов */


/* соответстие групп товаров */

/* соответстие товаров */


/* импортирвоаны  ДК */

/* ожидаемое кол-во  ДК */



/* соответстие  объектов */




/* импорт перецоенков */

/* импорт прих накл */





/* сюда добавлять новые параметры */




/* ------------------------------------------------------------------- */







procedure thth14-db-attr-code :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-type           as character no-undo . /* тип атрибута */
    define output parameter p-format         as character no-undo . /* формат атрибута */
    define output parameter p-label          as character no-undo . /* лабел атрибута */
    define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
    define output parameter p-output-display as logical   no-undo . /* виден в броусе */
    define output parameter p-other          as character no-undo . /* еще чего - нибудь */

    case p-code :
            when 'thth14-cli-grp':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие групп клиентов"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие групп клиентов"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-gds-grp':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие групп товаров"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие групп товаров"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-clients':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие клиентов"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие клиентов"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-goods':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие товаров"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие товаров"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-dis-card':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ ДК"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ ДК"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-qnty-dis-card':U then do:     assign     p-label = "Ожидаемое кол-во ДК"     p-type = 'I':U      p-format = "999,999,999"     p-label = "Ожидаемое кол-во ДК"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-shop':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие объeктов TH"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие объeктов TH"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-contract':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ договора и спецификации"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ договора и спецификации"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-price-doc':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ переоценки"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ переоценки"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-trn-doc':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ приходные накладные"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ приходные накладные"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.


      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.

procedure thth14-db-attr-tooltip :

  do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
            when 'thth14-cli-grp':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие групп клиентов для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие групп клиентов" .   end.
            when 'thth14-gds-grp':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие групп товаров для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие групп товаров" .   end.
            when 'thth14-clients':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие клиентов для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие клиентов" .   end.
            when 'thth14-goods':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие товаров для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие товаров" .   end.
            when 'thth14-dis-card':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ ДК"     p-label = "ИМПОРТИРОВАНЫ ДК" .   end.
            when 'thth14-qnty-dis-card':U then do:     assign     p-tooltip = "Ожидаемое кол-во ДК"     p-label = "Ожидаемое кол-во ДК" .   end.
            when 'thth14-shop':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие объeктов TH для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие объeктов TH" .   end.
            when 'thth14-contract':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ договора и спецификации для двух систем IBS TH"     p-label = "ИМПОРТИРОВАНЫ договора и спецификации" .   end.
            when 'thth14-price-doc':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ переоценки"     p-label = "ИМПОРТИРОВАНЫ переоценки" .   end.
            when 'thth14-trn-doc':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ приходные накладные"     p-label = "ИМПОРТИРОВАНЫ приходные накладные" .   end.





      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.

end procedure.


procedure thth14-db-attr-value :

  do
  on error undo, return error
  :
    define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
    define output parameter p-value     like ub.db-attr.attr-value no-undo .
    define output parameter p-type      as character no-undo .

    define buffer buf_db-attr for ub.db-attr .

    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run thth14-db-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if avail buf_db-attr then do:
      assign
        p-value =  buf_db-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.

end procedure.


procedure thth14-db-attr-write :

  do
  on error undo, return error
  :
    define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input parameter p-code      like ub.db-attr.attr-code  no-undo .
    define input parameter p-value     like ub.db-attr.attr-value no-undo .

    define buffer buf_db-attr for ub.db-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run thth14-db-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if not available buf_db-attr then do:
      create buf_db-attr .
      assign
        buf_db-attr.db-num    = p-db-num
        buf_db-attr.attr-code = p-code
      .
    end.
    assign
      buf_db-attr.attr-value = p-value
    .
  end.

end procedure.


procedure thth14-db-attr-exist :

  do
  on error undo, return error
  :
    define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input parameter p-code      like ub.db-attr.attr-code  no-undo .
    define output parameter p-exist    as logical  no-undo .

    define buffer buf_db-attr for ub.db-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run thth14-db-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if  available buf_db-attr then do:
      p-exist = yes.
    end.
  end.

end procedure.

procedure thth14-db-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.db-attr.db-num     no-undo .
    define input parameter p-code     like ub.db-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.

    define buffer buf_db-attr for ub.db-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run thth14-db-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_db-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_db-attr.
      p-deleted = yes.
    end.
  end.

end procedure.


procedure thth14-db-attr-news :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */

    case p-code :
            when 'thth14-cli-grp':U then do:     assign     p-news = no.   end.
            when 'thth14-gds-grp':U then do:     assign     p-news = no.   end.
            when 'thth14-clients':U then do:     assign     p-news = no.   end.
            when 'thth14-goods':U then do:     assign     p-news = no.   end.
            when 'thth14-dis-card':U then do:     assign     p-news = no.   end.
            when 'thth14-qnty-dis-card':U then do:     assign     p-news = no.   end.
            when 'thth14-shop':U then do:     assign     p-news = no.   end.
            when 'thth14-contract':U then do:     assign     p-news = no.   end.
            when 'thth14-price-doc':U then do:     assign     p-news = no.   end.
            when 'thth14-trn-doc':U then do:     assign     p-news = no.   end.

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.

/* $Workfile$ e n d */
 


define variable p-from-version as character no-undo .
define variable v-src-full-name as character no-undo .
define variable v-upper-code as integer no-undo .
define variable v-level as integer no-undo .
define variable v-counter as integer no-undo .
define variable v-rec as recid no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-ii as integer no-undo .
define variable v-ii-next as integer no-undo .
define variable v-ii-next-done as integer no-undo .
define variable v-ii-ok as integer no-undo .
define variable v-has-ss as logical no-undo .
define variable v-num-src-gds-prt as integer no-undo .
define variable v-num-gds-prt as integer no-undo .
define variable v-src-empty-scale  as integer no-undo .
define variable v-empty-scale  as integer no-undo .
define variable v-goods-uniq-key-rec as character no-undo .
define variable v-clients-uniq-key-rec as character no-undo .
define variable v-gds-code as integer no-undo .
define variable v-pbc as integer no-undo .
define variable v-pbc-ok as integer no-undo .
define variable v-is-new as logical no-undo .
define variable v-b-str as character no-undo .
define variable v-rid as recid no-undo .
define variable v-param-type                as character                no-undo.
define variable v-value-character           as character                no-undo.
define variable v-value-date                as date                     no-undo.
define variable v-value-decimal             as decimal                  no-undo.
define variable v-value-integer             as INTEGER                  no-undo.
define variable v-value-logical             AS LOGICAL                  no-undo.
define variable v-tth                       as handle                   no-undo.
define variable dif-pdbc as logical no-undo initial no.
define variable pbc-veto  as logical no-undo.
define variable p-import-type as integer no-undo .
define variable v-classif-name as character no-undo .
define variable v-cli-classif-name as character no-undo .


define buffer src_goods for src.goods.
define buffer src_prod-bc for src.prod-bc.
define buffer src_bar-code for src.bar-code.
define buffer src_code-range for src.code-range.
define buffer src_gds-prt for src.gds-prt.
define buffer buf_goods for ub.goods.
define buffer buf2_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_clients for ub.clients.
define buffer clients_ext-classif for ub.ext-classif.


define variable log-file-name as character no-undo .

DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
DEFINE BUFFER buf2_ext-classif FOR ub.ext-classif.




/*очищаем все*/
log-file-name = substitute("&1.txt", entry(1, entry(num-entries(this-procedure:file-name, chr(47)), this-procedure:file-name, chr(47)), ".")).

if num-entries(p-parameter, chr(4)) <> 2 then do:
  message
  substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 2"
             ,num-entries(p-parameter, chr(4)))
  view-as alert-box error .
  return.
end.
assign
p-import-type = integer(entry(1, p-parameter, chr(4) ))
p-from-version = entry(2, p-parameter, chr(4) )
.
case p-from-version:
  when 'v15_0000':U then do:
    assign
    v-classif-name = 'th-th150_goods':U
    v-cli-classif-name = 'th-th150_clients':U
    .
  end.
  when 'v14_0':U then do:
    assign
    v-classif-name = 'th-th14_goods':U
    v-cli-classif-name = 'th-th14_clients':U
    .
  end.
end case.

if p-import-type = 1 then do:
    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "Очищаем данные соответствий, полученные ПОСЛЕ upgrade или последнего завершенного переноса..."                                       ).
  for each buf_ext-classif WHERE
              buf_ext-classif.classif-subject = 'goods':U
          and buf_ext-classif.classif-name = v-classif-name
          AND buf_ext-classif.db-num = - 1
          and buf_ext-classif.key#_three  = 0
          :
    v-ii = v-ii + 1.
    if v-ii modulo 10 = 0 then do:
            run write-counter in p-log-handle (input substitute("Удалено &1", v-ii)).
    end.
    delete buf_ext-classif.
  end.
end.
v-ii = 0.
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "Импорт новых данных..."                                       ).
find first src_code-range no-lock where
          src_code-range.range-type = 'sslc':U
          or
          src_code-range.range-type = 'ssgb':U no-error.
if available src_code-range then do:
  v-has-ss = yes.
end.
for each src_gds-prt no-lock:
  v-num-src-gds-prt = v-num-src-gds-prt + 1.
end.
if v-num-src-gds-prt > 1 then do:
  find first src_gds-prt where
            src_gds-prt.node-name = '_Пустая шкала':U .
  assign
  v-src-empty-scale = src_gds-prt.node-code.
end.
for each buf_gds-prt no-lock:
  v-num-gds-prt = v-num-gds-prt + 1.
end.
if v-num-gds-prt > 1 then do:
  find first buf_gds-prt where
            buf_gds-prt.node-name = '_Пустая шкала':U .
  assign
  v-empty-scale = src_gds-prt.node-code.
end.

run adm/shattri.p (
    input "get":U
    ,input  '':U /*p-obj-type*/
    ,input  0 /*p-obj-code*/
    ,input  'gds-ref':U
    ,input  'dif-pdbc':U /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output dif-pdbc
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error.
delete object v-tth.
run adm/shattri.p (
    input "get":U
    ,input  '':U /*p-obj-type*/
    ,input  0 /*p-obj-code*/
    ,input  'gds-ref':U
    ,input  'pbc-veto':U /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output pbc-veto
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error.
delete object v-tth.


_goods:
for each src_goods no-lock :
  if src_goods.stts > 0 then next.
  v-ii = v-ii + 1.
  v-goods-uniq-key-rec = ''.
  if v-ii modulo 10 = 0 then do:
        run write-counter in p-log-handle (input substitute("Обработано &1 из них найдено соответствие для &2 пропущено &3 ранее сведено &4"                                       , v-ii                                       , v-ii-ok                                       , v-ii-next                                       , v-ii-next-done  )).
  end.
  find first buf_ext-classif no-lock where
            buf_ext-classif.classif-subject = 'goods':U
       and  buf_ext-classif.classif-name = v-classif-name
       and buf_ext-classif.key#_one = src_goods.gds-code
       and (buf_ext-classif.key#_three = 1
           or
           buf_ext-classif.key#_three = 2)
       no-error.
  if available buf_ext-classif then do:
    if buf_ext-classif.key#_two = src_goods.prod-code
    and buf_ext-classif.charkey_one = src_goods.artic
    and buf_ext-classif.charkey_two = src_goods.prod-type then do:
       v-ii-next-done = v-ii-next-done + 1.
       next _goods.
    end.
  end.

  v-gds-code = 0.

  /*находим соответствие*/
  _prod-bc:
  for each src_bar-code where src_bar-code.gds-code = src_goods.gds-code,
       each src_prod-bc where src_prod-bc.b-code = src_bar-code.b-code:
    if src_bar-code.in-code <> '' then next _prod-bc.
    if src_bar-code.part-code <> '' then next _prod-bc.
    if src_prod-bc.bc-on = no then next _prod-bc.
    if length(src_prod-bc.b-str) < 6 then next _prod-bc. /*это весовые*/
    if v-has-ss
    and length(src_prod-bc.b-str) < 10
    then do:
      find first src_code-range no-lock where
                src_code-range.range-type = 'sslc':U
            and src_code-range.first-code >= integer(src_prod-bc.b-str)
            and src_code-range.last-code <= integer(src_prod-bc.b-str) no-error.
      if available src_code-range then next _prod-bc.
      find first src_code-range no-lock where
                src_code-range.range-type = 'ssgb':U
            and src_code-range.first-code >= integer(src_prod-bc.b-str)
            and src_code-range.last-code <= integer(src_prod-bc.b-str) no-error.
      if available src_code-range then next _prod-bc.
    end.
    find first buf_prod-bc no-lock where
              buf_prod-bc.b-str = src_prod-bc.b-str no-error.
    if available buf_prod-bc then do:
      find first buf_bar-code no-lock where
              buf_bar-code.b-code = buf_prod-bc.b-code no-error.
      if available buf_bar-code then do:
        if not ((buf_bar-code.unit-cli = src_bar-code.unit-cli)
                and
                (buf_bar-code.cli-base-rate = src_bar-code.cli-base-rate)) then next _prod-bc.
        find first buf_goods no-lock where
                  buf_goods.gds-code = buf_bar-code.gds-code no-error.

        if available buf_goods then do:
          v-gds-code = buf_goods.gds-code.
          /*проверим по шкалам*/
          if v-num-src-gds-prt > 1
          or v-num-gds-prt > 1 then do:
            find first src_gds-prt no-lock WHERE
                     src_gds-prt.upper-code = src_goods.prt-root.
            find first buf_gds-prt no-lock WHERE
                     buf_gds-prt.upper-code = buf_goods.prt-root.
            if src_gds-prt.node-code <> v-src-empty-scale
            or buf_gds-prt.node-code <> v-empty-scale then do:
              v-ii-next = v-ii-next + 1.
              next.
            end.
          end.
          /*проверим по ед-изм*/
          if buf_goods.unit-base <> src_goods.unit-base
          then do:
            next _prod-bc.
          end. /*if buf_goods.unit-base = src_goods.unit-base then do:*/
          /*ПО ГРУППЕ НЕ ПРОВЕРЯЕМ!!!!*/
          find first buf_clients no-lock where
                    buf_clients.obj-type = buf_goods.prod-type
                and buf_clients.obj-code = buf_goods.prod-code no-error.
          if available buf_clients then do:
            run gen-key-rec in this-procedure ( input 'clients':U
                                              ,input (buffer buf_clients:handle)
                                              ,output v-clients-uniq-key-rec).
            find first clients_ext-classif share-lock where
                      clients_ext-classif.classif-subject  = 'clients':U
                  and  clients_ext-classif.classif-name  = v-cli-classif-name
                  and clients_ext-classif.db-num = -1
                  and clients_ext-classif.charkey_one = src_goods.prod-type
                  and clients_ext-classif.key#_one = src_goods.prod-code
                  and clients_ext-classif.uniq-key-rec = v-clients-uniq-key-rec no-error .
            if available clients_ext-classif
            or p-import-type = 2
            then do:
              run gen-key-rec in this-procedure ( input 'goods':U
                                                ,input (buffer buf_goods:handle)
                                                ,output v-goods-uniq-key-rec).
               leave _prod-bc.
            end. /*if available clients_ext-classif then do:*/
          end. /*if available buf_clients then do:*/
        end. /*if available buf_goods then do:*/
      end. /*if available buf_bar-code then do:*/
    end. /*if available buf_prod-bc then do:*/
  end. /*  for each src_bar-code where src_bar-code.gds-code = src_goods.gds-code,*/
  if v-goods-uniq-key-rec <> '' then do:
    /*надо проверить что все prod-bc товара в p-from-version принадлежат одному товару*/
    _prod-bc2:
    for each src_bar-code where src_bar-code.gds-code = src_goods.gds-code,
        each src_prod-bc where src_prod-bc.b-code = src_bar-code.b-code:
      if src_bar-code.in-code <> '' then next _prod-bc2.
      if src_bar-code.part-code <> '' then next _prod-bc2.
      if src_prod-bc.bc-on = no then next _prod-bc2.
      if length(src_prod-bc.b-str) < 6 then next _prod-bc2. /*это весовые*/
      if v-has-ss
      and length(src_prod-bc.b-str) < 10
      then do:
        find first src_code-range no-lock where
                  src_code-range.range-type = 'sslc':U
              and src_code-range.first-code >= integer(src_prod-bc.b-str)
              and src_code-range.last-code <= integer(src_prod-bc.b-str) no-error.
        if available src_code-range then next _prod-bc2.
        find first src_code-range no-lock where
                  src_code-range.range-type = 'ssgb':U
              and src_code-range.first-code >= integer(src_prod-bc.b-str)
              and src_code-range.last-code <= integer(src_prod-bc.b-str) no-error.
        if available src_code-range then next _prod-bc2.
      end.
      find first buf_prod-bc no-lock where
                buf_prod-bc.b-str = src_prod-bc.b-str no-error.
      if available buf_prod-bc then do:
        find first buf_bar-code no-lock where
                buf_bar-code.b-code = buf_prod-bc.b-code no-error.
        if available buf_bar-code then do:
           if buf_bar-code.gds-code <> v-gds-code then do:
             /*НЕ ВСЕ БАРКОДЫ ПРИНАДЛЕЖАТ В НАШЕЙ БД ОДНОМУ И ТОМУ ЖЕ ТОВАРУ*/
             v-goods-uniq-key-rec = ''.
             leave _prod-bc2.
           end.
        end. /*if available buf_bar-code then do:*/
      end. /*if available buf_prod-bc then do:*/
    end. /* for each src_bar-code where src_bar-code.gds-code = src_goods.gds-code,*/
  end.
  if p-import-type = 2 then do:
    find first buf_ext-classif no-lock where
              buf_ext-classif.classif-subject  =  'goods':U
         and  buf_ext-classif.classif-name  = v-classif-name
         and buf_ext-classif.key#_one = src_goods.gds-code no-error.
    if not available buf_ext-classif then do:
           run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute('Не найдена запись соответствия по товару &5 &1&2:&3&2&4'                                     , src_goods.gds-code                                     ,chr(10)                                     , error-status:get-message(1)                                     , return-value                                     , p-from-version)                                       ).
     next _goods.
    end.
    if buf_ext-classif.uniq-key-rec <> '' then do:
      v-ii-next = v-ii-next + 1.
      next _goods.
    end.
    v-rec = recid(buf_ext-classif).
  end.
  else do:
    v-rec = ?.
  end.
  if v-goods-uniq-key-rec <> ''
  and v-rec <> ?
  then do:
    find first buf2_ext-classif no-lock where
              buf2_ext-classif.classif-subject  =  'goods':U
         and  buf2_ext-classif.classif-name  = v-classif-name
         and buf2_ext-classif.uniq-key-rec = v-goods-uniq-key-rec no-error.
    if available buf2_ext-classif and recid(buf2_ext-classif) <> v-rec then do:
             run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute('Не могу привязать запись соответствия по товару &7 &1 (&2 &3&4 &5)&6'                                      , src_goods.gds-code                                     , src_goods.artic                                     , src_goods.prod-type                                     , src_goods.prod-code                                     , src_goods.gds-name                                      ,chr(10)                                     , p-from-version) +                        substitute("к товару v16.0 с кодом &1 (&2 &3&4 &5)&6"                                      , buf_goods.gds-code                                     , buf_goods.artic                                     , buf_goods.prod-type                                     , buf_goods.prod-code                                     , buf_goods.gds-name                                      ,chr(10)) +                        substitute("ТОВАР v16.0 УЖЕ СВЯЗАН С ТОВАРОМ &7 &1 (&2 &3&4 &5)"                                     , buf2_ext-classif.key#_one                                     , buf2_ext-classif.charkey_one                                     , buf2_ext-classif.charkey_two                                     , buf2_ext-classif.key#_two                                     , entry(1, buf2_ext-classif.charkey_three, chr(4) )                                     ,chr(10)                                     , p-from-version )                                       ).
       v-ii-next = v-ii-next + 1.
       next _goods.
    end.
  end.
  run ref/extclas1.p (
                       input (if p-import-type = 1 then 'ДОБАВЛЕНИЕ':U else 'ИЗМЕНЕНИЕ':U)
                      ,input yes /*p-silent*/
                      ,input-output v-rec
                      ,input 'goods':U /*p-classif-subject */
                      ,input v-classif-name
                      ,input -1 /*p-db-num*/
                      ,input src_goods.gds-code /*p-Key#_One*/
                      ,input src_goods.prod-code /*p-Key#_Two */
                      ,input 0  /*p-key#_Three*/
                      ,input src_goods.artic /*p-CharKey_One*/
                      ,input src_goods.prod-type /*p-CharKey_Two*/
                      ,input src_goods.gds-name + chr(4) + src_goods.unit-base /*p-CharKey_Three*/
                      ,input 0 /*p-nonunique*/
                      ,input v-goods-uniq-key-rec /*p-uniq-key-rec*/
                      ) no-error.
  if error-status:error then do:
        run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute('Ошибка при сохранении записи соответствия по товару &5 &1&2:&3&2&4'                                   , src_goods.gds-code                                   ,chr(10)                                   , error-status:get-message(1)                                   , return-value                                   , p-from-version )                                       ).
  end.
  if v-goods-uniq-key-rec > ''
  and false /*НЕ БУДЕМ ДОБАВЛЯТЬ ВСЕ РАВНО НЕ ЦЕНЯТ!!!!*/
  then do:
    /*добавим все prod-bc из  бд p-from-version*/
    _prod-bc3:
    for each src_bar-code where src_bar-code.gds-code = src_goods.gds-code,
        each src_prod-bc where src_prod-bc.b-code = src_bar-code.b-code:
      if src_bar-code.in-code <> '' then next _prod-bc3.
      if src_bar-code.part-code <> '' then next _prod-bc3.
      if src_prod-bc.bc-on = no then next _prod-bc3.
      if length(src_prod-bc.b-str) < 6 then next _prod-bc3. /*это весовые*/
      if v-has-ss
      and length(src_prod-bc.b-str) < 10
      then do:
        find first src_code-range no-lock where
                  src_code-range.range-type = 'sslc':U
              and src_code-range.first-code >= integer(src_prod-bc.b-str)
              and src_code-range.last-code <= integer(src_prod-bc.b-str) no-error.
        if available src_code-range then next _prod-bc3.
        find first src_code-range no-lock where
                  src_code-range.range-type = 'ssgb':U
              and src_code-range.first-code >= integer(src_prod-bc.b-str)
              and src_code-range.last-code <= integer(src_prod-bc.b-str) no-error.
        if available src_code-range then next _prod-bc3.
      end.
      find first buf_prod-bc no-lock where
                buf_prod-bc.b-str = src_prod-bc.b-str no-error.
      if not available buf_prod-bc then do:
        v-pbc = v-pbc + 1.
        /*найдем в бд v16.0 bar-code */
        find first buf_gds-prt no-lock WHERE
                  buf_gds-prt.upper-code = buf_goods.prt-root.
          run barcodcr in this-procedure (
                                           input  v-gds-code
                                          ,input buf_gds-prt.node-code
                                          ,input '' /*p-part-code*/
                                          ,input '' /*p-in-code*/
                                          ,input src_bar-code.unit-cli
                                          ,input src_bar-code.cli-base-rate
                                          ,output v-is-new
                                          ,buffer buf_bar-code
                                          ) no-error.
        if error-status:error then do:
                        run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Ошибка при добавлении собственного баркода для товара с найденным соответствием&1" +                                         "&7&1&8" +                                         "код товара в БД v16.0 &2, код товара в БД &9 &3,&1" +                                         " ДопБК &4, ед.изм в текущей БД &5, ед изм. в БД &9 &6"                                         , chr(10)                                         , src_goods.gds-code                                         , v-gds-code                                         , src_prod-bc.b-str                                         , src_bar-code.cli-base-rate                                         , buf_bar-code.cli-base-rate                                         , error-status:get-message(1)                                          , return-value                                         , p-from-version                                          )                                       ).
          next _prod-bc3.
        end.
        if available buf_bar-code then do:
          if buf_bar-code.cli-base-rate <> src_bar-code.cli-base-rate then do:
                        run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Невозможно добавить отсутствующий в текущей БД ДопБК для товара с найденным соответствием&1" +                                         "Не совпадают коэфф ед.изм." +                                          "код товара в БД v16.0 &2, код товара в БД &9 &3,&1" +                                         " ДопБК &4, ед.изм в текущей БД &5, ед изм. в БД &9 &6" +                                         " коэфф. в БД v16.0 &7 коэфф. в БД &9 &8"                                         , chr(10)                                         , src_goods.gds-code                                         , v-gds-code                                         , src_prod-bc.b-str                                         , src_bar-code.unit-cli                                         , buf_bar-code.unit-cli                                         , src_bar-code.cli-base-rate                                         , buf_bar-code.cli-base-rate                                         , p-from-version                                          )                                       ).
          end. /*if buf_bar-code.cli-base-rate <> src_bar-code.cli-base-rate then do:*/
          else do:
            v-b-str = src_prod-bc.b-str.
            run trg/prod-bc1.p ( input parparentproc
                                ,input yes /*p-silent*/
                                ,input dif-pdbc /* dif-pdbc */
                                ,input ? /*pbc-veto*/
                                ,input no /*send-ref*/
                                ,input ''
                                ,input "" /*p-ean-type*/
                                ,buffer buf_goods
                                ,input buf_bar-code.b-code
                                ,input-output v-b-str /*p-b-str*/
                                ,output v-rid
                                ) no-error.
            if not error-status:error then do:
              v-pbc-ok = v-pbc-ok + 1.
            end.
            else do:
                            run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Ошибка при добавлении ДоБК для товара с найденным соответствием&1" +                                           "&7&1&8" +                                           "код товара в БД v16.0 &2, код товара в БД &8 &3,&1" +                                           " ДопБК &4, ед.изм в БД v16.0 &5, ед изм. в БД &8 &6"                                           , chr(10)                                           , src_goods.gds-code                                           , v-gds-code                                           , src_prod-bc.b-str                                           , src_bar-code.cli-base-rate                                           , buf_bar-code.cli-base-rate                                           , error-status:get-message(1)                                            , return-value                                           , p-from-version                                           )                                       ).
            end.
          end. /*else if buf_bar-code.cli-base-rate <> src_bar-code.cli-base-rate then do:*/
        end. /*if available buf_bar-code then do:*/
      end. /*if available buf_prod-bc then do:*/
    end. /* for each src_bar-code where src_bar-code.gds-code = src_goods.gds-code,*/
  end. /*if v-goods-uniq-key-rec > '' then do:*/
  if v-goods-uniq-key-rec > '' then v-ii-ok = v-ii-ok + 1.
end. /*for each src_goods no-lock:*/
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Обработано &1, из них найдено соотв для &2, из отсутсв. &3 ДопБК удалось добавить &4&5пропущено &6 ранее сведено &7",                              v-ii, v-ii-ok, v-pbc, v-pbc-ok, chr(10), v-ii-next, v-ii-next-done)                                       ).
run hide-counter in p-log-handle.

procedure barcodcr :

  define input  parameter p-gds-code      like ub.bar-code.gds-code      no-undo .
  define input  parameter p-node-code     like ub.bar-code.node-code     no-undo .
  define input  parameter p-part-code     like ub.bar-code.part-code     no-undo .
  define input  parameter p-in-code       like ub.bar-code.in-code       no-undo .
  define input  parameter p-unit-cli      like ub.bar-code.unit-cli      no-undo .
  define input  parameter p-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
  define output parameter p-is-new        as logical                     no-undo .
  define parameter buffer buf_bar-code for ub.bar-code .

  define variable vss-description as character no-undo initial "barcodcr-03: поиск/создание бар-кода" .

  define variable v-new-b-code like ub.bar-code.b-code no-undo .
  define variable v-unit-base  like ub.goods.unit-base no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-is-new = false
    .

    find first buf_bar-code no-lock
      where buf_bar-code.gds-code  = p-gds-code
        and buf_bar-code.node-code = p-node-code
        and buf_bar-code.part-code = p-part-code
        and buf_bar-code.in-code   = p-in-code
        and buf_bar-code.unit-cli  = p-unit-cli
      no-error .
    if not available buf_bar-code
    then do
    transaction
    on error undo, return error return-value
    :
      run gen-b-code in this-procedure
        ( input 'bcgb':U,
          output v-new-b-code
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при получении номера бар-кода" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
       run unitbase in this-procedure ( input p-gds-code, output v-unit-base) no-error.
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка определения базовой единицы измерения товара" skip
          "Код товара" p-gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if p-unit-cli = v-unit-base
      then do:
        assign
          p-cli-base-rate = 1
        .
      end.

      if p-cli-base-rate = ?
      or p-cli-base-rate = 0
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не задана коэффициент преобразования из одной единицы измерения в другую" skip
          "Код товара" p-gds-code skip
          "p-unit-cli" p-unit-cli skip
          "v-unit-base" v-unit-base skip
          "p-cli-base-rate" p-cli-base-rate skip
          view-as alert-box error .
        undo, return error return-value .
      end.


      assign
        p-is-new = true
      .

      create buf_bar-code .
      assign
        buf_bar-code.b-code        = v-new-b-code
        buf_bar-code.gds-code      = p-gds-code
        buf_bar-code.node-code     = p-node-code
        buf_bar-code.part-code     = p-part-code
        buf_bar-code.in-code       = p-in-code
        buf_bar-code.unit-cli      = p-unit-cli
        buf_bar-code.cli-base-rate = p-cli-base-rate
      .
    end. /*if not available buf_bar-code*/
    else do:
      if buf_bar-code.stts_ = integer('99':U)
      or buf_bar-code.stts_ = integer('79':U)
      then do:
        undo, return error substitute("баркод &1 для товара &2 помечен к удалению или логически удален", buf_bar-code.b-code, p-gds-code).
      end.
    end.

  end.

end procedure. /* barcodcr */

procedure unitbase :

  define input  parameter p-gds-code  like ub.goods.gds-code  no-undo .
  define output parameter p-unit-base like ub.goods.unit-base no-undo .

  define variable vss-description as character no-undo initial "unitbase-01: определение базовой единицы измерения товара".

  define buffer buf_goods for ub.goods .

  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.

    assign
      p-unit-base = buf_goods.unit-base
    .
  end.

end procedure. /* unitbase */

def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile: ththgdsi.p $ $Revision: 1f78fe327cdf, 1091, rls $".



procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .

    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .

    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info3 ).
    end.

    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info3, p-tbl-name ).
    end.

    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.

    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", fh:buffer-value())
        .
      end.
    end.

    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info3, p-tbl-name ).
    end.

  end.
  return.
end procedure. /* gen-key-rec */

procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo . /* буфер записи которую будем искать. если ищем по key-rec то ? */
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo . /* буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
  define input  parameter p-stts-lock  as integer   no-undo . /* этот параметр игнорируется для временных таблиц */
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-where          as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do: /* если ищем по буферу */
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info3 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info3, p-key-rec ).
      end.
    end.
    else do: /* если ищем по ключу */
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
      end.
    end.

    assign
      p-tbl-name = entry( 1 , p-key-rec, chr(3) )
    .

    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info3, p-tbl-name, chr(10) ).
    end.

    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, p-tbl-name )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.

    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.

    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info3, p-tbl-name ).
    end.

    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, p-tbl-name ).
    end.
    assign
      v-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.

      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
        assign
          v-where = substitute( "&1 &2 &3 =", v-where, v-word-link, v-field-name )
        .
/*      if p-tt-handle = ? then do:*/
/*        assign*/
/*          v-where = substitute( "&1 &2 &3.&4 =", v-where, v-word-link, v-full-tbl-name, v-field-name )*/
/*        .*/
/*      end.*/
/*      else do:*/
/*        assign*/
/*          v-where = substitute( "&1 &2 &3 =", v-where, v-word-link, v-field-name )*/
/*        .*/
/*      end.*/
      if p-key-handle = ? then do:
        assign
          v-field-val = entry( v-count-fld + 1 , p-key-rec, chr(3) )
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info3, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.

      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        v-where = substitute( "&1 &2", v-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.

    end.

    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info3, p-tbl-name ).
    end.
    if p-tt-handle = ? then do:
      bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
    end.
    else do:
      bh_tbl-name:find-first( v-where ) no-error .
    end.

    if bh_tbl-name:available then do:
      assign
        p-tbl-row = bh_tbl-name:rowid
      .
    end.
    else do:
      assign
        p-tbl-row = ?
      .
    end.

    delete object bh_tbl-name.

  end.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info3, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.

end procedure. /* gen-row-keyr */

procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .

    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
    end.

    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name .

    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.

    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.

    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, v-tbl-name ).
    end.

    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.

      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.

    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info3, v-tbl-name ).
    end.

    delete object bh_tbl-name.

  end.

  return.

end procedure. /* gen-key-fv */



define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile: ththgdsi.p $ $Revision: 1f78fe327cdf, 1091, rls $".

define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile: ththgdsi.p $ $Revision: 1f78fe327cdf, 1091, rls $".


procedure gen-b-code :

  define input  parameter type-code like ub.code-range.range-type no-undo . /* тип кода, значение которого хотим получить */
  define output parameter p-b-code  like ub.bar-code.b-code       no-undo . /* выходное значение бар-кода                 */

  do
  on error  undo, return error substitute( "&1 (gen-b-code). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-b-code). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-b-code). endkey", vss-workfile )
  :
    define buffer buf_thbj-attr     for ub.thbj-attr .
    define buffer buf_sys-ctrl   for ub.sys-ctrl .
    define buffer buf_code-range for ub.code-range .

    define variable l-code         as   integer              no-undo .
    define variable v-db-num       like ub.db.db-num         no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .

    if type-code = 'sslc':U
    or type-code = 'ssgb':U
    then do:
      /* диапазон локальных взвешиваемых кодов */
      message
        "Нельзя генерировать локальный или глобальный взвешиваемый код." skip
        "Обратитесь к администратору системы."
        view-as alert-box error .
      undo, return error (if type-code = 'sslc':U then "loc-ss-code":U else "gbl-ss-code" ) .
    end.

    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    run get-next-seq( input  type-code,
                      output l-code
                    ).

    find first buf_sys-ctrl no-lock.
    if type-code = 'sclc':U
    or type-code = 'pglc':U
    then do:
      /* диапазон локальных весовых кодов всегда привязан к ГБД */
      assign
        v-db-num = 0
      .
    end.
    else do:
      assign
        v-db-num = buf_sys-ctrl.db-num
      .
    end.
    find first buf_code-range no-lock
      where buf_code-range.db-num     = v-db-num
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "a"
      use-index stts
      no-error .
    if available buf_code-range
       and l-code <= buf_code-range.last-code
       and l-code >= buf_code-range.first-code then do:
      /* значение внутри активного диапазона - выставляем его по sequence */
      assign
        p-b-code = l-code
      .
    end.
    else do:
      if available buf_code-range
         and l-code < buf_code-range.last-code then do:
        message
          substitute( "Последовательность для создания кодов с типом &1 имеет неверное значение.", type-code ) skip
          "Обратитесь к администратору системы."
          view-as alert-box error .
        undo, return error "sequence":U .
      end.
      /* завхватываем thbj-attr */
      /* чтобы никто другой не мог одновременно менять диапазон */
      do transaction
      on error undo, return error
      :
        find first buf_thbj-attr exclusive-lock
          where buf_thbj-attr.upper-prop-code = 'code-range':U
            and buf_thbj-attr.prop-code = cfg-param-code
            and buf_thbj-attr.obj-type   = 'БД':U
            and buf_thbj-attr.obj-code   = v-db-num
          no-error .
        if not available buf_thbj-attr then do:
          find first buf_thbj-attr exclusive-lock
            where buf_thbj-attr.upper-prop-code = 'code-range':U
              and buf_thbj-attr.prop-code = cfg-param-code
              and buf_thbj-attr.obj-type   = ''
              and buf_thbj-attr.obj-code   = 0
            no-error .
          if not available buf_thbj-attr then do:
            if not locked buf_thbj-attr then do:
              message
                substitute( "Отсутствует параметр 'длина диапазона кодов' (&1) для БД &2.", cfg-param-code, buf_sys-ctrl.db-num ) skip
                "Обратитесь к администратору системы."
                view-as alert-box error .
            end.
            /* если пользователь отказался подождать, */
            /* то ему не дадим менять диапазон и бар-код не дадим ! */
            undo, return error "config":U .
          end. /*if not available buf_thbj-attr then do:*/
        end. /*if not available buf_thbj-attr then do:*/

        run get-next-seq( input type-code,
                          output l-code
                        ).
        /* если диапазон сменился другим пользователем */
        /* то надо перечитать значение sequence, */
        /* если не сменился, то требуется смена диапазона и смена sequence */
        find first buf_code-range
          where buf_code-range.db-num     = v-db-num
            and buf_code-range.range-type = type-code
            and buf_code-range.stts       = "a"
          use-index stts
          no-error .
        if available buf_code-range
        and l-code <= buf_code-range.last-code
        and l-code >= buf_code-range.first-code
        then do:
          assign
            p-b-code = l-code
          .
        end.
        else do:
          if available buf_code-range then do:
            /* диапазон никто не сменил */
            /* sequence за пределами диапазона */
            /* помечаем его как использованный */
            assign
              buf_code-range.stts = "u"
            .
          end.
          find first buf_code-range
            where buf_code-range.db-num     = v-db-num
              and buf_code-range.range-type = type-code
              and buf_code-range.stts       = "f"
            use-index stts
            no-error .
          if not available buf_code-range then do:
            message
              substitute( "Отсутствует свободный диапазон для кодов с типом &1.", type-code ) skip
              "Обратитесь к администратору системы"
              view-as alert-box error .
            undo, return error "code-range":U .
          end.

          /* создаем новый диапазон и присваиваем новое значение seq */
          assign
            buf_code-range.stts           = "a"
          .
          if buf_code-range.first-code = 1 then do:
            run set-seq-cr( input type-code,
                            input buf_code-range.first-code
                          ).
            assign
              p-b-code = 1
            .
          end.
          else do:
            run set-seq-cr( input type-code,
                            input ( buf_code-range.first-code - 1 )
                          ).
            run get-next-seq( input type-code,
                              output p-b-code
                            ).
          end.
        end.
      end.
    end.
  end.
end procedure.

procedure get-next-seq :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter next-seq  as   integer                  no-undo .

  do
  on error  undo, return error substitute( "&1 (get-next-seq). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-next-seq). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-next-seq). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          next-seq = next-value(s-bcgb-code, ub)
        .
      end.
      when 'scgb':U then do:
        assign
          next-seq = next-value(s-scgb-code, ub)
        .
      end.
      when 'sclc':U then do:
        assign
          next-seq = next-value(s-sclc-code, ub)
        .
      end.
      when 'pglc':U then do:
        assign
          next-seq = next-value(s-pglc-code, ub)
        .
      end.
      when 'dcgb':U then do:
        assign
          next-seq = next-value(s-dcgb-code, ub)
        .
      end.
      when 'ctgb':U then do:
        assign
          next-seq = next-value(s-ctgb-code, ub)
        .
      end.
      when 'drgb':U then do:
        assign
          next-seq = next-value(s-drgb-code, ub)
        .
      end.
      when 'fmgb':U then do:
        assign
          next-seq = next-value(s-fmgb-code, ub)
        .
      end.
      when 'pngb':U then do:
        assign
          next-seq = next-value(s-pngb-code, ub)
        .
      end.
      when 'cagb':U then do:
        assign
          next-seq = next-value(s-cagb-code, ub)
        .
      end.
      when 'fdgb':U then do:
        assign
          next-seq = next-value(s-fin-doc, ub)
        .
      end.
    end case.
  end.
end procedure. /* get-next-seq */
