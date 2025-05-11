# ccui

## Install

CC: Tweaked Advanced computer/turtle is recommended.

### Interactive installer
```bash
wget run https://raw.githubusercontent.com/nomnivore/cc-ui/main/release/install.lua
```

### Release version
```bash
wget run https://raw.githubusercontent.com/nomnivore/cc-ui/main/release/install.lua -r
```

### Development version
```bash
wget run https://raw.githubusercontent.com/nomnivore/cc-ui/main/release/install.lua -d
```


## Usage

### Quick start

```lua
local ui = require("ccui")

local app = ui.new()

app.root
  :add(ui.components.Label.new{
    text = "Hello World!",
  })
  :add(ui.components.Button.new{
    text = "Close",
    y = 3,
  }
    :onClick(function(_self)
      app:stop()
    end)
  )

app:start()
```