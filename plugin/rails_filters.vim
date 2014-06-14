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
  let method_pattern = '^\(.*\)def \(.\+\)(\='
  let previous_method = search(method_pattern, 'bncW')
  let next_method = search(method_pattern, 'nW')

  if previous_method != 0
    let matches = matchlist(getline(previous_method), method_pattern)

    if len(matches) > 2
      let indentation = matches[1]
      let end_line = search(indentation . 'end', 'ncW')

      if previous_method < end_line && next_method > end_line
        let method_name = matches[2]
      endif
    endif
  endif

  return method_name
endfunction
