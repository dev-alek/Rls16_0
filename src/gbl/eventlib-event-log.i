/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание записив логе кассы

Автор: Белоусов Илья Александрович
Дата создания: 12/12/08
Author: Ilia Belousov
Creation date: 12/12/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop proc-name eventlib-event-log

do:
  {&run_proc_eventlib}
    ( input  {1}  /* p-log-level      */
    , input  {2}  /* p-db-num         */
    , input  {3}  /* p-action-item-id */
    , input  {4}  /* p-cash-num       */
    , input  {5}  /* p-cd-mode        */
    , input  {6}  /* p-chk-type       */
    , input  {7}  /* p-d-card         */
    , input  {8}  /* p-description    */
    , input  {9}  /* p-discnt         */
    , input  {10} /* p-doc-code       */
    , input  {11} /* p-doc-qnty       */
    , input  {12} /* p-event-date     */
    , input  {13} /* p-event-id       */
    , input  {14} /* p-event-time     */
    , input  {15} /* p-event-type     */
    , input  {16} /* p-gds-code       */
    , input  {17} /* p-obj-type       */
    , input  {18} /* p-obj-code       */
    , input  {19} /* p-pay-card       */
    , input  {20} /* p-pos-type       */
    , input  {21} /* p-price          */
    , input  {22} /* p-shift-date     */
    , input  {23} /* p-shift-name     */
    , input  {24} /* p-shift-num      */
    , input  {25} /* p-src-code       */
    , input  {26} /* p-tot-sum        */
    , input  {27} /* p-user-id        */
    ) {28} .
end.

/* $Workfile$ e n d */