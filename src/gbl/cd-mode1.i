/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

режимы кассы

Автор: Белоусов Илья Александрович
Дата создания: 08/01/08
Author: Ilia Belousov
Creation date: 08/01/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

/* режимы кассы */
&global-define cd-mode-ready         "0"
&global-define cd-mode-sale          "1"
&global-define cd-mode-ret           "2"
&global-define cd-mode-block         "4"
&global-define cd-mode-func          "5"
&global-define cd-mode-close-shift   "6"
&global-define cd-mode-inv           "7"
&global-define cd-mode-wth           "8"
&global-define cd-mode-user-block    "9"

/* подрежимы кассы */
&global-define cd-submode-goods        "0"
&global-define cd-submode-qnty         "1"
&global-define cd-submode-pay          "2"
&global-define cd-submode-card-chk     "3"
&global-define cd-submode-line-dsc     "4"
&global-define cd-submode-tot-dsc      "5"
&global-define cd-submode-find-gds     "6"
&global-define cd-submode-price        "7"
&global-define cd-submode-seller       "8"
/*
&global-define cd-submode-gds-upd      "9"
&global-define cd-submode-card-reg     "10"
&global-define cd-submode-qnty         "11"
*/


/* $Workfile$ e n d */