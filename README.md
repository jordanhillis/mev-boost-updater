# MEV-Boost-Updater

[![Version](https://img.shields.io/badge/Version-v1.0-green)](https://github.com/jordanhillis/mev-boost-updater)
[![License: MIT](https://img.shields.io/badge/license-GPL-green)](https://www.gnu.org/licenses/gpl-3.0.en.html)
![Debian](https://img.shields.io/badge/-Debian-red)
![Debian](https://img.shields.io/badge/-Ubuntu-orange)

Easily build and update MEV-Boost from Flashbots

## What is MEV-Boost-Updater?

MEV-Boost-Updater is a tool to help update the MEV-Boost process from Flashbots. MEV-Boost is open source middleware run by validators to access a competitive block-building market. MEV-Boost is an initial implementation of proposer-builder separation (PBS) for proof-of-stake (PoS) Ethereum. You can read more about MEV-Boost [here](https://github.com/flashbots/mev-boost)

## Latest Version

* v1.0

## Prerequisites

Before using this program you will need to have the following packages installed.
* golang
* mev-boost
* git
* wget

To install all required packages enter the following command.

##### Debian/Ubuntu:

```
sudo apt install golang git wget
```

## Installing

You can install MEV-Boost-Updater to any location you wish. It is recommended to install this to your home direction (~)

To install MEV-Boost-Updater please enter the following commands:

```
wget https://raw.githubusercontent.com/jordanhillis/mev-boost-updater/main/mev-boost-updater.sh
chmod +x mev-boost-updater.sh
./mev-boost-updater.sh
```

## Updating

To update MEV-Boost-Updater please run the same commands as described in the "Installing" section.


## Developers

* **Jordan Hillis** - *Lead Developer*

## License

This project is licensed under the GPLv3 License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* This program is not an official program by Flashbots or the Ethereum Foundation

