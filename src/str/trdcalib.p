block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека процедур для работы с атрибутами документа

Автор: Чернова Светлана Александровна
Дата создания: 12/13/06
Author: Svetlana Chernova
Creation date: 12/13/06

create: Булгаков Андрей Николаевич
Дата создания: 04/12/05

*/

/* ********************************************************************************************************************* *\
 *                                                                                                                       *
 * procedure trdcalib_tdat-val - trdcattr-value                                                                          *
 * procedure trdcalib_tdatinv-val - trdcattrinv-value                                                                          *
 * procedure trdcalib_tdat-wrt - trdcattr-write
 * procedure trdcalib_tdatinv-wrt - trdcattrinv-write                                                                       *
 * procedure trdcalib_tdat-xst - trdcattr-exist                                                                          *
 * procedure trdcalib_tdat-del - trdcattr-delete                                                                         *
 * procedure trdcalib_tdat-cod - trdcattr-code                                                                           *
 * procedure trdcalib_tdat-oth - proc-other                                                                              *
 *                                                                                                                       *
\* ********************************************************************************************************************* */

using ibs.th.gbl.gbl-hndllib from propath.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Библиотека процедур для работы с атрибутами документа":U.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/trdcalib.i }

/*----------------------------ВНИМАНИЕ!!!--------------------------------------------------- */
/* значения атрибутов имеющих логический тип должны записываться в базу чисто как yes или no */
/* все форматирование осуществлять на верхнем уровне                                         */

/* Номер партии для документа межфирменного перемещения */


if valid-handle( g#trdcalib ) and g#trdcalib <> this-procedure :handle then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 0 ) vss-description skip( 1 )
          "trdcalib.p: попытка повторной загрузки библиотеки" skip( 1 )
          g#trdcalib                     skip( 0 )
          g#trdcalib     :type           skip( 0 )
          g#trdcalib     :file-name      skip( 0 )
          valid-handle( g#trdcalib     ) skip( 0 )
          this-procedure :handle         skip( 0 )
          this-procedure :type           skip( 0 )
          this-procedure :file-name      skip( 0 )
          valid-handle( this-procedure ) skip( 0 )
  view-as alert-box error title " О Ш И Б К А  ! ! ! ".
  undo, return error "trdcalib.p: попытка повторной загрузки библиотеки".
end.
else do:
  assign
    g#trdcalib = this-procedure :handle
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#trdcalib", g#trdcalib).
  delete object gbl-hndllibObj.
end.

on delete of this-procedure do:
  assign
    g#trdcalib = ?
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#trdcalib", g#trdcalib).
  delete object gbl-hndllibObj.
end.

procedure trdcalib_tdat-val :
  define  input parameter p-doc-code like ub.doc-attr.doc-code   no-undo.
  define  input parameter p-code     like ub.doc-attr.attr-code  no-undo.
  define output parameter p-value    like ub.doc-attr.attr-value no-undo.
  define output parameter p-type     as   character              no-undo.

  define buffer buf_doc-attr for ub.doc-attr.

  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .
  do on error undo, return error return-value :
    { str/tdat-cod.i p-code
                 p-type
                 v-format
                 v-fillin_width
                 v-fillin_height
                 v-label
                 v-user-can-edit
                 v-output-display
                 v-other
                 v-proc-attr
                 v-full-screen-val
                 v-sort
                 no-error }
    if error-status :error then do: undo, return error return-value. end.

    find first buf_doc-attr no-lock where
               buf_doc-attr.doc-code  = p-doc-code and
               buf_doc-attr.attr-code = p-code     no-error.
    assign p-value = ( if available buf_doc-attr then buf_doc-attr.attr-value else
                     ( if p-type = {&type-log} then "no":U else "":U ) ).
  end. /* on error */
end procedure. /* trdcalib_tdat-val */

procedure trdcalib_tdatinv-val :
  define  input parameter p-doc-code like ub.inv-doc-attr.doc-code   no-undo.
  define  input parameter p-code     like ub.inv-doc-attr.attr-code  no-undo.
  define output parameter p-value    like ub.inv-doc-attr.attr-value no-undo.
  define output parameter p-type     as   character              no-undo.

  define buffer buf_doc-attr for ub.inv-doc-attr.

  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .
  do on error undo, return error return-value :
    { str/tdatinv-cod.i p-code
                 p-type
                 v-format
                 v-fillin_width
                 v-fillin_height
                 v-label
                 v-user-can-edit
                 v-output-display
                 v-other
                 v-proc-attr
                 v-full-screen-val
                 v-sort
                 no-error }
    if error-status :error then do: undo, return error return-value. end.

    find first buf_doc-attr no-lock where
               buf_doc-attr.doc-code  = p-doc-code and
               buf_doc-attr.attr-code = p-code     no-error.
    assign p-value = ( if available buf_doc-attr then buf_doc-attr.attr-value else
                     ( if p-type = {&type-log} then "no":U else "":U ) ).
  end. /* on error */
end procedure. /* trdcalib_tdatinv-val */

procedure trdcalib_tdat-wrt :
  define input parameter p-doc-code like ub.doc-attr.doc-code   no-undo.
  define input parameter p-code     like ub.doc-attr.attr-code  no-undo.
  define input parameter p-value    like ub.doc-attr.attr-value no-undo.

  define buffer buf_doc-attr for ub.doc-attr.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .

  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-sort           as integer   no-undo .

  do on error undo, return error return-value :
    { str/tdat-cod.i p-code
                 v-type
                 v-format
                 v-fillin_width
                 v-fillin_height
                 v-label
                 v-user-can-edit
                 v-output-display
                 v-other
                 v-proc-attr
                 v-full-screen-val
                 v-sort
                 no-error }

    if error-status :error then do: undo, return error return-value. end.

    find first buf_doc-attr exclusive-lock where
               buf_doc-attr.doc-code  = p-doc-code and
               buf_doc-attr.attr-code = p-code     no-error.
    if not available buf_doc-attr then do:
      create buf_doc-attr.
      assign buf_doc-attr.doc-code  = p-doc-code
             buf_doc-attr.attr-code = p-code.
    end.
    assign buf_doc-attr.attr-value = p-value.
  end. /* on error */
end procedure. /* trdcalib_tdat-wrt */

procedure trdcalib_tdatinv-wrt :
  define input parameter p-doc-code like ub.inv-doc-attr.doc-code   no-undo.
  define input parameter p-code     like ub.inv-doc-attr.attr-code  no-undo.
  define input parameter p-value    like ub.inv-doc-attr.attr-value no-undo.

  define buffer buf_doc-attr for ub.inv-doc-attr.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .

  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-sort           as integer   no-undo .

  do on error undo, return error return-value :
    { str/tdat-cod.i p-code
                 v-type
                 v-format
                 v-fillin_width
                 v-fillin_height
                 v-label
                 v-user-can-edit
                 v-output-display
                 v-other
                 v-proc-attr
                 v-full-screen-val
                 v-sort
                 no-error }

    if error-status :error then do: undo, return error return-value. end.

    find first buf_doc-attr exclusive-lock where
               buf_doc-attr.doc-code  = p-doc-code and
               buf_doc-attr.attr-code = p-code     no-error.
    if not available buf_doc-attr then do:
      create buf_doc-attr.
      assign buf_doc-attr.doc-code  = p-doc-code
             buf_doc-attr.attr-code = p-code.
    end.
    assign buf_doc-attr.attr-value = p-value.
  end. /* on error */
end procedure. /* trdcalib_tdatinv-wrt */

procedure trdcalib_tdat-xst :
  define  input parameter p-doc-code like ub.doc-attr.doc-code  no-undo.
  define  input parameter p-code     like ub.doc-attr.attr-code no-undo.
  define output parameter p-exist    as   logical               no-undo.

  define buffer buf_doc-attr for ub.doc-attr.

  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .

  do on error undo, return error return-value :
    { str/tdat-cod.i p-code
                 v-type
                 v-format
                 v-fillin_width
                 v-fillin_height
                 v-label
                 v-user-can-edit
                 v-output-display
                 v-other
                 v-proc-attr
                 v-full-screen-val
                 v-sort
                 no-error }

    if error-status :error then do: undo, return error return-value. end.

    find first buf_doc-attr no-lock where
               buf_doc-attr.doc-code  = p-doc-code and
               buf_doc-attr.attr-code = p-code     no-error.
    if available buf_doc-attr then do: p-exist = yes. end.
  end. /* on error */
end procedure. /* trdcalib_tdat-xst */

procedure trdcalib_tdat-del :
  define  input parameter p-doc-code like ub.doc-attr.doc-code  no-undo.
  define  input parameter p-code     like ub.doc-attr.attr-code no-undo.
  define output parameter p-deleted  as   logical               no-undo.

  define buffer buf_doc-attr for ub.doc-attr.

  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .
  do on error undo, return error return-value :
    { str/tdat-cod.i p-code
                 v-type
                 v-format
                 v-fillin_width
                 v-fillin_height
                 v-label
                 v-user-can-edit
                 v-output-display
                 v-other
                 v-proc-attr
                 v-full-screen-val
                 v-sort
                 no-error }

    if error-status :error then do: undo, return error return-value. end.

    find first buf_doc-attr exclusive-lock where
               buf_doc-attr.doc-code  = p-doc-code and
               buf_doc-attr.attr-code = p-code     no-error no-wait.
    if not available buf_doc-attr then do:
      assign p-deleted = no.
    end.
    else do:
      delete buf_doc-attr.
      assign p-deleted = yes.
    end.
  end. /* on error */
end procedure. /* trdcalib_tdat-del */

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign p-label          = ~{&label-~{&attr-code~}~} ~
           p-type           = ~{&type-~{&attr-code~}~}  ~
           p-format         = ~{&format-~{&attr-code~}~} ~
           p-fillin_width   = ~{&fillin_width-~{&attr-code~}~} ~
           p-fillin_height  = ~{&fillin_height-~{&attr-code~}~} ~
           p-label          = ~{&label-~{&attr-code~}~} ~
           p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
           p-output-display = ~{&output-display-~{&attr-code~}~} ~
           p-sort           = ~{&sort-~{&attr-code~}~} ~
           p-proc-attr      = '' ~
           p-other          = ~{&other-~{&attr-code~}~} . ~
&if '~{&proc-~{&attr-code~}~} ' <> '' &then  p-proc-attr = ~{&proc-~{&attr-code~}~}  .  &endif ~
  end.

procedure trdcalib_tdat-cod :
  define  input parameter p-code           as character no-undo. /* код атрибута    */
  define output parameter p-type           as character no-undo. /* тип атрибута    */
  define output parameter p-format         as character no-undo. /* формат атрибута */
  define output parameter p-fillin_width   as integer   no-undo. /* ширина          */
  define output parameter p-fillin_height  as integer   no-undo. /* высота          */
  define output parameter p-label          as character no-undo. /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo. /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo. /* виден в броусе */
  define output parameter p-other          as character no-undo. /* еще чего - нибудь */
  define output parameter p-proc-attr       as character no-undo. /* процедура корректировки */
  define output parameter p-full-screen-val as character no-undo. /* screen-value */
  define output parameter p-sort as integer   no-undo .

  do on error undo, return error return-value :
    case p-code :
      &scop attr-code trdcattr-hold-part-code
      {&attr-temp-full-code}
      &scop attr-code trdcattr-dov
      {&attr-temp-full-code}
      &scop attr-code trdcattr-dids
      {&attr-temp-full-code}
      &scop attr-code trdcattr-nids
      {&attr-temp-full-code}
      &scop attr-code trdcattr-negais
      {&attr-temp-full-code}
      &scop attr-code trdcattr-egais
      {&attr-temp-full-code}
      &scop attr-code trdcattr-ddog
      {&attr-temp-full-code}
      &scop attr-code trdcattr-ndog
      {&attr-temp-full-code}
      &scop attr-code trdcattr-dsf
      {&attr-temp-full-code}
      &scop attr-code trdcattr-nsf
      {&attr-temp-full-code}
      &scop attr-code trdcattr-addsum
      {&attr-temp-full-code}
      &scop attr-code trdcattr-clcasol
      {&attr-temp-full-code}
      &scop attr-code trdcattr-clcaswt
      {&attr-temp-full-code}
      &scop attr-code trdcattr-scanfile
      {&attr-temp-full-code}
      &scop attr-code trdcattr-indoclnsum
      {&attr-temp-full-code}
      &scop attr-code trdcattr-purchlimit
      {&attr-temp-full-code}
      &scop attr-code trdcattr-purchcodelist
      {&attr-temp-full-code}
      &scop attr-code trdcattr-expense_own
      {&attr-temp-full-code}
      &scop attr-code trdcattr-envd
      {&attr-temp-full-code}
      &scop attr-code trdcattr-ord_time
      {&attr-temp-full-code}
      &scop attr-code trdcattr-dchek
      {&attr-temp-full-code}
      &scop attr-code trdcattr-befpay
      {&attr-temp-full-code}
      &scop attr-code trdcattr-ord_nchek
      {&attr-temp-full-code}
      &scop attr-code trdcattr-deliv
      {&attr-temp-full-code}
      &scop attr-code trdcattr-sumwrk
      {&attr-temp-full-code}
      &scop attr-code trdcattr-sumsrk
      {&attr-temp-full-code}
      &scop attr-code trdcattr-ord_adr
      {&attr-temp-full-code}
      &scop attr-code trdcattr-ord_hwo
      {&attr-temp-full-code}
      &scop attr-code trdcattr-fbroperator
      {&attr-temp-full-code}
      &scop attr-code trdcattr-fbrauto
      {&attr-temp-full-code}
      &scop attr-code trdcattr-rsrv-doc-list
      {&attr-temp-full-code}
      &scop attr-code trdcattr-postdchek
      {&attr-temp-full-code}
      &scop attr-code trdcattr-postpay
      {&attr-temp-full-code}
      &scop attr-code trdcattr-postNchek
      {&attr-temp-full-code}
      &scop attr-code trdcattr-frsrv-date
      {&attr-temp-full-code}
      &scop attr-code trdcattr-ord_phone
      {&attr-temp-full-code}
      &scop attr-code trdcattr-ord_dl
      {&attr-temp-full-code}
      &scop attr-code trdcattr-ord_contact
      {&attr-temp-full-code}
      &scop attr-code trdcattr-m-inc
      {&attr-temp-full-code}
      &scop attr-code trdcattr-qntyplace
      {&attr-temp-full-code}
      &scop attr-code trdcattr-discnt-stop
      {&attr-temp-full-code}
      &scop attr-code trdcattr-discnt-other
      {&attr-temp-full-code}
      &scop attr-code trdcattr-dfindoc
      {&attr-temp-full-code}
      &scop attr-code trdcattr-nfindoc
      {&attr-temp-full-code}
      &scop attr-code trdcattr-place-storage
      {&attr-temp-full-code}
      &scop attr-code trdcattr-packer
      {&attr-temp-full-code}
      &scop attr-code trdcattr-dispath
      {&attr-temp-full-code}
      &scop attr-code trdcattr-price-target
      {&attr-temp-full-code}
      &scop attr-code trdcattr-edi
      {&attr-temp-full-code}
      &scop attr-code trdcattr-ddov
      {&attr-temp-full-code}
      &scop attr-code trdcattr-ndov
      {&attr-temp-full-code}
      &scop attr-code trdcattr-recipient
      {&attr-temp-full-code}
      &scop attr-code trdcattr-shipper
      {&attr-temp-full-code}
      &scop attr-code trdcattr-auto
      {&attr-temp-full-code}
      &scop attr-code trdcattr-driver
      {&attr-temp-full-code}
      &scop attr-code trdcattr-print-num
      {&attr-temp-full-code}
      &scop attr-code trdcattr-idCountryContr
      {&attr-temp-full-code}
      &scop attr-code trdcattr-oldsuppcntr
      {&attr-temp-full-code}
      &scop attr-code trdcattr-car-time
      {&attr-temp-full-code}
      &scop attr-code trdcattr-t_pass-fname
      {&attr-temp-full-code}
      &scop attr-code trdcattr-t_pass-position
      {&attr-temp-full-code}
      &scop attr-code trdcattr-t_accept-fname
      {&attr-temp-full-code}
      &scop attr-code trdcattr-t_accept-position
      {&attr-temp-full-code}
      &scop attr-code trdcattr-ndovwho
      {&attr-temp-full-code}
      &scop attr-code trdcattr-nosn
      {&attr-temp-full-code}
      &scop attr-code trdcattr-first-price
      {&attr-temp-full-code}
      &scop attr-code trdcattr-relprpdf
      {&attr-temp-full-code}
      &scop attr-code trdcattr-ora-exp-seq-num
      {&attr-temp-full-code}
      &scop attr-code trdcattr-need-saledc
      {&attr-temp-full-code}
      &scop attr-code trdcattr-dateinv
      {&attr-temp-full-code}
      &scop attr-code trdcattr-ser_on_pack
      {&attr-temp-full-code}
      &scop attr-code trdcattr-cargo-desc
      {&attr-temp-full-code}
      &scop attr-code trdcattr-carry-type
      {&attr-temp-full-code}
      &scop attr-code trdcattr-cargo-mass
      {&attr-temp-full-code}
      &scop attr-code trdcattr-exp-trans
      {&attr-temp-full-code}
      &scop attr-code trdcattr-zakaz-date
      {&attr-temp-full-code}
      &scop attr-code trdcattr-zakaz-number
      {&attr-temp-full-code}
      &scop attr-code trdcattr-delivery-date
      {&attr-temp-full-code}
      &scop attr-code trdcattr-delivery-time
      {&attr-temp-full-code}
      &scop attr-code trdcattr-ptbobj
      {&attr-temp-full-code}
      &scop attr-code trdcattr-ptb-item-pour
      {&attr-temp-full-code}
      &scop attr-code trdcattr-autoent
      {&attr-temp-full-code}
      &scop attr-code trdcattr-car-num
      {&attr-temp-full-code}
      &scop attr-code trdcattr-fio-driver
      {&attr-temp-full-code}
      &scop attr-code trdcattr-time-income
      {&attr-temp-full-code}
      &scop attr-code trdcattr-time-pour
      {&attr-temp-full-code}
      &scop attr-code trdcattr-time-start
      {&attr-temp-full-code}
      &scop attr-code trdcattr-time-end
      {&attr-temp-full-code}
      &scop attr-code trdcattr-date-pour
      {&attr-temp-full-code}
      &scop attr-code trdcattr-inspection-cert
      {&attr-temp-full-code}
      &scop attr-code trdcattr-date-cert
      {&attr-temp-full-code}
      &scop attr-code trdcattr-condition
      {&attr-temp-full-code}
      &scop attr-code trdcattr-seals-condition
      {&attr-temp-full-code}
      &scop attr-code trdcattr-doc-not
      {&attr-temp-full-code}
      &scop attr-code trdcattr-spisok-not-doc
      {&attr-temp-full-code}
      &scop attr-code trdcattr-acc-ship
      {&attr-temp-full-code}
      &scop attr-code trdcattr-is-fuel
      {&attr-temp-full-code}
      &scop attr-code trdcattr-techpass
      {&attr-temp-full-code}
      &scop attr-code trdcattr-othermoves
      {&attr-temp-full-code}
      &scop attr-code trdcattr-is-auto-trn
      {&attr-temp-full-code}
      &scop attr-code trdcattr-is-lgas
      {&attr-temp-full-code}
      &scop attr-code trdcattr-is-lgas-corr
      {&attr-temp-full-code}
      &scop attr-code trdcattr-trn-lgas-corr
      {&attr-temp-full-code}
      &scop attr-code trdcattr-is-return
      {&attr-temp-full-code}
      &scop attr-code trdcattr-edo-return
      {&attr-temp-full-code}
      &scop attr-code trdcattr-date-start
      {&attr-temp-full-code}
      &scop attr-code trdcattr-date-end
      {&attr-temp-full-code}
      &scop attr-code trdcattr-inv-introduce
      {&attr-temp-full-code}
      &scop attr-code trdcattr-clear-ac
      {&attr-temp-full-code}
      &scop attr-code trdcattr-is-not-close-fact-news
      {&attr-temp-full-code}
      &scop attr-code trdcattr-prikaz-number
      {&attr-temp-full-code}
      &scop attr-code trdcattr-prikaz-date
      {&attr-temp-full-code}
      &scop attr-code trdcattr-inv-date
      {&attr-temp-full-code}      
      &scop attr-code trdcattr-fio-agent
      {&attr-temp-full-code}
      &scop attr-code trdcattr-pos-agent
      {&attr-temp-full-code}
      &scop attr-code trdcattr-fio-player1
      {&attr-temp-full-code}  
      &scop attr-code trdcattr-pos-player1
      {&attr-temp-full-code}  
      &scop attr-code trdcattr-fio-player2
      {&attr-temp-full-code}  
      &scop attr-code trdcattr-pos-player2
      {&attr-temp-full-code}  
      &scop attr-code trdcattr-fio-player3
      {&attr-temp-full-code}  
      &scop attr-code trdcattr-pos-player3
      {&attr-temp-full-code}        
      &scop attr-code sugtpattr-massa-sug
      {&attr-temp-full-code}
      &scop attr-code sugtpattr-teh-loss
      {&attr-temp-full-code}
      &scop attr-code sugtpattr-err-allow
      {&attr-temp-full-code}
      &scop attr-code trdcattr-date-income
      {&attr-temp-full-code}
      &scop attr-code trdcattr-date-pasport
      {&attr-temp-full-code}
      &scop attr-code trdcattr-num-pasport
      {&attr-temp-full-code}
      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute( 'неизвестный атрибут документа "&1"', p-code ).
      end.
    end case. /* p-code */
  end. /* on error */
end procedure. /* trdcalib_tdat-cod */

procedure trdcalib_tdatinv-cod :
  define  input parameter p-code           as character no-undo. /* код атрибута    */
  define output parameter p-type           as character no-undo. /* тип атрибута    */
  define output parameter p-format         as character no-undo. /* формат атрибута */
  define output parameter p-fillin_width   as integer   no-undo. /* ширина          */
  define output parameter p-fillin_height  as integer   no-undo. /* высота          */
  define output parameter p-label          as character no-undo. /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo. /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo. /* виден в броусе */
  define output parameter p-other          as character no-undo. /* еще чего - нибудь */
  define output parameter p-proc-attr       as character no-undo. /* процедура корректировки */
  define output parameter p-full-screen-val as character no-undo. /* screen-value */
  define output parameter p-sort as integer   no-undo .

  do on error undo, return error return-value :
    case p-code :
      &scop attr-code trdcattr-prikaz-number
      {&attr-temp-full-code}
      &scop attr-code trdcattr-prikaz-date
      {&attr-temp-full-code}
      &scop attr-code trdcattr-inv-date
      {&attr-temp-full-code}      
      &scop attr-code trdcattr-fio-agent
      {&attr-temp-full-code}
      &scop attr-code trdcattr-pos-agent
      {&attr-temp-full-code}
      &scop attr-code trdcattr-fio-player1
      {&attr-temp-full-code}  
      &scop attr-code trdcattr-pos-player1
      {&attr-temp-full-code}  
      &scop attr-code trdcattr-fio-player2
      {&attr-temp-full-code}  
      &scop attr-code trdcattr-pos-player2
      {&attr-temp-full-code}  
      &scop attr-code trdcattr-fio-player3
      {&attr-temp-full-code}  
      &scop attr-code trdcattr-pos-player3
      {&attr-temp-full-code}        
      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute( 'неизвестный атрибут документа "&1"', p-code ).
      end.
    end case. /* p-code */
  end. /* on error */
end procedure. /* trdcalib_tdatinv-cod */

/* Обработка v-other */
procedure trdcalib_tdat-oth :
  define input parameter p-doc-code as character no-undo.
  define input parameter p-code     as character no-undo. /* код атрибута */
  define input parameter p-value    as character no-undo. /* значение атрибута */

  define variable v-type           as character no-undo. /* тип атрибута    */
  define variable v-format         as character no-undo. /* формат атрибута */
  define variable v-fillin_width   as integer   no-undo. /* ширина          */
  define variable v-fillin_height  as integer   no-undo. /* высота          */
  define variable v-label          as character no-undo. /* лабел атрибута  */
  define variable v-user-can-edit  as logical   no-undo. /* пользователь может изменять в броусе */
  define variable v-output-display as logical   no-undo. /* виден в броусе  */
  define variable v-other          as character no-undo. /* еще чего-нибудь */
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .

  define buffer buf_doc-attr for ub.doc-attr.
  define buffer nakl_trn-doc for ub.trn-doc.
  define buffer bf_trn-doc   for ub.trn-doc.

  do on error undo, return error return-value :
     { str/tdat-cod.i p-code
                  v-type
                  v-format
                  v-fillin_width
                  v-fillin_height
                  v-label
                  v-user-can-edit
                  v-output-display
                  v-other
                  v-proc-attr
                  v-full-screen-val
                  v-sort
                  no-error }

    if lookup( {&other-trdcattr-frsrv-date}, v-other ) > 0 and p-value <> "":U then do:
       find first bf_trn-doc exclusive-lock where
                  bf_trn-doc.doc-code = p-doc-code.
       assign bf_trn-doc.flora-order-date = date( p-value ).
       find first nakl_trn-doc exclusive-lock where
                  nakl_trn-doc.doc-code = bf_trn-doc.out-code no-error.
        if not error-status :error then do:
          assign nakl_trn-doc.flora-order-date = date( p-value ).
        end.
    end. /* if lookup( {&other-trdcattr-frsrv-date}, v-other ) > 0 */

    /* Даты  постоплаты */
    if lookup( "postdchek":U, v-other ) > 0 and p-value <> "":U then do:
      find first bf_trn-doc exclusive-lock where
                 bf_trn-doc.doc-code = p-doc-code.
      assign bf_trn-doc.flora-pay-date = date( p-value ).
      find first nakl_trn-doc exclusive-lock where
                 nakl_trn-doc.doc-code = bf_trn-doc.out-code no-error.
      if not error-status :error then do:
        assign nakl_trn-doc.flora-pay-date  = date( p-value ).
      end.
    end. /* if lookup( "postdchek":U, v-other ) > 0 */

    /* отправить по новостям самостоятельно без документа. */
    if lookup( "nws":U, v-other ) > 0 then do:
      find first bf_trn-doc no-lock where
                 bf_trn-doc.doc-code = p-doc-code /* and
                 bf_trn-doc.status_  = {&ready} */ no-error.
      if available bf_trn-doc then do:
        /* проверить активность стороны ??? */
        find first buf_doc-attr no-lock where
                   buf_doc-attr.doc-code  = p-doc-code and
                   buf_doc-attr.attr-code = p-code     no-error.
        run str/callnews.p ( input "doc-attr", input ( buffer buf_doc-attr :handle ) ) no-error.
        if error-status :error then do:
          message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                  "Невозможно маршрутизировать doc-attr для отправки в новости" skip( 0 )
                  "Документ:" '"' + bf_trn-doc.doc-code    + '"' skip( 0 )
                  "Атрибут:"  '"' + buf_doc-attr.attr-code + '"' skip( 0 )
                  error-status :get-message( 1 ) skip( 0 )
                  error-status :get-message( 2 ) skip( 0 )
                  error-status :get-message( 3 ) skip( 0 )
                  "return-value = " return-value skip( 0 )
          view-as alert-box error.
          undo, return error return-value.
        end. /* error */
      end. /* if available bf_trn-doc */

      define buffer bf_price-doc for ub.price-doc  .

      find first bf_price-doc no-lock where
                 bf_price-doc.doc-num = p-doc-code
                 no-error.
      if available bf_price-doc then do:
        /* проверить активность стороны ??? */
        find first buf_doc-attr no-lock where
                   buf_doc-attr.doc-code  = p-doc-code and
                   buf_doc-attr.attr-code = p-code     no-error.
        run str/callnews.p ( input "doc-attr", input ( buffer buf_doc-attr :handle ) ) no-error.
        if error-status :error then do:
          message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                  "Невозможно маршрутизировать doc-attr для отправки в новости" skip( 0 )
                  "Переоценка:" '"' + bf_price-doc.doc-num    + '"' skip( 0 )
                  "Атрибут:"  '"' + buf_doc-attr.attr-code + '"' skip( 0 )
                  error-status :get-message( 1 ) skip( 0 )
                  error-status :get-message( 2 ) skip( 0 )
                  error-status :get-message( 3 ) skip( 0 )
                  "return-value = " return-value skip( 0 )
          view-as alert-box error.
          undo, return error return-value.
        end. /* error */
      end. /* if available bf_price-doc */

    end. /* if lookup( "nws":U, v-other ) > 0 */
  end. /* on error */
end procedure. /* trdcalib_tdat-oth */

procedure trdcalib_tdatinv-oth :
  define input parameter p-doc-code as character no-undo.
  define input parameter p-code     as character no-undo. /* код атрибута */
  define input parameter p-value    as character no-undo. /* значение атрибута */

  define variable v-type           as character no-undo. /* тип атрибута    */
  define variable v-format         as character no-undo. /* формат атрибута */
  define variable v-fillin_width   as integer   no-undo. /* ширина          */
  define variable v-fillin_height  as integer   no-undo. /* высота          */
  define variable v-label          as character no-undo. /* лабел атрибута  */
  define variable v-user-can-edit  as logical   no-undo. /* пользователь может изменять в броусе */
  define variable v-output-display as logical   no-undo. /* виден в броусе  */
  define variable v-other          as character no-undo. /* еще чего-нибудь */
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .

  define buffer buf_doc-attr for ub.inv-doc-attr.
  define buffer nakl_trn-doc for ub.trn-doc.
  define buffer bf_trn-doc   for ub.trn-doc.

  do on error undo, return error return-value :
     { str/tdatinv-cod.i p-code
                  v-type
                  v-format
                  v-fillin_width
                  v-fillin_height
                  v-label
                  v-user-can-edit
                  v-output-display
                  v-other
                  v-proc-attr
                  v-full-screen-val
                  v-sort
                  no-error }

    /* отправить по новостям самостоятельно без документа. */
    if lookup( "nws":U, v-other ) > 0 then do:
      find first bf_trn-doc no-lock where
                 bf_trn-doc.doc-code = p-doc-code /* and
                 bf_trn-doc.status_  = {&ready} */ no-error.
      if available bf_trn-doc then do:
        /* проверить активность стороны ??? */
        find first buf_doc-attr no-lock where
                   buf_doc-attr.doc-code  = p-doc-code and
                   buf_doc-attr.attr-code = p-code     no-error.
        run str/callnews.p ( input "doc-attr", input ( buffer buf_doc-attr :handle ) ) no-error.
        if error-status :error then do:
          message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                  "Невозможно маршрутизировать doc-attr для отправки в новости" skip( 0 )
                  "Документ:" '"' + bf_trn-doc.doc-code    + '"' skip( 0 )
                  "Атрибут:"  '"' + buf_doc-attr.attr-code + '"' skip( 0 )
                  error-status :get-message( 1 ) skip( 0 )
                  error-status :get-message( 2 ) skip( 0 )
                  error-status :get-message( 3 ) skip( 0 )
                  "return-value = " return-value skip( 0 )
          view-as alert-box error.
          undo, return error return-value.
        end. /* error */
      end. /* if available bf_trn-doc */

      define buffer bf_price-doc for ub.price-doc  .

      find first bf_price-doc no-lock where
                 bf_price-doc.doc-num = p-doc-code
                 no-error.
      if available bf_price-doc then do:
        /* проверить активность стороны ??? */
        find first buf_doc-attr no-lock where
                   buf_doc-attr.doc-code  = p-doc-code and
                   buf_doc-attr.attr-code = p-code     no-error.
        run str/callnews.p ( input "doc-attr", input ( buffer buf_doc-attr :handle ) ) no-error.
        if error-status :error then do:
          message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                  "Невозможно маршрутизировать doc-attr для отправки в новости" skip( 0 )
                  "Переоценка:" '"' + bf_price-doc.doc-num    + '"' skip( 0 )
                  "Атрибут:"  '"' + buf_doc-attr.attr-code + '"' skip( 0 )
                  error-status :get-message( 1 ) skip( 0 )
                  error-status :get-message( 2 ) skip( 0 )
                  error-status :get-message( 3 ) skip( 0 )
                  "return-value = " return-value skip( 0 )
          view-as alert-box error.
          undo, return error return-value.
        end. /* error */
      end. /* if available bf_price-doc */

    end. /* if lookup( "nws":U, v-other ) > 0 */
  end. /* on error */
end procedure. /* trdcalib_tdatinv-oth */

procedure trdcalib_tdatothn :
  define input parameter p-doc-code as character no-undo.
  define input parameter p-code     as character no-undo. /* код атрибута */

  define variable v-type           as character no-undo. /* тип атрибута    */
  define variable v-format         as character no-undo. /* формат атрибута */
  define variable v-fillin_width   as integer   no-undo. /* ширина          */
  define variable v-fillin_height  as integer   no-undo. /* высота          */
  define variable v-label          as character no-undo. /* лабел атрибута  */
  define variable v-user-can-edit  as logical   no-undo. /* пользователь может изменять в броусе */
  define variable v-output-display as logical   no-undo. /* виден в броусе  */
  define variable v-other          as character no-undo. /* еще чего-нибудь */
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .

  define buffer buf_doc-attr for ub.doc-attr.
  define buffer nakl_trn-doc for ub.trn-doc.
  define buffer bf_trn-doc   for ub.trn-doc.

  do on error undo, return error return-value :

      define buffer bf_price-doc for ub.price-doc  .

      find first bf_price-doc no-lock where
                 bf_price-doc.doc-num = p-doc-code
                 no-error.
      if available bf_price-doc then do:
        find first buf_doc-attr no-lock where
                   buf_doc-attr.doc-code  = p-doc-code and
                   buf_doc-attr.attr-code = p-code     no-error.
        run str/callnews.p ( input "doc-attr", input ( buffer buf_doc-attr :handle ) ) no-error.
        if error-status :error then do:
          message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                  "Невозможно маршрутизировать doc-attr для отправки в новости" skip( 0 )
                  "Переоценка:" '"' + bf_price-doc.doc-num    + '"' skip( 0 )
                  "Атрибут:"  '"' + buf_doc-attr.attr-code + '"' skip( 0 )
                  error-status :get-message( 1 ) skip( 0 )
                  error-status :get-message( 2 ) skip( 0 )
                  error-status :get-message( 3 ) skip( 0 )
                  "return-value = " return-value skip( 0 )
          view-as alert-box error.
          undo, return error return-value.
        end. /* error */
      end. /* if available bf_price-doc */

  end. /* on error */
end procedure. /* trdcalib_tdatothn */

/* $Workfile$   E n d */