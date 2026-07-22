using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.trg.newbcod:
  define property ReturnMsg as character no-undo
    get.
    private set.
  define variable hndl-proc-b-code as handle.
  constructor public newbcod ():
    run trg\new-bcod.p persistent (output hndl-proc-b-code) no-error.
  end constructor.
  method public void GenBCod (
    input    type-code    as character,
    output   p-b-code     as integer):
    run gen-b-code in hndl-proc-b-code (   input type-code
      ,output p-b-code) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  method public void GetNextSeq (
    input type-code     as character,
    output next-seq     as integer
    ):
    run get-next-seq in hndl-proc-b-code (   input type-code
      ,output next-seq) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  method public void GenSeqCr (
    input type-code     as character,
    input set-val      as integer
    ):
    run set-seq-cr in hndl-proc-b-code  ( input type-code
      ,input set-val) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  method public void NewBcodGenCodeRange (
    input p-db-num     as integer,
    input type-code    as character
    ):
    run new-bcod-gen-code-range in hndl-proc-b-code  ( input p-db-num
      ,input type-code) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  method public void GenNewCodRange (
    input v-db-num        as integer,
    input v-range-type    as character,
    input v-cur-code      as integer,
    input v-g#news        as logical,
    input v-g#db-num      as integer,
    input v-g#news-source-db  as integer
    ):
    run gen-new-code-range-if-neces in hndl-proc-b-code  ( input v-db-num,
    input v-range-type,
    input v-cur-code,
    input v-g#news,
    input v-g#db-num,
    input v-g#news-source-db) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  method public void CreLocCodeRange (
    input v-cur-code     as integer,
    input p-cdrg-type    as character
    ):
    run cre-loc-sc-code-range in hndl-proc-b-code  ( input v-cur-code
      ,input p-cdrg-type) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  method public void MarkUserNeed (
    input p-cur-code     as integer,
    input p-range-type   as character,
    input p-db-num       as integer
    ):
    run mark-used-if-need in hndl-proc-b-code  ( input p-cur-code
      ,input p-range-type
      ,input p-db-num) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  destructor public newbcod ():
    delete object hndl-proc-b-code no-error.
    if error-status:error
      then
    do:
    end.
  end destructor.
end class.
