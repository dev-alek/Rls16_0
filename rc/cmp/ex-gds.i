/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

обработка товара для списка

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/17/06
Author: Bakhtadze Natalya
Creation date: 01/17/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE ex-gds :
    define parameter buffer buf_goods for ub.goods.
    define input parameter rs-list-method as character no-undo .
    define input parameter rs-status as character no-undo .
    define input parameter line-mode as character no-undo .
    if rs-list-method = "single":U or
        (buf_goods.stts = 0  and rs-status <> {&deleted}) or
        (buf_goods.stts <> 0 and rs-status <> {&current}) then 
    do:
        if line-mode = {&deletion} or line-mode = {&leave} then 
        do:
            if rs-list-method = "tsd":U then 
            do:
                for first ub.Code no-lock where ub.Code.parent = "TiketPrint" and 
                    ub.code.status_ = {&bef-current-status-int} and ub.Code.code = string(buf_goods.gds-code):    
                    find first {1} where {1}.artic = buf_goods.artic
                        and {1}.prod-type = buf_goods.prod-type
                        and {1}.prod-code = buf_goods.prod-code no-error.
                    if available {1} then 
                    do:
                        if line-mode = {&deletion} then 
                        do:
                            lns-cnt = lns-cnt + 1.
                            delete {1}.
                        end.
                        else 
                        do:
                            if {1}.to-del = ? then.
                            else 
                            do:
                                lns-cnt = lns-cnt + 1.
                                {1}.to-del = ?.
                            end.
                        end.
                    end.
                end.
            end.
            else 
            do: 
                find first {1} where {1}.artic = buf_goods.artic
                    and {1}.prod-type = buf_goods.prod-type
                    and {1}.prod-code = buf_goods.prod-code no-error.
                if available {1} then 
                do:
                    if line-mode = {&deletion} then 
                    do:
                        lns-cnt = lns-cnt + 1.
                        delete {1}.
                    end.
                    else 
                    do:
                        if {1}.to-del = ? then.
                        else 
                        do:
                            lns-cnt = lns-cnt + 1.
                            {1}.to-del = ?.
                        end.
                    end.
                end.
            end.
        end.
        else
            if line-mode = {&add-def} then 
            do:
                { cmp/gds-list.i {1} assign " " buf_goods }
                if rs-list-method = "tsd":U  then 
                do:
                    for first ub.Code no-lock where ub.Code.parent = "TiketPrint" and 
                        ub.code.status_ = {&bef-current-status-int} and ub.Code.code = string(buf_goods.gds-code):
                        find first {1} where {1}.gds-code = buf_goods.gds-code no-error.
                        if available {1} then 
                        do:
                            {1}.qnty = decimal(ub.Code.CodeValue) .
                        end.
                    end.
                end.   
            end.
  &if "{2}" <> "abc" &then
        if lns-cnt modulo 25 = 0 then
  &endif
            disp "ЖДИТЕ...    Обработано товаров :" + string (lns-cnt) @ dsp-rs with frame {2}.
    end.
    else
        assign
            lns-ignore = lns-ignore + 1
            .
end.

/* $Workfile$ e n d  */