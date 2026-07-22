/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

журнал продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/05/05
Author: Bakhtadze Natalya
Creation date: 12/05/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{3}" = "sj-adv.price" &then
  &if "{6}" = "-t" &then
&scoped-define   put-line-length-full 230
&scoped-define   put-line-length-base 196
  &else
&scoped-define   put-line-length-full 196
&scoped-define   put-line-length-base 136
  &endif

&else
  &if "{6}" = "-t" &then
&scoped-define   put-line-length-full 230
&scoped-define   put-line-length-base 196
  &else
&scoped-define   put-line-length-full 196
&scoped-define   put-line-length-base 196
  &endif
&endif



    ACCUMULATE
    sj-adv.qnty (TOTAL)
    sj-adv.qnty-2 (TOTAL)
    sj-adv.qnty-3 (TOTAL)
    sj-adv.brutto-sum (TOTAL)
    sj-adv.discnt-sum (TOTAL)
    sj-adv.netto-sum (TOTAL)
    sj-adv.brutto-sum-r (TOTAL)
    sj-adv.netto-sum-r (TOTAL)
    sj-adv.num-docs (TOTAL)
    sj-adv.num-lines (TOTAL)
    sj-adv.qnty ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty ( SUB-TOTAL BY {3} )
    sj-adv.qnty-2 ( SUB-TOTAL BY {3} )
    sj-adv.qnty-3 ( SUB-TOTAL BY {3} )
    sj-adv.brutto-sum ( SUB-TOTAL BY {3} )
    sj-adv.discnt-sum ( SUB-TOTAL BY {3} )
    sj-adv.netto-sum ( SUB-TOTAL BY {3} )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY {3} )
    sj-adv.netto-sum-r ( SUB-TOTAL BY {3} )
    sj-adv.qnty ( SUB-TOTAL BY {2} )
    sj-adv.qnty-2 ( SUB-TOTAL BY {2} )
    sj-adv.qnty-3 ( SUB-TOTAL BY {2} )
    sj-adv.brutto-sum ( SUB-TOTAL BY {2} )
    sj-adv.discnt-sum ( SUB-TOTAL BY {2} )
    sj-adv.netto-sum ( SUB-TOTAL BY {2} )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY {2} )
    sj-adv.netto-sum-r ( SUB-TOTAL BY {2} )
&if "{2}" = "sj-goods.saleman" &then
    sj-adv.num-docs (SUB-TOTAL BY {2} )
    sj-adv.num-lines (SUB-TOTAL BY {2} )
&endif
&if "{6}" = "-t" &then
    sj-adv.qnty  (SUB-TOTAL BY ( sj-goods.b-code ) )
    sj-adv.qnty-2 (SUB-TOTAL BY ( sj-goods.b-code ) )
    sj-adv.qnty-3 (SUB-TOTAL BY ( sj-goods.b-code ) )
    sj-adv.brutto-sum  (SUB-TOTAL BY ( sj-goods.b-code ) )
    sj-adv.discnt-sum  (SUB-TOTAL BY ( sj-goods.b-code ) )
    sj-adv.netto-sum  (SUB-TOTAL BY ( sj-goods.b-code ) )
    sj-adv.brutto-sum-r  (SUB-TOTAL BY ( sj-goods.b-code ) )
    sj-adv.netto-sum-r  (SUB-TOTAL BY ( sj-goods.b-code ) )
&endif
    .


&if "{6}" = "-t" &then
IF FIRST-OF({3}) then do:
  chk-gds-lines = 0.
end.
if sj-goods.twounit > 0 AND SHRS-BY <> 0 then do:
  namebuf1 = get-strokes(buffer sj-goods, 18, 21,
                         input-output namebuf1,
                         input-output namebuf2,
                         input-output prodbuf1,
                         input-output prodbuf2).
  CASE my-Set_val_type :
    when {&v-base} then  do:
      DISPLAY STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      namebuf1 @ sj-goods.name
      prodbuf1 @ sj-goods.prod-name
      sj-adv.qnty
      sj-adv.qnty-2
      sj-adv.qnty-3
      sj-adv.price
      sj-adv.brutto-sum
&if "{3}" = "sj-adv.discnt" &then
      sj-adv.discnt
&endif
      sj-adv.discnt-sum
      (IF sj-adv.qnty <> 0
      THEN
      round( sj-adv.discnt-sum  / sj-adv.brutto-sum  * 100 , 1 )
      else 0)  @ pcnt
      sj-adv.netto-sum
      with FRAME {4}{6} .
      DOWN STREAM PrnLibStream 1 with FRAME {4}{6} .
    end.
    when {&v-all} then do:
      DISPLAY STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      namebuf1 @ sj-goods.name
      prodbuf1 @ sj-goods.prod-name
      sj-adv.qnty
      sj-adv.qnty-2
      sj-adv.qnty-3
      sj-adv.price
      sj-adv.brutto-sum
      sj-adv.brutto-sum-r
&if "{3}" = "sj-adv.discnt" &then
      sj-adv.discnt
&endif
      sj-adv.discnt-sum
      (IF sj-adv.qnty <> 0
      THEN
      round( sj-adv.discnt-sum  /  sj-adv.brutto-sum  * 100, 1 )
      ELSE 0 ) @ pcnt
      sj-adv.netto-sum
      sj-adv.netto-sum-r
      with FRAME {5}{6} .
      DOWN STREAM PrnLibStream 1 with FRAME {5}{6} .
    end.
  END CASE .
  if ( namebuf2 <> "" ) OR ( prodbuf2 <> "" ) then
  CASE my-Set_val_type :
    when {&v-base} then  do:
      DISPLAY STREAM PrnLibStream
      namebuf2 @ sj-goods.name
      prodbuf2 @ sj-goods.prod-name
      with FRAME {4}{6} .
      DOWN STREAM PrnLibStream 1 with FRAME {4}{6} .
    end.
    when {&v-all} then do:
      DISPLAY STREAM PrnLibStream
      namebuf2 @ sj-goods.name
      prodbuf2 @ sj-goods.prod-name
      with FRAME {5}{6} .
      DOWN STREAM PrnLibStream 1 with FRAME {5}{6} .
    end.
  END CASE .
  OneLinePrinted = TRUE .
  if last-of(sj-goods.b-code) and Not shOnly_tot then do:



  CASE my-Set_Val_Type :
    when {&v-base} then  do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.qnty-2
        sj-adv.qnty-3
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        sj-adv.netto-sum
        with FRAME {4}{6} .
        DOWN STREAM PrnLibStream 1 with FRAME {4}{6} .
      DISPLAY STREAM PrnLibStream
      sj-goods.b-code
      "Итого по бар-коду" @ sj-goods.artic
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.qnty @ sj-adv.qnty
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.qnty-2 @ sj-adv.qnty-2
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.qnty-3 @ sj-adv.qnty-3
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.brutto-sum @ sj-adv.brutto-sum
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.discnt-sum @ sj-adv.discnt-sum
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.netto-sum @ sj-adv.netto-sum
      with FRAME {4}{6}.
      DOWN STREAM PrnLibStream 1 with FRAME {4}{6} .
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.qnty-2
        sj-adv.qnty-3
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        sj-adv.netto-sum
        with FRAME {4}{6} .
        DOWN STREAM PrnLibStream 1 with FRAME {4}{6} .
    end.
    when {&v-all} then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.qnty-2
        sj-adv.qnty-3
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        sj-adv.netto-sum
        sj-adv.brutto-sum-r
        sj-adv.netto-sum-r
        with FRAME {5}{6} .
        DOWN STREAM PrnLibStream 1 with FRAME {5}{6} .
      DISPLAY STREAM PrnLibStream
      sj-goods.b-code
      "Итого по бар-коду" @ sj-goods.artic
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.qnty @ sj-adv.qnty
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.qnty-2 @ sj-adv.qnty-2
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.qnty-3 @ sj-adv.qnty-3
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.brutto-sum @ sj-adv.brutto-sum
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.discnt-sum @ sj-adv.discnt-sum
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.netto-sum @ sj-adv.netto-sum
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.netto-sum-r @  sj-adv.netto-sum-r
      with FRAME {5}{6} .
      DOWN STREAM PrnLibStream 1 with FRAME {5}{6}.
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.qnty-2
        sj-adv.qnty-3
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        sj-adv.netto-sum
        sj-adv.brutto-sum-r
        sj-adv.netto-sum-r
        with FRAME {5}{6} .
        DOWN STREAM PrnLibStream 1 with FRAME {5}{6} .
    end.
  END CASE . /*my-Set_Val_Type*/
  end.
end. /*if sj-goods.twounit > 0*/
&endif

if sj-goods.twounit = 0 then do:
  if last-of ( {3} ) AND SHRs-by <> 0 then do:
    namebuf1 = get-strokes(buffer sj-goods, 18, 21,
                           input-output namebuf1,
                           input-output namebuf2,
                           input-output prodbuf1,
                           input-output prodbuf2).
    CASE my-Set_val_type :
    when {&v-base} then  do:
      DISPLAY STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      namebuf1 @ sj-goods.name
      prodbuf1 @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY {3} sj-adv.qnty @ sj-adv.qnty
&if "{6}" = "-t" &then
      ACCUM SUB-TOTAL BY {3} sj-adv.qnty-2 @ sj-adv.qnty-2
      ACCUM SUB-TOTAL BY {3} sj-adv.qnty-3 @ sj-adv.qnty-3
&endif
      sj-adv.price
      ACCUM SUB-TOTAL BY {3} sj-adv.brutto-sum @ sj-adv.brutto-sum
&if "{3}" = "sj-adv.discnt" &then
      sj-adv.discnt
&endif
      ACCUM SUB-TOTAL BY {3} sj-adv.discnt-sum @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY {3} sj-adv.qnty) <> 0
      THEN
      round( ( ACCUM SUB-TOTAL BY {3} sj-adv.discnt-sum ) /
      ( ACCUM SUB-TOTAL BY {3} sj-adv.brutto-sum ) * 100 , 1 )
      else 0)  @ pcnt
      ACCUM SUB-TOTAL BY {3} sj-adv.netto-sum @ sj-adv.netto-sum
      with FRAME {4}{6} .
      DOWN STREAM PrnLibStream 1 with FRAME {4}{6} .
     end.
     when {&v-all} then do:
      DISPLAY STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      namebuf1 @ sj-goods.name
      prodbuf1 @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY  {3}  sj-adv.qnty @ sj-adv.qnty
&if "{6}" = "-t" &then
      ACCUM SUB-TOTAL BY  {3}  sj-adv.qnty-2 @ sj-adv.qnty-2
      ACCUM SUB-TOTAL BY  {3}  sj-adv.qnty-3 @ sj-adv.qnty-3
&endif
      sj-adv.price
      ACCUM SUB-TOTAL BY  {3}  sj-adv.brutto-sum @ sj-adv.brutto-sum
      ACCUM SUB-TOTAL BY  {3}  sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
&if "{3}" = "sj-adv.discnt" &then
      sj-adv.discnt
&endif
      ACCUM SUB-TOTAL BY  {3}  sj-adv.discnt-sum @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY  {3}  sj-adv.qnty) <> 0
      THEN
      round( ( ACCUM SUB-TOTAL BY  {3}  sj-adv.discnt-sum ) /
      ( ACCUM SUB-TOTAL BY  {3}  sj-adv.brutto-sum ) * 100, 1 )
      ELSE 0 ) @ pcnt
      ACCUM SUB-TOTAL BY  {3}  sj-adv.netto-sum @ sj-adv.netto-sum
      ACCUM SUB-TOTAL BY  {3}  sj-adv.netto-sum-r @ sj-adv.netto-sum-r
      with FRAME {5}{6} .
      DOWN STREAM PrnLibStream 1 with FRAME {5}{6} .
     end.
     END CASE .
     if ( namebuf2 <> "" ) OR ( prodbuf2 <> "" ) then
     CASE my-Set_val_type :
       when {&v-base} then  do:
        DISPLAY STREAM PrnLibStream
        namebuf2 @ sj-goods.name
        prodbuf2 @ sj-goods.prod-name
        with FRAME {4}{6} .
        DOWN STREAM PrnLibStream 1 with FRAME {4}{6} .
      end.
      when {&v-all} then do:
        DISPLAY STREAM PrnLibStream
        namebuf2 @ sj-goods.name
        prodbuf2 @ sj-goods.prod-name
        with FRAME {5}{6} .
        DOWN STREAM PrnLibStream 1 with FRAME {5}{6} .
      end.
    END CASE .
    OneLinePrinted = TRUE .
  end .
end.

  if last-of( {2} ) AND SHBySalers then do:
    v-salesman-name = '':U.
    if entry(2, {2}, {&delim-par}) <> string(0) then do:
      find first buf_saleman where
                buf_saleman.obj-type = {&prs}
            AND buf_saleman.obj-code = integer(entry(2, {2}, {&delim-par})) no-error .
      if not available buf_saleman then do:
        v-salesman-name = '':U.
      end.
      else do:
        v-salesman-name = buf_saleman.obj-name.
      end.
    end.
    CASE my-Set_val_type :
      when {&v-base} then  do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
&if "{6}" = "-t" &then
        sj-adv.qnty-2
        sj-adv.qnty-3
&endif
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME {4}{6} .
        DISPLAY STREAM PrnLibStream
&if "{2}" = "sj-goods.saleman" &then
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("ч-&1", ( ACCUM SUB-TOTAL BY {2} sj-adv.num-docs))
        else '':U)  @ sj-goods.b-code
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("стр-&1", (ACCUM SUB-TOTAL BY {2} sj-adv.num-lines))
        else '':U) @ sj-goods.artic
&endif
        string(  v-seller-cashier-1 + entry(1, {2} , {&delim-par}) )  @ sj-goods.name
        v-salesman-name @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY {2} sj-adv.qnty    @ sj-adv.qnty
&if "{6}" = "-t" &then
        ACCUM SUB-TOTAL BY {2} sj-adv.qnty-2    @ sj-adv.qnty-2
        ACCUM SUB-TOTAL BY {2} sj-adv.qnty-3    @ sj-adv.qnty-3
&endif
        ACCUM SUB-TOTAL BY {2} sj-adv.brutto-sum      @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY {2} sj-adv.discnt-sum      @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY {2} sj-adv.qnty) <> 0
        THEN
        round( ( ACCUM SUB-TOTAL BY {2} sj-adv.discnt-sum ) /
        ( ACCUM SUB-TOTAL BY {2} sj-adv.brutto-sum) * 100 , 1 )
        ELSE 0 ) @ pcnt
        ACCUM SUB-TOTAL BY {2} sj-adv.netto-sum   @ sj-adv.netto-sum
        with FRAME {4}{6} .
        DOWN STREAM PrnLibStream 1 with FRAME {4}{6} .
      end.
      when {&v-all} then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
&if "{6}" = "-t" &then
        sj-adv.qnty-2
        sj-adv.qnty-3
&endif
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME {5}{6} .
        DISPLAY STREAM PrnLibStream
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("ч-&1", (ACCUM SUB-TOTAL BY ({2}) sj-adv.num-docs))
        else '':U) @ sj-goods.b-code
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("стр-&1", (ACCUM SUB-TOTAL BY ({2}) sj-adv.num-lines))
        else '':U)  @ sj-goods.artic
        string(  v-seller-cashier-1 + entry(1, {2} , {&delim-par})) @ sj-goods.name
        v-salesman-name @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY {2} sj-adv.qnty    @ sj-adv.qnty
&if "{6}" = "-t" &then
        ACCUM SUB-TOTAL BY {2} sj-adv.qnty    @ sj-adv.qnty
&endif
        ACCUM SUB-TOTAL BY {2} sj-adv.brutto-sum  @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY {2} sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM SUB-TOTAL BY {2} sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY {2} sj-adv.qnty) <> 0
        THEN
        round( ( ACCUM SUB-TOTAL BY {2} sj-adv.discnt-sum ) /
                        ( ACCUM SUB-TOTAL BY {2} sj-adv.brutto-sum) * 100, 1 )
        ELSE 0 ) @ pcnt
        ACCUM SUB-TOTAL BY {2} sj-adv.netto-sum   @ sj-adv.netto-sum
        ACCUM SUB-TOTAL BY {2} sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME {5}{6} .
        DOWN STREAM PrnLibStream 1 with FRAME {5}{6} .
      end.
    END CASE .
    if not last(  {3}  ) then
      CASE my-Set_val_type :
        when {&v-base} then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
  &if "{6}" = "-t" &then
          sj-adv.qnty-2
          sj-adv.qnty-3
  &endif
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
        with FRAME {4}{6} .
        when {&v-all} then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
&if "{6}" = "-t" &then
          sj-adv.qnty-2
          sj-adv.qnty-3
&endif
          sj-adv.brutto-sum
          sj-adv.brutto-sum-r
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          sj-adv.netto-sum-r
          with FRAME {5}{6} .
      END CASE .
      OneLinePrinted = TRUE .
    end.

    { rep/e-sjobj.i {6} }

    if last(  {3}  ) then do:
      if v-curr-r-b = {&r-b-base} and my-Set_val_type = {&v-all} then  do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream Line {&Line-put-format-full} SKIP.
      end.
      else do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream Line {&Line-put-format-base}  SKIP.
      end.
      if ( line-counter(PrnLibStream) + 7 ) > page-size(PrnLibStream) then page stream PrnLibStream .
      CASE my-Set_val_type :
        when {&v-base} then do:
          DISPLAY STREAM PrnLibStream
          substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
          ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
&if "{6}" = "-t" &then
          ACCUM TOTAL sj-adv.qnty-2 @ sj-adv.qnty-2
          ACCUM TOTAL sj-adv.qnty-3 @ sj-adv.qnty-3
&endif
          ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
          ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
          (IF (ACCUM TOTAL sj-adv.qnty) <> 0
          THEN
          round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
          ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 )
          ELSE 0) @ pcnt
          ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
          with FRAME {4}{6} .
          DOWN STREAM PrnLibStream 1 with FRAME {4}{6} .
          DISPLAY STREAM PrnLibStream
          (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч")  @ sj-adv.qnty
&if "{6}" = "-t" &then
          (string(round((ACCUM TOTAL sj-adv.qnty-2) / v-num-chk, 2)) + "/ч") @ sj-adv.qnty-2
          (string(round((ACCUM TOTAL sj-adv.qnty-3) / v-num-chk, 2)) + "/ч") @ sj-adv.qnty-3
&endif
          with FRAME {4}{6} .
          DOWN STREAM PrnLibStream 1 with FRAME {4}{6} .
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
&if "{6}" = "-t" &then
          sj-adv.qnty
&endif
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          with FRAME {4}{6} .
        end.
        when {&v-all} then do:
        DISPLAY STREAM PrnLibStream
        substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
        ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
&if "{6}" = "-t" &then
        ACCUM TOTAL sj-adv.qnty-2 @ sj-adv.qnty-2
        ACCUM TOTAL sj-adv.qnty-3 @ sj-adv.qnty-3
&endif
        ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM TOTAL sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM TOTAL sj-adv.qnty) <> 0
        THEN
        round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
                      ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 )
        ELSE 0) @ pcnt
        ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
        ACCUM TOTAL sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME {5}{6} .
        DOWN STREAM PrnLibStream 1 with FRAME {5}{6} .
        DISPLAY STREAM PrnLibStream
        (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч")  @ sj-adv.qnty
&if "{6}" = "-t" &then
        (string(round((ACCUM TOTAL sj-adv.qnty-2) / v-num-chk, 2)) + "/ч") @ sj-adv.qnty-2
        (string(round((ACCUM TOTAL sj-adv.qnty-3) / v-num-chk, 2)) + "/ч") @ sj-adv.qnty-3
&endif
        with FRAME {5}{6} .
        DOWN STREAM PrnLibStream 1 with FRAME {5}{6} .
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
&if "{6}" = "-t" &then
        sj-adv.qnty-2
        sj-adv.qnty-3
&endif
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME {5}{6} .
      end.
    END CASE .

    if ObjsQnty = 1 then
    PUT STREAM PrnLibStream
    " " SKIP(1) space(10)
    "Директор ______________" format "X(50)"
    "Кассир ___________________" format "X(50)" SKIP .
  end.

/* $Workfile$ e n d */