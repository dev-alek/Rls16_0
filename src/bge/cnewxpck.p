block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cnewxpck.p $
$Archive: bge/cnewxpck.p $

Нарезка новых пакетов в OpenXML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/17/08
Author: Bakhtadze Natalya
Creation date: 02/17/08

*/

define input  parameter p-esys-list  as character no-undo . /* если возможно, то формируем пакеты только для этих БД */
define output parameter p-err-code as integer no-undo .   /* 0 - без ошибок, 1 - ошибка подготовки пакетов, 2 - ошибка backup */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cnewxpck.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/cnewxpck.p $":U .
define variable vss-description as character no-undo init "Нарезка новых пакетов в OpenXML".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ adm/auto-def.i }
{ adm/onlinbkp.i }

define temp-table tt-esys-pck-cr no-undo
  field esys-id     as integer
  field db-num      as integer
  field cre-all-pck as logical
  index pi as unique primary esys-id db-num
  index cr cre-all-pck
  .

do
on error undo, return error
:
  define variable v-ind                      as integer   no-undo .
  define variable num-entries-pres-esys-list as integer   no-undo .
  define variable v-pres-esys-list           as character no-undo .
  define variable v-err-gen-pack             as integer   no-undo .
  define variable v-message                  as character no-undo .
  define variable v-msg                      as character no-undo .

  define variable v-need-initialize          as logical   no-undo .
  define variable v-db-num                   as integer   no-undo .
  define variable v-esys-id                  as integer   no-undo .
  define variable v-all-pck-cre              as logical   no-undo .

  define buffer buf_sys-ctrl for ub.sys-ctrl .

  find first buf_sys-ctrl no-lock .

  assign
    p-err-code = 0
  .
run bge/presesys.p
  ( output v-pres-esys-list
    ,output v-msg
  ) no-error .
if error-status :error then do:
  assign
    v-pres-esys-list = "":U
    p-err-code     = 1
  .
  return error substitute( "&1. Ошибка при подготовке списка действующих ВС &2&3&4"
                            ,vss-workfile
                            ,{&new-line}
                            ,error-status:get-message(error-status:num-messages)
                            ,{&new-line}
                            ,return-value
                          ) .
end.
if v-msg <> "":U  then do:
  if v-message = "":U then do:
    assign
      v-message = v-msg
    .
  end.
  else do:
    assign
      v-message = v-message + {&new-line} + v-msg
    .
  end.
end.


  for each tt-esys-pck-cr
  on error undo, return error return-value
  :
    delete tt-esys-pck-cr.
  end.
  assign
    num-entries-pres-esys-list = num-entries( v-pres-esys-list )
  .
  do v-ind = 1 to num-entries-pres-esys-list
  on error undo, return error
  :
    assign
      v-esys-id = integer( entry(1, entry( v-ind, v-pres-esys-list ), {&delim-par}  ))
      v-db-num = integer( entry(2, entry( v-ind, v-pres-esys-list ), {&delim-par}  ))
    .
    if (p-esys-list > ''
    and lookup( substitute("&1,&2", v-esys-id,v-db-num), p-esys-list ) > 0)
    or p-esys-list = ''
    then do:
    find first tt-esys-pck-cr
      where tt-esys-pck-cr.esys-id = v-esys-id
          and tt-esys-pck-cr.db-num = v-db-num
      no-error .
    if not available tt-esys-pck-cr then do:
      create tt-esys-pck-cr.
      assign
      tt-esys-pck-cr.esys-id     = v-esys-id
      tt-esys-pck-cr.db-num      = v-db-num
      tt-esys-pck-cr.cre-all-pck = false
      .

    end.
  end.
  end.
  assign
    v-all-pck-cre = false
  .

  /* формирование пакетов для всех БД */
  do while v-all-pck-cre <> true
  on error undo, return error
  :

    for each tt-esys-pck-cr
      where tt-esys-pck-cr.cre-all-pck = false
    on error undo, return error
    :
      if tt-esys-pck-cr.cre-all-pck = false then do:
        assign
        add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", tt-esys-pck-cr.esys-id )
        .


        run bge/cre-xpck.p
          ( input  tt-esys-pck-cr.esys-id
           ,input  tt-esys-pck-cr.db-num
           ,output v-err-gen-pack
           ,output tt-esys-pck-cr.cre-all-pck
          ) no-error .
        if error-status :error
          or v-err-gen-pack = 2
        then do:
          assign
          add-log-file-name = ?
            p-err-code = 1
          .
          return error substitute( "&1. Ошибка при подготовке нового(ых) пакета(ов) для ВС &2&3&4&5&6"
                                  ,vss-workfile
                                  ,tt-esys-pck-cr.esys-id
                                  ,{&new-line}
                                  ,error-status:get-message(error-status:num-messages)
                                  ,{&new-line}
                                  ,return-value
                                ) .
        end.
        assign
        add-log-file-name = ?
        .
      end.
    end.
    find first tt-esys-pck-cr
      where tt-esys-pck-cr.cre-all-pck = false
      no-error .
    if not available tt-esys-pck-cr then do:
      assign
        v-all-pck-cre = true
      .
    end.
  end.
  return v-message .

end.

/* $Workfile: cnewxpck.p $ end */