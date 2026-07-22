/*

$Revision$
$Author$
$Date$
$Workfile: $
$Archive: $

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/30/10
Author: Bakhtadze Natalya
Creation date: 08/30/10

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure re-save-conf-par :
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define buffer buf_rep-line for ub.rep-line  .
define buffer buf_price-list-type-attr  for ub.price-list-type-attr .
define buffer buf_thbj-attr  for ub.thbj-attr.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  for each buf_rep-line exclusive-lock where
           buf_rep-line.rep-num = 1996011203
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :

    find first buf_price-list-type-attr exclusive-lock where
              buf_price-list-type-attr.plt-id = integer(buf_rep-line.name4)
          and buf_price-list-type-attr.plt-db-num =  integer(buf_rep-line.name5)
          and buf_price-list-type-attr.attr-code = {&typeprice_ie-gen-marg} no-error.
    if available buf_price-list-type-attr then do:
      buf_price-list-type-attr.attr-value = buf_rep-line.name2 .

    end.
  end.
  for each buf_rep-line exclusive-lock where
           buf_rep-line.rep-num = 1996011206
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    case buf_rep-line.name3:
      when "object" then do:
        assign
        v-obj-type = buf_rep-line.name1
        v-obj-code = buf_rep-line.code3
        .
      end.
      when "host" then do:
        assign
        v-obj-type = {&cmp}
        v-obj-code = buf_rep-line.code2
        .
      end.
      when "global" then do:
        assign
        v-obj-type = ''
        v-obj-code = 0
        .
      end.
    end case.
    find first buf_thbj-attr exclusive-lock where
              buf_thbj-attr.obj-type = v-obj-type
          and buf_thbj-attr.obj-code = v-obj-code
          and buf_thbj-attr.prop-code = {&attr-overval_pr-goods}
          and buf_thbj-attr.upper-prop-code = {&attr-overval} no-error.
    if available buf_thbj-attr then do:
      buf_thbj-attr.property-value-character =  buf_rep-line.name2 .
    end.
  end.
  for each buf_rep-line exclusive-lock where
           buf_rep-line.rep-num = 1996011209
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    case buf_rep-line.name3:
      when "object" then do:
        assign
        v-obj-type = buf_rep-line.name1
        v-obj-code = buf_rep-line.code3
        .
      end.
      when "host" then do:
        assign
        v-obj-type = {&cmp}
        v-obj-code = buf_rep-line.code2
        .
      end.
      when "global" then do:
        assign
        v-obj-type = ''
        v-obj-code = 0
        .
      end.
    end case.

    find first buf_thbj-attr exclusive-lock where
              buf_thbj-attr.obj-type = buf_rep-line.name1
          and buf_thbj-attr.obj-code = buf_rep-line.code3
          and buf_thbj-attr.prop-code = {&attr-overval_pr-goods0}
          and buf_thbj-attr.upper-prop-code = {&attr-overval} no-error.
    if available buf_thbj-attr then do:
      buf_thbj-attr.property-value-character =  buf_rep-line.name2 .
    end.
  end.

end.
end procedure. /* re-save-conf-par */

procedure save-conf-par :
define buffer buf_rep-line for ub.rep-line  .
define variable ii as integer   no-undo init 0 .
define variable v-plt-id as integer no-undo .
define variable v-plt-db-num as integer no-undo .
define variable v-host-code as integer no-undo .
define buffer buf_price-list-type-attr  for ub.price-list-type-attr .
define buffer buf_thbj-attr for ub.thbj-attr.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  /* раньше было
  for each buf_config exclusive-lock where
          buf_config.db-num = v-cntxt-db-num
      and buf_config.param-code = "gen-mrgn" :

*/
  for each obj-list
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    { gbl/gtplobj.i
      ?
      obj-list.obj-type
      obj-list.obj-code
      yes
      v-plt-id
      v-plt-db-num
    }

    { gbl/hostcode.i
      obj-list.obj-type
      obj-list.obj-code
      v-host-code
      }


    for each buf_price-list-type-attr no-lock where
            buf_price-list-type-attr.plt-id     = v-plt-id
        and buf_price-list-type-attr.plt-db-num = v-plt-db-num
        and buf_price-list-type-attr.attr-code = {&typeprice_ie-gen-marg}
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      ii = ii + 1.
      find first buf_rep-line exclusive-lock where
                buf_rep-line.code1   = ii
            and buf_rep-line.rep-num = 1996011203
      no-error .

      if not available buf_rep-line then do:
        create buf_rep-line.
      end.
      assign
      buf_rep-line.code1   = ii
      buf_rep-line.rep-num = 1996011203
      buf_rep-line.code2   = v-host-code        /*host-code*/
      buf_rep-line.name1   = obj-list.obj-type  /*obj-type*/
      buf_rep-line.code3   = obj-list.obj-code  /*obj-code*/
      buf_rep-line.name2   = buf_price-list-type-attr.attr-value
      buf_rep-line.name4   = string(buf_price-list-type-attr.plt-id)
      buf_rep-line.name5   = string(buf_price-list-type-attr.plt-db-num)
      .
      buf_price-list-type-attr.attr-value = {&typeprice_no-margin}.
    end. /*for each buf_price-list-type-attr no-lock where*/
    { gbl/getsect.i run obj-list.obj-type obj-list.obj-code {&attr-overval} }
    for each thbjattr_thbj-attr
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-goods} then do:
        find first buf_rep-line exclusive-lock where
                  buf_rep-line.code1   = ii
              and buf_rep-line.rep-num = 1996011206
                  no-error .
        if not available buf_rep-line then do:
          create buf_rep-line.
        end.
        assign
        buf_rep-line.code1   = ii
        buf_rep-line.rep-num = 1996011206
        buf_rep-line.code2   = v-host-code
        buf_rep-line.name1   = obj-list.obj-type
        buf_rep-line.code3   = obj-list.obj-code
        buf_rep-line.name2   = thbjattr_thbj-attr.property-value-character
        .
        /*надем какой thbj-attr нам дал этот параметр*/
        find first buf_thbj-attr exclusive-locK where
                  buf_thbj-attr.upper-prop-code = {&attr-overval}
              and buf_thbj-attr.prop-code = {&attr-overval_pr-goods}
              and buf_thbj-attr.obj-type = obj-list.obj-type
              and buf_thbj-attr.obj-code = obj-list.obj-code no-error.
        if available buf_thbj-attr then do:
          buf_thbj-attr.property-value-character = {&pr-gds-no-ban} .
          buf_rep-line.name3   = "object".
        end.
        else do:
          find first buf_thbj-attr exclusive-locK where
                    buf_thbj-attr.upper-prop-code = {&attr-overval}
                and buf_thbj-attr.prop-code = {&attr-overval_pr-goods}
                and buf_thbj-attr.obj-type = {&cmp}
                and buf_thbj-attr.obj-code = v-host-code no-error.
          if available buf_thbj-attr then do:
            buf_thbj-attr.property-value-character = {&pr-gds-no-ban} .
            buf_rep-line.name3   = "host".
          end.
          else do:
            find first buf_thbj-attr exclusive-locK where
                      buf_thbj-attr.upper-prop-code = {&attr-overval}
                  and buf_thbj-attr.prop-code = {&attr-overval_pr-goods}
                  and buf_thbj-attr.obj-type = ''
                  and buf_thbj-attr.obj-code = 0 no-error.
            if available buf_thbj-attr then do:
              buf_thbj-attr.property-value-character = {&pr-gds-no-ban} .
              buf_rep-line.name3   = "global".
            end.
          end.
        end.

      end. /*if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-goods} then do:*/
      if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-goods0} then do:
        find first buf_rep-line exclusive-lock where
                  buf_rep-line.code1   = ii
              and buf_rep-line.rep-num = 1996011209
                  no-error .
        if not available buf_rep-line then do:
          create buf_rep-line.
        end.
        assign
        buf_rep-line.code1   = ii
        buf_rep-line.rep-num = 1996011209
        buf_rep-line.code2   = v-host-code
        buf_rep-line.name1   = obj-list.obj-type
        buf_rep-line.code3   = obj-list.obj-code
        buf_rep-line.name2   = thbjattr_thbj-attr.property-value-character
        .
        /*надем какой thbj-attr нам дал этот параметр*/
        find first buf_thbj-attr exclusive-locK where
                  buf_thbj-attr.upper-prop-code = {&attr-overval}
              and buf_thbj-attr.prop-code = {&attr-overval_pr-goods0}
              and buf_thbj-attr.obj-type = obj-list.obj-type
              and buf_thbj-attr.obj-code = obj-list.obj-code no-error.
        if available buf_thbj-attr then do:
          buf_thbj-attr.property-value-character = {&pr-gds-no-ban} .
          buf_rep-line.name3   = "object".
        end.
        else do:
          find first buf_thbj-attr exclusive-locK where
                    buf_thbj-attr.upper-prop-code = {&attr-overval}
                and buf_thbj-attr.prop-code = {&attr-overval_pr-goods0}
                and buf_thbj-attr.obj-type = {&cmp}
                and buf_thbj-attr.obj-code = v-host-code no-error.
          if available buf_thbj-attr then do:
            buf_thbj-attr.property-value-character = {&pr-gds-no-ban} .
            buf_rep-line.name3   = "host".
          end.
          else do:
            find first buf_thbj-attr exclusive-locK where
                      buf_thbj-attr.upper-prop-code = {&attr-overval}
                  and buf_thbj-attr.prop-code = {&attr-overval_pr-goods0}
                  and buf_thbj-attr.obj-type = ''
                  and buf_thbj-attr.obj-code = 0 no-error.
            if available buf_thbj-attr then do:
              buf_thbj-attr.property-value-character = {&pr-gds-no-ban} .
              buf_rep-line.name3   = "global".
            end.
          end.
        end.
      end. /*if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-goods0} then do:*/
    end. /*    for each thbjattr_thbj-attr :*/
  end. /*  for obj-list  */
end.
end procedure. /* save-conf-par */


/* $Workfile$ e n d */