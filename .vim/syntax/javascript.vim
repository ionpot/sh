let b:current_syntax = 'javascript'
colorscheme jsvc

let s:eof = '{$}'
let s:handlers = {}

function! s:get_cached(key)
    return get(s:cache, a:key, '')
endfunction

function! s:escape(char)
    if a:char ==# "\n"
        return '\n'

    elseif a:char ==# s:eof
        return ''
    endif

    return escape(a:char, '\*[]')
endfunction

function! s:is_alpha(char)
    return a:char =~? '[a-z]'
endfunction

function! s:is_alphanum(char)
    return a:char =~? '\w'
endfunction

function! s:is_ws(char)
    return a:char =~? '\s'
endfunction

function! s:match_expr(group, str, args)
    let pattern = ' *' . a:str . '*'
    let arg_str = ''

    if !empty(a:args)
        let arg_str = ' ' . a:args
    endif

    exe 'syn match ' . a:group . pattern . arg_str
endfunction

function! s:add_match(group, str)
    let cached = s:get_cached(a:str)

    if cached !=# a:group
        let s:cache[a:str] = a:group

        call s:match_expr(a:group, a:str, '')
    endif
endfunction

function! s:dead(text)
    let s:dead_buf .= s:escape(a:text)
endfunction

function! s:set_dead(text)
    let s:dead_buf = ''

    call s:dead(a:text)
endfunction

function! s:flush_dead()
    let str = s:dead_buf

    let s:dead_buf = ''

    return str
endfunction

function! s:hold(text)
    let s:hold_buf .= s:escape(a:text)
endfunction

function! s:flush_hold()
    let hold = s:hold_buf
    let s:hold_buf = ''

    return hold
endfunction

function! s:has_hold()
    return !empty(s:hold_buf)
endfunction

function! s:append(char)
    let s:func.text .= s:escape(a:char)
endfunction

function! s:append_text(text)
    let s:func.text .= a:text
endfunction

function! s:new_cluster(contains)
    let cached = s:get_cached(a:contains)

    if empty(cached)
        let s:c_count += 1

        let name = 'JSVC_c' . s:c_count
        let args = ' contains=' . a:contains

        exe 'syn cluster ' . name . args

        let name = '@' . name

        let s:cache[a:contains] = name

        return name
    endif

    return cached
endfunction

function! s:new_func()
    if s:f_count
        let contains = s:func.contains
        let contains = s:new_cluster(contains)

    else
        let contains = 'JSVC_x,JSVC_dead,JSVC_prop'
    endif

    let id = 'JSVC_f' . s:f_count

    let s:f_count += 1

    let obj = {}

    let obj.id = id
    let obj.name = ''
    let obj.text = ''
    let obj.open = {}
    let obj.index = 0
    let obj.in_var = 0
    let obj.contains = contains
    let obj.group = ''

    return obj
endfunction

function! s:add_group(func, group)
    let a:func.contains .= ',' . a:group
endfunction

function! s:new_group(func, depth)
    let s:g_count += 1

    let name = 'JSVC_g' . s:g_count

    let a:func.group = name
    call s:add_group(a:func, name)

    exe 'hi link ' . name . ' JSVC_' . a:depth

    return name
endfunction

function! s:match_var_at(name, depth)
    let func = s:funcs[a:depth]

    let key = a:depth . a:name
    let cached = s:get_cached(key)

    if empty(cached)
        let group = func.group
        let args = ''

        if empty(group)
            let group = s:new_group(func, a:depth)
        endif

        let s:cache[key] = group

        if s:depth
            let args = 'contained'
        endif

        let str = '\<' . a:name . '\>'

        call s:match_expr(group, str, args)

    else
        call s:add_group(func, cached)
    endif
endfunction

function! s:match_var(name)
    call s:match_var_at(a:name, s:depth)
endfunction

function! s:match_dead(text)
    call s:add_match('JSVC_dead', a:text)
endfunction

function! s:match_prop(text)
    call s:add_match('JSVC_prop', a:text)
endfunction

function! s:match_func(func)
    let args = 'contains=' . a:func.contains

    if s:depth
        let args .= ' containedin=' . s:func.id
    endif

    call s:match_expr(a:func.id, a:func.text, args)
endfunction

function! s:push_func()
    let s:func = s:new_func()

    let s:depth += 1

    let s:funcs[s:depth] = s:func
endfunction

function! s:pop_func()
    let func = s:func

    let s:depth -= 1

    let s:func = s:funcs[s:depth]

    call s:match_func(func)

    call s:append_text(func.text)
endfunction

function! s:handle(char)
    call s:handlers[s:state](a:char)
endfunction

function! s:set_state(name)
    let s:state = a:name
endfunction

function! s:to_state(name, char)
    call s:set_state(a:name)
    call s:handle(a:char)
endfunction

function! s:push_state(name)
    let s:saved = s:state

    call s:set_state(a:name)
endfunction

function! s:push_to_state(name, char)
    call s:push_state(a:name)
    call s:handle(a:char)
endfunction

function! s:pop_state()
    call s:set_state(s:saved)
endfunction

function! s:pop_to_state(char)
    call s:pop_state()
    call s:handle(a:char)
endfunction

function! s:begin_dead(char, name)
    let s:in_dead = 1

    call s:set_dead(a:char)

    call s:push_state(a:name)
endfunction

function! s:abort_dead(char)
    let s:in_dead = 0

    let text = s:flush_dead()
    call s:append_text(text)

    call s:pop_to_state(a:char)
endfunction

function! s:end_dead()
    if s:in_regex
        call s:set_state('regex_end')

    else
        let s:in_dead = 0

        let text = s:flush_dead()

        call s:append_text(text)
        call s:match_dead(text)

        call s:pop_state()
    endif
endfunction

function! s:check_dead(char)
    if a:char =~# "['\"]"
        let s:delim = a:char

        call s:begin_dead(a:char, 'until_delim')

    elseif a:char ==# '/'
        if s:is_alphanum(s:last_nonws)
            call s:begin_dead(a:char, 'comment')

        else
            call s:begin_dead(a:char, 'regex')
        endif
    endif
endfunction

function! s:which_comment(char)
    if a:char ==# '/'
        return 'comment_l'

    elseif a:char ==# '*'
        return 'comment_b'

    else
        return ''
    endif
endfunction

function! s:handlers.until_delim(char) dict
    call s:dead(a:char)

    if a:char ==# '\'
        let s:bs_count += 1

    else
        let esc = s:bs_count % 2
        let s:bs_count = 0

        if a:char ==# s:delim
            if !esc
                call s:end_dead()
            endif
        endif
    endif
endfunction

function! s:handlers.regex(char) dict
    call s:dead(a:char)

    let state = s:which_comment(a:char)

    if empty(state)
        let s:in_regex = 1
        let s:delim = '/'

        call s:set_state('until_delim')

    else
        call s:set_state(state)
    endif
endfunction

function! s:handlers.regex_end(char) dict
    if s:is_alpha(a:char)
        call s:dead(a:char)

    else
        let s:in_regex = 0

        call s:end_dead()
        call s:handle(a:char)
    endif
endfunction

function! s:handlers.comment(char) dict
    let state = s:which_comment(a:char)

    if empty(state)
        call s:abort_dead(a:char)

    else
        call s:dead(a:char)

        call s:set_state(state)
    endif
endfunction

function! s:handlers.comment_l(char) dict
    call s:dead(a:char)

    if a:char ==# "\n"
        call s:end_dead()
    endif
endfunction

function! s:handlers.comment_b(char) dict
    call s:dead(a:char)

    if a:char ==# '/'
        if s:last_char ==# '*'
            call s:end_dead()
        endif
    endif
endfunction

function! s:handlers.string_s(char) dict
    call s:dead(a:char)

    call s:append(a:char)

    if a:char ==# "'"
        call s:end_dead()
    endif
endfunction

function! s:handlers.string_d(char) dict
    call s:dead(a:char)

    call s:append(a:char)

    if a:char ==# '"'
        call s:end_dead()
    endif
endfunction

function! s:open(char)
    let i = s:func.index + 1
    let s:func.open[i] = a:char
    let s:func.index = i
endfunction

function! s:opened()
    return get(s:func.open, s:func.index, '')
endfunction

function! s:close()
    let s:func.index -= 1
endfunction

function! s:handlers.scope(char) dict
    if s:is_alpha(a:char)
        return s:to_state('token', a:char)
    endif

    call s:append(a:char)

    if a:char ==# ','
        let open = s:opened()

        if empty(open)
            call s:set_state('var_lval')

        elseif open ==# '{'
            call s:set_state('obj_lval')
        endif

    elseif a:char ==# ';'
        let s:func.in_var = 0

    elseif a:char =~# '[(\[]'
        call s:open(a:char)

    elseif a:char =~# '[)\]]'
        call s:close()

    elseif a:char ==# '{'
        if s:last_nonws =~# '[)a-z]'
            call s:open('B')

        else
            call s:open(a:char)

            call s:set_state('obj_lval')
        endif

    elseif a:char ==# '}'
        let open = s:opened()

        if empty(open)
            call s:set_state('func_end')

        else
            call s:close()
        endif
    endif
endfunction

function! s:handlers.token(char) dict
    if s:is_alphanum(a:char)
        call s:hold(a:char)

    else
        let hold = s:flush_hold()

        if hold ==# 'function'
            call s:push_func()
            call s:append_text(hold)

            call s:to_state('func_def', a:char)

        elseif hold ==# 'var'
            call s:append_text(hold . a:char)

            let s:func.in_var = 1

            call s:set_state('var_lval')

        else
            call s:append_text(hold)

            call s:to_state('scope', a:char)
        endif
    endif
endfunction

function! s:handlers.var_lval(char) dict
    call s:append(a:char)

    if s:is_alphanum(a:char)
        call s:hold(a:char)

    else
        if s:has_hold()
            call s:match_var(s:flush_hold())
        endif

        if a:char ==# ';'
            let s:func.in_var = 0

            call s:set_state('scope')

        elseif a:char ==# '='
            call s:set_state('scope')
        endif
    endif
endfunction

function! s:handlers.obj_lval(char) dict
    call s:append(a:char)

    if a:char ==# ':'
        if s:has_hold()
            let text = s:flush_hold() . a:char
            call s:match_prop(text)
        endif

        call s:set_state('scope')

    elseif a:char ==# '}'
        call s:close()

        call s:set_state('scope')

    elseif s:is_alphanum(a:char)
        call s:hold(a:char)
    endif
endfunction

function! s:handlers.func_def(char) dict
    call s:append(a:char)

    if a:char ==# '('
        call s:set_state('params')

    elseif s:is_alphanum(a:char)
        let s:func.name .= a:char
    endif
endfunction

function! s:handlers.params(char) dict
    call s:append(a:char)

    if a:char ==# '{'
        call s:set_state('scope')

    elseif s:is_alphanum(a:char)
        call s:hold(a:char)

    elseif s:has_hold()
        call s:match_var(s:flush_hold())
    endif
endfunction

function! s:handlers.func_end(char) dict
    if s:is_ws_char
        call s:append(a:char)

    elseif s:depth
        let name = s:func.name

        let at = s:depth - 1
        let f = s:funcs[at]

        if !empty(name)
            let open = s:opened()

            if a:char ==# '('
                call s:match_var(name)

            elseif f.in_var
                call s:match_var(name)

            elseif empty(open)
                call s:match_var_at(name, at)

            else
                call s:match_var(name)
            endif
        endif

        call s:pop_func()

        call s:to_state('scope', a:char)
    endif
endfunction

function! s:begin()
    let s:cache = {}
    let s:funcs = {}

    let s:state = ''
    let s:saved = ''

    let s:c_count = 0
    let s:f_count = 0
    let s:g_count = 0
    let s:bs_count = 0

    let s:depth = 0
    let s:state_index = 0
    let s:in_dead = 0
    let s:in_regex = 0

    let s:dead_buf = ''
    let s:hold_buf = ''

    let s:last_char = ''
    let s:last_nonws = ''

    let s:func = s:new_func()
    let s:funcs[0] = s:func

    call s:set_state('scope')

    let lines = getline(0, '$')
    let line_count = len(lines)
    let line_index = 0
    let line_last = line_count - 1

    while line_index < line_count
        let line = lines[line_index]
        let line_length = len(line)

        let char_index = 0

        while char_index < line_length
            let skip = 0
            let char = line[char_index]
            let s:is_ws_char = s:is_ws(char)

            if !s:in_dead
                call s:check_dead(char)

                let skip = s:in_dead
            endif

            if !skip
                call s:handle(char)
            endif

            let s:last_char = char

            if !s:is_ws_char
                let s:last_nonws = char
            endif

            let char_index += 1
        endwhile

        if line_index < line_last
            let s:is_ws_char = 1

            call s:handle("\n")
        endif

        let line_index += 1
    endwhile

    call s:handle(s:eof)
endfunction

function! JSVC_scan()
    syn clear

    call s:begin()

    syn match JSVC_x /\.\w\+/
endfunction

function! JSVC_setup()
    nnoremap <buffer> ; :call JSVC_scan()<CR>
    "imap <buffer> <C-[> <C-[>;

    call JSVC_scan()
endfunction
