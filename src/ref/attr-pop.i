/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура создания пункта pop-up меню для ручного и batch редактирования атрибутов различных таблиц

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/26/06
Author: Bakhtadze Natalya
Creation date: 04/26/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then

define temp-table tt-attr-property  no-undo
field upper-attr-code as character
field attr-code as character
field table-name as character
field edit-menu-section-num as integer
field attr-label as character
field menu-item-handle as widget-handle
field user-can-edit as logical
field menu-name as character
field parent-handle as handle
index pi is unique primary
table-name
menu-name
upper-attr-code
attr-code
index i-section
edit-menu-section-num
.

&endif

&if "{1}" = "prepare" &then
&endif

&if "{1}" = "proc" or  "{1}" = "proc2" or "{1}" = "proc3" &then

procedure attr-pop-create-items :
define input parameter p-table-name as character no-undo .
define input parameter p-get-section-num-proc-name as character no-undo .
define input parameter p-get-attr-label-proc-name as character no-undo .
define input parameter p-attr-choose-proc-name as character no-undo .
define input parameter p-menu-handle as widget-handle no-undo .
&if "{1}" = "proc2" or "{1}" = "proc3" &then
define input parameter p-upper-attr-code as character no-undo .
&endif
define input parameter p-attr-list as character no-undo .

define variable ii as integer no-undo .
define variable V-CREATED as logical no-undo .
define variable v-tool-tip as character no-undo .
define variable v-dop as character no-undo .
define variable v-attr-item as character no-undo .
&if "{1}" = "proc" &then
define variable p-upper-attr-code as character no-undo .
&endif

define buffer buf_tt-attr-property for tt-attr-property.

  do
  on error undo, return error return-value
  :
     do ii = 1 to num-entries (p-attr-list):
       v-attr-item = entry(ii, p-attr-list) .
       find first tt-attr-property where
                 tt-attr-property.table-name = p-table-name
             and tt-attr-property.attr-code = v-attr-item
             and tt-attr-property.upper-attr-code = p-upper-attr-code
             and tt-attr-property.menu-name = p-menu-handle:name  no-error .
       if not available tt-attr-property then do:
         create tt-attr-property.
         assign
         tt-attr-property.table-name = p-table-name
         tt-attr-property.attr-code = v-attr-item
         tt-attr-property.upper-attr-code = p-upper-attr-code
         tt-attr-property.menu-name = p-menu-handle:name
         .
         run value ( p-get-section-num-proc-name) (
                                                   &if "{1}" = "proc2" or "{1}" = "proc3" &then
                                                   input p-upper-attr-code,
                                                   &endif
                                                   input tt-attr-property.attr-code
                                                  ,output tt-attr-property.edit-menu-section-num ) no-error .
         run value ( p-get-attr-label-proc-name ) (
                                        &if "{1}" = "proc2" or "{1}" = "proc3" &then
                                        input p-upper-attr-code,
                                        &endif
                                        input tt-attr-property.attr-code
                                       ,output v-tool-tip
                                       ,output tt-attr-property.attr-label
                                       &if "{1}" = "proc3" &then
                                       ,output v-dop
                                       &endif
                                      ) no-error .

         release tt-attr-property.
       end.
     end.
     for each tt-attr-property where tt-attr-property.menu-name = p-menu-handle:name
     break
     by  tt-attr-property.edit-menu-section-num
     by  tt-attr-property.attr-label
     :
       if tt-attr-property.edit-menu-section-num > 0
       then do:
          if not valid-handle(tt-attr-property.menu-item-handle) then do:
            if num-entries(tt-attr-property.attr-code, {&delim-par}) > 1
            and entry(2, tt-attr-property.attr-code, {&delim-par}) <> '':U
            then do:
              find first buf_tt-attr-property where
                        buf_tt-attr-property.table-name = p-table-name
                    and buf_tt-attr-property.menu-name = p-menu-handle:name
                    and buf_tt-attr-property.upper-attr-code = p-upper-attr-code
                    and buf_tt-attr-property.attr-code = entry(1, tt-attr-property.attr-code, {&delim-par}) no-error .
              if not available buf_tt-attr-property then do:
                create buf_tt-attr-property.
                assign
                buf_tt-attr-property.table-name = p-table-name
                buf_tt-attr-property.attr-code = entry(1, tt-attr-property.attr-code, {&delim-par})
                buf_tt-attr-property.upper-attr-code = p-upper-attr-code
                buf_tt-attr-property.menu-name = p-menu-handle:name
                .
                create sub-menu buf_tt-attr-property.menu-item-handle
                assign
                name = entry(1, tt-attr-property.attr-code, {&delim-par})  + {&delim-par}  + p-menu-handle:name
                parent = p-menu-handle.
              end.
              create menu-item tt-attr-property.menu-item-handle
              assign
              label = tt-attr-property.attr-label
              name = tt-attr-property.attr-code  + {&delim-par}  + p-menu-handle:name
              parent = buf_tt-attr-property.menu-item-handle
              triggers:
                on choose
                  persistent run value(p-attr-choose-proc-name + "-2") (
                                                                        &if "{1}" = "proc2" or "{1}" = "proc3" &then
                                                                        input tt-attr-property.upper-attr-code,
                                                                        &endif
                                                                         input  entry(1, tt-attr-property.attr-code, {&delim-par} )
                                                                        ,input entry(2, tt-attr-property.attr-code, {&delim-par} )
                                                                          ) .

              end triggers.
              assign
              v-created = yes.
            end.
            else do:
              create menu-item tt-attr-property.menu-item-handle
              assign
              label = tt-attr-property.attr-label
              name = entry(1, tt-attr-property.attr-code, {&delim-par}) + {&delim-par}  + p-menu-handle:name
              parent = p-menu-handle
              triggers:
                on choose
                  persistent run value(p-attr-choose-proc-name) (
                                                                  &if "{1}" = "proc2" or "{1}" = "proc3" &then
                                                                  input tt-attr-property.upper-attr-code,
                                                                  &endif
                                                                 input  entry(1, tt-attr-property.attr-code, {&delim-par} )) .

              end triggers.
              assign
              v-created = yes.
            end.
          end.
          if last-of(tt-attr-property.edit-menu-section-num)
          /*and not last(tt-attr-property.edit-menu-section-num)*/  then do:
            find first buf_tt-attr-property where
                      buf_tt-attr-property.table-name = p-table-name
                 and  buf_tt-attr-property.attr-code = substitute("&1&2&3"
                                                         , p-table-name
                                                         , tt-attr-property.edit-menu-section-num
                                                         , p-menu-handle:name
                                                         )
                  and buf_tt-attr-property.menu-name = p-menu-handle:name  no-error .
            if not available buf_tt-attr-property then do:
              create buf_tt-attr-property.
              assign
              buf_tt-attr-property.table-name = p-table-name
              buf_tt-attr-property.edit-menu-section-num =  - 1
              buf_tt-attr-property.menu-name = p-menu-handle:name
              buf_tt-attr-property.upper-attr-code = ''
              buf_tt-attr-property.attr-code = substitute("&1&2&3"
                                                          , p-table-name
                                                          , tt-attr-property.edit-menu-section-num
                                                          , p-menu-handle:name
                                                          )
              .
              create menu-item buf_tt-attr-property.menu-item-handle
              assign
              subtype = "rule"
              parent = p-menu-handle
              /*name = buf_tt-attr-property.attr-code
              label = fill ( '_', 20)*/
              .
            end.
          end. /*          if last-of(tt-attr-property.edit-menu-section-num)*/
       end.  /*if tt-attr-property.edit-menu-section-num > 0*/
     end. /*for each tt-attr-property*/
     if not v-created then do:
        run attr-pop-clean-up in this-procedure ( input p-table-name).
     end.
  end. /*DOE*/

end procedure. /* attr-pop-create-items */



procedure attr-pop-clean-up :
define input parameter p-table-name as character no-undo .
  for each tt-attr-property where
          tt-attr-property.table-name = p-table-name
    and tt-attr-property.edit-menu-section-num > 0:
    if valid-handle ( tt-attr-property.menu-item-handle) then do:
      delete widget tt-attr-property.menu-item-handle.
    end.
    delete tt-attr-property.
  end.
  for each tt-attr-property where
           tt-attr-property.table-name = p-table-name
       and tt-attr-property.edit-menu-section-num =  - 1:
    if valid-handle ( tt-attr-property.menu-item-handle) then do:
      delete widget tt-attr-property.menu-item-handle.
    end.
    delete tt-attr-property.
  end.
end procedure.

&endif



/* $Workfile$ e n d */