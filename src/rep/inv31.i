/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

тело для inv-3

Автор: Демин Алексей Сергеевич
Дата создания: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

  assign Lines_Counter = Lines_Counter + 1  .

  if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.

  if line-counter( Out-Stream ) < Tmp_Counter then
    assign PgNPP = 0  PgQnty = 0 PgSum = 0 PgQnty-b = 0 PgSum-b  = 0  PgQnty-v = 0  PgQnty-b-v = 0 .

  assign
    Tmp_Counter  = line-counter( Out-Stream )
    PgNPP        = PgNPP      + 1
    PgQnty       = PgQnty     + temp-str.a-qnty
    PgQnty-b     = PgQnty-b   + temp-str.b-qnty
    PgQnty-v     = PgQnty-v   + temp-str.a-qnty1
    PgQnty-b-v   = PgQnty-b-v + temp-str.b-qnty1
    PgSum        = PgSum      + temp-str.a-stoim
    PgSum-b      = PgSum-b    + temp-str.b-stoim
    num-ln = num-ln + 1
    sum-a-qnty    = sum-a-qnty    + temp-str.a-qnty
    sum-b-qnty    = sum-b-qnty    + temp-str.b-qnty
    sum-a-qnty1   = sum-a-qnty1   + temp-str.a-qnty1
    sum-b-qnty1   = sum-b-qnty1   + temp-str.b-qnty1
    sum-a-stoim   = sum-a-stoim   + temp-str.a-stoim
    sum-b-stoim   = sum-b-stoim   + temp-str.b-stoim
    sum-ubl       = sum-ubl       + temp-str.ubl
    sum1-a-qnty   = sum1-a-qnty   + temp-str.a-qnty
    sum1-b-qnty   = sum1-b-qnty   + temp-str.b-qnty
    sum1-a-qnty1  = sum1-a-qnty1  + temp-str.a-qnty1
    sum1-b-qnty1  = sum1-b-qnty1  + temp-str.b-qnty1
    sum1-a-stoim  = sum1-a-stoim  + temp-str.a-stoim
    sum1-b-stoim  = sum1-b-stoim  + temp-str.b-stoim
    sum1-ubl      = sum1-ubl      + temp-str.ubl
    sum2-a-qnty   = sum2-a-qnty   + temp-str.a-qnty
    sum2-b-qnty   = sum2-b-qnty   + temp-str.b-qnty
    sum2-a-qnty1  = sum2-a-qnty1  + temp-str.a-qnty1
    sum2-b-qnty1  = sum2-b-qnty1  + temp-str.b-qnty1
    sum2-a-stoim  = sum2-a-stoim  + temp-str.a-stoim
    sum2-b-stoim  = sum2-b-stoim  + temp-str.b-stoim
    sum2-ubl      = sum2-ubl      + temp-str.ubl
  .

  /* полное название на несколько строк */
  FullNameGds = temp-str.gds-name .
  gds-str1 = breakstr(FullNameGds, {&gds-len}, input-output  gds-str1, input-output gds-str2).
  assign j = 0.
  DO WHILE gds-str2 <> "" :
    assign gds-str = gds-str2.
    gds-str1 = breakstr(gds-str, {&gds-len}, input-output gds-str1, input-output gds-str2).
    assign j = j + 1.
  END. /* DO WHILE ... */
  if line-counter( Out-Stream ) + j > page-size( Out-Stream ) then  PAGE STREAM Out-Stream.

  gds-str1 = breakstr(FullNameGds, {&gds-len}, input-output  gds-str1, input-output gds-str2).
if temp-str.aa-qnty <> 0 then do:
    if p-grp = "no" then do:
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
/*    &if "{1}" = "invent"                  &then sym8   temp-str.price-befor &endif*/
/*    &if "{1}" = "invent-gold"             &then sym8 sym11   temp-str.price-befor temp-str.bb-price @ temp-str.Price-after  &endif*/
    &if "{1}" = "sl" or "{1}" = "sl-gold" &then sym14 temp-str.UBL                &endif                                          
    &if "{1}" = "sl-gold"                 &then sym8 sym11  sym15 UBL-v           &endif                                          
/*    &if "{1}" = "invent-gold"             &then temp-str.a-qnty1 temp-str.b-qnty1 &endif                                          */
    &if "{1}" = "sl-gold"                 &then temp-str.a-qnty1 temp-str.b-qnty1 &endif                                          
    &if "{1}" <> "sl" &then sym7     temp-str.price-befor &endif
    &if "{1}" <> "sl" &then sym8     temp-str.b-qnty @ temp-str.a-qnty &endif
/*    sym9     temp-str.bb-stoim @ temp-str.a-stoim*/
    sym9    temp-str.b-qnty
/*    sym12    temp-str.b-stoim*/
    sym10  with FRAME {1}.
  DOWN stream Out-Stream 1 with FRAME {1} .

  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
/*    &if "{1}" = "invent"                  &then sym8   0.00 @ temp-str.price-befor  &endif*/
/*    &if "{1}" = "invent-gold"             &then sym8 sym11   0.00 @ temp-str.price-befor temp-str.price @ temp-str.Price-after  &endif*/
    &if "{1}" = "sl" or "{1}" = "sl-gold" &then sym14 temp-str.UBL                &endif                                              
    &if "{1}" = "sl-gold"                 &then sym8 sym11  sym15 UBL-v           &endif                                              
/*    &if "{1}" = "invent-gold"             &then temp-str.a-qnty1 temp-str.b-qnty1 &endif                                              */
    &if "{1}" = "sl-gold"                 &then temp-str.a-qnty1 temp-str.b-qnty1 &endif                                              
    &if "{1}" <> "sl" &then sym7     temp-str.price-befor &endif
    &if "{1}" <> "sl" &then sym8     temp-str.aa-qnty @ temp-str.a-qnty &endif
/*    sym9     temp-str.aa-stoim @ temp-str.a-stoim*/
    sym9    0.00 @ temp-str.b-qnty
/*    sym12    0.00 @ temp-str.b-stoim*/
    sym10  with FRAME {1}.
  DOWN stream Out-Stream 1 with FRAME {1} .
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-write-line-data in this-procedure (
            input num-ln                          /* p-num*/
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )      /* p-name*/
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )  /* p-gdscode*/
            , input temp-str.unit-base              /* p-EI*/
            , input temp-str.OKEI                   /* p-OKEI*/
            , input temp-str.bb-price               /* p-price*/
            , input temp-str.b-qnty                 /* p-qntyFact*/
            , input temp-str.bb-stoim                /* p-sumFact*/
            , input temp-str.b-qnty                 /* p-qntyBuh*/
            , input temp-str.b-stoim                /* p-sumBuh*/
        ).
        run inv3xl-write-line-data in this-procedure (
            input num-ln                          /* p-num*/
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )      /* p-name*/
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )  /* p-gdscode*/
            , input temp-str.unit-base              /* p-EI*/
            , input temp-str.OKEI                   /* p-OKEI*/
            , input temp-str.Price                  /* p-price*/
            , input temp-str.aa-qnty                 /* p-qntyFact*/
            , input temp-str.aa-stoim                /* p-sumFact*/
            , input 0.00                             /* p-qntyBuh*/
            , input 0.00                            /* p-sumBuh*/
        ).
    end.
  if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then DO:
    DO WHILE gds-str2 <> "" :
      assign gds-str = gds-str2.
      gds-str1 = breakstr(gds-str, {&gds-len}, input-output gds-str1, input-output gds-str2).
      DISPLAY STREAM Out-Stream gds-str1 @ temp-str.gds-name sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym10  with frame {1} .
      DOWN STREAM Out-Stream 1 with FRAME {1} .
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0               /* p-num*/
                , input gds-str1        /* p-name*/
                , input "":U            /* p-gdscode*/
                , input "":U            /* p-EI*/
                , input "":U            /* p-OKEI*/
                , input "":U            /* p-price*/
                , input "":U            /* p-qntyFact*/
                , input "":U            /* p-sumFact*/
                , input "":U            /* p-qntyBuh*/
                , input "":U            /* p-sumBuh*/
            ).
        end.
    END. /* DO WHILE ... */
  END.

/*-------------------------------------------------------ПО ПРИЗНАКАМ----------------------------------------------*/
  if PrintScale and temp-str.empty-scale = no THEN DO :
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
        and buf_gds-dtl.artic     = temp-str.artic
        and buf_gds-dtl.prod-type = temp-str.prod-type
        and buf_gds-dtl.prod-code = temp-str.prod-code
      :
      { gbl/gdsbcode.i  temp-str.gds-code  buf_gds-dtl.prt-code  b-code  no-error }
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip  "Код товара" temp-str.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip
        view-as alert-box error .
      end.
      find first buf_gds-prt where buf_gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .

      assign qnty = buf_gds-dtl.doc-qnty .
      if not CostPrice then do:
        if PrintRubl then assign sum = buf_gds-dtl.price-rubl .
        else              assign sum = buf_gds-dtl.price-base .
      end.
      else assign sum = if temp-str.a-stoim <> 0  or temp-str.a-qnty <> 0 then temp-str.a-stoim / temp-str.a-qnty else temp-str.b-stoim / temp-str.b-qnty .
      if qnty >= 0 then do: /* излишек */
        display stream Out-Stream
          sym1     sym2     sym3     ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
/*          &if "{1}" = "sl-gold" &then sym8 sym11 sym15 UBL-v  &endif*/
          sym7     qnty @ temp-str.a-qnty
/*          sym9*/
/*          sym9    sum * qnty @ temp-str.a-stoim*/
          sym10
        with FRAME {1}.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0                                   /* p-num*/
                , input ( "  /":U + buf_gds-prt.f-name )    /* p-name*/
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )           /* p-gdscode*/
                , input "":U                                /* p-EI*/
                , input "":U                                /* p-OKEI*/
                , input "":U                                /* p-price*/
                , input string( qnty )                      /* p-qntyFact*/
                , input string( sum * qnty )                /* p-sumFact*/
                , input "":U                                /* p-qntyBuh*/
                , input "":U                                /* p-sumBuh*/
            ).
        end.
      end.
      else do:
        assign qnty = - qnty .
        display stream Out-Stream
          sym1     sym2     sym3  ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
/*          &if "{1}" = "sl-gold" &then sym8 sym11 sym15 UBL-v &endif*/
          sym7     qnty @ temp-str.b-qnty
/*          sym9*/
/*          sym9    sum * qnty @ temp-str.b-stoim*/
               sym10
        with FRAME {1}.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0                                   /* p-num*/
                , input ( '  /':U + buf_gds-prt.f-name )    /* p-name*/
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )           /* p-gdscode*/
                , input "":U                                /* p-EI*/
                , input "":U                                /* p-OKEI*/
                , input "":U                                /* p-price*/
                , input "":U                                /* p-qntyFact*/
                , input "":U                                /* p-sumFact*/
                , input string( qnty )                      /* p-qntyBuh*/
                , input string( sum * qnty )                /* p-sumBuh*/
            ).
        end.
      end.
      DOWN stream Out-Stream 1 with FRAME {1} .
    end.
  end.

  if print-graft = false THEN  Put stream Out-Stream LineBuf format "{2}" SKIP.
end.
    
end.
else do:    
if p-grp = "no" then do:
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    &if "{1}" = "sl"                 &then sym7  temp-str.a-qnty &endif  
/*    &if "{1}" = "invent"                  &then sym8    temp-str.price-befor   &endif*/
/*    &if "{1}" = "invent-gold"             &then sym8 sym11   temp-str.price-befor temp-str.Price-after  &endif*/
    &if "{1}" = "sl" or "{1}" = "sl-gold" &then sym14 temp-str.UBL                &endif                      
    &if "{1}" = "sl-gold"                 &then sym8 sym11  sym15 UBL-v           &endif                      
/*    &if "{1}" = "invent-gold"             &then temp-str.a-qnty1 temp-str.b-qnty1 &endif                      */
    &if "{1}" = "sl-gold"                 &then temp-str.a-qnty1 temp-str.b-qnty1 &endif                      
    &if "{1}" <> "sl" &then sym7    temp-str.price-befor &endif
    &if "{1}" <> "sl" &then sym8    temp-str.a-qnty &endif
    sym9     temp-str.a-stoim
    sym9    temp-str.b-qnty
    sym12    temp-str.b-stoim
    sym10  with FRAME {1}.
  DOWN stream Out-Stream 1 with FRAME {1} .
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-write-line-data in this-procedure (
            input num-ln                          /* p-num*/
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )      /* p-name*/
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )  /* p-gdscode*/
            , input temp-str.unit-base              /* p-EI*/
            , input temp-str.OKEI                   /* p-OKEI*/
            , input temp-str.Price-after            /* p-price*/
            , input temp-str.a-qnty                 /* p-qntyFact*/
            , input temp-str.a-stoim                /* p-sumFact*/
            , input temp-str.b-qnty                 /* p-qntyBuh*/
            , input temp-str.b-stoim                /* p-sumBuh*/
        ).
    end.
  if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then DO:
    DO WHILE gds-str2 <> "" :
      assign gds-str = gds-str2.
      gds-str1 = breakstr(gds-str, {&gds-len}, input-output gds-str1, input-output gds-str2).
      DISPLAY STREAM Out-Stream gds-str1 @ temp-str.gds-name sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym10  with frame {1} .
      DOWN STREAM Out-Stream 1 with FRAME {1} .
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0               /* p-num*/
                , input gds-str1        /* p-name*/
                , input "":U            /* p-gdscode*/
                , input "":U            /* p-EI*/
                , input "":U            /* p-OKEI*/
                , input "":U            /* p-price*/
                , input "":U            /* p-qntyFact*/
                , input "":U            /* p-sumFact*/
                , input "":U            /* p-qntyBuh*/
                , input "":U            /* p-sumBuh*/
            ).
        end.
    END. /* DO WHILE ... */
  END.

/*-------------------------------------------------------ПО ПРИЗНАКАМ----------------------------------------------*/
  if PrintScale and temp-str.empty-scale = no THEN DO :
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
        and buf_gds-dtl.artic     = temp-str.artic
        and buf_gds-dtl.prod-type = temp-str.prod-type
        and buf_gds-dtl.prod-code = temp-str.prod-code
      :
      { gbl/gdsbcode.i  temp-str.gds-code  buf_gds-dtl.prt-code  b-code  no-error }
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip  "Код товара" temp-str.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip
        view-as alert-box error .
      end.
      find first buf_gds-prt where buf_gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .

      assign qnty = buf_gds-dtl.doc-qnty .
      if not CostPrice then do:
        if PrintRubl then assign sum = buf_gds-dtl.price-rubl .
        else              assign sum = buf_gds-dtl.price-base .
      end.
      else assign sum = if temp-str.a-stoim <> 0  or temp-str.a-qnty <> 0 then temp-str.a-stoim / temp-str.a-qnty else temp-str.b-stoim / temp-str.b-qnty .
      if qnty >= 0 then do: /* излишек */
        display stream Out-Stream
          sym1     sym2     sym3     ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
/*          &if "{1}" = "sl-gold" &then sym8 sym11 sym15 UBL-v  &endif*/
          sym7     qnty @ temp-str.a-qnty
/*          sym9    sum * qnty @ temp-str.a-stoim*/
              sym10
        with FRAME {1}.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0                                   /* p-num*/
                , input ( "  /":U + buf_gds-prt.f-name )    /* p-name*/
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )           /* p-gdscode*/
                , input "":U                                /* p-EI*/
                , input "":U                                /* p-OKEI*/
                , input "":U                                /* p-price*/
                , input string( qnty )                      /* p-qntyFact*/
                , input string( sum * qnty )                /* p-sumFact*/
                , input "":U                                /* p-qntyBuh*/
                , input "":U                                /* p-sumBuh*/
            ).
        end.
      end.
      else do:
        assign qnty = - qnty .
        display stream Out-Stream
          sym1     sym2     sym3  ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
/*          &if "{1}" = "sl-gold" &then sym8 sym11 sym15 UBL-v &endif*/
          sym7     qnty @ temp-str.b-qnty
/*          sym9*/
/*          sym9    sum * qnty @ temp-str.b-stoim*/
               sym10
        with FRAME {1}.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0                                   /* p-num*/
                , input ( '  /':U + buf_gds-prt.f-name )    /* p-name*/
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )           /* p-gdscode*/
                , input "":U                                /* p-EI*/
                , input "":U                                /* p-OKEI*/
                , input "":U                                /* p-price*/
                , input "":U                                /* p-qntyFact*/
                , input "":U                                /* p-sumFact*/
                , input string( qnty )                      /* p-qntyBuh*/
                , input string( sum * qnty )                /* p-sumBuh*/
            ).
        end.
      end.
      DOWN stream Out-Stream 1 with FRAME {1} .
    end.
  end.

  if print-graft = false THEN  Put stream Out-Stream LineBuf format "{2}" SKIP.
end.
end.
/* $Workfile$   E n d */