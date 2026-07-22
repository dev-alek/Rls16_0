/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Prodgrprpoc ‰Îˇ ÊÛÌ‡Î‡ ÔÓ‰‡Ê

¿‚ÚÓ: ¡‡ıÚ‡‰ÁÂ Õ‡Ú‡Î¸ˇ ¬ËÍÚÓÓ‚Ì‡
ƒ‡Ú‡ ÒÓÁ‰‡ÌËˇ: 12/05/05
Author: Bakhtadze Natalya
Creation date: 12/05/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if SHRS-Sort = "Article":U then do:
  FOR EACH sj-goods NO-LOCK,
    EACH sj-adv NO-LOCK WHERE
         sj-adv.obj-attr = sj-goods.obj-attr AND
         sj-adv.b-code = sj-goods.b-code AND
         sj-adv.saleman-chr = sj-goods.saleman-chr
    BREAK BY sj-goods.obj-attr
          BY sj-goods.prod-name
          BY sj-goods.grp-name
          BY sj-goods.saleman-chr
          BY sj-goods.artic
          BY sj-goods.b-code
          BY sj-adv.price
&if "{1}" = "sj-adv.discnt" &then
          BY sj-adv.discnt
&endif
          :
  { rep/e-sjobs.i {2} {3} {4}}
  if first-of( sj-goods.prod-name ) then do:
    if v-curr-r-b = {&r-b-base} then do:
      if my-set_Val_Type = {&v-base} then do:
        if frame {2}{4}:line = 0 then do:
           down 1 stream PrnLibStream
           with frame {2}{4} .
        end.
      end.
      else do:
        if frame {3}{4}:line = 0 then do:
           down 1 stream PrnLibStream
           with frame {3}{4} .
        end.
      end.
      PUT STREAM PrnLibStream string( "   œ–Œ»«¬Œƒ»“≈À‹ : " + sj-goods.prod-name ) format "x(120)" SKIP.
      if my-set_Val_Type = {&v-base} then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.artic
        sj-goods.name
        with FRAME {2}{4} .
      end.
      else do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.artic
        sj-goods.name
        with FRAME {3}{4} .
       end.
     end.
     else do:
        if frame {2}{4}:line = 0 then do:
           down 1 stream PrnLibStream
           with frame {2}{4} .
        end.
        PUT STREAM PrnLibStream string( "   œ–Œ»«¬Œƒ»“≈À‹ : " + sj-goods.prod-name ) format "x(120)" SKIP.
        UNDERLINE STREAM PrnLibStream
        sj-goods.artic
        sj-goods.name
       with FRAME {2}{4} .
     end.
   end. /*if first-of( sj-goods.prod-name ) then do:*/
   if first-of( sj-goods.grp-name ) then do:
     if grouptot_flag OR NOT SHOnly_tot then do:
       if v-curr-r-b = {&r-b-base} then do:
          if my-set_Val_Type = {&v-base} then do:
            if frame {2}{4}:line = 0 then do:
              down 1 stream PrnLibStream
              with frame {2}{4} .
            end.
          end.
          else do:
            if frame {3}{4}:line = 0 then do:
              down 1 stream PrnLibStream
              with frame {3}{4} .
            end.
          end.
         PUT STREAM PrnLibStream string( "   √–”œœ¿ : " + get-grp-name(sj-goods.grp-name) ) format "x(120)" SKIP.
         if my-Set_Val_Type = {&v-base} then do:
            UNDERLINE STREAM PrnLibStream
            sj-goods.artic
            sj-goods.name
            with FRAME {2}{4} .
          end.
          else do:
            UNDERLINE STREAM PrnLibStream
            sj-goods.artic
            sj-goods.name
            with FRAME {3}{4} .
          end.
        end.
        else do:
          if frame {2}{4}:line = 0 then do:
            down 1 stream PrnLibStream
            with frame {2}{4} .
          end.
          PUT STREAM PrnLibStream string( "   √–”œœ¿ : " + get-grp-name(sj-goods.grp-name) ) format "x(120)" SKIP.
          UNDERLINE STREAM PrnLibStream
          sj-goods.artic
          sj-goods.name
          with FRAME {2}{4} .
        end.
      end.
    end. /*if first-of( sj-goods.grp-name ) then do:*/
    { rep/e-sjprod.i sj-goods.prod-name sj-goods.grp-name prodtot_flag grouptot_flag {1} {2} {3} {4}}
  END. /*FOR EACH sj-goods NO-LOCK,*/
end.
else do:
  FOR EACH sj-goods NO-LOCK,
      EACH sj-adv NO-LOCK WHERE
            sj-adv.obj-attr = sj-goods.obj-attr AND
            sj-adv.b-code = sj-goods.b-code AND
            sj-adv.saleman-chr = sj-goods.saleman-chr
      BREAK
      BY sj-goods.obj-attr
      BY sj-goods.prod-name
      BY sj-goods.grp-name
      BY sj-goods.saleman-chr
      BY sj-goods.b-code
      BY sj-adv.price
&if "{1}" = "sj-adv.discnt" &then
      BY sj-adv.discnt
&endif
  :
    { rep/e-sjobs.i {2} {3} {4}}
    if first-of( sj-goods.prod-name ) then do:
      format "x(120)" SKIP .
      if v-curr-r-b = {&r-b-base} then do:
        if my-set_Val_Type = {&v-base} then do:
          if frame {2}{4}:line = 0 then do:
            down 1 stream PrnLibStream
            with frame {2}{4} .
          end.
        end.
        else do:
          if frame {3}{4}:line = 0 then do:
            down 1 stream PrnLibStream
            with frame {3}{4} .
          end.
        end.
        PUT STREAM PrnLibStream string( "   œ–Œ»«¬Œƒ»“≈À‹ : " + sj-goods.prod-name ) format "x(120)" skip.
        if my-Set_Val_Type = {&v-base} then do:
          UNDERLINE STREAM PrnLibStream
          sj-goods.artic
          sj-goods.name
          with FRAME {2}{4} .
        end.
        else do:
          UNDERLINE STREAM PrnLibStream
          sj-goods.artic
          sj-goods.name
          with FRAME {3}{4} .
        end.
      end.
      else do:
        if frame {2}{4}:line = 0 then do:
           down 1 stream PrnLibStream
           with frame {2}{4} .
        end.
        PUT STREAM PrnLibStream string( "   œ–Œ»«¬Œƒ»“≈À‹ : " + sj-goods.prod-name ) format "x(120)" skip.
        UNDERLINE STREAM PrnLibStream
        sj-goods.artic
        sj-goods.name
        with FRAME {2}{4} .
      end.
    end. /*if first-of( sj-goods.prod-name ) then do:*/
    if first-of( sj-goods.grp-name ) then do:
      if grouptot_flag OR NOT SHOnly_tot then do:
        if v-curr-r-b = {&r-b-base} then do:
          if my-set_Val_Type = {&v-base} then do:
            if frame {2}{4}:line = 0 then do:
              down 1 stream PrnLibStream
              with frame {2}{4} .
            end.
          end.
          else do:
            if frame {3}{4}:line = 0 then do:
              down 1 stream PrnLibStream
              with frame {3}{4} .
            end.
          end.
          PUT STREAM PrnLibStream
          string( "   √–”œœ¿ : " + get-grp-name(sj-goods.grp-name) ) format "x(120)" SKIP.
          if my-Set_Val_Type = {&v-base} then do:
            UNDERLINE STREAM PrnLibStream
            sj-goods.artic
            sj-goods.name
            with FRAME {2}{4} .
          end.
          else do:
            UNDERLINE STREAM PrnLibStream
            sj-goods.artic
            sj-goods.name
            with FRAME {3}{4} .
          end.
        end.
        else do:
          if frame {2}{4}:line = 0 then do:
            down 1 stream PrnLibStream
            with frame {2}{4} .
          end.
          PUT STREAM PrnLibStream
          string( "   √–”œœ¿ : " + get-grp-name(sj-goods.grp-name) ) format "x(120)" SKIP.
          UNDERLINE STREAM PrnLibStream
          sj-goods.artic
          sj-goods.name
          with FRAME {2}{4} .
        end.
      end.
    end. /*if first-of( sj-goods.grp-name ) then do:*/
    { rep/e-sjprod.i sj-goods.prod-name sj-goods.grp-name prodtot_flag grouptot_flag {1} {2} {3} {4}}
  END. /*FOR EACH sj-goods NO-LOCK,*/
end.

/* $Workfile$ e n d */