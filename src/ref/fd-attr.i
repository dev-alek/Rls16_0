/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Атрибуты ПЛАТЕЖА и УДАЛЕННОГО ПЛАТЕЖА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/09/04
Author: Bakhtadze Natalya
Creation date: 12/09/04

АТРИБУТЫ ОДИНАКОВЫЕ
ПРОЦЕДУРЫ РАЗНЫЕ

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/* Дата смены */
&scop bef-fd-attr-shift-date shift-date
&glob fd-attr-shift-date '{&bef-fd-attr-shift-date}':U
&scop type-fd-attr-shift-date {&type-date}
&scop format-fd-attr-shift-date "99/99/9999"
&scop label-fd-attr-shift-date "Дата смены"
&scop tooltip-fd-attr-shift-date "Дата смены"
&scop user-can-edit-fd-attr-shift-date false
&scop output-display-fd-attr-shift-date true
&scop other-fd-attr-shift-date '':u
&scop news-fd-attr-shift-date no


/* П номер смены */
&scop bef-fd-attr-shift-num shift-num
&glob fd-attr-shift-num '{&bef-fd-attr-shift-num}':U
&scop type-fd-attr-shift-num {&type-int}
&scop format-fd-attr-shift-num "99"
&scop label-fd-attr-shift-num "П.смены"
&scop tooltip-fd-attr-shift-num "П.смены"
&scop user-can-edit-fd-attr-shift-num false
&scop output-display-fd-attr-shift-num true
&scop other-fd-attr-shift-num '':u
&scop news-fd-attr-shift-num no


/* номер смены */
&scop bef-fd-attr-shift-name shift-name
&glob fd-attr-shift-name '{&bef-fd-attr-shift-name}':U
&scop type-fd-attr-shift-name {&type-char}
&scop format-fd-attr-shift-name "X(2)"
&scop label-fd-attr-shift-name "№ смены"
&scop tooltip-fd-attr-shift-name "№ смены"
&scop user-can-edit-fd-attr-shift-name false
&scop output-display-fd-attr-shift-name true
&scop other-fd-attr-shift-name '':u
&scop news-fd-attr-shift-name no

/* штрих-код (баркод) блокировки для сервера авторизации АСУ refuler */
&scop bef-fd-attr-barcode barcode
&glob fd-attr-barcode '{&bef-fd-attr-barcode}':U
&scop type-fd-attr-barcode {&type-char}
&scop format-fd-attr-barcode "X(20)"
&scop label-fd-attr-barcode "Штрих-код"
&scop tooltip-fd-attr-barcode "Штрих-код"
&scop user-can-edit-fd-attr-barcode false
&scop output-display-fd-attr-barcode true
&scop other-fd-attr-barcode '':u
&scop news-fd-attr-barcode no

/* идентификатор штрих-кода (баркода) блокировки для сервера авторизации АСУ refuler */
&scop bef-fd-attr-lockid lockid
&glob fd-attr-lockid '{&bef-fd-attr-lockid}':U
&scop type-fd-attr-lockid {&type-char}
&scop format-fd-attr-lockid "X(2)"
&scop label-fd-attr-lockid "ID блокировки чека"
&scop tooltip-fd-attr-lockid "ID блокировки чека"
&scop user-can-edit-fd-attr-lockid false
&scop output-display-fd-attr-lockid true
&scop other-fd-attr-lockid '':u
&scop news-fd-attr-lockid no

/* Банк получатель */
&scop bef-fd-attr-bank-recipient bank-recipient
&glob fd-attr-bank-recipient '{&bef-fd-attr-bank-recipient}':U
&scop type-fd-attr-bank-recipient {&type-char}
&scop format-fd-attr-bank-recipient "X(256)"
&scop label-fd-attr-bank-recipient "Банк-получатель"
&scop tooltip-fd-attr-bank-recipient "Банк-получатель"
&scop user-can-edit-fd-attr-bank-recipient false
&scop output-display-fd-attr-bank-recipient true
&scop other-fd-attr-bank-recipient '':u
&scop news-fd-attr-bank-recipient no


/* Банк вноситель */
&scop bef-fd-attr-bank-deposit bank-deposit
&glob fd-attr-bank-deposit '{&bef-fd-attr-bank-deposit}':U
&scop type-fd-attr-bank-deposit {&type-char}
&scop format-fd-attr-bank-deposit "X(256)"
&scop label-fd-attr-bank-deposit "Банк-вноситель"
&scop tooltip-fd-attr-bank-deposit "Банк-вноситель"
&scop user-can-edit-fd-attr-bank-deposit false
&scop output-display-fd-attr-bank-deposit true
&scop other-fd-attr-bank-deposit '':u
&scop news-fd-attr-bank-deposit no


/* Контрагент для инкассации */
&scop bef-fd-attr-obj-inkas obj-inkas
&glob fd-attr-obj-inkas '{&bef-fd-attr-obj-inkas}':U
&scop type-fd-attr-obj-inkas {&type-char}
&scop format-fd-attr-obj-inkas "X(256)"
&scop label-fd-attr-obj-inkas "ID блокировки чека"
&scop tooltip-fd-attr-obj-inkas "ID блокировки чека"
&scop user-can-edit-fd-attr-obj-inkas false
&scop output-display-fd-attr-obj-inkas true
&scop other-fd-attr-obj-inkas '':u
&scop news-fd-attr-obj-inkas no

&scop bef-fd-attr-pre-vedom pre-vedom
&glob fd-attr-pre-vedom '{&bef-fd-attr-pre-vedom}':U
&scop type-fd-attr-pre-vedom {&type-char}
&scop format-fd-attr-pre-vedom "X(256)"
&scop label-fd-attr-pre-vedom "Атрибут для препроводительной ведомости"
&scop tooltip-fd-attr-pre-vedom "Атрибут для препроводительной ведомости"
&scop user-can-edit-fd-attr-pre-vedom false
&scop output-display-fd-attr-pre-vedom false
&scop other-fd-attr-pre-vedom '':u
&scop news-fd-attr-pre-vedom no

&scop bef-fd-attr-cover_sheet cover_sheet
&glob fd-attr-cover_sheet '{&bef-fd-attr-cover_sheet}':U
&scop type-fd-attr-cover_sheet {&type-char}
&scop format-fd-attr-cover_sheet "X(4000)"
&scop label-fd-attr-cover_sheet "Разбиение по номиналам"
&scop tooltip-fd-attr-cover_sheet "Разбиение по номиналам"
&scop user-can-edit-fd-attr-cover_sheet false
&scop output-display-fd-attr-cover_sheet true
&scop other-fd-attr-cover_sheet '':u
&scop news-fd-attr-cover_sheet no

&scop bef-fd-attr-ParentMoney ParentMoney
&glob fd-attr-ParentMoney '{&bef-fd-attr-ParentMoney}':U
&scop type-fd-attr-ParentMoney {&type-char}
&scop format-fd-attr-ParentMoney "X(4000)"
&scop label-fd-attr-ParentMoney "Ссылка на документ с распределением купюр"
&scop tooltip-fd-attr-ParentMoney "Ссылка на документ с распределением купюр"
&scop user-can-edit-fd-attr-ParentMoney false
&scop output-display-fd-attr-ParentMoney true
&scop other-fd-attr-ParentMoney '':u
&scop news-fd-attr-ParentMoney no

&scop bef-fd-attr-contr-kb contr-kb
&glob fd-attr-contr-kb '{&bef-fd-attr-contr-kb}':U
&scop type-fd-attr-contr-kb {&type-int}
&scop format-fd-attr-contr-kb ">>>9"
&scop label-fd-attr-contr-kb "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"
&scop tooltip-fd-attr-contr-kb "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"
&scop user-can-edit-fd-attr-contr-kb false
&scop output-display-fd-attr-contr-kb true
&scop other-fd-attr-contr-kb '':u
&scop news-fd-attr-contr-kbno

&glob fd-attr-list '{&bef-fd-attr-shift-date},{&bef-fd-attr-shift-num},{&bef-fd-attr-shift-name},~
{&bef-fd-attr-pre-vedom},{&bef-fd-attr-cover_sheet},{&bef-fd-attr-ParentMoney},~
{&bef-fd-attr-barcode},{&bef-fd-attr-lockid},{&bef-fd-attr-bank-recipient},{&bef-fd-attr-bank-deposit},{&bef-fd-attr-obj-inkas}':u


&glob fd-attr-list '':u

&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} . ~
  end.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-type = ~{&type-~{&attr-code~}~}  ~
    p-format = ~{&format-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

&scop attr-news-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-news = ~{&news-~{&attr-code~}~}. ~
  end.



procedure fd-attr-code :

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
      &scop attr-code fd-attr-shift-date
      {&attr-temp-full-code}
      &scop attr-code fd-attr-shift-num
      {&attr-temp-full-code}
      &scop attr-code fd-attr-shift-name
      {&attr-temp-full-code}
      &scop attr-code fd-attr-barcode
      {&attr-temp-full-code}
      &scop attr-code fd-attr-lockid
      {&attr-temp-full-code}
      &scop attr-code fd-attr-cover_sheet
      {&attr-temp-full-code}
      &scop attr-code fd-attr-pre-vedom
      {&attr-temp-full-code}
      &scop attr-code fd-attr-contr-kb
      {&attr-temp-full-code}



      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.
end procedure.

procedure fd-attr-tooltip :

  do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
      &scop attr-code fd-attr-shift-date
      {&attr-temp-code}
      &scop attr-code fd-attr-shift-num
      {&attr-temp-code}
      &scop attr-code fd-attr-shift-name
      {&attr-temp-code}
      &scop attr-code fd-attr-barcode
      {&attr-temp-code}
      &scop attr-code fd-attr-lockid
      {&attr-temp-code}
      &scop attr-code fd-attr-cover_sheet
      {&attr-temp-code}
      &scop attr-code fd-attr-pre-vedom
      {&attr-temp-code}
      &scop attr-code fd-attr-contr-kb
      {&attr-temp-code}



      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.

end procedure.


procedure fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-attr-code     like ub.fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.fin-doc-attr.attr-value no-undo .

define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.

run fd-attr-code in this-procedure
                                  (input  p-attr-code           /* p-code           */
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



find first buf_fin-doc-attr  exclusive-lock  where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code    = p-host-code
      AND buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code  no-error .
  if not available  buf_fin-doc-attr then do:
      create buf_fin-doc-attr.
      assign
      buf_fin-doc-attr.attr-code    = p-attr-code
      buf_fin-doc-attr.attr-value   = p-attr-value
      buf_fin-doc-attr.host-code    = p-host-code
      buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .

  end.
  else do:
&if "{1}" = "force-history" &then
     if buf_fin-doc-attr.attr-value = p-attr-value then do:
       run write-fin-doc-attr-proc  in this-procedure (buffer buf_fin-doc-attr ).
     end.
     else do:
&endif
       assign
       buf_fin-doc-attr.attr-value = p-attr-value.
&if "{1}" = "force-history" &then
     end.
&endif

  end.
 end. /* do */
end procedure. /* fin-doc-attr-write */


procedure fd-attr-exist :

  do
  on error undo, return error
  :
    define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
    define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
    define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .

    define buffer buf_fin-doc-attr for {&db-name}.fin-doc-attr .

    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .

    run fd-attr-code in this-procedure
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

    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error .

    if  available buf_fin-doc-attr then do:
      p-exist = yes.
    end.
  end.

end procedure.



procedure fd-attr-delete :
  do
  on error undo, return error
  :
  define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
  define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
  define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.

    define buffer buf_fin-doc-attr for {&db-name}.fin-doc-attr .

    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .

    run fd-attr-code in this-procedure
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
    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_fin-doc-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_fin-doc-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.

end procedure.



procedure fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.fin-doc-attr.fin-doc-code     no-undo .
define input  parameter p-attr-code    like ub.fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.fin-doc-attr.attr-value   no-undo .

define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.

run fd-attr-code in this-procedure
  (input  p-attr-code       /* p-code           */
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

find first buf_fin-doc-attr no-lock where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code     = p-host-code
      AND buf_fin-doc-attr.fin-doc-code = p-fin-doc-code      no-error .
  if available  buf_fin-doc-attr then do:
    assign
    p-attr-value = buf_fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.


 end. /* do */
end procedure. /* fin-doc-attr-value */

procedure fd-attr-news :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */

    case p-code :
      &scop attr-code fd-attr-shift-date
      {&attr-news-code}
      &scop attr-code fd-attr-shift-num
      {&attr-news-code}
      &scop attr-code fd-attr-shift-name
      {&attr-news-code}
      &scop attr-code fd-attr-barcode
      {&attr-news-code}
      &scop attr-code fd-attr-lockid
      {&attr-news-code}
      &scop attr-code fd-attr-cover_sheet
      {&attr-news-code}
      &scop attr-code fd-attr-pre-vedom
      {&attr-news-code}
      
      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут платежа " + " " + p-code .
      end.
    end.
  end.
end procedure.


procedure c-fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.c-fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.c-fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input parameter p-attr-code     like ub.c-fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.c-fin-doc-attr.attr-value no-undo .

define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.

run fd-attr-code in this-procedure
                                  (input  p-attr-code           /* p-code           */
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



find first buf_c-fin-doc-attr  exclusive-lock  where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.host-code    = p-host-code
      AND buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .
  if not available  buf_c-fin-doc-attr then do:
      create buf_c-fin-doc-attr.
      assign
      buf_c-fin-doc-attr.attr-code    = p-attr-code
      buf_c-fin-doc-attr.attr-value   = p-attr-value
      buf_c-fin-doc-attr.host-code    = p-host-code
      buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .

  end.
  else do:
        buf_c-fin-doc-attr.attr-value   = p-attr-value .
  end.
 end. /* do */
end procedure. /* c-fin-doc-attr-write */



procedure c-fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .

define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.

run fd-attr-code in this-procedure
  (input  p-attr-code       /* p-code           */
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

find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      AND buf_c-fin-doc-attr.host-code      = p-host-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .

  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.


 end. /* do */
end procedure. /* c-fin-doc-attr-value */

procedure c-fin-doc-attr-value-nextchip :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .

define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.

run fd-attr-code in this-procedure
  (input  p-attr-code       /* p-code           */
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

find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      and buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      and buf_c-fin-doc-attr.host-code      = p-host-code
      and buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      and buf_c-fin-doc-attr.chip-num         > p-chip-num      no-error .

  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.


 end. /* do */
end procedure. /* c-fin-doc-attr-value */


&if "{2}" <> "" &then
procedure fin-doc-temp-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-attr-code     like ub.fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.fin-doc-attr.attr-value no-undo .

define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_temp-fin-doc-attr for {2}.

run fd-attr-code in this-procedure
                                  (input  p-attr-code           /* p-code           */
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

find first buf_temp-fin-doc-attr  exclusive-lock  where
          buf_temp-fin-doc-attr.attr-code    = p-attr-code
      AND buf_temp-fin-doc-attr.host-code    = p-host-code
      AND buf_temp-fin-doc-attr.fin-doc-code     = p-fin-doc-code  no-error .
  if not available  buf_temp-fin-doc-attr then do:
      create buf_temp-fin-doc-attr.
      assign
      buf_temp-fin-doc-attr.attr-code    = p-attr-code
      buf_temp-fin-doc-attr.attr-value   = p-attr-value
      buf_temp-fin-doc-attr.host-code    = p-host-code
      buf_temp-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
    assign
    buf_temp-fin-doc-attr.attr-value = p-attr-value.
 end. /* do */
end procedure. /* fin-doc-attr-temp-write */

procedure fin-doc-temp-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.fin-doc-attr.fin-doc-code     no-undo .
define input  parameter p-attr-code    like ub.fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.fin-doc-attr.attr-value   no-undo .

define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for {2}.

run fd-attr-code in this-procedure
  (input  p-attr-code       /* p-code           */
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

find first buf_fin-doc-attr no-lock where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code     = p-host-code
      AND buf_fin-doc-attr.fin-doc-code = p-fin-doc-code      no-error .
  if available  buf_fin-doc-attr then do:
    assign
    p-attr-value = buf_fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.


 end. /* do */
end procedure. /* fin-doc-attr-value */
&endif

/* $Workfile$ e n d */