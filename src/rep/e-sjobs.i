/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

журнал продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/05/06
Author: Bakhtadze Natalya
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if first( sj-goods.obj-attr ) then do:
  if v-curr-r-b = {&r-b-base} then do:
                        if my-set_val_type = {&v-base}  then
                            DOWN STREAM PrnLibStream 1 with FRAME {1}{3} .
                        else
                            DOWN STREAM PrnLibStream 1 with FRAME {2}{3} .
  end.
  else do:
                            DOWN STREAM PrnLibStream 1 with FRAME {1}{3} .
  end.
end.
                if first-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then  do:
                        assign
                        strbuf1 = substr( sj-goods.obj-attr, 1, 3 )
                        intbuf1 = integer( substr( sj-goods.obj-attr, 4 ) ) .
                        FIND FIRST cli-obj WHERE
                                   cli-obj.obj-type = strbuf1 AND
                                   cli-obj.obj-code = intbuf1 NO-LOCK .
                        PUT STREAM PrnLibStream
                        cli-obj.obj-name format "x(120)" SKIP.
if v-curr-r-b = {&r-b-base} then do:
                        if my-set_val_type = {&v-base}  then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME {1}{3} .
                        else
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME {2}{3} .
end.
else do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME {1}{3} .
end.
                    end.

/* $Workfile$ e n d */