/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-sjprod.i $
$Archive: rep/e-sjprod.i $

журнал продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/05/05
Author: Bakhtadze Natalya
Creation date: 12/05/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: e-sjprod.i $ $Revision: aea5316774be, 0, rls $".

&if "{5}" = "sj-adv.price" &then
  &if "{8}" = "-t" &then
&scoped-define   put-line-length-full 232
&scoped-define   put-line-length-base 198
  &else
&scoped-define   put-line-length-full 198
&scoped-define   put-line-length-base 138
  &endif

&else
  &if "{8}" = "-t" &then
&scoped-define   put-line-length-full 232
&scoped-define   put-line-length-base 198
  &else
&scoped-define   put-line-length-full 198
&scoped-define   put-line-length-base 198
  &endif
&endif


{ rep/e-sjacc.i {5} {8} }

&if "{8}" = "-t" &then
IF FIRST-OF({5}) then do:
      chk-gds-lines = 0.
end.
if sj-goods.twounit > 0 AND SHRS-by <> 0 then do:
  if not SHOnly_tot then do:
    namebuf1 = get-strokes(buffer sj-goods, 18, 21,
                           input-output namebuf1,
                           input-output namebuf2,
                           input-output prodbuf1,
                           input-output prodbuf2).
  end. /*if not only_tot*/
  CASE my-Set_Val_Type :
    when {&v-base} then  do:
      if not SHOnly_tot then
      DISPLAY STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      namebuf1 @ sj-goods.name
      prodbuf1 @ sj-goods.prod-name
      sj-adv.qnty
&if "{8}" = "-t" &then
      sj-adv.qnty-2
      sj-adv.qnty-3
&endif
      sj-adv.price
      sj-adv.brutto-sum
&if "{5}" = "sj-adv.discount" &then
      sj-adv.discnt
&endif
      sj-adv.discnt-sum
      (IF sj-adv.qnty <> 0 THEN
      round( sj-adv.discnt-sum / sj-adv.brutto-sum * 100 , 1 )   ELSE 0) @ pcnt
      sj-adv.netto-sum
      with FRAME {6}{8}.
      if not SHOnly_tot then
      DOWN STREAM PrnLibStream 1 with FRAME {6}{8} .
    end.
    when {&v-all} then do:
      if not SHOnly_tot then
      DISPLAY STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      namebuf1 @ sj-goods.name
      prodbuf1 @ sj-goods.prod-name
      sj-adv.qnty
&if "{8}" = "-t" &then
      sj-adv.qnty-2
      sj-adv.qnty-3
&endif
      sj-adv.price
      sj-adv.brutto-sum
      sj-adv.brutto-sum-r
&if "{5}" = "sj-adv.discnt" &then
      sj-adv.discnt
&endif
      sj-adv.discnt-sum
      (IF sj-adv.qnty <> 0 THEN
      round( sj-adv.discnt-sum / sj-adv.brutto-sum * 100 , 1 )   ELSE 0) @ pcnt
      sj-adv.netto-sum
      sj-adv.netto-sum-r
      with FRAME {7}{8} .
      if not SHOnly_tot then
      DOWN STREAM PrnLibStream 1 with FRAME {7}{8}.
    end.
  END CASE . /*my-Set_Val_Type*/
  if ( namebuf2 <> "" ) OR ( prodbuf2 <> "" ) then
  CASE my-Set_Val_Type :
    when {&v-base} then  do:
      if not SHOnly_tot then
      DISPLAY STREAM PrnLibStream
      namebuf2 @ sj-goods.name
      prodbuf2 @ sj-goods.prod-name
      with FRAME {6}{8} .
      if not SHOnly_tot then
      DOWN STREAM PrnLibStream 1 with FRAME {6}{8} .
    end.
    when {&v-all} then do:
      if not SHOnly_tot then
      DISPLAY STREAM PrnLibStream
      namebuf2 @ sj-goods.name
      prodbuf2 @ sj-goods.prod-name
      with FRAME {7}{8} .
      if not SHOnly_tot then
      DOWN STREAM PrnLibStream 1 with FRAME {7}{8} .
    end.
  END CASE . /*my-Set_Val_Type*/
  if LASt-OF(sj-goods.b-code) AND NOT SHOnly_tot then do:
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
        with FRAME {6}{8} .
        DOWN STREAM PrnLibStream 1 with FRAME {6}{8} .
      DISPLAY STREAM PrnLibStream
      sj-goods.b-code
      "Итого по бар-коду" @ sj-goods.artic
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.qnty @ sj-adv.qnty
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.qnty-2 @ sj-adv.qnty-2
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.qnty-3 @ sj-adv.qnty-3
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.brutto-sum @ sj-adv.brutto-sum
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.discnt-sum @ sj-adv.discnt-sum
      ACCUM TOTAL by ( Sj-goods.b-code ) sj-adv.netto-sum @ sj-adv.netto-sum
      with FRAME {6}{8}.
      DOWN STREAM PrnLibStream 1 with FRAME {6}{8} .
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
        with FRAME {6}{8} .
        DOWN STREAM PrnLibStream 1 with FRAME {6}{8} .
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
        with FRAME {7}{8} .
        DOWN STREAM PrnLibStream 1 with FRAME {7}{8} .
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
      with FRAME {7}{8} .
      DOWN STREAM PrnLibStream 1 with FRAME {7}{8}.
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
        with FRAME {7}{8} .
        DOWN STREAM PrnLibStream 1 with FRAME {7}{8} .
    end.
  END CASE . /*my-Set_Val_Type*/
 end. /*LASt-OF(sj-goods.b-code) AND SHOnly_tot */
end. /*if sj-goods.twounit > 0*/
&endif
/*if "{8}" = "-t"*/

if sj-goods.twounit = 0 then do:
  if last-of ({5}) then  do:
    if not SHOnly_tot then do:
      namebuf1 = get-strokes(buffer sj-goods, 18, 21,
                             input-output namebuf1,
                             input-output namebuf2,
                             input-output prodbuf1,
                             input-output prodbuf2).
    end. /*if not Only_tot*/
    CASE my-Set_Val_Type :
      when {&v-base} then  do:
        if not SHOnly_tot then
        DISPLAY STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        namebuf1 @ sj-goods.name
        prodbuf1 @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY  ( {5} )  sj-adv.qnty @ sj-adv.qnty
&if "{8}" = "-t" &then
        ACCUM SUB-TOTAL BY  ( {5} )  sj-adv.qnty-2 @ sj-adv.qnty-2
        ACCUM SUB-TOTAL BY  ( {5} )  sj-adv.qnty-3 @ sj-adv.qnty-3
&endif
        sj-adv.price
        ACCUM SUB-TOTAL BY  ( {5} )  sj-adv.brutto-sum @ sj-adv.brutto-sum
&if "{5}" = "sj-adv.discount" &then
        sj-adv.discnt
&endif
        ACCUM SUB-TOTAL BY  ( {5} )  sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY  ( {5} )  sj-adv.qnty ) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY  ( {5} )  sj-adv.discnt-sum ) /
        ( ACCUM SUB-TOTAL BY  ( {5} )  sj-adv.brutto-sum ) *
          100 , 1 )   ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY  ( {5} )  sj-adv.netto-sum @ sj-adv.netto-sum
        with FRAME {6}{8} .
        if not SHOnly_tot then
        DOWN STREAM PrnLibStream 1 with FRAME {6}{8} .
      end.
      when {&v-all} then do:
        if not SHOnly_tot then
        DISPLAY STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        namebuf1 @ sj-goods.name
        prodbuf1 @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY  ( {5}  )  sj-adv.qnty @ sj-adv.qnty
&if "{8}" = "-t" &then
        ACCUM SUB-TOTAL BY  ( {5}  )  sj-adv.qnty-2 @ sj-adv.qnty-2
        ACCUM SUB-TOTAL BY  ( {5}  )  sj-adv.qnty-3 @ sj-adv.qnty-3
&endif
        sj-adv.price
        ACCUM SUB-TOTAL BY  ( {5}  )  sj-adv.brutto-sum @
        sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY  ( {5}  )  sj-adv.brutto-sum-r @
        sj-adv.brutto-sum-r
&if "{5}" = "sj-adv.discount" &then
        sj-adv.discnt
&endif
        ACCUM SUB-TOTAL BY  ( {5} )  sj-adv.discnt-sum @
        sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY  ( {5}  )  sj-adv.qnty) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY  ( {5}  )  sj-adv.discnt-sum ) /
              ( ACCUM SUB-TOTAL BY  ( {5}  )  sj-adv.brutto-sum ) *
                      100 , 1 )   ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY  ( {5}  )  sj-adv.netto-sum @ sj-adv.netto-sum
        ACCUM SUB-TOTAL BY  ( {5}  )  sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME {7}{8} .
        if not SHOnly_tot then
        DOWN STREAM PrnLibStream 1 with FRAME {7}{8}.
      end.
    END CASE .
    if ( namebuf2 <> "" ) OR ( prodbuf2 <> "" ) then
    CASE my-Set_Val_Type :
      when {&v-base} then  do:
        if not SHOnly_tot then
          DISPLAY STREAM PrnLibStream
          namebuf2 @ sj-goods.name
          prodbuf2 @ sj-goods.prod-name
          with FRAME {6}{8} .
          if not SHOnly_tot then
          DOWN STREAM PrnLibStream 1 with FRAME {6}{8} .
        end.
      when {&v-all} then do:
        if not SHOnly_tot then
        DISPLAY STREAM PrnLibStream
        namebuf2 @ sj-goods.name
        prodbuf2 @ sj-goods.prod-name
        with FRAME {7}{8} .
        if not SHOnly_tot then
        DOWN STREAM PrnLibStream 1 with FRAME {7}{8} .
      end.
    END CASE .
  end. /*if last-of {5}*/
end. /*if sj-goods.twounit = 0*/

if SHBySalers AND last-of( sj-goods.saleman-chr ) then do:
  if entry(2, sj-goods.saleman-chr, {&delim-par}) <> string(0) then do:
    find first buf_saleman where
              buf_saleman.obj-type = {&prs}
          AND buf_saleman.obj-code = integer(entry(2, sj-goods.saleman-chr, {&delim-par})) no-error .
    if not available buf_saleman then do:
      v-salesman-name = '':U.
    end.
    else do:
      v-salesman-name = buf_saleman.obj-name.
    end.
  end.
  CASE my-Set_Val_Type :
    when {&v-base} then  do:
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
&if "{8}" = "-t" &then
      sj-adv.qnty-2
      sj-adv.qnty-3
&endif
      sj-adv.brutto-sum
      sj-adv.discnt-sum
      pcnt sj-adv.netto-sum
      with FRAME {6}{8} .
      DISPLAY STREAM PrnLibStream
      (if Shrs-seller-cashier = 'Cashier'
      then  substitute("ч-&1", (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.num-docs))
      else '':U)  @ sj-goods.b-code
      (if Shrs-seller-cashier = 'Cashier'
      then substitute("стр-&1", (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.num-lines))
      else '':U)  @ sj-goods.artic
      string( v-seller-cashier-1 + entry(1, sj-goods.saleman-chr, {&delim-par} ) ) @ sj-goods.name
      v-salesman-name @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty    @ sj-adv.qnty
&if "{8}" = "-t" &then
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty    @ sj-adv.qnty
&endif
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum      @ sj-adv.brutto-sum
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum      @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty) <> 0
      THEN
      round( ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum ) /
                  ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum) * 100 , 1 )
      ELSE 0) @ pcnt
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.netto-sum   @ sj-adv.netto-sum
      with FRAME {6}{8} .
      DOWN STREAM PrnLibStream 1 with FRAME {6}{8} .
    end.
    when {&v-all} then do:
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
&if "{8}" = "-t" &then
      sj-adv.qnty-2
      sj-adv.qnty-3
&endif
      sj-adv.brutto-sum
      sj-adv.brutto-sum-r
      sj-adv.discnt-sum
      pcnt
      sj-adv.netto-sum
      sj-adv.netto-sum-r
      with FRAME {7}{8} .
      DISPLAY STREAM PrnLibStream
      (if Shrs-seller-cashier = 'Cashier'
      then substitute("ч-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman-chr) sj-adv.num-docs))
      else '':U)  @ sj-goods.b-code
      (if Shrs-seller-cashier = 'Cashier'
      then substitute("стр-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman-chr) sj-adv.num-lines))
      else '':U) @ sj-goods.artic
      string( v-seller-cashier-1 + entry(1, sj-goods.saleman-chr, {&delim-par} ) ) @ sj-goods.name
      v-salesman-name @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty    @ sj-adv.qnty
&if "{8}" = "-t" &then
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty-2    @ sj-adv.qnty-2
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty-3    @ sj-adv.qnty-3
&endif
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum  @ sj-adv.brutto-sum
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum      @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty) <> 0 THEN
      round( ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum ) /
                  ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum) * 100 , 1 )
        ELSE 0) @ pcnt
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.netto-sum   @ sj-adv.netto-sum
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.netto-sum-r @ sj-adv.netto-sum-r
      with FRAME {7}{8} .
      DOWN STREAM PrnLibStream 1 with FRAME {7}{8} .
    end.
  END CASE .
  if not last(  {5}  ) then
  CASE my-set_Val_Type :
    when {&v-base} then
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
&if "{8}" = "-t" &then
      sj-adv.qnty-2
      sj-adv.qnty-3
&endif
      sj-adv.brutto-sum
      sj-adv.discnt-sum
      pcnt
      sj-adv.netto-sum
      with FRAME {6}{8} .
    when {&v-all} then
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
&if "{8}" = "-t" &then
      sj-adv.qnty-2
      sj-adv.qnty-3
&endif
      sj-adv.brutto-sum
      sj-adv.brutto-sum-r
      sj-adv.discnt-sum
      pcnt
      sj-adv.netto-sum
      sj-adv.netto-sum-r
      with FRAME {7}{8} .
    END CASE .
    OneLinePrinted = TRUE .
  end.

  if last-of( {2} ) AND {4} then do:
    CASE my-Set_Val_Type :
      when {&v-base} then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
&if "{8}" = "-t" &then
        sj-adv.qnty-2
        sj-adv.qnty-3
&endif
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME {6}{8} .
        DISPLAY STREAM PrnLibStream
&if string( "{2}" ) = "sj-goods.prod-name"   &then
        "Итого по произв-лю"
&else
        "Итого по группе"
&endif
                                                                          @ sj-goods.name
        ACCUM SUB-TOTAL BY {2} sj-adv.qnty    @ sj-adv.qnty
&if "{8}" = "-t" &then
        ACCUM SUB-TOTAL BY {2} sj-adv.qnty-2    @ sj-adv.qnty-2
        ACCUM SUB-TOTAL BY {2} sj-adv.qnty-3    @ sj-adv.qnty-3
&endif
        ACCUM SUB-TOTAL BY {2} sj-adv.brutto-sum      @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY {2} sj-adv.discnt-sum      @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY {2} sj-adv.qnty) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY {2} sj-adv.discnt-sum ) /
                    ( ACCUM SUB-TOTAL BY {2} sj-adv.brutto-sum) * 100 , 1 )
          ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY {2} sj-adv.netto-sum   @ sj-adv.netto-sum
        with FRAME {6}{8} .
        DOWN STREAM PrnLibStream 1 with FRAME {6}{8} .
      end.
      when {&v-all} then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME {7}{8} .
        DISPLAY STREAM PrnLibStream
&if string( "{2}" ) = "sj-goods.prod-name"   &then
        "Итого по произв-лю"
&else
        "Итого по группе"
&endif
                                                                          @ sj-goods.name
        ACCUM SUB-TOTAL BY {2} sj-adv.qnty    @ sj-adv.qnty
&if "{8}" = "-t" &then
        ACCUM SUB-TOTAL BY {2} sj-adv.qnty-2    @ sj-adv.qnty-2
        ACCUM SUB-TOTAL BY {2} sj-adv.qnty-3    @ sj-adv.qnty-3
&endif
        ACCUM SUB-TOTAL BY {2} sj-adv.brutto-sum  @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY {2} sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM SUB-TOTAL BY {2} sj-adv.discnt-sum      @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY {2} sj-adv.qnty) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY {2} sj-adv.discnt-sum ) /
                    ( ACCUM SUB-TOTAL BY {2} sj-adv.brutto-sum) * 100 , 1 )
          ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY {2} sj-adv.netto-sum   @ sj-adv.netto-sum
        ACCUM SUB-TOTAL BY {2} sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME {7}{8} .
        DOWN STREAM PrnLibStream 1 with FRAME {7}{8} .
      end.
    END CASE .
    if not last( {5} ) then
    CASE my-Set_Val_Type :
      when {&v-base} then
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
&if "{8}" = "-t" &then
        sj-adv.qnty-2
        sj-adv.qnty-3
&endif
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME {6}{8} .
      when {&v-all} then
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
&if "{8}" = "-t" &then
        sj-adv.qnty-2
        sj-adv.qnty-3
&endif
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME {7}{8} .
      END CASE .
      OneLinePrinted = TRUE .
    end.

  if last-of( {1} ) AND {3} then do:
    IF AllObjsTotalsBy  then do:
      FIND FIRST sj-tots WHERE
                 sj-tots.obj-attr = sj-goods.obj-attr AND
                sj-tots.grp-name = sj-goods.grp-name AND
                sj-tots.prod-name = sj-goods.prod-name No-ERROR.
        IF NOT avail sj-tots then do:
          create sj-tots.
          assign
          sj-tots.obj-attr = sj-goods.obj-attr
&if string( "{1}" ) = "sj-goods.prod-name"   &then
          sj-tots.prod-name = sj-goods.prod-name
&else
          sj-tots.grp-name = sj-goods.grp-name
&endif
          sj-tots.qnty = ACCUM SUB-TOTAL BY {1} sj-adv.qnty
          sj-tots.qnty-2 = ACCUM SUB-TOTAL BY {1} sj-adv.qnty-2
          sj-tots.qnty-3 = ACCUM SUB-TOTAL BY {1} sj-adv.qnty-3
          sj-tots.discnt-sum  = ACCUM SUB-TOTAL BY {1} sj-adv.discnt-sum
          sj-tots.brutto-sum  = ACCUM SUB-TOTAL BY {1} sj-adv.brutto-sum
          sj-tots.netto-sum  = ACCUM SUB-TOTAL BY {1} sj-adv.netto-sum.
          IF my-Set_Val_Type = {&v-all} then
          assign
          sj-tots.brutto-sum-r  = ACCUM SUB-TOTAL BY {1} sj-adv.brutto-sum-r
          sj-tots.netto-sum-r  = ACCUM SUB-TOTAL BY {1} sj-adv.netto-sum-r.
          ACCUMULATE
          sj-tots.discnt-sum ( TOTAL )
          sj-tots.brutto-sum  ( TOTAL )
          sj-tots.netto-sum  ( TOTAL ).
          IF my-set_val_type = {&v-all} then
          ACCUMULATE
          sj-tots.brutto-sum-r  ( TOTAL )
          sj-tots.netto-sum-r  ( TOTAL ).
        end.
      end. /*OBjs-qnty > 1*/
      CASE my-set_val_type :
        when {&v-base} then do:
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
&if "{8}" = "-t" &then
          sj-adv.qnty-2
          sj-adv.qnty-3
&endif
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          with FRAME {6}{8} .
          DISPLAY STREAM PrnLibStream
&if string( "{1}" ) = "sj-goods.prod-name"   &then
          "Итого по произв-лю"
&else
          "Итого по группе"
&endif
                                                                            @ sj-goods.name
          ACCUM SUB-TOTAL BY {1} sj-adv.qnty    @ sj-adv.qnty
&if "{8}" = "-t" &then
          ACCUM SUB-TOTAL BY {1} sj-adv.qnty-2    @ sj-adv.qnty-2
          ACCUM SUB-TOTAL BY {1} sj-adv.qnty-3    @ sj-adv.qnty-3
&endif
          ACCUM SUB-TOTAL BY {1} sj-adv.brutto-sum      @ sj-adv.brutto-sum
          ACCUM SUB-TOTAL BY {1} sj-adv.discnt-sum      @ sj-adv.discnt-sum
          (IF (ACCUM SUB-TOTAL BY {1} sj-adv.qnty) <> 0 THEN
          round( ( ACCUM SUB-TOTAL BY {1} sj-adv.discnt-sum ) /
                      ( ACCUM SUB-TOTAL BY {1} sj-adv.brutto-sum) * 100 , 1 )
            ELSE 0) @ pcnt
          ACCUM SUB-TOTAL BY {1} sj-adv.netto-sum   @ sj-adv.netto-sum
          with FRAME {6}{8} .
          DOWN STREAM PrnLibStream 1 with FRAME {6}{8} .
        end.
        when {&v-all} then do:
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
&if "{8}" = "-t" &then
          sj-adv.qnty-2
          sj-adv.qnty-3
&endif
          sj-adv.brutto-sum
          sj-adv.brutto-sum-r
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          sj-adv.netto-sum-r
          with FRAME {7}{8} .
          DISPLAY STREAM PrnLibStream
&if string( "{1}" ) = "sj-goods.prod-name"   &then
          "Итого по произв-лю"
&else
          "Итого по группе"
&endif
          @ sj-goods.name
          ACCUM SUB-TOTAL BY {1} sj-adv.qnty    @ sj-adv.qnty
&if "{8}" = "-t" &then
          ACCUM SUB-TOTAL BY {1} sj-adv.qnty-2    @ sj-adv.qnty-2
          ACCUM SUB-TOTAL BY {1} sj-adv.qnty-3    @ sj-adv.qnty-3
&endif
          ACCUM SUB-TOTAL BY {1} sj-adv.brutto-sum  @ sj-adv.brutto-sum
          ACCUM SUB-TOTAL BY {1} sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
          ACCUM SUB-TOTAL BY {1} sj-adv.discnt-sum      @ sj-adv.discnt-sum
          (IF (ACCUM SUB-TOTAL BY {1} sj-adv.qnty) <> 0 THEN
          round( ( ACCUM SUB-TOTAL BY {1} sj-adv.discnt-sum ) /
                 ( ACCUM SUB-TOTAL BY {1} sj-adv.brutto-sum) * 100 , 1 )
          ELSE 0) @ pcnt
          ACCUM SUB-TOTAL BY {1} sj-adv.netto-sum   @ sj-adv.netto-sum
          ACCUM SUB-TOTAL BY {1} sj-adv.netto-sum-r @ sj-adv.netto-sum-r
          with FRAME {7}{8} .
          DOWN STREAM PrnLibStream 1 with FRAME {7}{8} .
        end.
      END CASE .
      if not last(  {5}   ) then
      CASE my-set_val_type :
        when {&v-base} then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
&if "{8}" = "-t" &then
          sj-adv.qnty-2
          sj-adv.qnty-3
&endif
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          with FRAME {6}{8} .
        when {&v-all} then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
&if "{8}" = "-t" &then
          sj-adv.qnty-2
          sj-adv.qnty-3
&endif
          sj-adv.brutto-sum
          sj-adv.brutto-sum-r
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          sj-adv.netto-sum-r
          with FRAME {7}{8} .
      END CASE .
      OneLinePrinted = TRUE .
    end.
    { rep/e-sjobj.i {8}}

    if last( {5}    ) then do:
      IF AllObjsTotalsBy then do:
        PUT STREAM PrnLibStream string( "   ПО ВСЕМ ОБЪЕКТАМ " +
&if string( "{1}" ) = "sj-goods.prod-name"   &then
           "ПО ПРОИЗВОДИТЕЛЯМ:"
&else
           "ПО ГРУППАМ:"
&endif

           )
        format "x(120)" SKIP .
&if  string( "{1}" ) = "sj-goods.prod-name"  &then
        for each sj-tots NO-LOCK BREAK BY sj-tots.prod-name:
          ACCUMULATE
          sj-tots.qnty   (TOTAL BY sj-tots.prod-name)
          sj-tots.qnty-2   (TOTAL BY sj-tots.prod-name)
          sj-tots.qnty-3   (TOTAL BY sj-tots.prod-name)
          sj-tots.brutto-sum  (TOTAL BY sj-tots.prod-name)
          sj-tots.discnt-sum  (TOTAL BY sj-tots.prod-name)
          sj-tots.netto-sum   (TOTAL BY sj-tots.prod-name).
          if my-set_val_type = {&v-all}  then
          ACCUMULATE
          sj-tots.brutto-sum-r (TOTAL BY sj-tots.prod-name)
          sj-tots.netto-sum-r (TOTAL BY sj-tots.prod-name).
          IF LAST-OF(sj-tots.prod-name) then do:
            CASE my-set_val_type :
              when {&v-base} then do:
                UNDERLINE STREAM PrnLibStream
                sj-goods.b-code
                sj-goods.artic
                sj-goods.name
                sj-adv.qnty
&if "{8}" = "-t" &then
                sj-adv.qnty-2
                sj-adv.qnty-3
&endif
                sj-adv.brutto-sum
                sj-adv.discnt-sum
                pcnt
                sj-adv.netto-sum
                with FRAME {6}{8} .
                DISPLAY STREAM PrnLibStream
                sj-tots.prod-name  @ sj-goods.name
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.qnty    @ sj-adv.qnty
&if "{8}" = "-t" &then
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.qnty-2    @ sj-adv.qnty-2
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.qnty-3    @ sj-adv.qnty-3
&endif
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.brutto-sum      @ sj-adv.brutto-sum
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.discnt-sum      @ sj-adv.discnt-sum
                round( ( ACCUM TOTAL BY sj-tots.prod-name sj-tots.discnt-sum ) /
                       ( ACCUM TOTAL BY sj-tots.prod-name sj-tots.brutto-sum) * 100 , 1 )
                                @ pcnt
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.netto-sum   @ sj-adv.netto-sum
                with FRAME {6}{8} .
                DOWN STREAM PrnLibStream 1 with FRAME {6}{8} .
              end.
              when {&v-all} then do:
                UNDERLINE STREAM PrnLibStream
                sj-goods.b-code
                sj-goods.artic
                sj-goods.name
                sj-adv.qnty
&if "{8}" = "-t" &then
                sj-adv.qnty-2
                sj-adv.qnty-3
&endif
                sj-adv.brutto-sum
                sj-adv.brutto-sum-r
                sj-adv.discnt-sum
                pcnt
                sj-adv.netto-sum
                sj-adv.netto-sum-r
                with FRAME {7}{8} .
                DISPLAY STREAM PrnLibStream
                sj-tots.prod-name @ sj-goods.name
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.qnty    @ sj-adv.qnty
&if "{8}" = "-t" &then
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.qnty    @ sj-adv.qnty
&endif
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.brutto-sum  @ sj-adv.brutto-sum
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.brutto-sum-r @ sj-adv.brutto-sum-r
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.discnt-sum      @ sj-adv.discnt-sum
                round( ( ACCUM TOTAL BY sj-tots.prod-name sj-tots.discnt-sum ) /
                            ( ACCUM TOTAL BY sj-tots.prod-name sj-tots.brutto-sum) * 100 , 1 )
                                @ pcnt
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.netto-sum   @ sj-adv.netto-sum
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.netto-sum-r @ sj-adv.netto-sum-r
                with FRAME {7}{8} .
                DOWN STREAM PrnLibStream 1 with FRAME {7}{8} .
              end.
            END CASE .
          end. /*if last-of */
        END. /*for each sj-tots*/
&else                                    /*string( "{1}" ) = "sj-goods.grp-name"*/
        for each sj-tots NO-LOCK BREAK BY sj-tots.grp-name:
          ACCUMULATE
          sj-tots.qnty   (TOTAL BY sj-tots.grp-name)
          sj-tots.qnty-2   (TOTAL BY sj-tots.grp-name)
          sj-tots.qnty-3   (TOTAL BY sj-tots.grp-name)
          sj-tots.brutto-sum  (TOTAL BY sj-tots.grp-name)
          sj-tots.discnt-sum  (TOTAL BY sj-tots.grp-name)
          sj-tots.netto-sum   (TOTAL BY sj-tots.grp-name).
          if my-set_val_type = {&v-all}  then
          ACCUMULATE
          sj-tots.brutto-sum-r (TOTAL BY sj-tots.grp-name)
          sj-tots.netto-sum-r (TOTAL BY sj-tots.grp-name).
          IF LAST-OF(sj-tots.grp-name) then do:
          CASE my-set_val_type :
            when {&v-base} then do:
              UNDERLINE STREAM PrnLibStream
              sj-goods.b-code
              sj-goods.artic
              sj-goods.name
              sj-adv.qnty
&if "{8}" = "-t" &then
              sj-adv.qnty-2
              sj-adv.qnty-3
&endif
              sj-adv.brutto-sum
              sj-adv.discnt-sum
              pcnt
              sj-adv.netto-sum
              with FRAME {6}{8} .
              DISPLAY STREAM PrnLibStream
              get-grp-name(sj-tots.grp-name)  @ sj-goods.name
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.qnty    @ sj-adv.qnty
&if "{8}" = "-t" &then
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.qnty-2    @ sj-adv.qnty-2
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.qnty-3    @ sj-adv.qnty-3
&endif
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.brutto-sum      @ sj-adv.brutto-sum
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.discnt-sum      @ sj-adv.discnt-sum
              round( ( ACCUM TOTAL BY sj-tots.grp-name sj-tots.discnt-sum ) /
                     ( ACCUM TOTAL BY sj-tots.grp-name sj-tots.brutto-sum) * 100 , 1 )
                              @ pcnt
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.netto-sum   @ sj-adv.netto-sum
              with FRAME {6}{8} .
              DOWN STREAM PrnLibStream 1 with FRAME {6}{8} .
            end.
            when {&v-all} then do:
              UNDERLINE STREAM PrnLibStream
              sj-goods.b-code
              sj-goods.artic
              sj-goods.name
              sj-adv.qnty
&if "{8}" = "-t" &then
              sj-adv.qnty-2
              sj-adv.qnty-3
&endif
              sj-adv.brutto-sum
              sj-adv.brutto-sum-r
              sj-adv.discnt-sum
              pcnt
              sj-adv.netto-sum
              sj-adv.netto-sum-r
              with FRAME {7}{8} .
              DISPLAY STREAM PrnLibStream
              get-grp-name(sj-tots.grp-name) @ sj-goods.name
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.qnty    @ sj-adv.qnty
&if "{8}" = "-t" &then
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.qnty-2    @ sj-adv.qnty-2
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.qnty-3    @ sj-adv.qnty-3
&endif
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.brutto-sum  @ sj-adv.brutto-sum
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.brutto-sum-r @ sj-adv.brutto-sum-r
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.discnt-sum      @ sj-adv.discnt-sum
              round( ( ACCUM TOTAL BY sj-tots.grp-name sj-tots.discnt-sum ) /
                          ( ACCUM TOTAL BY sj-tots.grp-name sj-tots.brutto-sum) * 100 , 1 )
                              @ pcnt
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.netto-sum   @ sj-adv.netto-sum
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.netto-sum-r @ sj-adv.netto-sum-r
              with FRAME {7}{8} .
              DOWN STREAM PrnLibStream 1 with FRAME {7}{8} .
            end.
          END CASE .
        end. /*if last-of */
      END. /*for each sj-tots*/
&endif
    end. /*Objs-qnty > 1*/
    if ( line-counter(PrnLibStream) + 7 ) > page-size(PrnLibStream) then page stream PrnLibStream.
    CASE my-set_val_type :
      when {&v-base} then do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream  LINE {&line-put-format-base} SKIP.
        DISPLAY STREAM PrnLibStream
        substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
        ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
&if "{8}" = "-t" &then
        ACCUM TOTAL sj-adv.qnty-2 @ sj-adv.qnty-2
        ACCUM TOTAL sj-adv.qnty-3 @ sj-adv.qnty-3
&endif
        ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM TOTAL sj-adv.qnty) <> 0 THEN
        round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
                    ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 ) ELSE 0) @ pcnt
        ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
            with FRAME {6}{8} .
        DOWN STREAM PrnLibStream 1 with FRAME {6}{8} .
        DISPLAY STREAM PrnLibStream
        (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч")  @ sj-adv.qnty
&if "{8}" = "-t" &then
        (string(round((ACCUM TOTAL sj-adv.qnty-2) / v-num-chk, 2)) + "/ч") @ sj-adv.qnty-2
        (string(round((ACCUM TOTAL sj-adv.qnty-3) / v-num-chk, 2)) + "/ч") @ sj-adv.qnty-3

&endif
        with FRAME {6}{8} .
        DOWN STREAM PrnLibStream 1 with FRAME {6}{8} .
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
&if "{8}" = "-t" &then
        sj-adv.qnty-2
        sj-adv.qnty-3
&endif
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME {6}{8} .
      end.
      when {&v-all} then do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream LINE {&line-put-format-full} SKIP.
        DISPLAY STREAM PrnLibStream
        substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
        ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
&if "{8}" = "-t" &then
        ACCUM TOTAL sj-adv.qnty-2 @ sj-adv.qnty-2
        ACCUM TOTAL sj-adv.qnty-3 @ sj-adv.qnty-3
&endif
        ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM TOTAL sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM TOTAL sj-adv.qnty) <> 0 THEN
        round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
                    ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 ) ELSE 0) @ pcnt
        ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
        ACCUM TOTAL sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME {7}{8} .
        DOWN STREAM PrnLibStream 1 with FRAME {7}{8} .
        DISPLAY STREAM PrnLibStream
        (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч") @ sj-adv.qnty
&if "{8}" = "-t" &then
        (string(round((ACCUM TOTAL sj-adv.qnty-2) / v-num-chk, 2)) + "/ч") @ sj-adv.qnty-2
        (string(round((ACCUM TOTAL sj-adv.qnty-3) / v-num-chk, 2)) + "/ч") @ sj-adv.qnty-3
&endif
        with FRAME {7}{8} .
        DOWN STREAM PrnLibStream 1 with FRAME {7}{8} .
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
&if "{8}" = "-t" &then
        sj-adv.qnty-2
        sj-adv.qnty-3
&endif
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME {7}{8} .
      end.
    END CASE .
    if ObjsQnty = 1 then
    PUT STREAM PrnLibStream
    " " SKIP(1) space(10)
    "Директор ______________" format "X(50)"
    "Кассир ___________________" format "X(50)" SKIP .
  end.
/* $Workfile: e-sjprod.i $ e n d */