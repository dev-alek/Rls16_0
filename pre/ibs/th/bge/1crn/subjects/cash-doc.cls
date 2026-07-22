using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.cash-doc implements iexpsubject:
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
method private void xmlchar-test (input  p-in-string          as character,
                                  output p-out-string-enc     as character,
                                  output p-out-string-dec    as character):
do
on error undo, return error
:
       xmlchar-encode
    (
          input p-in-string
        , output p-out-string-enc
    ).
       xmlchar-decode
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
method private void xmlchar-encode (input  p-in-string          as character,
                                  output p-out-string         as character):
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
method private character  xmlchar-encode-1c (input  p-in-string          as character):
define variable p-out-string as character no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
return p-out-string.
end .
method private void xmlchar-decode (input  p-in-string          as character,
                                  output p-out-string         as character):
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    xmlchar-read-integer
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
method private void xmlchar-read-integer (input  p-input-string       as character,
                                          output p-output-integer     as integer,
                                          output p-success            as logical):
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
  define temp-table tt-coins no-undo XML-NODE-NAME "coins" serialize-name  "coins"
  field id       as decimal
  field qnty     as decimal
  field sum-qnty as decimal
  index pi is primary unique id desc.
define temp-table tt-banknots no-undo XML-NODE-NAME "banknots" serialize-name  "banknots"
  field id       as integer
  field qnty     as integer
  field sum-qnty as integer
  index pi is primary unique id desc.
define temp-table tt-cover-sheet no-undo
  field num-bag      as character
  field depos-code   as integer
  field depos-bank   as character
  field repos-code   as integer
  field repos-bank   as character
  field pin02        as character
  field source_      as character
  field total-sum    as decimal
  index pi num-bag
.
define dataset ds-banknots XML-NODE-NAME "money" serialize-name  "money" for tt-banknots,
  tt-coins .
define         variable hQueryCoins                           as handle                                         no-undo .
define         variable hQueryBanknot                         as handle                                         no-undo .
method private handle add_Coints():
   define variable v-list-coints as character no-undo .
   define variable ii            as integer   no-undo .
   v-list-coints = "10;5;2;1;0.5;0.1;0.05" .
    define variable ddd as decimal no-undo.
    do ii = 1 to num-entries (v-list-coints,";"):
      find first tt-coins where tt-coins.id       = decimal (entry(ii,v-list-coints,";"))
      no-error.
      if not available tt-coins
      then do:
         create tt-coins .
         assign
           tt-coins.id       = decimal(entry(ii,v-list-coints,";"))
           tt-coins.qnty     = 0
           tt-coins.sum-qnty = 0
           .
       end.
    end.
end.
method private handle getq_Coints():
if valid-handle(hQueryCoins)  then delete object hQueryCoins.
    create query hQueryCoins.
    hQueryCoins:set-buffers(buffer tt-coins:HANDLE).
    hQueryCoins:query-prepare("FOR EACH tt-coins by tt-coins.id desc").
    hQueryCoins:query-open.
    return hQueryCoins.
end.
method private handle add_Banknot():
   define variable v-list-banknot as character no-undo .
   define variable ii             as integer   no-undo .
   v-list-banknot = "5000;2000;1000;500;200;100;50;10" .
    do ii = 1 to num-entries (v-list-banknot,";"):
      find first tt-banknots where tt-banknots.id       = integer(entry(ii,v-list-banknot,";"))
      no-error.
      if not available tt-banknots
      then do:
         create tt-banknots .
         assign
           tt-banknots.id       = integer(entry(ii,v-list-banknot,";"))
           tt-banknots.qnty     = 0
           tt-banknots.sum-qnty = 0
           .
       end.
    end.
end.
method private handle getq_Banknot():
   if valid-handle(hQueryBanknot)  then delete object hQueryBanknot.
    create query hQueryBanknot.
    hQueryBanknot:set-buffers(buffer tt-banknots:HANDLE).
    hQueryBanknot:query-prepare("FOR EACH tt-banknots by tt-banknots.id desc").
    hQueryBanknot:query-open.
    return hQueryBanknot.
end.
  define temp-table tt-fin-doc like ub.c-fin-doc .
  define temp-table tt-fin-doc-tax like ub.c-fin-doc-tax .
  define temp-table tt-fin-doc-attr no-undo
    field fin-doc      as integer
    field sumka        as character
    field banknote     as character
    field bank-resive  as integer
    field bank-deposit as integer
    field pin          as character
    field source_      as character
    field contr-kb     as character init ?
    index pi fin-doc
    .
  define property Msg as character no-undo
    get.
    private set.
  define property InitSecTag as character no-undo init "cash"
    get.
    private set.
  define public property sendTableName  as character  no-undo init "fin-doc"
    get.
  define public property sendOldRowid as rowid  no-undo
    get.
    set.
  define public property sendNewRowid as rowid  no-undo
    get.
    set.
  define property fin-doc as character no-undo
    get.
    set.
  define property del_f  as integer no-undo
    get.
    set.
  define variable sw     as handle    no-undo.
  define variable v-type as character no-undo .
  define variable CSJson as longchar  no-undo .
  method public void CrContentToSW (insw as handle):
  define buffer buf_fin-doc       for ub.fin-doc .
  define buffer buf_fin-doc-attr  for ub.fin-doc-attr .
  define buffer buf_fin-doc-tax   for ub.fin-doc-tax .
  define buffer buf_c-fin-doc     for ub.c-fin-doc .
  define buffer buf_c-fin-doc-tax for ub.c-fin-doc-tax .
  define buffer buf_CashBook      for ub.CashBook .
    sw = insw .
    find first buf_fin-doc no-lock where buf_fin-doc.fin-doc-code = INTEGER (fin-doc) no-error .
    if AVAILABLE buf_fin-doc then
    do:
      sendOldRowid  = rowid(buf_fin-doc).
      create tt-fin-doc .
      BUFFER-COPY buf_fin-doc to tt-fin-doc .
      for each buf_fin-doc-tax no-lock where buf_fin-doc-tax.fin-doc-code = buf_fin-doc.fin-doc-code:
        create tt-fin-doc-tax .
        BUFFER-COPY buf_fin-doc-tax to tt-fin-doc-tax .
      end.
    end.
    else
    do:
      find FIRST buf_c-fin-doc no-lock where buf_c-fin-doc.fin-doc-code = INTEGER (fin-doc) no-error .
      if AVAILABLE buf_c-fin-doc then
      do:
        sendOldRowid  = rowid(buf_c-fin-doc).
        create tt-fin-doc .
        BUFFER-COPY buf_c-fin-doc to tt-fin-doc .
        for first buf_c-fin-doc-tax no-lock where buf_c-fin-doc-tax.fin-doc-code = buf_c-fin-doc.fin-doc-code:
          create tt-fin-doc-tax .
          BUFFER-COPY buf_c-fin-doc-tax to tt-fin-doc-tax .
        end.
      end.
      else
      do:
        Msg = "Нет финансового документа с номером " + fin-doc .
        return error Msg.
      end.
    end.
    case tt-fin-doc.fin-doc-type:
      when 'пко':U then
        v-type = "1".
      when 'рко':U then
        v-type = "2".
      when ? then
        v-type = "".
    end.
    sw:start-element ("cash-doc") .
    sw:write-data-element ("doc-code", string-mth(tt-fin-doc.fin-doc-code)).
    sw:write-data-element ("num", if tt-fin-doc.prn-doc-code = ? then "" else string(tt-fin-doc.prn-doc-code)).
    sw:write-data-element ("del-f", string(del_f)).
    find first buf_CashBook no-lock where buf_CashBook.id = tt-fin-doc.CashBookId no-error .
    if available buf_CashBook then do :
      if buf_CashBook.ext-code > "" then
        sw:write-data-element ("type-kb", buf_CashBook.ext-code).
      find first buf_fin-doc-attr no-lock where buf_fin-doc-attr.fin-doc-code = tt-fin-doc.fin-doc-code and buf_fin-doc-attr.host-code = tt-fin-doc.host-code
      and buf_fin-doc-attr.attr-code = "contr-kb" no-error .
      if available (buf_fin-doc-attr) then
      do:
         find first tt-fin-doc-attr where tt-fin-doc-attr.fin-doc = buf_fin-doc-attr.fin-doc-code no-error .
         if not available (tt-fin-doc-attr) then
         do:
            create tt-fin-doc-attr .
            assign
               tt-fin-doc-attr.fin-doc = buf_fin-doc-attr.fin-doc-code
            .
         end.
         find first cashbook where cashbook.id eq int(buf_fin-doc-attr.attr-value)
         no-lock no-error.
         if available  cashbook
         then
            assign
              tt-fin-doc-attr.contr-kb = CashBook.ext-code.
            .
       end.
    end .
    find first buf_fin-doc-attr no-lock where buf_fin-doc-attr.fin-doc-code = tt-fin-doc.fin-doc-code and buf_fin-doc-attr.host-code = tt-fin-doc.host-code
      and buf_fin-doc-attr.attr-code = "pre-vedom" no-error .
    if available (buf_fin-doc-attr) then
    do:
      find first tt-fin-doc-attr where tt-fin-doc-attr.sumka = entry (1,buf_fin-doc-attr.attr-value,";") no-error .
      if not available (tt-fin-doc-attr) then
      do:
        create tt-fin-doc-attr .
        assign
          tt-fin-doc-attr.fin-doc = buf_fin-doc-attr.fin-doc-code
          .
      end.
      assign
        tt-fin-doc-attr.sumka = entry (1,buf_fin-doc-attr.attr-value,";")
        tt-fin-doc-attr.bank-deposit = integer(entry(2,buf_fin-doc-attr.attr-value,";"))
        tt-fin-doc-attr.bank-resive  = integer(entry (3,buf_fin-doc-attr.attr-value,";"))
        tt-fin-doc-attr.pin          = entry(4,buf_fin-doc-attr.attr-value,";")
        tt-fin-doc-attr.source_      = if tt-fin-doc.CashBookId = 0 then "Поступления от продажи товаров" else "Прочие поступления"
        .
    end.
    find first buf_fin-doc-attr no-lock where buf_fin-doc-attr.fin-doc-code = tt-fin-doc.fin-doc-code and buf_fin-doc-attr.host-code = tt-fin-doc.host-code
      and buf_fin-doc-attr.attr-code = "cover_sheet" no-error .
    if available (buf_fin-doc-attr) then
    do:
      find first tt-fin-doc-attr where tt-fin-doc-attr.fin-doc = buf_fin-doc-attr.fin-doc-code no-error .
      if not available (tt-fin-doc-attr) then
      do:
        create tt-fin-doc-attr .
        assign
          tt-fin-doc-attr.fin-doc = buf_fin-doc-attr.fin-doc-code
          .
      end.
      assign
        tt-fin-doc-attr.banknote = buf_fin-doc-attr.attr-value
        .
    end.
    sw:write-data-element ("date", if tt-fin-doc.doc-date = ? then "" else ISO-DATE (tt-fin-doc.doc-date)).
    sw:write-data-element ("shift-date", if tt-fin-doc.shift-date = ? then "" else ISO-DATE (tt-fin-doc.shift-date)).
    sw:write-data-element ("shift-num", string-mth(tt-fin-doc.shift-num)).
    sw:write-data-element ("type", v-type).
    if v-type = "1"
    then do :
      if tt-fin-doc.cor-acc-value > "" then
        sw:write-data-element ("kredit", tt-fin-doc.cor-acc-value).
      if tt-fin-doc.cor-acc1-value > "" then
        sw:write-data-element ("debit", tt-fin-doc.cor-acc1-value).
    end .
    if v-type = "2"
    then do :
      if tt-fin-doc.cor-acc-value > "" then
        sw:write-data-element ("kredit", tt-fin-doc.cor-acc1-value).
      if tt-fin-doc.cor-acc1-value > "" then
        sw:write-data-element ("debit", tt-fin-doc.cor-acc-value).
    end .
    sw:write-data-element ("sum", string-mth(tt-fin-doc.sum-doc)).
    if v-type = "1" then
    do:
      sw:write-data-element ("contr-name", if tt-fin-doc.payer-name = ? then "" else string(tt-fin-doc.payer-name)).
      sw:write-data-element ("contr-code", string-mth(tt-fin-doc.payer-code)).
    end.
    else
    do:
      sw:write-data-element ("contr-name", if tt-fin-doc.receiver-name = ? then "" else string(tt-fin-doc.receiver-name)).
      sw:write-data-element ("contr-code", string-mth(tt-fin-doc.receiver-code)).
    end.
    sw:write-data-element ("doc-osn", if tt-fin-doc.naznach-plat = ? then "" else xmlchar-encode-1c(string(tt-fin-doc.naznach-plat))).
    sw:write-data-element ("pril", xmlchar-encode-1c(tt-fin-doc.enclosure)).
    sw:write-data-element ("nds-str", if tt-fin-doc.including = ? then "" else xmlchar-encode-1c(string(tt-fin-doc.including))).
    sw:write-data-element ("operator", if tt-fin-doc.user-name-doc = ? then "" else user-name(tt-fin-doc.user-name-doc)).
    sw:write-data-element ("idty-doc", if tt-fin-doc.payer-dop1 = ? then "" else xmlchar-encode-1c(string(tt-fin-doc.receiver-passport))).
    find first tt-fin-doc-attr no-lock where tt-fin-doc-attr.fin-doc = tt-fin-doc.fin-doc-code no-error .
    if available (tt-fin-doc-attr) then do:
       if     tt-fin-doc-attr.sumka ne ?
          and tt-fin-doc-attr.sumka ne ""
       then
          sw:write-data-element ("sumka", xmlchar-encode-1c(tt-fin-doc-attr.sumka)).
       if     tt-fin-doc-attr.bank-resive ne ?
          and tt-fin-doc-attr.bank-resive ne 0
       then do:
          for first ub.fin-bank no-lock where ub.fin-bank.host-code = tt-fin-doc.host-code and
                                               ub.fin-bank.code-bank = tt-fin-doc-attr.bank-resive:
          sw:write-data-element ("bank-resive",  string(ub.fin-bank.bik)).
          end.
       end.
       if     tt-fin-doc-attr.source_ ne ?
          and tt-fin-doc-attr.source_ ne ""
       then
          sw:write-data-element ("source",  string(tt-fin-doc-attr.source_)).
    end.
    find first tt-fin-doc-attr no-lock where tt-fin-doc-attr.fin-doc = tt-fin-doc.fin-doc-code no-error .
    if     available tt-fin-doc-attr
       and tt-fin-doc-attr.contr-kb ne ?
    then do:
       sw:write-data-element ("contr-kb",  tt-fin-doc-attr.contr-kb).
    end.
    sw:start-element ("ndss") .
    for each tt-fin-doc-tax no-lock where tt-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code:
      sw:start-element ("nds") .
      sw:write-data-element ("sum", string-mth(tt-fin-doc-tax.sum-line-doc)).
      sw:write-data-element ("nds-code", string-mth(tt-fin-doc-tax.vat-pc)).
      sw:write-data-element ("sum-nds", string-mth(tt-fin-doc-tax.sum-vat-line-doc)).
      sw:end-element ("nds") .
    end.
    sw:end-element ("ndss")  .
    sw:END-ELEMENT ("cash-doc") .
  end method.
  method private character string-mth (inValue as decimal):
    def var v-str as character no-undo.
    if inValue = ?
      then v-str = "0".
    if string (inValue) begins "."
      then v-str = "0" + string (inValue).
    else v-str = string (inValue).
    return v-str.
  end.
  method private character  user-name   (v-user-code as character):
    define variable v-user-name as character no-undo .
    define buffer buf_user-account for ub.user-account .
    find first buf_user-account no-lock
      where buf_user-account.user-id = v-user-code
      no-error .
    if not available buf_user-account
      then
    do:
      assign
        v-user-name = string(v-user-code)
        .
    end.
    else
    do:
      assign
        v-user-name = buf_user-account.nik
        .
    end.
    return v-user-name.
  end.
end class.
