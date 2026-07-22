/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выборка по 4-м запроса даты

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Суслов Алексей Юрьевич
Дата создания1: 03/27/06

&add-query       - дополнительное условие на приходные накладные
&break-by-shift  - условие break by
&inc-file        - файл внутри запроса
&gds-buffer      - буффер goods
&include-query   - внутренний подзапрос
&include-query2  - внутренний подзапрос2
&break-by        - условие break by по календарным датам
&no-x            - отмена того или иного case
&clc-ptrl-weight - учет топливных товаров по весу

*/

&scop master-query for each buf_trn-doc where ~
                            buf_trn-doc.obj-type    = parobj-type and ~
                            buf_trn-doc.obj-code    = parobj-code and ~
                            ~{&shift-query~} ~
                            buf_trn-doc.status_     = {&fact} ~
                            {&add-query}, ~
                            {&include-query} ~
                       each buf_doc-line no-lock where ~
                            buf_doc-line.doc-code   = buf_trn-doc.doc-code     and ~
                            buf_doc-line.artic      = {&gds-buffer}.artic     and ~
                            buf_doc-line.prod-type  = {&gds-buffer}.prod-type and ~
                            buf_doc-line.prod-code  = {&gds-buffer}.prod-code ~
                            {&include-query2} ~
                   {&break-by} : ~
                     ~{ {&inc-file} ~
                          &gds-buffer={&gds-buffer} ~
                          &clc-ptrl-weight={&clc-ptrl-weight} ~
                     ~} ~
                   end. /* for each buf_trn-doc */

CASE pardate-shift :
  &if "{&no-1}" <> "yes" &then
    WHEN 1 THEN DO: /* Запрос по календарным датам */
      &scop shift-query  buf_trn-doc.fact-date >= parstart_date and buf_trn-doc.fact-date <= parend_date and
      {&master-query}
    END.
  &endif
  &if "{&no-2}" <> "yes" &then
    WHEN 2 THEN DO: /* Запрос по сменным датам */
      &scop shift-query  buf_trn-doc.shift-date >= parstart_date and buf_trn-doc.shift-date <= parend_date and
      {&master-query}
    END.
  &endif
  &if "{&no-3}" <> "yes" &then
    WHEN 3 THEN DO: /* Запрос по сменным датам c указанием смен */
       &scop shift-query    ( buf_trn-doc.shift-date >  parstart_date        or  ~
                              buf_trn-doc.shift-date  = parstart_date        and ~
                              buf_trn-doc.shift-num  >= parstart_shift_num ) and ~
                            ( buf_trn-doc.shift-date <  parend_date          or  ~
                              buf_trn-doc.shift-date  = parend_date          and ~
                              buf_trn-doc.shift-num  <= parend_shift_num )   and
       {&master-query}
    END.
  &endif
  &if "{&no-4}" <> "yes" &then
    WHEN 4 THEN DO: /* Запрос по конкретной смене в диапазоне сменных суток */
        &scop shift-query   buf_trn-doc.shift-date >= parstart_date      and ~
                            buf_trn-doc.shift-num   = parstart_shift_num and ~
                            buf_trn-doc.shift-date <= parend_date        and ~
                            buf_trn-doc.shift-num   = parend_shift_num   and
       {&master-query}
    END.
  &endif
END CASE. /* pardate-shift */

/* $Workfile$   E n d */