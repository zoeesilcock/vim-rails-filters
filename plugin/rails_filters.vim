function! s:rails_filters()
  let method = s:get_current_method()

  let filter_lines = s:get_filters_for(method)

  call setqflist(s:build_quickfix_list(filter_lines), 'r')
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

function! s:get_filters_for(method_name)
  let original_pos = getpos('.')
  let filter_pattern = '^.*\(\(before_\|after_\|around_\)\(filter\|action\)\)'

  call cursor(1, 1)

  let line = -1
  let filters = []
  while line != 0
    let line = search(filter_pattern, 'W')
    let method = s:extract_method_from_filter(getline(line))

    if len(method) > 0
      let method_line = search('^.*def ' . method, 'nW')

      call add(filters, {'filter_line': line, 'method_line': method_line})
    endif
  endwhile

  call setpos('.', original_pos)

  return filters
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

function! s:build_quickfix_list(filter_lines)
  let quickfix_list = []
  for filter in a:filter_lines
    let item = {
          \ 'lnum': filter.method_line,
          \ 'bufnr': bufnr('%'),
          \ 'text': s:strip(getline(filter.filter_line))
          \ }

    call add(quickfix_list, item)
  endfor

  return quickfix_list
endfunction

function! s:strip(input_string)
  return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction
