block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getrefdt.p $
$Archive: gbl/getrefdt.p $

Получение даты по выбору сущностей из различных справочников

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/23/06
Author: Bakhtadze Natalya
Creation date: 11/23/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-reference as character no-undo .
define input-output parameter p-date as date no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getrefdt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/getrefdt.p $":U .
define variable vss-description as character no-undo init "Получение даты по выбору сущностей из различных справочников".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/trg-def.i }
{ gbl/getcntxt.i def }

define variable v-rid-list as character no-undo .
define variable v-mode as character no-undo .
define variable v-code-schet as integer no-undo .
define variable v-curr-code as integer no-undo .

do
on error undo, return error
:

  message p-reference view-as alert-box .
  { gbl/getcntxt.i get }
  case entry(1, p-reference, {&delim-par} ):
    when "finsttms" then do:
       if entry(2, p-reference, {&delim-par}) = "ext-type-stat-start" then do:
         assign
         v-mode = "ext-type-stat-start"
         v-code-schet = 0
         v-curr-code = ?
         .
       end.
       if entry(2, p-reference, {&delim-par}) =  "ext-type-stat-end"
       or entry(2, p-reference, {&delim-par}) =  "ext-type-stat-end1"
       then do:
         assign
         v-mode = "ext-type-stat-end"
         v-code-schet = 0
         v-curr-code = ?
         .
       end.
       if entry(2, p-reference, {&delim-par}) = "code-schet-end":U
       or entry(2, p-reference, {&delim-par}) = "code-schet-start":U
       or entry(2, p-reference, {&delim-par}) = "code-schet-end1":U then do:
         assign
         v-mode = "code-schet"
         v-code-schet = integer(entry(3, p-reference, {&delim-par}))
         v-curr-code = ?
         .
       end.
       if entry(2, p-reference, {&delim-par}) = "currency-start":U
       or entry(2, p-reference, {&delim-par}) = "currency-end":U
       or entry(2, p-reference, {&delim-par}) = "currency-end1":U then do:
         assign
         v-mode = "currency"
         v-code-schet = 0
         v-curr-code = integer(entry(3, p-reference, {&delim-par}))
         .
       end.
      define buffer buf_fin-statement for ub.fin-statement.
      run ref/finsttms.w (
                     input parparentproc
                    ,input v-cntxt-host-code-obj /*p-current-host-code*/
                    ,input "b-sel":U  /*bttns*/
                    ,input v-mode
                    ,input v-cntxt-host-code-obj /*p-host-code*/
                    ,input {&fin-fact}      /*p-status*/
                    ,input {&standard-sttm}
                    ,input {&FSEDT_standard-sttm}  /*p-fins-ext-doc-type*/
                    ,input ?      /*p-start-date  */
                    ,input ?      /*p-end-date  */
                    ,input 0      /*p-code-bank*/
                    ,input v-code-schet      /* p-code-schet */
                    ,input v-curr-code      /* p-curr-code */
                    ,input-output v-rid-list) no-error .
      if v-rid-list = '':U then return.
      find first buf_fin-statement no-lock where
                recid(buf_fin-statement) = integer(v-rid-list) no-error.
      if available buf_fin-statement then do:
        if entry(2, p-reference, {&delim-par}) = "ext-type-stat-start"
        or entry(2, p-reference, {&delim-par}) = "code-schet-start"
        or entry(2, p-reference, {&delim-par}) = "currency-start"
        then do:
          assign
          p-date = buf_fin-statement.start-date.
        end.
        if entry(2, p-reference, {&delim-par}) = "ext-type-stat-end"
        or entry(2, p-reference, {&delim-par}) = "code-schet-end"
        or entry(2, p-reference, {&delim-par}) = "currency-end"
        then do:
          assign
          p-date = buf_fin-statement.end-date.
        end.
        if entry(2, p-reference, {&delim-par}) = "ext-type-stat-end1"
        or entry(2, p-reference, {&delim-par}) = "code-schet-end1"
        or entry(2, p-reference, {&delim-par}) = "currency-end1"
        then do:
          assign
          p-date = buf_fin-statement.end-date + 1.
        end.
      end.
    end.
    otherwise do:
      message
      substitute("Не определен или неверно определен справочник &1 для выбора даты", p-reference)
      view-as alert-box error .
      return .
    end.
  end case.
end. /*doe*/