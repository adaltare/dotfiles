if command -v brew >/dev/null 2>&1; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if command -v /opt/local/bin/port >/dev/null 2>&1; then
  export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
fi
