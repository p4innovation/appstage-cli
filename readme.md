# Appstage CLI

[![Gem Version](https://badge.fury.io/rb/appstage.svg)](https://badge.fury.io/rb/appstage)

A CLI gem to allow uploading to project live builds on [appstage.io](https://wwww.appstage.io)

## Installation & usage

Install:

```
gem install appstage
```

Update your Gemfile:

```
gem 'appstage', '->0.8.0'
```

## Usage

```
$ appstage
Usage: appstage <command> [options]
 Commands:-
    -u, --upload [PATTERN]           Upload a file to the live build release
    -d, --delete [PATTERN]           Delete a file to the live build release
    -l, --list [PATTERN]             Lists files the live build release
    -v, --version                    Display the gem version
        --help                       Show this help message
 Options:-
    -j, --jwttoken JWT               Your appstage.io account JWT token
    -p, --project_id ID              Your appstage.io project id
    -h, --host HOSTURL               The appstage host, optional, leave blank to use live server
```


## License & Copyright

- Copyright:: Copyright (c) 2023-2024 P4 Innovation Ltd
- License:: Apache License, Version 2.0

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```