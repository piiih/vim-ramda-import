let g:ramdaFunctionsList = ['F', 'T', '__', 'add', 'addIndex', 'adjust', 'all', 'allPass', 'always', 'and', 'andThen', 'any', 'anyPass', 'ap', 'aperture', 'append', 'apply', 'applySpec', 'applyTo', 'ascend', 'assoc', 'assocPath', 'binary', 'bind', 'both', 'call', 'chain', 'clamp', 'clone', 'comparator', 'complement', 'compose', 'composeWith', 'concat', 'cond', 'construct', 'constructN', 'converge', 'countBy', 'curry', 'curryN', 'dec', 'defaultTo', 'descend', 'difference', 'differenceWith', 'dissoc', 'dissocPath', 'divide', 'drop', 'dropLast', 'dropLastWhile', 'dropRepeats', 'dropRepeatsWith', 'dropWhile', 'either', 'empty', 'endsWith', 'eqBy', 'eqProps', 'equals', 'evolve', 'filter', 'find', 'findIndex', 'findLast', 'findLastIndex', 'flatten', 'flip', 'forEach', 'forEachObjIndexed', 'fromPairs', 'groupBy', 'groupWith', 'gt', 'gte', 'has', 'hasIn', 'hasPath', 'head', 'identical', 'identity', 'ifElse', 'inc', 'includes', 'index', 'indexBy', 'indexOf', 'init', 'innerJoin', 'insert', 'insertAll', 'intersection', 'intersperse', 'into', 'invert', 'invertObj', 'invoker', 'is', 'isEmpty', 'isNil', 'join', 'juxt', 'keys', 'keysIn', 'last', 'lastIndexOf', 'length', 'lens', 'lensIndex', 'lensPath', 'lensProp', 'lift', 'liftN', 'lt', 'lte', 'map', 'mapAccum', 'mapAccumRight', 'mapObjIndexed', 'match', 'mathMod', 'max', 'maxBy', 'mean', 'median', 'memoizeWith', 'mergeAll', 'mergeDeepLeft', 'mergeDeepRight', 'mergeDeepWith', 'mergeDeepWithKey', 'mergeLeft', 'mergeRight', 'mergeWith', 'mergeWithKey', 'min', 'minBy', 'modulo', 'move', 'multiply', 'nAry', 'negate', 'none', 'not', 'nth', 'nthArg', 'o', 'objOf', 'of', 'omit', 'once', 'or', 'otherwise', 'over', 'pair', 'partial', 'partialRight', 'partition', 'path', 'pathEq', 'pathOr', 'pathSatisfies', 'paths', 'pick', 'pickAll', 'pickBy', 'pipe', 'pipeWith', 'pluck', 'prepend', 'product', 'project', 'prop', 'propEq', 'propIs', 'propOr', 'propSatisfies', 'props', 'range', 'reduce', 'reduceBy', 'reduceRight', 'reduceWhile', 'reduced', 'reject', 'remove', 'repeat', 'replace', 'reverse', 'scan', 'sequence', 'set', 'slice', 'sort', 'sortBy', 'sortWith', 'split', 'splitAt', 'splitEvery', 'splitWhen', 'splitWhenever', 'startsWith', 'subtract', 'sum', 'symmetricDifference', 'symmetricDifferenceWith', 'tail', 'take', 'takeLast', 'takeLastWhile', 'takeWhile', 'tap', 'test', 'thunkify', 'times', 'toLower', 'toPairs', 'toPairsIn', 'toString', 'toUpper', 'transduce', 'transpose', 'traverse', 'trim', 'tryCatch', 'type', 'unapply', 'unary', 'uncurryN', 'unfold', 'union', 'unionWith', 'uniq', 'uniqBy', 'uniqWith', 'unless', 'unnest', 'until', 'update', 'useWith', 'values', 'valuesIn', 'view', 'when', 'where', 'whereEq', 'without', 'xor', 'xprod', 'zip', 'zipObj', 'zipWith']

function! FindImport()
  let currentWord = expand('<cword>')

  let isValidWord = index(g:ramdaFunctionsList, currentWord) >= 0

  if !isValidWord
    echoerr "[Error] Coundn't find a function named `" . currentWord . "`"
    return
  endif

  let endImportLineNumber = search("\}.*require\(\'ramda\'\)$",'n')

  let startImportLineNumber = s:FindStartLineNumber(endImportLineNumber)

  let importExists = endImportLineNumber > 0

  if !importExists
    call append(0, "const { " . currentWord . " } = require('ramda')")
    return
  endif

  let importList = s:GetImportContent(startImportLineNumber, endImportLineNumber)

  let functionAlreadyImported = index(importList, currentWord) >= 0

  if functionAlreadyImported
    echo "[Info] Function `" . currentWord . "` is already imported"
    return
  endif

  call add(importList, currentWord)

  let sortedList = sort(importList, "s:sortByAsc")

  let completeImport = ''

  if len(sortedList) > 3
    let breakLineList = map(sortedList, '"  " . v:val . ","')

    call insert(breakLineList, "const {")
    call add(breakLineList, "} = require('ramda')")

    let completeImport = breakLineList

    if startImportLineNumber == endImportLineNumber
      for i in range(startImportLineNumber, startImportLineNumber + len(sortedList) - 1)
        call append(i, '')
      endfor
    else
      call append(startImportLineNumber, '')
    endif
  else
    let sortedContent = join(sortedList, ", ")

    let completeImport = "const { " . sortedContent . " } = require('ramda')"
  endif

  call setline(startImportLineNumber, completeImport)
endfunction

function! s:FindStartLineNumber(endLineNumber)
  let currentLine = a:endLineNumber
  while match(getline(currentLine), 'const {') < 0
    if currentLine <= 0
      return 0
    endif

    let currentLine -= 1
  endwhile

  return currentLine
endfunction

function! s:sortByAsc(a, b)
  if a:a < a:b
    return -1
  endif

  if a:a > a:b
    return 1
  endif

  return 0
endfunction

function! s:GetImportContent(startLineNumber, endLineNumber)
  if a:endLineNumber > a:startLineNumber
    let importList = getline(a:startLineNumber+1, a:endLineNumber-1)
    let importListWithoutComma = map(importList, 'substitute(v:val, " ", "", "g")')
    let importListSanitized = map(importListWithoutComma, 'substitute(v:val, ",", "", "g")')

    return importListSanitized
  endif

  let importWithBrackets = matchstr(getline(a:endLineNumber), "\{.*\}")
  let importWithCloseBracket = substitute(importWithBrackets, "\{", "", "")
  let importWithoutBrackets = substitute(importWithCloseBracket, "\}", "", "")
  let importSanitized = substitute(importWithoutBrackets, " ", "", "g")
  let importListSanitized = split(importSanitized, ',')

  return importListSanitized
endfunction
