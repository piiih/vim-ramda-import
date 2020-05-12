let g:ramdaFunctionsList = ['F', 'T', '__', 'add', 'addIndex', 'adjust', 'all', 'allPass', 'always', 'and', 'andThen', 'any', 'anyPass', 'ap',
      \'aperture', 'append', 'apply', 'applySpec', 'applyTo', 'ascend', 'assoc', 'assocPath', 'binary', 'bind', 'both', 'call', 'chain', 'clamp',
      \'clone', 'comparator', 'complement', 'compose', 'composeWith', 'concat', 'cond', 'construct', 'constructN', 'converge', 'countBy', 'curry',
      \'curryN', 'dec', 'defaultTo', 'descend', 'difference', 'differenceWith', 'dissoc', 'dissocPath', 'divide', 'drop', 'dropLast', 'dropLastWhile',
      \'dropRepeats', 'dropRepeatsWith', 'dropWhile', 'either', 'empty', 'endsWith', 'eqBy', 'eqProps', 'equals', 'evolve', 'filter', 'find',
      \'findIndex', 'findLast', 'findLastIndex', 'flatten', 'flip', 'forEach', 'forEachObjIndexed', 'fromPairs', 'groupBy', 'groupWith', 'gt', 'gte',
      \'has', 'hasIn', 'hasPath', 'head', 'identical', 'identity', 'ifElse', 'inc', 'includes', 'index', 'indexBy', 'indexOf', 'init', 'innerJoin',
      \'insert', 'insertAll', 'intersection', 'intersperse', 'into', 'invert', 'invertObj', 'invoker', 'is', 'isEmpty', 'isNil', 'join', 'juxt', 'keys',
      \'keysIn', 'last', 'lastIndexOf', 'length', 'lens', 'lensIndex', 'lensPath', 'lensProp', 'lift', 'liftN', 'lt', 'lte', 'map', 'mapAccum', 'mapAccumRight',
      \'mapObjIndexed', 'match', 'mathMod', 'max', 'maxBy', 'mean', 'median', 'memoizeWith', 'mergeAll', 'mergeDeepLeft', 'mergeDeepRight', 'mergeDeepWith',
      \'mergeDeepWithKey', 'mergeLeft', 'mergeRight', 'mergeWith', 'mergeWithKey', 'min', 'minBy', 'modulo', 'move', 'multiply', 'nAry', 'negate', 'none',
      \'not', 'nth', 'nthArg', 'o', 'objOf', 'of', 'omit', 'once', 'or', 'otherwise', 'over', 'pair', 'partial', 'partialRight', 'partition', 'path', 'pathEq',
      \'pathOr', 'pathSatisfies', 'paths', 'pick', 'pickAll', 'pickBy', 'pipe', 'pipeWith', 'pluck', 'prepend', 'product', 'project', 'prop', 'propEq', 'propIs',
      \'propOr', 'propSatisfies', 'props', 'range', 'reduce', 'reduceBy', 'reduceRight', 'reduceWhile', 'reduced', 'reject', 'remove', 'repeat', 'replace',
      \'reverse', 'scan', 'sequence', 'set', 'slice', 'sort', 'sortBy', 'sortWith', 'split', 'splitAt', 'splitEvery', 'splitWhen', 'splitWhenever', 'startsWith',
      \'subtract', 'sum', 'symmetricDifference', 'symmetricDifferenceWith', 'tail', 'take', 'takeLast', 'takeLastWhile', 'takeWhile', 'tap', 'test', 'thunkify',
      \'times', 'toLower', 'toPairs', 'toPairsIn', 'toString', 'toUpper', 'transduce', 'transpose', 'traverse', 'trim', 'tryCatch', 'type', 'unapply', 'unary',
      \'uncurryN', 'unfold', 'union', 'unionWith', 'uniq', 'uniqBy', 'uniqWith', 'unless', 'unnest', 'until', 'update', 'useWith', 'values', 'valuesIn', 'view',
      \'when', 'where', 'whereEq', 'without', 'xor', 'xprod', 'zip', 'zipObj', 'zipWith']

function! ImportFunction()
  let currentWord = expand('<cword>')

  if !s:isValidFunction(currentWord)
    echoerr "[Error] Coundn't find a function named `" . currentWord . "`"
    return
  endif

  let endImportLineNumber = search("\}.*from.*\'ramda\'$",'n')

  let startImportLineNumber = s:FindStartLineNumber(endImportLineNumber, "import")

  let importList = s:GetImportContent("import")

  let functionAlreadyImported = index(importList, currentWord) >= 0

  if functionAlreadyImported
    echo "[Info] Function `" . currentWord . "` is already imported"
    return
  endif

  let importExists = endImportLineNumber > 0

  call add(importList, currentWord)

  if !importExists
    call append(0, "import { " . currentWord . " } from 'ramda'")
    return
  endif

  let sortedList = sort(importList, "s:sortByAsc")

  let completeImport = ''

  if startImportLineNumber != endImportLineNumber || len(sortedList) > 3
    let completeImport = s:BuildMultilineImport(sortedList, "import")

    if startImportLineNumber == endImportLineNumber
      for i in range(startImportLineNumber, startImportLineNumber + len(sortedList) - 1)
        call append(i, '')
      endfor
    else
      call append(startImportLineNumber, '')
    endif
  else
    let completeImport = s:BuildOnelineImport(sortedList, "import")
  endif

  call setline(startImportLineNumber, completeImport)
endfunction

function! RequireFunction()
  let currentWord = expand('<cword>')

  if !s:isValidFunction(currentWord)
    echoerr "[Error] Coundn't find a function named `" . currentWord . "`"
    return
  endif

  let endImportLineNumber = search("\}.*require\(\'ramda\'\)$",'n')

  let startImportLineNumber = s:FindStartLineNumber(endImportLineNumber, "require")

  let importList = s:GetImportContent("require")

  let functionAlreadyImported = index(importList, currentWord) >= 0

  if functionAlreadyImported
    echo "[Info] Function `" . currentWord . "` is already imported"
    return
  endif

  let importExists = endImportLineNumber > 0

  call add(importList, currentWord)

  if !importExists
    call append(0, "const { " . currentWord . " } = require('ramda')")
    return
  endif

  let sortedList = sort(importList, "s:sortByAsc")

  let completeImport = ''

  if startImportLineNumber != endImportLineNumber || len(sortedList) > 3
    let completeImport = s:BuildMultilineImport(sortedList, "require")

    if startImportLineNumber == endImportLineNumber
      for i in range(startImportLineNumber, startImportLineNumber + len(sortedList) - 1)
        call append(i, '')
      endfor
    else
      call append(startImportLineNumber, '')
    endif
  else
    let completeImport = s:BuildOnelineImport(sortedList, "require")
  endif

  call setline(startImportLineNumber, completeImport)
endfunction

function! CheckImportedFunctions(importList)
  let endImportLineNumber = search("\}.*require\(\'ramda\'\)$",'n')

  let importList = s:GetImportContent()

  call clearmatches()

  highlight notImportedFunction ctermbg=red guibg=red
  for i in g:ramdaFunctionsList
    if index(importList, i) < 0
      call matchadd("notImportedFunction", '\%>'.endImportLineNumber.'l\zs\<'.i.'\>\ze')
    endif
  endfor
endfunction

function! s:BuildOnelineImport(importList, importType)
  let sortedContent = join(a:importList, ", ")

  if a:importType == "import"
    return "import { " . sortedContent . " } from 'ramda'"
  else
    return "const { " . sortedContent . " } = require('ramda')"
  endif
endfunction

function! s:BuildMultilineImport(importList, importType)
  let startImportString = ""
  let endImportString = ""

  if a:importType == "import"
    let startImportString = "import {"
    let endImportString = "} from 'ramda'"
  else
    let startImportString = "const {"
    let endImportString = "} = require('ramda')"
  endif

  let breakLineList = map(a:importList, '"  " . v:val . ","')

  call insert(breakLineList, startImportString)
  call add(breakLineList, endImportString)

  return breakLineList
endfunction

function! s:isValidFunction(currentWord)
  return index(g:ramdaFunctionsList, a:currentWord) >= 0
endfunction

function! s:FindStartLineNumber(endLineNumber, importType)
  let importString = ""

  if a:importType == "import"
    let importString = 'import {'
  else
    let importString = 'const {'
  endif

  let currentLine = a:endLineNumber
  while match(getline(currentLine), importString) < 0
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

function! s:GetImportContent(importType)
  let endImportLineNumber = 0

  if a:importType == "import"
    let endImportLineNumber = search("\}.*from.*\'ramda\'$",'n')
  else
    let endImportLineNumber = search("\}.*require\(\'ramda\'\)$",'n')
  endif

  let startImportLineNumber = s:FindStartLineNumber(endImportLineNumber, a:importType)

  if endImportLineNumber > startImportLineNumber
    let importList = getline(startImportLineNumber+1, endImportLineNumber-1)
    let importListWithoutComma = map(importList, 'substitute(v:val, " ", "", "g")')
    let importListSanitized = map(importListWithoutComma, 'substitute(v:val, ",", "", "g")')

    return importListSanitized
  endif

  let importWithBrackets = matchstr(getline(endImportLineNumber), "\{.*\}")
  let importWithCloseBracket = substitute(importWithBrackets, "\{", "", "")
  let importWithoutBrackets = substitute(importWithCloseBracket, "\}", "", "")
  let importSanitized = substitute(importWithoutBrackets, " ", "", "g")
  let importListSanitized = split(importSanitized, ',')

  return importListSanitized
endfunction
