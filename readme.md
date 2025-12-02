# Appstage CLI

[![Gem Version](https://badge.fury.io/rb/appstage.svg)](https://badge.fury.io/rb/appstage)
[![CI](https://github.com/p4innovation/appstage-cli/actions/workflows/ci.yml/badge.svg)](https://github.com/p4innovation/appstage-cli/actions/workflows/ci.yml)

A CLI gem to allow uploading to project live builds on [appstage.io](https://wwww.appstage.io). The intention of this Gem is for use with CI and command line builds. A successful build can use the gem to upload the completed build to the live build area on an appstage project and make it available instantly to clients without any developer intervention. 

## Installation & usage

Install:

```
gem install appstage
```

Update your Gemfile:

```
gem 'appstage', '->1.0.0'
```

## Usage

To see command line options:

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
    -h, --host HOSTURL               The appstage host, optional, leave blank to use live server
```

Example shell script used within a CI build script:-

```
gem update appstage

# Delete current live ipas using regex
appstage -d .ipa -h $APPSTAGE_HOST -j $APPSTAGE_JWT

# Upload new build files
FILES=build/*.ipa
for f in $FILES
do
	appstage -u $f -h $APPSTAGE_HOST -j $APPSTAGE_JWT
done
```

## History

### V1.0.14

* Improved upload speed and reliability by utilising direct signed CDN upload


## License & Copyright

- Copyright:: Copyright (c) 2025 P4 Innovation Ltd
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