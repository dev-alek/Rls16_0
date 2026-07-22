/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

для edi

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 07/19/05
*/

/* для  ord-doc.date-pay и для  trn-doc-attr */
/* статусы ответов поставщика 12 */
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/key-rec.i }
{ ref/extclass.i }

FUNCTION status-edoc-nn{1} RETURN CHAR (buffer loc-o-doc for ub.ord-doc
                                   , input is-edoc-nn as logical
                                   , input is-edi as logical
                                   , output p-color as integer ).
&scop order-stts-int1 string(loc-o-doc.ord-int1)
define variable v-obj-db-num as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define buffer buf_clients for ub.clients  .
define buffer obj_clients for ub.clients  .
define buffer buf_ext-classif for ub.ext-classif  .
define buffer buf2_ext-classif for ub.ext-classif  .
define buffer buf_ext-system  for ub.ext-system  .
p-color = ?.
if not available loc-o-doc then do:
  return ''.
end.
if not ( is-edoc-nn or is-edi)
or loc-o-doc.doc-type <> {&o-p}  then do:
  p-color = ?.
  return ''.
end.
{ gbl/objdbnum.i loc-o-doc.obj-type loc-o-doc.obj-code v-obj-db-num }
find first  buf_clients no-lock where
            buf_clients.obj-type = loc-o-doc.cli-type and
            buf_clients.obj-code = loc-o-doc.cli-code
              no-error .
if not available buf_clients then do:
  p-color = ?.
  return "" .
end.

run gen-key-rec IN THIS-PROCEDURE ( input {&table_clients}
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
find first buf_ext-classif no-lock
      where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        and buf_ext-classif.classif-subject = {&table_clients}
        and buf_ext-classif.classif-name    = {&extclass_clients_edoc-nn} no-error.
if available buf_ext-classif then do :
  assign
  p-color = integer({&edoc-stts-color})
  no-error .
  return {&edoc-stts-name} .
end. /*if available buf_ext-classif then do :*/
else do :
  find first obj_clients no-lock where
            obj_clients.obj-type = loc-o-doc.obj-type
        and obj_clients.obj-code = loc-o-doc.obj-code no-error.
  if not available obj_clients then do:
    return ''.
  end.
  run gen-key-rec IN THIS-PROCEDURE ( input {&table_clients}
                                    , input (buffer obj_clients:handle)
                                    , output v-obj-uniq-key-rec).
  for each buf_ext-classif no-lock
        where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
          and buf_ext-classif.classif-subject = {&table_clients}
          and buf_ext-classif.classif-name    = {&extclass_clients_exite-edi},
     first buf_ext-system no-lock
        where buf_ext-system.esys-id = buf_ext-classif.key#_one
          and buf_ext-system.db-num  = 0
          and buf_ext-system.esys-have-export = yes
          and buf_ext-system.esys-db-num-exp = v-obj-db-num,
     first buf2_ext-classif no-lock
              where buf2_ext-classif.uniq-key-rec = v-obj-uniq-key-rec
                and buf2_ext-classif.classif-subject = {&table_clients}
                and buf2_ext-classif.classif-name    = {&extclass_clients_exite-edi}
                and buf2_ext-classif.key#_one  = buf_ext-classif.key#_one:
    assign
    p-color = integer({&edi-stts-color})
    no-error .
    return {&edi-stts-name} .
  end. /*if available buf_ext-classif then do :*/
  return ''.
end. /*else if available buf_ext-classif then do :*/
return ''.
END FUNCTION.


FUNCTION status-is-edoc-nn{1} RETURN logical ( input p-is-edoc-nn   as logical
                                             , input p-cli-type     as character
                                             , input p-cli-code     as integer
                                             , input p-obj-type     as character
                                             , input p-obj-code     as integer
                                             ) .

define variable v-uniq-key-rec as character no-undo .

define buffer buf_clients     for ub.clients .
define buffer buf_ext-classif for ub.ext-classif .
define buffer buf_ext-system  for ub.ext-system  .
if not p-is-edoc-nn then do:
  return no.
end.

find first buf_clients no-lock
     where buf_clients.obj-type = p-cli-type
       and buf_clients.obj-code = p-cli-code
       no-error .
if not available buf_clients then do:
  return no .
end.

run gen-key-rec IN THIS-PROCEDURE ( input {&table_clients}
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
find first buf_ext-classif no-lock
     where buf_ext-classif.uniq-key-rec    = v-uniq-key-rec
       and buf_ext-classif.classif-subject = {&table_clients}
       and buf_ext-classif.classif-name    = {&extclass_clients_edoc-nn}
       no-error.
if available buf_ext-classif then do :
  return yes .
end. /*if available buf_ext-classif then do :*/
return no.

END FUNCTION.


FUNCTION status-is-edi{1} RETURN logical ( input p-is-edi as logical
                                         , input p-cli-type as character
                                         , input p-cli-code as integer
                                         , input p-obj-type     as character
                                         , input p-obj-code     as integer
                                         , output p-dm-edi as integer
                                         ) .

define variable v-obj-db-num   as integer   no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-obj-uniq-key-rec as character no-undo .

define buffer buf_clients     for ub.clients .
define buffer obj_clients     for ub.clients .
define buffer buf_ext-classif for ub.ext-classif .
define buffer buf2_ext-classif for ub.ext-classif .
define buffer buf_ext-system  for ub.ext-system  .

if not p-is-edi then do:
  return no.
end.

{ gbl/objdbnum.i p-obj-type p-obj-code v-obj-db-num }
find first buf_clients no-lock
     where buf_clients.obj-type = p-cli-type
       and buf_clients.obj-code = p-cli-code
       no-error .
if not available buf_clients then do:
  return no .
end.
find first obj_clients no-lock where
          obj_clients.obj-type = p-obj-type
      and obj_clients.obj-code = p-obj-code no-error.
if not available buf_clients then do:
  return no .
end.
run gen-key-rec IN THIS-PROCEDURE ( input {&table_clients}
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
run gen-key-rec IN THIS-PROCEDURE ( input {&table_clients}
                                  , input (buffer obj_clients:handle)
                                  , output v-obj-uniq-key-rec).

for each buf_ext-classif no-lock
      where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        and buf_ext-classif.classif-subject = {&table_clients}
        and buf_ext-classif.classif-name    = {&extclass_clients_exite-edi},
    first buf_ext-system no-lock
      where buf_ext-system.esys-id = buf_ext-classif.key#_one
        and buf_ext-system.db-num  = 0
        and buf_ext-system.esys-have-export = yes
        and (buf_ext-system.esys-db-num-exp = v-obj-db-num
        or buf_ext-system.esys-db-num-exp = 0),
    first buf2_ext-classif no-lock
            where buf2_ext-classif.uniq-key-rec = v-obj-uniq-key-rec
              and buf2_ext-classif.classif-subject = {&table_clients}
              and buf2_ext-classif.classif-name    = {&extclass_clients_exite-edi}
              and buf2_ext-classif.key#_one  = buf_ext-classif.key#_one:
  leave.
end. /*if available buf_ext-classif then do :*/

if available buf_ext-classif then do :
  p-dm-edi = buf_ext-system.whole-send-news.
  return yes .
end. /*if available buf_ext-classif then do :*/
return no .
END FUNCTION.

FUNCTION get-gln{1} returns character ( input p-obj-type as character
                                    ,input p-obj-code as integer):
define variable v-uniq-key-rec as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
find first buf_clients no-lock where
          buf_clients.obj-type = p-obj-type
      and buf_clients.obj-code = p-obj-code no-error.
if not available buf_clients then do:
  return {&question-mark}.
end.
run gen-key-rec  in this-procedure ( input {&table_clients}
                                    ,input (buffer buf_clients:handle)
                                    ,output v-uniq-key-rec) no-error.
if error-status:error then do:
   return {&question-mark}.
end.
find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = {&table_clients}
      and buf_ext-classif.classif-name = {&extclass_clients_GLN}
      and buf_ext-classif.uniq-key-rec = v-uniq-key-rec no-error .
if available buf_ext-classif then do:
  return buf_ext-classif.charkey_one.
end.
else do:
 return ''.
end.
END FUNCTION.

FUNCTION get-type-code-from-gln{1} returns logical ( input  p-gln      as character
                                                    ,output p-obj-type as character
                                                    ,output p-obj-code as integer) :
define variable v-uniq-key-rec as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .

define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.

find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = {&table_clients}
      and buf_ext-classif.classif-name = {&extclass_clients_GLN}
      and buf_ext-classif.charkey_one = p-gln no-error .
if available buf_ext-classif then do:
  assign v-uniq-key-rec = buf_ext-classif.uniq-key-rec.
end.
else do:
  assign
    p-obj-type = ''
    p-obj-code = 0
  .
  return no.
end.
if v-uniq-key-rec <> '' then do:
    run gen-key-fv in this-procedure ( input  v-uniq-key-rec
                                      ,output v-field-list
                                      ,output v-value-list).
end.
assign
  p-obj-type = entry(lookup("obj-type":U
                          , v-field-list
                          , {&delim-key})
                          , v-value-list, {&delim-key})
  p-obj-code = integer(entry(lookup("obj-code":U
                                  , v-field-list
                                  , {&delim-key})
                                  , v-value-list, {&delim-key}))
no-error .
if error-status:error then do:
  assign
    p-obj-type = ''
    p-obj-code = 0
  .
  return no.
end.
else do:
  return yes.
end.
END FUNCTION.

FUNCTION status-edoc-edi-light{1} RETURN CHAR (buffer loc-o-doc for ub.ord-doc
                                   , input is-edoc-nn as logical
                                   , input is-edi as logical
                                   , output p-color as integer ).
p-color = ?.
if not available loc-o-doc then do:
  return ''.
end.
if not ( is-edoc-nn or is-edi)
or loc-o-doc.doc-type <> {&o-p}  then do:
  p-color = ?.
  return ''.
end.
case loc-o-doc.whole-send-news:
  when integer({&doc-dm-edoc-nn}) then do:
    assign
    p-color = integer({&edoc-stts-color})
    no-error .
    return {&edoc-stts-name} .
  end.
  when integer({&doc-dm-edi}) then do:
    assign
    p-color = integer({&edi-stts-color})
    no-error .
    return {&edi-stts-name} .
  end .
  otherwise do:
    p-color = ?.
    return ''.
  end.
end case.
end function.
/* $Workfile$ e n d */