block-level on error undo, throw.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: usrs-prn.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/usrs-prn.p $":U .
def var vss-description as character no-undo init "Список пользователей системы".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
function check-entry-with-mask returns logical ( input p-element as character, input p-list as character, input p-delimiter as character ) :
  define variable p-entry   as logical   no-undo .
  define variable v-ind as integer   no-undo .
  if p-delimiter = "*":U then do:
    message
      vss-workfile "(check-entry-with-mask)" vss-revision vss-description skip
      substitute('Разделитель не может быть равный "&1"', p-delimiter ) skip
      view-as alert-box error .
    return ? .
  end.
  assign
    p-entry = true
  .
  if lookup( p-element, p-list, p-delimiter ) = 0 then do:
    assign
      p-entry = false
    .
    if num-entries( p-list, "*":U ) > 1 then do:
      block_check-list:
      do v-ind = 1 to num-entries( p-list, p-delimiter )
      :
        if p-element matches entry( v-ind, p-list, p-delimiter ) then do:
          assign
            p-entry = true
          .
          leave block_check-list .
        end.
      end.
    end.
  end.
  return p-entry .
end function .
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
        if v-menu-doc-sys-key <> 'ExpertekIBS':U
        and ( ( param-10 <> "":U
                and check-entry-with-mask( v-menu-doc-sys-key, param-10, chr(44) ) = false
              )
              or ( param-12 <> "":U
                   and check-entry-with-mask( v-menu-doc-sys-key, param-12, chr(44) ) = true )
                 )
        then do:
            undo, return .
        end.
        if param-7 = "":U
        then do:
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
            then do:
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
                if v-menu-doc-sys-key = 'ExpertekIBS':U
                then do:
                    run menu-doc-extend-blank-name-for-IBS in this-procedure (
                          input tmp#list.blank-name
                        , input tmp#list.sys-key
                        , input Tmp#List.sys-key-black
                        , output tmp#list.blank-name
                    ).
                end.
            end.
            else do:
                assign
                    v-menu-doc-item-disabled = no
                .
            end.
        end.
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
                if v-menu-doc-sys-key = 'ExpertekIBS':U
                then do:
                    run menu-doc-extend-blank-name-for-IBS in this-procedure (
                          input tmp#list.blank-name
                        , input tmp#list.sys-key
                        , input Tmp#List.sys-key-black
                        , output tmp#list.blank-name
                    ).
                end.
            end.
        end.
    end.
    end procedure.
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
    end procedure.
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
    end procedure.
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
    end procedure.
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
    end procedure.
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
    end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define input  parameter parparentproc as widget-handle no-undo .
define input parameter p-user-id like user-account.user-id no-undo.
define input parameter p-db-num  AS INTEGER no-undo.
DEFINE STREAM out-stream .
DEFINE VARIABLE LineCounter AS INTEGER INITIAL 0   NO-UNDO .
define variable v-user-action   as character no-undo .
define variable v-printed       as logical   no-undo .
define variable Line            as character no-undo.
define variable g#report-num              as integer              no-undo .
def var sym1 as char init ":!:"   no-undo.
def var sym2 as char init ":!:"   no-undo.
def var sym3 as char init ":!:"   no-undo.
MESSAGE 123
view-as alert-box.
run get-report-num in parparentproc (output g#report-num).
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
DEFINE FRAME main
    sym1 column-label ":!:" format "x(1)"
    clients.obj-name     column-label "Макс. скидка / Объекты / Армы! " format "x(100)"
    sym2 column-label ":!:" format "x(1)"
    action-role.action-role-name  column-label "Группа прав! "
    sym3 column-label ":!:" format "x(1)"
    HEADER
        cur-time-print() AT 5 format "x(35)"
            string( "Страница " + string (PAGE-NUMBER( out-stream ) , ">>9") )
                    AT 45 format "X(15)" SKIP
        Line format "X(127)" AT 1
with width 160 down stream-io .
FORM HEADER
      Line format "X(127)" SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width 160 PAGE-BOTTOM NO-LABELS NO-BOX .
      VIEW stream out-stream FRAME BottomFrame .
if session:set-wait-state("compiler") then.
Line = fill("-", 140).
FORM with FRAME main .
if p-user-id = ? then
    PUT STREAM out-stream SPACE(30) "С П И С О К    П О Л Ь З О В А Т Е Л Е Й  С И С Т Е М Ы" FORMAT "X(127)" SKIP.
account_:
FOR EACH  user-account
    WHERE user-account.user-id = p-user-id
    OR    p-user-id = ?
    NO-LOCK
    :
       FIND FIRST user-login
            WHERE user-login.user-id = p-user-id
              AND (user-login.db-num  = p-db-num
                           )
            NO-LOCK
            NO-ERROR
            .
       IF NOT AVAILABLE user-login THEN DO:
          NEXT account_.
       END.
       FIND FIRST _user WHERE _user._userid = user-login.user-login NO-LOCK NO-ERROR.
       if NOT available _user then
           do:
               message string('Пользователь "' + user-account.user-id + '" не найден в таблице _user!') view-as alert-box ERROR.
               NEXT.
           end.
       LineCounter = LineCounter + 1 .
       DISPLAY stream  out-stream
           sym1
           string( string( LineCounter, ">>9" )
                 + ") Пользователь: "
                 + trim( _user._user-name )
                 ) @ clients.obj-name
           sym3
           with FRAME main .
       DOWN stream  out-stream 1 with FRAME main .
       DISPLAY stream  out-stream
           sym1
           string( "     Макс. скидка: " + trim( string( user-login.max-discnt ) ) + " %" ) @ clients.obj-name
           sym2 sym3
           with FRAME main .
       DOWN stream  out-stream 1 with FRAME main .
       DISPLAY stream  out-stream
           sym1 "     Объекты:" @ clients.obj-name
           sym2 sym3
       with FRAME main .
       DOWN stream  out-stream 1 with FRAME main .
       FOR EACH  user-login-action-role
           WHERE user-login-action-role.user-id             = user-account.user-id
             and user-login-action-role.db-num              = p-db-num
             and user-login-action-role.action-role-context = 'object':U
           NO-LOCK,
           FIRST action-role
           WHERE action-role.db-num           = p-db-num
             AND action-role.action-head-code = 0
             AND action-role.action-role-code = user-login-action-role.action-role-code
           NO-LOCK
           :
            FIND FIRST clients
                 WHERE clients.obj-type = user-login-action-role.obj-type
                 AND   clients.obj-code = user-login-action-role.obj-code
                 NO-LOCK
                 NO-ERROR.
            IF NOT AVAILABLE clients THEN
                DO:
                    MESSAGE STRING('В ДБ нет объекта "' + user-login-action-role.obj-type + ' ' + string(user-login-action-role.obj-code) + '" принадлежащего пользователю ' + trim( _user._user-name ) ) view-as alert-box ERROR.
                    NEXT.
                END.
            DISPLAY stream  out-stream
                sym1 clients.obj-name
                sym2 action-role.action-role-name
                sym3
            WITH FRAME main .
            DOWN STREAM  out-stream 1 with FRAME main .
       END.
       DISPLAY stream  out-stream
           sym1 "     Армы:" @ clients.obj-name
           sym2 sym3
           with FRAME main .
       DOWN stream  out-stream 1 with FRAME main .
       FOR EACH  user-login-action-role
           WHERE user-login-action-role.user-id             = user-account.user-id
             and user-login-action-role.db-num              = p-db-num
             and user-login-action-role.action-role-context = 'firm':U
           NO-LOCK,
           FIRST action-role
           WHERE action-role.db-num           = p-db-num
             AND action-role.action-head-code = 0
             AND action-role.action-role-code = user-login-action-role.action-role-code
           NO-LOCK
           :
           DISPLAY stream out-stream
               sym1
               string( "фирма " + string(user-login-action-role.host-code) + ")" ) @ clients.obj-name
               sym2 action-role.action-role-name @ action-role.action-role-name
               sym3
               with FRAME main .
           DOWN stream  out-stream 1 with FRAME main .
       END.
END.
IF ( LINE-COUNTER( out-stream ) + 1 ) > PAGE-SIZE( out-stream )
THEN PAGE STREAM out-stream .
PUT STREAM out-stream Line FORMAT "X(127)" SKIP.
HIDE STREAM out-stream FRAME BottomFrame .
OUTPUT STREAM out-stream CLOSE.
run gbl/prnfilen.w
                   ( input  "":U
                   , input  0
                   , input  string(session :temp-directory)
                          + "rpt"
                          + string( g#report-num )
                   , input  7
                   , output v-user-action
                   , output v-printed
                   ) .
