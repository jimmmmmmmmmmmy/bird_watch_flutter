# Homebrew and MySQL configurations
export PATH="/opt/homebrew/opt/mysql@8.4/bin:/opt/homebrew/opt/mysql/bin:$PATH"
export DYLD_LIBRARY_PATH=$(brew --prefix mysql@8.4)/lib:$DYLD_LIBRARY_PATH

# Ruby configurations
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"

# Flutter configuration
export PATH="$PATH:/Users/jamesliu/flutter/bin"

# Add your personal bin directory if needed
export PATH="$PATH:/Users/jamesliubin"
