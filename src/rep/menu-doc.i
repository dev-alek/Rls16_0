/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пункт меню печати документа

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 03/23/06
Author: Victor Guntner
Creation date: 03/23/06

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
        field type-parts                as character
        field type-parts-enabled        as logical
        field type-price                as character
        field type-price-enabled        as logical
        field type-scale                as character
        field type-scale-enabled        as logical
        field type-val                  as character
        field type-val-enabled          as logical
        field sort-name                 as character
        field sort-name-enabled         as logical
        field sort-gr                   as character
        field sort-gr-enabled           as logical
        field print-graft               as character
        field print-graft-enabled       as logical
        field no-vat                    as character
        field no-vat-enabled            as logical


        index pi is primary unique id
        index in-name
           blank-name
        index lu
            last-use
    .
    define temp-table temp_form-list no-undo
        field doc-code  as character
        field id        as integer
        field doc-type  as character
        field status_   as character
        field internal  as character
        field flag      as character

        index pi is primary unique
            doc-code
            id
        index idx
            id
    .
    define temp-table temp_menu-doc_disabled-doc-list no-undo
        field doc-code      as character
        field blank-name    as character
        field reason        as character

        index pi is primary unique
                doc-code
                blank-name
    .
    define variable v-menu-doc-sys-key              as character    no-undo.
    define variable v-menu-doc-doc-code             as character    no-undo.
    define variable v-menu-doc-doc-type             as character    no-undo.
    define variable v-menu-doc-ext-doc-type         as character    no-undo.
    define variable v-menu-doc-status_              as character    no-undo.
    define variable v-menu-doc-internal             as character    no-undo.
    define variable v-menu-doc-flag                 as character    no-undo.
    define variable v-menu-doc-item-counter         as integer      no-undo.
    define variable v-menu-doc-item-disabled        as logical      no-undo.

    { gbl/chk-entr.i }

    procedure menu-doc-create-menu-item
    :
    define input parameter p-type   as   character no-undo.
    define input parameter p-stat   as   character no-undo.
    define input parameter p-intr   as   character no-undo.
    define input parameter p-flag   as   character no-undo.
    define input parameter param-1  as   character no-undo.
    define input parameter param-2  as   character no-undo.
    define input parameter param-3  as   character no-undo.
    define input parameter param-4  as   character no-undo.
    define input parameter param-5  as   character no-undo.
    define input parameter param-6  as   character no-undo.
    define input parameter param-7  as   character no-undo.
    define input parameter param-8  as   character no-undo.
    define input parameter param-9  as   character no-undo.
    define input parameter param-10 as   character no-undo.
    define input parameter param-11 as   character no-undo.
    define input parameter param-12 as   character no-undo.

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
                if param-3 = '*':U
                or lookup( p-intr, param-3 ) > 0
                then do:
                    if param-4 = '*':U
                    or lookup( p-flag, param-4 ) > 0
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
                            run menu-doc-set-visible-options in this-procedure (
                                  input tmp#list.print-options
                                , output tmp#list.type-parts-enabled  
                                , output tmp#list.type-price-enabled
                                , output tmp#list.type-scale-enabled
                                , output tmp#list.type-val-enabled
                                , output tmp#list.sort-name-enabled
                                , output tmp#list.sort-gr-enabled
                                , output tmp#list.print-graft-enabled
                                , output tmp#list.no-vat-enabled                                                                
                            ).
                        end.
                    end.
                end.
            end.
        end.
        if v-menu-doc-item-disabled = yes
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
            then do:        /* Форма есть в списке, но для данного документа должна быть недоступна */
                find first temp_menu-doc_disabled-doc-list
                     where temp_menu-doc_disabled-doc-list.doc-code     = v-menu-doc-doc-code
                       and temp_menu-doc_disabled-doc-list.blank-name   = param-5
                no-error.
                if not available temp_menu-doc_disabled-doc-list
                then do:
                    create temp_menu-doc_disabled-doc-list.
                    assign
                        temp_menu-doc_disabled-doc-list.doc-code    = v-menu-doc-doc-code
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
                if param-3 <> '*':U
                and lookup( p-intr, param-3 ) > 0
                then do:
                    assign
                        temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + "intr":U
                    .
                end.
                assign
                    temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + ",":U
                .
                if param-4 <> '*':U
                and lookup( p-flag, param-4 ) > 0
                then do:
                    assign
                        temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + "flag":U
                    .
                end.
                if v-menu-doc-sys-key = {&SuperSysKey}
                then do:
                    run menu-doc-extend-blank-name-for-IBS in this-procedure (
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
                     where temp_form-list.doc-code  = v-menu-doc-doc-code
                       and temp_form-list.id        = tmp#list.id
                no-error.
                if not available temp_form-list
                then do:
                    create temp_form-list.
                    assign
                        temp_form-list.doc-code  = v-menu-doc-doc-code
                        temp_form-list.id        = tmp#list.id
                        temp_form-list.doc-type  = v-menu-doc-doc-type
                        temp_form-list.status_   = v-menu-doc-status_
                        temp_form-list.internal  = v-menu-doc-internal
                        temp_form-list.flag      = v-menu-doc-flag
                    .
                end.
                if v-menu-doc-sys-key = {&SuperSysKey}
                then do:
                    run menu-doc-extend-blank-name-for-IBS in this-procedure (
                          input tmp#list.blank-name
                        , input tmp#list.sys-key
                        , input Tmp#List.sys-key-black
                        , output tmp#list.blank-name
                    ).
                end.
            end.        /* if available tmp#list */
        end.        /* if v-menu-doc-item-disabled = no */
    end.
    end procedure. /* menu-doc-create-menu-item */

    /*==========================================================================*/
    procedure menu-doc-set-visible-options :
    define input parameter p-print-options          as character        no-undo.
    define output parameter p-type-parts-enabled    as logical          no-undo.
    define output parameter p-type-price-enabled    as logical          no-undo.
    define output parameter p-type-scale-enabled    as logical          no-undo.
    define output parameter p-type-val-enabled      as logical          no-undo.
    define output parameter p-sort-name-enabled     as logical          no-undo.
    define output parameter p-sort-gr-enabled       as logical          no-undo.
    define output parameter p-print-graft-enabled   as logical          no-undo.
    define output parameter p-no-vat-enabled        as logical          no-undo.
      
    do
    on error undo, return error
    :
        assign
            p-type-parts-enabled    = ( if substring( p-print-options, 1, 1 ) = "+" then yes else no )
            p-type-price-enabled    = ( if substring( p-print-options, 2, 1 ) = "+" then yes else no )
            p-type-scale-enabled    = ( if substring( p-print-options, 3, 1 ) = "+" then yes else no )
            p-type-val-enabled      = ( if substring( p-print-options, 4, 1 ) = "+" then yes else no )
            p-sort-name-enabled     = ( if substring( p-print-options, 5, 1 ) = "+" then yes else no )
            p-sort-gr-enabled       = ( if substring( p-print-options, 6, 1 ) = "+" then yes else no )
            p-print-graft-enabled   = ( if substring( p-print-options, 7, 1 ) = "+" then yes else no )
            p-no-vat-enabled        = ( if substring( p-print-options, 8, 1 ) = "+" then yes else no )
        .
    end.
    end procedure. /* menu-doc-set-visible-options */

    /*==========================================================================*/
    procedure menu-doc-create-options-string :
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
            p-options-string =  ( if trim( buf_tmp#list.type-parts  ) = "+":U then "+":U else "-":U )  
                              + ( if trim( buf_tmp#list.type-price  ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.type-scale  ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.type-val    ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.sort-name   ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.sort-gr     ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.print-graft ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.no-vat      ) = "+":U then "+":U else "-":U )

        .
    end.
    end procedure. /* menu-doc-create-options-string */

    /*==========================================================================*/
    procedure menu-doc-set-options-string :
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
            buf_tmp#list.type-parts  = ( if buf_tmp#list.type-parts-enabled     = yes then substitute( "  &1", substring( p-options-string, 1, 1 ) ) else " ":U )
            buf_tmp#list.type-price  = ( if buf_tmp#list.type-price-enabled     = yes then substitute( "  &1", substring( p-options-string, 2, 1 ) ) else " ":U )
            buf_tmp#list.type-scale  = ( if buf_tmp#list.type-scale-enabled     = yes then substitute( "  &1", substring( p-options-string, 3, 1 ) ) else " ":U )
            buf_tmp#list.type-val    = ( if buf_tmp#list.type-val-enabled       = yes then substitute( "  &1", substring( p-options-string, 4, 1 ) ) else " ":U )
            buf_tmp#list.sort-name   = ( if buf_tmp#list.sort-name-enabled      = yes then substitute( "  &1", substring( p-options-string, 5, 1 ) ) else " ":U )
            buf_tmp#list.sort-gr     = ( if buf_tmp#list.sort-gr-enabled        = yes then substitute( "  &1", substring( p-options-string, 6, 1 ) ) else " ":U )
            buf_tmp#list.print-graft = ( if buf_tmp#list.print-graft-enabled    = yes then substitute( "  &1", substring( p-options-string, 7, 1 ) ) else " ":U )
            buf_tmp#list.no-vat      = ( if buf_tmp#list.no-vat-enabled         = yes then substitute( "  &1", substring( p-options-string, 8, 1 ) ) else " ":U )
        .
    end.
    end procedure. /* menu-doc-create-options-string */

    /*==========================================================================*/
    procedure menu-doc-create-options-enabled-string :
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
            p-options-enabled-string =  ( if buf_tmp#list.type-parts-enabled  = yes then "+":U else "-":U )  
                                      + ( if buf_tmp#list.type-price-enabled  = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.type-scale-enabled  = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.type-val-enabled    = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.sort-name-enabled   = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.sort-gr-enabled     = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.print-graft-enabled = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.no-vat-enabled      = yes then "+":U else "-":U )                                      
        .
    end.
    end procedure. /* menu-doc-create-options-string */

    /*==========================================================================*/
    procedure menu-doc-extend-blank-name-for-IBS :
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
    end procedure. /* menu-doc-extend-blank-name-for-IBS */
&else
    &if "{13}" <> '?':U &then
      if {13} then do:
    &endif
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input {1}
           , input {2}
           , input {3}
           , input {4}
           , input {5}
           , input {6}
           , input {7}
           , input {8}
           , input {9}
           , input {10}
           , input {11}
           , input {12}
        ).
    &if "{13}" <> '?':U &then
      end.
    &endif
    {14}
&endif

/* $Workfile$   E n d */