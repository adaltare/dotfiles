function fish_prompt
    string join '' -- (set_color green) (prompt_pwd --full-length-dirs 2) (set_color --reset) (set_color blue) ' $> '
end
