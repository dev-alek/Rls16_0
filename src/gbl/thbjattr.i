/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами клиента

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "fix" &then
&glob thbj-revision  "v15_1.1"
procedure check-thbj-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .
define buffer buf_thbj-attr for ub.thbj-attr.


  do
  on error undo, return error
  :
    find first buf_thbj-attr no-lock where
              buf_thbj-attr.obj-type = '':U
          and buf_thbj-attr.obj-code = 0
          and buf_thbj-attr.prop-code = ''
          and buf_thbj-attr.upper-prop-code = '' no-error .
    if (not available buf_thbj-attr
    or buf_thbj-attr.property-value-character <> {&thbj-revision} )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_thbj-attr.property-value-character, "."))
      v-dopi2 = integer(entry(2, {&thbj-revision}, "."))
      v-dopi3 = integer(entry(2, entry(1, buf_thbj-attr.property-value-character, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, {&thbj-revision}, "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_thbj-attr.property-value-character, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.

end procedure. /* check-thbj-version */

procedure get-thbj-version :
define output parameter p-thbj-version as character no-undo init ?.

define buffer buf_thbj-attr for ub.thbj-attr.


do
on error undo, return error
:
  find first buf_thbj-attr no-lock where
            buf_thbj-attr.obj-type = '':U
        and buf_thbj-attr.obj-code = 0
        and buf_thbj-attr.prop-code = ''
        and buf_thbj-attr.upper-prop-code = '' no-error .
  if available buf_thbj-attr then do:
    p-thbj-version = buf_thbj-attr.property-value-character.
  end.
end.
end procedure. /* get-thbj-version */


&else

&if defined (include_attr-lib) = 0 &then
{ gbl/attr-lib.i }
&endif


{ gbl/thbj-def.i }
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo . /* код атрибута                           */
   define input  parameter p-code           as character no-undo . /* код атрибута                           */
   define output parameter p-label          as character no-undo . /* лэйбл атрибута                         */
   define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в браузере */
   define output parameter p-output-display as logical   no-undo . /* виден в браузере                       */
   define output parameter p-other          as character no-undo . /* еще чего - нибудь                      */
   define output parameter p-prop-list      as character no-undo . /*список членов секции*/
   define output parameter p-prop-type-list as character no-undo . /*список типов членов секции*/
   define output parameter p-prop-label-list as character no-undo . /*список лейблов членов секции*/
   define output parameter p-global          as logical no-undo .   /*может ли быть задан в глобальном контексте*/
   define output parameter p-host           as logical no-undo .    /*может ли быть задан в контексте фирмы*/
   define output parameter p-shop           as logical no-undo .    /*может ли быть задан в контексте маг*/
   define output parameter p-store          as logical no-undo .    /*может ли быть задан в контексте склад*/
   define output parameter p-db             as logical no-undo .    /*может ли быть задан в контексте БД*/
    
   define variable p-region as logical no-undo.  
 
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region  
                                            ).                     

end procedure.

procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo . /* код атрибута                           */
define input  parameter p-code           as character no-undo . /* код атрибута                           */
define output parameter p-label          as character no-undo . /* лэйбл атрибута                         */
define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в браузере */
define output parameter p-output-display as logical   no-undo . /* виден в браузере                       */
define output parameter p-other          as character no-undo . /* еще чего - нибудь                      */
define output parameter p-prop-list      as character no-undo . /*список членов секции*/
define output parameter p-prop-type-list as character no-undo . /*список типов членов секции*/
define output parameter p-prop-label-list as character no-undo . /*список лейблов членов секции*/
define output parameter p-global          as logical no-undo .   /*может ли быть задан в глобальном контексте*/
define output parameter p-host           as logical no-undo .    /*может ли быть задан в контексте фирмы*/
define output parameter p-shop           as logical no-undo .    /*может ли быть задан в контексте маг*/
define output parameter p-store          as logical no-undo .    /*может ли быть задан в контексте склад*/
define output parameter p-db             as logical no-undo .    /*может ли быть задан в контексте БД*/
define output parameter p-region         as logical no-undo .    /*может ли быть задан в контексте региона*/

do
on error undo, return error return-value
:
  &scop proc-name thbjattr_code
  {&run_proc_attr-lib}
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:      
    undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1)).
  end. 
end.
end procedure.

procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .

do
on error undo, return error return-value
:
  &scop proc-name thbjattr_tooltip
  {&run_proc_attr-lib}
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.

procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo . /* код секции  */
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .

do
on error undo, return error return-value
:
  &scop proc-name thbjattr_legacy
  {&run_proc_attr-lib}
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1)).
  end.
end.
end procedure.


procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .

do
on error undo, return error return-value
:
  &scop proc-name thbjattr_value
  {&run_proc_attr-lib}
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.

end procedure.

procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .

do
on error undo, return error return-value
:
  &scop proc-name thbjattr_get-section
  {&run_proc_attr-lib}
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.

end procedure. /* thbjattr_get-seaction */



procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .

do
on error undo, return error return-value
:
  &scop proc-name thbjattr_write
  {&run_proc_attr-lib}
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.

end procedure.

procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.

do
on error undo, return error return-value
:
  &scop proc-name thbjattr_set-section
  {&run_proc_attr-lib}
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.

end procedure.

procedure thbjattr_delete :

define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.

do
on error undo, return error return-value
:
  &scop proc-name thbjattr_delete
  {&run_proc_attr-lib}
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.

end procedure.

procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .

do
on error undo, return error return-value
:
  &scop proc-name thbjattr_delete-section
  {&run_proc_attr-lib}
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.

end procedure.


procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo . /* код секции */
define input  parameter p-code           as character no-undo . /* код атрибута */
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
  &scop proc-name thbjattr_manual-edit
  {&run_proc_attr-lib}
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.

end procedure.

&endif

/* $Workfile$ e n d */