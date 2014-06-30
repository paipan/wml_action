# WMLAction

WMLAction is WML parser and modifier. WML modifications described as simple extension to WML. If you have many WML files and want to do some modifications to them all, then you can give it a try.

## Features

### Changing/adding attributes
File:
```
[unit]
  hp=10
  level=1
[/unit]
```
Modifications:
```
[unit]
  hp=25
  race="human"
  {REGENERATES}
[/unit]
```
Becomes:
```
[unit]
  hp=25
  level=1
  race="human"
  {REGENERATES}
[/unit]
```
### Adding tags
File:
```
[unit]
[/unit]
```
Modifications:
```
[unit]
  + [attack]
    damage=1
  [/attack]
[/unit]
```
Becomes:
```
[unit]
  [attack]
    damage=1
  [/attack]
[/unit]
```

### Operations on tags with filters
File:
```
[unit]
  [attack]
    range=ranged
  [/attack]
  [attack]
    range=melee
  [/attack]
[/unit]
```
Modifications:
```
[unit]
  [attack]
    / range=melee
    damage=10
  [/attack]
[/unit]
```
Becomes:
```
[unit]
  [attack]
    range=ranged
  [/attack]
  [attack]
    range=melee
    damage=10
  [/attack]
[/unit]
```

### Expressions
File:
```
[unit]
  hp=10
  level=2
  name=_ "Archer"
[/unit]
```
Modifications:
```
[unit]
  hp=`(hp+level)*2`
  name=`"Tough ".name`
[/unit]
```
Becomes:
```
[unit]
  hp=24
  level=2
  name=_ "Tough Archer"
[/unit]
```

## Installation

Add this line to your application's Gemfile:

    gem 'wml_action'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wml_action

## Usage

    $ wml_action modify wml_file actions_file

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
