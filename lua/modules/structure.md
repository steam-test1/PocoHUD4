Modules
===

Lifecycle
---
- `Init` (leave as is)
- `PostInit`
 - install `Hook`s
 - copy required options to `self.C`
- do things through `Update` / `Hook`
- `PostDestroy`
 - free items & clean up things
- `Destroy` (leave as is)
