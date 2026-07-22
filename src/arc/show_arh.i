/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Чтение атрибутов главного экрана архивов

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if "{1}" = "def" &then
define variable varis-calend     as integer   no-undo.
define variable varis-shift-num  as logical   no-undo.
define variable vardate-start    as date      no-undo.
define variable vardate-end      as date      no-undo.
define variable varshift-start   as integer   no-undo.
define variable varshift-end     as integer   no-undo.
define variable varext-doc-type  as character no-undo.
define variable varrubl-base     as integer   no-undo.
&endif
&if "{1}" = "body" &then
&scop is-error-get  RUN request-attribute IN adm-broker-hdl ~
                    (INPUT THIS-PROCEDURE,                  ~
                     INPUT 'Container-Source':U,            ~
                     INPUT '~{&prep-attr~}':U) NO-ERROR.    ~
                    if return-value = "" or return-value = ? or return-value = "?" then do: ~
                       &if "{2}" = "" &then return error "Нет атрибута: " + "~{&prep-attr~}" + " для получения данных." &else {2} &endif .~
                    end.
&scop prep-attr main-handle
{&is-error-get}
assign varh_caller-main = widget-handle(return-value).
&scop prep-attr varis-calend
{&is-error-get}
assign varis-calend = integer(return-value).
&scop prep-attr varis-shift-num
{&is-error-get}
assign varis-shift-num = if return-value = 'yes' then yes else no.
&scop prep-attr vardate-start
{&is-error-get}
assign vardate-start = date(return-value).
&scop prep-attr vardate-end
{&is-error-get}
assign vardate-end = date(return-value).
&scop prep-attr varshift-start
{&is-error-get}
assign varshift-start = integer(return-value).
&scop prep-attr varshift-end
{&is-error-get}
assign varshift-end = integer(return-value).
&scop prep-attr varext-doc-type
{&is-error-get}
assign varext-doc-type = return-value.
&scop prep-attr rubl-base
{&is-error-get}
assign varrubl-base = integer(return-value).

&endif
/* $Workfile$ e n d */