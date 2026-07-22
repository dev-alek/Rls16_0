/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Копирование в документы а-ля расходная накладна

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/
&scop proc-name lib-trn_copy-ret
{&run_proc_lib-trn}
  (
    input {1}         /*parparentproc        */
  , input {2}         /*pardoc-code          */
  , input {3}         /*pardoc-type          */
  , input {4}         /*parstatus_           */
  , input {5}         /*parinternal          */
  , input {6}         /*parcli-type          */
  , input {7}         /*parcli-code          */
  , input {8}         /*pardiscnt-type       */
  , input {9}         /*partot-calc          */
  , input {10}         /*pardiscnt-pc         */
  , input {11}        /*paragnt              */
  , input {12}        /*parboss              */
  , input {13}        /*parwrkr              */
  , input {14}        /*parbase-rate         */
  , input {15}        /*parbase-scale        */
  , input {16}        /*parexch-code         */
  , input {17}        /*parvat-type          */
  , input {18}        /*pardstdoc-code       */
  , input {19}        /*parinp-discnt-type   */
  , input {20}        /*parinp-discnt-pc     */
  , input {21}        /*parinp-agnt          */
  , input {22}        /*parinp-boss          */
  , input {23}        /*parinp-wrkr          */
  , input {24}        /*parinp-base-rate     */
  , input {25}        /*parinp-base-scale    */
  , input {26}        /*parcash-pay          */
  , input {27}        /*parglob-base-code    */
  , input-output table {28}  /*table for tt-doc-line*/
  , input-output table {29}  /*table for tt-gds-dtl */
  , input-output table {30}  /*table for tt-parts   */
  , input {31}        /*paruse-parts         */
  , input {32}        /*parall-qnty          */
  , input {33}        /*parfix-price          */
  , input {34}        /*parrsrv-fact-qnty    */
  ) {35}.
/* $Workfile$ e n d */