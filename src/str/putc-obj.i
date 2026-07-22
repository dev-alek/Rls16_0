/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вывод в поток информации по объектам БД - пока только IBM-XML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/04/03
Author: Bakhtadze Natalya
Creation date: 12/04/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE putc-dept.
define input parameter pos-type as char no-undo.


define variable ii as integer no-undo .

CASE pos-type:
  when {&cd-type-IBM-XML} then do:
     for each cash-obj no-lock
     break
     by cash-obj.km-objtype
     by cash-obj.km-objcode
     by cash-obj.km-objname
     :
      if first-of(cash-obj.km-objname) then do:
        run bgelib-tag-open in this-procedure ( input 2, input "Object"
                                              , input substitute("ctrl='&1' tms='&2'"
                                                                , (if action = "U"
                                                                    then "ADD":U
                                                                    else "DEL":U)
                                                                  ,OS2-time
                                                                )).
        run bgelib-tag-put in this-procedure ( input 3, input "ObjName"
                                            , input cash-obj.km-objname, input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "ObjType":U
                                            , input string(cash-obj.km-objtype), input 1 ). /*backoffice*/
        run bgelib-tag-put in this-procedure ( input 3, input "ObjOnAddr":U
                                            , input cash-obj.on-addr, input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "ObjOffAddr":U
                                            , input cash-obj.off-addr, input 1 ).
        do ii = 1 to num-entries (cash-obj.shop-nums):
          run bgelib-tag-open in this-procedure ( input 3, input "ObjShop":U
                                              , input "":U).
          run bgelib-tag-put in this-procedure ( input 4, input "OSNum":U
                                              , input entry(ii, cash-obj.shop-nums), input 1 ).
          run bgelib-tag-close in this-procedure ( input 3, input "ObjShop").
        end.

        if cash-obj.km-objtype = 1 then do:

          run bgelib-tag-open in this-procedure ( input 3, input "ObjParam":U
                                                , input "":U).
          run bgelib-tag-put in this-procedure ( input 4, input "OPName":U
                                                , input "firm-name", input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "OPValue":U
                                                , input cash-obj.firm-name, input 1 ).
          run bgelib-tag-close in this-procedure ( input 3, input "ObjParam").


          run bgelib-tag-open in this-procedure ( input 3, input "ObjParam":U
                                                , input "":U).
          run bgelib-tag-put in this-procedure ( input 4, input "OPName":U
                                                , input "jur-address", input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "OPValue":U
                                                , input cash-obj.jur-address, input 1 ).
          run bgelib-tag-close in this-procedure ( input 3, input "ObjParam").

          run bgelib-tag-open in this-procedure ( input 3, input "ObjParam":U
                                                , input "":U).
          run bgelib-tag-put in this-procedure ( input 4, input "OPName":U
                                                , input "post-address", input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "OPValue":U
                                                , input cash-obj.post-address, input 1 ).
          run bgelib-tag-close in this-procedure ( input 3, input "ObjParam").

          run bgelib-tag-open in this-procedure ( input 3, input "ObjParam":U
                                                , input "":U).
          run bgelib-tag-put in this-procedure ( input 4, input "OPName":U
                                                , input "INN", input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "OPValue":U
                                                , input cash-obj.INN, input 1 ).
          run bgelib-tag-close in this-procedure ( input 3, input "ObjParam").

          run bgelib-tag-open in this-procedure ( input 3, input "ObjParam":U
                                                , input "":U).
          run bgelib-tag-put in this-procedure ( input 4, input "OPName":U
                                                , input "KPP", input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "OPValue":U
                                                , input cash-obj.KPP, input 1 ).
          run bgelib-tag-close in this-procedure ( input 3, input "ObjParam").
        end.


        run bgelib-tag-put in this-procedure ( input 3, input "ObjLock":U
                                              , input string(cash-obj.obj-lock), input 1 ).
        run bgelib-tag-close in this-procedure ( input 2, input "Object").
       end.

     end.
  end. /*when ibm-xml*/
END CASE .
END PROCEDURE .


/* $Workfile$ e n d */