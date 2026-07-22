block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: esys-key.p $
$Archive: bge/esys-key.p $

Проверка корректности типов имеющихся ВС значениям выданных ключей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/11/10
Author: Bakhtadze Natalya
Creation date: 05/11/10

*/


define input parameter p-db-num as integer no-undo .
define input parameter p-silence as logical no-undo .
define output parameter p-ok as logical no-undo .
define output parameter p-err-mess as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: esys-key.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/esys-key.p $":U .
define variable vss-description as character no-undo init "Проверка корректности типов имеющихся ВС значениям выданных ключей".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }

/*сколько ВС в данной БД импортируют или экспортируют*/
define variable v-esys-by-type-found as integer extent {&max-openxml-type-code} no-undo .
/*сколько ВС в данной БД РАЗРЕШЕНО СОГЛАСНО КЛЮЧАМ импортировать или экспортировать*/
define variable v-esys-by-type-key  as integer extent {&max-openxml-type-code}.
define variable v-esys-by-type-key-chr  as character extent {&max-openxml-type-code}.
define variable v-esys-type-num as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-code as character no-undo .
define variable v-type as character no-undo .
define buffer buf_ext-system  for ub.ext-system.

main-block:
for each buf_ext-system no-lock where
       ((buf_ext-system.esys-have-export = yes
         and
         buf_ext-system.esys-db-num-exp = p-db-num)
         or
         (buf_ext-system.esys-have-import = yes
         and
         buf_ext-system.esys-db-num-imp = p-db-num)
        )
      and buf_ext-system.esys-type > integer({&openxml-type-special})
      /*НЕКОНКРЕТНЫЙ ТИП ПРОПУСКАЕМ*/
by buf_ext-system.esys-type
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  v-esys-type-num = buf_ext-system.esys-type.
  assign
  v-esys-by-type-found[v-esys-type-num] = v-esys-by-type-found[v-esys-type-num]  + 1
  .
end.
do v-ii = 2 to {&max-openxml-type-code}:
  v-code = substitute("esys-&1", string(v-ii, "999")).
  if v-esys-by-type-found[v-ii]  > 0
  and lookup(string(v-ii), {&openxml-licensed-type-list}) > 0
  then do:
    { gbl/confrddb.i
      v-code
      p-db-num
      0
      ''
      0
      p-silence
      v-esys-by-type-key-chr[v-ii]
      v-type
      no-error
      }
    assign
    v-esys-by-type-key[v-ii] = integer(v-esys-by-type-key-chr[v-ii])
    no-error
    .
    if v-esys-by-type-key[v-ii] < v-esys-by-type-found[v-ii] then do:
      &scop openxml-type-code string(v-ii)
      p-err-mess = substitute("&1Количество разрешенных согласно параметру <esys-&7>  ВС с типом &2 (&3) =  &4, а реально &5"
                              , {&new-line}
                              , v-ii
                              , {&openxml-type-name}
                              , v-esys-by-type-key[v-ii]
                              , v-esys-by-type-found[v-ii]
                              , string(v-ii, "999")
                              ).
    end.
  end.
end.
if p-err-mess = '' then do:
  p-ok = yes.
end.