/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вывод в поток информации о группах блюд по подразделениям (группы перйскурантов) - пока только MAGIA

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/04/03
Author: Bakhtadze Natalya
Creation date: 12/04/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE putc-fbr-gds-grp:
define input parameter pos-type as char no-undo.
define buffer buf_shop for ub.shop.

CASE pos-type:
  when {&cd-type-MAGIA-XML} then do:
    find first buf_shop no-lock where
                buf_shop.obj-code = i-obj-code no-error .
    if not available buf_shop then return.
    if buf_shop.is-catering = no
    AND buf_shop.is-kitchen = no
    AND buf_shop.is-kitchen-store = no  then return.

&scop put-record ~
      run bgelib-tag-open in this-procedure ( input 2, input "PriceGroup" ~
                                            , input substitute("ctrl='&1' tms='&2' code='&3'", 'ADD':U, OS2-time, cash-fgrp.out-code)). ~
      run bgelib-tag-put in this-procedure ( input 3, input "PriceGroupName" ~
                                          , input trim(cash-fgrp.node-name, {&space-char}), input 1 ). ~
      run bgelib-tag-put in this-procedure ( input 3, input "PriceParentGroupID":U ~
                                          , input (string(cash-fgrp.upper-out-code)), input 1 ). ~
      run bgelib-tag-put in this-procedure ( input 3, input "PriceListID":U ~
                                          , input (string(buf_shop.obj-code)), input 1 ). ~
      run bgelib-tag-put in this-procedure ( input 3, input "ImageIndex":U ~
                                          , input (string(0)), input 1 ). ~
      run bgelib-tag-put in this-procedure ( input 3, input "PriceGroupLock" ~
                                          , input string(if action = "U":U then 0 else 1), input 1 ). ~
      run bgelib-tag-close in this-procedure ( input 2, input "PriceGroup")
      /*точки в конце скопника нет для контроля синтаксиса*/

    if action = "U":U then do:
      _fbr-gds-grp-add:
      for each cash-fgrp no-lock
      by cash-fgrp.action-code
      by cash-fgrp.lvl-num  :
         if cash-fgrp.out-code = 0 then NEXT  _fbr-gds-grp-add.
        {&put-record}.
      end. /*for each cash-fgrp no-lock where*/
    end.
    if action = "D":U then do:
      _fbr-gds-grp-del:
      for each cash-fgrp no-lock
      by cash-fgrp.action-code
      by cash-fgrp.lvl-num descending :
        if cash-fgrp.out-code = 0 then NEXT  _fbr-gds-grp-del.
        {&put-record}.
      end. /*for each cash-fgrp no-lock where*/
    end.
  end.
END CASE .
END PROCEDURE .


/* $Workfile$ e n d */