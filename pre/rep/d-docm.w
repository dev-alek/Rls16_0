define temp-table temp_trn-doc-code no-undo
    field doc-code as character
    index pi is primary unique doc-code
.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-alldocs-handle     as handle           no-undo.
define input parameter table for temp_trn-doc-code .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список печатных форм для печати документов.".
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define new shared variable print-graft as logical no-undo .
define new shared variable no-vat      as logical no-undo .
define new shared variable sort-gr     as logical no-undo .
define new shared variable sort-name   as logical no-undo .
define new shared variable CostPrice   as logical no-undo .
define new shared variable PrintScale  as logical no-undo .
define new shared variable PrintParts  as logical no-undo .
define variable in-docprvalue       as character    no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.1.
DEFINE BUTTON b-deselect
     LABEL "&Снять *"
     SIZE 10 BY 1.1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1.1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 3.5 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-print-doc
     LABEL ".   Пе&чать":L
     SIZE 11.75 BY 1.1
     BGCOLOR 8 .
DEFINE BUTTON b-sel
     LABEL "*"
     SIZE 3 BY 1.1.
DEFINE BUTTON i-print
     IMAGE-UP FILE "cmp/b-print.bmp":U
     IMAGE-DOWN FILE "cmp/b-print.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-print.bmp":U
     LABEL ""
     SIZE 4 BY .96.
DEFINE VARIABLE fi-default-printer AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 97 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY br-table FOR
      Tmp#List SCROLLING.
DEFINE BROWSE br-table
  QUERY br-table NO-LOCK DISPLAY
    Tmp#List.last-use COLUMN-LABEL "*" FORMAT "*/"
    Tmp#List.blank-name COLUMN-LABEL "Название печатной формы":C53 FORMAT "X(128)"
    Tmp#List.type-parts     column-label "ц.пар"    format "X(5)"
    Tmp#List.type-price     column-label "ц.док"    format "X(5)"
    Tmp#List.type-scale     column-label "шкала"    format "X(5)"
    Tmp#List.type-val       column-label "в ..."    format "X(5)"
    Tmp#List.sort-name      column-label "по наим"  format "X(7)"
    Tmp#List.sort-gr        column-label "по гр"    format "X(5)"
    Tmp#List.print-graft    column-label "по арт"   format "X(4)"
    Tmp#List.no-vat         column-label "-НДС"     format "X(4)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.88 BY 20.25 EXPANDABLE.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1.63
     b-sel AT ROW 1 COL 11.63
     b-deselect AT ROW 1 COL 14.63
     b-chg AT ROW 1 COL 24.75
     b-print-doc AT ROW 1 COL 34.75
     b-help AT ROW 1 COL 96
     i-print AT ROW 1.04 COL 35 WIDGET-ID 2 NO-TAB-STOP
     br-table AT ROW 2.25 COL 1.63
     fi-default-printer AT ROW 22.75 COL 1.5 NO-LABEL
     SPACE(1.37) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список печатных форм".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       fi-default-printer:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
    if available tmp#list
    then do:
        define variable v-options-string            as character    no-undo.
        define variable v-options-string-new        as character    no-undo.
        define variable v-options-enabled-string    as character    no-undo.
        run menu-doc-create-options-string in this-procedure (
              input tmp#list.id
            , output v-options-string
        ).
        run menu-doc-create-options-enabled-string in this-procedure (
              input tmp#list.id
            , output v-options-enabled-string
        ).
        run rep/d-docmd.w (
              input tmp#list.blank-name
            , input v-options-string
            , input v-options-enabled-string
            , output v-options-string-new
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка изменения параметров печати."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        if v-options-string-new <> v-options-string
        then do:
            run menu-doc-set-options-string in this-procedure (
                    input tmp#list.id
                  , input v-options-string-new
            ).
            browse br-table :refresh().
            apply "entry" to br-table in frame Dialog-Frame.
        end.
    end.
END.
ON CHOOSE OF b-deselect IN FRAME Dialog-Frame
DO:
    for each tmp#list no-lock
    :
        assign
            tmp#list.last-use = no
        .
    end.
    browse br-table :refresh().
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    run save-form-parameters in this-procedure no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка при сохранении параметров"
            skip "списка печатных форм."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
    end.
END.
ON CHOOSE OF b-print-doc IN FRAME Dialog-Frame
DO:
    define variable v-is-selected   as logical      no-undo.
    define buffer buf_temp_tmp#list      for tmp#list.
    assign
        v-is-selected = no
    .
    test-selecting:
    for each buf_temp_tmp#list
    :
        if buf_temp_tmp#list.last-use <> no
        then do:
            assign
                v-is-selected = yes
            .
            leave test-selecting.
        end.
    end.
    if v-is-selected = no
    then do:
        message
            "Не выбрано ни одной формы"
            skip "для печати."
        view-as alert-box information
        title "Печать невозможна"
        .
        undo, return no-apply.
    end.
    else do:
        run print-docs in this-procedure no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка печати документов."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
    if available tmp#list
    then do:
        assign
            tmp#list.last-use = ( if tmp#list.last-use = yes then no else yes )
        .
        run reposition-browse in this-procedure .
        browse br-table :refresh().
    end.
END.
ON 1 OF br-table IN FRAME Dialog-Frame
DO:
    if available tmp#list
    then do:
        if tmp#list.type-parts = "  +":U
        or tmp#list.type-parts = "  -":U
        then do:
            assign
                tmp#list.type-parts = ( if tmp#list.type-parts = "  +":U then "  -":U else "  +":U )
            .
        end.
        br-table :refresh().
    end.
END.
ON 2 OF br-table IN FRAME Dialog-Frame
DO:
    if available tmp#list
    then do:
        if tmp#list.type-price = "  +":U
        or tmp#list.type-price = "  -":U
        then do:
            assign
                tmp#list.type-price = ( if tmp#list.type-price = "  +":U then "  -":U else "  +":U )
            .
        end.
        br-table :refresh().
    end.
END.
ON 3 OF br-table IN FRAME Dialog-Frame
DO:
    if available tmp#list
    then do:
        if tmp#list.type-scale = "  +":U
        or tmp#list.type-scale = "  -":U
        then do:
            assign
                tmp#list.type-scale = ( if tmp#list.type-scale = "  +":U then "  -":U else "  +":U )
            .
        end.
        br-table :refresh().
    end.
END.
ON 4 OF br-table IN FRAME Dialog-Frame
DO:
    if available tmp#list
    then do:
        if tmp#list.type-val = "  +":U
        or tmp#list.type-val = "  -":U
        then do:
            assign
                tmp#list.type-val = ( if tmp#list.type-val = "  +":U then "  -":U else "  +":U )
            .
        end.
        br-table :refresh().
    end.
END.
ON 5 OF br-table IN FRAME Dialog-Frame
DO:
    if available tmp#list
    then do:
        if tmp#list.sort-name = "  +":U
        or tmp#list.sort-name = "  -":U
        then do:
            assign
                tmp#list.sort-name = ( if tmp#list.sort-name = "  +":U then "  -":U else "  +":U )
            .
        end.
        br-table :refresh().
    end.
END.
ON 6 OF br-table IN FRAME Dialog-Frame
DO:
    if available tmp#list
    then do:
        if tmp#list.sort-gr = "  +":U
        or tmp#list.sort-gr = "  -":U
        then do:
            assign
                tmp#list.sort-gr = ( if tmp#list.sort-gr = "  +":U then "  -":U else "  +":U )
            .
        end.
        br-table :refresh().
    end.
END.
ON 7 OF br-table IN FRAME Dialog-Frame
DO:
    if available tmp#list
    then do:
        if tmp#list.print-graft = "  +":U
        or tmp#list.print-graft = "  -":U
        then do:
            assign
                tmp#list.print-graft = ( if tmp#list.print-graft = "  +":U then "  -":U else "  +":U )
            .
        end.
        br-table :refresh().
    end.
END.
ON 8 OF br-table IN FRAME Dialog-Frame
DO:
    if available tmp#list
    then do:
        if tmp#list.no-vat      = "  +":U
        or tmp#list.no-vat      = "  -":U
        then do:
            assign
                tmp#list.no-vat      = ( if tmp#list.no-vat      = "  +":U then "  -":U else "  +":U )
            .
        end.
        br-table :refresh().
    end.
END.
ON MOUSE-SELECT-DBLCLICK OF br-table IN FRAME Dialog-Frame
DO:
    if available Tmp#List
    then do:
        run select-or-deselect-item in this-procedure (
            input Tmp#List.id
        ) no-error.
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description
                skip "Ошибка выбора или отмены выбора."
                skip return-value
                skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        br-table :refresh().
    end.
END.
ON ROW-DISPLAY OF br-table IN FRAME Dialog-Frame
DO:
    if tmp#list.type-price-enabled = no
    then do:
        assign
            Tmp#List.type-price :bgcolor in browse br-table = GREY_COLOR
        .
    end.
    if tmp#list.type-scale-enabled = no
    then do:
        assign
            Tmp#List.type-scale :bgcolor in browse br-table = GREY_COLOR
        .
    end.
    if tmp#list.type-val-enabled = no
    then do:
        assign
            Tmp#List.type-val :bgcolor in browse br-table = GREY_COLOR
        .
    end.
    if tmp#list.sort-name-enabled = no
    then do:
        assign
            Tmp#List.sort-name :bgcolor in browse br-table = GREY_COLOR
        .
    end.
    if tmp#list.sort-gr-enabled = no
    then do:
        assign
            Tmp#List.sort-gr :bgcolor in browse br-table = GREY_COLOR
        .
    end.
    if tmp#list.print-graft-enabled = no
    then do:
        assign
            Tmp#List.print-graft :bgcolor in browse br-table = GREY_COLOR
        .
    end.
    if tmp#list.no-vat-enabled = no
    then do:
        assign
            Tmp#List.no-vat :bgcolor in browse br-table = GREY_COLOR
        .
    end.
    if tmp#list.type-parts-enabled = no
    then do:
        assign
            Tmp#List.type-parts :bgcolor in browse br-table = GREY_COLOR
        .
    end.
    if lookup("other", tmp#list.filtr) > 0  then do:
        assign
            Tmp#List.last-use          :bgcolor in browse br-table = yellow_COLOR
            Tmp#List.blank-name        :bgcolor in browse br-table = yellow_COLOR
        .
    end.
    else do:
        assign
            Tmp#List.last-use          :bgcolor in browse br-table = ?
            Tmp#List.blank-name        :bgcolor in browse br-table = ?
        .
    end.
    if Tmp#List.orient-font-num <> 7
    then do:
        assign
            Tmp#List.last-use          :fgcolor in browse br-table = DARK_GREEN_COLOR
            Tmp#List.blank-name        :fgcolor in browse br-table = DARK_GREEN_COLOR
        .
    end.
    else do:
        if Tmp#List.orient-orientation = 'A4port':U
        or Tmp#List.orient-orientation = 'A3port':U
        then do:
            Tmp#List.last-use          :fgcolor in browse br-table = BLUE_COLOR.
            Tmp#List.blank-name        :fgcolor in browse br-table = BLUE_COLOR.
        end.
        else do:
            if Tmp#List.orient-orientation = 'EXCEL':U
            or Tmp#List.orient-orientation = 'self':U
            then do:
                Tmp#List.last-use   :fgcolor in browse br-table = CYAN_COLOR.
                Tmp#List.blank-name :fgcolor in browse br-table = CYAN_COLOR.
            end.
            else do:
                Tmp#List.last-use   :fgcolor in browse br-table = BLACK_COLOR.
                Tmp#List.blank-name :fgcolor in browse br-table = BLACK_COLOR.
            end.
        end.
    end.
END.
ON CHOOSE OF i-print IN FRAME Dialog-Frame
DO:
  APPLY "choose" TO b-print-doc.
END.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-table :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    Tmp#List.type-val:label =  "в руб"  .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in p-mainmenu-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
  ,input 'prt-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'in-docpr' then in-docprvalue =  thbjattr_thbj-attr.property-value-character .
    end.
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    run init-fields in this-procedure.
    RUN enable_UI.
    run ui-disable-all in this-procedure.
    run ui-enable in this-procedure.
    apply "value-changed" to br-table.
    apply "entry" to br-table.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE create-menu-items1 :
define input parameter p-doc-code       as character        no-undo.
define input parameter p-doc-type       as character        no-undo.
define input parameter p-ext-doc-type   as character        no-undo.
define input parameter p-status_        as character        no-undo.
define input parameter p-Internal       as character        no-undo.
define input parameter p-flag_          as character        no-undo.
    define variable xtype        as character    no-undo.
    define variable xstatus      as character    no-undo.
    define variable xInternal    as character    no-undo.
    define variable xflag        as character    no-undo.
do
on error undo, return error
:
    if p-doc-type <> 'инв':U
    then do:
        assign
            xtype = p-doc-type
        .
    end.
    else do:
        assign
            xtype = p-ext-doc-type
        .
    end.
    assign
        xstatus             = string( p-status_  )
        xInternal           = string( p-Internal )
        xflag               = string( p-flag_    )
    .
    assign
        v-menu-doc-doc-code     = p-doc-code
        v-menu-doc-doc-type     = xtype
        v-menu-doc-ext-doc-type = p-ext-doc-type
        v-menu-doc-status_      = xstatus
        v-menu-doc-internal     = xInternal
        v-menu-doc-flag         = xflag
    .
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile: load-doc.i $ $Revision: 992a74a9441b, 3581, rls $".
define variable is-ptrl  as character no-undo .
define variable is-jwlr  as character no-undo .
define variable par-type as character no-undo .
run gbl/conf-rd.p ("is-ptrl", "", "", 0, "", "", "", no, output is-ptrl, output par-type) no-error.
if error-status :error
  or par-type <> "l"
  or is-ptrl  <> "yes"
then do:
  assign is-ptrl = "no".
end.
run gbl/conf-rd.p ("is-jwlr", "", "", 0, "", "", "", no, output is-jwlr, output par-type) no-error.
if error-status :error
  or par-type <> "l"
  or is-jwlr  <> "yes"
then do:
  assign is-jwlr = "no".
end.
define variable vss-include-info13 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Расходная накладная (с упаковками)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-outretu.p'
           , input 'no'
           , input '-++++++-'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info14 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input '*'
           , input 'yes'
           , input '*'
           , input 'Накладная расхода (короткая форма)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-outret.p'
           , input 'no,no'
           , input '-++++++-'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info15 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input '*'
           , input 'yes'
           , input '*'
           , input 'Накладная расхода (Аптека)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-outrta.p'
           , input 'no'
           , input '-++++++-'
           , input 'ODIS'
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info16 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input '*'
           , input 'yes'
           , input '*'
           , input 'Накладная ТАМОЖНЯ (короткая форма)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-outrec.p'
           , input 'no'
           , input '-++++++-'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info17 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'разрешен':U
           , input '*'
           , input '*'
           , input 'Список на отгрузку'
           , input 'cost,sale,rubl,base'
           , input 'rep/load-lst.w'
           , input ''
           , input '--------'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info18 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Возвратная накладная Румыния'
           , input 'cost,sale,rubl,base'
           , input in-docprvalue
           , input ''
           , input '--------'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info19 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'ТН Приложение № 4 (Бизнес-Букет)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-f_t1.p'
           , input 'no,TopAukc,no'
           , input '---+----'
           , input 'TopAukc'
           , input ''
           , input ''
        ).
define variable vss-include-info20 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'ТН Приложение № 4'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-f_t1.p'
           , input 'no,all,no'
           , input '-+-+----'
           , input ''
           , input ''
           , input 'mag,Mari,iab,ng,Rosneft-Moscow'
        ).
define variable vss-include-info21 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'Типовая межотраслевая форма № 1-Т (Бизнес-Букет)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-ft1old.p'
           , input 'no,TopAukc,no-round,no,no'
           , input '---+----'
           , input 'TopAukc'
           , input ''
           , input ''
        ).
define variable vss-include-info22 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'Типовая межотраслевая форма № 1-Т'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-ft1old.p'
           , input 'no,all,no-round,no,no'
           , input '-++++++-'
           , input ''
           , input ''
           , input 'mag,Mari,iab,ng,Rosneft-Moscow'
        ).
define variable vss-include-info23 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Документ ТОРГ12 (Бизнес-Букет)'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12.p'
           , input 'no,TopAukc;Vnesh_art,no-round,no,no'
           , input '-++++++-'
           , input 'TopAukc'
           , input ''
           , input ''
        ).
define variable vss-include-info24 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Документ ТОРГ12 ГТД (Бизнес-Букет)'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12.p'
           , input 'no,TopAukc;GTD,no-round,no,no'
           , input '-+-++++-'
           , input 'TopAukc'
           , input ''
           , input ''
        ).
define variable vss-include-info25 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'Документ ТОРГ12'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12.p'
           , input 'no,all,no-round,no,no'
           , input '-++++++-'
           , input ''
           , input ''
           , input 'mag,Mari,iab,ng,Rosneft-Moscow'
        ).
define variable vss-include-info26 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'Документ ТОРГ12'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12.p'
           , input 'no,KEDR,no-round,no,no'
           , input '-++++++-'
           , input 'Rosneft-Moscow'
           , input ''
           , input ''
        ).
define variable vss-include-info27 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'Документ ТОРГ12 обратная'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12.p'
           , input 'no,all,no-round,no,yes'
           , input '-++++++-'
           , input ''
           , input ''
           , input 'mag,Mari,iab,ng'
        ).
define variable vss-include-info28 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Топливная накладная'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12p.p'
           , input ''
           , input '---+++--'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info29 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Документ ТОРГ12'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12.p'
           , input 'no,mag,no-round,no,no'
           , input '-++++++-'
           , input 'mag'
           , input ''
           , input ''
        ).
define variable vss-include-info30 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Документ ТОРГ12'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12.p'
           , input 'no,Mari,no-round,no,no'
           , input '-++++++-'
           , input 'Mari'
           , input ''
           , input ''
        ).
define variable vss-include-info31 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'Документ ТОРГ12'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12.p'
           , input 'no,iab,no-round,no,no'
           , input '-++++++-'
           , input 'IAB'
           , input ''
           , input ''
        ).
define variable vss-include-info32 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Документ ТОРГ12'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12.p'
           , input 'no,ng,no-round,no,no'
           , input '-++++++-'
           , input 'NG'
           , input ''
           , input ''
        ).
define variable vss-include-info33 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Документ ТОРГ12 по чекам'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12.p'
           , input 'no,all,no-round,yes,no'
           , input '-++++++-'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info34 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Документ ТОРГ12 по складским местам'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg12pl.p'
           , input 'all'
           , input '-+-+----'
           , input 'IBS'
           , input ''
           , input 'mag'
        ).
define variable vss-include-info35 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Документ ТОРГ12 по складским местам'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg12pl.p'
           , input 'mag'
           , input '-+-+----'
           , input 'IBSmag'
           , input ''
           , input ''
        ).
define variable vss-include-info36 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Документ ТОРГ12 с округлением'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12.p'
           , input 'no,all,round,no,no'
           , input '-++++++-'
           , input ''
           , input ''
           , input 'mag,Mari'
        ).
define variable vss-include-info37 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Документ ТОРГ12 с округлением'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12.p'
           , input 'no,mag,round,no,no'
           , input '-++++++-'
           , input 'mag'
           , input ''
           , input ''
        ).
define variable vss-include-info38 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Документ ТОРГ12 с округлением'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12.p'
           , input 'no,Mari,round,no,no'
           , input '-++++++-'
           , input 'Mari'
           , input ''
           , input ''
        ).
define variable vss-include-info39 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Упаковочный лист поставщика'
           , input 'cost,sale,rubl,base'
           , input 'rep/pack-list.p'
           , input ''
           , input '--------'
           , input ''
           , input 'EXCEL'
           , input ''
        ).
define variable vss-include-info40 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Накладная с артикулом поставщика'
           , input 'cost,sale,rubl,base'
           , input 'rep/t12-art.p'
           , input ''
           , input '-+++++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info41 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'Список сертификатов к накладной'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-sert.p'
           , input ''
           , input '--------'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info42 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'Список сертификатов к накладной (расширенный)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-sert1.p'
           , input ''
           , input '--------'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info43 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input '*'
           , input 'yes'
           , input '*'
           , input 'Документ ТОРГ13'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-13.p'
           , input 'no,no,no'
           , input '++++++++'
           , input ''
           , input ''
           , input 'zum'
        ).
define variable vss-include-info44 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input '*'
           , input 'yes'
           , input '*'
           , input 'Документ внутреннего перемещения'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-13x.p'
           , input 'no,no,no'
           , input '-+++++--'
           , input 'iab,NG,Statir'
           , input 'HTML'
           , input ''
        ).
define variable vss-include-info45 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input '*'
           , input 'yes'
           , input '*'
           , input 'Документ внутреннего перемещения с фото товара'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-13x-foto.p'
           , input 'no,no,no'
           , input '-+++++--'
           , input ''
           , input 'HTML'
           , input ''
        ).
define variable vss-include-info46 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input '*'
           , input 'yes'
           , input '*'
           , input 'Документ  ТОРГ13'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-13.p'
           , input 'no,yes,no'
           , input '++++++++'
           , input 'zum'
           , input ''
           , input ''
        ).
define variable vss-include-info47 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input 'yes'
           , input '*'
           , input 'Документ ТОРГ13 для ювелирных изделий'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-13.p'
           , input 'yes,yes,yes'
           , input '++++++--'
           , input 'zum'
           , input ''
           , input ''
        ).
define variable vss-include-info48 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'спи':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Документ Списания ТОРГ16'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-16.p'
           , input ''
           , input '-+++--++'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info49 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'спи':U
           , input 'факт':U
           , input 'no'
           , input '*'
           , input 'Документ Списания ТОРГ15'
           , input 'cost,rubl,base'
           , input 'rep/torg-15.p'
           , input ''
           , input '-------'
           , input ''
           , input 'HTML'
           , input ''
        ).
define variable vss-include-info50 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'спи':U
           , input 'факт':U
           , input 'no'
           , input '*'
           , input 'АКТ учета НП при выполнении ремонтных работ'
           , input 'cost,rubl,base'
           , input 'rep/akt-np-make.p'
           , input ''
           , input '-------'
           , input ''
           , input 'HTML'
           , input ''
        ).
define variable vss-include-info51 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,спи,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'Спецификация по партиям к документу'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-specif.p'
           , input 'no'
           , input '--------'
           , input ''
           , input ''
           , input 'world'
        ).
define variable vss-include-info52 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'Счет-фактура (формат 2011г.)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-sf-old.p'
           , input 'no,all,no-round,no,no'
           , input '-+++--+-'
           , input ''
           , input ''
           , input 'GreenL,zum'
        ).
define variable vss-include-info53 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт':U
           , input '*'
           , input '*'
           , input 'Корректировочный счет-фактура в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'no,corr,no-round,no,no'
           , input '-+++--+-'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info54 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'Счет-фактура в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'no,all,no-round,no,no'
           , input '-+++--+-'
           , input ''
           , input ''
           , input 'GreenL,zum'
        ).
define variable vss-include-info55 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура обратная в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'no,all,no-round,no,yes'
           , input '-+++--+-'
           , input ''
           , input ''
           , input 'GreenL,zum'
        ).
define variable vss-include-info56 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'no,zum,no-round,no,no'
           , input '-+++--+-'
           , input 'zum'
           , input ''
           , input ''
        ).
define variable vss-include-info57 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'no,GreenL,no-round,no,no'
           , input '-+++--+-'
           , input 'GreenL'
           , input ''
           , input ''
        ).
define variable vss-include-info58 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура (Бизнес-Букет) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'no,TopAukc,no-round,no,no'
           , input '-+++--+-'
           , input 'TopAukc'
           , input ''
           , input ''
        ).
define variable vss-include-info59 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура на услуги в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'no,serv,no-round,no,no'
           , input '-+++--+-'
           , input ''
           , input ''
           , input 'GreenL,zum'
        ).
define variable vss-include-info60 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура с округлением в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'no,all,round,no,no'
           , input '-+++--+-'
           , input ''
           , input ''
           , input 'zum'
        ).
define variable vss-include-info61 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура с округлением в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'no,zum,round,no,no'
           , input '-+++--+-'
           , input 'zum'
           , input ''
           , input ''
        ).
define variable vss-include-info62 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура старая (без НП) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'no,all,no-round,yes,no'
           , input '-+++--+-'
           , input ''
           , input ''
           , input 'GreenL,zum'
        ).
define variable vss-include-info63 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура старая (без НП) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'no,zum,no-round,yes,no'
           , input '-+++--+-'
           , input 'zum'
           , input ''
           , input ''
        ).
define variable vss-include-info64 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура старая (без НП) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'no,GreenL,no-round,yes,no'
           , input '-+++--+-'
           , input 'GreenL'
           , input ''
           , input ''
        ).
define variable vss-include-info65 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура (в редакции от 02.04.2021)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur-2021.p'
           , input 'no,all,no-round,no,no'
           , input '-+++----'
           , input ''
           , input 'HTML'
           , input 'GreenL,zum'
        ).
define variable vss-include-info66 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура (в редакции от 23.01.2026)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur-2026.p'
           , input 'no,all,no-round,no,no'
           , input '-+++----'
           , input ''
           , input 'HTML'
           , input 'GreenL,zum'
        ).
define variable vss-include-info67 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура старая с округлением (без НП) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'no,all,round,yes,no'
           , input '-+++--+-'
           , input ''
           , input ''
           , input 'zum'
        ).
define variable vss-include-info68 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура старая с округлением (без НП) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'no,zum,round,yes,no'
           , input '-+++--+-'
           , input 'zum'
           , input ''
           , input ''
        ).
define variable vss-include-info69 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'Счёт-фактура с итогами по НДС в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/factur.p'
           , input 'no,no,vat-itog,no-round,yes'
           , input '-++++-+-'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info70 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура (без НП) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/factur.p'
           , input 'no,no,all,no-round,yes'
           , input '-+++--+-'
           , input ''
           , input ''
           , input 'GreenL,zum'
        ).
define variable vss-include-info71 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура (без НП) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/factur.p'
           , input 'no,no,zum,no-round,yes'
           , input '-+++--+-'
           , input 'zum'
           , input ''
           , input ''
        ).
define variable vss-include-info72 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура (без НП) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/factur.p'
           , input 'no,no,GreenL,no-round,yes'
           , input '-+++--+-'
           , input 'GreenL'
           , input ''
           , input ''
        ).
define variable vss-include-info73 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счёт-фактура до 10-го знака в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/factur.p'
           , input 'no,no,dec10,no-round,yes'
           , input '-++++-+-'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info74 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура с округлением (без НП) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/factur.p'
           , input 'no,no,all,round,yes'
           , input '-+++--+-'
           , input ''
           , input ''
           , input 'zum'
        ).
define variable vss-include-info75 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Счет-фактура с округлением (без НП) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/factur.p'
           , input 'no,no,zum,round,yes'
           , input '-+++--+-'
           , input 'zum'
           , input ''
           , input ''
        ).
define variable vss-include-info76 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'Рахунок-фактура'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-sf-ukr.p'
           , input 's-f'
           , input '-+-+----'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info77 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'накл':U
           , input '*'
           , input 'yes'
           , input 'Рахунок'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-sf-ukr.p'
           , input 'rahunok'
           , input '-+-+----'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info78 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт':U + chr(44) + 'разрешен':U
           , input '*'
           , input '*'
           , input 'Рахунок'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-sf-ukr.p'
           , input 'rahunok'
           , input '-+-+----'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info79 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'Витратна накладная'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-sf-ukr.p'
           , input 'vit-nakl'
           , input '-+-+----'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info80 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт':U
           , input '*'
           , input 'no'
           , input 'Акт несоответствия'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-nesoot.p'
           , input '1'
           , input '-+------'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info81 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт':U
           , input '*'
           , input 'no'
           , input 'Акт несоответствия с округлением'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-nest2.p'
           , input '1,'
           , input '--------'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info82 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт автоматической переоценки'
           , input 'crsa,sale,rubl,base'
           , input 'rep/avt-akt0.p'
           , input 'all'
           , input '--------'
           , input ''
           , input ''
           , input 'ParCom'
        ).
define variable vss-include-info83 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт автоматической переоценки'
           , input 'crsa,sale,rubl,base'
           , input 'rep/avt-akt0.p'
           , input 'ParCom'
           , input '--------'
           , input 'ParCom'
           , input ''
           , input ''
        ).
define variable vss-include-info84 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт автоматической переоценки топлива (весовой учет)'
           , input 'crsa,sale,rubl,base'
           , input 'rep/autoact0.p'
           , input 'all'
           , input '--------'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info85 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт':U
           , input 'no'
           , input '*'
           , input 'Справка А-Б'
           , input 'sale,rubl,base'
           , input 'rep/formA-B.p'
           , input ''
           , input '--------'
           , input ''
           , input 'HTML'
           , input ''
        ).
define variable vss-include-info86 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт':U
           , input 'yes'
           , input '*'
           , input 'Справка Б'
           , input 'sale,rubl,base'
           , input 'rep/formA-B.p'
           , input ''
           , input '--------'
           , input ''
           , input 'HTML'
           , input ''
        ).
define variable vss-include-info87 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт формирования продажной цены  (текущие продажные цены)'
           , input 'sale,rubl,base'
           , input 'rep/avt-akt.p'
           , input 'yes,no'
           , input '----+---'
           , input ''
           , input ''
           , input 'Basis'
        ).
define variable vss-include-info88 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт формирования продажной цены  (цены на момент закрытия)'
           , input 'sale,rubl,base'
           , input 'rep/avt-akt.p'
           , input 'no,no'
           , input '----+---'
           , input ''
           , input ''
           , input 'Basis,'
        ).
define variable vss-include-info89 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт формирования продажной цены  (текущие продажные цены)'
           , input 'sale,rubl,base'
           , input 'rep/avt-akt1.p'
           , input 'yes'
           , input '--------'
           , input 'Basis'
           , input ''
           , input ''
        ).
define variable vss-include-info90 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт формирования продажной цены  (цены на момент закрытия)'
           , input 'sale,rubl,base'
           , input 'rep/avt-akt1.p'
           , input 'no'
           , input '--------'
           , input 'Basis'
           , input ''
           , input ''
        ).
define variable vss-include-info91 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Протокол согласования отпускных цен'
           , input 'sale,rubl,base'
           , input 'rep/r-protcl.p'
           , input '1,no'
           , input '--------'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info92 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Протокол согласования отпускных цен c округлением'
           , input 'sale,rubl,base'
           , input 'rep/r-avprtc.p'
           , input '1,no'
           , input '--++----'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info93 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-jwlr = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Документ для ювелирных изделий'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12z.p'
           , input 'no'
           , input '-+-+-+--'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info94 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'Ценники (этикетки)         '
           , input 'cost,sale,rubl,base'
           , input 'rep/tick-doc.p'
           , input 'trn,1,no,no'
           , input '--------'
           , input ''
           , input 'self'
           , input ''
        ).
define variable vss-include-info95 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,спи':U
           , input 'факт,разрешен,накл,прво':U
           , input 'yes'
           , input '*'
           , input 'Документ ОП-4 накладная производства'
           , input 'cost,sale,rubl,base'
           , input 'rep/op-4.p'
           , input ''
           , input '---+----'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info96 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,спи,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input '*'
           , input '*'
           , input 'Спецификация по партиям'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-specif.p'
           , input 'yes'
           , input '---+----'
           , input 'world,SportC'
           , input ''
           , input ''
        ).
define variable vss-include-info97 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'разрешен,факт,накл'
           , input '*'
           , input '*'
           , input 'Счет с разбивкой по НДС'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-schflr.p'
           , input ''
           , input '---+----'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info98 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт':U
           , input 'no'
           , input '*'
           , input 'Счет'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-schet1.p'
           , input ''
           , input '-+++++--'
           , input ''
           , input ''
           , input 'mag'
        ).
define variable vss-include-info99 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'накл':U
           , input 'no'
           , input '*'
           , input 'Счет'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-schet1.p'
           , input ''
           , input '-+++++--'
           , input ''
           , input ''
           , input 'mag'
        ).
define variable vss-include-info100 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'накл':U
           , input 'no'
           , input 'yes'
           , input 'Счет'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-schet.p'
           , input 'mag'
           , input '--++----'
           , input 'mag'
           , input ''
           , input ''
        ).
define variable vss-include-info101 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'запрос':U
           , input 'no'
           , input 'yes'
           , input 'Счет'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-schet1.p'
           , input ''
           , input '-+++++--'
           , input ''
           , input ''
           , input 'mag'
        ).
define variable vss-include-info102 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'запрос':U
           , input 'no'
           , input 'yes'
           , input 'Запрос'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-schet.p'
           , input 'mag'
           , input '---+----'
           , input 'mag'
           , input ''
           , input ''
        ).
define variable vss-include-info103 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'запрос':U
           , input 'no'
           , input '*'
           , input 'Запрос'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-schet.p'
           , input 'all'
           , input '---+----'
           , input ''
           , input ''
           , input 'mag'
        ).
define variable vss-include-info104 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Накладная расхода (короткая форма)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-outret.p'
           , input 'no,no'
           , input '-++++++-'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info105 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт,разрешен,накл,прво':U
           , input 'no'
           , input '*'
           , input 'Накладная расхода (короткая форма) Аптека'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-outrta.p'
           , input 'no'
           , input '-++++++-'
           , input 'ODIS'
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info106 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'спи':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Накладная списания (короткая форма)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-outret.p'
           , input 'no,no'
           , input '-++++++-'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info107 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'спи':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Накладная списания (короткая форма.Spar)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-outret.p'
           , input 'no,SPAR'
           , input '-++++++-'
           , input 'SPAR'
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info108 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'спи':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Служебная записка (Роснефть)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-wofrosneft.p'
           , input 'no,no'
           , input '--------'
           , input 'yukos,ibs,Rosneft-*'
           , input 'self'
           , input ''
        ).
define variable vss-include-info109 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Выгрузка товарной накладной'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-unlway.p'
           , input ''
           , input '-+-+----'
           , input 'Can_Ru'
           , input 'EXCEL'
           , input ''
        ).
define variable vss-include-info110 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'спи':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Акт о списании материалов'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-16a.p'
           , input ''
           , input '--++----'
           , input 'zum'
           , input ''
           , input ''
        ).
define variable vss-include-info111 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'запрос,готов'
           , input '*'
           , input '*'
           , input 'Заказ флористов - бланк № 1'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-flor1.p'
           , input ''
           , input '---+----'
           , input ''
           , input 'self'
           , input ''
        ).
define variable vss-include-info112 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'разрешен,факт,накл'
           , input '*'
           , input '*'
           , input 'Заказ флористов - бланк № 2'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-flor2.p'
           , input ''
           , input '---+----'
           , input ''
           , input 'self'
           , input ''
        ).
define variable vss-include-info113 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'разрешен,факт,накл'
           , input '*'
           , input '*'
           , input 'Заказ флористов - бланк № 2(TRADE)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-flor4.p'
           , input ''
           , input '---+----'
           , input ''
           , input 'self'
           , input ''
        ).
define variable vss-include-info114 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Эффективность движения товара'
           , input 'cost,sale,rubl,base'
           , input 'rep/eff-move.p'
           , input ''
           , input '---+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info115 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Товарный чек'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-outret.p'
           , input 'yes,no'
           , input '-++++++-'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info116 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Распоряжение на склад'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-alkout.p'
           , input ''
           , input '--------'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info117 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if v-menu-doc-ext-doc-type = 'ep':U  then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input '*'
           , input '*'
           , input 'АКТ (ТОРГ-2)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-torg2.p'
           , input ''
           , input '----++--'
           , input ''
           , input 'A4port'
           , input ''
        ).
      end.
define variable vss-include-info118 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if v-menu-doc-ext-doc-type = 'ep':U  then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Претензия'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-pret.p'
           , input ''
           , input '--------'
           , input ''
           , input 'A4port'
           , input ''
        ).
      end.
define variable vss-include-info119 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Маршрутный лист - по выделенным накладным'
           , input 'other,no-print-many'
           , input 'rep/mar-list.p'
           , input ''
           , input '--------'
           , input ''
           , input 'EXCEL'
           , input ''
        ).
define variable vss-include-info120 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Лист журнала фасовочных работ'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-fasov.p'
           , input ''
           , input '---+++--'
           , input ''
           , input 'A4lans'
           , input ''
        ).
define variable vss-include-info121 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Стеллажная карта'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-stkard.p'
           , input ''
           , input '--------'
           , input ''
           , input 'self'
           , input ''
        ).
define variable vss-include-info122 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Документ приход Румыния'
           , input 'cost,sale,rubl,base'
           , input in-docprvalue
           , input ''
           , input '--------'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info123 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Накладная прихода (короткая форма)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-inp.p'
           , input ''
           , input '-+++++--'
           , input ''
           , input 'A4port'
           , input 'zum,UKR'
        ).
define variable vss-include-info124 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Накладная прихода (короткая форма)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-inp-uk.p'
           , input ''
           , input '-+++++--'
           , input 'UKR'
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info125 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input 'факт':U
           , input 'yes'
           , input '*'
           , input 'Накладная прихода (Аптека)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-outrta.p'
           , input 'no'
           , input '-++++++-'
           , input 'ODIS'
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info126 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Документ ТОРГ12'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12.p'
           , input 'no,all,no-round,no,no'
           , input '-++++++-'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info127 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Накладная с артикулом поставщика'
           , input 'cost,sale,rubl,base'
           , input 'rep/t12-art.p'
           , input ''
           , input '-+++++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info128 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'yes'
           , input '*'
           , input 'Документ ТОРГ13'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-13.p'
           , input 'no,no,no'
           , input '++++++-+'
           , input ''
           , input ''
           , input 'zum'
        ).
define variable vss-include-info129 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'yes'
           , input '*'
           , input 'Документ внутреннего перемещения'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-13x.p'
           , input 'no,no,no'
           , input '-+++++--'
           , input 'iab,NG'
           , input 'HTML'
           , input ''
        ).
define variable vss-include-info130 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'yes'
           , input '*'
           , input 'Документ внутреннего перемещения с фото товара'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-13x-foto.p'
           , input 'no,no,no'
           , input '-+++++--'
           , input ''
           , input 'HTML'
           , input ''
        ).
define variable vss-include-info131 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'yes'
           , input '*'
           , input 'Документ  ТОРГ13'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-13.p'
           , input 'no,yes,no'
           , input '++++++--'
           , input 'zum'
           , input ''
           , input ''
        ).
define variable vss-include-info132 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'yes'
           , input '*'
           , input 'Документ ТОРГ13 для ювелирных изделий'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-13.p'
           , input 'yes,yes,yes'
           , input '++++++--'
           , input 'zum'
           , input ''
           , input ''
        ).
define variable vss-include-info133 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input 'запрос':U
           , input '*'
           , input '*'
           , input 'Заказ ТОРГ26'
           , input 'cost,sale,rubl,base'
           , input 'rep/order2.p'
           , input ''
           , input '-+++-+--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info134 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Спецификация к документу'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-specsr.p'
           , input 'при':U
           , input '--------'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info135 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Спецификация по срокам годности'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-specsg.p'
           , input ''
           , input '---+++--'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info136 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input 'факт':U
           , input '*'
           , input 'no'
           , input 'Акт несоответствия'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-nesoot.p '
           , input '1'
           , input '--------'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info137 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input 'факт':U
           , input '*'
           , input '*'
           , input 'Акт несоответствия поставке'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-nesonn.p'
           , input ''
           , input '-+-+----'
           , input 'SPAR'
           , input ''
           , input ''
        ).
define variable vss-include-info138 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт автоматической переоценки'
           , input 'cost,sale,rubl,base'
           , input 'rep/avt-akt0.p'
           , input 'all'
           , input '--------'
           , input ''
           , input ''
           , input 'ParCom'
        ).
define variable vss-include-info139 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт автоматической переоценки'
           , input 'cost,sale,rubl,base'
           , input 'rep/avt-akt0.p'
           , input 'ParCom'
           , input '--------'
           , input 'ParCom'
           , input ''
           , input ''
        ).
define variable vss-include-info140 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт автоматической переоценки топлива (весовой учет)'
           , input 'cost,sale,rubl,base'
           , input 'rep/autoact0.p'
           , input 'all'
           , input '--------'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info141 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт формирования продажной цены (текущие продажные цены)'
           , input 'cost,sale,rubl,base'
           , input 'rep/avt-akt.p'
           , input 'yes,no'
           , input '----+---'
           , input ''
           , input ''
           , input 'Basis,Pskov'
        ).
define variable vss-include-info142 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт формирования продажной цены (текущие продажные цены)'
           , input 'cost,sale,rubl,base'
           , input 'rep/avt-akt.p'
           , input 'yes,yes'
           , input '----+---'
           , input 'Pskov'
           , input ''
           , input 'Basis'
        ).
define variable vss-include-info143 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт формирования продажной цены (текущие продажные цены)'
           , input 'cost,sale,rubl,base'
           , input 'rep/avt-akt1.p'
           , input 'yes'
           , input '--------'
           , input 'Basis'
           , input ''
           , input ''
        ).
define variable vss-include-info144 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт приемки-передачи товаров народного потребления'
           , input 'cost,sale,rubl,base'
           , input 'rep/orl-aktn.p'
           , input 'yes'
           , input '--------'
           , input 'yukos,ibs,Rosneft-*'
           , input ''
           , input ''
        ).
define variable vss-include-info145 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт формирования продажной цены (цены на момент закрытия)'
           , input 'cost,sale,rubl,base'
           , input 'rep/avt-akt.p'
           , input 'no,no'
           , input '--------'
           , input ''
           , input ''
           , input 'Basis,Pskov'
        ).
define variable vss-include-info146 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт формирования продажной цены (цены на момент закрытия)'
           , input 'cost,sale,rubl,base'
           , input 'rep/avt-akt.p'
           , input 'no,yes'
           , input '--------'
           , input 'Pskov'
           , input ''
           , input 'Basis'
        ).
define variable vss-include-info147 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт формирования продажной цены (цены на момент закрытия)'
           , input 'cost,sale,rubl,base'
           , input 'rep/avt-akt1.p'
           , input 'no'
           , input '--------'
           , input 'Basis'
           , input ''
           , input ''
        ).
define variable vss-include-info148 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Ценники (этикетки)         '
           , input 'cost,sale,rubl,base'
           , input 'rep/tick-doc.p'
           , input 'trn,1,no,no'
           , input '--------'
           , input ''
           , input 'self'
           , input ''
        ).
define variable vss-include-info149 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Расходная накладная (для поставщика)'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12.p'
           , input 'yes,all,no-round,no,no'
           , input '---++++-'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info150 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счет-фактура для поставщика (формат 2011г.)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-sf-old.p'
           , input 'yes,all,no-round,no,no'
           , input '-+-+--+-'
           , input ''
           , input ''
           , input 'GreenL,zum'
        ).
define variable vss-include-info151 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счет-фактура (для поставщика) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'yes,all,no-round,no,no'
           , input '-+-+--+-'
           , input ''
           , input ''
           , input 'GreenL,zum'
        ).
define variable vss-include-info152 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счет-фактура (для поставщика) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'yes,zum,no-round,no,no'
           , input '-+-+--+-'
           , input 'zum'
           , input ''
           , input ''
        ).
define variable vss-include-info153 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счет-фактура (для поставщика) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'yes,GreenL,no-round,no,no'
           , input '-+-+--+-'
           , input 'GreenL'
           , input ''
           , input ''
        ).
define variable vss-include-info154 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счет-фактура старая (для поставщика) (без НП) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'yes,all,no-round,yes,no'
           , input '-+-+--+-'
           , input ''
           , input ''
           , input 'GreenL,zum'
        ).
define variable vss-include-info155 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счет-фактура (в редакции от 02.04.2021)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur-2021.p'
           , input 'no,all,no-round,no,no'
           , input '-+++----'
           , input ''
           , input 'HTML'
           , input 'GreenL,zum'
        ).
define variable vss-include-info156 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счет-фактура (в редакции от 23.01.2026)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur-2026.p'
           , input 'no,all,no-round,no,no'
           , input '-+++----'
           , input ''
           , input 'HTML'
           , input 'GreenL,zum'
        ).
define variable vss-include-info157 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счет-фактура старая (для поставщика) (без НП) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'yes,zum,no-round,yes,no'
           , input '-+-+--+-'
           , input 'zum'
           , input ''
           , input ''
        ).
define variable vss-include-info158 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счет-фактура старая (для поставщика) (без НП) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-factur.p'
           , input 'yes,GreenL,no-round,yes,no'
           , input '-+-+--+-'
           , input 'GreenL'
           , input ''
           , input ''
        ).
define variable vss-include-info159 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счёт-фактура (для поставщика) с итогами по НДС в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/factur.p'
           , input 'no,yes,vat-itog,no-round,yes'
           , input '-+-++--+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info160 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счет-фактура (для поставщика) (без НП) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/factur.p'
           , input 'no,yes,all,no-round,yes'
           , input '-+-+--+-'
           , input ''
           , input ''
           , input 'GreenL,zum'
        ).
define variable vss-include-info161 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счет-фактура (для поставщика) (без НП) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/factur.p'
           , input 'no,yes,zum,no-round,yes'
           , input '-+-+--+-'
           , input 'zum'
           , input ''
           , input ''
        ).
define variable vss-include-info162 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счет-фактура (для поставщика) (без НП) в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/factur.p'
           , input 'no,yes,GreenL,no-round,yes'
           , input '-+-+--+-'
           , input 'GreenL'
           , input ''
           , input ''
        ).
define variable vss-include-info163 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счёт-фактура (для поставщика) до 10-го знака в ред. от 19.08.2017'
           , input 'cost,sale,rubl,base'
           , input 'rep/factur.p'
           , input 'no,yes,dec10,no-round,yes'
           , input '-+-++-+-'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info164 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Топливная накладная'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-inrvs.p'
           , input ''
           , input '--------'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info165 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Протокол цен - (Excel)'
           , input 'cost,sale,rubl,base'
           , input 'rep/xl-prtcl.p'
           , input ''
           , input '-+------'
           , input ''
           , input 'EXCEL'
           , input ''
        ).
define variable vss-include-info166 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-jwlr = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Накладная для ювелирных изделий'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12z.p'
           , input 'no'
           , input '-+-+-+--'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info167 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-jwlr = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Расходная накладная (для поставщка юв.изделий)'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-12z.p'
           , input 'yes'
           , input '-----+--'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info168 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Документ ТОРГ1 - АКТ о приемке товаров'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-1.p'
           , input 'no'
           , input '---+----'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info169 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input 'факт':U
           , input 'no'
           , input '*'
           , input 'Документ ТОРГ1 - АКТ о приемке товаров (HTML)'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-1a.p'
           , input 'no'
           , input '--------'
           , input 'SPAR'
           , input 'self'
           , input ''
        ).
define variable vss-include-info170 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт о приемке товаров, ТОРГ-8.4'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-torg84.p'
           , input 'no'
           , input '---+----'
           , input 'yukos,ibs,Rosneft-*'
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info171 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт о расхождениях при приемке товара, ТОРГ-8.3'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-torg83.p'
           , input 'no'
           , input '--------'
           , input 'yukos,ibs,Rosneft-*'
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info172 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт несоответствия по топливной накладной'
           , input 'cost,sale,rubl,base'
           , input 'rep/akt-topl.p'
           , input 'yes'
           , input '--------'
           , input ''
           , input 'A4port'
           , input ''
        ).
      end.
define variable vss-include-info173 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'yes'
           , input '*'
           , input 'Документ ОП-4 накладная производства'
           , input 'cost,sale,rubl,base'
           , input 'rep/op-4.p'
           , input ''
           , input '---+----'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info174 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Накладная прихода (короткая форма)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-inpzum.p'
           , input ''
           , input '-+++++--'
           , input 'zum'
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info175 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input 'факт':U
           , input 'no'
           , input '*'
           , input 'Справка'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-sprav.p'
           , input ''
           , input '---+----'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info176 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input 'факт':U
           , input 'no'
           , input '*'
           , input 'Справка по менеджерам'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-spravm.p'
           , input ''
           , input '---+----'
           , input 'Basis'
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info177 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U + chr(44) + 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Товарная накладная'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-tov.p'
           , input ''
           , input '--+-++--'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info178 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'спи':U + chr(44) + 'рас':U + chr(44) + 'возврат':U + chr(44) + 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Приложение к документам перемещения товаров'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-0.p'
           , input ''
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info179 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'спи':U + chr(44) + 'рас':U + chr(44) + 'возврат':U + chr(44) + 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Качественное удостоверение на мясные полуфабрикаты'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-cert.p'
           , input ''
           , input '--------'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info180 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'спи':U + chr(44) + 'рас':U + chr(44) + 'возврат':U + chr(44) + 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Накладная с баркодами производителя'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-bcod-p.p'
           , input ''
           , input '-+-++++-'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info181 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'спи':U + chr(44) + 'рас':U + chr(44) + 'возврат':U + chr(44) + 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Требование в кладовую'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-trkl.p'
           , input ''
           , input '--------'
           , input ''
           , input 'self'
           , input ''
        ).
define variable vss-include-info182 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Акт отклонения цен накладной от цен спецификации к договору с поставщиком'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-spccnt.p'
           , input ''
           , input '----++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info183 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input 'факт':U
           , input 'no'
           , input '*'
           , input 'Документ ТОРГ-2'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-2.p'
           , input ''
           , input '----++--'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info184 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Лист журнала фасовочных работ'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-fasov.p'
           , input ''
           , input '---+++--'
           , input ''
           , input 'A4lans'
           , input ''
        ).
define variable vss-include-info185 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if v-menu-doc-ext-doc-type = 'im':U then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input 'факт':U
           , input 'yes'
           , input '*'
           , input 'Документ ОП-12'
           , input 'cost,sale,rubl,base'
           , input 'rep/op-12.p'
           , input ''
           , input '---+----'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info186 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт приема и недовоза нефтепродуктов'
           , input 'cost,sale,rubl,base'
           , input 'rep/apn-ptrl.p'
           , input ''
           , input '--------'
           , input 'yukos,ibs,Rosneft-*'
           , input 'A4port'
           , input ''
        ).
      end.
define variable vss-include-info187 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Стеллажная карта'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-stkard.p'
           , input ''
           , input '--------'
           , input ''
           , input 'self'
           , input ''
        ).
define variable vss-include-info188 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт приемки нефтепродуктов по количеству'
           , input 'cost,sale,rubl,base'
           , input 'rep/akt-petrl-qnty.p'
           , input ''
           , input '--------'
           , input 'Pskov'
           , input 'A4port'
           , input ''
        ).
      end.
define variable vss-include-info189 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Этикетка проб'
           , input 'cost,sale,rubl,base'
           , input 'rep/ticket-prob.p'
           , input ''
           , input '--------'
           , input 'yukos,ibs,Rosneft-*'
           , input 'HTML'
           , input ''
        ).
      end.
define variable vss-include-info190 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт отбора проб'
           , input 'cost,sale,rubl,base'
           , input 'rep/akt-prob.p'
           , input ''
           , input '--------'
           , input 'yukos,ibs,Rosneft-*'
           , input 'HTML'
           , input ''
        ).
      end.
define variable vss-include-info191 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт приема нефтепродуктов'
           , input 'cost,sale,rubl,base'
           , input 'rep/akt-petrol.p'
           , input ''
           , input '--------'
           , input 'yukos,ibs,Rosneft-*'
           , input 'HTML'
           , input ''
        ).
      end.
define variable vss-include-info192 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input 'факт':U
           , input '*'
           , input '*'
           , input 'Акт приема СУГ'
           , input 'cost,sale,rubl,base'
           , input 'rep/akt-sug.p'
           , input ''
           , input '--------'
           , input 'yukos,ibs,Rosneft-*'
           , input 'HTML'
           , input ''
        ).
      end.
define variable vss-include-info193 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input 'факт':U
           , input '*'
           , input '*'
           , input 'Акт приема СУГ (Расчет тех. потерь)'
           , input 'cost,sale,rubl,base'
           , input 'rep/akt-sug-ras.p'
           , input ''
           , input '--------'
           , input 'yukos,ibs,Rosneft-*'
           , input 'HTML'
           , input ''
        ).
      end.
define variable vss-include-info194 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input 'факт':U
           , input '*'
           , input '*'
           , input 'Акт приема СУГ (корректировка)'
           , input 'cost,sale,rubl,base'
           , input 'rep/akt-sug-corr.p'
           , input ''
           , input '--------'
           , input 'yukos,ibs,Rosneft-*'
           , input 'HTML'
           , input ''
        ).
      end.
end.
END PROCEDURE.
PROCEDURE create-menu-items2 :
define input parameter p-doc-code       as character        no-undo.
define input parameter p-doc-type       as character        no-undo.
define input parameter p-ext-doc-type   as character        no-undo.
define input parameter p-status_        as character        no-undo.
define input parameter p-Internal       as character        no-undo.
define input parameter p-flag_          as character        no-undo.
    define variable xtype        as character    no-undo.
    define variable xstatus      as character    no-undo.
    define variable xInternal    as character    no-undo.
    define variable xflag        as character    no-undo.
do
on error undo, return error
:
    if p-doc-type <> 'инв':U
    then do:
        assign
            xtype = p-doc-type
        .
    end.
    else do:
        assign
            xtype = p-ext-doc-type
        .
    end.
    assign
        xstatus             = string( p-status_  )
        xInternal           = string( p-Internal )
        xflag               = string( p-flag_    )
    .
    assign
        v-menu-doc-doc-code     = p-doc-code
        v-menu-doc-doc-type     = xtype
        v-menu-doc-ext-doc-type = p-ext-doc-type
        v-menu-doc-status_      = xstatus
        v-menu-doc-internal     = xInternal
        v-menu-doc-flag         = xflag
    .
define variable vss-include-info195 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable is-ptrl  as character no-undo .
define variable is-jwlr  as character no-undo .
define variable par-type as character no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define VARIABLE v-izlish        as logical    no-undo .
run gbl/conf-rd.p ("is-ptrl", "", "", 0, "", "", "", no, output is-ptrl, output par-type) no-error.
if error-status :error
  or par-type <> "l"
  or is-ptrl  <> "yes"
then do:
  assign is-ptrl = "no".
end.
run gbl/conf-rd.p ("is-jwlr", "", "", 0, "", "", "", no, output is-jwlr, output par-type) no-error.
if error-status :error
  or par-type <> "l"
  or is-jwlr  <> "yes"
then do:
  assign is-jwlr = "no".
end.
      run adm/shattri.p (
        input "get":U
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input 'inv-obj':U
        ,input  "izlcstpr"
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-izlish
        ,output v-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
 define variable Log-Res      as      logical     no-undo.
define variable vss-include-info196 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_mark_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output log-res
    )  .
end.
define variable vss-include-info197 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if v-izlish = yes then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3p.p'
           , input 'invent,no,no'
           , input '-+-+++-+'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info198 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись ИНВ-5'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-5.p'
           , input 'invent,no,no'
           , input '-+-+++-+'
           , input ''
           , input 'HTML'
           , input ''
        ).
define variable vss-include-info199 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if v-izlish = yes then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Предварительная инвентаризационная опись'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'invent,no,no'
           , input '-+-+++-+'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info200 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if v-izlish = no then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'invent,no,no'
           , input '-+-+++-+'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info201 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'invent,no,yes'
           , input '-+-+++-+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info202 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись топлива (вес)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3-kg.p'
           , input 'invent,no,no,no'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info203 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись топлива (вес) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3-kg.p'
           , input 'invent,no,no,yes'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info204 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'sl,no,no'
           , input '-+++++-+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info205 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'sl,no,yes'
           , input '-+++++-+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info206 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input 'факт,разрешен':U
           , input '*'
           , input '*'
           , input 'Сличительная ведомость ИНВ-19'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-19.p'
           , input ' '
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info207 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input 'факт,разрешен':U
           , input '*'
           , input '*'
           , input 'Сличительная ведомость ИНВ-19 (с ОКДП)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-19.p'
           , input 'OKDP'
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info208 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость топлива (вес)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3-kg.p'
           , input 'sl,no,no,no'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info209 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость топлива (вес) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3-kg.p'
           , input 'sl,no,no,yes'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info210 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (итоги по группам)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'invent,yes,no'
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info211 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (итоги по группам) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'invent,yes,yes'
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info212 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись топлива (вес) (итоги по группам)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3-kg.p'
           , input 'invent,no,yes,no'
           , input '-+-+----'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info213 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись топлива (вес) (итоги по группам) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3-kg.p'
           , input 'invent,no,yes,yes'
           , input '-+-+----'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info214 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (итоги по группам)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'sl,yes,no'
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info215 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (итоги по группам) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'sl,yes,yes'
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info216 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость топлива (вес) (итоги по группам)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3-kg.p'
           , input 'sl,no,yes,no'
           , input '-+-+----'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info217 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость топлива (вес) (итоги по группам) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3-kg.p'
           , input 'sl,no,yes,yes'
           , input '-+-+----'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info218 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (ювелирные изделия)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'invent-gold,no,no'
           , input '-+-+++-+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info219 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (ювелирные изделия) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'invent-gold,no,yes'
           , input '-+-+++-+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info220 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость   (ювелирные изделия)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'sl-gold,no,no'
           , input '-+-+++-+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info221 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость   (ювелирные изделия) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'sl-gold,no,yes'
           , input '-+-+++-+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info222 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (ювелирные изделия) ИНВ-8'
           , input 'rubl'
           , input 'rep/inv-8l.p'
           , input ''
           , input '-----+--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info223 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (ювелирные изделия) ИНВ-8 ед.'
           , input 'rubl'
           , input 'rep/inv-8.p'
           , input ''
           , input '-----+--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info224 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Ведомость учета результатов, выявленных инв-ей (ИНВ-26)'
           , input 'rubl'
           , input 'rep/inv-26.p'
           , input ''
           , input '-----+--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info225 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (для пересчета)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3del.p'
           , input 'no,no'
           , input '----++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info226 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (для пересчета) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3del.p'
           , input 'yes,no'
           , input '----++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info227 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (для пересчета - только расхождения)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3del.p'
           , input 'no,yes'
           , input '----++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info228 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (для пересчета - только расхождения) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3del.p'
           , input 'yes,yes'
           , input '----++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info229 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Пустографка для всех документов'
           , input 'cost,sale,rubl,base'
           , input 'rep/zeroinv.p'
           , input string(p-alldocs-handle) + ',no'
           , input '----++--'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info230 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Пустографка для документа'
           , input 'cost,sale,rubl,base'
           , input 'rep/zeroinv.p'
           , input string(p-alldocs-handle) + ',yes'
           , input '----++--'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info231 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость результатов инвентаризации СУГ'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-orsvx-sug.p'
           , input ''
           , input '---+----'
           , input 'yukos,ibs,Rosneft-*'
           , input 'HTML'
           , input ''
        ).
      end.
define variable vss-include-info232 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость результатов инвентаризации нефтепродуктов'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-orsvxl.p'
           , input ''
           , input '---+----'
           , input 'yukos,ibs,Rosneft-*'
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info233 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Расчет естественной убыли нефтепродуктов. Форма 34-НП'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-np34.p'
           , input ''
           , input '-+-+----'
           , input 'yukos,ibs,Rosneft-*'
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info234 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись нефти и нефтепродуктов'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-orioxl.p'
           , input ''
           , input '---+----'
           , input 'yukos,ibs,Rosneft-*'
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info235 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись СУГ'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-orioxl-sug.p'
           , input ''
           , input '---+----'
           , input 'yukos,ibs,Rosneft-*'
           , input 'HTML'
           , input ''
        ).
      end.
define variable vss-include-info236 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if log-res = yes then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Печать датаматриксов по излишкам'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-print-marks.p'
           , input ''
           , input '---+----'
           , input ''
           , input 'HTML'
           , input ''
        ).
      end.
define variable vss-include-info237 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (РН-регионы) результатов инв. нефтепродуктов'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-orsvx1.p'
           , input ''
           , input '---+----'
           , input 'yukos,ibs,Rosneft-*'
           , input ''
           , input 'Rosneft-Moscow'
        ).
      end.
define variable vss-include-info238 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (по поставщикам)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-pst.p'
           , input 'invent,no,no,no'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info239 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (по поставщикам)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-pst.p'
           , input 'invent,no,no,yes'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info240 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (по поставщикам)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-pst.p'
           , input 'sl,no,no,no'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info241 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (по поставщикам)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-pst.p'
           , input 'sl,no,no,yes'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info242 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (итоги по производителям) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'invent,prod,no'
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info243 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (итоги по производителям)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'invent,prod,yes'
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info244 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input 'факт':U
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись нефтепродуктов'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-orioxl-pokmi.p'
           , input ''
           , input '---+----'
           , input 'yukos,ibs,Rosneft-*'
           , input 'HTML'
           , input ''
        ).
      end.
define variable vss-include-info245 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (итоги по производителям) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'sl,prod,no'
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info246 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (итоги по производителям)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'sl,prod,yes'
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info247 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризация (анализ отклонений)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3slg.p'
           , input 'no'
           , input '-+-+++--'
           , input 'SPAR'
           , input ''
           , input ''
        ).
define variable vss-include-info248 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризация (анализ отклонений) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3slg.p'
           , input 'yes'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info249 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Документ инвентаризации'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-new.p'
           , input ''
           , input '---+----'
           , input 'world'
           , input ''
           , input ''
        ).
define variable vss-include-info250 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input 'факт':U
           , input '*'
           , input '*'
           , input 'Акт приема-передачи'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-akt.p'
           , input ''
           , input '----++--'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info251 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'invent,no,no'
           , input '-+-+++-+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info252 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'invent,no,yes'
           , input '-+-+++-+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info253 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись топлива (вес)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3-kg.p'
           , input 'invent,no,no,no'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info254 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись топлива (вес) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3-kg.p'
           , input 'invent,no,no,yes'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info255 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'sl,no,no'
           , input '-+++++-+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info256 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'sl,no,yes'
           , input '-+++++-+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info257 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость топлива (вес)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3-kg.p'
           , input 'sl,no,no,no'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info258 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость топлива (вес) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3-kg.p'
           , input 'sl,no,no,yes'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info259 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (итоги по группам)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'invent,yes,no'
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info260 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (итоги по группам) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'invent,yes,yes'
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info261 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись топлива (вес) (итоги по группам)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3-kg.p'
           , input 'invent,no,yes,no'
           , input '-+-+----'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info262 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись топлива (вес) (итоги по группам) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3-kg.p'
           , input 'invent,no,yes,yes'
           , input '-+-+----'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info263 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (итоги по группам)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'sl,yes,no'
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info264 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (итоги по группам) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'sl,yes,yes'
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info265 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость топлива (вес) (итоги по группам)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3-kg.p'
           , input 'sl,no,yes,no'
           , input '-+-+----'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info266 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      if is-ptrl = 'yes' then do:
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость топлива (вес) (итоги по группам) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3-kg.p'
           , input 'sl,no,yes,yes'
           , input '-+-+----'
           , input ''
           , input ''
           , input ''
        ).
      end.
define variable vss-include-info267 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (ювелирные изделия)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'invent-gold,no,no'
           , input '-+-+++-+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info268 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (ювелирные изделия) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'invent-gold,no,yes'
           , input '-+-+++-+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info269 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость   (ювелирные изделия)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'sl-gold,no,no'
           , input '-+-+++-+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info270 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость   (ювелирные изделия) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'sl-gold,no,yes'
           , input '-+-+++-+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info271 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Пустографка для всех документов'
           , input 'cost,sale,rubl,base'
           , input 'rep/zeroinv.p'
           , input 'no'
           , input '----++--'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info272 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Пустографка для документа'
           , input 'cost,sale,rubl,base'
           , input 'rep/zeroinv.p'
           , input 'yes'
           , input '----++--'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info273 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (по поставщикам)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-pst.p'
           , input 'invent,no,no,no'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info274 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (по поставщикам)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-pst.p'
           , input 'invent,no,no,yes'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info275 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (по поставщикам)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-pst.p'
           , input 'sl,no,no,no'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info276 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (по поставщикам)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-pst.p'
           , input 'sl,no,no,yes'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info277 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (итоги по производителям) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'invent,prod,no'
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info278 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризационная опись (итоги по производителям)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'invent,prod,yes'
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info279 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (итоги по производителям) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'sl,prod,no'
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info280 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (итоги по производителям)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3.p'
           , input 'sl,prod,yes'
           , input '-+-+---+'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info281 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризация (анализ отклонений)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3slg.p'
           , input 'no'
           , input '-+-+++--'
           , input 'SPAR'
           , input ''
           , input ''
        ).
define variable vss-include-info282 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Инвентаризация (анализ отклонений) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3slg.p'
           , input 'yes'
           , input '-+-+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info283 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (для пересчета)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3del.p'
           , input 'no,no'
           , input '----++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info284 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (для пересчета) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3del.p'
           , input 'yes,no'
           , input '----++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info285 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (для пересчета - только расхождения)'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3del.p'
           , input 'no,yes'
           , input '----++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info286 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Сличительная ведомость (для пересчета - только расхождения) сжатая'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-3del.p'
           , input 'yes,yes'
           , input '----++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info287 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Документ инвентаризации'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-new.p'
           , input ''
           , input '---+----'
           , input 'world'
           , input ''
           , input ''
        ).
define variable vss-include-info288 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input 'факт':U
           , input '*'
           , input '*'
           , input 'Акт приема-передачи'
           , input 'cost,sale,rubl,base'
           , input 'rep/inv-akt.p'
           , input ''
           , input '----++--'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info289 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vp':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Документ пересортицы'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-resort.p'
           , input ''
           , input '---+----'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info290 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'ap':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт переоценки учетной цены по остаткам товара поставщика'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-akt-po.p'
           , input ''
           , input '---+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info291 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'ap':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Документ ТОРГ12 (возврат поставщику) для переоценки уч.цены'
           , input 'cost,sale,rubl,base'
           , input 'rep/trg-12po.p'
           , input 'yes'
           , input '---+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info292 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'ap':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Документ ТОРГ12 (приход внешний) для переоценки уч.цены'
           , input 'cost,sale,rubl,base'
           , input 'rep/trg-12po.p'
           , input 'no'
           , input '---+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info293 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'ap':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счет-фактура (возврат поставщику) для переоценки уч.цены'
           , input 'cost,sale,rubl,base'
           , input 'rep/factur.p'
           , input 'yes,yes,all,no,no'
           , input '---+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info294 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'ap':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счет-фактура (приход внешний) для переоценки уч.цены'
           , input 'cost,sale,rubl,base'
           , input 'rep/factur.p'
           , input 'yes,no,all,no,no'
           , input '---+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info295 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'pc':U
           , input '*'
           , input '*'
           , input '*'
           , input 'Акт смены типа приобретения'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-akt-st.p'
           , input ''
           , input '---+++--'
           , input ''
           , input 'A4port'
           , input ''
        ).
define variable vss-include-info296 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'ap':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счет-фактура (приход внешний) для переоц.(без НП)'
           , input 'cost,sale,rubl,base'
           , input 'rep/factur.p'
           , input 'yes,no,all,no,yes'
           , input '---+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info297 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'ap':U
           , input '*'
           , input 'no'
           , input '*'
           , input 'Счет-фактура (возврат поставщику) для переоц.(без НП)'
           , input 'cost,sale,rubl,base'
           , input 'rep/factur.p'
           , input 'yes,yes,all,no,yes'
           , input '---+++--'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info298 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input '*'
           , input '*'
           , input '*'
           , input '*'
           , input 'Печать документов внешней программой'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-ext.p'
           , input 'печать':U
           , input '--------'
           , input 'BDC'
           , input 'self'
           , input ''
        ).
define variable vss-include-info299 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input '*'
           , input '*'
           , input '*'
           , input '*'
           , input 'Печать штрих-кодов внешней программой'
           , input 'cost,sale,rubl,base'
           , input 'rep/torg-ext.p'
           , input 'доп-БК':U
           , input '--------'
           , input 'BDC'
           , input 'self'
           , input ''
        ).
define variable vss-include-info300 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'vt':U
           , input 'факт':U
           , input '*'
           , input '*'
           , input 'Акт на списание материалов'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-achmat.p'
           , input ''
           , input '-+-----+'
           , input 'yukos,ibs,Rosneft-*'
           , input ''
           , input ''
        ).
define variable vss-include-info301 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'спи':U
           , input 'факт':U
           , input 'no'
           , input '*'
           , input 'Требование-накладная (форма М-11)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-f_m11.p'
           , input ''
           , input '-+-+----'
           , input ''
           , input 'self'
           , input ''
        ).
define variable vss-include-info302 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас,возврат':U
           , input 'факт':U
           , input 'yes'
           , input '*'
           , input 'Требование-накладная (форма М-11)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-f_m11.p'
           , input ''
           , input '-+-+----'
           , input ''
           , input 'self'
           , input ''
        ).
define variable vss-include-info303 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'спи':U
           , input 'факт':U
           , input 'no'
           , input '*'
           , input 'Акт о списании материалов (ЦУМ)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-actspi.p'
           , input ''
           , input '--------'
           , input 'ZUM'
           , input 'self'
           , input ''
        ).
define variable vss-include-info304 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input 'факт':U
           , input '*'
           , input '*'
           , input 'Приходный ордер (форма М-4)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-f_m04.p'
           , input 'no,11'
           , input '--------'
           , input ''
           , input ''
           , input 'yukos,ibs,Rosneft-*'
        ).
define variable vss-include-info305 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input 'факт':U
           , input '*'
           , input '*'
           , input 'Приходный ордер (форма М-4)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-f_m04.p'
           , input 'yes,11'
           , input '--------'
           , input 'yukos,ibs,Rosneft-*'
           , input ''
           , input ''
        ).
define variable vss-include-info306 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input 'факт':U
           , input '*'
           , input '*'
           , input 'Приходный ордер (форма М-4)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-f_m04.p'
           , input 'no,12'
           , input '--------'
           , input ''
           , input ''
           , input ''
        ).
define variable vss-include-info307 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'при':U
           , input 'факт':U
           , input '*'
           , input '*'
           , input 'Приходный ордер (форма М-4Р)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-f_m04.p'
           , input 'no,13'
           , input '--------'
           , input 'Pskov'
           , input ''
           , input ''
        ).
define variable vss-include-info308 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        run menu-doc-create-menu-item in this-procedure
          ( input xtype
           , input xstatus
           , input xinternal
           , input xflag
           , input 'рас':U
           , input 'факт':U
           , input 'no'
           , input '*'
           , input 'Накладная на отпуск материалов на сторону (форма М-15)'
           , input 'cost,sale,rubl,base'
           , input 'rep/r-f_m15.p'
           , input ''
           , input '--------'
           , input 'ZUM'
           , input 'self'
           , input ''
        ).
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-default-printer
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-chg b-print-doc b-help i-print br-table fi-default-printer
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run local-open-query in this-procedure .
END PROCEDURE.
PROCEDURE get-call-point :
define input parameter p-tmp#list-id as integer          no-undo.
define output parameter p-call-point as character        no-undo.
    define variable v-doc-type        as character    no-undo.
    define variable v-doc-status      as character    no-undo.
    define variable v-doc-internal    as character    no-undo.
    define variable v-doc-flag        as character    no-undo.
    define buffer buf_temp_form-list        for temp_form-list.
do
for buf_temp_form-list
on error undo, return error
:
    assign
        v-doc-type     = "":U
        v-doc-status   = "":U
        v-doc-internal = "":U
        v-doc-flag     = "":U
    .
    for each buf_temp_form-list
       where buf_temp_form-list.id = Tmp#List.id
    :
        if lookup( buf_temp_form-list.doc-type, v-doc-type ) = 0
        then do:
            assign
                v-doc-type = ( if v-doc-type = "":U then "":U else "_":U ) + buf_temp_form-list.doc-type
            .
        end.
        if lookup( buf_temp_form-list.status_, v-doc-status ) = 0
        then do:
            assign
                v-doc-status = ( if v-doc-status = "":U then "":U else "_":U ) + buf_temp_form-list.status_
            .
        end.
        if lookup( buf_temp_form-list.internal, v-doc-internal ) = 0
        then do:
            assign
                v-doc-internal = ( if v-doc-internal = "":U then "":U else "_":U ) + buf_temp_form-list.internal
            .
        end.
        if lookup( buf_temp_form-list.flag, v-doc-flag ) = 0
        then do:
            assign
                v-doc-flag = ( if v-doc-flag = "":U then "":U else "_":U ) + buf_temp_form-list.flag
            .
        end.
    end.
    assign
        p-call-point = substitute( "&1,&2,&3,&4", v-doc-type, v-doc-status, v-doc-internal, v-doc-flag )
    .
end.
END PROCEDURE.
PROCEDURE get-handle-all-docs :
define output parameter p-handle as handle no-undo .
  p-handle =  p-alldocs-handle .
END PROCEDURE.
PROCEDURE get-saved-character :
define input parameter p-list           as character        no-undo.
define input parameter p-name           as character        no-undo.
define output parameter p-character     as character        no-undo.
    define variable v-position    as integer      no-undo.
do
on error undo, return error
:
    assign
        v-position = lookup( p-name, p-list )
    .
    if v-position = 0
    then do:
        assign
            p-character = "":U
        .
    end.
    else do:
        if num-entries( p-list ) > v-position
        then do:
            assign
                p-character = entry( v-position + 1, p-list )
            .
        end.
        else do:
            assign
                p-character = "":U
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE get-saved-logical :
define input parameter p-list       as character        no-undo.
define input parameter p-name       as character        no-undo.
define output parameter p-logical   as character        no-undo.
    define variable v-position    as integer      no-undo.
do
on error undo, return error
:
    assign
        v-position = lookup( p-name, p-list )
    .
    if v-position = 0
    then do:
        assign
            p-logical = "  -":U
        .
    end.
    else do:
        if num-entries( p-list ) > v-position
        then do:
            assign
                p-logical = "  ":U + entry( v-position + 1, p-list )
            .
            if trim( p-logical ) = "":U
            then do:
                assign
                    p-logical = "  -":U
                .
            end.
        end.
        else do:
            assign
                p-logical = "  -":U
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE init-fields :
define variable xtype        as character    no-undo.
define variable xstatus      as character    no-undo.
define variable xInternal    as character    no-undo.
define variable xflag        as character    no-undo.
    define variable v-temp-char     as character    no-undo.
    define variable v-par-type      as character    no-undo.
    define variable v-call-point    as character    no-undo.
    define variable v-doc-counter   as integer      no-undo.
    define variable v-form-title    as character    no-undo.
    define buffer buf_trn-doc           for ub.trn-doc.
    define buffer buf_usr-flt           for ubflt.usr-flt.
do
for buf_trn-doc
  , buf_usr-flt
with frame Dialog-Frame
on error undo, return error
:
    assign
        fi-default-printer = session :printer-name
    .
define variable vss-include-info309 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-menu-doc-sys-key
  ) no-error .
    for each temp_trn-doc-code
    on error undo, return error
    :
        assign
            v-doc-counter = v-doc-counter + 1
        .
        find first buf_trn-doc no-lock
             where buf_trn-doc.doc-code = temp_trn-doc-code.doc-code
        .
        run create-menu-items1 in this-procedure (
              input buf_trn-doc.doc-code
            , input buf_trn-doc.doc-type
            , input buf_trn-doc.ext-doc-type
            , input buf_trn-doc.status_
            , input buf_trn-doc.Internal
            , input buf_trn-doc.flag_
        ).
        run create-menu-items2 in this-procedure (
              input buf_trn-doc.doc-code
            , input buf_trn-doc.doc-type
            , input buf_trn-doc.ext-doc-type
            , input buf_trn-doc.status_
            , input buf_trn-doc.Internal
            , input buf_trn-doc.flag_
        ).
    end.
    if v-doc-counter = 1
    then do:
        assign
            v-form-title = substitute( "Печать документа   Тип: &1 Статус: &2&3 &4   № &5"
                , v-menu-doc-doc-type
                , v-menu-doc-status_
                , string( v-menu-doc-flag, "+/-" )
                , string( v-menu-doc-internal,"внутренний/внешний")
                , v-menu-doc-doc-code )
        .
    end.
    else do:
        assign
            v-form-title = substitute( "Печать выбранных документов по списку" )
        .
    end.
    assign
        frame Dialog-Frame :title = v-form-title
    .
    for each Tmp#List
    :
        run get-call-point in this-procedure (
              input Tmp#List.id
            , output v-call-point
        ).
        find first buf_usr-flt no-lock
             where buf_usr-flt.user-name  = v-cntxt-userid
               and buf_usr-flt.call-point = substitute( "&1,&2,&3,&4"
                                            , Tmp#List.blank-name
                                            , Tmp#List.sys-key
                                            , Tmp#List.sys-key-black
                                            , v-call-point )
        no-error.
        if available buf_usr-flt
        then do:
            run get-saved-logical in this-procedure (
                  input buf_usr-flt.list_
                , input "type-parts":U
                , output Tmp#List.type-parts
            ).
            run get-saved-logical in this-procedure (
                  input buf_usr-flt.list_
                , input "type-price":U
                , output Tmp#List.type-price
            ).
            run get-saved-logical in this-procedure (
                  input buf_usr-flt.list_
                , input "type-val":U
                , output Tmp#List.type-val
            ).
            run get-saved-logical in this-procedure (
                  input buf_usr-flt.list_
                , input "sort-gr":U
                , output Tmp#List.sort-gr
            ).
            run get-saved-logical in this-procedure (
                  input buf_usr-flt.list_
                , input "print-graft":U
                , output Tmp#List.print-graft
            ).
            run get-saved-logical in this-procedure (
                  input buf_usr-flt.list_
                , input "type-scale":U
                , output Tmp#List.type-scale
            ).
            run get-saved-logical in this-procedure (
                  input buf_usr-flt.list_
                , input "sort-name":U
                , output Tmp#List.sort-name
            ).
            run get-saved-logical in this-procedure (
                  input buf_usr-flt.list_
                , input "no-vat":U
                , output Tmp#List.no-vat
            ).
            assign
                v-temp-char = "":U
            .
            run get-saved-logical in this-procedure (
                  input buf_usr-flt.list_
                , input "selection":U
                , output v-temp-char
            ).
            if v-temp-char = "  +":U
            then do:
                assign
                    Tmp#List.last-use = yes
                .
            end.
        end.
        else do:
            assign
                Tmp#List.type-parts   = "  -":U
                Tmp#List.type-price   = "  -":U
                Tmp#List.type-val     = "  -":U
                Tmp#List.sort-gr      = "  -":U
                Tmp#List.sort-name    = "  -":U
                Tmp#List.print-graft  = "  -":U
                Tmp#List.type-scale   = "  -":U
                Tmp#List.no-vat       = "  -":U
            .
        end.
        if Tmp#List.type-parts-enabled = no
        then do:
            assign
                Tmp#List.type-parts   = " ":U
            .
        end.
        if Tmp#List.type-price-enabled = no
        then do:
            assign
                Tmp#List.type-price   = " ":U
            .
        end.
        if Tmp#List.type-val-enabled = no
        then do:
            assign
                Tmp#List.type-val     = " ":U
            .
        end.
        if Tmp#List.sort-gr-enabled = no
        then do:
            assign
                Tmp#List.sort-gr      = " ":U
            .
        end.
        if Tmp#List.sort-name-enabled = no
        then do:
            assign
                Tmp#List.sort-name    = " ":U
            .
        end.
        if Tmp#List.print-graft-enabled = no
        then do:
            assign
                Tmp#List.print-graft  = " ":U
            .
        end.
        if Tmp#List.no-vat-enabled = no
        then do:
            assign
                Tmp#List.no-vat  = " ":U
            .
        end.
        if Tmp#List.type-scale-enabled = no
        then do:
            assign
                Tmp#List.type-scale   = " ":U
            .
        end.
      if v-doc-counter > 1 then do:
         if lookup("no-print-many" ,Tmp#List.filtr )  > 0 then do:
            Tmp#List.view_ = 0.
         end.
      end.
    end.
end.
END PROCEDURE.
PROCEDURE local-open-query :
        open query br-table
        for each Tmp#List no-lock
           where Tmp#List.view_ <> 0
        by Tmp#List.blank-name
        .
 END PROCEDURE.
PROCEDURE print-docs :
    define variable v-doc-type          as character    no-undo.
    define variable v-status            as character    no-undo.
    define variable v-internal          as character    no-undo.
    define variable v-flag              as character    no-undo.
    define variable v-form-amount       as integer      no-undo.
    define variable v-user-action       as character    no-undo.
    define variable v-printed           as logical      no-undo.
    define variable v-log               as logical      no-undo.
    define variable listGdsProcActn     as character init "rep/inv-3p.p,rep/inv-3.p,rep/inv-19.p,rep/inv-8l.p,rep/inv-8.p,rep/inv-3del.p,rep/inv-pst.p,rep/inv-3slg.p,rep/inv-pst.p" no-undo.
    define variable listPtrlProcActn    as character init "rep/inv-3-kg.p,rep/r-orsvx1.p,rep/r-np34.p,rep/r-orioxl.p" no-undo.
    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_t_tmp#list    for tmp#list.
    define buffer buf_tmp#list      for tmp#list.
do
for buf_trn-doc
  , buf_t_tmp#list
  , buf_tmp#list
with frame Dialog-Frame
on error undo, return error
:
    if g#quest-print = yes
    then do:
        output  to value( string( session:temp-directory + "$" + string( g#report-num ) ) ) .
        output close.
    End.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
    output close.
    output to value( string( session:temp-directory + "rpt" + string( g#report-num ) ) + ".txl" ) .
    output close.
    for each temp_form-list
    by temp_form-list.doc-code
    on error undo, return error
    :
        for each buf_tmp#list
           where buf_tmp#list.id = temp_form-list.id
        on error undo, return error
        :
            if buf_tmp#list.last-use <> no
            then do:
              if lookup (buf_tmp#list.proc-name, listGdsProcActn) > 0 and not buf_tmp#list.blank-name = "Предварительная инвентаризационная опись"
              then do:
define variable vss-include-info310 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inv-gds_report':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-log
    )  .
end.
                 if not v-log then do:
                   message
                     "Недостаточно прав для вывода на печать"
                     skip
                     buf_tmp#list.blank-name "."
                     skip
                     " "
                     skip
                     "Для вывода на печать"
                     skip
                     buf_tmp#list.blank-name
                     skip
                     "обратитесь в службу поддержки."
                   view-as alert-box error title "Ошибка".
                   next.
                 end.
               end.
              if lookup (buf_tmp#list.proc-name, listPtrlProcActn) > 0
              then do:
define variable vss-include-info311 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inv-ptrl_report':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-log
    )  .
end.
                 if not v-log then do:
                   message
                     "Недостаточно прав для вывода на печать"
                     skip
                     buf_tmp#list.blank-name "."
                     skip
                     " "
                     skip
                     "Для вывода на печать"
                     skip
                     buf_tmp#list.blank-name
                     skip
                     "обратитесь в службу поддержки."
                   view-as alert-box error title "Ошибка".
                   next.
                 end.
               end.
                find first buf_t_tmp#list no-lock
                     where buf_t_tmp#list.id = temp_form-list.id
                .
                assign
                    v-form-amount = v-form-amount + 1
                .
                find first buf_trn-doc
                     where buf_trn-doc.doc-code = temp_form-list.doc-code
                no-lock.
                if buf_trn-doc.doc-type <> 'инв':U
                then do:
                    assign
                        v-doc-type = buf_trn-doc.doc-type
                    .
                end.
                else do:
                    assign
                        v-doc-type = buf_trn-doc.ext-doc-type
                    .
                end.
                assign
                    v-status   = string( buf_trn-doc.status_  )
                    v-internal = string( buf_trn-doc.Internal )
                    v-flag     = string( buf_trn-doc.flag_    )
                .
                assign
                    print-graft = ( trim( buf_tmp#list.print-graft ) = "+":U )
                    no-vat      = ( trim( buf_tmp#list.no-vat      ) = "+":U )
                    sort-gr     = ( trim( buf_tmp#list.sort-gr     ) = "+":U )
                    sort-name   = ( trim( buf_tmp#list.sort-name   ) = "+":U )
                    CostPrice   = ( trim( buf_tmp#list.type-price  ) <> "+":U )
                    PrintScale  = ( trim( buf_tmp#list.type-scale  ) = "+":U )
                    PrintRubl   = ( trim( buf_tmp#list.type-val    ) = "+":U )
                    PrintParts  = ( trim( buf_tmp#list.type-parts  ) = "+":U )
                .
                run trg/userlog.p (
                      input "printdoc":U
                    , input substitute("&1&2&3&2&4&2&5",buf_tmp#list.blank-name,chr(3),temp_form-list.doc-code, buf_tmp#list.proc-param,
                      string(PrintParts) + ',' + string(print-graft) + ',' + string(no-vat) + ',' + string(print-graft) + ',' + string(sort-gr) + ',' + string(sort-name) + ',' + string(CostPrice) + ',' + string(PrintScale)  + ',' + string(PrintRubl))
                    , input ?
                    , input ?
                    , input ""
                ) no-error.
                if error-status :error
                then do:
                    message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
                end.
                case num-entries( buf_tmp#list.proc-param )
                :
                    when 0
                    then do:
                        run value ( buf_tmp#list.proc-name )  (
                              input p-mainmenu-handle
                            , input recid( buf_trn-doc )
                        ).
                    end.
                    when 1
                    then do:
                        run value ( buf_tmp#list.proc-name ) (
                              input p-mainmenu-handle
                            , input recid( buf_trn-doc )
                            , input buf_tmp#list.proc-param
                        ).
                    end.
                    when 2
                    then do:
                        run value ( buf_tmp#list.proc-name )  (
                              input p-mainmenu-handle
                            , input recid( buf_trn-doc )
                            , input entry( 1, buf_tmp#list.proc-param )
                            , input entry( 2, buf_tmp#list.proc-param )
                        ).
                    end.
                    when 3
                    then do:
                        run value ( buf_tmp#list.proc-name )  (
                              input p-mainmenu-handle
                            , input recid( buf_trn-doc )
                            , input entry( 1, buf_tmp#list.proc-param )
                            , input entry( 2, buf_tmp#list.proc-param )
                            , input entry( 3, buf_tmp#list.proc-param )
                        ).
                    end.
                    when 4
                    then do:
                        run value ( buf_tmp#list.proc-name )  (
                              input p-mainmenu-handle
                            , input recid( buf_trn-doc )
                            , input entry( 1, buf_tmp#list.proc-param )
                            , input entry( 2, buf_tmp#list.proc-param )
                            , input entry( 3, buf_tmp#list.proc-param )
                            , input entry( 4, buf_tmp#list.proc-param )
                        ).
                    end.
                    when 5
                    then do:
                        run value ( buf_tmp#list.proc-name )  (
                              input p-mainmenu-handle
                            , input recid( buf_trn-doc )
                            , input entry( 1, buf_tmp#list.proc-param )
                            , input entry( 2, buf_tmp#list.proc-param )
                            , input entry( 3, buf_tmp#list.proc-param )
                            , input entry( 4, buf_tmp#list.proc-param )
                            , input entry( 5, buf_tmp#list.proc-param )
                        ).
                    end.
                    when 6
                    then do:
                        run value ( buf_tmp#list.proc-name )  (
                              input p-mainmenu-handle
                            , input recid( buf_trn-doc )
                            , input entry( 1, buf_tmp#list.proc-param )
                            , input entry( 2, buf_tmp#list.proc-param )
                            , input entry( 3, buf_tmp#list.proc-param )
                            , input entry( 4, buf_tmp#list.proc-param )
                            , input entry( 5, buf_tmp#list.proc-param )
                            , input entry( 6, buf_tmp#list.proc-param )
                        ).
                    end.
                    when 7
                    then do:
                        run value ( buf_tmp#list.proc-name )  (
                              input p-mainmenu-handle
                            , input recid( buf_trn-doc )
                            , input entry( 1, buf_tmp#list.proc-param )
                            , input entry( 2, buf_tmp#list.proc-param )
                            , input entry( 3, buf_tmp#list.proc-param )
                            , input entry( 4, buf_tmp#list.proc-param )
                            , input entry( 5, buf_tmp#list.proc-param )
                            , input entry( 6, buf_tmp#list.proc-param )
                            , input entry( 7, buf_tmp#list.proc-param )
                        ).
                    end.
                    when 8
                    then do:
                        run value ( buf_tmp#list.proc-name )  (
                              input p-mainmenu-handle
                            , input recid( buf_trn-doc )
                            , input entry( 1, buf_tmp#list.proc-param )
                            , input entry( 2, buf_tmp#list.proc-param )
                            , input entry( 3, buf_tmp#list.proc-param )
                            , input entry( 4, buf_tmp#list.proc-param )
                            , input entry( 5, buf_tmp#list.proc-param )
                            , input entry( 6, buf_tmp#list.proc-param )
                            , input entry( 7, buf_tmp#list.proc-param )
                            , input entry( 8, buf_tmp#list.proc-param )
                        ).
                    end.
                end case.
            end.
        end.
    end.
    if g#quest-print = yes
    Then do:
        os-delete
            value( string( session:temp-directory ) + "rpt" + string( g#report-num ) )
        .
        os-rename
            value(  string( session:temp-directory ) + "$" + string( g#report-num ) )
            value(  string( session:temp-directory ) + "rpt" + string( g#report-num ) )
        .
        os-delete
            value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
        .
        os-rename
            value(  string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
            value(  string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
        .
        if v-form-amount = 1
        and ((can-find (first buf_tmp#list where CAPS(buf_tmp#list.proc-name) = "XL-PRTCL.P":U and buf_tmp#list.last-use = yes) = yes  )
        or (can-find (first buf_tmp#list where CAPS(buf_tmp#list.proc-name) = "TICK-DOC.P":U and buf_tmp#list.last-use = yes) = yes  ))
        then do:
if session :set-wait-state( "" ) then.
        end.
        else do
        :
            find first buf_tmp#list
                 where buf_tmp#list.last-use = yes
            no-error.
            if available buf_tmp#list
            then do:
                if buf_tmp#list.orient-orientation = "runexcelport":U
                or buf_tmp#list.orient-orientation = "runexcellans":U
                then do:
                    os-rename
                        value(  string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
                        value(  string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".tx_" )
                    .
                end.
                case buf_tmp#list.orient-orientation
                :
                    when "A4port":U
                    or when "runexcelport":U
                    then do:
                        run gbl/prnfilen.w (
                              input "":U
                            , input 0
                            , input string( session :temp-directory )
                                        + "rpt"
                                        + string( g#report-num )
                            , input buf_tmp#list.orient-font-num
                            , output v-user-action
                            , output v-printed
                        ) .
                    end.
                    when "A4lans":U
                    or when "runexcellans":U
                    or when "":U
                    then do:
                        run gbl/prnfilen.w (
                              input "":U
                            , input 8
                            , input string( session :temp-directory )
                                        + "rpt"
                                        + string( g#report-num )
                            , input buf_tmp#list.orient-font-num
                            , output v-user-action
                            , output v-printed
                        ) .
                    end.
                end case.
                if buf_tmp#list.orient-orientation = "runexcelport":U
                or buf_tmp#list.orient-orientation = "runexcellans":U
                then do:
                    os-rename
                        value(  string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".tx_" )
                        value(  string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
                    .
                end.
            end.
        end.
    end.
    else do:
        Message 'Задание распечатано'.
    end.
end.
END PROCEDURE.
PROCEDURE reposition-browse :
do
with frame Dialog-Frame
on error undo, return error
:
    define variable v-focused-row    as integer      no-undo.
    assign
        v-focused-row     = br-table :focused-row in frame Dialog-Frame.
    .
    get next br-table.
    if available tmp#list
    then do:
        if v-focused-row >= br-table :height-chars - 4
        then do:
            br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame Dialog-Frame.
        end.
        else do:
            br-table :set-repositioned-row( v-focused-row + 1, "ALWAYS" ) in frame Dialog-Frame.
        end.
        reposition br-table to rowid rowid( tmp#list ) no-error.
    end.
    else do:
        get last br-table.
    end.
end.
END PROCEDURE.
PROCEDURE reposition-to-recid :
define input parameter p-ext-system-recid  as recid        no-undo.
do
on error undo, return error
:
    if p-ext-system-recid <> ?
    then do:
        reposition br-table to recid p-ext-system-recid no-error .
    end.
    do with frame Dialog-Frame
    :
        apply "entry":u to browse br-table .
    end.
end.
END PROCEDURE.
PROCEDURE save-form-parameters :
    define variable v-call-point    as character    no-undo.
    define buffer buf_tmp#list          for tmp#list.
    define buffer buf_usr-flt           for ubflt.usr-flt.
    define buffer buf_temp_form-list    for temp_form-list.
do
for buf_tmp#list
  , buf_usr-flt
  , buf_temp_form-list
on error undo, return error
:
    for each buf_tmp#list
    :
        run get-call-point in this-procedure (
              input buf_tmp#list.id
            , output v-call-point
        ).
        find first buf_usr-flt exclusive-lock
             where buf_usr-flt.user-name  = v-cntxt-userid
               and buf_usr-flt.call-point = substitute( "&1,&2,&3,&4"
                                            , buf_tmp#list.blank-name
                                            , buf_tmp#list.sys-key
                                            , buf_tmp#list.sys-key-black
                                            , v-call-point )
        no-error.
        if not available buf_usr-flt
        then do:
            create buf_usr-flt.
            assign
                buf_usr-flt.user-name  = v-cntxt-userid
                buf_usr-flt.call-point = substitute( "&1,&2,&3,&4"
                                            , buf_tmp#list.blank-name
                                            , buf_tmp#list.sys-key
                                            , buf_tmp#list.sys-key-black
                                            , v-call-point )
            .
        end.
        assign
            buf_usr-flt.list_ = substitute( "selection,&1,type-parts,&2,type-price,&3,type-scale,&4,type-val,&5,sort-name,&6,sort-gr,&7,print-graft,&8":U
                                    , ( if buf_tmp#list.last-use = yes then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.type-parts , "+":U ) <> 0 then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.type-price , "+":U ) <> 0 then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.type-scale , "+":U ) <> 0 then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.type-val   , "+":U ) <> 0 then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.sort-name  , "+":U ) <> 0 then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.sort-gr    , "+":U ) <> 0 then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.print-graft, "+":U ) <> 0 then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.no-vat     , "+":U ) <> 0 then "+":U else "-":U )
                                    )
        .
    end.
end.
END PROCEDURE.
PROCEDURE select-or-deselect-item :
define input  parameter p-id as integer    no-undo.
    define buffer buf_tmp#list for tmp#list.
do
for buf_tmp#list
on error undo, return error
:
    find first buf_tmp#list
         where buf_tmp#list.id = p-id
    .
    if buf_tmp#list.last-use = yes
    then do:
        assign
            buf_tmp#list.last-use = no
        .
    end.
    else do:
        assign
            buf_tmp#list.last-use = yes
        .
    end.
end.
END PROCEDURE.
PROCEDURE test-temp-tables :
    define buffer buf_t_tmp#list      for tmp#list.
do
for buf_t_tmp#list
on error undo, return error
:
    output to "D:\111.txt".
    for each temp_trn-doc-code no-lock
    :
        put unformatted
            skip substitute( "&1", temp_trn-doc-code.doc-code )
        .
    end.
    put unformatted
        skip "================================================================================"
    .
    for each temp_form-list no-lock
    on error undo, return error
    :
        find first buf_t_tmp#list no-lock
             where buf_t_tmp#list.id = temp_form-list.id
        .
        put unformatted
            skip substitute( "&1 &2 &3 &4 &5 &6 &7 &8", temp_form-list.doc-code, temp_form-list.doc-type, temp_form-list.status_, temp_form-list.internal, temp_form-list.flag, temp_form-list.id, buf_t_tmp#list.blank-name, buf_t_tmp#list.last-use )
        .
    end.
    put unformatted
        skip "================================================================================"
    .
    for each temp_menu-doc_disabled-doc-list no-lock
    on error undo, return error
    :
        put unformatted
            skip substitute( "&1 &2 &3", temp_menu-doc_disabled-doc-list.doc-code, temp_menu-doc_disabled-doc-list.blank-name, temp_menu-doc_disabled-doc-list.reason )
        .
    end.
    output close.
end.
END PROCEDURE.
PROCEDURE ui-disable-all :
do
on error undo, return error
:
end.
END PROCEDURE.
PROCEDURE ui-enable :
    define buffer buf_clients       for ub.clients.
do
for buf_clients
on error undo, return error
:
    enable
        b-sel
        b-deselect
    with frame Dialog-Frame .
    Tmp#List.blank-name:width in browse br-table = 53.
    Tmp#List.blank-name:resizable in browse br-table = yes.
end.
END PROCEDURE.
