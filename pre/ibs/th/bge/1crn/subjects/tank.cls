using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.str.placelib from propath .
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.tank implements iexpsubject:
  define variable placelib as class placelib no-undo .
  define buffer buf_place      for ub.place .
  define buffer com_place      for ub.place .
  define buffer buf_c-place    for ub.c-place .
  define buffer buf_place-attr for ub.place-attr .
  define buffer buf_pl-level   for ub.pl-level .
  define buffer buf_c-pl-level for ub.c-pl-level .
  define buffer buf_pl-level-mm   for ub.pl-level-mm .
  define buffer buf_pl-level-attr for ub.pl-level-attr .
  define buffer buf_pl-gds     for ub.pl-gds .
  define temp-table tt-place like ub.c-place
  field gds-code as integer.
  define temp-table tt-pl-level-mm like ub.pl-level-mm.
  define temp-table tt-pl-level like ub.c-pl-level
  field belt      as decimal
  field comp-err  as decimal
  field deltaV    as decimal
  .
  define variable ii      as integer   no-undo .
  define variable v-code  as character no-undo .
  define variable v-value as character no-undo .
  define variable v-ok    as logical   no-undo .
  define variable v-del   as logical   no-undo .
   define temp-table tt-place-attr
      field pl-code             like place.pl-code
      field place-type          as character
      field place-Si            as integer
      field place-diameter      as decimal
      field dead-balance        as decimal
      field place-rel-error     as decimal
      field pl-twice-code       like place.loc1
      field place-dens-prov     as decimal
      field place-local         as integer
      field place-asi-sertif    as integer
      field place-error-mass    as decimal
      field place-rvd-dnsty     as integer
      field place-rvd-lvl       as integer
      field place-rvd-tmp       as integer
      field place-dc-height     as integer
      field place-tank-tk       as decimal
      field place-dnst-mi-code  as character
      field place-lvl-mi-code   as character
      field place-tmp-mi-code   as character
      field place-passport-num  as character
      field place-passport-type as character
      field ponton              as logical
      field ponton-mass         as decimal
      field ponton-height       as decimal
      field com-vessel          as logical
      field com-tanks           as character
      field is-main             as logical
      field main-com-code       as character
      field gate-valve          as logical
      index pi as primary unique
      pl-code
      .
  define property Msg as character no-undo
    get.
    private set.
  define property pl-code as character no-undo
    get.
    set.
  define variable sw as handle no-undo.
  define property InitSecTag as character no-undo init "tanks"
    get.
    private set.
  define public property sendTableName as character no-undo init "place"
    get.
  define public property sendOldRowid as rowid  no-undo
    get.
    set.
  define public property sendNewRowid as rowid  no-undo
    get.
    set.
  method public void CrContentToSW (insw as handle):
    sw = insw .
    placelib = new placelib().
    find first buf_place no-lock where buf_place.pl-code = INTEGER (pl-code) no-error .
    if AVAILABLE buf_place then
    do:
      v-del = no .
      sendOldRowid = rowid(buf_place).
      create tt-place .
      BUFFER-COPY buf_place to tt-place .
      find first buf_pl-gds no-lock where buf_pl-gds.pl-code = buf_place.pl-code no-error .
      if AVAILABLE (buf_pl-gds) then do:
        tt-place.gds-code = buf_pl-gds.gds-code .
      end.
    end.
    else
    do:
      find LAST buf_c-place no-lock where buf_c-place.pl-code = INTEGER (pl-code) no-error .
      if AVAILABLE buf_c-place then
      do:
        v-del = yes .
        sendOldRowid = rowid(buf_c-place).
        create tt-place .
        BUFFER-COPY buf_c-place to tt-place .
        find first buf_pl-gds no-lock where buf_pl-gds.pl-code = buf_c-place.pl-code no-error .
        if AVAILABLE (buf_pl-gds) then
        do:
          tt-place.gds-code = buf_pl-gds.gds-code .
        end.
      end.
      else
      do:
        Msg = "Нет складкского места с кодом" + pl-code .
        return error.
      end.
    end.
    find first buf_pl-level no-lock where buf_pl-level.pl-code = tt-place.pl-code and
      buf_pl-level.obj-code = tt-place.obj-code and
      buf_pl-level.obj-type = tt-place.obj-type no-error .
    if AVAILABLE buf_pl-level then
    do:
      for each buf_pl-level no-lock where buf_pl-level.pl-code = tt-place.pl-code and
        buf_pl-level.obj-code = tt-place.obj-code and
        buf_pl-level.obj-type = tt-place.obj-type:
        create tt-pl-level .
        buffer-copy buf_pl-level to tt-pl-level .
        find first buf_pl-level-attr no-lock where buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
                                               and buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
                                               and buf_pl-level-attr.pl-code   = buf_pl-level.pl-code
                                               and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
                                               and buf_pl-level-attr.attr-code = "tarir-delta"
                                               no-error .
        if available buf_pl-level-attr then tt-pl-level.comp-err = decimal (buf_pl-level-attr.attr-value) .
        find first buf_pl-level-attr no-lock where buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
                                               and buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
                                               and buf_pl-level-attr.pl-code   = buf_pl-level.pl-code
                                               and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
                                               and buf_pl-level-attr.attr-code = "deltaV"
                                               no-error .
        if available buf_pl-level-attr then tt-pl-level.deltaV = decimal (buf_pl-level-attr.attr-value) no-error .
        find first buf_pl-level-mm where
                   buf_pl-level-mm.obj-type   = tt-place.obj-type
               and buf_pl-level-mm.obj-code   = tt-place.obj-code
               and buf_pl-level-mm.pl-code    = tt-place.pl-code
               and buf_pl-level-mm.min-level <= buf_pl-level.pl-level
               and buf_pl-level-mm.max-level >= buf_pl-level.pl-level
             no-lock no-error.
        tt-pl-level.belt = if avail buf_pl-level-mm then buf_pl-level-mm.zone else 0.
      end .
    end .
    else
    do:
      for each buf_c-pl-level no-lock where buf_c-pl-level.pl-code = tt-place.pl-code and
        buf_c-pl-level.obj-code = tt-place.obj-code and
        buf_c-pl-level.obj-type = tt-place.obj-type:
        create tt-pl-level .
        buffer-copy buf_c-pl-level to tt-pl-level .
        find first buf_pl-level-attr no-lock where buf_pl-level-attr.obj-type  = buf_c-pl-level.obj-type
                                               and buf_pl-level-attr.obj-code  = buf_c-pl-level.obj-code
                                               and buf_pl-level-attr.pl-code   = buf_c-pl-level.pl-code
                                               and buf_pl-level-attr.pl-level  = buf_c-pl-level.pl-level
                                               and buf_pl-level-attr.attr-code = "tarir-delta"
                                               no-error .
        if available buf_pl-level-attr then tt-pl-level.comp-err = decimal (buf_pl-level-attr.attr-value) .
        find first buf_pl-level-attr no-lock where buf_pl-level-attr.obj-type  = buf_c-pl-level.obj-type
                                               and buf_pl-level-attr.obj-code  = buf_c-pl-level.obj-code
                                               and buf_pl-level-attr.pl-code   = buf_c-pl-level.pl-code
                                               and buf_pl-level-attr.pl-level  = buf_c-pl-level.pl-level
                                               and buf_pl-level-attr.attr-code = "deltaV"
                                               no-error .
        if available buf_pl-level-attr then tt-pl-level.deltaV = decimal (buf_pl-level-attr.attr-value) no-error .
        find first buf_pl-level-mm where
                   buf_pl-level-mm.obj-type = tt-place.obj-type
               and buf_pl-level-mm.obj-code = tt-place.obj-code
               and buf_pl-level-mm.pl-code = tt-place.pl-code
               and buf_pl-level-mm.min-level <= buf_c-pl-level.pl-level
               and buf_pl-level-mm.max-level >= buf_c-pl-level.pl-level
             no-lock no-error.
        tt-pl-level.belt = if avail buf_pl-level-mm then buf_pl-level-mm.zone else 0.
      end.
    end.
    find first buf_pl-level-mm where
               buf_pl-level-mm.pl-code = tt-place.pl-code
           and buf_pl-level-mm.obj-code = tt-place.obj-code
           and buf_pl-level-mm.obj-type = tt-place.obj-type no-lock no-error .
    if avail buf_pl-level-mm then
    do:
        for each buf_pl-level-mm where
                 buf_pl-level-mm.pl-code = tt-place.pl-code
             and buf_pl-level-mm.obj-code = tt-place.obj-code
             and buf_pl-level-mm.obj-type = tt-place.obj-type
            no-lock:
            create tt-pl-level-mm .
            buffer-copy buf_pl-level-mm to tt-pl-level-mm .
        end.
    end.
    for each tt-place where tt-place.pl-code = INTEGER (pl-code) no-lock :
      find first tt-place-attr exclusive-lock where tt-place-attr.pl-code = tt-place.pl-code no-error.
      if not available tt-place-attr then
      do :
        create tt-place-attr.
        tt-place-attr.pl-code = tt-place.pl-code.
        ii = 0.
        do ii = 1 to num-entries('place-type,place-SI,place-diameter,dead-balance,water-level,dens-prov,place-virtual,place-twice-code,place-sert-urov,place-local,place-error-mass,place-asi-sertif,place-rvd-dnsty,place-rvd-lvl,place-rvd-tmp,place-SI-dens,place-SI-level,place-SI-temp,place-passp-num,place-passp-type,place-dead-high,place-temp-coef,disable-water-alarm,disable-level-alarm,place-ponton,place-ponton-mass,place-ponton-height,place-com-vessel,place-com-tanks,place-is-main,place-gate-valve':u):
          v-code = entry(ii,'place-type,place-SI,place-diameter,dead-balance,water-level,dens-prov,place-virtual,place-twice-code,place-sert-urov,place-local,place-error-mass,place-asi-sertif,place-rvd-dnsty,place-rvd-lvl,place-rvd-tmp,place-SI-dens,place-SI-level,place-SI-temp,place-passp-num,place-passp-type,place-dead-high,place-temp-coef,disable-water-alarm,disable-level-alarm,place-ponton,place-ponton-mass,place-ponton-height,place-com-vessel,place-com-tanks,place-is-main,place-gate-valve':u) .
          placelib:placelib_get-attr (
            input v-code
            ,input tt-place.obj-code
            ,input tt-place.obj-type
            ,input tt-place.pl-code
            ,output v-value
            ,output v-ok      ) no-error.
           case v-code :
              when "place-type" then
                 do :
                    if v-ok then
                    do :
                       if integer(v-value) = 1 then tt-place-attr.place-type = "1"  .
                       if integer(v-value) = 2 then tt-place-attr.place-type = "2"  .
                    end.
                 end.
              when "place-SI" then
                 do :
                    if v-ok then tt-place-attr.place-Si = integer(v-value) .
                 end.
              when "place-diameter" then
                 do :
                    if v-ok then tt-place-attr.place-diameter = decimal(v-value) .
                 end.
              when "dead-balance" then
                 do :
                    if v-ok then tt-place-attr.dead-balance = decimal(v-value) .
                 end.
              when "dens-prov" then
                 do :
                    if v-ok then tt-place-attr.place-dens-prov = decimal(v-value) .
                 end.
              when "place-twice-code" then
                 do:
                    if v-ok then tt-place-attr.pl-twice-code = v-value .
                 end.
              when "place-error-mass" then
                 do:
                    if v-ok then tt-place-attr.place-error-mass = decimal(v-value) .
                 end.
              when "place-local" then
                 do:
                    if v-ok then
                    do:
                       if v-value = "1" then tt-place-attr.place-local = 0 .
                       else tt-place-attr.place-local = 1 .
                    end.
                 end.
              when "place-asi-sertif" then
                 do:
                    if v-ok then
                    do:
                       if v-value = "yes" then tt-place-attr.place-asi-sertif = 1 .
                       else tt-place-attr.place-asi-sertif = 0 .
                    end.
                 end.
              when "place-rvd-dnsty" then
                 do:
                    if v-ok then
                    do:
                       if v-value = "yes" then tt-place-attr.place-rvd-dnsty = 1 .
                       else tt-place-attr.place-rvd-dnsty = 0 .
                    end.
                 end.
              when "place-rvd-lvl" then
                 do:
                    if v-ok then
                    do:
                       if v-value = "yes" then tt-place-attr.place-rvd-lvl = 1 .
                       else tt-place-attr.place-rvd-lvl = 0 .
                    end.
                 end.
              when "place-rvd-tmp" then
                 do:
                    if v-ok then
                    do:
                       if v-value = "yes" then tt-place-attr.place-rvd-tmp = 1 .
                       else tt-place-attr.place-rvd-tmp = 0 .
                    end.
                 end.
              when "place-dead-high" then
                 do:
                    if v-ok then
                    do:
                       tt-place-attr.place-dc-height = integer(v-value).
                    end.
                 end.
              when "place-temp-coef" then
                 do:
                    if v-ok then
                    do:
                       tt-place-attr.place-tank-tk = decimal(v-value).
                    end.
                 end.
              when "place-SI-dens" then
                 do:
                    if v-ok then
                    do:
                       tt-place-attr.place-dnst-mi-code = v-value .
                       if tt-place-attr.place-dnst-mi-code = ? then tt-place-attr.place-dnst-mi-code = "0" .
                    end.
                 end.
              when "place-SI-level" then
                 do:
                    if v-ok then
                    do:
                       tt-place-attr.place-lvl-mi-code = v-value .
                       if tt-place-attr.place-lvl-mi-code = ? then tt-place-attr.place-lvl-mi-code = "0" .
                    end.
                 end.
              when "place-SI-temp" then
                 do:
                    if v-ok then
                    do:
                       tt-place-attr.place-tmp-mi-code = v-value.
                       if tt-place-attr.place-tmp-mi-code = ? then tt-place-attr.place-tmp-mi-code = "0" .
                    end.
                 end.
              when "place-passp-num" then
                 do:
                    if v-ok then
                    do:
                       tt-place-attr.place-passport-num = v-value .
                    end.
                 end.
              when "place-passp-type" then
                 do:
                    if v-ok then
                    do:
                       tt-place-attr.place-passport-type = v-value .
                    end.
                 end.
              when "place-ponton" then do :
                if v-ok then tt-place-attr.ponton = logical(v-value) .
              end.
              when "place-ponton-mass" then do:
                if v-ok then tt-place-attr.ponton-mass = decimal(v-value) .
              end.
              when "place-ponton-height" then do:
                if v-ok then tt-place-attr.ponton-height = decimal(v-value) .
              end.
              when "place-com-vessel" then do :
                if v-ok then tt-place-attr.com-vessel = logical(v-value) .
              end.
              when "place-com-tanks" then do :
                if v-ok then tt-place-attr.com-tanks = v-value .
              end.
              when "place-is-main" then do :
                if v-ok then tt-place-attr.is-main = logical(v-value) .
              end.
              when "place-gate-valve" then do :
                if v-ok then tt-place-attr.gate-valve = logical(v-value) .
              end.
           end case.
        end.
        if tt-place-attr.com-vessel
        and not tt-place-attr.is-main
        and tt-place-attr.com-tanks > ""
        then
        do ii = 1 to num-entries(tt-place-attr.com-tanks) :
          find first com_place no-lock where com_place.obj-type = tt-place.obj-type
                                         and com_place.obj-code = tt-place.obj-code
                                         and com_place.loc1     = entry(ii, tt-place-attr.com-tanks)
                                         and com_place.status_  = ""
                                         no-error .
          if available com_place
          then do :
            placelib:placelib_get-attr (
            input "place-is-main"
            ,input com_place.obj-code
            ,input com_place.obj-type
            ,input com_place.pl-code
            ,output v-value
            ,output v-ok      ) no-error.
            if v-ok
            and logical (v-value)
            then do :
              tt-place-attr.main-com-code = string(com_place.pl-code) .
            end .
          end .
        end .
      end.
      sw:start-element ("tank") .
      sw:write-data-element ("tank-code", string(tt-place.pl-code)).
      sw:write-data-element ("tank-num", string(tt-place.loc1)).
      sw:write-data-element ("del-l", if tt-place.status_ <> 'удал':U then "0" else "1").
      sw:write-data-element ("del-f", if v-del then "1" else "0").
      sw:write-data-element ("name", if tt-place.pl-name = ? then "" else tt-place.pl-name).
      sw:write-data-element ("gs-code", string(tt-place.obj-code)).
      for first tt-place-attr no-lock where tt-place-attr.pl-code = tt-place.pl-code:
        sw:write-data-element ("tank-type", string(tt-place-attr.place-type)).
        sw:write-data-element ("pl-qnty"  , string(tt-place.add-qnty)).
        sw:write-data-element ("max-qnty" , string(tt-place.max-qnty)).
        sw:write-data-element ("d-qnty"   , string(tt-place-attr.dead-balance)).
        sw:write-data-element ("tank-d"   , string(tt-place-attr.place-diameter)).
        sw:write-data-element ("dc-height" , string(tt-place-attr.place-dc-height)).
        sw:write-data-element ("rel-er"   , if tt-place-attr.place-type = "1" then "0.20" else "0.25").
        sw:write-data-element ("dnsty"    , string-mth (tt-place-attr.place-dens-prov)).
        sw:write-data-element ("main-mi-code"  , string(if tt-place-attr.place-Si = ? then 0 else tt-place-attr.place-Si)).
        sw:write-data-element ("position"  , string(tt-place-attr.place-local)).
        sw:write-data-element ("certified"  , string(tt-place-attr.place-asi-sertif)).
        sw:write-data-element ("pipe-er"  , string-mth(tt-place-attr.place-error-mass)).
        sw:write-data-element ("tank-tk" , string(tt-place-attr.place-tank-tk)).
        sw:write-data-element ("rvd-dnsty"  , string(tt-place-attr.place-rvd-dnsty)).
        sw:write-data-element ("dnst-mi-code" , string(if tt-place-attr.place-dnst-mi-code = ? then "0" else tt-place-attr.place-dnst-mi-code)).
        sw:write-data-element ("rvd-lvl"  , string(tt-place-attr.place-rvd-lvl)).
        sw:write-data-element ("lvl-mi-code" , string(if tt-place-attr.place-lvl-mi-code = ? then "0" else tt-place-attr.place-lvl-mi-code)).
        sw:write-data-element ("rvd-tmp"  , string(tt-place-attr.place-rvd-tmp)).
        sw:write-data-element ("tmp-mi-code" , string(if tt-place-attr.place-tmp-mi-code = ? then "0" else tt-place-attr.place-tmp-mi-code)).
        sw:write-data-element ("gd-code", string(tt-place.gds-code)).
        sw:write-data-element ("izm-pr", if tt-place.is-meas = yes then "1" else "0").
        sw:write-data-element ("passport-num" , string(tt-place-attr.place-passport-num)).
        sw:write-data-element ("passport-type" , string(tt-place-attr.place-passport-type)).
        if tt-place-attr.place-type = "1"
        then do :
          if tt-place-attr.ponton
          then do :
            sw:write-data-element ("pontoon", "1").
            sw:write-data-element ("wght-pntn", string(tt-place-attr.ponton-mass)).
            sw:write-data-element ("srfcng-pntn", string(tt-place-attr.ponton-height)).
          end .
          else do :
            sw:write-data-element ("pontoon", "0").
          end .
        end .
        if tt-place-attr.com-vessel
        then do :
          sw:write-data-element ("com-vessel", "1").
          if tt-place-attr.is-main
          then do :
            sw:write-empty-element ("com-code") .
          end .
          else do :
            sw:write-data-element ("com-code", tt-place-attr.main-com-code) .
          end .
        end .
        if tt-place-attr.gate-valve
        then do :
          sw:write-data-element ("gate-valve", "1").
        end .
        else do :
          sw:write-data-element ("gate-valve", "0").
        end .
      end.
      find first tt-pl-level no-lock where tt-pl-level.pl-code = tt-place.pl-code and
        tt-pl-level.obj-code = tt-place.obj-code and
        tt-pl-level.obj-type = tt-place.obj-type no-error .
      if AVAILABLE (tt-pl-level) then
      do:
        sw:start-element ("cal-tbl") .
        for each tt-pl-level no-lock where tt-pl-level.pl-code = tt-place.pl-code and
          tt-pl-level.obj-code = tt-place.obj-code and
          tt-pl-level.obj-type = tt-place.obj-type:
          sw:start-element ("cal-tbl-line") .
          sw:write-data-element ("lvl"  , string(tt-pl-level.pl-level)).
          if tt-pl-level.belt <> 0 then sw:write-data-element ("belt", string(tt-pl-level.belt)).
          sw:write-data-element ("amnt" , string(tt-pl-level.pl-qnty)).
          sw:write-data-element ("comp-err" , string(tt-pl-level.comp-err,">9.999")).
          if tt-pl-level.deltaV > 0 then sw:write-data-element ("deltaV", trim(string(tt-pl-level.deltaV, ">>9.9999"))).
          sw:end-element ("cal-tbl-line")  .
        end.
        sw:end-element ("cal-tbl")  .
      end.
      find first tt-pl-level-mm no-lock where tt-pl-level-mm.pl-code = tt-place.pl-code and
        tt-pl-level-mm.obj-code = tt-place.obj-code and
        tt-pl-level-mm.obj-type = tt-place.obj-type no-error .
      if AVAILABLE (tt-pl-level-mm) then
      do:
        sw:start-element ("belt-tbl") .
        for each tt-pl-level-mm no-lock where tt-pl-level-mm.pl-code = tt-place.pl-code and
          tt-pl-level-mm.obj-code = tt-place.obj-code and
          tt-pl-level-mm.obj-type = tt-place.obj-type:
          sw:start-element ("belt-tbl-line") .
          sw:write-data-element ("num-belt"  , string(tt-pl-level-mm.zone)).
          sw:write-data-element ("low-lvl"  , string(tt-pl-level-mm.min-level)).
          sw:write-data-element ("up-lvl"  , string(tt-pl-level-mm.max-level)).
          sw:write-data-element ("tbl-lvl"  , string(tt-pl-level-mm.level)).
          sw:write-data-element ("Belt-capacity"  , left-trim(right-trim(string(tt-pl-level-mm.capacity / 1000,">>>9.9999"),"0")," ")).
          sw:end-element ("belt-tbl-line")  .
        end.
        sw:end-element ("belt-tbl")  .
      end.
      sw:END-ELEMENT ("tank") .
    end.
  end.
  method private character string-mth (inValue as decimal):
    def var v-str as character no-undo.
    if inValue = ?
      then v-str = "0".
    if string (inValue) begins "."
      then v-str = "0" + string (inValue).
    else v-str = string (inValue).
    return v-str.
  end.
end class.
