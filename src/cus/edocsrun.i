/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры запуска RUM для EDOC-NN - профайл 37

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/13/08
Author: Bakhtadze Natalya
Creation date: 10/13/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


procedure  oxml-routing-order:
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

define variable v-uniq-key-rec as character no-undo .
define buffer buf_thbj-attr for ub.thbj-attr.

  do
  on error undo, return error
  :

    find first buf_thbj-attr no-lock where
              buf_thbj-attr.upper-prop-code = {&attr-rum}
          and buf_thbj-attr.prop-code = {&attr-rum_edoc}
          and buf_thbj-attr.obj-type = ''
          and buf_thbj-attr.obj-code = 0
          and buf_thbj-attr.property-value-logical = yes
          no-error.
    if not available buf_thbj-attr then do:
      message
      "В Вашей системе нет настроек для операций электронного документооборота"
      view-as alert-box error .
      undo, return ''.
    end.
    run gen-key-rec in this-procedure (
                                      input  {&table_thbj-attr}
                                    ,input (buffer buf_thbj-attr:handle)
                                    ,output v-uniq-key-rec).
    run str/edocrum.p
      (
      input parparentproc
      ,input p-parent-handle
      ,input p-log-handle
      ,input {&edoc-proc_batchwork-routing_order}
      ,input v-profile-id /*p-profile-id*/
      ,input {&edoc-proc_18} /*p-codex-id*/
      ,input {&edoc-proc_18_batchwork-routing_order_2} /*p-ruleset-id*/
      ,input g#db-num        /*current-db-num*/
      ,input v-uniq-key-rec
      ,input ( buf_ord-doc.doc-code + {&delim-par} + '')
      ,input yes /*p-save*/
      ) no-error .
  end.
end procedure. /* local */


procedure  oxml-routing-rcv:
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

define variable v-uniq-key-rec as character no-undo .
define buffer buf_thbj-attr for ub.thbj-attr.

  do
  on error undo, return error
  :

    find first buf_thbj-attr no-lock where
              buf_thbj-attr.upper-prop-code = {&attr-rum}
          and buf_thbj-attr.prop-code = {&attr-rum_edoc}
          and buf_thbj-attr.obj-type = ''
          and buf_thbj-attr.obj-code = 0
          and buf_thbj-attr.property-value-logical = yes
          no-error.
    if not available buf_thbj-attr then do:
      message
      "В Вашей системе нет настроек для операций электронного документооборота"
      view-as alert-box error .
      undo, return ''.
    end.
    run gen-key-rec in this-procedure (
                                      input  {&table_thbj-attr}
                                    ,input (buffer buf_thbj-attr:handle)
                                    ,output v-uniq-key-rec).
    run str/edocrum.p
      (
      input parparentproc
      ,input p-parent-handle
      ,input p-log-handle
      ,input {&edoc-proc_batchwork-routing_rcv}
      ,input v-profile-id /*p-profile-id*/
      ,input {&edoc-proc_18} /*p-codex-id*/
      ,input {&edoc-proc_18_batchwork-routing_rcv_6} /*p-ruleset-id*/
      ,input g#db-num        /*current-db-num*/
      ,input v-uniq-key-rec
      ,input ( buf_trn-doc.doc-code + {&delim-par} + '')
      ,input yes /*p-save*/
      ) no-error .
  end.
end procedure. /* oxml-routing-rcv */

