function! s:rails_filters()
  " Identify which method we are in now.
  echo s:get_current_method()

  " Search for filters in the file.
  " Take only and except into account.
  " Extract information about each filter.
  " Display the information in a quick fix window.
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
