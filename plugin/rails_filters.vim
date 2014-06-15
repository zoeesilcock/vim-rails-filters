function! s:rails_filters()
  " Identify which method we are in now.
  let method = s:get_current_method()

  " Search for filters in the file.
  let filter_methods = s:get_filters_for(method)
  " Take only and except into account.
  " Extract information about each filter.
  " Display the information in a quick fix window.
  call setqflist(s:build_quickfix_list(filter_methods), 'r')
  cwindow
endfunction

command! RailsFilters call s:rails_filters()

function! s:get_current_method()
  let method_name = ''
  let method_pattern = '^.*def \([^(]\+\)'
  let original_pos = getpos('.')
  let target_line = original_pos[1]

  if match(getline(target_line), method_pattern) != -1
    let target_line += 1
  endif

  call cursor(target_line, 1)

  let def_line = searchpair('def', '', 'end', 'bnW')
  let matches = matchlist(getline(def_line), method_pattern)

  if len(matches) > 1
    let method_name = matches[1]
  end

  call setpos('.', original_pos)

  return method_name
endfunction

function! s:get_filters_for(method)
  let original_pos = getpos('.')
  let filter_pattern = '^.*\(\(before_\|after_\|around_\)\(filter\|action\)\)'

  call cursor(1, 1)

  let line = -1
  let methods = []
  while line != 0
    let line = search(filter_pattern, 'W')
    let method = s:extract_method_from_filter(getline(line))

    if len(method) > 0
      call add(methods, method)
    endif
  endwhile

  call setpos('.', original_pos)

  return methods
endfunction

function! s:extract_method_from_filter(input)
  let method = ''
  let pattern = '^\s*.*\s\+:\([^,]*\)'

  let matches = matchlist(a:input, pattern)

  if len(matches) > 0
    let method = matches[1]
  endif

  return method
endfunction

function! s:build_quickfix_list(methods)
  let quickfix_list = []
  let original_pos = getpos('.')

  for m in a:methods
    call cursor(1, 1)
    let line = search('^.*def ' . m, 'W')

    if line != 0
      call add(quickfix_list, {'lnum': line, 'bufnr': bufnr('%'), 'text': getline(line)})
    endif
  endfor

  call setpos('.', original_pos)
  return quickfix_list
endfunction
