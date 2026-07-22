block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение конфигурационного параметра по типу диапазона

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/12/06
Author: Dmitry Ukhanov
Creation date: 04/12/06

*/

define input  parameter p-range-type like ub.code-range.range-type no-undo .
define output parameter p-param-code like ub.config.param-code     no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "определение конфигурационного параметра по типу диапазона".
{ cmp/vssrevis.i "substitute('&1':u,p-range-type)"}
{ cmp/str-glbl.i }

do
on error undo, return error
:
  case p-range-type:
    when {&gbl-bc-code} then do:
      assign
        p-param-code = {&attr-code-range_cdrgbcgb}
      .
    end.
    when {&gbl-sc-code} then do:
      assign
        p-param-code = {&attr-code-range_cdrgscgb}
      .
    end.
    when {&loc-sc-code} then do:
      assign
        p-param-code = {&attr-code-range_cdrgsclc}
      .
    end.
    when {&gbl-ss-code} then do:
      assign
        p-param-code = {&attr-code-range_cdrgssgb}
      .
    end.
    when {&loc-ss-code} then do:
      assign
        p-param-code = {&attr-code-range_cdrgsslc}
      .
    end.
    when {&loc-pg-code} then do:
      assign
        p-param-code = {&attr-code-range_cdrgpglc}
      .
    end.
    when {&gbl-dc-code} then do:
      assign
        p-param-code = {&attr-code-range_cdrgdcgb}
      .
    end.
    when {&gbl-dr-code} then do:
      assign
        p-param-code = {&attr-code-range_cdrgdrgb}
      .
    end.
    when {&gbl-ct-code} then do:
      assign
        p-param-code = {&attr-code-range_cdrgctgb}
      .
    end.
    when {&gbl-fm-code} then do:
      assign
        p-param-code = {&attr-code-range_cdrgfmgb}
      .
    end.
    when {&gbl-pn-code} then do:
      assign
        p-param-code = {&attr-code-range_cdrgpngb}
      .
    end.
    when {&gbl-ca-code} then do:
      assign
        p-param-code = {&attr-code-range_cdrgcagb}
      .
    end.
    when {&gbl-fd-code} then do:
      assign
        p-param-code = {&attr-code-range_cdrgfdgb}
      .
    end.

  end case.
end.


/* $Workfile$ end */