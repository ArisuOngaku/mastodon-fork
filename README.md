![Toot Party](app/javascript/images/logo_full_light.svg)
========

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/ArisuOngaku/toot.party.svg)][releases]
[![CircleCI](https://img.shields.io/circleci/build/github/ArisuOngaku/toot.party/toot-party)][circleci]
[![Translation status](http://translation.toot.party/widgets/toot-party/-/svg-badge.svg)][translation]

[releases]: https://github.com/ArisuOngaku/toot.party/releases
[circleci]: https://circleci.com/gh/ArisuOngaku/toot.party
[translation]: https://translation.toot.party/engage/toot-party/?utm_source=widget

Toot Party is a **free, open-source social network server** based on Mastodon (which is based on ActivityPub). We aim to stay up to date with new releases of Mastodon.

[Learn more about Mastodon](https://github.com/tootsuite/mastodon/README.md)

## Contributing

Mastodon and Toot Party are **free, open source software** licensed under **AGPLv3**.

If your contribution would be relevant to the original Mastodon project, [please make it there](https://github.com/tootsuite/mastodon).

You can open issues for bugs you've found or features you think are missing. You can also submit pull requests to this repository, or [submit translations on Weblate](https://translation.toot.party/projects/toot-party). To get started, take a look at [CONTRIBUTING.md](CONTRIBUTING.md). Unlike the original project, you can't get paid for your contributions here (however you are free to make them there too).

## License

Mastodon Copyright (C) 2016-2019 Eugen Rochko & other Mastodon contributors (see [AUTHORS.md](AUTHORS.md))
Toot Party modifications Copyright (C) 2019 Alice Gaudon & other Toot Party contributors (see [TOOT_AUTHORS.md](TOOT_AUTHORS.md))

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

## What's different between Mastodon and Toot Party ?

You can check the differences by cloning this repository and running these commands:
```
git remote add -f upstream https://github.com/tootsuite/mastodon.git
git remote update
git diff toot-party remotes/upstream/master
```
