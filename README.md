# envctl: Your Faithful Environment Variables Manager

A helpful tool to load (export) environment variables from a .env file, and manage them on the fly

## A Little Example

Say you have an app using a set of environment variables:

```bash
MYAPP_USERNAME=Mario
MYAPP_SECRET=itsme
```

You can either:
* copy the existing file to `~/.envctl/envs/myapp.env`
* symlink it: `ln -s ~/path/to/myapp.env ~/.envctl/envs/myapp.env`
* create it from scratch by running:

```bash
envctl edit myapp
```

You can then view available environments

```bash
envctl ls
```

Finally you can decide to apply it

```bash
envctl set myapp
```

And once you are done

```bash
envctl unset myapp
```

Easy peasy!

## Installation

Run once:

```bash
mkdir -p ~/envctl/envs/ && curl https://raw.githubusercontent.com/norvan/envctl/main/envctl.sh > ~/.envctl/envctl.sh
echo "source ~/.envctl/envctl.sh" >> ~/.bashrc
source ~/.envctl/envctl.sh
```
