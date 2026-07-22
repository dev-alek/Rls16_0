/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Дата создания: 08/15/01
*/
&if '{7}' = 'tree' &then
 IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO:
   for each tmp-gds no-lock :
   For  EACH gds-obj
                WHERE  gds-obj.obj-code   = x-store-code /* obj-list.obj-code */
                  AND  gds-obj.obj-type   = x-store-type /* obj-list.obj-type */
                  and  (trim(gds-obj.grp-name)   begins trim(tmp-gds.f-name) )
                  {&ver-last-doc}
                       no-lock ,
            First G#cli
                  Where gds-obj.prod-code  = g#cli.obj-code
                  AND  gds-obj.prod-type  = g#cli.obj-type no-lock ,
            First Goods
                 where gds-obj.prod-code  = Goods.prod-code and
                       gds-obj.prod-type  = Goods.prod-type and
                       gds-obj.artic      = Goods.artic no-lock
                  BREAK BY {1} BY {2}  BY {6} :
             str = n-lavel(INPUT {4}.grp-name, Input tmp-gds.lvl ) .
                assign
                    gds-zap-unit-base  = {4}.unit-base
                    gds-zap-prt-root   = {4}.prt-root
                    gds-zap-prod-type  = {4}.prod-type
                    gds-zap-prod-code  = {4}.prod-code
                    gds-zap-artic      = {4}.artic
                    gds-zap-type       = {4}.gds-type
                    gds-zap-grp-name   = {4}.grp-name
                    gds-zap-b-code     = {4}.gds-code
                    .
                  run foreach.
                  i = i + 1.
            End.
        if NOT
        (
          b1-oborot-{&bef-TDEDT_Pri_Vnesh }                 [1]    = 0 and
          b1-oborot-{&bef-TDEDT_Ras_Vnesh }                 [1]    = 0 and
          b1-oborot-{&bef-TDEDT_RAS_Vnesh_VP }              [1]    = 0 and
          b1-oborot-{&bef-TDEDT_Ras_Vnesh_Kass }            [1]    = 0 and
          b1-oborot-{&bef-TDEDT_Vozvrat_Vnesh }             [1]    = 0 and
          b1-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass }        [1]    = 0 and
          b1-oborot-{&bef-TDEDT_Spi_Vnesh }                 [1]    = 0 and
          b1-oborot-{&bef-TDEDT_Inv }                       [1]    = 0 and
          b1-oborot-{&bef-TDEDT_Pri_Perem }                 [1]    = 0 and
          b1-oborot-{&bef-TDEDT_Ras_Perem }                 [1]    = 0 and
          b1-oborot-{&bef-TDEDT_Vozvrat_Perem }             [1]    = 0 and
          b1-oborot-{&bef-TDEDT_Ras_Prvo }                  [1]    = 0 and
          b1-oborot-{&bef-TDEDT_Spi_Prvo }                  [1]    = 0 and
          b1-oborot-{&bef-TDEDT_Pri_Prvo }                  [1]    = 0 and
          b1-oborot-{&bef-TDEDT_Overturn }                  [1]    = 0 and
          b1-oborot-{&bef-Disc }                            [1]    = 0 and
          b1-ostatok-end                                    [1]    = 0 and
          b1-ostatok-start                                  [1]    = 0 and
          b1-oborot-{&bef-TDEDT_Overturn }                  [2]    = 0
           )  then do:
         Assign
          s-bar-code       = substring(tmp-gds.name,1,9)
          sf1:screen-value = substring(tmp-gds.name,10,1)
          gds-zap-artic    = substring(tmp-gds.name,11,16)
          sf2:screen-value = substring(tmp-gds.name,27,1)
          gds-zap-gds-name = substring(tmp-gds.name,28,40)
          no-error .
          run display-b1 .
          run clear-b1 .
          run clear-b2 .
          assign
            sf1:screen-value = ""
            sf2:screen-value = ""
            no-error .
      end.
    end.
  END.
 Else DO:
  For each obj-list no-lock :
        For  EACH gds-obj   where
          gds-obj.obj-type = obj-list.obj-type    and
          gds-obj.obj-code = obj-list.obj-code
          {&ver-last-doc}
           no-lock ,
            First G#cli
                  Where gds-obj.prod-code  = g#cli.obj-code
                  AND  gds-obj.prod-type  = g#cli.obj-type no-lock ,
            First {4}
                 where gds-obj.prod-code  = {4}.prod-code and
                       gds-obj.prod-type  = {4}.prod-type and
                       gds-obj.artic      = {4}.artic no-lock  :

                    if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do :
                        Create temp-gds-list.
                        Assign
                          temp-gds-list.prod-code = gds-obj.prod-code
                          temp-gds-list.grp-name  = substring(gds-obj.grp-name,1,170)
                          temp-gds-list.gds-code  = gds-obj.gds-code
                          temp-gds-list.artic     = gds-obj.artic
                          temp-gds-list.gds-name  = {4}.gds-name
                          .
                    End.
            End.
 End.
        for each tmp-gds no-lock     :
         for each temp-gds-list no-lock
             where (trim(temp-gds-list.grp-name)   begins trim(tmp-gds.f-name) )
          &if "{4}" = "goods":U  &then     , First goods  where goods.gds-code  = temp-gds-list.gds-code no-lock   &endif
          &if "{4}" = "gds-list":U  &then  , First gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock  &endif
            BREAK
              &If "{1}" <> "1"  &then BY {1}  &endif
              &If "{2}" <> "1"  &then BY {2}  &endif
              BY {6} :
             str = n-lavel(INPUT {4}.grp-name, Input tmp-gds.lvl ) .
                assign
                    gds-zap-unit-base  = {4}.unit-base
                    gds-zap-prt-root   = {4}.prt-root
                    gds-zap-prod-type  = {4}.prod-type
                    gds-zap-prod-code  = {4}.prod-code
                    gds-zap-artic      = {4}.artic
                    gds-zap-type       = {4}.gds-type
                    gds-zap-grp-name   = {4}.grp-name
                    gds-zap-b-code     = {4}.gds-code
                    .
                  run foreach.
                  i = i + 1.
        End.
            if NOT
            (
              b1-oborot-{&bef-TDEDT_Pri_Vnesh }                 [1]    = 0 and
              b1-oborot-{&bef-TDEDT_Ras_Vnesh }                 [1]    = 0 and
              b1-oborot-{&bef-TDEDT_RAS_Vnesh_VP }              [1]    = 0 and
              b1-oborot-{&bef-TDEDT_Ras_Vnesh_Kass }            [1]    = 0 and
              b1-oborot-{&bef-TDEDT_Vozvrat_Vnesh }             [1]    = 0 and
              b1-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass }        [1]    = 0 and
              b1-oborot-{&bef-TDEDT_Spi_Vnesh }                 [1]    = 0 and
              b1-oborot-{&bef-TDEDT_Inv }                       [1]    = 0 and
              b1-oborot-{&bef-TDEDT_Pri_Perem }                 [1]    = 0 and
              b1-oborot-{&bef-TDEDT_Ras_Perem }                 [1]    = 0 and
              b1-oborot-{&bef-TDEDT_Vozvrat_Perem }             [1]    = 0 and
              b1-oborot-{&bef-TDEDT_Ras_Prvo }                  [1]    = 0 and
              b1-oborot-{&bef-TDEDT_Spi_Prvo }                  [1]    = 0 and
              b1-oborot-{&bef-TDEDT_Pri_Prvo }                  [1]    = 0 and
              b1-oborot-{&bef-TDEDT_Overturn }                  [1]    = 0 and
              b1-oborot-{&bef-Disc }                            [1]    = 0 and
              b1-ostatok-end                                    [1]    = 0 and
              b1-ostatok-start                                  [1]    = 0 and
              b1-oborot-{&bef-TDEDT_Overturn }                  [2]    = 0
              )  then do:
            Assign
              s-bar-code       = substring(tmp-gds.name,1,9)
              sf1:screen-value = substring(tmp-gds.name,10,1)
              gds-zap-artic    = substring(tmp-gds.name,11,16)
              sf2:screen-value = substring(tmp-gds.name,27,1)
              gds-zap-gds-name = substring(tmp-gds.name,28,40)
              no-error .
              run display-b1 .
              run clear-b1 .
              run clear-b2 .
              assign
                sf1:screen-value =""
                sf2:screen-value =""
                no-error .
            end.
    End.
  End.
&else
  &scoped-define seq {&sequence}
  define buffer buf_obj-list{&seq} for obj-list.
  for each buf_obj-list{&seq} no-lock :
      if xtog-obj and  not (buf_obj-list{&seq}.obj-type = x-store-type  and
                            buf_obj-list{&seq}.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                  gds-obj.obj-type = buf_obj-list{&seq}.obj-type    and
                  gds-obj.obj-code = buf_obj-list{&seq}.obj-code
                  {&ver-last-doc}
                    no-lock ,
        first g#cli
              where    g#cli.obj-code = gds-obj.prod-code
              and      g#cli.obj-type = gds-obj.prod-type
                       no-lock ,
        first {4} where {4}.gds-code = gds-obj.gds-code
                            no-lock :
            if not can-find ( first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                create temp-gds-list.
                assign
                  temp-gds-list.prod-code = gds-obj.prod-code
                  temp-gds-list.grp-name  = ""
                  temp-gds-list.gds-code  = gds-obj.gds-code
                  temp-gds-list.artic     = gds-obj.artic
                  temp-gds-list.gds-name  = {4}.gds-name
                  .
                  temp-gds-list.grp-name  = n-lavel(input gds-obj.grp-name, input xlavel )
                  .
            end.
        end.
 end.

  for each temp-gds-list no-lock
    &if "{4}" = "goods":u  &then     , first goods     where goods.gds-code     = temp-gds-list.gds-code no-lock   &endif
    &if "{4}" = "gds-list":u  &then  , first gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock  &endif
      break
        &if "{2}" <> "1"  &then by  temp-gds-list.grp-name   &endif
        by {6} :
        str = n-lavel(input {4}.grp-name, input xlavel ) no-error .
        { rep/o-lavel.i "''" temp-gds-list.grp-name "''" {4} }
  end.

  &endif
  /* $Workfile$ e n d */