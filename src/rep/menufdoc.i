/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пункт меню печати финдокумента

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/14/10
Author: Bakhtadze Natalya
Creation date: 04/14/10

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then
define temp-table Tmp#List no-undo like ub.ord-blank
field id                        as integer
field proc-name                 as character
field proc-param                as character
field print-options             as character
field orient                    as character
field orient-orientation        as character
field orient-font-num           as integer
field font-num                  as character
field filtr                     as character
field view_                     as integer  init 1
field sys-key                   as character
field sys-key-black             as character
field type-val                  as character
field type-val-enabled          as logical


index pi is primary unique id
index in-name
blank-name
index lu
last-use
.
define temp-table temp_form-list no-undo
field host-code as integer
field fin-doc-code  as integer
field id        as integer
field fin-doc-type  as character
field status_   as character

index pi is primary unique
host-code
fin-doc-code
id
index idx
id
.
define temp-table temp_menu-doc_disabled-doc-list no-undo
field host-code      as integer
field fin-doc-code      as integer
field blank-name    as character
field reason        as character

index pi is primary unique
host-code
fin-doc-code
blank-name
.
define variable v-menu-doc-sys-key              as character    no-undo.
define variable v-menu-doc-fin-doc-code         as integer      no-undo.
define variable v-menu-doc-host-code            as integer      no-undo .
define variable v-menu-doc-fin-doc-type         as character    no-undo.
define variable v-menu-doc-fin-ext-doc-type     as character    no-undo.
define variable v-menu-doc-status_              as character    no-undo.
define variable v-menu-doc-item-counter         as integer      no-undo.
define variable v-menu-doc-item-disabled        as logical      no-undo.

{ gbl/chk-entr.i }

procedure menufdoc-create-menu-item
:
define input parameter p-type   as   character no-undo.
define input parameter p-stat   as   character no-undo.
define input parameter param-1  as   character no-undo. /*доступный тип*/
define input parameter param-2  as   character no-undo. /*доступный статус*/
define input parameter param-5  as   character no-undo. /*название формы*/
define input parameter param-6  as   character no-undo. /*типы цен*/
define input parameter param-7  as   character no-undo. /*название процедуры*/
define input parameter param-8  as   character no-undo. /*доп параметры кроме parparentproc и recid*/
define input parameter param-9  as   character no-undo. /*опции печати*/
define input parameter param-10 as   character no-undo. /*список s y s - k e y*/
define input parameter param-11 as   character no-undo. /*ориентация*/
define input parameter param-12 as   character no-undo. /*черный список sys-key*/

do
on error undo, return error
:
  assign
  v-menu-doc-item-disabled = yes
    .
  if v-menu-doc-sys-key <> {&SuperSysKey}
  and ( ( param-10 <> "":U
          and check-entry-with-mask( v-menu-doc-sys-key, param-10, {&comma-char} ) = false
        )
        or ( param-12 <> "":U
              and check-entry-with-mask( v-menu-doc-sys-key, param-12, {&comma-char} ) = true )
            )
  then do:        /* sys-key базы данных занесён в чёрный список формы или белый список формы не пуст и в нём нет такого sys-key */
    undo, return .
  end.
  if param-7 = "":U
  then do:        /* Если не определена процедура обработки, строку не включать */
    undo, return .
  end.
  if param-1 = '*':U
  or lookup( p-type, param-1 ) > 0
  then do:
    if param-2 = '*':U
    or lookup( p-stat, param-2 ) > 0
    then do:
      assign
     v-menu-doc-item-disabled = no
      .
      find first tmp#list
            where tmp#list.blank-name     = param-5
              and tmp#list.filtr          = param-6
              and tmp#list.proc-name      = param-7
              and tmp#list.proc-param     = param-8
              and tmp#list.print-options  = param-9
              and tmp#list.sys-key        = param-10
              and tmp#list.orient         = param-11
              and tmp#list.sys-key-black  = param-12
      no-error.
      if not available tmp#list
      then do:
        assign
        v-menu-doc-item-counter = v-menu-doc-item-counter + 1
        .
        create tmp#list.
        assign
        tmp#list.id             = v-menu-doc-item-counter
        tmp#list.cli-code       = v-menu-doc-item-counter
        tmp#list.blank-name     = param-5
        tmp#list.filtr          = param-6
        tmp#list.proc-name      = param-7
        tmp#list.proc-param     = param-8
        tmp#list.print-options  = param-9
        tmp#list.sys-key        = param-10
        tmp#list.orient         = param-11
        tmp#list.sys-key-black  = param-12
        .
        assign
        tmp#list.orient-orientation     = entry( 1, tmp#list.orient )
        tmp#list.orient-font-num        = 7
        .
        assign
        tmp#list.orient-font-num      = ( if num-entries( tmp#list.orient ) > 1
                                          then integer( entry( 2, tmp#list.orient ) )
                                          else 7 )
        no-error.
        if error-status :error
        then do:
          assign
          tmp#list.orient-font-num = 7
          .
        end.
        run menufdoc-set-visible-options in this-procedure (
              input tmp#list.print-options
            , output tmp#list.type-val-enabled
        ).
      end.
    end.
  end.
  if v-menu-doc-item-disabled = yes then do:
    find first tmp#list
          where tmp#list.blank-name     = param-5
            and tmp#list.filtr          = param-6
            and tmp#list.proc-name      = param-7
            and tmp#list.proc-param     = param-8
            and tmp#list.print-options  = param-9
            and tmp#list.sys-key        = param-10
            and tmp#list.orient         = param-11
            and tmp#list.sys-key-black  = param-12
      no-error.
  if available tmp#list
  then do:        /* Форма есть в списке, но для данного документа должна быть недоступна */
    find first temp_menu-doc_disabled-doc-list
          where temp_menu-doc_disabled-doc-list.host-code     = v-menu-doc-host-code
            and temp_menu-doc_disabled-doc-list.fin-doc-code     = v-menu-doc-fin-doc-code
            and temp_menu-doc_disabled-doc-list.blank-name   = param-5
    no-error.
    if not available temp_menu-doc_disabled-doc-list
    then do:
      create temp_menu-doc_disabled-doc-list.
      assign
      temp_menu-doc_disabled-doc-list.host-code    = v-menu-doc-host-code
      temp_menu-doc_disabled-doc-list.fin-doc-code    = v-menu-doc-fin-doc-code
      temp_menu-doc_disabled-doc-list.blank-name  = param-5
      .
    end.
    if param-1 <> '*':U
    and lookup( p-type, param-1 ) > 0
    then do:
      assign
      temp_menu-doc_disabled-doc-list.reason   = "type":U
      .
    end.
    assign
    temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + ",":U
    .
    if param-2 <> '*':U
    and lookup( p-stat, param-2 ) > 0
    then do:
      assign
      temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + "stat":U
      .
    end.
    assign
    temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + ",":U
    .
    assign
    temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + ",":U
    .
    if v-menu-doc-sys-key = {&SuperSysKey}
    then do:
      run menufdoc-extend-blank-name-for-IBS in this-procedure (
              input tmp#list.blank-name
            , input tmp#list.sys-key
            , input Tmp#List.sys-key-black
            , output tmp#list.blank-name
        ).
    end.
  end.        /* if available tmp#list */
  else do:
    assign
    v-menu-doc-item-disabled = no
    .
  end.
end.        /* if v-menu-doc-item-disabled = yes */
  if v-menu-doc-item-disabled = no
  then do:
    find first tmp#list
          where tmp#list.blank-name     = param-5
            and tmp#list.filtr          = param-6
            and tmp#list.proc-name      = param-7
            and tmp#list.proc-param     = param-8
            and tmp#list.print-options  = param-9
            and tmp#list.sys-key        = param-10
            and tmp#list.orient         = param-11
            and tmp#list.sys-key-black  = param-12
    no-error.
    if available tmp#list
    then do:
      find first temp_form-list
            where temp_form-list.host-code  = v-menu-doc-host-code
              and temp_form-list.fin-doc-code  = v-menu-doc-fin-doc-code
              and temp_form-list.id        = tmp#list.id
      no-error.
      if not available temp_form-list then do:
        create temp_form-list.
        assign
        temp_form-list.host-code      = v-menu-doc-host-code
        temp_form-list.fin-doc-code  = v-menu-doc-fin-doc-code
        temp_form-list.id        = tmp#list.id
        temp_form-list.fin-doc-type  = v-menu-doc-fin-doc-type
        temp_form-list.status_   = v-menu-doc-status_
        .
       end.
       if v-menu-doc-sys-key = {&SuperSysKey}
       then do:
         run menufdoc-extend-blank-name-for-IBS in this-procedure (
                      input tmp#list.blank-name
                    , input tmp#list.sys-key
                    , input Tmp#List.sys-key-black
                    , output tmp#list.blank-name
                ).
       end.
     end.        /* if available tmp#list */
  end.        /* if v-menu-doc-item-disabled = no */
end. /*doe*/
end procedure. /* menufdoc-create-menu-item */

/*==========================================================================*/
procedure menufdoc-set-visible-options :
define input parameter p-print-options          as character        no-undo.
define output parameter p-type-val-enabled      as logical          no-undo.


do
on error undo, return error
:
  assign
  p-type-val-enabled      = ( if substring( p-print-options, 1, 1 ) = "+" then yes else no )
  .
end.
end procedure. /* menufdoc-set-visible-options */

/*==========================================================================*/
procedure menufdoc-create-options-string :
define input parameter p-tmp-list-id        as integer          no-undo.
define output parameter p-options-string    as character        no-undo.

define buffer buf_tmp#list      for tmp#list.
do
for buf_tmp#list
on error undo, return error
:
  find first buf_tmp#list
        where buf_tmp#list.id = p-tmp-list-id
  .
  assign
  p-options-string =  ( if trim( buf_tmp#list.type-val    ) = "+":U then "+":U else "-":U )
  .
end.
end procedure. /* menufdoc-create-options-string */

/*==========================================================================*/
procedure menufdoc-set-options-string :
define input parameter p-tmp-list-id            as integer          no-undo.
define input parameter p-options-string         as character        no-undo.

define buffer buf_tmp#list      for tmp#list.
do
for buf_tmp#list
on error undo, return error
:
  find first buf_tmp#list
        where buf_tmp#list.id = p-tmp-list-id
  .
  assign
  buf_tmp#list.type-val    = ( if buf_tmp#list.type-val-enabled       = yes then substitute( "  &1", substring( p-options-string, 1, 1 ) ) else " ":U )
    .
end.
end procedure. /* menufdoc-create-options-string */

/*==========================================================================*/
procedure menufdoc-create-options-enabled-string :
define input parameter p-tmp-list-id                as integer          no-undo.
define output parameter p-options-enabled-string    as character        no-undo.

define buffer buf_tmp#list      for tmp#list.
do
for buf_tmp#list
on error undo, return error
:
  find first buf_tmp#list
        where buf_tmp#list.id = p-tmp-list-id
    .
 assign
  p-options-enabled-string =  ( if buf_tmp#list.type-val-enabled    = yes then "+":U else "-":U )
                                .
end.
end procedure. /* menufdoc-create-options-string */

/*==========================================================================*/
procedure menufdoc-extend-blank-name-for-IBS :
define input parameter p-in-blank-name      as character        no-undo.
define input parameter p-sys-key            as character        no-undo.
define input parameter p-sys-key-black      as character        no-undo.
define output parameter p-out-blank-name    as character        no-undo.

do
on error undo, return error
:
  assign
  p-out-blank-name = p-in-blank-name
  .
  if p-sys-key <> "":U
  then do:
    assign
    p-out-blank-name = substring( p-in-blank-name + " '" + p-sys-key + "'" , 1, 120 )
    .
  end.
  if p-sys-key-black <> ""
  then do:
    assign
    p-out-blank-name = substring( p-in-blank-name + " no-'" + p-sys-key-black + "'", 1, 120 )
    .
  end.
end.
end procedure. /* menufdoc-extend-blank-name-for-IBS */
&else
  &if "{11}" <> '?':U &then
  if {11} then do:
  &endif
      run menufdoc-create-menu-item in this-procedure
        (   input xtype /*тип текущего документа*/
          , input xstatus /*статус текущего документа*/
          , input {1}  /*тип*/
          , input {2}  /*статус*/
          , input {3}  /*название формы в меню*/
          , input {4}  /*типы цены*/
          , input {5}  /*имя вызываемой программы*/
          , input {6}  /*доп параметры кроме parparentproc и recid*/
          , input {7}  /*опции печати*/
          , input {8}  /*список sys-key*/
          , input {9}  /*ориентация*/
          , input {10} /*черный список sys-key*/
      ).

  &if "{11}" <> '?':U &then
      end.
  &endif
    {12}
&endif

/* $Workfile$   E n d */