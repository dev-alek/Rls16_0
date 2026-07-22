using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.check-fuel-docs implements iexpsubject:
  define buffer buf_rvs-doc             for ub.rvs-doc .
  define buffer buf_c-rvs-doc           for ub.c-rvs-doc .
  define buffer buf_rvs-line            for ub.rvs-line .
  define buffer buf_c-rvs-line          for ub.c-rvs-line .
  define buffer buf_doc-attr            for ub.doc-attr .
  define buffer buf_c-doc-attr          for ub.c-doc-attr .
  define buffer buf_rvs-line-attr       for ub.rvs-line-attr .
  define buffer buf_rvs-line-pump       for ub.rvs-line-pump .
  define buffer buf_c-rvs-line-pump     for ub.c-rvs-line-pump .
  define buffer buf_parent_user-account for ub.user-account .
  define buffer buf_user-account        for ub.user-account .
  define buffer buf_place-attr          for ub.place-attr .
  define buffer buf_rvs-doc-attr        for ub.rvs-doc-attr .
  define temp-table tt-rvs-doc like ub.c-rvs-doc
    field del-f as integer .
  define temp-table tt-rvs-line like ub.c-rvs-line .
  define temp-table tt-doc-attr like ub.doc-attr .
  define temp-table tt-rvs-line-attr like ub.rvs-line-attr .
  define temp-table tt-rvs-line-pump like ub.c-rvs-line-pump .
  define variable v-user-name             as character no-undo .
  define variable v-autorvs               as integer   no-undo init 0 .
  define variable v-type                  as character no-undo .
  define variable v-dnsty                 as decimal   no-undo .
  define variable v-wght                  as decimal   no-undo .
  define variable v-ex-df                 as decimal   no-undo .
  define variable v-dens-sug              as decimal   no-undo .
  define variable v-pres-sug              as decimal   no-undo .
  define variable v-dens-sug-fact         as decimal   no-undo .
  define variable v-pres-sug-fact         as decimal   no-undo .
  define variable v-line-input-type-p as character no-undo .
  define variable v-line-input-type-t as character no-undo .
  define variable v-line-input-type-l as character no-undo .
  define variable v-doc-input-type        as character no-undo .
  define variable v-input-type-list       as character no-undo .
  define variable er-wght-pipeline        as decimal   no-undo .
  define variable v-temp-izm-vol          as decimal no-undo .
  define variable it                      as integer no-undo .
  define variable id                      as integer no-undo .
  define variable sr-type-temp            as integer no-undo .
  define variable sr-type-dens            as integer no-undo .
  define variable v-izm-temps             as character no-undo .
  define variable v-izm-denses            as character no-undo .
  define variable v-POkMI-result-attr     as character no-undo .
  define variable v-POkMI-mass            as decimal no-undo .
  define variable v-POkMI-otn-delta-mass  as decimal no-undo .
  define variable v-POkMI-standart-dens   as decimal no-undo .
  define variable v-POkMI-standart-vol    as decimal no-undo .
  define variable v-POkMI-vol             as decimal no-undo .
  define variable v-POkMI-water-vol       as decimal no-undo .
  define variable v-ASI-POkMI-standart-dens   as decimal no-undo .
  define variable ii                      as integer no-undo .
  define variable v-is-sug                as logical no-undo .
  define variable v-dnst-mi               as character no-undo .
  define variable v-lvl-mi                as character no-undo .
  define variable v-tmp-mi                as character no-undo .
  define variable varmeasure-water-qnty   as decimal no-undo.
  define variable varstate-water-qnty     as decimal no-undo.
  define variable v-pl-code               as character no-undo .
  define variable v-test-asi-diff         as decimal no-undo .
  define property Msg as character no-undo
    get.
    private set.
  define property DocCode as character no-undo
    get.
    set.
  define property InitSecTag as character no-undo
    get.
    private set.
  define public property sendTableName  as character  no-undo init "rvs-doc"
    get.
  define public property sendOldRowid as rowid  no-undo
    get.
    set.
  define public property sendNewRowid as rowid  no-undo
    get.
    set.
  define variable sw as handle no-undo.
  define private variable libFindtank as class ibs.th.str.findtank no-undo .
  method public void CrContentToSW (insw as handle):
    sw = insw .
    libFindtank = new ibs.th.str.findtank ().
    find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-code = DocCode no-error.
    if available (buf_rvs-doc) then
    do:
      buffer-copy buf_rvs-doc to tt-rvs-doc .
      tt-rvs-doc.del-f = 0 .
      tt-rvs-doc.fact-time = buf_rvs-doc.fact-time .
      sendOldRowid  = rowid(buf_rvs-doc).
    end.
    else
    do:
      find first buf_c-rvs-doc no-lock where buf_c-rvs-doc.rvs-code = DocCode no-error.
      if available (buf_c-rvs-doc) then
      do:
        buffer-copy buf_c-rvs-doc to tt-rvs-doc .
        tt-rvs-doc.del-f = 1 .
        sendOldRowid  = rowid(buf_c-rvs-doc).
      end.
      else return.
    end.
    find first buf_doc-attr no-lock where tt-rvs-doc.rvs-code = buf_doc-attr.doc-code and buf_doc-attr.attr-code = "rvs-auto" and buf_doc-attr.attr-value = "Yes" no-error.
    if available buf_doc-attr then
    do :
      v-autorvs = 1.
    end.
    else
    do:
      find first buf_c-doc-attr no-lock where tt-rvs-doc.rvs-code = buf_c-doc-attr.doc-code and buf_c-doc-attr.attr-code = "rvs-auto" and buf_c-doc-attr.attr-value = "Yes" no-error.
      if available buf_c-doc-attr then
      do :
        v-autorvs = 1.
      end.
    end.
    case tt-rvs-doc.rvs-type:
      when 'перед_док':U then
        do:
          v-type = "1" .
        end.
      when 'после_док':U then
        do:
          v-type = "2" .
        end.
      when 'смена':U then
        do:
          v-type = "4" .
        end.
      when 'контроль':U then
        do:
          v-type = "3" .
        end.
      when 'проверка':U then
        do:
          v-type = "test-asi" .
        end.
    end case.
    find first buf_user-account no-lock
      where buf_user-account.user-id = tt-rvs-doc.creid
      no-error .
    if not available buf_user-account
      then
    do:
      assign
        v-user-name = tt-rvs-doc.creid
        .
    end.
    else
    do:
      if buf_user-account.check-parent = true
        then
      do:
        find first buf_parent_user-account no-lock
          where buf_parent_user-account.user-id = buf_user-account.parent-user-id
          no-error .
        if not available buf_parent_user-account
          then
        do:
          assign
            v-user-name = tt-rvs-doc.creid
            .
        end.
        else
        do:
          assign
            v-user-name = buf_user-account.nik
            .
        end.
      end.
      else
      do:
        assign
          v-user-name = buf_user-account.nik
          .
      end.
    end.
    if tt-rvs-doc.del-f = 0 then
    do:
      for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = tt-rvs-doc.rvs-code:
        create tt-rvs-line .
        buffer-copy buf_rvs-line to tt-rvs-line .
      end.
      for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = tt-rvs-doc.rvs-code
                                           and buf_rvs-line-pump.obj-code = tt-rvs-doc.obj-code
                                           and buf_rvs-line-pump.obj-type = tt-rvs-doc.obj-type
                                           break
                                           by buf_rvs-line-pump.pump-code
                                           by buf_rvs-line-pump.nozzle-code:
        if first-of(buf_rvs-line-pump.nozzle-code)
        then do :
          find first tt-rvs-line-pump where tt-rvs-line-pump.pump-code    = buf_rvs-line-pump.pump-code
                                        and tt-rvs-line-pump.nozzle-code  = buf_rvs-line-pump.nozzle-code
                                        and tt-rvs-line-pump.pl-code      = buf_rvs-line-pump.pl-code
                                        no-error .
          if not available tt-rvs-line-pump
          then do :
            create tt-rvs-line-pump .
            buffer-copy buf_rvs-line-pump to tt-rvs-line-pump .
          end.
        end.
      end.
    end.
    else
    do:
      for each buf_c-rvs-line no-lock where buf_c-rvs-line.rvs-code = tt-rvs-doc.rvs-code and buf_c-rvs-line.chip-num = tt-rvs-doc.chip-num:
        create tt-rvs-line .
        buffer-copy buf_c-rvs-line to tt-rvs-line .
      end.
      for each buf_c-rvs-line-pump no-lock where buf_c-rvs-line-pump.rvs-code = tt-rvs-doc.rvs-code
                                             and buf_c-rvs-line-pump.obj-code = tt-rvs-doc.obj-code
                                             and buf_c-rvs-line-pump.obj-type = tt-rvs-doc.obj-type
                                             break
                                             by buf_c-rvs-line-pump.pump-code
                                             by buf_c-rvs-line-pump.nozzle-code:
        if first-of(buf_c-rvs-line-pump.nozzle-code)
        then do :
          find first tt-rvs-line-pump where tt-rvs-line-pump.pump-code    = buf_c-rvs-line-pump.pump-code
                                        and tt-rvs-line-pump.nozzle-code  = buf_c-rvs-line-pump.nozzle-code
                                        and tt-rvs-line-pump.pl-code      = buf_c-rvs-line-pump.pl-code
                                        no-error .
          if not available tt-rvs-line-pump
          then do :
            create tt-rvs-line-pump .
            buffer-copy buf_c-rvs-line-pump to tt-rvs-line-pump .
          end.
        end.
      end.
    end.
    if v-type = "test-asi"
    then do :
      expCheckCorrectDoc() .
    end .
    else do :
      expCheckFuelDoc() .
    end .
  end .
  method private void expCheckCorrectDoc() :
    InitSecTag = "check-correct-docs" .
    define variable v-asi-type as character no-undo .
    find first buf_doc-attr no-lock where buf_doc-attr.doc-code = tt-rvs-doc.rvs-code
                                      and buf_doc-attr.attr-code = "test-asi-type"
                                      no-error .
    if not available buf_doc-attr
    then do :
      find last buf_c-doc-attr no-lock where buf_c-doc-attr.doc-code = tt-rvs-doc.rvs-code
                                         and buf_c-doc-attr.attr-code = "test-asi-type"
                                         no-error .
      if available buf_c-doc-attr
      then do :
        assign v-asi-type = buf_c-doc-attr.attr-value .
      end .
    end .
    else do :
      assign v-asi-type = buf_doc-attr.attr-value .
    end .
    case v-asi-type :
      when "test-asi_dens-place" then v-type = "1" .
      when "test-asi_dens-pump" then v-type = "2" .
      when "test-asi_mass" then v-type = "3" .
      otherwise v-type = "0" .
    end case .
    sw:start-element ("check-correct-doc") .
    sw:write-data-element ("doc-code", if tt-rvs-doc.rvs-code = ? then "" else string(tt-rvs-doc.rvs-code)) no-error .
    sw:write-data-element ("doc-num", if tt-rvs-doc.rvs-code = ? then "" else string(tt-rvs-doc.rvs-code)) no-error .
    sw:write-data-element ("doc-date", if tt-rvs-doc.doc-date = ? then "" else iso-date(datetime(tt-rvs-doc.doc-date, (tt-rvs-doc.fact-time * 1000 )))).
    sw:write-data-element ("doc-date-f", if tt-rvs-doc.sys-date = ? then "" else iso-date(datetime(tt-rvs-doc.sys-date, (tt-rvs-doc.sys-time-int * 1000 )))).
    sw:write-data-element ("del-f", if tt-rvs-doc.del-f = ? then "" else string(tt-rvs-doc.del-f)) no-error .
    sw:write-data-element ("doc-type", string(v-type)) no-error .
    sw:write-data-element ("shift-date", if tt-rvs-doc.shift-date = ? then "" else iso-date(tt-rvs-doc.shift-date)) no-error .
    sw:write-data-element ("shift-num", if tt-rvs-doc.shift-num = ? then "" else string(tt-rvs-doc.shift-num)) no-error .
    sw:write-data-element ("operator", if v-user-name = ? then "" else string(v-user-name)) no-error .
    sw:start-element ("tanks") .
    for each tt-rvs-line no-lock:
      varmeasure-water-qnty = (tt-rvs-line.brutto-qnty - tt-rvs-line.measure-qnty) .
      assign
        v-dnsty = ?
        v-wght = ?
        v-ex-df = ?
        v-line-input-type-p = ""
        v-line-input-type-T = ""
        v-line-input-type-l = ""
        v-dens-sug = ?
        v-pres-sug = ?
        v-dens-sug-fact = ?
        v-pres-sug-fact = ?
        v-temp-izm-vol = ?
        v-dnst-mi = ""
        v-lvl-mi = ""
        v-tmp-mi = ""
        sr-type-temp = ?
        v-izm-temps = ""
        sr-type-dens = ?
        v-izm-denses = ""
        v-POkMI-result-attr = ""
        varmeasure-water-qnty = ?
        varstate-water-qnty = ?
        v-test-asi-diff = ?
      .
      for each buf_rvs-line-attr no-lock
        where buf_rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        and buf_rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        and buf_rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        and buf_rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        and buf_rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code:
        case buf_rvs-line-attr.attr-code:
          when "test-asi-diff" then
            do:
              v-test-asi-diff = decimal(buf_rvs-line-attr.attr-value) .
            end.
          when "izmer-density" then
            do:
              v-dnsty = decimal(buf_rvs-line-attr.attr-value) .
            end.
          when "delta-mass-qnty" then
            do:
              v-wght = decimal(buf_rvs-line-attr.attr-value) .
            end.
          when "CriticalDif" then
            do:
              v-ex-df = decimal(buf_rvs-line-attr.attr-value) .
            end.
          when "temp-izm-vol" then
            do:
              v-temp-izm-vol = decimal(buf_rvs-line-attr.attr-value) .
            end.
          when "izm-temps" then
            do:
              sr-type-temp = integer(entry(1, buf_rvs-line-attr.attr-value, ";")) no-error .
              v-izm-temps = entry(2, buf_rvs-line-attr.attr-value, ";") no-error .
            end.
          when "izm-denses" then
            do:
              sr-type-dens = integer(entry(1, buf_rvs-line-attr.attr-value, ";")) no-error .
              v-izm-denses = entry(2, buf_rvs-line-attr.attr-value, ";") no-error .
            end.
          when "POkMI-result" then
            do:
              v-POkMI-result-attr = buf_rvs-line-attr.attr-value .
              v-POkMI-mass            = decimal(entry(2, entry(1, v-POkMI-result-attr, chr(10)), ":")) no-error .
              v-POkMI-otn-delta-mass  = decimal(entry(2, entry(2, v-POkMI-result-attr, chr(10)), ":")) no-error .
              v-POkMI-standart-dens   = decimal(entry(2, entry(3, v-POkMI-result-attr, chr(10)), ":")) no-error .
              v-POkMI-standart-vol    = decimal(entry(2, entry(4, v-POkMI-result-attr, chr(10)), ":")) no-error .
              v-POkMI-vol             = decimal(entry(2, entry(5, v-POkMI-result-attr, chr(10)), ":")) no-error .
              v-POkMI-water-vol       = decimal(entry(2, entry(6, v-POkMI-result-attr, chr(10)), ":")) no-error .
            end .
          when "pokmi-water-qnty" then
            do:
              if not v-is-sug
              then do :
                varstate-water-qnty = decimal(buf_rvs-line-attr.attr-value) .
              end .
            end.
          when "measure-water-qnty" then
            do:
              varmeasure-water-qnty = decimal(buf_rvs-line-attr.attr-value) .
            end.
          when "asi-pomi-density" then
            do:
              v-ASI-POkMI-standart-dens = decimal(buf_rvs-line-attr.attr-value) .
            end.
        end case .
      end.
      if v-wght = ? then v-wght = 0 .
      if v-ex-df = ? then v-ex-df = 0 .
      find first buf_place-attr no-lock where buf_place-attr.attr-code   = "place-error-mass"
                                          and buf_place-attr.obj-code    = tt-rvs-line.obj-code
                                          and buf_place-attr.obj-type    = tt-rvs-line.obj-type
                                          and buf_place-attr.pl-code     = tt-rvs-line.pl-code no-error.
      if available buf_place-attr
      then do :
        er-wght-pipeline = tt-rvs-line.state-add-qnty * tt-rvs-line.state-density * decimal(buf_place-attr.attr-value) / 100 no-error.
      end.
      else er-wght-pipeline = ? .
      sw:start-element ("tank") .
      sw:write-data-element ("tank-num"  , if tt-rvs-line.pl-code = ? then "0" else string(tt-rvs-line.pl-code)) no-error .
      sw:write-data-element ("gd-code"  , if tt-rvs-line.gds-code = ? then "0" else string(tt-rvs-line.gds-code)) no-error .
      sw:write-data-element ("tank-cmn-lvl" , if tt-rvs-line.level-total = ? then "0" else string-mth(tt-rvs-line.level-total)) no-error .
      sw:write-data-element ("tnk-wtr-lvl" , if tt-rvs-line.level-water = ? then "0" else string-mth(tt-rvs-line.level-water)) no-error .
      if tt-rvs-line.temperature = ?
      then
        sw:write-empty-element ("tnk-t") .
      else
        sw:write-data-element ("tnk-t" , string-mth(tt-rvs-line.temperature)) no-error .
      sw:write-data-element ("tank-ost" , if tt-rvs-line.measure-qnty = ? then "0" else string(tt-rvs-line.measure-qnty)) no-error .
      sw:write-data-element ("tank-wght" , if tt-rvs-line.measure-cli-qnty = ? then "0" else string-mth(tt-rvs-line.measure-cli-qnty)) no-error .
      sw:write-data-element ("tank-dnst" , if tt-rvs-line.density = ? then "0" else string-mth(tt-rvs-line.density)) no-error .
      sw:write-data-element ("tank-wtr" , if varmeasure-water-qnty = ? then "0" else string-mth(varmeasure-water-qnty)) no-error .
      sw:write-data-element ("tank-ost-br" , if tt-rvs-line.brutto-qnty = ? then "0" else string-mth(tt-rvs-line.brutto-qnty)) no-error .
      sw:write-data-element ("tank-ost-fact" , if tt-rvs-line.state-measure-qnty = ? then "0" else string-mth(tt-rvs-line.state-measure-qnty)) no-error .
      sw:write-data-element ("tank-dnst-fact" , if tt-rvs-line.state-density = ? then "0" else string-mth(tt-rvs-line.state-density)) no-error .
      sw:write-data-element ("tank-ost-br-fact" , if tt-rvs-line.state-brutto-qnty = ? then "0" else string-mth(tt-rvs-line.state-brutto-qnty)) no-error .
      sw:write-data-element ("tank-wtr-fact" , if varstate-water-qnty = ? then "0" else string-mth(varstate-water-qnty)) no-error .
      sw:write-data-element ("tank-wght-fact" , if tt-rvs-line.state-measure-cli-qnty = ? then "0" else string-mth(tt-rvs-line.state-measure-cli-qnty)) no-error .
      sw:write-data-element ("tank-cmn-lvl-fact" , if tt-rvs-line.state-level-total = ? then "0" else string-mth(tt-rvs-line.state-level-total)) no-error .
      sw:write-data-element ("tnk-wtr-lvl-fact" , if tt-rvs-line.state-level-water = ? then "0" else string-mth(tt-rvs-line.state-level-water)) no-error .
      sw:write-data-element ("tnk-t-vlm-fact" , if v-temp-izm-vol = ? then "0" else string-mth(v-temp-izm-vol)) no-error .
      sw:write-data-element ("tnk-t-average-fact" , if tt-rvs-line.state-temperature = ? then "0" else string-mth(tt-rvs-line.state-temperature)) no-error .
      case sr-type-temp :
        when 0
        then
        do it = 1 to num-entries(v-izm-temps) :
          sw:write-data-element (substitute("tnk-t&1-fact", string(it)) , string-mth(decimal(entry(it, v-izm-temps)))) no-error .
        end .
        when 1
        then
        do it = 1 to num-entries(v-izm-temps) :
          if it = 1
          then
            sw:write-data-element ("tnk-t-low-fact" , string-mth(decimal(entry(it, v-izm-temps)))) no-error .
          if it = 2
          then
            sw:write-data-element ("tnk-t-mid-fact" , string-mth(decimal(entry(it, v-izm-temps)))) no-error .
          if it = 3
          then
            sw:write-data-element ("tnk-t-upp-fact" , string-mth(decimal(entry(it, v-izm-temps)))) no-error .
        end .
      end case .
      sw:write-data-element ("ms-dnsty-average" , if v-dnsty = ? then "0" else string-mth(v-dnsty)) no-error .
      case sr-type-dens :
        when 0
        then
        do id = 1 to num-entries(v-izm-denses) :
          sw:write-data-element (substitute("ms-dnsty&1", string(id)) , string-mth(decimal(entry(id, v-izm-denses)))) no-error .
        end .
        when 1
        then
        do id = 1 to num-entries(v-izm-denses) :
          if id = 1
          then
            sw:write-data-element ("ms-dnsty-low" , string-mth(decimal(entry(id, v-izm-denses)))) no-error .
          if id = 2
          then
            sw:write-data-element ("ms-dnsty-mid" , string-mth(decimal(entry(id, v-izm-denses)))) no-error .
          if id = 3
          then
            sw:write-data-element ("ms-dnsty-upp" , string-mth(decimal(entry(id, v-izm-denses)))) no-error .
        end .
      end case .
      sw:write-data-element ("er-wght" , string-mth(v-wght)) no-error .
      sw:write-data-element ("abs-er-wght" , if (tt-rvs-line.state-measure-cli-qnty * v-wght / 100) = ? then "0" else string-mth(tt-rvs-line.state-measure-cli-qnty * v-wght / 100)) no-error .
      case v-type :
        when "1"
        then do :
          sw:write-data-element ("calc-dnst" , string-mth(tt-rvs-line.density)) no-error .
          sw:write-data-element ("calc-dnst-fact" , string-mth(v-dnsty)) no-error .
          sw:write-data-element ("calc-dnst-discrepancy" , string-mth(v-test-asi-diff)) no-error .
          sw:write-data-element ("calc-dnst-discrepancy-gram" , string-mth(v-test-asi-diff / 1000)) no-error .
        end .
        when "2"
        then do :
          sw:write-data-element ("pomi-wght" , string-mth(v-POkMI-mass)) no-error .
          sw:write-data-element ("pomi-rel-me" , string-mth(v-POkMI-otn-delta-mass)) no-error .
          sw:write-data-element ("pomi-dnst" , string-mth(v-POkMI-standart-dens)) no-error .
          sw:write-data-element ("pomi-vlm-st" , string-mth(v-POkMI-standart-vol)) no-error .
          sw:write-data-element ("pomi-vlm-tv" , string-mth(v-POkMI-vol)) no-error .
          sw:write-data-element ("pomi-wtr" , string-mth(v-POkMI-water-vol)) no-error .
          sw:write-data-element ("calc-dnst" , string-mth(tt-rvs-line.density)) no-error .
          sw:write-data-element ("calc-dnst-fact" , string-mth(v-POkMI-standart-dens)) no-error .
          sw:write-data-element ("calc-dnst-discrepancy" , string-mth(v-test-asi-diff)) no-error .
          sw:write-data-element ("calc-dnst-above" , string-mth(v-ASI-POkMI-standart-dens)) no-error .
          sw:write-data-element ("calc-dnst-discrepancy-gram" , string-mth(v-test-asi-diff / 1000)) no-error .
        end .
        when "3"
        then do :
          sw:write-data-element ("pomi-wght" , string-mth(v-POkMI-mass)) no-error .
          sw:write-data-element ("pomi-rel-me" , string-mth(v-POkMI-otn-delta-mass)) no-error .
          sw:write-data-element ("pomi-dnst" , string-mth(v-POkMI-standart-dens)) no-error .
          sw:write-data-element ("pomi-vlm-st" , string-mth(v-POkMI-standart-vol)) no-error .
          sw:write-data-element ("pomi-vlm-tv" , string-mth(v-POkMI-vol)) no-error .
          sw:write-data-element ("pomi-wtr" , string-mth(v-POkMI-water-vol)) no-error .
          sw:write-data-element ("calc-wght" , string-mth(tt-rvs-line.measure-cli-qnty)) no-error .
          sw:write-data-element ("calc-wght-fact" , string-mth(tt-rvs-line.state-measure-cli-qnty)) no-error .
          sw:write-data-element ("calc-wght-discrepancy" , string-mth(v-test-asi-diff)) no-error .
          sw:write-data-element ("calc-wght-discrepancy-kilo" , string-mth(ABS(tt-rvs-line.state-measure-cli-qnty - tt-rvs-line.measure-cli-qnty))) no-error .
        end .
      end case .
      sw:end-element ("tank")  .
    end .
    sw:end-element ("tanks")  .
    sw:start-element ("comp-comm") .
      find first buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = tt-rvs-doc.rvs-code
                                            and buf_rvs-doc-attr.attr-code = "test-asi-commission-1"
                                            no-error .
      if available buf_rvs-doc-attr
      and num-entries(buf_rvs-doc-attr.attr-value, chr(4)) = 2
      then do :
        sw:write-data-element ("chairmen1", entry(1, buf_rvs-doc-attr.attr-value, chr(4))) no-error .
      end .
      find first buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = tt-rvs-doc.rvs-code
                                            and buf_rvs-doc-attr.attr-code = "test-asi-commission-2"
                                            no-error .
      if available buf_rvs-doc-attr
      and num-entries(buf_rvs-doc-attr.attr-value, chr(4)) = 2
      then do :
        sw:write-data-element ("chairmen2", entry(1, buf_rvs-doc-attr.attr-value, chr(4))) no-error .
      end .
      find first buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = tt-rvs-doc.rvs-code
                                            and buf_rvs-doc-attr.attr-code = "test-asi-commission-3"
                                            no-error .
      if available buf_rvs-doc-attr
      and num-entries(buf_rvs-doc-attr.attr-value, chr(4)) = 2
      then do :
        sw:write-data-element ("chairmen3", entry(1, buf_rvs-doc-attr.attr-value, chr(4))) no-error .
      end .
      find first buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = tt-rvs-doc.rvs-code
                                            and buf_rvs-doc-attr.attr-code = "test-asi-commission-4"
                                            no-error .
      if available buf_rvs-doc-attr
      and num-entries(buf_rvs-doc-attr.attr-value, chr(4)) = 2
      then do :
        sw:write-data-element ("chairmen4", entry(1, buf_rvs-doc-attr.attr-value, chr(4))) no-error .
      end .
      find first buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = tt-rvs-doc.rvs-code
                                            and buf_rvs-doc-attr.attr-code = "test-asi-commission-5"
                                            no-error .
      if available buf_rvs-doc-attr
      and num-entries(buf_rvs-doc-attr.attr-value, chr(4)) = 2
      then do :
        sw:write-data-element ("chairmen5", entry(1, buf_rvs-doc-attr.attr-value, chr(4))) no-error .
      end .
      find first buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = tt-rvs-doc.rvs-code
                                            and buf_rvs-doc-attr.attr-code = "test-asi-commission-1"
                                            no-error .
      if available buf_rvs-doc-attr
      and num-entries(buf_rvs-doc-attr.attr-value, chr(4)) = 2
      then do :
        sw:write-data-element ("jobtitle1", entry(2, buf_rvs-doc-attr.attr-value, chr(4))) no-error .
      end .
      find first buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = tt-rvs-doc.rvs-code
                                            and buf_rvs-doc-attr.attr-code = "test-asi-commission-2"
                                            no-error .
      if available buf_rvs-doc-attr
      and num-entries(buf_rvs-doc-attr.attr-value, chr(4)) = 2
      then do :
        sw:write-data-element ("jobtitle2", entry(2, buf_rvs-doc-attr.attr-value, chr(4))) no-error .
      end .
      find first buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = tt-rvs-doc.rvs-code
                                            and buf_rvs-doc-attr.attr-code = "test-asi-commission-3"
                                            no-error .
      if available buf_rvs-doc-attr
      and num-entries(buf_rvs-doc-attr.attr-value, chr(4)) = 2
      then do :
        sw:write-data-element ("jobtitle3", entry(2, buf_rvs-doc-attr.attr-value, chr(4))) no-error .
      end .
      find first buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = tt-rvs-doc.rvs-code
                                            and buf_rvs-doc-attr.attr-code = "test-asi-commission-4"
                                            no-error .
      if available buf_rvs-doc-attr
      and num-entries(buf_rvs-doc-attr.attr-value, chr(4)) = 2
      then do :
        sw:write-data-element ("jobtitle4", entry(2, buf_rvs-doc-attr.attr-value, chr(4))) no-error .
      end .
      find first buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = tt-rvs-doc.rvs-code
                                            and buf_rvs-doc-attr.attr-code = "test-asi-commission-5"
                                            no-error .
      if available buf_rvs-doc-attr
      and num-entries(buf_rvs-doc-attr.attr-value, chr(4)) = 2
      then do :
        sw:write-data-element ("jobtitle5", entry(2, buf_rvs-doc-attr.attr-value, chr(4))) no-error .
      end .
    sw:end-element ("comp-comm")  .
    sw:end-element ("check-correct-doc")  .
    return .
  end method .
  method private void expCheckFuelDoc() :
    InitSecTag = "check-fuel-docs" .
    v-input-type-list = '' .
    for each tt-rvs-line no-lock :
      for first buf_rvs-line-attr no-lock
        where buf_rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        and buf_rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        and buf_rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        and buf_rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        and buf_rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
        and buf_rvs-line-attr.attr-code = 'input-type-p':
        v-input-type-list = v-input-type-list + ',' + buf_rvs-line-attr.attr-value .
      end.
      for first buf_rvs-line-attr no-lock
        where buf_rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        and buf_rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        and buf_rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        and buf_rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        and buf_rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
        and buf_rvs-line-attr.attr-code = 'input-type-t':
        v-input-type-list = v-input-type-list + ',' + buf_rvs-line-attr.attr-value .
      end.
      for first buf_rvs-line-attr no-lock
        where buf_rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        and buf_rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        and buf_rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        and buf_rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        and buf_rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
        and buf_rvs-line-attr.attr-code = 'input-type-l':
        v-input-type-list = v-input-type-list + ',' + buf_rvs-line-attr.attr-value .
      end.
    end.
    v-input-type-list = left-trim(v-input-type-list, ",") .
    if can-do(v-input-type-list, 'а')
    and not can-do(v-input-type-list, 'ф')
    and not can-do(v-input-type-list, 'ак')
    and not can-do(v-input-type-list, 'фк')
    and not can-do(v-input-type-list, 'п')
    then v-doc-input-type = 'а'.
    if can-do(v-input-type-list, 'ф')
    and not can-do(v-input-type-list, 'а')
    and not can-do(v-input-type-list, 'ак')
    and not can-do(v-input-type-list, 'фк')
    and not can-do(v-input-type-list, 'п')
    then v-doc-input-type = 'ф'.
    if  not can-do(v-input-type-list, 'ф')
    and can-do(v-input-type-list, 'ак')
    and not can-do(v-input-type-list, 'п')
    then v-doc-input-type = 'ак'.
    if ((can-do(v-input-type-list, 'ф')
    or can-do(v-input-type-list, 'п'))
    and can-do(v-input-type-list, 'а'))
    or can-do(v-input-type-list, 'фк')
    then v-doc-input-type = 'фк'.
    if can-do(v-input-type-list, 'р')
    and not can-do(v-input-type-list, 'а')
    and not can-do(v-input-type-list, 'ф')
    and not can-do(v-input-type-list, 'к')
    and not can-do(v-input-type-list, 'п')
    then v-doc-input-type = 'р'.
    if v-doc-input-type = 'а'
    and (can-do(v-input-type-list, 'р')
      or can-do(v-input-type-list, ''))
    then v-doc-input-type = 'ак'.
    if v-doc-input-type = 'ф'
    and (can-do(v-input-type-list, 'р')
      or can-do(v-input-type-list, ''))
    then v-doc-input-type = 'фк'.
    define variable v-out-code as character no-undo .
    sw:start-element ("check-fuel-doc") .
    sw:write-data-element ("doc-code", if tt-rvs-doc.rvs-code = ? then "" else string(tt-rvs-doc.rvs-code)) no-error .
    sw:write-data-element ("doc-num", if tt-rvs-doc.rvs-code = ? then "" else string(tt-rvs-doc.rvs-code)) no-error .
    sw:write-data-element ("doc-date", if tt-rvs-doc.doc-date = ? then "" else iso-date(datetime(tt-rvs-doc.doc-date, (tt-rvs-doc.fact-time * 1000 )))).
    sw:write-data-element ("doc-date-f", if tt-rvs-doc.sys-date = ? then "" else iso-date(datetime(tt-rvs-doc.sys-date, (tt-rvs-doc.sys-time-int * 1000 )))).
    sw:write-data-element ("del-f", if tt-rvs-doc.del-f = ? then "" else string(tt-rvs-doc.del-f)) no-error .
    sw:write-data-element ("doc-type", string(v-type)) no-error .
    if v-type = "4" then do:
      if tt-rvs-doc.out-code = ? then do:
        if num-entries(tt-rvs-doc.PS,"№") > 1 then do:
          v-out-code = entry(2,tt-rvs-doc.PS,"№") .
          v-out-code = replace (v-out-code,".","") .
          v-out-code = trim(v-out-code," ").
        end.
        sw:write-data-element ("parent-doc", v-out-code) no-error .
      end.
      else sw:write-data-element ("parent-doc", tt-rvs-doc.out-code) no-error .
    end.
    sw:write-data-element ("inp-type", v-doc-input-type).
    sw:write-data-element ("shift-date", if tt-rvs-doc.shift-date = ? then "" else iso-date(tt-rvs-doc.shift-date)) no-error .
    sw:write-data-element ("shift-num", if tt-rvs-doc.shift-num = ? then "" else string(tt-rvs-doc.shift-num)) no-error .
    sw:write-data-element ("auto-cr", string(v-autorvs)) no-error .
    if tt-rvs-doc.out-code > "" then sw:write-data-element ("out-code", tt-rvs-doc.out-code).
    else sw:write-empty-element ("out-code").
    sw:write-data-element ("operator", if v-user-name = ? then "" else string(v-user-name)) no-error .
    sw:start-element ("tanks") .
    for each tt-rvs-line no-lock:
      v-is-sug = no .
      for first goods-attr no-lock where goods-attr.gds-code = tt-rvs-line.gds-code
                                     and goods-attr.attr-code = 'fuel-type':U
                                     :
        v-is-sug = logical(goods-attr.attr-value = 'lgas':U) no-error .
      end .
      if not v-is-sug
      then do :
        varmeasure-water-qnty = (tt-rvs-line.brutto-qnty - tt-rvs-line.measure-qnty) .
      end .
      assign
        v-dnsty = ?
        v-wght = ?
        v-ex-df = ?
        v-line-input-type-p = ""
        v-line-input-type-T = ""
        v-line-input-type-l = ""
        v-dens-sug = ?
        v-pres-sug = ?
        v-dens-sug-fact = ?
        v-pres-sug-fact = ?
        v-temp-izm-vol = ?
        v-dnst-mi = ""
        v-lvl-mi = ""
        v-tmp-mi = ""
        sr-type-temp = ?
        v-izm-temps = ""
        sr-type-dens = ?
        v-izm-denses = ""
        v-POkMI-result-attr = ""
        varmeasure-water-qnty = ?
        varstate-water-qnty = ?
      .
      for each buf_rvs-line-attr no-lock
        where buf_rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        and buf_rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        and buf_rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        and buf_rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        and buf_rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code:
        case buf_rvs-line-attr.attr-code:
          when "izmer-density" then
            do:
              v-dnsty = decimal(buf_rvs-line-attr.attr-value) .
            end.
          when "delta-mass-qnty" then
            do:
              v-wght = decimal(buf_rvs-line-attr.attr-value) .
            end.
          when "CriticalDif" then
            do:
              v-ex-df = decimal(buf_rvs-line-attr.attr-value) .
            end.
          when "input-type-p" then
            do:
              v-line-input-type-p = buf_rvs-line-attr.attr-value .
              if length(v-line-input-type-p) = 2 then v-line-input-type-p = substring(v-line-input-type-p, 2, 1) .
            end.
          when "input-type-T" then
            do:
              v-line-input-type-T = buf_rvs-line-attr.attr-value .
              if length(v-line-input-type-T) = 2 then v-line-input-type-T = substring(v-line-input-type-T, 2, 1) .
            end.
          when "input-type-l" then
            do:
              v-line-input-type-l = buf_rvs-line-attr.attr-value .
              if length(v-line-input-type-l) = 2 then v-line-input-type-l = substring(v-line-input-type-l, 2, 1) .
            end.
          when "dens-pf-sug" then
            do:
              v-dens-sug = decimal(buf_rvs-line-attr.attr-value) .
            end.
          when "pressure-sug" then
            do:
              v-pres-sug = decimal(buf_rvs-line-attr.attr-value) .
            end.
          when "state-dens-pf-sug" then
            do:
              v-dens-sug-fact = decimal(buf_rvs-line-attr.attr-value) .
            end.
          when "state-pressure-sug" then
            do:
              v-pres-sug-fact = decimal(buf_rvs-line-attr.attr-value) .
            end.
          when "temp-izm-vol" then
            do:
              v-temp-izm-vol = decimal(buf_rvs-line-attr.attr-value) .
            end.
          when "mi-dnst" then
            do:
              v-dnst-mi = buf_rvs-line-attr.attr-value .
            end.
          when "mi-lvl" then
            do:
              v-lvl-mi = buf_rvs-line-attr.attr-value .
            end.
          when "mi-tmp" then
            do:
              v-tmp-mi = buf_rvs-line-attr.attr-value .
            end.
          when "izm-temps" then
            do:
              sr-type-temp = integer(entry(1, buf_rvs-line-attr.attr-value, ";")) no-error .
              v-izm-temps = entry(2, buf_rvs-line-attr.attr-value, ";") no-error .
            end.
          when "izm-denses" then
            do:
              sr-type-dens = integer(entry(1, buf_rvs-line-attr.attr-value, ";")) no-error .
              v-izm-denses = entry(2, buf_rvs-line-attr.attr-value, ";") no-error .
            end.
          when "POkMI-result" then
            do:
              v-POkMI-result-attr = buf_rvs-line-attr.attr-value .
              if v-is-sug
              then do :
                v-POkMI-mass            = decimal(entry(2, entry(1, v-POkMI-result-attr, chr(10)), ":")) no-error .
                v-POkMI-otn-delta-mass  = decimal(entry(2, entry(2, v-POkMI-result-attr, chr(10)), ":")) no-error .
                v-POkMI-standart-vol    = decimal(entry(2, entry(3, v-POkMI-result-attr, chr(10)), ":")) no-error .
              end .
              else do :
                v-POkMI-mass            = decimal(entry(2, entry(1, v-POkMI-result-attr, chr(10)), ":")) no-error .
                v-POkMI-otn-delta-mass  = decimal(entry(2, entry(2, v-POkMI-result-attr, chr(10)), ":")) no-error .
                v-POkMI-standart-dens   = decimal(entry(2, entry(3, v-POkMI-result-attr, chr(10)), ":")) no-error .
                v-POkMI-standart-vol    = decimal(entry(2, entry(4, v-POkMI-result-attr, chr(10)), ":")) no-error .
                v-POkMI-vol             = decimal(entry(2, entry(5, v-POkMI-result-attr, chr(10)), ":")) no-error .
                v-POkMI-water-vol       = decimal(entry(2, entry(6, v-POkMI-result-attr, chr(10)), ":")) no-error .
              end .
            end .
          when "sug-water-qnty" then
            do:
              if v-is-sug
              then do :
                varmeasure-water-qnty = decimal(buf_rvs-line-attr.attr-value) .
                varstate-water-qnty = varmeasure-water-qnty .
              end .
            end.
          when "pokmi-water-qnty" then
            do:
              if not v-is-sug
              then do :
                varstate-water-qnty = decimal(buf_rvs-line-attr.attr-value) .
              end .
            end.
          when "measure-water-qnty" then
            do:
              varmeasure-water-qnty = decimal(buf_rvs-line-attr.attr-value) .
            end.
        end case .
      end.
      if v-wght = ? then v-wght = 0 .
      if v-ex-df = ? then v-ex-df = 0 .
      if v-dens-sug-fact = 0 or v-dens-sug-fact = ? then v-dens-sug-fact = v-dens-sug .
      if v-pres-sug-fact = 0 or v-pres-sug-fact = ? then v-pres-sug-fact = v-pres-sug .
      find first buf_place-attr no-lock where buf_place-attr.attr-code   = "place-error-mass"
                                          and buf_place-attr.obj-code    = tt-rvs-line.obj-code
                                          and buf_place-attr.obj-type    = tt-rvs-line.obj-type
                                          and buf_place-attr.pl-code     = tt-rvs-line.pl-code no-error.
      if available buf_place-attr
      then do :
        er-wght-pipeline = tt-rvs-line.state-add-qnty * tt-rvs-line.state-density * decimal(buf_place-attr.attr-value) / 100 no-error.
      end.
      else er-wght-pipeline = ? .
      sw:start-element ("tank") .
      sw:write-data-element ("tank-num"  , if tt-rvs-line.pl-code = ? then "0" else string(tt-rvs-line.pl-code)) no-error .
      sw:write-data-element ("gd-code"  , if tt-rvs-line.gds-code = ? then "0" else string(tt-rvs-line.gds-code)) no-error .
      sw:write-data-element ("tank-ost" , if tt-rvs-line.measure-qnty = ? then "0" else string(tt-rvs-line.measure-qnty)) no-error .
      sw:write-data-element ("tank-ost-tc" , if tt-rvs-line.measure-tc-qnty = ? then "0" else string-mth(tt-rvs-line.measure-tc-qnty)) no-error .
      sw:write-data-element ("tank-dnst" , if tt-rvs-line.density = ? then "0" else string-mth(tt-rvs-line.density)) no-error .
      sw:write-data-element ("pipeline-qnty" , if tt-rvs-line.add-qnty = ? then "0" else string-mth(tt-rvs-line.add-qnty)) no-error .
      sw:write-data-element ("tank-ost-br" , if tt-rvs-line.brutto-qnty = ? then "0" else string-mth(tt-rvs-line.brutto-qnty)) no-error .
      sw:write-data-element ("tank-ost-br-tc" , if tt-rvs-line.brutto-tc-qnty = ? then "0" else string-mth(tt-rvs-line.brutto-tc-qnty)) no-error .
      sw:write-data-element ("tank-wtr" , if varmeasure-water-qnty = ? then "0" else string-mth(varmeasure-water-qnty)) no-error .
      sw:write-data-element ("tank-wght" , if tt-rvs-line.measure-cli-qnty = ? then "0" else string-mth(tt-rvs-line.measure-cli-qnty)) no-error .
      sw:write-data-element ("tank-wght-br" , if tt-rvs-line.brutto-cli-qnty = ? then "0" else string-mth(tt-rvs-line.brutto-cli-qnty)) no-error .
      sw:write-data-element ("tank-wtr-wght" , if varmeasure-water-qnty = ? then "0" else string-mth(varmeasure-water-qnty)) no-error .
      sw:write-data-element ("tank-lvl" , if tt-rvs-line.level-petrol = ? then "0" else string-mth(tt-rvs-line.level-petrol)) no-error .
      sw:write-data-element ("tank-cmn-lvl" , if tt-rvs-line.level-total = ? then "0" else string-mth(tt-rvs-line.level-total)) no-error .
      sw:write-data-element ("tnk-wtr-lvl" , if tt-rvs-line.level-water = ? then "0" else string-mth(tt-rvs-line.level-water)) no-error .
      if tt-rvs-line.temperature = ?
      then
        sw:write-empty-element ("tnk-t") .
      else
        sw:write-data-element ("tnk-t" , string-mth(tt-rvs-line.temperature)) no-error .
      if tt-rvs-line.temp-layer1 = ?
      then
        sw:write-empty-element ("tnk-t1") .
      else
        sw:write-data-element ("tnk-t1" , string-mth(tt-rvs-line.temp-layer1)) no-error .
      if tt-rvs-line.temp-layer2 = ?
      then
        sw:write-empty-element ("tnk-t2") .
      else
        sw:write-data-element ("tnk-t2" , string-mth(tt-rvs-line.temp-layer2)) no-error .
      if tt-rvs-line.temp-layer3 = ?
      then
        sw:write-empty-element ("tnk-t3") .
      else
        sw:write-data-element ("tnk-t3" , string-mth(tt-rvs-line.temp-layer3)) no-error .
      sw:write-data-element ("tnk-flng" , if tt-rvs-line.meas-cf-qnty = ? then "0" else string-mth(tt-rvs-line.meas-cf-qnty)) no-error .
      if v-dnst-mi > "" then sw:write-data-element ("dnst-mi" , v-dnst-mi) no-error .
      if v-line-input-type-p > "" then sw:write-data-element ("inp-type-p" , v-line-input-type-p) no-error .
      if v-lvl-mi > "" then sw:write-data-element ("lvl-mi" , v-lvl-mi) no-error .
      if v-line-input-type-l > "" then sw:write-data-element ("inp-type-l" , v-line-input-type-l) no-error .
      if v-tmp-mi > "" then sw:write-data-element ("tmp-mi" , v-tmp-mi) no-error .
      if v-line-input-type-t > "" then sw:write-data-element ("inp-type-t" , v-line-input-type-t) no-error .
      if v-dens-sug <> ? and v-dens-sug <> 0 then sw:write-data-element ("tnk-dens-sug" , string-mth(v-dens-sug)) no-error .
      if v-pres-sug <> ? and v-pres-sug <> 0 then sw:write-data-element ("tnk-pres-sug" , string-mth(v-pres-sug)) no-error .
      sw:write-data-element ("tank-ost-fact" , if tt-rvs-line.state-measure-qnty = ? then "0" else string-mth(tt-rvs-line.state-measure-qnty)) no-error .
      sw:write-data-element ("tank-ost-tc-fact" , if tt-rvs-line.state-measure-tc-qnty = ? then "0" else string-mth(tt-rvs-line.state-measure-tc-qnty)) no-error .
      sw:write-data-element ("tank-dnst-fact" , if tt-rvs-line.state-density = ? then "0" else string-mth(tt-rvs-line.state-density)) no-error .
      sw:write-data-element ("pipeline-qnty-fact" , if tt-rvs-line.state-add-qnty = ? then "0" else string-mth(tt-rvs-line.state-add-qnty)) no-error .
      sw:write-data-element ("pipeline-wght-fact" , if tt-rvs-line.state-add-qnty * tt-rvs-line.state-density = ? then "0" else string-mth(tt-rvs-line.state-add-qnty * tt-rvs-line.state-density)) no-error .
      sw:write-data-element ("er-wght-pipeline" , if er-wght-pipeline = ? then "0" else string-mth(er-wght-pipeline)) no-error .
      sw:write-data-element ("tank-ost-br-fact" , if tt-rvs-line.state-brutto-qnty = ? then "0" else string-mth(tt-rvs-line.state-brutto-qnty)) no-error .
      sw:write-data-element ("tank-ost-br-tc-fact" , if tt-rvs-line.state-brutto-tc-qnty = ? then "0" else string-mth(tt-rvs-line.state-brutto-tc-qnty)) no-error .
      sw:write-data-element ("tank-wtr-fact" , if varstate-water-qnty = ? then "0" else string-mth(varstate-water-qnty)) no-error .
      sw:write-data-element ("tank-wght-fact" , if tt-rvs-line.state-measure-cli-qnty = ? then "0" else string-mth(tt-rvs-line.state-measure-cli-qnty)) no-error .
      sw:write-data-element ("tank-wght-br-fact" , if tt-rvs-line.state-brutto-cli-qnty = ? then "0" else string-mth(tt-rvs-line.state-brutto-cli-qnty)) no-error .
      sw:write-data-element ("tank-wtr-wght-fact" , if varstate-water-qnty = ? then "0" else string-mth(varstate-water-qnty)) no-error .
      sw:write-data-element ("tank-lvl-fact" , if tt-rvs-line.state-level-petrol = ? then "0" else string-mth(tt-rvs-line.state-level-petrol)) no-error .
      sw:write-data-element ("tank-cmn-lvl-fact" , if tt-rvs-line.state-level-total = ? then "0" else string-mth(tt-rvs-line.state-level-total)) no-error .
      sw:write-data-element ("tnk-wtr-lvl-fact" , if tt-rvs-line.state-level-water = ? then "0" else string-mth(tt-rvs-line.state-level-water)) no-error .
      if not v-is-sug
      then
        sw:write-data-element ("tnk-t-vlm-fact" , if v-temp-izm-vol = ? then "0" else string-mth(v-temp-izm-vol)) no-error .
      sw:write-data-element ("tnk-t-average-fact" , if tt-rvs-line.state-temperature = ? then "0" else string-mth(tt-rvs-line.state-temperature)) no-error .
      case sr-type-temp :
        when 0
        then
        do it = 1 to num-entries(v-izm-temps) :
          sw:write-data-element (substitute("tnk-t&1-fact", string(it)) , string-mth(decimal(entry(it, v-izm-temps)))) no-error .
        end .
        when 1
        then
        do it = 1 to num-entries(v-izm-temps) :
          if it = 1
          then
            sw:write-data-element ("tnk-t-low-fact" , string-mth(decimal(entry(it, v-izm-temps)))) no-error .
          if it = 2
          then
            sw:write-data-element ("tnk-t-mid-fact" , string-mth(decimal(entry(it, v-izm-temps)))) no-error .
          if it = 3
          then
            sw:write-data-element ("tnk-t-upp-fact" , string-mth(decimal(entry(it, v-izm-temps)))) no-error .
        end .
      end case .
      sw:write-data-element ("tnk-flng-fact" , if tt-rvs-line.state-cf-qnty = ? then "0" else string-mth(tt-rvs-line.state-cf-qnty)) no-error .
      if v-dens-sug-fact <> ? and v-dens-sug-fact <> 0 then sw:write-data-element ("tnk-dens-sug-fact" , string-mth(v-dens-sug-fact)) no-error .
      if v-pres-sug-fact <> ? and v-pres-sug-fact <> 0 then sw:write-data-element ("tnk-pres-sug-fact" , string-mth(v-pres-sug-fact)) no-error .
      if not v-is-sug
      then
        sw:write-data-element ("ms-dnsty-average" , if v-dnsty = ? then "0" else string-mth(v-dnsty)) no-error .
      case sr-type-dens :
        when 0
        then
        do id = 1 to num-entries(v-izm-denses) :
          sw:write-data-element (substitute("ms-dnsty&1", string(id)) , string-mth(decimal(entry(id, v-izm-denses)))) no-error .
        end .
        when 1
        then
        do id = 1 to num-entries(v-izm-denses) :
          if id = 1
          then
            sw:write-data-element ("ms-dnsty-low" , string-mth(decimal(entry(id, v-izm-denses)))) no-error .
          if id = 2
          then
            sw:write-data-element ("ms-dnsty-mid" , string-mth(decimal(entry(id, v-izm-denses)))) no-error .
          if id = 3
          then
            sw:write-data-element ("ms-dnsty-upp" , string-mth(decimal(entry(id, v-izm-denses)))) no-error .
        end .
      end case .
      sw:write-data-element ("er-wght" , string-mth(v-wght)) no-error .
      sw:write-data-element ("abs-er-wght" , if (tt-rvs-line.state-measure-cli-qnty * v-wght / 100) = ? then "0" else string-mth(tt-rvs-line.state-measure-cli-qnty * v-wght / 100)) no-error .
      sw:write-data-element ("ex-df" , string-mth(v-ex-df)) no-error .
      sw:write-data-element ("pomi-wght" , string-mth(v-POkMI-mass)) no-error .
      sw:write-data-element ("pomi-rel-me" , string-mth(v-POkMI-otn-delta-mass)) no-error .
      if not v-is-sug
      then
        sw:write-data-element ("pomi-dnst" , string-mth(v-POkMI-standart-dens)) no-error .
      sw:write-data-element ("pomi-vlm-st" , string-mth(v-POkMI-standart-vol)) no-error .
      if not v-is-sug
      then
        sw:write-data-element ("pomi-vlm-tv" , string-mth(v-POkMI-vol)) no-error .
      if not v-is-sug
      then
        sw:write-data-element ("pomi-wtr" , string-mth(v-POkMI-water-vol)) no-error .
      sw:end-element ("tank")  .
    end.
    sw:end-element ("tanks")  .
    find first tt-rvs-line-pump no-error .
    if available (tt-rvs-line-pump) then do:
    sw:start-element ("trk-ps") .
    for each tt-rvs-line-pump :
      v-pl-code = getTankNum
              (input tt-rvs-line-pump.obj-type
              ,input tt-rvs-line-pump.obj-code
              ,input tt-rvs-line-pump.pump-code
              ,input tt-rvs-line-pump.nozzle-code
              ,input ?
              ,input ?
              ,input tt-rvs-line-pump.gds-code
              ) .
      if v-pl-code = ?
      or v-pl-code = "0"
      then
        v-pl-code = string(tt-rvs-line-pump.pl-code)
      .
      sw:start-element ("trk-p") .
      sw:write-data-element ("tank-num" , if v-pl-code = ? then "0" else v-pl-code) no-error .
      sw:write-data-element ("trk-num" , if tt-rvs-line-pump.pump-code = ? then "0" else string-mth(tt-rvs-line-pump.pump-code)) no-error .
      sw:write-data-element ("trk-p-num" , if tt-rvs-line-pump.nozzle-code = ? then "0" else string-mth(tt-rvs-line-pump.nozzle-code)) no-error .
      sw:write-data-element ("cnt-el" , if tt-rvs-line-pump.meas-el-cnt = ? then "0" else string-mth(tt-rvs-line-pump.meas-el-cnt)) no-error .
      sw:write-data-element ("sum-cnt-el" , if tt-rvs-line-pump.meas-am-cnt = ? then "0" else string-mth(tt-rvs-line-pump.meas-am-cnt)) no-error .
      sw:write-data-element ("qnty" , if tt-rvs-line-pump.meas-cf-cnt = ? then "0" else string-mth(tt-rvs-line-pump.meas-cf-cnt)) no-error .
      sw:write-data-element ("cnt-meh" , if tt-rvs-line-pump.meas-mh-cnt = ? then "0" else string-mth(tt-rvs-line-pump.meas-mh-cnt)) no-error .
      sw:write-data-element ("cnt-ob" , if tt-rvs-line-pump.meas-mh-qnty = ? then "0" else string-mth(tt-rvs-line-pump.meas-mh-qnty)) no-error .
      sw:write-data-element ("sum-cnt-ob" , if tt-rvs-line-pump.meas-am-qnty = ? then "0" else string-mth(tt-rvs-line-pump.meas-am-qnty)) no-error .
      sw:write-data-element ("qnty-nal" , if tt-rvs-line-pump.meas-cf-qnty = ? then "0" else string-mth(tt-rvs-line-pump.meas-cf-qnty)) no-error .
      sw:write-data-element ("cnt-el-fact" , if tt-rvs-line-pump.state-el-cnt = ? then "0" else string-mth(tt-rvs-line-pump.state-el-cnt)) no-error .
      sw:write-data-element ("sum-fact" , if tt-rvs-line-pump.state-am-cnt = ? then "0" else string-mth(tt-rvs-line-pump.state-am-cnt)) no-error .
      sw:write-data-element ("qnty-fact" , if tt-rvs-line-pump.state-cf-cnt = ? then "0" else string-mth(tt-rvs-line-pump.state-cf-cnt)) no-error .
      sw:write-data-element ("cnt-meh-fact" , if tt-rvs-line-pump.state-mh-cnt = ? then "0" else string-mth(tt-rvs-line-pump.state-mh-cnt)) no-error .
      sw:write-data-element ("cnt-meh-ob" , if tt-rvs-line-pump.state-mh-qnty = ? then "0" else string-mth(tt-rvs-line-pump.state-mh-qnty)) no-error .
      sw:write-data-element ("sum-meh-ob" , if tt-rvs-line-pump.state-am-qnty = ? then "0" else string-mth(tt-rvs-line-pump.state-am-qnty)) no-error .
      sw:write-data-element ("qnty-nal-fact" , if tt-rvs-line-pump.state-cf-qnty = ? then "0" else string-mth(tt-rvs-line-pump.state-cf-qnty)) no-error .
      if v-type = "1"
      or v-type = "2"
      then do :
        if tt-rvs-line-pump.state-el-cnt = ?
        or tt-rvs-line-pump.state-el-cnt <= 0
        then do :
          sw:write-data-element ("trk-err" , "1") no-error .
        end .
        else do :
          sw:write-data-element ("trk-err" , "0") no-error .
        end .
      end .
      sw:end-element ("trk-p")  .
    end.
    sw:end-element ("trk-ps")  .
    end.
    sw:end-element ("check-fuel-doc") .
    finally :
      if valid-object(libFindtank) then delete object libFindtank .
    end finally .
  end.
  method private character getTankNum (p-obj-type    as character,
                                       p-obj-code    as integer,
                                       p-pump        as integer,
                                       p-nozzle-code as integer,
                                       p-src-pl-code as integer,
                                       p-pl-code     as integer,
                                       p-gds-code    as integer) :
    define buffer buf_place for ub.place .
    define variable v-pl-code as integer no-undo .
    define variable v-loc1    as character no-undo .
         if p-src-pl-code > 0 then v-pl-code = p-src-pl-code.
    else if p-pl-code     > 0 then v-pl-code = p-pl-code.
    else do:
      libFindtank:findtank_
      (input p-obj-type
      ,input p-obj-code
      ,input p-pump
      ,input p-nozzle-code
      ,input p-pl-code
      ,input p-gds-code
      ,output v-pl-code
      ) .
    end .
    if v-pl-code > 0 then do:
      find first buf_place no-lock where buf_place.pl-code = v-pl-code no-error .
      v-loc1 = if available buf_place then string(buf_place.pl-code) else "0" .
    end.
    else v-loc1 = "0" .
    return v-loc1 .
  end method .
  method private character string-mth (inValue as decimal):
    def var v-str as character no-undo.
    def var v-stt as decimal   no-undo.
    if inValue = ?  then v-str = "0".
    if inValue < 0 then
    do:
      v-stt = inValue .
      inValue = abs(v-stt).
    end.
    if string (inValue) begins "."
      then v-str = "0" + string (inValue).
    else v-str = string (inValue).
    if v-stt <> 0 then v-str = "-" + v-str.
    return v-str.
  end.
end class.
