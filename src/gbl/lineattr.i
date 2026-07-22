/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами строки документа

Автор: Чернова Светлана Александровна
Дата создания: 04/11/06
Author: Svetlana Chernova
Creation date: 04/11/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*----------------------------ВНИМАНИЕ!!!------------------------------------------------- */
/*значения атрибутов имеющих логический тип должны записываться в базу чисто как yes или no*/
/*все форматирование осуществлять на верхнем уровне                                        */
/* Описание не товарной позиции*/
&glob type-lineattr-flora_ps {&type-char}
&glob format-lineattr-flora_ps "x(70)"
&glob fillin_width-lineattr-flora_ps 12
&glob fillin_height-lineattr-flora_ps 1
&glob label-lineattr-flora_ps "Описание не товарной позиции"
&glob tooltip-lineattr-flora_ps "Описание не товарной позиции"
&glob user-can-edit-lineattr-flora_ps true
&glob output-display-lineattr-flora_ps true
&glob other-lineattr-flora_ps '':u
&glob news-lineattr-flora_ps true

/* Количество по букету */
&glob type-lineattr-flora_gds-code {&type-char}
&glob format-lineattr-flora_gds-code "x(70)"
&glob fillin_width-lineattr-flora_gds-code 12
&glob fillin_height-lineattr-flora_gds-code 1
&glob label-lineattr-flora_gds-code "Количество по букету"
&glob tooltip-lineattr-flora_gds-code "Количество по букету"
&glob user-can-edit-lineattr-flora_gds-code false
&glob output-display-lineattr-flora_gds-code false
&glob other-lineattr-flora_gds-code '':u
&glob news-lineattr-flora_gds-code true

/* Страна происхождения */
&glob type-lineattr-country-code {&type-int}
&glob format-lineattr-country-code "->>>>>>>>9"
&glob fillin_width-lineattr-country-code 10
&glob fillin_height-lineattr-country-code 1
&glob label-lineattr-country-code "Страна"
&glob tooltip-lineattr-country-code "Числовой код страны"
&glob user-can-edit-lineattr-country-code false
&glob output-display-lineattr-country-code false
&glob other-lineattr-country-code '':u
&glob news-lineattr-country-code true

/* Прочии расходы рассчитанные старым методом */
&glob type-lineattr-old_other-ras {&type-char}
&glob format-lineattr-old_other-ras "x(100)"
&glob fillin_width-lineattr-old_other-ras 12
&glob fillin_height-lineattr-old_other-ras 1
&glob label-lineattr-old_other-ras " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"
&glob tooltip-lineattr-old_other-ras "Сумма дополнительных расходов по строке rubl base"
&glob user-can-edit-lineattr-old_other-ras false
&glob output-display-lineattr-old_other-ras false
&glob other-lineattr-old_other-ras '':u
&glob news-lineattr-old_other-ras true

/* Прочии расходы рассчитанные новым  методом */
&glob type-lineattr-new_other-ras {&type-char}
&glob format-lineattr-new_other-ras "x(100)"
&glob fillin_width-lineattr-new_other-ras 12
&glob fillin_height-lineattr-new_other-ras 1
&glob label-lineattr-new_other-ras " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"
&glob tooltip-lineattr-new_other-ras "Сумма дополнительных расходов по строке rubl base"
&glob user-can-edit-lineattr-new_other-ras false
&glob output-display-lineattr-new_other-ras false
&glob other-lineattr-new_other-ras '':u
&glob news-lineattr-new_other-ras true


/* ДопРасходы  к коду  атрибута  +  cli-type cli-code contract-code host-code exch-code */
&glob type-lineattr-add-line-cli   {&type-char}
&glob format-lineattr-add-line-cli "x(100)"
&glob fillin_width-lineattr-add-line-cli 12
&glob fillin_height-lineattr-add-line-cli 1
&glob label-lineattr-add-line-cli "Курс . шкала . сумма . НДС "
&glob tooltip-lineattr-add-line-cli "Курс . шкала . сумма . НДС"
&glob user-can-edit-lineattr-add-line-cli false
&glob output-display-lineattr-add-line-cli false
&glob other-lineattr-add-line-cli '':u
&glob news-lineattr-add-line-cli false

/* Продажная цена в строке ПН - была ручная корректировка */
&glob type-lineattr-corr-price-sale           {&type-char}
&glob format-lineattr-corr-price-sale         "x(100)"
&glob fillin_width-lineattr-corr-price-sale   10
&glob fillin_height-lineattr-corr-price-sale  1
&glob label-lineattr-corr-price-sale          "Продажная цена в строке ПН"
&glob tooltip-lineattr-corr-price-sale        "Продажная цена в строке ПН - была ручная корректировка"
&glob user-can-edit-lineattr-corr-price-sale  false
&glob output-display-lineattr-corr-price-sale false
&glob other-lineattr-corr-price-sale          '':u
&glob news-lineattr-corr-price-sale           true


/* Код причины отклонения по РТ */
&glob type-lineattr-reason-code {&type-int}
&glob format-lineattr-reason-code "->>>>>>>>9"
&glob fillin_width-lineattr-reason-code 10
&glob fillin_height-lineattr-reason-code 1
&glob label-lineattr-reason-code "Причина отклонения"
&glob tooltip-lineattr-reason-code "Причина отклонения по радиотерминалу"
&glob user-can-edit-lineattr-reason-code true
&glob output-display-lineattr-reason-code true
&glob other-lineattr-reason-code '':u
&glob news-lineattr-reason-code true

/* Цена производителя Без НДС*/
&glob type-lineattr-price-prod {&type-dec}
&glob format-lineattr-price-prod ">>>>>>>>9.99"
&glob fillin_width-lineattr-price-prod 10
&glob fillin_height-lineattr-price-prod 1
&glob label-lineattr-price-prod "Цена производителя Без НДС"
&glob tooltip-lineattr-price-prod "Цена производителя Без НДС"
&glob user-can-edit-lineattr-price-prod true
&glob output-display-lineattr-price-prod true
&glob other-lineattr-price-prod '':u
&glob news-lineattr-price-prod true

/* Цена производителя С НДС*/
&glob type-lineattr-price-prod-vat {&type-dec}
&glob format-lineattr-price-prod-vat ">>>>>>>>9.99"
&glob fillin_width-lineattr-price-prod-vat 10
&glob fillin_height-lineattr-price-prod-vat 1
&glob label-lineattr-price-prod-vat "Цена производителя c НДС"
&glob tooltip-lineattr-price-prod-vat "Цена производителя c НДС"
&glob user-can-edit-lineattr-price-prod-vat true
&glob output-display-lineattr-price-prod-vat true
&glob other-lineattr-price-prod-vat '':u
&glob news-lineattr-price-prod-vat true

/* Продажная цена партии */
&glob type-lineattr-parts_price-sale {&type-char}
&glob format-lineattr-parts_price-sale "x(70)"
&glob fillin_width-lineattr-parts_price-sale 12
&glob fillin_height-lineattr-parts_price-sale 1
&glob label-lineattr-parts_price-sale "Продажная цена партии"
&glob tooltip-lineattr-parts_price-sale "Продажная цена партии"
&glob user-can-edit-lineattr-parts_price-sale false
&glob output-display-lineattr-parts_price-sale false
&glob other-lineattr-parts_price-sale '':u
&glob news-lineattr-parts_price-sale true

/* ------------------------------------------------------------------- */
procedure lineattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-fillin_width   /* p-fillin_width   */
      ,output v-fillin_height  /* p-fillin_height  */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value =  buf_doc-line-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = {&type-log} then "no":U else ""
      .
    end.
  end.

end procedure.

procedure lineattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-fillin_width   /* p-fillin_width   */
      ,output v-fillin_height  /* p-fillin_height  */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code = p-gds-code
        buf_doc-line-attr.attr-code = p-code
      .
    end.
    assign
      buf_doc-line-attr.attr-value = p-value
    .

     release buf_doc-line-attr.
  end.
end procedure.

procedure lineattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .

    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-fillin_width   /* p-fillin_width   */
      ,output v-fillin_height  /* p-fillin_height  */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if  available buf_doc-line-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.

procedure lineattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.

    define buffer buf_doc-line-attr for ub.doc-line-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-fillin_width   /* p-fillin_width   */
      ,output v-fillin_height  /* p-fillin_height  */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label          = ~{&label-~{&attr-code~}~} ~
    p-type           = ~{&type-~{&attr-code~}~}  ~
    p-format         = ~{&format-~{&attr-code~}~} ~
    p-fillin_width   = ~{&fillin_width-~{&attr-code~}~} ~
    p-fillin_height  = ~{&fillin_height-~{&attr-code~}~} ~
    p-label          = ~{&label-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other          = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

procedure lineattr-code :
  do on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo . /* код атрибута    */
    define output parameter p-type           as character no-undo . /* тип атрибута    */
    define output parameter p-format         as character no-undo . /* формат атрибута */
    define output parameter p-fillin_width   as integer   no-undo . /* ширина          */
    define output parameter p-fillin_height  as integer   no-undo . /* высота          */
    define output parameter p-label          as character no-undo . /* лабел атрибута */
    define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
    define output parameter p-output-display as logical   no-undo . /* виден в броусе */
    define output parameter p-other          as character no-undo . /* еще чего - нибудь */
    case p-code :
      &scop attr-code lineattr-parts_price-sale
      {&attr-temp-full-code}

      &scop attr-code lineattr-flora_gds-code
      {&attr-temp-full-code}
      &scop attr-code lineattr-old_other-ras
      {&attr-temp-full-code}
      &scop attr-code lineattr-new_other-ras
      {&attr-temp-full-code}
      &scop attr-code lineattr-flora_ps
      {&attr-temp-full-code}
      &scop attr-code lineattr-country-code
      {&attr-temp-full-code}
      &scop attr-code lineattr-add-line-cli
      {&attr-temp-full-code}
      &scop attr-code lineattr-corr-price-sale
      {&attr-temp-full-code}
      &scop attr-code lineattr-reason-code
      {&attr-temp-full-code}
      &scop attr-code lineattr-price-prod
      {&attr-temp-full-code}
      &scop attr-code lineattr-price-prod-vat
      {&attr-temp-full-code}



      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут строки документа" + " " + p-code .
      end.
    end.
  end.
end procedure.

procedure lineattr-value-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .

    define buffer buf_doc-line-attr for ub.doc-line-attr .

    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + {&comma-char} + string(p-prt-code)  + {&comma-char} + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.

end procedure.


procedure lineattr-write-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .

    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + {&comma-char}  + string(p-prt-code)  + {&comma-char} + string(p-bk-gds-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + {&comma-char}  + string(p-prt-code)  + {&comma-char} + string(p-bk-gds-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.


procedure lineattr-delete-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.

    define buffer buf_doc-line-attr for ub.doc-line-attr .

    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + {&comma-char} + string(p-prt-code)  + {&comma-char} + string(p-bk-gds-code)
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.


procedure lineattr-delete-flora-all :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .

    define buffer buf_doc-line-attr for ub.doc-line-attr .

    for each buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code begins {&lineattr-flora_gds-code} + {&comma-char} + string(p-prt-code)  + {&comma-char}
     :
      delete buf_doc-line-attr.
    end.
 end.
end procedure.


procedure lineattr-exist-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define output parameter p-exist as logical   no-undo .

    define buffer buf_doc-line-attr for ub.doc-line-attr .
    p-exist = false .

    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = {&lineattr-flora_gds-code}  + {&comma-char} + string(p-prt-code)  + {&comma-char} + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
       p-exist = true
      .
    end.
  end.

end procedure.


procedure lineattr-write-add-line-cli :
define input  parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input  parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input  parameter p-cli-type      as character no-undo .
define input  parameter p-cli-code      as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-exch-code     as integer   no-undo .
define input  parameter p-exch-rate     as decimal   no-undo .
define input  parameter p-exch-scale    as integer   no-undo .
define input  parameter p-sum-cli       as decimal   no-undo .
define input  parameter p-sum-vat       as decimal   no-undo .

define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :

    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = {&lineattr-add-line-cli} +
                                          {&delim-par} + p-cli-type +
                                          {&delim-par} + string(p-cli-code) +
                                          {&delim-par} + string(p-contract-code) +
                                          {&delim-par} + string(p-host-code)

      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = {&lineattr-add-line-cli}  +
                                      {&delim-par} + p-cli-type +
                                      {&delim-par} + string(p-cli-code) +
                                      {&delim-par} + string(p-contract-code) +
                                      {&delim-par} + string(p-host-code)

      .
    end.
    assign
      buf_doc-line-attr.attr-value =
      string(p-exch-code)  + {&delim-par} +
      string(p-exch-rate)  + {&delim-par} +
      string(p-exch-scale) + {&delim-par} +
      string(p-sum-cli)    + {&delim-par} +
      string(p-sum-vat)
      .
  end.

end procedure. /* lineattr-write-add-line-cli */


procedure lineattr-value-add-line-cli :
define input   parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input   parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input   parameter p-cli-type      as character no-undo .
define input   parameter p-cli-code      as integer   no-undo .
define input   parameter p-contract-code as integer   no-undo .
define input   parameter p-host-code     as integer   no-undo .

define output  parameter p-exch-code     as integer   no-undo .
define output  parameter p-exch-rate     as decimal   no-undo .
define output  parameter p-exch-scale    as integer   no-undo .
define output  parameter p-sum-cli       as decimal   no-undo .
define output  parameter p-sum-vat       as decimal   no-undo .

define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :

    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = {&lineattr-add-line-cli} +
                                          {&delim-par} + p-cli-type +
                                          {&delim-par} + string(p-cli-code) +
                                          {&delim-par} + string(p-contract-code) +
                                          {&delim-par} + string(p-host-code)
      no-error .
    if available buf_doc-line-attr then do:
     assign
        p-exch-code  = integer ( entry (1 , buf_doc-line-attr.attr-value,  {&delim-par} ))
        p-exch-rate  = decimal ( entry (2 , buf_doc-line-attr.attr-value, {&delim-par} ))
        p-exch-scale = integer ( entry (3 , buf_doc-line-attr.attr-value, {&delim-par} ))
        p-sum-cli    = decimal ( entry (4 , buf_doc-line-attr.attr-value, {&delim-par} ))
        p-sum-vat    = decimal ( entry (5 , buf_doc-line-attr.attr-value, {&delim-par} ))
       .
     end.
  end.

end procedure. /* lineattr-value-add-line-cli */


/* Значение по классификатору */
function lineattr-get-reason returns character ( buffer local-doc-line for ub.doc-line ) :
  define variable v-code as character no-undo .
  define variable v-type as character no-undo .
  define variable v-gds-code as integer   no-undo .
  { gbl/gds-code.i
    local-doc-line.artic
    local-doc-line.prod-type
    local-doc-line.prod-code
    v-gds-code
    }
  run lineattr-value (
      input   local-doc-line.doc-code ,
      input   v-gds-code              ,
      input   {&lineattr-reason-code} ,
      output  v-code                  ,
      output  v-type ) .
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = integer ( v-code ) no-error.
  if not available ub.trn-reason then do:
     return "" .
  end.
  else do:
     return ub.trn-reason.reason-name .
  end.

end function. /* get-add-gtd */

procedure lineattr-value-parts :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-part-code   as character no-undo .
    define input  parameter p_in-code     as character no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .

    define buffer buf_doc-line-attr for ub.doc-line-attr .

    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + {&delim-par} + trim(p-part-code)  + {&delim-par} + trim(p_in-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.

end procedure.


procedure lineattr-write-parts :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-part-code  as character no-undo .
    define input parameter p_in-code    as character no-undo .
    define input parameter p-code       like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value      as decimal   no-undo .

    define buffer buf_doc-line-attr for ub.doc-line-attr .

    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + {&delim-par}  + trim(p-part-code)  + {&delim-par} + trim(p_in-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + {&delim-par}  + trim(p-part-code)  + {&delim-par} + trim(p_in-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.

/* $Workfile$ e n d */